import '../data/database/tables/connections.dart';
import '../remote/remote_home.dart';

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
    this.remoteHost,
    this.transport = ConnectionTransport.mqtt,
    this.relay,
  });

  final String id;
  final String host;
  final int port;
  final MqttProtocol protocol;
  final String? username;
  final int keepAliveSeconds;

  /// Optional fallback address (e.g. a Tailscale MagicDNS name) tried after
  /// [host] is unreachable. Reuses [port], [protocol], and credentials.
  final String? remoteHost;

  /// How to reach the home. For [ConnectionTransport.homeAssistant], [host]
  /// (and [remoteHost]) are Home Assistant addresses and the password slot
  /// carries the sign-in (see `HaMqttClient`).
  final ConnectionTransport transport;

  bool get viaHomeAssistant => transport == ConnectionTransport.homeAssistant;

  /// Through Zigbee2MQTT's web page, no broker (3.2 spike).
  bool get viaZ2mPage => transport == ConnectionTransport.z2mPage;

  /// Not an MQTT broker: no broker ladder, no relay.
  bool get notBroker => viaHomeAssistant || viaZ2mPage;

  /// This phone's login to the ZigDash relay for the Home (3.1), tried after
  /// the broker's own addresses fail.
  final RemoteHome? relay;
}
