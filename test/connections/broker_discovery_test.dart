import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:zigdash/features/connections/discovery/broker_probe.dart';
import 'package:zigdash/features/connections/discovery/broker_scan_service.dart';
import 'package:zigdash/features/connections/discovery/subnet.dart';

/// Fake prober: returns hits for a fixed set of `host:port`, and tracks the
/// peak number of concurrent probe calls so we can assert the cap.
class _FakeProber implements HostProber {
  _FakeProber(this.hits);
  final Map<String, bool> hits; // "host:port" -> needsAuth
  final probed = <String>{};
  int active = 0;
  int maxActive = 0;

  @override
  Future<ProbeResult?> probe(String host, int port) async {
    probed.add(host);
    active++;
    if (active > maxActive) maxActive = active;
    await Future<void>.delayed(const Duration(milliseconds: 3));
    active--;
    final key = '$host:$port';
    if (hits.containsKey(key)) {
      return ProbeResult(host: host, port: port, needsAuth: hits[key]!);
    }
    return null;
  }
}

void main() {
  group('subnetBaseFromIp', () {
    test('returns the first three octets', () {
      expect(subnetBaseFromIp('192.168.7.42'), '192.168.7');
    });
    test('rejects malformed input', () {
      expect(subnetBaseFromIp('192.168.7'), isNull);
      expect(subnetBaseFromIp('192.168.7.999'), isNull);
      expect(subnetBaseFromIp('not.an.ip.addr'), isNull);
    });
  });

  group('candidateHosts', () {
    test('produces .1–.254 excluding self', () {
      final hosts = candidateHosts('192.168.7.42');
      expect(hosts.length, 253); // 254 minus self
      expect(hosts, contains('192.168.7.1'));
      expect(hosts, contains('192.168.7.254'));
      expect(hosts, isNot(contains('192.168.7.42')));
    });
    test('empty on malformed ip', () {
      expect(candidateHosts('garbage'), isEmpty);
    });
  });

  group('widerCandidateHosts', () {
    test('covers the rest of the aligned /22, not the own /24', () {
      final hosts = widerCandidateHosts('192.168.68.42');
      expect(hosts.length, 256 + 256 + 255); // 69, 70, 71 minus broadcast
      expect(hosts.first, '192.168.69.0');
      expect(hosts, contains('192.168.71.254'));
      expect(hosts, isNot(contains('192.168.71.255')));
      expect(hosts.any((h) => h.startsWith('192.168.68.')), isFalse);
    });
    test('from a middle block, includes the first block but not .0', () {
      final hosts = widerCandidateHosts('192.168.69.10');
      expect(hosts, contains('192.168.68.55'));
      expect(hosts, isNot(contains('192.168.68.0')));
      expect(hosts.any((h) => h.startsWith('192.168.69.')), isFalse);
    });
    test('empty for public or malformed addresses', () {
      expect(widerCandidateHosts('8.8.8.8'), isEmpty);
      expect(widerCandidateHosts('garbage'), isEmpty);
    });
  });

  group('mqttConnackToAuth', () {
    test('auth-related refusals → true', () {
      expect(mqttConnackToAuth(MqttConnectReturnCode.notAuthorized), isTrue);
      expect(
          mqttConnackToAuth(MqttConnectReturnCode.badUsernameOrPassword), isTrue);
    });
    test('accepted / unrelated → false', () {
      expect(mqttConnackToAuth(MqttConnectReturnCode.connectionAccepted), isFalse);
      expect(mqttConnackToAuth(MqttConnectReturnCode.brokerUnavailable), isFalse);
    });
  });

  group('BrokerScanService', () {
    test('emits confirmed brokers, deduped, and terminates', () async {
      final prober = _FakeProber({
        '192.168.7.210:1883': false,
        '192.168.7.50:1883': true,
      });
      final service = BrokerScanService(prober: prober, ports: const [1883]);

      final results = await service.scan('192.168.7.42').toList();

      expect(results.map((r) => r.host).toSet(),
          {'192.168.7.210', '192.168.7.50'});
      expect(results.firstWhere((r) => r.host == '192.168.7.50').needsAuth,
          isTrue);
      expect(results.firstWhere((r) => r.host == '192.168.7.210').needsAuth,
          isFalse);
    });

    test('respects the concurrency cap', () async {
      final prober = _FakeProber({});
      final service =
          BrokerScanService(prober: prober, ports: const [1883], concurrency: 8);
      await service.scan('192.168.7.42').toList();
      expect(prober.maxActive, lessThanOrEqualTo(8));
      expect(prober.maxActive, greaterThan(1)); // actually ran in parallel
    });

    test('finds a hub in another block of a /22 (mesh networks)', () async {
      final prober = _FakeProber({'192.168.68.55:1883': false});
      final service = BrokerScanService(prober: prober, ports: const [1883]);
      final results = await service.scan('192.168.69.10').toList();
      expect(results.map((r) => r.host), ['192.168.68.55']);
    });

    test('does not widen when the own /24 has a broker', () async {
      final prober = _FakeProber({'192.168.7.210:1883': false});
      final service = BrokerScanService(prober: prober, ports: const [1883]);
      await service.scan('192.168.7.42').toList();
      expect(prober.probed.every((h) => h.startsWith('192.168.7.')), isTrue);
    });

    test('no brokers found → empty, still closes', () async {
      final service = BrokerScanService(
          prober: _FakeProber({}), ports: const [1883]);
      expect(await service.scan('192.168.7.42').toList(), isEmpty);
    });
  });
}
