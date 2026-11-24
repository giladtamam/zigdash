import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/ha_import/ha_import_apply.dart';
import 'package:zigdash/features/ha_import/ha_import_controller.dart';
import 'package:zigdash/features/ha_import/ha_import_screen.dart';
import 'package:zigdash/features/ha_import/ha_registry.dart';

import 'golden_harness.dart';

// 2.8 import from Home Assistant (docs/design/ha-import.md): the first step
// after a refused token, the preview of the user's real home, and done.

final _stamp = DateTime(2026, 10, 16);
final _homes = [
  Connection(
    transport: ConnectionTransport.mqtt,
    id: 'c1',
    name: 'My Home',
    host: '192.168.68.52',
    port: 1883,
    protocol: MqttProtocol.tcp,
    keepAliveSeconds: 60,
    autoConnect: true,
    createdAt: _stamp,
    updatedAt: _stamp,
  ),
];

Z2mDevice _sensor(String ieee) => Z2mDevice(
  friendlyName: ieee,
  type: 'EndDevice',
  ieeeAddress: ieee,
  description: 'Motion sensor',
);

final _plan = ImportPlan(
  dashboards: [
    ImportDashboard(
      floor: 'Ground floor',
      rooms: [
        ImportRoom(
          name: 'Kitchen',
          devices: [
            ImportedDevice(
              device: _sensor('0xa4c13828d7b8e8a1'),
              name: 'Kitchen motion',
            ),
          ],
        ),
        ImportRoom(
          name: 'Living Room',
          devices: [
            ImportedDevice(
              device: _sensor('0xa4c13836276df66f'),
              name: 'Living room motion',
            ),
          ],
        ),
      ],
    ),
    ImportDashboard(
      floor: null,
      rooms: [
        ImportRoom(
          name: 'Bedroom',
          devices: [
            ImportedDevice(
              device: _sensor('0xa4c13863521bcd41'),
              name: 'Bedroom motion',
            ),
          ],
        ),
      ],
    ),
  ],
  zhaDevices: 0,
  z2mDevices: 3,
);

HaImportController _in(HaImportState state, {bool signIn = false}) =>
    HaImportController(
      signIn: signIn
          ? (_) async => (accessToken: null, refreshToken: null, error: null)
          : null,
      address: '192.168.68.52:8123',
      reader: (_, _) async => (registry: null, error: null),
      devices: () async => const [],
      writer: (_, {required makeDashboards, required skipRooms}) async =>
          const HaImportResult(renamed: 0, dashboardIds: [], tiles: 0),
    )..value = state;

void main() {
  group('ha import', () {
    goldenTest(
      'ha_import_sign_in',
      fileName: 'ha_import_sign_in',
      builder: () => goldenMatrix(
        variants: phoneMatrix,
        overrides: () => [
          connectionsStreamProvider.overrideWith((ref) => Stream.value(_homes)),
        ],
        screen: () => HaImportScreen(
          connectionId: 'c1',
          controller: _in(
            const HaImportAsk(address: '192.168.68.52:8123'),
            signIn: true,
          ),
        ),
      ),
    );

    for (final (name, state) in [
      (
        'ha_import_refused',
        const HaImportAsk(
          address: '192.168.68.52:8123',
          problem: HaImportProblem.badToken,
        ),
      ),
      ('ha_import_preview', HaImportPreview(plan: _plan)),
      (
        'ha_import_done',
        const HaImportDone(
          HaImportResult(renamed: 3, dashboardIds: ['a', 'b'], tiles: 3),
        ),
      ),
    ]) {
      goldenTest(
        name,
        fileName: name,
        builder: () => goldenMatrix(
          variants: phoneMatrix,
          overrides: () => [
            connectionsStreamProvider.overrideWith(
              (ref) => Stream.value(_homes),
            ),
          ],
          screen: () =>
              HaImportScreen(connectionId: 'c1', controller: _in(state)),
        ),
      );
    }
  });
}
