import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/daos/dashboard_dao.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
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
