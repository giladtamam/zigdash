# ZigDash information architecture (redesign target)

Decided 2026-09-26 in the redesign map's "Decide the information architecture" and "Decide the first-run journey" tickets. Vocabulary follows [`CONTEXT.md`](../../CONTEXT.md): users see *home*, *dashboard*, *tile*, *device*, *scene*; *broker* appears only in setup and connection settings.

## Structure

```
App launch
 ├─ First run ──► Setup (single flow, outside the navigation shell)
 │                 Welcome ─► "Find my setup" (scan)
 │                   ├─ one broker ──► [login if asked] ──► Review devices ──► Dashboard
 │                   ├─ several ─────► pick one ──────────────────┘
 │                   ├─ none ────────► Enter address · Try demo
 │                   └─ broker, no Zigbee2MQTT ─► base topic · setup guide · Try demo
 │
 └─ Returning ──► last-used Dashboard of the current Home

Navigation shell (one Home at a time)
 Header:  [Home switcher ▾]  Dashboard title  ........  [Edit] [Settings] [⋮]
 Destinations (bottom bar on phone, navigation rail at ≥ 600 dp):
 ├─ Dashboards
 │    ├─ tab strip only when the home has ≥ 2 dashboards
 │    ├─ Sections (e.g. Lights, Covers, Sensors) ─► Tiles
 │    ├─ Edit mode: drag handles, tile edit badge, "Add tile", "Add section",
 │    │             dashboard name / lock / color in a header sheet
 │    └─ ⋮ overflow: Add dashboard · Backup · Restore
 ├─ Devices   (list; list-detail panes when expanded)
 └─ Scenes    (list; list-detail panes when expanded)

 Settings (header icon, full screen)
 ├─ Homes: list, add (runs Setup), edit connection (broker details live here)
 ├─ Appearance · Language (single row opening a picker)
 └─ About · Rate ZigDash · Help
```

## Rules

- **Home = last-used dashboard.** No server list on launch. Several homes switch in the header.
- **Dashboards are the primary object.** No rooms. Generated dashboards are split into sections by device type; users rename or regroup freely.
- **Normal use is chrome-light.** Only Edit, Settings and overflow sit in the header; no FAB outside edit mode. Long-press on a tile jumps straight into editing that tile.
- **Offline:** last-known values stay visible, stale marked per tile, plus a slim "Can't reach your broker" line with "Why?" to diagnostics. No full-screen takeover, no overlay chips.
- **Demo:** demo dashboards carry a persistent "Connect your home" bar; real setup removes the demo home.
- **Window sizes:** compact (< 600 dp) bottom bar, 2-column grid; medium rail, 3 columns; expanded rail, 4 columns and list-detail for Devices and Scenes. Tile widths (full, half, third) are relative to the grid.

## New data implied (build note)

- **Section** within a dashboard (name, order) — not in the schema today.
- **Current home** selection persisted, replacing "open a broker from the list".
- Everything else maps onto existing tables (`connections`, `dashboards`, `panels`, `scenes`).

## Not decided here

- The add-to-dashboard flow (device-first vs tile-type-first) — its own ticket.
- A dedicated wall-tablet presentation (always-on, dimming, hidden chrome) — still in the map's fog.
- Visual treatment of tiles, sections and stale state — directions and tokens tickets.
