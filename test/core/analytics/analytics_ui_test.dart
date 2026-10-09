import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/analytics/analytics_tracker.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/dashboards/widgets/analytics_consent_card.dart';
import 'package:zigdash/features/onboarding/demo_service.dart';
import 'package:zigdash/features/onboarding/setup/setup_analytics.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

Connection _home(String host) => Connection(
      id: 'c1',
      name: 'Home',
      host: host,
      port: 1883,
      protocol: MqttProtocol.tcp,
      keepAliveSeconds: 60,
      autoConnect: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

Future<SharedPreferences> _card(WidgetTester tester,
    {required String host, Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      analyticsAvailableProvider.overrideWithValue(true),
      analyticsSinkProvider.overrideWithValue(_NullSink()),
      connectionByIdProvider.overrideWith((ref, _) async => _home(host)),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: AnalyticsConsentCard(connectionId: 'c1')),
    ),
  ));
  await tester.pump();
  return p;
}

class _NullSink implements AnalyticsSink {
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) {}
}

void main() {
  group("the upgraders' card", () {
    testWidgets('asks once on a real home and records the answer',
        (tester) async {
      final prefs = await _card(tester, host: '192.168.1.2');
      expect(find.text('Help improve ZigDash?'), findsOneWidget);
      await tester.tap(find.text('Share'));
      await tester.pump();
      expect(prefs.getBool('analytics_consent'), isTrue);
      expect(find.text('Help improve ZigDash?'), findsNothing);
    });

    testWidgets('No thanks is remembered', (tester) async {
      final prefs = await _card(tester, host: '192.168.1.2');
      await tester.tap(find.text('No thanks'));
      await tester.pump();
      expect(prefs.getBool('analytics_consent'), isFalse);
      expect(find.text('Help improve ZigDash?'), findsNothing);
    });

    testWidgets('never on the demo home', (tester) async {
      await _card(tester, host: demoHost);
      expect(find.text('Help improve ZigDash?'), findsNothing);
    });

    testWidgets('never once answered', (tester) async {
      await _card(tester,
          host: '192.168.1.2', prefs: {'analytics_consent': false});
      expect(find.text('Help improve ZigDash?'), findsNothing);
    });
  });

  group('setup steps', () {
    const scanning = SetupScanning([]);
    test('the funnel', () {
      expect(setupStepFor(const SetupIdle(), scanning)?.props,
          {'step': 'started'});
      expect(setupStepFor(scanning, const SetupScanning([], done: true)), isNull,
          reason: 'more scan results are not a step');
      expect(setupStepFor(scanning, const SetupScanEmpty())?.props,
          {'step': 'scan_empty'});
      expect(
          setupStepFor(null,
                  const SetupFailed(SetupErrorKind.authRequired))
              ?.props,
          {'step': 'failed', 'error': 'auth_required'});
      expect(
          setupStepFor(
                  null,
                  const SetupComplete(SetupResult(
                      connectionId: 'c', dashboardId: 'd', panelCount: 12)))
              ?.props,
          {'step': 'complete', 'devices': '6-20'});
    });
  });

  test('routes that count as features', () {
    expect(featureForPath('/connections/c1/devices'), Feature.devicesTab);
    expect(featureForPath('/connections/c1/devices/0x1'), Feature.devicePage);
    expect(featureForPath('/connections/c1/scenes'), Feature.scenes);
    expect(featureForPath('/connections/c1/dashboards'), isNull);
    expect(featureForPath('/settings'), isNull);
  });
}
