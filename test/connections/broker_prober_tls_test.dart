// The scan's prober against a real TLS broker on localhost (3.8.5): it
// accepts any certificate to see that a broker is there, and records that
// the phone wouldn't trust this one. The certificate under
// test/fixtures/tls is TEST ONLY (see its README).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/discovery/broker_prober_io.dart';

void main() {
  test('an untrusted certificate is found, and flagged', () async {
    final context = SecurityContext()
      ..useCertificateChain('test/fixtures/tls/test_only_cert.pem')
      ..usePrivateKey('test/fixtures/tls/test_only_key.pem');
    final server = await SecureServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
      context,
    );
    addTearDown(server.close);
    server.listen((socket) {
      // Any CONNECT gets "not authorized": a broker that wants a login.
      socket.listen(
        (_) => socket.add(const [0x20, 0x02, 0x00, 0x05]),
        onError: (_) {},
      );
    }, onError: (_) {});

    final prober = SocketMqttProber(tlsPort: server.port);
    final found = await prober.probe('127.0.0.1', server.port);
    expect(found, isNotNull);
    expect(found!.needsAuth, isTrue);
    expect(found.untrustedCert, isTrue);
  });
}
