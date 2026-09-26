import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/dashboard_dao.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/daos/section_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/backup_service.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

void main() {
  late AppDatabase db;
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
    backup = BackupService(dashboards, sections, panels);
  });
  tearDown(() => db.close());

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

  test('format 2 round-trips sections, sizes and device links', () async {
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
    expect(json.decode(exported)['version'], 2);

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
}
