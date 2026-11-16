// Founders' pass pieces that need no broker (docs/design/founders-pass.md):
// codes and their normalisation, rate keys, the CLI's parsing, and opening a
// database from before the pass.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { CROCKFORD, codeHash, newCode, normaliseCode, rateKey } from '../passes.mjs';
import { commandOf, endOfDay } from '../cli.mjs';
import { createVerifier } from '../server.mjs';

test('codes: ZD-XXXX-XXXX-XX in Crockford base32, all different', () => {
  const codes = new Set(Array.from({ length: 2000 }, newCode));
  assert.equal(codes.size, 2000);
  for (const c of codes) assert.match(c, /^ZD-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{2}$/);
  assert.equal(CROCKFORD.length, 32);
  assert.doesNotMatch(CROCKFORD, /[ILOU]/);
  // Every character shows up: the 50 bits are spread over all ten places.
  const seen = new Set([...codes].join('').replace(/ZD|-/g, ''));
  assert.equal(seen.size, 32);
});

test('normalisation: case, spaces and dashes ignored; I and L read as 1, O as 0', () => {
  assert.equal(normaliseCode(' zd-1abc-0def-g9 '), 'ZD1ABC0DEFG9');
  assert.equal(normaliseCode('ZD-IABC-ODEF-L9'), 'ZD1ABC0DEF19');
  const secret = 'k';
  const h = codeHash(secret, 'ZD-1ABC-0DEF-19');
  assert.match(h, /^[0-9a-f]{64}$/);
  for (const typed of ['zd-1abc-0def-19', 'ZD 1ABC 0DEF 19', 'zd1abc0def19', 'ZD-IABC-ODEF-L9', 'zd-labc-odef-i9']) assert.equal(codeHash(secret, typed), h, typed);
  assert.notEqual(codeHash('another key', 'ZD-1ABC-0DEF-19'), h, 'keyed: the hash depends on PASS_SECRET');
  for (const bad of ['', 'ZD-1ABC-0DEF-1', 'ZD-1ABC-0DEF-199', 'XX-1ABC-0DEF-19', 'ZD-UABC-0DEF-19', null]) assert.equal(codeHash(secret, bad), null, String(bad));
});

test('rate keys: IPv4 as it is, IPv6 by its /64, IPv4-mapped as IPv4', () => {
  assert.equal(rateKey('203.0.113.9'), '203.0.113.9');
  assert.equal(rateKey('::ffff:203.0.113.9'), '203.0.113.9');
  const k = rateKey('2001:db8:aa:bb::1');
  assert.equal(k, '2001:db8:aa:bb::/64');
  assert.equal(rateKey('2001:0db8:00aa:00bb:ffff:1:2:3'), k);
  assert.equal(rateKey('2001:DB8:AA:BB:1::'), k);
  assert.equal(rateKey('2001:db8:aa:bb::1%eth0'), k);
  assert.notEqual(rateKey('2001:db8:aa:bc::1'), k);
  assert.equal(rateKey('::1'), '0:0:0:0::/64');
  assert.equal(rateKey('2001:db8::'), '2001:db8:0:0::/64');
  assert.equal(rateKey('64:ff9b::1.2.3.4'), '64:ff9b:0:0::/64');
});

test('cli: commands and dates', () => {
  assert.deepEqual(commandOf(['passes', 'new', '--count', '3', '--redeem-by', '2027-01-31']),
    { op: 'passes new', args: { count: 3, days: undefined, redeem_by: Date.UTC(2027, 1, 1) - 1 } });
  assert.deepEqual(commandOf(['passes', 'extend', 'abcdef12', '--days=0']), { op: 'passes extend', args: { pass: 'abcdef12', redeem_by: undefined, days: '0' } });
  assert.deepEqual(commandOf(['homes', 'delete', '0123456789abcdef']), { op: 'homes delete', args: { home: '0123456789abcdef' } });
  assert.throws(() => commandOf(['passes', 'revoke']), /usage/);
  assert.throws(() => commandOf(['passes', 'burn']), /usage/);
  assert.throws(() => endOfDay('2027-02-30'), /not a date/);
  assert.equal(new Date(endOfDay('2027-02-28')).toISOString(), '2027-02-28T23:59:59.999Z');
});

test('a database from before the founders\' pass opens, keeps its Homes and gains the new columns', async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'zd-old-db-'));
  const file = path.join(dir, 'verifier.db');
  const old = new DatabaseSync(file);
  old.exec(`
    create table homes (id text primary key, token_hash text unique, created integer);
    create table phones (username text primary key, home text, pw_hash text, created integer);
    insert into homes values ('00112233445566aa', 'hash-of-a-purchase', 1700000000000);
    insert into phones values ('phone-00112233445566aa-abcdef', '00112233445566aa', 'x:y', 1700000000000);
  `);
  old.close();
  for (let i = 0; i < 2; i++) { // twice: the migration runs once and then finds its columns
    const v = createVerifier({ DB: file, VERIFY: 'fake' });
    const cols = v.db.prepare('pragma table_info(homes)').all().map((c) => c.name);
    assert.deepEqual(cols, ['id', 'token_hash', 'created', 'kind', 'expires_at', 'disabled_at']);
    const row = v.db.prepare('select * from homes').get();
    assert.deepEqual({ ...row }, { id: '00112233445566aa', token_hash: 'hash-of-a-purchase', created: 1700000000000, kind: null, expires_at: null, disabled_at: null });
    assert.equal(v.entitled('00112233445566aa'), true, 'a purchase Home stays entitled');
    for (const t of ['passes', 'chat_acls', 'tombstones']) assert.ok(v.db.prepare('select name from sqlite_master where name = ?').get(t), t);
    assert.equal(v.db.prepare('select count(*) as n from phones').get().n, 1);
    await v.stop();
  }
});
