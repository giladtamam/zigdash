// ZigDash relay verifier (3.1, zigdash-3.0.md §5).
//
// A small HTTP service beside the relay broker. It admits a Home only after
// checking a purchase of Pro (Google Play, or the App Store: apple.mjs), then creates the Home's broker
// logins through Mosquitto's dynamic-security plugin: one role confined to
// homes/<id>/#, one client for the hub and one per phone. Phones it paired
// can ask for more phone logins (for the QR code) and remove phones.
//
// It never sees device data: that travels sealed between hub and phones.
// It stores: purchase hash (Play token, or Apple original transaction) → home, and scrypt hashes of phone passwords;
// for founders' passes the code's keyed hash, its dates and its Home; the Chat topics it granted per Home; and
// a tombstone (Home, date) for a year after a Home's deletion.
//
// Env: PORT, DB, MQTT_URL, ADMIN_USER, ADMIN_PASSWORD, HUB_URL, PHONE_URL,
//      VERIFY (play | fake), PLAY_PACKAGE, PLAY_PRODUCT, GOOGLE_SA (path to JSON key),
//      APPLE_BUNDLE, APPLE_ENVIRONMENTS (Production[,Sandbox]).
//
// ZigDash Chat (docs/design/chat-linking.md §2), off until both secrets are set:
//   CHAT_TICKET_SECRET_FILE (or CHAT_TICKET_SECRET)  signs Chat tickets; the chat service holds it too
//   CHAT_ACL_SECRET_FILE (or CHAT_ACL_SECRET)        the chat service's key to the internal ACL route
//   CHAT_ROLE (zigdash-chat)                         the chat service's dynamic-security role
//   INTERNAL_PORT (8788)                             the internal route's own port: Caddy never
//                                                    proxies it, so only containers on the verifier's
//                                                    Docker networks can reach it
//   TICKETS_PER_HOUR (20)                            tickets per Home an hour (each one asks Play)
//
//   POST /v1/homes/<id>/chat-ticket   phone Basic login, {purchase_token, client_id?, request_topic?,
//                                     answer_topic?} (topics only with client_id, both or neither)
//                                     -> {ticket, home_id, client_id, request_topic,
//                                     answer_topic, exp}; 401 wrong login, 402 purchase not valid or not
//                                     this Home's, 400 bad body, 429, 503 (Chat off, or Play unreachable)
//   POST /v1/internal/chat-acl        INTERNAL_PORT only, header X-Chat-Acl-Secret, no forwarding
//                                     headers: {home_id, request_topic, answer_topic, op: add|remove}
//                                     adds or removes the chat role's three ACL entries for one client;
//                                     402 pass_ended on an add for a Home that is not entitled
//   GET  /v1/internal/home/<id>       INTERNAL_PORT only, same header: {entitled, ended_at} for the chat
//                                     service; 410 deleted (a tombstone), 404 unknown (never "deleted")
//
// Founders' pass (docs/design/founders-pass.md, its appendix is the wire contract): a code from the
// owner admits one Home for remote control and Chat for a number of days instead of a purchase.
//   PASS_SECRET_FILE (or PASS_SECRET)  keys the codes' hashes (passes.mjs); passes are off without it
//   CHAT_INTERNAL_URL                  the chat service's internal listener, told of changed and deleted
//                                      Homes (unset: no pushes)
//   ADMIN_SOCKET                       a Unix socket for the owner's commands (cli.mjs), inside the
//                                      container only (Compose: /tmp/zigdash-verifier.sock); unset: none
//   SWEEP_MS (3600000)                 how often ended passes are swept (0: at start only)
//   CODE_FAILS_LOGGED_PER_HOUR (1000)  wrong codes an hour, all addresses together, before a log line
//
//   POST /v1/homes {store:"founder", purchaseToken:<code>, redeem_nonce}
//                                     -> {homeId, hub, phone, kind:"founder", expires_at}; 402 no_pass,
//                                     deadline or revoked; 409 code_used; the same nonce within 15
//                                     minutes (a lost answer) gets fresh logins for the same Home
//   GET  /v1/homes/<id>               phone login -> {kind, expires_at, ended}
//   POST /v1/homes/<id>/upgrade       phone login, {purchaseToken, store} -> {kind:null}; 402
//                                     no_purchase, 409 purchase_has_home
//   Any /v1/homes/<id>/... of a deleted Home: 410 deleted, without a login.

import http from 'node:http';
import crypto from 'node:crypto';
import fs from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import mqtt from 'mqtt';
import { verifyAppleTransaction } from './apple.mjs';
import { signTicket } from './ticket.mjs';
import { codeHash, newCode, rateKey } from './passes.mjs';

const DAY = 86400000;
const RETRY_MS = 15 * 60000;  // a lost redeem answer may be asked for again this long, with the same nonce
const KEEP_DAYS = 90;         // an ended founder Home is deleted this long after its end
const YEAR = 365 * DAY;       // tombstones, and passes after their Home's, are kept this long

/** A secret from [name]_FILE (preferred; a missing file means not set) or [name]; null when neither is set. */
function secretFrom(env, name) {
  const file = env[`${name}_FILE`];
  const value = file ? (fs.existsSync(file) ? fs.readFileSync(file, 'utf8').trim() : '') : env[name];
  return value ? String(value) : null;
}

const sameSecret = (a, b) => {
  const x = Buffer.from(String(a || '')), y = Buffer.from(String(b || ''));
  return x.length === y.length && x.length > 0 && crypto.timingSafeEqual(x, y);
};

/**
 * Hooks, tests only: [purchaseValid] stands in for Google Play (a refund, an outage); [now] for the
 * clock; [log] for console.error; [clearQuietMs] for the 3 s a clearing round waits; [pushTimeoutMs]
 * for the 5 s the chat service gets to answer.
 */
export function createVerifier(env = process.env, hooks = {}) {
  const now = hooks.now || Date.now;
  const log = hooks.log || ((...a) => console.error(...a));
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
    chatTicketSecret: secretFrom(env, 'CHAT_TICKET_SECRET'),
    chatAclSecret: secretFrom(env, 'CHAT_ACL_SECRET'),
    chatRole: env.CHAT_ROLE || 'zigdash-chat',
    internalPort: Number(env.INTERNAL_PORT ?? 8788),
    ticketsPerHour: Number(env.TICKETS_PER_HOUR || 20),
    passSecret: secretFrom(env, 'PASS_SECRET'),
    chatInternalUrl: env.CHAT_INTERNAL_URL ? env.CHAT_INTERNAL_URL.replace(/\/$/, '') : null,
    adminSocket: env.ADMIN_SOCKET || null,
    sweepMs: Number(env.SWEEP_MS ?? 3600000),
    codeFailsLogged: Number(env.CODE_FAILS_LOGGED_PER_HOUR || 1000),
  };

  // ---------- storage ----------
  const db = new DatabaseSync(cfg.db);
  db.exec(`
    create table if not exists homes (id text primary key, token_hash text unique, created integer);
    create table if not exists phones (username text primary key, home text, pw_hash text, created integer);
    create table if not exists passes (hash text primary key, created integer, redeem_by integer, days integer,
      redeemed_at integer, redeem_nonce text, expires_at integer, revoked_at integer, home text);
    create table if not exists chat_acls (home text, request_topic text, answer_topic text, primary key (home, request_topic));
    create table if not exists tombstones (home text primary key, deleted_at integer, notified_at integer);
  `);
  // Homes from before the founders' pass lack these three; added in place, every row kept.
  // kind: null for a purchase, 'founder' for a pass; expires_at: a pass's end; disabled_at: when its
  // logins and Chat access were switched off on the broker.
  const columns = new Set(db.prepare('pragma table_info(homes)').all().map((c) => c.name));
  for (const [name, type] of [['kind', 'text'], ['expires_at', 'integer'], ['disabled_at', 'integer']]) {
    if (!columns.has(name)) db.exec(`alter table homes add column ${name} ${type}`);
  }
  const homeRow = (id) => db.prepare('select * from homes where id = ?').get(id);
  const deleted = (id) => !!db.prepare('select 1 from tombstones where home = ?').get(id);
  const phonesOf = (id) => db.prepare('select username from phones where home = ?').all(id).map((p) => p.username);
  const chatRows = (id) => db.prepare('select request_topic, answer_topic from chat_acls where home = ?').all(id);
  /** Purchase Homes as before; a founder Home until its pass ends (revoking ends it at once). */
  const entitled = (home) => !!home && (home.kind !== 'founder' || (home.expires_at != null && now() < home.expires_at));
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
    if (!commands.length) return Promise.resolve([]);
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
  /** Runs commands whose "already exists" and "not found" both mean done (switching, deleting). */
  async function settle(commands) {
    const bad = (await control(commands)).filter((r) => r.error && !/already exists|not found/i.test(r.error));
    if (bad.length) throw new Error(bad[0].error);
  }

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
  /** The hub's login, created or given a new password (the old one stops working). */
  async function renewHub(homeId) {
    const password = secret();
    try { await createClient(`hub-${homeId}`, password, homeId); } catch { /* exists */ }
    await setPassword(`hub-${homeId}`, password);
    return { url: cfg.hubUrl, username: `hub-${homeId}`, password };
  }

  // A Chat client's two relay topics on the chat service's role: it may send
  // requests on one and read answers on the other, nothing else of the Home.
  const chatAcls = (req, ans) => [
    { acltype: 'publishClientSend', topic: req },
    { acltype: 'subscribeLiteral', topic: ans },
    { acltype: 'publishClientReceive', topic: ans },
  ];
  async function chatAcl(op, req, ans) {
    const rolename = cfg.chatRole;
    if (op === 'add') {
      const created = await control([{ command: 'createRole', rolename }]);
      if (failed(created).length) throw new Error(failed(created)[0].error);
      const r = await control(chatAcls(req, ans).map((a) => ({ command: 'addRoleACL', rolename, ...a, priority: 0, allow: true })));
      if (failed(r).length) throw new Error(failed(r)[0].error);
    } else {
      const r = await control(chatAcls(req, ans).map((a) => ({ command: 'removeRoleACL', rolename, ...a })));
      const bad = failed(r).filter((x) => !/not found/i.test(x.error));
      if (bad.length) throw new Error(bad[0].error);
    }
  }

  // ---------- founders' pass: switching off, on, and deleting ----------
  // Every broker change for one Home runs under its lock, one after another:
  // the sweep, the owner's commands, an upgrade, a Chat ACL add, new logins.
  const locks = new Map();
  function withLock(homeId, fn) {
    const run = (locks.get(homeId) || Promise.resolve()).then(() => fn());
    const tail = run.catch(() => {});
    locks.set(homeId, tail);
    tail.then(() => { if (locks.get(homeId) === tail) locks.delete(homeId); });
    return run;
  }

  /**
   * Switches a Home's broker access off (its hub and phone logins disabled: the
   * broker drops them and refuses them while disabled, the flag persists; the
   * chat role's ACLs for its Chat links removed) or back on. The caller holds
   * the Home's lock. The Home is read again before every command; should it
   * have changed sides meanwhile, the other direction runs instead. False when
   * the Home isn't on the asked side of entitled() (nothing done).
   */
  async function switchHome(homeId, on, depth = 0) {
    const wanted = () => { const h = homeRow(homeId); return !!h && (on ? entitled(h) : h.kind === 'founder' && !entitled(h)); };
    if (!wanted()) return false;
    const command = on ? 'enableClient' : 'disableClient';
    const steps = [
      ...[`hub-${homeId}`, ...phonesOf(homeId)].map((username) => () => settle([{ command, username }])),
      ...chatRows(homeId).map((r) => async () => {
        await chatAcl(on ? 'add' : 'remove', r.request_topic, r.answer_topic);
        // The chat service removes links without the lock: one removed meanwhile stays removed.
        if (on && !db.prepare('select 1 from chat_acls where home = ? and request_topic = ?').get(homeId, r.request_topic)) {
          await chatAcl('remove', r.request_topic, r.answer_topic);
        }
      }),
    ];
    for (const step of steps) {
      if (!wanted()) return depth < 2 ? switchHome(homeId, !on, depth + 1) : false;
      await step();
    }
    db.prepare('update homes set disabled_at = ? where id = ?').run(on ? null : now(), homeId);
    return true;
  }
  /** Back on for a Home that is entitled again (upgrade, extend, unrevoke); then the chat service is told. */
  async function reenable(homeId) {
    await withLock(homeId, () => switchHome(homeId, true));
    await tellChat('/v1/internal/home-changed', homeId);
  }

  /**
   * The chat service's internal listener, told that a Home changed (it drops
   * its cached status) or was deleted (it removes the Home's Chat links). Never
   * called under a Home's lock: the service may call back. True on a 200.
   */
  async function tellChat(path, homeId) {
    if (!cfg.chatInternalUrl || !cfg.chatAclSecret) return false;
    try {
      const res = await fetch(`${cfg.chatInternalUrl}${path}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-Chat-Acl-Secret': cfg.chatAclSecret },
        body: JSON.stringify({ home_id: homeId }),
        signal: AbortSignal.timeout(hooks.pushTimeoutMs || 5000),
      });
      if (res.status === 200) return true;
      log(`verifier: the chat service answered ${res.status} to ${path}`);
    } catch (e) {
      log(`verifier: the chat service did not answer ${path}: ${e.message}`);
    }
    return false;
  }

  /**
   * Clears a Home's retained messages on the relay: a temporary client in the
   * Home's role subscribes at QoS 0 to homes/<id>/#, waits for 3 s without a
   * message, unsubscribes and publishes an empty retained message on every
   * topic that came retained; again until a round brings nothing (at most 20
   * rounds: the broker may hold back part of a large burst). The client has a
   * random login and is deleted in any case. False when 20 rounds weren't enough.
   */
  const clearing = new Set();
  async function clearRetained(homeId) {
    const quietMs = hooks.clearQuietMs || 3000;
    const username = `clear-${crypto.randomBytes(8).toString('hex')}`;
    const topic = `homes/${homeId}/#`;
    clearing.add(username);
    let client;
    // One round: subscribed until 3 s pass without a message (or 30 s in all: not settled).
    const round = () => new Promise((resolve, reject) => {
      const seen = new Set();
      const stop = () => { clearTimeout(quiet); clearTimeout(limit); client.off('message', onMessage); };
      const finish = (settled) => { stop(); resolve({ seen, settled }); };
      const onMessage = (t, payload, packet) => { if (packet.retain && payload.length) seen.add(t); quiet.refresh(); };
      const quiet = setTimeout(() => finish(true), quietMs);
      const limit = setTimeout(() => finish(false), quietMs * 10);
      client.on('message', onMessage);
      client.subscribeAsync(topic, { qos: 0 }).then(() => quiet.refresh(), (e) => { stop(); reject(e); });
    });
    try {
      await createHomeOnBroker(homeId); // its role again, if an earlier try got as far as deleting it
      const password = secret();
      await createClient(username, password, homeId);
      client = await mqtt.connectAsync(cfg.mqttUrl, {
        username, password, clientId: `clear-${crypto.randomBytes(8).toString('hex')}`,
        protocolVersion: 5, clean: true, reconnectPeriod: 0, connectTimeout: 10000,
      });
      for (let i = 0; i < 20; i++) {
        const { seen, settled } = await round();
        await client.unsubscribeAsync(topic);
        if (settled && !seen.size) return true;
        for (const t of seen) client.publish(t, '', { qos: 0, retain: true });
      }
      return false;
    } finally {
      if (client) client.end(true);
      await deleteClient(username).catch((e) => log(`verifier: a clearing login is left (${e.message}); the next sweep removes it`));
      clearing.delete(username);
    }
  }
  /** Clearing logins a crash left behind (none in use here). */
  async function removeLeftClearing() {
    const [r] = await control([{ command: 'listClients', verbose: false, count: -1, offset: 0 }]);
    const left = ((r && r.data && r.data.clients) || []).filter((u) => typeof u === 'string' && u.startsWith('clear-') && !clearing.has(u));
    await settle(left.map((username) => ({ command: 'deleteClient', username })));
  }

  /**
   * Deletes a Home (an ended founder Home 90 days on, or any Home on the
   * owner's command): logins off, retained messages cleared, then its logins,
   * role, Chat ACLs and rows; a tombstone stays. [due] re-checks, under the
   * lock, that it is still to be deleted. The chat service is told after the
   * lock is released. Returns 'deleted', 'kept' (retained messages not cleared
   * yet: everything stays for the next try), 'missing' or 'not_due'.
   */
  async function deleteHome(homeId, due = () => true) {
    const outcome = await withLock(homeId, async () => {
      const home = homeRow(homeId);
      if (!home) return 'missing';
      if (!due(home)) return 'not_due';
      const clients = [`hub-${homeId}`, ...phonesOf(homeId)];
      await settle(clients.map((username) => ({ command: 'disableClient', username })));
      if (!(await clearRetained(homeId))) {
        log('verifier: a Home\'s retained messages did not settle in 20 rounds; kept for the next sweep');
        return 'kept';
      }
      await settle([...clients.map((username) => ({ command: 'deleteClient', username })), { command: 'deleteRole', rolename: `home-${homeId}` }]);
      for (const r of chatRows(homeId)) await chatAcl('remove', r.request_topic, r.answer_topic);
      db.exec('begin');
      try {
        for (const table of ['chat_acls', 'phones']) db.prepare(`delete from ${table} where home = ?`).run(homeId);
        db.prepare('delete from homes where id = ?').run(homeId);
        db.prepare('insert or replace into tombstones (home, deleted_at) values (?, ?)').run(homeId, now());
        db.exec('commit');
      } catch (e) { db.exec('rollback'); throw e; }
      return 'deleted';
    });
    if (outcome === 'deleted') await notifyDeleted(homeId);
    return outcome;
  }
  async function notifyDeleted(homeId) {
    if (!(await tellChat('/v1/internal/home-deleted', homeId))) return false;
    db.prepare('update tombstones set notified_at = ? where home = ?').run(now(), homeId);
    return true;
  }

  /**
   * The hourly sweep (also at start, and `passes sweep`): ended founder Homes
   * switched off once; Homes entitled again but still off switched on; founder
   * Homes 90 days past their end deleted; deletions the chat service hasn't
   * answered told again; old tombstones, passes and rate keys dropped.
   */
  let sweeping = null;
  const sweep = () => (sweeping ||= runSweep().finally(() => { sweeping = null; }));
  async function runSweep() {
    const out = { disabled: 0, enabled: 0, deleted: 0, kept: 0, notified: 0, failed: 0 };
    const each = async (rows, fn) => {
      for (const { id } of rows) {
        try { await fn(id); } catch (e) { out.failed++; log(`verifier: sweep: ${e.message}`); }
      }
    };
    try { await removeLeftClearing(); } catch (e) { log(`verifier: sweep: ${e.message}`); }
    await each(db.prepare("select id from homes where kind = 'founder' and disabled_at is null and expires_at <= ?").all(now()), async (id) => {
      if (await withLock(id, () => switchHome(id, false))) out.disabled++;
    });
    await each(db.prepare('select id from homes where disabled_at is not null').all(), async (id) => {
      if (!entitled(homeRow(id))) return;
      if (await withLock(id, () => switchHome(id, true))) { out.enabled++; await tellChat('/v1/internal/home-changed', id); }
    });
    await each(db.prepare('select home as id from tombstones where notified_at is null').all(), async (id) => {
      if (await notifyDeleted(id)) out.notified++;
    });
    const dueBefore = () => now() - KEEP_DAYS * DAY;
    await each(db.prepare("select id from homes where kind = 'founder' and expires_at <= ?").all(dueBefore()), async (id) => {
      const r = await deleteHome(id, (h) => h.kind === 'founder' && h.expires_at <= dueBefore());
      if (r === 'deleted') out.deleted++;
      if (r === 'kept') out.kept++;
    });
    const cut = now() - YEAR;
    db.prepare(`delete from passes where created < ?
      and not exists (select 1 from homes h where h.id = passes.home and h.kind = 'founder')
      and not exists (select 1 from tombstones t where t.home = passes.home and t.deleted_at >= ?)`).run(cut, cut);
    db.prepare('delete from tombstones where deleted_at < ?').run(cut);
    pruneAttempts();
    return out;
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
    if (hooks.purchaseValid) return hooks.purchaseValid(purchaseToken);
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
  const attempts = new Map(); // rate key (an address, an IPv6 /64, ticket:<home>) -> [times]
  /** More than [limit] calls under [key] in the last hour. */
  function overLimit(key, limit) {
    const t = now();
    const list = (attempts.get(key) || []).filter((x) => t - x < 3600000);
    list.push(t);
    attempts.delete(key);
    attempts.set(key, list); // the most recent key last, for pruneAttempts
    if (attempts.size > 20000) pruneAttempts();
    return list.length > limit;
  }
  const rateLimited = (ip) => overLimit(rateKey(ip), cfg.pairPerHour);
  /** Drops keys without a call in the last hour; past 10,000 keys, the least recent ones. */
  function pruneAttempts() {
    const t = now();
    for (const [key, list] of attempts) if (!list.some((x) => t - x < 3600000)) attempts.delete(key);
    for (const key of attempts.keys()) { if (attempts.size <= 10000) break; attempts.delete(key); }
  }
  // Wrong founder's codes from all addresses together: only logged (once an
  // hour) above the ceiling. 50 random bits make guessing hopeless anyway.
  let codeFails = { hour: -1, count: 0 };
  function countWrongCode() {
    const hour = Math.floor(now() / 3600000);
    if (codeFails.hour !== hour) codeFails = { hour, count: 0 };
    if (++codeFails.count === cfg.codeFailsLogged + 1) log(`verifier: more than ${cfg.codeFailsLogged} wrong founder's codes this hour`);
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
    db.prepare('insert into phones (username, home, pw_hash, created) values (?, ?, ?, ?)').run(username, homeId, hashPw(password), now());
    return { url: cfg.phoneUrl, username, password };
  }

  /**
   * A founder's code instead of a purchase (POST /v1/homes, store "founder").
   * A code admits once: its first use creates the Home (or, for a code from
   * `passes reissue`, joins the Home it was made for); the same code with the
   * same redeem_nonce within 15 minutes (the answer was lost) gets fresh hub
   * and phone logins for that Home; any other later use is refused.
   */
  async function redeem(res, token, nonce) {
    if (!cfg.passSecret) return send(res, 503, { error: 'passes are off' });
    if (typeof nonce !== 'string' || !/^[A-Za-z0-9_-]{16,64}$/.test(nonce)) return send(res, 400, { error: 'redeem_nonce missing' });
    const hash = codeHash(cfg.passSecret, token);
    const pass = hash && db.prepare('select * from passes where hash = ?').get(hash);
    if (!pass) { countWrongCode(); return send(res, 402, { error: 'no_pass' }); }
    if (pass.revoked_at != null) return send(res, 402, { error: 'revoked' });
    const t = now();
    let homeId = pass.home;
    if (pass.redeemed_at != null) {
      const retry = pass.redeem_nonce === nonce && t - pass.redeemed_at <= RETRY_MS;
      if (!retry || !entitled(homeRow(homeId))) return send(res, 409, { error: 'code_used' });
    } else {
      if (t > pass.redeem_by) return send(res, 402, { error: 'deadline' });
      // A reissued code joins its Home, which must still have its pass.
      if (homeId && !entitled(homeRow(homeId))) return send(res, 402, { error: 'deadline' });
      // Claimed here, before anything is awaited: two requests can't both claim it.
      db.exec('begin');
      try {
        if (homeId) {
          db.prepare('update passes set redeemed_at = ?, redeem_nonce = ? where hash = ?').run(t, nonce, hash);
        } else {
          homeId = crypto.randomBytes(8).toString('hex');
          const expiresAt = t + pass.days * DAY;
          db.prepare('update passes set redeemed_at = ?, redeem_nonce = ?, home = ?, expires_at = ? where hash = ?').run(t, nonce, homeId, expiresAt, hash);
          db.prepare('insert into homes (id, token_hash, created, kind, expires_at) values (?, ?, ?, ?, ?)')
            .run(homeId, sha(`founder:${hash}`), t, 'founder', expiresAt);
        }
        db.exec('commit');
      } catch (e) { db.exec('rollback'); throw e; }
    }
    const logins = await withLock(homeId, async () => {
      if (!entitled(homeRow(homeId))) return null;
      await createHomeOnBroker(homeId); // already there for a reissued code or a retry
      return { hub: await renewHub(homeId), phone: await newPhone(homeId) };
    });
    if (!logins) return send(res, 409, { error: 'code_used' });
    if (!logins.phone) return send(res, 409, { error: 'phone limit reached' });
    const home = homeRow(homeId);
    return send(res, 200, { homeId, ...logins, kind: home.kind ?? null, expires_at: home.expires_at ?? null });
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
      if (body.store === 'founder') return redeem(res, token, body.redeem_nonce);
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
        db.prepare('insert into homes (id, token_hash, created) values (?, ?, ?)').run(homeId, tokenHash, now());
      }
      const { hub, phone } = await withLock(homeId, async () => ({ hub: await renewHub(homeId), phone: await newPhone(homeId) }));
      if (!phone) return send(res, 409, { error: 'phone limit reached' });
      return send(res, 200, { homeId, hub, phone });
    }

    // A deleted Home answers 410 to everything, without a login: its phones are gone.
    if (parts[0] === 'v1' && parts[1] === 'homes' && parts[2] && deleted(parts[2])) return send(res, 410, { error: 'deleted' });

    // What the app shows on the Remote and Chat screens.
    if (req.method === 'GET' && parts[0] === 'v1' && parts[1] === 'homes' && parts[2] && parts.length === 3) {
      if (!phoneOf(req, parts[2])) return send(res, 401, { error: 'not a phone of this home' });
      const home = homeRow(parts[2]);
      return send(res, 200, { kind: home.kind ?? null, expires_at: home.expires_at ?? null, ended: !entitled(home) });
    }

    // A founder Home becomes a purchase Home, with the owner's consent in the
    // app: same Home, phones and Chat links; switched back on if it was off.
    if (req.method === 'POST' && parts[0] === 'v1' && parts[1] === 'homes' && parts[2] && parts[3] === 'upgrade' && parts.length === 4) {
      const homeId = parts[2];
      if (!phoneOf(req, homeId)) return send(res, 401, { error: 'not a phone of this home' });
      if (overLimit(`upgrade:${homeId}`, cfg.pairPerHour)) return send(res, 429, { error: 'too many attempts' });
      const body = await readJson(req);
      const token = body && typeof body.purchaseToken === 'string' ? body.purchaseToken : '';
      if (!token || token.length > 16384) return send(res, 400, { error: 'purchaseToken missing' });
      let key;
      try { key = await purchaseKey(body.store === 'apple' ? 'apple' : 'play', token); } catch { return send(res, 503, { error: 'Play did not answer' }); }
      if (!key) return send(res, 402, { error: 'no_purchase' });
      const tokenHash = sha(key);
      const outcome = await withLock(homeId, async () => {
        const home = homeRow(homeId);
        if (!home) return 'deleted';
        const bound = db.prepare('select id from homes where token_hash = ?').get(tokenHash);
        if (bound && bound.id !== homeId) return 'taken';
        if (!bound && home.kind !== 'founder') return 'not_founder';
        db.prepare('update homes set token_hash = ?, kind = null, expires_at = null where id = ?').run(tokenHash, homeId);
        await switchHome(homeId, true);
        return 'ok';
      });
      if (outcome === 'deleted') return send(res, 410, { error: 'deleted' });
      if (outcome === 'taken') return send(res, 409, { error: 'purchase_has_home' });
      if (outcome === 'not_founder') return send(res, 400, { error: 'not a founder home' });
      await tellChat('/v1/internal/home-changed', homeId);
      return send(res, 200, { kind: null });
    }

    // A paired phone renews the hub's login, to hand it to a hub that lost it
    // (remote turned off on the hub only, or the Engine reinstalled).
    if (req.method === 'POST' && parts[0] === 'v1' && parts[1] === 'homes' && parts[2] && parts[3] === 'hub' && parts.length === 4) {
      const homeId = parts[2];
      if (!phoneOf(req, homeId)) return send(res, 401, { error: 'not a phone of this home' });
      const hub = await withLock(homeId, async () => (entitled(homeRow(homeId)) ? renewHub(homeId) : null));
      if (!hub) return send(res, 402, { error: 'pass_ended' });
      return send(res, 200, { hub });
    }

    if (parts[0] === 'v1' && parts[1] === 'homes' && parts[2] && parts[3] === 'phones') {
      const homeId = parts[2];
      const me = phoneOf(req, homeId);
      if (!me) return send(res, 401, { error: 'not a phone of this home' });
      if (req.method === 'GET' && parts.length === 4) {
        return send(res, 200, db.prepare('select username, created from phones where home = ?').all(homeId));
      }
      if (req.method === 'POST' && parts.length === 4) {
        const phone = await withLock(homeId, async () => (entitled(homeRow(homeId)) ? (await newPhone(homeId)) || 'full' : null));
        if (!phone) return send(res, 402, { error: 'pass_ended' });
        return phone !== 'full' ? send(res, 200, { phone }) : send(res, 409, { error: 'phone limit reached' });
      }
      if (req.method === 'DELETE' && parts.length === 5) {
        const row = db.prepare('select username from phones where username = ? and home = ?').get(parts[4], homeId);
        if (!row) return send(res, 404, { error: 'no such phone' });
        await deleteClient(row.username);
        db.prepare('delete from phones where username = ?').run(row.username);
        return send(res, 200, { removed: row.username });
      }
    }
    // Chat: a phone of this Home with a Pro purchase that is still valid now
    // gets a ticket for the chat service. Play only in this beta. A founder
    // Home needs no purchase: its phone's login is enough, and after its pass
    // ends only tickets without link topics (to list and remove links).
    if (req.method === 'POST' && parts[0] === 'v1' && parts[1] === 'homes' && parts[2] && parts[3] === 'chat-ticket' && parts.length === 4) {
      const homeId = parts[2];
      if (!cfg.chatTicketSecret) return send(res, 503, { error: 'chat is off' });
      if (!phoneOf(req, homeId)) return send(res, 401, { error: 'not a phone of this home' });
      if (overLimit(`ticket:${homeId}`, cfg.ticketsPerHour)) return send(res, 429, { error: 'too many tickets' });
      const body = await readJson(req);
      const home = homeRow(homeId);
      const founder = !!home && home.kind === 'founder';
      // purchase_token as the app sends it; purchaseToken as /v1/homes takes it.
      const raw = body && (body.purchase_token ?? body.purchaseToken);
      const token = typeof raw === 'string' ? raw : '';
      if (!founder && (!token || token.length > 16384)) return send(res, 400, { error: 'purchase_token missing' });
      if (!body) return send(res, 400, { error: 'bad body' });
      // A link names the client and its two topics; a removal only the client; a listing nothing.
      const fields = { home_id: homeId, client_id: null, request_topic: null, answer_topic: null };
      if (body.client_id !== undefined) {
        if (typeof body.client_id !== 'string' || !/^[A-Za-z0-9_-]{1,40}$/.test(body.client_id)) return send(res, 400, { error: 'bad client_id' });
        fields.client_id = body.client_id;
      }
      if (body.request_topic !== undefined || body.answer_topic !== undefined) {
        const topic = new RegExp(`^homes/${homeId}/x/[0-9a-f]{24}$`);
        if (!fields.client_id || !topic.test(String(body.request_topic)) || !topic.test(String(body.answer_topic)) ||
            body.request_topic === body.answer_topic) {
          return send(res, 400, { error: 'client_id, request_topic and answer_topic must name one Chat client of this home' });
        }
        Object.assign(fields, { request_topic: body.request_topic, answer_topic: body.answer_topic });
      }
      if (founder) {
        if (fields.request_topic && !entitled(home)) return send(res, 402, { error: 'pass_ended' });
      } else {
        if (!home || home.token_hash !== sha(token)) return send(res, 402, { error: 'not the purchase of this home' });
        let valid;
        try { valid = await purchaseValid(token); } catch { return send(res, 503, { error: 'Play did not answer' }); }
        if (!valid) return send(res, 402, { error: 'no Pro purchase' });
      }
      const { ticket, payload } = signTicket(cfg.chatTicketSecret, fields);
      return send(res, 200, { ticket, ...fields, exp: payload.exp });
    }

    if (req.method === 'GET' && url.pathname === '/v1/health') return send(res, 200, { ok: true });
    return send(res, 404, { error: 'not found' });
  }

  /**
   * The internal port: only the chat service, from the Docker network, with
   * its secret. Anything that came through a proxy (Caddy adds forwarding
   * headers) is refused, in case this port is ever proxied by mistake.
   */
  async function handleInternal(req, res) {
    const url = new URL(req.url, 'http://x');
    const status = /^\/v1\/internal\/home\/([0-9a-f]{16})$/.exec(url.pathname);
    const route = req.method === 'POST' && url.pathname === '/v1/internal/chat-acl' ? 'acl' : req.method === 'GET' && status ? 'status' : null;
    if (!route) return send(res, 404, { error: 'not found' });
    if (req.headers['x-forwarded-for'] || req.headers['x-forwarded-host'] || req.headers.forwarded || req.headers['x-real-ip']) {
      return send(res, 403, { error: 'internal only' });
    }
    if (!cfg.chatAclSecret) return send(res, 503, { error: 'chat is off' });
    if (!sameSecret(req.headers['x-chat-acl-secret'], cfg.chatAclSecret)) return send(res, 401, { error: 'no' });

    // A Home's status for the chat service. An unknown Home is 404, never
    // "deleted": a lost or restored database must not unlink anyone.
    if (route === 'status') {
      const homeId = status[1];
      if (deleted(homeId)) return send(res, 410, { error: 'deleted' });
      const home = homeRow(homeId);
      if (!home) return send(res, 404, { error: 'unknown' });
      const ok = entitled(home);
      return send(res, 200, { entitled: ok, ended_at: ok ? null : home.expires_at ?? null });
    }

    const body = await readJson(req);
    const homeId = body && typeof body.home_id === 'string' && /^[0-9a-f]{16}$/.test(body.home_id) ? body.home_id : null;
    if (!homeId || !['add', 'remove'].includes(body.op)) return send(res, 400, { error: 'home_id and op (add or remove) needed' });
    const topic = new RegExp(`^homes/${homeId}/x/[0-9a-f]{24}$`);
    if (!topic.test(String(body.request_topic)) || !topic.test(String(body.answer_topic)) || body.request_topic === body.answer_topic) {
      return send(res, 400, { error: 'request_topic and answer_topic must be two of this home\'s chat topics' });
    }
    if (body.op === 'remove') {
      // Without the Home's lock (the chat service removes links after a deletion; a missing Home is fine).
      db.prepare('delete from chat_acls where home = ? and request_topic = ?').run(homeId, body.request_topic);
      await chatAcl('remove', body.request_topic, body.answer_topic);
      return send(res, 200, { ok: true, op: 'remove' });
    }
    if (!homeRow(homeId)) return send(res, 404, { error: 'no such home' });
    // Kept per Home, so switching off, on and deleting can take them back and give them again.
    const added = await withLock(homeId, async () => {
      if (!entitled(homeRow(homeId))) return false;
      await chatAcl('add', body.request_topic, body.answer_topic);
      db.prepare('insert or replace into chat_acls (home, request_topic, answer_topic) values (?, ?, ?)').run(homeId, body.request_topic, body.answer_topic);
      return true;
    });
    if (!added) return send(res, 402, { error: 'pass_ended' });
    return send(res, 200, { ok: true, op: 'add' });
  }

  // ---------- the owner's commands (cli.mjs) ----------
  const DAYS_MAX = 3650;
  /** A pass by its code or by a prefix of its hash (at least 6 hex), which must be unique. */
  function passOf(ref) {
    const text = String(ref || '');
    if (/^[0-9a-f]{6,64}$/.test(text)) {
      const rows = db.prepare("select * from passes where hash like ? || '%'").all(text);
      if (rows.length > 1) throw new Error('more than one pass starts with that; give more of it');
      if (rows.length) return rows[0];
    }
    const hash = cfg.passSecret && codeHash(cfg.passSecret, text);
    const row = hash && db.prepare('select * from passes where hash = ?').get(hash);
    if (!row) throw new Error('no such pass');
    return row;
  }
  const days = (n, fallback) => {
    if (n === undefined || n === null) return fallback;
    const d = Number(n);
    if (!Number.isInteger(d) || d < 0 || d > DAYS_MAX) throw new Error(`days: a whole number from 0 to ${DAYS_MAX}`);
    return d;
  };
  const view = (p) => ({
    hash: p.hash.slice(0, 12), created: p.created, redeem_by: p.redeem_by, days: p.days, redeemed_at: p.redeemed_at,
    expires_at: p.expires_at, revoked_at: p.revoked_at, home: p.home,
    state: p.revoked_at != null ? 'revoked' : p.home && deleted(p.home) ? 'deleted'
      : p.redeemed_at == null ? (now() > p.redeem_by ? 'deadline passed' : 'not used')
        : !homeRow(p.home) ? 'no home' : homeRow(p.home).kind !== 'founder' ? 'upgraded'
          : entitled(homeRow(p.home)) ? 'active' : homeRow(p.home).disabled_at ? 'ended, off' : 'ended',
  });
  /** Inserts a pass under a new code; the code is returned once and kept nowhere. */
  function insertPass(fields) {
    for (;;) {
      const code = newCode();
      const hash = codeHash(cfg.passSecret, code);
      if (db.prepare('select 1 from passes where hash = ?').get(hash)) continue;
      db.prepare('insert into passes (hash, created, redeem_by, days, expires_at, home) values (?, ?, ?, ?, ?, ?)')
        .run(hash, now(), fields.redeem_by, fields.days, fields.expires_at ?? null, fields.home ?? null);
      return { code, hash: hash.slice(0, 12) };
    }
  }
  const ops = {
    'passes new': ({ count = 1, days: d, redeem_by: by } = {}) => {
      if (!cfg.passSecret) throw new Error('PASS_SECRET_FILE is missing');
      const n = Number(count);
      if (!Number.isInteger(n) || n < 1 || n > 500) throw new Error('count: 1 to 500');
      const fields = { days: days(d, 90), redeem_by: by ?? now() + 60 * DAY };
      if (fields.days < 1) throw new Error('days: at least 1');
      return { codes: Array.from({ length: n }, () => insertPass(fields).code), ...fields };
    },
    'passes list': () => ({ passes: db.prepare('select * from passes order by created').all().map(view) }),
    // A lost founder's new code for the same Home (the old one stays used).
    'passes reissue': ({ home: homeId, redeem_by: by } = {}) => {
      if (!cfg.passSecret) throw new Error('PASS_SECRET_FILE is missing');
      const home = homeRow(String(homeId));
      if (!home) throw new Error(deleted(String(homeId)) ? 'that Home was deleted' : 'no such Home');
      if (home.kind !== 'founder') throw new Error('that Home is on Pro now: its owner pairs with the purchase');
      if (!entitled(home)) throw new Error('that Home\'s pass has ended: extend it first');
      const last = db.prepare('select days from passes where home = ? order by created desc').get(home.id);
      const fields = { home: home.id, days: last ? last.days : 90, expires_at: home.expires_at, redeem_by: by ?? now() + 60 * DAY };
      return { ...insertPass(fields), ...fields };
    },
    // Ends a pass now: its Home (if the code was used) is switched off at once.
    'passes revoke': async ({ pass } = {}) => {
      const p = passOf(pass);
      const home = p.redeemed_at != null && p.home ? homeRow(p.home) : null;
      db.prepare('update passes set revoked_at = ? where hash = ?').run(p.revoked_at ?? now(), p.hash);
      if (home && home.kind === 'founder') {
        db.prepare('update homes set expires_at = min(expires_at, ?) where id = ?').run(now(), home.id);
        await withLock(home.id, () => switchHome(home.id, false));
        await tellChat('/v1/internal/home-changed', home.id);
      }
      return view(passOf(p.hash));
    },
    'passes unrevoke': async ({ pass } = {}) => {
      const p = passOf(pass);
      db.prepare('update passes set revoked_at = null where hash = ?').run(p.hash);
      const home = p.redeemed_at != null && p.home ? homeRow(p.home) : null;
      if (home && home.kind === 'founder') {
        db.prepare('update homes set expires_at = ? where id = ?').run(p.expires_at, home.id);
        await reenable(home.id);
      }
      return view(passOf(p.hash));
    },
    // A later deadline to enter the code, and/or a new length: N days from
    // the day the code was entered (0 ends a used pass now; the sweep then
    // switches its Home off). A Home in time again is switched back on.
    'passes extend': async ({ pass, redeem_by: by, days: d } = {}) => {
      const p = passOf(pass);
      if (p.home && deleted(p.home)) throw new Error('that Home was deleted');
      if (by != null) db.prepare('update passes set redeem_by = ? where hash = ?').run(by, p.hash);
      const n = days(d, null);
      if (n !== null) {
        if (p.expires_at == null) {
          db.prepare('update passes set days = ? where hash = ?').run(n, p.hash);
        } else {
          const expiresAt = p.expires_at - p.days * DAY + n * DAY;
          db.prepare('update passes set days = ?, expires_at = ? where home = ? and expires_at is not null').run(n, expiresAt, p.home);
          if (p.revoked_at == null) db.prepare("update homes set expires_at = ? where id = ? and kind = 'founder'").run(expiresAt, p.home);
        }
      }
      if (p.home && homeRow(p.home)) await reenable(p.home);
      return view(passOf(p.hash));
    },
    'passes sweep': () => sweep(),
    // Any Home, a purchase Home too (a deletion request by email).
    'homes delete': async ({ home: homeId } = {}) => {
      const id = String(homeId || '');
      if (!/^[0-9a-f]{16}$/.test(id)) throw new Error('a Home ID is 16 hex characters');
      if (deleted(id)) return { home: id, outcome: 'already deleted' };
      const outcome = await deleteHome(id);
      if (outcome === 'missing') throw new Error('no such Home');
      return { home: id, outcome };
    },
  };

  /** cli.mjs asks over a Unix socket inside the container: {op, args} -> {ok, result} | {error}. */
  const adminServer = http.createServer(async (req, res) => {
    const body = await readJson(req);
    const op = body && ops[body.op];
    if (req.method !== 'POST' || !op) return send(res, 404, { error: 'no such command' });
    try {
      send(res, 200, { ok: true, result: await op(body.args || {}) });
    } catch (e) {
      send(res, 400, { error: String(e.message || e).slice(0, 200) });
    }
  });

  const server = http.createServer((req, res) => {
    handle(req, res).catch((e) => send(res, 500, { error: String(e.message || e).slice(0, 120) }));
  });
  const internal = http.createServer((req, res) => {
    handleInternal(req, res).catch((e) => send(res, 502, { error: String(e.message || e).slice(0, 120) }));
  });
  let sweepTimer = null;

  return {
    cfg,
    /** The owner's commands, as cli.mjs runs them; and what tests drive directly. */
    ops,
    sweep,
    deleteHome,
    withLock,
    entitled: (homeId) => entitled(homeRow(homeId)),
    db,
    async start() {
      admin = mqtt.connect(cfg.mqttUrl, { username: cfg.adminUser, password: cfg.adminPassword, clientId: 'zigdash-verifier', protocolVersion: 5 });
      admin.on('error', (e) => console.error('verifier mqtt:', e.message));
      await new Promise((resolve, reject) => {
        admin.once('connect', resolve);
        setTimeout(() => reject(new Error('could not reach the broker')), 10000);
      });
      await admin.subscribeAsync('$CONTROL/dynamic-security/v1/response');
      admin.on('message', onControlResponse);
      await sweep().catch((e) => log(`verifier: sweep: ${e.message}`));
      if (cfg.sweepMs > 0) {
        sweepTimer = setInterval(() => sweep().catch((e) => log(`verifier: sweep: ${e.message}`)), cfg.sweepMs);
        sweepTimer.unref();
      }
      await new Promise((r) => server.listen(cfg.port, r));
      if (cfg.internalPort >= 0 && !Number.isNaN(cfg.internalPort)) await new Promise((r) => internal.listen(cfg.internalPort, r));
      if (cfg.adminSocket) {
        fs.rmSync(cfg.adminSocket, { force: true });
        await new Promise((r) => adminServer.listen(cfg.adminSocket, r));
        fs.chmodSync(cfg.adminSocket, 0o600);
      }
      return server.address().port;
    },
    /** The internal route's port (INTERNAL_PORT, or the one picked for 0). */
    internalPort: () => internal.address() && internal.address().port,
    async stop() {
      clearInterval(sweepTimer);
      await sweeping?.catch(() => {});
      for (const s of [adminServer, internal, server]) if (s.listening) await new Promise((r) => s.close(r));
      admin && admin.end(true);
      db.close();
    },
  };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const v = createVerifier();
  v.start().then((port) => console.log(`zigdash verifier on :${port}, internal :${v.internalPort()}, verify=${v.cfg.verify}, chat=${v.cfg.chatTicketSecret && v.cfg.chatAclSecret ? 'on' : 'off'}, passes=${v.cfg.passSecret ? 'on' : 'off'}`));
}
