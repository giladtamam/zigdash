# Automations: no endless "Checking your hub…" (plan rev 2.2, scored 9)

Status: plan, not built. Branch fix/engine-checking from main a16c41df.

## Why

A Pro user (IL, 3.8.7, 2026-11-26) opened Automations and saw
"Checking your hub…" spin with no end. He opened the broker form, the
in-app test said `connected` with 1–5 devices (15:30, `setup_step
manual_test`), he saved, went back: still spinning. No `app_started`
after the save.

What the code does today:
- `engineViewProvider` waits for `$base/bridge/info` and
  `$base/bridge/extensions`. Only through the relay does it give up
  (15 s → `unreachable`). On a local broker, `checking` has no end.
- While `mqttManagerProvider` hasn't resolved, the screen shows a bare
  spinner (`view.when(loading:)`), also with no end.
- The broker form invalidates `mqttManagerProvider` and
  `engineViewProvider` only when a page Home moves to a broker
  (`_fromPage`). A plain edit of a broker Home (new address, user,
  password, port) saves to the database, but the live manager keeps the
  old settings until the app restarts. `mqttManagerProvider` reads the
  Home with `getById` once and doesn't watch it.
- Nothing is tracked while checking, so we don't know how many people
  hit this. `engine_setup offered` (24 people since Nov 9) only counts
  the ones who got past it.

`ensureEngine` (History, save flows) already times out after 20 s with a
reason (`engineWhy`: noConnection / noInfo / noExtensions / relay). The
Automations screen is the one place without it.

## Changes

Rev 1 scored 5. Rev 2: a real "connected" signal (rev 1 would have told
the friend "connected… restart Zigbee2MQTT" while his broker never
connected), the timer restarts on every fresh check, the live policy
file (store/PRIVACY.md) and its step list, a new "Broker settings"
string, invalidate on every edit save, the timer after a busy state, and
sharper tests.

### 1. A broker edit reconnects
`connection_form_screen.dart` `_write`, edit branch: after `repo.update`,
always invalidate `mqttManagerProvider(id)` and `engineViewProvider(id)`
(every edit save, like remote_screen / pair_phone / ha_connect already
do; no change detection, since an empty password means "keep it"). The
`_fromPage` invalidation folds into this.

### 2. The view knows whether the broker is connected
`EngineView` gets `connected` (bool, default `false`). `engineViewProvider`
always passes it: seeded from `mgr.status`, then `mgr.status$`, emitting
only when it flips (no extra `rememberEngine` writes on retry flaps); the
subscription is cancelled in `onDispose` with the others. The
`needsBroker` yield keeps the default (no manager). Test edits:
engine_on_save_test.dart:617 and :622 build their views with
`connected: true`, plus a `connected: false` case expecting
noConnection.
`engineWhy`: `last == null || !last.connected` → noConnection (after the
relay check, before noInfo). This also corrects `ensureEngine`'s reason
for History/save (`history_setup` / `engine_setup` why), which today
says "no info" for a broker that never connected.

### 3. The Automations screen stops waiting after 20 s
`_AutomationsScreenState`:
- `ref.listen(engineViewProvider(id))` in build. Riverpod 2.6 keeps the
  previous value while reloading after an invalidate, so a restart is
  detected with `next.isLoading` (covers first load and reload), or a
  data value whose phase turns `checking` from another phase (also after
  an invalidate from the broker form, decline/undecline or Remote): clear
  `_timedOut`, mark the current value stale (`_lastFresh = null`), and
  (re)start `Timer(engineCheckWait)` (20 s, longer than the relay's 15 s
  so away ends as `unreachable` first). Data that arrives while not
  loading sets `_lastFresh`. In initState, read the provider once (the
  dashboard may already keep it alive, and `ref.listen` doesn't fire for
  the current state): not loading with a value → `_lastFresh` = it. Every
  (re)start cancels a running timer first. Cancelled in dispose.
- When it fires and the state `isLoading` or the phase is `checking`: if
  `_busy != none`, re-arm when busy returns to none; else
  `_timedOut = true`, `why = engineWhy((view: null, last: _lastFresh))`
  (a stale value from a disposed manager never decides why: null →
  noConnection).
- The timeout message is rendered before `view.when`, so stale data
  kept during a reload never hides it. It goes away as soon as fresh
  data with a phase other than `checking` arrives.

| why | Title | Body | Buttons |
|---|---|---|---|
| noConnection | Can't reach your hub's broker | ZigDash can't connect to your broker. Are you on your home Wi-Fi? Away from home, Automations need Remote. | Try again · Broker settings |
| noInfo (connected, no `bridge/info`) | Zigbee2MQTT isn't answering | ZigDash is connected to your broker but hears nothing from Zigbee2MQTT on "{base}". Check that Zigbee2MQTT is running and uses this broker, then restart it. | Try again · Broker settings |
| noExtensions | Zigbee2MQTT didn't finish answering | Restart Zigbee2MQTT, then try again. If it happens again, update Zigbee2MQTT. | Try again |
| other | Your hub didn't answer | Restart Zigbee2MQTT, then try again. | Try again |

  No host in the text (the manager may be trying the remote address).
  `{base}` is the base topic the provider listens on. Broker settings
  opens `/connections/{id}/edit`. Try again: invalidate
  `engineViewProvider(id)` (the listener restarts the timer), not the
  manager. `view.when(error:)` is unchanged.

### 4. Count it
New `EngineStep.checkTimeout` (`check_timeout`) on `engine_setup` with
the existing `why` and `z2m`, once per visit per why (Try again with the
same outcome sends nothing new). The read counts distinct users per day.
store/PRIVACY.md `engine_setup` row: add "from 3.8.x, the hub check on
the Automations screen gave up after 20 seconds, with why (the same
reasons)". Wording needs the owner's approval; publish GitHub + GitLab
with the release.

### 5. Texts
New: 4 titles, 3 bodies (one with `{base}`), "Broker settings"
(`engineNeedsBrokerButton` says "Add broker details", wrong here) = 8
strings × 13 languages. "Try again" reuses `setupTryAgain`.

## Tests
- Unit, `engineWhy`: last null → noConnection; `connected=false` with no
  hub → noConnection (the friend's case); connected, no hub → noInfo;
  hub, no extensions → noExtensions; away → relay.
- Unit, `engineViewProvider` with a fake manager: `connected` follows
  `status$`.
- Widget (fake async, provider overridden): stuck `checking` +
  `connected=false` → noConnection message after 20 s; `connected=true`
  → noInfo; hub without extensions → noExtensions; not before 20 s.
- Widget: after the message, `notInstalled` arrives → offer, no message.
- Widget: an invalidate after the timeout hides the message and a new
  20 s starts; Try again does the same.
- Widget: invalidate to a stream that never emits (old value kept by
  Riverpod) → after 20 s the noConnection message, not the old phase.
- Widget: the view is already live, `checking`, `connected=true` before
  the screen mounts → noInfo after 20 s.
- Widget: two Try agains with the same outcome → one `check_timeout`.
- Widget: busy during the 20 s → message after busy ends if still
  checking.
- Widget: `check_timeout` tracked once with the right why;
  engine_analytics_test covers its props.
- Form: an edit save invalidates the manager (a new build with the new
  host).
- `flutter analyze` clean, all tests and goldens pass; emulator
  screenshots of noConnection and noInfo (en + he) before release.

## Out of scope
- The same spinner text in History sheet, History card and Remote:
  their flows already go through `ensureEngine`'s 20 s timeout.
- Finding why his hub sends no `bridge/info` (asked him for the
  Zigbee2MQTT version and settings).

## Release
Goes into the next Android release (with or before the scan plan on
plan/388), version decided then; privacy check as above; read
`check_timeout` by why 3 weeks after it is live.

From 3.8.8, `history_setup` and `engine_setup` `why` values for a broker
that never connected move from `no_info` to `no_connection`. Don't compare
`why` counts across that version.

From 3.8.8, hubs with external JS off go to consent (`engine_setup`
`consent_shown`, `history_setup` why `blocked`) instead of timing out as
`no_extensions`. Don't compare those counts across that version either.
