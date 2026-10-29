import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/dashboards/widgets/remote_offer_card.dart';
import 'package:zigdash/features/ha_import/ha_import_offer.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/remote/remote_home.dart';
import 'package:zigdash/remote/remote_setup.dart';

class _Sink implements AnalyticsSink {
  final sent = <String>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

Connection _home(String host) => Connection(
  transport: ConnectionTransport.mqtt,
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

const _title = 'Control your home from anywhere';
const _ready = {'analytics_consent': true, 'review_sessions': 5};

Future<(SharedPreferences, _Sink, GoRouter)> _card(
  WidgetTester tester, {
  Map<String, Object> prefs = _ready,
  ProStatus pro = ProStatus.locked,
  bool sold = true,
  bool atHome = true,
  RemoteHome? remote,
  String host = '192.168.1.10',
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final sink = _Sink();
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: Column(
            children: [
              const RemoteOfferCard(connectionId: 'c1'),
            ],
          ),
        ),
      ),
      GoRoute(
        path: '/settings/home/:id/remote',
        builder: (_, _) => const Text('remote screen'),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        analyticsAvailableProvider.overrideWithValue(true),
        analyticsSinkProvider.overrideWithValue(sink),
        proStatusProvider.overrideWithValue(pro),
        proPurchaseProvider.overrideWithValue(() {}),
        proPriceProvider.overrideWith((ref) async => null),
        remoteSoldProvider.overrideWithValue(sold),
        atHomeProvider.overrideWith((ref, _) => atHome),
        remoteHomeProvider.overrideWith((ref, _) async => remote),
        connectionByIdProvider.overrideWith((ref, _) async => _home(host)),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (p, sink, router);
}

void main() {
  testWidgets('offered at home on day five, counted once as shown', (
    tester,
  ) async {
    final (_, sink, _) = await _card(tester);
    expect(find.text(_title), findsOneWidget);
    expect(find.textContaining('no monthly fee'), findsOneWidget);
    expect(sink.sent, ['remote {step: offer_shown, pro: no}']);
  });

  testWidgets('without Pro, Show me opens the Pro screen', (tester) async {
    final (prefs, sink, _) = await _card(tester);
    await tester.tap(find.byKey(const Key('remote-offer-open')));
    await tester.pumpAndSettle();
    expect(find.text('ZigDash Pro'), findsOneWidget);
    expect(sink.sent, [
      'remote {step: offer_shown, pro: no}',
      'remote {step: offer_opened, pro: no}',
      'pro {step: screen_shown}',
    ]);
    expect(prefs.getString(remoteOfferDoneKey), '1');
  });

  testWidgets('with Pro, Show me opens Remote control', (tester) async {
    final (_, sink, _) = await _card(tester, pro: ProStatus.unlocked);
    expect(find.textContaining('You have Pro'), findsOneWidget);
    await tester.tap(find.byKey(const Key('remote-offer-open')));
    await tester.pumpAndSettle();
    expect(find.text('remote screen'), findsOneWidget);
    expect(sink.sent.last, 'remote {step: offer_opened, pro: yes}');
  });

  testWidgets('Not now puts it away for good', (tester) async {
    final (prefs, sink, _) = await _card(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text(_title), findsNothing);
    expect(sink.sent.last, 'remote {step: offer_not_now, pro: no}');
    expect(prefs.getString(remoteOfferDoneKey), '1');
  });

  testWidgets('asked only once', (tester) async {
    await _card(tester, prefs: {..._ready, remoteOfferDoneKey: '1'});
    expect(find.text(_title), findsNothing);
  });

  testWidgets('not before day five', (tester) async {
    await _card(tester, prefs: {..._ready, 'review_sessions': 4});
    expect(find.text(_title), findsNothing);
  });

  testWidgets('not away from home', (tester) async {
    await _card(tester, atHome: false);
    expect(find.text(_title), findsNothing);
  });

  testWidgets('not where Pro is not sold', (tester) async {
    await _card(tester, sold: false);
    expect(find.text(_title), findsNothing);
  });

  testWidgets('not when remote control is already on', (tester) async {
    await _card(
      tester,
      remote: RemoteHome(
        homeId: 'h',
        url: 'wss://relay.example/mqtt',
        username: 'u',
        password: 'p',
        key: Uint8List(32),
      ),
    );
    expect(find.text(_title), findsNothing);
  });

  testWidgets('not on the demo home', (tester) async {
    await _card(tester, host: demoHost);
    expect(find.text(_title), findsNothing);
  });

  testWidgets('the other first-run cards come first', (tester) async {
    await _card(tester, prefs: {'review_sessions': 5});
    expect(find.text(_title), findsNothing);
    await _card(tester, prefs: {..._ready, HaImportOffer.key: 'c1'});
    expect(find.text(_title), findsNothing);
  });
}
