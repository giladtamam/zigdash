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

  test('secure WebSocket stays a WebSocket: not `secure`, wss:// URL '
      '(3.8.5: `secure` turned WebSocket off and WSS never connected)', () {
    final c = buildPlatformClient(cfg(MqttProtocol.wss, '192.168.1.20'), 'id')
        as MqttServerClient;
    expect(c.secure, isFalse);
    expect(c.useWebSocket, isTrue);
    expect(c.server, 'wss://192.168.1.20');
  });

  test('TLS over TCP is `secure`, not a WebSocket', () {
    final c = buildPlatformClient(cfg(MqttProtocol.tcpSsl, '192.168.1.20'), 'id')
        as MqttServerClient;
    expect(c.secure, isTrue);
    expect(c.useWebSocket, isFalse);
    expect(c.server, '192.168.1.20');
  });

  group('watchBadCert (3.8.5)', () {
    test('a secure client reports a bad certificate and still refuses it', () {
      for (final p in [MqttProtocol.tcpSsl, MqttProtocol.wss]) {
        final config = cfg(p, '192.168.1.20');
        final c = buildPlatformClient(config, 'id') as MqttServerClient;
        var bad = 0;
        watchBadCert(c, config, () => bad++);
        // mqtt_client casts it this way before use (mqtt_server_client.dart).
        final cb = c.onBadCertificate as bool Function(Object certificate)?;
        expect(cb, isNotNull, reason: p.name);
        expect(cb!(Object()), isFalse, reason: p.name);
        expect(bad, 1, reason: p.name);
      }
    });

    test('plain protocols are left alone', () {
      for (final p in [MqttProtocol.tcp, MqttProtocol.ws]) {
        final config = cfg(p, '192.168.1.20');
        final c = buildPlatformClient(config, 'id') as MqttServerClient;
        watchBadCert(c, config, () {});
        expect(c.onBadCertificate, isNull, reason: p.name);
      }
    });
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

  test('one CONNECT per try, so a slow refusal is not wiped by a retry', () {
    final c = buildPlatformClient(cfg(MqttProtocol.tcp, '192.168.1.20'), 'id')
        as MqttServerClient;
    expect(c.maxConnectionAttempts, 1);
  });
}
