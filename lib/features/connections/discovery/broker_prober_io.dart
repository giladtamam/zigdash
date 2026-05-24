import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:mqtt_client/mqtt_server_client.dart';

import 'broker_probe.dart';

HostProber createHostProber() => const SocketMqttProber();

/// Confirms a broker by first doing a fast TCP connect (cheap rejection of
/// closed ports) and then an MQTT handshake. Mirrors [MqttManager]'s client
/// settings — notably staying on the default MQTT 3.1 protocol, which the
/// SMLIGHT SMHUB's Mosquitto build requires. Never throws.
class SocketMqttProber implements HostProber {
  const SocketMqttProber({
    this.tcpTimeout = const Duration(milliseconds: 500),
    this.mqttTimeoutMs = 2500,
  });

  final Duration tcpTimeout;
  final int mqttTimeoutMs;

  @override
  Future<ProbeResult?> probe(String host, int port) async {
    // 1) Fast TCP pre-check — most hosts refuse instantly.
    try {
      final sock = await Socket.connect(host, port, timeout: tcpTimeout);
      sock.destroy();
    } catch (_) {
      return null;
    }

    // 2) MQTT confirm.
    final client = MqttServerClient.withPort(host, '', port)
      ..logging(on: false)
      ..secure = port == 8883
      ..keepAlivePeriod = 5
      ..connectTimeoutPeriod = mqttTimeoutMs
      ..autoReconnect = false;
    if (client.secure) client.onBadCertificate = (Object? _) => true;
    final id = 'zigdash-scan-${DateTime.now().microsecondsSinceEpoch & 0xffffff}';
    client.connectionMessage = mc.MqttConnectMessage()
        .withClientIdentifier(id)
        .startClean()
        .withWillQos(mc.MqttQos.atLeastOnce);

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

    final spokeMqtt = state == mc.MqttConnectionState.connected ||
        (code != null && code != mc.MqttConnectReturnCode.noneSpecified);
    if (!spokeMqtt) return null; // port open but not an MQTT broker

    return ProbeResult(
      host: host,
      port: port,
      needsAuth: mqttConnackToAuth(code ?? mc.MqttConnectReturnCode.connectionAccepted),
    );
  }
}
