import 'broker_config.dart';

/// Which address a live MQTT connection is using.
enum MqttEndpoint { local, remote, relay }

/// The candidate host that means "through the ZigDash relay" (3.1).
const relayCandidateHost = 'zigdash-relay';

/// A relay connect is TLS over WebSocket to a server on the internet.
const int relayConnectTimeoutMs = 10000;

/// One ordered connect attempt: a host and the timeout to give it.
typedef MqttCandidate = ({MqttEndpoint kind, String host, int timeoutMs});

/// Short probe for the LAN host when a remote fallback exists — fail fast so we
/// can try the remote address quickly when away from home.
const int localProbeTimeoutMs = 3000;

/// Normal connect timeout (matches the previous single-host behavior).
const int standardConnectTimeoutMs = 5000;

/// A Home Assistant connect is a token refresh, TLS, the sign-in and a
/// probe subscription, often over the internet: more than an MQTT CONNECT.
const int homeAssistantConnectTimeoutMs = 12000;

/// A broker that checks a login may answer slowly: the Home Assistant
/// Mosquitto add-on asks Home Assistant about every login, and a scanned
/// broker isn't known to be Home Assistant's. 5 s gave up before a Russian
/// broker answered three logins in a row (3.3.1, login_no_answer).
const int loginConnectTimeoutMs = 12000;

/// Local-first ordered candidates for [config]. With a remote host set, the LAN
/// host is tried first with a short timeout, then the remote host. Without one,
/// a single local candidate with the standard timeout (unchanged behavior).
/// Test builds only (--dart-define=ZIGDASH_FORCE_RELAY=true): skip the
/// broker's own addresses when a relay login exists, to try "away" at home.
const forceRelay = bool.fromEnvironment('ZIGDASH_FORCE_RELAY');

List<MqttCandidate> endpointCandidates(BrokerConfig config) {
  if (forceRelay && config.relay != null && !config.notBroker) {
    return [(kind: MqttEndpoint.relay, host: relayCandidateHost, timeoutMs: relayConnectTimeoutMs)];
  }
  final remote = config.remoteHost?.trim();
  final standard = config.viaHomeAssistant
      ? homeAssistantConnectTimeoutMs
      : standardConnectTimeoutMs;
  final relay = config.relay != null && !config.notBroker
      ? [(kind: MqttEndpoint.relay, host: relayCandidateHost, timeoutMs: relayConnectTimeoutMs)]
      : const <MqttCandidate>[];
  if ((remote == null || remote.isEmpty) && relay.isEmpty) {
    // The broker is the only way in: a login may take its time. With a
    // remote address or the relay, away from home must not wait 12 s on
    // the LAN address before trying them.
    final login = !config.viaHomeAssistant &&
        (config.username?.isNotEmpty ?? false);
    return [
      (
        kind: MqttEndpoint.local,
        host: config.host,
        timeoutMs: login ? loginConnectTimeoutMs : standard,
      ),
    ];
  }
  if (remote == null || remote.isEmpty) {
    return [
      (
        kind: MqttEndpoint.local,
        host: config.host,
        // The relay is a fallback: at home the broker must win, so it keeps
        // the full budget (a slow hub broker took more than 3 s).
        timeoutMs: standard,
      ),
      ...relay,
    ];
  }
  return [
    (
      kind: MqttEndpoint.local,
      host: config.host,
      timeoutMs: localProbeTimeoutMs,
    ),
    (kind: MqttEndpoint.remote, host: remote, timeoutMs: standard),
    ...relay,
  ];
}
