# 3.6.2: the Engine when it's needed (v3, scored 7 → 8 → 9)

v2 after review (v1 scored 7/10): the hub check's real causes, away-from-home and Zigbee2MQTT-page homes,
waiting rules that start together, and a count bar instead of a rate.

Why now: 3.6's trial is led by History, and History, automations and alerts that keep running with the
phone off all need ZigDash Engine on the hub. The Engine is what people don't get to.

## What the data says (self-hosted analytics, Nov 9–15, Play robots excluded)

- **Automations tab, Engine not installed (`engine_setup offered`): ~10 different homes, 1 install** (Turkey,
  3.6.0, Zigbee2MQTT 2.14). No `consent_shown`, `failed` or `too_old`: people saw the offer and left.
  Zigbee2MQTT versions 2.9–2.14, so not a version problem.
- **The Dutch wall-tablet home** was offered it 3 times in two days (Zigbee2MQTT 2.13), opened the Pro
  screen three times, and records History on the tablet instead.
- **"Turn on History" (3.6.1), Poland:** the app waits 8 s for the hub to say whether the Engine is there
  (`settledEngineView`, lib/engine/engine_setup.dart:56); the hub didn't answer in time (13 s after an
  update restart), so the app logged `history_setup failed` with no reason and offered the phone instead.
  The hub itself works (the daily backup went through a second later).

## Why people stop (lib/engine/automations_screen.dart)

On the Automations tab without the Engine, the whole screen is a text block ("Automations run on your hub,
not on your phone…"), three bullets and **Install on hub**. The "New automation" button only exists once
the Engine is installed (line 189). Someone who came to make "door opens → light on" is first asked to
install software on their hub, before they have anything to run, and with no word on what it is or where it
comes from. Zigbee2MQTT users are careful about what runs next to their Zigbee network.

Automations are already stored as retained messages on the broker (automations_repo.dart:108), whether or
not the Engine is installed, and the Engine reads them when it starts (hub/zigdash-engine.js:1012 subscribes
to `zigdash/automations/#`, 1065–1080 load each retained rule). So the order can change. Caveat: a rule
saved but not running lives only as long as the broker keeps retained messages (a Mosquitto without
persistence loses it on restart); the "Not running" row says so.

**Why the hub check times out (three causes, not one):**
- **Away from home**, through the relay, the view stays `checking` until `relayWait` (15 s,
  engine_providers.dart:103): an 8 s check always fails there.
- The view needs both `bridge/info` and `bridge/extensions`. After a broker restart without persistence,
  Zigbee2MQTT before 2.14.2 doesn't send them again, so no wait is long enough.
- A slow hub or a phone just restarted (Poland: 13 s after an update).

## The change (3.6.2)

1. **Make the automation first.** Without the Engine, the Automations tab shows the same list and
   **New automation** button as with it, under a slim card: "Automations run on your hub with ZigDash
   Engine. ZigDash puts it there when you save your first one." The full explanation moves to the save step.
   Rules saved without the Engine are listed under "**None of these run yet**" with Install, so nobody thinks
   the phone runs them.
   - **Homes connected through the Zigbee2MQTT page** (`needsBroker`) have no broker to save to: the tab
     keeps today's "Automations need your MQTT broker" step before the editor; nothing new there.
2. **Install on save.** Saving an automation on a hub without the Engine opens a sheet:
   - what happens: "ZigDash Engine is one open-source file that ZigDash adds to Zigbee2MQTT's folder on your
     hub. It runs your automations there, with your phone off. Remove it any time from this tab.";
   - **Install and save** (the existing install, then the rule is live) and **Save without running**
     (the rule is kept on the broker, shown as "Not running: ZigDash Engine isn't on your hub" with an
     Install button);
   - if Zigbee2MQTT blocks add-ons, the existing consent screen (allow external JavaScript and restart)
     comes first; too old: the existing "update Zigbee2MQTT" message, rule kept.
   - **away from home** (connected through the relay, which never carries Zigbee2MQTT's bridge topics,
     engine_providers.dart:131): no Install button; the sheet says "Save now. ZigDash asks you to install
     the Engine the next time this phone is home" with **Save** only; the rule is kept as not running.
     The next time the Automations tab opens with the hub reachable directly, the install sheet (with the
     waiting-rules list) opens by itself **once per batch of waiting rules** (a closed sheet doesn't come
     back on the next visit; the Install button under "None of these run yet" stays); nothing is ever
     installed without a tap;
   - the free-three limit and the trial check run before the editor opens, as now.
   - **Rules waiting from before:** when the Engine is about to be installed (from any path) and rules are
     waiting, the sheet lists them with a switch each ("run" / "keep paused"), so a "7:00 heater on" saved
     weeks ago doesn't start by surprise. Paused ones are saved as disabled.
3. **Trust in one line, with a link:** the sheet and the slim card link the Engine's source on GitHub at the
   release tag it was built from (not main).
4. **The hub check waits longer, and says why.** `settledEngineView` from 8 s to 20 s (longer than the
   relay's 15 s), with "Checking your hub…" on screen and a **Use this phone instead** button on the History
   path so nobody waits stuck. `history_setup failed` and the new install path carry `why`: `relay` (away),
   `no_info` (no `bridge/info`), `no_extensions` (info but no `bridge/extensions`), `too_old`, `blocked`,
   `refused`, `other`.
5. **Nothing else changes:** the Engine itself, consent, the History card flow after the check, remote.

## Events and policy
- `engine_setup` gains step `install_tapped` (with `from`: `automations`, `save`, `history`) so the funnel
  reads offered → tapped → installed/failed; `from: save` is new.
- `automation_saved` gains `running: yes/no`.
- `history_setup` gains `why` on `failed`.
- PRIVACY.md rows for these three updated (no new data: steps and reasons only). Effective 3.6.2.

## Tests
- Without the Engine: the tab shows the list and New automation; saving opens the sheet; Install and save
  installs then the rule is live; Save without running keeps the rule and shows "Not running".
- Blocked add-ons: consent screen first; declined → rule kept, not running.
- Too old: message, rule kept.
- Hub silent for 20 s: `why: no_info`; info without extensions: `why: no_extensions`; through the relay:
  `why: relay`, save sheet without Install.
- Waiting rules: the list with switches appears before an install; paused ones stay disabled after it.
- Zigbee2MQTT-page home: the broker step before the editor, unchanged.
- "Use this phone instead" during the History check.
- Saved away, then the tab opened at home: the install sheet with the waiting rules opens; nothing is
  installed until Install is tapped.
- The free-three limit still stops a 4th automation before the editor without Pro or the trial.
- Existing Engine, consent and History tests unchanged.

## Read (3 weeks after 3.6.2 is live)
At ~10 homes a week a rate swings ±16 points, and the History card (new in 3.6) changes who is counted, so
the bar is a count:
- **Bar: at least 6 Engine installs from the save sheet in 3 weeks** (baseline: 1 install from any path in
  6 days before 3.6.2).
- **Confusion check:** homes whose only rules are still not running 7 days after saving. If more than half,
  the "None of these run yet" wording or the install moment is wrong.
- Of those, how many came through "install on save" vs the History card.
- `why` split on failures: if `no_info` + `no_extensions` outweigh `relay`, the next work is the hub check
  (re-asking Zigbee2MQTT for its bridge state), not the copy.
- Side read: History-on via the hub vs via the phone.
- Trial read: count `automation_saved running:no` during trials; rules that never ran don't carry the
  trial's "automations you made keep running" promise.

## Effort
2–3 days: editor and tab changes, the away-to-home prompt, the waiting-rules sheet, the sheet, the wait, events, tests, emulator screenshots of the tab and
the sheet before the user uploads. Strings in 13 languages (AI translation accepted).
