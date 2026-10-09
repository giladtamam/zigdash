import 'package:drift/drift.dart';

import 'dashboards.dart';
import 'sections.dart';

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

  /// A whole Zigbee2MQTT device of a known class (1.12). Config:
  /// DeviceTileConfig; the device is `deviceIeee`.
  device,

  /// One numeric value with its unit (1.12). Config: ReadingConfig.
  reading,
}

/// A tile's size on the dashboard grid: **Small** spans one column, **Wide**
/// two, **Full** the whole row. Schema 6 renamed 1.11's `half` and `third`
/// to [small]; see [PanelWidthLegacy.parse] for older names in backups.
enum PanelWidth { small, wide, full }

extension PanelWidthLegacy on PanelWidth {
  /// Parses a stored width name, mapping the pre-1.12 names `half` and
  /// `third` to [PanelWidth.small]. Unknown names fall back to small.
  static PanelWidth parse(String? name) => switch (name) {
        'full' => PanelWidth.full,
        'wide' => PanelWidth.wide,
        _ => PanelWidth.small,
      };
}

@TableIndex(name: 'panels_device_ieee', columns: {#deviceIeee})
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

  /// The section this tile sits in; null renders it first, without a header.
  TextColumn get sectionId => text()
      .nullable()
      .references(Sections, #id, onDelete: KeyAction.setNull)();

  /// IEEE address of the device this tile shows, if any. Decides whether a
  /// device is on a dashboard.
  TextColumn get deviceIeee => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
