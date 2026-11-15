// Chat tickets and the chat service's ACL entries (docs/design/chat-linking.md
// §2), against a real Mosquitto with dynamic security started here (skipped
// when mosquitto isn't installed). Google Play is replaced by a test hook.
import test from 'node:test';
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import net from 'node:net';
import crypto from 'node:crypto';
import mqtt from 'mqtt';
import { createVerifier } from '../server.mjs';
import { verifyTicket } from '../ticket.mjs';

const have = (bin) => spawnSync('which', [bin]).status === 0;
const freePort = () => new Promise((r) => { const s = net.createServer(); s.listen(0, () => { const p = s.address().port; s.close(() => r(p)); }); });
const plugin = ['/opt/homebrew/lib/mosquitto_dynamic_security.so', '/usr/lib/mosquitto_dynamic_security.so', '/usr/lib/x86_64-linux-gnu/mosquitto_dynamic_security.so'].find((p) => fs.existsSync(p));
const skip = !have('mosquitto') || !have('mosquitto_ctrl') || !plugin ? 'mosquitto with dynamic security not installed' : false;

const TICKET_SECRET = crypto.randomBytes(32).toString('base64url');
const ACL_SECRET = crypto.randomBytes(32).toString('base64url');
const hex24 = () => crypto.randomBytes(12).toString('hex');

test('chat: tickets and the chat role\'s ACL entries, against a real broker', { skip }, async (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'zd-relay-chat-'));
  const adminPw = crypto.randomBytes(12).toString('hex');
  assert.equal(spawnSync('mosquitto_ctrl', ['dynsec', 'init', path.join(dir, 'dynsec.json'), 'admin', adminPw]).status, 0);
  const port = await freePort();
  fs.writeFileSync(path.join(dir, 'mosquitto.conf'),
    `listener ${port} 127.0.0.1\nallow_anonymous false\npersistence false\nplugin ${plugin}\nplugin_opt_config_file ${dir}/dynsec.json\n`);
  const broker = spawn('mosquitto', ['-c', path.join(dir, 'mosquitto.conf')], { stdio: 'ignore' });
  t.after(() => broker.kill());
  await new Promise((r) => setTimeout(r, 600));
  const url = `mqtt://127.0.0.1:${port}`;

  // Google Play, played by a hook: a purchase refunded after pairing, or Play down.
  const refunded = new Set();
  let playDown = false;
  const play = (token) => {
    if (playDown) throw new Error('play 500');
    return token.startsWith('test-pro-') && !refunded.has(token);
  };
  fs.writeFileSync(path.join(dir, 'ticket'), `${TICKET_SECRET}\n`);
  const v = createVerifier({
    VERIFY: 'fake', PORT: '0', INTERNAL_PORT: '0', MQTT_URL: url, ADMIN_USER: 'admin', ADMIN_PASSWORD: adminPw, HUB_URL: url, PHONE_URL: url,
    CHAT_TICKET_SECRET_FILE: path.join(dir, 'ticket'), CHAT_ACL_SECRET: ACL_SECRET, TICKETS_PER_HOUR: '12',
  }, { purchaseValid: play });
  const httpPort = await v.start();
  const internalPort = v.internalPort();
  t.after(() => v.stop());
  assert.notEqual(internalPort, httpPort);

  const call = async (p, method, body, headers = {}) => {
    const res = await fetch(`http://127.0.0.1:${p}`.concat(method.path), {
      method: method.verb, headers: { 'Content-Type': 'application/json', ...headers }, body: body === undefined ? undefined : JSON.stringify(body),
    });
    return { status: res.status, body: await res.json() };
  };
  const basic = (c) => ({ Authorization: `Basic ${Buffer.from(`${c.username}:${c.password}`).toString('base64')}` });
  const api = (verb, p, body, auth) => call(httpPort, { verb, path: p }, body, auth ? basic(auth) : {});
  const acl = (body, headers = { 'X-Chat-Acl-Secret': ACL_SECRET }, onPort = internalPort) => call(onPort, { verb: 'POST', path: '/v1/internal/chat-acl' }, body, headers);
  const connect = (c, id) => new Promise((resolve) => {
    const client = mqtt.connect(url, { username: c.username, password: c.password, clientId: id, protocolVersion: 5, reconnectPeriod: 0 });
    client.once('connect', () => resolve(client));
    client.once('error', (e) => { client.end(true); resolve({ error: e.code || e.message }); });
  });

  const A = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-AAA' });
  const B = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-BBB' });
  const H = A.body.homeId;
  const client = { client_id: 'tg-a1b2c3', request_topic: `homes/${H}/x/${hex24()}`, answer_topic: `homes/${H}/x/${hex24()}` };
  const ticketPath = `/v1/homes/${H}/chat-ticket`;

  await t.test('ticket: a phone of the Home with its valid purchase gets a signed ticket for 10 minutes', async () => {
    const r = await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client }, A.body.phone);
    assert.equal(r.status, 200);
    assert.deepEqual(Object.keys(r.body).sort(), ['answer_topic', 'client_id', 'exp', 'home_id', 'request_topic', 'ticket']);
    const { payload } = verifyTicket(TICKET_SECRET, r.body.ticket);
    assert.deepEqual({ ...payload, iat: 0 }, { v: 1, home_id: H, ...client, iat: 0, exp: r.body.exp });
    assert.ok(Math.abs(payload.exp - (Date.now() / 1000 + 600)) < 5);
    assert.equal(verifyTicket('another secret', r.body.ticket).error, 'bad_ticket');
    // Without a client: for listing and removing links.
    const bare = await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA' }, A.body.phone);
    assert.equal(bare.status, 200);
    assert.equal(verifyTicket(TICKET_SECRET, bare.body.ticket).payload.client_id, null);
  });

  await t.test('ticket: a wrong login, or another Home\'s phone, is 401', async () => {
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client }, { username: A.body.phone.username, password: 'wrong' })).status, 401);
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client }, B.body.phone)).status, 401);
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client })).status, 401);
  });

  await t.test('ticket: another purchase, a refunded one, or Play down: 402, 402, 503', async () => {
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-BBB', ...client }, A.body.phone)).status, 402, 'valid, but not this Home\'s');
    refunded.add('test-pro-AAA');
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client }, A.body.phone)).status, 402, 'checked with Play now, not only at pairing');
    refunded.delete('test-pro-AAA');
    playDown = true;
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client }, A.body.phone)).status, 503);
    playDown = false;
    // An App Store Home is not in this beta: its binding is not a Play token.
    const apple = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-IOS', store: 'apple' });
    assert.equal((await api('POST', `/v1/homes/${apple.body.homeId}/chat-ticket`, { purchaseToken: 'test-pro-IOS' }, apple.body.phone)).status, 402);
  });

  await t.test('ticket: a missing purchase or topics outside the Home are 400', async () => {
    assert.equal((await api('POST', ticketPath, { ...client }, A.body.phone)).status, 400);
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client, answer_topic: `homes/${B.body.homeId}/x/${hex24()}` }, A.body.phone)).status, 400);
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client, answer_topic: client.request_topic }, A.body.phone)).status, 400);
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client, client_id: 'no spaces' }, A.body.phone)).status, 400);
    assert.equal((await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA', ...client, request_topic: `homes/${H}/#` }, A.body.phone)).status, 400);
  });

  const body = { home_id: H, request_topic: client.request_topic, answer_topic: client.answer_topic };

  await t.test('internal ACL route: not on the public port; refused without its secret or through a proxy', async () => {
    assert.equal((await acl({ ...body, op: 'add' }, { 'X-Chat-Acl-Secret': ACL_SECRET }, httpPort)).status, 404, 'Caddy\'s port has no such route');
    assert.equal((await acl({ ...body, op: 'add' }, {})).status, 401);
    assert.equal((await acl({ ...body, op: 'add' }, { 'X-Chat-Acl-Secret': `${ACL_SECRET}x` })).status, 401);
    assert.equal((await acl({ ...body, op: 'add' }, { 'X-Chat-Acl-Secret': ACL_SECRET, 'X-Forwarded-For': '203.0.113.9' })).status, 403);
    assert.equal((await acl({ ...body, op: 'add' }, { 'X-Chat-Acl-Secret': ACL_SECRET, Forwarded: 'for=203.0.113.9' })).status, 403);
    assert.equal((await acl({ ...body, op: 'grant' })).status, 400);
    assert.equal((await acl({ ...body, op: 'add', answer_topic: `homes/${H}/s/#` })).status, 400);
    assert.equal((await acl({ ...body, op: 'add', home_id: '0000000000000000', request_topic: `homes/0000000000000000/x/${hex24()}`, answer_topic: `homes/0000000000000000/x/${hex24()}` })).status, 404);
  });

  // The chat service's own broker login, holding the chat role.
  const admin = await connect({ username: 'admin', password: adminPw }, 'test-admin');
  const dynsec = (commands) => new Promise((resolve) => {
    admin.once('message', (_t, p) => resolve(JSON.parse(String(p))));
    admin.publish('$CONTROL/dynamic-security/v1', JSON.stringify({ commands }));
  });
  await admin.subscribeAsync('$CONTROL/dynamic-security/v1/response');
  t.after(() => admin.end(true));
  const chatLogin = { username: 'zigdash-chat', password: crypto.randomBytes(12).toString('hex') };
  const hubLogin = A.body.hub;

  /** What the chat login can do with this client's topics and a few others. */
  async function chatCan() {
    const chat = await connect(chatLogin, `chat-${hex24()}`);
    const hub = await connect(hubLogin, `hub-${hex24()}`);
    assert.ok(!chat.error && !hub.error, JSON.stringify([chat.error, hub.error]));
    const out = {};
    const tryP = async (p) => { try { await p; return true; } catch { return false; } };
    out.subscribeAnswer = await tryP(chat.subscribeAsync(client.answer_topic, { qos: 1 }));
    out.subscribeHome = await tryP(chat.subscribeAsync(`homes/${H}/s/#`, { qos: 1 }));
    out.publishCommand = await tryP(chat.publishAsync(`homes/${H}/c`, 'x', { qos: 1 }));
    await hub.subscribeAsync(client.request_topic, { qos: 1 });
    const gotRequest = new Promise((r) => { hub.on('message', (topic) => { if (topic === client.request_topic) r(true); }); setTimeout(() => r(false), 500); });
    out.publishRequest = await tryP(chat.publishAsync(client.request_topic, 'sealed', { qos: 1 }));
    out.requestArrived = await gotRequest;
    const gotAnswer = new Promise((r) => { chat.on('message', (topic) => { if (topic === client.answer_topic) r(true); }); setTimeout(() => r(false), 500); });
    hub.publish(client.answer_topic, 'sealed answer', { qos: 1 });
    out.answerArrived = await gotAnswer;
    chat.end(true); hub.end(true);
    return out;
  }

  await t.test('internal ACL route: add gives the chat role this client\'s two topics and nothing else; remove takes them back', async () => {
    assert.deepEqual((await acl({ ...body, op: 'add' })).body, { ok: true, op: 'add' });
    assert.equal((await acl({ ...body, op: 'add' })).status, 200, 'adding twice is fine');
    const created = await dynsec([{ command: 'createClient', ...chatLogin, roles: [{ rolename: 'zigdash-chat' }] }]);
    assert.ok(!created.responses[0].error, created.responses[0].error);
    assert.deepEqual(await chatCan(), { subscribeAnswer: true, subscribeHome: false, publishCommand: false, publishRequest: true, requestArrived: true, answerArrived: true });
    assert.deepEqual((await acl({ ...body, op: 'remove' })).body, { ok: true, op: 'remove' });
    assert.equal((await acl({ ...body, op: 'remove' })).status, 200, 'removing twice is fine');
    const after = await chatCan();
    assert.equal(after.subscribeAnswer, false);
    assert.equal(after.requestArrived, false);
    assert.equal(after.answerArrived, false);
  });

  await t.test('tickets are limited per Home an hour', async () => {
    let last;
    for (let i = 0; i < 14; i++) last = await api('POST', ticketPath, { purchaseToken: 'test-pro-AAA' }, A.body.phone);
    assert.equal(last.status, 429);
  });
});

test('chat: off without its secrets', { skip }, async (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'zd-relay-chat-off-'));
  const adminPw = crypto.randomBytes(12).toString('hex');
  assert.equal(spawnSync('mosquitto_ctrl', ['dynsec', 'init', path.join(dir, 'dynsec.json'), 'admin', adminPw]).status, 0);
  const port = await freePort();
  fs.writeFileSync(path.join(dir, 'mosquitto.conf'),
    `listener ${port} 127.0.0.1\nallow_anonymous false\npersistence false\nplugin ${plugin}\nplugin_opt_config_file ${dir}/dynsec.json\n`);
  const broker = spawn('mosquitto', ['-c', path.join(dir, 'mosquitto.conf')], { stdio: 'ignore' });
  t.after(() => broker.kill());
  await new Promise((r) => setTimeout(r, 600));
  const url = `mqtt://127.0.0.1:${port}`;
  const v = createVerifier({ VERIFY: 'fake', PORT: '0', INTERNAL_PORT: '0', MQTT_URL: url, ADMIN_USER: 'admin', ADMIN_PASSWORD: adminPw });
  const httpPort = await v.start();
  t.after(() => v.stop());
  const home = await (await fetch(`http://127.0.0.1:${httpPort}/v1/homes`, { method: 'POST', body: JSON.stringify({ purchaseToken: 'test-pro-X' }) })).json();
  const auth = { Authorization: `Basic ${Buffer.from(`${home.phone.username}:${home.phone.password}`).toString('base64')}` };
  const ticket = await fetch(`http://127.0.0.1:${httpPort}/v1/homes/${home.homeId}/chat-ticket`, { method: 'POST', headers: auth, body: JSON.stringify({ purchaseToken: 'test-pro-X' }) });
  assert.equal(ticket.status, 503);
  const acl = await fetch(`http://127.0.0.1:${v.internalPort()}/v1/internal/chat-acl`, { method: 'POST', headers: { 'X-Chat-Acl-Secret': 'anything' }, body: '{}' });
  assert.equal(acl.status, 503);
});
