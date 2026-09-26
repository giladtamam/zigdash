import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/daos/dashboard_dao.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/daos/section_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/onboarding/setup/recommendation_policy.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';

class _MemSecure implements SecureStore {
  final _m = <String, String>{};
  @override
  Future<void> writePassword(String id, String pw) async => _m[id] = pw;
  @override
  Future<String?> readPassword(String id) async => _m[id];
  @override
  Future<void> deletePassword(String id) async => _m.remove(id);
}

ReviewRow row(String name, Z2mExpose expose) => recommendDevices([
      Z2mDevice(friendlyName: name, type: 'EndDevice', exposes: [expose]),
    ]).single;

void main() {
  late AppDatabase db;
  late SetupCreator creator;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    creator = SetupCreator(
      connections: ConnectionRepo(ConnectionDao(db), _MemSecure()),
      dashboards: DashboardRepo(DashboardDao(db)),
      sections: SectionRepo(SectionDao(db)),
      panels: PanelRepo(PanelDao(db)),
    );
  });
  tearDown(() => db.close());

  final selected = [
    row('lamp', const Z2mExpose(type: 'light')),
    row('shutter', const Z2mExpose(type: 'cover')),
  ];

  test('creates connection, dashboard and one panel per selected row', () async {
    final result = await creator.create(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
      selected: selected,
    );

    final conn = await ConnectionDao(db).getById(result.connectionId);
    expect(conn, isNotNull);
    expect(conn!.host, '192.168.1.10');
    expect(conn.autoConnect, isTrue);

    final dash = await DashboardDao(db).getById(result.dashboardId);
    expect(dash, isNotNull);
    expect(dash!.connectionId, result.connectionId);

    final panels = await PanelDao(db).getByDashboard(result.dashboardId);
    expect(panels, hasLength(2));
    expect(panels.map((p) => p.type),
        containsAll([PanelType.slider, PanelType.cover]));
    expect(panels.map((p) => p.topicPrefixOverride),
        containsAll(['zigbee2mqtt/lamp', 'zigbee2mqtt/shutter']));
  });

  test('created tiles publish to <device>/set and read <device>', () async {
    final result = await creator.create(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
      selected: selected,
    );
    final dash = await DashboardDao(db).getById(result.dashboardId);
    final lamp = (await PanelDao(db).getByDashboard(result.dashboardId))
        .firstWhere((p) => p.name == 'lamp');

    // Composed exactly as PanelTile does.
    final prefix = lamp.topicPrefixOverride ?? dash!.topicPrefix;
    expect(composeTopic(prefix, lamp.topic), 'zigbee2mqtt/lamp/set');
    expect(composeTopic(prefix, lamp.subscribeTopic ?? lamp.topic),
        'zigbee2mqtt/lamp');
  });

  test('a second create call returns the same result without duplicating',
      () async {
    final first = await creator.create(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
      selected: selected,
    );
    final second = await creator.create(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
      selected: selected,
    );

    expect(second.connectionId, first.connectionId);
    expect(second.dashboardId, first.dashboardId);
    final panels = await PanelDao(db).getByDashboard(first.dashboardId);
    expect(panels, hasLength(2));
  });

  test('failure rolls everything back so a retry starts clean', () async {
    final failing = SetupCreator(
      connections: ConnectionRepo(ConnectionDao(db), _MemSecure()),
      dashboards: DashboardRepo(DashboardDao(db)),
      sections: SectionRepo(SectionDao(db)),
      panels: _FailingPanelRepo(PanelDao(db)),
    );

    await expectLater(
      failing.create(
        host: '192.168.1.10',
        port: 1883,
        protocol: MqttProtocol.tcp,
        selected: selected,
      ),
      throwsStateError,
    );

    // Nothing half-configured survives the failure.
    expect(await db.select(db.connections).get(), isEmpty);
    expect(await db.select(db.dashboards).get(), isEmpty);
    expect(await db.select(db.panels).get(), isEmpty);
  });

  test('custom base topic is respected in panel topic prefixes', () async {
    final result = await creator.create(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
      base: 'z2m',
      selected: [
        recommendDevices([
          const Z2mDevice(
              friendlyName: 'lamp',
              type: 'EndDevice',
              exposes: [Z2mExpose(type: 'light')]),
        ], base: 'z2m')
            .single,
      ],
    );
    final panels = await PanelDao(db).getByDashboard(result.dashboardId);
    expect(panels.single.topicPrefixOverride, 'z2m/lamp');
  });

  group('device tiles from bridge/devices', () {
    Z2mDevice device(String name, String ieee, List<Object?> exposes) =>
        Z2mDevice(
          friendlyName: name,
          type: 'Router',
          vendor: 'Tuya',
          model: 'CK-BL702-AL-01',
          ieeeAddress: ieee,
          rawExposes: exposes,
        );
    final bulb = device('0xc4d7fdbbfeba0000', '0xc4d7fdbbfeba0000', [
      {
        'type': 'light',
        'features': [
          {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7},
          {'type': 'composite', 'name': 'color_xy', 'property': 'color', 'access': 7},
        ],
      },
    ]);
    final plug = device('plug', '0x6ce4a4fffe6d2f80', [
      {
        'type': 'switch',
        'features': [
          {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7},
        ],
      },
    ]);
    final door = device('door', '0x01', [
      {'type': 'binary', 'name': 'contact', 'property': 'contact', 'access': 1},
    ]);
    ReviewRow pick(Z2mDevice d) =>
        recommendDevices([d]).single.copyWith(selected: true);

    test('sections in order, one device tile each, sizes by class',
        () async {
      final result = await creator.create(
        host: '192.168.68.55',
        port: 1883,
        protocol: MqttProtocol.tcp,
        selected: [pick(door), pick(plug), pick(bulb)],
      );

      final sections = await SectionDao(db).getByDashboard(result.dashboardId);
      expect(sections.map((s) => s.name),
          ['Lights', 'Switches and covers', 'Sensors']);
      final tiles = await PanelDao(db).getByDashboard(result.dashboardId);
      expect(tiles.map((p) => p.type), everyElement(PanelType.device));
      final byName = {for (final p in tiles) p.name: p};
      final b = byName['0xc4d7fdbbfeba0000']!;
      expect(b.sectionId, sections[0].id);
      expect(b.width, PanelWidth.wide);
      expect(b.deviceIeee, '0xc4d7fdbbfeba0000');
      expect(composeTopic(b.topicPrefixOverride, b.topic),
          'zigbee2mqtt/0xc4d7fdbbfeba0000/set');
      expect(composeTopic(b.topicPrefixOverride, b.subscribeTopic!),
          'zigbee2mqtt/0xc4d7fdbbfeba0000');
      final cfg = PanelConfig.decode(b.type, b.config) as DeviceTileConfig;
      expect(cfg.profile.deviceClass, DeviceClass.colorLight);
      expect(cfg.model, 'Tuya CK-BL702-AL-01');
      expect(byName['plug']!.sectionId, sections[1].id);
      expect(byName['plug']!.width, PanelWidth.small);
      expect(byName['door']!.sectionId, sections[2].id);
    });

    test('the first home is My Home, the next Home 2', () async {
      final first = await creator.create(
        host: '192.168.68.55',
        port: 1883,
        protocol: MqttProtocol.tcp,
        selected: [pick(plug)],
      );
      final second = await SetupCreator(
        connections: ConnectionRepo(ConnectionDao(db), _MemSecure()),
        dashboards: DashboardRepo(DashboardDao(db)),
        sections: SectionRepo(SectionDao(db)),
        panels: PanelRepo(PanelDao(db)),
      ).create(
        host: '10.0.0.2',
        port: 1883,
        protocol: MqttProtocol.tcp,
        selected: [pick(plug)],
      );
      final dao = ConnectionDao(db);
      expect((await dao.getById(first.connectionId))!.name, 'My Home');
      expect((await dao.getById(second.connectionId))!.name, 'Home 2');
    });

    test('names are written in the app language', () async {
      final hebrew = SetupCreator(
        connections: ConnectionRepo(ConnectionDao(db), _MemSecure()),
        dashboards: DashboardRepo(DashboardDao(db)),
        sections: SectionRepo(SectionDao(db)),
        panels: PanelRepo(PanelDao(db)),
        l10n: lookupAppLocalizations(const Locale('he')),
      );
      final result = await hebrew.create(
        host: '192.168.68.55',
        port: 1883,
        protocol: MqttProtocol.tcp,
        selected: [pick(bulb)],
      );
      expect((await ConnectionDao(db).getById(result.connectionId))!.name,
          'הבית שלי');
      expect(
          (await SectionDao(db).getByDashboard(result.dashboardId)).single.name,
          'תאורה');
    });
  });
}

class _FailingPanelRepo extends PanelRepo {
  _FailingPanelRepo(super.dao);

  @override
  Future<String> create({
    required String dashboardId,
    required String name,
    required PanelType type,
    required String topic,
    String? subscribeTopic,
    String? topicPrefixOverride,
    int qos = 1,
    bool retain = false,
    PanelWidth width = PanelWidth.small,
    int sortOrder = 0,
    String? sectionId,
    String? deviceIeee,
    required config,
  }) =>
      throw StateError('disk full');
}
