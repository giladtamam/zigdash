import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/features/devices/device_health.dart';
import 'package:zigdash/features/devices/device_registry.dart';
import 'package:zigdash/features/devices/devices_providers.dart';
import 'package:zigdash/features/devices/screens/device_page.dart';
import 'package:zigdash/features/devices/z2m_bridge.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/l10n/app_localizations.dart';

const _door = Z2mDevice(
  friendlyName: 'Back door',
  type: 'EndDevice',
  ieeeAddress: '0x03',
  powerSource: 'Battery',
  rawExposes: [
    {'type': 'binary', 'name': 'contact', 'property': 'contact', 'access': 1},
    {'type': 'numeric', 'name': 'device_temperature', 'property': 'device_temperature', 'access': 1, 'unit': '°C'},
    {'type': 'numeric', 'name': 'battery', 'property': 'battery', 'access': 1, 'unit': '%', 'category': 'diagnostic'},
  ],
);

Widget _app({List<Z2mDevice> devices = const [_door], String ieee = '0x03'}) {
  final db = AppDatabase.test(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        ref.onDispose(db.close);
        return db;
      }),
      connectionsStreamProvider.overrideWith((ref) => Stream.value(const [])),
      dashboardsForConnectionProvider.overrideWith((ref, _) => Stream.value(const [])),
      bridgeDevicesStreamProvider.overrideWith((ref, _) => Stream.value(devices)),
      deviceHealthProvider.overrideWith((ref, _) => Stream.value(deviceHealthFrom(
            devices,
            states: {
              'Back door': (
                payload: '{"contact":true,"device_temperature":22.1,"battery":8,"linkquality":112}',
                at: DateTime(2026, 9, 27)
              ),
            },
          ))),
      availabilityConfigProvider
          .overrideWith((ref, _) => Stream.value(AvailabilityConfig.unknown)),
      deviceTilesProvider.overrideWith((ref, _) => Stream.value(const [])),
      unassignedDevicesProvider.overrideWith((ref, _) => AsyncValue.data(devices)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DevicePage(connectionId: 'c1', ieee: ieee),
    ),
  );
}

void main() {
  testWidgets('card titles are headings; low battery and readings shown',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.pump();

    for (final title in ['Readings', 'Health', 'On dashboards']) {
      final node = tester.getSemantics(find.text(title));
      expect(node.getSemanticsData().flagsCollection.isHeader, isTrue,
          reason: '$title is announced as a heading');
    }
    expect(find.text('Device temperature'), findsOneWidget);
    expect(find.textContaining('Battery low'), findsWidgets);
    expect(find.text('Off in Zigbee2MQTT'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget, reason: 'a new device');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a device no longer in Zigbee2MQTT says so', (tester) async {
    await tester.pumpWidget(_app(ieee: '0xgone'));
    await tester.pump();
    await tester.pump();
    expect(find.text('This device is no longer in Zigbee2MQTT.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
