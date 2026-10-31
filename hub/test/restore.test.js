// node --test hub/test/restore.test.js
const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const zlib = require('zlib');
const Restore = require('../zigdash-restore.js');

/** A zip of {name: string|Buffer}, deflated when [deflate]. */
function zip(entries, deflate = true) {
  const locals = [];
  const centrals = [];
  let offset = 0;
  for (const [name, content] of Object.entries(entries)) {
    const data = Buffer.from(content);
    const body = deflate ? zlib.deflateRawSync(data) : data;
    const n = Buffer.from(name);
    const local = Buffer.alloc(30);
    local.writeUInt32LE(0x04034b50, 0);
    local.writeUInt16LE(deflate ? 8 : 0, 8);
    local.writeUInt32LE(body.length, 18);
    local.writeUInt32LE(data.length, 22);
    local.writeUInt16LE(n.length, 26);
    const central = Buffer.alloc(46);
    central.writeUInt32LE(0x02014b50, 0);
    central.writeUInt16LE(deflate ? 8 : 0, 10);
    central.writeUInt32LE(body.length, 20);
    central.writeUInt32LE(data.length, 24);
    central.writeUInt16LE(n.length, 28);
    central.writeUInt32LE(offset, 42);
    locals.push(local, n, body);
    centrals.push(central, n);
    offset += 30 + n.length + body.length;
  }
  const cd = Buffer.concat(centrals);
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(Object.keys(entries).length, 8);
  end.writeUInt16LE(Object.keys(entries).length, 10);
  end.writeUInt32LE(cd.length, 12);
  end.writeUInt32LE(offset, 16);
  return Buffer.concat([...locals, cd, end]);
}

test('reads stored and deflated zips', () => {
  for (const deflate of [true, false]) {
    const files = Restore.unzip(zip({ 'configuration.yaml': 'a: 1\n', 'sub/x.json': '{}' }, deflate));
    assert.deepStrictEqual(files.map((f) => [f.name, f.data.toString()]), [
      ['configuration.yaml', 'a: 1\n'],
      ['sub/x.json', '{}'],
    ]);
  }
  assert.throws(() => Restore.unzip(Buffer.from('not a zip at all, really not')));
});

test('writes only into the data folder, never logs or itself', () => {
  for (const ok of ['configuration.yaml', 'database.db', 'extension/zigdash-engine.js']) assert.ok(Restore.writable(ok), ok);
  for (const no of ['../etc/passwd', '/abs', 'a/../b', 'log/2026/x.txt', 'z.log', 'extension/zigdash-restore.js',
    'zigdash-restore-previous/x', 'a\\b', '']) assert.ok(!Restore.writable(no), no);
});

test('moves the frame counter past the margin, leaves other files alone', () => {
  const out = JSON.parse(Restore.bumpCounter(Buffer.from(JSON.stringify({ network_key: { key: 'k', frame_counter: 5 } }))));
  assert.strictEqual(out.network_key.frame_counter, 5 + Restore.COUNTER_MARGIN);
  assert.strictEqual(Restore.bumpCounter(Buffer.from('nope')).toString(), 'nope');
});

function harness() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'zd-restore-'));
  fs.mkdirSync(path.join(dir, 'extension'));
  fs.writeFileSync(path.join(dir, 'configuration.yaml'), 'pan_id: GENERATE\n');
  fs.writeFileSync(path.join(dir, 'database.db'), 'new network\n');
  fs.writeFileSync(path.join(dir, 'extension', 'zigdash-restore.js'), '// me');
  const published = [];
  let handler;
  const ext = new Restore(
    {}, { subscribe: () => {}, unsubscribe: async () => {}, publish: (t, p, o) => published.push([`${o.baseTopic}/${t}`, JSON.parse(p)]) },
    {}, () => {}, { onMQTTMessage: (_, fn) => { handler = fn; }, removeListeners: () => {} },
    () => {}, () => {}, () => {}, {}, { info() {}, warning() {}, error() {} });
  ext.dataDir = dir;
  ext.selfPath = path.join(dir, 'extension', 'zigdash-restore.js');
  let exited = 0;
  ext.exit = () => { exited++; };
  ext.start();
  return { dir, ext, published, send: (msg) => handler({ topic: 'zigdash/backup/restore', message: JSON.stringify(msg) }), exited: () => exited };
}

test('a restore writes the backup, keeps the old files, removes itself and stops', async () => {
  const h = harness();
  const backup = zip({
    'configuration.yaml': 'pan_id: 0x2ef6\n',
    'database.db': 'old network\n',
    'coordinator_backup.json': JSON.stringify({ network_key: { key: 'k', frame_counter: 10 } }),
    'log/x.log': 'nope',
  });
  h.send({ tx: 't1', zip: backup.toString('base64') });
  assert.strictEqual(fs.readFileSync(path.join(h.dir, 'configuration.yaml'), 'utf8'), 'pan_id: 0x2ef6\n');
  assert.strictEqual(fs.readFileSync(path.join(h.dir, 'database.db'), 'utf8'), 'old network\n');
  const coord = JSON.parse(fs.readFileSync(path.join(h.dir, 'coordinator_backup.json'), 'utf8'));
  assert.strictEqual(coord.network_key.frame_counter, 10 + Restore.COUNTER_MARGIN);
  assert.ok(!fs.existsSync(path.join(h.dir, 'log')));
  const [kept] = fs.readdirSync(path.join(h.dir, 'zigdash-restore-previous'));
  assert.strictEqual(fs.readFileSync(path.join(h.dir, 'zigdash-restore-previous', kept, 'configuration.yaml'), 'utf8'), 'pan_id: GENERATE\n');
  assert.ok(!fs.existsSync(path.join(h.dir, 'extension', 'zigdash-restore.js')));
  assert.deepStrictEqual(h.published, [['zigdash/backup/restore/result', { tx: 't1', status: 'writing', files: 3 }]]);
  assert.strictEqual(h.exited(), 0);
  await new Promise((r) => setTimeout(r, 1700));
  assert.strictEqual(h.exited(), 1);
});

test('a zip without a configuration is refused and nothing changes', () => {
  const h = harness();
  h.send({ tx: 't2', zip: zip({ 'database.db': 'x' }).toString('base64') });
  assert.strictEqual(fs.readFileSync(path.join(h.dir, 'configuration.yaml'), 'utf8'), 'pan_id: GENERATE\n');
  assert.strictEqual(h.published[0][1].status, 'error');
  assert.ok(fs.existsSync(path.join(h.dir, 'extension', 'zigdash-restore.js')));
});
