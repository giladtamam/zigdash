// Function node "ingest config". In: retained zigdash/alerts/config.
// Keeps the config and an index from device state topic to the alerts that
// watch it. An empty payload (ZigDash turned alerts off) drops everything.
const raw = msg.payload;
const empty = raw === undefined || raw === null ||
    (typeof raw === 'string' && raw.trim() === '') ||
    (Buffer.isBuffer(raw) && raw.length === 0);
if (empty) {
    flow.set('cfg', null);
    flow.set('index', {});
    return null;
}
const cfg = (typeof raw === 'object' && !Buffer.isBuffer(raw)) ? raw : JSON.parse(raw.toString());
const index = {};
for (const a of cfg.alerts || []) {
    if (a.enabled === false) continue;
    for (const d of a.devices || []) {
        if (!d.topic) continue;
        (index[d.topic] = index[d.topic] || []).push({
            id: a.id, kind: a.kind, from: a.from, to: a.to,
            threshold: a.threshold === undefined ? 20 : a.threshold,
            ieee: d.ieee, name: d.name,
        });
    }
}
flow.set('cfg', cfg);
flow.set('index', index);
flow.set('jwts', {}); // a new config may carry new keys
// Forget devices that are no longer watched.
const mem = flow.get('mem') || {};
let changed = false;
for (const t of Object.keys(mem)) if (!index[t]) { delete mem[t]; changed = true; }
if (changed) {
    flow.set('mem', mem);
    return { topic: 'zigdash/alerts/state', retain: true,
             payload: JSON.stringify({ mem, dead: flow.get('dead') || {} }) };
}
return null;
