import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/connections.dart';

part 'connection_dao.g.dart';

@DriftAccessor(tables: [Connections])
class ConnectionDao extends DatabaseAccessor<AppDatabase> with _$ConnectionDaoMixin {
  ConnectionDao(super.db);

  Stream<List<Connection>> watchAll() =>
      (select(connections)..orderBy([(c) => OrderingTerm(expression: c.name)])).watch();

  Future<Connection?> getById(String id) =>
      (select(connections)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<void> upsert(ConnectionsCompanion entry) =>
      into(connections).insertOnConflictUpdate(entry);

  Future<int> deleteById(String id) =>
      (delete(connections)..where((c) => c.id.equals(id))).go();
}
