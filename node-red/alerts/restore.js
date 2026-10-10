// Function node "restore memory". In: retained zigdash/alerts/state.
// Node-RED's context on the hub is memory only, so what the flow remembers
// (each device's last values, which batteries were reported, dead phones)
// comes back from the broker once, on start.
if (flow.get('memLoaded')) return null;
flow.set('memLoaded', true);
const raw = msg.payload;
if (raw === undefined || raw === null || raw === '' || (Buffer.isBuffer(raw) && raw.length === 0)) return null;
try {
    const s = (typeof raw === 'object' && !Buffer.isBuffer(raw)) ? raw : JSON.parse(raw.toString());
    flow.set('mem', s.mem || {});
    flow.set('dead', s.dead || {});
} catch (e) {
    node.warn('alerts: bad state ' + e);
}
return null;
