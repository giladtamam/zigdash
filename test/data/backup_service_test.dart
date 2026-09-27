import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/daos/dashboard_dao.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/daos/section_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/backup_service.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

class _MemSecure implements SecureStore {
  @override
  Future<void> writePassword(String id, String pw) async {}
  @override
  Future<String?> readPassword(String id) async => null;
  @override
  Future<void> deletePassword(String id) async {}
}

void main() {
  late AppDatabase db;
  late ConnectionRepo homes;
  late DashboardRepo dashboards;
  late SectionRepo sections;
  late PanelRepo panels;
  late BackupService backup;

  Future<String> connection(String id) async {
    final now = DateTime(2026);
    await db.into(db.connections).insert(ConnectionsCompanion.insert(
          id: id,
          name: id,
          host: 'broker',
          port: 1883,
          protocol: MqttProtocol.tcp,
          createdAt: now,
          updatedAt: now,
        ));
    return id;
  }

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    dashboards = DashboardRepo(DashboardDao(db));
    sections = SectionRepo(SectionDao(db));
    panels = PanelRepo(PanelDao(db));
    homes = ConnectionRepo(ConnectionDao(db), _MemSecure());
    backup = BackupService(dashboards, sections, panels, homes);
  });
  tearDown(() => db.close());

  test('format 3 carries the base topic to a home that has none', () async {
    final source = await connection('c1');
    await homes.setBaseTopic(source, ' z2m-garage ');
    await dashboards.create(
        connectionId: source, name: 'Home', colorSeed: 0, iconCodepoint: 0);
    final raw = await backup.exportConnection(source);
    expect(json.decode(raw)['version'], 3);
    expect(json.decode(raw)['z2mBaseTopic'], 'z2m-garage');

    final empty = await connection('c2');
    await backup.importToConnection(empty, raw);
    expect((await homes.getById(empty))!.z2mBaseTopic, 'z2m-garage');

    final set = await connection('c3');
    await homes.setBaseTopic(set, 'mine');
    await backup.importToConnection(set, raw);
    expect((await homes.getById(set))!.z2mBaseTopic, 'mine');
  });

  test('a format 2 backup leaves the base topic unset', () async {
    final target = await connection('c1');
    await backup.importToConnection(
        target, json.encode({'version': 2, 'dashboards': []}));
    expect((await homes.getById(target))!.z2mBaseTopic, isNull);
  });

  test('clearing the base topic stores null', () async {
    final id = await connection('c1');
    await homes.setBaseTopic(id, 'x');
    await homes.setBaseTopic(id, '  ');
    expect((await homes.getById(id))!.z2mBaseTopic, isNull);
  });

  test('a 1.11 (format 1) backup imports with half and third as Small',
      () async {
    final target = await connection('c1');
    final raw = json.encode({
      'version': 1,
      'dashboards': [
        {
          'name': 'Home',
          'panels': [
            for (final (i, w) in ['full', 'half', 'third'].indexed)
              {
                'name': w,
                'type': 'toggle',
                'topic': 't/$w',
                'width': w,
                'sortOrder': i,
                'config': {},
              },
          ],
        },
      ],
    });

    expect(await backup.importToConnection(target, raw), 1);

    final dash = (await dashboards.getByConnection(target)).single;
    final rows = await panels.getByDashboard(dash.id);
    expect(rows.map((p) => p.width),
        [PanelWidth.full, PanelWidth.small, PanelWidth.small]);
    expect(rows.every((p) => p.sectionId == null), isTrue);
  });

  test('format 3 round-trips sections, sizes and device links', () async {
    final source = await connection('c1');
    final dashId = await dashboards.create(
      connectionId: source,
      name: 'Home',
      colorSeed: 0,
      iconCodepoint: 0,
    );
    final lights = await sections.create(dashboardId: dashId, name: 'Lights');
    await sections.create(dashboardId: dashId, name: 'Sensors', sortOrder: 1);
    await panels.create(
      dashboardId: dashId,
      name: 'Loose',
      type: PanelType.textLog,
      topic: 'log',
      width: PanelWidth.full,
      config: PanelConfig.defaultFor(PanelType.textLog),
    );
    await panels.create(
      dashboardId: dashId,
      name: 'Desk lamp',
      type: PanelType.toggle,
      topic: 'zigbee2mqtt/desk',
      width: PanelWidth.wide,
      sortOrder: 1,
      sectionId: lights,
      deviceIeee: '0xc4d7fdbbfeba0000',
      config: PanelConfig.defaultFor(PanelType.toggle),
    );

    final exported = await backup.exportConnection(source);
    expect(json.decode(exported)['version'], 3);

    final target = await connection('c2');
    await backup.importToConnection(target, exported);

    final dash = (await dashboards.getByConnection(target)).single;
    final secs = await sections.getByDashboard(dash.id);
    expect(secs.map((s) => s.name), ['Lights', 'Sensors']);
    final rows = await panels.getByDashboard(dash.id);
    expect(rows.map((p) => p.name), ['Loose', 'Desk lamp']);
    expect(rows[0].sectionId, isNull);
    expect(rows[1].sectionId, secs[0].id);
    expect(rows[1].width, PanelWidth.wide);
    expect(rows[1].deviceIeee, '0xc4d7fdbbfeba0000');
  });

  test('deleting a section keeps or deletes its tiles as asked', () async {
    final c = await connection('c1');
    final dashId = await dashboards.create(
        connectionId: c, name: 'Home', colorSeed: 0, iconCodepoint: 0);
    final a = await sections.create(dashboardId: dashId, name: 'A');
    final b = await sections.create(dashboardId: dashId, name: 'B');
    for (final (s, name) in [(a, 'a1'), (b, 'b1')]) {
      await panels.create(
        dashboardId: dashId,
        name: name,
        type: PanelType.toggle,
        topic: name,
        sectionId: s,
        config: PanelConfig.defaultFor(PanelType.toggle),
      );
    }

    await sections.delete(a, deleteTiles: false);
    await sections.delete(b, deleteTiles: true);

    final rows = await panels.getByDashboard(dashId);
    expect(rows.map((p) => p.name), ['a1']);
    expect(rows.single.sectionId, isNull);
    expect(await sections.getByDashboard(dashId), isEmpty);
  });

  test('deleting a dashboard deletes its sections and tiles', () async {
    final c = await connection('c1');
    final dashId = await dashboards.create(
        connectionId: c, name: 'Home', colorSeed: 0, iconCodepoint: 0);
    await sections.create(dashboardId: dashId, name: 'A');
    await panels.create(
      dashboardId: dashId,
      name: 'p',
      type: PanelType.toggle,
      topic: 't',
      config: PanelConfig.defaultFor(PanelType.toggle),
    );

    await dashboards.delete(dashId);

    expect(await db.select(db.panels).get(), isEmpty);
    expect(await db.select(db.sections).get(), isEmpty);
  });
}
