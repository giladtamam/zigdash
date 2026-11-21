# Your own tiles in scenes (3.8.7): plan rev 2.2 (2026-11-21), scored 9/10

Rev 2.1 scored 8. Rev 2.2: custom tiles are not linked by topic
(`deviceIeee` comes only from "Pick a device"), so §4 matches by topic:
every `$base/<x>/set` action waits for the device list, then device (if
its row could build the payload) → any tile → kept; only actions outside
the base go to tiles at `_load`; failed discovery still lets tiles claim
pending actions. §1 reworded; two tests added.

Rev 2 scored 8/10. Rev 2.1: `_load` reads the tiles through the DAO, not
an unwatched autoDispose provider; actions waiting for the device list
are shown and counted on the kept line, with the 8 s discovery failure and
`_refresh` spelled out; a device claims a payload its row could build
before a linked tile does; `runScene`'s `base` is a named optional (null =
today). Tests for each.

Rev 1 scored 7/10. Rev 2 takes every point and records the owner's
decisions: `sceneActionsCount` reworded to actions (13 ARBs) and the
editor's count line replaced by the "kept" line; a per-tile note for
actions that run only from the phone at home; matching order (unlinked
tiles, then devices, then kept) so group and linked tiles never become
phantom device rows; duplicate actions kept byte-identical; `_load` waits
for the tiles; cover value read from one raw stream; slider guards (step
0, min ≥ max); a Remove control on the kept line; widgets don't wait for
confirmation on topics outside the base; Share-a-home in the consumer
table; the wrong HA-import citation dropped; the reviewer's extra tests.

## Decisions (owner, 2026-11-21)
- Text-input tiles stay out.
- Auto-linked custom tiles are listed next to their device.
- Scenes don't carry retain/QoS: QoS 1, retain false, as today.
- `sceneActionsCount` is reworded now in all 13 languages.
- The edit round-trip fix ships in 3.8.7.
- Tiles outside the Zigbee2MQTT base not running from Automations or away
  is acceptable, with a clear note in the editor.
- The reporter is reached by email (outside this plan).

## What happened

DE (report date not given), 3.8.5, Android 17, Zigbee2MQTT 2.14.2, 16
devices. Report: "Own tiles are not displayed when adding scenes".

Reading: the scene editor lists Zigbee2MQTT devices by their Zigbee2MQTT
name, never the tiles the user built. Two ways that reads as "my tiles are
missing", and the plan covers both:
- **Custom MQTT tiles** (Add tile → Custom MQTT tile: Toggle, Slider,
  Button, Cover, Multi-State, Combo, Radio…) are not in the list at all,
  whatever their topic. Typical: Tasmota/ESPHome/Shelly topics, or a
  Zigbee2MQTT group (`zigbee2mqtt/<group>/set`; ZigDash never reads
  `bridge/groups`, so a group is reachable **only** as a custom tile).
- **Device tiles the user renamed** ("Wohnzimmer Licht") appear under the
  device's Zigbee2MQTT name (often `0x00158d…`), so the user doesn't
  recognise them.

## Causes in the code (release/3.8.6)

1. `scene_form_screen.dart:222–235`: the only source is
   `discoveredDevicesProvider` (`bridge/devices`), filtered to devices with
   a settable expose (`capturable`). Panels are never read.
2. `scene_form_screen.dart:151–161` `_buildActions`: every action is
   `'$_base/<friendlyName>/set'` + a JSON map; the form's state
   (`_edits`, line 65) is keyed by friendly name, so a tile has nowhere to
   live.
3. `scene_form_screen.dart:355` shows `d.friendlyName`, not the tile name
   or `displayName`.
4. Edit (pre-existing, makes the fix unsafe without §4):
   `scene_form_screen.dart:85–93` loads only the action **count**; nothing
   is pre-selected. `_save` 185–189 then keeps the stored actions only when
   nothing is selected, else **replaces all of them** with the selection.
   "Edit my scene, add my tile" today would silently drop every device
   already in it.

The model fits as is: `SceneAction(setTopic, payload)` (`scene.dart:10`)
is a full topic + a string, and `activateScene`
(`scenes_providers.dart:188–206`) publishes the payload verbatim
(`mgr.publish(topic, payload, '')`; no `{value}` is left after §2
resolves it).

## What an own tile publishes today

Topic: `composeTopic(panel.topicPrefixOverride ?? dashboard.topicPrefix,
panel.topic)` (`panel_tile.dart:204–205`,
`panel_value_provider.dart:57`). QoS `panel.qos`, retain `panel.retain`
(`panels.dart` table). Payloads (`panel_config.dart`):

| Type | Publishes | Payload kind |
|---|---|---|
| toggle | `onPayload` / `offPayload` (default `{"state":"ON"}`/`OFF`) | any string, JSON or raw |
| slider | `valueTemplate` with `{value}` = `v.round()`, `min..max` (default 0–254) | template (`slider_panel.dart:59–65`) |
| button | `payload` (default `PRESS`; `isJson` flag) | fixed string |
| multiState / combo / radio | the chosen `SelectOption.payload` | fixed strings |
| cover | `open/stop/closePayload`; `positionTemplate` with `{value}` 0–100 when `showSlider` | strings + template |
| textInput | `template` with typed text | free text |
| schedule, autoClose | retained **config** for a Node-RED flow, not a command | — |
| led, nodeStatus, progress, textLog, reading | nothing (read-only) | — |
| scene | runs another scene | — |
| device | a Zigbee2MQTT device tile (already reachable as a device) | — |

## Change

### 1. Which tiles become scene-able
Control tiles of this Home: **toggle, slider, button, multiState, combo,
radio, cover**, from every dashboard of the Home.
Not: textInput (owner), schedule/autoClose (config, not commands), scene
(a scene in a scene: loops), read-only types, device tiles (they are the
device rows, §3).
Custom tiles on a device's topic **are** listed (owner), whether made with
"Pick a device" (the only path that sets `deviceIeee`,
`panel_form_screen.topics.dart:212`, saved at
`panel_form_screen.dart:675/687`) or with a hand-typed topic
(`deviceIeee == null`): their payload or endpoint (`state_l2`, a custom
JSON) often differs from what the device row offers. `deviceIeee` plays
no part in matching (§4); matching goes by topic.

Source: a new `sceneTilesProvider` (`FutureProvider.autoDispose.family`
on connection id) in `scenes_providers.dart` over
`DeviceRegistryDao.tilesOfHome(connectionId)`
(`device_registry_dao.dart:29–41`, returns `(Panel, dashboardPrefix)` in
dashboard + tile order; already used by History), overridable in tests.
Pure helper `sceneTileOf(Panel, String? dashboardPrefix) → SceneTile?` in
`scene_capture.dart` (null for excluded types), carrying: panel id, name,
dashboard name (subtitle when the Home has >1 dashboard), type, decoded
config, `deviceIeee`, publish topic, subscribe topic + jsonPath (via
`panelReliabilityPolicy(type).jsonPath(config)`, as `panel_tile.dart`
does).

### 2. Editor UI ("Your tiles" section)
Below "Devices to capture", a header "Your tiles" + one-line hint; shown
only when the Home has at least one scene-able tile. Each tile: a
`CheckboxListTile` (title = tile name, subtitle = dashboard name when
several), and when ticked, its control, built from the same widgets the
device rows use:
- toggle → `SwitchListTile` (`sceneCtrlPower`) → on/off payload;
- slider → `Slider(min, max, divisions)` with the value label →
  `valueTemplate` with `{value}` = the rounded value (as the tile does).
  `divisions` copies the tile's rule (`slider_panel.dart:129–132`):
  `step > 0 ? ((max − min) / step).round() : null`. A slider tile with
  `min ≥ max` is listed **disabled** (no control, can't be ticked; the
  tile itself can't work either), and the value is always clamped to
  `min..max`;
- multiState / combo / radio → a `DropdownButton` of the option labels →
  that option's payload (a tile with no options is disabled like above);
- cover → Open / Close / Stop as a `SegmentedButton` (existing
  `panelCoverOpen/Stop/Close`), plus, when `showSlider`, a "Position"
  segment (`sceneCtrlPosition`) with a 0–100 slider →
  `positionTemplate`;
- button → no control; subtitle shows the payload it sends (raw, not
  translated). Ticked = "press it".

**Note for actions that run only at home.** Under a ticked tile whose
built action is not `'$_base/…/set'` + a JSON object, a small outline
line: "Runs only from this phone at home: not from Automations or when
you're away." (new key `sceneTileHomeOnly`). Why: away through the relay
the hub drops it (`engine.js:247`, §7) while `activateScene` still counts
it sent (`scenes_screen.dart:50` shows "Activated"); the Engine drops it
too. The rule is one pure helper `engineCanSend(SceneAction, base)` in
`scene_capture.dart`, shared with `sceneCommands` (§7) and the shortcut
confirmation (§7), so the three can't drift.

Form state: `final Map<String, SceneAction> _tileActions = {}` keyed by
panel id, plus `final Map<String, Object?> _tileValues` (the control's
value: bool / num / option index / cover choice). `buildTileAction(tile,
value)` (pure, `scene_capture.dart`) resolves the payload **at edit
time**, so the stored action is exactly what the tile would publish.

Payloads: stored as the tile's string, **JSON or raw, unchanged**. No
JSON validation (a raw `ON` to a Tasmota `cmnd/…/POWER` is valid).

### 3. Device rows show the name the user knows
Device row title: the name of the Home's `PanelType.device` tile for that
IEEE (first in dashboard order; reading tiles carry `deviceIeee` too and
are ignored) when there is one and it differs from the friendly name, else
`d.displayName`; subtitle: the friendly name when it differs. Comes from
the same `sceneTilesProvider` read (it also returns the device-tile
names). Nothing else changes in device rows.

### 4. Edit: open the scene as it was saved
`_load` **awaits the tiles directly**: `loadSceneTiles(db, connectionId)`
(a plain async function over `DeviceRegistryDao.tilesOfHome` +
`sceneTileOf`, the same one `sceneTilesProvider` wraps for the build),
with the scene row, before seeding and before `_loaded = true`. It does
not `ref.read(...future)` the autoDispose provider: with nothing
listening yet that read can dispose the provider mid-flight. So a scene
never seeds against an empty tile list (a tile action would fall to kept
or to a phantom device row). A failed/timed-out read (3 s,
`shutterListTimeout`) seeds with no tiles: everything not matched goes to
kept, nothing is lost.

Each stored action, in stored order, claims **one slot**. The route is
decided **by topic** (a custom tile's `deviceIeee` is set only by "Pick a
device", so it can't tell a device topic from a group topic):

- **Topic outside `$_base/`** (Tasmota, ESPHome…): at `_load`, **a tile**
  whose publish topic equals `setTopic` and whose payload matches (below),
  not yet claimed; else `_keptActions`.
- **Topic `'$_base/<x>/set'`**: always to `_pendingActions` at `_load`,
  whatever tiles exist. When the device list first arrives, in stored
  order:
  1. **a device**, when `<x>` is a device in the list, its slot is free,
     and the payload is **what the device row could build**: a JSON object
     whose keys are all settable exposes of that device
     (`captureSettableState(d, map)` keeps every key) →
     `_edits[x] = that map`. So `{"state":"ON"}` from a toggle with the
     default payloads (`panel_config.dart:98`), hand-typed or picked,
     lands on the device row, as it would have been captured there;
  2. else **any tile** (linked or not) on exact topic + payload, not yet
     claimed: groups (`<x>` is not a device), payloads the device row
     couldn't produce (`state_l2` not exposed, raw), a second action for a
     taken device slot;
  3. else `_keptActions`.
- **Discovery fails** (§ below): pending `$_base` actions still go through
  step 2 (tiles), so a group tile still ticks; the rest stay pending and
  are saved as they were.
  Accepted trade-off: then a pending device action whose payload equals a
  hand-typed tile on the same topic ticks that tile instead of the device
  row; nothing is lost and an untouched save stays byte-identical.

**Waiting actions are visible and counted.** Until matched they are shown
in the kept line's count (and the Remove button removes them too); they
count as "something in the scene" for the empty-scene check, so an edit
with pending actions and nothing ticked still saves. If discovery fails
(`discoveredDevicesProvider` gives up after 8 s,
`discovery_provider.dart:18`, or the broker is down) they are first
offered to tiles (step 2 above); those no tile claims stay pending
for the life of the form and **Save writes them as they were**, in their
stored place. `_refresh` (a new base typed in the editor) re-reads the
device list but does **not** re-match pending or kept actions: they were
stored under the old base and stay as they are.

Payload match per tile: toggle (`== on/offPayload`), options and cover
buttons (`== a payload`), slider and cover position (`{value}` in the
template replaced by a number pattern, the rest matched literally; value
parsed and clamped), button (`== payload`).

A second action for an already-claimed slot (same tile, same device) goes
to `_keptActions`; it is never merged or dropped. A device action whose
device is not in the arrived list (renamed, removed) goes to a linked tile
if one matches, else kept; step 2 never invents device rows.

Save writes exactly what the form shows + kept actions, in stored order
for actions that survived and new ones appended. An untouched device or
tile slot keeps its **original payload string** (no decode → re-encode,
which would change whitespace or key order of a hand-typed or imported
payload). So an untouched edit saves byte-identical `actions`, duplicates
included.

The old fallback "nothing selected → keep stored" (185–189) goes; an edit
with everything unticked and nothing kept shows
`sceneFormNoDevicesSelected` like a new scene.

**Kept line.** Replaces today's count line (`scene_form_screen.dart:
323–330`, `sceneActionsCount(_existingActions)`, which no longer says
anything once the scene opens as saved): "{count} other actions are kept"
(new key `sceneFormKeptActions`) with a **Remove** text button
(`sceneFormRemoveKept`) that empties `_keptActions` (after it, Save
writes the scene without them; leaving without saving changes nothing).
Hidden when nothing is kept. `_existingActions` goes.

### 5. Capture of the current value (own tiles)
On tick, seed from the tile's live value when known, from the tile's own
stream `panelValueSnapshotProvider(PanelStreamKey(connectionId, topic:
subscribeTopic, jsonPath: …))`. The provider is `autoDispose`
(`panel_value_provider.dart:104`), so the build `watch`es it for every
listed subscribing tile (same keys as `panel_tile.dart`, so no extra
subscription when the dashboard is alive) and the tick uses the watched
value. Cost: one subscription per listed tile while the editor is open
and no dashboard holds it, like `deviceStatesProvider` for devices.
- toggle: `value == onMatch` → on, else off;
- slider: the number, clamped to `min..max`;
- options: the option whose `match` equals the value, else the first;
- **cover**: one raw stream, key with `jsonPath: null` (whole payload), as
  `cover_panel.dart:116–124` does: `extractByPath(raw, statePath)` and
  `extractByPath(raw, positionPath)` (num or parsed string). Seed: a
  position when `showSlider` and a number was found → "Position" at that
  value; else the state, upper-cased: `OPEN`/`OPENING` → Open,
  `CLOSE`/`CLOSED`/`CLOSING` → Close, `STOP`/`STOPPED` → Stop; anything
  else or nothing → Open.
- button: nothing to capture.
Unknown → the defaults above (on, mid-range, first option, Open). Own-tile
rows never show "Reading current state…" (no `/get`, many tiles never
retain, so it would never go away). The value is copied once, on tick, so
a tile changing while the editor is open does not move the user's choice.

### 6. Retain and QoS (owner: not carried)
Scenes keep publishing QoS 1, retain false, for own tiles too. A tile with
`retain: true` is usually a "last command" topic; replaying a retained
`/set` on every broker reconnect is the wrong default for a scene. No
model change.

### 7. Where scenes run, and what each does with an own-tile action
| Consumer | File | With an own-tile action |
|---|---|---|
| Scenes tab, scene tile | `scenes_screen.dart:47–50` → `runScene` → `activateScene` (`scenes_providers.dart:161,188`) | published verbatim. At home OK; away, the hub drops non-base topics (row "Away") but the snackbar says "Activated": covered by the editor note (§2) |
| Home-screen widget, NFC tag | `shortcut_engine.dart:359–399` → `shortcut_commander.dart:362–407` | published (395–397). **Change**: see below |
| Engine automation "Run a scene" | `automation_editor_screen.dart:174–182` → `sceneCommands` (`automation.dart:323–342`) | **bug to fix**: a raw payload becomes `{}` (332–335) and is still sent (337–340) |
| Engine on the hub | `hub/src/engine.js:392–399 send()` | runs a raw-topic command only under `<base>/…/set`; others silently dropped. Unchanged (owner) |
| Away (relay) | `hub/src/engine.js:245–251 remoteCommandAllowed` | only `<base>/…/set|get`; non-Zigbee2MQTT topics dropped (same as the tiles themselves away). Unchanged (owner) |
| Backup / export | `backup_service.dart:44–63` (export), `119–132, 190–209` (import) | `toJson`/`fromJson` of the stored strings; model unchanged. OK |
| Share this home | `share_home_screen.dart:70–71` → `exportConnection`; `join_home_screen.dart:76` → `importToConnection` | scenes travel with the dashboards, topics absolute; the joiner's copy works against the same broker. OK, no change |
| Chat / assistant | `hub/src/chat.js`, `lib/features/chat` | no scene running found. Not affected |

**Shortcuts.** `runScene` waits for confirmation only on JSON `/set`
actions (372–379), up to `confirmWithin` = 5 s (line 95). An own tile on
`zigbee2mqtt/<group>/set` with JSON passes that test, but a group or a
non-Zigbee2MQTT device may never answer on `<topic>`, so the widget would
sit 5 s before "Sent". Change: `runScene` gets a named optional
`String? base` (null = today's behaviour exactly, so the existing
`shortcut_commander_test.dart` cases pass unchanged); `shortcut_engine
.dart` passes the Home's `_homeBase(connectionId)`. With a base it waits
only for
actions where `engineCanSend(a, base)` (base + `/set` + JSON object; no
check that the device exists); others are published and not waited on. A scene of only such
actions returns `sent` at once. Group tiles under the base still wait (a
group does publish its state on `<base>/<group>`), which is correct.

**Engine fix** (app only, hub untouched): `sceneCommands` drops actions
where `!engineCanSend(a, base)`. The automation editor (174–182) counts
them: all dropped → existing `autoErrEmptyScene`; some dropped → a note
under the scene picker (`autoSceneTilesSkipped`, plural: "{count} of this
scene's actions run only from this phone at home, not from
Automations"). Existing automations keep their already-built commands
(snapshotted at save), so nothing running changes.

### 8. Scene list (owner: reword now)
`scenes_screen.dart:225,236` shows `sceneActionsCount`; its English
becomes `"{count, plural, =1{1 action} other{{count} actions}}"`,
reworded in all 13 ARBs (plural form per language, e.g. cs/pl/ru with
few/many). Its only other use (form 323–330) is removed in §4.

### 9. Strings (13 languages: cs de en es fr he it nb nl pl pt ru sv, AI translation accepted)
New keys (**6**): `sceneFormTilesHeader` ("Your tiles"),
`sceneFormTilesHint` ("Tiles you made yourself. The scene sends what the
tile sends."), `sceneTileHomeOnly` (§2), `sceneFormKeptActions` (plural:
"1 other action is kept" / "{count} other actions are kept"),
`sceneFormRemoveKept` ("Remove"), `autoSceneTilesSkipped` (plural).
Reworded (**3**, all 13): `sceneActionsCount` (§8), `sceneFormNoDevices`
("No controllable devices or tiles found…"), `sceneFormNoDevicesSelected`
("Select at least one device or tile.").
Reused: `sceneCtrlPower`, `sceneCtrlPosition`, `panelCoverOpen/Stop/Close`
(`sceneFormReadingState` stays device-only).

### 10. Analytics and policy
None. `sceneCreated`/`sceneRun` already exist (`analytics_events.dart:677,
681`) and are unchanged. No new event, so store/PRIVACY.md is untouched
(no effective-version bump).

## Not changed
`SceneAction` model and the Drift schema (no migration); `activateScene`;
the hub Engine and relay filters (own tiles off the Zigbee2MQTT base don't
run from Automations or away: the editor says so); retain/QoS (§6);
`/get` capture for devices; the All-shutters built-ins; Zigbee2MQTT groups
as a first-class list (reachable only as custom tiles); text-input tiles;
a scene does not follow a tile whose topic is edited later (the stored
topic is absolute, as a renamed device's is today; it then shows as kept).

## Tests
Unit (`test/scenes/scene_capture_test.dart`, new groups):
- `sceneTileOf`: toggle/slider/button/options/cover → tile with the
  composed topic (dashboard prefix, override, empty prefix); textInput,
  schedule, autoClose, scene, led, reading, device → null.
- `buildTileAction`: toggle on/off raw (`ON`) and JSON; slider `{value}`
  rounded and clamped; options payload; cover open/close/stop and
  `{"position":{value}}`; button payload as is.
- Slider guards: `step: 0` → divisions null, value still clamped;
  `min ≥ max` → tile disabled (no action built).
- Payload → value matching: each kind, template with text around
  `{value}`, no match → null.
- Seeding: toggle `onMatch`, slider clamp, option `match`; **cover**:
  `{"state":"CLOSED","position":40}` with `showSlider` → Position 40;
  without `showSlider` → Close; `{"state":"stopped"}` → Stop; nothing →
  Open.
- `engineCanSend`: base `/set` + JSON object → true; raw payload, topic
  outside base, base topic without `/set` → false.
- `sceneCommands`: raw payload dropped (no `{}` command), topic outside
  base dropped, Zigbee2MQTT `/set` JSON kept (existing
  `test/engine/automation_test.dart` unchanged).
- `shortcut_commander_test.dart` (existing cases untouched, no `base`):
  with `base: 'zigbee2mqtt'`, a scene with one device and one
  `cmnd/plug/POWER` action confirms on the device's answer alone; a scene
  of only outside-base actions returns `sent` without waiting
  (`confirmWithin` not reached, fake clock); without `base` the same
  scene behaves as today.
Widget (new `test/scenes/scene_form_screen_test.dart`; devices, states,
`sceneTilesProvider`, repo and MQTT manager faked; no sockets):
- New scene: a custom toggle on `cmnd/plug/POWER` is listed under "Your
  tiles"; tick + off + save → `(cmnd/plug/POWER, OFF)`; the home-only
  note shows under it. A ticked tile on `zigbee2mqtt/lamp/set` with JSON
  shows **no** note.
- A renamed device tile's name shows on the device row; a Home with tiles
  and no devices shows the tiles, no dead end; neither → reworded text.
- **Group round-trip**: stored `(zigbee2mqtt/kitchen/set,
  {"state":"ON"})`, a hand-typed group toggle on that topic, no device
  `kitchen` → pending at `_load` (kept count 1); **after the device list
  arrives** the group tile is ticked, no device row, kept line gone; Save
  untouched → byte-identical. Same with discovery failing → the group
  tile still ticks (tiles tried before staying pending).
- **Hand-typed toggle on a device topic**: device `lamp` (settable
  `state`), an unlinked (`deviceIeee == null`) toggle typed on
  `zigbee2mqtt/lamp/set` with the default payloads; stored
  `(zigbee2mqtt/lamp/set, {"state":"ON"})` → the **device row** is
  ticked, the tile is not; Save untouched → byte-identical.
- **Linked tile vs device**: device `relay` (settable `state` only), a
  linked toggle with the default payloads (`{"state":"ON"}`,
  `panel_config.dart:98`) and a linked toggle with `{"state_l2":"ON"}`;
  stored `(zigbee2mqtt/relay/set, {"state":"ON"})` and `(…,
  {"state_l2":"ON"})` → the first on the **device row** (its row could
  build it), the second on the `state_l2` tile; round-trip
  byte-identical. With `state_l2` also settable on the device, the
  device slot is already taken by the first action, so the second still
  lands on the `state_l2` tile.
- **Tiles read with nothing watching**: no widget or override listens to
  `sceneTilesProvider` before `_load`; the fake DAO answers after a delay;
  a `cmnd/plug/POWER` action seeds on its tile (guards against the
  autoDispose read).
- **Devices late**: device list arrives after the form opened → pending
  actions move to their rows and the kept count drops. **Save before it
  arrives** → `actions` byte-identical. **Discovery times out** (fake
  provider errors) → pending stay counted on the kept line, an edit with
  nothing ticked still saves them as they were; `_refresh` with a new
  base does not move them.
- **Duplicates**: the same tile action twice + the same device twice →
  one slot each, two kept, "2 other actions are kept"; Save untouched →
  byte-identical, order kept.
- **Tiles load late**: the fake tiles read (`loadSceneTiles`) completes after a delay; the
  form shows the spinner until then and seeds an outside-base tile action
  on the tile (not kept).
- Edit round-trip: 2 devices + 1 tile + 1 unknown action opens as saved;
  Save untouched → byte-identical; tick one more tile → all old actions
  kept, new one appended (regression for cause 4); untick everything with
  nothing kept → snackbar, nothing saved.
- **Remove kept**: tap Remove → line gone; Save writes the scene without
  the kept actions; back without saving → row unchanged.
- Slider tile with `step: 0` works; `min ≥ max` tile disabled.
- `automation_editor_test.dart`: a scene with one device + one raw tile →
  one command and the note; only raw tiles → `autoErrEmptyScene`.
- `activateScene` publishes a raw payload unchanged (fake manager records
  `(topic, payload)`).
- l10n: a test (or `tool/` check run in CI) that every ARB has the same
  key set as `app_en.arb` and `sceneActionsCount` is a plural in all 13.
- Full suite green except the known macOS-only golden.

## Release
3.8.7+129 from release/3.8.6 (branch feat/scene-own-tiles). Note
(en-US): "Scenes can now include the tiles you built yourself (custom MQTT
tiles), and editing a scene keeps everything already in it." Emulator
screenshots (Your tiles section, a ticked toggle + slider with the
home-only note, edit of an existing scene with the kept line) before
asking for the upload. No policy change.

## Read / verification
- Before release: on the emulator against the Pi rig, a Tasmota-style
  custom toggle (`cmnd/test/POWER`, raw) and a group tile
  (`zigbee2mqtt/<group>/set`) in one scene with a device; run from the
  Scenes tab, a scene tile, a home-screen widget (returns "Sent" without
  the 5 s wait for the Tasmota action); `mosquitto_sub -v -t '#'` shows
  each payload exactly as the tile sends it.
- Edit that scene, save untouched, compare the `actions` column before and
  after (byte-identical).
- Engine: an automation on that scene sends the device and the group, not
  the Tasmota topic, and shows the note.
- No analytics event tells own-tile scenes apart (deliberately). 3 weeks
  after live: `scene_created` per active Home, 3.8.6 vs 3.8.7 (expect
  flat or up; a drop would mean the longer editor hurts).
