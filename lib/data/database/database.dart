import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/connections.dart';
import 'tables/dashboards.dart';
import 'tables/device_dismissals.dart';
import 'tables/panels.dart';
import 'tables/scenes.dart';
import 'tables/sections.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Connections,
  Dashboards,
  Panels,
  Scenes,
  Sections,
  DeviceDismissals,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 6;

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
          if (from < 6) {
            // First, while every stored width still decodes: 1.12 renamed
            // half and third to small (Small / Wide / Full tile sizes).
            await customStatement(
              "UPDATE panels SET width = 'small' "
              "WHERE width IN ('half', 'third')",
            );
            await m.createTable(sections);
            await m.createTable(deviceDismissals);
            await m.addColumn(panels, panels.sectionId);
            await m.addColumn(panels, panels.deviceIeee);
            await m.createIndex(panelsDeviceIeee);
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
