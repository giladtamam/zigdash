// 3.7.0: the release Engine carries ZigDash Chat (hub/src/chat.js), dormant
// until a Chat client is linked. A dormant Engine must behave exactly as the
// Engine without it: the same scenario (rules, alerts, history, the relay)
// runs on the built hub/zigdash-engine.js and on the same file with the chat
// part cut off, and everything each one sends is compared.
// Run: node --test hub/test/*.test.js
'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const os = require('os');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { EventEmitter } = require('events');

process.env.ZIGBEE2MQTT_DATA = fs.mkdtempSync(path.join(os.tmpdir(), 'zigdash-dormant-'));
const builtFile = path.join(__dirname, '..', 'zigdash-engine.js');
const built = fs.readFileSync(builtFile, 'utf8');
const cut = built.indexOf('// ---------- ZigDash Chat (release Engine');
if (cut < 0) throw new Error('chat part not found in the built Engine');
const bareFile = path.join(process.env.ZIGBEE2MQTT_DATA, 'zigdash-engine-bare.js');
fs.writeFileSync(bareFile, built.slice(0, cut));
const WithChat = require(builtFile);
const Bare = require(bareFile);

const DEVICES = {
  '0xmotion': 'Hallway motion', '0xlight': 'Hallway light', '0xleak': 'Bathroom leak', '0xtemp': 'Balcony',
};

function fakeZ2m(Engine) {
  const listeners = { mqtt: [], entity: [], published: [] };
  const out = { published: [], subscribed: [], unsubscribed: [], injected: [], fetched: [], relay: null };
  const devices = {};
  for (const [ieee, name] of Object.entries(DEVICES)) {
    const d = { name, ieeeAddr: ieee, isDevice: () => true, isGroup: () => false, definition: { exposes: [] } };
    devices[ieee] = d;
    devices[name] = d;
  }
  const eventBus = {
    onMQTTMessage: (k, cb) => listeners.mqtt.push(cb),
    onPublishEntityState: (k, cb) => listeners.entity.push(cb),
    onMQTTMessagePublished: (k, cb) => listeners.published.push(cb),
    removeListeners: () => { listeners.mqtt = []; listeners.entity = []; listeners.published = []; },
  };
  const mqtt = {
    publish: (topic, payload, options) => {
      out.published.push({ topic: `${options.baseTopic}/${topic}`, payload: String(payload), retain: !!options.clientOptions.retain, receive: options.skipReceive === false });
      return Promise.resolve();
    },
    subscribe: (topic) => { out.subscribed.push(topic); return Promise.resolve(); },
    unsubscribe: (topic) => { out.unsubscribed.push(topic); return Promise.resolve(); },
    onMessage: (topic, buf) => out.injected.push({ topic, payload: JSON.parse(buf.toString()) }),
  };
  const zigbee = {
    resolveEntity: (k) => devices[k],
    devicesIterator: function* () { yield* new Set(Object.values(devices)); },
    groupsIterator: function* () {},
  };
  const settings = { get: () => ({ mqtt: { base_topic: 'zigbee2mqtt' } }) };
  const logger = { info() {}, warning() {}, error() {}, debug() {} };
  const engine = new Engine(zigbee, mqtt, {}, null, eventBus, null, null, null, settings, logger);
  engine.readRemoteConfig = () => null;
  engine.remoteWipeMs = 10;
  if (engine.chatFilePath) {
    const file = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'zigdash-dormant-chat-')), 'zigdash-chat.json');
    engine.chatFilePath = () => file;
    out.chatFile = file;
  }
  engine.fetch = async (url, init) => { out.fetched.push({ url, method: init.method, headers: Object.keys(init.headers || {}).sort() }); return { status: 201, text: async () => '' }; };
  engine.mqttConnect = () => {
    const client = new EventEmitter();
    client.published = [];
    client.subscribed = [];
    client.publish = (topic, payload, opts) => client.published.push({ topic, payload, opts });
    client.subscribe = (topic, opts) => client.subscribed.push({ topic, opts });
    client.end = () => { client.ended = true; };
    out.relay = client;
    return client;
  };
  return {
    engine, out,
    mqttIn: (topic, message) => listeners.mqtt.forEach((cb) => cb({ topic, message })),
    z2mPublished: (topic, payload) => listeners.published.forEach((cb) => cb({ topic, payload: JSON.stringify(payload) })),
    device: (ieee, message) => listeners.entity.forEach((cb) => cb({ entity: devices[ieee], message })),
  };
}

function alertsConfig() {
  const vapid = crypto.generateKeyPairSync('ec', { namedCurve: 'prime256v1' });
  const jwk = vapid.publicKey.export({ format: 'jwk' });
  const phone = crypto.createECDH('prime256v1'); phone.generateKeys();
  return {
    home: 'Home', base: 'zigbee2mqtt', timeZone: 'UTC',
    vapid: {
      privateJwk: vapid.privateKey.export({ format: 'jwk' }),
      publicKey: Buffer.concat([Buffer.from([4]), Buffer.from(jwk.x, 'base64url'), Buffer.from(jwk.y, 'base64url')]).toString('base64url'),
    },
    phones: [{ id: 'p1', name: 'Phone', endpoint: 'https://fcm.googleapis.com/fcm/send/abc',
      p256dh: phone.getPublicKey().toString('base64url'), auth: crypto.randomBytes(16).toString('base64url') }],
    alerts: [{ id: 'a1', kind: 'leak', enabled: true, devices: [{ topic: 'zigbee2mqtt/Bathroom leak', ieee: '0xleak', name: 'Bathroom leak' }] }],
    text: { leak: '{name}: leak' },
  };
}

const homeKey = crypto.randomBytes(32);
const remoteCfg = { url: 'mqtts://relay.example:8883', homeId: 'h1', username: 'hub-h1', password: 'pw', key: homeKey.toString('base64') };
const ALERTS = JSON.stringify(alertsConfig());
const HISTORY = JSON.stringify({ v: 1, timeZone: 'UTC',
  readings: [{ topic: 'zigbee2mqtt/Balcony', ieee: '0xtemp', attr: 'temperature', path: 'temperature', unit: '°C' }],
  tallies: [{ topic: 'zigbee2mqtt/Hallway light', ieee: '0xlight', attr: 'state', path: 'state', kind: 'on' }] });

/** Rules, alerts, history and the relay, as one Home's day; returns what the Engine sent. */
async function scenario(t, Engine) {
  const z = fakeZ2m(Engine);
  await z.engine.start();
  z.mqttIn('zigdash/automations/meta', JSON.stringify({ timezone: 'UTC', lat: 32.8, lon: 35 }));
  z.mqttIn('zigdash/automations/rules/r1', JSON.stringify({ v: 1, enabled: true, conditions: [],
    trigger: { type: 'device', ieee: '0xmotion', property: 'occupancy', equals: true },
    action: { type: 'device', commands: [{ ieee: '0xlight', payload: { state: 'ON' } }], offAfter: 1 } }));
  z.mqttIn('zigdash/automations/rules/r2', JSON.stringify({ v: 1, enabled: true, conditions: [],
    trigger: { type: 'time', at: '12:05', days: [] }, action: { type: 'scene', commands: [{ topic: 'zigbee2mqtt/Hallway light/set', payload: { brightness: 20 } }] } }));
  z.mqttIn('zigdash/alerts/config', ALERTS);
  z.mqttIn('zigdash/history/config', HISTORY);
  // Retained records found at start, and the chat topics a dormant Engine must ignore.
  z.mqttIn('zigdash/history/0xtemp/temperature/2026-10-21', JSON.stringify({ v: 1, unit: '°C', b: [[0, 20, 19, 21]] }));
  z.mqttIn('zigdash/chat/req/tg1', 'c2VhbGVk');
  z.mqttIn('zigdash/chat/audit', '[]');
  z.mqttIn('zigdash/remote/set', JSON.stringify(remoteCfg));
  z.out.relay.emit('connect');
  t.mock.timers.tick(46000); // both flows take over
  z.device('0xmotion', { occupancy: true });
  z.z2mPublished('zigbee2mqtt/Hallway light', { state: 'ON' });
  z.z2mPublished('zigbee2mqtt/Balcony', { temperature: 21.5 });
  z.z2mPublished('zigbee2mqtt/Bathroom leak', { water_leak: false });
  z.z2mPublished('zigbee2mqtt/Bathroom leak', { water_leak: true });
  await new Promise((r) => setImmediate(r));
  for (let i = 0; i < 20; i++) t.mock.timers.tick(60000); // the off timer, the clock rule, history slots
  z.z2mPublished('zigbee2mqtt/Hallway light', { state: 'OFF' });
  await new Promise((r) => setImmediate(r));
  await z.engine.stop();
  return z.out;
}

/** What went up to the relay, opened (the seals' random ivs aside). */
const relayView = (relay) => relay.published.map((p) => {
  const inner = p.payload && p.payload.length ? WithChat.helpers.unseal(homeKey, p.payload) : null;
  return { topic: p.topic, retain: !!(p.opts && p.opts.retain), inner: inner ? { topic: inner.topic, payload: inner.payload } : String(p.payload) };
});

test('dormant: rules, alerts, history and the relay behave as without Chat', async (t) => {
  t.mock.timers.enable({ apis: ['setTimeout', 'setInterval', 'Date'], now: Date.UTC(2026, 9, 22, 12, 0, 30) });
  const bare = await scenario(t, Bare);
  t.mock.timers.reset();
  t.mock.timers.enable({ apis: ['setTimeout', 'setInterval', 'Date'], now: Date.UTC(2026, 9, 22, 12, 0, 30) });
  const chat = await scenario(t, WithChat);

  // The scenario did something in each part.
  assert.ok(bare.injected.length >= 3, 'the motion rule, its off timer and the clock rule ran');
  assert.equal(bare.fetched.length, 1, 'the leak push went out');
  assert.ok(bare.published.some((p) => p.topic.startsWith('zigdash/history/0xtemp/temperature/')));
  assert.ok(bare.published.some((p) => p.topic.startsWith('zigdash/history/tally/0xlight/')));
  assert.ok(bare.relay.published.length > 3);

  assert.deepEqual(chat.subscribed, [...bare.subscribed, 'zigdash/chat/clients/+'], 'only the config topic is added');
  assert.deepEqual(chat.unsubscribed, ['zigdash/chat/clients/+', ...bare.unsubscribed]);
  assert.deepEqual(chat.published, bare.published);
  assert.deepEqual(chat.injected, bare.injected);
  assert.deepEqual(chat.fetched, bare.fetched);
  assert.deepEqual(chat.relay.subscribed, bare.relay.subscribed, 'no chat topics on the relay');
  assert.deepEqual(relayView(chat.relay), relayView(bare.relay));
  assert.ok(!fs.existsSync(chat.chatFile), 'no data file');
});
