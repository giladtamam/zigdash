// Chat tickets, checked here exactly as relay/verifier/ticket.mjs signs them
// (a test checks the two agree). A ticket proves that a phone of a Home with a
// valid Pro purchase asked for it in the last 10 minutes.
//
//   ticket = base64url(JSON payload) "." base64url(HMAC-SHA256(secret, first part))
//   payload = {v:1, home_id, client_id, request_topic, answer_topic, iat, exp}  (times in seconds)

import crypto from 'node:crypto';

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
