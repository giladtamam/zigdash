// Chat tickets (docs/design/chat-linking.md §2): what a phone of a Home gets
// from the verifier after a live Pro check, and hands to the chat service to
// link or unlink a Telegram chat. Signed with HMAC-SHA256 under a secret only
// the verifier and the chat service hold; a ticket opens nothing on the broker
// by itself. tool/zigdash-chat/ticket.mjs checks it the same way.
//
//   ticket = base64url(JSON payload) "." base64url(HMAC-SHA256(secret, first part))
//   payload = {v:1, home_id, client_id, request_topic, answer_topic, iat, exp}  (times in seconds)

import crypto from 'node:crypto';

export const TICKET_SECONDS = 600;

export function signTicket(secret, fields, now = Date.now()) {
  const iat = Math.floor(now / 1000);
  const payload = { v: 1, ...fields, iat, exp: iat + TICKET_SECONDS };
  const body = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const mac = crypto.createHmac('sha256', secret).update(body).digest('base64url');
  return { ticket: `${body}.${mac}`, payload };
}

/** The payload of a valid, unexpired ticket, or {error: 'bad_ticket' | 'ticket_expired'}. */
export function verifyTicket(secret, ticket, now = Date.now()) {
  if (typeof ticket !== 'string' || ticket.length > 4096) return { error: 'bad_ticket' };
  const [body, mac, extra] = ticket.split('.');
  if (!body || !mac || extra !== undefined) return { error: 'bad_ticket' };
  const want = crypto.createHmac('sha256', secret).update(body).digest();
  const got = Buffer.from(mac, 'base64url');
  if (got.length !== want.length || !crypto.timingSafeEqual(got, want)) return { error: 'bad_ticket' };
  let payload;
  try { payload = JSON.parse(Buffer.from(body, 'base64url').toString()); } catch { return { error: 'bad_ticket' }; }
  if (!payload || payload.v !== 1 || typeof payload.home_id !== 'string' || typeof payload.exp !== 'number') return { error: 'bad_ticket' };
  if (payload.exp * 1000 <= now) return { error: 'ticket_expired' };
  return { payload };
}
