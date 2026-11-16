// The support Worker's ZigDash Chat paths (passthrough from zigdash-chat, the
// linked list, the rollback reply) and the early-access webhook they share,
// with a fake KV and a fake Telegram. Run:
//   env -u NODE_OPTIONS node --test tool/support-worker/test/*.test.mjs

import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import worker from '../worker.js';
import { linkedId } from '../../zigdash-chat/bot.mjs';

const SECRET = 'chat-service-secret';
const HOOK = 'hook_secret';

function kv() {
  const m = new Map();
  return {
    m,
    async get(k, type) { const v = m.get(k); return v === undefined ? null : type === 'json' ? JSON.parse(v) : v; },
    async put(k, v) { m.set(k, v); },
    async delete(k) { m.delete(k); },
  };
}

function setup(t, over = {}) {
  const env = { EARLY: kv(), RATE: kv(), ASSISTANT_BOT_TOKEN: 'bot-token', ASSISTANT_WEBHOOK_SECRET: HOOK, CHAT_SERVICE_SECRET: SECRET, TELEGRAM_BOT_TOKEN: 'support', TELEGRAM_CHAT_ID: '1', ...over };
  const sent = [];
  const realFetch = globalThis.fetch;
  globalThis.fetch = async (url, init) => {
    sent.push({ method: String(url).split('/').at(-1), body: JSON.parse(init.body) });
    return new Response('{"ok":true}', { status: 200 });
  };
  t.after(() => { globalThis.fetch = realFetch; });
  const call = (path, body, headers = {}) => worker.fetch(new Request(`https://support.example${path}`, { method: 'POST', headers: { 'content-type': 'application/json', ...headers }, body: JSON.stringify(body) }), env);
  const fromChat = (path, body) => call(path, body, { 'X-ZigDash-Chat-Secret': SECRET });
  const hook = (body) => call(`/v1/tg/${HOOK}`, body, { 'X-Telegram-Bot-Api-Secret-Token': HOOK });
  const toChat = (chat) => sent.filter((s) => s.method === 'sendMessage' && s.body.chat_id === chat).map((s) => s.body.text);
  return { env, sent, call, fromChat, hook, toChat };
}

const message = (chat, textBody, lang = 'en') => ({ update_id: 1, message: { chat: { id: chat, type: 'private' }, from: { language_code: lang }, text: textBody } });
const button = (chat, data) => ({ update_id: 2, callback_query: { id: 'cb', data, from: { language_code: 'en' }, message: { chat: { id: chat } } } });

test('passthrough: refused without the service secret', async (t) => {
  const w = setup(t);
  assert.equal((await w.call('/v1/early/tg', message(5, '/start early_c'))).status, 401);
  assert.equal((await w.call('/v1/early/tg', message(5, '/start early_c'), { 'X-ZigDash-Chat-Secret': 'wrong' })).status, 401);
  assert.equal((await w.call('/v1/early/linked', { ids: [] })).status, 401);
  const off = setup(t, { CHAT_SERVICE_SECRET: undefined });
  assert.equal((await off.call('/v1/early/tg', message(5, '/start early_c'), { 'X-ZigDash-Chat-Secret': '' })).status, 401);
  assert.equal(w.sent.length, 0);
});

test('passthrough: /start early_c joins as the webhook did, the price button answers, /stop leaves', async (t) => {
  const w = setup(t);
  assert.equal((await w.fromChat('/v1/early/tg', message(5, '/start early_c', 'de'))).status, 200);
  const entry = JSON.parse(w.env.EARLY.m.get('early:tg:5'));
  assert.deepEqual([entry.via, entry.lang, entry.counted, entry.position], ['telegram', 'de', true, 1]);
  assert.match(w.toChat(5)[0], /You're #1 on the list/);
  assert.equal(w.toChat(5)[1], 'After the free months, would €2.49 a month be OK?');
  assert.equal((await w.fromChat('/v1/early/tg', button(5, 'price:yes'))).status, 200);
  assert.equal(JSON.parse(w.env.EARLY.m.get('early:tg:5')).price, 'yes');
  assert.equal(w.toChat(5).at(-1), 'Thanks, noted.');
  assert.equal((await w.fromChat('/v1/early/tg', message(5, '/stop'))).status, 200);
  assert.ok(!w.env.EARLY.m.has('early:tg:5'));
  assert.match(w.toChat(5).at(-1), /You've left the list/);
  // Anything else from a chat not on the list: the intro with its button, as before.
  await w.fromChat('/v1/early/tg', message(6, ''));
  assert.match(w.toChat(6)[0], /Join the early-access list/);
});

test('linked list: replaced whole, HMACs only; bad lists refused', async (t) => {
  const w = setup(t);
  const ids = [linkedId(SECRET, 424242), linkedId(SECRET, 515151)];
  assert.equal((await w.fromChat('/v1/early/linked', { ids })).status, 200);
  assert.deepEqual(JSON.parse(w.env.EARLY.m.get('chat:linked')), ids);
  assert.ok(!w.env.EARLY.m.get('chat:linked').includes('424242'));
  assert.equal((await w.fromChat('/v1/early/linked', { ids: ['424242'] })).status, 400);
  assert.equal((await w.fromChat('/v1/early/linked', {})).status, 400);
  assert.equal((await w.fromChat('/v1/early/linked', { ids: [] })).status, 200);
  assert.deepEqual(JSON.parse(w.env.EARLY.m.get('chat:linked')), []);
});

test('rollback: on the Worker\'s webhook, a linked chat hears Chat is paused; early access and /stop still work', async (t) => {
  const w = setup(t);
  await w.fromChat('/v1/early/linked', { ids: [linkedId(SECRET, 424242)] });
  assert.equal((await w.hook(message(424242, 'close the office shutter'))).status, 200);
  assert.deepEqual(w.toChat(424242), ['Chat is paused for maintenance; it will be back soon.']);
  await w.hook(message(424242, '/start early_n'));
  assert.match(w.toChat(424242).at(-2), /on the list/, 'early access is unchanged for a linked chat');
  assert.match(w.toChat(424242).at(-1), /a month be OK/);
  await w.hook(message(424242, '/stop'));
  assert.match(w.toChat(424242).at(-1), /You've left the list/);
  // Someone not linked gets the early-access intro, as before.
  await w.hook(message(777, 'hi'));
  assert.match(w.toChat(777)[0], /Join the early-access list/);
  // And the webhook's own secret is still required.
  assert.equal((await w.call(`/v1/tg/${HOOK}`, message(777, 'hi'))).status, 401);
});

test('the HMAC of a chat id is the same in the Worker and in zigdash-chat', async () => {
  const ours = crypto.createHmac('sha256', SECRET).update('424242').digest('hex').slice(0, 32);
  assert.equal(linkedId(SECRET, 424242), ours);
});
