import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/connections.dart';
import 'tables/dashboards.dart';
import 'tables/panels.dart';
import 'tables/scenes.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Connections, Dashboards, Panels, Scenes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 5;

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
          if (from < 5) {
            await m.createTable(scenes);
          }
        },
        beforeOpen: (_) => repairSetupTopics(),
      );

  /// 1.11.0 setup stored the device's full topic as both prefix and topic,
  /// so its tiles used `<device>/<device>`. Rewrites them to the suffixes
  /// setup meant ('set' for controls, '' to read). Idempotent: repaired rows
  /// no longer match.
  Future<void> repairSetupTopics() async {
    await customStatement(
      "UPDATE panels SET subscribe_topic = '' "
      'WHERE subscribe_topic = topic_prefix_override',
    );
    await customStatement(
      'UPDATE panels SET topic = CASE WHEN type IN '
      "('toggle', 'slider', 'cover') THEN 'set' ELSE '' END "
      'WHERE topic = topic_prefix_override',
    );
  }

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
