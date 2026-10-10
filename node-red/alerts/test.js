// Function node "test". In: zigdash/alerts/test, {"phone": "<id>"} or {}.
// Sends a test alert to that phone, or to every channel.
const cfg = flow.get('cfg');
if (!cfg) return null;
let req = {};
try { req = typeof msg.payload === 'object' && !Buffer.isBuffer(msg.payload) ? msg.payload : JSON.parse(msg.payload.toString() || '{}'); } catch (e) {}
return { onlyPhone: req.phone || null,
         payload: { v: 1, kind: 'test', connection: cfg.connection || null, device: null, name: 'ZigDash', home: cfg.home,
                    cleared: false, value: null,
                    at: new Date().toISOString() } };
