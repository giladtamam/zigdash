#!/usr/bin/env node
// ZigDash Chat service (docs/design/chat-linking.md, phase 3): many Homes,
// each linked Telegram chat talking to its own Home through the Engine, over
// the ZigDash relay (or, for development at home, the hub's own broker).
// Linking happens from the app over HTTPS (http.mjs, bot.mjs). Configuration
// (paths may start with ~/; secrets are read from files and never printed):
//
//   TELEGRAM_TOKEN_FILE        the bot's token                                  (~/.config/zigdash/dev_bot_token)
//   TELEGRAM_MODE              polling (dev bot) or webhook (live bot)          (polling)
//   TELEGRAM_WEBHOOK_SECRET_FILE  webhook mode: the /v1/tg/<secret> path part and the header secret
//   BOT_USERNAME               for the link URL                                 (ZigDashHomeBot)
//   ANTHROPIC_API_KEY, or ANTHROPIC_KEY_FILE                                     (~/.config/zigdash/anthropic_key)
//   ZIGDASH_CHAT_KEYS          the encrypted keys file (bindings)              (~/.config/zigdash/chat-keys.json)
//   ZIGDASH_CHAT_SECRETS       the service key that opens it                    (~/.config/zigdash/chat-secrets.json)
//   ZIGDASH_CHAT_STATE         counters, last use, ACL retries (no secrets)     (~/.config/zigdash/chat-state.json)
//   ZIGDASH_TRANSPORT          relay, or broker (the hub's own broker, dev)     (broker)
//   ZIGDASH_MQTT_URL           mqtts://relay.zigdash.app:8883, or mqtt://<hub>:1883
//   ZIGDASH_MQTT_USER, ZIGDASH_MQTT_PASSWORD_FILE   the service's MQTT login
//   HTTP_PORT, HTTP_HOST       the API                                          (8790, 0.0.0.0; HTTP_PORT=off: none)
//   CHAT_TICKET_SECRET_FILE    checks the verifier's tickets (the API is off without it)
//   VERIFIER_INTERNAL_URL, CHAT_ACL_SECRET_FILE   the verifier's internal routes: ACL entries and a Home's
//                              founder's-pass status (http://zigdash-relay-verifier-1:8788)
//   INTERNAL_PORT              the verifier's pushes to the service (home-changed, home-deleted), with the
//                              same ACL secret; never published or proxied   (8791; off: none; on HTTP_HOST)
//   WORKER_URL, WORKER_SECRET_FILE   the support Worker: early access and the linked list (https://support.giladha.com)
//   MONTHLY_CAP                messages a Home a month                          (300)
//   MONTHLY_BUDGET_USD         model spend a month, all Homes, then Chat pauses (20)
//   MODEL                      (claude-haiku-5-5)        TIME_ZONE (the host's)

import crypto from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { expandHome, loadServiceKey, readSecretFile } from './keystore.mjs';
import { makeAgent, DEFAULT_MODEL } from './agent.mjs';
import { makeBot, startPolling } from './telegram.mjs';
import { makeMetrics } from './metrics.mjs';
import { makeBindings, makeState } from './store.mjs';
import { makeChat } from './bot.mjs';
import { makeHttp, makeInternalHttp } from './http.mjs';

export function configFromEnv(env = process.env) {
  const path = (name, fallback) => expandHome(env[name] || fallback);
  const optional = (name) => (env[name] ? expandHome(env[name]) : null);
  return {
    tokenFile: path('TELEGRAM_TOKEN_FILE', '~/.config/zigdash/dev_bot_token'),
    telegramMode: env.TELEGRAM_MODE === 'webhook' ? 'webhook' : 'polling',
    webhookSecretFile: optional('TELEGRAM_WEBHOOK_SECRET_FILE'),
    botUsername: env.BOT_USERNAME || 'ZigDashHomeBot',
    anthropicKeyFile: path('ANTHROPIC_KEY_FILE', '~/.config/zigdash/anthropic_key'),
    keysFile: path('ZIGDASH_CHAT_KEYS', '~/.config/zigdash/chat-keys.json'),
    secretsFile: path('ZIGDASH_CHAT_SECRETS', '~/.config/zigdash/chat-secrets.json'),
    stateFile: path('ZIGDASH_CHAT_STATE', '~/.config/zigdash/chat-state.json'),
    transport: env.ZIGDASH_TRANSPORT === 'relay' ? 'relay' : 'broker',
    mqttUrl: env.ZIGDASH_MQTT_URL || 'mqtt://127.0.0.1:1883',
    mqttUser: env.ZIGDASH_MQTT_USER || undefined,
    mqttPasswordFile: optional('ZIGDASH_MQTT_PASSWORD_FILE'),
    homeId: env.ZIGDASH_HOME_ID || null, // the CLI's default for milestone 1's hand-made client
    httpPort: env.HTTP_PORT === 'off' ? null : Number(env.HTTP_PORT || 8790),
    httpHost: env.HTTP_HOST || '0.0.0.0',
    internalPort: env.INTERNAL_PORT === 'off' ? null : Number(env.INTERNAL_PORT || 8791),
    ticketSecretFile: optional('CHAT_TICKET_SECRET_FILE'),
    verifierUrl: env.VERIFIER_INTERNAL_URL || null,
    aclSecretFile: optional('CHAT_ACL_SECRET_FILE'),
    workerUrl: env.WORKER_URL || null,
    workerSecretFile: optional('WORKER_SECRET_FILE'),
    cap: Number(env.MONTHLY_CAP || 300),
    budgetUsd: Number(env.MONTHLY_BUDGET_USD || 20),
    model: env.MODEL || DEFAULT_MODEL,
    timeZone: env.TIME_ZONE || undefined,
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
 * or a fake), mqttClient (connected), fetchImpl (Telegram, the verifier and
 * the Worker), metrics, and secrets in place of their files.
 */
export async function startService(config, { anthropic, mqttClient, fetchImpl = fetch, metrics = makeMetrics(), telegramToken, pollSeconds, secrets = {}, now = Date.now } = {}) {
  const secret = (name, file) => secrets[name] || (file ? readSecretFile(file) : null);
  const serviceKey = loadServiceKey(config.secretsFile);
  const bindings = makeBindings(config.keysFile, serviceKey);
  const state = makeState(config.stateFile, { now });
  const token = telegramToken || readSecretFile(config.tokenFile);
  const bot = makeBot({ token, fetchImpl });
  const verifierSecret = secret('acl', config.aclSecretFile);
  const workerSecret = secret('worker', config.workerSecretFile);
  let chat = null;
  const agent = makeAgent({
    anthropic, model: config.model, metrics, timeZone: config.timeZone, now,
    linkFor: (chatId) => chat.linkFor(chatId).catch(() => null),
    onCost: (chatId, usd) => chat.costSink(chatId, usd),
  });
  chat = makeChat({
    bindings, state, bot, agent, metrics, mqtt: mqttClient, fetchImpl, now,
    config: {
      transport: config.transport, botUsername: config.botUsername, cap: config.cap, budgetUsd: config.budgetUsd,
      ticketSecret: secret('ticket', config.ticketSecretFile),
      verifier: config.verifierUrl && verifierSecret ? { url: config.verifierUrl.replace(/\/$/, ''), secret: verifierSecret } : null,
      worker: config.workerUrl && workerSecret ? { url: config.workerUrl.replace(/\/$/, ''), secret: workerSecret } : null,
    },
  });

  let api = null;
  let port = null;
  const webhookSecret = config.telegramMode === 'webhook' ? secret('webhook', config.webhookSecretFile) : null;
  if (config.telegramMode === 'webhook' && !webhookSecret) throw new Error('webhook mode needs TELEGRAM_WEBHOOK_SECRET_FILE');
  const ticketsOn = !!secret('ticket', config.ticketSecretFile);
  if (config.httpPort !== null && (ticketsOn || webhookSecret)) {
    api = makeHttp({ chat, metrics, webhookSecret });
    port = await api.listen(config.httpPort, config.httpHost);
  }
  // The verifier's pushes: only with the ACL secret they share.
  let internal = null;
  let internalPort = null;
  if (config.internalPort !== null && config.internalPort !== undefined && verifierSecret) {
    internal = makeInternalHttp({ chat, metrics, secret: verifierSecret });
    internalPort = await internal.listen(config.internalPort, config.httpHost);
  }
  const polling = config.telegramMode === 'polling'
    ? startPolling({ token, onUpdate: (u) => chat.onUpdate(u), metrics, fetchImpl, pollSeconds })
    : null;
  chat.syncWorker().catch(() => {});
  chat.retryAcl().catch(() => {});
  metrics.count('started', { webhook: webhookSecret ? 1 : 0, linked: bindings.list().length });
  return {
    agent, chat, port, internalPort,
    async stop() {
      if (polling) await polling.stop();
      if (api) await api.close();
      if (internal) await internal.close();
      await chat.idle();
      chat.stop();
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
