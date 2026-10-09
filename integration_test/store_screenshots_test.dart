import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/app.dart';
import 'package:zigdash/core/build/store_capture.dart';
import 'package:zigdash/core/router/app_router.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/features/onboarding/first_run.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

/// Play Store screenshots (signal-2.0.md §10), from the demo home on a fresh
/// install. Run by tool/store/capture.sh, one locale and form factor per run:
///
///   --dart-define=ZIGDASH_STORE_CAPTURE=true
///   --dart-define=STORE_LOCALE=fr      en, fr, de, es, he
///   --dart-define=STORE_FORM=tablet    phone (6 shots) or tablet (2 shots)
const _locale = String.fromEnvironment('STORE_LOCALE', defaultValue: 'en');
const _form = String.fromEnvironment('STORE_FORM', defaultValue: 'phone');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store screenshots: $_form, $_locale', (tester) async {
    expect(storeCapture, isTrue,
        reason: 'build with --dart-define=ZIGDASH_STORE_CAPTURE=true');
    final l10n = lookupAppLocalizations(Locale(_locale));

    SharedPreferences.setMockInitialValues({'locale': _locale});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c.dispose);
    // Fresh install into the demo; tablets end first run in dark (§5).
    final home = await c.read(firstRunProvider).startDemo();

    await tester.pumpWidget(UncontrolledProviderScope(
        container: c, child: const ZigDashApp()));
    // The app owns MQTT timers: bounded pumps, never pumpAndSettle.
    Future<void> settle() async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await settle();
    await binding.convertFlutterSurfaceToImage();
    Future<void> shot(String name) async {
      await settle();
      await binding.takeScreenshot(name);
    }

    final router = c.read(routerProvider);
    Future<void> go(String location) async {
      router.go(location);
      await settle();
    }

    if (_form == 'tablet') {
      // 1. The wall tablet: dark, rail, columns.
      await shot('01-dashboard');
      // 2. Devices as list-detail, the attention device open beside it.
      await go(Routes.homeDevices(home));
      await tester.tap(find.text('Front door').first);
      await shot('02-devices');
      return;
    }

    // 1. The dashboard, light.
    await shot('01-dashboard');
    // 2. A light's controls: brightness and colour.
    await tester.tap(find.text('Living room bulb'));
    await shot('02-device-controls');
    await tester.tapAt(const Offset(20, 80)); // close the sheet
    await settle();
    // 3. Devices, with the one needing attention first.
    await go(Routes.homeDevices(home));
    await shot('03-devices');
    // 4. That device's own page.
    await go(Routes.homeDevice(home, '0xdemo000000000005'));
    await shot('04-device-page');
    // 5. The dashboard in dark.
    await c
        .read(settingsControllerProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    await go(Routes.homeDashboards(home));
    await shot('05-dashboard-dark');
    // 6. Edit mode: arrange tiles, with Undo.
    await c
        .read(settingsControllerProvider.notifier)
        .setThemeMode(ThemeMode.light);
    await tester.tap(find.byTooltip(l10n.dashEditDashboard));
    await shot('06-edit-mode');
  });
}
