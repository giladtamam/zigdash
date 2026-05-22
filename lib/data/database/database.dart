import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/connections.dart';
import 'tables/dashboards.dart';
import 'tables/panels.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Connections, Dashboards, Panels])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(dashboards);
            await m.createTable(panels);
          }
          if (from < 3) {
            await m.addColumn(panels, panels.topicPrefixOverride);
          }
          if (from < 4) {
            await m.addColumn(connections, connections.remoteHost);
          }
        },
      );

  static QueryExecutor _open() => driftDatabase(
        name: 'zigdash',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
