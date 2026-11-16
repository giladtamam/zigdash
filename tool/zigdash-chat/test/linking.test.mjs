// Phase 3 (docs/design/chat-linking.md): linking from the app over HTTPS, the
// live bot's webhook, early access passed to the support Worker, unlinking,
// the monthly cap and the budget. The release Engine runs on a fake
// Zigbee2MQTT with remote on, over a broker that plays the hub's broker and
// the relay; Telegram, Claude, the verifier and the Worker are fakes.
// Run: env -u NODE_OPTIONS node --test test/*.test.mjs

import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { loadChatEngine, startBroker, startHub, fakeTelegram, fakeClaude, fakeVerifier, tmpDir, CONTROLS } from './harness.mjs';
import { startService, configFromEnv } from '../service.mjs';
import { makeMetrics } from '../metrics.mjs';
import { readKeys, loadServiceKey } from '../keystore.mjs';
import { chatTopics, sha256 } from '../wire.mjs';
import { CODE_RE, CODE_ALPHABET, LINK_TEXT, linkedId } from '../bot.mjs';
import { verifyTicket } from '../ticket.mjs';
import { signTicket } from '../../../relay/verifier/ticket.mjs';

const Engine = loadChatEngine();
const HOME = 'a1b2c3d4e5f60718';
const OTHER_HOME = '0f1e2d3c4b5a6978';
const OWNER = '424242';
const DANA = '515151';
const TICKET_SECRET = crypto.randomBytes(32).toString('base64url');
const ACL_SECRET = 'acl-secret-never-logged';
const WORKER_SECRET = 'worker-secret-never-logged';
const WEBHOOK_SECRET = 'hook_secret_never_logged_123';
const BOT_TOKEN = '7000000001:AAtest-token-never-logged';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const SCRIPT = [
  [/close the office shutter/i, [{ tool: 'set_device', input: { devices: ['Office shutter'], command: { state: 'CLOSE' } } }, { text: 'Closing the office shutter.' }]],
  [/how are things/i, [{ text: 'All quiet at home.' }]],
];

/** A Chat client the way the app makes one: id, token, key, its relay topics and its hub config. */
function newClient(homeId = HOME, { scope = 'control' } = {}) {
  const clientId = `tg-${crypto.randomBytes(3).toString('hex')}`;
  const key = crypto.randomBytes(32);
  const token = crypto.randomBytes(32).toString('base64url');
  const t = chatTopics({ transport: 'relay', clientId, key, homeId });
  return {
    clientId, homeId, key, token, scope,
    topics: { request_topic: t.req, answer_topic: t.res },
    config: JSON.stringify({ v: 1, name: 'Telegram', hash: sha256(token), key: key.toString('base64'), scope, controls: CONTROLS }),
    ticket: (over = {}, now = Date.now()) => signTicket(TICKET_SECRET, { home_id: homeId, client_id: clientId, request_topic: t.req, answer_topic: t.res, ...over }, now).ticket,
  };
}

async function world(t, { cap = 300, budgetUsd = 20, timeZone } = {}) {
  const broker = await startBroker();
  const dir = tmpDir();
  const lines = [];
  const origLog = console.log, origErr = console.error;
  console.log = (...a) => lines.push(a.join(' '));
  console.error = (...a) => lines.push(a.join(' '));
  const hubClient = await broker.connect();
  const hub = await startHub(Engine, hubClient, { relay: broker });
  const phoneMqtt = await broker.connect(); // the app at home, on the hub's broker
  phoneMqtt.publish('zigdash/remote/set', JSON.stringify({ url: 'mqtts://relay.example', homeId: HOME, username: 'u', password: 'p', key: Buffer.alloc(32, 7).toString('base64') }));
  for (let i = 0; i < 100 && !(hub.engine.remote && hub.engine.remote.connected); i++) await sleep(20);

  const tg = fakeTelegram();
  const verifier = fakeVerifier({ secret: ACL_SECRET });
  verifier.setHome(HOME, { entitled: true, ended_at: null });
  verifier.setHome(OTHER_HOME, { entitled: true, ended_at: null });
  const { acl } = verifier;
  const worker = { forwarded: [], linked: [] };
  const fetchImpl = async (url, init) => {
    if (url.startsWith('https://api.telegram.org/')) return tg.fetchImpl(url, init);
    if (verifier.handles(url)) return verifier.fetch(url, init);
    const body = JSON.parse(init.body);
    if (url.startsWith('https://worker.test/v1/early/')) {
      assert.equal(init.headers['X-ZigDash-Chat-Secret'], WORKER_SECRET);
      if (url.endsWith('/tg')) worker.forwarded.push(body); else worker.linked.push(body.ids);
      return { status: 200, json: async () => ({}) };
    }
    throw new Error(`unexpected fetch ${url}`);
  };
  let shift = 0;
  const now = () => Date.now() + shift;
  const config = {
    ...configFromEnv({}),
    keysFile: path.join(dir, 'keys.json'), secretsFile: path.join(dir, 'secrets.json'), stateFile: path.join(dir, 'state.json'),
    transport: 'relay', telegramMode: 'webhook', httpPort: 0, httpHost: '127.0.0.1', internalPort: 0,
    verifierUrl: 'http://verifier.test:8788', workerUrl: 'https://worker.test', cap, budgetUsd, timeZone,
  };
  loadServiceKey(config.secretsFile, { create: true });
  const claude = fakeClaude(SCRIPT);
  const serviceClient = await broker.connect();
  const metrics = makeMetrics((l) => lines.push(l));
  const service = await startService(config, {
    anthropic: claude, mqttClient: serviceClient, fetchImpl, metrics, telegramToken: BOT_TOKEN, now,
    secrets: { ticket: TICKET_SECRET, acl: ACL_SECRET, worker: WORKER_SECRET, webhook: WEBHOOK_SECRET },
  });
  t.after(async () => {
    await service.stop();
    await hub.stop();
    await broker.stop();
    console.log = origLog;
    console.error = origErr;
  });
  const base = `http://127.0.0.1:${service.port}`;
  const api = async (method, p, body, ticket) => {
    const res = await fetch(`${base}${p}`, {
      method, headers: { 'content-type': 'application/json', ...(ticket ? { 'X-Chat-Ticket': ticket } : {}) },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    return { status: res.status, body: await res.json() };
  };
  /** Delivers an update through the webhook, as Telegram would, and waits for the work. */
  const hook = async (update, { secret = WEBHOOK_SECRET, header = WEBHOOK_SECRET } = {}) => {
    const res = await fetch(`${base}/v1/tg/${secret}`, { method: 'POST', headers: { 'content-type': 'application/json', 'X-Telegram-Bot-Api-Secret-Token': header }, body: JSON.stringify(update) });
    await sleep(5);
    await service.chat.idle();
    return res.status;
  };
  const say = (chatId, text, opts) => hook(tg.update(chatId, text, opts));
  const lastTo = (chatId) => tg.sent.filter((s) => s.chatId === String(chatId)).at(-1);
  /** The app's whole link flow for [client], claimed by [chatId]. */
  const link = async (client, chatId = OWNER, { firstName = 'Owner' } = {}) => {
    phoneMqtt.publish(`zigdash/chat/clients/${client.clientId}`, client.config, { qos: 1, retain: true });
    await sleep(80);
    const created = await api('POST', '/v1/link', { ticket: client.ticket(), token: client.token, key: client.key.toString('base64'), scope: client.scope });
    assert.equal(created.status, 200, JSON.stringify(created.body));
    await say(chatId, `/start ${created.body.code}`, { firstName });
    const backCode = /code: (\d{4})/.exec(lastTo(chatId).text)[1];
    const confirmed = await api('POST', '/v1/link/confirm', { ticket: client.ticket(), code_back: backCode });
    return { created, backCode, confirmed };
  };
  const keys = () => readKeys(config.keysFile, loadServiceKey(config.secretsFile)).clients;
  /** The verifier's push to the service's internal port. */
  const internal = async (p, body, { headers = {}, method = 'POST' } = {}) => {
    const res = await fetch(`http://127.0.0.1:${service.internalPort}${p}`, {
      method, headers: { 'content-type': 'application/json', 'X-Chat-Acl-Secret': ACL_SECRET, ...headers }, body: method === 'GET' ? undefined : JSON.stringify(body),
    });
    return { status: res.status, body: await res.json() };
  };
  return {
    broker, hub, tg, claude, service, api, hook, say, lastTo, link, keys, internal, acl, worker, lines, metrics, phoneMqtt, config, verifier,
    setAcl: verifier.setAcl, later: (ms) => { shift += ms; }, now,
  };
}

const noSecretsInLogs = (lines, ...words) => {
  for (const l of lines) for (const w of words) assert.ok(!l.includes(String(w)), `a log line holds "${w}": ${l}`);
};

// ---------- the whole flow ----------

test('link: ticket, code, claim, back-code; ACL only on confirm; then chat through the relay; then remove from the app', async (t) => {
  const w = await world(t);
  const c = newClient();
  w.phoneMqtt.publish(`zigdash/chat/clients/${c.clientId}`, c.config, { qos: 1, retain: true });
  await sleep(80);
  const created = await w.api('POST', '/v1/link', { ticket: c.ticket(), token: c.token, key: c.key.toString('base64'), scope: 'control' });
  assert.equal(created.status, 200);
  assert.match(created.body.code, CODE_RE);
  assert.equal(created.body.url, `https://t.me/ZigDashHomeBot?start=${created.body.code}`);
  assert.equal(created.body.expires_in, 600);

  await w.say(OWNER, `/start ${created.body.code}`, { firstName: 'Gilad' });
  const backCode = /code: (\d{4})/.exec(w.lastTo(OWNER).text)[1];
  assert.deepEqual(w.acl, [], 'a claim alone opens nothing on the broker');
  assert.deepEqual(w.keys(), {}, 'nor is anything written');

  const wrong = await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: backCode === '0000' ? '1111' : '0000' });
  assert.deepEqual([wrong.status, wrong.body], [400, { error: 'wrong_code', tries_left: 2 }]);
  const ok = await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: backCode });
  assert.deepEqual([ok.status, ok.body], [200, { linked: true, client_id: c.clientId, telegram_name: 'Gilad', scope: 'control' }]);
  assert.deepEqual(w.acl, [{ home_id: HOME, ...c.topics, op: 'add' }]);
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.linked);
  assert.deepEqual(w.worker.linked.at(-1), [linkedId(WORKER_SECRET, OWNER)], 'the Worker knows the chat as a hash');

  // Encrypted at rest, one entry for the binding.
  const entry = Object.values(w.keys())[0];
  assert.deepEqual([entry.home_id, entry.client_id, entry.chat_id, entry.scope], [HOME, c.clientId, OWNER, 'control']);
  assert.ok(!fs.readFileSync(w.config.keysFile, 'utf8').includes(c.token));

  await w.say(OWNER, 'close the office shutter');
  assert.equal(w.lastTo(OWNER).text, 'Closing the office shutter.');
  assert.deepEqual(w.hub.injected, [{ topic: 'zigbee2mqtt/Office shutter/set', payload: { state: 'CLOSE' } }]);

  const list = await w.api('GET', '/v1/links', undefined, c.ticket());
  assert.equal(list.status, 200);
  assert.equal(list.body.links.length, 1);
  assert.deepEqual({ ...list.body.links[0], last_used: typeof list.body.links[0].last_used, linked_at: typeof list.body.links[0].linked_at },
    { client_id: c.clientId, telegram_name: 'Gilad', scope: 'control', last_used: 'number', linked_at: 'number' });

  // Removing needs a fresh ticket of this Home.
  assert.equal((await w.api('DELETE', `/v1/link/${c.clientId}`)).status, 401);
  assert.equal((await w.api('DELETE', `/v1/link/${c.clientId}`, undefined, c.ticket({}, Date.now() - 11 * 60000))).status, 401);
  assert.equal((await w.api('DELETE', `/v1/link/${c.clientId}`, undefined, newClient(OTHER_HOME).ticket({ client_id: c.clientId }))).status, 404);
  const removed = await w.api('DELETE', `/v1/link/${c.clientId}`, undefined, c.ticket({ request_topic: null, answer_topic: null }));
  assert.deepEqual([removed.status, removed.body], [200, { removed: true }]);
  assert.deepEqual(w.acl.at(-1), { home_id: HOME, ...c.topics, op: 'remove' });
  assert.deepEqual(w.keys(), {});
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.unlinkedInApp);
  assert.deepEqual(w.worker.linked.at(-1), []);
  assert.equal((await w.api('DELETE', `/v1/link/${c.clientId}`, undefined, c.ticket())).status, 404, 'already gone');

  // Now a stranger: the message goes to the Worker's early-access reply, never to the model.
  const calls = w.claude.calls.length;
  await w.say(OWNER, 'close the office shutter');
  assert.equal(w.claude.calls.length, calls);
  assert.deepEqual(w.worker.forwarded.at(-1).message, { chat: { id: Number(OWNER), type: 'private' }, from: { language_code: 'en' }, text: '' });
  noSecretsInLogs(w.lines, OWNER, 'Gilad', backCode, c.token, created.body.code, c.clientId, HOME, BOT_TOKEN, ACL_SECRET, WORKER_SECRET, WEBHOOK_SECRET, 'shutter');
});

// ---------- tickets ----------

test('link: a forged, expired or other-key ticket is refused; 5 links a Home an hour', async (t) => {
  const w = await world(t);
  const c = newClient();
  const body = (ticket, over = {}) => ({ ticket, token: c.token, key: c.key.toString('base64'), scope: 'read', ...over });
  const forged = signTicket('another secret', { home_id: HOME, client_id: c.clientId, ...c.topics }).ticket;
  assert.deepEqual(await w.api('POST', '/v1/link', body(forged)), { status: 401, body: { error: 'bad_ticket' } });
  assert.deepEqual(await w.api('POST', '/v1/link', body(c.ticket({}, Date.now() - 11 * 60000))), { status: 401, body: { error: 'ticket_expired' } });
  const tampered = c.ticket().replace(/^[^.]+/, Buffer.from(JSON.stringify({ v: 1, home_id: OTHER_HOME, client_id: c.clientId, ...c.topics, exp: 9e9 })).toString('base64url'));
  assert.equal((await w.api('POST', '/v1/link', body(tampered))).status, 401);
  assert.deepEqual(await w.api('POST', '/v1/link', body(c.ticket(), { key: crypto.randomBytes(32).toString('base64') })), { status: 400, body: { error: 'topics_mismatch' } }, 'the topics must be the ones this key makes');
  assert.equal((await w.api('POST', '/v1/link', body(c.ticket({ request_topic: null, answer_topic: null })))).status, 400);
  assert.equal((await w.api('POST', '/v1/link', body(c.ticket(), { scope: 'admin' }))).status, 400);
  assert.equal((await w.api('POST', '/v1/link', body(c.ticket(), { token: 'short' }))).status, 400);
  for (let i = 0; i < 5; i++) assert.equal((await w.api('POST', '/v1/link', body(c.ticket()))).status, 200);
  assert.deepEqual(await w.api('POST', '/v1/link', body(c.ticket())), { status: 429, body: { error: 'too_many' } });
  assert.equal((await w.api('POST', '/v1/link', body(newClient(OTHER_HOME).ticket()))).status, 400, 'another Home has its own count (this one fails on its topics only)');
  assert.equal(w.service.chat.pendingCount(), 1, 'a new code replaces the client\'s previous one');
});

test('ticket: the verifier signs and the service checks the same way', () => {
  const { ticket, payload } = signTicket('s3cret', { home_id: HOME, client_id: 'tg-1', request_topic: 'a', answer_topic: 'b' });
  assert.deepEqual(verifyTicket('s3cret', ticket).payload, payload);
  assert.equal(verifyTicket('s3cret', ticket, (payload.exp + 1) * 1000).error, 'ticket_expired');
  assert.equal(verifyTicket('other', ticket).error, 'bad_ticket');
  assert.equal(verifyTicket('s3cret', `${ticket}x`).error, 'bad_ticket');
  assert.equal(verifyTicket('s3cret', 'nonsense').error, 'bad_ticket');
});

// ---------- codes ----------

test('codes: L + 6 from an alphabet without "_": never early_c or early_n, in both directions', () => {
  assert.ok(!CODE_ALPHABET.includes('_'));
  for (const early of ['early_c', 'early_n', 'EARLY_C']) assert.ok(!CODE_RE.test(early));
  assert.ok(CODE_RE.test('LABC234'));
  assert.ok(!CODE_RE.test('LABC23_'));
  assert.ok(!CODE_RE.test('LABCD0O'), 'no 0 or O');
});

test('codes: an expired code is refused and forgotten; nothing reaches the broker or the keys file', async (t) => {
  const w = await world(t);
  const c = newClient();
  const { body } = await w.api('POST', '/v1/link', { ticket: c.ticket(), token: c.token, key: c.key.toString('base64'), scope: 'read' });
  w.later(10 * 60000 + 1000);
  await w.say(OWNER, `/start ${body.code}`);
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.badCode);
  assert.equal(w.service.chat.pendingCount(), 0, 'swept, token and key with it');
  const late = await w.api('POST', '/v1/link/confirm', { ticket: c.ticket({}, w.now()), code_back: '1234' });
  assert.deepEqual([late.status, late.body], [404, { error: 'unknown_code' }]);
  assert.deepEqual(w.acl, []);
  assert.deepEqual(w.keys(), {});
});

test('codes: a claimed code is single-use; 5 failed claims a chat an hour, then silence', async (t) => {
  const w = await world(t);
  const c = newClient();
  const { body } = await w.api('POST', '/v1/link', { ticket: c.ticket(), token: c.token, key: c.key.toString('base64'), scope: 'read' });
  await w.say(OWNER, `/start ${body.code}`);
  assert.match(w.lastTo(OWNER).text, /code: \d{4}/);
  await w.say(DANA, `/start ${body.code}`);
  assert.equal(w.lastTo(DANA).text, LINK_TEXT.badCode, 'someone else with the same code gets nothing');
  for (let i = 0; i < 4; i++) await w.say(DANA, '/start LZZZZZZ');
  const told = w.tg.sent.filter((s) => s.chatId === DANA).length;
  assert.equal(told, 5);
  await w.say(DANA, '/start LZZZZZZ');
  assert.equal(w.tg.sent.filter((s) => s.chatId === DANA).length, told, 'the sixth try gets no answer');
  // The owner's claim still works.
  const backCode = /code: (\d{4})/.exec(w.lastTo(OWNER).text)[1];
  assert.equal((await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: backCode })).status, 200);
});

test('back-code: before the claim 409; three wrong cancel the claim, with no ACL entry', async (t) => {
  const w = await world(t);
  const c = newClient();
  const { body } = await w.api('POST', '/v1/link', { ticket: c.ticket(), token: c.token, key: c.key.toString('base64'), scope: 'read' });
  assert.deepEqual(await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: '1234' }), { status: 409, body: { error: 'not_claimed' } });
  await w.say(OWNER, `/start ${body.code}`);
  const right = /code: (\d{4})/.exec(w.lastTo(OWNER).text)[1];
  const bad = right === '9999' ? '8888' : '9999';
  assert.equal((await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: bad })).body.tries_left, 2);
  assert.equal((await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: bad })).body.tries_left, 1);
  assert.deepEqual(await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: bad }), { status: 410, body: { error: 'cancelled' } });
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.cancelled);
  assert.deepEqual(await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: right }), { status: 404, body: { error: 'unknown_code' } });
  assert.deepEqual(w.acl, []);
  assert.deepEqual(w.keys(), {});
});

test('confirm: when the verifier can\'t add the ACL entries, 503 and nothing linked; the same code works on retry', async (t) => {
  const w = await world(t);
  const c = newClient();
  const { body } = await w.api('POST', '/v1/link', { ticket: c.ticket(), token: c.token, key: c.key.toString('base64'), scope: 'read' });
  await w.say(OWNER, `/start ${body.code}`);
  const code = /code: (\d{4})/.exec(w.lastTo(OWNER).text)[1];
  w.setAcl(502);
  assert.deepEqual(await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: code }), { status: 503, body: { error: 'try_again' } });
  assert.deepEqual(w.keys(), {});
  w.setAcl(200);
  assert.equal((await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: code })).status, 200);
});

// ---------- many homes ----------

test('many homes: each Home sees and removes only its own links; each chat talks to its own Home', async (t) => {
  const w = await world(t);
  const a = newClient();
  const b = newClient(OTHER_HOME, { scope: 'read' });
  assert.equal((await w.link(a, OWNER)).confirmed.status, 200);
  assert.equal((await w.link(b, DANA, { firstName: 'Dana' })).confirmed.status, 200);
  const listA = (await w.api('GET', '/v1/links', undefined, a.ticket())).body.links;
  const listB = (await w.api('GET', '/v1/links', undefined, b.ticket())).body.links;
  assert.deepEqual(listA.map((l) => l.client_id), [a.clientId]);
  assert.deepEqual(listB.map((l) => [l.client_id, l.telegram_name, l.scope]), [[b.clientId, 'Dana', 'read']]);
  assert.equal((await w.api('DELETE', `/v1/link/${a.clientId}`, undefined, b.ticket({ client_id: a.clientId }))).status, 404);
  assert.equal((await w.api('DELETE', `/v1/link/${a.clientId}`, undefined, b.ticket())).status, 403, 'a ticket for another client');
  assert.equal(Object.keys(w.keys()).length, 2);
  assert.ok((await w.service.chat.linkFor(DANA)).topics.req.startsWith(`homes/${OTHER_HOME}/x/`));
  assert.ok((await w.service.chat.linkFor(OWNER)).topics.req.startsWith(`homes/${HOME}/x/`));
  // A chat already linked can't claim a second code.
  const again = await w.api('POST', '/v1/link', { ticket: newClient().ticket(), token: a.token, key: a.key.toString('base64'), scope: 'read' });
  assert.equal(again.status, 400, 'a new client needs its own key and topics');
  const c = newClient();
  const code = (await w.api('POST', '/v1/link', { ticket: c.ticket(), token: c.token, key: c.key.toString('base64'), scope: 'read' })).body.code;
  await w.say(OWNER, `/start ${code}`);
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.alreadyLinked);
});

// ---------- the webhook ----------

test('webhook: the path secret and the header secret are both needed; a repeated update_id runs once', async (t) => {
  const w = await world(t);
  assert.equal(await w.hook(w.tg.update(OWNER, '/start early_c'), { secret: 'wrong' }), 401);
  assert.equal(await w.hook(w.tg.update(OWNER, '/start early_c'), { header: 'wrong' }), 401);
  assert.equal(w.worker.forwarded.length, 0);
  const update = w.tg.update(OWNER, '/start early_c');
  assert.equal(await w.hook(update), 200);
  assert.equal(await w.hook(update), 200);
  assert.equal(w.worker.forwarded.length, 1);
  assert.equal(w.metrics.totals.webhook_duplicate, 1);
  assert.equal(w.metrics.totals.webhook_refused, 2);
});

test('webhook: 200 at once, the work in the background', async (t) => {
  const w = await world(t);
  const c = newClient();
  await w.link(c);
  let release;
  const gate = new Promise((r) => { release = r; });
  const slow = w.claude.messages.create;
  w.claude.messages.create = async (...a) => { await gate; return slow(...a); };
  const started = Date.now();
  const res = await fetch(`http://127.0.0.1:${w.service.port}/v1/tg/${WEBHOOK_SECRET}`, {
    method: 'POST', headers: { 'X-Telegram-Bot-Api-Secret-Token': WEBHOOK_SECRET }, body: JSON.stringify(w.tg.update(OWNER, 'how are things?')),
  });
  assert.equal(res.status, 200);
  assert.ok(Date.now() - started < 1000);
  release();
  await sleep(5);
  await w.service.chat.idle();
  assert.equal(w.lastTo(OWNER).text, 'All quiet at home.');
});

// ---------- early access passes through ----------

test('early access: /start early_c|n, the buttons and /stop go to the Worker, without names or text; /stop never unlinks', async (t) => {
  const w = await world(t);
  await w.say(DANA, '/start early_n', { firstName: 'Dana', lang: 'de' });
  assert.deepEqual(w.worker.forwarded.at(-1), { update_id: w.worker.forwarded.at(-1).update_id, message: { chat: { id: Number(DANA), type: 'private' }, from: { language_code: 'de' }, text: '/start early_n' } });
  await w.hook(w.tg.callback(DANA, 'price:yes', { lang: 'de' }));
  const cb = w.worker.forwarded.at(-1).callback_query;
  assert.deepEqual({ ...cb, id: 'x' }, { id: 'x', data: 'price:yes', from: { language_code: 'de' }, message: { chat: { id: Number(DANA) } } });
  await w.say(DANA, 'hello there, my name is Dana');
  assert.equal(w.worker.forwarded.at(-1).message.text, '', 'free text never leaves');
  assert.ok(!JSON.stringify(w.worker.forwarded).includes('Dana'));

  const c = newClient();
  await w.link(c);
  await w.say(OWNER, '/stop');
  assert.equal(w.worker.forwarded.at(-1).message.text, '/stop');
  assert.equal(Object.keys(w.keys()).length, 1, '/stop left the link alone');
  await w.say(OWNER, '/start early_c');
  assert.equal(w.worker.forwarded.at(-1).message.text, '/start early_c');
  assert.equal(Object.keys(w.keys()).length, 1);
  // Groups: nothing at all.
  const before = w.worker.forwarded.length;
  await w.say(OWNER, '/start early_c', { type: 'group' });
  assert.equal(w.worker.forwarded.length, before);
});

// ---------- /unlink from the chat ----------

test('/unlink: asks first; Keep keeps; Unlink within 60 s removes the binding, keys and ACL entries', async (t) => {
  const w = await world(t);
  const c = newClient();
  await w.link(c);
  await w.say(OWNER, '/unlink');
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.askUnlink);
  assert.deepEqual(w.lastTo(OWNER).markup.inline_keyboard[0].map((b) => b.callback_data), ['unlink:yes', 'unlink:no']);
  await w.hook(w.tg.callback(OWNER, 'unlink:no'));
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.kept);
  assert.deepEqual(w.tg.cleared.at(-1), { chatId: OWNER, messageId: 1, markup: { inline_keyboard: [] } }, 'Keep takes the buttons off');
  await w.hook(w.tg.callback(OWNER, 'unlink:yes'));
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.unlinkExpired, 'the question was answered already');
  await w.say(OWNER, '/unlink');
  w.later(61000);
  await w.hook(w.tg.callback(OWNER, 'unlink:yes'));
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.unlinkExpired);
  assert.equal(Object.keys(w.keys()).length, 1);
  await w.say(OWNER, '/unlink');
  await w.hook(w.tg.callback(OWNER, 'unlink:yes'));
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.unlinked);
  assert.equal(w.tg.cleared.length, 4, 'every answer takes the buttons off');
  assert.deepEqual(w.keys(), {});
  assert.deepEqual(w.acl.at(-1), { home_id: HOME, ...c.topics, op: 'remove' });
  assert.deepEqual((await w.api('GET', '/v1/links', undefined, c.ticket())).body.links, []);
  await w.say(DANA, '/unlink');
  assert.equal(w.worker.forwarded.at(-1).message.text, '/unlink', 'a stranger\'s /unlink is the Worker\'s');
});

// ---------- the monthly cap and the budget ----------

test('cap: 300 messages a Home a month (here 2), then a friendly line and no model call', async (t) => {
  const w = await world(t, { cap: 2 });
  await w.link(newClient());
  await w.say(OWNER, 'how are things?');
  await w.say(OWNER, 'how are things?');
  const calls = w.claude.calls.length;
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.cap(2));
  assert.equal(w.claude.calls.length, calls);
  assert.equal(w.metrics.totals.cap_reached, 1);
  // Commands still answer.
  await w.say(OWNER, '/start');
  assert.match(w.lastTo(OWNER).text, /^Hi!/);
  // A new month starts again.
  w.later(32 * 86400000);
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, 'All quiet at home.');
});

test('budget: when this month\'s model spend reaches the budget, Chat pauses with a message', async (t) => {
  const w = await world(t, { budgetUsd: 0.0001 });
  await w.link(newClient());
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, 'All quiet at home.');
  const calls = w.claude.calls.length;
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.paused);
  assert.equal(w.claude.calls.length, calls);
  assert.equal(w.metrics.totals.budget_paused, 1);
  const state = JSON.parse(fs.readFileSync(w.config.stateFile, 'utf8'));
  assert.ok(state.cost_usd >= 0.0001);
  assert.equal(fs.statSync(w.config.stateFile).mode & 0o777, 0o600);
  assert.ok(!JSON.stringify(state).includes(OWNER), 'no chat ids in the state file');
});

// ---------- founder's passes (docs/design/founders-pass.md) ----------

const ENDED_AT = Date.UTC(2027, 1, 14, 12); // 14 Feb 2027, noon UTC: the same date in every time zone
const ENDED_TEXT = LINK_TEXT.ended('14 Feb 2027');
const textsTo = (w, chatId) => w.tg.sent.filter((s) => s.chatId === String(chatId)).map((s) => s.text);

test('pass ended: one notice (kept in the state file), no model call; a "no" is cached 1 minute; then at most daily', async (t) => {
  const w = await world(t);
  const c = newClient();
  await w.link(c);
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, 'All quiet at home.');
  assert.deepEqual(w.verifier.statusCalls, [HOME]);
  // Entitled is cached 10 minutes: the end shows once that runs out.
  w.verifier.setHome(HOME, { entitled: false, ended_at: ENDED_AT });
  await w.say(OWNER, 'how are things?');
  assert.equal(w.verifier.statusCalls.length, 1);
  w.later(10 * 60000 + 1000);
  const calls = w.claude.calls.length;
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, ENDED_TEXT);
  assert.equal(ENDED_TEXT, "This Home's founder's pass ended on 14 Feb 2027. ZigDash Pro keeps Chat: open ZigDash to get it.");
  await w.say(OWNER, 'how are things?');
  await w.say(OWNER, '/start');
  assert.equal(w.claude.calls.length, calls, 'no model call');
  assert.equal(textsTo(w, OWNER).filter((x) => x === ENDED_TEXT).length, 1, 'once');
  assert.equal(w.verifier.statusCalls.length, 2, 'the "no" is cached');
  w.later(61000);
  await w.say(OWNER, 'how are things?');
  assert.equal(w.verifier.statusCalls.length, 3, 'asked again after a minute');
  assert.equal(textsTo(w, OWNER).filter((x) => x === ENDED_TEXT).length, 1, 'and still quiet');
  // Survives a restart: the state file says when, by binding (no chat id).
  const state = JSON.parse(fs.readFileSync(w.config.stateFile, 'utf8'));
  assert.deepEqual(Object.keys(state.ended_notice), [`${HOME}.${c.clientId}`]);
  assert.ok(!JSON.stringify(state).includes(OWNER));
  // A day later, one reminder.
  w.later(24 * 3600000);
  await w.say(OWNER, 'how are things?');
  await w.say(OWNER, 'how are things?');
  assert.equal(textsTo(w, OWNER).filter((x) => x === ENDED_TEXT).length, 2);
  assert.equal(w.claude.calls.length, calls);
  // /unlink still works.
  await w.say(OWNER, '/unlink');
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.askUnlink);
  assert.equal(w.metrics.totals.pass_ended, 6);
  noSecretsInLogs(w.lines, OWNER, HOME, c.clientId, ACL_SECRET, '14 Feb');
});

test('pass ended: the notice survives a restart of the service (same state file)', async (t) => {
  const w = await world(t);
  const c = newClient();
  await w.link(c);
  w.verifier.setHome(HOME, { entitled: false, ended_at: ENDED_AT });
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, ENDED_TEXT);
  const { makeState } = await import('../store.mjs');
  const again = makeState(w.config.stateFile, { now: w.now });
  assert.ok(again.endedNotice(`${HOME}.${c.clientId}`) > 0);
});

test('pass ended: the date is the service\'s TIME_ZONE date', async (t) => {
  // UTC+14: noon UTC is already the next day there, and in no host's own zone.
  const w = await world(t, { timeZone: 'Pacific/Kiritimati' });
  await w.link(newClient());
  w.verifier.setHome(HOME, { entitled: false, ended_at: ENDED_AT });
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, LINK_TEXT.ended('15 Feb 2027'));
});

test('home-changed: drops the cached status and the notice; the next message asks the verifier again', async (t) => {
  const w = await world(t);
  const c = newClient();
  await w.link(c);
  w.verifier.setHome(HOME, { entitled: false, ended_at: ENDED_AT });
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, ENDED_TEXT);
  // Upgraded: the verifier re-enables the Home and says so.
  w.verifier.setHome(HOME, { entitled: true, ended_at: null });
  assert.deepEqual(await w.internal('/v1/internal/home-changed', { home_id: HOME }), { status: 200, body: { ok: true } });
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, 'All quiet at home.');
  assert.equal(w.verifier.statusCalls.length, 2);
  assert.deepEqual(JSON.parse(fs.readFileSync(w.config.stateFile, 'utf8')).ended_notice, {});
  // Ended again later (a revoke): told again, once.
  w.verifier.setHome(HOME, { entitled: false, ended_at: ENDED_AT });
  await w.internal('/v1/internal/home-changed', { home_id: HOME });
  await w.say(OWNER, 'how are things?');
  await w.say(OWNER, 'how are things?');
  assert.equal(textsTo(w, OWNER).filter((x) => x === ENDED_TEXT).length, 2);
  assert.equal(w.metrics.totals.home_changed, 2);
});

test('home-deleted: 200 at once, then every link of that Home is removed with one message per chat', async (t) => {
  const w = await world(t);
  const a = newClient();
  const b = newClient(HOME, { scope: 'read' });
  const other = newClient(OTHER_HOME);
  await w.link(a, OWNER);
  await w.link(b, DANA, { firstName: 'Dana' });
  await w.link(other, '616161');
  // The ACL removals wait until the answer is in.
  let release;
  const gate = new Promise((r) => { release = r; });
  const real = w.verifier.fetch;
  w.verifier.fetch = async (u, init) => { if (u.endsWith('/chat-acl')) await gate; return real(u, init); };
  const res = await w.internal('/v1/internal/home-deleted', { home_id: HOME });
  assert.deepEqual(res, { status: 200, body: { ok: true } });
  release();
  await w.service.chat.idle();
  assert.deepEqual(Object.values(w.keys()).map((e) => e.home_id), [OTHER_HOME]);
  assert.deepEqual(w.acl.filter((x) => x.op === 'remove').map((x) => x.request_topic).sort(), [a.topics.request_topic, b.topics.request_topic].sort());
  for (const chat of [OWNER, DANA]) {
    assert.equal(w.lastTo(chat).text, LINK_TEXT.passEnded);
    assert.equal(textsTo(w, chat).filter((x) => x === LINK_TEXT.passEnded || x === LINK_TEXT.unlinked || x === LINK_TEXT.unlinkedInApp).length, 1, 'one message');
  }
  assert.equal(w.lastTo('616161').text, LINK_TEXT.linked, 'another Home is untouched');
  assert.deepEqual((await w.api('GET', '/v1/links', undefined, a.ticket())).body.links, []);
  // Repeated (a later sweep's retry): nothing more.
  assert.equal((await w.internal('/v1/internal/home-deleted', { home_id: HOME })).status, 200);
  await w.service.chat.idle();
  assert.equal(textsTo(w, OWNER).filter((x) => x === LINK_TEXT.passEnded).length, 1);
  // The chat is a stranger now: early access, no model.
  const calls = w.claude.calls.length;
  await w.say(OWNER, 'how are things?');
  assert.equal(w.claude.calls.length, calls);
  noSecretsInLogs(w.lines, OWNER, DANA, HOME, ACL_SECRET, a.clientId);
});

test('410 from the status route: the same removal, caught up on the next message', async (t) => {
  const w = await world(t);
  await w.link(newClient(), OWNER);
  await w.link(newClient(), DANA, { firstName: 'Dana' });
  w.verifier.setHome(HOME, 410);
  const calls = w.claude.calls.length;
  await w.say(OWNER, 'how are things?');
  await w.service.chat.idle();
  assert.equal(w.claude.calls.length, calls);
  assert.deepEqual(textsTo(w, OWNER).slice(-1), [LINK_TEXT.passEnded]);
  assert.equal(textsTo(w, OWNER).filter((x) => x === LINK_TEXT.passEnded).length, 1);
  assert.equal(w.lastTo(DANA).text, LINK_TEXT.passEnded);
  assert.deepEqual(w.keys(), {});
  assert.equal(w.acl.filter((x) => x.op === 'remove').length, 2);
});

test('an unknown Home (404) is no reason to act: the message is answered, nothing unlinked', async (t) => {
  const w = await world(t);
  const c = newClient();
  await w.link(c);
  w.verifier.setHome(HOME, 404);
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, 'All quiet at home.');
  assert.equal(Object.keys(w.keys()).length, 1);
  assert.equal((await w.internal('/v1/internal/home-deleted', { home_id: 'ffffffffffffffff' })).status, 200);
  await w.service.chat.idle();
  assert.equal(Object.keys(w.keys()).length, 1);
});

test('verifier unreachable: the last answer however old, else entitled; counted in the logs', async (t) => {
  const w = await world(t);
  await w.link(newClient());
  w.verifier.setHome(HOME, 'down');
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, 'All quiet at home.', 'nothing cached yet: entitled (the broker still enforces the end)');
  w.verifier.setHome(HOME, 503);
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, 'All quiet at home.');
  assert.equal(w.metrics.totals.home_status_error, 2);
  w.verifier.setHome(HOME, { entitled: false, ended_at: ENDED_AT });
  await w.say(OWNER, 'how are things?');
  assert.equal(w.lastTo(OWNER).text, ENDED_TEXT);
  w.later(5 * 60000);
  w.verifier.setHome(HOME, 'down');
  const calls = w.claude.calls.length;
  await w.say(OWNER, 'how are things?');
  assert.equal(w.claude.calls.length, calls, 'the last answer (ended) holds while the verifier is down');
  assert.equal(w.metrics.totals.home_status_error, 3);
});

test('confirm: a 402 from the verifier\'s ACL add is final: 402 pass_ended, the link dropped', async (t) => {
  const w = await world(t);
  const c = newClient();
  const { body } = await w.api('POST', '/v1/link', { ticket: c.ticket(), token: c.token, key: c.key.toString('base64'), scope: 'read' });
  await w.say(OWNER, `/start ${body.code}`);
  const code = /code: (\d{4})/.exec(w.lastTo(OWNER).text)[1];
  w.setAcl(402);
  assert.deepEqual(await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: code }), { status: 402, body: { error: 'pass_ended' } });
  w.setAcl(200);
  assert.deepEqual(await w.api('POST', '/v1/link/confirm', { ticket: c.ticket(), code_back: code }), { status: 404, body: { error: 'unknown_code' } });
  assert.deepEqual(w.keys(), {});
  assert.deepEqual(w.acl, []);
  assert.equal(w.service.chat.pendingCount(), 0);
});

test('internal port: forwarding headers, a missing or wrong secret, other routes and bad bodies are refused; the public API has no internal routes', async (t) => {
  const w = await world(t);
  await w.link(newClient());
  for (const h of [{ 'X-Forwarded-For': '203.0.113.9' }, { Forwarded: 'for=203.0.113.9' }, { 'X-Real-IP': '203.0.113.9' }, { 'X-Forwarded-Host': 'chat.zigdash.app' }]) {
    assert.deepEqual(await w.internal('/v1/internal/home-deleted', { home_id: HOME }, { headers: h }), { status: 403, body: { error: 'internal_only' } });
  }
  assert.equal((await w.internal('/v1/internal/home-deleted', { home_id: HOME }, { headers: { 'X-Chat-Acl-Secret': '' } })).status, 401);
  assert.equal((await w.internal('/v1/internal/home-deleted', { home_id: HOME }, { headers: { 'X-Chat-Acl-Secret': 'wrong' } })).status, 401);
  const res = await fetch(`http://127.0.0.1:${w.service.internalPort}/v1/internal/home-deleted`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ home_id: HOME }) });
  assert.equal(res.status, 401, 'no secret header at all');
  assert.equal((await w.internal('/v1/internal/home-changed', null, { method: 'GET' })).status, 404);
  assert.equal((await w.internal('/v1/internal/chat-acl', { home_id: HOME })).status, 404);
  assert.equal((await w.internal('/v1/internal/home-deleted', { home_id: 'not-a-home' })).status, 400);
  assert.equal((await w.api('POST', '/v1/internal/home-deleted', { home_id: HOME })).status, 404, 'not on the proxied port');
  await w.service.chat.idle();
  assert.equal(Object.keys(w.keys()).length, 1, 'nothing was removed');
  assert.equal(w.metrics.totals.internal_refused, 7);
});

test('internal port: INTERNAL_PORT defaults to 8791; "off" turns it off', () => {
  assert.equal(configFromEnv({}).internalPort, 8791);
  assert.equal(configFromEnv({ INTERNAL_PORT: 'off' }).internalPort, null);
  assert.equal(configFromEnv({ INTERNAL_PORT: '9000' }).internalPort, 9000);
});
