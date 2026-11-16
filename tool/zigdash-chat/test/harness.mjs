// Test harness: the release Engine (3.7.0 and later, with Chat) on a fake Zigbee2MQTT, a broker (a real
// local mosquitto when installed, otherwise an in-process fake), a fake
// Telegram and a scripted fake Claude. Nothing here talks to the internet.

import { spawn, spawnSync } from 'node:child_process';
import { createRequire } from 'node:module';
import { EventEmitter } from 'node:events';
import fs from 'node:fs';
import net from 'node:net';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import mqtt from 'mqtt';

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '../../..');

export function tmpDir(prefix = 'zigdash-chat-') {
  return fs.mkdtempSync(path.join(os.tmpdir(), prefix));
}

/** The release Engine (hub/zigdash-engine.js, Chat included since 3.7.0). */
export function loadChatEngine() {
  process.env.ZIGBEE2MQTT_DATA = tmpDir('zigdash-chat-engine-');
  const r = spawnSync(process.execPath, [path.join(repo, 'hub/build.mjs'), '--check']);
  if (r.status !== 0) throw new Error(`hub/zigdash-engine.js is stale: ${String(r.stderr)}`);
  return createRequire(import.meta.url)(path.join(repo, 'hub/zigdash-engine.js'));
}

// ---------- brokers ----------

const MOSQUITTO = ['/opt/homebrew/sbin/mosquitto', '/usr/local/sbin/mosquitto', '/usr/sbin/mosquitto'].find((p) => fs.existsSync(p));

const freePort = () => new Promise((resolve) => {
  const s = net.createServer().listen(0, '127.0.0.1', () => { const { port } = s.address(); s.close(() => resolve(port)); });
});

/** A broker: {connect(): Promise<client>, stop(), kind}. */
export async function startBroker() {
  if (MOSQUITTO && !process.env.ZIGDASH_CHAT_FAKE_BROKER) {
    const dir = tmpDir('zigdash-chat-mosq-');
    const port = await freePort();
    fs.writeFileSync(path.join(dir, 'mosquitto.conf'), `listener ${port} 127.0.0.1\nallow_anonymous true\npersistence false\n`);
    const proc = spawn(MOSQUITTO, ['-c', path.join(dir, 'mosquitto.conf')], { stdio: 'ignore' });
    for (let i = 0; i < 50; i++) {
      const ok = await new Promise((resolve) => { const s = net.connect(port, '127.0.0.1', () => { s.end(); resolve(true); }).on('error', () => resolve(false)); });
      if (ok) break;
      await new Promise((r) => setTimeout(r, 100));
    }
    const clients = [];
    return {
      kind: 'mosquitto',
      url: `mqtt://127.0.0.1:${port}`,
      async connect(options = {}) {
        const c = mqtt.connect(`mqtt://127.0.0.1:${port}`, { protocolVersion: 5, reconnectPeriod: 200, ...options });
        clients.push(c);
        await new Promise((resolve) => c.once('connect', resolve));
        return c;
      },
      /** A client for the Engine's own relay connection, connected later by the Engine. */
      connectLater(options = {}) {
        const c = mqtt.connect(`mqtt://127.0.0.1:${port}`, { protocolVersion: 5, reconnectPeriod: 200, ...options });
        clients.push(c);
        return c;
      },
      async stop() {
        for (const c of clients) c.end(true);
        proc.kill();
      },
    };
  }
  return fakeBroker();
}

const matches = (filter, topic) => {
  const f = filter.split('/'), t = topic.split('/');
  for (let i = 0; i < f.length; i++) {
    if (f[i] === '#') return true;
    if (i >= t.length || (f[i] !== '+' && f[i] !== t[i])) return false;
  }
  return f.length === t.length;
};

/** An in-process broker with the parts of mqtt.js the code uses: retain, no-local, callbacks. */
function fakeBroker() {
  const retained = new Map();
  const clients = new Set();
  const make = () => {
    const c = new EventEmitter();
    c.subs = new Map(); // filter -> {nl}
    c.connected = false;
    c.publish = (topic, payload, opts = {}, cb) => {
      const buf = Buffer.isBuffer(payload) ? payload : Buffer.from(String(payload));
      if (opts.retain) { if (buf.length) retained.set(topic, buf); else retained.delete(topic); }
      for (const other of clients) {
        for (const [f, o] of other.subs) {
          if (matches(f, topic) && !(o.nl && other === c)) { setImmediate(() => other.emit('message', topic, buf, { retain: false })); break; }
        }
      }
      if (typeof opts === 'function') opts(); else if (cb) setImmediate(cb);
      return c;
    };
    c.subscribe = (topic, opts = {}, cb) => {
      if (typeof opts === 'function') { cb = opts; opts = {}; }
      c.subs.set(topic, { nl: !!opts.nl });
      for (const [t, buf] of retained) if (matches(topic, t)) setImmediate(() => c.emit('message', t, buf, { retain: true }));
      if (cb) setImmediate(() => cb(null));
      return c;
    };
    c.unsubscribe = (topic) => { c.subs.delete(topic); return c; };
    c.end = (_force, _opts, cb) => { clients.delete(c); c.connected = false; if (typeof cb === 'function') cb(); return c; };
    c.open = () => { clients.add(c); c.connected = true; setImmediate(() => c.emit('connect')); };
    return c;
  };
  return {
    kind: 'fake',
    url: 'mqtt://fake',
    async connect() { const c = make(); c.open(); await new Promise((r) => c.once('connect', r)); return c; },
    connectLater() { const c = make(); c.open(); return c; },
    async stop() {},
  };
}

// ---------- the hub: the chat Engine on a fake Zigbee2MQTT, bridged to a broker ----------

const light = { exposes: [{ type: 'light', features: [{ type: 'binary', property: 'state', access: 7, value_on: 'ON', value_off: 'OFF', value_toggle: 'TOGGLE' }, { type: 'numeric', property: 'brightness', access: 7, value_min: 0, value_max: 254 }] }] };
const plug = { exposes: [{ type: 'switch', features: [{ type: 'binary', property: 'state', access: 7, value_on: 'ON', value_off: 'OFF' }] }] };
export const HOME = {
  '0x0000000000000001': ['Office shutter', { exposes: [{ type: 'cover', features: [{ type: 'enum', property: 'state', access: 7, values: ['OPEN', 'CLOSE', 'STOP'] }, { type: 'numeric', property: 'position', access: 7, value_min: 0, value_max: 100 }] }] }],
  '0x0000000000000002': ['Front door', { exposes: [{ type: 'binary', property: 'contact', access: 1 }] }],
  '0x0000000000000003': ['Garden valve', { description: 'Water valve', exposes: [{ type: 'switch', features: [{ type: 'binary', property: 'state', access: 7 }] }] }],
  '0x0000000000000004': ['Front lock', { exposes: [{ type: 'lock', features: [{ type: 'binary', property: 'state', access: 7 }] }] }],
  '0x0000000000000005': ['Freezer plug', plug],
  '0x0000000000000006': ['Kettle plug', plug],
  '0x0000000000000011': ['Hall light', light],
  '0x0000000000000012': ['Kitchen light', light],
  '0x0000000000000013': ['Desk lamp', light],
  '0x0000000000000014': ['Bed lamp', light],
  '0x0000000000000015': ['Porch light', light],
};
export const ieeeOf = (name) => Object.keys(HOME).find((k) => HOME[k][0] === name);
export const CONTROLS = ['Office shutter', 'Kettle plug', 'Hall light', 'Kitchen light', 'Desk lamp', 'Bed lamp', 'Porch light', 'Garden valve', 'Front lock'].map(ieeeOf);

/**
 * Starts the Engine on [client] (a broker client for the hub's own broker).
 * [relay]: an optional {connectLater} broker for the Engine's relay connection.
 */
export async function startHub(Engine, client, { relay } = {}) {
  const listeners = { mqtt: [], entity: [], published: [] };
  const injected = [];
  const devices = {};
  for (const [ieee, [name, definition]] of Object.entries(HOME)) {
    const d = { name, ieeeAddr: ieee, definition, isDevice: () => true, isGroup: () => false };
    devices[ieee] = d;
    devices[name] = d;
  }
  const state = {};
  // As Zigbee2MQTT: a topic it published to (skipReceive on, the default) is
  // never handed to extensions again; skipReceive off lets the echo through.
  const publishedTopics = new Set();
  client.on('message', (topic, payload) => {
    if (publishedTopics.has(topic)) return;
    for (const cb of listeners.mqtt) cb({ topic, message: payload.toString() });
  });
  const z2mMqtt = {
    publish: (topic, payload, options) => {
      const full = `${options.baseTopic}/${topic}`;
      if (options.skipReceive !== false) publishedTopics.add(full);
      return new Promise((resolve) => client.publish(full, payload, { qos: 1, retain: !!options.clientOptions.retain }, () => resolve()));
    },
    subscribe: (topic) => new Promise((resolve) => client.subscribe(topic, { qos: 1 }, () => resolve())),
    unsubscribe: (topic) => { client.unsubscribe(topic); return Promise.resolve(); },
    onMessage: (topic, buf) => injected.push({ topic, payload: JSON.parse(buf.toString()) }),
  };
  const zigbee = {
    resolveEntity: (k) => devices[k],
    devicesIterator: function* () { yield* new Set(Object.values(devices)); },
    groupsIterator: function* () {},
  };
  const eventBus = {
    onMQTTMessage: (k, cb) => listeners.mqtt.push(cb),
    onPublishEntityState: (k, cb) => listeners.entity.push(cb),
    onMQTTMessagePublished: (k, cb) => listeners.published.push(cb),
    removeListeners: () => { listeners.mqtt = []; listeners.entity = []; listeners.published = []; },
  };
  const settings = { get: () => ({ mqtt: { base_topic: 'zigbee2mqtt' } }) };
  const logger = { info() {}, warning() {}, error() {}, debug() {} };
  const engine = new Engine(zigbee, z2mMqtt, { get: (e) => state[e.ieeeAddr] }, null, eventBus, null, null, null, settings, logger);
  engine.readRemoteConfig = () => null;
  const chatFile = path.join(tmpDir('zigdash-chat-hub-'), 'zigdash-chat.json');
  engine.chatFilePath = () => chatFile;
  if (relay) engine.mqttConnect = (url, options) => relay.connectLater({ clientId: options.clientId, will: options.will });
  await engine.start();
  // Zigbee2MQTT's retained device list, as the CLI reads it.
  await new Promise((r) => client.publish('zigbee2mqtt/bridge/devices', JSON.stringify(Object.entries(HOME).map(([ieee, [name]]) => ({ ieee_address: ieee, friendly_name: name, type: 'EndDevice' }))), { qos: 1, retain: true }, r));
  return {
    engine, injected, chatFile,
    report: (name, message) => {
      state[ieeeOf(name)] = { ...(state[ieeeOf(name)] || {}), ...message };
      for (const cb of listeners.entity) cb({ entity: devices[name], message });
    },
    async stop() { await engine.stop(); },
  };
}

// ---------- Telegram ----------

/** A fake Bot API: queue updates with send(); replies land in sent. */
export function fakeTelegram() {
  const queue = [];
  const sent = [];
  const waiters = [];
  let updateId = 100;
  const calls = [];
  const cleared = [];
  const fetchImpl = async (url, init) => {
    const method = url.slice(url.lastIndexOf('/') + 1);
    calls.push({ url, method });
    const body = JSON.parse(init.body);
    const reply = (result) => ({ json: async () => ({ ok: true, result }), status: 200 });
    if (method === 'getMe') return reply({ id: 1, username: 'ZigDashHomeDevBot' });
    if (method === 'sendChatAction') return reply(true);
    if (method === 'sendMessage') { sent.push({ chatId: String(body.chat_id), text: body.text, markup: body.reply_markup }); waiters.splice(0).forEach((w) => w()); return reply({}); }
    if (method === 'answerCallbackQuery') return reply(true);
    if (method === 'editMessageReplyMarkup') { cleared.push({ chatId: String(body.chat_id), messageId: body.message_id, markup: body.reply_markup }); return reply(true); }
    if (method === 'getUpdates') {
      for (;;) {
        const ready = queue.filter((u) => u.update_id >= body.offset);
        if (ready.length) return reply(ready);
        await new Promise((resolve, reject) => {
          const t = setTimeout(resolve, 50);
          init.signal?.addEventListener('abort', () => { clearTimeout(t); reject(Object.assign(new Error('aborted'), { name: 'AbortError' })); });
        });
      }
    }
    return reply({});
  };
  return {
    fetchImpl, sent, calls, cleared,
    send(chatId, text, { type = 'private', firstName = 'Owner' } = {}) {
      queue.push(this.update(chatId, text, { type, firstName }));
    },
    /** A message update, as Telegram would send it (for the webhook too). */
    update(chatId, text, { type = 'private', firstName = 'Owner', lang = 'en' } = {}) {
      return { update_id: ++updateId, message: { message_id: updateId, from: { id: Number(chatId), first_name: firstName, language_code: lang }, chat: { id: Number(chatId), type }, ...(text === null ? { photo: [] } : { text }) } };
    },
    /** A button press. */
    callback(chatId, data, { lang = 'en' } = {}) {
      return { update_id: ++updateId, callback_query: { id: `cb${updateId}`, data, from: { id: Number(chatId), first_name: 'Owner', language_code: lang }, message: { message_id: 1, chat: { id: Number(chatId), type: 'private' } } } };
    },
    press(chatId, data) { queue.push(this.callback(chatId, data)); },
    /** Resolves with the next reply to [chatId]. */
    async replyTo(chatId, timeoutMs = 8000) {
      const start = sent.filter((s) => s.chatId === String(chatId)).length;
      const deadline = Date.now() + timeoutMs;
      while (Date.now() < deadline) {
        const mine = sent.filter((s) => s.chatId === String(chatId));
        if (mine.length > start) return mine[start].text;
        await new Promise((r) => setTimeout(r, 20));
      }
      throw new Error('no reply');
    },
  };
}

// ---------- the relay verifier's internal routes ----------

/**
 * A fake verifier at [url]: the chat-ACL route (status set with setAcl) and
 * the Home-status route, GET /v1/internal/home/<id>: setHome(id, {entitled,
 * ended_at}) answers 200 with it, setHome(id, 410|404|503) that status,
 * setHome(id, 'down') throws as a timeout would. A Home never set is 404.
 * Both routes check [secret]. [statusCalls] lists the Homes asked about.
 */
export function fakeVerifier({ url = 'http://verifier.test:8788', secret }) {
  const acl = [];
  const statusCalls = [];
  const homes = new Map();
  let aclStatus = 200;
  const answer = (status, body = {}) => ({ status, json: async () => body });
  return {
    url, acl, statusCalls,
    setAcl: (s) => { aclStatus = s; },
    setHome: (id, v) => { homes.set(id, v); },
    handles: (u) => u.startsWith(`${url}/v1/internal/`),
    async fetch(u, init) {
      if (init.headers['X-Chat-Acl-Secret'] !== secret) return answer(401, { error: 'no' });
      if (u === `${url}/v1/internal/chat-acl` && init.method === 'POST') {
        const body = JSON.parse(init.body);
        if (aclStatus === 200) acl.push(body);
        return answer(aclStatus, aclStatus === 402 ? { error: 'pass_ended' } : aclStatus === 200 ? { ok: true, op: body.op } : {});
      }
      const m = new RegExp(`^${url}/v1/internal/home/([0-9a-f]{16})$`).exec(u);
      if (m && init.method === 'GET') {
        statusCalls.push(m[1]);
        const v = homes.has(m[1]) ? homes.get(m[1]) : 404;
        if (v === 'down') throw Object.assign(new Error('The operation was aborted due to timeout'), { name: 'TimeoutError' });
        if (typeof v === 'number') return answer(v, { error: v === 410 ? 'deleted' : v === 404 ? 'unknown' : 'failed' });
        return answer(200, v);
      }
      throw new Error(`unexpected verifier call ${init.method} ${u}`);
    },
  };
}

// ---------- Claude ----------

/**
 * A scripted model. [script] maps the newest user text to steps, one per model
 * round: {tool, input} asks for a tool, {text} answers. [calls] keeps every
 * request for assertions.
 */
export function fakeClaude(script) {
  const calls = [];
  let n = 0;
  return {
    calls,
    messages: {
      async create(params, opts) {
        calls.push({ params: JSON.parse(JSON.stringify(params)), opts });
        const msgs = params.messages;
        let i = msgs.length - 1;
        while (i >= 0 && !(msgs[i].role === 'user' && typeof msgs[i].content === 'string')) i--;
        const text = msgs[i].content.replace(/^\[[^\]]*\]\s*/, '');
        const round = msgs.slice(i + 1).filter((m) => m.role === 'user').length;
        const entry = script.find(([re]) => re.test(text));
        const steps = entry ? (typeof entry[1] === 'function' ? entry[1](msgs.slice(i + 1)) : entry[1]) : [{ text: 'I can only help with your home.' }];
        const step = steps[Math.min(round, steps.length - 1)];
        const usage = { input_tokens: 900, output_tokens: 40, cache_read_input_tokens: 600, cache_creation_input_tokens: 0 };
        if (step.tool) {
          return { stop_reason: 'tool_use', usage, content: [{ type: 'thinking', thinking: '', signature: 'sig' }, { type: 'tool_use', id: `tu_${++n}`, name: step.tool, input: step.input }] };
        }
        return { stop_reason: 'end_turn', usage, content: [{ type: 'text', text: step.text }] };
      },
    },
  };
}

/** The tool results the model was given in its last request. */
export function lastToolResults(claude) {
  const msgs = claude.calls.at(-1).params.messages;
  return msgs.filter((m) => Array.isArray(m.content)).flatMap((m) => m.content).filter((b) => b.type === 'tool_result').map((b) => ({ ...b, data: JSON.parse(b.content) }));
}
