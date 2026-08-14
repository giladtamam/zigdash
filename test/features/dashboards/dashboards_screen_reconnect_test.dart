import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/features/dashboards/screens/dashboards_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

void main() {
  testWidgets('failed reconnect shows feedback without an uncaught exception', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectionByIdProvider.overrideWith((ref, id) async => null),
          dashboardsForConnectionProvider.overrideWith(
            (ref, id) => Stream.value([]),
          ),
          connectionStatusProvider.overrideWith(
            (ref, id) => Stream.value(MqttStatus.reconnecting),
          ),
          mqttManagerProvider.overrideWith(
            (ref, id) =>
                Future.error(StateError('manager construction failed')),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardsScreen(connectionId: 'c1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Reconnect now'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Connection failed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
