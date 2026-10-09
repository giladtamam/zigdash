import 'package:drift/drift.dart';

import 'connections.dart';

/// A device the user chose not to be reminded about: it no longer counts
/// toward the new-device dot or the unassigned-devices card. Local only.
class DeviceDismissals extends Table {
  TextColumn get connectionId =>
      text().references(Connections, #id, onDelete: KeyAction.cascade)();
  TextColumn get ieee => text()();
  DateTimeColumn get dismissedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {connectionId, ieee};
}
