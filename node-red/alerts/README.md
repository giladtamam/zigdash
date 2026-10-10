# ZigDash alerts flow

The hub-side half of alerts (docs/design/alerts-2.3.md). Node-RED on the
always-on hub watches the devices named in a retained config and sends each
alert as an end-to-end encrypted Web Push to every phone running ZigDash
(Google's push service carries it, with no second app and no ZigDash server),
and optionally to ntfy or Pushover. Core nodes only; the `send` function
uses Node's built-in `crypto` through the function node's Setup tab.

- `*.js` — the function-node bodies, one per node. Edit these, not the JSON.
- `build.mjs` — assembles `../alerts-flow.json` from them: `node node-red/alerts/build.mjs`.
- `test/harness.mjs` — runs the bodies as Node-RED would through a scripted
  day (leak, door at night, battery, restart, dead phone, test):
  `node node-red/alerts/test/harness.mjs`.

ZigDash installs the flow itself through Node-RED's admin API, filling in
the Home's broker address (never `localhost`: on SMHUB, Node-RED can't reach
the broker that way) and the Zigbee2MQTT base topic. To import by hand: open
Node-RED, Import, paste `alerts-flow.json`, set the broker, Deploy.

Verified 2026-10-10 on the user's SMHUB (Node-RED 4.1.10): installed via
`POST /flow`, a fake sensor's dry → wet sent a push that woke a closed
ZigDash on an Android 16 emulator; the test topic answered on
`zigdash/alerts/test/result`.
