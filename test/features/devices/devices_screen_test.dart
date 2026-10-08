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
import 'package:zigdash/features/devices/z2m_bridge.dart';
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

const _door = [
  {'type': 'binary', 'name': 'contact', 'property': 'contact', 'access': 1},
  {'type': 'numeric', 'name': 'battery', 'property': 'battery', 'access': 1},
];

const _deskDevice = Z2mDevice(
    friendlyName: 'desk', type: 'Router', ieeeAddress: '0x1', rawExposes: _light);
const _hallDevice = Z2mDevice(
    friendlyName: 'hall',
    type: 'Router',
    vendor: 'Tuya',
    model: 'CK-BL702-AL-01',
    ieeeAddress: '0x2',
    rawExposes: _light);
const _doorDevice = Z2mDevice(
    friendlyName: 'back door',
    type: 'EndDevice',
    ieeeAddress: '0x3',
    rawExposes: _door);

Widget _app({
  AvailabilityConfig availability = AvailabilityConfig.unknown,
  ValueChanged<String>? onSelect,
}) {
  final rows = deviceHealthFrom(
    [_deskDevice, _hallDevice, _doorDevice],
    states: {
      'desk': (payload: '{"state":"ON","linkquality":80}', at: _stamp),
      'hall': (payload: '{"state":"OFF","linkquality":60}', at: _stamp),
      'back door': (
        payload: '{"contact":true,"battery":8,"linkquality":90}',
        at: _stamp
      ),
    },
  );
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
      bridgeDevicesStreamProvider.overrideWith(
          (ref, _) => Stream.value([_deskDevice, _hallDevice, _doorDevice])),
      deviceHealthProvider.overrideWith((ref, _) => Stream.value(rows)),
      availabilityConfigProvider
          .overrideWith((ref, _) => Stream.value(availability)),
      linkedIeeesProvider.overrideWith((ref, _) => Stream.value({'0x1', '0x3'})),
      unassignedDevicesProvider
          .overrideWith((ref, _) => const AsyncValue.data([_hallDevice])),
      sectionsForDashboardProvider
          .overrideWith((ref, _) => Stream.value(const <Section>[])),
      panelsForDashboardProvider
          .overrideWith((ref, _) => Stream.value(const <Panel>[])),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DevicesScreen(connectionId: 'c1', onSelect: onSelect),
    ),
  );
}

/// The Devices tab for a home with no devices; [missing] says whether
/// Zigbee2MQTT's device list never arrived.
Widget _emptyApp({required bool missing}) => ProviderScope(
      overrides: [
        connectionsStreamProvider.overrideWith((ref) => Stream.value(const [])),
        bridgeDevicesMissingProvider.overrideWith((ref, _) async => missing),
        deviceHealthProvider
            .overrideWith((ref, _) => Stream.value(const <DeviceHealth>[])),
        availabilityConfigProvider
            .overrideWith((ref, _) => Stream.value(AvailabilityConfig.unknown)),
        linkedIeeesProvider
            .overrideWith((ref, _) => Stream.value(const <String>{})),
        unassignedDevicesProvider
            .overrideWith((ref, _) => const AsyncValue.data(<Z2mDevice>[])),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DevicesScreen(connectionId: 'c1'),
      ),
    );

void main() {
  testWidgets('no devices: says so plainly when the list arrived empty',
      (tester) async {
    await tester.pumpWidget(_emptyApp(missing: false));
    await tester.pumpAndSettle();
    expect(find.text('No devices found.'), findsOneWidget);
    expect(find.text('Restart Zigbee2MQTT'), findsNothing);
  });

  testWidgets('device list never arrived: explains it and offers a restart',
      (tester) async {
    await tester.pumpWidget(_emptyApp(missing: true));
    await tester.pumpAndSettle();
    expect(find.textContaining("hasn't sent its device list"), findsOneWidget);
    expect(find.text('Restart Zigbee2MQTT'), findsOneWidget);
    expect(find.text('No devices found.'), findsNothing);
  });

  testWidgets('attention first, with filter counts; unassigned marked',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Not on a dashboard'), findsOneWidget);
    expect(find.text('Needs attention · 1'), findsOneWidget);
    expect(find.text('Not on a dashboard · 1'), findsOneWidget);
    final names = tester
        .widgetList<DeviceHealthRow>(find.byType(DeviceHealthRow))
        .map((r) => r.health.friendlyName);
    expect(names, ['back door', 'desk', 'hall']);
    expect(find.byIcon(Icons.battery_alert), findsOneWidget);
  });

  testWidgets('availability off: no online/offline claims, one footnote',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off), findsNothing);
    expect(find.text('How to turn it on'), findsOneWidget);
  });

  testWidgets('availability on: the footnote goes away', (tester) async {
    await tester.pumpWidget(
        _app(availability: const AvailabilityConfig(enabled: true)));
    await tester.pumpAndSettle();
    expect(find.text('How to turn it on'), findsNothing);
  });

  testWidgets('filtering to Needs attention shows only those', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Needs attention · 1'));
    await tester.pumpAndSettle();
    expect(find.byType(DeviceHealthRow), findsOneWidget);
    expect(find.text('back door'), findsOneWidget);
  });

  testWidgets('tapping a device opens it', (tester) async {
    String? opened;
    await tester.pumpWidget(_app(onSelect: (ieee) => opened = ieee));
    await tester.pumpAndSettle();
    await tester.tap(find.text('hall'));
    expect(opened, '0x2');
  });

  testWidgets('long-press offers Add to a dashboard, and Dismiss when new',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.longPress(find.text('hall'));
    await tester.pumpAndSettle();
    expect(find.text('Add to a dashboard'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });
}
