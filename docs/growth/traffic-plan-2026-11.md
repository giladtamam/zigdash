# Traffic plan, Nov 15 – Jan 5 2027 (v3.1, scored 9/10)

Part of [the profit plan](profit-plan-2026-11.md) (v4.1), not a fork of it. It adds one thing the profit
plan does not have, a Play listing pass, and brings two Month 2 items forward now that 3.6 is live: the
small Home Assistant forum post and the ratings prompt. Everything the profit plan rules out stays out.

v2 after review (v1 scored 6/10): the "MQTT dashboard" and "Home Assistant dashboard" targets are
dropped (people searching them mostly can't finish setup), the short description keeps the remote
promise until the remote read is over, ratings move from "measure only" to the main lever for the broad
searches, a no-release-in-review rule, and the scraper reads German in German. v3 (v2 scored 8/10): the
short description is left exactly as it is until Dec 21, the German bars use German phrases, the install
read is descriptive with the held terms as the control, and a conversion guardrail.

## 1. What the data says

**Play Console, Oct 17 – Nov 13 (28 days):**

| | Value | vs previous 28 days |
|---|---|---|
| Device impressions | 6,750 | +47% |
| Store listing visitors | 1,030 (~37 a day; 15% of impressions) | +55% |
| Install clicks / visitors | 60% | +6% |
| Device acquisitions | 540 | +47% |
| from Google Play explore (search + browse) | **484 (90%)** | +77% |
| from paid and direct (outside links) | 33 | −56% |
| Ratings | **10 in total, 4.9** (5.0 in the last 28 days) | |

The page converts (60% of visitors install); what limits installs is how often Play shows ZigDash and
how often a searcher taps it (15%). Play Console no longer offers a search-term breakdown in its menus
(checked Nov 15: Grow overview, Statistics dimensions, Store listings), so rank is read with
`tool/play_rank.mjs`.

**Play search, Nov 15** (first ~30 results; US in English, DE in German; full table in
`play-rank-2026-11-15.csv`; the "zigbee" position, 8 in the US, matches the store page read by hand):

| Term | US | DE | |
|---|---|---|---|
| zigbee2mqtt, zigbee2mqtt dashboard, zigbee dashboard, zigbee2mqtt app | 1 | 1 | held |
| zigbee2mqtt android | 2 | 2 | held |
| zigbee2mqtt home assistant | 2 | 3 | held |
| zigbee wall tablet | 3 | – | |
| zigbee wandtablet | 9 | – | target (DE) |
| zigbee2mqtt fernzugriff | 2 | 10 | target (DE) |
| smart home wandtablet | – | – | reference |
| zigbee | 8 | 7 | target |
| zigbee control | 9 | 28 | target |
| zigbee app | 10 | 9 | target |
| smlight, sonoff zigbee | – | – | reference |
| mqtt dashboard, home assistant dashboard | – | – | reference only |

(Play's search-term report, Grow › Store performance in older Consoles, was not available on Nov 15;
at ~37 visitors a day most terms would fall under its privacy threshold anyway.) "zigbee remote control"
is not a target: most people searching it want a hardware remote.

**What this means.** Every search that names Zigbee2MQTT is already won. The room is in the broad
Zigbee searches (zigbee, zigbee app, zigbee control), where the apps above ZigDash have thousands of
ratings and ZigDash has 10. Those positions move on ratings and installs more than on words, so the
listing text alone will not move them much. The text matters where a phrase is missing (wall tablet and
remote in German) and for who installs.

**Not targeted, on purpose.** "MQTT dashboard": ZigDash has custom MQTT tiles, but setup only finishes
with Zigbee2MQTT ("Your broker works, but Zigbee2MQTT isn't publishing here" has no way past it), so a
Tasmota or ESPHome user who searched that would install, fail and uninstall. "Home Assistant
dashboard": most of those people use ZHA, which hits "No Zigbee2MQTT in this Home Assistant" and would
pull down the Home Assistant route rate the profit plan reads in Month 3. Home Assistant is named in the
listing only as "Home Assistant with Zigbee2MQTT".

**The live listing is several versions old** (read from the store page Nov 15; de, nl, fr, es the same).
The full description says automation runs in Node-RED and remote needs Tailscale, names Home Assistant
once, and says nothing about Home Assistant sign-in, ZigDash Engine, alerts, History, hub backup, the
setup scan or the assistant. The repo copy (`fastlane/metadata/android/*/full_description.txt`) is older
still. The listing is wrong today, which is reason enough to fix it, whatever the rank does.

**Ratings prompt:** requested 4 times in the 6 days the self-hosted analytics covers (3.4.7 and later).
It waits for 2 days, a device answering on two days and the 3rd command, so few people reach it.

## 2. Steps

### Step 1. Rewrite the Play listing (me; the user approves the text before it is submitted)
- **Title unchanged:** "ZigDash: Zigbee2MQTT Dashboard" holds the #1 positions.
- **Short description unchanged until the remote read ends (Dec 21):** "Fast Zigbee2MQTT dashboard.
  Control your home from anywhere, no monthly fee." Home Assistant sign-in goes in the first lines of the
  full description instead. A short-description change, if any, gets its own date after Dec 21.
- **Full description**, rewritten from what 3.6 does, each claim checked against the code and
  changelogs 95–113. The first lines (before "More"): Zigbee2MQTT, alone or in Home Assistant, a
  dashboard that builds itself, phone and wall tablet. Then: two ways to connect (Home Assistant sign-in
  when Zigbee2MQTT runs in it; any MQTT broker Zigbee2MQTT uses) · the dashboard builds itself, plus
  custom MQTT tiles · History (Pro; 14-day free trial) · automations on your hub (ZigDash Engine) ·
  alerts · wall tablet (wall display and kiosk lock free; readings on the clock, wake on motion, night
  schedule and alarms in Pro) · shortcuts and widgets · hub backup · remote control (Pro, one payment) ·
  private · what you need (Zigbee2MQTT; ZHA is not supported; demo home without a hub). Node-RED and
  Tailscale leave the requirements.
- **Play metadata policy:** no keyword lists, no "best/#1", no ratings or testimonials, no claim the
  app doesn't meet. Each phrase appears where it describes a real feature.
- **13 locales, words chosen per language**, not translated word for word: what people type there
  (German: "Zigbee2MQTT App", "Wandtablet", "Fernzugriff"; Dutch: "wandtablet", "op afstand"; French:
  "tablette murale", "à distance"). AI translation (the user accepts it), the German one read back by me
  against German Play search results. The fastlane files are updated to match, so the repo is the source
  of truth again.
- **Same wording on zigdash.app and the README** (the site is its own repo, zigdash-site).
- **Screenshots and promo video unchanged.** Conversion is not the bottleneck, and the October setup
  video shows a setup that has changed since.
- **Release rule:** managed publishing is off, so a listing edit sent while a build is in review goes into
  the same review. The listing is submitted only when no build is in review, and no build is sent until
  the listing is approved. Today nothing is in review (3.6.0 is live).

### Step 2. Ratings prompt at a happy moment (3.6.1; pulled forward from the profit plan's Month 2)
- Also ask after the first scene run or the first automation saved, keeping the 2-day minimum; Play's
  own quota still decides whether the dialog shows. Its own small plan is scored to 9 first.
- Sent only after the listing is approved (release rule).
- Read: prompts requested a week, and ratings in Console. Bar: 25 ratings by Jan 15 (10 today).

### Step 3. Measure (me)
- **Noise first:** four runs of `tool/play_rank.mjs` on Nov 15–16 before the listing is submitted, to see
  how much positions move with no change.
- **Then every Monday:** `env -u NODE_OPTIONS node tool/play_rank.mjs --csv >> docs/growth/play-rank.csv`,
  plus the ratings count.
- **Bars, 6 weeks after the listing goes live (~Jan 5):**
  - Held: every Zigbee2MQTT term stays in the top 3 (a loss means the rewrite hurt; revert that locale).
  - Text-driven, German: "zigbee wandtablet" enters the top 10 in DE (absent today) and
    "zigbee2mqtt fernzugriff" moves into the top 5 in DE (10 today).
  - Ratings-driven stretch: "zigbee" or "zigbee app" in the top 5 in US or DE. A miss is expected:
    25 ratings against apps with thousands is a start, not a match.
- **Conversion guardrail:** install clicks per listing visitor (60%, Console's 28 days to Nov 8; the
  guardrail is read on the same Console view). If the 28 days after the listing goes live fall below
  50%, the old full description goes back. 3.6.1's release date is marked in that window.
- **Installs, descriptive only:** explore acquisitions are already rising (+77%) and Black Friday
  (Nov 27) lands in the window, so no install number is a bar. The held Zigbee2MQTT terms act as the
  control: their positions should not change with the listing, so a rise with them flat points at the
  new terms.
- If the text bars fail: one second wording, then stop. The listing stays accurate either way.

### Step 4. Two small posts in existing threads (drafted by me, rewritten and posted by the user)
Reddit, the Home Assistant forum and GitHub writes are not mine to make, and the Home Assistant groups
ban AI-written text, so these are the user's own words from my notes.
- **Home Assistant forum:** a reply in ZigDash's own thread (1018963), not a new showcase topic: the
  forum expects one thread per project, and the old one carries its history. Home Assistant sign-in,
  History recorded on the hub, the 14-day trial. The profit plan's Month 2 line changes to match.
- **Zigbee2MQTT discussion #33283** (our Show and tell): a short "what changed since October" comment.
- Links carry a Play referrer (`utm_source=haforum` / `z2mdiscussion`, `utm_medium=post`), so Play
  counts them under paid and direct, apart from the listing's effect on explore.
- After the listing is live, a week apart, so each shows on its own.

### Step 5. iPhone, when Apple approves 3.5.3 (gated on approval, not a date)
- App Store keywords field (100 characters) with the same honest terms; subtitle with Home Assistant.
- Recontact Jonatan Castro (ES, 106K), who said on Nov 1 he would look once ZigDash was on iPhone.
- "Now on iPhone" on r/homeassistant (the user) and in the Telegram announcements.

### Step 6. zigdash.app (added Nov 15 at the user's request)
**Data (GoatCounter, Oct 18 – Nov 15):** 240 visits; 148 on /hubs and most others from Android with no
referrer, i.e. people tapping links inside the app; 6 from Google; 1 tap on "Get it on Google Play". The
site helps people who already have ZigDash and brings almost no one new. Google may not index it well:
no robots.txt, no sitemap, and Search Console was never set up.

**It is also out of date:** the hero says "without Home Assistant" while 8 of 18 recent working homes
came through Home Assistant sign-in; the comparison table says automations run in Node-RED; the Home
Assistant card describes the pre-2.10 Mosquitto login; nothing about History, the Engine or hub backup.

What changes (source in the main repo's `landing/`, published by copying to `giladtamam/zigdash-site`,
as today):
1. **Truth first, same wording as the new listing.** Hero: "A fast Zigbee2MQTT dashboard for your phone
   and wall tablet", with "No Home Assistant needed, and it signs in to Home Assistant too" underneath
   (the October line, "works with it too", kept; never "better than Home Assistant"). The new headline
   changes the October brand line, so the user approves it before the site is published. Pricing said
   plainly: free, with an optional one-time Pro (the site says only "Free for Android" today). Comparison table
   and cards rewritten from 3.6 (Engine, History, hub backup, Home Assistant sign-in). The Home
   Assistant guide leads with sign-in; the Mosquitto login moves to "the older way". Home Assistant's
   "add-ons" are now "apps" in its own menus; the guide uses its words.
2. **What search engines need:** robots.txt, sitemap.xml, a unique title and description per page,
   `SoftwareApplication` structured data on the home page (name, Android, free with in-app purchase; no
   rating markup with 10 ratings, so no rich result is expected from it), `hreflang` on both `/` and
   `/de/` pointing at each other plus `x-default`. The paths the app links to (`/hubs/`, `/setup/`,
   `/home-assistant/`, `/help/`) stay where they are.
3. **Google Search Console** on a URL-prefix property for https://zigdash.app/, verified with an HTML
   file in the site repo (no DNS change). The user adds the property in their Google account (I can do
   it in their browser if they say so); sitemap submitted. This gives the search queries Play no longer
   shows, for the site.
4. **Play links carry a referrer** (`utm_source=zigdash.app`, `utm_medium=site`, `utm_campaign=<page>`),
   so installs from the site show in Play apart from explore.
5. **Three new pages, each a real how-to that stands without the app:**
   - `/zigbee2mqtt-android/`: "Control Zigbee2MQTT from your Android phone": the three ways in (Home
     Assistant sign-in, the broker, the Zigbee2MQTT page), widgets and Quick Settings, what needs the
     Engine. Search intent "zigbee2mqtt android app".
   - `/wall-tablet/`: "A Zigbee2MQTT wall tablet": an old Android tablet, kiosk lock, keeping it charged,
     what is free and what is Pro.
   - `/de/`: a German page ("Zigbee2MQTT App für Android und Wandtablet"); Germany is the second country
     on Play and on the site.
   No page targets MQTT-only or ZHA users (same reason as the listing).
6. **Links in**, because a month-old domain with none gets little from Google: the GitHub repo's
   Website field and README point at zigdash.app; the Play listing's website field is checked to be
   zigdash.app; the Step 4 forum and Zigbee2MQTT posts link `/zigbee2mqtt-android/` next to Play.
7. **Not in this step:** a blog, more languages, an App Store badge (comes with Step 5).

**Read (with the listing read, ~Jan 5):** Search Console impressions and clicks per query and page; site
visits from Google (6 in the last 4 weeks); Play installs with `utm_source=zigdash.app`. Bar: Google sends
50 visits in the 4 weeks from the first impression Search Console reports (not from publishing), read
next to Play installs with `utm_source=zigdash.app`, since visits alone are not installs (1 Play tap in
240 visits today). The site read can land after the ~Jan 5 listing read if Google is slow to show the
site. If the bar fails, the pages stay (they are help pages anyway) and no more are written.

**Effort:** about a day (me); a few minutes for the user to add the Search Console property and approve
the headline. The listing is already submitted, so nothing waits on this step; it slips rather than
anything else.

## 3. Not doing (from the profit plan and the outreach log)
- Paid ads; the Google Ads draft stays unpublished (a working home costs ~$11 in ads, earns $0.60–1.20).
- The big push (r/homeassistant feature post, German forum, simon42, Everything Smart Home): waits for
  ZHA in Month 4.
- Zigbee2MQTT docs PR (closed until critical mass), Gladys (declined), more SMLIGHT emails (three
  unanswered), Product Hunt.
- An MQTT-only setup path to earn the "MQTT dashboard" searches: a product decision, not traffic work.

## 4. How it touches the other reads
- **Remote read (Dec 1–21):** the short description is not touched before Dec 21, so the promise that
  brings people stays the same through the read.
- **Home Assistant read (Month 3, route completes ÷ opens):** the listing names Home Assistant only with
  Zigbee2MQTT and says ZHA isn't supported, so it should not add ZHA users; the read notes the listing date.
- **History-on read (~Nov 29):** a share of new homes; more homes don't move the bar.
- **Trial read (50 ended trials):** more installs reach it sooner; the price comparison already counts
  only homes installed before Feb 15.

## 5. Order
| When | What | Who |
|---|---|---|
| Nov 15–16 | Rank noise runs; English full description draft, checked against the code | me |
| Nov 16 | Approve the text | user |
| Nov 16–17 | Locale wording, Console entry, fastlane, zigdash.app, README; submit | me (the user confirms Submit) |
| Nov 17–19 | Listing live | Google |
| after approval | 3.6.1 ratings prompt (own plan, scored to 9) | me |
| Nov 24 | Home Assistant forum reply | user, from my notes |
| Dec 1 | Zigbee2MQTT discussion comment | user, from my notes |
| Mondays | Rank run + ratings count | me |
| ~Jan 5 | Read | me |
| Apple approval | Step 5 | me + user |
| after the listing is submitted | Step 6: site fixes, SEO basics, three pages, publish (headline approved by the user) | me |
| after publish | Search Console property + sitemap | user (or me, if asked) |
