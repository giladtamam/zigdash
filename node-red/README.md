# Scheduled-shutter Node-RED flow

Generic daily open/close scheduler for ZigDash, executed on the always-on
SMHUB (SMLIGHT SMHUB Nano 24). ZigDash publishes retained config over MQTT;
this flow watches the clock and fires the shutter commands. Core Node-RED
nodes only — nothing extra to install.

> ⚠️ **Not yet verified on hardware.** This flow JSON is hand-authored from the
> design spec. Import it on the SMHUB, deploy, and run the manual test cases
> below before relying on it. Adjust node coordinates/IDs freely — they don't
> affect behavior.

## One-time install

1. Open Node-RED on the hub: `http://smhub.local:1880` (or `http://192.168.7.210:1880`).
2. Menu (☰) → **Import** → paste the contents of `scheduled-shutter-flow.json` → **Import**.
3. The import includes an `mqtt-broker` config node ("SMHUB Mosquitto") pointed at
   `192.168.7.210:1883`, no credentials. If your broker node differs, double-click
   the imported MQTT nodes and select the correct broker.
4. Click **Deploy**.

## What it does (the MQTT contract)

- **Subscribes:** `zigdash/automation/schedule/+/config` (retained config from ZigDash):
  ```json
  { "name": "...", "target": "zigbee2mqtt/<shutter>/set",
    "openTime": "07:00", "closeTime": "19:00",
    "openPayload": "{\"state\":\"OPEN\"}", "closePayload": "{\"state\":\"CLOSE\"}",
    "enabled": true }
  ```
- **Fires:** publishes `openPayload`/`closePayload` to `target` when the local
  clock reaches `openTime`/`closeTime` (de-duplicated within the minute).
- **Reports:** retained `zigdash/automation/schedule/<id>/state` with
  `enabled`, `nextAction`, `nextAt`, and the last fired action.
- **Heartbeat:** publishes retained `zigdash/automation/bridge/state` = `online`
  on start + every 30s. The broker's Last-Will publishes `offline` (retained) if
  Node-RED disconnects, so ZigDash's "scheduler offline" chip is accurate.

Times are interpreted in the **SMHUB's local time** (the Node-RED process timezone).

## Manual test cases (run after deploy)

From WSL on the dev machine:
```bash
cd ~/projects/zigdash
dart run bin/smoke.dart --host 192.168.7.210 --port 1883 --sub 'zigdash/automation/#' --seconds 6
```

1. **Heartbeat:** after deploy, the smoke output shows retained
   `zigdash/automation/bridge/state = online`.
2. **Fire once at the minute:** publish a config with `openTime` set to the
   current minute → `target` receives `openPayload` exactly once (not repeatedly
   for the rest of that minute).
3. **Disabled:** publish the same config with `enabled:false` → no commands fire;
   `zigdash/automation/schedule/<id>/state` shows `{"enabled":false}`.
4. **Tombstone:** publish an empty retained payload to a `…/config` topic
   (ZigDash does this on panel delete) → that schedule is dropped from the
   in-memory map and stops firing.
