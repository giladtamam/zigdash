import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/features/onboarding/setup/ha_handover.dart';

class _Sink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

// docs/design/ha-share-paste.md
void main() {
  group('text shared to ZigDash from another app', () {
    Future<(GoRouter, _Sink)> pump(WidgetTester tester) async {
      final sink = _Sink();
      final router = GoRouter(
        initialLocation: Routes.setup,
        routes: [
          GoRoute(path: Routes.setup, builder: (_, __) => const Text('setup')),
          GoRoute(
            path: Routes.haConnect,
            builder: (_, state) => Text('sign-in ${state.uri.query}'),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      return (router, sink);
    }

    testWidgets("the Home Assistant app's Share server link opens the sign-in "
        'with its address', (tester) async {
      final (router, sink) = await pump(tester);
      openSharedHaText(
        router,
        Analytics(sink, enabled: true),
        'https://my.home-assistant.io/invite/#url=https%3A%2F%2Fabc.ui.nabu.casa',
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'sign-in host=https%3A%2F%2Fabc.ui.nabu.casa&from=shared',
        ),
        findsOneWidget,
      );
      // Counted as found; never the address.
      expect(sink.sent.single.$1, 'setup_step');
      expect(sink.sent.single.$2, {'step': 'ha_share', 'result': 'address'});
    });

    testWidgets('text with no address still opens the sign-in, which says so', (
      tester,
    ) async {
      final (router, sink) = await pump(tester);
      openSharedHaText(router, Analytics(sink, enabled: true), 'hello there');
      await tester.pumpAndSettle();
      expect(find.text('sign-in from=shared'), findsOneWidget);
      expect(sink.sent.single.$2, {'step': 'ha_share', 'result': 'no_address'});
    });
  });

  test('the shared sign-in link carries the address and where it came from', () {
    expect(
      Uri.parse(Routes.haConnectShared('http://192.168.1.20:8123')).queryParameters,
      {'host': 'http://192.168.1.20:8123', 'from': 'shared'},
    );
    expect(Uri.parse(Routes.haConnectShared(null)).queryParameters, {
      'from': 'shared',
    });
  });

  group('ZigDash is in share sheets only until a home exists', () {
    late AppDatabase db;
    late ProviderContainer c;

    setUp(() {
      db = AppDatabase.test(NativeDatabase.memory());
      c = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
    });
    tearDown(() async {
      c.dispose();
      await db.close();
    });

    Future<void> addHome(String id, String host) =>
        db.into(db.connections).insert(
          ConnectionsCompanion.insert(
            id: id,
            name: id,
            host: host,
            port: 1883,
            protocol: MqttProtocol.tcp,
            createdAt: DateTime(2026, 11, 6),
            updatedAt: DateTime(2026, 11, 6),
          ),
        );

    Future<bool> next() async {
      final seen = <bool>[];
      final sub = c.listen(haShareTargetProvider, (_, v) {
        if (v.value != null) seen.add(v.value!);
      }, fireImmediately: true);
      await pumpEventQueue();
      sub.close();
      return seen.last;
    }

    test('on with no home, and with only the demo home', () async {
      expect(await next(), isTrue);
      await addHome('demo', demoHost);
      expect(await next(), isTrue);
    });

    test('off once a real home exists', () async {
      await addHome('home', '192.168.1.20');
      expect(await next(), isFalse);
    });

    test('never on outside Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final ios = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(ios.dispose);
      expect(await ios.read(haShareTargetProvider.future), isFalse);
    });
  });
}
