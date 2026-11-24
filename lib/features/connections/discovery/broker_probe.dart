import 'package:mqtt_client/mqtt_client.dart';

/// A broker found by the scan: where it lives and whether the MQTT handshake
/// indicated that credentials are required.
class ProbeResult {
  const ProbeResult({
    required this.host,
    required this.port,
    this.needsAuth = false,
    this.untrustedCert = false,
  });

  final String host;
  final int port;
  final bool needsAuth;

  /// The broker's TLS certificate isn't one the phone trusts (3.8.5). The
  /// scan accepts it only to see that a broker is there; the app itself
  /// never does, so a login can't help.
  final bool untrustedCert;

  String get key => '$host:$port';

  @override
  bool operator ==(Object other) =>
      other is ProbeResult && other.host == host && other.port == port;

  @override
  int get hashCode => Object.hash(host, port);

  @override
  String toString() =>
      'ProbeResult($host:$port, needsAuth=$needsAuth'
      '${untrustedCert ? ', untrustedCert' : ''})';
}

/// One probe's full outcome: the broker, if the port spoke MQTT, and whether
/// the host answered at all. [alive] is true when the TCP connect succeeded
/// or was refused (something is there), false when it timed out, and null
/// when the prober cannot tell.
typedef HostProbe = ({ProbeResult? broker, bool? alive});

/// Probes a single host:port; returns a [ProbeResult] when it's an MQTT broker,
/// or null otherwise. Implementations must never throw.
abstract class HostProber {
  Future<ProbeResult?> probe(String host, int port);

  /// [probe], also saying whether the host was alive (2.6.2, for the empty
  /// scan's diagnostics). Probers that cannot tell leave [HostProbe.alive]
  /// null.
  Future<HostProbe> probeHost(String host, int port) async =>
      (broker: await probe(host, port), alive: null);
}

/// Maps an MQTT CONNACK return code to whether the broker requires auth.
/// A refusal for bad/missing credentials means "needs login"; anything else
/// (accepted, or an unrelated refusal) is treated as not requiring auth.
bool mqttConnackToAuth(MqttConnectReturnCode code) =>
    code == MqttConnectReturnCode.notAuthorized ||
    code == MqttConnectReturnCode.badUsernameOrPassword;
