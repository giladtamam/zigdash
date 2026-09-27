# ZigDash redesign: phasing and guardrails

How the redesign spec becomes releases. Decided 2026-09-26 in the wayfinder ticket "Decide implementation phasing and regression guardrails".

## Phases

Each phase ships to production on its own. The order is set by where users are lost: first run leaks the most, so it goes first. The Signal identity is held for a named 2.0 so the launch posts have something to headline.

| Phase | Release | Contents | Look | Exit criteria |
|---|---|---|---|---|
| 0 Foundations | 1.10 | Flutter 3.47 for ZigDash only, dynamic_color ^1.9.0, Java 17, RadioGroup migration; the three accessibility defects; the MQTT client-id takeover bug; CI workflow; golden harness with baselines of today's UI | current | CI green; baselines committed; no visual change except the surface fix under dynamic color; strict-broker connect works on a device |
| 1 First run | 1.11 | "Find my setup" single entry point; none-found and no-Zigbee2MQTT outcomes; demo with persistent connect bar; home opens the last-used dashboard | interim A | Goldens for every first-run outcome; a fresh install on a device reaches a dashboard with a real broker and with the demo |
| 2 Dashboard | 1.12 | Dashboards / Devices / Scenes bar; homes in the header; Edit mode; device-first Add tile; device and reading tiles; last-known values when offline | interim A | Existing dashboards migrate with no lost tiles; all 15 raw panel types still reachable under Custom MQTT tile (build spec: [dashboard-1.12.md](dashboard-1.12.md)); offline shows last-known values |
| 3 Devices and tablet | 1.13 | Devices tab and device page; Settings with homes; navigation rail and 2/3/4-column grid | interim A | Tablet goldens; health flags match Zigbee2MQTT availability and battery data (build spec: [devices-tablet-1.13.md](devices-tablet-1.13.md)) |
| 4 Identity | 2.0 | Signal tokens: Space Grotesk and IBM Plex fonts, amber active fill, squircle tiles, filled-when-active icons, dark default on tablets; launcher icon and feature graphic; new store screenshots; launch posts | Signal | Goldens re-baselined once, reviewed board by board against the canvas; Hebrew and dynamic-color passes |

## Flutter upgrade

- **Upgrade before any redesign code.** ZigDash moves to Flutter 3.47.x in phase 0, before golden baselines are recorded, so they are not thrown away later.
- **Project-local SDK.** Install 3.47 for ZigDash only, with fvm or a second SDK checkout. face_yoga, hitbonenut and pl-predictor keep 3.32.5.
- **Same step.** dynamic_color ^1.9.0, Java 17 in the Android build, RadioListTile to RadioGroup. This also clears Play's deprecated edge-to-edge API warning.
- **Not yet.** The move to the standalone material_ui package, and dynamic_color 2.x, wait until after 2.0.

## Guardrails that gate every phase

- **Golden tests.** alchemist in two tiers: layout goldens in the square test font, and Linux-only goldens with real fonts for typography.
- **Golden matrix.** Screens: first run, dashboard, edit mode, Add tile, Devices, device page, Settings. Variants: light and dark, English and Hebrew, text scale 1.0 and 2.0, phone and tablet.
- **Dynamic color.** Goldens run under two fixed wallpaper schemes plus the fallback scheme.
- **CI.** A GitHub Actions workflow runs analyze and test, goldens included, on every pull request and push to main.
- **Device check.** Before production, each build goes to the Play internal track and is checked on a physical phone. The check covers TalkBack, Hebrew, and a connect to a strict broker.
- **Rollout.** Straight to 100% production after the device check. No staged rollout and no beta track: at about 70 installs a staged slice is too small to signal anything. If a release goes bad, the fix is a quick follow-up release.

## Store assets and measurement

- **Screenshots change once, at 2.0.** They are captured on a device or emulator, because web builds draw squircles as plain rounded rectangles.
- **Localized screenshots** follow at 2.0: French, German, Spanish and Hebrew first.
- **No Play listing experiment.** Traffic is too low for a result. Compare listing conversion over the 28 days before and after the swap instead.
- **Retention is the primary measure.** Track DAU/MAU and monthly user loss in Play Console after each phase. There is no in-app telemetry.

## Community reaction round

- **When.** During phase 2, before any Signal code exists.
- **Where.** Zigbee2MQTT GitHub Discussions and the Home Assistant community thread.
- **What is shown.** Board images of the dashboard, Devices, the dark tablet, and the Hebrew dashboard.
- **What it asks.**
  1. What would stop you from switching your daily dashboard to this?
  2. Which of your devices has no sensible tile here?
  3. Tablet on the wall: light or dark?
- **Rule.** It asks for reactions, not votes. Anything that changes a decision reopens that decision's ticket.
