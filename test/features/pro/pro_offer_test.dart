import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/pro/pro_screen.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

class _Sink implements AnalyticsSink {
  final sent = <String>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

const _channel = MethodChannel('zigdash/billing');

ProOffer _sale({Duration left = const Duration(days: 3)}) => ProOffer(
  price: '€4.79',
  priceMicros: 4790000,
  fullPriceMicros: 7990000,
  currency: 'EUR',
  percent: 40,
  ends: DateTime.now().add(left),
  offerId: 'november',
);

Connection _home(String id, {ConnectionTransport? transport, String? host}) =>
    Connection(
      transport: transport ?? ConnectionTransport.mqtt,
      id: id,
      name: id,
      host: host ?? '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
      keepAliveSeconds: 60,
      autoConnect: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

// 3.4.4 (docs/design/remote-tab.md): a sale is a Play discount offer. The
// app shows Play's own numbers, and buys exactly what it showed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('what Play says about the price', () {
    test('the plain price', () {
      final o = ProOffer.fromChannel({
        'price': '€7.99',
        'priceMicros': 7990000,
        'currency': 'EUR',
        'fullPriceMicros': null,
        'percent': null,
        'endMs': null,
        'offerId': null,
      })!;
      expect(o.price, '€7.99');
      expect(o.onSale(DateTime(2026, 11, 20)), isFalse);
      expect(o.fullPrice('en'), isNull);
      expect(o.offerId, isNull);
    });

    test('a discount offer: full price, percent and end, all from Play', () {
      final end = DateTime(2026, 11, 30, 23, 59);
      final o = ProOffer.fromChannel({
        'price': '€4.79',
        'priceMicros': 4790000,
        'currency': 'EUR',
        'fullPriceMicros': 7990000,
        'percent': 40,
        'endMs': end.millisecondsSinceEpoch,
        'offerId': 'november',
      })!;
      expect(o.onSale(DateTime(2026, 11, 20)), isTrue);
      expect(o.percent, 40);
      expect(o.ends, end);
      expect(o.fullPrice('en'), '€7.99');
      expect(o.offerId, 'november');
      // The line is not drawn once the end has passed, whatever is cached.
      expect(o.onSale(DateTime(2026, 12, 1)), isFalse);
    });

    test('an amount-off offer still gets a percentage', () {
      final o = ProOffer.fromChannel({
        'price': '€5.99',
        'priceMicros': 5990000,
        'currency': 'EUR',
        'fullPriceMicros': 7990000,
        'percent': null,
        'endMs': null,
        'offerId': 'two-off',
      })!;
      expect(o.percent, 25);
      expect(o.ends, isNull);
      expect(o.onSale(DateTime(2030)), isTrue, reason: 'Play gave no end');
    });

    test('a "full price" that is not higher is no sale', () {
      final o = ProOffer.fromChannel({
        'price': '€7.99',
        'priceMicros': 7990000,
        'currency': 'EUR',
        'fullPriceMicros': 7990000,
        'percent': 0,
      })!;
      expect(o.onSale(DateTime(2026)), isFalse);
    });

    test('no price, no offer', () {
      expect(ProOffer.fromChannel(null), isNull);
      expect(ProOffer.fromChannel({'price': ''}), isNull);
    });
  });

  group('buying', () {
    late List<MethodCall> calls;
    late _Sink sink;
    late SharedPreferences prefs;

    Future<ProviderContainer> container(
      String buyAnswer, {
      ProOffer? shown,
      ProFrom? from,
    }) async {
      calls = [];
      sink = _Sink();
      SharedPreferences.setMockInitialValues({'analytics_consent': true});
      prefs = await SharedPreferences.getInstance();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            calls.add(call);
            return call.method == 'buy' ? buyAnswer : 'locked';
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding
            .instance
            .defaultBinaryMessenger
            .setMockMethodCallHandler(_channel, null),
      );
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          analyticsAvailableProvider.overrideWithValue(true),
          analyticsSinkProvider.overrideWithValue(sink),
          proOfferProvider.overrideWith((ref) async => shown),
        ],
      );
      addTearDown(c.dispose);
      // Keep the offer alive, as the Pro screen does.
      c.listen(proOfferProvider, (_, _) {});
      await c.read(proOfferProvider.future);
      c.read(proBillingProvider);
      await Future<void>.delayed(Duration.zero);
      if (from != null) c.read(proFromProvider.notifier).state = from;
      return c;
    }

    test('Play is asked for exactly the price that was shown', () async {
      final c = await container(
        'unlocked',
        shown: _sale(),
        from: ProFrom.remoteDoor,
      );
      await c.read(proBillingProvider.notifier).buy();
      final buy = calls.singleWhere((m) => m.method == 'buy');
      expect(buy.arguments, {'offerId': 'november', 'priceMicros': 4790000});
      expect(c.read(proBillingProvider), ProStatus.unlocked);
      expect(sink.sent, [
        'pro {step: unlock_tapped, from: remote_door, '
            'path: remote_door/unlock_tapped, sale: yes}',
        'pro {step: unlocked, from: remote_door, '
            'path: remote_door/unlocked, sale: yes}',
      ]);
      expect(prefs.getString(proOfferedKey), '1');
    });

    test('the sale ended between showing and tapping: nothing is bought, '
        'and the screen is told', () async {
      final c = await container(
        'changed',
        shown: _sale(),
        from: ProFrom.settings,
      );
      await c.read(proBillingProvider.notifier).buy();
      expect(c.read(proBillingProvider), ProStatus.locked);
      expect(c.read(proSaleEndedProvider), isTrue);
      expect(sink.sent, [
        'pro {step: unlock_tapped, from: settings, '
            'path: settings/unlock_tapped, sale: yes}',
      ]);
    });

    test('a sale that began in between only shows the new price', () async {
      final c = await container(
        'changed',
        shown: const ProOffer(price: '€7.99', priceMicros: 7990000),
      );
      await c.read(proBillingProvider.notifier).buy();
      expect(c.read(proSaleEndedProvider), isFalse);
      expect(sink.sent, ['pro {step: unlock_tapped, sale: no}']);
    });

    test('no price known: Play decides, as before', () async {
      final c = await container('locked');
      await c.read(proBillingProvider.notifier).buy();
      final buy = calls.singleWhere((m) => m.method == 'buy');
      expect(buy.arguments, {'offerId': null, 'priceMicros': null});
    });
  });

  group('the Pro screen', () {
    Future<void> screen(
      WidgetTester tester, {
      ProOffer? offer,
      bool saleEnded = false,
    }) async {
      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proStatusProvider.overrideWithValue(ProStatus.locked),
            proPurchaseProvider.overrideWithValue(() {}),
            proOfferProvider.overrideWith((ref) async => offer),
            proSaleEndedProvider.overrideWith((ref) => saleEnded),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a sale: what it is, until when, the old price struck out', (
      tester,
    ) async {
      await screen(tester, offer: _sale());
      expect(find.textContaining('Sale: 40% off until'), findsOneWidget);
      final full = tester.widget<Text>(find.byKey(const Key('pro-full-price')));
      expect(full.data, '€7.99');
      expect(full.style?.decoration, TextDecoration.lineThrough);
      expect(find.text('Get Pro · €4.79'), findsOneWidget);
    });

    testWidgets('no sale: no line, no struck price', (tester) async {
      await screen(
        tester,
        offer: const ProOffer(price: '€7.99', priceMicros: 7990000),
      );
      expect(find.byKey(const Key('pro-sale')), findsNothing);
      expect(find.byKey(const Key('pro-full-price')), findsNothing);
      expect(find.text('Get Pro · €7.99'), findsOneWidget);
    });

    testWidgets('a sale whose end has passed is not drawn', (tester) async {
      await screen(tester, offer: _sale(left: const Duration(minutes: -1)));
      expect(find.byKey(const Key('pro-sale')), findsNothing);
    });

    testWidgets('after a tap found the sale gone: said, with the price now', (
      tester,
    ) async {
      await screen(
        tester,
        offer: const ProOffer(price: '€7.99', priceMicros: 7990000),
        saleEnded: true,
      );
      expect(find.byKey(const Key('pro-sale-ended')), findsOneWidget);
      expect(find.text('Get Pro · €7.99'), findsOneWidget);
    });
  });

  testWidgets('"The sale has ended" does not follow into the next visit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    late BuildContext ctx;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proStatusProvider.overrideWithValue(ProStatus.locked),
          proPurchaseProvider.overrideWithValue(() {}),
          proOfferProvider.overrideWith(
            (ref) async => const ProOffer(price: '€7.99', priceMicros: 7990000),
          ),
          proSaleEndedProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (c) {
              ctx = c;
              return const Scaffold();
            },
          ),
        ),
      ),
    );
    openPro(ctx, from: ProFrom.settings);
    await tester.pumpAndSettle();
    expect(find.text('Get Pro · €7.99'), findsOneWidget);
    expect(find.byKey(const Key('pro-sale-ended')), findsNothing);
  });

  // 3.4.4: the Pro screen listed remote control first for everyone, also
  // where every home is one the relay can't serve.
  test('remote control is promised only where a home can use it', () async {
    Future<bool> line(List<Connection>? homes) async {
      final c = ProviderContainer(
        overrides: [
          connectionsStreamProvider.overrideWith(
            (ref) => homes == null ? const Stream.empty() : Stream.value(homes),
          ),
        ],
      );
      addTearDown(c.dispose);
      c.listen(proRemoteLineProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      return c.read(proRemoteLineProvider);
    }

    expect(await line(null), isTrue, reason: 'not known yet');
    expect(await line([]), isTrue, reason: 'no home yet');
    expect(await line([_home('demo', host: demoHost)]), isTrue);
    expect(await line([_home('a')]), isTrue);
    expect(
      await line([_home('ha', transport: ConnectionTransport.homeAssistant)]),
      isFalse,
    );
    expect(
      await line([
        _home('ha', transport: ConnectionTransport.homeAssistant),
        _home('z', transport: ConnectionTransport.z2mPage),
      ]),
      isFalse,
    );
    expect(
      await line([
        _home('ha', transport: ConnectionTransport.homeAssistant),
        _home('a'),
      ]),
      isTrue,
    );
  });
}
