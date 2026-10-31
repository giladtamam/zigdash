// Runs the function-node bodies in node-red/history/*.js as Node-RED would,
// through a scripted day and midnight, and checks what gets published.
// Usage: node node-red/history/test/harness.mjs
import fs from 'node:fs';
import assert from 'node:assert/strict';
const dir = new URL('../', import.meta.url).pathname;
const load = name => new Function('msg', 'flow', 'env', 'node', 'Buffer', fs.readFileSync(dir + name + '.js', 'utf8'));
const fns = Object.fromEntries(['ingest', 'restore', 'record', 'tally', 'restoretally', 'tick', 'heartbeat'].map(n => [n, load(n)]));

let store = {};
const flow = { get: k => store[k], set: (k, v) => { store[k] = v; } };
const node = { warn: () => {}, error: () => {} };
const run = (name, msg = {}) => {
    const r = fns[name](msg, flow, { get: () => undefined }, node, Buffer);
    if (r === null || r === undefined) return [];
    if (Array.isArray(r)) return r.flat().filter(Boolean);
    return [r];
};
const TZ = 'Asia/Jerusalem';
const at = (dayOffset, h, m = 0) => { // a Date whose wall time in TZ is h:m on today+dayOffset
    const d = new RealDate(); const local = new RealDate(d.toLocaleString('en-US', { timeZone: TZ }));
    const diff = d - local; local.setHours(h, m, 0, 0); local.setDate(local.getDate() + dayOffset);
    return new RealDate(local.getTime() + diff);
};
const RealDate = Date;
const clock = t => { globalThis.Date = class extends RealDate { constructor(...a) { super(...(a.length ? a : [t])); } static now() { return t.getTime(); } }; };
const dateOf = t => new Intl.DateTimeFormat('en-CA', { timeZone: TZ, year: 'numeric', month: '2-digit', day: '2-digit' }).format(t);

let step = 0;
const check = (what, fn) => { step++; try { fn(); console.log(`ok ${step}: ${what}`); } catch (e) { console.log(`FAIL ${step}: ${what}\n   ${e.message}`); process.exitCode = 1; } };

const config = { v: 1, home: 'My Home', base: 'zigbee2mqtt', timeZone: TZ, keepDays: 30, readings: [
    { ieee: '0xa1', attr: 'temperature', topic: 'zigbee2mqtt/Living room', path: 'temperature', unit: '°C' },
    { ieee: '0xa1', attr: 'humidity', topic: 'zigbee2mqtt/Living room', path: 'humidity', unit: '%' },
    { ieee: '0xb2', attr: 'power', topic: 'zigbee2mqtt/Plug', path: 'power', unit: 'W' },
] };

// 1. Config.
run('ingest', { topic: 'zigdash/history/config', payload: JSON.stringify(config) });
check('config indexed by device topic', () => assert.deepEqual(Object.keys(store.index).sort(), ['zigbee2mqtt/Living room', 'zigbee2mqtt/Plug']));

// 2. First tick of the day: clears a week of records past the window, for every reading.
clock(at(0, 10, 0));
let out = run('tick');
const today = dateOf(at(0, 10)), yesterday = dateOf(at(-1, 10));
check('first tick clears records 30 to 36 days back, 7 per reading', () => {
    assert.equal(out.length, 21);
    assert.ok(out.every(m => m.retain && m.payload === ''));
    assert.ok(out.some(m => m.topic === `zigdash/history/0xa1/temperature/${dateOf(at(-30, 10))}`));
    assert.ok(!out.some(m => m.topic.endsWith(dateOf(at(-29, 10)))), 'day 29 back is kept');
});

// 3. Values in the 10:00 slot (slot 40): averaged, min, max.
for (const [t, temp] of [[1, 21.0], [5, 22.0], [9, 23.5]]) {
    clock(at(0, 10, t));
    run('record', { topic: 'zigbee2mqtt/Living room', payload: JSON.stringify({ temperature: temp, humidity: 50, battery: 90 }) });
}
clock(at(0, 10, 12));
check('nothing published while the slot is open', () => assert.equal(run('tick').length, 0));

// 4. Slot closes at 10:15: one record per reading with data.
clock(at(0, 10, 15));
out = run('tick');
check('closing a slot publishes the day records', () => {
    const t = out.find(m => m.topic === `zigdash/history/0xa1/temperature/${today}`);
    assert.ok(t && t.retain);
    assert.deepEqual(JSON.parse(t.payload), { v: 1, unit: '°C', b: [[40, 22.17, 21, 23.5]] });
    assert.ok(out.find(m => m.topic === `zigdash/history/0xa1/humidity/${today}`));
    assert.ok(!out.find(m => m.topic.startsWith('zigdash/history/0xb2/')), 'the plug sent nothing');
});
clock(at(0, 10, 16));
check('the same slot is not published twice', () => assert.equal(run('tick').length, 0));

// 5. Strings and junk: a numeric string counts, text and missing values do not.
clock(at(0, 10, 20));
run('record', { topic: 'zigbee2mqtt/Plug', payload: JSON.stringify({ power: '12.5' }) });
run('record', { topic: 'zigbee2mqtt/Plug', payload: JSON.stringify({ power: 'n/a' }) });
run('record', { topic: 'zigbee2mqtt/Plug', payload: 'not json' });
run('record', { topic: 'zigbee2mqtt/Other', payload: JSON.stringify({ power: 99 }) });
check('a numeric string is recorded, junk is ignored', () => assert.deepEqual(store.mem['0xb2/power'].slots[41], [1, 12.5, 12.5, 12.5]));

// 6. Restart: memory is gone; today's retained record comes back and refills it.
const saved = JSON.parse(out.find(m => m.topic === `zigdash/history/0xa1/temperature/${today}`).payload);
store = {};
run('ingest', { topic: 'zigdash/history/config', payload: JSON.stringify(config) });
clock(at(0, 11, 0));
run('restore', { topic: `zigdash/history/0xa1/temperature/${today}`, payload: JSON.stringify(saved) });
run('restore', { topic: `zigdash/history/0xa1/temperature/${yesterday}`, payload: JSON.stringify(saved) });
check('restore keeps today only', () => {
    assert.deepEqual(store.mem['0xa1/temperature'].slots[40], [1, 22.17, 21, 23.5]);
    assert.equal(store.mem['0xa1/temperature'].date, today);
});
run('record', { topic: 'zigbee2mqtt/Living room', payload: JSON.stringify({ temperature: 24 }) });
clock(at(0, 11, 15));
out = run('tick').filter(m => m.payload !== '');
check('after a restart the record holds old and new slots', () => {
    const t = JSON.parse(out.find(m => m.topic === `zigdash/history/0xa1/temperature/${today}`).payload);
    assert.deepEqual(t.b, [[40, 22.17, 21, 23.5], [44, 24, 24, 24]]);
});

// 7. An echo of our own record does not overwrite exact sums in memory.
run('record', { topic: 'zigbee2mqtt/Living room', payload: JSON.stringify({ temperature: 26 }) });
run('restore', { topic: `zigdash/history/0xa1/temperature/${today}`, payload: JSON.stringify({ v: 1, unit: '°C', b: [[45, 1, 1, 1]] }) });
check('memory wins over a record for the same slot', () => assert.deepEqual(store.mem['0xa1/temperature'].slots[45], [1, 26, 26, 26]));

// 8. Midnight: a value at 23:50, then the first tick after midnight publishes
// the full old day (its last slot included) and starts a new one.
clock(at(0, 23, 50));
run('record', { topic: 'zigbee2mqtt/Living room', payload: JSON.stringify({ temperature: 19 }) });
clock(at(1, 0, 1));
out = run('tick');
check('after midnight the old day is published in full', () => {
    const t = JSON.parse(out.find(m => m.topic === `zigdash/history/0xa1/temperature/${today}`).payload);
    assert.deepEqual(t.b.at(-1), [95, 19, 19, 19]);
    assert.equal(store.mem['0xa1/temperature'].date, dateOf(at(1, 0, 1)));
    assert.ok(out.some(m => m.payload === '' && m.topic.endsWith(dateOf(at(-29, 10)))), 'the day that left the window is cleared');
});

// 9. A value after midnight before any tick: the old day is not lost.
clock(at(1, 23, 59));
run('record', { topic: 'zigbee2mqtt/Plug', payload: JSON.stringify({ power: 30 }) });
clock(at(2, 0, 0, 30));
run('record', { topic: 'zigbee2mqtt/Plug', payload: JSON.stringify({ power: 40 }) });
out = run('tick');
check('a day closed by a new value is still published in full', () => {
    const t = JSON.parse(out.find(m => m.topic === `zigdash/history/0xb2/power/${dateOf(at(1, 12))}`).payload);
    assert.deepEqual(t.b.at(-1), [95, 30, 30, 30]);
});

// 10. Config off: nothing recorded any more.
run('ingest', { topic: 'zigdash/history/config', payload: '' });
run('record', { topic: 'zigbee2mqtt/Plug', payload: JSON.stringify({ power: 50 }) });
check('an empty config stops recording', () => assert.equal(store.cfg, null));
check('heartbeat is retained online', () => assert.deepEqual(run('heartbeat'), [{ topic: 'zigdash/history/bridge/state', payload: 'online', retain: true }]));

// ---------- tallies (3.3): times on or opened, minutes on ----------
const tcfg = { v: 1, home: 'My Home', base: 'zigbee2mqtt', timeZone: TZ, keepDays: 30, readings: [], tallies: [
    { ieee: '0xc1', attr: 'state', topic: 'zigbee2mqtt/Lamp', path: 'state', kind: 'on' },
    { ieee: '0xd1', attr: 'contact', topic: 'zigbee2mqtt/Door', path: 'contact', kind: 'open' },
    { ieee: '0xe1', attr: 'occupancy', topic: 'zigbee2mqtt/Hall', path: 'occupancy', kind: 'motion' },
    { ieee: '0xf1', attr: 'state', topic: 'zigbee2mqtt/Bad', path: 'state', kind: 'blink' },
] };
const D = 3;
const tallyRec = (outs, ieee, attr, day = D) => {
    const m = outs.findLast(x => x.topic === `zigdash/history/tally/${ieee}/${attr}/${dateOf(at(day, 12))}`);
    return m && JSON.parse(m.payload);
};
const minutes = rec => Math.round(rec.b.reduce((a, b) => a + b[2], 0) * 10) / 10;
const ticks = (day, fromH, fromM, toH, toM) => {
    const outs = [];
    for (let t = fromH * 60 + fromM; t <= toH * 60 + toM; t++) { clock(at(day, Math.floor(t / 60), t % 60)); outs.push(...run('tick')); }
    return outs;
};
clock(at(D, 8, 40));
run('ingest', { topic: 'zigdash/history/config', payload: JSON.stringify(tcfg) });
check('tallies indexed by device topic; an unknown kind is skipped', () =>
    assert.deepEqual(Object.keys(store.tindex).sort(), ['zigbee2mqtt/Door', 'zigbee2mqtt/Hall', 'zigbee2mqtt/Lamp']));

// The lamp: off at 08:50, on at 09:00, a repeated ON report at 09:05, off at 10:30.
clock(at(D, 8, 50));
run('tally', { topic: 'zigbee2mqtt/Lamp', payload: JSON.stringify({ state: 'OFF', linkquality: 90 }) });
clock(at(D, 9, 0));
run('tally', { topic: 'zigbee2mqtt/Lamp', payload: JSON.stringify({ state: 'ON' }) });
let tout = ticks(D, 9, 1, 9, 4);
clock(at(D, 9, 5));
run('tally', { topic: 'zigbee2mqtt/Lamp', payload: JSON.stringify({ state: 'ON', linkquality: 60 }) });
tout = tout.concat(ticks(D, 9, 5, 10, 29));
clock(at(D, 10, 30));
run('tally', { topic: 'zigbee2mqtt/Lamp', payload: JSON.stringify({ state: 'OFF' }) });
check('a repeated ON report is not a second switch-on', () =>
    assert.equal(Object.values(store.tmem['0xc1/state'].slots).reduce((a, s) => a + s[0], 0), 1));
check('the 09:00 slot is published when it closes, with its 15 minutes', () => {
    const rec = tallyRec(tout, '0xc1', 'state');
    assert.ok(rec, 'no tally record published');
    assert.deepEqual(rec.b.find(b => b[0] === 36), [36, 1, 15]);
    assert.equal(rec.kind, 'on');
});
tout = ticks(D, 10, 31, 10, 45);
check('on from 09:00 to 10:30 is 90 minutes in all, and it is off now', () => {
    const rec = tallyRec(tout, '0xc1', 'state');
    assert.equal(minutes(rec), 90);
    assert.equal(rec.last, false);
});

// The door: closed (contact true), opened twice, each with repeats.
clock(at(D, 11, 0));
for (const c of [true, false, false, true, true, false, true]) run('tally', { topic: 'zigbee2mqtt/Door', payload: JSON.stringify({ contact: c, battery: 90 }) });
// Motion: the first value after a start is not counted unless it was off.
run('tally', { topic: 'zigbee2mqtt/Hall', payload: JSON.stringify({ occupancy: true }) });
run('tally', { topic: 'zigbee2mqtt/Hall', payload: JSON.stringify({ occupancy: false }) });
run('tally', { topic: 'zigbee2mqtt/Hall', payload: JSON.stringify({ occupancy: true }) });
run('tally', { topic: 'zigbee2mqtt/Hall', payload: JSON.stringify({ battery: 80 }) });
clock(at(D, 11, 15));
tout = run('tick');
check('the door opened twice; the open flag is contact false', () => assert.equal(tallyRec(tout, '0xd1', 'contact').b.find(b => b[0] === 44)[1], 2));
check('motion counts changes from off, a message without the value is ignored', () => assert.equal(tallyRec(tout, '0xe1', 'occupancy').b.find(b => b[0] === 44)[1], 1));

// Restart while the lamp is on: memory is gone, the retained record brings back the count and the open interval.
clock(at(D, 12, 0));
run('tally', { topic: 'zigbee2mqtt/Lamp', payload: JSON.stringify({ state: 'ON' }) });
tout = ticks(D, 12, 1, 12, 15);
const kept = tout.filter(m => m.topic.startsWith('zigdash/history/tally/0xc1/')).at(-1);
store.tmem = {}; store.tdone = [];
clock(at(D, 12, 20));
run('restoretally', { topic: kept.topic, payload: kept.payload });
check('a restart keeps today\'s count and that the lamp is on', () => {
    assert.equal(store.tmem['0xc1/state'].last, true);
    assert.equal(Object.values(store.tmem['0xc1/state'].slots).reduce((a, s) => a + s[0], 0), 2);
});
tout = ticks(D, 12, 21, 12, 30);
clock(at(D, 12, 30));
run('tally', { topic: 'zigbee2mqtt/Lamp', payload: JSON.stringify({ state: 'OFF' }) });
tout = ticks(D, 12, 31, 12, 45);
check('the minutes across the restart are credited (90 + 30)', () => assert.equal(minutes(tallyRec(tout, '0xc1', 'state')), 120));
check('a record from another day is not restored', () => {
    store.tmem = {};
    run('restoretally', { topic: `zigdash/history/tally/0xc1/state/${dateOf(at(D - 1, 12))}`, payload: kept.payload });
    assert.equal(store.tmem['0xc1/state'], undefined);
});

// Midnight with the lamp on: the old day ends with its last slot, the new day starts on.
clock(at(D, 23, 50));
run('tally', { topic: 'zigbee2mqtt/Lamp', payload: JSON.stringify({ state: 'OFF' }) });
clock(at(D, 23, 51));
run('tally', { topic: 'zigbee2mqtt/Lamp', payload: JSON.stringify({ state: 'ON' }) });
tout = ticks(D, 23, 52, 23, 59);
tout = tout.concat(ticks(D + 1, 0, 0, 0, 16));
check('on over midnight: 9 minutes to the old day, the new day starts on', () => {
    const old = tallyRec(tout, '0xc1', 'state', D);
    assert.equal(old.b.find(b => b[0] === 95)[2], 9);
    const now = tallyRec(tout, '0xc1', 'state', D + 1);
    assert.equal(now.b.find(b => b[0] === 0)[2], 15);
    assert.equal(now.last, true);
});
check('old tally records are cleared on a new day', () => {
    const old = dateOf(new RealDate(at(D + 1, 12).getTime() - 30 * 86400000));
    assert.ok(tout.some(m => m.topic === `zigdash/history/tally/0xc1/state/${old}` && m.payload === ''));
});
check('tally topics are not taken for readings', () => {
    const before = JSON.stringify(store.mem || {});
    run('restore', { topic: `zigdash/history/tally/0xc1/state/${dateOf(at(D + 1, 12))}`, payload: '{"v":1,"b":[[0,1,2,3]]}' });
    assert.equal(JSON.stringify(store.mem || {}), before);
});
globalThis.Date = RealDate;
