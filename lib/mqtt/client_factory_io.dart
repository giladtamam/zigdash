import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:mqtt_client/mqtt_server_client.dart';

import 'broker_config.dart';
import 'client_factory.dart';

mc.MqttClient buildPlatformClient(BrokerConfig config, String clientId) {
  final client = MqttServerClient.withPort(config.host, clientId, config.port);
  client.secure = isSecureProtocol(config.protocol);
  if (isWebSocketProtocol(config.protocol)) {
    client.useWebSocket = true;
    client.websocketProtocols = ['mqtt'];
  }
  return client;
}
