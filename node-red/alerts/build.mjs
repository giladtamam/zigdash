// Assembles node-red/alerts-flow.json from the function bodies in this
// folder, so the flow's code is never hand-edited inside JSON.
// Usage: node node-red/alerts/build.mjs
import fs from 'node:fs';
const dir = new URL('.', import.meta.url).pathname;
const body = n => fs.readFileSync(dir + n + '.js', 'utf8');
const TAB = 'zigdash_alerts_tab', BROKER = 'zigdash_alerts_broker';
const fn = (id, name, file, x, y, wires, extra = {}) =>
    ({ id, type: 'function', z: TAB, name, func: body(file), outputs: wires.length, noerr: 0,
       initialize: '', finalize: '', libs: [], x, y, wires, ...extra });
const flow = [
    { id: TAB, type: 'tab', label: 'ZigDash alerts', disabled: false,
      info: 'Installed by ZigDash (docs/design/alerts-2.3.md). ZigDash rewrites this tab when alerts change; edits here are lost.' },
    // ZigDash fills broker/port/username in from the Home before installing.
    { id: BROKER, type: 'mqtt-broker', name: 'ZigDash alerts broker', broker: '192.168.1.1', port: '1883',
      clientid: 'zigdash-alerts', autoConnect: true, usetls: false, protocolVersion: '4', keepalive: '60',
      cleansession: true, birthTopic: '', birthQos: '0', birthPayload: '', closeTopic: '', closeQos: '0',
      closePayload: '', willTopic: 'zigdash/alerts/bridge/state', willQos: '1', willRetain: 'true', willPayload: 'offline' },

    { id: 'zda_in_config', type: 'mqtt in', z: TAB, name: 'config', topic: 'zigdash/alerts/config', qos: '1',
      datatype: 'utf8', broker: BROKER, nl: false, rap: true, rh: 0, x: 120, y: 60, wires: [['zda_fn_ingest']] },
    fn('zda_fn_ingest', 'ingest config', 'ingest', 330, 60, [['zda_out']]),

    { id: 'zda_in_state', type: 'mqtt in', z: TAB, name: 'memory', topic: 'zigdash/alerts/state', qos: '1',
      datatype: 'utf8', broker: BROKER, nl: false, rap: true, rh: 0, x: 120, y: 120, wires: [['zda_fn_restore']] },
    fn('zda_fn_restore', 'restore memory', 'restore', 330, 120, [[]]),

    { id: 'zda_in_devices', type: 'mqtt in', z: TAB, name: 'devices', topic: 'zigbee2mqtt/#', qos: '0',
      datatype: 'utf8', broker: BROKER, nl: false, rap: true, rh: 0, x: 120, y: 200, wires: [['zda_fn_watch']] },
    fn('zda_fn_watch', 'watch devices', 'watch', 330, 200, [['zda_fn_push'], ['zda_out']]),

    { id: 'zda_in_test', type: 'mqtt in', z: TAB, name: 'test', topic: 'zigdash/alerts/test', qos: '1',
      datatype: 'utf8', broker: BROKER, nl: false, rap: true, rh: 0, x: 120, y: 280, wires: [['zda_fn_test']] },
    fn('zda_fn_test', 'test', 'test', 330, 280, [['zda_fn_push']]),

    fn('zda_fn_push', 'send', 'push', 540, 240, [['zda_http']], { libs: [{ var: 'crypto', module: 'crypto' }] }),
    { id: 'zda_http', type: 'http request', z: TAB, name: 'post', method: 'use', ret: 'txt', paytoqs: 'ignore',
      url: '', tls: '', persist: false, proxy: '', insecureHTTPParser: false, authType: '', senderr: false,
      headers: [], x: 700, y: 240, wires: [['zda_fn_result']] },
    fn('zda_fn_result', 'result', 'result', 860, 240, [['zda_out']]),

    { id: 'zda_hb', type: 'inject', z: TAB, name: 'every 30s', props: [{ p: 'payload' }], repeat: '30', crontab: '',
      once: true, onceDelay: '1', topic: '', payload: '', payloadType: 'date', x: 120, y: 360, wires: [['zda_fn_hb']] },
    fn('zda_fn_hb', 'online heartbeat', 'heartbeat', 330, 360, [['zda_out']]),

    { id: 'zda_out', type: 'mqtt out', z: TAB, name: 'publish (msg.topic / msg.retain)', topic: '', qos: '1',
      retain: '', respTopic: '', contentType: '', userProps: '', correl: '', expiry: '', broker: BROKER,
      x: 1080, y: 200, wires: [] },
];
fs.writeFileSync(dir + '../alerts-flow.json', JSON.stringify(flow, null, 1) + '\n');
console.log('wrote node-red/alerts-flow.json:', flow.length, 'nodes');
