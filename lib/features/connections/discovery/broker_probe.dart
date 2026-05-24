import 'package:mqtt_client/mqtt_client.dart';

/// A broker found by the scan: where it lives and whether the MQTT handshake
/// indicated that credentials are required.
class ProbeResult {
  const ProbeResult({
    required this.host,
    required this.port,
    this.needsAuth = false,
  });

  final String host;
  final int port;
  final bool needsAuth;

  String get key => '$host:$port';

  @override
  bool operator ==(Object other) =>
      other is ProbeResult && other.host == host && other.port == port;

  @override
  int get hashCode => Object.hash(host, port);

  @override
  String toString() => 'ProbeResult($host:$port, needsAuth=$needsAuth)';
}

/// Probes a single host:port; returns a [ProbeResult] when it's an MQTT broker,
/// or null otherwise. Implementations must never throw.
abstract class HostProber {
  Future<ProbeResult?> probe(String host, int port);
}

/// Maps an MQTT CONNACK return code to whether the broker requires auth.
/// A refusal for bad/missing credentials means "needs login"; anything else
/// (accepted, or an unrelated refusal) is treated as not requiring auth.
bool mqttConnackToAuth(MqttConnectReturnCode code) =>
    code == MqttConnectReturnCode.notAuthorized ||
    code == MqttConnectReturnCode.badUsernameOrPassword;
