import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/app.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

/// End-to-end discovery-first setup on a real device/emulator against a real
/// MQTT broker on the host. From the emulator, the host is reachable inside
/// the scanned /24 as 10.0.2.2 — no adb reverse needed for the scan itself,
/// but the mini broker must listen on an interface the NAT alias reaches
/// (127.0.0.1 works: 10.0.2.2 maps to the host loopback).
///
/// Run with a broker reachable from the device:
///   flutter test integration_test/setup_flow_test.dart -d DEVICE
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Bounded polling pump: the flow owns real timers and sockets, so
  /// pumpAndSettle is unsafe once network work starts.
  Future<bool> waitFor(
      WidgetTester tester, bool Function() condition, Duration step,
      {int max = 60}) async {
    for (var i = 0; i < max; i++) {
      await tester.pump(step);
      if (condition()) return true;
    }
    return false;
  }

  testWidgets('setup: welcome → scan → review → create → dashboard',
      (tester) async {
    // Deterministic fresh state regardless of previous runs on the device.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ZigDashApp(),
    ));
    await tester.pumpAndSettle();

    // --- A fresh install opens directly on setup: one door, no carousel ---
    expect(find.text('Find my setup'), findsOneWidget);

    // --- Scan: the host's broker (10.0.2.2). With exactly one broker found
    // setup continues on its own; with several, pick the first. ---
    await tester.tap(find.text('Find my setup'));
    final inReview = await waitFor(
      tester,
      () {
        final picker = find.text('Possible connection found');
        if (tester.any(picker) && !tester.any(find.byType(CircularProgressIndicator))) {
          tester.tap(picker.first);
        }
        return tester.any(find.textContaining('devices found'));
      },
      const Duration(milliseconds: 500),
    );
    expect(inReview, isTrue,
        reason: 'review screen with discovered device count');

    // The mini broker's three devices: lamp-style controls preselected.
    expect(find.text('office_light'), findsOneWidget);
    expect(find.textContaining('Create dashboard with'), findsOneWidget);

    // --- Create the first dashboard: it opens directly, no "ready" screen ---
    await tester.tap(find.textContaining('Create dashboard with'));
    final onDashboards = await waitFor(
      tester,
      () => tester.any(find.text('office_light')) &&
          !tester.any(find.textContaining('Create dashboard with')),
      const Duration(seconds: 1),
    );
    expect(onDashboards, isTrue,
        reason: 'a created panel is visible on the new dashboard');
    expect(find.text('Your dashboard is ready'), findsNothing);
  });
}
