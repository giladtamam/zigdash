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
  });
}
