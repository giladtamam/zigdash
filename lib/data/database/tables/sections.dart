import 'package:drift/drift.dart';

import 'dashboards.dart';

/// A titled group of tiles inside a dashboard.
class Sections extends Table {
  TextColumn get id => text()();
  TextColumn get dashboardId =>
      text().references(Dashboards, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
