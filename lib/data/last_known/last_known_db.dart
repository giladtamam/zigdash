import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'last_known_db.g.dart';

/// The last payload of each subscribed topic, per home, so a dashboard is
/// never empty when the broker is unreachable (docs/adr/0004).
class LastKnownValues extends Table {
  TextColumn get connectionId => text()();
  TextColumn get topic => text()();
  TextColumn get payload => text()();
  DateTimeColumn get receivedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {connectionId, topic};
}

/// A separate SQLite file (`last_known`), not the main database: it takes
/// frequent writes, is excluded from Android backup and device transfer,
/// and never goes into a ZigDash backup.
@DriftDatabase(tables: [LastKnownValues])
class LastKnownDb extends _$LastKnownDb {
  LastKnownDb()
      : super(driftDatabase(
          name: 'last_known',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));
  LastKnownDb.test(super.executor);

  @override
  int get schemaVersion => 1;
}
