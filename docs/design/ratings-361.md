# 3.6.1: ask for a rating where people actually are (v2, scored 9/10)

v2 after review (v1 scored 7/10): the report path keeps its sensor-only rule (v1 would have asked on
opening the dashboard), History asks when the sheet closes, the read counts total asks to Jan 15, the
event drops `nth`, and the race test is added.

Step 2 of the [traffic plan](../growth/traffic-plan-2026-11.md): the broad Play searches ("zigbee" #8,
"zigbee app" #10) are held by apps with thousands of ratings; ZigDash has **10 ratings** (4.9) since
August. Bar there: 25 ratings by Jan 15.

## What the data says (self-hosted analytics, Nov 9–15, Play robots excluded)

| | |
|---|---|
| `review_prompt` requested | **4** in ~6 days (3.4.7: 2, 3.5.1: 1, 3.5.2: 1) |
| App starts with a home (`homes=1`) | 132 in 7 days (~19 a day) |
| Sessions with a device control (`feature_used control`) | 57 |
| Sessions that opened History | 20 |
| Scenes run (`scene_run`) | **1**; automations saved: 0 |

The profit plan's "after the first scene run" would almost never fire. Returning users mostly open the
dashboard, look, maybe switch one thing, and leave.

## Why so few asks today (lib/core/review/)

The policy (2 calendar days since the first successful day, 2 counted days, 90-day cooldown, never in the
10 minutes after setup) is fine. What starves it is the trigger: `ReviewPromptTrigger` asks only on the
**3rd confirmed command within one dashboard visit** (`kReviewNthCommand = 3`, 3.4.8). A passive device
report may ask only on installs that never sent a command, after 7 counted days. A visit with one or two
commands, or none, never asks.

## The change (3.6.1)

1. **Command path: the 1st confirmed command of a visit, not the 3rd.** The policy already demands two
   different days of working use and two days of age, which is what "one lucky tap is not enough" was
   guarding. Still waits `kReviewDelay` (1.5 s) so the tile's own confirmation is seen, still only if the
   dashboard is still on screen.
2. **Sensor-only homes sooner.** The passive-report path keeps its rule that only installs that never
   sent a command may ask (the first device report fires on every dashboard visit, so dropping the rule
   would ask on opening the app, before anything happened). `reportMinSessions` 7 → 4 for those homes.
3. **History, when the person is done with it.** If during a visit the History sheet showed a 7- or 30-day
   chart with at least two days of points (so not locked: Pro, the trial, or F-Droid/GitHub builds),
   `maybeRequest(trigger: history)` runs when the sheet closes, after the same 1.5 s delay and only if the
   screen underneath (a dashboard, the Devices tab, a device page) is still the one showing. Never while
   the chart is being read.
4. **Nothing else changes:** policy numbers, setup window, 90-day cooldown, the Settings "Rate ZigDash"
   row, and the automatic path never opening the store listing.

Google decides whether the dialog actually shows (its own quota) and says nothing back, so every request
uses our 90-day cooldown. Asking at the first good moment instead of a rare one is the whole change.

**Event and policy:** `review_prompt` gains trigger `history` and loses `nth` (it would always be 1). The
PRIVACY.md row is rewritten to name the three moments: a device you control answers (from the second
day of use), a sensor-only home after four days, closing History after a week or month chart. Effective
3.6.1. Less data than before, none new.

**iPhone:** the same controller drives the App Store prompt, which Apple shows at most three times a
year; the 90-day cooldown stays under that.

## Tests
- Trigger: asks on the 1st confirmed command; not when unmounted before the delay; one ask per visit.
- Race: a report and a command within the same 1.5 s give exactly one request (`_requesting`).
- Controller: a report asks after 4 counted days on a sensor-only install, not at 3, and never on an
  install that has sent a command.
- History sheet: asks on close after a 7- or 30-day chart with ≥2 days of points; not with today only;
  not when locked (no Pro, no trial); not if the dashboard is gone; never while the sheet is open.
- Existing policy tests unchanged.

## Read
- **Total `review_prompt` requests from 3.6.1 to Jan 15** by trigger (a floor: only devices that share
  usage data send the event), not a weekly rate: devices that
  already pass the policy are all asked in the first week, then each waits 90 days, so week one is a
  one-off burst. With the 90-day cooldown, each request is one device.
- Rough check on the bar: ~15 new ratings at Google's unknown show rate and a typical rating rate means
  on the order of 100–200 devices asked. The 1st-command change is what can reach that; if the total by
  Dec 15 is under 50, the bar is out of reach and the read says so rather than loosening the policy.
- Ratings in Console each Monday with the rank run. **Bar: 25 ratings by Jan 15** (traffic plan).
- Average rating stays ≥ 4.5; a drop means we ask people who are not happy (then back to the 3rd command).

## Order
Listing approved Nov 15, nothing in review, so 3.6.1 can go to review once built and tested on the
emulator. Release notes: one line ("ZigDash may ask for a rating at a better moment"), or none.
