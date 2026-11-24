import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/discovery/broker_probe.dart';
import 'package:zigdash/features/onboarding/setup/setup_candidate.dart';

void main() {
  group('SetupCandidate.fromProbe', () {
    test('port 8883 maps to tcpSsl', () {
      final c = SetupCandidate.fromProbe(
          const ProbeResult(host: '192.168.1.10', port: 8883));
      expect(c.protocol, MqttProtocol.tcpSsl);
      expect(c.needsAuth, isFalse);
    });

    test('other ports map to tcp', () {
      final c = SetupCandidate.fromProbe(
          const ProbeResult(host: '192.168.1.10', port: 1883, needsAuth: true));
      expect(c.protocol, MqttProtocol.tcp);
      expect(c.needsAuth, isTrue);
    });
  });

  group('mergeCandidates', () {
    test('dedupes by host+port+protocol identity', () {
      final merged = mergeCandidates([
        const ProbeResult(host: '192.168.1.10', port: 1883),
        const ProbeResult(host: '192.168.1.10', port: 1883),
        const ProbeResult(host: '192.168.1.11', port: 1883),
      ]);
      expect(merged, hasLength(2));
    });

    test('keeps first-seen order', () {
      final merged = mergeCandidates([
        const ProbeResult(host: '192.168.1.20', port: 1883),
        const ProbeResult(host: '192.168.1.10', port: 1883),
      ]);
      expect(merged.map((c) => c.host), ['192.168.1.20', '192.168.1.10']);
    });

    test('same host different ports are distinct candidates', () {
      final merged = mergeCandidates([
        const ProbeResult(host: '192.168.1.10', port: 1883),
        const ProbeResult(host: '192.168.1.10', port: 8883),
      ]);
      expect(merged, hasLength(2));
    });

    test('a later probe can upgrade needsAuth', () {
      final merged = mergeCandidates([
        const ProbeResult(host: '192.168.1.10', port: 1883),
        const ProbeResult(host: '192.168.1.10', port: 1883, needsAuth: true),
      ]);
      expect(merged.single.needsAuth, isTrue);
    });

    test('empty input yields empty list', () {
      expect(mergeCandidates(const []), isEmpty);
    });

    // 3.8.5: an untrusted certificate survives every copy.
    test('untrustedCert survives fromProbe and the merge, and can upgrade',
        () {
      const tls = ProbeResult(
        host: '192.168.1.10',
        port: 8883,
        needsAuth: true,
        untrustedCert: true,
      );
      expect(SetupCandidate.fromProbe(tls).untrustedCert, isTrue);
      expect(mergeCandidates([tls]).single.untrustedCert, isTrue);
      final upgraded = mergeCandidates([
        const ProbeResult(host: '192.168.1.10', port: 8883),
        tls,
      ]).single;
      expect(upgraded.untrustedCert, isTrue);
      expect(upgraded.needsAuth, isTrue);
      // A later probe that saw neither keeps both.
      final kept = mergeCandidates([
        tls,
        const ProbeResult(host: '192.168.1.10', port: 8883),
      ]).single;
      expect(kept.untrustedCert, isTrue);
      expect(kept.needsAuth, isTrue);
    });

    test('copyWith keeps the transport', () {
      const c = SetupCandidate(
        host: 'h',
        port: 8080,
        protocol: MqttProtocol.ws,
        transport: ConnectionTransport.z2mPage,
      );
      final copy = c.copyWith(untrustedCert: true);
      expect(copy.transport, ConnectionTransport.z2mPage);
      expect(copy.untrustedCert, isTrue);
      expect(copy, c);
    });
  });

  group('preferUsable (3.8.5)', () {
    const plain = SetupCandidate(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
    );
    const untrusted = SetupCandidate(
      host: '192.168.1.10',
      port: 8883,
      protocol: MqttProtocol.tcpSsl,
      needsAuth: true,
      untrustedCert: true,
    );

    test('1883 on the same machine beats an untrusted 8883', () {
      expect(preferUsable([untrusted, plain]), [plain]);
    });

    test('an untrusted 8883 alone, or on another machine, stays', () {
      expect(preferUsable([untrusted]), [untrusted]);
      const other = SetupCandidate(
        host: '192.168.1.11',
        port: 1883,
        protocol: MqttProtocol.tcp,
      );
      expect(preferUsable([untrusted, other]), [untrusted, other]);
    });

    test('a trusted 8883 stays next to 1883', () {
      final trusted = untrusted.copyWith(untrustedCert: false);
      expect(preferUsable([trusted, plain]), [trusted, plain]);
    });
  });
}
