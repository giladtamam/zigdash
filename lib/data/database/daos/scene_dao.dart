import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/scenes.dart';

part 'scene_dao.g.dart';

@DriftAccessor(tables: [Scenes])
class SceneDao extends DatabaseAccessor<AppDatabase> with _$SceneDaoMixin {
  SceneDao(super.db);

  Stream<List<Scene>> watchByConnection(String connectionId) {
    return (select(scenes)
          ..where((s) => s.connectionId.equals(connectionId))
          ..orderBy([
            (s) => OrderingTerm(expression: s.sortOrder),
            (s) => OrderingTerm(expression: s.name),
          ]))
        .watch();
  }

  /// A home's scenes, in display order, read once (for backups).
  Future<List<Scene>> getByConnection(String connectionId) {
    return (select(scenes)
          ..where((s) => s.connectionId.equals(connectionId))
          ..orderBy([
            (s) => OrderingTerm(expression: s.sortOrder),
            (s) => OrderingTerm(expression: s.name),
          ]))
        .get();
  }

  Future<Scene?> getById(String id) =>
      (select(scenes)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(ScenesCompanion entry) => into(scenes).insert(entry);

  Future<int> updateById(String id, ScenesCompanion patch) =>
      (update(scenes)..where((s) => s.id.equals(id))).write(patch);

  Future<int> deleteById(String id) =>
      (delete(scenes)..where((s) => s.id.equals(id))).go();
}
