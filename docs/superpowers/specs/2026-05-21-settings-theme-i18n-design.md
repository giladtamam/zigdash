# ZigDash — Settings (Phase 7): Theme Control + Hebrew Localization

**Date:** 2026-05-21
**Status:** Approved design, pending implementation plan

## Goal

Replace the `Settings — Phase 7` placeholder with a real Settings screen that
controls **appearance** (theme mode + Material You dynamic color) and
**language**, and make the whole app **localizable in English and Hebrew**
(including right-to-left layout). gilad is a native Hebrew speaker with Hebrew
Z2M device names, so a Hebrew UI is a first-class goal.

## Decisions (locked during brainstorming)

1. **Scope: theme control + full Hebrew localization** bundled into one Settings
   phase (not theme-only, not deferred).
2. **Persistence: `shared_preferences`** — UI prefs are not domain data, so they
   live in key-value storage, not the Drift DB. No schema migration.
3. **Localization mechanism: Flutter's standard `flutter gen-l10n`** with ARB
   files (`flutter_localizations` + `intl`), generating a typed
   `AppLocalizations`. Chosen over map-based packages for being idiomatic and
   maintainable. Locales: `en` (default/template) and `he`.

## Section 1 — Localization mechanism

- Add to `pubspec.yaml`: `flutter_localizations` (sdk), `intl`, and
  `shared_preferences`. Enable `flutter: generate: true`.
- Add `l10n.yaml` at the repo root:
  ```yaml
  arb-dir: lib/l10n
  template-arb-file: app_en.arb
  output-localization-file: app_localizations.dart
  output-class: AppLocalizations
  nullable-getter: false
  ```
- `lib/l10n/app_en.arb` (template, English) and `lib/l10n/app_he.arb` (Hebrew).
  Every user-facing string is a key (lowerCamelCase, grouped by feature, e.g.
  `connectionsTitle`, `panelFormPublishTopic`, `coverOpen`, `schedulerOffline`).
- `flutter gen-l10n` (run via `flutter pub get` with `generate: true`) produces
  `AppLocalizations`. A tiny `BuildContext` extension `l10n` gives
  `context.l10n.connectionsTitle`.

## Section 2 — Settings state & persistence

```dart
// lib/features/settings/models/app_settings.dart
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.dynamicColor = true,
    this.locale,            // null = follow system
  });
  final ThemeMode themeMode;
  final bool dynamicColor;
  final Locale? locale;
  AppSettings copyWith({ThemeMode? themeMode, bool? dynamicColor, Object? locale = _unset});
}
```

- `sharedPreferencesProvider` — a `Provider<SharedPreferences>` that throws by
  default and is **overridden** in `main()` with the preloaded instance.
- `settingsControllerProvider` = `NotifierProvider<SettingsController, AppSettings>`.
  - `build()` reads prefs synchronously: `theme_mode` (`system`/`light`/`dark`),
    `dynamic_color` (bool, default `true`), `locale` (`''`/`en`/`he`; empty ⇒
    null ⇒ system).
  - `setThemeMode`, `setDynamicColor`, `setLocale` update state and write the
    pref (best-effort await).
- `main()` becomes async:
  ```dart
  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    runApp(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ZigDashApp(),
    ));
  }
  ```
  Preloading keeps the settings read synchronous — no theme/locale flicker.

## Section 3 — `app.dart` wiring

`ZigDashApp` watches `settingsControllerProvider`:

```dart
final settings = ref.watch(settingsControllerProvider);
return DynamicColorBuilder(
  builder: (light, dark) => MaterialApp.router(
    title: 'ZigDash',                 // see note below
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(dynamic: settings.dynamicColor ? light : null),
    darkTheme: AppTheme.dark(dynamic: settings.dynamicColor ? dark : null),
    themeMode: settings.themeMode,
    locale: settings.locale,          // null ⇒ follow system
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    routerConfig: ref.watch(routerProvider),
  ),
);
```

- **RTL is automatic.** With `locale == he`, the Material localization delegates
  set `Directionality` to RTL app-wide; directional widgets mirror without extra
  code.
- `onGenerateTitle: (ctx) => ctx.l10n.appTitle` replaces the static `title` so the
  task-switcher label localizes too.
- No change to `app_theme.dart` (its `_fallbackSeed` already handles
  dynamic-off / unsupported devices).

## Section 4 — Settings UI

- Delete `lib/features/settings/screens/settings_placeholder.dart`; create
  `lib/features/settings/screens/settings_screen.dart`. Update the import +
  builder in `lib/core/router/app_router.dart` (line ~114).
- Layout (`ListView`), all strings localized:
  - **Appearance** section header.
    - Theme: three `RadioListTile<ThemeMode>` — System / Light / Dark.
    - `SwitchListTile` "Use Material You colors" (subtitle: "Android 12+;
      otherwise uses the app color"). Bound to `dynamicColor`.
  - **Language** section header.
    - Three radios: System / English / עברית → `setLocale(null|en|he)`.

## Section 5 — String migration + RTL audit (the bulk)

Every user-facing literal in `lib/` moves to ARB keys with Hebrew translations.
Inventory by area (each becomes a batch of ARB keys + call-site edits):

- **Shell/nav + app title:** bottom-nav labels, `AppTitle`.
- **Connections:** list screen, add/edit form (field labels, hints, validation
  messages), connection tile menu.
- **Dashboards:** dashboards screen (app-bar actions, empty state), dashboard
  form (name/prefix/color/icon/lock), the inlined panel picker
  (`_openPanelPicker` — all type labels + subtitles), backup menu strings.
- **Panels:** the large `panel_form_screen.dart` (every label/hint/helper for all
  types), `panel_tile.dart` options sheet (Edit/Duplicate/Move/Width/Delete,
  width labels), and the 12 panel widgets' literals (e.g. `coverOpen`/`coverStop`/
  `coverClose`, `schedulerOffline`, `disabled`, `nextAt`, snackbars).
- **Settings:** the new screen's own strings.

RTL audit: grep for `EdgeInsets.only(` with `left:`/`right:`, `Alignment.centerLeft`/
`centerRight`, `Positioned(left:/right:)`, and any `TextAlign.left/right`; convert
to directional equivalents (`EdgeInsetsDirectional`, `AlignmentDirectional`,
`TextAlign.start/end`) so they mirror under RTL. Symmetric padding and
`MainAxisAlignment` need no change.

**Not localized:** Z2M device data (friendly names like `lavi`, `אור חדר עבודה`),
MQTT topics/payloads, and broker hostnames — these are user/device data, not UI
chrome.

## Section 6 — Error handling

- Missing/garbage prefs → defaults (System theme, dynamic on, system locale).
- Pref writes are best-effort; if a write throws, the in-memory setting still
  applies for the session.
- A missing ARB key fails at build time (`gen-l10n` / analyzer), so there are no
  runtime "missing translation" surprises for `en`; `he` falls back to `en` for
  any key not yet translated (acceptable safety net, though the goal is full
  coverage).

## Section 7 — Testing

- Unit-test `SettingsController` with `SharedPreferences.setMockInitialValues`:
  initial load for each pref (incl. defaults when absent), and that
  `setThemeMode`/`setDynamicColor`/`setLocale` both update state and persist.
- Widget test: pump the app forced to `he`, assert a known screen renders the
  Hebrew string and that `Directionality.of(context) == TextDirection.rtl`.
- `flutter gen-l10n` produces no errors; `flutter analyze` clean; full suite green.

## Verification (end state)

1. Build + sideload; open **Settings**.
2. Toggle Theme System/Light/Dark — app re-themes immediately and persists across
   restart.
3. Toggle Material You off — app uses the brand blue; on (Android 12+) — uses the
   wallpaper palette.
4. Set Language → עברית: the entire UI switches to Hebrew and flips to RTL;
   persists across restart. Set → System: follows the device language.
5. Spot-check a few screens (connections form, panel form, a dashboard) in Hebrew
   for translated text and correct RTL mirroring.

## Out of scope

- Backup/restore, About/Help, notifications (other Phase 7 "extras").
- Custom accent-color picker when dynamic color is off.
- Additional languages beyond en/he.
- Localizing Z2M device data.
