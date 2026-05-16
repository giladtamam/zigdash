import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/panels.dart';

part 'panel_dao.g.dart';

@DriftAccessor(tables: [Panels])
class PanelDao extends DatabaseAccessor<AppDatabase> with _$PanelDaoMixin {
  PanelDao(super.db);

  Stream<List<Panel>> watchByDashboard(String dashboardId) {
    return (select(panels)
          ..where((p) => p.dashboardId.equals(dashboardId))
          ..orderBy([
            (p) => OrderingTerm(expression: p.sortOrder),
            (p) => OrderingTerm(expression: p.name),
          ]))
        .watch();
  }

  Future<Panel?> getById(String id) =>
      (select(panels)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(PanelsCompanion entry) => into(panels).insert(entry);

  Future<int> updateById(String id, PanelsCompanion patch) =>
      (update(panels)..where((p) => p.id.equals(id))).write(patch);

  Future<int> deleteById(String id) =>
      (delete(panels)..where((p) => p.id.equals(id))).go();
}
