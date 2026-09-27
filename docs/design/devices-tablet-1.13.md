# Release 1.13 "Devices and tablet": build spec

This is the handoff from design to building release 1.13, phase 3 in [phasing.md](phasing.md). It collects every decision the phase needs, so the build does not have to stop and ask. The decisions were made on 2026-09-27 in the "ZigDash 1.13 Devices and tablet phase design" map, and the user accepted them. The look is **interim A (Calm Material)**, not Signal. Where this spec disagrees with an older redesign doc, this spec wins for 1.13.

Boards: the "1.13" row of the [Claude Design canvas](https://claude.ai/artifact/Gt1x8Q8TpDfY2VMVqNqF5w) (version 11). Health facts: [research/z2m-health-data.md](research/z2m-health-data.md). Built on `release/1.13-devices-tablet`, cut from 1.12.0+27.

## Scope

In: the Devices tab with filters and health; the device page; the reordered Custom MQTT tile form; Settings with homes; the navigation rail, window-class columns, dashboard chips and list-detail on large screens; the schema 6 → 7 migration.

Out: thermostat (TRV) tiles; Zigbee2MQTT management (rename, remove, OTA, pairing, binding); Zigbee2MQTT group scenes; kiosk presentation; the Signal identity (fonts, amber, squircles, 64 px quick actions, dark-by-default tablets); motion.

## 1. Data model (drift schema 6 → 7)

| Change | Detail |
|---|---|
| `connections.z2mBaseTopic` | Nullable text. Null keeps today's derivation (`z2mBase()` from a dashboard's topic prefix, default `zigbee2mqtt`). Set from Settings › home, and by setup's no-Zigbee2MQTT retry when the user corrects the topic. Every reader of the base topic goes through one function that prefers this column. |
| `device_health_flags` table | connectionId (cascade delete with the home), ieee, `batteryLow` bool, `acknowledged` bool, `changedAt`. Phone only, like `device_dismissals`. A sibling table rather than columns on `device_dismissals`, because a dismissal row's presence means "dismissed". |
| Backups | `formatVersion` 2 → 3 carries `z2mBaseTopic`. Health flags are not backed up (they describe this install's observations). Restoring a version-2 backup leaves the column null. |

The migration adds the column and the table and nothing else. No data is rewritten, so the upgrade changes nothing on screen by itself.

## 2. Device health

What Zigbee2MQTT gives, confirmed on the SMHUB (Z2M 2.13) and in the 2.x source:

- **Availability** is off by default. When on, `<base>/<name>/availability` carries retained JSON `{"state":"online"|"offline"}`; 1.x plain strings are still parsed. It counts only when `bridge/info` has `config.availability.enabled` true, or the device's own `devices.<ieee>.availability` override is on. A retained message left from before availability was turned off is ignored.
- **last_seen** is off by default and is not used. "Last heard" is the `receivedAt` of the device's state topic in the last-known store, which survives restarts.
- **Battery** is `battery` (%) and `battery_low` (bool) in the state payload. Low means `battery_low` true or `battery` ≤ 20.
- **Link quality** (0–255) is in every state payload. Weak is below 30. It is shown, never counted as attention.
- **`bridge/devices`**: `interview_state` FAILED and `supported: false` are reliable flags; `power_source` is shown on the page.
- **Not responding** is the 1.12 rule: a state request unanswered for 15 s while the device has no state.
- **No report yet** (nothing in the last-known store and no reply pending) is neutral, not attention.

A device **needs attention** when its battery is low, availability (counted as above) says offline, it is not responding, or its interview failed or it is unsupported.

## 3. Devices tab

Board: G-devices-tab.

- **Row.** Class icon, friendly name, then one line: the attention reason when there is one ("Not responding", "Offline"), otherwise the state ("On · 70% · 2700 K", "21.4° · 48%", with the stale age when stale). A trailing signal appears only when it matters: battery % in an error chip when low, a cloud-off icon when not responding or offline, a "Weak" chip for weak link. "Not on a dashboard" stays as a small marker under the name.
- **Filters.** Chips All · Needs attention (n) · Not on a dashboard (n). A chip whose count is 0 is hidden, except All. Search is a header icon that appears at 8 or more devices. Sort: needs attention first, then by name. The Coordinator is never listed.
- **Availability footnote.** When availability is not counted for this home, one line at the end of the list: "Zigbee2MQTT availability is off, so offline devices show as Not responding", with "How to turn it on", which opens a new Help section. No card, no prompt.
- **Tap** opens the device page. Long-press offers "Add to a dashboard" and, for unassigned devices, "Dismiss".
- **⋮** keeps Refresh. The base-topic item moves to Settings › home.

### The Devices dot

The dot shows when either is true for the current home:

1. **New device** (1.12 rule, unchanged): paired after `devicesSeenAt`, on no dashboard, not dismissed.
2. **Battery went low while this install watched.** On each state message, compute `low` from whichever of `battery_low` and `battery` the message carries (either one saying low makes it low). A message with neither, such as one with only `linkquality`, leaves the row untouched. Then compare with `device_health_flags`:
   - no row yet → insert `batteryLow` = current, `acknowledged` = true (a first report never lights the dot, so upgrading never brings one);
   - `batteryLow` false → true → set `acknowledged` = false (dot on);
   - true → false → set `batteryLow` false (dot off).
   Opening the device page sets `acknowledged` = true.

Not responding, offline and weak link never light the dot. The tooltip names the reason: "Devices, new device" or "Devices, battery low".

## 4. Device page

Boards: G-device-page (light, color light), G-device-page-dark (contact sensor, low battery).

- **Route** `/connections/:id/devices/:ieee`, by IEEE so it follows renames ([ADR 0003](../adr/0003-device-tiles-bind-to-ieee.md)). An unknown IEEE shows "This device is no longer in Zigbee2MQTT" with the tiles that still link it.
- **Entry points.** A Devices tab row; a "Device details" button in the header of every device tile's class sheet (tile body → sheet → details); "Device details" in the Edit-mode ⋯ badge sheet for device, reading and linked custom tiles; "Open device" in the Custom MQTT tile form. Tile taps are unchanged: the icon is the quick action and the body opens the sheet. Long-press still enters Edit mode.
- **Header.** Class icon (filled when on), friendly name as the title, the tile state line, then model, vendor and class.
- **Control card.** The 1.12 class sheet's content, embedded, not a sheet. Multi-endpoint switches get one row per endpoint. Sensors show their values large. Generic devices show only their writable exposes: binary as a switch, numeric as a slider, enum as a segmented button (≤ 4 values) or menu. Unsupported devices show "Zigbee2MQTT doesn't support this device yet" and no controls.
- **Readings card.** Every other exposed value without a `config` or `diagnostic` category, read-only with its unit (power, energy, device temperature, and similar). A numeric reading has "Add as reading tile". The card is hidden when there is nothing to list.
- **Health card.** Battery (% or "Battery low", error-colored when low), link quality with a word (Good ≥ 30, Weak < 30), power source, Last heard, and Availability: "Online"/"Offline" when counted, otherwise "Off in Zigbee2MQTT". The card is outlined in the error color when the device needs attention.
- **On dashboards card.** One row per linked tile, "dashboard name › section", which opens that dashboard. "Add to a dashboard" opens the shared 1.12 sheet. With no links: "Not on a dashboard", the add button, and "Dismiss" when the device counts as new.
- **At expanded width** the page is the detail pane (section 7).

## 5. Custom MQTT tile form

Board: G-custom-form. The type picker behind "Custom MQTT tile" is unchanged.

1. **Order:** Name → Topic → Live preview → type fields (payloads, ranges, options, value path) → Size → Advanced.
2. **Topic block** (always open). "State topic" (today's subscribe topic) and, for writable types, "Command topic" (today's publish topic), prefilled as `<state topic>/set` until edited. Read-only types show only the state topic. Both stay relative to the effective prefix (the dashboard's topic prefix, or the tile's override), and the prefix shows as a non-editable lead-in so the full topic is visible.
3. **Pick a device** opens the shared device list without tile choices. It writes the device topic `<base>/<friendly name>` relative to the effective prefix:
   - prefix `zigbee2mqtt` → state topic `<friendly name>`;
   - no prefix → `zigbee2mqtt/<friendly name>`;
   - a prefix that is not a leading part of the device topic → the tile's prefix override becomes the base topic (the case fixed for Add tile in 5b80d30).

   It sets `deviceIeee`, prefills the command topic, and offers the device's properties as value-path choices.
4. **Live preview** shows the last payload on the state topic (last-known first, then live).
5. **Linked tiles** show "Linked to <device>" with "Open device" and "Unlink".
6. **Advanced** (collapsed): prefix override, QoS, retain, JSON path. It opens expanded on an existing tile that uses any of them, so nothing in use is hidden.
7. Existing tiles open with the same values; only positions move. The hard-coded "MQTT Settings" title goes away.

## 6. Settings with homes

Boards: G-settings, G-home-page, G-language.

- **One page** from the header gear, three groups: Homes, Appearance, About. At expanded width the content is centered at max 720 dp.
- **Homes.** A row per home: icon, name, and host:port. The current home adds a connection word ("Connected", "Can't reach broker") and a check. The last row is "Add a home", which runs setup and lands on the new home's dashboard. The guided-connect wand and the add FAB are removed; setup already covers manual entry and Advanced.
- **Home page.** Name (inline rename); Connection (today's connection form, unchanged); Zigbee2MQTT base topic (writes `z2mBaseTopic`); "Switch to this home" (hidden for the current home); "Delete home" at the bottom with today's confirmation. Deleting the current home switches to the next home, or to setup when none remain.
- **"Manage homes"** in the header switcher opens Settings scrolled to Homes. The Homes list screen and its route are removed, and `/connections` redirects to Settings. No-homes routing does not depend on it: `HomeStartScreen` sends zero homes to setup. Update the stale comment in `first_run_redirect.dart`.
- **Appearance.** Theme is a segmented button (System / Light / Dark). "Colors from wallpaper" is a switch shown on Android 12 and later. Language is one row showing the current choice; it opens a picker page listing System plus the eight languages, each in its own name. A choice applies immediately and returns.
- **About.** Rate ZigDash; Help and setup guides; Privacy policy (opens https://giladtamam.github.io/zigdash/PRIVACY, subtitle "No telemetry. Everything stays on this phone."); Version.
- **Upgrade.** Theme, dynamic color, locale and homes are read from the same stores. Nothing to confirm.
- Backup and Restore stay in the dashboard ⋮ menu.

## 7. Window sizes, rail and list-detail

Boards: G-tablet-dashboard, G-tablet-devices.

- **Window class decides chrome and columns.** Compact (< 600 dp): bottom bar, 2 columns (1 at text scale ≥ 1.6). Medium (600–839): rail, 3 columns. Expanded (≥ 840): rail, 4 columns, list-detail. The grid's only caller, `panel_grid.dart` (Edit mode renders through it too), passes the **window** width to `gridColumns` and `minTileHeight` instead of `constraints.maxWidth`; the functions are unchanged. Without this, a 600–679 dp window would drop from 3 columns to 2 when the rail takes 80 dp.
- **Rail.** `NavigationRail` with labels, the same three destinations and the same dot, top-aligned below the header height. No FAB. At text scale 2.0 labels hide if they would clip, and tooltips remain.
- **Edit mode at medium and expanded.** The rail stays. "Add tile" and "Add section" become buttons in the Edit header instead of replacing the bar.
- **Dashboard switching.** At medium and expanded, two or more dashboards show as a chip row under the header, in place of the tab strip. Compact keeps the 1.12 tab strip.
- **List-detail at expanded.** The Devices list is 360 dp on the start side with the device page as detail; selecting a row swaps the detail without a route push, and back clears the selection. Scenes work the same way, with the scene editor as detail. With nothing selected, the detail pane says "Select a device" or "Select a scene". Medium and compact push pages as today.
- **Reading tiles** added at expanded width default to Wide.
- **Landscape phones** at 600 dp or wider get the rail; no special case.
- **Header on tablets.** The connection state ("Connected" with a dot) sits at the end of the header at medium and expanded.
- Everything mirrors in Hebrew: the rail sits on the right, and the list pane on the start side.

## 8. Strings and help

- New strings go into all eight languages (the eight ARB files), including the filter chips, health words, device page cards, Settings rows, the availability footnote and the dot tooltips.
- A Help section, "Turn on availability in Zigbee2MQTT": Settings › Availability in the Zigbee2MQTT frontend, or `availability: enabled: true` in `configuration.yaml`, and what ZigDash shows once it is on.

## 9. Tests and goldens

- **Migration test** 6 → 7 on a 1.12 fixture database: every panel, section, dismissal and home survives; `z2mBaseTopic` is null. Backup round trip for format 3, and a restore of a format-2 backup.
- **Health unit tests:** availability counted only with `bridge/info` enabled (a stale retained offline message is ignored when disabled); battery low from `battery_low` alone and from `battery` ≤ 20 alone; the dot's transition table (first report, false → true, true → false, acknowledge, and a message without battery fields leaving the row alone); interview FAILED and unsupported.
- **Base topic:** every reader prefers `z2mBaseTopic`; null keeps the 1.12 derivation.
- **Custom form:** "Pick a device" topic writing for the three prefix cases; existing tiles keep their values; Advanced opens when in use.
- **Window classes:** columns at 599, 600, 679, 839 and 840 dp with the rail; a drag across a 4-column row in Edit mode.
- **Goldens.** The phone matrix (light/dark, English/Hebrew, text 1.0/2.0) adds: the Devices tab with filters and a low-battery row, the device page (color light; contact sensor with low battery, dark), Settings, the home page, the language picker and the Custom MQTT tile form. `tabletMatrix` adds: the dashboard with rail and chips, Edit mode, Devices list-detail, Scenes list-detail and Settings. Its Hebrew variants are the check that the rail sits on the right and the list pane on the start side. A medium portrait variant (700 × 1000) adds the dashboard.
- **Accessibility widget tests:** the rail and dot semantics, filter chip labels with counts, the device page cards' headings.

## 10. Exit checks

1. After upgrading from 1.12, nothing on screen changes except the new layouts: no dot, card or prompt appears because of the upgrade. The migration and backup tests pass.
2. On the SMHUB (availability off): no device shows "Online" or "Offline"; the footnote shows; a bulb that ignores its state request shows "Not responding". Health flags match what Zigbee2MQTT reports for battery and availability (phase exit criterion).
3. The device page opens from the Devices tab, from a tile's sheet and from Edit mode, and follows a rename in Zigbee2MQTT.
4. A custom tile made with "Pick a device" controls the SONOFF on a dashboard with and without a topic prefix.
5. Tablet goldens pass. On a physical tablet or a 1280 × 800 emulator, the rail, 4 columns and Devices list-detail work, in English and Hebrew.
6. The device check on the internal track (phone): TalkBack reads the rail or bar and the device page; Hebrew mirrors; strict-broker connect.
7. CI is green, goldens included.

## Deferred, with a reason

- **Thermostat tiles.** No test device.
- **Zigbee2MQTT management.** The redesign is UX-only.
- **Using `bridge/health` `leave_count`.** A rising count hints at a flaky device, but it is published every 10 minutes and needs history to read; revisit with real reports.
- **PNG exports of the 1.13 boards.** The canvas is the source of truth; export on request.
- **Kiosk presentation, Signal identity, motion.** Later phases.
