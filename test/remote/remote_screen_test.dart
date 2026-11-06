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
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/endpoint.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';
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
}) async {
  tester.view.physicalSize = const Size(1080, 3200);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'analytics_consent': true, ...prefs});
  final p = await SharedPreferences.getInstance();
  final sink = _Sink();
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
        proStatusProvider.overrideWithValue(pro),
        proPurchaseProvider.overrideWithValue(() {}),
        proPriceProvider.overrideWith((ref) async => price),
        proOfferProvider.overrideWith((ref) async => offer),
        remoteSoldProvider.overrideWithValue(sold),
        atHomeProvider.overrideWith((ref, _) => connected && atHome),
        remoteHomeProvider.overrideWith((ref, _) async => login),
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
    }) => remoteStateOf(
      fits: fits,
      sold: sold,
      on: on,
      pro: pro,
      connected: connected,
      atHome: atHome,
      engine: engine,
    );

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
}
