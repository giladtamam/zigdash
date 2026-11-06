import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/analytics/analytics_tracker.dart';
import 'package:zigdash/core/router/app_router.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/shortcuts.dart';
import 'package:zigdash/features/onboarding/demo_service.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

class _Sink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 11, 5);

  setUp(() => db = AppDatabase.test(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> home(String id, String host) => db.into(db.connections).insert(
        ConnectionsCompanion.insert(
          id: id,
          name: id,
          host: host,
          port: 1883,
          protocol: MqttProtocol.tcp,
          autoConnect: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
      );

  Future<void> scene(String id, String connectionId) => db.into(db.scenes).insert(
        ScenesCompanion.insert(
          id: id,
          connectionId: connectionId,
          name: id,
          iconCodepoint: 0,
          colorSeed: 0,
          actions: '[]',
          createdAt: now,
          updatedAt: now,
        ),
      );

  Future<void> shortcut(String id, String connectionId, int slot) => db.into(db.shortcuts).insert(
        ShortcutsCompanion.insert(
          id: id,
          connectionId: connectionId,
          kind: ShortcutKind.device,
          surface: ShortcutSurface.tile,
          targets: '[]',
          tileSlot: Value(slot),
          createdAt: now,
        ),
      );

  Future<Map<String, String>> started(WidgetTester tester, Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues({'analytics_consent': true, ...prefs});
    final p = await SharedPreferences.getInstance();
    final sink = _Sink();
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(p),
          appDatabaseProvider.overrideWithValue(db),
          analyticsAvailableProvider.overrideWithValue(true),
          analyticsSinkProvider.overrideWithValue(sink),
          routerProvider.overrideWithValue(router),
        ],
        child: AnalyticsTracker(child: MaterialApp.router(routerConfig: router)),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    return sink.sent.singleWhere((e) => e.$1 == 'app_started').$2;
  }

  testWidgets('app_started counts what the real homes have set up', (tester) async {
    await tester.runAsync(() async {
      await home('a', '192.168.1.10');
      await home('b', '192.168.1.11');
      await scene('s1', 'a');
      await shortcut('k1', 'b', 0);
    });
    final props = await started(tester, {
      'engine.installed.a': true,
      'engine.rules.a': 2,
      'engine.installed.b': true,
      'engine.rules.b': 3,
      // A home that was deleted: its keys stay behind and must not count.
      'engine.installed.gone': true,
      'engine.rules.gone': 9,
    });
    expect(props['homes'], '2+');
    expect(props['automations'], '4+');
    expect(props['scenes'], '1+');
    expect(props['shortcuts'], '1+');
  });

  testWidgets("app_started leaves the demo home's scenes and shortcuts out", (tester) async {
    await tester.runAsync(() async {
      await home('demo', demoHost);
      await scene('s1', 'demo');
      await shortcut('k1', 'demo', 0);
    });
    final props = await started(tester, {'engine.installed.demo': true, 'engine.rules.demo': 5});
    expect(props['homes'], '0');
    expect(props['automations'], '0');
    expect(props['scenes'], '0');
    expect(props['shortcuts'], '0');
  });

  testWidgets('a rule count without a known Engine is not counted', (tester) async {
    await tester.runAsync(() => home('a', '192.168.1.10'));
    final props = await started(tester, {'engine.rules.a': 2});
    expect(props['automations'], '0');
  });
}
