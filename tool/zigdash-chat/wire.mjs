// The Chat wire format, matching hub/src/chat.js: AES-256-GCM seals
// (iv(12) | ciphertext | tag(16), base64 on the wire), opaque relay ids
// (HMAC-SHA256 of the real topic with the client key), and the topics.

import crypto from 'node:crypto';

export function seal(key, obj) {
  const iv = crypto.randomBytes(12);
  const c = crypto.createCipheriv('aes-256-gcm', key, iv);
  const body = Buffer.concat([c.update(Buffer.from(JSON.stringify(obj))), c.final()]);
  return Buffer.concat([iv, body, c.getAuthTag()]).toString('base64');
}

/** The object inside a base64 seal, or null when it was not sealed with [key]. */
export function unseal(key, text) {
  try {
    const b = Buffer.from(String(text), 'base64');
    if (b.length < 29) return null;
    const d = crypto.createDecipheriv('aes-256-gcm', key, b.subarray(0, 12));
    d.setAuthTag(b.subarray(b.length - 16));
    return JSON.parse(Buffer.concat([d.update(b.subarray(12, b.length - 16)), d.final()]).toString());
  } catch {
    return null;
  }
}

export const opaqueId = (key, topic) => crypto.createHmac('sha256', key).update(topic).digest('hex').slice(0, 24);
export const sha256 = (text) => crypto.createHash('sha256').update(String(text)).digest('hex');
export const newRequestId = () => crypto.randomBytes(12).toString('base64url');

/**
 * Where a client's requests and the Engine's answers travel: plain topics on
 * the home broker, or opaque ids under homes/<home>/x/ on the relay.
 */
export function chatTopics({ transport, clientId, key, homeId }) {
  const req = `zigdash/chat/req/${clientId}`;
  const res = `zigdash/chat/res/${clientId}`;
  if (transport !== 'relay') return { req, res };
  if (!homeId) throw new Error('the relay needs the home id');
  return { req: `homes/${homeId}/x/${opaqueId(key, req)}`, res: `homes/${homeId}/x/${opaqueId(key, res)}` };
}

export const CLIENT_ID_RE = /^[A-Za-z0-9_-]{1,40}$/;
