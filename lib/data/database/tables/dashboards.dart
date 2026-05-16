import 'package:drift/drift.dart';

import 'connections.dart';

class Dashboards extends Table {
  TextColumn get id => text()();
  TextColumn get connectionId =>
      text().references(Connections, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get topicPrefix => text().nullable()();
  IntColumn get colorSeed => integer()();
  IntColumn get iconCodepoint => integer()();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
