// Assembles node-red/history-flow.json from the function bodies in this
// folder, so the flow's code is never hand-edited inside JSON.
// Usage: node node-red/history/build.mjs
import fs from 'node:fs';
const dir = new URL('.', import.meta.url).pathname;
const body = n => fs.readFileSync(dir + n + '.js', 'utf8');
const TAB = 'zigdash_history_tab', BROKER = 'zigdash_history_broker';
const fn = (id, name, file, x, y, wires, extra = {}) =>
    ({ id, type: 'function', z: TAB, name, func: body(file), outputs: wires.length, noerr: 0,
       initialize: '', finalize: '', libs: [], x, y, wires, ...extra });
const flow = [
    { id: TAB, type: 'tab', label: 'ZigDash history', disabled: false,
      info: 'Installed by ZigDash (docs/design/history-2.7.md). Records every reading tile into retained day records on zigdash/history/<ieee>/<attribute>/<date>. ZigDash rewrites this tab; edits here are lost.' },
    // ZigDash fills broker/port/username in from the Home before installing.
    { id: BROKER, type: 'mqtt-broker', name: 'ZigDash history broker', broker: '192.168.1.1', port: '1883',
      clientid: 'zigdash-history', autoConnect: true, usetls: false, protocolVersion: '4', keepalive: '60',
      cleansession: true, birthTopic: '', birthQos: '0', birthPayload: '', closeTopic: '', closeQos: '0',
      closePayload: '', willTopic: 'zigdash/history/bridge/state', willQos: '1', willRetain: 'true', willPayload: 'offline' },

    { id: 'zdh_in_config', type: 'mqtt in', z: TAB, name: 'config', topic: 'zigdash/history/config', qos: '1',
      datatype: 'utf8', broker: BROKER, nl: false, rap: true, rh: 0, x: 120, y: 60, wires: [['zdh_fn_ingest']] },
    fn('zdh_fn_ingest', 'ingest config', 'ingest', 330, 60, [[]]),

    { id: 'zdh_in_records', type: 'mqtt in', z: TAB, name: 'day records', topic: 'zigdash/history/+/+/+', qos: '1',
      datatype: 'utf8', broker: BROKER, nl: false, rap: true, rh: 0, x: 120, y: 120, wires: [['zdh_fn_restore']] },
    fn('zdh_fn_restore', 'restore today', 'restore', 330, 120, [[]]),

    { id: 'zdh_in_tallies', type: 'mqtt in', z: TAB, name: 'tally records', topic: 'zigdash/history/tally/+/+/+', qos: '1',
      datatype: 'utf8', broker: BROKER, nl: false, rap: true, rh: 0, x: 120, y: 160, wires: [['zdh_fn_restoretally']] },
    fn('zdh_fn_restoretally', 'restore tallies', 'restoretally', 330, 160, [[]]),

    { id: 'zdh_in_devices', type: 'mqtt in', z: TAB, name: 'devices', topic: 'zigbee2mqtt/#', qos: '0',
      datatype: 'utf8', broker: BROKER, nl: false, rap: true, rh: 0, x: 120, y: 220, wires: [['zdh_fn_record', 'zdh_fn_tally']] },
    fn('zdh_fn_record', 'record', 'record', 330, 200, [[]]),
    fn('zdh_fn_tally', 'tally', 'tally', 330, 240, [[]]),

    { id: 'zdh_tick', type: 'inject', z: TAB, name: 'every minute', props: [{ p: 'payload' }], repeat: '60', crontab: '',
      once: true, onceDelay: '5', topic: '', payload: '', payloadType: 'date', x: 120, y: 280, wires: [['zdh_fn_tick']] },
    fn('zdh_fn_tick', 'tick', 'tick', 330, 280, [['zdh_out']]),

    { id: 'zdh_hb', type: 'inject', z: TAB, name: 'every 30s', props: [{ p: 'payload' }], repeat: '30', crontab: '',
      once: true, onceDelay: '1', topic: '', payload: '', payloadType: 'date', x: 120, y: 360, wires: [['zdh_fn_hb']] },
    fn('zdh_fn_hb', 'online heartbeat', 'heartbeat', 330, 360, [['zdh_out']]),

    { id: 'zdh_out', type: 'mqtt out', z: TAB, name: 'publish (msg.topic / msg.retain)', topic: '', qos: '1',
      retain: '', respTopic: '', contentType: '', userProps: '', correl: '', expiry: '', broker: BROKER,
      x: 600, y: 280, wires: [] },
];
fs.writeFileSync(dir + '../history-flow.json', JSON.stringify(flow, null, 1) + '\n');
console.log('wrote node-red/history-flow.json:', flow.length, 'nodes');
