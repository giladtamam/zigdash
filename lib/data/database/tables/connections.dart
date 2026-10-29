import 'package:drift/drift.dart';

enum MqttProtocol { tcp, tcpSsl, ws, wss }

/// How a home is reached (2.10). [mqtt] talks to the broker; [homeAssistant]
/// goes through Home Assistant's WebSocket API with a stored sign-in, for
/// phones that cannot reach the broker (docs/design/ha-route.md). For a
/// Home Assistant home, `host` is the Home Assistant address the user
/// typed, `remoteHost` an optional second one.
/// [z2mPage] (3.2 spike): through Zigbee2MQTT's own web page, its frontend
/// WebSocket, with no broker; the password slot holds the page's token.
enum ConnectionTransport { mqtt, homeAssistant, z2mPage }

/// The transport of a stored connection, MQTT when unset.
ConnectionTransport transportOf(ConnectionTransport? stored) =>
    stored ?? ConnectionTransport.mqtt;

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

  /// See [ConnectionTransport]; null (homes made before 2.10, and backup
  /// files read at their own schema version) means MQTT: [transportOf].
  TextColumn get transport => textEnum<ConnectionTransport>().nullable()();

  /// When the home's existing devices were recorded as seen (first connect
  /// after 1.12 setup or upgrade). Null until then; only devices paired
  /// later count as new.
  DateTimeColumn get devicesSeenAt => dateTime().nullable()();

  /// The Zigbee2MQTT base topic set for this home (Settings › home, or the
  /// setup retry). Null keeps the pre-1.13 derivation from a dashboard's
  /// topic prefix; see `homeBaseTopic`.
  TextColumn get z2mBaseTopic => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
