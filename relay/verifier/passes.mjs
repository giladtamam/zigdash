// Founders' pass codes (docs/design/founders-pass.md, "Codes"): ZD-XXXX-XXXX-XX,
// 50 random bits in Crockford base32 (no I, L, O, U). The verifier keeps only
// HMAC-SHA256(PASS_SECRET, normalised code), never the code itself.
//
// Normalised: upper case; spaces and dashes removed; I and L read as 1, O as 0
// (what a person types for a code read aloud or from a screen).

import crypto from 'node:crypto';
import net from 'node:net';

export const CROCKFORD = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
const NORMAL = /^ZD[0-9A-HJKMNP-TV-Z]{10}$/;

/** A new code, ZD- and ten Crockford characters (50 random bits) in groups of four, four and two. */
export function newCode() {
  let n = BigInt(`0x${crypto.randomBytes(7).toString('hex')}`) & ((1n << 50n) - 1n);
  let s = '';
  for (let i = 0; i < 10; i++) { s = CROCKFORD[Number(n & 31n)] + s; n >>= 5n; }
  return `ZD-${s.slice(0, 4)}-${s.slice(4, 8)}-${s.slice(8)}`;
}

export function normaliseCode(code) {
  return String(code ?? '').toUpperCase().replace(/[\s-]/g, '').replace(/[IL]/g, '1').replace(/O/g, '0');
}

/** The code's keyed hash (hex), or null when it can't be a code at all. */
export function codeHash(secret, code) {
  const normal = normaliseCode(code);
  if (!NORMAL.test(normal)) return null;
  return crypto.createHmac('sha256', secret).update(normal).digest('hex');
}

/**
 * The key an address is rate-limited under: an IPv4 address as it is, an IPv6
 * address by its /64 (one household or one server gets a whole /64, so
 * counting single IPv6 addresses would limit nothing).
 */
export function rateKey(address) {
  let a = String(address || '').trim().split('%')[0];
  const mapped = /^::ffff:(\d+\.\d+\.\d+\.\d+)$/i.exec(a);
  if (mapped) return mapped[1];
  if (!net.isIPv6(a)) return a;
  // An embedded IPv4 tail (64:ff9b::1.2.3.4) is two groups; only the first four groups count.
  a = a.replace(/(\d+)\.(\d+)\.(\d+)\.(\d+)$/, (_m, p, q, r, s) => `${((p << 8) | q).toString(16)}:${((r << 8) | s).toString(16)}`);
  const [head, tail] = a.split('::');
  const h = head ? head.split(':') : [];
  const t = tail ? tail.split(':') : [];
  const groups = tail === undefined ? h : [...h, ...Array(8 - h.length - t.length).fill('0'), ...t];
  return `${groups.slice(0, 4).map((g) => parseInt(g, 16).toString(16)).join(':')}::/64`;
}
