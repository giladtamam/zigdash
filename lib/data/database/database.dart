import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/connections.dart';
import 'tables/dashboards.dart';
import 'tables/device_dismissals.dart';
import 'tables/device_health_flags.dart';
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
  DeviceHealthFlags,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 7;

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
            await m.addColumn(connections, connections.devicesSeenAt);
            await m.createIndex(panelsDeviceIeee);
            // 1.11 setup stored the device's full topic as both prefix and
            // topic, so its tiles used '<device>/<device>'. Rewrite them to
            // the suffixes setup meant: 'set' for controls, '' to read.
            await customStatement(
              "UPDATE panels SET subscribe_topic = '' "
              'WHERE subscribe_topic = topic_prefix_override',
            );
            await customStatement(
              'UPDATE panels SET topic = CASE WHEN type IN '
              "('toggle', 'slider', 'cover') THEN 'set' ELSE '' END "
              'WHERE topic = topic_prefix_override',
            );
            // 1.11 setup and the demo stored 0xe88a, the web font's home,
            // which in Flutter's font is a "?" bubble (never pickable).
            await customStatement(
              'UPDATE dashboards SET icon_codepoint = 58136 '
              'WHERE icon_codepoint = 59530',
            );
            // Before 1.12 foreign keys were off, so deletes never cascaded
            // and left rows behind. Drop them before enforcement starts.
            await customStatement(
              'DELETE FROM dashboards WHERE connection_id NOT IN '
              '(SELECT id FROM connections)',
            );
            await customStatement(
              'DELETE FROM panels WHERE dashboard_id NOT IN '
              '(SELECT id FROM dashboards)',
            );
            await customStatement(
              'DELETE FROM scenes WHERE connection_id NOT IN '
              '(SELECT id FROM connections)',
            );
          }
          if (from < 7) {
            await m.addColumn(connections, connections.z2mBaseTopic);
            await m.createTable(deviceHealthFlags);
          }
        },
        // The schema's cascades (home → dashboards → sections, tiles) only
        // run with enforcement on; SQLite leaves it off per connection.
        beforeOpen: (_) async {
          await customStatement('PRAGMA foreign_keys = ON');
          // The "?" bubble repair also runs on every open: 1.12 previews
          // reached schema 6 before the migration had it. Idempotent, and
          // 0xe88a was never pickable, so no user choice is overwritten.
          await customStatement(
            'UPDATE dashboards SET icon_codepoint = 58136 '
            'WHERE icon_codepoint = 59530',
          );
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
