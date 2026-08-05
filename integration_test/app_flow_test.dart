import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/app.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

/// End-to-end boot flow on a fresh install:
/// onboarding pages → demo mode → connections list → demo connection →
/// dashboard tab → panel grid renders the seeded demo panels.
///
/// Run on a device or emulator:
///   flutter test integration_test -d DEVICE
/// or via the host driver:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/app_flow_test.dart -d DEVICE
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fresh install: onboarding → demo mode → dashboard grid',
      (tester) async {
    // Deterministic fresh state regardless of previous runs on the device.
    // Mirror lib/main.dart wiring: ZigDashApp needs a ProviderScope with the
    // real SharedPreferences instance (the provider throws otherwise).
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ZigDashApp(),
    ));
    await tester.pumpAndSettle();

    // --- Onboarding: page 1 ---
    expect(find.text('Welcome to ZigDash'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Connect your broker'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Build your dashboards'), findsOneWidget);

    // --- Enter demo mode. From here on the app owns MQTT auto-connect /
    // reconnect timers, so pumpAndSettle is unsafe; use bounded pumps. ---
    await tester.tap(find.text('Try demo'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // --- Connections list: demo connection seeded ---
    expect(find.text('Demo Smart Home'), findsOneWidget);

    // --- Open the demo connection → dashboards tab bar ---
    await tester.tap(find.text('Demo Smart Home'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('My Home'), findsWidgets); // dashboard tab label

    // --- Panel grid renders the seeded demo panels ---
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Living Room Light'), findsOneWidget);
    expect(find.text('Brightness'), findsOneWidget);
    expect(find.text('Living Room Cover'), findsOneWidget);
    expect(find.text('Front Door'), findsOneWidget);
  });
}
