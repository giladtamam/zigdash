# ZigDash — Auto-Close Rule (v1) Design

**Date:** 2026-06-20
**Status:** Approved design, pending implementation plan

## Goal

Let a ZigDash user configure "device X auto-closes N seconds after it turns
on", executed reliably on the always-on SMLIGHT SMHUB Nano 24 via Node-RED —
not by the phone. The phone configures the rule and shows its status;
Node-RED watches the device's state topic and fires the close command when
the delay elapses.

First concrete use case: a Zigbee relay named `door` that should publish
`{"state":"OFF"}` 60 seconds after it transitions to `"state":"ON"`. Same
mechanism works for any Z2M device with a JSON state field — switches,
locks (LOCK after UNLOCK), covers (CLOSE after OPEN), lights.

## Key constraint that drives the architecture

A phone app cannot be the executor: ZigDash is not running mid-countdown
(phone asleep / app closed / out of WiFi range). Whatever holds the timer
must live on the always-on SMHUB. That is Node-RED's job. ZigDash's role is
**configure + monitor**; Node-RED's role is **watch + execute**.

This mirrors the existing scheduled-shutter feature (Phase 4, merged
2026-05-21). The same architectural split is reused.

## Decisions (locked during brainstorming)

1. **Integration transport: MQTT retained-config**, not the Node-RED Admin
   API. Identical to the scheduled-shutter precedent — ZigDash stays
   pure-MQTT, no new transport or auth model.
2. **UX/data model: a new "Auto-close" panel type** (the 15th `PanelType`),
   living on a dashboard alongside the device's manual control panel.
   Reuses the existing panel / grid / form / value-provider infrastructure.
3. **Re-trigger behavior: Lock the timer.** First OFF→ON edge starts the
   countdown; further matching messages while a timer is pending are
   ignored. Close fires exactly `delaySeconds` after the first edge. No
   "extend" mode in v1.
4. **Trigger detection: true edge.** Only OFF→ON transitions fire, not
   every ON message. This is the central correctness requirement — Z2M
   republishes state messages on linkquality changes even when the state
   field hasn't changed, so a level-triggered design fires repeatedly.
5. **Panel tile UX: minimal.** Name + enable switch + one status line
   (`Idle` / `Closing in 47s` / `Disabled` / `Offline`). No manual-cancel
   button, no fire-now button. Tap tile = edit the rule.
6. **Heartbeat is shared** with the scheduler: both flows rely on
   `zigdash/automation/bridge/state`. The scheduler already publishes it;
   the auto-close flow does NOT republish.

## Architecture & MQTT contract

ZigDash stays pure-MQTT. An auto-close rule is two retained topics plus an
always-on Node-RED flow that does the watching and timing.

```
ZigDash  --(retained config)-->  zigdash/automation/autoclose/<panelId>/config
                                         |
                              Node-RED "auto-close" flow (always-on, on SMHUB)
                                         |
                                    watches: <triggerTopic>
                                         |
                  on edge (off->ON), starts <delaySeconds>s timer.
                  timer expires -> publishes closePayload to <target>
                                         |
            zigbee2mqtt/<device>/set <---+
                                         +-> zigdash/automation/autoclose/<panelId>/state  (retained)
ZigDash  <--(state + pendingCloseAt)----------+
ZigDash  <-- zigdash/automation/bridge/state  (shared online/offline heartbeat,
                                               published by the scheduler flow)
```

### Topic: config (ZigDash → Node-RED, retained)

`zigdash/automation/autoclose/<panelId>/config`

```json
{
  "name": "Front door auto-close",
  "triggerTopic": "zigbee2mqtt/door",
  "triggerPath": "state",
  "triggerValue": "ON",
  "target": "zigbee2mqtt/door/set",
  "closePayload": "{\"state\":\"OFF\"}",
  "delaySeconds": 60,
  "enabled": true
}
```

- `<panelId>` = ZigDash panel UUID. Stable, unique, ties the retained
  config to exactly one panel.
- `triggerTopic`, `triggerPath`, `triggerValue`: what to watch and what
  value counts as "open". For Z2M friendly-name devices the defaults
  compose to `zigbee2mqtt/<panel topic>`, path `state`, value `ON` —
  works for switches/relays/lights out of the box. Lock: value `UNLOCK`.
  Cover: value `OPEN`.
- `target` and `closePayload`: where and what to publish when the timer
  fires. Default `target` = `<triggerTopic>/set` (Z2M convention) — user
  can override in the form.
- `delaySeconds`: integer, **bounds `[1, 3600]`** (1 second to 1 hour).
  Stored as seconds. The form offers a "use minutes" toggle for
  convenience but storage and the wire format are always seconds.
- **Tombstone:** deleting the panel publishes an empty retained payload to
  the config topic. Node-RED drops the rule and cancels any pending timer
  for that `panelId`. Same convention as the scheduler.

### Topic: state (Node-RED → ZigDash, retained)

`zigdash/automation/autoclose/<panelId>/state`

```json
{
  "enabled": true,
  "status": "pending",
  "pendingCloseAt": "2026-06-20T17:42:30Z",
  "lastFiredAt": "2026-06-20T16:31:10Z"
}
```

- `status` ∈ `"idle"` | `"pending"` | `"disabled"`.
  - `idle`: rule is enabled but no countdown is currently running.
  - `pending`: a countdown is running; `pendingCloseAt` is non-null.
  - `disabled`: rule's `enabled` is false; any pending timer was cancelled.
- `pendingCloseAt`: non-null only when `status == "pending"`. UTC
  ISO-8601 (`2026-06-20T17:42:30Z`). The phone renders countdowns in
  local time; storing UTC sidesteps SMHUB-vs-phone timezone mismatch.
- `lastFiredAt`: UTC ISO-8601 of the last time the close payload was
  actually published. Null until the first fire.

### Topic: heartbeat (shared with scheduler)

`zigdash/automation/bridge/state` = `"online"` / `"offline"`. **Reused
from the scheduler flow** — the auto-close flow does NOT publish to this
topic. ZigDash's existing "scheduler offline" chip semantically becomes
"automation offline" and covers both flows. (The chip's literal label
will be retitled in the panel widget; existing l10n keys updated.)

### Edge-detection semantics (Node-RED side, normative)

This section is the central correctness requirement of the design.

- The flow holds an in-memory map `lastTriggerValue[panelId] : string?`
  and `pendingTimer[panelId] : timerHandle?`.
- On each incoming message to `triggerTopic`:
  1. Parse JSON. Extract value at `triggerPath`. (If JSON parse fails or
     path is missing, ignore the message.)
  2. Read `prev = lastTriggerValue[panelId]`; update
     `lastTriggerValue[panelId] = current`.
  3. **Fire only when** `prev != triggerValue` AND `current == triggerValue`
     (true OFF→ON edge).
  4. If the rule is `enabled: false`, skip firing.
  5. If `pendingTimer[panelId]` already exists, skip firing (Lock
     semantics — first edge wins).
- Otherwise: start a `delaySeconds` timer, publish updated state
  (`status: "pending"`, `pendingCloseAt`). When the timer expires:
  publish `closePayload` to `target`, clear `pendingTimer[panelId]`,
  publish updated state (`status: "idle"`, `lastFiredAt`, `pendingCloseAt: null`).
- Receiving a new `config` payload for an existing `panelId` while a
  timer is pending: cancel the pending timer (the rule has been
  reconfigured; safest is to drop in-flight state and let the next edge
  start fresh under the new settings).
- Receiving an empty `config` payload (tombstone): cancel any pending
  timer, remove all state for that `panelId`.

## ZigDash app changes (deliberately small)

### No Drift migration

`PanelType` is persisted via `textEnum` (stores the enum *name*). Adding
a 15th value `autoClose` is purely additive — existing rows are
unaffected and `schemaVersion` does not change. Rule settings live in the
existing `config` JSON column.

### Files added

- **`lib/features/panels/models/panel_config.dart`** — new
  `AutoCloseConfig` class with fields:
  - `String triggerPath` (default `"state"`)
  - `String triggerValue` (default `"ON"`)
  - `String closePayload` (default `'{"state":"OFF"}'`)
  - `int delaySeconds` (default `60`, bounds `[1, 3600]`)
  - `bool enabled` (default `true`)
  
  Hand-rolled `toJson`/`fromJson`, matching the existing `ScheduleConfig`
  style. Wired into `PanelConfig.decode` (the dispatcher in the same
  file). Validation: a constructor assert (or factory) clamps
  `delaySeconds` into bounds; out-of-range JSON falls back to default.

- **`lib/features/panels/services/auto_close_config_publisher.dart`** —
  sibling of `AutomationConfigPublisher`. Same shape (`publishConfig` /
  `clearConfig`), different namespace:
  - `configTopic(panelId)` → `zigdash/automation/autoclose/$panelId/config`
  - `stateTopic(panelId)` → `zigdash/automation/autoclose/$panelId/state`
  - Reuses `AutomationConfigPublisher.bridgeStateTopic` (no duplication
    of the heartbeat topic string).
  
  Kept as a sibling, NOT a refactor of `AutomationConfigPublisher`. The
  scheduled-shutter code stays untouched.

- **`lib/features/panels/widgets/auto_close_panel.dart`** — the tile
  widget. Shows name, enable switch, status line driven by the state
  topic (via the existing `panelValueProvider`). Status line is computed
  client-side from the parsed state payload + current wall clock:
  - `"idle"` → `Idle`
  - `"pending"` with `pendingCloseAt` → `Closing in 47s` (recomputed
    every 1s via a periodic timer; widget-local, not a provider rebuild)
  - `"disabled"` → `Disabled`
  - bridge heartbeat stale → `Offline` (overrides the above, same chip
    behaviour as `SchedulePanel`)

- **`node-red/auto-close-flow.json`** + **`node-red/AUTO_CLOSE_README.md`**
  — the executor. Core nodes only (no extra palette install). High-level
  shape:
  - `mqtt in` on `zigdash/automation/autoclose/+/config` → function
    node maintains `rules: Map<panelId, ruleConfig>`. Empty payload
    removes the entry and cancels any pending timer.
  - For each rule's `triggerTopic`, a dynamic `mqtt in` subscription is
    created/torn-down by a function node (using the runtime
    `node.send`/global context approach, or a simple "subscribe to a
    wildcard + filter" approach — implementation detail decided in the
    plan).
  - Function node implements the edge-detection state machine described
    in the *Edge-detection semantics* section above.
  - `mqtt out` publishes close payloads to `target` and state payloads
    to `zigdash/automation/autoclose/<panelId>/state` (retained).
  - No heartbeat node — `bridge/state` is the scheduler flow's
    responsibility.

  README mirrors `node-red/README.md`: import instructions, the MQTT
  contract section, and at least four manual test cases:
  1. Edge fires once: `state=OFF` → `state=ON` triggers a single close
     after `delaySeconds`. Duplicate `state=ON` messages during the
     countdown do NOT extend or restart it.
  2. Edge filter: a message with `state=ON` arriving when prev was
     already `ON` does NOT fire.
  3. Disabled: publishing config with `enabled:false` cancels any
     pending timer and prevents new ones.
  4. Tombstone: empty retained config drops the rule and cancels any
     pending timer.

### Files modified

- **`lib/data/database/tables/panels.dart`** — append `autoClose` as the
  15th value of `PanelType`. Comment: `// No migration: textEnum is
  additive (same as `schedule`, `scene`).`
- **`lib/features/panels/screens/panel_form_screen.fields.dart`** — a
  new type-aware section, shown when the form's selected type is
  `autoClose`:
  - **Device-type preset** dropdown (Switch / Lock / Cover / Custom).
    Selecting a preset pre-fills `triggerValue` + `closePayload`
    (Switch: `ON`/`{"state":"OFF"}`; Lock: `UNLOCK`/`{"state":"LOCK"}`;
    Cover: `OPEN`/`{"state":"CLOSE"}`; Custom: leaves fields as-is).
  - `triggerPath` text field (default `state`).
  - `triggerValue` text field.
  - `closePayload` text field (multiline, monospace).
  - `delaySeconds` numeric field + "Use minutes" toggle for input
    convenience. Stored value is always seconds.
  - `enabled` switch.
- **`lib/features/panels/widgets/panel_tile.dart`** — add
  `case PanelType.autoClose: return AutoClosePanel(panel: panel);`
  to the dispatcher.
- **`lib/features/dashboards/screens/dashboards_screen.dart`**
  (`_openPanelPicker`) — picker entry "Auto-close rule" under the
  Control group.
- **`lib/l10n/app_en.arb`** + **`lib/l10n/app_he.arb`** — new keys for
  the picker label, panel-type display name, status line variants,
  form field labels, preset names, and the renamed "automation
  offline" chip. EN/HE parity enforced by `flutter gen-l10n`.

### Component boundaries

Each unit can be understood and tested independently:

- `AutoCloseConfig` — pure data + (de)serialization. No I/O. Bounds
  clamping for `delaySeconds`. Testable with `flutter test`.
- `AutoCloseConfigPublisher` — turns (panel + config + connection) into
  a retained MQTT publish. Depends only on `MqttManager` and
  `AutoCloseConfig`. Unit-tested for topic + payload construction +
  tombstone case.
- `AutoClosePanel` widget — display + enable toggle; depends on
  `panelValueProvider` (state) and `AutoCloseConfigPublisher` (writes).
  Widget-tested for the four status states (`idle`, `pending`,
  `disabled`, `offline`).
- Node-RED flow — independent executor. Only contract with ZigDash is
  the three topics above.

## Error handling

- **Heartbeat stale / "automation offline":** the existing chip (driven
  by `zigdash/automation/bridge/state` going stale) covers this rule
  type too. Chip label retitled in l10n; widget code shared with
  `SchedulePanel` (extract a small `_AutomationOfflineChip` helper if
  needed, or duplicate — plan decides).
- **Publish while disconnected:** the config publish is attempted on
  save / enable-toggle / delete. On failure ZigDash surfaces a snackbar
  (same pattern as `SchedulePanel`). Because the config is retained,
  once it lands it persists across broker/flow restarts.
- **Phone-vs-SMHUB clock skew:** `pendingCloseAt` is UTC published by
  the SMHUB; the phone uses it directly to compute the countdown. A few
  seconds of drift is acceptable for a countdown display. The actual
  fire timing is governed by the SMHUB's own timer, so skew never causes
  early or late firing of the close payload — only a slightly
  off-by-seconds display.
- **JSON parse failure on a trigger message:** ignored silently. Logged
  to Node-RED debug only.
- **Trigger path missing from the JSON:** treated as "value didn't
  match", no fire.

## Testing

### Pure-Dart unit tests

- `AutoCloseConfig` JSON round-trip (defaults, all fields, bounds
  clamping for `delaySeconds`).
- `AutoCloseConfigPublisher` topic + payload construction (including
  the tombstone empty-payload case).
- Status-line computation (given a state payload + current time → the
  rendered string), covering each of `idle` / `pending` / `disabled` /
  `offline` and the `pending` countdown formatting at various offsets.

### Widget tests

- `AutoClosePanel` renders the four status states correctly.
- Enable-switch tap publishes the expected config payload via a fake
  `AutoCloseConfigPublisher`.

### Node-RED flow

- The four manual test cases enumerated in the flow README, run on the
  real SMHUB against the real `door` device, before claiming completion.

### Verification-before-completion (end state)

1. Import the auto-close flow into Node-RED on the SMHUB (via the
   embedded "nodered" app in the SMHUB web UI, or directly at the
   Node-RED editor URL once confirmed reachable from the dev machine).
2. In ZigDash, add an Auto-close panel on the relevant dashboard:
   device topic `door`, Switch preset, 60s delay, enabled.
3. Confirm the retained config on the broker:
   `dart run bin/smoke.dart --host 10.0.0.57 --port 1883 --sub 'zigdash/automation/autoclose/#' --seconds 6`.
4. Confirm the state topic shows `status: "idle"`.
5. Turn the door ON (via its toggle panel or physically). Within 1s,
   the panel tile must show `Closing in 60s` (decrementing). Confirm
   the state topic flipped to `status: "pending"` with a `pendingCloseAt`
   ~60s in the future.
6. Wait 60s. The relay must physically click OFF and the state topic
   must flip back to `status: "idle"` with `lastFiredAt` populated.
7. Repeat: turn the door ON, then back ON within 30s. The OFF must
   still fire 60s after the FIRST ON (Lock semantics).
8. Disable the rule (panel tile switch). Confirm any pending close is
   cancelled and `status: "disabled"`.
9. Delete the panel. Confirm the config topic is empty (retained
   tombstone) and any pending timer is cancelled.

No "done" claim until steps 5–9 all pass on the real device.

## Out of scope for v1

- **Extend-timer mode** (each new edge resets the countdown to full
  `delaySeconds`). v1 is Lock only. Clean future extension: a
  `retriggerMode` field on the config blob.
- **Manual cancel-pending button** on the panel tile.
- **"Close now" / "Fire immediately" button.** The device's regular
  Toggle/Button panel already covers manual control.
- **Multiple trigger paths per rule** (e.g., fire only when motion AND
  door open).
- **Non-JSON trigger payload formats** (raw text, binary). All Z2M
  devices publish JSON, which covers the immediate need.
- **Delay > 1 hour.** Bounds are `[1, 3600]` seconds; longer delays
  are scheduled-shutter territory.

All are clean future extensions of the same config blob and/or flow.
