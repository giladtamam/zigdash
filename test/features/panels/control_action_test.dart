import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/panels/widgets/control_action.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

void main() {
  testWidgets('disconnected control action shows snackbar and does not publish', (tester) async {
    final mgr = MqttManager(
      config: const BrokerConfig(id: 'c1', host: 'x', port: 1883, protocol: MqttProtocol.tcp),
      password: '',
    ); // never connected -> isConnected == false
    addTearDown(mgr.dispose);
    var published = false;

    await tester.pumpWidget(ProviderScope(
      overrides: [mqttManagerProvider('c1').overrideWith((ref) async => mgr)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(builder: (context, ref, _) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => runControlAction(context, ref, 'c1', (_) => published = true),
                child: const Text('tap'),
              ),
            ),
          );
        }),
      ),
    ));
    await tester.tap(find.text('tap'));
    await tester.pumpAndSettle();

    expect(published, isFalse);
    expect(find.text('Not connected — change not sent'), findsOneWidget);
  });
}
