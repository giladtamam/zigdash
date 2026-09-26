# Release 1.12 "Dashboard": build spec

This is the handoff from design to building release 1.12, phase 2 in [phasing.md](phasing.md). It collects every decision the phase needs, so the build does not have to stop and ask. All decisions were made on 2026-09-26 in the "ZigDash 1.12 Dashboard phase design" map. The look is **interim A (Calm Material)**, not Signal: dynamic color, Roboto, and today's radii. Where this spec disagrees with an older redesign doc, this spec wins for 1.12.

Boards: the "1.12" row of the [Claude Design canvas](https://claude.ai/artifact/Gt1x8Q8TpDfY2VMVqNqF5w) (version 9), exported to [screens/1.12/](screens/1.12/). The canvas is the source of truth when the images differ.

## Scope

In: the Dashboards / Devices / Scenes bar; homes in the header; Edit mode; device-first Add tile; device tiles in eight classes plus generic; reading tiles; sections; the 2/3/4-column grid with Small / Wide / Full; last-known values that survive a restart; the schema 5 → 6 migration.

Out (later phases): thermostat (TRV) tiles, the device page, the redesigned Settings, the tablet navigation rail, Signal tokens, kiosk presentation, and motion design.

## 1. Data model (drift schema 5 → 6)

Decided in "Decide the tile data model" (see [ADR 0003](../adr/0003-device-tiles-bind-to-ieee.md)).

| Change | Detail |
|---|---|
| `PanelType.device` | One row per device tile. The config holds the IEEE address, the class chosen when the tile was added, the endpoint (for multi-endpoint switches), and a cached snapshot of the relevant exposes (property, access bits, ranges, `value_on` / `value_off` / `value_toggle`) so the tile can render offline. `topic` caches `<base>/<friendly name>` and is rewritten when a rename shows up in `bridge/devices`. |
| `PanelType.reading` | One numeric value with its unit. It is bound either to a device property (IEEE plus property) or to a raw topic plus JSON path. |
| `panels.deviceIeee` | Nullable and indexed. It is set for device and reading tiles, for custom tiles made with "Pick a device", and for custom tiles auto-linked at first connect. |
| `sections` table | id, dashboardId (cascade delete), name, sortOrder. |
| `panels.sectionId` | Nullable. Deleting a section sets it to null. Tiles with no section render first, with no header. |
| `panels.width` | The values become `small` / `wide` / `full`. The migration rewrites `half` and `third` to `small`. |
| `device_dismissals` table | connectionId, ieee. Stored on the phone only. |
| Backups | The format version goes up. Exports carry sections, sizes and device links. Restoring an older backup maps full → full and half/third → small. |

A device is **on no dashboard** when it is a non-coordinator device of the current home in `bridge/devices` and no tile of that home carries its IEEE.

**Foreign keys.** Before 1.12, ZigDash never turned SQLite foreign-key enforcement on, so deleting a dashboard or home left its tiles behind. From schema 6, `beforeOpen` sets `PRAGMA foreign_keys = ON`, so the declared cascades run: a home removes its dashboards, scenes and dismissals, and a dashboard removes its sections and tiles. The 5 → 6 migration first deletes rows that older versions orphaned.

The migration runs offline and has no network. Auto-linking therefore happens at the first connect after the upgrade, not inside `onUpgrade`.

## 2. Classifying devices

This follows [the classification research](research/device-classes.md), which has the full class table, protocol facts and the captured SMHUB payloads.

- **Precedence.** Composite type comes first: color light (a `light` with a `color_xy` or `color_hs` feature) > light > cover > switch/plug. Then binary sensor property: leak/smoke/gas > contact > occupancy/presence. Then climate (a numeric `temperature` or `humidity`, never `device_temperature`). Anything else is generic.
- **Only exposes without a `category` decide the class.** `config` and `diagnostic` exposes are ignored, so the SONOFF's `turbo_mode` never makes a device a switch.
- **Access bits.** A control is drawn only when access includes 2, and a value only when it includes 1. Access 2 alone is a stateless button.
- **Properties.** Read and write the `property` (for example `state_l1`), never the `name`. Parsers recurse into nested composites.
- **What actually arrives.** The swatch follows `color_mode` (`color_temp`, `xy` or `hs`) and falls back to whatever keys are present. Colors are sent as `{"color":{"hex":"#RRGGBB"}}`.
- **Secondary matches** become optional readings on the winning tile. Examples: a plug's power, a motion sensor's temperature, and battery everywhere.
- **Availability** is off by default in Zigbee2MQTT. A missing `/availability` message means "unknown", not "offline".

## 3. Grid and sizes

Decided in "Decide grid sizing".

- **Columns.** Compact (< 600 dp) has 2 columns, medium has 3 and expanded has 4. Small spans 1 column, Wide spans 2 and Full spans the whole row.
- **Rows** take the height of their tallest tile, never less than the minimum tile height (118 / 140 / 176 dp). There are no multi-row tiles.
- **Large text.** Rows grow with their content. On compact width at a text scale of 1.6 or more, the grid drops to one column.
- **Default sizes.**
  - Small: light, switch/plug, contact, motion, leak/smoke, climate, reading, generic, scene, button, and the other custom types.
  - Wide: color light, cover, slider.
  - Full: text log, schedule.

  These are defaults only. The Edit-mode badge resizes any tile.

## 4. Tile anatomy

Board: [tiles.png](screens/1.12/tiles.png), [color-sheet.png](screens/1.12/color-sheet.png).

**Every device tile** works the same way:

- The icon disc is the quick action, for classes that have one.
- Tapping the body opens the class's sheet.
- A long press enters Edit mode with that tile's action sheet open.
- The title is the tile name, and below it a state line shows state · main value · secondary reading.

| Class | Size | Quick action | Tile shows | Sheet |
|---|---|---|---|---|
| Color light | Wide | toggle (`value_toggle`) | "On · 100% · Warm white", inline brightness slider, color swatch at the end | Brightness; White (mired shown in kelvin); 8 preset swatches; hue slider |
| Light | Small | toggle | "On · 70%" (no % without brightness) | Brightness; White if `color_temp` is exposed |
| Switch / plug | Small | toggle | "On"/"Off"; a multi-endpoint device shows one toggle per endpoint and "1 on · 2 off"; power if present | Per-endpoint toggles; power/energy readings |
| Cover | Wide | none | Open / stop / close buttons; position bar only if `position` is readable; "Closed · 0%" | Position slider if settable |
| Climate | Small | none | Large temperature; humidity in the state line | All readings |
| Contact | Small | none | "Open"/"Closed" (`true` = closed); battery | Readings |
| Motion | Small | none | "Clear"/"Motion" plus the time since the last change, measured from message arrivals | Readings |
| Leak / smoke | Small | none | Error-container fill and "Leak detected" / "Smoke detected" while alarming | Readings |
| Reading | Small | none | Large value and unit, with the name below | none |
| Generic | Small | first plain settable binary, if any | Help icon, first readable value | All readable values; config and diagnostic under "More" |

- **Battery** shows in the state line. At 20% or below, or when `battery_low` is set, it is drawn in the error color.
- **Stale:** the tile is dimmed and carries an age chip ("2 h ago", or a date after a day).
- **Never reported:** values show "—" and the tile says "waiting for first report". Toggles stay disabled until the state is known.
- **Header summary** under the home name: "N on" (lights and switches on in this dashboard) and the temperature of the first climate tile, when there is one.
- **Names** default to the Zigbee2MQTT friendly name. When that name is an IEEE address, the add sheet asks for a name and uses vendor and model as the hint.
- **TalkBack.**
  - Each tile is one node, for example "Desk lamp, light, on, 70 percent".
  - The quick action is the tap action. The sheet is the custom action "Controls".
  - Sliders are labeled Brightness, Position or White.
- **Custom MQTT tiles** keep today's rendering and behavior. Only their size names change.

## 5. Offline and last-known values

Decided in "Decide how last-known values survive a restart" (see [ADR 0004](../adr/0004-last-known-values-stay-on-the-phone.md)).

- **What is stored:** the last payload per subscribed topic, per home, with its arrival time. The file is a separate SQLite database, not the main one.
- **Writes** are batched: at most once per topic every 5 s, and a flush when the app goes to the background.
- **Loading:** saved values load before connecting, so a tile that has a value is never empty at launch.
- **Privacy:** the file is excluded from Auto Backup and device-to-device transfer. That needs `dataExtractionRules` and `fullBackupContent` in the manifest, which ZigDash does not declare today.
- **Retention:**
  - The file is deleted with its home.
  - Topics that have not been subscribed for 30 days are pruned.
  - Each home keeps at most 2,000 topics, dropping the oldest first.
- **Fresh state:** once per connection, device tiles on screen send `<base>/<name>/get` with `{"<property>":""}`. They do this only for properties with access bit 4, and the requests are spaced out. Custom MQTT tiles are never polled.
- **Status line:** a slim "Can't reach your broker · Why?" line replaces `ConnectionStatusBanner`. "Why?" opens the connection diagnostics, where manual retry lives. The line never covers tiles.

## 6. Navigation and homes

Decided in "Decide where homes are switched" and "Decide what the Devices and Scenes tabs show". Boards: [home-switcher.png](screens/1.12/home-switcher.png), [devices-tab.png](screens/1.12/devices-tab.png).

- **Bottom bar:** Dashboards / Devices / Scenes. The Brokers tab and the Dashboards placeholder are removed. Settings is an icon in the header.
- **Header:** the home name, with a ▾ menu at two or more homes. The menu lists the homes, "Add a home" and "Manage homes". With one home, the name is plain text and "Add a home" sits in the ⋮ menu.
- **Dashboards in a home:** a tab strip appears only at two or more dashboards. Add dashboard, Backup and Restore stay in ⋮.
- **Add a home** runs setup, with a back arrow. Success opens the new home. "Manage homes" opens today's connections list, retitled "Homes". Settings gets a "Homes" row that opens the same screen.
- **Start:** the app opens the remembered home and dashboard. With homes but none remembered, it opens the first home. With no homes, it opens setup.
- **Devices tab (stopgap until 1.13):**
  - It keeps today's health list.
  - Rows on no dashboard carry a "Not on a dashboard" marker, and tapping a row opens the shared "Add to dashboard" sheet.
  - The base-topic field moves to ⋮.
  - The tab icon shows a dot while any device is on no dashboard and not dismissed.
- **Scenes tab:** ZigDash's own scenes, as today. Tapping activates a scene. Edit, delete and "Add to dashboard" stay in the row menu.
- **Current home:** all three tabs follow it.

## 7. Edit mode

Board: [edit-mode.png](screens/1.12/edit-mode.png).

- **Enter** from the header pencil, or by long-pressing a tile, which opens that tile's action sheet. **Leave** with Done, system back or a tab switch. Changes save as they happen, and there is no cancel.
- **Header:** "Editing", a "Dashboard" button and Done. The Dashboard sheet holds the name, icon, accent color and "Delete dashboard". It has no column count, because columns follow the window size.
- **Tiles** get a dashed outline, a grip and a ⋯ badge, and their controls are inert. A long-press drag moves a tile within a section or across sections.
- **Badge sheet:**
  - Size (Small / Wide / Full)
  - Move to section
  - Edit tile (device tiles: name, icon and optional readings; custom tiles: today's form)
  - Remove from dashboard
  - "Replace with device tile", for linked custom tiles only
- **Remove** takes effect immediately, with an Undo snackbar for about 5 s and no confirmation dialog. Deleting a section asks whether to move its tiles to no section or delete them.
- **Sections:** a grip to reorder and a pencil to rename.
- **Bottom bar** in Edit mode is replaced by "Add tile" and "Add section".
- **Unassigned card:** "N devices aren't on any dashboard", with **Add**, which opens Add tile filtered to those devices, and **✕**, which writes `device_dismissals` for them. A newly paired device brings the card back.
- **TalkBack:** every drag has a path that needs no dragging. Tiles and sections get the custom actions "Move earlier" and "Move later", and tiles also have "Move to section".
- **Drag, from the spike (2026-09-26):** a throwaway widget-test spike on the packed-row grid confirmed the approach. It used one `LongPressDraggable` per tile, one `DragTarget` per tile and one per section header, with no new package. It covered moving a Wide tile ahead of a Small tile across rows, dropping into another section, dropping on a section header, and a quick swipe scrolling instead of moving a tile. Rules for the build:
  - Use `dragAnchorStrategy: pointerDragAnchorStrategy`. With the default strategy, `DragTargetDetails.offset` is the feedback's top-left corner, not the finger, and before/after decisions come out wrong.
  - A drop on a tile's leading half inserts before it, and on the trailing half after it. "Leading" flips in right-to-left.
  - A drop on a section header makes the tile that section's first. A drop on a tile takes that tile's section.
  - Reorder the list and let the grid repack. Never place tiles by coordinates.
  - `Draggable` does not scroll the dashboard near its edges. Drive `EdgeDraggingAutoScroller` from `onDragUpdate`.

## 8. Add tile

- **Device list.** Add tile opens a searchable list of devices, with the ones on no dashboard first. Picking a device shows its recommended tile (class, size, name) and lets the user change it before saving.
- **Other rows.** "Reading" asks for a device property or a topic. At the bottom, "Custom MQTT tile" opens today's type picker and form.
- **Custom form.** It is reordered: name and topic first, then "Pick a device", then payloads and JSON path under Advanced.
- **Shared sheet.** The Devices tab uses the same "Add to dashboard" sheet.

## 9. Migration and generation

Decided in "Decide migration of existing dashboards and what setup generates".

- **Existing dashboards are not restructured.** Every panel stays a custom MQTT tile in its order, with no section, sized per section 3. Nothing is converted automatically.
- **Auto-link** runs at the first connect after the upgrade. A custom tile whose topic is `<base>/<friendly name>` (or its `/set` topic) of a known device gets that device's `deviceIeee`. Devices already on a dashboard then don't raise the new-device dot.
- **Seamless upgrade.** An update changes the UI only: existing users are never asked to do anything. The migration and auto-link run silently, and no dialog, card or badge appears just because of the upgrade. Devices that already exist at the first connect after the upgrade and are on no dashboard are recorded as seen, silently, in `device_dismissals`. They stay listed in the Devices tab with their "Not on a dashboard" marker, but don't light the dot or the Edit-mode card. Only devices paired after the upgrade do.
- **Conversion** is offered per tile, never in bulk. A linked custom tile's badge offers "Replace with device tile", which keeps position, section and size and can be undone.
- **Setup from 1.12** creates device tiles, not raw panels, and groups them into sections in this order:
  1. Lights
  2. Switches and covers
  3. Sensors: climate, contact, motion, leak/smoke
  4. Other: generic

  A section is created only when it has tiles. Section names are localized, and sizes follow the class defaults. Unsupported devices stay unselectable. Setup never creates reading tiles.
- **Names.**
  - The first home is "My Home" (localized), and later ones are "Home 2", "Home 3" and so on. The host stays visible in Manage homes.
  - The generated dashboard keeps the name "Home".
- **Demo** seeds device tiles with cached exposes for a canned device set: color light, light, plug, cover, climate, contact, motion and leak. They go in the same sections, with seeded values shown as current, and no age chips on the demo home. The "Connect your home" bar stays.

## 10. Tests and goldens

- **Migration test.** A drift 5 → 6 test runs against a 1.11 fixture database. The fixture has full, half and third panels of all 15 `PanelType`s and scenes, and the test asserts that every panel survives with its order, size mapping and config. A companion backup round-trip test covers restoring a 1.11 backup and exporting and reimporting a 1.12 one.
- **Classification unit tests** run on the captured SMHUB payloads (two CK-BL702 bulbs and a SONOFF MINI-ZBD) and on the research examples: a multi-endpoint TS0002, a plug with power, a motion sensor with temperature, and a leak sensor with `device_temperature`.
- **Last-known store tests:** batching, pruning, the 2,000-topic cap, deletion with the home, and loading before connect.
- **Goldens** use the phasing matrix (light/dark, English/Hebrew, text 1.0/2.0) and add:
  - the dashboard with every tile class
  - stale and never-reported tiles
  - the offline line
  - Edit mode with the badge sheet
  - the color sheet
  - Add tile
  - the Devices tab
  - the home switcher
- **Accessibility widget tests:** tile semantics labels, and the "Move earlier" and "Move later" actions.

## 11. Exit checks

1. After upgrading from 1.11, every existing panel is present, in order, with its config. The migration and backup tests pass.
2. All 15 panel types (`PanelType.values` minus the new `device` and `reading`) can be created under Custom MQTT tile. The "16" in older docs counted device discovery as a type.
3. With the broker unreachable at launch, tiles show last-known values marked stale, and the status line shows.
4. On the device check (internal track, physical phone), a fresh setup against the SMHUB produces sectioned device tiles:
   - the color bulbs' swatch matches `color_mode`
   - a hex color change reaches the bulb
   - the SONOFF toggles
   - TalkBack reads the tiles
   - Hebrew mirrors the grid
5. CI is green, with goldens included.

## Deferred, with a reason

- **Thermostat tiles.** There is no test device.
- **Zigbee2MQTT group scenes.** ZigDash keeps its own scenes.
- **A column-count setting.** The window size decides the columns.
- **Bulk conversion of custom tiles.** Conversion is per tile only.
