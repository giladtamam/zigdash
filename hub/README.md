# ZigDash Engine

`zigdash-engine.js` runs a Home's Automations, Alerts and history Recorder inside Zigbee2MQTT (2.4 or newer) on the hub. The ZigDash app installs it as a Zigbee2MQTT external extension; it is not meant to be copied by hand. Contract and behaviour: [docs/design/zigdash-3.0.md](../docs/design/zigdash-3.0.md).

- `src/engine.js` — the source. Edit this.
- `build.mjs` — builds `zigdash-engine.js` from the source and the Node-RED flows' function bodies (`node-red/alerts/*.js`, `node-red/history/*.js`), which run inside the Engine unchanged: `node hub/build.mjs`.
- `test/engine.test.js` — Node tests against a fake Zigbee2MQTT, including the flows and a check that the built file is current: `node --test hub/test/engine.test.js`.
- `src/chat.js` — ZigDash Chat, milestone 1 ([docs/design/whatsapp-assistant.md](../docs/design/whatsapp-assistant.md), revision 6): `node hub/build.mjs --chat` builds a separate Engine, version `9.0.0-chat`, into `hub/build/zigdash-engine.js` (not in git, not bundled by the app; installed by hand on the owner's hub only). The release build never reads `chat.js`. Tests: `node --test hub/test/chat.test.js`.

While a Node-RED copy of the alerts or history flow still beats on its heartbeat topic, that flow stays passive in the Engine (it keeps its memory but sends and publishes nothing) and takes over 90 s after the last foreign beat.

Verified live on 2026-10-22 against Zigbee2MQTT 2.8.0: installed over the frontend WebSocket with no restart, fired a clock rule on its minute in Asia/Jerusalem, took over alerts and history after the observe window and kept both active across beats, removed cleanly with an offline beat.
