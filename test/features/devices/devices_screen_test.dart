import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/devices/device_health.dart';
import 'package:zigdash/features/devices/device_registry.dart';
import 'package:zigdash/features/devices/devices_providers.dart';
import 'package:zigdash/features/devices/screens/devices_screen.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/l10n/app_localizations.dart';

final _stamp = DateTime(2026, 9, 26);
const _light = [
  {
    'type': 'light',
    'features': [
      {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7},
    ],
  },
];

Widget _app() {
  final devices = [
    const Z2mDevice(
        friendlyName: 'desk',
        type: 'Router',
        ieeeAddress: '0x1',
        rawExposes: _light),
    const Z2mDevice(
        friendlyName: 'hall',
        type: 'Router',
        vendor: 'Tuya',
        model: 'CK-BL702-AL-01',
        ieeeAddress: '0x2',
        rawExposes: _light),
  ];
  return ProviderScope(
    overrides: [
      connectionsStreamProvider.overrideWith((ref) => Stream.value(const [])),
      dashboardsForConnectionProvider.overrideWith((ref, _) => Stream.value([
            Dashboard(
              id: 'd1',
              connectionId: 'c1',
              name: 'Home',
              topicPrefix: 'zigbee2mqtt',
              colorSeed: 0,
              iconCodepoint: 0,
              locked: false,
              sortOrder: 0,
              createdAt: _stamp,
              updatedAt: _stamp,
            ),
          ])),
      discoveredDevicesProvider.overrideWith((ref, _) async => devices),
      deviceHealthProvider.overrideWith((ref, _) => Stream.value([
            const DeviceHealth(friendlyName: 'desk', linkQuality: 80),
            const DeviceHealth(friendlyName: 'hall', linkQuality: 60),
          ])),
      linkedIeeesProvider.overrideWith((ref, _) => Stream.value({'0x1'})),
      sectionsForDashboardProvider
          .overrideWith((ref, _) => Stream.value(const <Section>[])),
      panelsForDashboardProvider
          .overrideWith((ref, _) => Stream.value(const <Panel>[])),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DevicesScreen(connectionId: 'c1'),
    ),
  );
}

void main() {
  testWidgets('unassigned devices are marked; unknown availability is not '
      'shown as offline', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Not on a dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsNothing);
    expect(find.text('Tuya CK-BL702-AL-01'), findsOneWidget);
  });

  testWidgets('tapping a device offers to add it to a dashboard',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('hall'));
    await tester.pumpAndSettle();
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
  });
}
