import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/endpoint.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';
import 'package:zigdash/remote/founder.dart';
import 'package:zigdash/remote/founder_ui.dart';
import 'package:zigdash/remote/remote_home.dart';
import 'package:zigdash/remote/remote_phones.dart';
import 'package:zigdash/remote/remote_screen.dart';
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

Connection _home({
  ConnectionTransport transport = ConnectionTransport.mqtt,
  String? remoteHost,
}) => Connection(
  transport: transport,
  id: 'c1',
  name: 'Home',
  host: '192.168.1.10',
  port: 1883,
  remoteHost: remoteHost,
  protocol: MqttProtocol.tcp,
  keepAliveSeconds: 60,
  autoConnect: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final _now = DateTime(2026, 11, 16, 12);
final _end = DateTime(2027, 2, 14, 12);

FounderStatus _pass({DateTime? ends, bool ended = false, bool deleted = false, String? kind = 'founder'}) =>
    FounderStatus(kind: kind, expiresAt: ends ?? _end, ended: ended, deleted: deleted, fetchedAt: _now);

/// The relay, as the page uses it: answers set by the test, calls recorded.
class _Relay extends RemoteSetup {
  _Relay() : super(RemoteHomeStore(const FlutterSecureStorage()), (_) => throw UnimplementedError());

  final calls = <String>[];
  RemoteHome? login;
  FounderStatus? founder;
  FounderRedeemResult redeemAnswer = FounderRedeemResult.ready;
  FounderUpgradeResult upgradeAnswer = FounderUpgradeResult.done;

  @override
  Future<(FounderRedeemResult, DateTime?)> redeem(String connectionId, String code) async {
    calls.add('redeem $code');
    if (redeemAnswer != FounderRedeemResult.ready) return (redeemAnswer, null);
    login = _login;
    founder = _pass();
    return (redeemAnswer, _end);
  }

  @override
  Future<FounderUpgradeResult> upgrade(String connectionId) async {
    calls.add('upgrade');
    if (upgradeAnswer == FounderUpgradeResult.done) founder = FounderStatus(fetchedAt: _now);
    return upgradeAnswer;
  }

  @override
  Future<void> turnOff(String connectionId, {bool everywhere = true}) async {
    calls.add('turnOff everywhere=$everywhere');
    login = null;
    founder = null;
  }
}

/// This phone's Pro, changed by a test as a purchase would.
final _pro = StateProvider<ProStatus>((ref) => ProStatus.locked);

final _login = RemoteHome(
  homeId: 'a1b2',
  url: 'wss://relay.example/mqtt',
  username: 'phone-a1b2-ff',
  password: 'x',
  key: Uint8List(32),
);

Future<_Sink> _page(
  WidgetTester tester, {
  Connection? home,
  ProStatus pro = ProStatus.locked,
  bool sold = true,
  bool connected = true,
  bool atHome = true,
  MqttEndpoint endpoint = MqttEndpoint.local,
  HubEnginePhase phase = HubEnginePhase.running,
  RemoteHome? login,
  String? price = '€7.99',
  ProOffer? offer,
  Map<String, Object> prefs = const {},
  RemoteFrom from = RemoteFrom.door,
  FounderStatus? founder,
  bool founderOffered = false,
  _Relay? relay,
  EngineReport? report,
  Map<String, String> secure = const {},
}) async {
  tester.view.physicalSize = const Size(1080, 6000);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'analytics_consent': true, ...prefs});
  final p = await SharedPreferences.getInstance();
  FlutterSecureStorage.setMockInitialValues({...secure});
  final sink = _Sink();
  relay?.login ??= login;
  relay?.founder ??= founder;
  final router = GoRouter(
    initialLocation: '/remote',
    routes: [
      GoRoute(
        path: '/remote',
        builder: (_, _) => RemoteScreen(connectionId: 'c1', from: from),
      ),
      GoRoute(
        path: '/connections/:id/automations',
        builder: (_, _) => const Text('automations tab'),
      ),
      GoRoute(
        path: '/connections/:id/edit',
        builder: (_, _) => const Text('connection form'),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        analyticsAvailableProvider.overrideWithValue(true),
        analyticsSinkProvider.overrideWithValue(sink),
        _pro.overrideWith((ref) => pro),
        proStatusProvider.overrideWith((ref) => ref.watch(_pro)),
        proPurchaseProvider.overrideWithValue(() {}),
        proPriceProvider.overrideWith((ref) async => price),
        proOfferProvider.overrideWith((ref) async => offer),
        remoteSoldProvider.overrideWithValue(sold),
        atHomeProvider.overrideWith((ref, _) => connected && atHome),
        remoteHomeProvider.overrideWith((ref, _) async => relay == null ? login : relay.login),
        founderStatusProvider.overrideWith((ref, _) async => relay == null ? founder : relay.founder),
        founderRefreshProvider.overrideWithValue((_) async {}),
        founderCodeOfferedProvider.overrideWithValue(founderOffered),
        founderNowProvider.overrideWithValue(() => _now),
        if (relay != null) ...[
          remoteSetupProvider.overrideWithValue(relay),
          founderUpgraderProvider.overrideWith((ref) => FounderUpgrader(relay, p, delay: (_) => Duration.zero)),
        ],
        remotePhonesProvider.overrideWith((ref, _) async => const []),
        connectionByIdProvider.overrideWith(
          (ref, _) async => home ?? _home(),
        ),
        connectionStatusProvider.overrideWith(
          (ref, _) => Stream.value(
            connected ? MqttStatus.connected : MqttStatus.disconnected,
          ),
        ),
        connectionEndpointProvider.overrideWith(
          (ref, _) => Stream.value(connected ? endpoint : null),
        ),
        engineViewProvider.overrideWith(
          (ref, _) => Stream.value(
            EngineView(
              phase: phase,
              hub: const HubInfo(version: '2.14.0', externalJsAllowed: true),
              report: report,
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return sink;
}

void main() {
  group('what the page shows', () {
    RemoteState of({
      bool fits = true,
      bool sold = true,
      bool on = false,
      bool pro = true,
      bool connected = true,
      bool atHome = true,
      RemoteEngineStep engine = RemoteEngineStep.installed,
      bool founder = false,
      bool passEnded = false,
      bool deleted = false,
    }) => remoteStateOf(
      fits: fits,
      sold: sold,
      on: on,
      pro: pro,
      connected: connected,
      atHome: atHome,
      engine: engine,
      founder: founder,
      passEnded: passEnded,
      deleted: deleted,
    );

    test("a founder's pass counts as Pro while it runs; ended and deleted Homes say so", () {
      expect(of(pro: false, founder: true), RemoteState.ready);
      expect(of(pro: false, founder: true, atHome: false), RemoteState.away);
      expect(of(on: true, pro: false, founder: true), RemoteState.on);
      expect(of(on: true, pro: false, passEnded: true), RemoteState.passEnded);
      // Pro bought elsewhere doesn't move the Home by itself.
      expect(of(on: true, passEnded: true), RemoteState.passEnded);
      expect(of(on: true, pro: false, passEnded: true, deleted: true), RemoteState.deleted);
      // Neither without a login here.
      expect(of(pro: false, passEnded: true, deleted: true), RemoteState.noPro);
      expect(of(fits: false, on: true, deleted: true), RemoteState.unfit);
      // Where Play billing isn't available, a founder's Home stays on.
      expect(of(on: true, sold: false, pro: false, founder: true), RemoteState.on);
    });

    test('one state for every case, decided before any tap', () {
      expect(of(), RemoteState.ready);
      expect(of(atHome: false), RemoteState.away);
      expect(of(engine: RemoteEngineStep.install), RemoteState.noEngine);
      expect(of(engine: RemoteEngineStep.tooOld), RemoteState.noEngine);
      expect(of(engine: RemoteEngineStep.checking), RemoteState.noEngine);
      expect(of(connected: false), RemoteState.proOffline);
      expect(of(pro: false), RemoteState.noPro);
      expect(of(pro: false, connected: false), RemoteState.noProOffline);
      expect(of(sold: false), RemoteState.notSold);
      expect(of(on: true, sold: false), RemoteState.on);
      // A home the relay can't serve is never offered remote control,
      // whatever else is true.
      expect(of(fits: false, on: true), RemoteState.unfit);
    });

    test('offline, the Engine step claims only what the phone kept', () {
      RemoteEngineStep step(bool connected, HubEnginePhase? phase, bool seen) =>
          remoteEngineStep(
            connected: connected,
            phase: phase,
            seenInstalled: seen,
          );
      expect(step(true, HubEnginePhase.running, false), RemoteEngineStep.installed);
      expect(step(true, HubEnginePhase.paused, false), RemoteEngineStep.installed);
      expect(step(true, HubEnginePhase.notInstalled, true), RemoteEngineStep.install);
      expect(step(true, HubEnginePhase.needsConsent, false), RemoteEngineStep.install);
      expect(step(true, HubEnginePhase.tooOld, false), RemoteEngineStep.tooOld);
      expect(step(true, HubEnginePhase.checking, true), RemoteEngineStep.checking);
      expect(step(true, null, false), RemoteEngineStep.checking);
      expect(step(false, HubEnginePhase.notInstalled, true), RemoteEngineStep.seenBefore);
      // "No" is also "too old" and "never looked": none of them is said.
      expect(step(false, HubEnginePhase.tooOld, false), RemoteEngineStep.unknown);
    });
  });

  testWidgets('no Pro: how the phone reaches home, both ways, the steps, '
      'then the price', (tester) async {
    final sink = await _page(tester);
    expect(
      find.text('At home, straight to your broker at 192.168.1.10:1883'),
      findsOneWidget,
    );
    expect(find.text('Zigbee2MQTT 2.14.0'), findsOneWidget);
    expect(find.text('Your own address'), findsOneWidget);
    expect(find.textContaining('Tailscale, a VPN or a forwarded port'), findsOneWidget);
    expect(find.text('ZigDash Engine on your hub (free)'), findsOneWidget);
    expect(find.text('One payment, no monthly fee'), findsOneWidget);
    // At home already: step 3 has nothing to add.
    expect(find.text("Turn it on when you're home"), findsNothing);
    expect(find.byKey(const Key('remote-on')), findsNothing);
    expect(find.text('See Pro · €7.99'), findsOneWidget);
    expect(sink.sent, ['remote {step: opened, pro: no, open: door/no_pro}']);

    await tester.tap(find.byKey(const Key('remote-see-pro')));
    await tester.pumpAndSettle();
    expect(find.text('ZigDash Pro'), findsWidgets);
    expect(sink.sent.sublist(1), [
      'remote {step: see_pro, pro: no, went: door}',
      'pro {step: screen_shown, from: remote_door, path: remote_door/screen_shown}',
    ]);
  });

  testWidgets('"See Pro" is counted once per app start', (tester) async {
    final sink = await _page(tester, from: RemoteFrom.settings);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byKey(const Key('remote-see-pro')));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(
      sink.sent.where((e) => e.startsWith('remote')).toList(),
      [
        'remote {step: opened, pro: no, open: settings/no_pro}',
        'remote {step: see_pro, pro: no, went: settings}',
      ],
    );
    expect(
      sink.sent.where((e) => e.contains('remote_settings/screen_shown')),
      hasLength(2),
    );
  });

  testWidgets('away and cut off, no Pro: still a way on, and nothing '
      'claimed about the Engine', (tester) async {
    final sink = await _page(tester, connected: false);
    expect(find.text('Not connected to your home right now'), findsOneWidget);
    expect(find.text("Checked when you're home"), findsOneWidget);
    expect(find.textContaining('Install it under'), findsNothing);
    expect(find.text('See Pro · €7.99'), findsOneWidget);
    expect(find.text("Turn it on when you're home"), findsOneWidget);
    expect(sink.sent, [
      'remote {step: opened, pro: no, open: door/no_pro_offline}',
    ]);
  });

  testWidgets('cut off, and the Engine was there last time', (tester) async {
    await _page(
      tester,
      connected: false,
      prefs: {'engine.installed.c1': true},
    );
    expect(
      find.text('Installed when this phone last saw your hub'),
      findsOneWidget,
    );
  });

  testWidgets('a sale shows in step 2, in Play\'s own numbers', (tester) async {
    await _page(
      tester,
      price: '€4.79',
      offer: ProOffer(
        price: '€4.79',
        priceMicros: 4790000,
        fullPriceMicros: 7990000,
        currency: 'EUR',
        percent: 40,
        ends: DateTime.now().add(const Duration(days: 3)),
        offerId: 'november',
      ),
    );
    expect(find.textContaining('Sale: 40% off until'), findsOneWidget);
    expect(find.text('See Pro · €4.79'), findsOneWidget);
  });

  testWidgets('Pro, no Engine: step 1 leads to Automations', (tester) async {
    final sink = await _page(
      tester,
      pro: ProStatus.unlocked,
      phase: HubEnginePhase.notInstalled,
    );
    expect(find.text('Not installed yet. Install it under Automations.'), findsOneWidget);
    expect(find.byKey(const Key('remote-on')), findsNothing);
    expect(sink.sent, ['remote {step: opened, pro: yes, open: door/no_engine}']);
    await tester.tap(find.byKey(const Key('remote-engine')));
    await tester.pumpAndSettle();
    expect(find.text('automations tab'), findsOneWidget);
  });

  testWidgets('Pro, too old a Zigbee2MQTT: said, with nothing to install', (
    tester,
  ) async {
    await _page(tester, pro: ProStatus.unlocked, phase: HubEnginePhase.tooOld);
    expect(find.textContaining('too old for it'), findsOneWidget);
    expect(find.byKey(const Key('remote-engine')), findsNothing);
  });

  testWidgets('Pro, through the own remote address: "at home" is said '
      'before any tap', (tester) async {
    final sink = await _page(
      tester,
      pro: ProStatus.unlocked,
      atHome: false,
      endpoint: MqttEndpoint.remote,
      home: _home(remoteHost: 'home.example.net'),
    );
    expect(
      find.text('Away, through your own address home.example.net'),
      findsOneWidget,
    );
    expect(find.text('Free. Set to home.example.net.'), findsOneWidget);
    expect(find.byKey(const Key('remote-at-home-first')), findsOneWidget);
    expect(find.byKey(const Key('remote-on')), findsNothing);
    expect(sink.sent, ['remote {step: opened, pro: yes, open: door/away}']);
  });

  testWidgets('Pro, the hub has not answered yet: not counted as "no '
      'Engine"', (tester) async {
    final sink = await _page(
      tester,
      pro: ProStatus.unlocked,
      phase: HubEnginePhase.checking,
    );
    expect(find.text('Checking your hub…'), findsOneWidget);
    expect(sink.sent, isEmpty);
  });

  testWidgets('Pro, Engine, at home: turn it on', (tester) async {
    final sink = await _page(tester, pro: ProStatus.unlocked);
    expect(find.byKey(const Key('remote-on')), findsOneWidget);
    expect(find.byKey(const Key('remote-restore')), findsOneWidget);
    expect(find.byKey(const Key('remote-see-pro')), findsNothing);
    expect(sink.sent, ['remote {step: opened, pro: yes, open: door/ready}']);
  });

  testWidgets('on: the phones and the way off, no steps', (tester) async {
    final sink = await _page(tester, pro: ProStatus.unlocked, login: _login);
    expect(find.text('Remote control is on'), findsOneWidget);
    expect(find.byKey(const Key('remote-off')), findsOneWidget);
    expect(find.byKey(const Key('remote-steps')), findsNothing);
    expect(find.text('Your own address'), findsNothing);
    expect(sink.sent, ['remote {step: opened, pro: yes, open: door/on}']);
  });

  testWidgets('where Pro is not sold: said, with no price', (tester) async {
    await _page(tester, sold: false, pro: ProStatus.unlocked);
    expect(find.byKey(const Key('remote-play-only')), findsOneWidget);
    expect(find.byKey(const Key('remote-steps')), findsNothing);
    expect(find.byKey(const Key('remote-on')), findsNothing);
    // The free way is still shown.
    expect(find.text('Your own address'), findsOneWidget);
  });

  // 3.4.4: a home carried by Home Assistant could be sold remote control
  // and told it was on, though the relay is never used for it.
  testWidgets('a Home Assistant home is told plainly, and offered nothing', (
    tester,
  ) async {
    final sink = await _page(
      tester,
      pro: ProStatus.unlocked,
      home: _home(transport: ConnectionTransport.homeAssistant),
    );
    expect(find.textContaining('reached through Home Assistant'), findsOneWidget);
    expect(find.byKey(const Key('remote-on')), findsNothing);
    expect(find.byKey(const Key('remote-see-pro')), findsNothing);
    expect(find.byKey(const Key('remote-off')), findsNothing);
    expect(sink.sent, ['remote {step: opened, pro: yes, open: door/unfit}']);
  });

  testWidgets('a Zigbee2MQTT-page home gets its own words', (tester) async {
    await _page(tester, home: _home(transport: ConnectionTransport.z2mPage));
    expect(find.textContaining("Zigbee2MQTT's own page"), findsOneWidget);
    expect(find.textContaining('Home Assistant'), findsNothing);
  });

  testWidgets('a home that got in before the fix keeps the way out', (
    tester,
  ) async {
    await _page(
      tester,
      home: _home(transport: ConnectionTransport.homeAssistant),
      login: _login,
    );
    expect(find.byKey(const Key('remote-unfit')), findsOneWidget);
    expect(find.byKey(const Key('remote-off')), findsOneWidget);
  });

  group("founder's pass", () {
    Future<void> openCode(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('founder-code-ask')));
      await tester.pumpAndSettle();
    }

    FilledButton use(WidgetTester tester) => tester.widget<FilledButton>(find.byKey(const Key('founder-code-use')));

    testWidgets('where Play billing is unavailable the code field is still offered, and at home it turns remote on',
        (tester) async {
      final relay = _Relay();
      final sink = await _page(tester, sold: false, pro: ProStatus.unavailable, founderOffered: true, relay: relay);
      expect(find.byKey(const Key('remote-play-only')), findsNothing);
      expect(find.text("Have a founder's code?"), findsOneWidget);
      await openCode(tester);
      expect(use(tester).onPressed, isNull, reason: 'nothing typed yet');
      expect(find.byKey(const Key('founder-code-at-home')), findsNothing);
      await tester.enterText(find.byKey(const Key('founder-code')), 'zd-7k3m q9ab-x2');
      await tester.pump();
      await tester.tap(find.byKey(const Key('founder-code-use')));
      await tester.pumpAndSettle();
      expect(relay.calls, ['redeem zd-7k3m q9ab-x2']);
      expect(find.text('Remote control is on'), findsOneWidget);
      expect(find.text("Your founder's pass is on: remote control and Chat for this Home until Feb 14, 2027."),
          findsOneWidget);
      // No new analytics: the page counted what it showed first.
      expect(sink.sent, ['remote {step: opened, pro: no, open: door/not_sold}']);
    });

    testWidgets('without Pro: See Pro, and the code below it', (tester) async {
      await _page(tester, founderOffered: true);
      expect(find.byKey(const Key('remote-see-pro')), findsOneWidget);
      expect(find.byKey(const Key('founder-code-ask')), findsOneWidget);
    });

    testWidgets('outside the Play build, no code field', (tester) async {
      await _page(tester);
      expect(find.byKey(const Key('founder-code-ask')), findsNothing);
    });

    testWidgets('with Pro, no code field', (tester) async {
      await _page(tester, founderOffered: true, pro: ProStatus.unlocked);
      expect(find.byKey(const Key('founder-code-ask')), findsNothing);
    });

    testWidgets('away, the code waits for home', (tester) async {
      await _page(tester, founderOffered: true, atHome: false, endpoint: MqttEndpoint.remote, relay: _Relay());
      await openCode(tester);
      await tester.enterText(find.byKey(const Key('founder-code')), 'ZD-7K3M-Q9AB-X2');
      await tester.pump();
      expect(find.byKey(const Key('founder-code-at-home')), findsOneWidget);
      expect(use(tester).onPressed, isNull);
    });

    testWidgets('without the Engine, the code waits for it', (tester) async {
      await _page(tester, founderOffered: true, phase: HubEnginePhase.notInstalled, relay: _Relay());
      await openCode(tester);
      await tester.enterText(find.byKey(const Key('founder-code')), 'ZD-7K3M-Q9AB-X2');
      await tester.pump();
      expect(find.byKey(const Key('founder-code-at-home')), findsOneWidget);
      expect(use(tester).onPressed, isNull);
    });

    for (final (answer, text) in [
      (FounderRedeemResult.wrongCode, "That isn't a founder's code. Check it and try again."),
      (FounderRedeemResult.used, 'That code was already used. Each code works once.'),
      (FounderRedeemResult.deadline, 'The date to enter that code has passed. Ask for more time from Get help.'),
      (FounderRedeemResult.revoked, 'That code was withdrawn.'),
      (FounderRedeemResult.tooMany, 'Too many tries. Try again in an hour.'),
      (FounderRedeemResult.unreachable, "ZigDash's relay didn't answer. Try again later."),
    ]) {
      testWidgets('${answer.name}: said, and the code stays to try again', (tester) async {
        final relay = _Relay()..redeemAnswer = answer;
        await _page(tester, founderOffered: true, relay: relay);
        await openCode(tester);
        await tester.enterText(find.byKey(const Key('founder-code')), 'ZD-7K3M-Q9AB-X2');
        await tester.pump();
        await tester.tap(find.byKey(const Key('founder-code-use')));
        await tester.pumpAndSettle();
        expect(find.text(text), findsOneWidget);
        expect(find.text('Remote control is on'), findsNothing);
        expect(tester.widget<TextField>(find.byKey(const Key('founder-code'))).controller!.text, 'ZD-7K3M-Q9AB-X2');
        await tester.tap(find.byKey(const Key('founder-code-use')));
        await tester.pumpAndSettle();
        expect(relay.calls, hasLength(2));
      });
    }

    testWidgets('ended: no Reconnect hub, no Phones; the date and Get Pro', (tester) async {
      final sink = await _page(
        tester,
        login: _login,
        founder: _pass(ended: true),
        report: const EngineReport(
            version: '3.7.1', runningOn: 'hub', rulesLoaded: 0, rulesUnknown: [], stoppedSelf: false, at: null,
            remoteConnected: false, remoteError: 'refused'),
      );
      expect(
        find.text("Your founder's pass ended on Feb 14, 2027. ZigDash Pro brings remote control and Chat back, "
            'with nothing to set up again.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('founder-get-pro')), findsOneWidget);
      expect(find.byKey(const Key('remote-reconnect-hub')), findsNothing);
      expect(find.byKey(const Key('remote-add-phone')), findsNothing);
      expect(find.text('Remote control is on'), findsNothing);
      expect(find.byKey(const Key('remote-off')), findsOneWidget);
      expect(sink.sent, ['remote {step: opened, pro: no, open: door/on}']);
    });

    testWidgets('an end date that has passed reads as ended before the relay says so', (tester) async {
      await _page(tester, login: _login, founder: _pass(ends: _now.subtract(const Duration(hours: 1))));
      expect(find.byKey(const Key('remote-pass-ended')), findsOneWidget);
    });

    testWidgets('Get Pro from the line, bought: the Home moves to the purchase', (tester) async {
      final relay = _Relay();
      await _page(tester, login: _login, founder: _pass(ended: true), relay: relay);
      await tester.tap(find.byKey(const Key('founder-get-pro')));
      await tester.pumpAndSettle();
      expect(find.text('ZigDash Pro'), findsWidgets);
      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).last));
      container.read(_pro.notifier).state = ProStatus.unlocked;
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(relay.calls, ['upgrade']);
      expect(find.text('This Home now runs on your Pro purchase.'), findsOneWidget);
      expect(find.text('Remote control is on'), findsOneWidget);
      expect(find.byKey(const Key('founder-pro-line')), findsNothing);
    });

    testWidgets('Get Pro, then back without buying: nothing moves, and nothing is remembered', (tester) async {
      final relay = _Relay();
      await _page(tester, login: _login, founder: _pass(ended: true), relay: relay);
      await tester.tap(find.byKey(const Key('founder-get-pro')));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(relay.calls, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(founderUpgradeKey('c1')), isNull);
    });

    testWidgets('Pro bought elsewhere: asked first, and nothing happens without a yes', (tester) async {
      final relay = _Relay();
      await _page(tester, pro: ProStatus.unlocked, login: _login, founder: _pass(), relay: relay);
      expect(find.text("Your founder's pass is on: remote control and Chat for this Home until Feb 14, 2027."),
          findsOneWidget);
      await tester.tap(find.byKey(const Key('founder-use-pro')));
      await tester.pumpAndSettle();
      expect(find.text('Use your Pro purchase for this Home?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(relay.calls, isEmpty);

      relay.upgradeAnswer = FounderUpgradeResult.taken;
      await tester.tap(find.byKey(const Key('founder-use-pro')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('founder-use-pro-ok')));
      await tester.pumpAndSettle();
      expect(relay.calls, ['upgrade']);
      expect(find.text('That purchase already belongs to another Home.'), findsOneWidget);
    });

    testWidgets('the last 7 days: the date and Get Pro', (tester) async {
      await _page(tester, login: _login, founder: _pass(ends: _now.add(const Duration(days: 3))), relay: _Relay());
      expect(find.textContaining("Your founder's pass ends on Nov 19, 2026."), findsOneWidget);
      expect(find.byKey(const Key('founder-get-pro')), findsOneWidget);
      // Running, so the hub and the phones are still there.
      expect(find.byKey(const Key('remote-add-phone')), findsOneWidget);
    });

    testWidgets('earlier in the pass, without Pro: no line', (tester) async {
      await _page(tester, login: _login, founder: _pass());
      expect(find.byKey(const Key('founder-pro-line')), findsNothing);
      expect(find.text('Remote control is on'), findsOneWidget);
    });

    testWidgets('deleted: said, and Set up with Pro forgets the dead login first', (tester) async {
      final relay = _Relay();
      final sink = await _page(tester, login: _login, founder: _pass(ended: true, deleted: true), relay: relay);
      expect(find.text("This Home's founder's pass ended and its remote control was removed."), findsOneWidget);
      expect(find.byKey(const Key('remote-add-phone')), findsNothing);
      await tester.tap(find.byKey(const Key('remote-set-up-with-pro')));
      await tester.pumpAndSettle();
      expect(relay.calls, ['turnOff everywhere=false']);
      // Without Pro, the Pro screen; behind it the usual steps.
      expect(sink.sent.last, 'pro {step: screen_shown, from: remote_door, path: remote_door/screen_shown}');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('remote-steps')), findsOneWidget);
    });

    testWidgets('a Pro Home the relay deleted gets plain words', (tester) async {
      await _page(tester, pro: ProStatus.unlocked, login: _login, founder: _pass(kind: null, deleted: true));
      expect(find.text("This Home's remote control was removed from the relay."), findsOneWidget);
    });

    testWidgets("the Engine says the relay refused the hub's login", (tester) async {
      await _page(
        tester,
        pro: ProStatus.unlocked,
        login: _login,
        report: const EngineReport(
            version: '3.7.1', runningOn: 'hub', rulesLoaded: 0, rulesUnknown: [], stoppedSelf: false, at: null,
            remoteConnected: false, remoteError: 'refused'),
      );
      expect(find.text("The relay refused this hub's login"), findsOneWidget);
      expect(find.byKey(const Key('remote-reconnect-hub')), findsOneWidget);
    });

    testWidgets('a purchase from the line that never reached the relay moves the Home on the next visit',
        (tester) async {
      final relay = _Relay();
      await _page(
        tester,
        pro: ProStatus.unlocked,
        login: _login,
        founder: _pass(ended: true),
        relay: relay,
        prefs: {founderUpgradeKey('c1'): true},
        secure: {'remote_founder::c1': jsonEncode(_pass(ended: true).toJson())},
      );
      expect(relay.calls, ['upgrade']);
      expect(find.text('This Home now runs on your Pro purchase.'), findsOneWidget);
    });

    testWidgets('without that earlier yes, opening the page moves nothing', (tester) async {
      final relay = _Relay();
      await _page(
        tester,
        pro: ProStatus.unlocked,
        login: _login,
        founder: _pass(ended: true),
        relay: relay,
        secure: {'remote_founder::c1': jsonEncode(_pass(ended: true).toJson())},
      );
      expect(relay.calls, isEmpty);
      expect(find.byKey(const Key('founder-use-pro')), findsOneWidget);
    });
  });
}
