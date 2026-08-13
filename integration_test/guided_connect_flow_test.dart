import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/app.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

/// End-to-end guided-connect flow on a real device/emulator against a real
/// MQTT broker. Point the wizard at a live broker (from the emulator, the
/// host's broker is 10.0.2.2) and expect the full ladder to pass and the
/// "Found N devices" success moment to render.
///
/// Run with a broker reachable from the device:
///   flutter test integration_test/guided_connect_flow_test.dart -d DEVICE
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('guided connect: wizard → real broker → Found N devices',
      (tester) async {
    // Deterministic fresh state regardless of previous runs on the device.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ZigDashApp(),
    ));
    await tester.pumpAndSettle();

    // --- Onboarding → last page → "Connect my broker" → discovery-first
    // setup → "Enter details manually" (the guided form is the flow's
    // manual fallback since v2's discovery-first onboarding). ---
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connect my broker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter details manually'));
    await tester.pumpAndSettle();

    // --- Wizard: default Z2M preset (localhost:1883). Run with
    // `adb reverse tcp:1883 tcp:1883` so the device's localhost reaches the
    // host's broker. ---
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Local host'), 'localhost');
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Test & connect'));

    // Real ladder: connect + 3s device window + auto-save. The app owns MQTT
    // timers from here, so pumpAndSettle is unsafe — poll with bounded pumps.
    var found = false;
    for (var i = 0; i < 24 && !found; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      found = tester.any(find.textContaining('Found '));
    }
    expect(found, isTrue, reason: 'success screen with a device count');
    expect(find.textContaining('Continue to dashboard'), findsOneWidget);

    // --- Continue → the saved connection's dashboard area ---
    await tester.tap(find.text('Continue to dashboard'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Continue to dashboard'), findsNothing);
    // Landed on the saved connection's dashboards screen (title = host).
    expect(find.text('localhost'), findsWidgets);
  });
}
