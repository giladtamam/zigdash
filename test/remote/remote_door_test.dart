import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/remote/pair_phone_screen.dart';
import 'package:zigdash/remote/remote_door.dart';
import 'package:zigdash/remote/remote_home.dart';
import 'package:zigdash/remote/remote_pairing.dart';
import 'package:zigdash/remote/remote_setup.dart';

Connection _home({
  String id = 'c1',
  String name = 'Home',
  String host = '192.168.1.10',
  ConnectionTransport transport = ConnectionTransport.mqtt,
}) => Connection(
  transport: transport,
  id: id,
  name: name,
  host: host,
  port: 1883,
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

Future<void> _bar(
  WidgetTester tester, {
  Connection? home,
  bool sold = true,
  RemoteHome? login,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          appBar: AppBar(actions: const [RemoteDoor(connectionId: 'c1')]),
        ),
      ),
      GoRoute(
        path: '/settings/home/:id/remote',
        builder: (_, state) =>
            Text('remote page from=${state.uri.queryParameters['from']}'),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        remoteSoldProvider.overrideWithValue(sold),
        remoteHomeProvider.overrideWith((ref, _) async => login),
        connectionByIdProvider.overrideWith((ref, _) async => home ?? _home()),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _door = find.byKey(const Key('remote-door'));

// 3.4.4 (docs/design/remote-tab.md): remote control gets a door that is
// always on the dashboard, in place of a card shown once.
void main() {
  testWidgets('opens the Remote control page, saying it was the door', (
    tester,
  ) async {
    await _bar(tester);
    expect(find.byTooltip('Remote control'), findsOneWidget);
    await tester.tap(_door);
    await tester.pumpAndSettle();
    expect(find.text('remote page from=door'), findsOneWidget);
  });

  testWidgets('says so while remote control is on', (tester) async {
    await _bar(tester, login: _login);
    expect(find.byTooltip('Remote control is on'), findsOneWidget);
  });

  testWidgets('not where Pro is not sold', (tester) async {
    await _bar(tester, sold: false);
    expect(_door, findsNothing);
  });

  testWidgets('not on a home the relay cannot serve, nor the demo', (
    tester,
  ) async {
    await _bar(tester, home: _home(transport: ConnectionTransport.homeAssistant));
    expect(_door, findsNothing);
    await _bar(tester, home: _home(transport: ConnectionTransport.z2mPage));
    expect(_door, findsNothing);
    await _bar(tester, home: _home(host: demoHost));
    expect(_door, findsNothing);
  });

  test('remote control fits a real home on its own broker only', () {
    expect(remoteFits(_home()), isTrue);
    expect(remoteFits(_home(transport: ConnectionTransport.homeAssistant)), isFalse);
    expect(remoteFits(_home(transport: ConnectionTransport.z2mPage)), isFalse);
    expect(remoteFits(_home(host: demoHost)), isFalse);
  });

  // A remote login given to a home carried by Home Assistant would never
  // be used: the pair list no longer offers such a home.
  testWidgets('adding a phone by code lists only homes that fit', (
    tester,
  ) async {
    final code = Uri.parse(RemotePairing.link(_login)).queryParameters['c'];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectionsStreamProvider.overrideWith(
            (ref) => Stream.value([
              _home(id: 'broker', name: 'Flat'),
              _home(
                id: 'ha',
                name: 'Cabin',
                transport: ConnectionTransport.homeAssistant,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PairPhoneScreen(code: code),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pair-home-broker')), findsOneWidget);
    expect(find.byKey(const Key('pair-home-ha')), findsNothing);
  });

  testWidgets('only homes that do not fit: set one up first', (tester) async {
    final code = Uri.parse(RemotePairing.link(_login)).queryParameters['c'];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectionsStreamProvider.overrideWith(
            (ref) => Stream.value([
              _home(id: 'ha', transport: ConnectionTransport.homeAssistant),
            ]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PairPhoneScreen(code: code),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Set this home up on this phone first'), findsOneWidget);
  });
}
