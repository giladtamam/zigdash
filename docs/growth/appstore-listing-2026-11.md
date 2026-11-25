# App Store listing refresh (iOS), plan v2 — 2026-11-25

(v1 scored 6/10: keywords over 100 bytes, trademark risk in the subtitle, captions that overclaim on iOS,
no baseline, stale captures. v2 fixes all of these; History capture and es-MX are scoped out on purpose.)

## Why
iOS is live everywhere incl. the EU since 2026-11-25. iPhone traffic is 0–8 people/day and comes only from
App Store search (zigdash.app sends ~14 visits/day, nearly all existing Android users). The listing has:
- Subtitle "Zigbee home, no Home Assistant": a negative, and it pushes away the largest group (most
  completed setups sign in through Home Assistant).
- Keywords that repeat the name's token and use multi-word phrases that waste bytes.
- Six raw, caption-less screenshots per locale from 3.3.1. Play has had captioned shots since Oct 15.

## Baseline first (before anything changes)
Record from App Store Connect → Analytics (Nov 23–today, per source: App Store search / browse / web
referrer): impressions, product page views, first-time downloads, conversion rate. Save to
docs/growth/appstore-baseline-2026-11.md on ios/prep. Read date: 4 weeks after the version with the new
listing goes live (same metrics, same sources). Product Page Optimization (A/B) is not usable for subtitle/
keywords and needs traffic we don't have; a before/after read is the honest option at this volume.

## 1. Subtitle (≤30 characters, 13 locales)
en-US: **"Zigbee lights, blinds, sensors"** (30). No third-party marks, no repeat of the name's
"Zigbee2MQTT" token; says what you control. Each locale translates the same idea within 30 characters
(checked by script).

## 2. Keywords (≤100 bytes UTF-8, single words, comma-separated, no spaces)
Rules: single words (Apple combines words across name, subtitle and keywords, so "smart,home" covers
"smart home"); no word already in the name/subtitle EXCEPT "zigbee", because the name indexes
"Zigbee2MQTT" as one token; no other apps' or companies' names (no "home assistant", "hass", "smlight",
"tuya", "hue"). "mosquitto" (open-source broker) and "raspberry,pi" (generic platform) stay.
en-US: `zigbee,dashboard,mqtt,smart,home,switch,plug,remote,broker,mosquitto,raspberry,pi,tablet,wall` (93 bytes)
Other locales: local words for the same concepts plus "zigbee,mqtt,dashboard", each ≤100 bytes.

## 3. Screenshots (iPhone 6.9", 1320x2868, 13 locales)
- **Fresh captures** of the current 3.8.7 app from the demo home with the existing pipeline
  (tool/store/capture_ios.sh phone, all 13 locales, iPhone 18 Pro Max simulator, status bar 9:41) —
  running now. No re-compressed store JPGs.
- New `tool/store/captions_ios.py` on ios/prep: same palette, fonts and headless-Chrome render as
  captions.py, canvas 1320x2868, phone frame, Hebrew RTL. Five shots, captions true on iOS:
  1. dashboard — "Your Zigbee home, set up in a minute" / "Needs Zigbee2MQTT and an MQTT broker. ZigDash
     finds them and gives every device a tile."
  2. device controls — "Every control, one tap away" / "Brightness, white, colour, blinds and scenes."
  3. devices list — "Works with Home Assistant, or on its own" / "Sign in with Home Assistant, or connect
     straight to your MQTT broker." (states compatibility, no affiliation, no logo)
  4. device page — "See what needs attention" / "Low batteries and devices that went quiet, at a glance."
  5. dark dashboard — "No account. No ads." / "Free to use, one-time Pro. Your home's data stays on your
     broker." (no "no cloud": Pro's relay and anonymous usage counts exist)
  Translations: Play's existing pairs reused where the meaning is unchanged; new/changed lines translated
  (AI translations are accepted by the owner) for all 13 locales.
- The scenes/automations tabs stay visible in the bottom bar because that is the real app; captions steer
  attention to dashboard, controls, HA and attention instead.
- iPad 13" sets: unchanged (2 raw captures per locale) in this round.

## 4. Text fixes that ship with it
- Description, first paragraph, all 13 locales: drop "no Home Assistant" as the lead; new lead: works on its
  own with a small hub, or with Home Assistant.
- Promotional text (changeable without review, so done as soon as the score passes): same change.

## 5. Where it lands
- Create App Store version 3.8.8 in App Store Connect (prepare state; 3.8.7 is already live). Subtitle,
  keywords, description, screenshots go on it via the API. It goes out with the next iOS build, submitted
  only with the owner's yes.
- Metadata files in ios/prep fastlane/metadata/ios/<locale>/; script + rendered PNGs in store/appstore/ on
  ios/prep; committed on ios/prep only.

## Checks
- Script asserts subtitle ≤30 chars and keywords ≤100 bytes for every locale, no duplicates within a field.
- Look at en-US, de-DE and he renders before uploading all 65.
- Independent score ≥9 on the built result before upload.

## Out of scope (next round)
History/Remote captures (need seeded demo history), es-MX keyword localization for the US storefront,
captioned iPad set, In-App Events, featuring nomination, Search Ads.

## All 13 locales, drafted and checked (listing/meta.py, listing/check.py)
```
# subtitle (<=30 chars), keywords (<=100 bytes) per App Store locale
META = {
 'en-US': ('Zigbee lights, blinds, sensors', 'zigbee,dashboard,mqtt,smart,home,switch,plug,remote,broker,mosquitto,raspberry,pi,tablet,wall'),
 'de-DE': ('Zigbee: Licht, Rollo, Sensoren', 'zigbee,dashboard,mqtt,smart,home,steckdose,schalter,fernsteuerung,broker,mosquitto,raspberry,pi'),
 'fr-FR': ('Zigbee : lumières, volets', 'zigbee,tableau,bord,mqtt,maison,connectée,domotique,prise,capteur,interrupteur,distance,broker'),
 'es-ES': ('Zigbee: luces, persianas', 'zigbee,panel,mqtt,casa,inteligente,domótica,enchufe,sensor,interruptor,remoto,broker,mosquitto'),
 'it': ('Zigbee: luci, tapparelle', 'zigbee,dashboard,mqtt,casa,smart,domotica,presa,sensore,interruttore,remoto,broker,mosquitto'),
 'nl-NL': ('Zigbee: lampen, rolluiken', 'zigbee,dashboard,mqtt,slim,huis,domotica,stekker,sensor,schakelaar,afstand,broker,mosquitto'),
 'pl': ('Zigbee: światła, rolety', 'zigbee,panel,mqtt,inteligentny,dom,gniazdko,czujnik,przełącznik,zdalne,broker,mosquitto'),
 'pt-BR': ('Zigbee: luzes, persianas', 'zigbee,painel,mqtt,casa,inteligente,automação,tomada,sensor,interruptor,remoto,broker'),
 'ru': ('Zigbee: свет, шторы, датчики', 'zigbee,панель,mqtt,умный,дом,розетка,брокер,mosquitto,пульт'),
 'sv': ('Zigbee: lampor, gardiner', 'zigbee,dashboard,mqtt,smart,hem,uttag,sensor,strömbrytare,fjärr,broker,mosquitto,raspberry,pi'),
 'no': ('Zigbee: lys, gardiner, sensor', 'zigbee,dashbord,mqtt,smart,hjem,stikkontakt,bryter,fjernstyring,broker,mosquitto,raspberry,pi'),
 'cs': ('Zigbee: světla, žaluzie', 'zigbee,panel,mqtt,chytrá,domácnost,zásuvka,senzor,vypínač,dálkové,broker,mosquitto'),
 'he': ('Zigbee: תאורה, תריסים, חיישנים', 'zigbee,לוח,mqtt,בית,חכם,שקע,חיישן,מתג,שליטה,מרחוק,broker,mosquitto'),
}
```
Checker output (subtitle chars, keyword bytes, no duplicates, no keyword repeating a subtitle word except zigbee):
```
en-US  sub 30/30  kw  93/100  OK 
de-DE  sub 30/30  kw  95/100  OK 
fr-FR  sub 25/30  kw  95/100  OK 
es-ES  sub 24/30  kw  95/100  OK 
it     sub 24/30  kw  92/100  OK 
nl-NL  sub 25/30  kw  91/100  OK 
pl     sub 23/30  kw  89/100  OK 
pt-BR  sub 24/30  kw  87/100  OK 
ru     sub 28/30  kw  91/100  OK 
sv     sub 24/30  kw  95/100  OK 
no     sub 29/30  kw  93/100  OK 
cs     sub 23/30  kw  89/100  OK 
he     sub 30/30  kw  96/100  OK 
all ok
```
