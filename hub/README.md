# ZigDash Engine

`zigdash-engine.js` runs a Home's Automations, Alerts and history Recorder inside Zigbee2MQTT (2.4 or newer) on the hub. The ZigDash app installs it as a Zigbee2MQTT external extension; it is not meant to be copied by hand. Contract and behaviour: [docs/design/zigdash-3.0.md](../docs/design/zigdash-3.0.md).

- `src/engine.js` — the source. Edit this.
- `build.mjs` — builds `zigdash-engine.js` from the source and the Node-RED flows' function bodies (`node-red/alerts/*.js`, `node-red/history/*.js`), which run inside the Engine unchanged: `node hub/build.mjs`.
- `test/engine.test.js` — Node tests against a fake Zigbee2MQTT, including the flows and a check that the built file is current: `node --test hub/test/engine.test.js`.
- `src/chat.js` — ZigDash Chat ([docs/design/chat-linking.md](../docs/design/chat-linking.md)), appended to the release build since 3.7.0. Dormant until a Chat client is linked: it subscribes only to `zigdash/chat/clients/+`. A client's config (published once by the app or the `tool/zigdash-chat` CLI) is kept in `zigdash-chat.json` in the Zigbee2MQTT data folder (mode 600) and its retained copy is cleared; `{"v":1,"delete":true}` (or an empty payload) deletes the client. Tests: `node --test hub/test/chat.test.js hub/test/dormant.test.js` (the second runs rules, alerts, history and the relay on the Engine with and without Chat and compares everything they send). `node hub/build.mjs --chat` (milestone 1's hand-installed `9.0.0-chat` build) is legacy and not needed any more.

While a Node-RED copy of the alerts or history flow still beats on its heartbeat topic, that flow stays passive in the Engine (it keeps its memory but sends and publishes nothing) and takes over 90 s after the last foreign beat.

Verified live on 2026-10-22 against Zigbee2MQTT 2.8.0: installed over the frontend WebSocket with no restart, fired a clock rule on its minute in Asia/Jerusalem, took over alerts and history after the observe window and kept both active across beats, removed cleanly with an offline beat.
