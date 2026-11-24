// Founders' passes (docs/design/founders-pass.md) against a real Mosquitto
// 2.1.2 with dynamic security, started here as in the relay (max_queued_messages
// 200), skipped when mosquitto isn't installed. Google Play is VERIFY=fake
// (tokens starting "test-pro-" pass), the clock is a hook, and the chat
// service's internal listener is played by a small HTTP server here.
import test from 'node:test';
import assert from 'node:assert/strict';
import { execFile, spawn, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import http from 'node:http';
import os from 'node:os';
import path from 'node:path';
import net from 'node:net';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import mqtt from 'mqtt';
import { createVerifier } from '../server.mjs';
import { verifyTicket } from '../ticket.mjs';

const have = (bin) => spawnSync('which', [bin]).status === 0;
const freePort = () => new Promise((r) => { const s = net.createServer(); s.listen(0, () => { const p = s.address().port; s.close(() => r(p)); }); });
const plugin = ['/opt/homebrew/lib/mosquitto_dynamic_security.so', '/usr/lib/mosquitto_dynamic_security.so', '/usr/lib/x86_64-linux-gnu/mosquitto_dynamic_security.so'].find((p) => fs.existsSync(p));
const skip = !have('mosquitto') || !have('mosquitto_ctrl') || !plugin ? 'mosquitto with dynamic security not installed' : false;

const DAY = 86400000;
const TICKET_SECRET = crypto.randomBytes(32).toString('base64url');
const ACL_SECRET = crypto.randomBytes(32).toString('base64url');
const hex24 = () => crypto.randomBytes(12).toString('hex');
const nonce = () => crypto.randomBytes(12).toString('base64url');
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const verifierDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

test('founders\' passes, against a real broker', { skip }, async (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'zd-fp-'));
  const adminPw = crypto.randomBytes(12).toString('hex');
  assert.equal(spawnSync('mosquitto_ctrl', ['dynsec', 'init', path.join(dir, 'dynsec.json'), 'admin', adminPw]).status, 0);
  const port = await freePort();
  fs.writeFileSync(path.join(dir, 'mosquitto.conf'),
    `listener ${port} 127.0.0.1\nallow_anonymous false\npersistence false\nmax_queued_messages 200\nplugin ${plugin}\nplugin_opt_config_file ${dir}/dynsec.json\n`);
  const broker = spawn('mosquitto', ['-c', path.join(dir, 'mosquitto.conf')], { stdio: 'ignore' });
  t.after(() => broker.kill());
  await sleep(600);
  const url = `mqtt://127.0.0.1:${port}`;

  // The chat service's internal listener: records what it is told; may fail, or look at the Home's lock.
  const pushes = [];
  let chatStatus = 200;
  let onPush = null;
  const chat = http.createServer(async (req, res) => {
    let raw = '';
    for await (const c of req) raw += c;
    const entry = { path: req.url, home: JSON.parse(raw).home_id, secret: req.headers['x-chat-acl-secret'] === ACL_SECRET };
    if (onPush) entry.seen = await onPush(entry);
    pushes.push(entry);
    res.writeHead(chatStatus, { 'Content-Type': 'application/json' });
    res.end('{"ok":true}');
  });
  await new Promise((r) => chat.listen(0, '127.0.0.1', r));
  t.after(() => chat.close());

  fs.writeFileSync(path.join(dir, 'pass-secret'), `${crypto.randomBytes(32).toString('base64url')}\n`, { mode: 0o600 });
  let clock = Date.now();
  const logs = [];
  const socket = path.join(dir, 'admin.sock');
  const v = createVerifier({
    VERIFY: 'fake', PORT: '0', INTERNAL_PORT: '0', MQTT_URL: url, ADMIN_USER: 'admin', ADMIN_PASSWORD: adminPw, HUB_URL: url, PHONE_URL: url,
    CHAT_TICKET_SECRET: TICKET_SECRET, CHAT_ACL_SECRET: ACL_SECRET, TICKETS_PER_HOUR: '1000',
    PASS_SECRET_FILE: path.join(dir, 'pass-secret'), CHAT_INTERNAL_URL: `http://127.0.0.1:${chat.address().port}/`,
    ADMIN_SOCKET: socket, SWEEP_MS: '0', PAIR_PER_HOUR: '5', MAX_PHONES: '10', CODE_FAILS_LOGGED_PER_HOUR: '3',
  }, { now: () => clock, log: (m) => logs.push(String(m)), clearQuietMs: 400, pushTimeoutMs: 1500 });
  const httpPort = await v.start();
  const internalPort = v.internalPort();
  t.after(() => v.stop());

  const someIp = () => `10.${crypto.randomInt(256)}.${crypto.randomInt(256)}.${crypto.randomInt(256)}`;
  const basic = (c) => ({ Authorization: `Basic ${Buffer.from(`${c.username}:${c.password}`).toString('base64')}` });
  const call = async (p, verb, route, body, headers) => {
    const res = await fetch(`http://127.0.0.1:${p}${route}`, { method: verb, headers: { 'Content-Type': 'application/json', ...headers }, body: body === undefined ? undefined : JSON.stringify(body) });
    return { status: res.status, body: await res.json() };
  };
  const api = (verb, route, body, { auth, ip } = {}) => call(httpPort, verb, route, body, { 'X-Forwarded-For': ip || someIp(), ...(auth ? basic(auth) : {}) });
  const internal = (verb, route, body, headers = { 'X-Chat-Acl-Secret': ACL_SECRET }) => call(internalPort, verb, route, body, headers);
  const redeem = (code, n = nonce(), ip) => api('POST', '/v1/homes', { store: 'founder', purchaseToken: code, redeem_nonce: n }, { ip });
  const connect = (c, id = `c-${hex24()}`) => new Promise((resolve) => {
    const client = mqtt.connect(url, { username: c.username, password: c.password, clientId: id, protocolVersion: 5, reconnectPeriod: 0 });
    client.once('connect', () => resolve(client));
    client.once('error', (e) => { client.end(true); resolve({ error: e.code || e.message }); });
  });
  const canConnect = async (c) => { const x = await connect(c); if (x.error) return false; x.end(true); return true; };

  // The test's own admin login, to look at the broker's dynamic security.
  const admin = await connect({ username: 'admin', password: adminPw }, 'test-admin');
  await admin.subscribeAsync('$CONTROL/dynamic-security/v1/response');
  t.after(() => admin.end(true));
  const dynsec = (commands) => new Promise((resolve) => {
    const tag = hex24();
    const onMessage = (_t, p) => {
      const r = JSON.parse(String(p)).responses || [];
      if (r[0] && r[0].correlationData === `${tag}-0`) { admin.off('message', onMessage); resolve(r); }
    };
    admin.on('message', onMessage);
    admin.publish('$CONTROL/dynamic-security/v1', JSON.stringify({ commands: commands.map((c, i) => ({ ...c, correlationData: `${tag}-${i}` })) }));
  });
  const chatRoleTopics = async () => {
    const [r] = await dynsec([{ command: 'getRole', rolename: 'zigdash-chat' }]);
    return r.error ? [] : r.data.role.acls.map((a) => a.topic);
  };
  const clients = async () => (await dynsec([{ command: 'listClients', verbose: false, count: -1, offset: 0 }]))[0].data.clients;
  const homeRow = (id) => v.db.prepare('select * from homes where id = ?').get(id);
  const passOfHome = (id) => v.db.prepare('select * from passes where home = ? order by redeemed_at').get(id);

  const made = await v.ops['passes new']({ count: 4 });
  const codes = made.codes;
  const n1 = nonce();
  const first = await redeem(codes[0].toLowerCase().replace(/-/g, ' '), n1);
  const H = first.body.homeId;
  let hubLogin = first.body.hub;

  await t.test('redeem: a code, typed in any case with spaces, admits one Home for 90 days', async () => {
    assert.equal(first.status, 200, JSON.stringify(first.body));
    assert.deepEqual(Object.keys(first.body).sort(), ['expires_at', 'homeId', 'hub', 'kind', 'phone']);
    assert.equal(first.body.kind, 'founder');
    assert.equal(first.body.expires_at, clock + 90 * DAY);
    assert.match(H, /^[0-9a-f]{16}$/);
    assert.ok(await canConnect(first.body.hub));
    assert.ok(await canConnect(first.body.phone));
    // Only the keyed hash is kept, never the code.
    const stored = JSON.stringify(v.db.prepare('select * from passes').all());
    for (const c of codes) assert.ok(!stored.includes(c.replace(/-/g, '')) && !stored.includes(c));
  });

  await t.test('the same nonce within 15 minutes (a lost answer) gets fresh logins for the same Home; any other use is code_used', async () => {
    clock += 10 * 60000;
    const again = await redeem(codes[0], n1);
    assert.equal(again.status, 200);
    assert.equal(again.body.homeId, H);
    assert.ok(!(await canConnect(first.body.hub)), 'the earlier hub password stopped working');
    assert.ok(await canConnect(again.body.hub));
    hubLogin = again.body.hub;
    assert.deepEqual(await redeem(codes[0]), { status: 409, body: { error: 'code_used' } });
    clock += 6 * 60000;
    assert.deepEqual(await redeem(codes[0], n1), { status: 409, body: { error: 'code_used' } });
    // Two at once with one code: one Home.
    const both = await Promise.all([redeem(codes[3]), redeem(codes[3])]);
    assert.deepEqual(both.map((r) => r.status).sort(), [200, 409]);
  });

  await t.test('a wrong code, a passed deadline, a revoked code, a bad nonce', async () => {
    assert.deepEqual(await redeem('ZD-0000-0000-00'), { status: 402, body: { error: 'no_pass' } });
    assert.deepEqual(await redeem('not a code'), { status: 402, body: { error: 'no_pass' } });
    assert.equal((await redeem(codes[1], 'short')).status, 400);
    assert.equal((await api('POST', '/v1/homes', { store: 'founder', purchaseToken: codes[1] })).status, 400, 'no nonce');

    const late = (await v.ops['passes new']({ count: 1, redeem_by: clock - 1 })).codes[0];
    assert.deepEqual(await redeem(late), { status: 402, body: { error: 'deadline' } });
    await v.ops['passes extend']({ pass: late, redeem_by: clock + DAY });
    assert.equal((await redeem(late)).status, 200, 'extend gives a later deadline');

    await v.ops['passes revoke']({ pass: codes[1] });
    assert.deepEqual(await redeem(codes[1]), { status: 402, body: { error: 'revoked' } });
    await v.ops['passes unrevoke']({ pass: codes[1] });
    assert.equal((await redeem(codes[1])).status, 200);
  });

  const client = { client_id: 'tg-founder', request_topic: `homes/${H}/x/${hex24()}`, answer_topic: `homes/${H}/x/${hex24()}` };
  const aclBody = { home_id: H, request_topic: client.request_topic, answer_topic: client.answer_topic };
  let phone = first.body.phone;

  await t.test('a founder Home\'s Chat tickets need only the phone\'s login; the chat service gets its ACLs', async () => {
    const ticket = await api('POST', `/v1/homes/${H}/chat-ticket`, client, { auth: phone });
    assert.equal(ticket.status, 200, JSON.stringify(ticket.body));
    assert.equal(verifyTicket(TICKET_SECRET, ticket.body.ticket).payload.request_topic, client.request_topic);
    assert.equal((await api('POST', `/v1/homes/${H}/chat-ticket`, { purchase_token: 'anything', ...client }, { auth: phone })).status, 200, 'a token sent is ignored');
    assert.deepEqual((await internal('POST', '/v1/internal/chat-acl', { ...aclBody, op: 'add' })).body, { ok: true, op: 'add' });
    assert.ok(v.db.prepare('select 1 from chat_acls where home = ? and request_topic = ?').get(H, client.request_topic));
    assert.ok((await chatRoleTopics()).includes(client.request_topic));
  });

  await t.test('status: the app\'s (phone login) and the chat service\'s (internal); unknown is 404, not deleted', async () => {
    assert.deepEqual((await api('GET', `/v1/homes/${H}`, undefined, { auth: phone })).body, { kind: 'founder', expires_at: homeRow(H).expires_at, ended: false });
    assert.equal((await api('GET', `/v1/homes/${H}`)).status, 401);
    assert.deepEqual((await internal('GET', `/v1/internal/home/${H}`)).body, { entitled: true, ended_at: null });
    assert.equal((await internal('GET', `/v1/internal/home/${H}`, undefined, {})).status, 401);
    assert.equal((await internal('GET', `/v1/internal/home/${H}`, undefined, { 'X-Chat-Acl-Secret': ACL_SECRET, 'X-Forwarded-For': '203.0.113.9' })).status, 403);
    assert.equal((await call(httpPort, 'GET', `/v1/internal/home/${H}`, undefined, { 'X-Chat-Acl-Secret': ACL_SECRET })).status, 404, 'not on the public port');
    assert.deepEqual(await internal('GET', '/v1/internal/home/0000000000000000'), { status: 404, body: { error: 'unknown' } });
    const purchase = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-STATUS' });
    assert.deepEqual((await api('GET', `/v1/homes/${purchase.body.homeId}`, undefined, { auth: purchase.body.phone })).body, { kind: null, expires_at: null, ended: false });
    assert.equal(purchase.body.kind, undefined, 'a purchase\'s answer is unchanged');
  });

  await t.test('reissue: a lost founder\'s new code joins the same Home, with the same end', async () => {
    const re = await v.ops['passes reissue']({ home: H });
    assert.match(re.code, /^ZD-/);
    const r = await redeem(re.code);
    assert.equal(r.status, 200);
    assert.equal(r.body.homeId, H);
    assert.equal(r.body.expires_at, homeRow(H).expires_at);
    assert.ok(await canConnect(r.body.phone));
    hubLogin = r.body.hub;
    phone = r.body.phone;
    assert.equal((await redeem(re.code)).status, 409);
    assert.throws(() => v.ops['passes reissue']({ home: '0000000000000000' }), /no such Home/);
  });

  let hubLive;
  await t.test('after the end: no new hub or phone logins, no re-pairing, no Chat link; listing and removing still work', async () => {
    hubLive = await connect(hubLogin);
    assert.ok(!hubLive.error);
    clock = homeRow(H).expires_at + 1000;
    assert.deepEqual(await api('POST', `/v1/homes/${H}/hub`, undefined, { auth: phone }), { status: 402, body: { error: 'pass_ended' } });
    assert.deepEqual(await api('POST', `/v1/homes/${H}/phones`, undefined, { auth: phone }), { status: 402, body: { error: 'pass_ended' } });
    assert.equal((await api('GET', `/v1/homes/${H}/phones`, undefined, { auth: phone })).status, 200);
    assert.equal((await redeem(codes[0])).status, 409);
    assert.deepEqual(await api('POST', `/v1/homes/${H}/chat-ticket`, client, { auth: phone }), { status: 402, body: { error: 'pass_ended' } });
    assert.equal((await api('POST', `/v1/homes/${H}/chat-ticket`, {}, { auth: phone })).status, 200, 'a listing ticket');
    assert.equal((await api('POST', `/v1/homes/${H}/chat-ticket`, { client_id: client.client_id }, { auth: phone })).status, 200, 'a removal ticket');
    const other = { ...aclBody, request_topic: `homes/${H}/x/${hex24()}` };
    assert.deepEqual(await internal('POST', '/v1/internal/chat-acl', { ...other, op: 'add' }), { status: 402, body: { error: 'pass_ended' } });
    assert.equal((await api('GET', `/v1/homes/${H}`, undefined, { auth: phone })).body.ended, true);
    assert.deepEqual((await internal('GET', `/v1/internal/home/${H}`)).body, { entitled: false, ended_at: homeRow(H).expires_at });
  });

  await t.test('the sweep switches an ended Home off once: logins dropped and refused, Chat ACLs removed', async () => {
    const closed = new Promise((r) => hubLive.once('close', r));
    const s = await v.sweep();
    assert.ok(s.disabled >= 1, JSON.stringify(s));
    await closed;
    assert.ok(!(await canConnect(hubLogin)));
    assert.ok(!(await canConnect(phone)));
    const at = homeRow(H).disabled_at;
    assert.equal(at, clock);
    assert.ok(!(await chatRoleTopics()).includes(client.request_topic));
    assert.ok(v.db.prepare('select 1 from chat_acls where home = ?').get(H), 'the row stays, to give the ACLs back');
    assert.equal((await v.sweep()).disabled, 0);
    clock += 3600000;
    await v.sweep();
    assert.equal(homeRow(H).disabled_at, at, 'once');
  });

  const prefix = () => passOfHome(H).hash.slice(0, 10);
  await t.test('extend switches it back on, gives the ACLs back and tells the chat service; fewer days end it', async () => {
    pushes.length = 0;
    await v.ops['passes extend']({ pass: prefix(), days: 200 });
    assert.equal(homeRow(H).disabled_at, null);
    assert.equal(homeRow(H).expires_at, passOfHome(H).redeemed_at + 200 * DAY);
    assert.ok(await canConnect(hubLogin));
    assert.ok(await canConnect(phone));
    assert.ok((await chatRoleTopics()).includes(client.request_topic));
    assert.deepEqual(pushes, [{ path: '/v1/internal/home-changed', home: H, secret: true }]);
    // Days count from the day the code was entered: 90 is already over (and 0 would be 90 days over: deleted).
    await v.ops['passes extend']({ pass: prefix(), days: 90 });
    assert.equal(v.entitled(H), false);
    await v.sweep();
    assert.ok(homeRow(H).disabled_at);
    assert.ok(!(await canConnect(hubLogin)));
  });

  await t.test('revoke switches a Home off at once; unrevoke brings back its date and switches it on', async () => {
    await v.ops['passes extend']({ pass: prefix(), days: 200 });
    assert.ok(await canConnect(hubLogin));
    pushes.length = 0;
    const revoked = await v.ops['passes revoke']({ pass: prefix() });
    assert.equal(revoked.state, 'revoked');
    assert.equal(homeRow(H).expires_at, clock);
    assert.ok(homeRow(H).disabled_at);
    assert.ok(!(await canConnect(hubLogin)));
    assert.equal(passOfHome(H).expires_at, passOfHome(H).redeemed_at + 200 * DAY, 'the pass keeps its date');
    await v.ops['passes unrevoke']({ pass: prefix() });
    assert.equal(homeRow(H).expires_at, passOfHome(H).expires_at);
    assert.ok(await canConnect(hubLogin));
    assert.deepEqual(pushes.map((p) => p.path), ['/v1/internal/home-changed', '/v1/internal/home-changed']);
  });

  await t.test('upgrade: with a purchase, the same Home becomes a purchase Home and comes back on', async () => {
    await v.ops['passes extend']({ pass: prefix(), days: 90 });
    await v.sweep();
    assert.ok(homeRow(H).disabled_at);
    pushes.length = 0;
    const up = (body, auth = phone) => api('POST', `/v1/homes/${H}/upgrade`, body, { auth });
    assert.equal((await up({ purchaseToken: 'test-pro-UP', store: 'play' }, { username: phone.username, password: 'wrong' })).status, 401);
    assert.deepEqual(await up({ purchaseToken: 'free-user', store: 'play' }), { status: 402, body: { error: 'no_purchase' } });
    await api('POST', '/v1/homes', { purchaseToken: 'test-pro-TAKEN' });
    assert.deepEqual(await up({ purchaseToken: 'test-pro-TAKEN', store: 'play' }), { status: 409, body: { error: 'purchase_has_home' } });
    assert.deepEqual(await up({ purchaseToken: 'test-pro-UP', store: 'play' }), { status: 200, body: { kind: null } });
    assert.deepEqual((await api('GET', `/v1/homes/${H}`, undefined, { auth: phone })).body, { kind: null, expires_at: null, ended: false });
    assert.ok(await canConnect(hubLogin));
    assert.ok((await chatRoleTopics()).includes(client.request_topic));
    assert.deepEqual(pushes.map((p) => [p.path, p.home]), [['/v1/internal/home-changed', H]]);
    assert.deepEqual(await up({ purchaseToken: 'test-pro-UP', store: 'play' }), { status: 200, body: { kind: null } }, 'a retry is fine');
    const repair = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-UP' });
    assert.equal(repair.body.homeId, H, 'the purchase now pairs with this Home');
    assert.equal((await api('POST', `/v1/homes/${H}/chat-ticket`, client, { auth: phone })).status, 400, 'a purchase Home\'s ticket needs its token again');
    assert.equal((await api('POST', `/v1/homes/${H}/chat-ticket`, { purchase_token: 'test-pro-UP', ...client }, { auth: phone })).status, 200);
    // Ended founder Homes are not touched by later sweeps once upgraded.
    clock += 200 * DAY;
    await v.sweep();
    assert.ok(homeRow(H) && homeRow(H).disabled_at === null);
  });

  await t.test('race: an upgrade landing during the sweep leaves the Home on', async () => {
    const code = (await v.ops['passes new']({ count: 1 })).codes[0];
    const r = await redeem(code);
    const R = r.body.homeId;
    clock = homeRow(R).expires_at + 1;
    const [, up] = await Promise.all([
      v.sweep(),
      api('POST', `/v1/homes/${R}/upgrade`, { purchaseToken: 'test-pro-RACE', store: 'play' }, { auth: r.body.phone }),
    ]);
    assert.equal(up.status, 200);
    assert.equal(homeRow(R).disabled_at, null);
    assert.ok(await canConnect(r.body.hub));
    await v.sweep();
    assert.ok(await canConnect(r.body.hub));
  });

  await t.test('deletion, 90 days after the end: retained messages cleared, logins, role and rows gone, a tombstone; the chat service told after the lock', async () => {
    const code = (await v.ops['passes new']({ count: 1 })).codes[0];
    const r = await redeem(code);
    const D = r.body.homeId;
    const hub = await connect(r.body.hub);
    for (let i = 0; i < 500; i++) hub.publish(`homes/${D}/s/${i}`, `sealed ${i}`, { qos: 0, retain: true });
    await hub.publishAsync(`homes/${D}/s/last`, 'sealed', { qos: 1, retain: true });
    hub.end(true);
    const topics = { home_id: D, request_topic: `homes/${D}/x/${hex24()}`, answer_topic: `homes/${D}/x/${hex24()}` };
    assert.equal((await internal('POST', '/v1/internal/chat-acl', { ...topics, op: 'add' })).status, 200);

    // A login that may read every Home, to see what is retained.
    await dynsec([
      { command: 'createRole', rolename: 'checker', acls: [{ acltype: 'subscribePattern', topic: 'homes/#', allow: true }, { acltype: 'publishClientReceive', topic: 'homes/#', allow: true }] },
      { command: 'createClient', username: 'checker', password: 'checker-pw', roles: [{ rolename: 'checker' }] },
    ]);
    const retained = async () => {
      const c = await connect({ username: 'checker', password: 'checker-pw' });
      let n = 0;
      c.on('message', (_t, p, packet) => { if (packet.retain && p.length) n++; });
      await c.subscribeAsync(`homes/${D}/#`, { qos: 0 });
      await sleep(700);
      c.end(true);
      return n;
    };
    assert.equal(await retained(), 501);

    clock = homeRow(D).expires_at + 1;
    await v.sweep();
    clock += 89 * DAY;
    await v.sweep();
    assert.ok(homeRow(D), 'not yet: 90 days after the end');
    clock += 2 * DAY;
    pushes.length = 0;
    onPush = (e) => (e.path === '/v1/internal/home-deleted' ? Promise.race([v.withLock(e.home, async () => 'free'), sleep(1000).then(() => 'held')]) : null);
    const s = await v.sweep();
    onPush = null;
    assert.ok(s.deleted >= 1, JSON.stringify(s));
    assert.equal(await retained(), 0);
    const left = await clients();
    assert.ok(!left.some((u) => u.includes(D)), JSON.stringify(left));
    assert.ok(!left.some((u) => u.startsWith('clear-')), 'the clearing login is gone');
    assert.match((await dynsec([{ command: 'getRole', rolename: `home-${D}` }]))[0].error, /not found/i);
    assert.ok(!(await chatRoleTopics()).includes(topics.request_topic));
    for (const table of ['phones', 'chat_acls']) assert.equal(v.db.prepare(`select count(*) as n from ${table} where home = ?`).get(D).n, 0, table);
    assert.equal(homeRow(D), undefined);
    const tomb = v.db.prepare('select * from tombstones where home = ?').get(D);
    assert.equal(tomb.deleted_at, clock);
    assert.equal(tomb.notified_at, clock);
    assert.equal(passOfHome(D).home, D, 'the pass keeps its hash, dates and Home');
    assert.deepEqual(pushes.find((p) => p.home === D), { path: '/v1/internal/home-deleted', home: D, secret: true, seen: 'free' });

    assert.deepEqual(await api('GET', `/v1/homes/${D}`), { status: 410, body: { error: 'deleted' } });
    assert.deepEqual(await api('POST', `/v1/homes/${D}/upgrade`, { purchaseToken: 'test-pro-LATE' }), { status: 410, body: { error: 'deleted' } });
    assert.deepEqual(await internal('GET', `/v1/internal/home/${D}`), { status: 410, body: { error: 'deleted' } });
    assert.equal((await redeem(code)).status, 409);
  });

  await t.test('homes delete: a purchase Home too; a push not answered is sent again by the next sweep', async () => {
    const p = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-DELETE' });
    const P = p.body.homeId;
    chatStatus = 500;
    assert.deepEqual(await v.ops['homes delete']({ home: P }), { home: P, outcome: 'deleted' });
    assert.ok(!(await canConnect(p.body.hub)));
    assert.equal(v.db.prepare('select notified_at from tombstones where home = ?').get(P).notified_at, null);
    chatStatus = 200;
    pushes.length = 0;
    assert.equal((await v.sweep()).notified, 1);
    assert.deepEqual(pushes.map((x) => [x.path, x.home]), [['/v1/internal/home-deleted', P]]);
    assert.ok(v.db.prepare('select notified_at from tombstones where home = ?').get(P).notified_at);
    assert.equal((await v.sweep()).notified, 0);
    assert.equal((await api('GET', `/v1/homes/${P}`)).status, 410);
    assert.notEqual((await api('POST', '/v1/homes', { purchaseToken: 'test-pro-DELETE' })).body.homeId, P, 'the purchase pairs a new Home');
    assert.deepEqual(await v.ops['homes delete']({ home: P }), { home: P, outcome: 'already deleted' });
    await assert.rejects(v.ops['homes delete']({ home: '0000000000000000' }), /no such Home/);
  });

  await t.test('pairing is limited per IPv6 /64, not per address', async () => {
    const a = (i) => `2001:db8:7:${i}::${(crypto.randomInt(65535)).toString(16)}`;
    for (let i = 0; i < 5; i++) assert.equal((await api('POST', '/v1/homes', { purchaseToken: 'free-user' }, { ip: a(1) })).status, 402);
    assert.equal((await api('POST', '/v1/homes', { purchaseToken: 'free-user' }, { ip: a(1) })).status, 429, 'another address of the same /64');
    assert.equal((await api('POST', '/v1/homes', { purchaseToken: 'free-user' }, { ip: a(2) })).status, 402, 'another /64');
  });

  await t.test('wrong codes above the hourly ceiling are logged once, and only logged', async () => {
    clock += 3600000;
    logs.length = 0;
    for (let i = 0; i < 6; i++) assert.equal((await redeem(`ZD-0000-0000-${i}0`)).status, 402);
    const lines = logs.filter((l) => /wrong founder/.test(l));
    assert.equal(lines.length, 1);
    assert.ok(!logs.some((l) => /ZD/.test(l)), 'no code in the logs');
  });

  await t.test('the CLI asks the running verifier over its socket', async () => {
    const env = { ...process.env, ADMIN_SOCKET: socket };
    delete env.NODE_OPTIONS;
    const cli = (...args) => new Promise((resolve) => {
      execFile(process.execPath, ['cli.mjs', ...args], { cwd: verifierDir, env }, (e, stdout, stderr) => resolve({ code: e ? e.code : 0, stdout, stderr }));
    });
    const made2 = await cli('passes', 'new', '--count', '2', '--days', '30');
    assert.equal(made2.code, 0, made2.stderr);
    const lines = made2.stdout.trim().split('\n');
    assert.equal(lines.filter((l) => /^ZD-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{2}$/.test(l)).length, 2);
    assert.match(lines[2], /2 code\(s\), 30 days each/);
    assert.equal((await redeem(lines[0])).body.expires_at, clock + 30 * DAY);
    const list = await cli('passes', 'list');
    assert.match(list.stdout, /active/);
    assert.match(list.stdout, /not used/);
    assert.match((await cli('passes', 'sweep')).stdout, /disabled: \d+/);
    const bad = await cli('passes', 'revoke', 'ffffffffffff');
    assert.equal(bad.code, 1);
    assert.match(bad.stderr, /no such pass/);
    assert.match((await cli('passes', 'burn')).stderr, /usage/);
  });

  await t.test('a year after deletion its tombstone and passes go; the Home is then unknown (404), never "deleted"', async () => {
    const D = v.db.prepare('select home from tombstones order by deleted_at limit 1').get().home;
    clock += 366 * DAY;
    await v.sweep();
    assert.equal(v.db.prepare('select count(*) as n from tombstones where home = ?').get(D).n, 0);
    assert.equal(v.db.prepare('select count(*) as n from passes where home = ?').get(D).n, 0);
    assert.deepEqual(await internal('GET', `/v1/internal/home/${D}`), { status: 404, body: { error: 'unknown' } });
  });
});
