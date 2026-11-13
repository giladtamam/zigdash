# Nothing yet: a screen for people without a hub (3.4)

Built 2026-11-04 from the November theme of [roadmap-2026-11.md](roadmap-2026-11.md). Words follow [CONTEXT.md](../../CONTEXT.md).

## Why

Aptabase, 2026-10-05 to 11-04, Google's review device removed: ~710 setup starts, 461 empty scans, and in 441 of them the scan saw no hub page of any kind. Where the guide asked "Is Zigbee2MQTT running?", 17 said "not yet" against 9 "yes"; 27 tapped "no hub yet". The first screen already asks "What runs your Zigbee?" (3.2), but its "Nothing yet?" was a small row with a demo link and a browser link to zigdash.app/hubs, and nobody who left for the browser came back through setup.

## Decisions

1. **A fourth answer on the first screen**, "Nothing yet", a card like the other three (Zigbee2MQTT, Home Assistant, SMLIGHT). It opens a screen in the app, not a web page. The demo and hubs links under the question are gone; both live on the new screen.
2. **The screen** says what ZigDash needs in one line, then the three ways to a hub, each a card that opens its guide: SMLIGHT SMHUB (zigdash.app/hubs), a Raspberry Pi or any Linux box (Zigbee2MQTT's installation guide), Home Assistant (zigdash.app/home-assistant). A note says a Pi or Home Assistant also needs a Zigbee adapter. Then the demo home (filled button), "Remind me in a week", "I have one now" (back to the first screen) and the hubs page.
3. **The guide's "Zigbee2MQTT not set up yet" step** opens the same screen instead of the browser.
4. **Remind me in a week** reuses the 2.9.7 reminder with a second kind: seven days, "Got your hub? ZigDash sets it up in about a minute." One local notification, nothing leaves the phone.
5. **From the guide**, "I have one now" goes back to the guide's step, not the first screen, so `have_one` from `guide` means a return to the empty result.
6. **Measured** as `setup_step` no_hub with `choice` = where from (welcome, guide) and `result` = what was done (opened, smhub, pi, home_assistant, hubs_page, demo, remind, have_one). `welcome_demo` and `welcome_hubs` stop being sent (the ZHA note's demo now counts as a plain `demo`). Policy updated for 3.4.0.

## Read on about 2026-11-18

- no_hub opened, by from, against scan_empty with hub none: the share of no-hub people who now land on the screen instead of an empty scan.
- no_hub remind and reminder_opened: whether anyone comes back.
- complete ÷ (scan_found + z2m_running yes + manual_test connected): the November metric; it should not fall, since the no-hub cohort now leaves the denominator earlier.

## 3.4.1: what a home has set up, on `app_started`

The December work (roadmap-2026-11.md §4, item 0) needs "share of homes with an automation", and every existing event counts taps, not homes. From 3.4.1 `app_started` carries three more ranges, for real homes only (the demo is left out):

- `automations`: 0 / 1-3 / 4+. Automations live on the hub, and `app_started` is sent before any broker answers, so the number is the rule count the Home's Engine last reported to this phone (`engine.rules.<home>`, written by `rememberEngine`). It is a floor: a phone that never saw the Engine on a hub sends 0, and the count is as old as the last launch that heard the Engine. It counts every valid rule on the hub, switched on or off.
- `scenes`: 0 / 1+, saved scenes; the built-in shutter scenes are not rows.
- `shortcuts`: 0 / 1+, widgets and Quick Settings tiles; Device Controls keep no record.

Read from ~2026-11-20, by `installed` range: the share of launches at 8-30 days with each of the three above 0 is December's baseline.
