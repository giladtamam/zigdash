# ZigDash 2.0 design tokens — "Signal"

Decided 2026-09-26 in the redesign map's "Decide the design system tokens" ticket. Direction: B · Signal identity, C · Wall Panel tablet layout (see the directions canvas). Protected throughout: Material You dynamic color, RTL, all eight locales, system font scaling.

Implementation shape (from the Flutter feasibility research): shape tokens on `ThemeData` component themes; a `TextTheme` override; state colors as a `ThemeExtension` built with `harmonizeWith(primary)`; directional radii everywhere.

## Color

**Fallback palette** (Material You off): seed and roles derived from Signal's ivory, ink and amber.

| Token | Light | Dark |
|---|---|---|
| ground | #F6F3EC | #15130F |
| tile (idle) | #FFFFFF + 1 dp #E7E1D4 hairline | #211E18 + 1 dp #2F2B24 hairline |
| ink (text) | #1C1A16 | #EFE9DD |
| ink variant (secondary text) | #5B5446 | #A79F90 |
| amber (active fill) | #F5C878, ink on top | #F0A544, ink #1C1A16 on top |

**With Material You on:** surfaces, navigation and buttons follow the wallpaper scheme. The **active** fill stays amber, harmonized toward the wallpaper's primary (max ~15° hue shift).

**State roles** (`ThemeExtension`, each a container + on-container pair, all harmonized):

| Role | Meaning | Treatment |
|---|---|---|
| active | on / open | amber fill, ink content, filled icon |
| idle | off / closed | tile surface, outlined icon |
| stale | value older than the connection | desaturated surface, hatched pattern in dark, age pill, dashed quick action |
| attention | low battery, leak, door open too long | harmonized orange-red text/badge; differs from amber in lightness |
| offlineDevice | device reports unavailable | outline only, muted text |
| healthy | online indicators | harmonized green, sparingly |

**Per-dashboard color:** the existing six swatches become an **accent only**: title, active tab indicator, section headers, harmonized. They no longer replace the scheme or the active fill. No data migration.

Replaces the 11 hard-coded `Colors.*` uses. `dynamic_color` moves to `^1.9.0` so Material You dark gets real container steps.

## Shape

Squircle (`RoundedSuperellipseBorder`) on Android; rounded rectangle elsewhere. All radii `BorderRadiusDirectional`.

| Component | Radius |
|---|---|
| Tile | 28 |
| Quick action inside a tile | 18 |
| Chips, summary pills, small buttons | 12 |
| Sheets, dialogs | 28 (top corners for sheets) |
| Primary buttons | 20 |
| Navigation indicator | 12 |

## Type

Fonts bundled (subset): **Space Grotesk** (display, Latin), **IBM Plex Sans** (body, Latin), **IBM Plex Sans Hebrew** (body and Hebrew display fallback). Roughly 300–400 KB.

| Role | Size (sp) / weight | Face | Use |
|---|---|---|---|
| Display | 34 / Bold | Space Grotesk | dashboard title |
| Reading | 40 / Bold (64 tablet) | Space Grotesk | sensor values |
| Title | 18 / SemiBold | Plex Sans | tile names on tablet, sheet titles |
| Tile name | 15 / SemiBold | Plex Sans | tile names on phone |
| Body | 15 / Regular | Plex Sans | copy |
| State | 13 / Regular | Plex Sans | tile state line |
| Section label | 13 / Bold, uppercase, +1.2 tracking | Space Grotesk | section headers; **no uppercase in Hebrew** |

Respects system font size up to 200%: tiles grow in height, never truncate.

## Spacing and grid

4 dp base.

| | Phone (< 600 dp) | Medium | Expanded (tablet) |
|---|---|---|---|
| Columns | 2 | 3 | 4 |
| Screen margin | 16 | 24 | 36 |
| Tile gap | 10 | 12 | 16 |
| Section gap | 12 | 12 | 16 |
| Tile min height | 118 | 140 | 176 |
| Quick action size | 48 | 56 | 64 |
| Navigation | bottom bar | rail | rail |

Tile widths (full / half / third) are relative to the grid. Tiles in one row match height.

## Dark mode

Warm near-black ground, tiles one step lighter with a 1 dp hairline, no shadows. Amber stays saturated with dark ink. Tablets default to dark (user can override); phones follow the system.

## Icons

**Material Symbols Rounded** (variable font), weight 400. Outlined for idle, **filled for active** (a second cue beyond color). One icon per device class; `matchTextDirection` on directional glyphs.

## Not decided here

- Motion tokens (springs, easing) — in the map's fog.
- Launcher icon and feature graphic in the new identity — in the fog.
