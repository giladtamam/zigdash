import 'package:drift/drift.dart';

import 'connections.dart';

/// A Home's alerts (CONTEXT.md: Alert), as the JSON the hub's flow reads
/// (docs/design/alerts-2.3.md, "The config contract"). One row per Home:
/// the alerts, the push keys, every phone that gets notifications, and the
/// optional ntfy/Pushover settings. The broker holds the same JSON retained;
/// the row is this phone's copy of it.
class AlertConfigs extends Table {
  TextColumn get connectionId =>
      text().references(Connections, #id, onDelete: KeyAction.cascade)();
  TextColumn get config => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {connectionId};
}
