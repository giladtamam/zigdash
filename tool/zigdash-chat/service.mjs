#!/usr/bin/env node
// ZigDash Chat, milestone 1 (docs/design/whatsapp-assistant.md, revision 6):
// the owner's Telegram chat talks to the owner's home through the 9.0.0-chat
// Engine, over the home broker or the ZigDash relay. Configuration (all paths
// may start with ~/; secrets are read from files and never printed):
//
//   TELEGRAM_TOKEN_FILE      the dev bot's token             (~/.config/zigdash/dev_bot_token)
//   ALLOWED_CHATS_FILE       allowed Telegram chat ids, one per line (~/.config/zigdash/dev_allowed_chat_ids)
//   ANTHROPIC_API_KEY, or ANTHROPIC_KEY_FILE                 (~/.config/zigdash/anthropic_key)
//   ZIGDASH_CHAT_KEYS        the encrypted keys file (cli.mjs writes it)   (~/.config/zigdash/chat-keys.json)
//   ZIGDASH_CHAT_SECRETS     the service key that opens it                 (~/.config/zigdash/chat-secrets.json)
//   ZIGDASH_CHAT_CLIENT      which client in the keys file (default: the only one)
//   ZIGDASH_TRANSPORT        broker (home broker) or relay                 (broker)
//   ZIGDASH_MQTT_URL         mqtt://<hub>:1883, or mqtts://relay.zigdash.app:8883
//   ZIGDASH_MQTT_USER, ZIGDASH_MQTT_PASSWORD_FILE   the MQTT login, if any
//   ZIGDASH_HOME_ID          the relay home id (default: the client's home_id from the CLI)
//   MODEL                    (claude-haiku-5-5)        TIME_ZONE (the host's)

import fs from 'node:fs';
import crypto from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { expandHome, keyring, loadServiceKey, readSecretFile } from './keystore.mjs';
import { HomeLink } from './link.mjs';
import { makeAgent, DEFAULT_MODEL } from './agent.mjs';
import { startTelegram } from './telegram.mjs';
import { makeMetrics } from './metrics.mjs';

export function configFromEnv(env = process.env) {
  const path = (name, fallback) => expandHome(env[name] || fallback);
  return {
    tokenFile: path('TELEGRAM_TOKEN_FILE', '~/.config/zigdash/dev_bot_token'),
    allowedFile: path('ALLOWED_CHATS_FILE', '~/.config/zigdash/dev_allowed_chat_ids'),
    anthropicKeyFile: path('ANTHROPIC_KEY_FILE', '~/.config/zigdash/anthropic_key'),
    keysFile: path('ZIGDASH_CHAT_KEYS', '~/.config/zigdash/chat-keys.json'),
    secretsFile: path('ZIGDASH_CHAT_SECRETS', '~/.config/zigdash/chat-secrets.json'),
    clientId: env.ZIGDASH_CHAT_CLIENT || null,
    transport: env.ZIGDASH_TRANSPORT === 'relay' ? 'relay' : 'broker',
    mqttUrl: env.ZIGDASH_MQTT_URL || 'mqtt://127.0.0.1:1883',
    mqttUser: env.ZIGDASH_MQTT_USER || undefined,
    mqttPasswordFile: env.ZIGDASH_MQTT_PASSWORD_FILE ? expandHome(env.ZIGDASH_MQTT_PASSWORD_FILE) : null,
    homeId: env.ZIGDASH_HOME_ID || null,
    model: env.MODEL || DEFAULT_MODEL,
    timeZone: env.TIME_ZONE || undefined,
  };
}

/** The allowed chat ids, read again when the file changes. Never logged. */
export function allowlist(file) {
  let stamp = null;
  let ids = new Set();
  return () => {
    let st = null;
    try { st = fs.statSync(file); } catch { /* missing: nobody */ }
    const now = st ? `${st.mtimeMs}:${st.size}` : 'none';
    if (now !== stamp) {
      stamp = now;
      ids = new Set(st ? fs.readFileSync(file, 'utf8').split(/\r?\n/).map((l) => l.replace(/#.*/, '').trim()).filter((l) => /^-?\d{1,20}$/.test(l)) : []);
    }
    return ids;
  };
}

/** Connects an MQTT client and resolves once it is connected. */
export async function connectMqtt(connect, { url, username, password, metrics }) {
  const client = connect(url, {
    username, password,
    clientId: `zigdash-chat-${crypto.randomBytes(4).toString('hex')}`,
    reconnectPeriod: 5000, connectTimeout: 20000,
  });
  client.on('error', (e) => metrics.count('mqtt_error', { code: Number(e && e.code) || 0 }));
  client.on('close', () => metrics.count('mqtt_closed'));
  await new Promise((resolve) => client.once('connect', resolve));
  metrics.count('mqtt_connected');
  return client;
}

/**
 * Starts the service. [deps] are injectable for tests: anthropic (an SDK client
 * or a fake), mqttClient (connected), fetchImpl (Telegram), metrics.
 */
export async function startService(config, { anthropic, mqttClient, fetchImpl = fetch, metrics = makeMetrics(), telegramToken, pollSeconds } = {}) {
  const serviceKey = loadServiceKey(config.secretsFile);
  const keys = keyring(config.keysFile, serviceKey);
  const links = new Map(); // client id -> { key, link }

  async function linkNow() {
    const clients = keys.current().clients;
    const ids = Object.keys(clients);
    const id = config.clientId || (ids.length === 1 ? ids[0] : null);
    const entry = id && clients[id];
    if (!entry) return null;
    const have = links.get(id);
    if (have && have.key === entry.key && have.token === entry.token) return have.link;
    if (have) have.link.stop();
    const link = new HomeLink({
      mqtt: mqttClient, transport: config.transport, homeId: config.homeId || entry.home_id,
      clientId: id, token: entry.token, key: entry.key,
    });
    await link.start();
    links.set(id, { key: entry.key, token: entry.token, link });
    return link;
  }

  const agent = makeAgent({ anthropic, model: config.model, linkFor: () => linkNow().catch(() => null), metrics, timeZone: config.timeZone });
  const onText = (chatId, text) => agent.handle(chatId, text);
  await linkNow().catch(() => null);
  const telegram = startTelegram({
    token: telegramToken || readSecretFile(config.tokenFile),
    allowed: allowlist(config.allowedFile),
    onText, metrics, fetchImpl, pollSeconds,
  });
  metrics.count('started');
  return {
    agent,
    async stop() {
      await telegram.stop();
      for (const { link } of links.values()) link.stop();
    },
  };
}

async function main() {
  const config = configFromEnv();
  const metrics = makeMetrics();
  const { default: Anthropic } = await import('@anthropic-ai/sdk');
  const mqtt = await import('mqtt');
  const apiKey = process.env.ANTHROPIC_API_KEY || readSecretFile(config.anthropicKeyFile);
  const mqttClient = await connectMqtt(mqtt.connect, {
    url: config.mqttUrl,
    username: config.mqttUser,
    password: config.mqttPasswordFile ? readSecretFile(config.mqttPasswordFile) : undefined,
    metrics,
  });
  const service = await startService(config, { anthropic: new Anthropic({ apiKey }), mqttClient, metrics });
  const bye = async () => { await service.stop(); mqttClient.end(); process.exit(0); };
  process.on('SIGTERM', bye);
  process.on('SIGINT', bye);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((e) => {
    // A start-up problem names the file or setting, never a secret's value.
    console.error(`zigdash-chat: ${e && e.message}`);
    process.exit(2);
  });
}
