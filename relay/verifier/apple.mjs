// App Store purchases of Pro (docs/design/ios.md §3).
//
// The iOS app sends StoreKit 2's signed transaction (a JWS). It is checked
// offline: the x5c chain must end in Apple Root CA - G3 (pinned by its
// SHA-256 fingerprint), each certificate must be signed by the next and in
// date, the intermediate and leaf must carry Apple's App Store receipt
// signing OIDs, and the leaf must have signed the JWS. Then the payload must
// be ZigDash's bundle, the Pro product, and not revoked.

import crypto from 'node:crypto';

/** SHA-256 of Apple Root CA - G3 (apple.com/certificateauthority). */
export const APPLE_ROOT_G3 =
  '63343ABFB89A6A03EBB57E9B3F5FA7BE7C4F5C756F3017B3A8C488C3653E9179';

// DER of the OIDs Apple documents for the chain: the WWDR intermediate
// (1.2.840.113635.100.6.2.1) and the App Store signing leaf (…100.6.11.1).
const oid = (s) => {
  const [a, b, ...rest] = s.split('.').map(Number);
  const out = [40 * a + b];
  for (const n of rest) {
    const bytes = [n & 0x7f];
    for (let v = n >> 7; v > 0; v >>= 7) bytes.unshift((v & 0x7f) | 0x80);
    out.push(...bytes);
  }
  return Buffer.from([0x06, out.length, ...out]);
};
const INTERMEDIATE_OID = oid('1.2.840.113635.100.6.2.1');
const LEAF_OID = oid('1.2.840.113635.100.6.11.1');

const b64url = (s) => Buffer.from(s, 'base64url');

/**
 * The verified transaction in [jws], or null when it isn't a genuine,
 * unrevoked purchase of [product] for [bundleId].
 *
 * [environments] lists the accepted StoreKit environments ('Production',
 * 'Sandbox'); [rootFingerprint] is replaceable for tests only.
 */
export function verifyAppleTransaction(jws, {
  bundleId, product, environments = ['Production'],
  rootFingerprint = APPLE_ROOT_G3, now = new Date(),
}) {
  try {
    const [h, p, s] = jws.split('.');
    if (!h || !p || !s) return null;
    const header = JSON.parse(b64url(h).toString());
    if (header.alg !== 'ES256' || !Array.isArray(header.x5c) || header.x5c.length !== 3) return null;
    const [leaf, intermediate, root] = header.x5c.map((c) => new crypto.X509Certificate(Buffer.from(c, 'base64')));

    const fingerprint = root.fingerprint256.replaceAll(':', '');
    if (fingerprint !== rootFingerprint.toUpperCase()) return null;
    if (!root.verify(root.publicKey)) return null;
    if (!intermediate.verify(root.publicKey) || !leaf.verify(intermediate.publicKey)) return null;
    for (const c of [leaf, intermediate, root]) {
      if (now < new Date(c.validFrom) || now > new Date(c.validTo)) return null;
    }
    if (!intermediate.raw.includes(INTERMEDIATE_OID) || !leaf.raw.includes(LEAF_OID)) return null;

    const signed = crypto.verify(
      'sha256', Buffer.from(`${h}.${p}`),
      { key: leaf.publicKey, dsaEncoding: 'ieee-p1363' }, b64url(s),
    );
    if (!signed) return null;

    const t = JSON.parse(b64url(p).toString());
    if (t.bundleId !== bundleId || t.productId !== product) return null;
    if (t.revocationDate || !environments.includes(t.environment)) return null;
    if (typeof t.originalTransactionId !== 'string' || !t.originalTransactionId) return null;
    return t;
  } catch {
    return null;
  }
}
