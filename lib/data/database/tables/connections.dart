import 'package:drift/drift.dart';

enum MqttProtocol { tcp, tcpSsl, ws, wss }

class Connections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get host => text()();
  IntColumn get port => integer()();
  TextColumn get protocol => textEnum<MqttProtocol>()();
  TextColumn get username => text().nullable()();
  IntColumn get keepAliveSeconds => integer().withDefault(const Constant(60))();
  BoolColumn get autoConnect => boolean().withDefault(const Constant(false))();
  TextColumn get homeDashboardId => text().nullable()();
  TextColumn get remoteHost => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
