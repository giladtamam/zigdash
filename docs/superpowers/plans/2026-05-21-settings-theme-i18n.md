# Settings (Theme + Hebrew Localization) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Settings placeholder with a real Settings screen (theme mode + Material You dynamic color + language) and make the whole app localizable in English and Hebrew with automatic RTL.

**Architecture:** A `shared_preferences`-backed `SettingsController` (Riverpod `Notifier`) holds `{themeMode, dynamicColor, locale}`, preloaded in an async `main()` so reads are synchronous. `app.dart` feeds those into `MaterialApp.router` (`themeMode`, dynamic-or-fixed color, `locale`, l10n delegates). UI strings move from hardcoded literals into `flutter gen-l10n` ARB files (`app_en.arb`/`app_he.arb`); Hebrew triggers RTL automatically via the Material localization delegates.

**Tech Stack:** Flutter + Riverpod, `shared_preferences`, `flutter_localizations` + `intl` + `flutter gen-l10n`, `dynamic_color` (already present). Commands run in WSL: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && <cmd>"`. Edit/read via `\\wsl.localhost\Ubuntu\home\gilad\projects\zigdash\...`. Work on branch `feat/settings-i18n` off `main`.

Spec: `docs/superpowers/specs/2026-05-21-settings-theme-i18n-design.md`

---

## File structure

**New:**
- `l10n.yaml` (repo root) — gen-l10n config.
- `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb` — translation sources (grow each task).
- `lib/core/l10n/l10n_ext.dart` — `BuildContext.l10n` getter.
- `lib/features/settings/models/app_settings.dart` — immutable settings model.
- `lib/features/settings/providers/settings_controller.dart` — `sharedPreferencesProvider` + `settingsControllerProvider`.
- `lib/features/settings/screens/settings_screen.dart` — the real screen.
- `test/features/settings/settings_controller_test.dart`, `test/app/locale_test.dart`.

**Modified:**
- `pubspec.yaml` — deps + `generate: true`.
- `lib/main.dart` — async preload + provider override.
- `lib/app.dart` — theme/locale/delegate wiring.
- `lib/core/router/app_router.dart` — Settings builder → `SettingsScreen`; nav labels localized.
- Every screen/widget with user-facing literals (Tasks 6–10).

**Deleted:**
- `lib/features/settings/screens/settings_placeholder.dart`.

## Hebrew glossary (use consistently in `app_he.arb`)

| English | Hebrew |
|---|---|
| Settings | הגדרות |
| Appearance | מראה |
| Theme | ערכת נושא |
| System | מערכת |
| Light | בהיר |
| Dark | כהה |
| Language | שפה |
| English | English |
| Hebrew | עברית |
| Use Material You colors | צבעי Material You |
| Brokers | ברוקרים |
| Dashboards | לוחות |
| Connections | חיבורים |
| Add broker | הוספת ברוקר |
| Save | שמירה |
| Saving… | שומר… |
| Required | שדה חובה |
| Name | שם |
| Host | מארח |
| Port | פורט |
| Username | שם משתמש |
| Password | סיסמה |
| Advanced | מתקדם |
| Add dashboard | הוספת לוח |
| Add panel | הוספת פאנל |
| Edit | עריכה |
| Delete | מחיקה |
| Duplicate | שכפול |
| Open / Stop / Close | פתיחה / עצירה / סגירה |
| Enabled | מופעל |
| Disabled | מושבת |
| Scheduler offline — won't run | המתזמן לא מקוון — לא יפעל |

Translations are gilad's to correct on review; keep keys grouped by feature in the ARB.

---

## Task 1: Localization + prefs dependencies and gen-l10n skeleton

**Files:** `pubspec.yaml`, `l10n.yaml` (create), `lib/l10n/app_en.arb` (create), `lib/l10n/app_he.arb` (create), `lib/core/l10n/l10n_ext.dart` (create)

- [ ] **Step 1: Add dependencies.** In `pubspec.yaml`, under `dependencies:` add (after `dynamic_color`):

```yaml
  # Localization
  flutter_localizations:
    sdk: flutter
  intl: any

  # Preferences
  shared_preferences: ^2.3.2
```

And under the `flutter:` section (after `uses-material-design: true`) add:

```yaml
  generate: true
```

- [ ] **Step 2: Create `l10n.yaml`** at the repo root:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

- [ ] **Step 3: Create `lib/l10n/app_en.arb`** (seed with app title + nav; more keys added per later task):

```json
{
  "@@locale": "en",
  "appTitle": "ZigDash",
  "navBrokers": "Brokers",
  "navDashboards": "Dashboards",
  "navSettings": "Settings"
}
```

- [ ] **Step 4: Create `lib/l10n/app_he.arb`:**

```json
{
  "@@locale": "he",
  "appTitle": "ZigDash",
  "navBrokers": "ברוקרים",
  "navDashboards": "לוחות",
  "navSettings": "הגדרות"
}
```

- [ ] **Step 5: Generate + verify.** Run:
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter pub get && flutter gen-l10n"`
Expected: pub resolves; gen-l10n writes `.dart_tool/flutter_gen/gen_l10n/app_localizations.dart` (and `_en`/`_he`). No errors.

- [ ] **Step 6: Create `lib/core/l10n/l10n_ext.dart`** (ergonomic accessor):

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

- [ ] **Step 7: Analyze + commit.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter analyze 2>&1 | tail -2"` (expect: No issues found)
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(l10n): add flutter_localizations + shared_preferences + gen-l10n skeleton'"
```

---

## Task 2: `AppSettings` model + `SettingsController` (+ tests)

**Files:** Create `lib/features/settings/models/app_settings.dart`, `lib/features/settings/providers/settings_controller.dart`, `test/features/settings/settings_controller_test.dart`

- [ ] **Step 1: Write the failing test.** Create `test/features/settings/settings_controller_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/settings/models/app_settings.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

ProviderContainer _containerWith(SharedPreferences prefs) => ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults when prefs empty: system theme, dynamic on, system locale', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);
    final s = c.read(settingsControllerProvider);
    expect(s.themeMode, ThemeMode.system);
    expect(s.dynamicColor, isTrue);
    expect(s.locale, isNull);
  });

  test('loads persisted values', () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'dynamic_color': false,
      'locale': 'he',
    });
    final prefs = await SharedPreferences.getInstance();
    final s = _containerWith(prefs).read(settingsControllerProvider);
    expect(s.themeMode, ThemeMode.dark);
    expect(s.dynamicColor, isFalse);
    expect(s.locale, const Locale('he'));
  });

  test('setters update state and persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);
    final ctrl = c.read(settingsControllerProvider.notifier);
    await ctrl.setThemeMode(ThemeMode.light);
    await ctrl.setDynamicColor(false);
    await ctrl.setLocale(const Locale('he'));
    final s = c.read(settingsControllerProvider);
    expect(s.themeMode, ThemeMode.light);
    expect(s.dynamicColor, isFalse);
    expect(s.locale, const Locale('he'));
    expect(prefs.getString('theme_mode'), 'light');
    expect(prefs.getBool('dynamic_color'), false);
    expect(prefs.getString('locale'), 'he');
  });

  test('setLocale(null) clears the pref (follow system)', () async {
    SharedPreferences.setMockInitialValues({'locale': 'he'});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);
    await c.read(settingsControllerProvider.notifier).setLocale(null);
    expect(c.read(settingsControllerProvider).locale, isNull);
    expect(prefs.getString('locale'), isNull);
  });
}
```

- [ ] **Step 2: Run it — expect FAIL** (undefined symbols):
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/features/settings/settings_controller_test.dart"`

- [ ] **Step 3: Create `lib/features/settings/models/app_settings.dart`:**

```dart
import 'package:flutter/material.dart';

/// Immutable app-level preferences. [locale] == null means "follow system".
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.dynamicColor = true,
    this.locale,
  });

  final ThemeMode themeMode;
  final bool dynamicColor;
  final Locale? locale;

  static const Object _unset = Object();

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? dynamicColor,
    Object? locale = _unset,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        dynamicColor: dynamicColor ?? this.dynamicColor,
        locale: identical(locale, _unset) ? this.locale : locale as Locale?,
      );
}
```

- [ ] **Step 4: Create `lib/features/settings/providers/settings_controller.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Overridden in main() with the preloaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden in main()'),
);

const _kThemeMode = 'theme_mode';
const _kDynamicColor = 'dynamic_color';
const _kLocale = 'locale';

ThemeMode _themeModeFromString(String? s) => switch (s) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

String _themeModeToString(ThemeMode m) => switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

class SettingsController extends Notifier<AppSettings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final code = _prefs.getString(_kLocale);
    return AppSettings(
      themeMode: _themeModeFromString(_prefs.getString(_kThemeMode)),
      dynamicColor: _prefs.getBool(_kDynamicColor) ?? true,
      locale: (code == null || code.isEmpty) ? null : Locale(code),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kThemeMode, _themeModeToString(mode));
  }

  Future<void> setDynamicColor(bool enabled) async {
    state = state.copyWith(dynamicColor: enabled);
    await _prefs.setBool(_kDynamicColor, enabled);
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale);
    if (locale == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, locale.languageCode);
    }
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
```

- [ ] **Step 5: Run the test — expect PASS (4 tests).**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/features/settings/settings_controller_test.dart && flutter analyze 2>&1 | tail -2"`

- [ ] **Step 6: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(settings): AppSettings model + SettingsController (prefs-backed)'"
```

---

## Task 3: Wire `main()` + `app.dart` (theme + locale + l10n delegates)

**Files:** `lib/main.dart`, `lib/app.dart`

- [ ] **Step 1: Rewrite `lib/main.dart`:**

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/settings/providers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ZigDashApp(),
    ),
  );
}
```

- [ ] **Step 2: Rewrite `lib/app.dart`:**

```dart
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_controller.dart';

class ZigDashApp extends ConsumerWidget {
  const ZigDashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);
    return DynamicColorBuilder(
      builder: (light, dark) => MaterialApp.router(
        onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(dynamic: settings.dynamicColor ? light : null),
        darkTheme: AppTheme.dark(dynamic: settings.dynamicColor ? dark : null),
        themeMode: settings.themeMode,
        locale: settings.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    );
  }
}
```

- [ ] **Step 3: Verify build + analyze.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n && flutter analyze 2>&1 | tail -2 && flutter test 2>&1 | tail -2"`
Expected: No issues; all tests pass. (The app now boots with system locale/theme, behavior unchanged visually.)

- [ ] **Step 4: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(settings): wire prefs-driven theme + locale + l10n delegates'"
```

---

## Task 4: Settings screen (replace placeholder)

**Files:** Create `lib/features/settings/screens/settings_screen.dart`; modify `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb`, `lib/core/router/app_router.dart`; delete `lib/features/settings/screens/settings_placeholder.dart`

- [ ] **Step 1: Add ARB keys.** Append to `app_en.arb` (before the closing `}`, adding a comma to the previous last entry):

```json
  "settingsAppearance": "Appearance",
  "settingsTheme": "Theme",
  "themeSystem": "System",
  "themeLight": "Light",
  "themeDark": "Dark",
  "settingsDynamicColor": "Use Material You colors",
  "settingsDynamicColorSubtitle": "Android 12+; otherwise uses the app color",
  "settingsLanguage": "Language",
  "languageSystem": "System",
  "languageEnglish": "English",
  "languageHebrew": "עברית"
```

Append to `app_he.arb`:

```json
  "settingsAppearance": "מראה",
  "settingsTheme": "ערכת נושא",
  "themeSystem": "מערכת",
  "themeLight": "בהיר",
  "themeDark": "כהה",
  "settingsDynamicColor": "צבעי Material You",
  "settingsDynamicColorSubtitle": "אנדרואיד 12 ומעלה; אחרת נעשה שימוש בצבע האפליקציה",
  "settingsLanguage": "שפה",
  "languageSystem": "מערכת",
  "languageEnglish": "English",
  "languageHebrew": "עברית"
```

- [ ] **Step 2: Create `lib/features/settings/screens/settings_screen.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../providers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          _SectionHeader(l10n.settingsAppearance),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeSystem),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (v) => ctrl.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (v) => ctrl.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (v) => ctrl.setThemeMode(v!),
          ),
          SwitchListTile(
            title: Text(l10n.settingsDynamicColor),
            subtitle: Text(l10n.settingsDynamicColorSubtitle),
            value: settings.dynamicColor,
            onChanged: ctrl.setDynamicColor,
          ),
          const Divider(),
          _SectionHeader(l10n.settingsLanguage),
          RadioListTile<String?>(
            title: Text(l10n.languageSystem),
            value: null,
            groupValue: settings.locale?.languageCode,
            onChanged: (_) => ctrl.setLocale(null),
          ),
          RadioListTile<String?>(
            title: Text(l10n.languageEnglish),
            value: 'en',
            groupValue: settings.locale?.languageCode,
            onChanged: (_) => ctrl.setLocale(const Locale('en')),
          ),
          RadioListTile<String?>(
            title: Text(l10n.languageHebrew),
            value: 'he',
            groupValue: settings.locale?.languageCode,
            onChanged: (_) => ctrl.setLocale(const Locale('he')),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
      child: Text(text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary)),
    );
  }
}
```

- [ ] **Step 3: Wire the router.** In `lib/core/router/app_router.dart`:
  - replace the import `import '../../features/settings/screens/settings_placeholder.dart';` with `import '../../features/settings/screens/settings_screen.dart';`
  - change the Settings branch builder (line ~114) from `const SettingsPlaceholder()` to `const SettingsScreen()`.

- [ ] **Step 4: Delete the placeholder.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && rm lib/features/settings/screens/settings_placeholder.dart"`

- [ ] **Step 5: Generate, analyze, test.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n && flutter analyze 2>&1 | tail -2 && flutter test 2>&1 | tail -2"`
Expected: clean; tests pass.

- [ ] **Step 6: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(settings): real Settings screen (theme + language)'"
```

---

## Localization tasks (5–8): procedure

Each of Tasks 5–8 localizes one area. For every task, follow this exact procedure (worked fully in Task 5):

1. **Read the file(s)** listed. Find every user-facing string literal (AppBar titles, labels, hints, helperText, button text, validator messages, snackbars, `Text(...)`, tooltips, empty-state copy). Do NOT touch MQTT topics, payload templates, JSON keys, route paths, Z2M device data, or debug `print`s.
2. **Add an ARB key** for each (lowerCamelCase, feature-prefixed) to BOTH `app_en.arb` (English source) and `app_he.arb` (Hebrew from the glossary; translate anything not in the glossary, keeping it natural). For strings with runtime values, use ARB placeholders, e.g. `"loadFailed": "Failed to load: {error}"` with an `@loadFailed` `placeholders` block.
3. **Replace call sites** with `context.l10n.<key>`. Add `import '../../../core/l10n/l10n_ext.dart';` (adjust depth) to each edited file. A `const` widget holding a now-dynamic string must drop `const`.
4. **Regenerate + analyze:** `flutter gen-l10n && flutter analyze`. gen-l10n fails if `he` is missing a key present in `en` — fix by adding the Hebrew entry.
5. **Commit** the area.

ARB placeholder example (for `Failed to load: $e`):
```json
"connLoadFailed": "Failed to load: {error}",
"@connLoadFailed": { "placeholders": { "error": {} } }
```
Call site: `context.l10n.connLoadFailed(e.toString())`.

---

## Task 5: Localize nav + Connections (worked example)

**Files:** `lib/core/router/app_router.dart` (nav labels), `lib/features/connections/screens/connections_list_screen.dart`, `lib/features/connections/screens/connection_form_screen.dart`, `lib/features/connections/widgets/connection_tile.dart`, `lib/features/connections/widgets/protocol_dropdown.dart`; plus `app_en.arb`/`app_he.arb`.

- [ ] **Step 1: Add ARB keys.** To `app_en.arb` (and `app_he.arb` with glossary Hebrew):

```json
  "connectionsTitle": "Connections",
  "connLoadFailed": "Failed to load: {error}",
  "@connLoadFailed": { "placeholders": { "error": {} } },
  "connAddBroker": "Add broker",
  "connEmpty": "No connections yet.\nTap \"Add broker\" to point ZigDash at your MQTT server.",
  "connNew": "New connection",
  "connEdit": "Edit connection",
  "save": "Save",
  "saving": "Saving…",
  "fieldRequired": "Required",
  "connName": "Name",
  "connNameHint": "Home broker",
  "connHost": "Host",
  "connHostHint": "192.168.1.10",
  "connPort": "Port",
  "connPortRange": "1–65535",
  "connUsernameOptional": "Username (optional)",
  "connPasswordOptional": "Password (optional)",
  "connPasswordKeepHint": "Leave blank to keep existing",
  "connAutoConnect": "Auto-connect on app start",
  "advanced": "Advanced",
  "connKeepAlive": "Keep-alive (seconds)",
  "connKeepAliveRange": "5–3600"
```

Hebrew (`app_he.arb`):
```json
  "connectionsTitle": "חיבורים",
  "connLoadFailed": "טעינה נכשלה: {error}",
  "@connLoadFailed": { "placeholders": { "error": {} } },
  "connAddBroker": "הוספת ברוקר",
  "connEmpty": "אין עדיין חיבורים.\nהקש \"הוספת ברוקר\" כדי לחבר את ZigDash לשרת ה-MQTT שלך.",
  "connNew": "חיבור חדש",
  "connEdit": "עריכת חיבור",
  "save": "שמירה",
  "saving": "שומר…",
  "fieldRequired": "שדה חובה",
  "connName": "שם",
  "connNameHint": "ברוקר הבית",
  "connHost": "מארח",
  "connHostHint": "192.168.1.10",
  "connPort": "פורט",
  "connPortRange": "1–65535",
  "connUsernameOptional": "שם משתמש (לא חובה)",
  "connPasswordOptional": "סיסמה (לא חובה)",
  "connPasswordKeepHint": "השאר ריק כדי לשמור את הקיימת",
  "connAutoConnect": "התחברות אוטומטית בהפעלה",
  "advanced": "מתקדם",
  "connKeepAlive": "Keep-alive (שניות)",
  "connKeepAliveRange": "5–3600"
```

- [ ] **Step 2: Replace nav labels** in `app_router.dart` `_RootShell.build`. The `NavigationBar`'s `destinations` use `const` with literal `label:` — make the list non-const and use `context.l10n`:

```dart
        destinations: [
          NavigationDestination(icon: const Icon(Icons.cloud_outlined), selectedIcon: const Icon(Icons.cloud), label: context.l10n.navBrokers),
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: context.l10n.navDashboards),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: context.l10n.navSettings),
        ],
```
Add `import '../l10n/l10n_ext.dart';` to `app_router.dart`.

- [ ] **Step 3: Localize `connections_list_screen.dart`:** `'Connections'`→`context.l10n.connectionsTitle`; `'Failed to load: $e'`→`context.l10n.connLoadFailed(e.toString())`; `'Add broker'`→`context.l10n.connAddBroker`; the `_Empty` text → `context.l10n.connEmpty` (drop `const` on `_Empty` and its `Padding`/`Text`; convert `_Empty` to a non-const `StatelessWidget` that reads `context.l10n`). Add the l10n import.

- [ ] **Step 4: Localize `connection_form_screen.dart`:** titles (`Edit connection`/`New connection` → `connEdit`/`connNew`), `Save`/`Saving...` (note: change literal `'Saving...'` to `saving`), all `labelText`/`hintText` (`connName`/`connNameHint`/`connHost`/`connHostHint`/`connPort`/`connUsernameOptional`/`connPasswordOptional`/`connPasswordKeepHint`/`connAutoConnect`/`advanced`/`connKeepAlive`), and validator messages (`Required`→`fieldRequired`, `1–65535`→`connPortRange`, `5–3600`→`connKeepAliveRange`). `InputDecoration`s holding these must drop `const`. Add the l10n import.

- [ ] **Step 5: Localize `connection_tile.dart` and `protocol_dropdown.dart`:** read both; replace any literal labels/menu text (e.g. protocol names if shown as UI text, tile menu items like Edit/Delete) with new ARB keys following the same pattern (add keys to both ARBs). If `protocol_dropdown` shows enum names directly (tcp/ws), leave the protocol *values* as-is but localize any surrounding label.

- [ ] **Step 6: Generate, analyze, commit.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n && flutter analyze 2>&1 | tail -2"`
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'i18n: localize nav + connections'"
```

---

## Task 6: Localize Dashboards area

**Files:** `lib/features/dashboards/screens/dashboards_screen.dart` (incl. the inlined `_openPanelPicker` and `_BackupMenu`), `lib/features/dashboards/screens/dashboard_form_screen.dart`, `lib/features/dashboards/screens/dashboards_placeholder.dart`; ARBs.

Follow the Tasks 5–8 procedure. Strings to extract include (non-exhaustive — extract ALL literals in these files):
- dashboards_screen: AppBar tooltips `Edit dashboard`/`Add dashboard`, FAB `Add panel`, empty-state `No dashboards yet...`, the whole `_openPanelPicker` sheet (`Add a panel`, section headers `Control`/`State`, every tile title + subtitle: Toggle, Slider — Brightness, Slider — Position, Cover, Multi-State, Combo, Radio, Button, Text Input, LED, Node Status, Progress, Text Log), `_BackupMenu` items (Export/Import + any snackbars/dialogs).
- dashboard_form_screen: `New dashboard`/`Edit dashboard`, `Save`/`Saving…` (reuse `save`/`saving`), `Name`/hint, `Topic prefix (optional)`/hint/helper, `Color seed`, `Icon`, `Lock`/subtitle, `Delete dashboard`, the delete dialog (`Delete this dashboard?`, body, `Cancel`, `Delete`).
- dashboards_placeholder: its prompt text.

Reuse existing keys where identical (`save`, `saving`, `advanced`). Then `flutter gen-l10n && flutter analyze`, commit `i18n: localize dashboards`.

---

## Task 7: Localize Panel form + Panel tile

**Files:** `lib/features/panels/screens/panel_form_screen.dart`, `lib/features/panels/widgets/panel_tile.dart`; ARBs.

Largest text surface. Extract ALL literals: every `labelText`/`hintText`/`helperText` and section text in `panel_form_screen.dart` `_typeSpecificFields` for all 12 types (On payload, Off payload, JSON path, On match, Min/Max/Step, Value template, Payload, On label/Off label, Online payload, Unit, Options/Label/Payload/Match/Add option, presets, Show position slider, time pickers Open time/Close time, Open payload/Close payload, Enabled, the schedule helper text, Width/Full/Half/Third, QoS labels, Retain, Publish topic/Subscribe topic labels+helpers, the `typeLabel` switch values Button/Toggle/Slider/LED/Node Status/Progress/Multi-State/Combo/Radio/Cover/Text Input/Text Log/Schedule, and the `New X`/`Edit X` title), plus `panel_tile.dart` options sheet (`Edit panel`, `Duplicate panel`, `Move up`, `Move down`, `Width`, `Full`/`Half`/`⅓`, `Delete panel`) and the schedule snackbar.

For the `New $typeLabel` / `Edit $typeLabel` title, add `panelFormNew`/`panelFormEdit` with a `{type}` placeholder and feed the localized type label.

`flutter gen-l10n && flutter analyze`, commit `i18n: localize panel form + tile`.

---

## Task 8: Localize the 12 panel widgets

**Files:** all of `lib/features/panels/widgets/{button,toggle,slider,cover,led,node_status,progress,multi_state,combo,radio,text_input,text_log,schedule}_panel.dart`; ARBs.

Extract every user-facing literal, e.g.: cover `Open`/`Stop`/`Close` (`coverOpen`/`coverStop`/`coverClose`); schedule `Opens {time}`/`Closes {time}` (placeholders), `Scheduler offline — won't run` (`schedulerOffline`), `Disabled`, `Next: {action} at {at}`, the "Not connected — saved…" snackbar; node status online/offline labels; text input hint/send; text log empty state; any `'—'` placeholders may stay. Reuse keys where identical. Read each widget; some have no user-facing text (skip those).

`flutter gen-l10n && flutter analyze`, commit `i18n: localize panel widgets`.

---

## Task 9: RTL audit

**Files:** any with directional layout literals.

- [ ] **Step 1: Find offenders.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && grep -rn 'EdgeInsets.only(.*\(left\|right\):\|Alignment.centerLeft\|Alignment.centerRight\|TextAlign.left\|TextAlign.right\|Positioned(.*\(left\|right\):' lib/ || echo NONE"`

- [ ] **Step 2: Convert** each hit to its directional equivalent: `EdgeInsets.only(left:/right:)` → `EdgeInsetsDirectional.only(start:/end:)`; `Alignment.centerLeft/Right` → `AlignmentDirectional.centerStart/centerEnd`; `TextAlign.left/right` → `TextAlign.start/end`; `Positioned` → `PositionedDirectional`. Leave symmetric/`horizontal:` paddings and `MainAxisAlignment` as-is. Don't change icon arrows that are semantically physical (e.g. cover up/down arrows).

- [ ] **Step 3: Analyze + commit.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter analyze 2>&1 | tail -2"`
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'i18n: RTL-safe directional layout'"
```

---

## Task 10: Locale/RTL widget test + final verification

**Files:** Create `test/app/locale_test.dart`.

- [ ] **Step 1: Write the test.** Pumps the Settings screen forced to `he` and asserts Hebrew text + RTL:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/features/settings/screens/settings_screen.dart';

void main() {
  testWidgets('Settings renders Hebrew + RTL when locale is he', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(
        locale: Locale('he'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: SettingsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('הגדרות'), findsOneWidget);   // navSettings (he)
    expect(find.text('שפה'), findsOneWidget);        // settingsLanguage (he)
    expect(Directionality.of(tester.element(find.byType(SettingsScreen))), TextDirection.rtl);
  });
}
```

- [ ] **Step 2: Run it (expect PASS) + full suite + analyze.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n && flutter test 2>&1 | tail -3 && flutter analyze 2>&1 | tail -2"`

- [ ] **Step 3: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'test(i18n): Hebrew + RTL widget test'"
```

- [ ] **Step 4: On-device verification (REQUIRED SUB-SKILL: superpowers:verification-before-completion).**
  1. `flutter build apk --debug`, install, open **Settings**.
  2. Theme System/Light/Dark — re-themes immediately and persists across restart.
  3. Material You off → brand blue; on (Android 12+) → wallpaper palette.
  4. Language → עברית: whole UI switches to Hebrew + flips RTL; persists. System → follows device.
  5. Spot-check connections form, a dashboard, the panel form, and a panel tile in Hebrew for translated text + correct mirroring.

---

## Self-review notes (author)

- **Spec coverage:** mechanism/gen-l10n (T1), AppSettings+controller+prefs (T2), main+app wiring incl. locale/delegates/RTL-auto (T3), Settings UI theme+language (T4), full string migration (T5–T8), RTL audit (T9), tests + device verification (T2/T10) — all mapped.
- **Type consistency:** `settingsControllerProvider` / `sharedPreferencesProvider` / `AppSettings{themeMode,dynamicColor,locale}` / `setThemeMode|setDynamicColor|setLocale` / `context.l10n` used identically across tasks. ARB keys reused (`save`, `saving`, `advanced`, `fieldRequired`) rather than duplicated.
- **Known pragmatic deviation:** Tasks 6–8 cannot pre-enumerate every literal without bloating the plan; they specify the files, the procedure, the glossary, and a fully-worked example (Task 5), then instruct exhaustive per-file extraction. The `flutter gen-l10n` step is the safety net — a missing `he` key for any `en` key fails generation, so coverage gaps surface immediately.
- **Translations** are first-pass; gilad (native Hebrew) should review the ARB on completion.
