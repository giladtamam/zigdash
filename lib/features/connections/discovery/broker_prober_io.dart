import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:mqtt_client/mqtt_server_client.dart';

import 'broker_probe.dart';

HostProber createHostProber() => const SocketMqttProber();

/// The scan's second look (2.9.3): time for the phone to find the machine
/// on the Wi-Fi first.
HostProber createPatientHostProber() =>
    const SocketMqttProber(tcpTimeout: Duration(milliseconds: 1500));

/// Confirms a broker by first doing a fast TCP connect (cheap rejection of
/// closed ports) and then an MQTT handshake. Mirrors [MqttManager]'s client
/// settings — notably staying on the default MQTT 3.1 protocol, which the
/// SMLIGHT SMHUB's Mosquitto build requires. Never throws.
class SocketMqttProber implements HostProber {
  const SocketMqttProber({
    this.tcpTimeout = const Duration(milliseconds: 500),
    this.mqttTimeoutMs = 2500,
    this.tlsPort = 8883,
  });

  final Duration tcpTimeout;
  final int mqttTimeoutMs;

  /// The port probed over TLS: MQTT's 8883 (a parameter so tests can serve
  /// TLS on a free port).
  final int tlsPort;

  @override
  Future<ProbeResult?> probe(String host, int port) async =>
      (await probeHost(host, port)).broker;

  @override
  Future<HostProbe> probeHost(String host, int port) async {
    // 1) Fast TCP pre-check — most hosts refuse instantly. A refusal still
    //    means a machine is there; only a timeout means nothing answered.
    try {
      final sock = await Socket.connect(host, port, timeout: tcpTimeout);
      sock.destroy();
    } on SocketException catch (e) {
      return (broker: null, alive: isConnectionRefused(e));
    } catch (_) {
      return (broker: null, alive: false);
    }
    return (broker: await _confirmMqtt(host, port), alive: true);
  }

  /// A TCP RST rather than silence: errno 111 (Linux, Android), 61 (macOS,
  /// iOS) or 10061 (Windows), or the message the platform attaches to it.
  static bool isConnectionRefused(SocketException e) {
    const codes = {111, 61, 10061};
    if (codes.contains(e.osError?.errorCode)) return true;
    return (e.osError?.message ?? e.message).toLowerCase().contains('refused');
  }

  Future<ProbeResult?> _confirmMqtt(String host, int port) async {
    // 2) MQTT confirm.
    final client = MqttServerClient.withPort(host, '', port)
      ..logging(on: false)
      ..secure = port == tlsPort
      ..keepAlivePeriod = 5
      ..connectTimeoutPeriod = mqttTimeoutMs
      ..autoReconnect = false;
    // Any certificate, to see whether a broker is there; whether the phone
    // would trust it is recorded (3.8.5), since the app itself won't.
    var untrusted = false;
    if (client.secure) {
      client.onBadCertificate = (Object? _) {
        untrusted = true;
        return true;
      };
    }
    final id =
        'zigdash-scan-${DateTime.now().microsecondsSinceEpoch & 0xffffff}';
    client.connectionMessage = mc.MqttConnectMessage()
        .withClientIdentifier(id)
        .startClean();

    try {
      await client.connect();
    } catch (_) {
      // Refusal (with a return code) or handshake failure — inspect status.
    }
    final code = client.connectionStatus?.returnCode;
    final state = client.connectionStatus?.state;
    try {
      client.disconnect();
    } catch (_) {}

    final spokeMqtt =
        state == mc.MqttConnectionState.connected ||
        (code != null && code != mc.MqttConnectReturnCode.noneSpecified);
    if (!spokeMqtt) return null; // port open but not an MQTT broker

    return ProbeResult(
      host: host,
      port: port,
      needsAuth: mqttConnackToAuth(
        code ?? mc.MqttConnectReturnCode.connectionAccepted,
      ),
      untrustedCert: untrusted,
    );
  }
}
