#!/usr/bin/env node
// Links a Home by hand for milestone 1: creates a Chat client on the hub's
// Engine and keeps its token and key in the encrypted keys file. Uses the
// same environment as service.mjs (ZIGDASH_MQTT_URL, ZIGDASH_CHAT_KEYS,
// ZIGDASH_CHAT_SECRETS, ...). create, set-controls and revoke write retained
// config, so they run against the hub's own broker (at home), never through
// the relay. Tokens and keys are never printed.
//
//   node cli.mjs create [--id tg1] [--name "Owner's Telegram"] [--scope control|read]
//                       [--controls "Office shutter,0x00158d0001a2b3c4"] [--home-id <relay home id>]
//   node cli.mjs list
//   node cli.mjs set-controls <id> "<name or ieee>,..." [--scope control|read]
//   node cli.mjs revoke <id> [--hub-only]      (--hub-only keeps the local keys: the acceptance test)
//   node cli.mjs audit [<id>] [--limit 50] [--retained]
//   node cli.mjs topics <id>                   (the relay topics, for the service's broker role)

import crypto from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { loadServiceKey, readKeys, writeKeys, readSecretFile } from './keystore.mjs';
import { configFromEnv } from './service.mjs';
import { HomeLink } from './link.mjs';
import { chatTopics, sha256, CLIENT_ID_RE } from './wire.mjs';

function parseArgs(argv) {
  const out = { _: [] };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const name = a.slice(2);
      const next = argv[i + 1];
      if (next === undefined || next.startsWith('--')) out[name] = true;
      else { out[name] = next; i++; }
    } else out._.push(a);
  }
  return out;
}

const publish = (mqtt, topic, payload) => new Promise((resolve, reject) =>
  mqtt.publish(topic, payload, { qos: 1, retain: true }, (e) => (e ? reject(e) : resolve())));

/** The first retained message on [topic], or null after [ms]. */
function retained(mqtt, topic, ms = 4000) {
  return new Promise((resolve) => {
    const done = (v) => { clearTimeout(timer); mqtt.removeListener('message', on); mqtt.unsubscribe(topic); resolve(v); };
    const on = (t, payload) => { if (t === topic) done(String(payload)); };
    const timer = setTimeout(() => done(null), ms);
    mqtt.on('message', on);
    mqtt.subscribe(topic, { qos: 1 });
  });
}

/** Device names or IEEE addresses to IEEE addresses, from Zigbee2MQTT's retained device list. */
async function resolveControls(mqtt, base, list) {
  const wanted = String(list || '').split(',').map((s) => s.trim()).filter(Boolean);
  if (!wanted.length) return [];
  const devices = JSON.parse((await retained(mqtt, `${base}/bridge/devices`)) || '[]');
  return wanted.map((w) => {
    const d = devices.find((x) => x.ieee_address === w || x.friendly_name === w);
    if (!d && /^0x[0-9a-f]{16}$/i.test(w)) return w.toLowerCase();
    if (!d) throw new Error(`no device "${w}" in ${base}/bridge/devices`);
    return d.ieee_address;
  });
}

function clientConfig(entry) {
  return JSON.stringify({ v: 1, name: entry.name, hash: sha256(entry.token), key: entry.key, scope: entry.scope, controls: entry.controls });
}

export async function runCli(argv, { config = configFromEnv(), mqtt, print = console.log, base = process.env.ZIGDASH_BASE_TOPIC || 'zigbee2mqtt' } = {}) {
  const args = parseArgs(argv);
  const cmd = args._[0];
  const serviceKey = loadServiceKey(config.secretsFile, { create: cmd === 'create' });
  const keys = readKeys(config.keysFile, serviceKey);
  const atHome = () => { if (config.transport === 'relay') throw new Error(`${cmd} writes to the hub's broker: run it at home with ZIGDASH_TRANSPORT=broker`); };
  const need = (id) => {
    if (!keys.clients[id]) throw new Error(`no client "${id}" in the keys file`);
    return keys.clients[id];
  };

  switch (cmd) {
    case 'create': {
      atHome();
      const id = args.id || `tg-${crypto.randomBytes(3).toString('hex')}`;
      if (!CLIENT_ID_RE.test(id)) throw new Error('the id may hold letters, digits, - and _ (40 at most)');
      if (keys.clients[id]) throw new Error(`client "${id}" exists: revoke it first`);
      const entry = {
        name: typeof args.name === 'string' ? args.name.slice(0, 40) : 'Telegram',
        token: crypto.randomBytes(32).toString('base64url'),
        key: crypto.randomBytes(32).toString('base64'),
        scope: args.scope === 'read' ? 'read' : 'control',
        controls: await resolveControls(mqtt, base, args.controls),
        home_id: typeof args['home-id'] === 'string' ? args['home-id'] : null,
        created_at: new Date().toISOString(),
      };
      // Keys first: a client on the hub whose key we lost could never be used.
      keys.clients[id] = entry;
      writeKeys(config.keysFile, serviceKey, keys);
      await publish(mqtt, `zigdash/chat/clients/${id}`, clientConfig(entry));
      print(`created ${id} (${entry.scope}, ${entry.controls.length} devices on the control list); token and key are in ${config.keysFile}`);
      return id;
    }
    case 'list': {
      const rows = Object.entries(keys.clients);
      if (!rows.length) print('no clients');
      for (const [id, c] of rows) print(`${id}  ${c.name}  ${c.scope}  controls=${(c.controls || []).length}  home=${c.home_id || '-'}  created=${c.created_at}`);
      return rows.length;
    }
    case 'set-controls': {
      atHome();
      const id = args._[1];
      const entry = need(id);
      entry.controls = await resolveControls(mqtt, base, args._[2] || '');
      if (args.scope === 'read' || args.scope === 'control') entry.scope = args.scope;
      writeKeys(config.keysFile, serviceKey, keys);
      await publish(mqtt, `zigdash/chat/clients/${id}`, clientConfig(entry));
      print(`${id}: ${entry.controls.length} devices on the control list, scope ${entry.scope}`);
      return entry.controls;
    }
    case 'revoke': {
      atHome();
      const id = args._[1];
      if (!CLIENT_ID_RE.test(String(id || ''))) throw new Error('revoke <id>');
      await publish(mqtt, `zigdash/chat/clients/${id}`, '');
      if (!args['hub-only'] && keys.clients[id]) {
        delete keys.clients[id];
        writeKeys(config.keysFile, serviceKey, keys);
      }
      print(`revoked ${id} on the Engine${args['hub-only'] ? ' (local keys kept)' : ' and removed its keys'}`);
      return id;
    }
    case 'audit': {
      const limit = Math.min(200, Number(args.limit) || 50);
      let entries;
      if (args.retained) {
        atHome();
        entries = JSON.parse((await retained(mqtt, 'zigdash/chat/audit')) || '[]');
        if (args._[1]) entries = entries.filter((e) => e.client === args._[1]);
      } else {
        const ids = Object.keys(keys.clients);
        const id = args._[1] || (ids.length === 1 ? ids[0] : null);
        const entry = need(id);
        const link = new HomeLink({ mqtt, transport: config.transport, homeId: config.homeId || entry.home_id, clientId: id, token: entry.token, key: entry.key });
        await link.start();
        try {
          const res = await link.request('audit', { limit });
          entries = (res.result && res.result.entries) || [];
        } finally {
          link.stop();
        }
      }
      entries = entries.slice(0, limit);
      if (!entries.length) print('no entries');
      for (const e of entries) print(`${e.at}  ${e.client}  ${e.tool}  ${e.device || '-'}  ${e.result}`);
      return entries;
    }
    case 'topics': {
      const id = args._[1];
      const entry = need(id);
      const homeId = config.homeId || entry.home_id;
      if (!homeId) throw new Error('set --home-id at create, or ZIGDASH_HOME_ID');
      const t = chatTopics({ transport: 'relay', clientId: id, key: Buffer.from(entry.key, 'base64'), homeId });
      print(`requests (service publishes): ${t.req}\nanswers  (service subscribes): ${t.res}`);
      return t;
    }
    default:
      throw new Error('usage: cli.mjs create|list|set-controls|revoke|audit|topics (see the top of cli.mjs)');
  }
}

async function main() {
  const config = configFromEnv();
  const cmd = process.argv[2];
  let mqtt = null;
  if (['create', 'set-controls', 'revoke', 'audit'].includes(cmd)) {
    const { connect } = await import('mqtt');
    mqtt = connect(config.mqttUrl, {
      username: config.mqttUser,
      password: config.mqttPasswordFile ? readSecretFile(config.mqttPasswordFile) : undefined,
      clientId: `zigdash-chat-cli-${crypto.randomBytes(4).toString('hex')}`,
      reconnectPeriod: 0, connectTimeout: 10000,
    });
    await new Promise((resolve, reject) => { mqtt.once('connect', resolve); mqtt.once('error', reject); });
  }
  try {
    await runCli(process.argv.slice(2), { config, mqtt });
  } finally {
    if (mqtt) await new Promise((r) => mqtt.end(false, {}, r));
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((e) => { console.error(`cli: ${e && e.message}`); process.exit(1); });
}
