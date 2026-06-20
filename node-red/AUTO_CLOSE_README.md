# Auto-close Node-RED flow

Generic auto-close executor for ZigDash, running on the always-on SMHUB
(SMLIGHT SMHUB Nano 24). ZigDash publishes retained config over MQTT; this
flow watches each rule's `triggerTopic`, detects true OFF→ON edges (ignoring
Z2M's duplicate state messages), and fires the close payload `<delaySeconds>`
later. Core Node-RED nodes only.

> ⚠️ **Not yet verified on hardware.** Import on the SMHUB, deploy, and run
> the manual test cases below before relying on it.

This flow does NOT publish the `bridge/state` heartbeat — that's owned by the
`scheduled-shutter-flow.json` scheduler. Deploy BOTH flows on the same hub
for the "automation offline" chip in the app to work correctly.

## One-time install

1. Open Node-RED on the SMHUB (via the embedded "nodered" app in the SMHUB
   web UI, or `http://10.0.0.57:1880` if reachable on the LAN).
2. Menu (☰) → **Import** → paste the contents of `auto-close-flow.json` →
   **Import**.
3. The import includes an `mqtt-broker` config node ("SMHUB Mosquitto")
   pointed at `10.0.0.57:1883`, no credentials. If your broker differs,
   double-click the imported MQTT nodes and select the correct broker.
4. Click **Deploy**.
5. If `scheduled-shutter-flow.json` was deployed pre-IP-change, re-import
   it too (its broker config still references the old IP `192.168.7.210`).

## What it does (the MQTT contract)

- **Subscribes:** `zigdash/automation/autoclose/+/config` (retained config from ZigDash):
  ```json
  { "name": "...", "triggerTopic": "zigbee2mqtt/door", "triggerPath": "state",
    "triggerValue": "ON", "target": "zigbee2mqtt/door/set",
    "closePayload": "{\"state\":\"OFF\"}", "delaySeconds": 60, "enabled": true }
  ```
- **Watches:** `zigbee2mqtt/#`. For non-Z2M trigger topics, add additional
  `mqtt in` nodes wired to the same `edge detect + arm timer` function node.
- **Fires:** on a true OFF→ON edge per `triggerPath`/`triggerValue`, arms a
  `delaySeconds` timer. When it expires, publishes `closePayload` to `target`.
- **Reports:** retained `zigdash/automation/autoclose/<id>/state`:
  - `{"enabled":true,"status":"idle"}` (or `"disabled"`)
  - `{"enabled":true,"status":"pending","pendingCloseAt":"<UTC ISO-8601>"}`
  - After firing: `{"enabled":true,"status":"idle","lastFiredAt":"<UTC ISO-8601>"}`

### Edge-detection semantics (the central correctness requirement)

Z2M republishes state messages on every `linkquality` change, including
when `state` itself didn't change. A level-triggered design fires forever
on these. This flow holds `lastValues[panelId:triggerTopic]` and fires
only when the previous extracted value differed from the current one
(true OFF→ON edge). While a timer is pending for a rule, further matching
messages are ignored (**Lock semantics**).

## Manual test cases (run after deploy)

From WSL on the dev machine:
```bash
cd ~/projects/zigdash
dart run bin/smoke.dart --host 10.0.0.57 --port 1883 \
  --sub 'zigdash/automation/autoclose/#' --seconds 10
```

1. **Edge fires once.** Publish a rule with `triggerTopic` =
   `zigbee2mqtt/door`, `delaySeconds` = 10 (use a short delay for testing).
   Toggle the door OFF→ON. Exactly one close command must publish to
   `zigbee2mqtt/door/set` 10 seconds later. The state topic must transition
   `idle` → `pending` → `idle` with a populated `lastFiredAt`.
2. **Duplicate ON ignored.** While the timer is pending, manually publish
   another `{"state":"ON"}` message to `zigbee2mqtt/door` via mosquitto_pub.
   The timer must NOT extend (close fires at the original `pendingCloseAt`,
   not 10s later).
3. **Disabled cancels pending.** While a timer is pending, publish an
   updated config with `enabled:false`. The pending timer must be
   cancelled and the state topic must show `{"enabled":false,"status":"disabled"}`.
4. **Tombstone removes rule.** Publish an empty retained payload to the
   `…/config` topic. The state topic must clear (empty retained), any
   pending timer must be cancelled, and the rule must be removed from the
   in-memory map (re-publishing matching trigger messages no longer fires).

Use Test #1 as the regression check after any flow edit; #2 is the
correctness check that proves edge detection works.

## Editing the flow

Adjust node coordinates/IDs freely — they don't affect behavior. The
function-node JavaScript is the meaningful logic; if you change it,
re-run all four manual test cases.
