# ZigDash — Node-RED Scheduled Automation (v1) Design

**Date:** 2026-05-21
**Status:** Approved design, pending implementation plan

## Goal

Let a ZigDash user schedule a shutter (cover) to open and close at fixed daily
times, executed reliably on the always-on SMLIGHT SMHUB Nano 24 via Node-RED —
not by the phone. The phone app configures the schedule and shows its status;
Node-RED watches the clock and fires the commands.

First concrete automation: **"Scheduled shutter"** — opens at a morning time,
closes at an evening time, every day, automatically. Manual OPEN/STOP/CLOSE is
already covered by the existing Cover panel sitting next to it.

## Key constraint that drives the architecture

A phone app cannot be the scheduler: ZigDash is not running at 07:00 (phone
asleep / app closed). Whatever fires on a clock must live on the always-on
SMHUB. That is Node-RED's job. ZigDash's role is **configure + monitor**;
Node-RED's role is **execute**.

## Decisions (locked during brainstorming)

1. **Integration transport: MQTT retained-config**, not the Node-RED Admin API.
   ZigDash is a pure-MQTT app (single `MqttManager`); MQTT adds no new transport,
   dependency, or auth model. The HTTP Admin API is reserved for a future
   "author arbitrary flows in-app" project.
2. **UX/data model: a new "Schedule" panel type** (the 13th `PanelType`), living
   on a dashboard next to the manual Cover panel. Reuses the existing
   panel/grid/form/value-provider infrastructure — least new code.
3. **Schedule richness (v1): daily fixed times only** — one open time + one close
   time, same every day. Day-of-week, sunrise/sunset, and multiple actions are
   explicit future extensions of the same config blob (YAGNI).

## Architecture & MQTT contract

ZigDash stays pure-MQTT. A scheduled automation is two retained topics plus an
always-on Node-RED flow that does the clock-watching.

```
ZigDash  --(retained config)-->  zigdash/automation/schedule/<panelId>/config
                                         |
                              Node-RED "scheduler" flow (always-on, on SMHUB)
                                         |  fires at open/close time
            zigbee2mqtt/<shutter>/set <--+
                                         +--> zigdash/automation/schedule/<panelId>/state  (retained)
ZigDash  <--(state + next-action)--------------+
ZigDash  <-- zigdash/automation/bridge/state  ("online"/"offline" heartbeat)
```

### Topic: config (ZigDash -> Node-RED, retained)

`zigdash/automation/schedule/<panelId>/config`

```json
{
  "name": "Living-room shutter",
  "target": "zigbee2mqtt/living_shutter/set",
  "openTime": "07:00",
  "closeTime": "19:00",
  "openPayload": "{\"state\":\"OPEN\"}",
  "closePayload": "{\"state\":\"CLOSE\"}",
  "enabled": true
}
```

- `<panelId>` is the ZigDash panel's UUID — stable, unique, ties the retained
  config to exactly one panel.
- `target` is the composed shutter command topic (dashboard prefix + panel
  `topic`, via the existing `composeTopic`), so it follows the same topic rules
  as every other panel.
- Deleting the panel (or disabling the whole feature) publishes an **empty
  retained payload** to the config topic as a tombstone, so Node-RED cancels and
  forgets that schedule.

### Topic: state (Node-RED -> ZigDash, retained)

`zigdash/automation/schedule/<panelId>/state`

```json
{
  "enabled": true,
  "nextAction": "close",
  "nextAt": "2026-05-21T19:00",
  "lastAction": "open",
  "lastAt": "2026-05-21T07:00"
}
```

### Topic: heartbeat (Node-RED -> ZigDash, retained)

`zigdash/automation/bridge/state` = `"online"` while the flow runs (published on
start + periodically). ZigDash shows a warning if it is stale/`"offline"` —
otherwise a schedule could silently never fire.

### Time semantics

Times are interpreted in the **SMHUB's local time** (Node-RED's process tz). v1
does not send a timezone; documented as a known simplification.

## ZigDash app changes (deliberately small)

- **No Drift migration.** `PanelType` is persisted via `textEnum` (stores the
  enum *name*). Adding a 13th value `schedule` is purely additive — existing rows
  are unaffected and `schemaVersion` does not change. Schedule settings live in
  the existing `config` JSON column; the shutter target reuses the existing
  `topic` + `topicPrefixOverride` + dashboard-prefix mechanism, exactly like the
  Cover panel.
- **`ScheduleConfig`** in `lib/features/panels/models/panel_config.dart`:
  `openTime`, `closeTime`, `openPayload`, `closePayload`, `enabled`. Hand-rolled
  `toJson`/`fromJson`, matching the existing config classes. Wired into
  `PanelConfig.decode`.
- **`schedule_panel.dart`** widget: shows "Opens 07:00 / Closes 19:00", an enable
  switch, the live `nextAction`/`nextAt` from the state topic (through the
  existing `panelValueProvider`), and an "offline" warning chip when the
  heartbeat is stale. Tap -> edit.
- **`panel_form_screen.dart`**: a type-aware schedule section — two time pickers,
  open/close payload fields (defaulted to `{"state":"OPEN"}` / `{"state":"CLOSE"}`),
  and an enabled switch.
- **Picker + tile dispatcher**: one new picker entry (under "Control") and one new
  `case PanelType.schedule` in `panel_tile.dart`.
- **`AutomationConfigPublisher`** (one focused, unit-testable unit): builds the
  config topic (`zigdash/automation/schedule/<panelId>/config`) and the retained
  JSON payload, and publishes via `MqttManager`. Called on panel save, enable
  toggle, and delete (tombstone). The UI/widgets just call it — they don't know
  the topic shape.

### Component boundaries

- `ScheduleConfig` — pure data + (de)serialization. No I/O.
- `AutomationConfigPublisher` — turns (panel + config + connection) into a
  retained MQTT publish. Depends only on `MqttManager` + `ScheduleConfig`.
- `SchedulePanel` widget — display + enable toggle; depends on
  `panelValueProvider` (state) and `AutomationConfigPublisher` (writes).
- Node-RED flow — independent executor; its only contract with ZigDash is the
  three topics above.

## Node-RED flow (provided as part of the plan)

A **generic scheduler flow**, imported once on the SMHUB. Uses **core nodes
only** (no BigTimer/cron-plus install required):

- `mqtt in` on `zigdash/automation/schedule/+/config` -> a function node holds a
  live map of `panelId -> config` (empty payload removes the entry).
- An `inject` node ticks every 60s -> a function node compares the current local
  `HH:mm` to each enabled schedule's `openTime`/`closeTime`; on a match it
  publishes the corresponding payload to `target` and republishes the schedule's
  `state` (with recomputed `nextAction`/`nextAt`).
- Publishes `zigdash/automation/bridge/state = "online"` on start and on a
  periodic tick.
- Handles any number of schedules from the single flow.

Flow notes will include 2-3 manual test cases for the time-match logic (match at
exact minute, no double-fire within the same minute, disabled schedule ignored).

## Error handling

- **Scheduler offline:** the heartbeat topic drives an explicit "scheduler
  offline — schedule won't run" chip on the panel.
- **Publish while disconnected:** the publish is attempted on save/toggle; on
  failure ZigDash surfaces a snackbar. Because config is retained, once it lands
  it persists across broker/flow restarts.
- **Clock/timezone:** documented that times follow SMHUB local time.

## Testing

- Pure-Dart unit tests: `ScheduleConfig` JSON round-trip; `AutomationConfigPublisher`
  topic + payload construction (including the delete tombstone case).
- Node-RED time-match logic validated via the included manual test cases.
- **`verification-before-completion`** end-to-end on the real device + real
  shutter (see below). No "done" claim before the shutter physically moves.

## Verification (end state)

1. Import the scheduler flow into Node-RED on the SMHUB.
2. In ZigDash, add a Schedule panel on the Living Room dashboard: target = the
   real shutter set topic, open/close times, enabled.
3. Confirm the retained config on the broker:
   `dart run bin/smoke.dart --host 192.168.7.210 --port 1883 --sub 'zigdash/automation/#' --seconds 6`.
4. Confirm the state topic shows `nextAction`/`nextAt`.
5. Set the open time to "now + 1 min" -> watch the shutter physically open;
   set close to "now + 1 min" -> watch it close.
6. Toggle enabled off -> confirm Node-RED stops firing (state shows disabled).

## Out of scope for v1

- Day-of-week selection.
- Sunrise/sunset (with offset) trigger times.
- Multiple open/close actions per day.
- In-app authoring of arbitrary Node-RED flows (HTTP Admin API).

All are clean future extensions of the same config blob / flow.
