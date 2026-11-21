# A broker with none of your devices (3.8.6): plan rev 2.1 (2026-11-21), scored 9/10

Rev 1 scored 6/10. Rev 2 takes every point: page port and token kept,
base-topic order without races, prefill never overwrites typing, a
bounded local-only guard with Cancel, analytics + policy, entry points and
the state after "Keep", string count, extra tests. Rev 2 scored 8; 2.1
adds an overall guard timeout, late results ignored after Cancel, the
manager read without awaiting, the policy date, touched flags for the
dropdown and scan fills.

## What happened

GB, 2026-11-21, SMHUB, 3.8.5, 6–20 devices. Setup finished through the
Zigbee2MQTT page (`via: z2m_page`). "Turn on History" sent them to the
broker form (`history_on step: broker`). Over 50 minutes:

- 1883 closed on the SMHUB (`smlight_closed` ×3), other ports `tcp` ×3;
- then `auth` ×3 (Mosquitto now on, login refused);
- **12:24 `connected`, `devices: 0`**; History `failed why: no_info` ×2;
  Pro screen → **unlock tapped (sale), no purchase**;
- again `auth` ×3, `connected devices: 0` (12:48);
- 12:53 hub backup `failed why: disconnected`;
- **12:57 `homes: 0`**: the home was deleted and set up again through the
  page; again 13:03 on the tablet; History → "later".

Reading: the broker they reached is not the one Zigbee2MQTT publishes to,
or Zigbee2MQTT never reconnected after Mosquitto was turned on. The app
called it a success, and Save moved the home off the working page onto an
empty broker (dashboard empty, backup "disconnected"), so they started over.

## Causes in the code (release/3.8.5)

1. `connection_form_screen.dart:157`: a page Home switches to
   `transport: mqtt` on Save with no check (then reconnects, 159–163).
   0 devices is `connected` (`connect_diagnostics.dart:438–451`) and the
   sheet shows the green `connTestOk` (form 262–269).
2. `_load` pre-fills a page Home with the page host and 1883 (line 92),
   though Zigbee2MQTT's `bridge/info` gives `config.mqtt.server`, `user`,
   `base_topic`; `z2mBrokerSetting()` already maps that (setup uses it).
3. `_testConnection` calls `diagnostics.run()` without `base`
   (212–215), so devices are always counted under `zigbee2mqtt/`.

## Change

### 1. Keep what the page knew (form `_load`, page Home)
Before line 90 overwrites them: `_pagePort = c.port`, `_pageToken = pw`.

### 2. Base topic for Test and the guard (every edit)
`_baseTopic()` resolved once in `_load` (async, not a handler `ref.read`):
1. the Home's stored `z2mBaseTopic` (from the loaded row `c`), else
2. the first dashboard's prefix via `z2mBase()` (read with the repo, not
   the autoDispose provider), else
3. page Home: `config.mqtt.base_topic` from the page's `bridge/info` (§3),
   else `zigbee2mqtt`.
Passed to `diagnostics.run(base: …)` by Test and by the guard.

### 3. Prefill from Zigbee2MQTT (page Home)
After `_load`, in the background: this session's `bridge/info` from the
Home's manager (`mgr.liveUnder('')`, the topic ending `/bridge/info`), only
if the manager is already created **and loaded**
(`ref.exists(...) && ref.read(...).valueOrNull != null`); `.future` is
never awaited, so the prefill never waits on or starts a connect;
else `fetchZ2mMqttConfig(host, _pagePort, token: _pageToken)` (new
optional `token` → `?token=` as `Z2mFrontendClient` does; 5 s timeout;
`Z2mPageLocked`/null → nothing). Then `z2mBrokerSetting(mqtt,
frontendHost: host)`:
- fill host (first of `hosts`), port, protocol (TLS → `ssl`), username,
  **only for fields not changed since load** (a touched flag per field,
  set by typing, by the protocol dropdown and by a network-scan fill
  (`applyScanResult`)); password never (Zigbee2MQTT doesn't send it);
- the note card gets "Zigbee2MQTT uses {server}" while reading shows a
  small "Reading Zigbee2MQTT's settings…" line, removed on any outcome.
Honest expectation: on SMHUB the server is likely `mqtt://localhost`, so
the host stays the page host as today; the gain there is the username and
the base topic. Docker/NAS setups (broker elsewhere) gain the host too.

### 4. 0 devices is not success (page Home, sheet after Test)
Connected + 0 devices → amber warning instead of the green tick:
"Connected, but this broker has none of your devices. {Zigbee2MQTT sends
to {server}.} If you just turned the broker on, restart Zigbee2MQTT so it
connects to it." Buttons Close / Retry. Non-page Homes unchanged.

### 5. Save guard (page Home only)
Save runs the ladder on the **local candidate only** (config without
`remoteHost`/relay, so no remote fallback), base from §2, with Save
showing a spinner and a **Cancel** button. The ladder's own steps can
take up to ~40 s with a username (each step waits up to the candidate's
12 s), so the guard wraps `run` in an **overall 15 s timeout**, counted as
"the broker didn't answer". Each guard run takes a generation number;
Cancel, a timeout or leaving the form bumps it, and a result for an old
generation (or after `!mounted`) is ignored: nothing is ever saved after
Cancel. (A timed-out `run()` keeps its probe connection until its own
steps end, at most ~40 s; harmless, not a leak.) Then:
- connected, ≥1 device → save as today (switch to `mqtt`, reconnect, pop);
- connected with 0 devices, or not connected → nothing saved; a dialog:
  title "Keep using the Zigbee2MQTT page?", body says which (none of your
  devices / the broker didn't answer: the ladder's first failure line),
  buttons **Keep the Zigbee2MQTT page** (closes the dialog; the form stays
  open with what was typed, so they can fix and retry) and **Save anyway**
  (today's behaviour: switch, reconnect, pop);
- Cancel → back to the form, nothing saved.
The guard's ladder sends **no** `manual_test` (no double count).

After "Keep": the Home stays `z2mPage`; leaving the form returns to where
it was opened from; Automations/History still show "needs broker"
(`engine_providers.dart:93–96`, `history_setup_flow.dart:95`), which is
correct. The form opens from Home settings, Dashboards (×2), Devices,
Automations ("needs broker", where History's card leads) and Remote; the
guard lives in the form, so all six get it. Setup and guided connect don't
use this form: unchanged.

### 6. Analytics (new event, policy row)
`page_broker` on every page-Home Save: `result` = `saved` | `kept_page` |
`saved_anyway` | `cancelled`; `answered` yes / no / `timeout` (stopped
by the 15 s limit, so the Read can see if it cuts off slow brokers); `devices` bucket (0,
1–5, 6–20, 21+). The device bucket is taken from the guard's report before the save and
reconnect. Policy row (store/PRIVACY.md, effective-version line 3 bumped
from 3.8.5 to 3.8.6; user approves the wording,
published GitHub + GitLab before release):
"`page_broker` | From 3.8.6: saving your MQTT broker for a home that
connects through the Zigbee2MQTT page | whether it was saved, you kept the
page, saved anyway or cancelled; whether the broker answered (or the check gave up after 15 seconds); how many
devices it had (0, 1–5, 6–20, 21+)".

### 7. Strings (new keys, 13 languages, AI translation accepted)
`connBrokerNoDevices`, `connZ2mUses`, `connReadingZ2m`, `connKeepPageTitle`,
`connKeepPageBodyEmpty`, `connKeepPageBodyNoAnswer`, `connKeepPage`,
`connSaveAnyway`, `connChecking` = 9 keys. Reword `connFromPageNote`'s last
sentence: "When the broker has your devices, ZigDash switches to it."

## Not changed
Non-page Homes' Save (no guard, no ladder), setup and guided connect, the
Engine and History flows, the `no_info` failure path itself (expected
effect: it stops being reached from an empty broker, since the Home stays
on the page).

## Tests
Unit:
- `fetchZ2mMqttConfig` builds `?token=` when given a token (URI helper
  extracted and tested).
- base resolution: stored → dashboard prefix → page `base_topic` → default.
Widget (`connection_form_screen_test.dart`, diagnostics and page-config
fakes overridden for every page-Home test, no real sockets):
- Test on a page Home passes the resolved base.
- Prefill: `mqtt://192.168.1.5:1883` user `z2m` → host/port/tcp/user;
  `mqtts://` → ssl 8883; `mqtt://localhost` → page host; locked/null →
  today's pre-fill; a field typed, a protocol picked or a scan result
  applied before the (delayed) fake answers is not overwritten; a Home
  whose manager is still loading is not awaited (fetch path used).
- Test connected + 0 devices → warning, no `connTestOk`.
- Save: 0 devices → dialog, transport stays `z2mPage`, event `kept_page`;
  "Save anyway" → `mqtt`, `saved_anyway`; ≥1 device → `mqtt`, no dialog,
  `saved`; not connected → dialog (no-answer body); a hanging fake →
  Cancel returns, nothing saved, `cancelled`; a fake answering
  "connected, 5 devices" **after** Cancel saves nothing; a fake slower
  than 15 s → no-answer dialog; the guard uses no remote
  candidate; no `manual_test` from the guard.
- Existing non-page save tests (lines ~117, ~305) pass unchanged with no
  ladder run.
- Full suite green except the known macOS-only golden.

## Release
3.8.6+128 from release/3.8.5. Note (en-US): "Adding your broker to a home
that uses the Zigbee2MQTT page now checks the broker really has your
devices before switching." Emulator screenshots (warning, dialog,
pre-filled form) before asking for the upload; policy approval first.

## Read (3 weeks after live)
- `page_broker` results: share of `kept_page` vs `saved`; any
  `saved_anyway` followed by a start-over (`homes: 0` + `started`, same
  day/user id) means the guard was right and overridden.
- Start-overs after `manual_test devices: 0` on page Homes: 3.8.5 vs 3.8.6,
  expect ~0 on 3.8.6.
Kill rule: if `saved_anyway` > `saved` with no start-overs after it (the
guard blocks working brokers), drop the guard and keep the warning.
