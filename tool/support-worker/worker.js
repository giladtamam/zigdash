// ZigDash support receiver (docs/design/help-and-review-2026-11.md §2) and
// the "Chat with your home" early-access list
// (docs/design/assistant-early-access.md §4–5).
//
// A Cloudflare Worker: the app POSTs a support message here, and it is
// forwarded to the developer's private Telegram chat through the support
// bot. Support messages are not stored and the body is never logged.
// Early-access entries are stored (KV EARLY, 180 days) and only used to
// invite people to the beta.
//
// Answering (docs/design/support-reply.md): the developer uses Reply on a
// forwarded message in Telegram, taps Send on the preview, and the answer is
// emailed through Resend. The address is read from the forwarded message
// itself; the only thing kept is the draft (address, answer, the person's
// message) in KV RATE for at most an hour, plus monthly counts.
//
// Founders' pass invites (docs/design/founders-pass.md, Invites): the owner
// POSTs /v1/early/invite with codes made by the relay's `passes new`; each
// list entry at position <= 20 not yet invited gets one code, by Telegram
// (@ZigDashHomeBot) or by email (Resend), in its language. The entry keeps
// only the invite date (`invited`), never the code.
//
// Secrets (set in the Worker's settings, never in this file):
//   SUPPORT_BOT_TOKEN         the support bot's token; its webhook answers
//   SUPPORT_WEBHOOK_SECRET    path part and header secret of that webhook
//   RESEND_API_KEY            Resend, sending access for zigdash.app only
//   TELEGRAM_BOT_TOKEN        @zigdash_bot (the group bot): the old sender,
//                             now only a fallback on an HTTP error
//   TELEGRAM_CHAT_ID          the developer's private chat with the bots
//   ASSISTANT_BOT_TOKEN       @ZigDashHomeBot, the chat-with-your-home bot
//   ASSISTANT_WEBHOOK_SECRET  path part and header secret of its webhook
//   CHAT_SERVICE_SECRET       ZigDash Chat (tool/zigdash-chat, WORKER_SECRET_FILE there):
//                             its header secret for /v1/early/tg and /v1/early/linked, and
//                             the HMAC key of the linked chat ids
//   EARLY_ADMIN_SECRET        the owner's header secret (X-ZigDash-Admin) for
//                             /v1/early/invite, and the HMAC key of the invite
//                             emails' idempotency keys
// Bindings:
//   RATE                a KV namespace for the per-address and daily counters,
//                       and the answer drafts (personal data, 1 hour)
//   EARLY               a KV namespace for the early-access list
//
// ZigDash Chat (docs/design/chat-linking.md §2): once @ZigDashHomeBot's webhook
// points at zigdash-chat, that service passes the early-access updates here
// (POST /v1/early/tg, the same handling as the webhook below) and keeps the
// list of linked chats (POST /v1/early/linked, HMACs only, KV EARLY
// "chat:linked"). If the webhook is rolled back to this Worker, a linked chat
// gets "Chat is paused for maintenance" instead of the early-access reply.
//
// Routes (POST only): /v1/message (support, from the app), /v1/early and
// /v1/early/price (the early-access card), /v1/early/tg and /v1/early/linked
// (zigdash-chat), /v1/early/invite (the owner), /v1/tg/<secret> and
// /v1/support-tg/<secret> (the two bots' webhooks).
//
// /v1/message answers: 200 sent, 400 bad body, 413 too large, 405 wrong method,
// 503 over a limit or Telegram unreachable (the app then offers Share).
// /v1/early/invite answers: 401 wrong or no admin secret, 400 bad body,
// 409 fewer codes than eligible entries (nothing sent), 200 {eligible} on a
// dry run, else 200 {sent, failed: [{position, why}], unused}.
// No CORS: the caller is the app, not a web page.

const MAX_BODY = 8 * 1024;
const PER_HOUR = 5;
const PER_DAY_ALL = 200;
const TELEGRAM_MAX = 4096;

export default {
  // Called by the app only, never by a browser page: no CORS headers, so a
  // web page cannot fire this endpoint from a visitor's browser.
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method !== 'POST') return text(405, 'POST only');
    if (url.pathname === '/v1/early') return earlyJoin(request, env);
    if (url.pathname === '/v1/early/price') return earlyPrice(request, env);
    if (url.pathname === '/v1/early/tg') return chatForwarded(request, env);
    if (url.pathname === '/v1/early/linked') return chatLinked(request, env);
    if (url.pathname === '/v1/early/invite') return earlyInvite(request, env);
    if (env.ASSISTANT_WEBHOOK_SECRET &&
        url.pathname === `/v1/tg/${env.ASSISTANT_WEBHOOK_SECRET}`) {
      return botUpdate(request, env);
    }
    if (env.SUPPORT_WEBHOOK_SECRET &&
        url.pathname === `/v1/support-tg/${env.SUPPORT_WEBHOOK_SECRET}`) {
      return supportUpdate(request, env);
    }
    if (url.pathname !== '/v1/message') return text(404, 'not here');

    const length = Number(request.headers.get('content-length') || 0);
    if (length > MAX_BODY) return text(413, 'too large');
    const raw = await request.text();
    if (raw.length > MAX_BODY) return text(413, 'too large');

    let body;
    try {
      body = JSON.parse(raw);
    } catch {
      return text(400, 'bad json');
    }
    const message = String(body.text ?? '').trim();
    if (!message) return text(400, 'text required');

    const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
    const counters = await read(env, ip);
    if (!counters.allowed) return text(503, 'over limit');

    // Lines 0 and 1 are what an answer is addressed by: no field may add a
    // line before the From line, and that line holds one plain address.
    const typed = String(body.email ?? '').trim();
    const email = cleanEmail(typed);
    const lines = [
      `ZigDash ${body.kind === 'ai_report' ? 'AI report' : 'support'}, ${field(body.app, VERSION_RE)}+${field(body.build, VERSION_RE)}, ${field(body.locale, LOCALE_RE)}`,
      email ? `From: ${email}` : typed ? 'From: (invalid address)' : 'From: (no email)',
      '',
      message,
      ...(typed && !email ? [`Typed: ${Array.from(typed.replace(/[\r\n]+/g, ' ')).slice(0, 100).join('')}`] : []),
      '',
      '— Support details —',
      String(body.details ?? ''),
    ];
    const sent = await supportPost(env, lines.join('\n'));
    // Counted only when delivered, so a Telegram outage does not burn the
    // user's hourly budget.
    if (sent) await bump(env, counters);
    return sent ? text(200, 'sent') : text(503, 'not sent');
  },
};

function text(status, s) {
  return new Response(s, { status, headers: { 'content-type': 'text/plain; charset=utf-8' } });
}

function clip(s, max) {
  if (s.length <= max) return s;
  const marker = '\n… (cut)';
  return s.slice(0, max - marker.length) + marker;
}

/// Per-address hourly and global daily counters in KV, each key expiring on
/// its own. KV is eventually consistent, so under a burst the counts are
/// approximate; that is accepted (a few extra messages, never a lost one),
/// so do not replace this with Durable Objects. A KV failure counts as
/// allowed: losing a message is worse than a burst.
async function read(env, ip) {
  const hour = Math.floor(Date.now() / 3_600_000);
  const day = Math.floor(Date.now() / 86_400_000);
  const ipKey = `ip:${hash(ip)}:${hour}`;
  const dayKey = `day:${day}`;
  try {
    const [ipCount, dayCount] = await Promise.all([
      env.RATE.get(ipKey),
      env.RATE.get(dayKey),
    ]);
    const perIp = Number(ipCount || 0);
    const perDay = Number(dayCount || 0);
    return {
      allowed: perIp < PER_HOUR && perDay < PER_DAY_ALL,
      ipKey, dayKey, perIp, perDay,
    };
  } catch {
    return { allowed: true, ipKey, dayKey, perIp: 0, perDay: 0 };
  }
}

async function bump(env, c) {
  try {
    await Promise.all([
      env.RATE.put(c.ipKey, String(c.perIp + 1), { expirationTtl: 3600 }),
      env.RATE.put(c.dayKey, String(c.perDay + 1), { expirationTtl: 86400 }),
    ]);
  } catch {
    // Counting failed; the message was delivered, which matters more.
  }
}

/// The address is only ever kept as a short hash in a counter key.
function hash(s) {
  let h = 2166136261;
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 16777619) >>> 0;
  }
  return h.toString(16);
}

async function telegram(env, textBody) {
  return (await tgCall(env.TELEGRAM_BOT_TOKEN, 'sendMessage', {
    chat_id: env.TELEGRAM_CHAT_ID,
    text: textBody,
    disable_web_page_preview: true,
  })).ok;
}

/// A Bot API call: ok, the HTTP status (0 when none came back), whether it
/// timed out, and Telegram's result.
async function tgCall(token, method, payload) {
  try {
    const r = await fetch(`https://api.telegram.org/bot${token}/${method}`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(payload),
      signal: AbortSignal.timeout(6000),
    });
    let result = null;
    try {
      result = (await r.json())?.result ?? null;
    } catch {}
    return { ok: r.ok, status: r.status, timeout: false, result };
  } catch (e) {
    return { ok: false, status: 0, timeout: e?.name === 'TimeoutError', result: null };
  }
}

const ANSWER_LINE = 'Reply to this message to answer by email.';
const TAP_LINE = 'Tap the address to answer by email.';

/// Posts to the developer through the support bot, or through
/// @zigdash_bot when there is no support bot yet or it gave a definite
/// error. A timeout is not retried there: the message may have arrived, and
/// a double post is worse than the Share the app then offers. The line on
/// how to answer is added after clipping, so it is never cut off.
async function supportPost(env, body, { answerable = true } = {}) {
  const withLine = (line) => line ? `${clip(body, TELEGRAM_MAX - line.length - 2)}\n\n${line}` : clip(body, TELEGRAM_MAX);
  if (env.SUPPORT_BOT_TOKEN) {
    const r = await tgCall(env.SUPPORT_BOT_TOKEN, 'sendMessage', {
      chat_id: env.TELEGRAM_CHAT_ID,
      text: withLine(answerable ? ANSWER_LINE : ''),
      disable_web_page_preview: true,
    });
    if (r.ok) return true;
    if (r.timeout || !env.TELEGRAM_BOT_TOKEN) return false;
    await count(env, `fallback:${month()}`);
  }
  return telegram(env, withLine(answerable ? TAP_LINE : ''));
}

const VERSION_RE = /^[0-9A-Za-z._+-]{1,20}$/;
const LOCALE_RE = /^[a-z]{2,3}([_-][A-Za-z]{2,4})?$/;

function field(v, re) {
  const s = String(v ?? '');
  return re.test(s) ? s : '?';
}

/// One plain address, or null: nothing that could add a second recipient
/// or a header.
function cleanEmail(s) {
  const e = String(s ?? '').trim();
  return validEmail(e) && !/[\s,;<>]/.test(e) ? e : null;
}

function month() {
  return new Date().toISOString().slice(0, 7);
}

/// A monthly count (approximate under races, like the rate counters).
async function count(env, key) {
  try {
    const n = Number((await env.RATE.get(key)) || 0) + 1;
    await env.RATE.put(key, String(n), { expirationTtl: 400 * 86_400 });
  } catch {}
}

// ---------------------------------------------------------------------------
// Chat with your home: early access (assistant-early-access.md §4–5)

const EARLY_FREE = 20;
const EARLY_TTL = 180 * 86_400;
const EARLY_PER_HOUR = 5;
const EARLY_PER_DAY = 100;
const EARLY_MAX_BODY = 1024;
const LOCALES = new Set(['en', 'de', 'fr', 'es', 'it', 'nl', 'pl', 'pt', 'ru', 'he', 'cs', 'sv', 'nb']);
const PRICE_ANSWERS = new Set(['yes', 'maybe', 'no']);
const POLICY_URL =
  'https://github.com/giladtamam/zigdash/blob/main/store/PRIVACY.md#chat-with-your-home-early-access';
const PRICE_QUESTION = 'After the free months, would €2.49 a month be OK?';

function json(status, obj) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8' },
  });
}

async function readJson(request, max) {
  const length = Number(request.headers.get('content-length') || 0);
  if (length > max) return null;
  const raw = await request.text();
  if (raw.length > max) return null;
  try {
    const body = JSON.parse(raw);
    return body && typeof body === 'object' ? body : null;
  } catch {
    return null;
  }
}

/// Sign-up counters, separate from the support ones so sign-up spam never
/// uses up the support Send budget.
async function earlyAllowed(env, ip) {
  const hour = Math.floor(Date.now() / 3_600_000);
  const day = Math.floor(Date.now() / 86_400_000);
  const ipKey = `early:ip:${hash(ip)}:${hour}`;
  const dayKey = `early:day:${day}`;
  try {
    const [a, b] = await Promise.all([env.RATE.get(ipKey), env.RATE.get(dayKey)]);
    const perIp = Number(a || 0);
    const perDay = Number(b || 0);
    if (perIp >= EARLY_PER_HOUR || perDay >= EARLY_PER_DAY) return false;
    await Promise.all([
      env.RATE.put(ipKey, String(perIp + 1), { expirationTtl: 3600 }),
      env.RATE.put(dayKey, String(perDay + 1), { expirationTtl: 86400 }),
    ]);
    return true;
  } catch {
    return true;
  }
}

function validEmail(e) {
  return typeof e === 'string' && e.length <= 254 &&
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e);
}

/// The next number on the list. KV can repeat a number under a race; the
/// rule (plan §5) is that every person told #N <= 20 is honoured, so a
/// race costs a place or two, never a broken promise.
async function nextPosition(env) {
  const n = Number((await env.EARLY.get('early:count')) || 0) + 1;
  await env.EARLY.put('early:count', String(n));
  return n;
}

/// Adds an entry, or returns the existing one with its first number.
async function enroll(env, key, fields) {
  const existing = await env.EARLY.get(key, 'json');
  if (existing) return { entry: existing, isNew: false };
  const entry = { ...fields, position: await nextPosition(env), at: new Date().toISOString() };
  await env.EARLY.put(key, JSON.stringify(entry), { expirationTtl: EARLY_TTL });
  return { entry, isNew: true };
}

async function earlyJoin(request, env) {
  const body = await readJson(request, EARLY_MAX_BODY);
  if (!body) return text(400, 'bad body');
  const email = String(body.email ?? '').trim().toLowerCase();
  if (!validEmail(email)) return text(400, 'bad email');
  const lang = LOCALES.has(body.lang) ? body.lang : 'en';
  const counted = body.counted === true;
  // The phone's own random id for this sign-up: it proves a retry or a
  // price answer comes from the phone that made the entry.
  const nonce = String(body.nonce ?? '');
  if (!/^[A-Za-z0-9-]{16,64}$/.test(nonce)) return text(400, 'bad nonce');
  const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
  if (!(await earlyAllowed(env, ip))) return text(503, 'over limit');
  try {
    const { entry, isNew } = await enroll(env, `early:email:${email}`, {
      via: 'email', lang, counted, token: nonce,
    });
    if (isNew) await notifyDeveloper(env, entry);
    // The number goes only to the phone that made the entry (a retry with
    // the same nonce), so nobody can look up whether an address is listed.
    if (!isNew && entry.token !== nonce) return json(200, { listed: true });
    return json(200, { position: entry.position, free: entry.position <= EARLY_FREE });
  } catch {
    return text(503, 'not stored');
  }
}

async function earlyPrice(request, env) {
  const body = await readJson(request, EARLY_MAX_BODY);
  if (!body) return text(400, 'bad body');
  const answer = String(body.answer ?? '');
  const email = String(body.email ?? '').trim().toLowerCase();
  const token = String(body.token ?? '');
  if (!PRICE_ANSWERS.has(answer) || !validEmail(email) || !token) return text(400, 'bad body');
  const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
  if (!(await earlyAllowed(env, ip))) return text(503, 'over limit');
  return (await setPrice(env, `early:email:${email}`, answer, token)) ? text(200, 'ok') : text(404, 'not on the list');
}

/// Telegram answers come only through the webhook (no token: the chat id
/// is proven by Telegram); email answers need the entry's token.
async function setPrice(env, key, answer, token) {
  const entry = await env.EARLY.get(key, 'json');
  if (!entry) return false;
  if (token !== undefined && entry.token !== token) return false;
  if (!entry.price) {
    entry.price = answer;
    await env.EARLY.put(key, JSON.stringify(entry), { expirationTtl: EARLY_TTL });
  }
  return true;
}

async function notifyDeveloper(env, e) {
  await supportPost(env, `Chat early access: #${e.position}, ${e.via}, ${e.counted ? 'counted' : 'not counted'}, ${e.lang}`, { answerable: false });
}

function placeLine(position) {
  return position <= EARLY_FREE
    ? `You're #${position} on the list: one of the first ${EARLY_FREE}. You'll get a founder's code: Chat and remote access, free for 3 months.`
    : `You're #${position} on the list. The first ${EARLY_FREE} places are taken. Chat is out now for ZigDash Pro owners.`;
}

/// What a listed chat hears (founders-pass.md, Replies). Chat is out; the
/// first 20 get a founder's code, and once it is sent, questions go through
/// Get help in the app (the webhook passes no free text on).
function listedReply(entry) {
  const p = entry.position;
  const leave = 'Send /stop to leave the list.';
  if (entry.invited) {
    return `Your founder's code was sent on ${formatDay(entry.invited, 'en')}. Questions or need more time? ` +
      `Write from Get help in the ZigDash app (Settings › Get help) and add your email so I can answer. ${leave}`;
  }
  if (p <= EARLY_FREE) return `${placeLine(p)} It's on its way soon. ${leave}`;
  return `You're #${p} on the list. Chat is out now for ZigDash Pro owners. ${leave}`;
}

// The bot (@ZigDashHomeBot): Telegram calls this webhook. No IP limit
// (these are Telegram's servers); the header secret proves the caller.
async function botUpdate(request, env) {
  if (request.headers.get('X-Telegram-Bot-Api-Secret-Token') !== env.ASSISTANT_WEBHOOK_SECRET) {
    return text(401, 'no');
  }
  const update = await readJson(request, 64 * 1024);
  if (!update) return text(200, 'ignored');
  try {
    // Rolled back from zigdash-chat: a linked chat is told Chat is paused,
    // except for what was always the early-access list's.
    const m = update.message;
    if (m && m.chat?.type === 'private' && !earlyCommand(m.text) && (await chatIsLinked(env, m.chat.id))) {
      await botSend(env, m.chat.id, CHAT_PAUSED);
    } else {
      await botDispatch(env, update);
    }
  } catch {
    // Answer 200 anyway, or Telegram retries the same update for hours.
  }
  return text(200, 'ok');
}

async function botDispatch(env, update) {
  if (update.callback_query) await botCallback(env, update.callback_query);
  else if (update.message) await botMessage(env, update.message);
}

// ---------------------------------------------------------------------------
// ZigDash Chat: the service holds the webhook and passes early access here.

const CHAT_PAUSED = 'Chat is paused for maintenance; it will be back soon.';
const CHAT_LINKED_KEY = 'chat:linked';
const CHAT_LINKED_MAX = 10000;

function earlyCommand(said) {
  const t = String(said ?? '').trim();
  return t === '/stop' || t === '/start early_c' || t === '/start early_n';
}

function sameSecret(a, b) {
  const x = String(a ?? ''), y = String(b ?? '');
  if (!x || x.length !== y.length) return false;
  let diff = 0;
  for (let i = 0; i < x.length; i++) diff |= x.charCodeAt(i) ^ y.charCodeAt(i);
  return diff === 0;
}

function fromChatService(request, env) {
  return !!env.CHAT_SERVICE_SECRET && sameSecret(request.headers.get('X-ZigDash-Chat-Secret'), env.CHAT_SERVICE_SECRET);
}

/// An update zigdash-chat passed on (chat id, type, language and a command
/// only): handled exactly as the webhook handles it.
async function chatForwarded(request, env) {
  if (!fromChatService(request, env)) return text(401, 'no');
  const update = await readJson(request, 16 * 1024);
  if (!update) return text(400, 'bad body');
  try {
    await botDispatch(env, update);
  } catch {
    return text(503, 'failed');
  }
  return text(200, 'ok');
}

/// The whole list of linked chats, as HMAC-SHA256(CHAT_SERVICE_SECRET, chat id) hex (32), replaced each time.
async function chatLinked(request, env) {
  if (!fromChatService(request, env)) return text(401, 'no');
  const body = await readJson(request, 512 * 1024);
  const ids = body && Array.isArray(body.ids) ? body.ids : null;
  if (!ids || ids.length > CHAT_LINKED_MAX || !ids.every((x) => typeof x === 'string' && /^[0-9a-f]{32}$/.test(x))) {
    return text(400, 'bad body');
  }
  await env.EARLY.put(CHAT_LINKED_KEY, JSON.stringify(ids));
  return text(200, 'ok');
}

async function chatIsLinked(env, chatId) {
  if (!env.CHAT_SERVICE_SECRET || chatId === undefined) return false;
  let ids;
  try {
    ids = await env.EARLY.get(CHAT_LINKED_KEY, 'json');
  } catch {
    return false;
  }
  if (!Array.isArray(ids) || !ids.length) return false;
  return ids.includes((await hmacHex(env.CHAT_SERVICE_SECRET, String(chatId))).slice(0, 32));
}

/// HMAC-SHA256(secret, message) as hex.
async function hmacHex(secret, message) {
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(message)));
  return [...mac].map((b) => b.toString(16).padStart(2, '0')).join('');
}

async function botMessage(env, m) {
  const chat = m.chat?.id;
  if (chat === undefined || m.chat?.type !== 'private') return;
  const key = `early:tg:${chat}`;
  const said = String(m.text ?? '').trim();
  const lang = LOCALES.has(String(m.from?.language_code ?? '').slice(0, 2))
    ? String(m.from.language_code).slice(0, 2) : 'en';

  if (said === '/stop') {
    await env.EARLY.delete(key);
    return botSend(env, chat, "You've left the list, and what we kept about you is deleted.");
  }
  const payload = said.startsWith('/start ') ? said.slice(7).trim() : '';
  if (payload === 'early_c' || payload === 'early_n') {
    return botJoin(env, chat, key, lang, payload === 'early_c');
  }
  const entry = await env.EARLY.get(key, 'json');
  if (entry) return botSend(env, chat, listedReply(entry));
  return botSend(env, chat,
    "This is ZigDash's chat with your home: send a message like \"close the office shutter\" and your home answers. " +
    "It isn't built yet. Join the early-access list?\n\nPrivacy: " + POLICY_URL,
    { inline_keyboard: [[{ text: 'Join the list', callback_data: 'join' }]] });
}

async function botJoin(env, chat, key, lang, counted) {
  const { entry, isNew } = await enroll(env, key, { via: 'telegram', lang, counted });
  if (isNew) await notifyDeveloper(env, entry);
  await botSend(env, chat,
    `${placeLine(entry.position)}\n\nWe keep only this chat's id and language, to invite you to the beta and tell you its price. Send /stop to leave. Privacy: ${POLICY_URL}`);
  if (!entry.price) {
    await botSend(env, chat, PRICE_QUESTION, {
      inline_keyboard: [[
        { text: 'Yes', callback_data: 'price:yes' },
        { text: 'Maybe', callback_data: 'price:maybe' },
        { text: 'No', callback_data: 'price:no' },
      ]],
    });
  }
}

async function botCallback(env, q) {
  const chat = q.message?.chat?.id;
  if (chat === undefined) return;
  const key = `early:tg:${chat}`;
  await botApi(env, 'answerCallbackQuery', { callback_query_id: q.id });
  if (q.data === 'join') {
    const lang = LOCALES.has(String(q.from?.language_code ?? '').slice(0, 2))
      ? String(q.from.language_code).slice(0, 2) : 'en';
    return botJoin(env, chat, key, lang, false);
  }
  const answer = String(q.data ?? '').replace('price:', '');
  if (PRICE_ANSWERS.has(answer) && (await setPrice(env, key, answer))) {
    return botSend(env, chat, 'Thanks, noted.');
  }
}

function botSend(env, chat, textBody, replyMarkup) {
  return botApi(env, 'sendMessage', {
    chat_id: chat,
    text: textBody,
    disable_web_page_preview: true,
    ...(replyMarkup ? { reply_markup: replyMarkup } : {}),
  });
}

async function botApi(env, method, payload) {
  try {
    const r = await fetch(`https://api.telegram.org/bot${env.ASSISTANT_BOT_TOKEN}/${method}`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(payload),
      signal: AbortSignal.timeout(6000),
    });
    return r.ok;
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Answering support from Telegram (docs/design/support-reply.md)

const SUPPORT_FROM = 'Gilad from ZigDash <support@zigdash.app>';
const SUPPORT_INBOX = 'giladtamam1@gmail.com';
const SUPPORT_SUBJECT = 'Your ZigDash support message';
const DRAFT_TTL = 3600;
const REPLY_MAX = 3800;
const ORIGINAL_MAX = 1500;
const DETAILS_LINE = '— Support details —';
const HEADER_RE = /^ZigDash (support|AI report), /;

const USE_REPLY = 'Use Reply on the support message you want to answer.';
const TEXT_ONLY = 'Text only: answer with a text reply.';
const NO_ADDRESS = "This message has no email address, so it can't be answered.";
const TOO_LONG = `Too long for one answer (over ${REPLY_MAX.toLocaleString('en')} characters): shorten it and reply again.`;

/// The support bot's webhook. Only the developer is answered; anything
/// else gets 200 and nothing, so Telegram never retries.
async function supportUpdate(request, env) {
  if (!sameSecret(request.headers.get('X-Telegram-Bot-Api-Secret-Token'), env.SUPPORT_WEBHOOK_SECRET)) {
    return text(401, 'no');
  }
  const update = await readJson(request, 64 * 1024);
  if (!update) return text(200, 'ignored');
  try {
    if (update.callback_query) await supportCallback(env, update.callback_query);
    else if (update.edited_message) await supportEdited(env, update.edited_message);
    else if (update.message) await supportMessage(env, update.message);
  } catch {
    // 200 anyway: a retry of the same update would not go better.
  }
  return text(200, 'ok');
}

const isOwner = (env, id) => id !== undefined && String(id) === String(env.TELEGRAM_CHAT_ID);
const supportBotId = (env) => String(env.SUPPORT_BOT_TOKEN ?? '').split(':')[0];
const sApi = (env, method, payload) => tgCall(env.SUPPORT_BOT_TOKEN, method, payload);
const sSay = (env, textBody, extra = {}) =>
  sApi(env, 'sendMessage', { chat_id: env.TELEGRAM_CHAT_ID, text: textBody, disable_web_page_preview: true, ...extra });

/// A forwarded support message: its kind, the one address on line 1 (or
/// null), the date, and the person's own text. Only lines 0 and 1 decide
/// where an answer goes; nothing in the person's text can.
function parseForwarded(textBody) {
  const lines = String(textBody ?? '').split('\n');
  if (!HEADER_RE.test(lines[0] ?? '')) return null;
  const from = /^From: (.+)$/.exec(lines[1] ?? '');
  if (!from) return null;
  const to = cleanEmail(from[1]);
  let end = lines.indexOf(DETAILS_LINE, 3);
  if (end < 0) end = lines.length;
  const body = lines.slice(3, end).filter((l) => l !== '… (cut)' && l !== ANSWER_LINE && l !== TAP_LINE);
  while (body.length && (body.at(-1).trim() === '' || body.at(-1).startsWith('Typed: '))) body.pop();
  return { to, original: body.join('\n') };
}

async function supportMessage(env, m) {
  if (!isOwner(env, m.chat?.id) || !isOwner(env, m.from?.id)) return;
  const r = m.reply_to_message;
  if (!r) return sSay(env, USE_REPLY);
  if (typeof m.text !== 'string' || !m.text.trim()) return sSay(env, TEXT_ONLY);
  const forwarded = String(r.from?.id) === supportBotId(env) ? parseForwarded(r.text) : null;
  if (!forwarded) return sSay(env, USE_REPLY);
  if (!forwarded.to) return sSay(env, NO_ADDRESS);
  if (m.text.length > REPLY_MAX) return sSay(env, TOO_LONG);

  const id = draftId();
  const draft = {
    to: forwarded.to, reply: m.text, original: forwarded.original,
    date: r.date, forwardedId: r.message_id, replyId: m.message_id,
  };
  await env.RATE.put(`reply:${id}`, JSON.stringify(draft), { expirationTtl: DRAFT_TTL });
  const chars = Array.from(m.text);
  const start = chars.slice(0, 60).join('') + (chars.length > 60 ? '…' : '');
  const preview = await sSay(env, `Send this answer (${chars.length} characters, starts "${start}") to ${forwarded.to}?`, {
    reply_to_message_id: m.message_id,
    reply_markup: { inline_keyboard: [[{ text: 'Send', callback_data: `s:${id}` }, { text: 'Cancel', callback_data: `c:${id}` }]] },
  });
  const previewId = preview.result?.message_id;
  if (previewId) {
    await env.RATE.put(`replyof:${m.message_id}`, JSON.stringify({ id, previewId }), { expirationTtl: DRAFT_TTL });
  }
}

/// The reply was edited after its preview: the draft holds the old text, so
/// it is dropped, and what is sent is always what the screen shows.
async function supportEdited(env, m) {
  if (!isOwner(env, m.chat?.id) || !isOwner(env, m.from?.id)) return;
  const link = await env.RATE.get(`replyof:${m.message_id}`, 'json');
  if (!link || !(await env.RATE.get(`reply:${link.id}`))) return;
  await env.RATE.delete(`reply:${link.id}`);
  await env.RATE.delete(`replyof:${m.message_id}`);
  await sApi(env, 'editMessageText', {
    chat_id: env.TELEGRAM_CHAT_ID, message_id: link.previewId,
    text: 'Your reply changed: reply to the support message again to send it.',
  });
}

/// Send, Cancel and Done. Only a success and Cancel edit the preview; every
/// other outcome is a notice on the tap, so a late or losing tap can never
/// overwrite "Accepted".
async function supportCallback(env, q) {
  if (!isOwner(env, q.from?.id) || !isOwner(env, q.message?.chat?.id)) return;
  const notice = (t) => sApi(env, 'answerCallbackQuery', { callback_query_id: q.id, ...(t ? { text: t, show_alert: true } : {}) });
  const [verb, a, b] = String(q.data ?? '').split(':');
  const previewId = q.message?.message_id;
  const edit = (t, keyboard) => sApi(env, 'editMessageText', {
    chat_id: env.TELEGRAM_CHAT_ID, message_id: previewId, text: t,
    ...(keyboard ? { reply_markup: { inline_keyboard: keyboard } } : {}),
  });

  if (verb === 'c') {
    await env.RATE.delete(`reply:${a}`);
    await edit('Cancelled.');
    return notice();
  }
  if (verb === 'd') {
    const left = [];
    for (const [id, name] of [[a, 'the support message'], [b, 'your reply'], [previewId, 'this note']]) {
      if (!id) continue;
      const r = await sApi(env, 'deleteMessage', { chat_id: env.TELEGRAM_CHAT_ID, message_id: Number(id) });
      if (!r.ok) left.push(name);
    }
    return notice(left.length ? `Too old for the bot to delete (over 48 hours): delete ${left.join(', ')} by hand.` : '');
  }
  if (verb !== 's') return notice();

  const draft = await env.RATE.get(`reply:${a}`, 'json');
  if (!draft) {
    if (await env.RATE.get(`sent:${a}`)) return notice('Already sent.');
    const young = Date.now() - Number(q.message?.date ?? 0) * 1000 < DRAFT_TTL * 1000;
    return notice(young ? 'Not ready yet: tap Send again.' : 'Expired: reply to the support message again.');
  }
  const res = await resendSend(env, draft, a);
  if (res.ok) {
    await env.RATE.put(`sent:${a}`, '1', { expirationTtl: DRAFT_TTL });
    await env.RATE.delete(`reply:${a}`);
    await env.RATE.delete(`replyof:${draft.replyId}`);
    await count(env, `replies:${month()}`);
    // No address here: this note stays in the chat.
    await edit('Accepted by Resend. Tap Done when the conversation is over.',
      [[{ text: 'Done', callback_data: `d:${draft.forwardedId}:${draft.replyId}` }]]);
    return notice();
  }
  if (res.name === 'invalid_idempotent_request') {
    await count(env, `bug:${month()}`);
    return notice(`Resend: ${res.message}`);
  }
  if (res.status === 0 || res.status === 409 || res.status === 429 || res.status >= 500) {
    return notice(`Still sending or busy (${res.name || res.status || 'no answer'}): tap Send again.`);
  }
  await env.RATE.delete(`reply:${a}`);
  return notice(`Resend refused it: ${res.message || res.name || res.status}. Reply again to retry.`);
}

function draftId() {
  const bytes = crypto.getRandomValues(new Uint8Array(9));
  return btoa(String.fromCharCode(...bytes)).replace(/\+/g, '-').replace(/\//g, '_');
}

/// The email, built from the draft alone (no clock, no randomness), so a
/// retry under the same idempotency key sends the same request.
function answerEmail(draft) {
  const day = new Date(Number(draft.date) * 1000).toISOString().slice(0, 10);
  return {
    from: SUPPORT_FROM,
    to: [draft.to],
    bcc: [SUPPORT_INBOX],
    reply_to: SUPPORT_INBOX,
    subject: SUPPORT_SUBJECT,
    text: [
      `You wrote to ZigDash support from the app on ${day}.`,
      '',
      draft.reply.trim(),
      '',
      'Reply to this email to answer.',
      '',
      'Your message:',
      quoteOriginal(draft.original),
    ].join('\n'),
  };
}

const TLDS = 'com|net|org|io|app|dev|info|biz|me|co|xyz|online|site|top|link|click|ly|gl|sh|tv|cc|eu|uk|de|nl|be|fr|es|it|pt|pl|cz|ch|at|se|no|dk|fi|ru|il|us|ca|au';
const LINK_RES = [
  /\bhttps?:\/\/\S+/gi,
  /\bwww\.\S+/gi,
  new RegExp(`\\b[a-z0-9-]+(\\.[a-z0-9-]+)*\\.(${TLDS})(\\/\\S*)?(?![a-z0-9-])`, 'gi'),
];

/// The person's message, cut and with links removed, so the sender can't
/// be used to mail someone a link.
function quoteOriginal(original) {
  const chars = Array.from(String(original ?? ''));
  let s = chars.slice(0, ORIGINAL_MAX).join('') + (chars.length > ORIGINAL_MAX ? '…' : '');
  for (const re of LINK_RES) s = s.replace(re, '[link removed]');
  return s;
}

function resendSend(env, draft, id) {
  return resendPost(env, answerEmail(draft), `reply-${id}`);
}

async function resendPost(env, email, idempotencyKey) {
  try {
    const r = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        authorization: `Bearer ${env.RESEND_API_KEY}`,
        'content-type': 'application/json',
        'idempotency-key': idempotencyKey,
      },
      body: JSON.stringify(email),
      signal: AbortSignal.timeout(10000),
    });
    if (r.ok) return { ok: true, status: r.status };
    let e = {};
    try {
      e = await r.json();
    } catch {}
    return { ok: false, status: r.status, name: String(e.name ?? e.type ?? ''), message: String(e.message ?? '') };
  } catch {
    return { ok: false, status: 0, name: '', message: '' };
  }
}

// ---------------------------------------------------------------------------
// Founders' pass invites (docs/design/founders-pass.md, Invites)
//
// The owner runs a dry run, makes exactly that many codes with the relay's
// `passes new`, then posts them here. Entries are listed under early:email:
// and early:tg: only; every entry at position <= 20 is eligible whatever
// `counted` says (it is only the analytics flag), duplicated positions too,
// unless already invited. Codes are paired in order with the entries sorted
// by position. Fewer codes than entries sends nothing (409): a rerun of an
// old file would otherwise give one code to two people. A failed send is
// not marked invited, so a rerun (with new codes) tries it again; the code
// it was paired with should then be revoked, since a timeout may have
// delivered it.

const INVITE_PREFIXES = ['early:email:', 'early:tg:'];
const INVITE_SUBJECT = "Your ZigDash founder's code";
const CROCKFORD = '[0-9A-HJKMNP-TV-Z]';
const CODE_RE = new RegExp(`^ZD-${CROCKFORD}{4}-${CROCKFORD}{4}-${CROCKFORD}{2}$`);
const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;

// The invite in the app's 13 languages: {code} and {date} are filled in,
// and {end} closes the last sentence (Telegram: a full stop; email: "or
// reply to this email" too). The menu names follow the app's own strings.
const INVITE_TEXT = {
  en: {
    locale: 'en-GB',
    paragraphs: [
      "You're one of the first 20 on the ZigDash Chat list, so here is your founder's code: {code}. It gives one Home remote control and Chat for 3 months, free, from the day you enter it.",
      'You need ZigDash 3.7 or later from Google Play, a Home connected to its MQTT broker, and ZigDash Engine on your hub. Open Settings › Home › Remote control, tap "Have a founder\'s code?" and enter it by {date}.',
      'Questions or need more time? Write from Get help in the app and add your email so I can answer{end}',
    ],
    tg: '.', email: ', or reply to this email.',
  },
  cs: {
    locale: 'cs',
    paragraphs: [
      'Jste mezi prvními 20 na seznamu ZigDash Chat, takže tady je váš zakladatelský kód: {code}. Dává jedné domácnosti dálkové ovládání a Chat na 3 měsíce, zdarma, ode dne, kdy ho zadáte.',
      'Potřebujete ZigDash 3.7 nebo novější z Google Play, domácnost připojenou k jejímu MQTT brokeru a ZigDash Engine na hubu. Otevřete Nastavení › Domácnost › Dálkové ovládání, klepněte na „Máte zakladatelský kód?“ a zadejte ho do {date}.',
      'Máte otázky nebo potřebujete víc času? Napište přes Získat pomoc v aplikaci a uveďte svůj e-mail, abych vám mohl odpovědět{end}',
    ],
    tg: '.', email: ', nebo odpovězte na tento e-mail.',
  },
  de: {
    locale: 'de',
    paragraphs: [
      'Du bist unter den ersten 20 auf der ZigDash-Chat-Liste, deshalb hier dein Gründer-Code: {code}. Er gibt einem Zuhause Fernsteuerung und Chat für 3 Monate, kostenlos, ab dem Tag, an dem du ihn eingibst.',
      'Du brauchst ZigDash 3.7 oder neuer aus Google Play, ein Zuhause, das mit seinem MQTT-Broker verbunden ist, und ZigDash Engine auf deinem Hub. Öffne Einstellungen › Zuhause › Fernsteuerung, tippe auf „Hast du einen Gründer-Code?“ und gib ihn bis zum {date} ein.',
      'Fragen, oder brauchst du mehr Zeit? Schreib über Hilfe holen in der App und gib deine E-Mail an, damit ich antworten kann{end}',
    ],
    tg: '.', email: ', oder antworte auf diese E-Mail.',
  },
  es: {
    locale: 'es',
    paragraphs: [
      'Estás entre los 20 primeros de la lista de ZigDash Chat, así que aquí tienes tu código de fundador: {code}. Le da a un hogar control remoto y Chat durante 3 meses, gratis, desde el día en que lo introduzcas.',
      'Necesitas ZigDash 3.7 o posterior de Google Play, un hogar conectado a su bróker MQTT y ZigDash Engine en tu hub. Abre Ajustes › Hogar › Control remoto, toca «¿Tienes un código de fundador?» e introdúcelo a más tardar el {date}.',
      '¿Preguntas o necesitas más tiempo? Escribe desde Obtener ayuda en la app y añade tu correo para que pueda responderte{end}',
    ],
    tg: '.', email: ', o responde a este correo.',
  },
  fr: {
    locale: 'fr',
    paragraphs: [
      'Vous faites partie des 20 premiers de la liste ZigDash Chat, voici donc votre code fondateur : {code}. Il donne à un domicile le contrôle à distance et Chat pendant 3 mois, gratuitement, à partir du jour où vous le saisissez.',
      "Il vous faut ZigDash 3.7 ou plus récent depuis Google Play, un domicile connecté à son broker MQTT et ZigDash Engine sur votre hub. Ouvrez Paramètres › Domicile › Contrôle à distance, touchez « Vous avez un code fondateur ? » et saisissez-le au plus tard le {date}.",
      "Des questions ou besoin de plus de temps ? Écrivez depuis Obtenir de l'aide dans l'application et indiquez votre e-mail pour que je puisse répondre{end}",
    ],
    tg: '.', email: ', ou répondez à cet e-mail.',
  },
  he: {
    locale: 'he',
    paragraphs: [
      'אתה בין 20 הראשונים ברשימה של ZigDash Chat, אז הנה קוד המייסד שלך: {code}. הוא נותן לבית אחד שליטה מרחוק ו-Chat למשך 3 חודשים, בחינם, מהיום שבו תזין אותו.',
      'צריך ZigDash 3.7 ומעלה מ-Google Play, בית שמחובר לברוקר ה-MQTT שלו, ו-ZigDash Engine ברכזת. פתח הגדרות › בית › שליטה מרחוק, הקש על "יש לך קוד מייסד?" והזן אותו עד {date}.',
      'יש שאלות או שצריך עוד זמן? כתוב דרך קבלת עזרה באפליקציה והוסף את האימייל שלך כדי שאוכל לענות{end}',
    ],
    tg: '.', email: ', או השב למייל הזה.',
  },
  it: {
    locale: 'it',
    paragraphs: [
      'Sei tra i primi 20 della lista di ZigDash Chat, quindi ecco il tuo codice fondatore: {code}. Dà a una casa il controllo remoto e Chat per 3 mesi, gratis, dal giorno in cui lo inserisci.',
      'Ti servono ZigDash 3.7 o successivo da Google Play, una casa collegata al suo broker MQTT e ZigDash Engine sul tuo hub. Apri Impostazioni › Casa › Controllo remoto, tocca «Hai un codice fondatore?» e inseriscilo entro il {date}.',
      'Domande o ti serve più tempo? Scrivi da Ottieni aiuto nell\'app e aggiungi la tua email così posso risponderti{end}',
    ],
    tg: '.', email: ', oppure rispondi a questa email.',
  },
  nb: {
    locale: 'nb',
    paragraphs: [
      'Du er blant de 20 første på ZigDash Chat-listen, så her er grunnleggerkoden din: {code}. Den gir ett hjem fjernstyring og Chat i 3 måneder, gratis, fra dagen du skriver den inn.',
      'Du trenger ZigDash 3.7 eller nyere fra Google Play, et hjem koblet til MQTT-brokeren sin og ZigDash Engine på huben din. Åpne Innstillinger › Hjem › Fjernstyring, trykk på «Har du en grunnleggerkode?» og skriv den inn innen {date}.',
      'Spørsmål, eller trenger du mer tid? Skriv via Få hjelp i appen og legg til e-posten din, så jeg kan svare{end}',
    ],
    tg: '.', email: ', eller svar på denne e-posten.',
  },
  nl: {
    locale: 'nl',
    paragraphs: [
      'Je bent een van de eerste 20 op de ZigDash Chat-lijst, dus hier is je oprichterscode: {code}. Die geeft één huis 3 maanden bediening op afstand en Chat, gratis, vanaf de dag dat je hem invoert.',
      "Je hebt ZigDash 3.7 of nieuwer uit Google Play nodig, een huis dat met zijn MQTT-broker verbonden is, en ZigDash Engine op je hub. Open Instellingen › Huis › Bediening op afstand, tik op 'Heb je een oprichterscode?' en voer hem uiterlijk {date} in.",
      'Vragen of meer tijd nodig? Schrijf via Hulp krijgen in de app en vul je e-mailadres in, zodat ik kan antwoorden{end}',
    ],
    tg: '.', email: ', of beantwoord deze e-mail.',
  },
  pl: {
    locale: 'pl',
    paragraphs: [
      'Jesteś wśród pierwszych 20 osób na liście ZigDash Chat, więc oto Twój kod założyciela: {code}. Daje jednemu domowi sterowanie zdalne i Chat na 3 miesiące, za darmo, od dnia, w którym go wpiszesz.',
      'Potrzebujesz ZigDash 3.7 lub nowszego z Google Play, domu połączonego z jego brokerem MQTT oraz ZigDash Engine na hubie. Otwórz Ustawienia › Dom › Sterowanie zdalne, stuknij „Masz kod założyciela?” i wpisz go do {date}.',
      'Masz pytania albo potrzebujesz więcej czasu? Napisz przez Uzyskaj pomoc w aplikacji i podaj swój e-mail, żebym mógł odpowiedzieć{end}',
    ],
    tg: '.', email: ' albo odpowiedz na tego e-maila.',
  },
  pt: {
    locale: 'pt-BR',
    paragraphs: [
      'Você está entre os 20 primeiros da lista do ZigDash Chat, então aqui está seu código de fundador: {code}. Ele dá a uma casa controle remoto e Chat por 3 meses, grátis, a partir do dia em que você o inserir.',
      'Você precisa do ZigDash 3.7 ou mais recente do Google Play, de uma casa conectada ao seu broker MQTT e do ZigDash Engine no seu hub. Abra Configurações › Casa › Controle remoto, toque em "Tem um código de fundador?" e insira-o até {date}.',
      'Dúvidas ou precisa de mais tempo? Escreva pelo Obter ajuda no app e informe seu e-mail para que eu possa responder{end}',
    ],
    tg: '.', email: ', ou responda a este e-mail.',
  },
  ru: {
    locale: 'ru',
    paragraphs: [
      'Вы среди первых 20 в списке ZigDash Chat, поэтому вот ваш код основателя: {code}. Он даёт одному дому удалённое управление и Chat на 3 месяца, бесплатно, со дня, когда вы его введёте.',
      'Нужны ZigDash 3.7 или новее из Google Play, дом, подключённый к своему MQTT-брокеру, и ZigDash Engine на хабе. Откройте Настройки › Дом › Удалённое управление, нажмите «Есть код основателя?» и до {date} введите его.',
      'Есть вопросы или нужно больше времени? Напишите через «Получить помощь» в приложении и укажите свой e-mail, чтобы я мог ответить{end}',
    ],
    tg: '.', email: ', или ответьте на это письмо.',
  },
  sv: {
    locale: 'sv',
    paragraphs: [
      'Du är en av de 20 första på ZigDash Chat-listan, så här är din grundarkod: {code}. Den ger ett hem fjärrstyrning och Chat i 3 månader, gratis, från dagen du anger den.',
      'Du behöver ZigDash 3.7 eller senare från Google Play, ett hem anslutet till sin MQTT-broker och ZigDash Engine på din hubb. Öppna Inställningar › Hem › Fjärrstyrning, tryck på ”Har du en grundarkod?” och ange den senast {date}.',
      'Frågor, eller behöver du mer tid? Skriv via Få hjälp i appen och ange din e-post så att jag kan svara{end}',
    ],
    tg: '.', email: ', eller svara på det här mejlet.',
  },
};

/// A YYYY-MM-DD day as the language writes it ("15 January 2027"); the day
/// itself if the runtime can't.
function formatDay(day, lang) {
  try {
    const locale = (INVITE_TEXT[lang] ?? INVITE_TEXT.en).locale;
    return new Intl.DateTimeFormat(locale, { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' })
      .format(new Date(`${day}T00:00:00Z`));
  } catch {
    return day;
  }
}

/// The invite's text for one channel ('tg' or 'email').
function inviteText(lang, code, redeemBy, channel) {
  const t = INVITE_TEXT[lang] ?? INVITE_TEXT.en;
  const fill = { code, date: formatDay(redeemBy, lang), end: t[channel] };
  return t.paragraphs.map((p) => p.replace(/\{(code|date|end)\}/g, (_, k) => fill[k])).join('\n\n');
}

/// The invite email: no BCC (the owner gets nothing back but the counts);
/// a reply goes to the support inbox, as with answers.
function inviteEmail(to, lang, code, redeemBy) {
  return {
    from: SUPPORT_FROM,
    to: [to],
    reply_to: SUPPORT_INBOX,
    subject: INVITE_SUBJECT,
    text: inviteText(lang, code, redeemBy, 'email'),
  };
}

function realDay(s) {
  if (typeof s !== 'string' || !DAY_RE.test(s)) return false;
  const d = new Date(`${s}T00:00:00Z`);
  return !Number.isNaN(d.getTime()) && d.toISOString().slice(0, 10) === s;
}

async function earlyInvite(request, env) {
  if (!env.EARLY_ADMIN_SECRET || !sameSecret(request.headers.get('X-ZigDash-Admin'), env.EARLY_ADMIN_SECRET)) {
    return text(401, 'no');
  }
  const body = await readJson(request, 16 * 1024);
  if (!body) return text(400, 'bad body');
  const dryRun = body.dry_run === true;
  const codes = body.codes;
  const redeemBy = body.redeem_by;
  if (!dryRun) {
    if (!Array.isArray(codes) || !codes.length || !codes.every((c) => typeof c === 'string' && CODE_RE.test(c)) ||
        new Set(codes).size !== codes.length) {
      return text(400, 'bad codes');
    }
    if (!realDay(redeemBy) || redeemBy < new Date().toISOString().slice(0, 10)) return text(400, 'bad redeem_by');
  }

  let eligible;
  try {
    eligible = await inviteEligible(env);
  } catch {
    return text(503, 'list failed');
  }
  if (dryRun) return json(200, { eligible: eligible.length });
  if (codes.length < eligible.length) return json(409, { error: 'too_few_codes', eligible: eligible.length });

  const today = new Date().toISOString().slice(0, 10);
  let sent = 0;
  const failed = [];
  for (const [i, e] of eligible.entries()) {
    const why = await inviteSend(env, e, codes[i], redeemBy);
    if (why) {
      failed.push({ position: e.position, why });
      continue;
    }
    sent++;
    if (!(await markInvited(env, e, today))) failed.push({ position: e.position, why: 'sent, not recorded' });
  }
  return json(200, { sent, failed, unused: codes.length - eligible.length });
}

/// Every entry to invite, by position (a duplicated position in key order).
/// `expiration` is the entry's own, from the listing, so marking it invited
/// keeps its remaining time rather than starting a new 180 days.
async function inviteEligible(env) {
  const out = [];
  for (const prefix of INVITE_PREFIXES) {
    let cursor;
    do {
      const page = await env.EARLY.list({ prefix, ...(cursor ? { cursor } : {}) });
      for (const k of page.keys ?? []) {
        const entry = await env.EARLY.get(k.name, 'json');
        if (!entry || typeof entry !== 'object' || entry.invited) continue;
        const position = Number(entry.position);
        if (!Number.isInteger(position) || position < 1 || position > EARLY_FREE) continue;
        const created = Math.floor(Date.parse(entry.at) / 1000);
        const expiration = Number(k.expiration) ||
          (Number.isFinite(created) ? created + EARLY_TTL : Math.floor(Date.now() / 1000) + EARLY_TTL);
        out.push({
          key: k.name,
          channel: prefix === 'early:tg:' ? 'tg' : 'email',
          to: k.name.slice(prefix.length),
          position,
          lang: LOCALES.has(entry.lang) ? entry.lang : 'en',
          expiration,
        });
      }
      cursor = page.list_complete ? undefined : page.cursor;
    } while (cursor);
  }
  return out.sort((a, b) => a.position - b.position || (a.key < b.key ? -1 : a.key > b.key ? 1 : 0));
}

/// Sends one invite: null when the channel accepted it, else why not (no
/// address, no code: this goes back to the owner).
async function inviteSend(env, e, code, redeemBy) {
  if (e.channel === 'tg') {
    if (!/^-?\d{1,20}$/.test(e.to)) return 'bad chat id';
    if (!env.ASSISTANT_BOT_TOKEN) return 'no bot token';
    const r = await tgCall(env.ASSISTANT_BOT_TOKEN, 'sendMessage', {
      chat_id: e.to,
      text: inviteText(e.lang, code, redeemBy, 'tg'),
      disable_web_page_preview: true,
    });
    if (r.ok) return null;
    return `telegram ${r.timeout ? 'timeout' : r.status || 'unreachable'}`;
  }
  const to = cleanEmail(e.to);
  if (!to) return 'bad address';
  if (!env.RESEND_API_KEY) return 'no resend key';
  const key = `invite-${e.position}-${(await hmacHex(env.EARLY_ADMIN_SECRET, code)).slice(0, 12)}`;
  const r = await resendPost(env, inviteEmail(to, e.lang, code, redeemBy), key);
  if (r.ok) return null;
  return `resend ${r.status || 'unreachable'}${r.name ? ` ${r.name}` : ''}`;
}

/// Records the invite date on the entry, keeping its remaining time. An
/// entry deleted since (/stop) is not brought back.
async function markInvited(env, e, day) {
  try {
    const entry = await env.EARLY.get(e.key, 'json');
    if (!entry) return false;
    const expiration = Math.max(e.expiration, Math.floor(Date.now() / 1000) + 60);
    await env.EARLY.put(e.key, JSON.stringify({ ...entry, invited: day }), { expiration });
    return true;
  } catch {
    return false;
  }
}
