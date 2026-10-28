// Function node "tally" (3.3). In: <base>/# device state messages.
// For each configured light, plug, door or motion sensor, counts the times
// it turned on, opened or saw motion, per 15-minute slot of today, and
// credits on time to the slot when it turns off ("tick" credits devices
// still on every minute). Repeated reports of the same value count once.
// Publishing happens in "tick".
const tindex = flow.get('tindex') || {};
const tallies = tindex[msg.topic];
if (!tallies) return null;
let state = msg.payload;
if (Buffer.isBuffer(state)) state = state.toString();
if (typeof state === 'string') { try { state = JSON.parse(state); } catch (e) { return null; } }
if (!state || typeof state !== 'object') return null;
const cfg = flow.get('cfg') || {};
const tz = cfg.timeZone || 'UTC';
const now = new Date();
const p = Object.fromEntries(new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' })
    .formatToParts(now).map(x => [x.type, x.value]));
const date = `${p.year}-${p.month}-${p.day}`;
const slot = Math.floor((Number(p.hour) * 60 + Number(p.minute)) / 15);
// Zigbee2MQTT: lights and plugs say "ON"/"OFF", contact true means closed,
// occupancy true means motion.
const active = (kind, v) => {
    if (kind === 'on') return v === 'ON' || v === 'on' || v === true;
    if (kind === 'open') return v === false;
    return v === true;
};
const tmem = flow.get('tmem') || {};
for (const t of tallies) {
    let v = state;
    for (const seg of t.path.split('.')) v = v === null || v === undefined ? undefined : v[seg];
    if (v === undefined || v === null) continue;
    const on = active(t.kind, v);
    let m = tmem[t.key];
    if (!m || m.date !== date) {
        // A new day before "tick" closed the old one: tick publishes it.
        if (m && m.date !== date) {
            const done = flow.get('tdone') || [];
            done.push({ key: t.key, rec: m });
            flow.set('tdone', done);
        }
        m = { date, slots: {}, pub: -1, kind: t.kind, last: m ? m.last : null, since: m ? m.since : null };
        tmem[t.key] = m;
    }
    m.kind = t.kind;
    const s = m.slots[slot] || (m.slots[slot] = [0, 0]);
    if (on && m.last !== true) {
        // The first value after a start isn't a change unless it was off.
        if (m.last === false) s[0] += 1;
        m.since = now.getTime();
    } else if (!on && m.last === true) {
        if (m.since) s[1] += Math.max(0, now.getTime() - m.since) / 60000;
        m.since = null;
    }
    m.last = on;
}
flow.set('tmem', tmem);
return null;
