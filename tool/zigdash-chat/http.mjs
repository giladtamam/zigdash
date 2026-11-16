// The service's HTTPS API (behind Caddy at https://chat.zigdash.app) and the
// live bot's webhook. JSON in and out, {error} on failure, no CORS (the caller
// is the app). A ticket comes in the X-Chat-Ticket header (or the body's
// "ticket", or Authorization: Bearer). Logs: counters only.
//
//   POST   /v1/link              {ticket, token, key, scope}  -> 200 {code, expires_in, bot, url}
//   POST   /v1/link/confirm      {ticket, code_back}          -> 200 {linked, client_id, telegram_name, scope}
//   GET    /v1/links             X-Chat-Ticket                -> 200 {links: [{client_id, telegram_name, scope, last_used, linked_at}]}
//   DELETE /v1/link/<client_id>  X-Chat-Ticket                -> 200 {removed: true}
//   POST   /v1/tg/<secret>       Telegram, with X-Telegram-Bot-Api-Secret-Token (webhook mode only)
//   GET    /v1/health                                         -> 200 {ok: true}
//
// The internal port (INTERNAL_PORT, 8791; makeInternalHttp): only the relay
// verifier, from the Docker network, with the chat-ACL secret. Never proxied:
// anything with forwarding headers is refused.
//   POST   /v1/internal/home-changed  {home_id}  X-Chat-Acl-Secret  -> 200 {ok: true}
//   POST   /v1/internal/home-deleted  {home_id}  X-Chat-Acl-Secret  -> 200 {ok: true} at once; links removed afterwards

import http from 'node:http';
import crypto from 'node:crypto';

const MAX_BODY = 16 * 1024;
const MAX_UPDATE = 256 * 1024;

const sameSecret = (a, b) => {
  const x = Buffer.from(String(a || '')), y = Buffer.from(String(b || ''));
  return x.length === y.length && x.length > 0 && crypto.timingSafeEqual(x, y);
};

function readBody(req, max) {
  return new Promise((resolve) => {
    let raw = '';
    let over = false;
    req.on('data', (c) => { if (over) return; raw += c; if (raw.length > max) { over = true; resolve({ tooLarge: true }); } });
    req.on('end', () => { if (over) return; try { resolve({ json: raw ? JSON.parse(raw) : {} }); } catch { resolve({ json: null }); } });
    req.on('error', () => resolve({ json: null }));
  });
}

/**
 * [chat]: from bot.mjs. [webhookSecret]: set in webhook mode (the path part
 * and the header Telegram sends back). Returns {listen(port, host), close()}.
 */
export function makeHttp({ chat, metrics, webhookSecret = null }) {
  const send = (res, status, body) => {
    res.writeHead(status, { 'content-type': 'application/json', 'cache-control': 'no-store' });
    res.end(JSON.stringify(body));
  };
  const ticketOf = (req, body) => {
    const auth = /^Bearer (.+)$/.exec(req.headers.authorization || '');
    return req.headers['x-chat-ticket'] || (auth && auth[1]) || (body && body.ticket) || '';
  };

  async function handle(req, res) {
    const url = new URL(req.url, 'http://x');
    const p = url.pathname;

    if (p.startsWith('/v1/tg/')) {
      if (!webhookSecret || req.method !== 'POST' || !sameSecret(p.slice('/v1/tg/'.length), webhookSecret) ||
          !sameSecret(req.headers['x-telegram-bot-api-secret-token'], webhookSecret)) {
        metrics.count('webhook_refused');
        return send(res, 401, { error: 'no' });
      }
      const { json } = await readBody(req, MAX_UPDATE);
      // 200 at once, or Telegram resends while a slow tool loop runs; the work goes on in the background.
      send(res, 200, { ok: true });
      if (json) setImmediate(() => { chat.onUpdate(json); });
      return undefined;
    }

    let out;
    if (req.method === 'GET' && p === '/v1/health') {
      out = { status: 200, body: { ok: true } };
    } else if (req.method === 'GET' && p === '/v1/links') {
      out = chat.listLinks(ticketOf(req, null));
    } else if (req.method === 'DELETE' && p.startsWith('/v1/link/') && p.split('/').length === 4) {
      const { json } = req.headers['content-length'] && req.headers['content-length'] !== '0' ? await readBody(req, MAX_BODY) : { json: {} };
      out = await chat.deleteLink(decodeURIComponent(p.split('/')[3]), ticketOf(req, json));
    } else if (req.method === 'POST' && (p === '/v1/link' || p === '/v1/link/confirm')) {
      const { json, tooLarge } = await readBody(req, MAX_BODY);
      if (tooLarge) out = { status: 413, body: { error: 'too_large' } };
      else if (!json || typeof json !== 'object') out = { status: 400, body: { error: 'bad_body' } };
      else {
        if (!json.ticket) json.ticket = ticketOf(req, json);
        out = p === '/v1/link' ? chat.createLink(json) : await chat.confirmLink(json);
      }
    } else {
      out = { status: 404, body: { error: 'not_found' } };
    }
    metrics.count('http', { status: out.status });
    return send(res, out.status, out.body);
  }

  const server = http.createServer((req, res) => {
    handle(req, res).catch(() => { metrics.count('http', { status: 500 }); send(res, 500, { error: 'failed' }); });
  });
  return {
    server,
    listen: (port, host) => new Promise((resolve) => server.listen(port, host, () => resolve(server.address().port))),
    close: () => new Promise((resolve) => { server.closeAllConnections?.(); server.close(() => resolve()); }),
  };
}

/**
 * The internal listener, as the verifier's own internal port: a request that
 * came through a proxy (Caddy adds forwarding headers) is refused, in case
 * this port is ever proxied by mistake; the rest needs [secret] (the chat-ACL
 * secret, the other direction). [chat]: homeChanged(id), homeDeleted(id).
 */
export function makeInternalHttp({ chat, metrics, secret }) {
  const send = (res, status, body) => {
    res.writeHead(status, { 'content-type': 'application/json', 'cache-control': 'no-store' });
    res.end(JSON.stringify(body));
  };
  const ROUTES = new Set(['/v1/internal/home-changed', '/v1/internal/home-deleted']);

  async function handle(req, res) {
    const p = new URL(req.url, 'http://x').pathname;
    if (req.method !== 'POST' || !ROUTES.has(p)) return send(res, 404, { error: 'not_found' });
    if (req.headers['x-forwarded-for'] || req.headers['x-forwarded-host'] || req.headers.forwarded || req.headers['x-real-ip']) {
      metrics.count('internal_refused', { proxied: 1 });
      return send(res, 403, { error: 'internal_only' });
    }
    if (!secret) return send(res, 503, { error: 'off' });
    if (!sameSecret(req.headers['x-chat-acl-secret'], secret)) {
      metrics.count('internal_refused', { proxied: 0 });
      return send(res, 401, { error: 'no' });
    }
    const { json, tooLarge } = await readBody(req, MAX_BODY);
    if (tooLarge) return send(res, 413, { error: 'too_large' });
    const homeId = json && typeof json.home_id === 'string' && /^[0-9a-f]{16}$/.test(json.home_id) ? json.home_id : null;
    if (!homeId) return send(res, 400, { error: 'bad_body' });
    if (p === '/v1/internal/home-changed') chat.homeChanged(homeId);
    else chat.homeDeleted(homeId); // in the background: the verifier's lock is released, the answer comes first
    return send(res, 200, { ok: true });
  }

  const server = http.createServer((req, res) => {
    handle(req, res).catch(() => { metrics.count('internal_http', { status: 500 }); send(res, 500, { error: 'failed' }); });
  });
  return {
    server,
    listen: (port, host) => new Promise((resolve, reject) => {
      server.once('error', reject);
      server.listen(port, host, () => { server.off('error', reject); resolve(server.address().port); });
    }),
    close: () => new Promise((resolve) => { server.closeAllConnections?.(); server.close(() => resolve()); }),
  };
}
