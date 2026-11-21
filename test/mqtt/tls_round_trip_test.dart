// A real TLS handshake on localhost, offline (3.8.5, tls-home-broker.md
// §4): a broker with a certificate the phone doesn't trust, over raw TLS
// and over WSS. The client from the factory, watched by watchBadCert, must
// see the bad certificate, refuse it and not connect; mqtt_client's cast
// of the callback must not throw.
//
// The certificate under test/fixtures/tls is TEST ONLY (see its README).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/client_factory.dart';

/// The test binding answers every HttpClient with a canned 400; WSS needs
/// the real one, which the base [HttpOverrides] makes.
class _RealHttp extends HttpOverrides {}

SecurityContext _serverContext() => SecurityContext()
  ..useCertificateChain('test/fixtures/tls/test_only_cert.pem')
  ..usePrivateKey('test/fixtures/tls/test_only_key.pem');

/// Connects a factory client to 127.0.0.1:[port] over [protocol]: whether
/// the bad certificate was seen, what connect threw, and the final state.
Future<({bool sawBadCert, Object? error, mc.MqttConnectionState? state})>
_connect(MqttProtocol protocol, int port) async {
  final config = BrokerConfig(
    id: 'tls-test',
    host: '127.0.0.1',
    port: port,
    protocol: protocol,
  );
  final client = buildMqttClient(config, 'tls-test')
    ..logging(on: false)
    ..keepAlivePeriod = 5
    ..connectTimeoutPeriod = 3000
    ..autoReconnect = false;
  client.connectionMessage = mc.MqttConnectMessage()
      .withClientIdentifier('tls-test')
      .startClean();
  var saw = false;
  watchBadCert(client, config, () => saw = true);
  Object? error;
  try {
    await client.connect().timeout(const Duration(seconds: 10));
  } catch (e) {
    error = e;
  }
  final state = client.connectionStatus?.state;
  try {
    client.disconnect();
  } catch (_) {}
  return (sawBadCert: saw, error: error, state: state);
}

void main() {
  test('raw TLS: an untrusted certificate is seen, refused, not connected',
      () async {
    final server = await SecureServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
      _serverContext(),
    );
    addTearDown(server.close);
    // The client walks away mid-handshake: the server side just drops it.
    server.listen((s) => s.destroy(), onError: (_) {});

    final r = await _connect(MqttProtocol.tcpSsl, server.port);
    expect(r.sawBadCert, isTrue);
    expect(r.error, isA<TlsException>());
    expect(r.state, isNot(mc.MqttConnectionState.connected));
  });

  test('WSS: an untrusted certificate is seen, refused, not connected',
      () async {
    final server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      _serverContext(),
    );
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      // Never reached while the certificate is refused.
      await WebSocketTransformer.upgrade(request);
    }, onError: (_) {});

    final r = await HttpOverrides.runWithHttpOverrides(
      () => _connect(MqttProtocol.wss, server.port),
      _RealHttp(),
    );
    expect(r.sawBadCert, isTrue);
    expect(r.error, isA<TlsException>());
    expect(r.state, isNot(mc.MqttConnectionState.connected));
  });
}
