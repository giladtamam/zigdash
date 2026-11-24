# 3.6: Turn on History, then try Pro

Plan v4.1, 2026-11-14 (scores: v1 5/10, v2 7/10, v3 8/10, v4 9/10 "ready to build"; 4.1 adds the last small fixes). Month 1 of the profit plan ([../growth/profit-plan-2026-11.md](../growth/profit-plan-2026-11.md) v4.1), with its "first week" theme pulled forward. Base: release/3.5.4 (in Play review). Version 3.6.0+113. The trial is Android Play only.

## 1. Why the order changed
Pro's features all sit behind a setup step nobody takes:
- History beyond today needs a recorder: History shows `_SetupCard` whenever the recorder heartbeat isn't `online` (history_sheet.dart:191; history_service.dart `historyRecorderOnlineProvider`). The recorder is ZigDash Engine on the hub (Set up → `ensureEngine`, engine_setup.dart) or "Record on this device" (app_recorder.dart).
- Automations need the Engine too (automations_screen.dart:254).
- Since Nov 9: `engine_setup offered` 9 sessions, nothing after; `history_setup` 0; kiosk starts 0; `automation_saved` 0.
A trial before that would unlock views that show a setup card. So 3.6 first gets History recording, and the trial starts when it does: the person sees their own days, then the week and month views.

## 2. Turn on History (the first-week step)
**Where:** (a) the setup finish screen, as its last step for a new home: "See your temperatures, power and doors over days. Turn on History" [Turn on] [Later]; (b) a one-time dashboard card with the same words for homes from before 3.6 whose recorder isn't online. Card order in the dashboard slot: usage-data card → this card → "Chat with your home" card; never two at once.

**What Turn on does, by connection type** (19 setups completed Nov 9–14: MQTT broker 7, Home Assistant 8, Zigbee2MQTT page 4):
- **MQTT broker:** `ensureEngine(from: history)` then `publishConfig`. If the Engine fails or the hub is too old: "Record on this phone instead?" (`historyRecordHere`), saying it records only while ZigDash is open.
- **Home Assistant:** the Engine first, as for a broker: Home Assistant carries MQTT through `mqtt/subscribe` and `mqtt.publish` with retain (ha_mqtt_client.dart:9–15, 281, 309–320). The step says the Home Assistant user must be an administrator for `mqtt.publish`; if publishing is refused, the same phone fallback.
- **Zigbee2MQTT page:** neither the Engine (`engineViewProvider` → `needsBroker`, engine_providers.dart:84–86) nor the phone recorder works (the page client sends nothing outside the base topic or retained, z2m_frontend_client.dart:167, 181–187). The step asks for the broker first, through the existing `needsBroker` flow; no fallback and no trial until a broker exists.
Each of the three has its own test.

**Consent code moved first:** `_consent` is private to the Automations screen (automations_screen.dart:90–118: `setEngineDeclined`, then `allowExtensionsAndRestart`, then `_install`); it moves into `history_setup_flow.dart` and both screens call it (about a day with tests). **An earlier "Not now":** a Home with `setEngineDeclined` (automations_screen.dart:120–124) still gets the History-on card once, since History is a different offer; declining there sets the same flag and the card never shows again.

**Consent inside the step:** new Zigbee2MQTT installs block external JavaScript (engine_status.dart:204), so `ensureEngine` returns `needsUser` and today jumps to the Automations screen (engine_setup.dart:37–39). In 3.6 the History-on step shows its own consent text, written for History ("ZigDash Engine runs on your hub so History keeps recording when your phone is off. Zigbee2MQTT restarts once, about 30 seconds."), accepts it in place (the same `consented` call the Automations screen makes), and returns to the finish screen or the card. `engine_setup` `consent_shown` / `consented` / `declined` gain `from: history_on`.

**The reading list:** new code: `configFor` builds only from dashboard tiles (history_service.dart:79–103), so 3.6 adds a devices-based list (temperature, humidity, power, contact; tiles first, then by device order) capped at the recorder's 50; `mergeHistoryReadings` keeps later tile additions. Sized at about a day's work with tests.

**Events:** `history_setup` gains `from` = finish / card / sheet (today only the sheet), so the read can see which entry works. `engine_setup` already carries `from`.

## 3. The Pro trial
**Who:** Play build with `proFlavor == 'play'` and `proLive` (not `proSold`: on ios/prep that is also true for the App Store), not when Pro is already bought.

**When it starts:** the first time a History recorder reports `online` for any Home on this install (the heartbeat, not the tap: a phone recorder that never runs never starts a trial), whatever turned it on. Homes that **already record** on 3.6 (Engine or Node-RED recorder online at first launch) get a one-time card "Try ZigDash Pro free for 14 days" [Start] [Not now] instead, since they're the warmest buyers. **One rule decides which:** if the install saw the recorder `online` before any History-on action of its own (a phone that joins a shared Home, a second phone in the house, an older install), it gets the offer card; the automatic start belongs only to an install whose own History-on action (step, card or sheet) preceded the first heartbeat. Tested both ways. It does **not** wait for Play's answer: `ProBilling` stays `unavailable` until something watches it (pro.dart:64–66), so the start writes `pro_trial_start` at once, and every gate checks the purchase separately. Demo Homes never start it (`isDemoConnection`). Once per install; declining Turn on doesn't block it (it starts whenever History is turned on later). It covers all three ways a Home is added (setup_analytics.dart:103, guided_connect_screen.dart:637, join_home_screen.dart:55) because it hangs on History, not on setup, and not on analytics (people who said no to usage data get the trial too).

**State and time:** its own file, `app_flutter/pro_trial.json` (`start`, `seen_max` = the latest clock time seen), not SharedPreferences (that is one file, `FlutterSharedPreferences.xml`, and backup rules exclude whole files). Running = `seen_max − start < 14 days` and `now ≥ start`: setting the clock back can't extend it; a start in the future ends it. The file is excluded under both `<cloud-backup>` and `<device-transfer>` in `data_extraction_rules.xml`, and in `backup_rules.xml` for Android 11 and older, so a reinstall or new phone starts fresh and "stays on your phone" is true.

**The gate model:** in `pro_trial.dart`:
- `access` = purchased Pro **or** trial running.
- `visible` (show Pro rows at all) = `access || status != unavailable`.
- `locked` (show the "get Pro" note) = `!access && status == locked`.
Applied at every Pro gate: history_sheet.dart:108–114 (ranges, locked, `lockedShown`); wall_display_sheet.dart:62–63 `proOpen`, :130, :160, `_ProNote` :169, :275; wall_display.dart:282, 326, 364, 491; automations_screen.dart:159 and :478. Purchase-only, unchanged: remote_screen.dart:288 and remote_setup.dart (the relay accepts only a purchased token), sale_card.dart:42, pro_screen.dart's buy button, settings_screen.dart:265–270 Pro row (it gains "Trial: N days left").
**Expiry while running:** a timer to the end time invalidates `access`; wall_display.dart reads with `ref.read` at :282/326/364, so the running kiosk re-reads on the timer, and the night schedule and motion wake end at the next screen wake rather than mid-night; at 3 a.m. nothing changes until the screen wakes.

**What the person sees:**
- Start: "Pro is on for 14 days: History for 7 and 30 days, the wall tablet extras, and more than three automations. No payment, nothing renews."
- Settings and the Pro screen: "Trial, N days left".
- Day 12 (if not bought): a card "Your Pro trial ends in 2 days" with what was used (`used` counted only when the History view showed data, a wall extra was on, or a 4th automation was made) and [Keep Pro · price] [Not now]; gone the moment Pro is unlocked.
- End: History shows today again, wall extras off with settings kept, automations made during the trial keep running (the gate is on creation only), new ones past three need Pro. One line on the Pro screen: "Your trial ended. Everything you set up is still there."
- **Promise text:** `proFreeBody` (app_en.arb:1456) "Nothing you use today gets locked" becomes "Nothing that is free today becomes paid" in 13 languages, so the trial's end doesn't contradict it.

## 4. Home Assistant "Open the app" (small, Android only)
Data Nov 9–14: 8 sessions tapped Open the Home Assistant app; 3 ended there, 2 reached `ha_connect ok` (one then hit ZHA), 1 completed. The button exists only on Android (ha_connect_screen.dart:84–92).
- The card says where the address is in the Home Assistant Android app (menu path checked on a real install first), and "copy it, come back, and tap Paste".
- Logging fixed: `open_app` is sent after `openHaApp` answers, with `opened` true/false (today it fires before, ha_connect_screen.dart:114). A flag set only when opened; `returned` once on resume; leaving time saved, and `returned_cold` on a restart within 30 minutes (Android may kill ZigDash while the person is in the other app). A cold return **reopens the Home Assistant address screen** with Paste highlighted, instead of the start of setup (sessions …764539 → …764924 show the restart today).
- On return, the Paste button is highlighted.
- Expected effect, stated: 8 of 56 Home Assistant sessions tapped it; even +2 completions moves the route from ~15% to ~18%. The profit plan's 30% for this route needs more than this; it is re-read with the other Home Assistant numbers in Month 3.

## 5. Measurement
- `history_setup` with `from`; `engine_setup` as today.
- `pro_trial`: `started` (`from`: finish / card / sheet; `hub`: zigbee2mqtt / home_assistant / z2m_page; `week`: the install's first-open ISO week), `used` (`what`: history / wall / automation, once each, only with data), `ending_shown`, `ended`, `kept` (Pro bought while running or within 7 days after).
- Every `pro` event gains `trial` = running / ended / none, so a purchase from Settings on day 20 is still tied to a trial.
**Expected numbers:** ~112 new homes a month × the History-on rate. At the 30% bar that is ~34 trials a month, plus the one-time offer to homes that already record (a few dozen once). So by ~Feb 7 roughly 40–60 trials will have ended, not 200.
**Reads:**
- **History on** (2 weeks after live): offered → tapped → consent shown → consented → recorder online, by `from` and connection type. Bar: ≥ 30% of new homes have a recorder online within a week (today ~0). **If it misses:** the next release works on the step (consent wording, the Zigbee2MQTT-page broker ask), and the trial read waits for 50 ended trials.
- **Trial** (trials started after Nov 30, a guard in case 3.6 ships before the November sale ends; denominator = `started` more than 14 days ago; the read happens once **50 trials have ended**, whatever the date): first look at 50 ended trials: **keep** if ≥ 3 sales (≥ 6%, the profit plan's mid case), otherwise **one** extension to 100 ended trials, then decide on the point estimate: **keep** at ≥ 3% (≥ 3 of 100), **remove** at ≤ 2 of 100. No further extensions. At ~34 trials a month the 50 mark is ~early February and the 100 mark ~mid-March. Split by `from` (new homes, older homes, homes that already recorded).
- The price stays €7.99 until that read closes. **Price step:** if the read closes at 50, the €12.99 step follows a week later (~Feb 10–15, as planned); if it extends to 100, the step moves to ~late March and the profit plan's March checkpoint is restated then.

## 6. Privacy and store
PRIVACY.md: `pro_trial` and `history_setup from` rows; `pro` gains `trial`; `ha_none` gains `opened`, `returned`, `returned_cold`; one sentence in "ZigDash Pro": "The Google Play version offers 14 days of Pro to try, once per install; the trial date stays on your phone and is not backed up." Published on GitHub and GitLab before release. No new Data safety type. Listing: "free" stays out of the title and short description.

## 7. Build and merge
- Files: `lib/features/onboarding/history_on_step.dart` (finish step + card, with the per-connection paths and the in-place consent, reusing the History sheet's install/record-here code moved into `history_setup_flow.dart`), `history_service.dart` (devices-based reading list), `lib/features/pro/pro_trial.dart` (the json file, clock guard), `pro_trial_card.dart` (offer to recording homes, day-12 card), the gates in §3, `data_extraction_rules.xml` and `backup_rules.xml`, ha_connect_screen.dart (§4), analytics_events.dart, strings in 13 languages (Android only for §4), tests: History-on outcomes (ready, needsUser, failed → record here, notBroker home), trial start (from History on, any entry, not demo, not when bought, without Play's answer, without analytics), gate model at every site, expiry timer, clock rollback, backup rule, remote and sale card unaffected, day-12 card gone after buying, HA logging after the result and returned once.
- **Merge order:** 3.6 is built on release/3.5.4 (Android). ios/prep (3.5.3 in Apple review) rewrites pro.dart, pro_screen.dart, settings_screen.dart and wall_display_sheet.dart (`proSold`, `appstore`): after Apple's answer, ios/prep merges main first, then 3.6 merges into ios/prep with the trial gated on `proFlavor == 'play'`, so iOS shows no trial until its own free-purchase trial exists.
- Release notes en-US: "New: turn on History right after setup, and try ZigDash Pro free for 14 days. Home Assistant setup now says where to find your address."

## 8. Size and schedule
One developer, in working days: History-on step with the three paths 3; consent move 1; devices-based reading list 1; trial state, file, clock guard, backup rules 1.5; gate model at every site and the expiry timer 2; offer card and day-12 card 1.5; Settings/Pro screen lines and `proFreeBody` 0.5; Home Assistant change 1; analytics, privacy rows 0.5; 13 languages 1; tests 2; emulator check and release 1. **About 16 days ≈ 3 weeks.** Month 1 (Nov 15 – Dec 15) fits it with a release about **Dec 8** rather than Nov 25; the profit plan's Dec 15 checkpoint becomes "3.6 shipped, first History-on numbers". If it runs late, the Home Assistant change (§4) is the part that moves to 3.6.1.

## 9. Risks
- The Engine install still fails or needs consent for some hubs (Zigbee2MQTT too old, external JS off): for broker and Home Assistant homes the record-on-phone fallback keeps History possible; Zigbee2MQTT-page homes have no fallback until they add a broker. `failed` and `tooOld` are read by `from`.
- Two cards for older homes (History on, then chat early access): one per launch.
- Small numbers: the trial read is a range, not a single bar.
