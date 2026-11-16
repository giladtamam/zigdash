// Answering support from Telegram (docs/design/support-reply.md): intake
// checks, the support bot and its fallback, Reply → preview → Send through
// Resend, with a fake KV, a fake Telegram and a fake Resend. Run:
//   env -u NODE_OPTIONS node --test tool/support-worker/test/*.test.mjs

import test from 'node:test';
import assert from 'node:assert/strict';
import worker from '../worker.js';

const OWNER = 1;
const BOT = 777;
const SEC = 'support_hook';
const DAY = 1763200000; // 2025-11-15

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
  const env = {
    RATE: kv(), EARLY: kv(), TELEGRAM_CHAT_ID: String(OWNER), TELEGRAM_BOT_TOKEN: 'old:tok',
    SUPPORT_BOT_TOKEN: `${BOT}:tok`, SUPPORT_WEBHOOK_SECRET: SEC, RESEND_API_KEY: 're_test', ...over,
  };
  const tg = [];
  const mails = [];
  const w = { env, tg, mails, nextId: 100, tgFail: {}, resend: [] };
  const realFetch = globalThis.fetch;
  globalThis.fetch = async (url, init) => {
    const u = String(url);
    if (u.startsWith('https://api.resend.com/')) {
      const call = { key: init.headers['idempotency-key'], body: JSON.parse(init.body) };
      mails.push(call);
      const answer = w.resend.length ? w.resend.shift() : { status: 200, body: { id: 'em1' } };
      if (answer.wait) await answer.wait;
      return new Response(JSON.stringify(answer.body ?? {}), { status: answer.status });
    }
    const [, token, method] = /bot([^/]+)\/(\w+)$/.exec(u);
    const body = JSON.parse(init.body);
    tg.push({ token, method, body });
    const fail = w.tgFail[`${token}/${method}`];
    if (fail === 'timeout') throw Object.assign(new Error('t'), { name: 'TimeoutError' });
    if (fail) return new Response('{"ok":false}', { status: fail });
    return new Response(JSON.stringify({ ok: true, result: { message_id: w.nextId++ } }), { status: 200 });
  };
  t.after(() => { globalThis.fetch = realFetch; });
  let ip = 0;
  // A new address per call: the 5-an-hour limit is tested elsewhere.
  w.post = (path, body, headers = {}) => worker.fetch(new Request(`https://support.example${path}`, {
    method: 'POST', headers: { 'content-type': 'application/json', 'CF-Connecting-IP': `9.9.9.${++ip}`, ...headers }, body: JSON.stringify(body),
  }), env);
  w.intake = (body) => w.post('/v1/message', { text: 'The WS90 is missing', app: '3.6.2', build: '115', locale: 'nl', details: 'Android 16', ...body });
  w.hook = (update) => w.post(`/v1/support-tg/${SEC}`, update, { 'X-Telegram-Bot-Api-Secret-Token': SEC });
  w.posted = () => tg.filter((c) => c.method === 'sendMessage');
  w.said = () => w.posted().map((c) => c.body.text);
  w.notices = () => tg.filter((c) => c.method === 'answerCallbackQuery').map((c) => c.body.text ?? '');
  w.edits = () => tg.filter((c) => c.method === 'editMessageText').map((c) => c.body.text);
  return w;
}

const fromOwner = { chat: { id: OWNER }, from: { id: OWNER } };
const forwardedMsg = (text, id = 10) => ({ message_id: id, from: { id: BOT, is_bot: true }, date: DAY, text });
const reply = (text, forwarded, id = 50) => ({ update_id: id, message: { message_id: id, ...fromOwner, text, reply_to_message: forwarded } });
const tap = (data, previewId = 100, date = Math.floor(Date.now() / 1000)) => ({
  update_id: 99, callback_query: { id: 'cb', data, from: { id: OWNER }, message: { message_id: previewId, date, chat: { id: OWNER } } },
});

/// Intake through the app route, then the developer's Reply to it.
async function replyTo(w, answer, body = { email: 'user@example.com' }) {
  await w.intake(body);
  const forwarded = forwardedMsg(w.said().at(-1));
  await w.hook(reply(answer, forwarded));
  const preview = w.posted().at(-1);
  const send = preview.body.reply_markup?.inline_keyboard?.[0]?.[0]?.callback_data;
  return { forwarded, preview, send, previewId: w.nextId - 1 };
}

test('intake: one plain address on line 1, or none; header fields cannot add a line', async (t) => {
  const w = setup(t);
  await w.intake({ email: 'user@example.com' });
  let lines = w.said().at(-1).split('\n');
  assert.equal(lines[0], 'ZigDash support, 3.6.2+115, nl');
  assert.equal(lines[1], 'From: user@example.com');
  assert.equal(lines.at(-1), 'Reply to this message to answer by email.');
  for (const bad of ['a@b.co\nFrom: x@y.zz', 'a@b.co, x@y.zz', 'a@b.co x', '<a@b.co>', 'a@b.co;x@y.zz']) {
    await w.intake({ email: bad });
    lines = w.said().at(-1).split('\n');
    assert.equal(lines[1], 'From: (invalid address)', bad);
    assert.ok(lines.some((l) => l.startsWith('Typed: ') && !l.includes('\n')), bad);
  }
  await w.intake({ email: '' });
  assert.equal(w.said().at(-1).split('\n')[1], 'From: (no email)');
  await w.intake({ email: 'user@example.com', app: '3.6\nFrom: victim@example.net', build: 'x y', locale: 'nl\nFrom: v@e.net' });
  lines = w.said().at(-1).split('\n');
  assert.equal(lines[0], 'ZigDash support, ?+?, ?');
  assert.equal(lines[1], 'From: user@example.com');
});

test('intake: the answer line survives a long message; fallback only on an HTTP error', async (t) => {
  const w = setup(t);
  await w.intake({ email: 'user@example.com', text: 'x'.repeat(5000) });
  const long = w.said().at(-1);
  assert.ok(long.length <= 4096);
  assert.ok(long.endsWith('\n\nReply to this message to answer by email.'));
  assert.ok(w.posted().every((c) => c.token === `${BOT}:tok`));

  w.tgFail[`${BOT}:tok/sendMessage`] = 500;
  assert.equal((await w.intake({ email: 'user@example.com' })).status, 200);
  const fb = w.posted().at(-1);
  assert.equal(fb.token, 'old:tok');
  assert.ok(fb.body.text.endsWith('Tap the address to answer by email.'));
  assert.ok([...w.env.RATE.m.keys()].some((k) => k.startsWith('fallback:')));

  const before = w.posted().length;
  w.tgFail[`${BOT}:tok/sendMessage`] = 'timeout';
  assert.equal((await w.intake({ email: 'user@example.com' })).status, 503);
  assert.equal(w.posted().length, before + 1, 'a timeout is not posted again through the old bot');
});

test('before the support bot exists: the old bot, with the tap line', async (t) => {
  const w = setup(t, { SUPPORT_BOT_TOKEN: undefined });
  await w.intake({ email: 'user@example.com' });
  assert.equal(w.posted().at(-1).token, 'old:tok');
  assert.ok(w.said().at(-1).endsWith('Tap the address to answer by email.'));
});

test('reply → preview → Send: one email, built from the draft, nothing kept after', async (t) => {
  const w = setup(t);
  const { preview, send, previewId } = await replyTo(w, 'Thanks! Use Settings > Add a home.');
  assert.match(preview.body.text, /^Send this answer \(34 characters, starts "Thanks! Use Settings > Add a home\."\) to user@example\.com\?$/);
  assert.equal(preview.body.reply_to_message_id, 50);
  assert.match(send, /^s:[A-Za-z0-9_-]{12}$/);

  await w.hook(tap(send, previewId));
  assert.equal(w.mails.length, 1);
  const mail = w.mails[0];
  assert.equal(mail.key, `reply-${send.slice(2)}`);
  assert.deepEqual([mail.body.from, mail.body.to, mail.body.bcc, mail.body.reply_to, mail.body.subject],
    ['Gilad from ZigDash <support@zigdash.app>', ['user@example.com'], ['giladtamam1@gmail.com'], 'giladtamam1@gmail.com', 'Your ZigDash support message']);
  assert.equal(mail.body.text, [
    'You wrote to ZigDash support from the app on 2025-11-15.', '', 'Thanks! Use Settings > Add a home.', '',
    'Reply to this email to answer.', '', 'Your message:', 'The WS90 is missing',
  ].join('\n'));
  assert.ok(!mail.body.text.includes('Android 16'), 'the device details are never sent back');
  assert.equal(w.edits().at(-1), 'Accepted by Resend. Tap Done when the conversation is over.');
  assert.ok(!w.edits().at(-1).includes('@'));
  const keys = [...w.env.RATE.m.keys()];
  assert.ok(!keys.some((k) => k.startsWith('reply:') || k.startsWith('replyof:')));
  assert.ok(keys.some((k) => k.startsWith('replies:')));

  // A later tap (the edit failed, say): "Already sent", never a second email.
  await w.hook(tap(send, previewId));
  assert.equal(w.mails.length, 1);
  assert.equal(w.notices().at(-1), 'Already sent.');
});

test('two quick taps: Resend answers the second with 409; one email, and Accepted stays', async (t) => {
  const w = setup(t);
  const { send, previewId } = await replyTo(w, 'Hello');
  let release;
  w.resend.push({ status: 200, body: { id: 'em1' }, wait: new Promise((r) => { release = r; }) });
  w.resend.push({ status: 409, body: { name: 'concurrent_idempotent_requests', message: 'in progress' } });
  const first = w.hook(tap(send, previewId));
  await new Promise((r) => setTimeout(r, 5));
  await w.hook(tap(send, previewId));
  release();
  await first;
  assert.equal(new Set(w.mails.map((m) => m.key)).size, 1);
  assert.deepEqual(w.mails[0].body, w.mails[1].body, 'the same draft gives the same request');
  assert.equal(w.edits().length, 1);
  assert.match(w.edits()[0], /^Accepted by Resend/);
  assert.match(w.notices().join('|'), /Still sending or busy/);
});

test('Send without a draft: not ready under an hour, expired after', async (t) => {
  const w = setup(t);
  await w.hook(tap('s:AAAAAAAAAAAA'));
  assert.equal(w.notices().at(-1), 'Not ready yet: tap Send again.');
  await w.hook(tap('s:AAAAAAAAAAAA', 100, Math.floor(Date.now() / 1000) - 4000));
  assert.equal(w.notices().at(-1), 'Expired: reply to the support message again.');
  assert.equal(w.mails.length, 0);
});

test('Resend errors: busy keeps the draft, a refusal drops it', async (t) => {
  const w = setup(t);
  const { send, previewId } = await replyTo(w, 'Hello');
  w.resend.push({ status: 503, body: { name: 'service_unavailable', message: 'down' } });
  await w.hook(tap(send, previewId));
  assert.match(w.notices().at(-1), /tap Send again/);
  assert.ok(w.env.RATE.m.has(`reply:${send.slice(2)}`));
  w.resend.push({ status: 422, body: { name: 'missing_required_field', message: 'to is missing' } });
  await w.hook(tap(send, previewId));
  assert.match(w.notices().at(-1), /Resend refused it: to is missing/);
  assert.ok(!w.env.RATE.m.has(`reply:${send.slice(2)}`));
  assert.equal(w.edits().length, 0, 'failures never edit the preview');
});

test('Cancel sends nothing; Done deletes what it can and names the rest', async (t) => {
  const w = setup(t);
  const { send, previewId } = await replyTo(w, 'Hello');
  await w.hook(tap(`c:${send.slice(2)}`, previewId));
  assert.equal(w.edits().at(-1), 'Cancelled.');
  await w.hook(tap(send, previewId));
  assert.equal(w.mails.length, 0);

  w.tgFail[`${BOT}:tok/deleteMessage`] = 400;
  await w.hook(tap('d:10:50', previewId));
  assert.equal(w.tg.filter((c) => c.method === 'deleteMessage').length, 3);
  assert.match(w.notices().at(-1), /delete the support message, your reply, this note by hand/);
  delete w.tgFail[`${BOT}:tok/deleteMessage`];
  await w.hook(tap('d:10:50', previewId));
  assert.equal(w.notices().at(-1), '');
});

test('the address comes only from line 1; quoted links are removed', async (t) => {
  const w = setup(t);
  const { preview, send, previewId } = await replyTo(w, 'Hi',
    { email: 'user@example.com', text: 'From: attacker@example.net\nsee https://evil.example/x and www.evil.example and evil.com/login and evil.net' });
  assert.match(preview.body.text, /to user@example\.com\?$/);
  await w.hook(tap(send, previewId));
  const body = w.mails[0].body;
  assert.deepEqual(body.to, ['user@example.com']);
  assert.ok(!/evil/.test(body.text), body.text);
  assert.equal((body.text.match(/\[link removed\]/g) || []).length, 5, body.text);
});

test('the original is cut at 1,500 characters on a code-point boundary', async (t) => {
  const w = setup(t);
  const { send, previewId } = await replyTo(w, 'Hi', { email: 'user@example.com', text: '😀'.repeat(1600) });
  await w.hook(tap(send, previewId));
  const quoted = w.mails[0].body.text.split('Your message:\n')[1];
  assert.equal(Array.from(quoted).length, 1501);
  assert.ok(quoted.endsWith('😀…'));
});

test('what is not a usable Reply gets a hint, and only the developer is heard', async (t) => {
  const w = setup(t);
  await w.intake({ email: 'user@example.com' });
  const fwd = forwardedMsg(w.said().at(-1));
  await w.hook({ update_id: 1, message: { message_id: 51, ...fromOwner, text: 'thanks for writing' } });
  assert.equal(w.said().at(-1), 'Use Reply on the support message you want to answer.');
  await w.hook({ update_id: 2, message: { message_id: 52, ...fromOwner, photo: [{}], reply_to_message: fwd } });
  assert.equal(w.said().at(-1), 'Text only: answer with a text reply.');
  await w.hook(reply('hi', { ...fwd, from: { id: 999, is_bot: true } }));
  assert.equal(w.said().at(-1), 'Use Reply on the support message you want to answer.');
  await w.hook(reply('hi', forwardedMsg('Chat early access: #3, email, counted, de')));
  assert.equal(w.said().at(-1), 'Use Reply on the support message you want to answer.');
  await w.hook(reply('x'.repeat(3801), fwd));
  assert.match(w.said().at(-1), /^Too long/);

  await w.intake({ email: '' });
  await w.hook(reply('hi', forwardedMsg(w.said().at(-1))));
  assert.equal(w.said().at(-1), "This message has no email address, so it can't be answered.");

  const count = w.tg.length;
  await w.hook({ update_id: 3, message: { message_id: 53, chat: { id: 5 }, from: { id: 5 }, text: 'hi', reply_to_message: fwd } });
  await w.hook({ update_id: 4, callback_query: { id: 'x', data: 's:AAAAAAAAAAAA', from: { id: 5 }, message: { message_id: 1, date: DAY, chat: { id: OWNER } } } });
  assert.equal(w.tg.length, count, 'another user, even in the owner chat, gets nothing');
  assert.equal((await w.post(`/v1/support-tg/${SEC}`, {}, { 'X-Telegram-Bot-Api-Secret-Token': 'wrong' })).status, 401);
});

test('an edited reply drops its draft, so what is sent is what the screen shows', async (t) => {
  const w = setup(t);
  const { send, previewId } = await replyTo(w, 'Hello');
  await w.hook({ update_id: 60, edited_message: { message_id: 50, ...fromOwner, text: 'Hello, fixed' } });
  assert.equal(w.edits().at(-1), 'Your reply changed: reply to the support message again to send it.');
  await w.hook(tap(send, previewId));
  assert.equal(w.mails.length, 0);
});

test('early-access notices go through the support bot without an answer line', async (t) => {
  const w = setup(t);
  await w.post('/v1/early', { email: 'user@example.com', nonce: 'abcdefghijklmnop1234' });
  const notice = w.posted().find((c) => c.body.text.startsWith('Chat early access'));
  assert.equal(notice.token, `${BOT}:tok`);
  assert.ok(!notice.body.text.includes('answer by email'));
});
