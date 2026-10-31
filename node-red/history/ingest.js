// Function node "ingest config". In: retained zigdash/history/config.
// Keeps the config and an index from device state topic to the readings
// recorded from it, and another to the tallies (3.3: on time and openings
// of lights, plugs, doors and motion sensors). An empty payload stops recording; records already on
// the broker stay until they age out.
const raw = msg.payload;
const empty = raw === undefined || raw === null ||
    (typeof raw === 'string' && raw.trim() === '') ||
    (Buffer.isBuffer(raw) && raw.length === 0);
if (empty) {
    flow.set('cfg', null);
    flow.set('index', {});
    flow.set('tindex', {});
    return null;
}
const cfg = (typeof raw === 'object' && !Buffer.isBuffer(raw)) ? raw : JSON.parse(raw.toString());
const index = {};
const keys = new Set();
for (const r of (cfg.readings || []).slice(0, 50)) {
    if (!r.topic || !r.ieee || !r.attr || !r.path) continue;
    const key = r.ieee + '/' + r.attr;
    keys.add(key);
    (index[r.topic] = index[r.topic] || []).push({ key, path: r.path, unit: r.unit || '' });
}
const tindex = {};
const tkeys = new Set();
for (const t of (cfg.tallies || []).slice(0, 50)) {
    if (!t.topic || !t.ieee || !t.attr || !t.path || !['on', 'open', 'motion'].includes(t.kind)) continue;
    const key = t.ieee + '/' + t.attr;
    tkeys.add(key);
    (tindex[t.topic] = tindex[t.topic] || []).push({ key, path: t.path, kind: t.kind });
}
flow.set('cfg', cfg);
flow.set('index', index);
flow.set('tindex', tindex);
// Forget readings that are no longer recorded.
const mem = flow.get('mem') || {};
for (const k of Object.keys(mem)) if (!keys.has(k)) delete mem[k];
flow.set('mem', mem);
const tmem = flow.get('tmem') || {};
for (const k of Object.keys(tmem)) if (!tkeys.has(k)) delete tmem[k];
flow.set('tmem', tmem);
return null;
