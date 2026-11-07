# Remote where people can see it, and a November sale (plan v3, 2026-11-06)

Status: stage 1 built and tested on `feat/remote-door` (from `release/3.4.3`), not released. Reviewed three times by an independent agent: 6, 7.5, then 9 of 10. The user chose the door first, the Play discount offer, and 3.4.4 (2026-11-06).

The idea as asked: a **Remote** tab in the bottom bar; a free user who taps it is asked to join Pro; a Pro user sees the network information and the remote settings. Plus Pro at **40% off the original price** in November.

**What changed since the first draft.** A first draft built the tab at once and was scored 6 of 10 by an independent review. Three findings decided it: the sale and the tab would have been measured on top of each other; a fifth tab does not fit the bar without renaming two of today's four tabs; and a button in the dashboard's top bar gives the same always-on-screen visibility for a tenth of the cost. So the same page ships first behind that button. The tab is stage 2, built only if stage 1's numbers say visibility is still the obstacle.

## The problem

Remote control is the first line of the Pro screen and almost nobody finds it. 30 days to 2026-11-06 (usage data: sessions, not people; all devices, so upper bounds: the roadmap found Play's review device behind 15 of 40 Pro events):

| | Count |
|---|---|
| App starts with a real home | 449 |
| `remote` events, all kinds | 9 |
| Remote offer card: shown → "Show me" → turned on | 5 → 1 → 0 |
| Pro screen opened | 21 |
| "Get Pro" tapped → bought | 6 → 1 |
| ZigDash Engine (remote needs it): offered → installed | 28 → 4 |

Remote has two doors today: a row in Settings › Home, and a card shown once, after five days, only at home.

Why now, when the roadmap gives November to setup and December to the first week: this is about three days, the hub guide is not delayed by it (it waits on a text check), and the page's first step is the Engine install, which is December's own metric (offered → installed, 13% → 50%).

## Stage 1 (3.4.4): the page, a door to it, the sale, and a bug

### A bug to fix first

A home carried by Home Assistant or by Zigbee2MQTT's page (`notBroker`) can be sold remote and told it is on, and it can never work: `RemoteSetup.setUp` only refuses the relay endpoint (`remote_setup.dart:73`), while `endpointCandidates` never uses the relay for such a home (`endpoint.dart:47`). Nothing guards it: not the Remote screen, not the Settings row, not the offer card, and the Pro screen lists remote first for everyone.

Fix, one rule `remoteFitsProvider(homeId)` (real home, own broker, not demo) used everywhere:

- Remote screen for a home that doesn't fit: no "Turn on", one plain paragraph. Two texts: for Home Assistant ("This home is reached through Home Assistant. Away from home it works when your Home Assistant address does.") and for Zigbee2MQTT's page ("This home is reached through Zigbee2MQTT's own page. Remote control needs a home connected to its broker.").
- **Turn off stays wherever a relay login is stored**, fit or not. It is the only thing that removes the relay registration and the hub's link (`remote_setup.dart:150-160`), so a home that got in through the hole can get out.
- Settings › Home: the Remote row is hidden for a home that doesn't fit and has no stored login.
- Adding a phone by code (`pair_phone_screen.dart:46-53`) lists every home today and adopts the login unchecked: the list is filtered by the same rule.
- Pro screen: the remote line shows only when the phone has no home yet or at least one home that fits.

### The page

The existing `RemoteScreen` at `/settings/home/:id/remote`, with two parts added on top. Nothing is disabled or greyed for anyone.

**1. How this phone reaches home now** (everyone): "At home" with the broker's address, "Your own remote address", "Away via ZigDash" or "Not connected"; Zigbee2MQTT's version; whether ZigDash Engine is on the hub. All from providers that exist: `connectionStatusProvider`, `activeEndpoint`, and `engineViewProvider`, whose hub info already carries Zigbee2MQTT's version (no extra request).

**2. Two ways to reach home from away** (everyone):

- *Your own address* (free, exists): Tailscale, a VPN or a forwarded port. Shows whether one is set; opens the home's connection form.
- *ZigDash remote control* (Pro): the relay. No VPN, nothing to open on the router.

The free way sits beside the paid one on purpose: the listing says "no ads", and nothing free moves behind Pro.

**3. Remote control**, by state. Every row is shown before anything is tapped:

| State | Shown |
|---|---|
| Not connected, no Pro | Often someone away and cut off, the moment remote is wanted most. What remote is; the three steps; "See Pro · {price}"; "Turn it on when you're home." Step 1 uses the one thing the phone keeps about the Engine, a yes/no "seen installed" (`engine_providers.dart:189-208`): yes shows "installed, last seen"; no shows the neutral "Checked when you're home", never "install it" or "too old", since no can also mean never looked. |
| Not connected, Pro | The same steps without the price; "Turn it on when you're home." |
| No Pro | Three steps with their real state: **1** ZigDash Engine on the hub (free: installed / install it / "this hub's Zigbee2MQTT is too old for it"), **2** Pro, **3** turn on at home. Button "See Pro · {price}" opens the Pro screen (the 2.9.6 rule: nobody meets Play's sheet before seeing what Pro adds and what stays free). |
| Pro, no Engine | Step 1 leads to Automations (exists) |
| Pro, Engine, away | "Turn this on at home", shown up front. Today it appears only as an error after the tap. `atHomeProvider` moves from the offer card's file to `remote_setup.dart` for this. |
| Pro, Engine, at home | "Turn on remote control", restore from a key backup (exists) |
| On | Hub connected or not, "through the relay now", phones, add a phone, key backup, Home ID, turn off (exists) |

The steps come before the price so a person knows their hub can run remote **before** paying. The Engine is the narrow point (28 → 4) and it is free.

### The door

An icon button in the top bar of the Dashboards tab, the screen every app start lands on: a globe, tooltip "Remote control". First of the actions: left of Edit where there is one, and first before Settings and the menu in the empty home's bar (`dashboards_screen.dart:86-91`). Plain while remote is off, in the accent colour while it is on (the tooltip says which). It pushes the page; no tab index, no redirect. Devices, Scenes and Automations do not get it: one place, not four.

Shown when `remoteFitsProvider` holds and remote is sold here (`remoteSoldProvider`: Play build, Pro buyable or owned). Hidden in the GitHub build, in a kiosk, on a demo home, and where Pro can't be bought. Play answers a moment after start (`ProBilling.build` returns `unavailable` first), so the last known answer is kept in preferences and the button does not pop in on every start.

**Removed:** `RemoteOfferCard`, its two stored keys, three strings and tests. `remoteSoldProvider` and `atHomeProvider` move to `remote_setup.dart`; `poll_card.dart` stops waiting for the offer. A door that is always there replaces a card shown five times a month.

### The sale

Facts:

- `zigdash_pro` is on Play's new one-time product model: one purchase option (`buy`, backwards compatible, 174 countries, active), no offers, and an **Add offer** control beside it (seen in Play Console on 2026-11-06). A discount offer is percent off, per country, with a start and an end that Play enforces.
- The product's description in Play, which Play's purchase sheet shows, still lists only history and the wall tablet. It should name remote control and automations before a door leads people there to buy for remote. The user's text to approve.
- `ProBilling.kt` (Billing Library 8.0.0) asks for the single backward-compatible offer (`:97`) and starts the purchase with no offer token (`:156-161`). Play's page says the singular getter returns the backward-compatible option and that the token must be set to buy an offer. That a live version therefore charges the full price while an offer runs is an inference, not a quoted rule. Either way is safe: a live version shows €7.99 and Play's own sheet shows what is charged.

Two routes:

| | A. Lower the base price by hand | B. Play discount offer (chosen) |
|---|---|---|
| Code | none | about a day in `ProBilling.kt` and the Pro screen |
| "Was €7.99, 40% off, until 30 Nov" in the app | not truthfully: a computed old price and hard-coded dates, wrong the day the price is changed back early or late | from Play, per currency: full price, percent, end time |
| Ends | when someone remembers | by itself |

Build for B:

- `getOneTimePurchaseOfferDetailsList()`; take the offer that has `discountDisplayInfo` and whose `validTimeWindow` holds now, else the base option.
- The channel returns price, full price, percent, end time **and the offer's token**. The Pro screen and the page's Pro step show one line, "November sale: 40% off until 30 November", the old price struck through, the new one on the button. No countdown, no pop-up, no notification.
- **The purchase is started with the token that was shown.** Today `buy` asks Play for the product again before launching (`ProBilling.kt:148`); with "the offer, else the base option" a tap just after the end would launch the full price under a screen still showing the sale. So `buy` takes what was shown, the offer's ID and its price, and launches with the fresh token of the offer that matches both (Play is not known to return the same token string twice). When no offer matches (or Play answers `ITEM_UNAVAILABLE`) it launches nothing and returns "changed". The screen then asks the price again, drops the sale line and says "The sale has ended." The person taps again at the price now shown. Never a higher charge than the screen's.
- The price is kept for the whole process today (`pro.dart:107`). It is asked again when the app comes back to the front and when the Pro screen or the page opens, and the sale line is not drawn once the end time has passed.
- Announced in the app, in the Play release notes and on Telegram as "in the latest version". People on an older version get the update from the dashboard's update banner (`lib/core/update/`).

Before the offer starts: one purchase through it with a licence-test account, on a build with usage data off, then "Turn on remote control" with it. The relay's verifier matches the product ID (`relay/verifier/server.mjs:131-139`), so an offer purchase should pass; this proves it.

**Dates:** from the day 3.4.4 is live until Monday 30 November 23:59. Pro has only ever cost €7.99 since it went on sale in mid-October, so the "was" price is true. The EU's 30-day prior-price rule is written for goods; a later start is not needed for it. Not legal advice.

**No verdict from the sale.** One sale a month is the baseline, and the sale is seen only on the Pro screen and the page. It is a revenue event: the count of orders is written down for February's pricing decision, and nothing is concluded from it. Base price stays €7.99; no second sale before February. One person paid full price on 27 October; nothing is owed.

### Measured

The analytics service gives one list per property and cannot cross two, and `step` is itself a property. So every number the read needs is one value of one property:

- `remote` gains step `opened`, once per app start and home, with one composed property `open` = `from/state`: from `door` or `settings`; state `no_pro`, `no_pro_offline`, `no_engine`, `away`, `ready`, `on`, `pro_offline`, `unfit`, `not_sold`. Opens from the door without Pro = `door/no_pro` + `door/no_pro_offline`.
- `remote` gains step `see_pro`, once per app start, with `went` = `door` or `settings`: the person tapped "See Pro" on the page. "Went on" = `went=door`.
- `pro` gains `from` (`remote_door`, `remote_settings`, `settings`, `history`, `automations`, `wall`), `path` = `from/step` (`remote_door/unlock_tapped`), and, on a tap on the price and on the unlock that follows, `sale` = `yes`/`no`.
- Purchases are counted from Play Console's orders, which is the truth; a pending payment never sends `unlocked` (`pro.dart:62-69`). The events only say where a buyer came from.
- Play's review device cannot reach these numbers: it has no real home, the door is hidden on a demo home, so it never sends `door/…` or `went=door`. The read does not depend on filtering it out. The developer's own remote home is subtracted by hand.
- Kinds only (ADR 0006). One sentence in `store/PRIVACY.md`, pushed to both hosts before the release.

### The read: 1 to 21 December, full price

The sale ends on 30 November, so these three weeks are the door alone, after its novelty.

- **Opens:** `open` = `door/no_pro` + `door/no_pro_offline`. Per app start, as app starts with a home are.
- **Went on:** `went` = `door`. Also per app start, so one person can't supply it three times in a sitting.
- **Outcome:** orders in Play Console, `turned_on`, `remote_door/unlock_tapped`.

Honest size: at one sale a month, one or two more purchases in the window would already be a doubling. The money is small. What it buys is knowing, before February, whether remote sells when it can be seen.

| What the three weeks show | Then |
|---|---|
| Fewer than 15 opens, and at least 3 went on (so one in five or better) | The door is on screen at every start, so it was seen and not read: a globe without a word does not say "remote". Those who did open it wanted it. **Build the tab** (stage 2): a word in the bar is the stronger test. |
| 15 opens or more, and at least 3 went on | The door works. Keep it; no tab. |
| Fewer than 3 went on, however many opened | The page does not make people want remote; a louder door will not change that. No tab. The next work is the page's step 1, the Engine, which is December's theme anyway. |

Counts this small are a coarse signal, and the table is read as that.

### Work, stage 1

| Part | Size |
|---|---|
| Sale: billing, Pro screen, the ended-offer case, licence-test purchase | 1 day |
| `remoteFitsProvider` and the three guards | 0.5 day |
| Page: facts, two ways, steps up front; the door; card removed | 1 day |
| About 12 strings in 13 languages; events; policy sentence; tests; emulator screenshots | 1 day |

About three and a half days: in review by 11 November, so the sale has close to three weeks.

Tests: a home that doesn't fit gets no "Turn on", no row, no door, no place in the pair list and no remote line on the Pro screen, and keeps Turn off while a login is stored; each page state, away and offline shown before a tap; the door shown and hidden per rule, in the empty home's bar, and stable across a cold start; the offer picked and matched by ID and price at purchase, an offer that is gone launches nothing, the price asked again on resume, no offer; `open`, `went`, `from`, `path` and `sale` on the events, each once per app start where the plan says so.

## Stage 2: the tab (only if the read says so)

Kept here so it can be built without new decisions.

**What it costs.** Five destinations is Material's maximum: this spends the last slot. And the labels do not fit. Widths at the bar's style (Roboto Medium 12 sp, 0.5 spacing), all 13 languages measured. A 360 dp phone gives each of five tabs 72 dp. The bar scales labels up to 1.3× with the system font size (`_kMaxLabelTextScaleFactor`), so a label must be under **55 dp** to hold at large font. The framework does not shorten a label; it wraps it, mid-word if needed.

| | |
|---|---|
| "Automations" over 72 dp | 12 of 13 languages, English included (74) |
| Over 55 dp | also "Dashboards" in most languages (en 69) and "Devices" in several (ru 70, es and pt 72) |
| Already wrapping today at four tabs | es 105, nl 104, fr 96, ru 96, fr "Tableaux de bord" 100; and most languages at large font |

So the tab means bar-only short words for Dashboards and Automations in most languages (the page titles stay), with a permanent test that measures every bar label in every language at 1.3×. The rail keeps today's words; it has the room. Candidates, measured, all under 55 dp:

| Label | Words (dp) |
|---|---|
| The tab | Remote 45 (en, de), Distance 51 (fr), Remoto 45 (es, it, pt), Afstand 46 (nl), Zdalnie 43 (pl), Dálkově 46 (cs), Fjärr 27 (sv), Fjern 29 (nb), Извне 37 (ru), מרחוק 36 (he) |
| Automations | Rules 32, Regeln 40, Règles 39, Reglas 39, Regole 40, Regras 40, Regels 39, Reguły 40, Pravidla 47, Regler 37, Правила 52, כללים 33 |
| Dashboards | Boards 41 (en, de, nl, sv), Tableaux 52 (fr), Pannelli 47 (it), Panele 40 (pl), Панели 45 (ru); es, pt, cs, he fit as they are; nb is 1 dp over and gets "Paneler" 44 |

"Devices" has no natural shorter word in six languages (ru 70, es and pt 72, pl 65, it 61, nl 60). They fit at normal font size and wrap only at the largest; the test carries them as a named list of exceptions, so a new one cannot slip in.

The one thing left for build time is the user's yes to these words: renaming two tabs is a visible change for everyone, and it is only worth asking if stage 2 happens.

**Design, when built:**

- Route `/connections/:id/remote` inside the `ShellRoute`, same page body as stage 1; the door button goes.
- Shown by the same rule as the door, from the same cached answer, so the bar does not jump from four to five tabs after start.
- `HomeShell` clamps the selected index to the destinations it has, and sends a `/remote` location with no tab to Dashboards. The router has no `refreshListenable`, so a redirect alone would not catch a rule that flips while the page is open.
- The tap switches the page; it never pushes the Pro screen from the bar.
- "Hide this tab" for people without Pro: per phone, all homes, kept in preferences. Buying Pro brings the tab back; a Pro owner has no hide. Settings › Home › Remote control stays either way.
- Read three weeks later against stage 1's own numbers, on what people did after opening, never on opens (a new tab gets explored once by everyone): kept only if "went on" from the tab is at least double the door's **and** there is at least one more `turned_on` or order than in the door's three weeks. Otherwise back to the door; the short labels and the label test stay.

Size: about two and a half days, most of it the label pass.

## Decisions for the user

1. **Order:** door first, tab only if the December read says so (recommended), or the tab now with its label cost.
2. **Sale:** Play discount offer, from the release day to 30 November (recommended).
3. **Version:** 3.4.4 for stage 1. The hub guide stays its own release.

## Out of scope

- Making remote work for homes carried by Home Assistant, and remote in the GitHub build.
- A separate remote subscription (the roadmap's rule stands: only at 20 Pro remote homes).
- A sale on iOS.

## Built and verified (2026-11-06)

- 1,351 tests pass. New ones cover every page state, the door and its rules, the pair list, the offer read from Play, buying exactly what was shown, a sale that ended or began between showing and tapping, and the Pro screen's sale line.
- The Play build compiles against Billing Library 8.0.0. Two names in Play's page were not in that version (`preorderDetails` does not exist; a time window's start and end can be missing) and the code follows the library.
- Emulator, against the real hub: the globe sits left of Edit; the page shows "At home, straight to your broker", Zigbee2MQTT's version, both ways, the three steps with the Engine's real state, and "See Pro" with the price; the Pro screen shows the sale line, the struck price and the new price. The sale was a stand-in value in a throwaway build, since the emulator has no Play.
- Not verified: a real discount offer end to end. That is the licence-test purchase, before the offer opens.
- Found on the way: the bar's labels are drawn in the app's own font, which is wider than the Roboto the stage-2 widths were measured with. "Automations" already reaches the screen edge at four tabs on the emulator, which is about 411 dp wide, so it wraps at 360 dp. Stage 2's widths have to be measured again with the app's font, and will be worse.
- For iOS (`ios/prep`): the billing channel now answers `offer` with a map and takes the shown offer in `buy`; the App Store side has to answer the same before that branch meets this one.
