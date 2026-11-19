// The site's link rules read the app's test vectors (ha-link.md).
// Run: env -u NODE_OPTIONS node --test tool/site_tests/
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const link = require('../../landing/assets/halink.js');

const root = path.join(__dirname, '..', '..');
const vectors = JSON.parse(
  fs.readFileSync(path.join(root, 'test/fixtures/ha_link_vectors.json'), 'utf8'),
);

for (const v of vectors) {
  test(`vector "${v.params}"`, () => {
    const got = link.fromParams(v.params);
    assert.deepStrictEqual(got.addresses, v.addresses);
    assert.strictEqual(got.src, v.src);
  });
}

test('a link made here reads back the same', () => {
  const made = link.toParams(['http://192.168.1.20:8123'], 'site');
  assert.deepStrictEqual(link.fromParams(made), {
    addresses: ['http://192.168.1.20:8123'],
    src: 'site',
  });
});

test('a browser link with a path, a login and a query keeps only the address', () => {
  assert.strictEqual(
    link.cleanAddress('https://me:pw@home.example.com:8443/lovelace/0?edit=1'),
    'https://home.example.com:8443',
  );
});
