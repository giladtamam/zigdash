#!/usr/bin/env node
// The milestone 1 replay test: sends one real sealed request (home_summary,
// which changes nothing), captures its bytes, and plays the same bytes again
// after each delay. The Engine must answer none of them with data: a replay
// inside the 120 s window gets no answer, an older one only "stale". Then it
// reads the Engine's audit log to show both were written down.
// Same environment as service.mjs.
//
//   node replay-test.mjs [--after 5,180] [--client <id>]

import crypto from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { loadServiceKey, readKeys, readSecretFile } from './keystore.mjs';
import { configFromEnv } from './service.mjs';
import { HomeLink } from './link.mjs';
import { unseal } from './wire.mjs';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/** Returns [{afterMs, outcome: 'no answer'|'stale'|'ACCEPTED'}] and the audit entries written meanwhile. */
export async function replayTest({ mqtt, transport, homeId, clientId, token, key, delaysMs, listenMs = 5000, print = console.log }) {
  let captured = null;
  const link = new HomeLink({ mqtt, transport, homeId, clientId, token, key, onSend: (topic, payload) => { if (!captured) captured = { topic, payload }; } });
  await link.start();
  const keyBuf = Buffer.from(key, 'base64');
  const answers = [];
  const listen = (topic, payload) => {
    if (topic !== link.topics.res) return;
    const m = unseal(keyBuf, String(payload));
    if (m) answers.push(m);
  };
  mqtt.on('message', listen);
  try {
    const first = await link.request('home_summary', {});
    if (!first.ok) throw new Error('the first request was not answered: is the client linked?');
    const id = unseal(keyBuf, captured.payload).id;
    print(`sent and answered one request (id ${id.slice(0, 6)}…); replaying the same bytes`);
    const results = [];
    let waited = 0;
    for (const afterMs of delaysMs) {
      await sleep(Math.max(0, afterMs - waited));
      waited = afterMs;
      const before = answers.length;
      mqtt.publish(captured.topic, captured.payload, { qos: 1, retain: false });
      await sleep(listenMs);
      waited += listenMs;
      const mine = answers.slice(before).filter((a) => a.id === id);
      const outcome = !mine.length ? 'no answer' : mine.every((a) => a.error === 'stale' && a.result === undefined) ? 'stale' : 'ACCEPTED';
      print(`after ${Math.round(afterMs / 1000)} s: ${outcome === 'ACCEPTED' ? 'ACCEPTED (the Engine answered with data: FAIL)' : `rejected (${outcome})`}`);
      results.push({ afterMs, outcome });
    }
    const audit = await link.request('audit', { limit: 10 });
    const entries = ((audit.result && audit.result.entries) || []).filter((e) => /^rejected: (replay|stale)/.test(e.result));
    for (const e of entries.slice(0, delaysMs.length)) print(`audit: ${e.at}  ${e.tool}  ${e.result}`);
    return { results, audit: entries };
  } finally {
    mqtt.removeListener('message', listen);
    link.stop();
  }
}

async function main() {
  const config = configFromEnv();
  const args = process.argv.slice(2);
  const opt = (name, fallback) => { const i = args.indexOf(`--${name}`); return i >= 0 && args[i + 1] ? args[i + 1] : fallback; };
  const delaysMs = opt('after', '5,180').split(',').map((s) => Number(s) * 1000).filter((n) => n >= 0);
  const keys = readKeys(config.keysFile, loadServiceKey(config.secretsFile));
  const ids = Object.keys(keys.clients);
  const clientId = opt('client', config.clientId || (ids.length === 1 ? ids[0] : null));
  const entry = keys.clients[clientId];
  if (!entry) throw new Error('no such client in the keys file (--client <id>)');
  const { connect } = await import('mqtt');
  const mqtt = connect(config.mqttUrl, {
    username: config.mqttUser,
    password: config.mqttPasswordFile ? readSecretFile(config.mqttPasswordFile) : undefined,
    clientId: `zigdash-chat-replay-${crypto.randomBytes(4).toString('hex')}`,
  });
  await new Promise((resolve, reject) => { mqtt.once('connect', resolve); mqtt.once('error', reject); });
  try {
    const { results } = await replayTest({ mqtt, transport: config.transport, homeId: config.homeId || entry.home_id, clientId, token: entry.token, key: entry.key, delaysMs });
    process.exitCode = results.every((r) => r.outcome !== 'ACCEPTED') ? 0 : 1;
  } finally {
    mqtt.end();
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((e) => { console.error(`replay-test: ${e && e.message}`); process.exit(2); });
}
