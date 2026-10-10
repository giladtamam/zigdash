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

  /// Inserts, or replaces the row for the same widget or tile slot
  /// (reconfiguring a widget keeps its launcher id).
  Future<void> put(ShortcutsCompanion row) =>
      into(shortcuts).insertOnConflictUpdate(row);

  Future<int> deleteByWidget(int appWidgetId) =>
      (delete(shortcuts)..where((s) => s.appWidgetId.equals(appWidgetId))).go();

  Future<int> deleteByTileSlot(int slot) =>
      (delete(shortcuts)..where((s) => s.tileSlot.equals(slot))).go();
}

/// A shortcut's targets, decoded.
List<String> shortcutTargets(Shortcut s) =>
    (jsonDecode(s.targets) as List).cast<String>();

String encodeShortcutTargets(List<String> targets) => jsonEncode(targets);
