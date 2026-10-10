// Runs the function-node bodies in node-red/alerts/*.js as Node-RED would,
// through a scripted day at home, and checks what gets published.
// Usage: node node-red/alerts/test/harness.mjs
import crypto from 'node:crypto';
import fs from 'node:fs';
import assert from 'node:assert/strict';
const dir = new URL('../', import.meta.url).pathname;
const load = name => new Function('msg', 'flow', 'env', 'node', 'Buffer', 'crypto', fs.readFileSync(dir + name + '.js', 'utf8'));
const fns = Object.fromEntries(['ingest', 'restore', 'watch', 'push', 'result', 'test', 'heartbeat'].map(n => [n, load(n)]));

let store = {};
const flow = { get: k => store[k], set: (k, v) => { store[k] = v; } };
const warnings = [];
const node = { warn: w => warnings.push(w), error: w => warnings.push('ERR ' + w) };
const run = (name, msg) => {
    const r = fns[name](msg, flow, { get: () => undefined }, node, Buffer, crypto);
    if (r === null || r === undefined) return [[]];
    if (!Array.isArray(r)) return [[r]];
    return r.map(o => o === null || o === undefined ? [] : Array.isArray(o) ? o : [o]);
};
const topicOf = outs => Object.fromEntries(outs.map(m => [m.topic, m.payload]));

// A fake phone: its Web Push keys, so the harness can decrypt what the hub sends.
const phoneEcdh = crypto.createECDH('prime256v1'); phoneEcdh.generateKeys();
const phoneAuth = crypto.randomBytes(16);
const decrypt = body => {
    const salt = body.subarray(0, 16), asPub = body.subarray(21, 86), ct = body.subarray(86);
    const secret = phoneEcdh.computeSecret(asPub);
    const ikm = Buffer.from(crypto.hkdfSync('sha256', secret, phoneAuth, Buffer.concat([Buffer.from('WebPush: info\0'), phoneEcdh.getPublicKey(), asPub]), 32));
    const cek = Buffer.from(crypto.hkdfSync('sha256', ikm, salt, Buffer.from('Content-Encoding: aes128gcm\0'), 16));
    const nonce = Buffer.from(crypto.hkdfSync('sha256', ikm, salt, Buffer.from('Content-Encoding: nonce\0'), 12));
    const d = crypto.createDecipheriv('aes-128-gcm', cek, nonce);
    d.setAuthTag(ct.subarray(ct.length - 16));
    const plain = Buffer.concat([d.update(ct.subarray(0, ct.length - 16)), d.final()]);
    return JSON.parse(plain.subarray(0, plain.length - 1).toString());
};
const { privateKey, publicKey } = crypto.generateKeyPairSync('ec', { namedCurve: 'P-256' });
const pubJwk = publicKey.export({ format: 'jwk' });
const vapidPub = Buffer.concat([Buffer.from([4]), Buffer.from(pubJwk.x, 'base64url'), Buffer.from(pubJwk.y, 'base64url')]).toString('base64url');

const config = {
    version: 1, home: 'My Home', base: 'zigbee2mqtt', timeZone: 'Asia/Jerusalem',
    vapid: { publicKey: vapidPub, privateJwk: privateKey.export({ format: 'jwk' }) },
    phones: [{ id: 'p1', name: 'Galaxy', endpoint: 'https://fcm.googleapis.com/fcm/send/abc', p256dh: phoneEcdh.getPublicKey().toString('base64url'), auth: phoneAuth.toString('base64url') },
             { id: 'p2', name: 'Old phone', endpoint: 'https://fcm.googleapis.com/fcm/send/old', p256dh: phoneEcdh.getPublicKey().toString('base64url'), auth: phoneAuth.toString('base64url') }],
    ntfy: { server: 'https://ntfy.sh', topic: 'zd-test' }, pushover: null,
    text: { leak: '💧 Leak — {name} ({home})', leakCleared: '✅ {name} is dry again', opened: '🚪 {name} opened ({home})', battery: '🔋 Battery low — {name}, {value}% ({home})', test: 'ZigDash test alert' },
    alerts: [
        { id: 'a1', kind: 'leak', devices: [{ ieee: '0x1', topic: 'zigbee2mqtt/Kitchen sensor', name: 'Kitchen sensor' }] },
        { id: 'a2', kind: 'opened', devices: [{ ieee: '0x2', topic: 'zigbee2mqtt/Front door', name: 'Front door' }], from: '23:00', to: '06:00' },
        { id: 'a3', kind: 'battery', devices: [{ ieee: '0x3', topic: 'zigbee2mqtt/Bedroom sensor', name: 'Bedroom sensor' }], threshold: 20 },
    ],
};
const at = (h, m = 0) => { // a Date whose wall time in Asia/Jerusalem is h:m today
    const d = new Date(); const local = new Date(d.toLocaleString('en-US', { timeZone: 'Asia/Jerusalem' }));
    const diff = d - local; local.setHours(h, m, 0, 0); return new Date(local.getTime() + diff);
};
const RealDate = Date;
const clock = t => { globalThis.Date = class extends RealDate { constructor(...a) { super(...(a.length ? a : [t])); } static now() { return t.getTime(); } }; };

let step = 0;
const check = (what, fn) => { step++; try { fn(); console.log(`ok ${step}: ${what}`); } catch (e) { console.log(`FAIL ${step}: ${what}\n   ${e.message}`); process.exitCode = 1; } };

// 1. Config arrives.
run('ingest', { topic: 'zigdash/alerts/config', payload: JSON.stringify(config) });
check('config indexed by topic', () => assert.deepEqual(Object.keys(store.index).sort(), ['zigbee2mqtt/Bedroom sensor', 'zigbee2mqtt/Front door', 'zigbee2mqtt/Kitchen sensor']));

// 2. Retained memory: nothing yet.
run('restore', { topic: 'zigdash/alerts/state', payload: '' });

// 3. A dry kitchen sensor reports: seeds, no alert.
clock(at(14));
let [ev, pub] = run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: false, battery: 90 } });
check('first dry report only seeds', () => { assert.equal(ev.length, 0); assert.ok(topicOf(pub)['zigdash/alerts/state']); });

// 4. Same report again (a /get republish): nothing.
[ev, pub] = run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: false } });
check('a republish of the same state is silent', () => { assert.equal(ev.length, 0); assert.equal(pub.length, 0); });

// 5. Leak!
[ev, pub] = run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: true } });
check('dry -> wet fires a leak', () => { assert.equal(ev.length, 1); assert.equal(ev[0].payload.kind, 'leak'); assert.equal(ev[0].payload.cleared, false); assert.equal(ev[0].payload.name, 'Kitchen sensor'); });
check('recent alerts published', () => assert.equal(JSON.parse(topicOf(pub)['zigdash/alerts/recent'])[0].kind, 'leak'));
let [reqs] = run('push', ev[0]);
check('one push per live phone, plus ntfy', () => {
    assert.deepEqual(reqs.map(r => r.phone || r.channel), ['p1', 'p2', 'ntfy']);
    const r = reqs[0];
    assert.equal(r.headers.Urgency, 'high'); assert.equal(r.headers['Content-Encoding'], 'aes128gcm');
    assert.match(r.headers.Authorization, /^vapid t=.+,k=.+$/);
    assert.equal(decrypt(r.payload).kind, 'leak');
    assert.equal(reqs[2].payload, '💧 Leak — Kitchen sensor (My Home)');
    assert.equal(reqs[2].headers.Priority, '5');
});
check('VAPID JWT verifies against the public key', () => {
    const t = reqs[0].headers.Authorization.match(/t=([^,]+)/)[1];
    const [h, p, s] = t.split('.');
    assert.ok(crypto.verify('sha256', Buffer.from(h + '.' + p), { key: publicKey, dsaEncoding: 'ieee-p1363' }, Buffer.from(s, 'base64url')));
    assert.equal(JSON.parse(Buffer.from(p, 'base64url')).aud, 'https://fcm.googleapis.com');
});

// 6. Leak republished while still wet: silent. Then it dries: cleared alert.
[ev] = run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: true, linkquality: 10 } });
check('still wet is silent', () => assert.equal(ev.length, 0));
[ev] = run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: false } });
check('wet -> dry fires cleared', () => { assert.equal(ev[0].payload.cleared, true); });
[reqs] = run('push', ev[0]);
check('cleared text and lower priority', () => { assert.equal(reqs[2].payload, '✅ Kitchen sensor is dry again'); assert.equal(reqs[2].headers.Priority, '4'); });

// 7. Old phone's registration is gone: 410 marks it dead.
[pub] = run('result', { statusCode: 410, phone: 'p2', payload: '' });
check('410 marks the phone dead and publishes state', () => { assert.ok(store.dead.p2); assert.ok(topicOf(pub)['zigdash/alerts/state']); });
[reqs] = run('push', ev[0]);
check('a dead phone is skipped', () => assert.deepEqual(reqs.map(r => r.phone || r.channel), ['p1', 'ntfy']));

// 8. Door at 14:00 (outside 23:00-06:00): opening is silent. At 02:00: fires. Open stays open: silent.
run('watch', { topic: 'zigbee2mqtt/Front door', payload: { contact: true } });
[ev] = run('watch', { topic: 'zigbee2mqtt/Front door', payload: { contact: false } });
check('door opened at 14:00 is outside the hours', () => assert.equal(ev.length, 0));
run('watch', { topic: 'zigbee2mqtt/Front door', payload: { contact: true } });
clock(at(2));
[ev] = run('watch', { topic: 'zigbee2mqtt/Front door', payload: { contact: false } });
check('door opened at 02:00 fires', () => assert.equal(ev[0]?.payload.kind, 'opened'));
[ev] = run('watch', { topic: 'zigbee2mqtt/Front door', payload: { contact: false } });
check('door still open is silent', () => assert.equal(ev.length, 0));

// 9. Battery: 80 seeds; 15 fires; 12 silent; 50 clears the mark; 10 fires again.
[ev] = run('watch', { topic: 'zigbee2mqtt/Bedroom sensor', payload: { battery: 80 } });
check('battery 80 seeds', () => assert.equal(ev.length, 0));
[ev] = run('watch', { topic: 'zigbee2mqtt/Bedroom sensor', payload: { battery: 15 } });
check('battery 15 fires with the value', () => { assert.equal(ev[0].payload.kind, 'battery'); assert.equal(ev[0].payload.value, 15); });
[reqs] = run('push', ev[0]);
check('battery text', () => assert.equal(reqs.find(r => r.channel === 'ntfy').payload, '🔋 Battery low — Bedroom sensor, 15% (My Home)'));
[ev] = run('watch', { topic: 'zigbee2mqtt/Bedroom sensor', payload: { battery: 12 } });
check('battery 12 is silent (already reported)', () => assert.equal(ev.length, 0));
run('watch', { topic: 'zigbee2mqtt/Bedroom sensor', payload: { battery: 50 } });
[ev] = run('watch', { topic: 'zigbee2mqtt/Bedroom sensor', payload: { battery: 10 } });
check('after a new battery, low fires again', () => assert.equal(ev.length, 1));

// 10. Restart: memory comes back from the retained state; a leak republish does not refire.
const retainedState = topicOf(run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: true } })[1])['zigdash/alerts/state'];
store = {};
run('ingest', { topic: 'zigdash/alerts/config', payload: JSON.stringify(config) });
run('restore', { topic: 'zigdash/alerts/state', payload: retainedState });
[ev] = run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: true } });
check('after a restart with memory, the retained wet state does not refire', () => assert.equal(ev.length, 0));
check('dead phones survive the restart', () => assert.ok(store.dead.p2));

// 11. Restart with NO memory: a leak in progress at first sight fires (better late than never); an open door does not.
store = {};
run('ingest', { topic: 'zigdash/alerts/config', payload: JSON.stringify(config) });
run('restore', { topic: 'zigdash/alerts/state', payload: '' });
[ev] = run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: true } });
check('a leak at first sight with no memory fires', () => assert.equal(ev.length, 1));
[ev] = run('watch', { topic: 'zigbee2mqtt/Front door', payload: { contact: false } });
check('an open door at first sight does not', () => assert.equal(ev.length, 0));

// 12. Test alert to one phone, and its result.
[ev] = run('test', { topic: 'zigdash/alerts/test', payload: '{"phone":"p1"}' });
[reqs] = run('push', ev[0]);
check('a test goes only to the asked phone', () => { assert.deepEqual(reqs.map(r => r.phone), ['p1']); assert.equal(decrypt(reqs[0].payload).kind, 'test'); });
[pub] = run('result', { statusCode: 201, phone: 'p1', isTest: true, payload: '' });
check('the test result reaches ZigDash', () => assert.deepEqual(JSON.parse(topicOf(pub)['zigdash/alerts/test/result']).ok, true));

// 13. Config removed: everything stops.
run('ingest', { topic: 'zigdash/alerts/config', payload: '' });
[ev] = run('watch', { topic: 'zigbee2mqtt/Kitchen sensor', payload: { water_leak: false } });
check('no config, no alerts', () => { assert.equal(ev.length, 0); assert.equal(store.cfg, null); });
check('heartbeat', () => assert.equal(run('heartbeat', {})[0][0].payload, 'online'));
check('only the 410 was warned about', () => assert.deepEqual(warnings, ['alerts: push answered 410']));
globalThis.Date = RealDate;
console.log(process.exitCode ? 'SOME CHECKS FAILED' : 'all checks passed');
