import 'package:drift/drift.dart';

import 'connections.dart';

/// A named bundle of device actions, scoped to a connection. [actions] holds a
/// JSON array of `{setTopic, payload}` objects (see `Scene.encodeActions`).
class Scenes extends Table {
  TextColumn get id => text()();
  TextColumn get connectionId =>
      text().references(Connections, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  IntColumn get iconCodepoint => integer()();
  IntColumn get colorSeed => integer()();
  TextColumn get actions => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
