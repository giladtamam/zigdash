# wayfinder:research — Reference UI benchmark for smart-home control apps

> Ticket: [01-benchmark-reference-uis](../tickets/01-benchmark-reference-uis.md)
> Question: *What do the best-regarded smart-home control apps do in the first ten minutes and on the main control surface that ZigDash does not?*
>
> Research run 2026-09-26 against official docs, help centers, release notes, store listings and a few reputable write-ups. **FACT** = sourced product claim; **INFERENCE** = recommendation derived from facts; **VERIFY IN AUDIT** = a comparison with ZigDash that ticket 03 (UI audit) must confirm with screenshots. This report covers UI only; features and positioning for IoT MQTT Panel are in [`wayfinder/research/iot-mqtt-panel-competitor-benchmark.md`](../../research/iot-mqtt-panel-competitor-benchmark.md) and are not repeated.

## TL;DR

1. **Every consumer-grade reference (Home Assistant, Google Home, Apple Home, Homey) opens on a surface organised by room/area with a per-category status row and a pinned Favorites strip; none opens on a list of connections.** Home Assistant's new default Overview shows summaries for lights, climate, security and media, then areas, with any entity pinnable to the top ([HA 2025.9](https://www.home-assistant.io/blog/2025/09/03/release-20259/), [HA 2026.2](https://www.home-assistant.io/blog/2026/02/04/release-20262/)). Apple shows category buttons with counts ("Lights — 3 on") under the home name, then Cameras, Scenes, Favorites, Rooms ([Apple](https://support.apple.com/guide/iphone/control-accessories-iph0a717a8fd/ios), [Apple iPad](https://support.apple.com/guide/ipad/intro-to-home-ipad59e50d78/ipados)). Google's Home tab swipes between Favorites, all devices by room, and category dashboards (Cameras, Lighting, Climate, Smoke & CO, Wifi) ([Google](https://support.google.com/googlehome/answer/7071794?hl=en)). ZigDash today opens on **Brokers / Dashboards / Settings**, and the Dashboards tab shows "Open a broker from the Brokers tab to see and manage its dashboards" until a broker is chosen (`lib/l10n/app_en.arb`, `dashPlaceholder`).
2. **The first useful screen is generated, not built.** HA prepopulates the Home dashboard from areas and adds a "For You" section of discovered devices plus an unassigned-devices area, with prompts to sort devices into rooms ([HA dashboards](https://www.home-assistant.io/dashboards/dashboards/), [HA 2026.2](https://www.home-assistant.io/blog/2026/02/04/release-20262/)). Homey's Devices tab shows all devices in one screen by default ([Homey blog](https://homey.app/en-us/blog/homey-v2-0-devices-flow/)). Zigbee2MQTT's own Dashboard lists every device with its exposes, no configuration ([NotEnoughTech](https://notenoughtech.com/home-automation/zigbee2mqtt-dashboard/)). The maker tools (IoT MQTT Panel, MQTT Dash) are the only ones that start from a blank grid, and MQTT Dash literally labels itself "for nerds only" ([Play](https://play.google.com/store/apps/details?id=net.routix.mqttdash&hl=en)).
3. **Tile grammar is converging on one contract:** icon = quick action (toggle), body = open controls, long-press = settings/context; active state coloured by domain; a one-line state text. Documented identically for HA's Tile card ([HA Tile](https://www.home-assistant.io/dashboards/tile/)), Apple ([Apple](https://support.apple.com/guide/iphone/control-accessories-iph0a717a8fd/ios)) and, since v10.0.0, Homey (quick action behind a top-right button, tap opens controls, status moved to the bottom of the tile) ([Homey changelog](https://homey.app/en-us/wiki/homey-mobile-app-changelog/)). Google uses tap to toggle and touch-and-hold for full controls ([Google](https://support.google.com/googlehome/answer/7071794?hl=en)).
4. **First-run has one door, discovery with three outcomes, and a setup assistant that ends on the home screen.** HA Companion: "Connect to my Home Assistant server" → scan network → one server / several / none ("Enter address manually") → login → name device → location permission → done, "your Home Assistant dashboard" ([HA Companion](https://companion.home-assistant.io/docs/getting_started/)). Apple: "The first time you open the Home app, the setup assistant helps you create a home, where you can add accessories and define rooms" ([Apple iPad setup](https://support.apple.com/guide/ipad/set-up-accessories-ipad395134af/ipados)). None of the references has a multi-page feature carousel before the first real action; ZigDash has a three-page one (Welcome / Connect your broker / Build your dashboards) before offering "Try demo" or "Connect my broker" (`app_en.arb`, `onboarding*`).
5. **Dark mode is "follow the system" everywhere, with a per-user or in-app override in HA and Homey**; tablets get a sidebar (Apple), a navigation rail (Material guidance at 600 dp and above), or a wider column count (HA Sections), never a stretched phone layout.

---

## Comparison table (one phrase per cell; details and sources in the per-app sections)

| App | First-run journey | Home-screen IA | Tile anatomy | Empty state | Tablet | Dark mode |
|---|---|---|---|---|---|---|
| **HA Companion + frontend** | One button → network discovery (1 / many / none) → login → name device → location → dashboard | Overview: summaries (lights, climate, security, media) → favorites → areas; per-area views; other built-in dashboards per topic | Icon tap toggles, body opens more-info, features rows (brightness, cover buttons/position, bar gauge, trend) | "For You" discovered devices + unassigned "Devices" area + prompts to assign rooms | Sections view with chosen max columns; drag-and-drop | Per-user theme; default follows system |
| **Google Home** | Google account → "Add > Device" → scan QR → follow steps | 3 tabs: Home / Activity / Automations; Home swipes Favorites → All devices by room → category dashboards; Ask Home in header | Tap toggles; touch-and-hold opens controls/settings; media mini-player | Not documented in reviewed sources | "Updated look on tablets" with landscape/portrait support (2023); no detail | Follows Android system theme (since v2.27) |
| **Apple Home** (pattern ref.) | Setup assistant creates a home and rooms → Add Accessory (scan code) → assign room, name, suggested automations | Home tab: category buttons with counts → Cameras → Scenes → Favorites → Rooms; editable order and tile size | Icon (left) toggles; name (right) opens controls; touch-and-hold → Accessory Settings | "Add Accessory" is the primary action in an empty home | iPad sidebar: Home, categories, rooms | Not documented in reviewed sources (system default assumed; unverified) |
| **Homey** | Log in → create a home → connect devices (free tier: 5 devices) | Home screen: quick actions + timeline; tabs Devices / Flows / Energy / More; Devices shows all, title tap → zones | Quick action button top-right, tap opens controls, status at bottom; live colour/temperature on tiles | Not documented in reviewed sources | Not documented in reviewed sources | In-app toggle or follow OS (v7.2.0) |
| **IoT MQTT Panel** | Connection → Dashboard → Panel, all manual (prior benchmark) | Connection list → dashboards → panel grid | Panel types with flexible width and merging; 250+ icons | Not documented; guide unreachable today | Play shows Phone and Tablet screenshot sets | "Dark theme for comfortable use in low light" (listing) |
| **MQTT Dash** | Add connection (IP, optional credentials) → add tiles by hand | One dashboard per connection; tiles | Tile types configured by topic/payload; JavaScript | Not documented | "Phones and tablets are supported in both orientations" | Not documented |
| **Zigbee2MQTT frontend** | None — it is the Z2M admin UI; opens on Devices table | Tabs: Devices, Dashboard, Map, Groups, OTA, Touchlink, Logs, Settings | Dashboard cards show each device's exposes; windfront borders cards red = offline, dotted orange = disabled | Not documented | Desktop-first web UI; responsive | windfront: 35 daisyUI themes |

---

## 1. Home Assistant (Companion app + frontend)

### First-run journey

**FACT.** The Companion onboarding is one linear flow: open the app and select **Connect to my Home Assistant server**; the app "searches for Home Assistant servers on your network" with three documented outcomes (a single server is offered automatically; several servers are listed; none found → **Enter address manually**); then Home Assistant login; then "choose a name for your device as it will appear in Home Assistant"; then a location prompt with **Share my location** / **Do not share my location**; for non-encrypted URLs a **Most secure** / **Less secure** choice that may ask to confirm the home Wi-Fi SSID; then the user lands on "your Home Assistant dashboard", and notifications are requested after setup. There is no demo mode and no feature carousel. [HA Companion getting started](https://companion.home-assistant.io/docs/getting_started/)

**INFERENCE.** The three-outcome discovery screen is the pattern ZigDash's broker scan sheet should copy at the *journey* level: discovery is the first screen after the welcome, not a sheet inside a form, and "none found" has a named next action rather than an empty list.

### Home-screen IA

**FACT.** Since 2026.2 the **Home** dashboard "is now Overview as it becomes the official default standard, replacing the old 'Overview' for all new instances"; long-time users who never customised are offered the switch. It ships a redesigned default theme "replacing the old blue top bar". [HA 2026.2](https://www.home-assistant.io/blog/2026/02/04/release-20262/)

**FACT.** What is on it, top to bottom, per the release notes and docs: "a quick way to navigate to useful summaries for your light, climate, security, and media devices"; **favorites** ("You can pin any entity to the top, whether it's a light, climate, or a person"); browsing by area; weather and energy cards. [HA 2025.9](https://www.home-assistant.io/blog/2025/09/03/release-20259/) The docs describe it as "an entry point to open other built-in dashboards based on areas or topics such as lights, climate, or media players", "prepopulated by default", "grouped by areas", using "the sections view type and tile cards"; "The first view shows all your areas and the entities that are assigned to those areas. In addition, the dashboard provides a separate view for each area", where entities "such as lights, covers, and cameras are automatically grouped by domain". [HA dashboards](https://www.home-assistant.io/dashboards/dashboards/)

**FACT.** Topic dashboards exist beside it and are all "grouped by floors and areas": Lights, Security (alarm, lock, camera, doors/covers, motion, binary sensors; with optional **Favorites** and **Active alerts** sections, the latter shown only when something "needs attention, such as a door left open"), Climate, Energy, Maintenance ("Overview of your battery entities… Low batteries are highlighted"). [HA dashboards](https://www.home-assistant.io/dashboards/dashboards/)

**FACT.** Area pages carry comfort indicators in the header: "At the top of each area page, temperature and humidity badges quickly indicate room comfort levels, which are configurable in the area's settings"; areas and entities can be rearranged, shown or hidden. [HA 2025.4](https://www.home-assistant.io/blog/2025/04/02/release-20254/) 2025.12 added "a new sidebar that gathers quick access links" and "a nicer area and floor layout that uses space more efficiently", and warned that favorites might need re-adding because of the migration "from a strategy to a built-in dashboard". [HA 2025.12](https://www.home-assistant.io/blog/2025/12/03/release-202512/)

### Tile / card anatomy

**FACT.** The Tile card shows an icon, the friendly name and the state; "a badge is shown for some entities like the climate or person entities". Defaults: card tap → more-info dialog; icon tap → "toggle the entity (if possible), otherwise, show the more-info dialog"; "The circular background behind an icon indicates that there is a tap action." Colour is applied "when the entity is active. By default, the color is based on state, domain, and device_class". A `vertical` variant puts the icon above name and state; `state_content` can show `last_changed`/`last_updated` or attributes; `hide_state` exists. **Features** (control rows) sit at the bottom by default or inline ("the first feature is displayed next to the name and any remaining features are displayed below it, two per row"). [HA Tile card](https://www.home-assistant.io/dashboards/tile/)

**FACT.** Documented features relevant to ZigDash's panel types: **Light brightness** ("a slider to select the brightness"), **Light color temp**, **Toggle**, **Cover open/close** ("buttons to open, close, or stop a cover"), **Cover position** ("a slider to control the position"), **Numeric input** ("a slider or buttons"), **Bar gauge** ("the state of a numeric sensor as a horizontal bar"), **Trend graph** ("a trend of the history for a numeric sensor"), **Button** (for button/scene/script), plus climate, fan and alarm rows. [HA card features](https://www.home-assistant.io/dashboards/features/) The trend graph "showing the history of a specific entity over time" initially covers 24 hours; the bar gauge targets percentage sensors such as battery. [HA 2025.9](https://www.home-assistant.io/blog/2025/09/03/release-20259/)

**INFERENCE.** This is the closest published equivalent of a spec for ZigDash's light, cover and sensor tiles: one base tile (icon / name / state / active colour) plus optional feature rows, rather than a different visual per panel type. It maps cleanly onto the 16 protected panel behaviours as *features* of a common tile.

### Empty states

**FACT.** 2026.2 adds "a 'For You' section featuring discovered devices" and "a dedicated Devices area that displays unassigned devices", plus "quick prompts to help categorize devices into rooms" and edit shortcuts for an area's primary sensors. [HA 2026.2](https://www.home-assistant.io/blog/2026/02/04/release-20262/) The docs' troubleshooting for a missing entity is one sentence: "Not all devices or entity types are automatically added to the Home dashboard. Make sure the entity is assigned to an area and check the dashboard again." [HA dashboards](https://www.home-assistant.io/dashboards/dashboards/)

**INFERENCE.** The empty/unsorted state is handled by *content that asks for one decision* (put this device in a room), not by a blank page with instructions.

### Tablet layout

**FACT.** The Sections view asks for "the maximum number of columns you want to see"; layouts are responsive (header side-by-side on desktop, stacked on mobile); sections and cards can be rearranged by drag-and-drop ("This is not yet possible in other views"); a heading card is auto-added per section; "Dense section placement" fills gaps at the cost of order control; badges sit in the view header. [HA Sections](https://www.home-assistant.io/dashboards/sections/) The Companion docs say nothing specific about tablets. [HA Companion](https://companion.home-assistant.io/docs/getting_started/)

### Dark mode

**FACT.** Theme is chosen per user ("A theme selector appears on the user profile page… This choice is saved to your user profile, so it applies across your devices"); themes can define light and dark variants and "default selection is based on the system settings". [HA frontend](https://www.home-assistant.io/integrations/frontend/)

---

## 2. Google Home

### First-run journey

**FACT.** Setup assumes a Google Account and starts from the app: "At the top right, tap Add and then Device", "Scan the QR code of your device", wait for the connection, "Follow the in-app steps to customize your device". The help page does not describe account/home creation or permission prompts in sequence. [Google set up](https://support.google.com/googlenest/answer/7029485)

### Home-screen IA

**FACT.** The October 2025 redesign reduced the bottom bar to three tabs — **Home**, **Activity**, **Automations** — and made the Home tab a set of swipeable sections so you can "swipe between your Favorites, all devices and dedicated dashboards without having to switch tabs"; **Ask Home** is "persistently accessible from the new header navigation". Google also reports the app loads "over 70% faster" on some Android devices. [Google blog, 2025-10-01](https://blog.google/products-and-platforms/devices/google-nest/google-home-app-gemini-redesign/) The prior 2023 design had five tabs: Favorites, Devices, Automations, Activity, Settings. [9to5Google, 2023-05-10](https://9to5google.com/2023/05/10/google-home-app-redesign-public/)

**FACT.** Help-center description of the current Home tab: **Favorites** — "Quick access to devices, automations, and more marked as your favorite", including a "Media mini-player"; **All devices** — "Shows all devices you've added in the Google Home app, organized by room"; device dashboards for **Cameras**, **Lighting**, **Climate**, **Smoke & CO**, **Wifi**; Settings via the profile picture "at the top right of any of the main app screens". [Google — Meet the app](https://support.google.com/googlehome/answer/7071794?hl=en) Rooms are assigned per device under **Placement**, with suggested or custom room names; deleting a room removes its devices. [Google — Organize](https://support.google.com/googlenest/answer/15559809?hl=en)

**FACT (secondary, dated 2025-09-27).** The header is an "Ask [Home name]" bar; a circle on the left sets Home/Away; a plus pill adds devices/automations; the section switcher renders the current selection as a rounded rectangle and the others as circles; "Device tiles remain unchanged from the previous version". [9to5Google](https://9to5google.com/2025/09/27/google-home-ask-redesign-iphone/)

### Tile / card anatomy

**FACT.** Favorites tiles toggle on tap; "touch and hold your device's tile to open all of its settings or controls"; speakers expose volume/EQ and transport, thermostats set point, mode and ambient temperature. [Google — Meet the app](https://support.google.com/googlehome/answer/7071794?hl=en)

### Empty states

Not documented in reviewed sources.

### Tablet layout

**FACT.** The 2023 redesign shipped "an updated look on tablets, with better support for landscape and portrait orientations on larger screens", Android tablets first; layout specifics are not described. [9to5Google, 2023-05-10](https://9to5google.com/2023/05/10/google-home-app-redesign-public/) The 2025 post does not mention tablets. [Google blog](https://blog.google/products-and-platforms/devices/google-nest/google-home-app-gemini-redesign/)

### Dark mode

**FACT.** Dark theme arrived in v2.27 (2020) and follows the Android system toggle; there is no independent in-app switch. [9to5Google, 2020-08-25](https://9to5google.com/2020/08/25/google-home-2-27-dark-theme/)

---

## 3. Apple Home (pattern reference only; iOS)

### First-run journey

**FACT.** "The first time you open the Home app, the setup assistant helps you create a home, where you can add accessories and define rooms." Adding: "Tap Home in the sidebar, then tap Add Accessory"; scan a QR code or enter an 8-digit (Apple Home) or 11/21-digit (Matter) code; "You can assign the accessory to a room, and give it a name… You can also add suggested automations during setup." [Apple iPad — Set up accessories](https://support.apple.com/guide/ipad/set-up-accessories-ipad395134af/ipados) Marketing framing: "Just scan the accessory to pair it with the Home app." [Apple Home app page](https://www.apple.com/home-app/)

### Home-screen IA

**FACT.** The Home view has, in order: **Categories** ("Tap a category such as Lights, Security, Climate, Speakers, or Water to show all related accessories on one screen, organized by room"), **Cameras** ("Video from up to four cameras… Swipe left to see more"), **Scenes**, **Favorites** ("the accessories you use most often"), **Rooms** ("Accessories are organized by room"). Editing: "Edit Home View, then drag tiles to a different position", "Reorder Sections", and "Resize icons: Select Edit Home View, tap a tile, tap [resize]". [Apple iPad — Intro to Home](https://support.apple.com/guide/ipad/intro-to-home-ipad59e50d78/ipados) On iPhone: "Below your home's name, buttons show the status of accessories belonging to a category—for example, a Lights category that shows '3 on.'" [Apple iPhone — Control accessories](https://support.apple.com/guide/iphone/control-accessories-iph0a717a8fd/ios)

### Tile / card anatomy

**FACT.** "On the Home tab, tap an accessory's icon on the left side of the tile—a light, for example—to quickly turn the accessory on or off. Tap the accessory's name on the right side of the tile to show the accessory's control. The available controls depend on the type of accessory." Settings: "touch and hold the tile, and then choose Accessory Settings"; rename and change icon from there ("If you don't get a choice of other icons, it means the icon can't be changed for this accessory"). [Apple iPhone — Control accessories](https://support.apple.com/guide/iphone/control-accessories-iph0a717a8fd/ios) Apple's marketing adds "color-coded icons" to locate accessories. [Apple Home app page](https://www.apple.com/home-app/)

### Empty states

**FACT.** The only documented action in a fresh home is **Add Accessory** from the Home view or the + menu. [Apple iPad — Set up accessories](https://support.apple.com/guide/ipad/set-up-accessories-ipad395134af/ipados)

### Tablet layout

**FACT.** iPad uses a **sidebar** holding Home, categories and each room ("Tap a room in the sidebar"). [Apple iPad — Intro to Home](https://support.apple.com/guide/ipad/intro-to-home-ipad59e50d78/ipados)

### Dark mode

Not documented in the reviewed Home-app pages.

---

## 4. Homey

### First-run journey

**FACT.** The listing's own summary of onboarding is "Log in, create a home and connect your devices – for free!"; the free tier "allows up to 5 connected devices and an unlimited number of Flows". The listing leads with "BEAUTIFUL CONTROLS FOR ANY DEVICE" and "PRIVACY BUILT-IN. SECURE BY DESIGN." Snapshot 2026-09-26: 4.3★, 7.09K reviews, 100K+ downloads, updated Sep 1, 2026. [Homey on Play](https://play.google.com/store/apps/details?id=app.homey&hl=en)

**FACT (snippet-verified only; support.homey.app returns 403 to automated fetches).** After login "you'll see Homey's home screen, which includes quick actions to control your devices or start favorite Flows, along with a timeline of recent updates"; the tab bar is **Devices**, **Flows**, **Energy**, **More (…)**. [Homey Support — Set up your Homey Bridge](https://support.homey.app/hc/en-us/articles/26761002278556-Set-up-your-Homey-Bridge)

### Home-screen IA

**FACT.** "By default the Devices screen shows all your devices"; tapping the title shows zones, and zones are hierarchical: "selecting First Floor shows all devices in First Floor, but also Bedroom, Bathroom and Study". "Many of them show their live color, temperature and on/off status." [Homey blog — v2.0](https://homey.app/en-us/blog/homey-v2-0-devices-flow/) Later releases added widgets inside the Devices tab ("Lights, Activity, Speakers, and Energy" in v7.3.0; Climate in v8.0.0), zone sorting and battery status (v9.8.0), hiding devices (v9.9.0), user dashboards with widgets (v9.0.0). [Homey changelog](https://homey.app/en-us/wiki/homey-mobile-app-changelog/)

### Tile / card anatomy

**FACT.** v10.0.0: "Device tiles now show quick actions, status, and context menus. Quick Actions now live behind a button in the top-right corner of each device tile, while tapping the tile directly opens the device controls." and "The status indicator has moved to the bottom of the tile, creating more room for useful information". [Homey changelog](https://homey.app/en-us/wiki/homey-mobile-app-changelog/) App Store notes confirm v10.0.0 "Device Quick Actions" and v10.1.1 "pull-down search". [Homey on App Store](https://apps.apple.com/us/app/homey-a-better-smart-home/id1435800024)

### Empty states / Tablet layout

Not documented in reviewed sources.

### Dark mode

**FACT.** v7.2.0: "you can enable Dark mode in the app or let it automatically follow your operating system's appearance settings." [Homey changelog](https://homey.app/en-us/wiki/homey-mobile-app-changelog/)

---

## 5. IoT MQTT Panel (UI dimensions only)

**FACT.** The listing promises "Material design", "Flexible panel width, merge any panels", "More than 250 icons", "Dark theme for comfortable use in low light", and clone/import-export; the Play page offers separate Phone and Tablet screenshot sets. Ratings block on 2026-09-26 shows 4.9★ / 3.2K reviews; updated Aug 28, 2026. [IoT MQTT Panel on Play](https://play.google.com/store/apps/details?id=snr.lab.iotmqttpanel.prod&hl=en) The setup model (Connection → Dashboard → Panel, all manual) and its consequences are in the prior benchmark. [Prior benchmark](../../research/iot-mqtt-panel-competitor-benchmark.md)

**Evidence gap.** First-run screens and empty-state copy are not documented in the listing, and the official guide (`blog.snrlab.in`) did not resolve today.

---

## 6. MQTT Dash

**FACT.** The listing opens with "Warning: This app is for nerds only :) If you don't know what MQTT is, this app is likely not for you." It claims "Phones and tablets are supported in both orientations", "Simple and easy to use dashboard-like UI", "Designed to run 24/7", JavaScript scripting, no ads. Snapshot: 4.8★, 5.72K reviews, 100K+ downloads, **updated Mar 2, 2017**. [MQTT Dash on Play](https://play.google.com/store/apps/details?id=net.routix.mqttdash&hl=en)

**FACT.** A third-party walkthrough shows the journey: launch, create a connection by entering the broker IP (credentials optional), then on the dashboard "create buttons and indicators" one at a time, each bound to a topic and payload. [CDP Technologies wiki](https://github.com/CDPTechnologies/MQTTSnake/wiki/Setting-up-MQTT-Dash-on-your-phone)

**INFERENCE.** MQTT Dash is the control case: an app that has not shipped since 2017 still holds 4.8★ with 100K+ installs because its audience is self-selected. ZigDash's retention problem (DAU/MAU 6% once discovery traffic arrived, per MAP) is the opposite audience; copying maker-tool IA would not fix it.

---

## 7. Zigbee2MQTT web frontend

**FACT.** Zigbee2MQTT ships "a built-in web-based frontend" on port 8080 with two packages: `zigbee2mqtt-frontend` ("The original frontend (legacy)") and `zigbee2mqtt-windfront` ("A remake of the original frontend with new code, new design, new features"); "The features, links and general design in each package will vary." [Z2M frontend docs](https://www.zigbee2mqtt.io/guide/configuration/frontend.html)

**FACT.** windfront's page set is Devices, Dashboard, Groups, Network map, OTA, Touchlink, Logs, Settings; it offers "35 themes offered by the design library" (daisyUI). [windfront README](https://github.com/Nerivec/zigbee2mqtt-windfront) Its wiki: "Cards and tiles get a border according to their device's status. Red = offline, dotted orange = disabled"; the Devices table supports column sorting and Shift-multi-sort; search is persisted per page; a notifications drawer lists recent messages. [windfront wiki](https://github.com/Nerivec/zigbee2mqtt-windfront/wiki)

**FACT.** On the legacy Dashboard tab "each card exposes possible interactions and data coming from each device"; all devices appear; "cards can't be arranged in custom orders"; a search box filters; some devices need an initial press before state is known. [NotEnoughTech](https://notenoughtech.com/home-automation/zigbee2mqtt-dashboard/)

**INFERENCE.** The Z2M frontend is what ZigDash's users already know. Two things carry over: the device is the unit (one card per device with all exposes, no per-panel setup), and offline/disabled is a *border treatment on the card*, not a banner. What does not carry over: it is an admin table first, with no rooms, no favorites, and no phone-first layout.

---

## 8. Platform guidance that bounds the options

**FACT.** Window size classes: compact < 600 dp (99.96 % of phones in portrait), medium 600–839 dp (93.73 % of tablets in portrait), expanded 840–1199 dp (97.22 % of tablets in landscape), large 1200–1599, extra-large ≥ 1600. [Android — window size classes](https://developer.android.com/develop/ui/compose/layouts/adaptive/use-window-size-classes) The default adaptive navigation is a **navigation bar** "if the width or height is compact or if the device is in tabletop posture" and a **navigation rail** "for everything else". [Android — adaptive navigation](https://developer.android.com/develop/ui/compose/layouts/adaptive/build-adaptive-navigation) Canonical layouts: list-detail (list pane + detail pane, both visible on expanded), supporting pane (primary ~2/3 + secondary), feed (adaptive grid, `GridCells.Adaptive(minSize = 180.dp)`). [Android — canonical layouts](https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts)

**FACT.** Material's empty-state guidance: a basic empty state is a subtle image plus a positive tagline; prefer **starter content** ("allow users to explore your app right away") or **educational content** ("help users understand what they'll be able to do on this screen once it has content"); avoid bright imagery or taglines phrased as calls to action. [Material — Empty states](https://m1.material.io/patterns/empty-states.html)

---

## 9. Patterns worth adopting for ZigDash

Each is compatible with the protected set (dynamic color, RTL, the 16 panel behaviours, no telemetry, no accounts). Source app in brackets.

1. **One door, discovery first, three outcomes.** After a single welcome screen, scan the network; show *one broker found* / *several* / *none — enter address*, and go straight to login only if the broker asks for it. [HA Companion] ZigDash already has the scan (`broker_scan_sheet.dart`) but it lives behind a form and after a three-page carousel. **INFERENCE:** promote it to the second screen.
2. **A generated first surface.** Prepopulate from discovered Zigbee2MQTT devices grouped by room (Z2M has no rooms, so group by device type first and let the user assign rooms) with a "For You / Unsorted devices" section that asks one question per device. [HA 2026.2, Homey, Z2M dashboard]
3. **Status row with counts at the top of the home surface** ("Lights — 3 on", "Covers — 2 open", "Sensors — 1 low battery"), each tapping into a filtered view grouped by room. [Apple; HA summaries; Google category dashboards]
4. **Favorites pinned above everything, any entity pinnable.** [HA, Google, Apple, Homey]
5. **One tile contract across all 16 panel behaviours:** icon = quick action with a circular tap affordance, body = open controls, long-press = edit/settings; active colour by device class; state text on one line; optional feature row (brightness, cover open/stop/close or position, bar gauge, trend). [HA Tile, Apple, Homey v10]
6. **Offline / stale as a tile treatment, not only a banner.** Red border for offline, dotted for disabled; keep the connection banner for the broker level. [windfront]
7. **Comfort badges on room headers** (temperature, humidity) picked from the room's sensors, editable. [HA 2025.4]
8. **Empty states as starter content.** ZigDash's demo mode is exactly Material's "starter content"; use it as the empty state of the dashboard surface instead of a text-only "No dashboards yet." [Material; HA "For You"]
9. **Tablet: navigation rail at ≥ 600 dp, sidebar-style room/category list on expanded, more grid columns rather than wider tiles.** [Android guidance; Apple iPad; HA Sections]
10. **Dark mode follows the system with an in-app override** (Homey pattern) — cheap, and the wall-tablet case wants a forced dark. [Homey, HA]

## 10. Patterns to avoid

1. **Connection-first IA.** No reference opens on a list of servers; HA has multi-server support but still lands on the dashboard. ZigDash's Brokers / Dashboards / Settings bar, with the Dashboards tab empty until a broker is opened, has no counterpart in any surveyed app. **INFERENCE:** the single-broker user (the common case) should never see the word "broker" on the home screen.
2. **Feature-carousel onboarding.** None of the references shows multi-page feature slides before the first action; Apple and HA go straight to the setup assistant. Three pages of "Skip / Next / Get Started" delay the first success.
3. **Blank-grid start.** IoT MQTT Panel and MQTT Dash start empty by design and say so ("for nerds only"); that audience is not the one ZigDash loses.
4. **Admin-table-as-home.** The Z2M frontend's Devices table is right for an admin tool and wrong for a control surface; keep a Devices list, but not as the landing screen.
5. **Patterns that need an account or cloud** (Google's Ask Home, Apple's suggested automations from iCloud, Homey's timeline synced through the cloud) are out by the no-telemetry / no-account constraint even where the UX is good.
6. **Five-tab bars.** Google went from five tabs to three in 2025 and moved Favorites / Devices / dashboards into swipeable sections of one Home tab; HA and Apple use one home surface plus a sidebar. Do not add tabs (Devices, Scenes) to fix the IA.
7. **Non-reorderable generated dashboards.** The Z2M dashboard "can't be arranged in custom orders"; HA solves this with "take control" (auto-updates stop) and drag-and-drop in Sections. Whatever ZigDash generates must stay editable without losing auto-updates for new devices, or say clearly when it does.

## 11. Open questions for the next tickets

### For [04 — Decide the first-run journey](../tickets/04-decide-first-run-journey.md)

| Sub-question in the ticket | Candidate answer from the benchmark | Still open |
|---|---|---|
| Demo-first or setup-first? | No reference offers a demo; all are setup-first with discovery as screen 2 (HA). Material calls demo content "starter content" for empty states, not a door. | Whether ZigDash keeps "Try demo" as a secondary link on the discovery screen or moves it to the empty dashboard state. |
| Guided setup the only door? | HA: yes, with "Enter address manually" inside the flow, not beside it. | Where TLS / websocket / client-cert live (HA hides them behind the URL; the prior benchmark says keep them as an expert path). |
| What shows while the broker is unreachable? | Not documented by any reference; windfront's per-card offline border is the nearest pattern. | Whether the last-known state stays visible and greyed (HA "last_changed" state content) or the surface is replaced by a diagnostic screen. |
| One tap to the dashboard for a single-broker user | Every consumer reference: app opens on the home surface, no server pick. | Whether multi-broker users get a home switcher in the header (Google "Switch home") or a rail destination. |
| Success screen that ends the journey | HA: lands on the prepopulated dashboard; Apple: the new accessory appears in its room; no reference shows a "You're done" page. | Whether "first device toggled" should be celebrated at all, or whether the generated dashboard *is* the success screen. |
| Which step counts as a session for the review prompt | Not answerable from references. | Depends on the previous row. |
| Scenarios: no Z2M yet / auth / wrong Wi-Fi / wall tablet | HA names each discovery outcome; "no Z2M" has no analogue (HA discovers itself). | Copy and next action for "broker found but no Zigbee2MQTT bridge topics". |

### For [05 — Decide the information architecture](../tickets/05-decide-information-architecture.md)

| Sub-question in the ticket | Candidate answer from the benchmark | Still open |
|---|---|---|
| Does Brokers / Dashboards / Settings survive? | No reference has a server tab. Google: Home / Activity / Automations; Homey: Devices / Flows / Energy / More; HA: one dashboard + sidebar. | Whether ZigDash goes to a single Home surface with sections (Google 2025) or a Home + Devices + Scenes bar (Homey-like). |
| Home for one broker vs several | One broker: the home surface. Several: Google's "Switch home" in the account menu; HA's per-server switch inside the companion app. | Whether a broker is a "home" (switcher) or a section on one surface. |
| Where Devices and Scenes live | Devices: Homey and Google keep a full device list one swipe/tap from home; scenes: Apple puts Scenes as a section of the home surface, Google puts them under Automations. | Whether Scenes are a home section (Apple) or an Automations-style destination. |
| Dashboards vs rooms vs devices | HA: rooms are the default grouping, user dashboards are optional extras; Apple/Google/Homey: rooms, with favorites on top; Z2M has no rooms. | Whether ZigDash keeps user dashboards as the primary object or demotes them to "views" beside a generated room view (Z2M cannot supply rooms, so who assigns them, and how cheaply). |
| Tablet landscape | Rail at ≥ 600 dp (Android), sidebar with rooms/categories at expanded (Apple iPad), more grid columns (HA). | Whether the wall-tablet mode is the expanded layout with chrome hidden, or a separate presentation. |
| Vocabulary for `CONTEXT.md` | References use *home*, *room/area/zone*, *device*, *favorite*, *tile/card*, *dashboard/view*; none says *broker*, *connection* or *panel* to users. | Which of *dashboard / panel / tile / broker / connection* become internal-only terms. |

## Evidence limits

- Store ratings, review counts and update dates are snapshots taken 2026-09-26 and will change.
- Apple Home is a pattern reference; it cannot be installed on Android, and its dark-mode behaviour was not documented in the pages reviewed.
- `support.homey.app` blocks automated fetches (HTTP 403); the tab-bar and home-screen description was obtained from a search snippet of that page and is marked as such. The changelog and store listings were fetched directly.
- The IoT MQTT Panel guide did not resolve today (DNS); UI claims rely on the Play listing and the prior benchmark.
- Google's help pages describe the current three-tab design; screenshots and tablet layouts were not inspected visually. Tile visuals for all apps are described from text sources, not from screenshots.
- Where a cell says "not documented in reviewed sources", that is an evidence gap, not a claim that the app lacks the behaviour.

## Sources

- [Home Assistant Companion — Getting started](https://companion.home-assistant.io/docs/getting_started/)
- [Home Assistant — Dashboards overview](https://www.home-assistant.io/dashboards/)
- [Home Assistant — Predefined dashboards / Home dashboard](https://www.home-assistant.io/dashboards/dashboards/)
- [Home Assistant — Tile card](https://www.home-assistant.io/dashboards/tile/)
- [Home Assistant — Card features](https://www.home-assistant.io/dashboards/features/)
- [Home Assistant — Sections view](https://www.home-assistant.io/dashboards/sections/)
- [Home Assistant — Frontend integration (themes, dark mode)](https://www.home-assistant.io/integrations/frontend/)
- [Home Assistant 2025.4 release notes (Areas dashboard)](https://www.home-assistant.io/blog/2025/04/02/release-20254/)
- [Home Assistant 2025.9 release notes (Home dashboard, tile features)](https://www.home-assistant.io/blog/2025/09/03/release-20259/)
- [Home Assistant 2025.12 release notes](https://www.home-assistant.io/blog/2025/12/03/release-202512/)
- [Home Assistant 2026.2 release notes (Home becomes Overview)](https://www.home-assistant.io/blog/2026/02/04/release-20262/)
- [Google — Set up the Google Home app / a device](https://support.google.com/googlenest/answer/7029485)
- [Google — Meet the Google Home app](https://support.google.com/googlehome/answer/7071794?hl=en)
- [Google — Organize your homes and devices](https://support.google.com/googlenest/answer/15559809?hl=en)
- [Google blog — New Google Home app, redesigned for Gemini (2025-10-01)](https://blog.google/products-and-platforms/devices/google-nest/google-home-app-gemini-redesign/)
- [9to5Google — Google Home app redesign leaves beta (2023-05-10)](https://9to5google.com/2023/05/10/google-home-app-redesign-public/)
- [9to5Google — Google Home 'Ask Home' redesign on iPhone (2025-09-27)](https://9to5google.com/2025/09/27/google-home-ask-redesign-iphone/)
- [9to5Google — Google Home 2.27 dark theme (2020-08-25)](https://9to5google.com/2020/08/25/google-home-2-27-dark-theme/)
- [Apple — Control accessories with Home on iPhone](https://support.apple.com/guide/iphone/control-accessories-iph0a717a8fd/ios)
- [Apple — Intro to Home on iPad](https://support.apple.com/guide/ipad/intro-to-home-ipad59e50d78/ipados)
- [Apple — Set up accessories with Home on iPad](https://support.apple.com/guide/ipad/set-up-accessories-ipad395134af/ipados)
- [Apple — Home app product page](https://www.apple.com/home-app/)
- [Homey — Google Play listing](https://play.google.com/store/apps/details?id=app.homey&hl=en)
- [Homey — App Store listing](https://apps.apple.com/us/app/homey-a-better-smart-home/id1435800024)
- [Homey — Mobile app changelog](https://homey.app/en-us/wiki/homey-mobile-app-changelog/)
- [Homey — Blog: Homey v2.0 Devices & Flow](https://homey.app/en-us/blog/homey-v2-0-devices-flow/)
- [Homey Support — Set up your Homey Bridge (snippet-verified; 403 to fetchers)](https://support.homey.app/hc/en-us/articles/26761002278556-Set-up-your-Homey-Bridge)
- [IoT MQTT Panel — Google Play listing](https://play.google.com/store/apps/details?id=snr.lab.iotmqttpanel.prod&hl=en)
- [MQTT Dash — Google Play listing](https://play.google.com/store/apps/details?id=net.routix.mqttdash&hl=en)
- [CDP Technologies — Setting up MQTT Dash on your phone](https://github.com/CDPTechnologies/MQTTSnake/wiki/Setting-up-MQTT-Dash-on-your-phone)
- [Zigbee2MQTT — Frontend configuration](https://www.zigbee2mqtt.io/guide/configuration/frontend.html)
- [zigbee2mqtt-windfront — README](https://github.com/Nerivec/zigbee2mqtt-windfront)
- [zigbee2mqtt-windfront — Wiki](https://github.com/Nerivec/zigbee2mqtt-windfront/wiki)
- [NotEnoughTech — "Secret" Zigbee2MQTT dashboard](https://notenoughtech.com/home-automation/zigbee2mqtt-dashboard/)
- [Android — Window size classes](https://developer.android.com/develop/ui/compose/layouts/adaptive/use-window-size-classes)
- [Android — Build adaptive navigation](https://developer.android.com/develop/ui/compose/layouts/adaptive/build-adaptive-navigation)
- [Android — Canonical layouts](https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts)
- [Material Design — Empty states](https://m1.material.io/patterns/empty-states.html)
- [Prior ZigDash benchmark — IoT MQTT Panel (features)](../../research/iot-mqtt-panel-competitor-benchmark.md)
