import '../data/database/tables/connections.dart';

/// Plain-Dart broker config consumed by [MqttManager]. Decoupled from Drift
/// so the manager (and the smoke harness in bin/) does not transitively pull
/// in dart:ui via drift_flutter.
class BrokerConfig {
  const BrokerConfig({
    required this.id,
    required this.host,
    required this.port,
    required this.protocol,
    this.username,
    this.keepAliveSeconds = 60,
  });

  final String id;
  final String host;
  final int port;
  final MqttProtocol protocol;
  final String? username;
  final int keepAliveSeconds;
}
