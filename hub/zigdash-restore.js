// ZigDash restore: puts a Zigbee2MQTT backup (bridge/request/backup's zip)
// back into the data folder, once. Installed by the ZigDash app as a
// Zigbee2MQTT external extension only for a restore, and gone after it.
// Open source: https://github.com/giladtamam/zigdash/tree/main/hub
// Design: docs/design/hub-backup.md, "Restoring".
//
//   zigdash/backup/restore         app -> hub   {tx, zip: base64}, not retained
//   zigdash/backup/restore/result  hub -> app   {tx, status: 'writing' | 'error', files?, error?}
//
// The files are written, the current ones kept in zigdash-restore-previous/
// <stamp>/, this file deletes itself, and Zigbee2MQTT is stopped hard: a
// clean stop would save the database and the coordinator backup over the
// restored ones. The service manager (OpenRC, Docker, the add-on) starts
// it again on the restored files.

'use strict';

const ROOT = 'zigdash/backup/restore';
const SELF = 'zigdash-restore.js';
/** Added to the network key's frame counter: a backup is up to a day old,
 *  and devices ignore a coordinator whose counter went backwards. */
const COUNTER_MARGIN = 100000;

// ---------- pure helpers (exported for tests) ----------

/** The files in a zip, as [{name, data}]; stored and deflated entries. */
function unzip(buf) {
  const zlib = require('zlib');
  let eocd = -1;
  for (let i = buf.length - 22; i >= Math.max(0, buf.length - 65557); i--) {
    if (buf.readUInt32LE(i) === 0x06054b50) { eocd = i; break; }
  }
  if (eocd < 0) throw new Error('not a zip');
  const count = buf.readUInt16LE(eocd + 10);
  let p = buf.readUInt32LE(eocd + 16);
  const out = [];
  for (let n = 0; n < count; n++) {
    if (buf.readUInt32LE(p) !== 0x02014b50) throw new Error('bad central directory');
    const method = buf.readUInt16LE(p + 10);
    const size = buf.readUInt32LE(p + 20);
    const nameLen = buf.readUInt16LE(p + 28);
    const extraLen = buf.readUInt16LE(p + 30);
    const commentLen = buf.readUInt16LE(p + 32);
    const local = buf.readUInt32LE(p + 42);
    const name = buf.toString('utf8', p + 46, p + 46 + nameLen);
    p += 46 + nameLen + extraLen + commentLen;
    if (buf.readUInt32LE(local) !== 0x04034b50) throw new Error('bad local header');
    const start = local + 30 + buf.readUInt16LE(local + 26) + buf.readUInt16LE(local + 28);
    const raw = buf.subarray(start, start + size);
    if (name.endsWith('/')) continue;
    if (method === 0) out.push({ name, data: Buffer.from(raw) });
    else if (method === 8) out.push({ name, data: zlib.inflateRawSync(raw) });
    else throw new Error(`unsupported compression ${method}`);
  }
  return out;
}

/** Whether a zip entry may be written into the data folder. */
function writable(name) {
  if (typeof name !== 'string' || name === '') return false;
  if (name.startsWith('/') || name.includes('\\') || name.includes('\0')) return false;
  const parts = name.split('/');
  if (parts.some((s) => s === '' || s === '.' || s === '..')) return false;
  if (parts[0] === 'log' || name.endsWith('.log')) return false;
  if (parts[0] === 'zigdash-restore-previous') return false;
  if (parts[parts.length - 1] === SELF) return false;
  return true;
}

/** The coordinator backup with its frame counter moved past the margin. */
function bumpCounter(data) {
  try {
    const j = JSON.parse(data.toString('utf8'));
    const key = j && j.network_key;
    if (key && typeof key.frame_counter === 'number') {
      key.frame_counter += COUNTER_MARGIN;
      return Buffer.from(JSON.stringify(j, null, 2));
    }
  } catch (_) {}
  return data;
}

// ---------- the extension ----------

class ZigDashRestore {
  constructor(zigbee, mqtt, state, publishEntityState, eventBus, enableDisableExtension, restartCallback, addExtension, settings, logger) {
    this.mqtt = mqtt;
    this.eventBus = eventBus;
    this.logger = logger;
    const path = require('path');
    this.dataDir = process.env.ZIGBEE2MQTT_DATA || path.join(__dirname, '..');
    this.selfPath = path.join(__dirname, SELF);
    this.fs = require('fs');
    this.exit = () => process.kill(process.pid, 'SIGKILL');
    this.busy = false;
  }

  async start() {
    this.eventBus.onMQTTMessage(this, (data) => {
      if (data.topic !== ROOT) return;
      try { this.onRestore(data.message); } catch (e) { this.log('error', `restore failed: ${e && e.message}`); }
    });
    const sub = this.mqtt.subscribe(ROOT);
    if (sub && typeof sub.catch === 'function') sub.catch(() => {});
  }

  async stop() {
    try { this.eventBus.removeListeners(this); } catch (_) {}
    try { await this.mqtt.unsubscribe(ROOT); } catch (_) {}
  }

  log(level, msg) {
    try { this.logger[level](`[zigdash-restore] ${msg}`); } catch (_) {}
  }

  answer(body) {
    const i = ROOT.indexOf('/');
    try {
      this.mqtt.publish(`${ROOT.slice(i + 1)}/result`, JSON.stringify(body), {
        clientOptions: { retain: false, qos: 1 },
        baseTopic: ROOT.slice(0, i),
      });
    } catch (_) {}
  }

  onRestore(message) {
    if (this.busy) return;
    let req;
    try { req = JSON.parse(String(message)); } catch (_) { return; }
    const tx = req && req.tx;
    if (!req || typeof req.zip !== 'string') return this.answer({ tx, status: 'error', error: 'no zip' });
    let files;
    try {
      files = unzip(Buffer.from(req.zip, 'base64')).filter((f) => writable(f.name));
    } catch (e) {
      return this.answer({ tx, status: 'error', error: String(e && e.message) });
    }
    if (!files.some((f) => f.name === 'configuration.yaml')) {
      return this.answer({ tx, status: 'error', error: 'no configuration.yaml' });
    }
    this.busy = true;
    this.write(files);
    this.log('warning', `restored ${files.length} files; stopping so they are read on start`);
    this.answer({ tx, status: 'writing', files: files.length });
    try { this.fs.unlinkSync(this.selfPath); } catch (_) {}
    // Let the answer leave before the hard stop.
    setTimeout(() => this.exit(), 1500);
  }

  write(files) {
    const fs = this.fs;
    const path = require('path');
    const stamp = new Date().toISOString().replace(/[:.]/g, '-');
    const keep = path.join(this.dataDir, 'zigdash-restore-previous', stamp);
    fs.mkdirSync(keep, { recursive: true });
    for (const f of files) {
      const target = path.join(this.dataDir, f.name);
      if (fs.existsSync(target)) {
        fs.mkdirSync(path.dirname(path.join(keep, f.name)), { recursive: true });
        fs.copyFileSync(target, path.join(keep, f.name));
      }
    }
    for (const f of files) {
      const target = path.join(this.dataDir, f.name);
      const data = f.name === 'coordinator_backup.json' ? bumpCounter(f.data) : f.data;
      fs.mkdirSync(path.dirname(target), { recursive: true });
      const tmp = `${target}.zigdash-restore`;
      const fd = fs.openSync(tmp, 'w');
      try { fs.writeSync(fd, data); fs.fsyncSync(fd); } finally { fs.closeSync(fd); }
      fs.renameSync(tmp, target);
    }
  }
}

module.exports = ZigDashRestore;
module.exports.unzip = unzip;
module.exports.writable = writable;
module.exports.bumpCounter = bumpCounter;
module.exports.COUNTER_MARGIN = COUNTER_MARGIN;
