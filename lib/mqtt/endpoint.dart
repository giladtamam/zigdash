import 'broker_config.dart';

/// Which address a live MQTT connection is using.
enum MqttEndpoint { local, remote }

/// One ordered connect attempt: a host and the timeout to give it.
typedef MqttCandidate = ({MqttEndpoint kind, String host, int timeoutMs});

/// Short probe for the LAN host when a remote fallback exists — fail fast so we
/// can try the remote address quickly when away from home.
const int localProbeTimeoutMs = 3000;

/// Normal connect timeout (matches the previous single-host behavior).
const int standardConnectTimeoutMs = 5000;

/// Local-first ordered candidates for [config]. With a remote host set, the LAN
/// host is tried first with a short timeout, then the remote host. Without one,
/// a single local candidate with the standard timeout (unchanged behavior).
List<MqttCandidate> endpointCandidates(BrokerConfig config) {
  final remote = config.remoteHost?.trim();
  if (remote == null || remote.isEmpty) {
    return [
      (kind: MqttEndpoint.local, host: config.host, timeoutMs: standardConnectTimeoutMs),
    ];
  }
  return [
    (kind: MqttEndpoint.local, host: config.host, timeoutMs: localProbeTimeoutMs),
    (kind: MqttEndpoint.remote, host: remote, timeoutMs: standardConnectTimeoutMs),
  ];
}
