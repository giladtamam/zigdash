import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../data/database/tables/connections.dart';
import 'broker_config.dart';
import 'client_factory.dart';

mc.MqttClient buildPlatformClient(BrokerConfig config, String clientId) {
  if (!isWebSocketProtocol(config.protocol)) {
    throw UnsupportedError(
      'Browsers cannot open raw TCP. Choose WS or WSS protocol for web targets. '
      'Got: ${config.protocol.name} on ${config.host}:${config.port}.',
    );
  }
  final scheme = config.protocol == MqttProtocol.wss ? 'wss' : 'ws';
  final client = MqttBrowserClient.withPort(
    '$scheme://${config.host}',
    clientId,
    config.port,
  );
  client.websocketProtocols = ['mqtt'];
  return client;
}
