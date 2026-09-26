import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/app.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics_provider.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_providers.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

/// End-to-end first run into the demo on a fresh install:
/// setup → Find my setup finds nothing → Try demo → the demo dashboard opens
/// directly, marked with the demo bar, with the seeded panels.
///
/// The scan is stubbed to find nothing so the run does not depend on the
/// test phone's network; the demo is only offered where setup cannot finish.
///
///   flutter test integration_test/app_flow_test.dart -d DEVICE
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fresh install: nothing found → Try demo → demo dashboard',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        setupCoordinatorProvider.overrideWith((ref) {
          final coordinator = SetupCoordinator(
            scan: (_) => const Stream.empty(),
            deviceIp: () async => '10.0.2.15',
            diagnostics: ref.watch(connectDiagnosticsProvider),
            fetchDevices: (_, __, ___) async =>
                const Z2mFetchResult(detected: false, devices: []),
            creator: SetupCreator(
              connections: ref.watch(connectionRepoProvider),
              dashboards: ref.watch(dashboardRepoProvider),
              panels: ref.watch(panelRepoProvider),
            ),
          );
          ref.onDispose(coordinator.dispose);
          return coordinator;
        }),
      ],
      child: const ZigDashApp(),
    ));
    await tester.pumpAndSettle();

    // --- One door: the app opens on setup, no carousel ---
    expect(find.text('Find my setup'), findsOneWidget);
    expect(find.text('Try demo'), findsNothing);

    await tester.tap(find.text('Find my setup'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No connection found'), findsOneWidget);

    // --- The demo, from the dead end. From here the app owns MQTT timers,
    // so pumpAndSettle is unsafe; use bounded pumps. ---
    await tester.tap(find.text('Try demo'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // --- The demo dashboard opens directly, marked as demo ---
    expect(find.text("You're in demo mode"), findsOneWidget);
    expect(find.text('Connect your home'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Living Room Light'), findsOneWidget);
    expect(find.text('Living Room Cover'), findsOneWidget);
    expect(find.text('Front Door'), findsOneWidget);
  });
}
