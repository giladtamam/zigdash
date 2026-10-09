# Play Console review, 2026-10-06

All of Play Console was read for Sep 8 to Oct 5 (28 days). Production was 1.9.x for most of the window and 1.13.0 from Oct 4. Play has no in-app usage data; that comes from the opt-in analytics in 2.0.

## Funnel (last 28 days)

| Step | Number | Change |
|---|---|---|
| Device impressions on Play | 3,000 | +353% |
| Store listing visitors | 389 | +332% |
| Device acquisitions | 211 | +331% |
| Device first opens | 98 | +345% |
| Monthly active devices | 135 | +350% |
| Device loss (uninstalled, or inactive for 30 days) | 120 | |
| Installed audience | ~32 → 117 | |

- **Discovery is Play itself.** Grow overview: "+165 explore user acquisitions in the last 90 days". Impressions peaked around Sep 17–18 at about 270 a day. The Sep 18 and Sep 22 install spikes were Play's Explore, not outreach, which started Oct 4.
- **The listing converts well.** 42% (default listing) to 57% (Grow overview) of visitors install. Click-through stayed flat while traffic rose about 330%.
- **The leak is after install.** Fewer than half of acquisitions ever open the app (98 of 211). Device loss is 57% of acquisitions. Losses rose with the Explore spike (8, 4, 9, 10, 6, 9 a day from Sep 16 to 21): browsers install, find they need a Zigbee2MQTT setup, and leave. The installed audience still grows, by about 91 net devices a month.

## Who

- **Form factor (Oct 2):** phone 85%, tablet 6% (7 devices), unreported 9%.
- **Language (Oct 2):** English (US) 18%, Russian 8.5%, German 7.7%, then French, Polish, Hebrew, Portuguese (Brazil), Spanish and a long tail. **Russian is the second language and has no translation.** Polish and Portuguese have none either.
- **Android:** the peer group is mostly Android 16. ZigDash's own split is "Data unavailable" (too few devices).

## Quality

- **Crashes and ANRs:** none in 28 days.
- **Rating:** 4.75 from 4 ratings. All 4 written reviews are 5 stars (Aug 19, Aug 17, Aug 16, Jun 10). They praise "just works" with Hue through Zigbee2MQTT, smart shutters, and quick setup.
- **Requests in reviews:** back up, export and import the dashboard as a **.json file** (today it is copy and paste only); Spanish (shipped since).
- **No new ratings in 28 days.** Expected: the in-app review prompt (commit 84f6efb, Sep 22) only recently reached production, and it waits for 4 distinct days with a confirmed command, at least 3 days apart. Check again in late October.
- **Pre-launch report:** never generated, because nothing has been uploaded to a testing track.

## Store setup issues

- **Broken custom listing.** "Store listing 1" (Aug 9, live, 50% rollout) targets one search keyword that is a whole phrase: "Zigbee MQTT homeassistant smart home smhub nano24 sonoff". No one searches that string, so it has had 0 visitors. Split it into separate keywords (zigbee2mqtt, zigbee, mqtt dashboard, home assistant, smlight, sonoff zigbee).

## What to improve, in order

1. **Activation of Explore installs.** This is the biggest number to move. Say "Needs Zigbee2MQTT and an MQTT broker" in the short description and the first screenshot, so people without one don't install and uninstall. Make the demo reachable for those who do install. 2.0's `setup_step` events will show exactly where people stop.
2. **Russian translation**, then Polish and Portuguese (Brazil). Russian is the second-largest language with none.
3. **Back up and restore as a .json file** (Android share sheet and file picker), the only open review request.
4. **Fix the custom listing keywords** at the 2.0 listing update.
5. **Ship 2.0 through internal or closed testing first** to get a free pre-launch report (crashes, accessibility and security on real devices), then promote to production.
6. **Re-read in four weeks:** device loss as a share of acquisitions, first opens as a share of acquisitions, ratings after the prompt, and 2.0 setup analytics.
