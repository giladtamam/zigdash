// Runs the verifier against a real Mosquitto with dynamic security, started
// here on a free local port (skipped when mosquitto isn't installed).
// Google Play is replaced by VERIFY=fake: tokens starting "test-pro-" pass.
import test from 'node:test';
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import net from 'node:net';
import crypto from 'node:crypto';
import mqtt from 'mqtt';
import { createVerifier } from '../server.mjs';

const have = (bin) => spawnSync('which', [bin]).status === 0;
const freePort = () => new Promise((r) => { const s = net.createServer(); s.listen(0, () => { const p = s.address().port; s.close(() => r(p)); }); });
const plugin = ['/opt/homebrew/lib/mosquitto_dynamic_security.so', '/usr/lib/mosquitto_dynamic_security.so', '/usr/lib/x86_64-linux-gnu/mosquitto_dynamic_security.so'].find((p) => fs.existsSync(p));

const skip = !have('mosquitto') || !have('mosquitto_ctrl') || !plugin ? 'mosquitto with dynamic security not installed' : false;

test('verifier against a real broker', { skip }, async (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'zd-relay-'));
  const adminPw = crypto.randomBytes(12).toString('hex');
  assert.equal(spawnSync('mosquitto_ctrl', ['dynsec', 'init', path.join(dir, 'dynsec.json'), 'admin', adminPw]).status, 0);
  const port = await freePort();
  fs.writeFileSync(path.join(dir, 'mosquitto.conf'),
    `listener ${port} 127.0.0.1\nallow_anonymous false\npersistence false\nplugin ${plugin}\nplugin_opt_config_file ${dir}/dynsec.json\n`);
  const broker = spawn('mosquitto', ['-c', path.join(dir, 'mosquitto.conf')], { stdio: 'ignore' });
  t.after(() => broker.kill());
  await new Promise((r) => setTimeout(r, 600));

  const url = `mqtt://127.0.0.1:${port}`;
  const v = createVerifier({ VERIFY: 'fake', PORT: '0', MQTT_URL: url, ADMIN_USER: 'admin', ADMIN_PASSWORD: adminPw, HUB_URL: url, PHONE_URL: url });
  const httpPort = await v.start();
  t.after(() => v.stop());
  const api = async (method, p, body, auth) => {
    const res = await fetch(`http://127.0.0.1:${httpPort}${p}`, {
      method,
      headers: { 'Content-Type': 'application/json', ...(auth ? { Authorization: `Basic ${Buffer.from(`${auth.username}:${auth.password}`).toString('base64')}` } : {}) },
      body: body ? JSON.stringify(body) : undefined,
    });
    return { status: res.status, body: await res.json() };
  };
  const connect = (c, id) => new Promise((resolve) => {
    const client = mqtt.connect(url, { username: c.username, password: c.password, clientId: id, protocolVersion: 5, reconnectPeriod: 0 });
    client.once('connect', () => resolve(client));
    client.once('error', (e) => { client.end(true); resolve({ error: e.code || e.message }); });
  });

  await t.test('no Pro purchase, no home', async () => {
    const r = await api('POST', '/v1/homes', { purchaseToken: 'free-user' });
    assert.equal(r.status, 402);
  });

  const first = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-AAA' });
  await t.test('a Pro purchase creates a home with a hub and a phone login', async () => {
    assert.equal(first.status, 200);
    assert.match(first.body.homeId, /^[0-9a-f]{16}$/);
    assert.equal(first.body.hub.username, `hub-${first.body.homeId}`);
  });
  const H = first.body.homeId;

  await t.test('hub and phone talk inside their home only', async () => {
    const hub = await connect(first.body.hub, 'hub-a');
    const phone = await connect(first.body.phone, 'phone-a');
    assert.ok(!hub.error && !phone.error, JSON.stringify([hub.error, phone.error]));
    const got = new Promise((r) => phone.once('message', (topic, p) => r([topic, p.toString()])));
    await phone.subscribeAsync(`homes/${H}/s/#`);
    hub.publish(`homes/${H}/s/x`, 'sealed');
    assert.deepEqual(await got, [`homes/${H}/s/x`, 'sealed']);
    await assert.rejects(phone.subscribeAsync('homes/other/#'), /Not authorized/, 'a subscription outside the home is refused');
    hub.end(true); phone.end(true);
  });

  await t.test('the same purchase again returns the same home (reinstall), not a second one', async () => {
    const again = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-AAA' });
    assert.equal(again.status, 200);
    assert.equal(again.body.homeId, H);
    const oldHub = await connect(first.body.hub, 'hub-old');
    assert.ok(oldHub.error, 'the old hub password stopped working');
    const newHub = await connect(again.body.hub, 'hub-new');
    assert.ok(!newHub.error);
    newHub.end(true);
  });

  await t.test('a paired phone adds a phone for the QR code, lists and removes phones', async () => {
    const added = await api('POST', `/v1/homes/${H}/phones`, null, first.body.phone);
    assert.equal(added.status, 200);
    const tablet = await connect(added.body.phone, 'tablet');
    assert.ok(!tablet.error);
    tablet.end(true);
    const list = await api('GET', `/v1/homes/${H}/phones`, null, first.body.phone);
    assert.equal(list.body.length, 3);
    const removed = await api('DELETE', `/v1/homes/${H}/phones/${added.body.phone.username}`, null, first.body.phone);
    assert.equal(removed.status, 200);
    const gone = await connect(added.body.phone, 'tablet-again');
    assert.ok(gone.error, 'a removed phone can no longer connect');
  });

  await t.test('a paired phone renews the hub login; the old one stops working', async () => {
    const current = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-AAA' });
    const renewed = await api('POST', `/v1/homes/${H}/hub`, null, current.body.phone);
    assert.equal(renewed.status, 200);
    const oldHub = await connect(current.body.hub, 'hub-before');
    assert.ok(oldHub.error);
    const newHub = await connect(renewed.body.hub, 'hub-after');
    assert.ok(!newHub.error);
    newHub.end(true);
    assert.equal((await api('POST', `/v1/homes/${H}/hub`, null, { username: 'nobody', password: 'x' })).status, 401);
  });

  await t.test('strangers and other homes are refused', async () => {
    assert.equal((await api('POST', `/v1/homes/${H}/phones`, null, { username: first.body.phone.username, password: 'wrong' })).status, 401);
    const other = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-BBB' });
    assert.equal((await api('POST', `/v1/homes/${H}/phones`, null, other.body.phone)).status, 401);
  });

  await t.test('an App Store purchase gets its own home; an unknown one gets none', async () => {
    const apple = await api('POST', '/v1/homes', { purchaseToken: 'test-pro-AAA', store: 'apple' });
    assert.equal(apple.status, 200);
    assert.notEqual(apple.body.homeId, H);
    assert.equal((await api('POST', '/v1/homes', { purchaseToken: 'free-user', store: 'apple' })).status, 402);
  });

  await t.test('pairing is limited per address', async () => {
    let last;
    for (let i = 0; i < 12; i++) last = await api('POST', '/v1/homes', { purchaseToken: `test-pro-L${i}` });
    assert.equal(last.status, 429);
  });
});
