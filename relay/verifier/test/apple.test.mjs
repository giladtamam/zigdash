// The App Store transaction check, against a test chain shaped like Apple's
// (test/apple: a root, an intermediate and a leaf with Apple's OIDs).
import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import { verifyAppleTransaction, APPLE_ROOT_G3 } from '../apple.mjs';

const dir = new URL('./apple/', import.meta.url);
const pem = (n) => fs.readFileSync(new URL(n, dir), 'utf8');
const der = (n) => new crypto.X509Certificate(pem(n)).raw.toString('base64');
const leafKey = crypto.createPrivateKey(pem('leaf.key'));
const rootFingerprint = new crypto.X509Certificate(pem('root.pem')).fingerprint256.replaceAll(':', '');
const opts = { bundleId: 'com.giladtamam.zigdash', product: 'zigdash_pro', rootFingerprint };

const enc = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
function sign(payload, { x5c = [der('leaf.pem'), der('int.pem'), der('root.pem')], key = leafKey } = {}) {
  const unsigned = `${enc({ alg: 'ES256', x5c })}.${enc(payload)}`;
  const sig = crypto.sign('sha256', Buffer.from(unsigned), { key, dsaEncoding: 'ieee-p1363' });
  return `${unsigned}.${sig.toString('base64url')}`;
}
const pro = {
  bundleId: 'com.giladtamam.zigdash', productId: 'zigdash_pro', environment: 'Production',
  transactionId: '2000000123', originalTransactionId: '2000000100',
};

test('a genuine Pro purchase passes and names its original transaction', () => {
  assert.equal(verifyAppleTransaction(sign(pro), opts)?.originalTransactionId, '2000000100');
});

test('the real Apple root is pinned by default, so the test chain fails without the override', () => {
  assert.notEqual(rootFingerprint, APPLE_ROOT_G3);
  assert.equal(verifyAppleTransaction(sign(pro), { ...opts, rootFingerprint: undefined }), null);
});

test('another app, another product, a refund or a sandbox purchase is refused', () => {
  assert.equal(verifyAppleTransaction(sign({ ...pro, bundleId: 'com.other.app' }), opts), null);
  assert.equal(verifyAppleTransaction(sign({ ...pro, productId: 'tip' }), opts), null);
  assert.equal(verifyAppleTransaction(sign({ ...pro, revocationDate: 1761300000000 }), opts), null);
  assert.equal(verifyAppleTransaction(sign({ ...pro, environment: 'Sandbox' }), opts), null);
});

test('sandbox passes when the relay allows it (TestFlight)', () => {
  const t = verifyAppleTransaction(sign({ ...pro, environment: 'Sandbox' }), { ...opts, environments: ['Production', 'Sandbox'] });
  assert.equal(t?.environment, 'Sandbox');
});

test('a tampered payload, a foreign key or a broken chain is refused', () => {
  const [h, , s] = sign(pro).split('.');
  assert.equal(verifyAppleTransaction(`${h}.${enc({ ...pro, productId: 'zigdash_pro' , bundleId: 'x' })}.${s}`, opts), null);
  const stranger = crypto.generateKeyPairSync('ec', { namedCurve: 'P-256' }).privateKey;
  assert.equal(verifyAppleTransaction(sign(pro, { key: stranger }), opts), null);
  assert.equal(verifyAppleTransaction(sign(pro, { x5c: [der('leaf.pem'), der('leaf.pem'), der('root.pem')] }), opts), null);
  assert.equal(verifyAppleTransaction(sign(pro, { x5c: [der('int.pem'), der('int.pem'), der('root.pem')] }), opts), null);
});

test('garbage is refused, not thrown', () => {
  for (const junk of ['', 'a.b', 'a.b.c', 'test-pro-AAA']) assert.equal(verifyAppleTransaction(junk, opts), null);
});
