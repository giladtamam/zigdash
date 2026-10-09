# Release 2.0 "Signal": build spec

This is the handoff from design to building release 2.0, phase 4 in [phasing.md](phasing.md). It applies the Signal identity to every screen built in 1.10–1.13 and adds the launch assets. The decisions were made on 2026-09-27 in the "ZigDash 2.0 Signal phase design" map, and the user accepted them. The base is [tokens.md](tokens.md) (colors, state roles, shape, type, spacing, dark mode) and [ADR 0002](../adr/0002-amber-is-a-harmonized-accent.md). Where this spec disagrees with tokens.md, this spec wins.

Boards: the Signal rows (B, D, E) and the "2.0" row of the [Claude Design canvas](https://claude.ai/artifact/Gt1x8Q8TpDfY2VMVqNqF5w) (version 13), exported to [screens/2.0/](screens/2.0/). Built on `release/2.0-signal`, cut from 1.13.0+28.

**Gate:** the build starts once the community reaction round ([docs/growth/2.0-community-round.md](../growth/2.0-community-round.md)) has been posted and its 7-day window has closed. Any decision that the reactions contradict reopens first.

## Scope

In: the Signal theme (colors, state roles, shapes, type, spacing), bundled fonts, app icons from a Material Symbols subset, Signal tiles in every state, dark by default on tablets for new installs, M3 motion, a "Wall display" toggle, the accessibility and contrast pass, the launcher icon, the feature graphic, store screenshots, and launch posts.

Out: thermostat (TRV) tiles (no test device), a full kiosk mode (dimming, lock-down), new features, the material_ui package, dynamic_color 2.x, and iOS.

## 1. Theme architecture

- **One module, `lib/core/theme/`:**
  - `tokens.dart`: colors, radii, spacing and type as constants, taken from tokens.md.
  - `signal_colors.dart`: a `SignalColors` ThemeExtension with six state roles (active, idle, stale, attention, offlineDevice, healthy), each a container plus an on-container color.
  - `app_theme.dart`: `AppTheme.light/dark(dynamic:)` builds ThemeData with component themes for Card, Chip, the buttons, NavigationBar, NavigationRail, BottomSheet, Dialog, Slider, Switch, SegmentedButton and ListTile.
- **Material You off:** the fallback scheme from tokens.md (ivory ground, ink text, amber active).
- **Material You on:** surfaces, navigation and buttons follow the wallpaper. The state roles are harmonized toward its primary with `Color.harmonizeWith`, at most about 15° per ADR 0002.
- **Per-dashboard color becomes an accent only:** the title, the tab or chip indicator, and section labels. It no longer re-seeds the scheme or changes the active fill. No stored data changes. *This is the most visible change for upgraders.*
- **No hard-coded colors:** the 10 `Colors.*` uses move to state roles. A test greps `lib/` for `Colors.(red|green|orange|amber|blue|grey)` and fails if any return.
- Screens read roles, not hex values: `SignalColors.of(context).active`.

## 2. Fonts

- Bundled in `assets/fonts/`, never loaded at runtime (google_fonts would call Google's servers, which the no-telemetry rule rules out).
  - Space Grotesk 500 and 700
  - IBM Plex Sans 400 and 600
  - IBM Plex Sans Hebrew 400 and 600
- Subset with fonttools (`pip install --user fonttools`) by `tool/fonts/subset.sh`:
  - Latin, Latin-1 Supplement, Latin Extended-A and General Punctuation
  - the units the app shows (°, µ, ³)
  - the Hebrew block, for Plex Hebrew only

  Budget: ≤ 450 KB for the six files.
- OFL licence files ship with the fonts and are registered with `LicenseRegistry`.
- `fontFamilyFallback` hands other scripts and emoji to the platform font. Nothing renders as tofu.
- Type roles follow tokens.md: display 34/700, reading 40/700 (64 on tablets), title 18/600, tile name 15/600, body 15/400, state 13/400, section label 13/700 uppercase with +1.2 tracking. **Hebrew section labels are not uppercased or tracked.**
- Text scales to 200%. Tiles grow and never truncate.

## 3. Icons ([ADR 0005](../adr/0005-app-icons-from-a-symbols-subset.md))

- **App icons:** a Material Symbols Rounded subset (about 60 glyphs, variable FILL axis), cut by the same `tool/fonts/` script and drawn through one icon table.
  - Covers device classes, navigation, headers and page chrome.
  - Idle draws FILL 0, active draws FILL 1.
- **User-picked icons** stay MaterialIcons code points in the database. `materialIcon()` maps each to its `_rounded` variant through a table generated from icons.dart by `tool/icons/rounded_table.dart`. Nothing is migrated. The picker offers the rounded glyphs.

## 4. Tiles

Boards: H-tiles (every state, light and dark), H-phone-light, H-tablet-dark.

- **Shape:** squircle tiles (`RoundedSuperellipseBorder`, radius 28), a 1 dp hairline, no elevation. Radii are directional. The quick action is a squircle of radius 18, at 48, 56 or 64 dp by window class.
- **Active:** amber container, ink content, filled icon. **Idle:** tile surface, outlined icon. On is never signalled by color alone.
- **Stale:** a flatter surface, an age pill and a dashed quick-action outline. In dark mode it adds a 45° hatch at about 6% ink.
- **Attention:** low battery shows as an attention pill. A leak or smoke alarm fills the whole tile with the attention container.
- **Offline device:** outline only, muted text. **Never reported:** idle tile with a muted icon and "Waiting for first report".
- **Custom panel types (15)** get the same shell, surface and type. Their inner controls follow the component themes; no type is redesigned.
- **Screens:** the Devices tab, device page, Settings, setup, Add tile and Edit mode take the component themes. The 1.13 content keeps its structure (boards D-devices, D-device-page-dark).
- **Spacing by window class:** margins 16, 24 or 36 dp; tile gaps 10, 12 or 16 dp.

## 5. Dark by default on tablets

- Fresh installs only, meaning setup is not yet complete (`onboarding_complete` absent). When setup or the demo finishes on a device whose shortest side is 600 dp or more, `ThemeMode.dark` is written as the theme setting. It is visible and changeable in Settings.
- Upgraders keep what they had. Phones stay on System.

## 6. Motion

- Material 3 easing and durations: emphasized 500 ms for containers, standard 300 ms for state changes. No custom physics.
- A tile state change cross-fades the fill in 200 ms and swaps the icon's fill with it.
- The leak alarm tile pulses slowly (2 s). Nothing else loops.
- With `MediaQuery.disableAnimations` set, every animation becomes an instant change.

## 7. Wall display

- "Wall display" in each dashboard's ⋮ menu, off by default and stored per dashboard in SharedPreferences.
- While that dashboard is open, the screen stays on (`wakelock_plus`, the phase's only new dependency) and the header and rail hide until the screen is tapped. They hide again after 10 s without a touch.
- No dimming and no lock-down.

## 8. Accessibility and contrast

- **Contrast test in CI:** for the fallback scheme and the two golden wallpaper schemes, in light and dark, every state-role pair and text-on-surface pair must reach 4.5:1 (3:1 for text of 24 sp or more and for icons).
- **Flutter's guideline matchers** (`androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`) run on every golden screen.
- **The 2.0 device check includes a TalkBack pass** with the screen reader on, following a 12-step script: open the app, switch a light, open its sheet, change brightness, open the device page, open Devices, filter Needs attention, open Settings, change language, enter and leave Edit mode, move a tile with the accessibility actions, and switch home.

## 9. Launcher icon and feature graphic

Board: H-launcher.

- **Icon:** a 2×2 grid of rounded tiles on an ink squircle, the top-left tile amber, over an ivory (#F6F3EC) background layer. Adaptive foreground and background layers, plus a monochrome layer (the grid with the lit tile filled) for Android 13+ themed icons. Each layer is exported as a 1024 px PNG from the SVG and run through flutter_launcher_icons.
- **Feature graphic (1024 × 500):** ivory ground, the icon and the "ZigDash" wordmark in Space Grotesk, a tagline ("Your Zigbee home, at a glance.", localized in the eight store languages), and a phone (light) and tablet (dark) showing Signal tiles.

## 10. Store screenshots and launch

- Captured on the phone and on the 1280 × 800 emulated tablet (`adb shell wm size 2560x1600` and `wm density 320`, reset afterwards), with the demo home, by scripts in `tool/store/`. Per locale: 6 phone and 2 tablet shots.
- Locales: en, fr, de, es and he. nl, sv and nb keep the English shots.
- Before release, record the 28-day listing conversion and DAU/MAU from Play Console in `docs/growth/`. Read them again 28 days after 100%. No listing experiment.
- Launch posts go to the same venues as the community round, drafted by Claude and posted by the user, on the day 2.0 reaches 100%.

## 11. Tests and goldens

- **Re-baseline once:** every golden is regenerated in one commit after the theme lands, then reviewed board by board against the canvas (phasing.md). Visual fixes go in follow-up commits, each with its own golden update.
- **Matrix unchanged:** light and dark, English and Hebrew, text 1.0 and 2.0, phone and tablet, and the dynamic-color matrix (fallback plus two wallpapers).
- **New tests:**
  - the contrast test (§8)
  - the `Colors.*` grep (§1)
  - the rounded-icon table covers every icon the picker offers
  - fonts load, and the Hebrew fallback works
  - tablet dark is written at setup completion and never for upgraders
  - Wall display keeps the screen on and hides the chrome, with a mocked wakelock
  - reduced motion
- **Font size:** the release bundle grows by at most 0.6 MB (fonts and icon subset).

## 12. Exit checks

1. Goldens are re-baselined once and reviewed board by board against the canvas.
2. The Hebrew pass: the layout mirrors, Plex Hebrew renders, and section labels are not uppercased.
3. The dynamic-color pass: two wallpapers plus the fallback, light and dark, with contrast tests green.
4. Upgrading from 1.13 (and from 1.9.2, the current production build) changes nothing a user stored: dashboard colors survive as accents, picked icons still draw, and the theme setting is untouched.
5. The device check on the internal track includes the TalkBack script, a strict-broker connect, a tablet layout check, and a Wall display check.
6. CI is green, goldens included.

## Found on the first device run (2.0.0-preview1, 2026-09-27)

- **Material You on hid most of Signal**, so its setting now defaults to off. The user decided this 2026-09-27 (ADR 0002 amendment). A choice made before is kept. *Done.*
- **The Devices "Weak" chip** now uses the Symbols glyph. *Done.*
- **Device page header and Devices rows** now use amber and a filled icon when a device is on. *Done.*

## Decided while building (2026-10-04)

- **Store screenshots (§10):** emulators of popular devices, a Pixel 8 phone and a Pixel Tablet (2560 × 1600 at 320 dpi, the 1280 × 800 dp tablet above), run by `tool/store/capture.sh`. Phone, 6 shots: dashboard, a light's controls, Devices, a device page, dashboard in dark, Edit mode. Tablet, 2 shots (`tenInchScreenshots`): the dark wall dashboard and Devices as list-detail. The capture build hides the demo bar (`ZIGDASH_STORE_CAPTURE`). Captured once, after the golden review.
- **Demo devices:** the demo publishes a Zigbee2MQTT device list, availability, and human friendly names, so the Devices tab and device pages look like a real home. The front door's battery is 15%, so one device needs attention. Demo homes from before 2.0 keep their old snake_case topics.
- **Default dashboard colour:** new dashboards (demo, setup, form) start with Signal's warm ink (`defaultDashboardSeed`), not 1.x blue or M3 teal. Stored colours are untouched.
- **Leak and smoke pulse (§6):** the attention fill eases a third of the way toward the tile surface and back, 1 s each way. It holds steady with animations off, and the contrast test covers its far end.
- **Reduced motion (§6):** every animated panel takes its duration from `SignalMotion.of`, and a guard test enforces it.

## Emulator check (2.0.0+29 debug, Pixel 8 emulator, 2026-10-05)

Against Mosquitto 2.1.2 and `tool/e2e/z2m_sim.py` on the host (10.0.2.2):

- **Upgrade from 1.13.0+28:** a home set up in 1.13 survives the install of 2.0 over it, connects, and opens in Signal with Material You off (the ADR 0002 amendment). *Pass.*
- **Upgraders' consent card:** shown on the upgraded home, including one with no dashboards yet (fixed here: the empty screen had no card). No thanks records "no", and the Settings switch reads off. *Pass.*
- **Opt-out on device:** switching it on queues `app_started`; switching off within two seconds deletes it before the 30 s send. *Pass.*
- **Fresh install with consent:** setup steps, `app_started` and `feature_used` arrive in Aptabase (Debug view). *Pass.*

Still for a physical phone (exit check 5): TalkBack script, a password-protected broker, the tablet layout, Wall display.

## Release-build smoke test (2.0.0+29 release APK, 2026-10-05)

Signed with the new upload key, on a Pixel 8 emulator, against Mosquitto with a password listener and `tool/e2e/z2m_sim.py`:

- Fresh install: the consent box shows unticked, and "What's shared" opens the browser. Leaving it unticked records "no", and no card appears later. *Pass.*
- Manual connect with a username and password: the ladder passes and finds 4 devices. *Pass.*
- Devices shows live state. A device page toggle reaches Zigbee2MQTT (`{"state": "OFF"}`) and the page follows. *Pass.*
- **Bug found and fixed:** "Add to a dashboard" on a home with no dashboard was a disabled dead end (also in 1.13). Add now creates a dashboard. *Pass after the fix.*
- A dashboard tile switches the light (`{"state": "ON"}`) and turns amber. *Pass.*

Also run: `bin/e2e_real_broker.dart` over TCP, WebSocket and a broker restart; the three `integration_test/` flows on the emulator. All pass.

## Deferred, with a reason

- **Thermostat tiles.** There is no test device. Generic tiles cover TRVs meanwhile.
- **Full kiosk mode.** The minimal Wall display toggle comes first.
- **dynamic_color 2.x and material_ui.** After 2.0, per phasing.md.
