import '../../../data/database/tables/connections.dart';
import '../../connections/discovery/broker_probe.dart';

/// A network candidate for the discovery-first setup: a verified-reachable
/// MQTT endpoint. Identity is host + port + protocol — duplicate scan results
/// merge on that identity.
class SetupCandidate {
  const SetupCandidate({
    required this.host,
    required this.port,
    required this.protocol,
    this.needsAuth = false,
  });

  factory SetupCandidate.fromProbe(ProbeResult probe) => SetupCandidate(
        host: probe.host,
        port: probe.port,
        protocol: probe.port == 8883 ? MqttProtocol.tcpSsl : MqttProtocol.tcp,
        needsAuth: probe.needsAuth,
      );

  final String host;
  final int port;
  final MqttProtocol protocol;

  /// The MQTT handshake indicated anonymous access is refused — the flow will
  /// ask for credentials after selection rather than discovering it late.
  final bool needsAuth;

  String get identity => '$host:$port:${protocol.name}';

  @override
  bool operator ==(Object other) =>
      other is SetupCandidate &&
      other.host == host &&
      other.port == port &&
      other.protocol == protocol;

  @override
  int get hashCode => Object.hash(host, port, protocol);

  @override
  String toString() => 'SetupCandidate($identity)';
}

/// Merges raw probe results into distinct candidates, first-seen order.
/// A later probe for the same identity can only upgrade [needsAuth] (a
/// CONNACK refusal observed on a repeat probe) — never downgrade it.
List<SetupCandidate> mergeCandidates(Iterable<ProbeResult> probes) {
  final byIdentity = <String, SetupCandidate>{};
  for (final probe in probes) {
    final c = SetupCandidate.fromProbe(probe);
    final existing = byIdentity[c.identity];
    if (existing == null) {
      byIdentity[c.identity] = c;
    } else if (c.needsAuth && !existing.needsAuth) {
      byIdentity[c.identity] = SetupCandidate(
        host: existing.host,
        port: existing.port,
        protocol: existing.protocol,
        needsAuth: true,
      );
    }
  }
  return byIdentity.values.toList();
}
