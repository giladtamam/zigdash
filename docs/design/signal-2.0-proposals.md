# 2.0 Signal — proposals (draft)

Status: **accepted by the user on 2026-09-27.** Decisions from the 2.0 design map (2026-09-27), kept here so they survive outside the gitignored wayfinder/ folder. The build spec replaces this file once the user accepts or overrides them. Base: [tokens.md](tokens.md), [ADR 0002](../adr/0002-amber-is-a-harmonized-accent.md), the Signal boards.

## Run the community reaction round



1. **Run it now, in parallel with the design tickets, and gate only the build on it.** 1.13 just shipped the structure; the round is about the Signal look, which is exactly what has no code yet.
2. **Claude drafts, the user posts.** Public posts under the user's name are the user's to send. Claude prepares the post text for both venues and exports the four boards as images.
3. **Window: 7 days.** Anything that contradicts a decision reopens that decision's ticket; silence changes nothing.
4. **The three questions** stay as written in phasing.md (switch-stopper, a device with no sensible tile, wall tablet light or dark).

## Decide icons: Material Symbols and stored code points



Facts checked 2026-09-27 in Flutter 3.47's icons.dart: every glyph has `_rounded` (filled) and `_outlined`, but only a few (e.g. lightbulb) have `_outline_rounded`. The device-class icons (toggle_on, roller_shades, sensor_door, directions_walk, thermostat, power_settings_new, devices_other, water_drop) do not. So Flutter's built-in font cannot give "rounded outline when idle, rounded filled when active" without mixing corner styles.

1. **App icons (device classes, navigation, chrome): a subset of Material Symbols Rounded,** bundled as our own font file (not the material_symbols_icons package), cut with fonttools to only the glyphs the app uses (~60) while keeping the variable FILL axis. Idle draws FILL 0, active FILL 1: the filled-when-active cue from tokens.md. Expected size: tens of KB, since we subset the font ourselves rather than relying on tree-shaking.
2. **User-picked icons** (dashboards, scenes, toggle/button tiles) stay MaterialIcons code points in the database. `materialIcon()` draws each through a generated table from regular to `_rounded` (built from icons.dart by a tool/ script), so every stored icon renders Rounded with nothing migrated. Code points missing from the table draw unchanged.
3. **The icon picker** offers the Rounded glyphs; what it stores stays a MaterialIcons code point.
4. **ADR 0005** records this split and the subset recipe (tool/fonts/).

## Decide the theme architecture



1. **One module, lib/core/theme/,** holding: tokens (colors, radii, spacing, type as constants), a SignalColors ThemeExtension with the six state roles (container + on-container each), and AppTheme.light/dark(dynamic:) building ThemeData with component themes (Card, Chip, Button, NavigationBar/Rail, BottomSheet, Dialog, Slider, Switch).
2. **Fallback scheme** from tokens.md when Material You is off; with it on, surfaces follow the wallpaper and the state roles are harmonized toward its primary (the dynamic_color package's harmonizeWith; ADR 0002 caps the shift at ~15°).
3. **Per-dashboard color becomes an accent only:** title, tab/chip indicator, section labels. It stops re-seeding the scheme and the active fill. No data change; existing colors are kept as accents.
4. **Every Colors.* use** moves to a state role; a lint-like test greps lib/ for Colors.red|green|orange|amber|blue|grey and fails if any return.
5. **Screens read roles, not hex:** tiles use SignalColors.of(context).active etc., so the dynamic-color and dark passes are one code path.

## Decide fonts: bundling, subsetting, Hebrew, size budget



1. **Bundle the TTFs in assets/fonts/, never google_fonts at runtime.** Runtime fetching calls Google's servers, which the no-telemetry rule rules out. All three fonts are SIL OFL; ship their licence files and register them with LicenseRegistry, so they appear on the licences page.
2. **Weights:** Space Grotesk 500 and 700; Plex Sans 400 and 600; Plex Sans Hebrew 400 and 600. Six files.
3. **Subset** with fonttools pyftsubset to Latin, Latin-1 Supplement, Latin Extended-A, General Punctuation, and the digits and units the app shows (°, µ, ³). Plex Hebrew also keeps the Hebrew block. Budget: ≤ 450 KB total. A script in tool/fonts/ reproduces the subset, and the same script cuts the Material Symbols subset (ticket 02). fonttools is not installed here; `pip install --user fonttools` needs no sudo.
4. **Fallback:** anything outside the subsets (Cyrillic device names, emoji) falls back to the platform font through fontFamilyFallback. Nothing renders as tofu.
5. **Hebrew:** Plex Sans Hebrew for body and display. Section labels are not uppercased or tracked in Hebrew (tokens.md).
6. **Text scale:** unchanged rules. Tiles grow, never truncate, up to 200%.

## Decide Signal tile anatomy and states



1. **Squircle tiles** (RoundedSuperellipseBorder, radius 28) with a 1 dp hairline, no elevation; quick action a squircle of radius 18 at 48/56/64 dp by window class.
2. **Active** = amber container + ink content + filled icon; **idle** = tile surface + outlined icon. Two cues, never colour alone.
3. **Stale:** desaturated surface, age pill, dashed quick-action outline; hatching only in dark (a subtle 45° pattern at 6% ink).
4. **Attention** (leak, low battery) uses the attention role in text and badge; the leak tile keeps its full alarm fill in the attention container.
5. **Custom panel types** get the same tile shell, surface and typography; their inner controls take the component themes. No per-type redesign.
6. **Boards:** redraw the 1.12 tile board and the 1.13 Devices/device page boards in Signal on the canvas ('2.0' row), light and dark, before code.

## Decide dark-by-default on tablets for new and upgrading users



Fact: SettingsController writes no theme key until the user changes it, so "no key" cannot tell a fresh install from an upgrader who never opened Settings.

1. **Only for fresh installs, defined as setup not yet completed** (`onboarding_complete` absent). When first-run setup or the demo completes on a tablet, write ThemeMode.dark into the theme setting. Upgraders already have `onboarding_complete` and keep exactly what they had: the seamless-update rule.
2. **Tablet** means the shortest side is ≥ 600 dp at that moment. The choice is an ordinary saved setting, visible and changeable in Settings, not a hidden rule.
3. Phones: System, as today.

## Decide motion



1. **Material 3 defaults, not springs:** Flutter's M3 easing/durations (emphasized 500 ms for containers, standard 300 ms for state). No custom physics.
2. **Tile state change:** the fill cross-fades amber↔surface in 200 ms and the icon swaps outlined↔filled with it.
3. **Reduced motion:** honour MediaQuery.disableAnimations — every animation becomes an instant change.
4. Nothing loops or pulses, except the leak alarm tile (a slow 2 s attention pulse, off under reduced motion).

## Decide 2.0 scope for thermostats and kiosk



1. **Thermostats: out of 2.0.** There is still no test device. Meanwhile they get the generic tile, and the device page shows a writable number as a slider. Revisit when a TRV is on the SMHUB.
2. **Kiosk: a minimal "Wall display" toggle in 2.0,** in each dashboard's ⋮ menu. It keeps the screen on while that dashboard is open and hides the header and rail until the screen is tapped. No dimming schedule, no lock-down. It adds one plugin, `wakelock_plus`, the only new dependency in the phase. It builds on the tablet layout that already exists.
3. Full kiosk (dimming, launcher replacement, admin lock) stays out of scope.

## Decide the accessibility and contrast pass



1. **Automated contrast test:** for the fallback scheme and the two golden wallpaper schemes, light and dark, assert every state-role pair and text-on-surface pair meets 4.5:1 (3:1 for ≥ 24 sp and icons). Runs in CI.
2. **Flutter's accessibility guideline matchers** (androidTapTargetGuideline, labeledTapTargetGuideline, textContrastGuideline) on each golden screen.
3. **Manual TalkBack pass** on the device check for 2.0 (the thing 1.13 could not do remotely): the user or Claude with TalkBack on, a script of 12 actions.
4. Findings go into the build as fixes, not tickets.

## Design the launcher icon and feature graphic



1. **Icon:** an amber squircle tile holding an ink "signal" glyph (three arcs over a dot), on the ivory ground. Adaptive foreground and background layers, plus a monochrome layer for Android 13+ themed icons.
2. **Feature graphic:** ivory ground, phone and tablet frames showing the Signal dashboard, and the ZigDash wordmark in Space Grotesk. No text beyond the name and a four-word tagline (localized).
3. **Drawn on the canvas** in a "2.0 assets" row. Export each layer as a 1024 px PNG (flutter_launcher_icons takes PNGs, not SVG), then generate the launcher icons with flutter_launcher_icons.

## Plan store screenshots and launch posts



1. **Capture on the phone** (and the 1280×800 emulated tablet from the 1.13 check) with the demo home, via adb scripts in tool/store/: 6 phone + 2 tablet shots per locale.
2. **Locales:** en, fr, de, es, he (the four from phasing.md plus English). nl, sv, nb keep English shots.
3. **Launch posts:** the same venues as the community round, drafted by Claude, posted by the user, the day 2.0 reaches 100%.
4. **Measurement:** note the 28-day listing conversion and DAU/MAU before release (Play Console statistics) in docs/growth/, re-read 28 days after.
