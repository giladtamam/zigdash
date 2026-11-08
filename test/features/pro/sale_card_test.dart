import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';
import 'package:zigdash/core/review/review_prompt_controller.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/pro/sale_card.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/remote/remote_home.dart';
import 'package:zigdash/remote/remote_setup.dart';

Connection _home({
  String host = '192.168.1.10',
  ConnectionTransport transport = ConnectionTransport.mqtt,
}) => Connection(
  transport: transport,
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

ProOffer _sale({DateTime? ends}) => ProOffer(
  price: '€4.79',
  priceMicros: 4790000,
  fullPriceMicros: 7990000,
  currency: 'EUR',
  percent: 40,
  ends: ends ?? DateTime.now().add(const Duration(days: 10)),
  offerId: 'november-2026',
);

Future<SharedPreferences> _pump(
  WidgetTester tester, {
  Connection? home,
  ProStatus status = ProStatus.locked,
  int days = 3,
  ProOffer? offer,
  bool noOffer = false,
  RemoteHome? paired,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues({
    ReviewPromptController.kSessions: days,
    ...prefs,
  });
  final sp = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        proStatusProvider.overrideWithValue(status),
        connectionByIdProvider.overrideWith((ref, _) async => home ?? _home()),
        remoteHomeProvider.overrideWith((ref, _) async => paired),
        proOfferProvider.overrideWith(
          (ref) async => noOffer ? null : offer ?? _sale(),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SaleCard(connectionId: 'c1')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return sp;
}

final _card = find.byKey(const Key('sale-card'));

void main() {
  testWidgets('a locked phone on a broker home sees the remote line', (
    tester,
  ) async {
    final sp = await _pump(tester);
    expect(_card, findsOneWidget);
    expect(find.textContaining('40%'), findsOneWidget);
    expect(find.textContaining('from anywhere'), findsOneWidget);
    expect(sp.getString(saleCardShownKey('november-2026')), '1');
  });

  testWidgets('a Home Assistant home is not promised remote control', (
    tester,
  ) async {
    await _pump(
      tester,
      home: _home(transport: ConnectionTransport.homeAssistant),
    );
    expect(find.textContaining('automations'), findsOneWidget);
    expect(find.textContaining('from anywhere'), findsNothing);
  });

  final hidden = <String, Future<void> Function(WidgetTester)>{
    'Pro owner': (t) => _pump(t, status: ProStatus.unlocked),
    'status not known yet': (t) => _pump(t, status: ProStatus.unavailable),
    'too new': (t) => _pump(t, days: 2),
    'demo home': (t) => _pump(t, home: _home(host: demoHost)),
    'Zigbee2MQTT page home': (t) =>
        _pump(t, home: _home(transport: ConnectionTransport.z2mPage)),
    'no offer': (t) => _pump(t, noOffer: true),
    'sale over': (t) => _pump(
      t,
      offer: _sale(ends: DateTime.now().subtract(const Duration(hours: 1))),
    ),
    'plain price': (t) => _pump(
      t,
      offer: const ProOffer(price: '€7.99', offerId: 'x'),
    ),
    'already put away': (t) =>
        _pump(t, prefs: {saleCardDoneKey('november-2026'): '1'}),
  };
  hidden.forEach((name, pump) {
    testWidgets('no card: $name', (tester) async {
      await pump(tester);
      expect(_card, findsNothing);
    });
  });

  testWidgets('closing puts it away for this sale', (tester) async {
    final sp = await _pump(tester);
    await tester.tap(find.byKey(const Key('sale-card-close')));
    await tester.pumpAndSettle();
    expect(_card, findsNothing);
    expect(sp.getString(saleCardDoneKey('november-2026')), '1');
  });

  test('events carry the step and the Pro path', () {
    expect(const SaleCardEvent(SaleCardStep.opened).name, 'sale_card');
    expect(const SaleCardEvent(SaleCardStep.opened).props, {'step': 'opened'});
    expect(
      const ProEvent(ProStep.screenShown, from: ProFrom.saleCard).props['path'],
      'sale_card/screen_shown',
    );
  });
}
