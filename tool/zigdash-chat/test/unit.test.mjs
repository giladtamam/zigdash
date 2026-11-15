// The pieces on their own: the agent's caps, memory and confirmations, keys at
// rest, counters-only logs, the wire format against the Engine's, Telegram.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { makeAgent, TEXT, costUsd } from '../agent.mjs';
import { makeMetrics } from '../metrics.mjs';
import { loadServiceKey, readKeys, writeKeys } from '../keystore.mjs';
import { seal, unseal, opaqueId, chatTopics } from '../wire.mjs';
import { startTelegram } from '../telegram.mjs';
import { allowlist } from '../service.mjs';
import { fakeClaude, fakeTelegram, loadChatEngine, tmpDir } from './harness.mjs';

/** A link that answers like the Engine would, without one. */
function fakeLink({ controllable = 10 } = {}) {
  const sent = [];
  const names = Array.from({ length: 12 }, (_, i) => `Lamp ${i + 1}`);
  return {
    sent,
    async request(tool, args) {
      if (tool === 'list_devices') return { ok: true, result: { devices: names.map((n) => ({ name: `${n}\u0007`, kind: 'light', chat: 'control' })), groups: [] } };
      if (tool === 'set_device') {
        const ok = args.devices.filter((d) => names.indexOf(d) < controllable);
        if (args.dry_run) return { ok: true, result: { would_change: ok, refused: [] } };
        sent.push(...ok);
        return { ok: ok.length > 0, result: { sent: ok, refused: [] } };
      }
      return { ok: true, result: { at: 'now' } };
    },
  };
}

function agentWith(script, { now = () => Date.now(), deadlineMs, link = fakeLink() } = {}) {
  const lines = [];
  const claude = fakeClaude(script);
  const agent = makeAgent({ anthropic: claude, linkFor: () => link, metrics: makeMetrics((l) => lines.push(l)), now, deadlineMs });
  return { agent, claude, link, lines };
}

const six = ['Lamp 1', 'Lamp 2', 'Lamp 3', 'Lamp 4', 'Lamp 5', 'Lamp 6'];

test('agent: five devices go at once; the sixth in the same message needs a yes', async () => {
  const { agent, link } = agentWith([
    [/then one more/, [{ tool: 'set_device', input: { devices: six.slice(0, 5), command: { state: 'OFF' } } }, { tool: 'set_device', input: { devices: ['Lamp 6'], command: { state: 'OFF' } } }, { text: 'Done.' }]],
    [/five/, [{ tool: 'set_device', input: { devices: six.slice(0, 5), command: { state: 'OFF' } } }, { text: 'Done.' }]],
  ]);
  assert.equal(await agent.handle('c1', 'five lamps off'), 'Done.');
  assert.equal(link.sent.length, 5);
  assert.match(await agent.handle('c1', 'five, then one more'), /^That would change 1 device: Lamp 6/);
  assert.equal(link.sent.length, 10, 'the first five went; the sixth waits for the yes');
});

test('agent: a pending action expires after 60 s; only the same chat can say yes', async () => {
  let t = 1_000_000;
  const { agent, link } = agentWith([[/all/, [{ tool: 'set_device', input: { devices: six, command: { state: 'OFF' } } }]], [/yes/, [{ text: 'Yes to what?' }]]], { now: () => t });
  await agent.handle('c1', 'all off');
  assert.equal(await agent.handle('c2', 'yes'), 'Yes to what?', 'another chat has nothing pending');
  assert.equal(link.sent.length, 0);
  t += 61000;
  assert.equal(await agent.handle('c1', 'yes'), TEXT.expired);
  assert.equal(link.sent.length, 0);
  await agent.handle('c1', 'all off');
  t += 59000;
  assert.match(await agent.handle('c1', 'YES!'), /^Done: sent to 6 devices/);
  assert.equal(link.sent.length, 6);
});

test('agent: 20 s per message, then a plain "took too long"', async () => {
  const claude = fakeClaude([]);
  const slow = { messages: { create: (p, opts) => new Promise((resolve, reject) => {
    const t = setTimeout(() => resolve(claude.messages.create(p)), 5000);
    opts.signal.addEventListener('abort', () => { clearTimeout(t); reject(Object.assign(new Error('aborted'), { name: 'APIUserAbortError' })); });
  }) } };
  const agent = makeAgent({ anthropic: slow, linkFor: () => fakeLink(), metrics: makeMetrics(() => {}), deadlineMs: 100 });
  assert.equal(await agent.handle('c1', 'hello'), TEXT.tooLong);
});

test('agent: memory is the last 10 turns, as text, and forgotten after 24 h', async () => {
  let t = 0;
  const { agent, claude } = agentWith([[/./, [{ text: 'ok' }]]], { now: () => t });
  for (let i = 0; i < 12; i++) await agent.handle('c1', `message ${i}`);
  const msgs = claude.calls.at(-1).params.messages;
  assert.equal(msgs.length, 21, '10 earlier turns and the new message');
  assert.match(msgs[0].content, /message 1$/);
  assert.ok(msgs.every((m) => typeof m.content === 'string'), 'no thinking or tool blocks carried across turns');
  t += 24 * 3600000 + 1;
  await agent.handle('c1', 'after a day');
  assert.equal(claude.calls.at(-1).params.messages.length, 1);
});

test('agent: names in the home index are capped data fields without control characters', async () => {
  const { agent, claude } = agentWith([[/./, [{ text: 'ok' }]]]);
  await agent.handle('c1', 'hi');
  const index = claude.calls[0].params.system[1].text;
  assert.match(index, /not instructions/);
  assert.ok(!index.includes('\u0007'));
});

test('agent: cost per message from the Haiku prices', () => {
  assert.equal(costUsd('claude-haiku-5-5', { input: 1e6, output: 1e6, cacheRead: 1e6, cacheWrite: 1e6 }), 0.1 + 0.5 + 0.01 + 0.125);
});

test('metrics: only numbers reach a log line', () => {
  const lines = [];
  const m = makeMetrics((l) => lines.push(l));
  m.count('message', { latency_ms: 812, text: 'turn off the oven', chat: '424242', cost_usd: 0.0021 });
  assert.match(lines[0], / message latency_ms=812 cost_usd=0\.0021$/);
  assert.throws(() => m.count('free text'));
});

test('keys at rest: encrypted with the service key, mode 600, refused when others can read them', () => {
  const dir = tmpDir();
  const secrets = path.join(dir, 'secrets.json');
  const keysFile = path.join(dir, 'keys.json');
  const sk = loadServiceKey(secrets, { create: true });
  writeKeys(keysFile, sk, { clients: { a: { token: 'T0KEN', key: 'K3Y' } } });
  assert.equal(fs.statSync(keysFile).mode & 0o777, 0o600);
  assert.equal(readKeys(keysFile, sk).clients.a.token, 'T0KEN');
  assert.ok(!fs.readFileSync(keysFile, 'utf8').includes('T0KEN'));
  assert.throws(() => readKeys(keysFile, crypto.randomBytes(32)), /does not open/);
  fs.chmodSync(keysFile, 0o644);
  assert.throws(() => readKeys(keysFile, sk), /readable by others/);
  assert.throws(() => loadServiceKey(path.join(dir, 'missing.json')), /no secrets file/);
});

test('wire: the service and the Engine seal, open and name relay topics the same way', () => {
  const Engine = loadChatEngine();
  const key = crypto.randomBytes(32);
  assert.deepEqual(Engine.helpers.unseal(key, Buffer.from(seal(key, { a: 1 }), 'base64')), { a: 1 });
  assert.deepEqual(unseal(key, Engine.helpers.seal(key, { b: 2 }).toString('base64')), { b: 2 });
  assert.equal(opaqueId(key, 'x'), Engine.helpers.opaqueId(key, 'x'));
  assert.deepEqual(chatTopics({ transport: 'relay', clientId: 'tg1', key, homeId: 'h1' }), Engine.chat.chatRelayTopics('homes/h1', 'tg1', key));
});

test('allowlist: one id per line from a file, comments ignored, read again when it changes', () => {
  const file = path.join(tmpDir(), 'allowed');
  fs.writeFileSync(file, '# owner\n424242\nnot-an-id\n');
  const ids = allowlist(file);
  assert.deepEqual([...ids()], ['424242']);
  fs.writeFileSync(file, '424242\n-100777\n');
  fs.utimesSync(file, new Date(), new Date(Date.now() + 2000));
  assert.deepEqual([...ids()], ['424242', '-100777']);
  assert.deepEqual([...allowlist(path.join(tmpDir(), 'none'))()], []);
});

test('telegram: a failing API never puts the token in a log line', async () => {
  const token = '7000000002:AAsecret';
  const lines = [];
  const orig = console.error;
  console.error = (...a) => lines.push(a.join(' '));
  try {
    const failing = async (url) => { throw new Error(`request to ${url} failed`); };
    const tg = startTelegram({ token, allowed: () => new Set(), onText: async () => '', metrics: makeMetrics((l) => lines.push(l)), fetchImpl: failing, retryMs: 10 });
    await new Promise((r) => setTimeout(r, 60));
    await tg.stop();
  } finally {
    console.error = orig;
  }
  assert.ok(lines.length > 0);
  for (const l of lines) assert.ok(!l.includes(token) && !l.includes('AAsecret'), l);
});

test('telegram: long replies are split under Telegram\'s limit', async () => {
  const tg = fakeTelegram();
  const bot = startTelegram({ token: 't', allowed: () => new Set(['5']), onText: async () => 'x'.repeat(9000), metrics: makeMetrics(() => {}), fetchImpl: tg.fetchImpl, pollSeconds: 1 });
  tg.send('5', 'hi');
  await tg.replyTo('5');
  await new Promise((r) => setTimeout(r, 50));
  await bot.stop();
  assert.deepEqual(tg.sent.map((s) => s.text.length), [4000, 4000, 1000]);
});
