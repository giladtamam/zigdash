# 2.0 Signal — proposals (draft)

Status: **proposed, not approved.** Recommendations from the 2.0 design map (2026-09-27), kept here so they survive outside the gitignored wayfinder/ folder. The build spec replaces this file once the user accepts or overrides them. Base: [tokens.md](tokens.md), [ADR 0002](../adr/0002-amber-is-a-harmonized-accent.md), the Signal boards.

## Run the community reaction round



1. **Run it now, in parallel with the design tickets, and gate only the build on it.** 1.13 just shipped the structure; the round is about the Signal look, which is exactly what has no code yet.
2. **Claude drafts, the user posts.** Public posts under the user's name are the user's to send. Claude prepares the post text for both venues and exports the four boards as images.
3. **Window: 7 days.** Anything that contradicts a decision reopens that decision's ticket; silence changes nothing.
4. **The three questions** stay as written in phasing.md (switch-stopper, a device with no sensible tile, wall tablet light or dark).

## Decide icons: Material Symbols and stored code points



1. **Use Flutter's built-in Material Icons, Rounded variants, not the Symbols font.** They live in the same MaterialIcons font the app already ships, so stored code points stay valid and nothing migrates. The outlined/filled pairs (e.g. lightbulb_outline_rounded / lightbulb_rounded) give the filled-when-active cue.
2. **Device-class icons and app chrome** switch to the Rounded variants through one icon table; filled when active, outlined when idle.
3. **User-picked icons** keep their stored code point. The icon picker offers Rounded variants from now on; old picks keep drawing as they were (no forced change).
4. **Record the deviation** from tokens.md (Symbols → Material Icons Rounded) in an ADR: no new font (~3–4 MB saved), no code-point migration, same look at 400 weight. What is lost: variable weight/grade axes and a few newer glyphs.

## Decide the theme architecture



1. **One module, lib/core/theme/,** holding: tokens (colors, radii, spacing, type as constants), a SignalColors ThemeExtension with the six state roles (container + on-container each), and AppTheme.light/dark(dynamic:) building ThemeData with component themes (Card, Chip, Button, NavigationBar/Rail, BottomSheet, Dialog, Slider, Switch).
2. **Fallback scheme** from tokens.md when Material You is off; with it on, surfaces follow the wallpaper and the state roles are harmonized toward its primary (the dynamic_color package's harmonizeWith; ADR 0002 caps the shift at ~15°).
3. **Per-dashboard color becomes an accent only:** title, tab/chip indicator, section labels. It stops re-seeding the scheme and the active fill. No data change; existing colors are kept as accents.
4. **Every Colors.* use** moves to a state role; a lint-like test greps lib/ for Colors.red|green|orange|amber|blue|grey and fails if any return.
5. **Screens read roles, not hex:** tiles use SignalColors.of(context).active etc., so the dynamic-color and dark passes are one code path.

## Decide fonts: bundling, subsetting, Hebrew, size budget



1. **Bundle the TTFs in assets/fonts/, never google_fonts at runtime** — runtime fetching calls Google's servers, which the no-telemetry rule rules out. All three are SIL OFL; ship their licence files and list them in the app's licences page.
2. **Weights:** Space Grotesk 500 and 700; Plex Sans 400, 600; Plex Sans Hebrew 400, 600. Six files.
3. **Subset** with fonttools pyftsubset to Latin + Latin-1 Supplement + Latin Extended-A + General Punctuation + the digits/units the app shows (°, µ, ³) and, for Plex Hebrew, the Hebrew block. Budget: ≤ 450 KB total; a tool script in tool/fonts/ reproduces the subset.
4. **Fallback:** anything outside the subsets (Cyrillic device names, emoji) falls back to the platform font through fontFamilyFallback; nothing renders as tofu.
5. **Hebrew:** Plex Sans Hebrew for body and display; section labels not uppercased or tracked in Hebrew (tokens.md).
6. **Text scale:** unchanged rules; tiles grow, never truncate, to 200%.

## Decide Signal tile anatomy and states



1. **Squircle tiles** (RoundedSuperellipseBorder, radius 28) with a 1 dp hairline, no elevation; quick action a squircle of radius 18 at 48/56/64 dp by window class.
2. **Active** = amber container + ink content + filled icon; **idle** = tile surface + outlined icon. Two cues, never colour alone.
3. **Stale:** desaturated surface, age pill, dashed quick-action outline; hatching only in dark (a subtle 45° pattern at 6% ink).
4. **Attention** (leak, low battery) uses the attention role in text and badge; the leak tile keeps its full alarm fill in the attention container.
5. **Custom panel types** get the same tile shell, surface and typography; their inner controls take the component themes. No per-type redesign.
6. **Boards:** redraw the 1.12 tile board and the 1.13 Devices/device page boards in Signal on the canvas ('2.0' row), light and dark, before code.

## Decide dark-by-default on tablets for new and upgrading users



1. **Only for fresh installs.** An upgrader keeps exactly what they had (System stays System): the seamless-update rule.
2. **Tablet** = shortest side ≥ 600 dp at first launch. The choice is stored as the theme setting (Dark), visible and changeable in Settings, not a hidden rule.
3. Phones: System, as today.

## Decide motion



1. **Material 3 defaults, not springs:** Flutter's M3 easing/durations (emphasized 500 ms for containers, standard 300 ms for state). No custom physics.
2. **Tile state change:** the fill cross-fades amber↔surface in 200 ms and the icon swaps outlined↔filled with it.
3. **Reduced motion:** honour MediaQuery.disableAnimations — every animation becomes an instant change.
4. Nothing loops or pulses, except the leak alarm tile (a slow 2 s attention pulse, off under reduced motion).

## Decide 2.0 scope for thermostats and kiosk



1. **Thermostats: out of 2.0.** Still no test device; they get the generic tile (writable numeric → slider on the device page) meanwhile. Revisit when a TRV is on the SMHUB.
2. **Kiosk: a minimal 'Wall display' toggle in 2.0,** per dashboard's ⋮ menu: keep the screen on while this dashboard is open (wakelock) and hide the header/rail until tapped. No dimming schedule, no lock-down. It rides on the tablet layout already built.
3. Full kiosk (dimming, launcher replacement, admin lock) stays out of scope.

## Decide the accessibility and contrast pass



1. **Automated contrast test:** for the fallback scheme and the two golden wallpaper schemes, light and dark, assert every state-role pair and text-on-surface pair meets 4.5:1 (3:1 for ≥ 24 sp and icons). Runs in CI.
2. **Flutter's accessibility guideline matchers** (androidTapTargetGuideline, labeledTapTargetGuideline, textContrastGuideline) on each golden screen.
3. **Manual TalkBack pass** on the device check for 2.0 (the thing 1.13 could not do remotely): the user or Claude with TalkBack on, a script of 12 actions.
4. Findings go into the build as fixes, not tickets.

## Design the launcher icon and feature graphic



1. **Icon:** an amber squircle tile with an ink 'signal' glyph (three arcs over a dot) on the ivory ground; adaptive foreground/background layers; a monochrome layer for themed icons.
2. **Feature graphic:** ivory ground, a phone and tablet frame showing the Signal dashboard, the ZigDash wordmark in Space Grotesk; no text beyond the name and a 4-word tagline (localized).
3. **Drawn on the canvas** in a '2.0 assets' row; exported with flutter_launcher_icons from the final SVG.

## Plan store screenshots and launch posts



1. **Capture on the phone** (and the 1280×800 emulated tablet from the 1.13 check) with the demo home, via adb scripts in tool/store/: 6 phone + 2 tablet shots per locale.
2. **Locales:** en, fr, de, es, he (the four from phasing.md plus English). nl, sv, nb keep English shots.
3. **Launch posts:** the same venues as the community round, drafted by Claude, posted by the user, the day 2.0 reaches 100%.
4. **Measurement:** note the 28-day listing conversion and DAU/MAU before release (Play Console statistics) in docs/growth/, re-read 28 days after.
