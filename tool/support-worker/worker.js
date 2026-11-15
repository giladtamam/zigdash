// ZigDash support receiver (docs/design/help-and-review-2026-11.md §2) and
// the "Chat with your home" early-access list
// (docs/design/assistant-early-access.md §4–5).
//
// A Cloudflare Worker: the app POSTs a support message here, and it is
// forwarded to the developer's private Telegram chat through the ZigDash
// bot. Support messages are not stored and the body is never logged.
// Early-access entries are stored (KV EARLY, 180 days) and only used to
// invite people to the beta.
//
// Secrets (set in the Worker's settings, never in this file):
//   TELEGRAM_BOT_TOKEN        the support bot's token (@zigdash_bot)
//   TELEGRAM_CHAT_ID          the developer's private chat with that bot
//   ASSISTANT_BOT_TOKEN       @ZigDashHomeBot, the chat-with-your-home bot
//   ASSISTANT_WEBHOOK_SECRET  path part and header secret of its webhook
//   CHAT_SERVICE_SECRET       ZigDash Chat (tool/zigdash-chat, WORKER_SECRET_FILE there):
//                             its header secret for /v1/early/tg and /v1/early/linked, and
//                             the HMAC key of the linked chat ids
// Bindings:
//   RATE                a KV namespace for the per-address and daily counters
//   EARLY               a KV namespace for the early-access list
//
// ZigDash Chat (docs/design/chat-linking.md §2): once @ZigDashHomeBot's webhook
// points at zigdash-chat, that service passes the early-access updates here
// (POST /v1/early/tg, the same handling as the webhook below) and keeps the
// list of linked chats (POST /v1/early/linked, HMACs only, KV EARLY
// "chat:linked"). If the webhook is rolled back to this Worker, a linked chat
// gets "Chat is paused for maintenance" instead of the early-access reply.
//
// Answers: 200 sent, 400 bad body, 413 too large, 405 wrong method,
// 503 over a limit or Telegram unreachable (the app then offers Share).
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
    if (env.ASSISTANT_WEBHOOK_SECRET &&
        url.pathname === `/v1/tg/${env.ASSISTANT_WEBHOOK_SECRET}`) {
      return botUpdate(request, env);
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

    const lines = [
      `ZigDash ${body.kind === 'ai_report' ? 'AI report' : 'support'}, ${String(body.app ?? '?')}+${String(body.build ?? '?')}, ${String(body.locale ?? '?')}`,
      body.email ? `From: ${String(body.email).trim()}` : 'From: (no email)',
      '',
      message,
      '',
      '— Support details —',
      String(body.details ?? ''),
    ];
    const sent = await telegram(env, clip(lines.join('\n'), TELEGRAM_MAX));
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
  try {
    const r = await fetch(`https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        chat_id: env.TELEGRAM_CHAT_ID,
        text: textBody,
        disable_web_page_preview: true,
      }),
      signal: AbortSignal.timeout(6000),
    });
    return r.ok;
  } catch {
    return false;
  }
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
  await telegram(env, `Chat early access: #${e.position}, ${e.via}, ${e.counted ? 'counted' : 'not counted'}, ${e.lang}`);
}

function placeLine(position) {
  return position <= EARLY_FREE
    ? `You're #${position} on the list: one of the first ${EARLY_FREE}. If we build it, you get it free for 3 months, remote access included.`
    : `You're #${position} on the list. The first ${EARLY_FREE} places are taken; you'll hear first when it's ready.`;
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
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(env.CHAT_SERVICE_SECRET), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(String(chatId))));
  const hex = [...mac].map((b) => b.toString(16).padStart(2, '0')).join('').slice(0, 32);
  return ids.includes(hex);
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
  if (entry) {
    return botSend(env, chat, `Chat with your home isn't ready yet. ${placeLine(entry.position)} Send /stop to leave the list.`);
  }
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
