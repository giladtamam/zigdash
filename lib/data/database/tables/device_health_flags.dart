import 'package:drift/drift.dart';

import 'connections.dart';

/// Per-device battery observations of this install, for the Devices dot.
/// Phone only and never backed up: they describe what this phone saw.
///
/// [batteryLow] is the last computed low state; [acknowledged] is false
/// only after a battery went low while the app watched, until the device
/// page is opened.
@DataClassName('DeviceHealthFlag')
class DeviceHealthFlags extends Table {
  TextColumn get connectionId =>
      text().references(Connections, #id, onDelete: KeyAction.cascade)();
  TextColumn get ieee => text()();
  BoolColumn get batteryLow => boolean()();
  BoolColumn get acknowledged => boolean()();
  DateTimeColumn get changedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {connectionId, ieee};
}
