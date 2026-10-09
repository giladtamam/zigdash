import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

import 'generated/schema.dart';
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

/// The 15 panel types a 1.11 database can hold.
const _v5Types = [
  PanelType.button,
  PanelType.toggle,
  PanelType.slider,
  PanelType.led,
  PanelType.nodeStatus,
  PanelType.progress,
  PanelType.multiState,
  PanelType.combo,
  PanelType.radio,
  PanelType.cover,
  PanelType.textInput,
  PanelType.textLog,
  PanelType.schedule,
  PanelType.scene,
  PanelType.autoClose,
];

const _v5Widths = ['full', 'half', 'third'];

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('schema 5 → 7 matches the declared schema', () async {
    final connection = await verifier.startAt(5);
    final db = AppDatabase.test(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 7);
  });

  test('schema 6 → 7 matches the declared schema', () async {
    final connection = await verifier.startAt(6);
    final db = AppDatabase.test(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 7);
  });

  test('a 1.12 home keeps everything through 6 → 7, base topic unset',
      () async {
    final schema = await verifier.schemaAt(6);
    final old = v6.DatabaseAtV6(schema.newConnection());
    await old.into(old.connections).insert(v6.ConnectionsCompanion.insert(
          id: 'c1',
          name: 'home',
          host: '192.168.68.55',
          port: 1883,
          protocol: 'tcp',
          devicesSeenAt: const Value(5),
          createdAt: 0,
          updatedAt: 0,
        ));
    await old.into(old.dashboards).insert(v6.DashboardsCompanion.insert(
          id: 'd1',
          connectionId: 'c1',
          name: 'Home',
          colorSeed: 0,
          iconCodepoint: 0xe88a, // a 1.12 preview's "?" bubble
          createdAt: 0,
          updatedAt: 0,
        ));
    await old.into(old.sections).insert(v6.SectionsCompanion.insert(
        id: 's1',
        dashboardId: 'd1',
        name: 'Lights',
        createdAt: 0,
        updatedAt: 0));
    await old.into(old.panels).insert(v6.PanelsCompanion.insert(
          id: 'p1',
          dashboardId: 'd1',
          name: 'Bulb',
          type: 'device',
          topic: 'zigbee2mqtt/bulb',
          width: 'wide',
          sectionId: const Value('s1'),
          deviceIeee: const Value('0x01'),
          config: '{"ieee":"0x01"}',
          createdAt: 0,
          updatedAt: 0,
        ));
    await old.into(old.deviceDismissals).insert(v6.DeviceDismissalsCompanion
        .insert(connectionId: 'c1', ieee: '0x02', dismissedAt: 0));
    await old.close();

    final db = AppDatabase.test(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 7);

    final home = await db.select(db.connections).getSingle();
    expect(home.z2mBaseTopic, isNull);
    expect(home.devicesSeenAt, isNotNull);
    final tile = await db.select(db.panels).getSingle();
    expect((tile.sectionId, tile.deviceIeee, tile.width),
        ('s1', '0x01', PanelWidth.wide));
    expect(await db.select(db.sections).get(), hasLength(1));
    expect(await db.select(db.deviceDismissals).get(), hasLength(1));
    expect(await db.select(db.deviceHealthFlags).get(), isEmpty);
    final dash = await db.select(db.dashboards).getSingle();
    expect(dash.iconCodepoint, 0xe318, reason: 'the ? bubble becomes home');
  });

  test('every 1.11 panel survives 5 → 7 with order, config and size',
      () async {
    final schema = await verifier.schemaAt(5);
    final old = v5.DatabaseAtV5(schema.newConnection());
    await old.into(old.connections).insert(v5.ConnectionsCompanion.insert(
          id: 'c1',
          name: 'home',
          host: '192.168.68.55',
          port: 1883,
          protocol: 'tcp',
          createdAt: 0,
          updatedAt: 0,
        ));
    await old.into(old.dashboards).insert(v5.DashboardsCompanion.insert(
          id: 'd1',
          connectionId: 'c1',
          name: 'Home',
          colorSeed: 0,
          iconCodepoint: 0xe88a, // as 1.11 setup stored it
          createdAt: 0,
          updatedAt: 0,
        ));
    final configs = <String, String>{};
    for (var i = 0; i < _v5Types.length; i++) {
      final type = _v5Types[i];
      final config = PanelConfig.defaultFor(type).encode();
      configs['p$i'] = config;
      await old.into(old.panels).insert(v5.PanelsCompanion.insert(
            id: 'p$i',
            dashboardId: 'd1',
            name: type.name,
            type: type.name,
            topic: 'zigbee2mqtt/${type.name}',
            width: _v5Widths[i % 3],
            sortOrder: Value(i),
            config: config,
            createdAt: 0,
            updatedAt: 0,
          ));
    }
    await old.into(old.scenes).insert(v5.ScenesCompanion.insert(
          id: 's1',
          connectionId: 'c1',
          name: 'Evening',
          iconCodepoint: 0,
          colorSeed: 0,
          actions: '[]',
          createdAt: 0,
          updatedAt: 0,
        ));
    // Tiles as 1.11 setup wrote them: full device topic as prefix and topic.
    for (final (id, type) in [('setup-toggle', 'toggle'), ('setup-led', 'led')]) {
      await old.into(old.panels).insert(v5.PanelsCompanion.insert(
            id: id,
            dashboardId: 'd1',
            name: id,
            type: type,
            topic: 'zigbee2mqtt/lamp',
            subscribeTopic: const Value('zigbee2mqtt/lamp'),
            topicPrefixOverride: const Value('zigbee2mqtt/lamp'),
            width: 'half',
            sortOrder: const Value(100),
            config: '{}',
            createdAt: 0,
            updatedAt: 0,
          ));
    }
    // A tile left behind by a pre-1.12 dashboard delete (no cascades then).
    await old.into(old.panels).insert(v5.PanelsCompanion.insert(
          id: 'orphan',
          dashboardId: 'deleted-dashboard',
          name: 'orphan',
          type: 'toggle',
          topic: 't',
          width: 'half',
          config: '{}',
          createdAt: 0,
          updatedAt: 0,
        ));
    await old.close();

    final db = AppDatabase.test(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 7);

    final all = await PanelDao(db).getByDashboard('d1');
    final toggle = all.firstWhere((p) => p.id == 'setup-toggle');
    expect((toggle.topic, toggle.subscribeTopic), ('set', ''));
    final led = all.firstWhere((p) => p.id == 'setup-led');
    expect((led.topic, led.subscribeTopic), ('', ''));

    final panels = all.where((p) => !p.id.startsWith('setup-')).toList();
    expect(panels.map((p) => p.id), [
      for (var i = 0; i < _v5Types.length; i++) 'p$i',
    ]);
    for (var i = 0; i < panels.length; i++) {
      final p = panels[i];
      expect(p.type, _v5Types[i]);
      expect(p.config, configs[p.id]);
      expect(
        p.width,
        _v5Widths[i % 3] == 'full' ? PanelWidth.full : PanelWidth.small,
      );
      expect(p.sectionId, isNull);
      expect(p.deviceIeee, isNull);
    }
    expect(await db.select(db.panels).get(), hasLength(_v5Types.length + 2),
        reason: 'the orphaned tile is dropped');
    expect(await db.select(db.scenes).get(), hasLength(1));
    expect(await db.select(db.sections).get(), isEmpty);
    // Upgraded homes have not had their devices recorded as seen yet.
    final dash = await db.select(db.dashboards).getSingle();
    expect(dash.iconCodepoint, 0xe318, reason: 'the ? bubble becomes home');
    final home = await db.select(db.connections).getSingle();
    expect(home.devicesSeenAt, isNull);
  });
}
