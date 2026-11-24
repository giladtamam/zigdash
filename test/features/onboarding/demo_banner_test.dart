import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/onboarding/demo_banner.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:zigdash/features/zha_move/zha_move.dart';
import 'package:zigdash/l10n/app_localizations.dart';

Connection _conn(String host) => Connection(
  transport: ConnectionTransport.mqtt,
  id: 'c1',
  name: 'Home',
  host: host,
  port: 1883,
  protocol: MqttProtocol.tcp,
  keepAliveSeconds: 60,
  autoConnect: true,
  createdAt: DateTime(2026, 9, 26),
  updatedAt: DateTime(2026, 9, 26),
);

Future<void> _pump(
  WidgetTester tester,
  String host, {
  List<Override> extra = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectionByIdProvider.overrideWith((ref, id) async => _conn(host)),
        ...extra,
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) =>
                  const Scaffold(body: DemoBanner(connectionId: 'c1')),
            ),
            GoRoute(
              path: Routes.setup,
              builder: (_, __) => const Text('setup'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // First-run decision: demo mode is persistent but marked, with a way out.
  testWidgets('a demo home shows the demo bar, which opens setup', (
    tester,
  ) async {
    await _pump(tester, 'demo.local');
    expect(find.text("You're in demo mode"), findsOneWidget);

    await tester.tap(find.text('Connect your home'));
    await tester.pumpAndSettle();
    expect(find.text('setup'), findsOneWidget);
  });

  testWidgets('a real home shows no demo bar', (tester) async {
    await _pump(tester, '192.168.1.20');
    expect(find.text("You're in demo mode"), findsNothing);
  });

  testWidgets('3.8: after a ZHA answer, the demo bar offers Moving from ZHA', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({zhaAnsweredKey: true});
    final prefs = await SharedPreferences.getInstance();
    final sent = <String>[];
    await _pump(
      tester,
      'demo.local',
      extra: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        analyticsProvider.overrideWithValue(
          Analytics(_Sink(sent), enabled: true),
        ),
      ],
    );
    await tester.tap(find.byKey(const Key('demo-zha-move')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('zha-move-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('zha-move-not-now')));
    await tester.pumpAndSettle();
    expect(sent, ['zha_move opened demo', 'zha_move not_now demo']);
  });

  testWidgets('3.8: no ZHA answer, no Moving from ZHA', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await _pump(
      tester,
      'demo.local',
      extra: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    expect(find.byKey(const Key('demo-zha-move')), findsNothing);
  });
}

class _Sink implements AnalyticsSink {
  _Sink(this.sent);
  final List<String> sent;
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) =>
      sent.add('$name ${props['step']} ${props['from']}');
}
