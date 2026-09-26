import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/dashboards/widgets/connection_status_banner.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';

Widget _wrap(
  MqttStatus status, {
  VoidCallback? onReconnect,
  VoidCallback? onSettings,
  Locale locale = const Locale('en'),
}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ConnectionStatusBanner(
          status: status,
          onReconnect: onReconnect ?? () {},
          onSettings: onSettings,
          lastError: 'Connection refused',
        ),
      ),
    );

void main() {
  for (final status in [
    MqttStatus.connected,
    MqttStatus.connecting,
    MqttStatus.disconnected,
  ]) {
    testWidgets('${status.name}: no line', (tester) async {
      await tester.pumpWidget(_wrap(status));
      expect(find.text("Can't reach your broker"), findsNothing);
    });
  }

  for (final status in [MqttStatus.reconnecting, MqttStatus.error]) {
    testWidgets('${status.name}: the slim line with Why?', (tester) async {
      await tester.pumpWidget(_wrap(status));
      expect(find.text("Can't reach your broker"), findsOneWidget);
      expect(find.text('Why?'), findsOneWidget);
    });
  }

  testWidgets('Why? explains and offers Reconnect now and settings',
      (tester) async {
    var reconnects = 0, settings = 0;
    await tester.pumpWidget(_wrap(MqttStatus.error,
        onReconnect: () => reconnects++, onSettings: () => settings++));

    await tester.tap(find.text('Why?'));
    await tester.pumpAndSettle();
    expect(find.text("Your broker isn't answering"), findsOneWidget);
    expect(find.text('Connection refused'), findsOneWidget);
    await tester.tap(find.text('Reconnect now'));
    await tester.pumpAndSettle();
    expect(reconnects, 1);

    await tester.tap(find.text('Why?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connection settings'));
    await tester.pumpAndSettle();
    expect(settings, 1);
  });

  testWidgets('the line is one live-region semantics node', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(MqttStatus.reconnecting));
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
        _wrap(MqttStatus.reconnecting, locale: const Locale('he')));
    expect(tester.takeException(), isNull);
    expect(find.text('למה?'), findsOneWidget);
  });
}
