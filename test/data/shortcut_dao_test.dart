import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/shortcut_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/shortcuts.dart';

void main() {
  late AppDatabase db;
  late ShortcutDao dao;
  final t = DateTime(2026, 10, 10);

  setUp(() async {
    db = AppDatabase.test(NativeDatabase.memory());
    dao = ShortcutDao(db);
    await db.into(db.connections).insert(ConnectionsCompanion.insert(
          id: 'home',
          name: 'Home',
          host: '192.168.1.20',
          port: 1883,
          protocol: MqttProtocol.tcp,
          createdAt: t,
          updatedAt: t,
        ));
  });
  tearDown(() => db.close());

  ShortcutsCompanion row(String id,
          {int? widget, int? slot, List<String> targets = const ['0x1']}) =>
      ShortcutsCompanion.insert(
        id: id,
        connectionId: 'home',
        kind: ShortcutKind.device,
        surface: widget != null ? ShortcutSurface.widget : ShortcutSurface.tile,
        targets: encodeShortcutTargets(targets),
        appWidgetId: Value(widget),
        tileSlot: Value(slot),
        createdAt: t,
      );

  test('finds a widget by launcher id and a tile by slot', () async {
    await dao.put(row('a', widget: 41));
    await dao.put(row('b', slot: 2, targets: ['0x2']));
    expect((await dao.getByWidget(41))!.id, 'a');
    expect(shortcutTargets((await dao.getByTileSlot(2))!), ['0x2']);
    expect(await dao.usedTileSlots(), {2});
    expect(await dao.getByWidget(99), isNull);
  });

  test('reconfiguring replaces the row', () async {
    await dao.put(row('a', widget: 41));
    await dao.put(row('a', widget: 41, targets: ['0x9']));
    expect(shortcutTargets((await dao.getByWidget(41))!), ['0x9']);
    expect(await db.select(db.shortcuts).get(), hasLength(1));
  });

  test('a widget id or tile slot is used once', () async {
    await dao.put(row('a', widget: 41));
    expect(() => db.into(db.shortcuts).insert(row('b', widget: 41)),
        throwsA(anything));
  });

  test('deleting a home deletes its shortcuts', () async {
    await db.customStatement('PRAGMA foreign_keys = ON');
    await dao.put(row('a', widget: 41));
    await (db.delete(db.connections)..where((c) => c.id.equals('home'))).go();
    expect(await db.select(db.shortcuts).get(), isEmpty);
  });

  test('removing a widget or a tile', () async {
    await dao.put(row('a', widget: 41));
    await dao.put(row('b', slot: 1));
    await dao.deleteByWidget(41);
    await dao.deleteByTileSlot(1);
    expect(await db.select(db.shortcuts).get(), isEmpty);
  });
}
