// ZigDash Engine: runs a Home's Automations inside Zigbee2MQTT (>= 2.4).
// Installed by the ZigDash app as a Zigbee2MQTT external extension. Open source:
// https://github.com/giladtamam/zigdash/tree/main/hub
//
// Contract (docs/design/zigdash-3.0.md, section 3), all retained under the broker root:
//   zigdash/automations/rules/<id>   app -> engine   one rule, JSON; empty payload deletes it
//   zigdash/automations/meta         app -> engine   {timezone, lat, lon, town}
//   zigdash/automations/control      app -> engine   {"cmd":"start"} after the engine stopped itself
//   zigdash/automations/state        engine -> app   every 30 s
//   zigdash/automations/recent       engine -> app   last 20 runs
//
// Rules:
//   trigger:    {type:'device', ieee, property, equals?|above?|below?}
//               {type:'time', at:'HH:MM'|null, sun:'sunrise'|'sunset'|null, offset:minutes, days:[1..7] (1 = Monday)}
//   conditions: [{type:'hours', from:'HH:MM', to:'HH:MM'} | {type:'device', ieee, property, equals}]
//   action:     {type:'device', commands:[{ieee, payload}], offAfter:minutes}
//               {type:'scene',  commands:[{ieee, payload}], offAfter:minutes, scene:name}
//   a command is {ieee, payload}, or {topic, payload} for a /set topic under the base topic
//   (the app resolves a Scene into its commands when the rule is saved)
//
// Alerts and history (zigdash-3.0.md §4): the Node-RED flows' function bodies
// (node-red/alerts/*.js, node-red/history/*.js) run here unchanged, wired as
// in Node-RED. While a Node-RED copy still beats on a flow's heartbeat topic,
// that flow stays passive (keeps its memory, sends and publishes nothing);
// 90 s after the last foreign beat it takes over.
//
// Remote (3.1, zigdash-3.0.md §5): when the app hands the Engine relay credentials
// and a home key (zigdash/remote/set, non-retained; kept in the data folder, never
// published), the Engine keeps one outbound MQTT connection to the ZigDash relay.
// Up: each device state Zigbee2MQTT publishes goes to homes/<id>/s/<opaque id>,
// retained, AES-256-GCM sealed with the home key; the real topic travels only
// inside the seal; bridge topics never leave. Down: commands arrive sealed on
// homes/<id>/c and are accepted only for <base>/.../set|get and automation rules,
// within five minutes of being sealed. Presence: homes/<id>/hub online/offline.
//
// This file is BUILT from hub/src/engine.js by hub/build.mjs. Edit the source.
//
// Safety: Zigbee2MQTT has no crash guard, so every callback and timer here is wrapped.
// After three caught errors within an hour the engine stops running rules (a flag file
// survives restarts) and reports stopped_self until the app sends {"cmd":"start"}.

'use strict';

const ENGINE_VERSION = '3.1.5';
const ROOT = 'zigdash';
const PREFIX = 'automations';
const STATE_EVERY_MS = 30000;
const TICK_MS = 20000;
const RECENT_MAX = 20;
const CRASH_LIMIT = 3;
const CRASH_WINDOW_MS = 3600000;
const STOP_FLAG = 'zigdash-engine-stopped';

// ---------- pure helpers (exported for tests) ----------

const DAY_NAMES = { Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6, Sun: 7 };

/** Local wall-clock parts of [date] in [timeZone]; falls back to the hub's zone. */
function localParts(date, timeZone) {
  let parts;
  try {
    parts = new Intl.DateTimeFormat('en-GB', {
      timeZone: timeZone || undefined, hourCycle: 'h23',
      year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', weekday: 'short',
    }).formatToParts(date);
  } catch (_) {
    return localParts(date, undefined);
  }
  const get = (t) => (parts.find((p) => p.type === t) || {}).value;
  return {
    date: `${get('year')}-${get('month')}-${get('day')}`,
    hhmm: `${get('hour')}:${get('minute')}`,
    weekday: DAY_NAMES[get('weekday')] || 0,
    year: +get('year'), month: +get('month'), day: +get('day'),
  };
}

const toMinutes = (hhmm) => {
  const m = /^(\d{1,2}):(\d{2})$/.exec(hhmm || '');
  return m ? (+m[1]) * 60 + (+m[2]) : NaN;
};
const fromMinutes = (min) => {
  const m = ((Math.round(min) % 1440) + 1440) % 1440;
  return `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`;
};

/** True when [hhmm] lies in [from, to); a window may cross midnight. */
function withinHours(hhmm, from, to) {
  const n = toMinutes(hhmm), f = toMinutes(from), t = toMinutes(to);
  if ([n, f, t].some(Number.isNaN)) return false;
  return f <= t ? n >= f && n < t : n >= f || n < t;
}

/**
 * Sunrise or sunset as a UTC Date for the civil date (y, m, d) at (lat, lon),
 * NOAA's sunrise equation (zenith 90.833 deg). null when the sun does not rise or set.
 */
function sunTimeUtc(kind, y, m, d, lat, lon) {
  const rad = Math.PI / 180;
  const jd = Date.UTC(y, m - 1, d, 12) / 86400000 + 2440587.5;
  const n = Math.round(jd - 2451545.0 + 0.0008);
  const jStar = n - lon / 360;
  const M = (357.5291 + 0.98560028 * jStar) % 360;
  const C = 1.9148 * Math.sin(M * rad) + 0.02 * Math.sin(2 * M * rad) + 0.0003 * Math.sin(3 * M * rad);
  const lambda = (M + C + 180 + 102.9372) % 360;
  const jTransit = 2451545.0 + jStar + 0.0053 * Math.sin(M * rad) - 0.0069 * Math.sin(2 * lambda * rad);
  const sinDec = Math.sin(lambda * rad) * Math.sin(23.4397 * rad);
  const cosDec = Math.cos(Math.asin(sinDec));
  const cosH = (Math.sin(-0.833 * rad) - Math.sin(lat * rad) * sinDec) / (Math.cos(lat * rad) * cosDec);
  if (cosH < -1 || cosH > 1) return null;
  const H = Math.acos(cosH) / rad;
  const j = kind === 'sunrise' ? jTransit - H / 360 : jTransit + H / 360;
  return new Date((j - 2440587.5) * 86400000);
}

/** The local HH:MM a time trigger fires at on the local date [parts], or null. */
function triggerTime(trigger, parts, meta) {
  if (trigger.sun === 'sunrise' || trigger.sun === 'sunset') {
    if (!meta || typeof meta.lat !== 'number' || typeof meta.lon !== 'number') return null;
    const utc = sunTimeUtc(trigger.sun, parts.year, parts.month, parts.day, meta.lat, meta.lon);
    if (!utc) return null;
    const shifted = new Date(utc.getTime() + (trigger.offset || 0) * 60000);
    return localParts(shifted, meta.timezone).hhmm;
  }
  return Number.isNaN(toMinutes(trigger.at)) ? null : fromMinutes(toMinutes(trigger.at) + (trigger.offset || 0));
}

/** Does a device message satisfy [t] (property equals / above / below)? */
function matchesValue(t, value) {
  if (value === undefined || value === null) return false;
  if ('equals' in t) return value === t.equals;
  if ('above' in t) return typeof value === 'number' && value > t.above;
  if ('below' in t) return typeof value === 'number' && value < t.below;
  return false;
}

/**
 * Whether a device trigger fires for a message, given the previous value seen.
 * Actions (button presses) fire on every matching message; everything else fires
 * on the change into the matching state, never on a repeat of the same value.
 */
function deviceTriggerFires(trigger, previous, message) {
  if (!(trigger.property in message)) return false;
  const now = message[trigger.property];
  if (!matchesValue(trigger, now)) return false;
  if (trigger.property === 'action') return true;
  return !matchesValue(trigger, previous);
}

const KNOWN_TRIGGERS = new Set(['device', 'time']);
const KNOWN_CONDITIONS = new Set(['hours', 'device']);
const KNOWN_ACTIONS = new Set(['device', 'scene']);

/** A rule this engine can run, or the reason it can't. */
function validateRule(rule) {
  if (!rule || typeof rule !== 'object') return 'not an object';
  if (rule.v !== 1) return `schema v${rule.v}`;
  if (!rule.trigger || !KNOWN_TRIGGERS.has(rule.trigger.type)) return 'unknown trigger';
  if (!Array.isArray(rule.conditions || [])) return 'conditions';
  if ((rule.conditions || []).some((c) => !KNOWN_CONDITIONS.has(c && c.type))) return 'unknown condition';
  if (!rule.action || !KNOWN_ACTIONS.has(rule.action.type)) return 'unknown action';
  if (!Array.isArray(rule.action.commands) || rule.action.commands.length === 0) return 'no commands';
  return null;
}

/** The command that undoes [payload] for "turn off again", or null if there is none. */
function offPayload(payload) {
  if (!payload || typeof payload !== 'object') return null;
  if (payload.state === 'ON' || payload.state === 'on') return { state: 'OFF' };
  return null;
}

// ---------- alerts and history: the Node-RED flows ----------

/*@FLOWS@*/

const FLOW_TAKEOVER_MS = 90000;
const FLOW_OBSERVE_MS = 40000;
const OWN_ECHO_MS = 3000;

/** MQTT topic filter match with + and # wildcards. */
function topicMatches(filter, topic) {
  const f = filter.split('/'), t = topic.split('/');
  for (let i = 0; i < f.length; i++) {
    if (f[i] === '#') return true;
    if (i >= t.length) return false;
    if (f[i] !== '+' && f[i] !== t[i]) return false;
  }
  return f.length === t.length;
}

/** A function body's return value as Node-RED outputs: an array of message arrays. */
function outputsOf(r) {
  if (r === null || r === undefined) return [];
  if (!Array.isArray(r)) return [[r]];
  return r.map((o) => (o === null || o === undefined ? [] : Array.isArray(o) ? o : [o]));
}

// ---------- remote: sealing and topics ----------

const REMOTE_FILE = 'zigdash-remote.json';
const REMOTE_MAX_AGE_MS = 5 * 60000;

/** AES-256-GCM: iv(12) | ciphertext | tag(16). */
function seal(key, obj) {
  const crypto = require('crypto');
  const iv = crypto.randomBytes(12);
  const c = crypto.createCipheriv('aes-256-gcm', key, iv);
  const body = Buffer.concat([c.update(Buffer.from(JSON.stringify(obj))), c.final()]);
  return Buffer.concat([iv, body, c.getAuthTag()]);
}

/** The object inside [buf], or null when it was not sealed with [key]. */
function unseal(key, buf) {
  try {
    const crypto = require('crypto');
    const b = Buffer.isBuffer(buf) ? buf : Buffer.from(buf);
    if (b.length < 29) return null;
    const d = crypto.createDecipheriv('aes-256-gcm', key, b.subarray(0, 12));
    d.setAuthTag(b.subarray(b.length - 16));
    return JSON.parse(Buffer.concat([d.update(b.subarray(12, b.length - 16)), d.final()]).toString());
  } catch (_) {
    return null;
  }
}

/** A topic name the relay can't read: HMAC of the real topic with the home key. */
function opaqueId(key, topic) {
  return require('crypto').createHmac('sha256', key).update(topic).digest('hex').slice(0, 24);
}

/** Commands a phone may send from away: device set/get under [base], and automation rules. */
function remoteCommandAllowed(base, topic) {
  if (typeof topic !== 'string' || topic.includes('#') || topic.includes('+')) return false;
  if (topic.startsWith(`${base}/`) && !topic.startsWith(`${base}/bridge/`)) {
    return topic.endsWith('/set') || topic.endsWith('/get');
  }
  return /^zigdash\/automations\/rules\/[A-Za-z0-9_-]+$/.test(topic);
}

// ---------- the extension ----------

class ZigDashEngine {
  constructor(zigbee, mqtt, state, publishEntityState, eventBus, enableDisableExtension, restartCallback, addExtension, settings, logger) {
    this.zigbee = zigbee;
    this.mqtt = mqtt;
    this.stateCache = state;
    this.eventBus = eventBus;
    this.settings = settings;
    this.logger = logger;
    this.rules = new Map();
    this.unknown = {};
    this.meta = {};
    this.lastValue = new Map(); // `${ieee}|${property}` -> last value seen
    this.firedOn = new Map(); // rule id -> local date it last fired (time triggers)
    this.recent = [];
    this.crashTimes = [];
    this.stoppedSelf = false;
    this.timers = [];
    this.offTimers = new Map();
    this.clock = () => new Date();
    this.fetch = (...args) => fetch(...args);
    this.mqttConnect = (url, options) => require('mqtt').connect(url, options);
    this.remoteWipeMs = 3000; // how long "off" listens for older sealed copies to delete
    this.remote = null; // { config, key, client, connected, error }
    this.flowState = {};
    for (const name of Object.keys(FLOWS)) {
      this.flowState[name] = { store: {}, active: false, startedAt: 0, foreignAt: 0, ownAt: 0 };
    }
  }

  // ----- safety -----

  guard(where, fn) {
    return (...args) => {
      try {
        const r = fn.apply(this, args);
        if (r && typeof r.catch === 'function') r.catch((e) => this.caught(where, e));
        return r;
      } catch (e) {
        this.caught(where, e);
        return undefined;
      }
    };
  }

  caught(where, error) {
    try {
      this.log('warning', `caught in ${where}: ${error && error.message}`);
      const now = Date.now();
      this.crashTimes = this.crashTimes.filter((t) => now - t < CRASH_WINDOW_MS);
      this.crashTimes.push(now);
      if (this.crashTimes.length >= CRASH_LIMIT && !this.stoppedSelf) {
        this.stoppedSelf = true;
        this.writeStopFlag(true);
        this.log('error', 'stopped itself after repeated errors; open ZigDash to start it again');
      }
      this.publishState();
    } catch (_) { /* never throw from the guard */ }
  }

  log(level, msg) {
    try { (this.logger[level] || this.logger.info).call(this.logger, `ZigDash engine: ${msg}`); } catch (_) {}
  }

  stopFlagPath() {
    const path = require('path');
    const dir = process.env.ZIGBEE2MQTT_DATA || path.join(__dirname, '..');
    return path.join(dir, STOP_FLAG);
  }

  readStopFlag() {
    try { return require('fs').existsSync(this.stopFlagPath()); } catch (_) { return false; }
  }

  writeStopFlag(on) {
    try {
      const fs = require('fs');
      if (on) fs.writeFileSync(this.stopFlagPath(), new Date().toISOString());
      else if (fs.existsSync(this.stopFlagPath())) fs.unlinkSync(this.stopFlagPath());
    } catch (_) {}
  }

  // ----- MQTT -----

  base() { return this.settings.get().mqtt.base_topic; }

  publish(sub, payload, retain) {
    try {
      const p = this.mqtt.publish(`${PREFIX}/${sub}`, payload, { clientOptions: { retain: !!retain, qos: 1 }, baseTopic: ROOT });
      if (p && typeof p.catch === 'function') p.catch(() => {});
    } catch (_) {}
  }

  /** Publishes to a full topic like zigdash/alerts/recent. */
  publishFull(topic, payload, retain, receive) {
    try {
      const i = topic.indexOf('/');
      const options = { clientOptions: { retain: !!retain, qos: 1 }, baseTopic: topic.slice(0, i) };
      if (receive) options.skipReceive = false;
      const body = typeof payload === 'string' || Buffer.isBuffer(payload) ? payload : JSON.stringify(payload);
      const p = this.mqtt.publish(topic.slice(i + 1), body, options);
      if (p && typeof p.catch === 'function') p.catch(() => {});
    } catch (_) {}
  }

  publishState() {
    this.publish('state', JSON.stringify({
      engine: ENGINE_VERSION,
      running_on: 'hub',
      rules_loaded: this.rules.size,
      rules_unknown: Object.keys(this.unknown),
      stopped_self: this.stoppedSelf,
      remote: this.remote ? { connected: !!this.remote.connected, error: this.remote.error || undefined } : undefined,
      flows: Object.fromEntries(Object.entries(this.flowState).map(([n, f]) => [n, f.active ? 'active' : 'passive'])),
      at: this.clock().toISOString(),
    }), true);
  }

  publishRecent() { this.publish('recent', JSON.stringify(this.recent), true); }

  /** Sends one rule command: to a device by IEEE address, or to a raw /set topic under this base. */
  send(c) {
    if (c.ieee) return this.command(c.ieee, c.payload);
    const base = this.base();
    if (typeof c.topic === 'string' && c.topic.startsWith(`${base}/`) && c.topic.endsWith('/set')) {
      this.mqtt.onMessage(c.topic, Buffer.from(JSON.stringify(c.payload || {})));
      return true;
    }
    return false;
  }

  /** Sends [payload] to the device with [ieee] the way an incoming /set would arrive. */
  command(ieee, payload) {
    const entity = this.zigbee.resolveEntity(ieee);
    if (!entity) { this.log('warning', `device ${ieee} not found`); return false; }
    const topic = `${this.base()}/${entity.name}/set`;
    this.mqtt.onMessage(topic, Buffer.from(JSON.stringify(payload)));
    return true;
  }

  // ----- lifecycle -----

  async start() {
    this.stoppedSelf = this.readStopFlag();
    this.eventBus.onMQTTMessage(this, this.guard('mqtt message', this.onMqtt));
    this.eventBus.onPublishEntityState(this, this.guard('device message', this.onDevice));
    this.eventBus.onMQTTMessagePublished(this, this.guard('published', this.onPublished));
    for (const filter of [`${ROOT}/${PREFIX}/#`, `${ROOT}/remote/set`, ...Object.keys(FLOWS).map((n) => `${ROOT}/${n}/#`)]) {
      const sub = this.mqtt.subscribe(filter);
      if (sub && typeof sub.catch === 'function') sub.catch((e) => this.caught('subscribe', e));
    }
    const now = Date.now();
    for (const [name, def] of Object.entries(FLOWS)) {
      this.flowState[name].startedAt = now;
      for (const t of def.timers) {
        const fire = this.guard(`${name} timer`, () => this.deliver(name, t.to, { payload: Date.now() }));
        this.timers.push(setTimeout(fire, t.first));
        this.timers.push(setInterval(fire, t.every));
      }
    }
    this.timers.push(setInterval(this.guard('flow takeover', this.checkTakeover), 5000));
    const saved = this.readRemoteConfig();
    if (saved) this.startRemote(saved);
    this.timers.push(setInterval(this.guard('state timer', this.publishState), STATE_EVERY_MS));
    this.timers.push(setInterval(this.guard('clock timer', this.onTick), TICK_MS));
    this.publishState();
  }

  async stop() {
    this.timers.forEach((t) => clearInterval(t));
    this.offTimers.forEach((t) => clearTimeout(t));
    this.timers = [];
    this.offTimers.clear();
    try { this.eventBus.removeListeners(this); } catch (_) {}
    for (const filter of [`${ROOT}/${PREFIX}/#`, `${ROOT}/remote/set`, ...Object.keys(FLOWS).map((n) => `${ROOT}/${n}/#`)]) {
      try { await this.mqtt.unsubscribe(filter); } catch (_) {}
    }
    for (const [name, def] of Object.entries(FLOWS)) {
      if (this.flowState[name].active) this.publishFull(def.heartbeat, 'offline', true, true);
    }
    this.stopRemote();
    this.publish('state', '', true);
  }

  // ----- inputs -----

  onMqtt(data) {
    if (data.topic === `${ROOT}/remote/set`) return this.onRemoteSet(data.message);
    this.flowInput(data.topic, data.message);
    const prefix = `${ROOT}/${PREFIX}/`;
    if (!data.topic.startsWith(prefix)) return;
    const sub = data.topic.slice(prefix.length);
    if (sub.startsWith('rules/')) {
      const id = sub.slice('rules/'.length);
      if (!data.message) {
        this.rules.delete(id);
        delete this.unknown[id];
      } else {
        const rule = JSON.parse(data.message);
        const problem = validateRule(rule);
        if (problem) { this.rules.delete(id); this.unknown[id] = problem; } else { delete this.unknown[id]; this.rules.set(id, rule); }
      }
      this.publishState();
    } else if (sub === 'meta') {
      this.meta = data.message ? JSON.parse(data.message) : {};
    } else if (sub === 'control') {
      const cmd = data.message ? JSON.parse(data.message).cmd : null;
      if (cmd === 'start') {
        this.stoppedSelf = false;
        this.crashTimes = [];
        this.writeStopFlag(false);
        this.publishState();
      }
    }
  }

  onDevice(data) {
    const entity = data.entity;
    if (!entity || typeof entity.isDevice !== 'function' || !entity.isDevice()) return;
    const ieee = entity.ieeeAddr;
    const message = data.message || {};
    const before = {};
    for (const key of Object.keys(message)) before[key] = this.lastValue.get(`${ieee}|${key}`);
    for (const key of Object.keys(message)) this.lastValue.set(`${ieee}|${key}`, message[key]);
    if (this.stoppedSelf) return;
    for (const [id, rule] of this.rules) {
      const t = rule.trigger;
      if (rule.enabled === false || t.type !== 'device' || t.ieee !== ieee) continue;
      if (deviceTriggerFires(t, before[t.property], message)) this.run(id, rule);
    }
  }

  onTick() {
    if (this.stoppedSelf) return;
    const parts = localParts(this.clock(), this.meta.timezone);
    for (const [id, rule] of this.rules) {
      const t = rule.trigger;
      if (rule.enabled === false || t.type !== 'time') continue;
      if (Array.isArray(t.days) && t.days.length && !t.days.includes(parts.weekday)) continue;
      if (triggerTime(t, parts, this.meta) !== parts.hhmm) continue;
      if (this.firedOn.get(id) === parts.date) continue;
      this.firedOn.set(id, parts.date);
      this.run(id, rule);
    }
  }

  // ----- alerts and history flows -----

  /** Every message Zigbee2MQTT publishes: device state for the flows' "devices" inputs. */
  onPublished(data) {
    const base = this.base();
    if (!data || typeof data.topic !== 'string' || !data.topic.startsWith(`${base}/`)) return;
    this.remoteUp(data.topic, data.payload);
    for (const [name, def] of Object.entries(FLOWS)) {
      for (const input of def.inputs) {
        if (input.devices) this.deliver(name, input.to, { topic: data.topic, payload: String(data.payload) });
      }
    }
  }

  /** A message on zigdash/<flow>/...: a flow input, or a heartbeat from a Node-RED copy. */
  flowInput(topic, message) {
    for (const [name, def] of Object.entries(FLOWS)) {
      if (topic === def.heartbeat) {
        this.onHeartbeat(name, message);
        continue;
      }
      for (const input of def.inputs) {
        if (input.topic && topicMatches(input.topic, topic)) this.deliver(name, input.to, { topic, payload: message });
      }
    }
  }

  onHeartbeat(name, message) {
    const f = this.flowState[name];
    const now = Date.now();
    if (String(message).trim() !== 'online') return;
    if (now - f.startedAt < OWN_ECHO_MS) return; // the retained copy, delivered on subscribe
    if (f.active && now - f.ownAt < OWN_ECHO_MS) return; // our own beat coming back
    f.foreignAt = now;
    if (f.active) {
      f.active = false;
      this.log('info', `${name}: Node-RED is running this flow too; ZigDash stays passive`);
      this.publishState();
    }
  }

  checkTakeover() {
    const now = Date.now();
    let changed = false;
    for (const [name, f] of Object.entries(this.flowState)) {
      if (f.active) continue;
      if (now - f.startedAt < FLOW_OBSERVE_MS) continue;
      if (f.foreignAt && now - f.foreignAt < FLOW_TAKEOVER_MS) continue;
      f.active = true;
      changed = true;
      this.log('info', `${name}: running in ZigDash`);
    }
    if (changed) this.publishState();
  }

  /** Runs one function body with [msg] and routes what it returns along its wires. */
  deliver(flowName, fnName, msg) {
    const def = FLOWS[flowName];
    const f = this.flowState[flowName];
    const body = def.fns[fnName];
    if (!body) return;
    const flow = { get: (k) => f.store[k], set: (k, v) => { f.store[k] = v; } };
    const node = {
      warn: (w) => this.log('warning', `${flowName}/${fnName}: ${w}`),
      error: (w) => this.log('error', `${flowName}/${fnName}: ${w}`),
    };
    const env = { get: () => undefined };
    const outs = outputsOf(body(msg, flow, env, node, Buffer, require('crypto')));
    const wires = def.wires[fnName] || [];
    outs.forEach((messages, port) => {
      for (const target of wires[port] || []) {
        for (const m of messages) {
          if (target === 'out') this.flowPublish(flowName, m);
          else if (target === 'http') this.flowHttp(flowName, m);
          else this.deliver(flowName, target, m);
        }
      }
    });
  }

  flowPublish(flowName, m) {
    const f = this.flowState[flowName];
    if (!f.active || !m || typeof m.topic !== 'string') return;
    const heartbeat = m.topic === FLOWS[flowName].heartbeat;
    if (heartbeat) f.ownAt = Date.now();
    this.publishFull(m.topic, m.payload === undefined ? '' : m.payload, m.retain === true || m.retain === 'true', heartbeat);
  }

  flowHttp(flowName, m) {
    const f = this.flowState[flowName];
    if (!f.active || !m || !m.url) return;
    const def = FLOWS[flowName];
    const body = m.payload === undefined || m.payload === null ? undefined
      : Buffer.isBuffer(m.payload) || typeof m.payload === 'string' ? m.payload : JSON.stringify(m.payload);
    const done = this.guard(`${flowName} http`, (statusCode, text) => {
      if (def.httpTo) this.deliver(flowName, def.httpTo, { ...m, statusCode, payload: text });
    });
    Promise.resolve()
      .then(() => this.fetch(m.url, { method: m.method || 'POST', headers: m.headers || {}, body }))
      .then((res) => res.text().then((text) => done(res.status, text)))
      .catch((e) => done(0, String(e && e.message)));
  }

  // ----- remote -----

  remoteFilePath() {
    const path = require('path');
    return path.join(process.env.ZIGBEE2MQTT_DATA || path.join(__dirname, '..'), REMOTE_FILE);
  }

  readRemoteConfig() {
    try {
      const fs = require('fs');
      if (!fs.existsSync(this.remoteFilePath())) return null;
      return JSON.parse(fs.readFileSync(this.remoteFilePath(), 'utf8'));
    } catch (_) {
      return null;
    }
  }

  /** zigdash/remote/set from the app at home: {url, homeId, username, password, key} or {off: true}. */
  onRemoteSet(message) {
    const fs = require('fs');
    const cfg = message ? JSON.parse(message) : null;
    const off = !cfg || cfg.off === true;
    this.stopRemote({ wipe: off });
    if (off) {
      try { fs.unlinkSync(this.remoteFilePath()); } catch (_) {}
      this.remote = null;
      this.publishState();
      return;
    }
    if (!cfg.url || !cfg.homeId || !cfg.username || !cfg.password || !cfg.key) return;
    fs.writeFileSync(this.remoteFilePath(), JSON.stringify(cfg), { mode: 0o600 });
    this.startRemote(cfg);
  }

  startRemote(cfg) {
    const key = Buffer.from(cfg.key, 'base64');
    if (key.length !== 32) {
      this.remote = { config: cfg, connected: false, error: 'bad key' };
      this.publishState();
      return;
    }
    const prefix = `homes/${cfg.homeId}`;
    const client = this.mqttConnect(cfg.url, {
      username: cfg.username,
      password: cfg.password,
      clientId: `hub-${cfg.homeId}`,
      protocolVersion: 5,
      reconnectPeriod: 15000,
      connectTimeout: 20000,
      clean: true,
      will: { topic: `${prefix}/hub`, payload: Buffer.from('offline'), qos: 1, retain: true },
    });
    const remote = { config: cfg, key, client, prefix, connected: false, error: undefined, sent: new Set(), pending: new Map() };
    this.remote = remote;
    // An mqtt client without an error listener would crash Zigbee2MQTT.
    const current = () => this.remote === remote;
    client.on('error', this.guard('remote error', (e) => {
      if (!current()) return;
      remote.error = String((e && (e.code || e.message)) || 'error').slice(0, 60);
      this.publishState();
    }));
    client.on('connect', this.guard('remote connect', () => {
      if (!current()) return;
      remote.connected = true;
      remote.error = undefined;
      client.publish(`${prefix}/hub`, 'online', { qos: 1, retain: true });
      client.subscribe(`${prefix}/c`, { qos: 1, nl: true });
      const missed = [...remote.pending];
      remote.pending.clear();
      for (const [topic, payload] of missed) this.remoteSend(remote, topic, payload);
      this.publishState();
    }));
    client.on('close', this.guard('remote close', () => {
      if (!current()) return;
      if (remote.connected) {
        remote.connected = false;
        this.publishState();
      }
    }));
    client.on('message', this.guard('remote message', (topic, payload) => {
      if (!current()) return;
      if (topic === `${prefix}/c`) this.remoteDown(payload);
    }));
    this.publishState();
  }

  /**
   * Leaves the relay. With [wipe] (remote turned off), first deletes this
   * Home's sealed copies there: the ones sent since start at once, older ones
   * as the relay hands them back retained, and the hub's presence flag.
   */
  stopRemote({ wipe = false } = {}) {
    const r = this.remote;
    if (!r || !r.client) return;
    const client = r.client;
    try {
      if (wipe && r.connected) {
        const clear = (t) => client.publish(t, '', { qos: 1, retain: true });
        r.sent.forEach(clear);
        clear(`${r.prefix}/hub`);
        client.on('message', this.guard('remote wipe', (topic, payload, packet) => {
          if (topic.startsWith(`${r.prefix}/s/`) && payload && payload.length && (!packet || packet.retain)) clear(topic);
        }));
        client.subscribe(`${r.prefix}/s/#`, { qos: 1 });
        setTimeout(this.guard('remote wipe end', () => client.end(false)), this.remoteWipeMs);
      } else {
        if (r.connected) client.publish(`${r.prefix}/hub`, 'offline', { qos: 1, retain: true });
        client.end(false);
      }
    } catch (_) {}
    r.connected = false;
  }

  /** A device state Zigbee2MQTT published: sealed up to the relay, retained. */
  remoteUp(topic, payload) {
    const r = this.remote;
    if (!r) return;
    const base = this.base();
    if (topic.startsWith(`${base}/bridge/`) || topic.endsWith('/set') || topic.endsWith('/get')) return;
    // 3.1.5: while the relay can't be reached (the home's internet down),
    // keep the latest of each device and send it on reconnect, so a phone
    // away never sees a value from before the outage. One entry per topic.
    if (!r.connected) {
      r.pending.set(topic, String(payload));
      return;
    }
    this.remoteSend(r, topic, String(payload));
  }

  remoteSend(r, topic, payload) {
    const body = seal(r.key, { topic, payload, at: Date.now() });
    const up = `${r.prefix}/s/${opaqueId(r.key, topic)}`;
    r.sent.add(up);
    r.client.publish(up, body, { qos: 0, retain: true });
  }

  /** A sealed command from a phone away from home. */
  remoteDown(payload) {
    const r = this.remote;
    const msg = unseal(r.key, payload);
    if (!msg || typeof msg.at !== 'number' || Math.abs(Date.now() - msg.at) > REMOTE_MAX_AGE_MS) return;
    const base = this.base();
    // A paired phone away from home may switch remote control off (never on,
    // never a new login): that is how "Turn off" works from the relay.
    if (msg.topic === `${ROOT}/remote/set`) {
      let body = null;
      try { body = typeof msg.payload === 'string' ? JSON.parse(msg.payload) : msg.payload; } catch (_) {}
      if (body && body.off === true) this.onRemoteSet(JSON.stringify({ off: true }));
      return;
    }
    if (!remoteCommandAllowed(base, msg.topic)) return;
    const body = typeof msg.payload === 'string' ? msg.payload : JSON.stringify(msg.payload ?? '');
    if (msg.topic.startsWith(`${base}/`)) {
      this.mqtt.onMessage(msg.topic, Buffer.from(body));
    } else {
      this.publishFull(msg.topic, body, true);
    }
  }

  // ----- running a rule -----

  conditionsHold(rule) {
    const hhmm = localParts(this.clock(), this.meta.timezone).hhmm;
    return (rule.conditions || []).every((c) => {
      if (c.type === 'hours') return withinHours(hhmm, c.from, c.to);
      if (c.type === 'device') return matchesValue(c, this.lastValue.get(`${c.ieee}|${c.property}`));
      return false;
    });
  }

  run(id, rule) {
    if (!this.conditionsHold(rule)) return;
    const sent = rule.action.commands.filter((c) => this.send(c)).length;
    const minutes = rule.action.offAfter || 0;
    if (minutes > 0) {
      const offs = rule.action.commands.map((c) => ({ ieee: c.ieee, topic: c.topic, payload: offPayload(c.payload) })).filter((c) => c.payload);
      if (offs.length) {
        clearTimeout(this.offTimers.get(id));
        this.offTimers.set(id, setTimeout(this.guard('off timer', () => {
          this.offTimers.delete(id);
          offs.forEach((c) => this.send(c));
        }), minutes * 60000));
      }
    }
    this.recent.unshift({ id, at: this.clock().toISOString(), commands: sent, off_after: minutes || undefined });
    this.recent = this.recent.slice(0, RECENT_MAX);
    this.publishRecent();
  }
}

ZigDashEngine.ENGINE_VERSION = ENGINE_VERSION;
ZigDashEngine.FLOWS = FLOWS;
ZigDashEngine.helpers = { seal, unseal, opaqueId, remoteCommandAllowed, topicMatches, outputsOf,  localParts, withinHours, sunTimeUtc, triggerTime, matchesValue, deviceTriggerFires, validateRule, offPayload, toMinutes, fromMinutes };
module.exports = ZigDashEngine;
