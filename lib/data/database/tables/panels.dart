import 'package:drift/drift.dart';

import 'dashboards.dart';

enum PanelType {
  button,
  toggle,
  slider,
  led,
  nodeStatus,
  progress,
  multiState,
  combo,
  radio,
  cover,
  textInput,
  textLog,
  schedule,
  scene,
  autoClose,
}

enum PanelWidth { full, half, third }

class Panels extends Table {
  TextColumn get id => text()();
  TextColumn get dashboardId =>
      text().references(Dashboards, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get type => textEnum<PanelType>()();
  TextColumn get topic => text()();
  TextColumn get subscribeTopic => text().nullable()();
  TextColumn get topicPrefixOverride => text().nullable()();
  IntColumn get qos => integer().withDefault(const Constant(1))();
  BoolColumn get retain => boolean().withDefault(const Constant(false))();
  TextColumn get width => textEnum<PanelWidth>()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get config => text()();
  IntColumn get mergeFlags => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
