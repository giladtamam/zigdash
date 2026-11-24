# Your own switch looks like the others (3.8.7): plan rev 2 (2026-11-21), scored 9/10

Review notes (rev 2, 9/10) to build in: the "waiting" test uses a fake
manager whose `status$` emits (the snapshot is a combineLatest with it);
an `AsyncError` from the snapshot provider shows "—".

Rev 1 scored 8/10. Rev 2: the stale label gets `AppLocalizations`;
sequencing after the scenes build (one l10n sequence, one goldens pass,
`scenes_tablet` expected to change); "Waiting" only before any message,
a message without the path value → "—"; the one-stored-icon case and the
form keeping the stored icons; a semantics assertion for device tiles
after the extraction; `toggleState` compares strings on both sides and
shows "—" for raw JSON; a toggle-only row in the emulator check.

Approved by the owner for 3.8.7 next to scene-own-tiles-387.md; separate
plan, same release.

## Sequencing with scene-own-tiles-387.md
This work starts **only after the scenes build is committed** on
feat/scene-own-tiles, in the same session, on top of it (same branch, no
parallel edits in the worktree). ARB edits run in one sequence: the
scenes keys and rewords first, then this plan's removals; one
`flutter gen-l10n` and one key-parity test at the end. Goldens: **one**
shared `ci/update-goldens` pass for both plans, after both are in.

## What happened

Same reporter as scene-own-tiles-387.md (DE, 3.8.5): "It would also be
nice if your own tile (switch) looked the same as the others." Screenshot:
his custom toggle tile "1_Licht-Flur" next to Zigbee2MQTT device tiles.
His tile: a crossed-out plug icon, the name, "OFF" in English, a Switch
on the right. The device tiles: the icon in a rounded chip, a bold name,
"Aus", tap to toggle, amber fill when on.

## Causes in the code (release/3.8.6)

1. Two tile designs. Custom toggles render with `toggle_panel.dart`
   (`Card` + `Row` of `Icon`, name, state text, `Switch.adaptive`,
   52–102), untouched since 2.0. Device tiles render with
   `device_tile_panel.dart:73–296`: Signal design (signal-2.0.md §4),
   amber `roles.active` fill with a colour tween, superellipse shape,
   `_QuickAction` chip (467–517), `titleMedium` name, state line.
2. "OFF" is not raw, it is a translation that says OFF:
   `toggle_panel.dart:83` uses `panelStateOn/Off`, which are "ON"/"OFF"
   in every language (`app_de.arb:301–302`; they were written for LED
   tiles). Device tiles use `deviceOn/deviceOff` ("An"/"Aus",
   `app_de.arb:824–825`).
3. Any value that isn't `onMatch` shows "OFF" (`toggle_panel.dart:47–50,
   83`), even `TOGGLE`, `50` or an unknown value; loading shows "…";
   errors show "err" (`panelToggleError`, untranslated in fr and others).
4. The icon: `Icons.power_off` (crossed-out plug) when off (105–109);
   `onIconCodepoint`/`offIconCodepoint` exist in `ToggleConfig` but no
   screen sets them (only old configs or imports carry them).

Who has custom toggles: anyone who built one (Custom MQTT tile), tiles
made with "Pick a device", and older setups' suggested toggles
(`setup_creator.dart:296,315–320`, `device_panel_suggestion.dart:107`).
So the change reaches many existing dashboards, not just the reporter.

## Change

### 1. One card for both (extract, no new design)
New `lib/features/panels/widgets/signal_tile.dart`, moved out of
`device_tile_panel.dart` with no visual change:
- `SignalTileCard({required bool on, bool alarming = false, required
  Widget child, VoidCallback? onTap})`: the fill tween (idle → active →
  attention, `SignalMotion.stateChange`, reduced motion respected), the
  superellipse shape when filled, the `InkWell` with `customBorder`, the
  14 px padding. The alarm pulse stays a device-only branch
  (`alarming` → `_AlarmPulse`, moved along).
- `QuickActionChip` = today's private `_QuickAction` made public, with
  `onPressed` nullable: null draws the same chip **without** its own
  `InkWell`, `Tooltip` or `Semantics` (decorative; the card is the
  target).
`DeviceTilePanel` uses both. Proof of "no change": the device goldens
(device_tiles_phone, dashboard_shell_tablet, edit_mode_*, devices_tablet,
home_page_phone, wall_*) stay byte-identical, **and** the semantics tree
of a device tile is asserted unchanged (§Tests): the chip keeps its
`toggled` flag, tooltip and tap action, the card keeps its "Controls"
custom action.

### 2. The custom toggle on that card
`TogglePanel.build` becomes, top to bottom like a device tile:
- row: `QuickActionChip(icon, on: isOn)` (decorative) and `Spacer`;
- the name in `titleMedium` (bold as on device tiles), 1 line, ellipsis;
- the state line in `bodyMedium`;
- fill: amber when on, idle otherwise; foreground colours from
  `SignalColors` exactly as `DeviceTilePanel` picks them (`fg`,
  `fgVariant`).
No history button, no colour dot, no brightness/cover rows (a toggle has
none).

### 3. Tap: the whole tile toggles; the Switch goes
One tap anywhere on the tile publishes `offPayload` when on, else
`onPayload` (today's `_toggle`, unchanged, same QoS/retain). The
`Switch.adaptive` is removed.
Why: device tiles have no Switch; state is carried by the fill, the
filled icon and the "An/Aus" line, as there. Keeping a Switch would keep
the tile looking different (the reporter's point) and leave two tap
targets doing the same thing. Today the card body already toggles
(`InkWell onTap`, 55), so nobody loses a gesture; the target grows to the
whole tile.
Difference from device tiles, deliberate: a device tile's body opens its
controls sheet and only the chip toggles; a custom toggle has no sheet,
so its body toggles. Long-press (Edit / tile options, `panel_tile.dart:
353–357`) is unchanged.

**Accessibility.** One node for the tile: `Semantics(button: true,
toggled: isOn ?? false, label: panel.name, value: <state line>, onTapHint:
deviceToggle)` around the card, inner texts excluded, the chip
decorative. TalkBack reads "1_Licht-Flur, Aus, switch, off, double tap to
turn on or off", like a Switch did. `panel_tile.dart` keeps wrapping
interactive tiles in `Semantics(container: true)`; the long-press hint
(`a11yPanelOptions`) stays. Tap target ≥ 48 dp (the whole tile).

### 4. State line and "on"
The tile watches `panelValueSnapshotProvider` (same key `panel_tile.dart`
already watches for the stale frame, so no extra subscription) instead
of `panelValueProvider`, so it knows whether **any message** arrived
(`snapshot != null`, with `receivedAt`) apart from the value.

Pure helper `toggleState(ToggleConfig, PanelValueSnapshot?) →
ToggleState` (`on` / `off` / `raw(text)` / `noValue` / `waiting`) in
`toggle_panel.dart`. All comparisons are on **strings, both sides**:
`extractByPath` can return a `bool` or `num` (`{"state":true}`,
`{"power":0}`), so the value is `value.toString()` and the targets are
strings too:
- **waiting**: no snapshot (no message since the tile subscribed);
- **noValue**: a message arrived but has nothing at `jsonPath`
  (`snapshot.value == null`);
- **on**: `value.toString() == onMatch` (today's rule);
- **off**: `value.toString() ==` the tile's off value as a string: with a
  `jsonPath`, `extractByPath(offPayload, jsonPath)?.toString()` (e.g.
  `{"state":"OFF"}` → `OFF`, `{"state":false}` → `false`,
  `{"power":0}` → `0`); without a path, `offPayload` itself; if
  `offPayload` has nothing at the path (not JSON, other key), a value
  equal to `offPayload` itself still counts;
- **raw** otherwise (`TOGGLE`, `50`).
Line: on → `deviceOn`; off → `deviceOff`; raw → the text, 1 line, except
a `Map`/`List` value, or with `jsonPath == null` a string starting with
`{` or `[` (trimmed), → `—` (never a wall of JSON); noValue → `—`;
waiting → `deviceWaiting`; stream error → `—`.
Fill and chip "on" only when on; raw or unknown draws idle (as an unknown
device does). Tap when not on sends `onPayload` (today's behaviour: a
toggle whose state is unknown turns on).
No pending/optimistic state: device tiles have none either (they change
when the device reports); the tile stays as is until a message arrives.

Toggles with a JSON path work as before (the value at the path); toggles
with `jsonPath == null` compare the whole payload (Tasmota
`stat/…/POWER`). Toggles that never get a state message stay "Waiting for
first report" forever, as a device that never reports does.

### 5. Icon
- both `onIconCodepoint` and `offIconCodepoint` set → today's rule: the
  on icon when on, the off icon otherwise (`materialIcon`), in the chip;
- **only one set** → that icon in both states (the chip's fill shows the
  state); today the missing one fell back to the power/plug icon, which
  mixed two designs on one tile;
- none → `Symbols.powerSettingsNew` (the switch/plug device class icon,
  `device_tile_panel.dart:410`) drawn with `SignalIcon` so it fills when
  on, the same icon in both states. The crossed-out plug goes.

**Keep stored icons on edit.** Today `_buildConfig`
(`panel_form_screen.dart:508–513`) builds a new `ToggleConfig` without
the icon fields, so saving a toggle in the form silently drops them.
The form keeps the loaded config's `onIconCodepoint`/`offIconCodepoint`
(read where it loads `cfg is ToggleConfig`, line 359) and passes them
through, so "honoured" stays true after an edit. Still no picker.

### 6. Stale overlay
`panelReliabilityValueLabel(PanelConfig, Object? value)`
(`panel_tile.dart:140–149`) has no localisations today. It gets an
`AppLocalizations l10n` parameter; the one call (`panel_tile.dart:361`,
in `build`, `context.l10n`) and the tests that call it
(`panel_tile_reliability_test.dart:169–180`, passing an English
`AppLocalizations`) are updated. New `ToggleConfig` case using the same
state rules: "Last known: Aus" instead of the raw `OFF`. Cover and text
log cases unchanged. The dimming, the gate and "Last known" stay.

### 7. Sizes
The tile becomes a column (chip row, name, line) like a device tile, so a
row holding only toggles grows to device-tile height (rows take their
tallest tile, `panel_grid.dart:162–190`); rows already mixing toggles and
device tiles don't change height. Chip size per window class
(`SignalSpacing.quickAction[WindowClass]`) as on device tiles, so phone,
tablet and wall/kiosk (same `PanelGrid`) scale the same way. Small /
Wide / Full widths all work (the card fills its cell).

## Not changed
Other custom tiles (slider, button, cover, multi-state, LED…) keep their
look; the toggle's config, form and stored data (no migration); publish
topic, payloads, QoS, retain; long-press, Edit mode, kiosk lock; no
icon picker in the toggle form (the stored icon fields are honoured, not
editable); no device-class icon for a toggle linked to a device (a later
step: needs the device's class looked up); `panelStateOn/Off` stay for
LED tiles.

## Strings
**No new keys.** (Edited after the scenes plan's ARB changes, §Sequencing.) Reused: `deviceOn`, `deviceOff`, `deviceWaiting`,
`deviceToggle`. `panelToggleNoState` and `panelToggleError` become
unused and are removed from all 13 ARBs (cs de en es fr he it nb nl pl pt
ru sv), with the ARB key-parity test from scene-own-tiles-387.md.

## Tests
Unit (`test/features/panels/toggle_state_test.dart`, new):
- `toggleState`: `ON` with `onMatch: ON` → on; default config
  `{"state":"OFF"}` at path `state` → off; raw `offPayload: "0"`, no
  path, value `0` → off; **bool**: `offPayload {"state":false}`, value
  `false` (bool from `extractByPath`) → off, `true` with
  `onMatch: "true"` → on; **num**: `offPayload {"power":0}`, value `0`
  (int) → off; `TOGGLE` → raw; JSON object value → raw, line `—`; no
  snapshot → waiting; snapshot with null value → noValue (`—`).
Widget (`test/features/panels/toggle_panel_test.dart`, new):
- Waiting before any message; a message `{"battery":90}` at path
  `state` → `—`; raw `{"a":1}` with no path → `—`.
- On: `deviceOn` text, `roles.active` card colour, chip filled; off:
  `deviceOff`, idle colour; German locale shows "An"/"Aus".
- Tap on the name area publishes `onPayload` when off, `offPayload` when
  on; exactly one publish per tap; no `Switch` in the tree.
- Semantics: one node with `isButton`, `hasToggledState`, `isToggled`
  matching, label = name, value = state line; tap action publishes.
- Unknown value → idle, "Waiting for first report"; tap sends
  `onPayload`.
- Icons: both stored → on/off icons by state; only `offIconCodepoint`
  stored → that icon on and off; none → `powerSettingsNew`.
- Form (`panel_form_screen` test): open a toggle with both icon fields
  stored, change the name, save → both fields still in the saved config.
- Disconnected: the reliability gate still absorbs taps (existing).
Existing:
- `panel_tile_reliability_test.dart:226` taps `find.byType(Switch)` →
  tap the tile (`find.byType(TogglePanel)`); expectations unchanged.
- `panelReliabilityValueLabel` tests (169–180) pass an English
  `AppLocalizations`; new case: toggle `OFF` → "Off"; German → "Aus".
- `edit_mode_test.dart` (uses a toggle) passes unchanged (long-press).
- `device_tile_panel_test.dart` unchanged and green after the
  extraction, plus a new semantics assertion on a switch/plug device
  tile (`tester.getSemantics` on the chip: `hasToggledState`,
  `isToggled` matching, tooltip `deviceToggle`, tap action; on the card:
  the `deviceControls` custom action), written and passing **before**
  the extraction and unchanged after it.
Goldens:
- **Change**: `dashboard_phone`, `dashboard_tablet`,
  `dashboard_dynamic_color` (screens_golden_test.dart:60–61, two
  toggles). Re-render the Linux goldens in CI through a throwaway
  `ci/update-goldens` branch (platform goldens only render on Linux),
  both `test/goldens/goldens/linux/` and `…/ci/`; review the three
  diffs by eye before taking them.
- **Expected to change from the scenes plan** in the same shared pass:
  `scenes_tablet` (device_tiles_golden_test.dart:572–584; the
  `sceneActionsCount` reword "{count} actions").
- **Must not change** (proves §1 is a pure extraction): all other
  goldens, device_tiles_phone, edit_mode_*, dashboard_shell_tablet,
  devices_tablet, home_page_phone, wall_* included. Any other diff in the
  pass is a bug, not something to accept.
- Full suite green except the known macOS-only golden.

## Release
Ships in 3.8.7+129 with scene-own-tiles-387.md. Line appended to the
en-US note: "Your own switch tiles now look like the device tiles: tap
anywhere to switch, with On/Off in your language." Emulator screenshots
(a custom toggle on and off next to a device tile, phone and tablet,
German locale, TalkBack focus on the tile) before asking for the upload.
No analytics, no policy change.

## Read / verification
- Before release: on the emulator against the Pi rig, a custom toggle on
  a Zigbee2MQTT light (`{"state":"ON"}`, path `state`) and one on a
  Tasmota-style raw topic (`ON`/`OFF`, no path), next to device tiles:
  same height, colours, chip, "An/Aus"; one tap toggles; TalkBack reads
  one node with the toggled state. Plus a dashboard screenshot of a row
  holding **only** toggles (Small width, phone and tablet), to see the
  taller row (§7).
- The reporter: screenshot request by email once live (outside this
  plan).
- No new event; complaints about the missing Switch in support mail over
  3 weeks are the kill signal (then: put a compact Switch back on the
  right, keeping the card look).
