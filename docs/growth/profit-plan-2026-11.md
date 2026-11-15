# ZigDash: six months to USD 1,000 a month

Version 4.1, 2026-11-14 (independent review: v1 5/10, v2 7/10, v3 8/10, v4 9/10; 4.1 adds the reviewer's last small fixes).
Goal (the user's words): a profitable app, USD 1,000 a month net, within six months (by mid-May 2027).
Sources: Play Console (2026-11-14), the self-hosted Aptabase (2026-11-09 to 14, app 3.4.7+ only, so counts are floors), the code (release/3.5.3), and three research passes on 2026-11-14 (sources at the end).

**Net** in this plan = store payouts after VAT and the store fee (Google 15%, Apple 15% via the Small Business Program), minus the monthly running costs in section 7. Before Israeli income tax.

## 1. Where we are

| Measure | Value | Denominator / source |
|---|---|---|
| Play device acquisitions, 28 days | 524 (+42%) | Play Console |
| Monthly active devices | 399 (+43%) | Play Console |
| **Working home** (the unit used everywhere below) | a device's first home: a setup that completes in a session whose `app_started` says `homes=0` | all 18 completes Nov 9–14 qualify; 14 of them on install day |
| Working homes a month | ~112 | 18 in ~4.8 days, 3.4.7+ only |
| **Working homes per Play acquisition** | **~20%** | ~112 a month / ~560 acquisitions a month. An upper bound: some completes come from F-Droid/GitHub builds or reinstalls, which Play does not count |
| Setup sessions that complete | 11% | 18 / 165 Android sessions with any setup step (a person often has several sessions) |
| Home Assistant route | 15% | 53 sessions opened it, 8 completed; 18 saw "Home Assistant not found" |
| Platform answer "ZHA" | 24% | 28 of 115 platform answers (bar set in the October roadmap: 15%) |
| "No hub" | 52 sessions, 0 completed | the largest single stop |
| Pro sales | 1 since Oct 27 (~0.3–0.5% of homes) | Play Console, ₪27.4 in 28 days |
| Pro seen, 5 days | sale card 3, Pro screen 1, locked rows 2, remote door 4 (all without Pro) | Aptabase |
| Engine | offered 8, started 0 | Aptabase |
| iOS | 3.5.3 and the Pro purchase in Apple review | App Store Connect |

**The math today.** €7.99 nets about $6.20 after ~20% VAT and 15%. USD 1,000 needs about 160 sales a month; we get ~112 working homes and sell to well under 1% of them.

**Why sales are low:** Pro sits where new users are not. Almost nobody reaches a 4th automation or the history limit in the first week, remote needs a Pro purchase before it can even be tried, and the Engine offer converts 0 of 8. Pro was seen about 10 times in 5 days.

## 2. What the research says

**Market.** Home Assistant has about 2.3 million homes (730k opted-in, +36% a year). Opted-in: Zigbee2MQTT add-on 120k (+32%), ZHA 146k (+30%). With the opt-in rate, 350–480 thousand Zigbee2MQTT homes on Home Assistant, plus Docker users. The market is not the limit; being found and finishing setup are. ZHA is the bigger Zigbee group in Home Assistant, and 24% of our own platform answers say ZHA. Germany is Home Assistant's biggest country.

**Channels.** QuickBars reached 10–17 thousand users from a Home Assistant forum thread plus GitHub, no paid spend. r/homeassistant 619k members, forum 27k active a month. Creators: simon42 (281k, German), Everything Smart Home (247k), Smart Home Junkie (89k). Apple Ads utilities CPI ~$2.25.

**Pricing.**
- €7.99 one-time is at the bottom: Home Remote $4.99, Fully Kiosk €8.90 per device, IoT MQTT Panel Pro $12.99 (iOS), Vulpo $59.99 lifetime, Homey self-hosted $149 lifetime.
- Remote access is sold as a yearly service everywhere (Nabu Casa $65, Hubitat $45, Homeway ~$42–72).
- This audience dislikes app subscriptions: SYNC Dashboard dropped its subscription for one-time pricing in July 2026.
- Higher-priced apps convert better (2.8% vs 1.4% of downloads, RevenueCat 2026). Trial uplift figures in the reports are for subscriptions, not one-time unlocks, so they are not used as an anchor here.
- iOS earns ~2.7x more per install. IoT MQTT Panel: Pro installs are ~1.3% of free installs on Android, ~8% on iOS. Their users already run MQTT, so their setup rate is higher than ours; per working home their Android rate is below 9%.
- 17% of new apps reach $1,000 a month within two years.

**Hardware referrals:** $2–50 a month at best, and an F-Droid ads label (Organic Maps precedent). Not a revenue line; a plain discount code is the only version kept.

## 3. The model, as a range

Inputs by May 2027: Play acquisitions 1,500 a month and iOS installs 400, at 28% working homes per install, so ~420 + 112 working homes. **The lever behind 28%** (from ~20%) is the Home Assistant route going from 15% to 30% complete: it gave 8 of the 18 completes, so doubling it adds ~40%; it has its own 60-day read (Month 3). The no-hub reminder is not counted on within six months.

With ZHA support (24% of platform answers, assumed to finish like the others): +30% homes, ~126 + 34 more. **ZHA homes convert at half the rate:** remote rides the home's MQTT broker (remote_setup.dart:47) and the Engine is a Zigbee2MQTT extension, so ZHA homes get History (from Home Assistant's API, in the ZHA plan's scope) and the wall-tablet extras, not remote or Engine automations. Pro at €12.99 / $12.99 for new buyers (~$10.10 / $10.50 net).

| Pro buys within 30 days | Without ZHA | With ZHA |
|---|---|---|
| Low: 3% Android, 5% iOS | $186 | $214 |
| Mid: 6% Android, 10% iOS | $373 | $428 |
| High: 12% Android, 20% iOS | $744 | $856 |

("With ZHA" = the Zigbee2MQTT homes at the row's rates plus the ZHA homes at half those rates.)

Plus (section 5): $0–20 in May. It is a beta from Month 5 at the earliest, with a 14-day trial and free months for Pro buyers; 2% of ~600 new homes is ~12 subscribers × $1.70 = ~$20 at most. Sponsors and tips ~$30. Running costs (section 7) ~$15 a month.

**Honest read.** Cash is planned on the mid case: about **$390–465 a month net by May** (without / with ZHA) (Pro + Plus $0–20 + tips $30 − costs $15). The best modelled case is ~$890 ($856 + $20 + $30 − $15). **No modelled case reaches $1,000 by May**; it would need installs or conversion beyond the high case. $1,000 is a month-9-to-12 target, reached by the same levers compounding (the installed base keeps buying, Plus grows). The checkpoints below follow the mid case, with the high case shown.

## 4. Six months

Checkpoints, net USD a month (mid / high, both with ZHA): Jan 15 $40 / $80, Mar 15 $150 / $350, May 15 $465 / $890. Every rate is read over 60 days with the denominator named; at this volume a 30-day rate moves several points by chance.

### Now (this week): unblock (the user's)
- Play Console: declare trader status (EU, deadline 2027-02-01; otherwise removal from EU stores) and fix "Action required with your payments account".
- App Store Connect: confirm the Small Business Program (15%), or Apple takes 30%.
- Fill the cost table (section 7).
- **May gap, decided 2026-11-14 (the user agreed):** no modelled case reaches $1,000 by May (mid ~$465, high ~$890). The goal stays $1,000 a month, now targeted at month 9–12 (Aug–Nov 2027); the plan keeps its order and its clean reads, and no lever is pulled forward.
- Ship Android 3.5.3.

### Month 1 (Nov 15 – Dec 15): Pro trial, Home Assistant fix
1. **Pro trial (3.6), led by History** (20 History uses in 5 days, the Pro feature people already reach). A home that finishes setup gets 14 days of history (7 and 30 days), the wall-tablet extras and unlimited automation creation. Built as a separate `trialProvider`, checked only by the History range, the wall-tablet extras and the automation-creation gate (automations_screen.dart:159). `proStatusProvider` (lib/features/pro/pro.dart) stays purchase-only, so the remote screen (remote_screen.dart:288) never shows remote as owned and the sale card (sale_card.dart:42) keeps showing during a trial. **At trial end:** History goes back to today; wall-tablet extras turn off with their settings kept; automations made during the trial keep running (the gate is on creation only), so nothing the person built breaks. **Remote is not in the trial:** the relay accepts only a purchased Play token (relay/verifier/server.mjs:129–139), and trial credentials for the relay would be new abuse-prone work. With no accounts, a reinstall restarts the trial; accepted. Day 12: a card lists what the person used and offers to keep it. iOS: Apple allows a time-limited trial in a non-subscription app only as a free (Tier 0) non-consumable purchase named for the trial (Guideline 3.1.1), so iOS gets the trial in the first iOS update after approval, with its own review. F-Droid: already fully unlocked, no change. Event `pro_trial` (started, used, ended, kept) with the home's platform (`hub`: zigbee2mqtt / home_assistant, later zha), so every read can be split by platform.
2. **Home Assistant fix:** 15% of Home Assistant setups finish; 18 of 53 hit "not found". Fix that step only. Target 30% (the lever behind the 28% per install).
3. **Price:** the November offer ends Nov 30; then €7.99 holds through the whole trial read.

Month 1 is only these three plus shipping 3.5.3, sized for one developer.

Checkpoint Dec 15: trial shipped, trial starts counted.

### Month 2 (Dec 15 – Jan 15): no-hub path, Pro at the moment of need, ZHA starts
1. **No-hub path:** 52 no-hub sessions, 0 completed. The no-hub answer leads to the demo, a "remind me when my hub arrives" reminder (the existing reminder), the hub guide, and an SMLIGHT discount code if they give one (no commission, no tracking). Measure reminder set, and reminder-to-completion.
2. **Pro at the moment of need:** opening History beyond today, setting up a wall tablet, a 4th automation.
3. **ZHA through Home Assistant, plan and start.** 24% of platform answers is above the October roadmap's own 15% bar, so ZHA is built now, not gated on sales. ZigDash already signs in to Home Assistant; ZHA devices come from Home Assistant's API. Its own plan is scored to 9 first; it is the largest piece of work in the six months.
4. **First, small post:** moved to Nov 2026 by the [traffic plan](traffic-plan-2026-11.md): a reply in ZigDash's own Home Assistant forum thread (one thread per project) and "now on iPhone" if Apple has approved. The big push waits for ZHA (Month 4).
5. **Ratings:** review prompt after a happy moment (first scene run); moved to 3.6.1 by the traffic plan.

### Month 3 (Jan 15 – Feb 15): read the trial, then price

**Updated 2026-11-14 by [3.6's plan](../design/pro-trial-360.md):** 3.6 turns History on first and starts the trial when History records (Pro's features need a recorder; nobody set one up Nov 9–14). The trial read happens at 50 ended trials (one extension to 100), not on a date; every date below assumes History-on reaches 30% of new homes, and if it doesn't, the read and the price step wait. 3.6 ships ~Dec 8.
1. ZHA continues.
2. **Home Assistant read:** route completes over sessions that opened it, 60 days after the fix ships. Below 30%: the per-install rate is rescaled as 20% × (1 + 0.44 × (route rate ÷ 15% − 1)), e.g. 20% → 23%, and the model's homes and checkpoints restated.
3. **Trial read** closes 60 days after the first trials end (3.6 ships ~Nov 25, first trials end ~Dec 9, read ~Feb 7; ~200 trials ended): keep the trial if it produced ≥ 6 sales (3%); otherwise remove it and put Pro behind a clear price on the wall-tablet setup instead.
4. **Price for new buyers €12.99 / $12.99, the week after the read closes (~Feb 10)**, once. Revert to €9.99 if the next 60 days bring less **net revenue per trial ended, counted on Zigbee2MQTT and Home Assistant homes only** than the €7.99 period. ZHA homes (from Month 4) and the big push land inside that window; splitting by `hub` keeps ZHA homes out of the comparison. The push also brings Zigbee2MQTT and Home Assistant homes with different intent, so the comparison counts only homes installed before Feb 15 (`pro_trial` also carries the install's first-open week); later homes are read separately (sales can fall ~38% at €12.99 and still bring the same money). Any later sale shows the lowest price of the previous 30 days (EU Omnibus Directive 2019/2161).

### Month 4 (Feb 15 – Mar 15): ZHA ships, the big push
1. ZHA release.
2. **The big push, timed with ZHA:** r/homeassistant post, German forum post and a pitch to simon42 (Germany is Home Assistant's biggest country), then Everything Smart Home and Smart Home Junkie. "Now works with ZHA" opens it to the bigger Zigbee group.
3. **Plus plan written and scored**, launched only if the gates in section 5 are met.

### Month 5 (Mar 15 – Apr 15): Plus beta and organic channels
- **No paid ads in these six months.** A working home costs ~$11 in ads (CPI $2.25 ÷ ~20%), and earns $0.60 (mid) to $1.20 (high) in Pro. Paid ads only make sense if revenue per working home rises more than tenfold.
- Plus beta, if gated in (section 5).
- Organic: a second forum post with what ZHA users say, creator follow-ups, ratings.

### Month 6 (Apr 15 – May 15): scale or cut
Double what moved revenue, drop what did not. One cheap B2B test: a page for installers and rental hosts offering a volume licence for wall tablets; build only with 5 real enquiries.

## 5. ZigDash Plus (a later, gated decision)

**What changed since the October roadmap**, which said no subscription before February and "decide remote at 20 Pro homes": the chat assistant (POC, Nov 12) costs money on every message, which a one-time payment cannot carry. That is the only reason for Plus; remote's question is unchanged.

- **What it is:** a subscription inside ZigDash (not a separate app), sold next to Pro: the Telegram chat assistant (WhatsApp later, after Meta business verification). €2.49 a month or €19.99 a year, 14-day trial. Message cap per month (fair use) set from measured API cost so each subscriber is net positive.
- **What it is not:** alerts. The Pro screen says alerts stay free (app_en.arb:1456); on-device alert rules stay free. Remote stays in Pro (option A, recommended), as the Pro screen promises "no monthly fee" (arb:1673). Option B (remote into Plus) only via `proRemoteFair` (arb:1674, "may change or end with notice"), with every earlier Pro buyer keeping it.
- **Promise text first:** before Plus exists, the Pro screen says what Pro is and names Plus as a separate hosted service with a running cost. Rewording does not change what earlier buyers read (arb:1454 "every Pro feature that comes later, at no extra cost"), so **everyone who bought Pro before the new wording gets Plus free**, within the same fair-use cap. Today that is a handful of people; the cost is small and the promise is kept. Later Pro buyers get the first 3 months free.
- **Gates:** launch only when the assistant has 10 beta users from the Telegram community using it weekly, and the cost per active user is measured.
- **Plumbing to scope:** Telegram chat linked to a home by a one-time code shown in the app, held by the relay, which verifies the Play/App Store subscription token (like Pro today). For earlier Pro buyers, the relay also accepts a `zigdash_pro` token with a purchase time before the wording change as a Plus entitlement (relay/verifier/server.mjs already verifies Pro tokens). The 3 free months for later Pro buyers are a Play subscription offer with developer-determined eligibility (the app offers it only when Pro is owned) and, on iOS, an Apple promotional offer, which needs a server-signed signature (the relay signs it). F-Droid: no Plus at launch (no Play Billing); a web payment option only if F-Droid users ask.
- **Law and stores:** Play and Apple handle cancellation; German renewal rules (§309 Nr. 9 BGB) for the yearly plan to be confirmed before launch.

## 6. Not doing
- Ads, and affiliate links in the app.
- Turning Pro into a subscription.
- Paid ads (section 4, Month 5), Product Hunt, Reddit ads (not available for Israel-billed accounts).

## 7. Costs (defines "net")

Estimates; the user confirms the real figures this week and the plan is updated.

| Item | Cost a month (estimate) |
|---|---|
| Apple Developer ($99 a year) | $8 |
| VPS (relay on grocery-vps, which already runs for the grocery project; ZigDash's marginal cost) | ~$0–5 |
| Claude API (support Worker, capped at 10 an hour; low use) | ~$1–5 |
| Domains (zigdash.app ~$15–20 a year) | ~$2 |
| Cloudflare (Workers free tier, tunnel), Aptabase on the Pi | $0 |
| **Total** | **~$11–20, planned as $15** |

The chat assistant's API cost is not in this table: Plus pays for it by design, with a message cap set from measured cost per user.

## 8. Risks
- **Small numbers:** 60-day windows, named denominators, and single go/no-go rules instead of percentage targets that noise can cross.
- **ZHA is big for one developer** and pushes everything after it; if its plan does not score 9, ZHA is dropped from the six months, the big push in Month 4 goes ahead without it, and the "with ZHA" column is off (mid case ~$400).
- **Price rise** may cut sales; the revert rule covers it.
- **Trial abuse** by reinstalling: accepted, as the features involved cost nothing to run.
- **iOS** rejection or a slow trial review delays a fifth of the homes and more of the revenue.

## Sources
- Home Assistant analytics: https://analytics.home-assistant.io (data.json, current_data.json, addons.json, 2026-11-13); Open Home Foundation: https://www.openhomefoundation.org/media-room/annual-report-factsheet/
- RevenueCat State of Subscription Apps 2025 and 2026; Adapty State of In-App Subscriptions 2026 and State of Paywalls
- Comparables: thehomeremote.com/pricing, fully-kiosk.com, apps.apple.com/app/id6466779963, appgoblin.info, sharptools.io/pricing, nabucasa.com/pricing, community.hubitat.com, blog.homeway.io, homey.app, apps.apple.com/us/app/vulpo-for-home-assistant/id6758255800, community.home-assistant.io (SYNC Dashboard thread)
- Channels: github.com/Trooped/About-QuickBars, community.home-assistant.io/about.json, thehiveindex.com (r/homeassistant), apptweak.com Apple Ads benchmarks
- Referrals: smlight.tech/partnership/for-creators, sonoff.tech/pages/affiliate, Amazon Associates fee schedules, organicmaps.app/news/2025-05-20
- Apple App Review Guideline 3.1.1 (free trial as a Tier 0 non-consumable); EU Directive 2019/2161 (price reductions)
