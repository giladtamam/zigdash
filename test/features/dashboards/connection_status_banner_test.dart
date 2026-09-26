import 'dart:ui' show SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/dashboards/widgets/connection_status_banner.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';

Widget _wrap(
  MqttStatus status, {
  required VoidCallback onReconnect,
  Locale locale = const Locale('en'),
}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ConnectionStatusBanner(
          status: status,
          onReconnect: onReconnect,
        ),
      ),
    );

void main() {
  testWidgets('connected renders no banner', (tester) async {
    await tester.pumpWidget(
      _wrap(MqttStatus.connected, onReconnect: () {}),
    );

    expect(find.byType(Card), findsNothing);
  });

  testWidgets('explicitly disconnected renders no banner', (tester) async {
    await tester.pumpWidget(
      _wrap(MqttStatus.disconnected, onReconnect: () {}),
    );

    expect(find.byType(Card), findsNothing);
  });

  testWidgets('reconnecting shows stale-values copy and reconnects once', (
    tester,
  ) async {
    var reconnects = 0;
    await tester.pumpWidget(
      _wrap(MqttStatus.reconnecting, onReconnect: () => reconnects++),
    );

    expect(find.text('Reconnecting…'), findsOneWidget);
    expect(find.text('Showing last known values'), findsOneWidget);
    await tester.tap(find.text('Reconnect now'));
    expect(reconnects, 1);
  });

  testWidgets('connecting shows progress without an action', (tester) async {
    await tester.pumpWidget(
      _wrap(MqttStatus.connecting, onReconnect: () {}),
    );

    expect(find.text('Connecting…'), findsOneWidget);
    expect(find.text('Reconnect now'), findsNothing);
  });

  testWidgets('error explains automatic retry and offers immediate action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(MqttStatus.error, onReconnect: () {}),
    );

    expect(find.text('Connection failed'), findsOneWidget);
    expect(find.text('Automatic retry will continue'), findsOneWidget);
    expect(find.text('Reconnect now'), findsOneWidget);
  });

  testWidgets('visible banner is one live-region semantics node', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(MqttStatus.reconnecting, onReconnect: () {}),
    );

    final liveRegions = find.bySemanticsIdentifier('connection-status-banner');
    expect(liveRegions, findsOneWidget);
    expect(
      tester.getSemantics(liveRegions).flagsCollection.isLiveRegion,
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('layout remains usable in RTL', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MqttStatus.reconnecting,
        onReconnect: () {},
        locale: const Locale('he'),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ConnectionStatusBanner), findsOneWidget);
  });
}
