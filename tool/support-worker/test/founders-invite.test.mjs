// Founders' pass invites (docs/design/founders-pass.md, Invites): the owner's
// POST /v1/early/invite and the bot's new replies to listed chats, with a fake
// KV (listing with expirations), a fake Telegram and a fake Resend. Run:
//   env -u NODE_OPTIONS node --test tool/support-worker/test/*.test.mjs

import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import worker from '../worker.js';

const ADMIN = 'admin-secret-for-tests';
const HOOK = 'hook_secret';
const CHAT = 'chat-service-secret';
const REDEEM_BY = '2030-01-15';
const NOW = Math.floor(Date.now() / 1000);
const CODES = ['ZD-AB12-CD34-EF', 'ZD-GH56-JK78-MN', 'ZD-PQ90-RS12-TV', 'ZD-WX34-YZ56-01', 'ZD-2345-6789-AB',
  'ZD-CDEF-GHJK-MN', 'ZD-PQRS-TVWX-YZ', 'ZD-0123-4567-89', 'ZD-ABCD-EFGH-JK', 'ZD-MNPQ-RSTV-WX',
  'ZD-YZ01-2345-67', 'ZD-89AB-CDEF-GH', 'ZD-JKMN-PQRS-TV', 'ZD-WXYZ-0123-45'];

/// A KV that keeps each key's absolute expiration and lists it, as Cloudflare's does.
function kv() {
  const m = new Map();
  const exp = new Map();
  const puts = [];
  return {
    m, exp, puts,
    async get(k, type) { const v = m.get(k); return v === undefined ? null : type === 'json' ? JSON.parse(v) : v; },
    async put(k, v, opts = {}) {
      puts.push({ k, opts });
      m.set(k, v);
      if (opts.expiration) exp.set(k, opts.expiration);
      else if (opts.expirationTtl) exp.set(k, NOW + opts.expirationTtl);
      else exp.delete(k);
    },
    async delete(k) { m.delete(k); exp.delete(k); },
    async list({ prefix = '', cursor } = {}) {
      // Two keys a page, so the cursor is followed.
      const all = [...m.keys()].filter((k) => k.startsWith(prefix)).sort();
      const start = Number(cursor || 0);
      const keys = all.slice(start, start + 2).map((name) => (exp.has(name) ? { name, expiration: exp.get(name) } : { name }));
      const done = start + 2 >= all.length;
      return { keys, list_complete: done, ...(done ? {} : { cursor: String(start + 2) }) };
    },
  };
}

function setup(t, over = {}) {
  const env = {
    EARLY: kv(), RATE: kv(), EARLY_ADMIN_SECRET: ADMIN, ASSISTANT_BOT_TOKEN: 'home:bot', ASSISTANT_WEBHOOK_SECRET: HOOK,
    CHAT_SERVICE_SECRET: CHAT, RESEND_API_KEY: 're_test', SUPPORT_BOT_TOKEN: '777:tok', TELEGRAM_CHAT_ID: '1', ...over,
  };
  const w = { env, tg: [], mails: [], fetches: 0, tgFail: {}, resendFail: {}, onSend: null };
  const realFetch = globalThis.fetch;
  globalThis.fetch = async (url, init) => {
    w.fetches++;
    const u = String(url);
    const body = JSON.parse(init.body);
    if (u.startsWith('https://api.resend.com/')) {
      w.mails.push({ key: init.headers['idempotency-key'], body });
      await w.onSend?.(body.to[0]);
      const fail = w.resendFail[body.to[0]];
      if (fail) return new Response(JSON.stringify({ name: 'validation_error', message: `bad ${body.to[0]}` }), { status: fail });
      return new Response('{"id":"em1"}', { status: 200 });
    }
    const [, token, method] = /bot([^/]+)\/(\w+)$/.exec(u);
    w.tg.push({ token, method, body });
    if (method === 'sendMessage') await w.onSend?.(String(body.chat_id));
    const fail = w.tgFail[String(body.chat_id)];
    if (fail === 'timeout') throw Object.assign(new Error('t'), { name: 'TimeoutError' });
    if (fail) return new Response('{"ok":false}', { status: fail });
    return new Response('{"ok":true,"result":{"message_id":1}}', { status: 200 });
  };
  t.after(() => { globalThis.fetch = realFetch; });
  w.call = (path, body, headers = {}) => worker.fetch(new Request(`https://support.example${path}`, {
    method: 'POST', headers: { 'content-type': 'application/json', ...headers }, body: JSON.stringify(body),
  }), env);
  w.invite = (body, secret = ADMIN) => w.call('/v1/early/invite', body, secret === null ? {} : { 'X-ZigDash-Admin': secret });
  w.entry = (key, fields, expiration = NOW + 100 * 86_400) => {
    env.EARLY.m.set(key, JSON.stringify({ at: new Date().toISOString(), counted: true, lang: 'en', ...fields }));
    if (expiration) env.EARLY.exp.set(key, expiration);
  };
  w.read = (key) => JSON.parse(env.EARLY.m.get(key));
  w.toChat = (chat) => w.tg.filter((c) => c.method === 'sendMessage' && String(c.body.chat_id) === String(chat)).map((c) => c.body.text);
  return w;
}

const idemKey = (position, code) => `invite-${position}-${crypto.createHmac('sha256', ADMIN).update(code).digest('hex').slice(0, 12)}`;
const longDay = (locale, day = REDEEM_BY) =>
  new Intl.DateTimeFormat(locale, { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' }).format(new Date(`${day}T00:00:00Z`));
const today = () => new Date().toISOString().slice(0, 10);

/// The list the selection tests share: positions 1, 2 (not counted), 7 twice
/// (a race), 20, plus what must be skipped.
function seed(w) {
  w.entry('early:email:ann@example.com', { via: 'email', position: 1, token: 'n1' });
  w.entry('early:tg:2002', { via: 'telegram', position: 2, counted: false });
  w.entry('early:tg:7007', { via: 'telegram', position: 7 });
  w.entry('early:email:bob@example.com', { via: 'email', position: 7, counted: false, token: 'n7' });
  w.entry('early:email:eve@example.com', { via: 'email', position: 20, token: 'n20' });
  w.entry('early:tg:2121', { via: 'telegram', position: 21 });
  w.entry('early:tg:3003', { via: 'telegram', position: 3, invited: '2026-11-01' });
  w.entry('early:other:4', { position: 4 });
  w.env.EARLY.m.set('early:count', '21');
  w.env.EARLY.m.set('chat:linked', '[]');
}

test('the admin secret: missing, wrong or not configured answers 401 and does nothing', async (t) => {
  const w = setup(t);
  seed(w);
  const before = JSON.stringify([...w.env.EARLY.m]);
  assert.equal((await w.invite({ dry_run: true }, null)).status, 401);
  assert.equal((await w.invite({ dry_run: true }, 'wrong')).status, 401);
  assert.equal((await w.invite({ dry_run: true }, '')).status, 401);
  assert.equal((await w.invite({ codes: CODES, redeem_by: REDEEM_BY }, ADMIN.slice(0, -1) + 'x')).status, 401);
  const off = setup(t, { EARLY_ADMIN_SECRET: undefined });
  seed(off);
  assert.equal((await off.invite({ dry_run: true }, '')).status, 401);
  assert.equal((await off.invite({ dry_run: true }, 'undefined')).status, 401);
  assert.equal(w.fetches + off.fetches, 0);
  assert.equal(JSON.stringify([...w.env.EARLY.m]), before);
});

test('dry run: counts position <= 20 whatever counted says, duplicates included; skips invited, > 20 and other keys', async (t) => {
  const w = setup(t);
  seed(w);
  const r = await w.invite({ dry_run: true });
  assert.equal(r.status, 200);
  assert.deepEqual(await r.json(), { eligible: 5 });
  assert.equal(w.fetches, 0);
  assert.equal(w.env.EARLY.puts.length, 0, 'a dry run writes nothing');
});

test('send: codes paired by position, both channels, invited written with the remaining TTL, no code stored', async (t) => {
  const w = setup(t);
  seed(w);
  const listed = Object.fromEntries([...w.env.EARLY.exp]);
  const codes = CODES.slice(0, 6);
  const r = await w.invite({ codes, redeem_by: REDEEM_BY });
  assert.equal(r.status, 200);
  assert.deepEqual(await r.json(), { sent: 5, failed: [], unused: 1 });

  // Order: 1 (email), 2 (tg), 7 (email before tg: key order), 7 (tg), 20 (email).
  assert.equal(w.mails.length, 3);
  assert.deepEqual(w.mails.map((m) => m.body.to), [['ann@example.com'], ['bob@example.com'], ['eve@example.com']]);
  assert.deepEqual(w.mails.map((m) => m.key), [idemKey(1, codes[0]), idemKey(7, codes[2]), idemKey(20, codes[4])]);
  for (const [i, m] of w.mails.entries()) {
    assert.equal(m.body.from, 'Gilad from ZigDash <support@zigdash.app>');
    assert.equal(m.body.reply_to, 'giladtamam1@gmail.com');
    assert.equal(m.body.subject, "Your ZigDash founder's code");
    assert.ok(!('bcc' in m.body) && !('cc' in m.body), 'no copy to anyone');
    assert.ok(m.body.text.includes([codes[0], codes[2], codes[4]][i]));
    assert.ok(m.body.text.endsWith('so I can answer, or reply to this email.'));
  }
  const tgSends = w.tg.filter((c) => c.method === 'sendMessage');
  assert.ok(tgSends.every((c) => c.token === 'home:bot'), 'through @ZigDashHomeBot');
  assert.deepEqual(w.toChat(2002).length, 1);
  assert.ok(w.toChat(2002)[0].includes(codes[1]));
  assert.ok(w.toChat(7007)[0].includes(codes[3]));
  assert.ok(w.toChat(2002)[0].endsWith('so I can answer.'));
  assert.equal(w.toChat(2121).length + w.toChat(3003).length, 0);

  for (const key of ['early:email:ann@example.com', 'early:tg:2002', 'early:tg:7007', 'early:email:bob@example.com', 'early:email:eve@example.com']) {
    assert.equal(w.read(key).invited, today(), key);
    const put = w.env.EARLY.puts.find((p) => p.k === key);
    assert.deepEqual(put.opts, { expiration: listed[key] }, `${key} keeps its own expiration`);
  }
  assert.equal(w.read('early:email:ann@example.com').token, 'n1', 'the rest of the entry is kept');
  assert.deepEqual(w.env.EARLY.puts.map((p) => p.k).sort(), ['early:email:ann@example.com', 'early:email:bob@example.com', 'early:email:eve@example.com', 'early:tg:2002', 'early:tg:7007']);
  const stored = JSON.stringify([...w.env.EARLY.m, ...w.env.RATE.m]);
  for (const c of codes) {
    assert.ok(!stored.includes(c) && !stored.includes(c.replace(/-/g, '')), 'no code is stored');
  }

  // A second run finds nobody left.
  assert.deepEqual(await (await w.invite({ dry_run: true })).json(), { eligible: 0 });
  assert.deepEqual(await (await w.invite({ codes: [CODES[13]], redeem_by: REDEEM_BY })).json(), { sent: 0, failed: [], unused: 1 });
});

test('remaining TTL: the listed expiration, or 180 days from `at` when the listing has none', async (t) => {
  const w = setup(t);
  const soon = NOW + 3 * 86_400;
  w.entry('early:tg:11', { position: 1 }, soon);
  const at = new Date(Date.now() - 40 * 86_400_000).toISOString();
  w.entry('early:tg:12', { position: 2, at }, null);
  await w.invite({ codes: CODES.slice(0, 2), redeem_by: REDEEM_BY });
  assert.deepEqual(w.env.EARLY.puts.find((p) => p.k === 'early:tg:11').opts, { expiration: soon });
  assert.deepEqual(w.env.EARLY.puts.find((p) => p.k === 'early:tg:12').opts,
    { expiration: Math.floor(Date.parse(at) / 1000) + 180 * 86_400 });
});

test('failures: not marked invited, reported by position without addresses, retried on the next run', async (t) => {
  const w = setup(t);
  w.entry('early:tg:501', { position: 1 });
  w.entry('early:tg:502', { position: 2 });
  w.entry('early:email:carl@example.com', { position: 3 });
  w.entry('early:tg:504', { position: 4 });
  w.tgFail['501'] = 403;
  w.tgFail['502'] = 'timeout';
  w.resendFail['carl@example.com'] = 422;
  const res = await (await w.invite({ codes: CODES.slice(0, 4), redeem_by: REDEEM_BY })).json();
  assert.deepEqual(res, {
    sent: 1, unused: 0,
    failed: [{ position: 1, why: 'telegram 403' }, { position: 2, why: 'telegram timeout' }, { position: 3, why: 'resend 422 validation_error' }],
  });
  assert.ok(!JSON.stringify(res).includes('carl') && !JSON.stringify(res).includes('501'));
  for (const k of ['early:tg:501', 'early:tg:502', 'early:email:carl@example.com']) assert.equal(w.read(k).invited, undefined);
  assert.equal(w.read('early:tg:504').invited, today());
  assert.deepEqual(await (await w.invite({ dry_run: true })).json(), { eligible: 3 });
});

test('an entry deleted (/stop) while its invite was going out is not brought back', async (t) => {
  const w = setup(t);
  w.entry('early:tg:601', { position: 1 });
  w.onSend = async (to) => { if (to === '601') await w.env.EARLY.delete('early:tg:601'); };
  const res = await (await w.invite({ codes: [CODES[0]], redeem_by: REDEEM_BY })).json();
  assert.deepEqual(res, { sent: 1, failed: [{ position: 1, why: 'sent, not recorded' }], unused: 0 });
  assert.ok(!w.env.EARLY.m.has('early:tg:601'));
});

test('refused before sending: too few codes (409), bad codes, bad or past redeem_by, bad body', async (t) => {
  const w = setup(t);
  seed(w);
  const r = await w.invite({ codes: CODES.slice(0, 4), redeem_by: REDEEM_BY });
  assert.equal(r.status, 409);
  assert.deepEqual(await r.json(), { error: 'too_few_codes', eligible: 5 });
  for (const codes of [[], 'ZD-AB12-CD34-EF', ['zd-ab12-cd34-ef'], ['ZD-AB12-CD34-EI'], ['ZD-AB12-CD34-EL'], ['ZD-AB12-CD34-EO'],
    ['ZD-AB12-CD34-EU'], ['ZD-AB12-CD34-EFG'], ['ZDAB12CD34EF'], [CODES[0], CODES[0]], [42]]) {
    assert.equal((await w.invite({ codes, redeem_by: REDEEM_BY })).status, 400, JSON.stringify(codes));
  }
  for (const day of [undefined, '2030-02-30', '15/01/2030', '2020-01-01', 20300115]) {
    assert.equal((await w.invite({ codes: CODES, redeem_by: day })).status, 400, String(day));
  }
  assert.equal((await w.call('/v1/early/invite', 'not json', { 'X-ZigDash-Admin': ADMIN })).status, 400);
  assert.equal(w.fetches, 0);
  assert.equal(w.env.EARLY.puts.length, 0);
});

test('the English message, exactly', async (t) => {
  const w = setup(t);
  w.entry('early:tg:701', { position: 1, lang: 'en' });
  w.entry('early:email:dan@example.com', { position: 2, lang: 'en' });
  await w.invite({ codes: CODES.slice(0, 2), redeem_by: REDEEM_BY });
  const body = (code, end) => [
    `You're one of the first 20 on the ZigDash Chat list, so here is your founder's code: ${code}. It gives one Home remote control and Chat for 3 months, free, from the day you enter it.`,
    'You need ZigDash 3.7 or later from Google Play, a Home connected to its MQTT broker, and ZigDash Engine on your hub. Open Settings › Home › Remote control, tap "Have a founder\'s code?" and enter it by 15 January 2030.',
    `Questions or need more time? Write from Get help in the app and add your email so I can answer${end}`,
  ].join('\n\n');
  // Email entries come first in key order only at equal positions; here email is #2.
  assert.equal(w.toChat(701)[0], body(CODES[0], '.'));
  assert.equal(w.mails[0].body.text, body(CODES[1], ', or reply to this email.'));
});

test('languages: the entry\'s own of the 13, its long date, else English', async (t) => {
  const w = setup(t);
  const langs = { en: 'en-GB', cs: 'cs', de: 'de', es: 'es', fr: 'fr', he: 'he', it: 'it', nb: 'nb', nl: 'nl', pl: 'pl', pt: 'pt-BR', ru: 'ru', sv: 'sv' };
  const order = Object.keys(langs);
  order.forEach((lang, i) => w.entry(`early:tg:${800 + i}`, { position: i + 1, lang }));
  w.entry('early:tg:899', { position: 14, lang: 'xx' });
  w.entry('early:email:mia@example.com', { position: 15, lang: 'de' });
  const codes = [...CODES, 'ZD-1111-2222-33'];
  const res = await (await w.invite({ codes, redeem_by: REDEEM_BY })).json();
  assert.equal(res.sent, 15);
  const texts = order.map((lang, i) => w.toChat(800 + i)[0]);
  assert.equal(new Set(texts).size, 13, 'every language has its own text');
  for (const [i, lang] of order.entries()) {
    const s = texts[i];
    assert.ok(s.includes(codes[i]), lang);
    assert.ok(s.includes(longDay(langs[lang])), `${lang}: ${longDay(langs[lang])}`);
    for (const word of ['ZigDash', '3.7', 'Google Play', 'MQTT', 'ZigDash Engine', '20', '3', '›']) assert.ok(s.includes(word), `${lang}: ${word}`);
    assert.equal(s.split('\n\n').length, 3, lang);
    assert.ok(!/\{(code|date|end)\}/.test(s), lang);
    assert.ok(s.endsWith('.') && !s.includes('..'), lang);
  }
  assert.equal(w.toChat(899)[0], texts[0].replace(codes[0], codes[13]));
  assert.match(texts[2], /Gründer-Code: ZD-/);
  const mail = w.mails[0].body.text;
  assert.ok(mail.includes(codes[14]) && mail.includes(longDay('de')));
  assert.ok(mail.endsWith(', oder antworte auf diese E-Mail.'));
  assert.equal(w.mails[0].body.subject, "Your ZigDash founder's code");
});

test('bot replies to a listed chat: invited, waiting for a code, past 20; same through zigdash-chat', async (t) => {
  const w = setup(t);
  w.entry('early:tg:901', { via: 'telegram', position: 4, invited: '2026-11-20' });
  w.entry('early:tg:902', { via: 'telegram', position: 5, counted: false });
  w.entry('early:tg:903', { via: 'telegram', position: 25 });
  const msg = (chat, text = 'hello') => ({ update_id: 1, message: { chat: { id: chat, type: 'private' }, from: { language_code: 'en' }, text } });
  await w.call(`/v1/tg/${HOOK}`, msg(901), { 'X-Telegram-Bot-Api-Secret-Token': HOOK });
  await w.call(`/v1/tg/${HOOK}`, msg(902), { 'X-Telegram-Bot-Api-Secret-Token': HOOK });
  await w.call(`/v1/tg/${HOOK}`, msg(903), { 'X-Telegram-Bot-Api-Secret-Token': HOOK });
  assert.equal(w.toChat(901)[0],
    "Your founder's code was sent on 20 November 2026. Questions or need more time? Write from Get help in the ZigDash app (Settings › Get help) and add your email so I can answer. Send /stop to leave the list.");
  assert.equal(w.toChat(902)[0],
    "You're #5 on the list: one of the first 20. You'll get a founder's code: Chat and remote access, free for 3 months. It's on its way soon. Send /stop to leave the list.");
  assert.equal(w.toChat(903)[0], "You're #25 on the list. Chat is out now for ZigDash Pro owners. Send /stop to leave the list.");
  assert.ok(!w.toChat(901)[0].includes('ZD-'));
  // zigdash-chat passes no free text: an empty text gets the same reply.
  await w.call('/v1/early/tg', msg(901, ''), { 'X-ZigDash-Chat-Secret': CHAT });
  assert.equal(w.toChat(901)[1], w.toChat(901)[0]);
  assert.equal(w.env.EARLY.puts.length, 0, 'a reply changes nothing');
});
