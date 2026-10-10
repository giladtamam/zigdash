// Function node "watch devices". In: every message under the Home's
// Zigbee2MQTT base topic. Out 1: alert events to send. Out 2: retained
// state and recent-alerts publishes. Fires on changes, never on values:
// Zigbee2MQTT republishes a device's whole state whenever anything asks.
const index = flow.get('index') || {};
const cfg = flow.get('cfg');
const topic = msg.topic;
if (!cfg || topic.endsWith('/set') || topic.endsWith('/get') || topic.includes('/bridge/')) return null;
const hits = index[topic];
if (!hits) return null;
let state;
try {
    const raw = msg.payload;
    state = (typeof raw === 'object' && !Buffer.isBuffer(raw)) ? raw : JSON.parse(raw.toString());
} catch (e) { return null; }
if (!state || typeof state !== 'object') return null;

const mem = flow.get('mem') || {};
const fresh = !mem[topic];           // first sight since the flow (re)started with no memory
const m = mem[topic] || (mem[topic] = {});
const now = new Date();
const hhmm = now.toLocaleTimeString('en-GB', { timeZone: cfg.timeZone || 'UTC', hour12: false }).slice(0, 5);
const within = (from, to) => {
    if (!from || !to) return true;
    return from <= to ? (hhmm >= from && hhmm < to) : (hhmm >= from || hhmm < to);
};
const events = [];
let changed = false;
const event = (h, kind, cleared, value) => ({
    v: 1, kind, device: h.ieee, name: h.name, home: cfg.home, cleared, value: value === undefined ? null : value,
    at: now.toISOString(),
});

for (const h of hits) {
    switch (h.kind) {
        case 'leak':
        case 'smoke': {
            const v = h.kind === 'leak' ? state.water_leak : state.smoke;
            if (typeof v !== 'boolean') break;
            const was = m[h.kind];
            if (was === undefined ? (fresh && v) : v !== was) events.push(event(h, h.kind, !v));
            if (was !== v) { m[h.kind] = v; changed = true; }
            break;
        }
        case 'opened': {
            const v = state.contact;
            if (typeof v !== 'boolean') break;
            // contact: true = closed. An opening is closed -> open.
            if (m.contact === true && v === false && within(h.from, h.to)) events.push(event(h, 'opened', false));
            if (m.contact !== v) { m.contact = v; changed = true; }
            break;
        }
        case 'battery': {
            const level = typeof state.battery === 'number' ? state.battery : undefined;
            const flag = state.battery_low;
            if (level === undefined && typeof flag !== 'boolean') break;
            const low = flag === true || (level !== undefined && level <= h.threshold);
            const was = m.batteryLow;
            if (low && (was === false || (was === undefined && fresh))) events.push(event(h, 'battery', false, level));
            if (was !== low) { m.batteryLow = low; changed = true; }
            break;
        }
    }
}
if (fresh) changed = true;
flow.set('mem', mem);

const out2 = [];
if (changed) {
    out2.push({ topic: 'zigdash/alerts/state', retain: true,
                payload: JSON.stringify({ mem, dead: flow.get('dead') || {} }) });
}
if (events.length) {
    const recent = [...events.slice().reverse(), ...(flow.get('recent') || [])].slice(0, 20);
    flow.set('recent', recent);
    out2.push({ topic: 'zigdash/alerts/recent', retain: true, payload: JSON.stringify(recent) });
}
return [events.map(e => ({ payload: e })), out2];
