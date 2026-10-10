import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/shortcuts.dart';

part 'shortcut_dao.g.dart';

@DriftAccessor(tables: [Shortcuts])
class ShortcutDao extends DatabaseAccessor<AppDatabase>
    with _$ShortcutDaoMixin {
  ShortcutDao(super.db);

  Stream<List<Shortcut>> watchAll() =>
      (select(shortcuts)..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
          .watch();

  Future<Shortcut?> getByWidget(int appWidgetId) =>
      (select(shortcuts)..where((s) => s.appWidgetId.equals(appWidgetId)))
          .getSingleOrNull();

  Future<Shortcut?> getByTileSlot(int slot) =>
      (select(shortcuts)..where((s) => s.tileSlot.equals(slot)))
          .getSingleOrNull();

  Future<List<Shortcut>> getByConnection(String connectionId) =>
      (select(shortcuts)..where((s) => s.connectionId.equals(connectionId)))
          .get();

  /// Tile slots already assigned.
  Future<Set<int>> usedTileSlots() async => {
        for (final s in await (select(shortcuts)
              ..where((s) => s.tileSlot.isNotNull()))
            .get())
          s.tileSlot!,
      };

  /// Inserts, replacing any row with the same id, widget or tile slot
  /// (reconfiguring a widget keeps its launcher id; reassigning a slot keeps
  /// the slot).
  Future<void> put(ShortcutsCompanion row) => transaction(() async {
        final widget = row.appWidgetId.present ? row.appWidgetId.value : null;
        final slot = row.tileSlot.present ? row.tileSlot.value : null;
        await (delete(shortcuts)
              ..where((s) =>
                  s.id.equals(row.id.value) |
                  (widget == null
                      ? const Constant(false)
                      : s.appWidgetId.equals(widget)) |
                  (slot == null
                      ? const Constant(false)
                      : s.tileSlot.equals(slot))))
            .go();
        await into(shortcuts).insert(row);
      });

  Future<int> deleteByWidget(int appWidgetId) =>
      (delete(shortcuts)..where((s) => s.appWidgetId.equals(appWidgetId))).go();

  Future<int> deleteByTileSlot(int slot) =>
      (delete(shortcuts)..where((s) => s.tileSlot.equals(slot))).go();
}

/// A shortcut's targets, decoded.
List<String> shortcutTargets(Shortcut s) =>
    (jsonDecode(s.targets) as List).cast<String>();

String encodeShortcutTargets(List<String> targets) => jsonEncode(targets);
