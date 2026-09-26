import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/dashboard_dao.dart';
import 'package:zigdash/data/database/daos/device_registry_dao.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/features/devices/device_registry.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

Z2mDevice _dev(String name, String ieee) =>
    Z2mDevice(friendlyName: name, type: 'Router', ieeeAddress: ieee);

void main() {
  late AppDatabase db;
  late DeviceRegistryDao dao;
  late DeviceRegistry registry;
  late PanelRepo panels;
  late String dash;

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    dao = DeviceRegistryDao(db);
    registry = DeviceRegistry(dao);
    panels = PanelRepo(PanelDao(db));
    final now = DateTime(2026);
    await db.into(db.connections).insert(ConnectionsCompanion.insert(
          id: 'c1',
          name: 'home',
          host: 'h',
          port: 1883,
          protocol: MqttProtocol.tcp,
          createdAt: now,
          updatedAt: now,
        ));
    dash = await DashboardRepo(DashboardDao(db)).create(
        connectionId: 'c1',
        name: 'Home',
        topicPrefix: 'zigbee2mqtt',
        colorSeed: 0,
        iconCodepoint: 0);
  });
  tearDown(() => db.close());

  Future<Set<String>> unassigned(List<Z2mDevice> devices) async =>
      unassignedDevices(
        devices,
        await dao.watchLinkedIeees('c1').first,
        await dao.watchDismissed('c1').first,
      ).map((d) => d.ieeeAddress!).toSet();

  test('an upgrade links old tiles and raises nothing for existing devices',
      () async {
    // A 1.11 custom tile on the lamp (topics as the panel form stores them).
    final lampTile = await panels.create(
      dashboardId: dash,
      name: 'Lamp',
      type: PanelType.toggle,
      topic: 'set',
      subscribeTopic: '',
      topicPrefixOverride: 'zigbee2mqtt/lamp',
      config: PanelConfig.defaultFor(PanelType.toggle),
    );
    final devices = [_dev('lamp', '0x1'), _dev('hall_sensor', '0x2')];

    await registry.sync('c1', 'zigbee2mqtt', devices);

    expect((await PanelDao(db).getById(lampTile))!.deviceIeee, '0x1');
    expect(await unassigned(devices), isEmpty,
        reason: 'the sensor existed before the upgrade');
    expect(await dao.devicesSeenAt('c1'), isNotNull);
  });

  test('a device paired after the first sync counts as new', () async {
    await registry.sync('c1', 'zigbee2mqtt', [_dev('lamp', '0x1')]);
    final later = [_dev('lamp', '0x1'), _dev('new_plug', '0x9')];

    await registry.sync('c1', 'zigbee2mqtt', later);

    expect(await unassigned(later), {'0x9'});
  });

  test('a rename in Zigbee2MQTT moves the device tile to the new topic',
      () async {
    final tile = await panels.create(
      dashboardId: dash,
      name: 'Bulb',
      type: PanelType.device,
      topic: 'set',
      subscribeTopic: '',
      topicPrefixOverride: 'zigbee2mqtt/0xc4d7fdbbfeba0000',
      deviceIeee: '0xc4d7fdbbfeba0000',
      config: PanelConfig.defaultFor(PanelType.device),
    );
    await registry.sync('c1', 'zigbee2mqtt',
        [_dev('0xc4d7fdbbfeba0000', '0xc4d7fdbbfeba0000')]);

    await registry.sync('c1', 'zigbee2mqtt',
        [_dev('living_room_bulb', '0xc4d7fdbbfeba0000')]);

    expect((await PanelDao(db).getById(tile))!.topicPrefixOverride,
        'zigbee2mqtt/living_room_bulb');
  });

  test('tiles on the dashboard prefix link too; unrelated topics do not',
      () async {
    final viaDashboard = await panels.create(
      dashboardId: dash,
      name: 'Door',
      type: PanelType.led,
      topic: 'door',
      config: PanelConfig.defaultFor(PanelType.led),
    );
    final other = await panels.create(
      dashboardId: dash,
      name: 'Log',
      type: PanelType.textLog,
      topic: 'system/log',
      config: PanelConfig.defaultFor(PanelType.textLog),
    );

    await registry.sync('c1', 'zigbee2mqtt', [_dev('door', '0x5')]);

    expect((await PanelDao(db).getById(viaDashboard))!.deviceIeee, '0x5');
    expect((await PanelDao(db).getById(other))!.deviceIeee, isNull);
  });
}
