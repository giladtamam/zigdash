import 'broker_probe.dart';

/// Something on the network that runs or hosts Zigbee2MQTT, found by its
/// web page while the broker scan came up empty (2.5): the empty result can
/// then say what was found and what is missing instead of "nothing".
enum HubKind {
  /// Home Assistant's web UI (port 8123).
  homeAssistant,

  /// The Zigbee2MQTT frontend (port 8080).
  zigbee2mqtt,

  /// An SMLIGHT hub's web UI (port 80, or 3000 on early SMHUBs; probed
  /// only when the user said so).
  smlight,
}

/// The web port each hub kind answers on, and the words that identify it.
const hubPorts = {
  HubKind.homeAssistant: 8123,
  HubKind.zigbee2mqtt: 8080,
  HubKind.smlight: 80,
};

/// Other web ports a hub kind may answer on (3.2.7): early SMHUB firmware
/// served its web UI on 3000.
const hubExtraPorts = {
  HubKind.smlight: [3000],
};

/// Every web port [kind] may answer on, the usual one first.
List<int> hubPortsOf(HubKind kind) => [
  hubPorts[kind]!,
  ...?hubExtraPorts[kind],
];

/// The hub kind a web page belongs to, from its text, or null when it is
/// none we know. Case-insensitive; the page can be any size.
HubKind? hubKindOfPage(String body) {
  final b = body.toLowerCase();
  if (b.contains('home assistant') || b.contains('homeassistant')) {
    return HubKind.homeAssistant;
  }
  if (b.contains('zigbee2mqtt')) return HubKind.zigbee2mqtt;
  if (b.contains('slzb') || b.contains('smlight') || b.contains('smhub')) {
    return HubKind.smlight;
  }
  return null;
}

/// A hub found by the scan.
class HubFound {
  const HubFound({required this.kind, required this.host, required this.port});
  final HubKind kind;
  final String host;
  final int port;

  String get key => '$host:$port';

  @override
  bool operator ==(Object other) =>
      other is HubFound &&
      other.kind == kind &&
      other.host == host &&
      other.port == port;

  @override
  int get hashCode => Object.hash(kind, host, port);

  @override
  String toString() => 'HubFound(${kind.name} at $key)';
}

/// Identifies a hub by its web page on `host:port`; null when nothing
/// answers or the page is not one we know. Implementations never throw.
abstract class HubProber {
  Future<HubKind?> probe(String host, int port);
}

/// What one machine is, from its web pages (2.7.1): every hub port probed at
/// once; Home Assistant wins over an SMLIGHT hub, which wins over a bare
/// Zigbee2MQTT frontend (an SMHUB serves that too, on 8080). Null when no
/// page is one we know.
Future<HubKind?> identifyHost(HubProber prober, String host) async {
  final kinds = await Future.wait([
    for (final kind in HubKind.values)
      for (final port in hubPortsOf(kind)) prober.probe(host, port),
  ]);
  for (final kind in const [
    HubKind.homeAssistant,
    HubKind.smlight,
    HubKind.zigbee2mqtt,
  ]) {
    if (kinds.contains(kind)) return kind;
  }
  return null;
}

/// The page on any of [ports] of [host], all probed at once, with the port
/// it answered on: the first known page in [ports] order, or null.
Future<({HubKind kind, int port})?> probeHubPorts(
  HubProber prober,
  String host,
  List<int> ports,
) async {
  final kinds = await Future.wait([
    for (final port in ports) prober.probe(host, port),
  ]);
  for (var i = 0; i < ports.length; i++) {
    final kind = kinds[i];
    if (kind != null) return (kind: kind, port: ports[i]);
  }
  return null;
}

/// What a running scan reports.
sealed class ScanEvent {
  const ScanEvent();
}

/// An MQTT broker answered.
class BrokerFound extends ScanEvent {
  const BrokerFound(this.broker);
  final ProbeResult broker;
}

/// A hub's web page answered (see [HubKind]).
class HubSeen extends ScanEvent {
  const HubSeen(this.hub);
  final HubFound hub;
}

/// How far the scan is: [checked] of [total] address probes so far. [total]
/// counts every pass the scan may run, so the bar never moves backwards.
class ScanProgress extends ScanEvent {
  const ScanProgress(this.checked, this.total);
  final int checked;
  final int total;
}

/// What the scan covered, sent once just before the stream closes (never on
/// cancel): whether it widened to the /22, how many hosts it tried for
/// brokers and how many of those answered at all (2.6.2). Counts only; no
/// address.
class ScanTriedEvent extends ScanEvent {
  const ScanTriedEvent({
    required this.widened,
    required this.hostsTried,
    this.aliveHosts = 0,
    this.lateHosts = 0,
  });
  final bool widened;
  final int hostsTried;
  final int aliveHosts;

  /// Hosts that answered only to the second, slower look (2.9.3).
  final int lateHosts;
}
