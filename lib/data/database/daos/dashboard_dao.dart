import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/dashboards.dart';

part 'dashboard_dao.g.dart';

@DriftAccessor(tables: [Dashboards])
class DashboardDao extends DatabaseAccessor<AppDatabase> with _$DashboardDaoMixin {
  DashboardDao(super.db);

  Stream<List<Dashboard>> watchByConnection(String connectionId) {
    return (select(dashboards)
          ..where((d) => d.connectionId.equals(connectionId))
          ..orderBy([(d) => OrderingTerm(expression: d.sortOrder), (d) => OrderingTerm(expression: d.name)]))
        .watch();
  }

  Future<Dashboard?> getById(String id) =>
      (select(dashboards)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(DashboardsCompanion entry) =>
      into(dashboards).insert(entry);

  Future<int> updateById(String id, DashboardsCompanion patch) =>
      (update(dashboards)..where((d) => d.id.equals(id))).write(patch);

  Future<int> deleteById(String id) =>
      (delete(dashboards)..where((d) => d.id.equals(id))).go();
}
