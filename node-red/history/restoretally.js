// Function node "restore tallies" (3.3). In: retained
// zigdash/history/tally/+/+/+ (tally day records, read back on connect and
// echoed after each publish). Like "restore today": after a restart today's
// record is the only copy of today's counts, and of whether a device was
// still on. Slots already in memory win.
const parts = msg.topic.split('/'); // zigdash history tally <ieee> <attr> <date>
if (parts.length !== 6) return null;
const key = parts[3] + '/' + parts[4];
const date = parts[5];
const cfg = flow.get('cfg');
const tz = (cfg && cfg.timeZone) || 'UTC';
const now = new Date();
const today = new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit' }).format(now);
if (date !== today) return null;
const raw = msg.payload;
if (raw === undefined || raw === null || raw === '' || (Buffer.isBuffer(raw) && raw.length === 0)) return null;
let rec;
try { rec = (typeof raw === 'object' && !Buffer.isBuffer(raw)) ? raw : JSON.parse(raw.toString()); } catch (e) { return null; }
const tmem = flow.get('tmem') || {};
let m = tmem[key];
if (!m || m.date !== date) {
    m = { date, slots: {}, pub: -1, kind: rec.kind, last: null, since: null };
    tmem[key] = m;
}
for (const b of rec.b || []) {
    const [slot, n, minutes] = b;
    if (m.slots[slot]) continue;
    m.slots[slot] = [n, minutes];
}
// Still on when the record was written: keep crediting from then.
if (m.last === null && typeof rec.last === 'boolean') {
    m.last = rec.last;
    m.since = rec.last && typeof rec.since === 'number' ? rec.since : null;
}
flow.set('tmem', tmem);
return null;
