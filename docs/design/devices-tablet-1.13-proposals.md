# 1.13 Devices and tablet — proposals (draft)

Status: **proposed, not approved.** These are the recommendations from the 1.13 design map (2026-09-27), kept here so they survive outside the gitignored wayfinder/ folder. The build spec replaces this file once the user accepts or overrides them. Health facts: [research/z2m-health-data.md](research/z2m-health-data.md).

## Decide the Devices tab: rows, filters, the tab dot



1. **Row.** Class icon · friendly name · one line: state ("On · 70%", "21.4° · 48%", "Open") or, when something needs attention, that instead · one trailing health signal, only when it matters: battery when low, "Not responding", "Offline" (availability on), weak link. Healthy rows show no health chip. "Not on a dashboard" stays as a small marker under the name.
2. **Filters.** Chips: **All** · **Needs attention (n)** · **Not on a dashboard (n)**; a chip with n = 0 is hidden, except All. Search field in the header (appears at ≥ 8 devices). Sort: needs attention first, then by name. The Coordinator is never listed.
3. **"Needs attention" means** any of:
   - battery_low is true, or battery ≤ 20 %;
   - availability reports offline, only when `bridge/info` has `config.availability.enabled` (or the device's own override) true, so a stale retained message left from before it was turned off is ignored;
   - "Not responding": a state request got no answer within 15 s and there is no state yet (1.12 rule);
   - `interview_state` FAILED or `supported: false`.
   A device with no state yet shows "No report yet" in the line, which is not attention.
   Weak link (linkquality < 30) shows the chip but does not count, since it fluctuates.
4. **Availability off (the Z2M 2.x default, confirmed on the SMHUB).** The tab never says "Online" or "Offline". A device's state line shows its last-known value with age if stale. A footnote at the bottom of the list, once: "Zigbee2MQTT availability is off, so offline devices show as Not responding" with a "How to turn on" link to the help page. No prompt, no card.
5. **Tab dot (reconciles 1.12 and screens.md).** Dot = a device paired after `devicesSeenAt` that is on no dashboard and not dismissed (1.12 rule, unchanged) **or** a battery at or below the low threshold. Not responding, offline and weak link do not light the dot: bulbs on switched-off wall circuits would keep it lit forever. The battery part lights only on a transition observed by this install (battery goes from above to at/below the threshold, or battery_low goes false → true), never from values already low at the first 1.13 run, so an upgrade never brings a dot. This needs stored state: a per-device `batteryLow` flag and the time it was set (a column pair on the 1.12 `device_dismissals` table, renamed in spirit to per-device local state), part of the schema 6 → 7 bump with ticket 05 §3a. A device's first-ever battery report sets the flag without lighting the dot. It clears when the battery rises again or when the user opens the device page.
6. **Tap** a row → device page (ticket 03), replacing the 1.12 tap-to-add. "Add to a dashboard" moves onto the page and into a row long-press menu.
7. **Menu.** ⋮ keeps Refresh; the base-topic item moves to Settings › home (ticket 05).

## Decide the device page



1. **Route.** `/connections/:id/devices/:ieee` (by IEEE, following renames, per ADR 0003). Opened from a Devices tab row; from a "Device details" button in the header of the tile's class sheet (tap body → sheet → details), so it is reachable outside Edit mode; from a "Device details" item in the Edit-mode ⋯ badge sheet; and from the custom form's "Open device". Long-press keeps entering Edit mode (1.12). At expanded it is the detail pane (ticket 06).
2. **Top.** Class icon, friendly name, model and vendor (from `bridge/devices` definition), and the state line used on tiles ("On · 70%", "Not responding", stale age).
3. **Control card.** The 1.12 class sheet's content embedded, not a sheet: switch/brightness/white/presets/hue for lights, open/stop/close/position for covers, on/off for switches with one row per endpoint for multi-endpoint devices. Sensors show their readings as large values. Generic devices show the writable exposes they have (binary → switch, numeric → slider, enum → segmented or menu) and nothing else.
4. **Readings.** Every other non-config, non-diagnostic expose with its last value and unit, read-only (e.g. power, energy, device temperature). Each row has "Add as reading tile".
5. **Health card.** Only what Zigbee2MQTT gives (ticket 01): battery % or "Battery low", link quality (with a plain word: Good / Weak), power source, "Last heard" from the receivedAt of the device state topic in the last-known store (survives restarts; not Z2M last_seen, which is off by default), and availability when the bridge has it enabled. When availability is off, no online/offline claim — "Not responding" only after a state request times out (1.12 rule).
6. **On dashboards.** Each tile that links this device: dashboard name › section, tap to go to that dashboard. Button **"Add to a dashboard"** opens the shared Add-to-dashboard sheet. Nothing linked → "Not on a dashboard" with the same button, plus "Dismiss" when it lights the dot.
7. **Tile taps unchanged.** Tile icon = quick action, body = class sheet (fast control stays one tap). The page is one step further, via the sheet's "Device details".
8. **Out of scope:** rename, remove, OTA, reconfigure, binding, Z2M settings. Unsupported devices (`supported: false`) show the health card and "Zigbee2MQTT doesn't support this device yet" with no controls.
9. **Base topic** leaves the Devices tab ⋮ menu for the home page in Settings (ticket 05).

## Decide the Custom MQTT tile form reorder



Facts: `panel_form_screen.dart` today is Name → a collapsed-on-new "MQTT Settings" expansion (topic-prefix override, publish topic, subscribe topic, QoS, retain; the title is a hard-coded English string) → type fields → Size → live preview last. So a new tile's topic is hidden by default.

1. **Order.** Name → **Topic** block (always open) → **Live preview** → type fields (payloads, ranges, options) → Size → **Advanced** (collapsed): topic-prefix override, QoS, retain, JSON path.
2. **Topic block.** "State topic" (today's subscribe topic) and, for writable types, "Command topic" (today's publish topic) prefilled as `<state topic>/set` until the user edits it; the command topic is not repeated under Advanced. Read-only types show only the state topic. Both keep today's semantics: they are relative to the dashboard's topic prefix (or the tile's override), and the prefix is shown as a non-editable lead-in so users see the full topic.
3. **"Pick a device".** A button in the Topic block opens the shared device list (the Add tile list, without tile choices). Picking a device writes the full topic `<base>/<friendly name>` minus whatever the effective prefix already covers: with prefix `zigbee2mqtt` the state topic becomes `<friendly name>`; with no prefix it becomes `zigbee2mqtt/<friendly name>`; with a prefix that is not a leading part of the device topic, it sets the tile's prefix override to the base topic (the case commit 5b80d30 fixed for Add tile). Command topic becomes `…/set`. It also sets `deviceIeee` (so the tile counts as "on a dashboard" and follows renames), and, when the type has a value path, offers the device's properties as JSON-path choices from its exposes.
4. **Live preview** shows the last payload on the state topic (from the last-known store, then live), before payload fields, so users see what to match.
5. **Device link.** A linked tile shows the device name under the Topic block with "Open device" (→ device page) and "Unlink". The device page lists the tile under "On dashboards".
6. **Existing tiles** open with the same values; only positions change. A tile that uses a prefix override, QoS ≠ 0 or retain opens with Advanced expanded so nothing it uses is hidden.
7. **Fix in passing:** localize "MQTT Settings" (it becomes "Advanced").
8. **Type picker** stays as today behind "Custom MQTT tile"; no change to the 15 types.

## Decide Settings with homes



Facts: today's Settings is one scrolling list — a "Connections" row (→ the Homes list), theme radios, a dynamic-color switch, nine language radios inline, About (Rate, Help, Version). The Homes list (`connections_list_screen.dart`) has open / edit / delete per row, a guided-connect wand and an add FAB for the manual form. "Manage homes" in the 1.12 switcher pushes the same list.

1. **Layout.** One full-screen page from the header gear, three groups: **Homes**, **Appearance**, **About**. No sub-page for Appearance or About; Homes is inline, not a row that opens a list.
2. **Homes group.** One row per home: name, broker address (host:port), and a connection-state word for the current home only ("Connected", "Can't reach broker"); other homes show no state, since only one is connected. The current home carries a check. Tap a row → the home's page (see 3). Last row: **"Add a home"** → setup (Find my setup), which returns to the new home's dashboard. The wand and the add FAB go away; setup already contains manual entry and Advanced.
3. **Home page.** Title = home name. Rows: Name (inline rename), Connection (opens today's connection form unchanged — address, port, login, TLS, WebSocket, remote host), Zigbee2MQTT base topic (moved here from the Devices tab menu; see 3a), "Switch to this home" (hidden for the current one), and **Delete home** at the bottom with the existing confirmation. Deleting the current home switches to the next one, or to setup when none remain (1.12 rule).
3a. **Base topic storage.** Today there is no per-home base topic: `z2mBase()` derives it from a dashboard's topic prefix (default `zigbee2mqtt`), and the Devices-tab ⋮ override lives only in widget state until the screen closes. Recommendation: a nullable per-home `z2mBaseTopic` (connections column, schema 6 → 7). Null keeps today's derivation, so upgrades change nothing; setup's no-Zigbee2MQTT retry writes it when the user corrects the topic.
4. **"Manage homes"** in the header switcher opens Settings scrolled to Homes. The retitled Homes list screen and its route are removed; old deep links redirect to Settings. Checked: no-homes routing does not use this list (`HomeStartScreen` sends zero homes to setup, and `startLocation` falls back to `Routes.start`), so removing it is safe; the stale doc comment in `first_run_redirect.dart` gets updated.
5. **Appearance.** Theme as a three-way segmented button (System / Light / Dark) instead of radios; the dynamic-color switch under it (Android 12+ only, as now); **Language** as one row showing the current choice, opening a picker page (radio list of System + the nine languages, each in its own name). Choosing applies immediately and returns.
6. **About.** Rate ZigDash, Help and setup guides, Privacy policy (opens https://giladtamam.github.io/zigdash/PRIVACY, the store-listed page; there is no in-app privacy screen today), Version. No account row.
7. **Upgrade.** Pure UI move: theme, dynamic color, locale and homes are read from the same stores; nothing to confirm, no "new" marker.
8. **Out.** Backup and Restore stay in the dashboard ⋮ overflow (IA); per-home backup is not added.

## Decide window sizes, the rail and list-detail



Facts: `gridColumns(width)` uses the grid's own width (< 600 → 2, or 1 at text ≥ 1.6; < 840 → 3; else 4) and `minTileHeight` steps 118 / 140 / 176. The shell always shows a `NavigationBar`; in Edit mode on Dashboards it is replaced by the Edit bar (Add tile / Add section). Goldens already have a 1280×800 tablet size.

1. **The window class decides both chrome and columns.** Compact < 600 dp: bottom bar, 2 columns. Medium 600–839: navigation rail with labels, 3 columns. Expanded ≥ 840: rail, 4 columns, list-detail where listed below. The grid's caller passes the window width (not the body width left after the rail) to `gridColumns` and `minTileHeight`; the functions are unchanged. Otherwise a 600–679 dp window, which has 3 columns in 1.12, would drop to 2 when the rail arrives, contradicting dashboard-1.12.md §3.
2. **Rail.** Same three destinations and the same Devices dot, top-aligned. The header keeps home switcher, Edit and Settings (no FAB in the rail). In Edit mode the rail stays, and "Add tile" / "Add section" move into the Edit header as buttons at medium and expanded, instead of replacing the bar.
3. **List-detail at expanded.** Devices: list on the start side (360 dp), device page on the end; selecting a row swaps the detail without navigation, back clears the selection. Scenes: list and the scene editor the same way. Medium and compact keep push navigation. Settings stays a single page; at expanded its content is centered at max 720 dp.
4. **Dashboard switching.** At medium and expanded, two or more dashboards show as a chip row under the header (the Signal tablet board's chips), replacing the tab strip; compact keeps the 1.12 tab strip.
5. **Taken from the Signal tablet board for 1.13:** rail, 4 columns, dashboard chips, reading tiles at Wide by default on expanded (so values read across a room). **Held for 2.0:** 64 px quick actions, squircles, amber fill, fonts, dark-by-default on tablets.
6. **Landscape phones** (≥ 600 dp wide, < 480 dp tall) get the rail, which frees vertical space; no special case.
7. **Large text.** Keep the 1.12 rule (one column at compact with text ≥ 1.6). The rail keeps labels at 2.0 text; if they would clip, labels hide and tooltips remain.
8. **Edit mode at 3–4 columns.** The 1.12 drag rules already pack rows by span; add a widget test that drags across a 4-column row and a golden of Edit mode on the tablet.
9. **Goldens** add, on `tabletMatrix`: dashboard with rail, Edit mode, Devices list-detail, Scenes list-detail, Settings; plus a medium 700×1000 portrait variant of the dashboard.
