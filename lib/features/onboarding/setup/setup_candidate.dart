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
    this.untrustedCert = false,
    this.transport = ConnectionTransport.mqtt,
  });

  factory SetupCandidate.fromProbe(ProbeResult probe) => SetupCandidate(
    host: probe.host,
    port: probe.port,
    protocol: probe.port == 8883 ? MqttProtocol.tcpSsl : MqttProtocol.tcp,
    needsAuth: probe.needsAuth,
    untrustedCert: probe.untrustedCert,
  );

  SetupCandidate copyWith({bool? needsAuth, bool? untrustedCert}) =>
      SetupCandidate(
        host: host,
        port: port,
        protocol: protocol,
        needsAuth: needsAuth ?? this.needsAuth,
        untrustedCert: untrustedCert ?? this.untrustedCert,
        transport: transport,
      );

  final String host;
  final int port;
  final MqttProtocol protocol;

  /// The MQTT handshake indicated anonymous access is refused — the flow will
  /// ask for credentials after selection rather than discovering it late.
  final bool needsAuth;

  /// The scan saw a TLS certificate the phone doesn't trust (3.8.5): the
  /// app can't connect to it, with or without a login.
  final bool untrustedCert;

  /// How this candidate is reached (2.10). Through Home Assistant, [host]
  /// is the Home Assistant address and the password slot holds the sign-in.
  final ConnectionTransport transport;

  bool get viaHomeAssistant => transport == ConnectionTransport.homeAssistant;
  bool get viaZ2mPage => transport == ConnectionTransport.z2mPage;
  bool get notBroker => viaHomeAssistant || viaZ2mPage;

  String get identity => '$host:$port:${protocol.name}:${transport.name}';

  @override
  bool operator ==(Object other) =>
      other is SetupCandidate &&
      other.host == host &&
      other.port == port &&
      other.protocol == protocol &&
      other.transport == transport;

  @override
  int get hashCode => Object.hash(host, port, protocol, transport);

  @override
  String toString() => 'SetupCandidate($identity)';
}

/// Merges raw probe results into distinct candidates, first-seen order.
/// A later probe for the same identity can only upgrade [needsAuth] (a
/// CONNACK refusal observed on a repeat probe) or [untrustedCert] — never
/// downgrade them.
List<SetupCandidate> mergeCandidates(Iterable<ProbeResult> probes) {
  final byIdentity = <String, SetupCandidate>{};
  for (final probe in probes) {
    final c = SetupCandidate.fromProbe(probe);
    final existing = byIdentity[c.identity];
    if (existing == null) {
      byIdentity[c.identity] = c;
    } else if ((c.needsAuth && !existing.needsAuth) ||
        (c.untrustedCert && !existing.untrustedCert)) {
      byIdentity[c.identity] = existing.copyWith(
        needsAuth: existing.needsAuth || c.needsAuth,
        untrustedCert: existing.untrustedCert || c.untrustedCert,
      );
    }
  }
  return byIdentity.values.toList();
}

/// Drops a broker on 8883 whose certificate the phone doesn't trust when
/// the same machine also answers on 1883 (3.8.5): the app can use only
/// that one.
List<SetupCandidate> preferUsable(List<SetupCandidate> candidates) => [
  for (final c in candidates)
    if (!(c.untrustedCert &&
        c.port == 8883 &&
        candidates.any((o) => o.host == c.host && o.port == 1883)))
      c,
];
