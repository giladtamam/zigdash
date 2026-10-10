// Function node "result". In: the HTTP answer. A 404 or 410 from Google's
// push means that phone's registration is gone: mark it dead (ZigDash
// removes it from the config). A test reports its result to ZigDash.
const status = msg.statusCode;
const out = [];
if (msg.phone && (status === 404 || status === 410)) {
    const dead = flow.get('dead') || {};
    if (!dead[msg.phone]) {
        dead[msg.phone] = true;
        flow.set('dead', dead);
        out.push({ topic: 'zigdash/alerts/state', retain: true,
                   payload: JSON.stringify({ mem: flow.get('mem') || {}, dead }) });
    }
}
if (msg.isTest) {
    out.push({ topic: 'zigdash/alerts/test/result', retain: false,
               payload: JSON.stringify({ phone: msg.phone || null, channel: msg.channel || 'push',
                                         status, ok: status >= 200 && status < 300,
                                         body: String(msg.payload || '').slice(0, 200) }) });
}
if (status < 200 || status >= 300) node.warn('alerts: ' + (msg.channel || 'push') + ' answered ' + status);
return [out];
