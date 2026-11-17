import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/dashboard_dao.dart';
import 'package:zigdash/data/database/daos/device_registry_dao.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/daos/section_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/devices/device_tiles.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/ha_import/ha_import_apply.dart';
import 'package:zigdash/features/ha_import/ha_registry.dart';

Z2mDevice _sensor(String ieee) => Z2mDevice(
  friendlyName: ieee,
  type: 'EndDevice',
  ieeeAddress: ieee,
  model: 'ZG-204Z',
  description: 'Motion sensor',
);

final _living = _sensor('0xa4c13836276df66f');
final _kitchen = _sensor('0xa4c13828d7b8e8a1');
final _bedroom = _sensor('0xa4c13863521bcd41');

// The user's Home Assistant after the 2026-10-16 test setup.
ImportPlan _realPlan() => ImportPlan(
  dashboards: [
    ImportDashboard(
      floor: 'Ground floor',
      rooms: [
        ImportRoom(
          name: 'Kitchen',
          devices: [ImportedDevice(device: _kitchen, name: 'Kitchen motion')],
        ),
        ImportRoom(
          name: 'Living Room',
          devices: [
            ImportedDevice(device: _living, name: 'Living room motion'),
          ],
        ),
      ],
    ),
    ImportDashboard(
      floor: null,
      rooms: [
        ImportRoom(
          name: 'Bedroom',
          devices: [ImportedDevice(device: _bedroom, name: 'Bedroom motion')],
        ),
      ],
    ),
  ],
  zhaDevices: 0,
  z2mDevices: 3,
);

void main() {
  late AppDatabase db;
  late HaImportApplier applier;
  late PanelRepo panels;
  late DashboardRepo dashboards;
  late SectionRepo sections;
  late String home;

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    panels = PanelRepo(PanelDao(db));
    dashboards = DashboardRepo(DashboardDao(db));
    sections = SectionRepo(SectionDao(db));
    applier = HaImportApplier(
      dashboards: dashboards,
      sections: sections,
      panels: panels,
      registry: DeviceRegistryDao(db),
    );
    final now = DateTime(2026);
    await db
        .into(db.connections)
        .insert(
          ConnectionsCompanion.insert(
            id: 'c1',
            name: 'My Home',
            host: '192.168.68.52',
            port: 1883,
            protocol: MqttProtocol.tcp,
            createdAt: now,
            updatedAt: now,
          ),
        );
    // The dashboard setup made: one tile per sensor, readable names.
    home = await dashboards.create(
      connectionId: 'c1',
      name: 'My Home',
      topicPrefix: 'zigbee2mqtt',
      colorSeed: 0,
      iconCodepoint: 0,
    );
    for (final (i, d) in [_living, _kitchen, _bedroom].indexed) {
      await createDeviceTile(
        panels,
        dashboardId: home,
        base: 'zigbee2mqtt',
        device: d,
        sortOrder: i,
      );
    }
  });
  tearDown(() => db.close());

  Future<List<String>> names(String dashboardId) async => [
    for (final p in await PanelDao(db).getByDashboard(dashboardId)) p.name,
  ];

  Future<HaImportResult> apply(ImportPlan plan, {bool make = true}) =>
      applier.apply(
        connectionId: 'c1',
        plan: plan,
        makeDashboards: make,
        homeName: 'Home',
        otherRoomsName: 'Other rooms',
        noRoomName: 'Other',
      );

  test('setup\'s tiles take the Home Assistant names; nothing moves', () async {
    final r = await apply(_realPlan(), make: false);
    expect(r.renamed, 3);
    expect(r.dashboardIds, isEmpty);
    expect(await names(home), [
      'Living room motion',
      'Kitchen motion',
      'Bedroom motion',
    ]);
  });

  test('a tile the user named keeps its name', () async {
    final tiles = await PanelDao(db).getByDashboard(home);
    await DeviceRegistryDao(db).setName(tiles.first.id, 'Hall sensor');
    final r = await apply(_realPlan(), make: false);
    expect(r.renamed, 2);
    expect((await names(home)).first, 'Hall sensor');
  });

  test(
    'a dashboard per floor, sections per room, rooms on no floor apart',
    () async {
      final r = await apply(_realPlan());
      expect(r.tiles, 3);
      expect(r.dashboardIds, hasLength(2));
      // The home's own dashboard stays first; the imported ones follow.
      final boards = await dashboards.getByConnection('c1');
      expect(boards.map((b) => b.name), [
        'My Home',
        'Ground floor',
        'Other rooms',
      ]);
      final ground = r.dashboardIds.first;
      expect((await sections.getByDashboard(ground)).map((s) => s.name), [
        'Kitchen',
        'Living Room',
      ]);
      final tiles = await PanelDao(db).getByDashboard(ground);
      expect(tiles.map((t) => t.type), everyElement(PanelType.device));
      expect(tiles.map((t) => t.deviceIeee), [
        '0xa4c13828d7b8e8a1',
        '0xa4c13836276df66f',
      ]);
    },
  );

  test(
    'no floors: one dashboard named Home; unticked rooms are skipped',
    () async {
      final r = await applier.apply(
        connectionId: 'c1',
        plan: ImportPlan(
          dashboards: [
            ImportDashboard(
              floor: null,
              rooms: [
                ImportRoom(
                  name: 'Hall',
                  devices: [ImportedDevice(device: _living, name: 'Hall')],
                ),
                ImportRoom(
                  name: 'Attic',
                  devices: [ImportedDevice(device: _kitchen, name: 'Attic')],
                ),
                ImportRoom(
                  name: null,
                  devices: [ImportedDevice(device: _bedroom, name: 'Spare')],
                ),
              ],
            ),
          ],
          zhaDevices: 0,
          z2mDevices: 3,
        ),
        makeDashboards: true,
        homeName: 'Home',
        otherRoomsName: 'Other rooms',
        noRoomName: 'Other',
        skipRooms: {'Attic'},
      );
      final board = await dashboards.getById(r.dashboardIds.single);
      expect(board!.name, 'Home');
      expect((await sections.getByDashboard(board.id)).map((s) => s.name), [
        'Hall',
        'Other',
      ]);
    },
  );

  test('empty rooms make no dashboard', () async {
    final r = await apply(
      const ImportPlan(
        dashboards: [
          ImportDashboard(
            floor: 'Ground floor',
            rooms: [ImportRoom(name: 'Kitchen', devices: [])],
          ),
        ],
        zhaDevices: 0,
        z2mDevices: 3,
      ),
    );
    expect(r.dashboardIds, isEmpty);
  });

  test(
    'a tile named after the device\'s earlier name is renamed too',
    () async {
      // Setup named the tile by the address; the device has since been
      // renamed in Zigbee2MQTT, before the tiles caught up.
      final renamedInZ2m = Z2mDevice(
        friendlyName: 'Hall',
        type: 'EndDevice',
        ieeeAddress: '0xa4c13836276df66f',
        description: 'Motion sensor',
      );
      final r = await apply(
        ImportPlan(
          dashboards: [
            ImportDashboard(
              floor: null,
              rooms: [
                ImportRoom(
                  name: 'Living Room',
                  devices: [
                    ImportedDevice(
                      device: renamedInZ2m,
                      name: 'Living room motion',
                    ),
                  ],
                ),
              ],
            ),
          ],
          zhaDevices: 0,
          z2mDevices: 3,
        ),
        make: false,
      );
      expect(r.renamed, 1);
      expect((await names(home)).first, 'Living room motion');
    },
  );

  test('importing again renames nothing twice', () async {
    await apply(_realPlan(), make: false);
    final again = await apply(_realPlan(), make: false);
    expect(again.renamed, 0);
  });
}
