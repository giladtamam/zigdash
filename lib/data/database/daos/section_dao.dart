import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/panels.dart';
import '../tables/sections.dart';

part 'section_dao.g.dart';

@DriftAccessor(tables: [Sections, Panels])
class SectionDao extends DatabaseAccessor<AppDatabase> with _$SectionDaoMixin {
  SectionDao(super.db);

  Stream<List<Section>> watchByDashboard(String dashboardId) {
    return (select(sections)
          ..where((s) => s.dashboardId.equals(dashboardId))
          ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
        .watch();
  }

  Future<List<Section>> getByDashboard(String dashboardId) {
    return (select(sections)
          ..where((s) => s.dashboardId.equals(dashboardId))
          ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
        .get();
  }

  Future<void> insertRow(SectionsCompanion entry) =>
      into(sections).insert(entry);

  Future<int> updateById(String id, SectionsCompanion patch) =>
      (update(sections)..where((s) => s.id.equals(id))).write(patch);

  /// Deletes a section. Its tiles are deleted with it when [deleteTiles],
  /// otherwise they move to "no section". Done here rather than by the
  /// foreign key, which SQLite enforces only with `PRAGMA foreign_keys`.
  Future<void> deleteById(String id, {required bool deleteTiles}) {
    return transaction(() async {
      if (deleteTiles) {
        await (delete(panels)..where((p) => p.sectionId.equals(id))).go();
      } else {
        await (update(panels)..where((p) => p.sectionId.equals(id))).write(
          const PanelsCompanion(sectionId: Value(null)),
        );
      }
      await (delete(sections)..where((s) => s.id.equals(id))).go();
    });
  }
}
