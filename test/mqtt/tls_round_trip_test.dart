// A real TLS handshake on localhost, offline (3.8.5, tls-home-broker.md
// §4): a broker with a certificate the phone doesn't trust, over raw TLS
// and over WSS. The client from the factory, watched by watchBadCert, must
// see the bad certificate, refuse it and not connect; mqtt_client's cast
// of the callback must not throw. A certificate the phone trusts must
// connect over WSS.
//
// The certificate under test/fixtures/tls is TEST ONLY (see its README).

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show listEquals;

import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/client_factory.dart';

/// The test binding answers every HttpClient with a canned 400; WSS needs
/// the real one, which the base [HttpOverrides] makes.
class _RealHttp extends HttpOverrides {}

/// The DER bytes of a one-certificate PEM file.
List<int> _der(String path) => base64.decode(
  File(path)
      .readAsLinesSync()
      .where((l) => !l.startsWith('-----'))
      .join(),
);

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

  // 3.8.5: `secure` on a wss client made mqtt_client open a raw TLS socket
  // to "wss://host", so direct WSS never connected.
  test('WSS with a trusted certificate connects', () async {
    final server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      _serverContext(),
    );
    addTearDown(() => server.close(force: true));
    final protocols = <String>[];
    server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(
        request,
        protocolSelector: (offered) {
          protocols.addAll(offered);
          return 'mqtt';
        },
      );
      var answered = false;
      socket.listen((data) {
        // The first packet is CONNECT: accept it (CONNACK, code 0).
        if (answered || data is! List<int>) return;
        answered = true;
        socket.add(const [0x20, 0x02, 0x00, 0x00]);
      }, onError: (_) {});
    }, onError: (_) {});

    final fixture = _der('test/fixtures/tls/test_only_cert.pem');
    final r = await HttpOverrides.runWithHttpOverrides(() async {
      final config = BrokerConfig(
        id: 'wss-test',
        host: '127.0.0.1',
        port: server.port,
        protocol: MqttProtocol.wss,
      );
      final client = buildMqttClient(config, 'wss-test')
        ..logging(on: false)
        ..keepAlivePeriod = 5
        ..connectTimeoutPeriod = 3000
        ..autoReconnect = false;
      client.connectionMessage = mc.MqttConnectMessage()
          .withClientIdentifier('wss-test')
          .startClean();
      // A phone that trusts this one certificate, as it would one from a
      // public authority. (A context with it as the only root isn't enough
      // on macOS, whose own check also refuses a server certificate valid
      // for over 825 days.)
      (client as MqttServerClient).onBadCertificate = (Object? cert) =>
          cert is X509Certificate && listEquals(cert.der, fixture);
      try {
        await client.connect().timeout(const Duration(seconds: 10));
      } catch (_) {}
      final state = client.connectionStatus?.state;
      try {
        client.disconnect();
      } catch (_) {}
      return state;
    }, _RealHttp());

    expect(r, mc.MqttConnectionState.connected);
    expect(protocols, contains('mqtt'));
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
