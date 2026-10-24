// ZigDash relay verifier (3.1, zigdash-3.0.md §5).
//
// A small HTTP service beside the relay broker. It admits a Home only after
// checking a purchase of Pro (Google Play, or the App Store: apple.mjs), then creates the Home's broker
// logins through Mosquitto's dynamic-security plugin: one role confined to
// homes/<id>/#, one client for the hub and one per phone. Phones it paired
// can ask for more phone logins (for the QR code) and remove phones.
//
// It never sees device data: that travels sealed between hub and phones.
// It stores: purchase hash (Play token, or Apple original transaction) → home, and scrypt hashes of phone passwords.
//
// Env: PORT, DB, MQTT_URL, ADMIN_USER, ADMIN_PASSWORD, HUB_URL, PHONE_URL,
//      VERIFY (play | fake), PLAY_PACKAGE, PLAY_PRODUCT, GOOGLE_SA (path to JSON key),
//      APPLE_BUNDLE, APPLE_ENVIRONMENTS (Production[,Sandbox]).

import http from 'node:http';
import crypto from 'node:crypto';
import fs from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import mqtt from 'mqtt';
import { verifyAppleTransaction } from './apple.mjs';

export function createVerifier(env = process.env) {
  const cfg = {
    port: Number(env.PORT || 8787),
    db: env.DB || ':memory:',
    mqttUrl: env.MQTT_URL || 'mqtt://mosquitto:1883',
    adminUser: env.ADMIN_USER || 'admin',
    adminPassword: env.ADMIN_PASSWORD,
    hubUrl: env.HUB_URL || 'mqtts://relay.zigdash.app:8883',
    phoneUrl: env.PHONE_URL || 'wss://relay.zigdash.app/mqtt',
    verify: env.VERIFY || 'play',
    playPackage: env.PLAY_PACKAGE || 'com.giladtamam.zigdash',
    playProduct: env.PLAY_PRODUCT || 'zigdash_pro',
    googleSa: env.GOOGLE_SA,
    appleBundle: env.APPLE_BUNDLE || 'com.giladtamam.zigdash',
    appleEnvironments: (env.APPLE_ENVIRONMENTS || 'Production').split(','),
    maxPhones: Number(env.MAX_PHONES || 5),
    pairPerHour: Number(env.PAIR_PER_HOUR || 10),
  };

  // ---------- storage ----------
  const db = new DatabaseSync(cfg.db);
  db.exec(`
    create table if not exists homes (id text primary key, token_hash text unique, created integer);
    create table if not exists phones (username text primary key, home text, pw_hash text, created integer);
  `);
  const sha = (s) => crypto.createHash('sha256').update(s).digest('hex');
  const secret = () => crypto.randomBytes(24).toString('base64url');
  const hashPw = (pw) => {
    const salt = crypto.randomBytes(16);
    return `${salt.toString('hex')}:${crypto.scryptSync(pw, salt, 32).toString('hex')}`;
  };
  const checkPw = (pw, stored) => {
    const [salt, h] = String(stored).split(':');
    if (!salt || !h) return false;
    const got = crypto.scryptSync(pw, Buffer.from(salt, 'hex'), 32);
    return crypto.timingSafeEqual(got, Buffer.from(h, 'hex'));
  };

  // ---------- the broker's dynamic security ----------
  let admin;
  const pending = new Map();
  function control(commands) {
    const correlationData = crypto.randomBytes(8).toString('hex');
    const tagged = commands.map((c, i) => ({ ...c, correlationData: `${correlationData}-${i}` }));
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => { pending.delete(correlationData); reject(new Error('broker did not answer')); }, 8000);
      pending.set(correlationData, { resolve: (r) => { clearTimeout(timer); resolve(r); }, count: commands.length, got: [] });
      admin.publish('$CONTROL/dynamic-security/v1', JSON.stringify({ commands: tagged }));
    });
  }
  function onControlResponse(_topic, payload) {
    let msg;
    try { msg = JSON.parse(payload.toString()); } catch { return; }
    for (const r of msg.responses || []) {
      const [id] = String(r.correlationData || '').split('-');
      const p = pending.get(id);
      if (!p) continue;
      p.got.push(r);
      if (p.got.length >= p.count) { pending.delete(id); p.resolve(p.got); }
    }
  }
  const failed = (responses) => responses.filter((r) => r.error && !/already exists/i.test(r.error));

  async function createHomeOnBroker(homeId) {
    const role = `home-${homeId}`;
    const acls = ['publishClientSend', 'publishClientReceive', 'subscribePattern', 'unsubscribePattern']
      .map((acltype) => ({ acltype, topic: `homes/${homeId}/#`, priority: 5, allow: true }));
    const r = await control([{ command: 'createRole', rolename: role, acls }]);
    if (failed(r).length) throw new Error(failed(r)[0].error);
  }
  async function createClient(username, password, homeId) {
    const r = await control([{ command: 'createClient', username, password, roles: [{ rolename: `home-${homeId}` }] }]);
    if (failed(r).length) throw new Error(failed(r)[0].error);
  }
  async function setPassword(username, password) {
    const r = await control([{ command: 'setClientPassword', username, password }]);
    if (failed(r).length) throw new Error(failed(r)[0].error);
  }
  async function deleteClient(username) {
    await control([{ command: 'deleteClient', username }]);
  }

  // ---------- Google Play ----------
  let googleToken = null;
  async function googleAccessToken() {
    if (googleToken && googleToken.exp > Date.now() + 60000) return googleToken.value;
    const sa = JSON.parse(fs.readFileSync(cfg.googleSa, 'utf8'));
    const now = Math.floor(Date.now() / 1000);
    const enc = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
    const unsigned = `${enc({ alg: 'RS256', typ: 'JWT' })}.${enc({
      iss: sa.client_email, scope: 'https://www.googleapis.com/auth/androidpublisher',
      aud: 'https://oauth2.googleapis.com/token', iat: now, exp: now + 3600,
    })}`;
    const sig = crypto.sign('RSA-SHA256', Buffer.from(unsigned), sa.private_key).toString('base64url');
    const res = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: `${unsigned}.${sig}` }),
    });
    if (!res.ok) throw new Error(`google token ${res.status}`);
    const j = await res.json();
    googleToken = { value: j.access_token, exp: Date.now() + j.expires_in * 1000 };
    return googleToken.value;
  }

  /** True when [purchaseToken] is a completed purchase of Pro. */
  async function purchaseValid(purchaseToken) {
    if (cfg.verify === 'fake') return purchaseToken.startsWith('test-pro-');
    const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(cfg.playPackage)}` +
      `/purchases/productsv2/tokens/${encodeURIComponent(purchaseToken)}`;
    const res = await fetch(url, { headers: { Authorization: `Bearer ${await googleAccessToken()}` } });
    if (res.status === 404 || res.status === 400) return false;
    if (!res.ok) throw new Error(`play ${res.status}`);
    const j = await res.json();
    const state = j.purchaseStateContext && j.purchaseStateContext.purchaseState;
    const items = j.productLineItem || [];
    return state === 'PURCHASED' && items.some((i) => i.productId === cfg.playProduct);
  }

  /**
   * What binds a purchase to its Home, or null without Pro: the Play token,
   * or the App Store's original transaction id (the same across reinstalls
   * and restores, unlike the signed transaction itself).
   */
  async function purchaseKey(store, token) {
    if (store === 'apple') {
      if (cfg.verify === 'fake') return token.startsWith('test-pro-') ? `apple:${token}` : null;
      const t = verifyAppleTransaction(token, {
        bundleId: cfg.appleBundle, product: cfg.playProduct, environments: cfg.appleEnvironments,
      });
      return t ? `apple:${t.originalTransactionId}` : null;
    }
    return (await purchaseValid(token)) ? token : null;
  }

  // ---------- HTTP ----------
  const attempts = new Map(); // ip -> [times]
  function rateLimited(ip) {
    const now = Date.now();
    const list = (attempts.get(ip) || []).filter((t) => now - t < 3600000);
    list.push(now);
    attempts.set(ip, list);
    return list.length > cfg.pairPerHour;
  }
  const send = (res, status, body) => {
    res.writeHead(status, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
    res.end(JSON.stringify(body));
  };
  const readJson = (req) => new Promise((resolve) => {
    let raw = '';
    req.on('data', (c) => { raw += c; if (raw.length > 32768) req.destroy(); });
    req.on('end', () => { try { resolve(JSON.parse(raw || '{}')); } catch { resolve(null); } });
  });
  /** The phone a request's Basic credentials belong to, if any. */
  function phoneOf(req, homeId) {
    const m = /^Basic (.+)$/.exec(req.headers.authorization || '');
    if (!m) return null;
    const [username, ...rest] = Buffer.from(m[1], 'base64').toString().split(':');
    const row = db.prepare('select * from phones where username = ? and home = ?').get(username, homeId);
    return row && checkPw(rest.join(':'), row.pw_hash) ? row : null;
  }
  async function newPhone(homeId) {
    const count = db.prepare('select count(*) as n from phones where home = ?').get(homeId).n;
    if (count >= cfg.maxPhones) return null;
    const username = `phone-${homeId}-${crypto.randomBytes(3).toString('hex')}`;
    const password = secret();
    await createClient(username, password, homeId);
    db.prepare('insert into phones values (?, ?, ?, ?)').run(username, homeId, hashPw(password), Date.now());
    return { url: cfg.phoneUrl, username, password };
  }

  async function handle(req, res) {
    const ip = (req.headers['x-forwarded-for'] || req.socket.remoteAddress || '').split(',')[0].trim();
    const url = new URL(req.url, 'http://x');
    const parts = url.pathname.split('/').filter(Boolean); // v1 homes :id phones :username

    if (req.method === 'POST' && url.pathname === '/v1/homes') {
      if (rateLimited(ip)) return send(res, 429, { error: 'too many attempts' });
      const body = await readJson(req);
      const token = body && typeof body.purchaseToken === 'string' ? body.purchaseToken : '';
      if (!token || token.length > 16384) return send(res, 400, { error: 'purchaseToken missing' });
      const store = body.store === 'apple' ? 'apple' : 'play';
      const key = await purchaseKey(store, token);
      if (!key) return send(res, 402, { error: 'no Pro purchase' });
      const tokenHash = sha(key);
      const bound = db.prepare('select id from homes where token_hash = ?').get(tokenHash);
      // One purchase, one Home. Pairing the same purchase again (a reinstall)
      // returns the same Home with a fresh hub login and a new phone.
      const homeId = bound ? bound.id : crypto.randomBytes(8).toString('hex');
      if (!bound) {
        await createHomeOnBroker(homeId);
        db.prepare('insert into homes values (?, ?, ?)').run(homeId, tokenHash, Date.now());
      }
      const hubPassword = secret();
      try { await createClient(`hub-${homeId}`, hubPassword, homeId); } catch { /* exists */ }
      await setPassword(`hub-${homeId}`, hubPassword);
      const phone = await newPhone(homeId);
      if (!phone) return send(res, 409, { error: 'phone limit reached' });
      return send(res, 200, { homeId, hub: { url: cfg.hubUrl, username: `hub-${homeId}`, password: hubPassword }, phone });
    }

    // A paired phone renews the hub's login, to hand it to a hub that lost it
    // (remote turned off on the hub only, or the Engine reinstalled).
    if (req.method === 'POST' && parts[0] === 'v1' && parts[1] === 'homes' && parts[2] && parts[3] === 'hub' && parts.length === 4) {
      const homeId = parts[2];
      if (!phoneOf(req, homeId)) return send(res, 401, { error: 'not a phone of this home' });
      const hubPassword = secret();
      try { await createClient(`hub-${homeId}`, hubPassword, homeId); } catch { /* exists */ }
      await setPassword(`hub-${homeId}`, hubPassword);
      return send(res, 200, { hub: { url: cfg.hubUrl, username: `hub-${homeId}`, password: hubPassword } });
    }

    if (parts[0] === 'v1' && parts[1] === 'homes' && parts[2] && parts[3] === 'phones') {
      const homeId = parts[2];
      const me = phoneOf(req, homeId);
      if (!me) return send(res, 401, { error: 'not a phone of this home' });
      if (req.method === 'GET' && parts.length === 4) {
        return send(res, 200, db.prepare('select username, created from phones where home = ?').all(homeId));
      }
      if (req.method === 'POST' && parts.length === 4) {
        const phone = await newPhone(homeId);
        return phone ? send(res, 200, { phone }) : send(res, 409, { error: 'phone limit reached' });
      }
      if (req.method === 'DELETE' && parts.length === 5) {
        const row = db.prepare('select username from phones where username = ? and home = ?').get(parts[4], homeId);
        if (!row) return send(res, 404, { error: 'no such phone' });
        await deleteClient(row.username);
        db.prepare('delete from phones where username = ?').run(row.username);
        return send(res, 200, { removed: row.username });
      }
    }
    if (req.method === 'GET' && url.pathname === '/v1/health') return send(res, 200, { ok: true });
    return send(res, 404, { error: 'not found' });
  }

  const server = http.createServer((req, res) => {
    handle(req, res).catch((e) => send(res, 500, { error: String(e.message || e).slice(0, 120) }));
  });

  return {
    cfg,
    async start() {
      admin = mqtt.connect(cfg.mqttUrl, { username: cfg.adminUser, password: cfg.adminPassword, clientId: 'zigdash-verifier', protocolVersion: 5 });
      admin.on('error', (e) => console.error('verifier mqtt:', e.message));
      await new Promise((resolve, reject) => {
        admin.once('connect', resolve);
        setTimeout(() => reject(new Error('could not reach the broker')), 10000);
      });
      await admin.subscribeAsync('$CONTROL/dynamic-security/v1/response');
      admin.on('message', onControlResponse);
      await new Promise((r) => server.listen(cfg.port, r));
      return server.address().port;
    },
    async stop() {
      await new Promise((r) => server.close(r));
      admin && admin.end(true);
      db.close();
    },
  };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const v = createVerifier();
  v.start().then((port) => console.log(`zigdash verifier on :${port}, verify=${v.cfg.verify}`));
}
