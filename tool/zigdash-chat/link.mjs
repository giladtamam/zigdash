// One Chat client's line to the Engine: sealed requests out, sealed answers
// back, over the home broker or the relay (one MQTT connection either way).
// Every request has a fresh random id and a time; the Engine's time in each
// answer corrects for a drifting hub clock, and a "stale" answer is retried
// once with a new id and the corrected time.

import { chatTopics, newRequestId, seal, unseal } from './wire.mjs';

export class LinkError extends Error {
  constructor(code, message) {
    super(message || code);
    this.code = code; // 'not_linked' | 'timeout' | 'offline'
  }
}

export class HomeLink {
  /**
   * [mqtt]: a connected client with publish(topic, payload, opts), subscribe(topic, opts), on('message').
   * [onSend]: optional hook (topic, payload) for the replay test; never used by the service.
   */
  constructor({ mqtt, transport = 'broker', homeId, clientId, token, key, timeoutMs = 8000, onSend, now = Date.now }) {
    this.mqtt = mqtt;
    this.clientId = clientId;
    this.token = token;
    this.key = Buffer.isBuffer(key) ? key : Buffer.from(key, 'base64');
    this.topics = chatTopics({ transport, clientId, key: this.key, homeId });
    this.timeoutMs = timeoutMs;
    this.onSend = onSend;
    this.now = now;
    this.offsetMs = 0; // Engine clock minus ours, from the last answer
    this.pending = new Map(); // request id -> { resolve, reject, timer, tool, args, retried }
    this.onMessage = (topic, payload) => { if (topic === this.topics.res) this.receive(String(payload)); };
  }

  async start() {
    this.mqtt.on('message', this.onMessage);
    await new Promise((resolve, reject) => this.mqtt.subscribe(this.topics.res, { qos: 1 }, (e) => (e ? reject(e) : resolve())));
  }

  stop() {
    this.mqtt.removeListener?.('message', this.onMessage);
    for (const p of this.pending.values()) { clearTimeout(p.timer); p.reject(new LinkError('offline', 'stopped')); }
    this.pending.clear();
  }

  /** The Engine's answer to one tool call: {ok, result, error}. Throws LinkError. */
  request(tool, args = {}, { timeoutMs = this.timeoutMs } = {}) {
    return new Promise((resolve, reject) => {
      const entry = { resolve, reject, tool, args, retried: false, timer: null };
      entry.timer = setTimeout(() => {
        for (const [id, p] of this.pending) if (p === entry) this.pending.delete(id);
        reject(new LinkError('timeout', 'the home did not answer'));
      }, timeoutMs);
      this.send(entry);
    });
  }

  send(entry) {
    const id = newRequestId();
    this.pending.set(id, entry);
    const body = { id, at: this.now() + this.offsetMs, token: this.token, tool: entry.tool, args: entry.args };
    const payload = seal(this.key, body);
    if (this.onSend) this.onSend(this.topics.req, payload);
    this.mqtt.publish(this.topics.req, payload, { qos: 1, retain: false });
  }

  receive(text) {
    if (text.startsWith('{')) {
      // Plain answers carry no data: only "this client is not linked" (revoked on the Engine).
      let plain = null;
      try { plain = JSON.parse(text); } catch { return; }
      if (plain && plain.error === 'not_linked') {
        for (const p of new Set(this.pending.values())) { clearTimeout(p.timer); p.reject(new LinkError('not_linked', 'not linked')); }
        this.pending.clear();
      }
      return;
    }
    const msg = unseal(this.key, text);
    if (!msg || typeof msg.id !== 'string') return;
    const entry = this.pending.get(msg.id);
    if (!entry) return; // an answer we no longer wait for, or a replayed one
    this.pending.delete(msg.id);
    if (typeof msg.at === 'number') this.offsetMs = msg.at - this.now();
    if (msg.error === 'stale' && !entry.retried) {
      entry.retried = true;
      this.send(entry);
      return;
    }
    clearTimeout(entry.timer);
    entry.resolve({ ok: msg.ok === true, result: msg.result, error: msg.error });
  }
}
