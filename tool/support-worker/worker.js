// ZigDash support receiver (docs/design/help-and-review-2026-11.md §2).
//
// A Cloudflare Worker: the app POSTs a support message here, and it is
// forwarded to the developer's private Telegram chat through the ZigDash
// bot. Nothing is stored and the body is never logged.
//
// Secrets (set in the Worker's settings, never in this file):
//   TELEGRAM_BOT_TOKEN  the bot's token
//   TELEGRAM_CHAT_ID    the developer's private chat with the bot
// Bindings:
//   RATE                a KV namespace for the per-address and daily counters
//
// Answers: 200 sent, 400 bad body, 413 too large, 405 wrong method,
// 503 over a limit or Telegram unreachable (the app then offers Share).

const MAX_BODY = 8 * 1024;
const PER_HOUR = 5;
const PER_DAY_ALL = 200;
const TELEGRAM_MAX = 4096;

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return cors(new Response(null, { status: 204 }));
    if (request.method !== 'POST') return cors(text(405, 'POST only'));
    const url = new URL(request.url);
    if (url.pathname !== '/v1/message') return cors(text(404, 'not here'));

    const length = Number(request.headers.get('content-length') || 0);
    if (length > MAX_BODY) return cors(text(413, 'too large'));
    const raw = await request.text();
    if (raw.length > MAX_BODY) return cors(text(413, 'too large'));

    let body;
    try {
      body = JSON.parse(raw);
    } catch {
      return cors(text(400, 'bad json'));
    }
    const message = String(body.text ?? '').trim();
    if (!message) return cors(text(400, 'text required'));

    const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
    if (!(await allow(env, ip))) return cors(text(503, 'over limit'));

    const lines = [
      `ZigDash support, ${String(body.app ?? '?')}+${String(body.build ?? '?')}, ${String(body.locale ?? '?')}`,
      body.email ? `From: ${String(body.email).trim()}` : 'From: (no email)',
      '',
      message,
      '',
      '— Support details —',
      String(body.details ?? ''),
    ];
    const sent = await telegram(env, clip(lines.join('\n'), TELEGRAM_MAX));
    return cors(sent ? text(200, 'sent') : text(503, 'not sent'));
  },
};

function text(status, s) {
  return new Response(s, { status, headers: { 'content-type': 'text/plain; charset=utf-8' } });
}

function cors(response) {
  response.headers.set('access-control-allow-origin', '*');
  response.headers.set('access-control-allow-methods', 'POST, OPTIONS');
  response.headers.set('access-control-allow-headers', 'content-type');
  return response;
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
async function allow(env, ip) {
  try {
    const hour = Math.floor(Date.now() / 3_600_000);
    const day = Math.floor(Date.now() / 86_400_000);
    const ipKey = `ip:${hash(ip)}:${hour}`;
    const dayKey = `day:${day}`;
    const [ipCount, dayCount] = await Promise.all([
      env.RATE.get(ipKey),
      env.RATE.get(dayKey),
    ]);
    const perIp = Number(ipCount || 0);
    const perDay = Number(dayCount || 0);
    if (perIp >= PER_HOUR || perDay >= PER_DAY_ALL) return false;
    await Promise.all([
      env.RATE.put(ipKey, String(perIp + 1), { expirationTtl: 3600 }),
      env.RATE.put(dayKey, String(perDay + 1), { expirationTtl: 86400 }),
    ]);
    return true;
  } catch {
    return true;
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
