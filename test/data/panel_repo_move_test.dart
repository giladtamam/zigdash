import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/dashboard_dao.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/daos/section_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

void main() {
  late AppDatabase db;
  late PanelRepo panels;
  late String dash, lights, sensors;
  final ids = <String, String>{};

  Future<List<(String, String?)>> order() async => [
        for (final p in await panels.getByDashboard(dash))
          (p.name, p.sectionId == lights
              ? 'L'
              : p.sectionId == sensors
                  ? 'S'
                  : null),
      ];

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    panels = PanelRepo(PanelDao(db));
    final now = DateTime(2026);
    await db.into(db.connections).insert(ConnectionsCompanion.insert(
        id: 'c1',
        name: 'h',
        host: 'h',
        port: 1883,
        protocol: MqttProtocol.tcp,
        createdAt: now,
        updatedAt: now));
    dash = await DashboardRepo(DashboardDao(db)).create(
        connectionId: 'c1', name: 'Home', colorSeed: 0, iconCodepoint: 0);
    final sections = SectionRepo(SectionDao(db));
    lights = await sections.create(dashboardId: dash, name: 'Lights');
    sensors =
        await sections.create(dashboardId: dash, name: 'Sensors', sortOrder: 1);
    var i = 0;
    for (final (name, section) in [
      ('a', lights),
      ('b', lights),
      ('c', sensors),
      ('d', sensors),
    ]) {
      ids[name] = await panels.create(
        dashboardId: dash,
        name: name,
        type: PanelType.toggle,
        topic: name,
        sortOrder: i++,
        sectionId: section,
        config: PanelConfig.defaultFor(PanelType.toggle),
      );
    }
  });
  tearDown(() => db.close());

  test('a drop before a tile in another section moves it there', () async {
    await panels.moveTile(dash, ids['a']!,
        sectionId: sensors, beforeId: ids['d']);
    expect(await order(), [('b', 'L'), ('c', 'S'), ('a', 'S'), ('d', 'S')]);
  });

  test('a drop on a section header puts the tile last in that section',
      () async {
    await panels.moveTile(dash, ids['d']!, sectionId: lights);
    expect(await order(), [('a', 'L'), ('b', 'L'), ('d', 'L'), ('c', 'S')]);
  });

  test('move earlier and later stay within the section', () async {
    await panels.moveWithinSection(dash, ids['b']!, -1);
    expect(await order(), [('b', 'L'), ('a', 'L'), ('c', 'S'), ('d', 'S')]);
    await panels.moveWithinSection(dash, ids['a']!, 1);
    expect(await order(), [('b', 'L'), ('a', 'L'), ('c', 'S'), ('d', 'S')],
        reason: 'already last in Lights');
  });

  test('undo restores a removed tile exactly', () async {
    final before = (await panels.getById(ids['c']!))!;
    await panels.delete(ids['c']!);
    await panels.restore(before);
    expect(await panels.getById(ids['c']!), before);
  });
}
