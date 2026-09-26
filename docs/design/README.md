# ZigDash 2.0 redesign spec

This is the handoff from design to release work. It collects the decisions made on 2026-09-26 and points to where each one is written down in full. The redesign ships in five releases, from 1.10 to 2.0. The plan is in [phasing.md](phasing.md).

## Why

Play Console numbers at the start of the redesign:

| Measure | Value |
|---|---|
| Install base | about 70 |
| Store listing conversion | 49% |
| DAU/MAU | 6.3% |
| Monthly user loss | 6.8% |

People who find the listing install the app, but few come back. The redesign is judged on **retention first** and listing conversion second. The [UI audit](audit.md) of 1.9.2 found why new users stall. The app opens on a list of brokers, with a dead-end Dashboards tab. A carousel comes before the first action. The toolbar has six icons. Offline state hides tiles, and adding a tile means choosing an MQTT panel type.

## Principles

1. **Open on something useful.** The first screen after setup is a generated dashboard, not a list of connections.
2. **One door.** Setup has a single entry point, "Find my setup", with manual and advanced paths inside it.
3. **Devices first, MQTT second.** Users pick devices. Raw topics stay one tap away under "Custom MQTT tile".
4. **Show the last known value.** When the broker is unreachable, tiles keep their last values, marked stale, under a slim status line.
5. **One way to edit.** One Edit mode replaces the per-screen toolbar icons.
6. **Protected.** Material You dynamic color, Hebrew right-to-left, all eight locales, system font scaling, the 16 panel behaviors, and no telemetry.

## Decisions

| Area | Decision | Detail |
|---|---|---|
| First run | One door with four discovery outcomes: one broker, several, none, or broker without Zigbee2MQTT. A device review list, then straight to the dashboard. The demo appears only on the none-found and no-Zigbee2MQTT outcomes, with a persistent connect bar. | [ia.md](ia.md), First-run section below |
| Structure | Dashboards stay primary, with no rooms. A broker is a "home", switched in the header. The bottom bar is Dashboards, Devices and Scenes. Settings sits in the header. | [ia.md](ia.md), [ADR 0001](../adr/0001-dashboards-not-rooms.md) |
| Adding tiles | "Add tile" is device-first. Each device gets one composite device tile, in 7 classes plus a generic fallback. A new reading tile shows numeric sensors. The 16 raw types sit under "Custom MQTT tile" with a form that leads with the topic. | Adding tiles section below |
| Visual direction | 2.0 is **Signal**: a warm ground, amber fill when on, squircle tiles and a bold display face. It takes the tablet layout from Wall Panel. Calm Material is the interim look until 2.0. | [Claude Design canvas](https://claude.ai/artifact/Gt1x8Q8TpDfY2VMVqNqF5w) |
| Tokens | Amber is a harmonized accent over dynamic color. Fonts are Space Grotesk, IBM Plex Sans and IBM Plex Sans Hebrew. There are six state roles. Radii are 28, 18, 12 and 20. The grid has 2, 3 or 4 columns. Icons are Material Symbols Rounded. | [tokens.md](tokens.md), [ADR 0002](../adr/0002-amber-is-a-harmonized-accent.md) |
| Screens | There are nine Signal boards, each with a per-screen note. The dashboard, dark offline, welcome and dark tablet boards from the direction round complete the set. | [screens.md](screens.md) |
| Phasing | There are five production releases. Flutter 3.47 is installed for ZigDash only, before golden baselines. Golden, dynamic-color and CI gates run on every release. There is an internal-track device check, then 100% rollout. | [phasing.md](phasing.md) |

### First run

- **Welcome.** One screen with one action, "Find my setup", which scans the local network immediately. "Enter address instead" and "Advanced" (TLS, WebSocket, remote host) sit inside the flow. The carousel is removed. Setup runs outside the navigation shell.
- **Outcomes.**
  - One broker found continues.
  - Several brokers found asks the user to pick one.
  - None found offers "Enter address" and a small "Try demo".
  - A broker that answers with no Zigbee2MQTT on its bridge topic gets its own screen. It offers a base-topic retry, setup guides and the demo.
  - Login appears only if the broker asks for it.
- **End of setup.** A device review list ("choose what goes on your first dashboard") leads straight to the generated dashboard. The "Creating…" and "ready" screens are dropped.
- **Returning users** open the last-used dashboard of the current home.
- **Demo mode** stays marked with a "Connect your home" bar. Completing real setup deletes the demo connection.
- **Successful session** is a calendar day on which a command got a confirming state update. It feeds the local review prompt.

### Adding tiles

- **Add tile** opens a searchable device list. Devices not on any dashboard come first. Picking a device adds its recommended tile, which can be changed before saving.
- **Device tiles:** the icon is the quick action, the body holds the controls, and long-press edits the tile. The first release covers these classes:
  - light
  - switch or plug
  - cover
  - climate sensor
  - contact
  - motion
  - leak or smoke
  - a generic fallback

  Thermostats and color lights come later.
- **Reading tile:** a numeric value with its unit, for temperature, humidity or power.
- **Custom MQTT tile:** the 16 existing types. The form leads with name and topic and offers "Pick a device". A live preview comes before the payload fields. Payloads and JSON path collapse under Advanced.
- **New devices** are never auto-added. Edit mode shows a card counting unassigned devices, and the Devices tab carries a badge.

## Where everything lives

| What | Where |
|---|---|
| Glossary: home, dashboard, section, tile kinds, device, successful session | [CONTEXT.md](../../CONTEXT.md) |
| Audit of 1.9.2 with 18 findings and screenshots | [audit.md](audit.md), [audit/](audit/) |
| Information architecture diagram | [ia.md](ia.md) |
| Design tokens | [tokens.md](tokens.md) |
| Per-screen notes and exported images | [screens.md](screens.md), [screens/](screens/) |
| Phases, guardrails, store and community plan | [phasing.md](phasing.md) |
| Decision records | [docs/adr/](../adr/) |
| Research: reference smart-home UIs | [research/reference-ui-benchmark.md](research/reference-ui-benchmark.md) |
| Research: Material 3 Expressive and Flutter feasibility | [research/m3-expressive-flutter-feasibility.md](research/m3-expressive-flutter-feasibility.md) |
| Mockups: three directions plus the Signal screens | [Claude Design canvas](https://claude.ai/artifact/Gt1x8Q8TpDfY2VMVqNqF5w), private to the owner until shared |

## Open, decided later

These are in scope for 2.0 but not designed yet. They get decided in the phase that needs them.

- **Thermostat and color-light tiles** need their own control design.
- **Wall-tablet kiosk presentation** covers always-on use, screen dimming and hidden chrome. The layout is set, the presentation is not.
- **Motion** for tile state changes and banner transitions uses M3 easing and spring tokens.
- **Launcher icon and Play feature graphic** in the Signal identity.
- **An accessibility pass** beyond the three audit defects, including contrast under dynamic color.
- **Localized store screenshots** in French, German, Spanish and Hebrew, at 2.0.

## Out of scope

- iOS and other platforms.
- A Flutter rewrite or leaving Material 3.
- New features beyond UX: widgets, automations, rooms.
- In-app analytics or A/B tests, which the no-telemetry rule excludes.
- Paid design tooling.

## Next: release 1.10, Foundations

1. Install Flutter 3.47 for ZigDash only, move Java to 17, migrate to RadioGroup, and bump dynamic_color to ^1.9.0.
2. Add a GitHub Actions workflow for analyze and test.
3. Add the alchemist golden harness and record baselines of today's UI.
4. Fix the three accessibility defects and the MQTT client-id takeover loop.
5. Ship through the internal track and the device check, then 100% production.
