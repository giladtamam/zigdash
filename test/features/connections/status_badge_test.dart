import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/widgets/status_badge.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/endpoint.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('connected via remote shows "Connected · Remote"', (tester) async {
    await tester.pumpWidget(_wrap(
      const StatusBadge(status: MqttStatus.connected, endpoint: MqttEndpoint.remote),
    ));
    expect(find.text('Connected · Remote'), findsOneWidget);
  });

  testWidgets('connected via local shows plain "Connected"', (tester) async {
    await tester.pumpWidget(_wrap(
      const StatusBadge(status: MqttStatus.connected, endpoint: MqttEndpoint.local),
    ));
    expect(find.text('Connected'), findsOneWidget);
  });

  testWidgets('disconnected ignores endpoint', (tester) async {
    await tester.pumpWidget(_wrap(
      const StatusBadge(status: MqttStatus.disconnected, endpoint: MqttEndpoint.remote),
    ));
    expect(find.text('Disconnected'), findsOneWidget);
  });
}
