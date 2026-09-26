import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/client_factory_io.dart';

void main() {
  BrokerConfig cfg(MqttProtocol p, String host) =>
      BrokerConfig(id: 'c', host: host, port: 9001, protocol: p);

  test('WebSocket clients get a ws:// URL (bare host was rejected)', () {
    final c = buildPlatformClient(cfg(MqttProtocol.ws, '192.168.1.20'), 'id')
        as MqttServerClient;
    expect(c.server, 'ws://192.168.1.20');
    expect(c.useWebSocket, isTrue);
  });

  test('secure WebSocket gets wss://', () {
    expect(webSocketServer(MqttProtocol.wss, 'home.example'),
        'wss://home.example');
  });

  test('a scheme the user typed is kept', () {
    expect(webSocketServer(MqttProtocol.ws, 'ws://10.0.0.2'), 'ws://10.0.0.2');
  });

  test('TCP keeps the bare host', () {
    final c = buildPlatformClient(cfg(MqttProtocol.tcp, '192.168.1.20'), 'id')
        as MqttServerClient;
    expect(c.server, '192.168.1.20');
  });
}
