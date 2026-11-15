// End to end: the zigdash-chat service and the 9.0.0-chat Engine over a broker
// (a local mosquitto when installed), with fake Telegram and fake Claude.
// Run: env -u NODE_OPTIONS node --test test/*.test.mjs

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { loadChatEngine, startBroker, startHub, fakeTelegram, fakeClaude, lastToolResults, tmpDir, CONTROLS, HOME } from './harness.mjs';
import { startService, configFromEnv } from '../service.mjs';
import { runCli } from '../cli.mjs';
import { makeMetrics } from '../metrics.mjs';
import { readKeys, loadServiceKey } from '../keystore.mjs';
import { HomeLink } from '../link.mjs';
import { replayTest } from '../replay-test.mjs';
import { TEXT } from '../agent.mjs';

const Engine = loadChatEngine();
const OWNER = '424242';
const BOT_TOKEN = '7000000001:AAtest-token-never-logged';
const EVERYTHING = ['Hall light', 'Kitchen light', 'Desk lamp', 'Bed lamp', 'Porch light', 'Kettle plug', 'Freezer plug', 'Garden valve', 'Front lock'];

const SCRIPT = [
  [/close the office shutter/i, [{ tool: 'set_device', input: { devices: ['Office shutter'], command: { state: 'CLOSE' } } }, { text: 'Closing the office shutter.' }]],
  [/front door closed/i, [{ tool: 'get_device', input: { device: 'Front door' } }, { text: 'Yes, the front door is closed.' }]],
  [/turn off the valve/i, [{ tool: 'set_device', input: { devices: ['Garden valve'], command: { state: 'OFF' } } }, { text: 'The valve is read-only from chat. Open ZigDash to do that.' }]],
  [/unlock/i, [{ tool: 'set_device', input: { devices: ['Front lock'], command: { state: 'UNLOCK' } } }, { text: 'Open ZigDash to do that.' }]],
  [/freezer/i, [{ tool: 'set_device', input: { devices: ['Freezer plug'], command: { state: 'OFF' } } }, { text: 'That plug is not on your control list.' }]],
  [/turn off everything/i, [{ tool: 'set_device', input: { devices: EVERYTHING, command: { state: 'OFF' } } }, { text: 'Done.' }]],
  // The model trying to act on a bare "yes" by itself: it only gets a new question.
  [/^yes$/i, [{ tool: 'set_device', input: { devices: EVERYTHING, command: { state: 'OFF' } } }, { text: 'Done.' }]],
  [/^no$/i, [{ text: 'OK, nothing changed.' }]],
  [/loop/i, [{ tool: 'home_summary', input: {} }]],
];

async function world(t, { transport = 'broker' } = {}) {
  const broker = await startBroker();
  const dir = tmpDir();
  const lines = [];
  const capture = (orig) => (...a) => { lines.push(a.join(' ')); };
  const origLog = console.log, origErr = console.error;
  console.log = capture(origLog);
  console.error = capture(origErr);
  const hubClient = await broker.connect();
  const hub = await startHub(Engine, hubClient, { relay: broker });
  const cliClient = await broker.connect();
  if (transport === 'relay') {
    cliClient.publish('zigdash/remote/set', JSON.stringify({ url: 'mqtts://relay.example', homeId: 'h1', username: 'u', password: 'p', key: Buffer.alloc(32, 7).toString('base64') }));
    for (let i = 0; i < 100 && !(hub.engine.remote && hub.engine.remote.connected); i++) await new Promise((r) => setTimeout(r, 20));
    assert.ok(hub.engine.remote.connected, 'the Engine reached the relay');
  }
  fs.writeFileSync(path.join(dir, 'allowed'), `# the owner\n${OWNER}\n`, { mode: 0o600 });
  const config = {
    ...configFromEnv({}),
    keysFile: path.join(dir, 'keys.json'), secretsFile: path.join(dir, 'secrets.json'),
    allowedFile: path.join(dir, 'allowed'), transport, homeId: transport === 'relay' ? 'h1' : null,
  };
  const out = [];
  const cli = (...argv) => runCli(argv, { config: { ...config, transport: 'broker' }, mqtt: cliClient, print: (l) => out.push(l) });
  await cli('create', '--id', 'tg1', '--name', 'Owner', '--controls', CONTROLS.join(','), '--home-id', 'h1');
  await new Promise((r) => setTimeout(r, 150)); // the Engine takes the retained config
  const tg = fakeTelegram();
  const claude = fakeClaude(SCRIPT);
  const serviceClient = await broker.connect();
  const metrics = makeMetrics((l) => lines.push(l));
  const service = await startService(config, { anthropic: claude, mqttClient: serviceClient, fetchImpl: tg.fetchImpl, metrics, telegramToken: BOT_TOKEN, pollSeconds: 1 });
  const say = async (text) => { tg.send(OWNER, text); return tg.replyTo(OWNER); };
  const audit = () => hub.engine.chat.audit;
  t.after(async () => {
    await service.stop();
    await hub.stop();
    await broker.stop();
    console.log = origLog;
    console.error = origErr;
  });
  return { broker, hub, tg, claude, say, audit, cli, out, config, lines, metrics, cliClient, serviceClient };
}

const noTextInLogs = (lines, ...words) => {
  for (const l of lines) for (const w of words) assert.ok(!l.includes(w), `a log line holds "${w}": ${l}`);
};

test(`e2e (${process.env.ZIGDASH_CHAT_FAKE_BROKER ? 'fake broker' : 'mosquitto if installed'}): "close the office shutter" closes it; logs hold counters only`, async (t) => {
  const w = await world(t);
  assert.equal(await w.say('close the office shutter'), 'Closing the office shutter.');
  assert.deepEqual(w.hub.injected, [{ topic: 'zigbee2mqtt/Office shutter/set', payload: { state: 'CLOSE' } }]);
  assert.equal(w.audit()[0].result, 'sent {"state":"CLOSE"}');
  // The model: Haiku, low effort, two cached system blocks (the rules, then the home index).
  const p = w.claude.calls[0].params;
  assert.equal(p.model, 'claude-haiku-5-5');
  assert.deepEqual(p.output_config, { effort: 'low' });
  assert.equal(p.system.length, 2);
  assert.ok(p.system.every((b) => b.cache_control && b.cache_control.type === 'ephemeral'));
  assert.match(p.system[1].text, /Office shutter/);
  assert.deepEqual(p.tools.map((x) => x.name), ['home_summary', 'list_devices', 'get_device', 'get_history', 'set_device', 'set_group']);
  const msg = w.lines.find((l) => / message /.test(l));
  assert.match(msg, /latency_ms=\d+ tool_calls=1 devices_changed=1 refusals=0 input_tokens=1800 output_tokens=80 cache_read_tokens=1200 cache_write_tokens=0 cost_usd=/);
  noTextInLogs(w.lines, 'shutter', 'Closing', OWNER, BOT_TOKEN, 'tg1');
});

test('e2e: "is the front door closed?" answers from live state', async (t) => {
  const w = await world(t);
  w.hub.report('Front door', { contact: true });
  assert.equal(await w.say('is the front door closed?'), 'Yes, the front door is closed.');
  const [r] = lastToolResults(w.claude);
  assert.equal(r.data.state.contact, true);
  assert.equal(r.data.chat, 'read only: not on the control list');
});

test('e2e: a valve and a lock are refused with "Open ZigDash to do that"; a plug off the list too', async (t) => {
  const w = await world(t);
  assert.match(await w.say('turn off the valve'), /Open ZigDash to do that/);
  assert.match(lastToolResults(w.claude)[0].data.refused[0].reason, /read only: valve\. Open ZigDash to do that\./);
  assert.match(await w.say('unlock the front door'), /Open ZigDash/);
  assert.match(lastToolResults(w.claude)[0].data.refused[0].reason, /read only: lock/);
  await w.say('switch the freezer off');
  assert.match(lastToolResults(w.claude)[0].data.refused[0].reason, /not on the control list/);
  assert.deepEqual(w.hub.injected, []);
  assert.deepEqual(w.audit().slice(0, 3).map((a) => [a.device, a.result.split('.')[0]]),
    [['Freezer plug', 'refused: read only: not on the control list'], ['Front lock', 'refused: read only: lock'], ['Garden valve', 'refused: read only: valve']]);
  assert.match(w.lines.filter((l) => / message /.test(l)).at(-1), /refusals=1/);
});

test('e2e: "turn off everything" asks first, and only "yes" from that chat runs it, on listed devices only', async (t) => {
  const w = await world(t);
  const ask = await w.say('turn off everything');
  assert.match(ask, /^That would change 6 devices: Hall light, Kitchen light, Desk lamp, Bed lamp, Porch light, Kettle plug\. Reply yes within 60 seconds/);
  assert.deepEqual(w.hub.injected, [], 'nothing changes before the yes');
  const done = await w.say('yes');
  assert.match(done, /^Done: sent to 6 devices/);
  assert.match(done, /Not changed from chat: Freezer plug, Garden valve, Front lock\. Open ZigDash/);
  assert.deepEqual(w.hub.injected.map((i) => i.topic.split('/')[1]).sort(), ['Bed lamp', 'Desk lamp', 'Hall light', 'Kettle plug', 'Kitchen light', 'Porch light']);
  assert.equal(w.claude.calls.length, 1, '"yes" ran in code, without the model');
});

test('e2e: the model cannot confirm: "no" cancels, and a later "yes" only gets a new question', async (t) => {
  const w = await world(t);
  await w.say('turn off everything');
  assert.equal(await w.say('no'), 'OK, nothing changed.');
  assert.match(await w.say('yes'), /^That would change 6 devices/);
  assert.deepEqual(w.hub.injected, []);
});

test('e2e: the tool loop stops at 6 calls', async (t) => {
  const w = await world(t);
  assert.equal(await w.say('loop forever'), TEXT.tooMany);
  assert.ok(w.claude.calls.length <= 7);
  assert.match(w.lines.filter((l) => / message /.test(l)).at(-1), /tool_calls=6/);
});

test('e2e: a stranger gets nothing back and leaves no log line with their text, name or id', async (t) => {
  const w = await world(t);
  w.tg.send('999001', 'STRANGER-SECRET please unlock', { firstName: 'Mallory' });
  w.tg.send(OWNER, 'OWNER-IN-A-GROUP', { type: 'group' });
  assert.equal(await w.say('close the office shutter'), 'Closing the office shutter.');
  assert.deepEqual(w.tg.sent.filter((s) => s.chatId !== OWNER), []);
  assert.equal(w.tg.sent.filter((s) => s.chatId === OWNER).length, 1, 'no reply in the group either');
  assert.equal(w.metrics.totals.ignored, 2);
  assert.equal(w.claude.calls.length, 2, 'only the owner reached the model');
  noTextInLogs(w.lines, 'STRANGER', 'Mallory', '999001', 'OWNER-IN-A-GROUP', BOT_TOKEN);
  assert.ok(w.lines.some((l) => / ignored$/.test(l)));
});

test('e2e: replay: the same sealed request played again is rejected and audited', async (t) => {
  const w = await world(t);
  const entry = readKeys(w.config.keysFile, loadServiceKey(w.config.secretsFile)).clients.tg1;
  const { results } = await replayTest({ mqtt: w.serviceClient, transport: 'broker', clientId: 'tg1', token: entry.token, key: entry.key, delaysMs: [200], listenMs: 300, print: () => {} });
  assert.deepEqual(results.map((r) => r.outcome), ['no answer']);
  assert.ok(w.audit().some((a) => a.result === 'rejected: replay' && a.tool === 'home_summary'));
});

test('e2e: a hub clock 3 minutes off: rejected as stale, then corrected from the Engine time', async (t) => {
  const w = await world(t);
  const entry = readKeys(w.config.keysFile, loadServiceKey(w.config.secretsFile)).clients.tg1;
  const link = new HomeLink({ mqtt: w.serviceClient, clientId: 'tg1', token: entry.token, key: entry.key, now: () => Date.now() - 180000 });
  await link.start();
  t.after(() => link.stop());
  const r = await link.request('home_summary');
  assert.equal(r.ok, true);
  assert.ok(Math.abs(link.offsetMs - 180000) < 2000);
  assert.equal(w.audit()[0].result, 'rejected: stale');
});

test('e2e: revoke: after deleting the client on the Engine, "not linked", and the Engine refuses', async (t) => {
  const w = await world(t);
  await w.say('close the office shutter');
  await w.cli('revoke', 'tg1', '--hub-only');
  await new Promise((r) => setTimeout(r, 150));
  assert.equal(await w.say('close the office shutter'), TEXT.notLinked);
  assert.equal(w.hub.injected.length, 1);
  assert.equal(w.audit()[0].result, 'refused: not linked');
  // Removing the local keys too: the service no longer has anything to send with.
  await w.cli('revoke', 'tg1');
  assert.equal(await w.say('close the office shutter'), TEXT.notLinked);
  assert.equal(w.metrics.totals.not_linked, 2);
  assert.deepEqual(readKeys(w.config.keysFile, loadServiceKey(w.config.secretsFile)).clients, {});
});

test('e2e: CLI: keys encrypted at rest, mode 600; the hub keeps only the token hash; nothing secret printed', async (t) => {
  const w = await world(t);
  const keys = readKeys(w.config.keysFile, loadServiceKey(w.config.secretsFile));
  const entry = keys.clients.tg1;
  for (const f of [w.config.keysFile, w.config.secretsFile]) assert.equal(fs.statSync(f).mode & 0o777, 0o600, f);
  const raw = fs.readFileSync(w.config.keysFile, 'utf8');
  assert.ok(!raw.includes(entry.token) && !raw.includes(entry.key), 'the keys file is encrypted');
  assert.deepEqual(entry.controls.sort(), [...CONTROLS].sort());
  const retainedConfig = await new Promise((resolve) => {
    w.cliClient.on('message', (topic, p) => { if (topic === 'zigdash/chat/clients/tg1') resolve(JSON.parse(String(p))); });
    w.cliClient.subscribe('zigdash/chat/clients/tg1');
  });
  assert.equal(retainedConfig.hash.length, 64);
  assert.ok(!JSON.stringify(retainedConfig).includes(entry.token), 'the hub never sees the token');
  await w.cli('list');
  await w.cli('set-controls', 'tg1', 'Office shutter,Desk lamp');
  await new Promise((r) => setTimeout(r, 150));
  assert.match(await w.say('turn off everything'), /^Done\.$|^That would change/);
  assert.deepEqual(w.hub.injected.map((i) => i.topic), ['zigbee2mqtt/Desk lamp/set'], 'only the one light still on the list');
  const entries = await w.cli('audit', 'tg1', '--limit', '20');
  assert.ok(entries.some((e) => e.device === 'Hall light' && /not on the control list/.test(e.result)));
  for (const line of w.out) assert.ok(!line.includes(entry.token) && !line.includes(entry.key), line);
  assert.ok(Object.keys(HOME).length > 0);
});

test('e2e through the relay: "close the office shutter" under opaque topics', async (t) => {
  const w = await world(t, { transport: 'relay' });
  const seen = [];
  const spy = await w.broker.connect();
  spy.on('message', (topic) => seen.push(topic));
  await new Promise((r) => spy.subscribe('homes/#', { qos: 1 }, r));
  t.after(() => spy.end(true));
  assert.equal(await w.say('close the office shutter'), 'Closing the office shutter.');
  assert.deepEqual(w.hub.injected, [{ topic: 'zigbee2mqtt/Office shutter/set', payload: { state: 'CLOSE' } }]);
  const chatTopics = seen.filter((s) => s.startsWith('homes/h1/x/'));
  assert.ok(chatTopics.length >= 4, 'the index and the change, each a request and an answer');
  assert.ok(chatTopics.every((s) => /^homes\/h1\/x\/[0-9a-f]{24}$/.test(s)));
  // And revoke through the relay: "not linked".
  await w.cli('revoke', 'tg1', '--hub-only');
  await new Promise((r) => setTimeout(r, 150));
  assert.equal(await w.say('close the office shutter'), TEXT.notLinked);
  assert.equal(w.hub.injected.length, 1);
});
