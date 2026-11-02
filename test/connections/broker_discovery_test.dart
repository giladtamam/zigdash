import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:zigdash/features/connections/discovery/broker_probe.dart';
import 'package:zigdash/features/connections/discovery/broker_scan_service.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';
import 'package:zigdash/features/connections/discovery/subnet.dart';

/// Fake prober: returns hits for a fixed set of `host:port`, and tracks the
/// peak number of concurrent probe calls so we can assert the cap.
class _FakeProber extends HostProber {
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

/// Fake prober that finds no broker but knows which hosts are alive.
class _AliveProber extends HostProber {
  _AliveProber(this.alive, {this.brokers = const {}});
  final Set<String> alive;

  /// Hosts that answer as a broker on any port.
  final Set<String> brokers;
  final probed = <String>[];

  @override
  Future<ProbeResult?> probe(String host, int port) async => null;

  @override
  Future<HostProbe> probeHost(String host, int port) async {
    probed.add('$host:$port');
    return (
      broker: brokers.contains(host)
          ? ProbeResult(host: host, port: port)
          : null,
      alive: alive.contains(host),
    );
  }
}

/// Fake hub prober: answers with a kind for a fixed set of `host:port`.
class _FakeHubs implements HubProber {
  _FakeHubs(this.hits);
  final Map<String, HubKind> hits;
  final probed = <String>[];

  @override
  Future<HubKind?> probe(String host, int port) async {
    probed.add('$host:$port');
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return hits['$host:$port'];
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
        mqttConnackToAuth(MqttConnectReturnCode.badUsernameOrPassword),
        isTrue,
      );
    });
    test('accepted / unrelated → false', () {
      expect(
        mqttConnackToAuth(MqttConnectReturnCode.connectionAccepted),
        isFalse,
      );
      expect(
        mqttConnackToAuth(MqttConnectReturnCode.brokerUnavailable),
        isFalse,
      );
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

      expect(results.map((r) => r.host).toSet(), {
        '192.168.7.210',
        '192.168.7.50',
      });
      expect(
        results.firstWhere((r) => r.host == '192.168.7.50').needsAuth,
        isTrue,
      );
      expect(
        results.firstWhere((r) => r.host == '192.168.7.210').needsAuth,
        isFalse,
      );
    });

    test('respects the concurrency cap', () async {
      final prober = _FakeProber({});
      final service = BrokerScanService(
        prober: prober,
        ports: const [1883],
        concurrency: 8,
      );
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

    test('reports what it tried, once', () async {
      final stats = <ScanStats>[];
      final service = BrokerScanService(
        prober: _FakeProber({'192.168.68.55:1883': false}),
        ports: const [1883, 8883],
      );
      await service.scan('192.168.69.10', onDone: stats.add).toList();
      expect(stats, hasLength(1));
      expect(stats.single.widened, isTrue);
      expect(stats.single.brokersFound, 1);
      // 253 in the own /24, then the other 765 of the /22 (all but .0 and
      // the /24 already tried), each on two ports.
      expect(stats.single.hostsTried, greaterThan(1000));

      stats.clear();
      await BrokerScanService(
        prober: _FakeProber({}),
        ports: const [1883],
      ).scan('8.8.8.8', onDone: stats.add).toList();
      // A public address has no wider /22 to try.
      expect(stats.single, (
        widened: false,
        hostsTried: 253,
        brokersFound: 0,
        aliveHosts: 0,
        lateHosts: 0,
      ));
    });

    // 2.6.2: hosts that answered at all, for the empty scan's diagnostics.
    test('counts the hosts that answered, once each', () async {
      final service = BrokerScanService(
        prober: _AliveProber({'192.168.7.1', '192.168.7.20'}),
        ports: const [1883, 8883],
      );
      final stats = <ScanStats>[];
      final events = await service
          .run('192.168.7.42', hubs: const {}, onDone: stats.add)
          .events
          .toList();
      expect(stats.single.aliveHosts, 2);
      expect(stats.single.brokersFound, 0);
      final tried = events.whereType<ScanTriedEvent>().single;
      expect(tried.aliveHosts, 2);
      expect(tried.widened, isTrue);
    });

    // 2.9.3: a quick first try can give up before the phone has found the
    // machine on the Wi-Fi; the silent hosts get a second, slower look.
    test('the second look finds a broker the first one missed', () async {
      final patient = _AliveProber({'192.168.7.20'}, brokers: {'192.168.7.20'});
      final stats = <ScanStats>[];
      final events = await BrokerScanService(
        prober: _AliveProber({'192.168.7.1'}),
        patientProber: patient,
        ports: const [1883, 8883],
      ).run('192.168.7.42', hubs: const {}, onDone: stats.add).events.toList();
      expect(events.whereType<BrokerFound>().map((e) => e.broker.key), [
        '192.168.7.20:1883',
      ]);
      // Only the /24's silent hosts, once each, on the first port.
      expect(patient.probed, isNot(contains('192.168.7.1:1883')));
      expect(patient.probed.every((k) => k.endsWith(':1883')), isTrue);
      expect(patient.probed, hasLength(252));
      expect(stats.single.lateHosts, 1);
      expect(stats.single.aliveHosts, 2);
      expect(events.whereType<ScanTriedEvent>().single.lateHosts, 1);
      final last = events.whereType<ScanProgress>().last;
      expect(last.checked, last.total);
    });

    test('a host that answers late is asked for its hub page', () async {
      final hubs = _FakeHubs({'192.168.7.30:8123': HubKind.homeAssistant});
      final events = await BrokerScanService(
        prober: _AliveProber({}),
        hubProber: _FakeHubs({}),
        patientProber: _AliveProber({'192.168.7.30'}),
        patientHubProber: hubs,
        ports: const [1883],
      ).run('192.168.7.42', hubs: {HubKind.homeAssistant}).events.toList();
      expect(events.whereType<HubSeen>().map((e) => e.hub.key), [
        '192.168.7.30:8123',
      ]);
      expect(hubs.probed, ['192.168.7.30:8123']);
    });

    test('no second look once a broker is found', () async {
      final patient = _AliveProber({});
      await BrokerScanService(
        prober: _FakeProber({'192.168.68.55:1883': false}),
        patientProber: patient,
        ports: const [1883],
      ).scan('192.168.69.10').toList();
      expect(patient.probed, isEmpty);
    });

    test('no brokers found → empty, still closes', () async {
      final service = BrokerScanService(
        prober: _FakeProber({}),
        ports: const [1883],
      );
      expect(await service.scan('192.168.7.42').toList(), isEmpty);
    });
  });

  group('hubKindOfPage', () {
    test('knows the three web pages, whatever the case', () {
      expect(
        hubKindOfPage('<title>Home Assistant</title>'),
        HubKind.homeAssistant,
      );
      expect(hubKindOfPage('<title>Zigbee2MQTT</title>'), HubKind.zigbee2mqtt);
      expect(hubKindOfPage('SLZB-06 web UI'), HubKind.smlight);
      expect(hubKindOfPage('<title>Printer</title>'), isNull);
    });

    test('an SMHUB calls itself SMHUB', () {
      expect(hubKindOfPage('<title>SMHUB</title>'), HubKind.smlight);
    });
  });

  // 2.7.1: two brokers found, each card says what its machine is.
  group('identifyHost', () {
    test(
      'Home Assistant beats a Zigbee2MQTT page on the same machine',
      () async {
        final hubs = _FakeHubs({
          '192.168.1.20:8123': HubKind.homeAssistant,
          '192.168.1.20:8080': HubKind.zigbee2mqtt,
        });
        expect(await identifyHost(hubs, '192.168.1.20'), HubKind.homeAssistant);
      },
    );

    test('an SMLIGHT hub beats the Zigbee2MQTT page it serves', () async {
      final hubs = _FakeHubs({
        '192.168.1.30:80': HubKind.smlight,
        '192.168.1.30:8080': HubKind.zigbee2mqtt,
      });
      expect(await identifyHost(hubs, '192.168.1.30'), HubKind.smlight);
    });

    // 3.2.7: early SMHUB firmware served its web page on 3000.
    test('an SMHUB serving its page on 3000', () async {
      final hubs = _FakeHubs({'192.168.1.31:3000': HubKind.smlight});
      expect(await identifyHost(hubs, '192.168.1.31'), HubKind.smlight);
    });

    test('a bare Zigbee2MQTT page, or nothing', () async {
      final hubs = _FakeHubs({'192.168.1.40:8080': HubKind.zigbee2mqtt});
      expect(await identifyHost(hubs, '192.168.1.40'), HubKind.zigbee2mqtt);
      expect(await identifyHost(hubs, '192.168.1.41'), isNull);
    });
  });

  // 2.5: the empty result says what was found, so the scan looks for hubs
  // when the broker pass of the /24 comes up empty.
  group('BrokerScanService.run', () {
    test('no broker on the /24 → hubs on the /24, then the /22', () async {
      final hubs = _FakeHubs({'192.168.7.20:8123': HubKind.homeAssistant});
      final prober = _FakeProber({});
      final service = BrokerScanService(
        prober: prober,
        hubProber: hubs,
        ports: const [1883],
      );
      final events = await service.run('192.168.7.42').events.toList();
      final seen = events.whereType<HubSeen>().map((e) => e.hub).toList();
      expect(seen, [
        const HubFound(
          kind: HubKind.homeAssistant,
          host: '192.168.7.20',
          port: 8123,
        ),
      ]);
      // Home Assistant and the Zigbee2MQTT frontend on every /24 host; no
      // SMLIGHT pass unless asked; never the /22.
      expect(hubs.probed.where((p) => p.endsWith(':8123')), hasLength(253));
      expect(hubs.probed.where((p) => p.endsWith(':8080')), hasLength(253));
      expect(hubs.probed.any((p) => p.endsWith(':80')), isFalse);
      expect(hubs.probed.every((p) => p.startsWith('192.168.7.')), isTrue);
      expect(
        prober.probed.any((h) => h.startsWith('192.168.4.')),
        isTrue,
        reason: 'the wider pass still runs',
      );
    });

    test('a broker on the /24 → no hub pass at all', () async {
      final hubs = _FakeHubs({'192.168.7.20:8123': HubKind.homeAssistant});
      final service = BrokerScanService(
        prober: _FakeProber({'192.168.7.210:1883': false}),
        hubProber: hubs,
        ports: const [1883],
      );
      final events = await service.run('192.168.7.42').events.toList();
      expect(events.whereType<BrokerFound>(), hasLength(1));
      expect(events.whereType<HubSeen>(), isEmpty);
      expect(hubs.probed, isEmpty);
    });

    test('the SMLIGHT pass runs only when added, also mid-scan', () async {
      final hubs = _FakeHubs({'192.168.7.30:80': HubKind.smlight});
      final service = BrokerScanService(
        prober: _FakeProber({}),
        hubProber: hubs,
        ports: const [1883],
      );
      final run = service.run('192.168.7.42');
      final events = <ScanEvent>[];
      final done = run.events.listen(events.add).asFuture<void>();
      run.addHub(HubKind.smlight);
      await done;
      expect(events.whereType<HubSeen>().map((e) => e.hub.kind), [
        HubKind.smlight,
      ]);
      expect(hubs.probed.where((p) => p.endsWith(':80')), hasLength(253));

      final again = _FakeHubs({'192.168.7.30:80': HubKind.smlight});
      final noAsk = BrokerScanService(
        prober: _FakeProber({}),
        hubProber: again,
        ports: const [1883],
      );
      await noAsk.run('192.168.7.42').events.toList();
      expect(again.probed.any((p) => p.endsWith(':80')), isFalse);
    });

    test('the SMLIGHT pass also sees a page on 3000', () async {
      final hubs = _FakeHubs({'192.168.7.31:3000': HubKind.smlight});
      final service = BrokerScanService(
        prober: _FakeProber({}),
        hubProber: hubs,
        ports: const [1883],
      );
      final run = service.run('192.168.7.42');
      final events = <ScanEvent>[];
      final done = run.events.listen(events.add).asFuture<void>();
      run.addHub(HubKind.smlight);
      await done;
      expect(events.whereType<HubSeen>().map((e) => e.hub), [
        const HubFound(kind: HubKind.smlight, host: '192.168.7.31', port: 3000),
      ]);
    });

    test('progress never goes backwards and ends at the total', () async {
      final service = BrokerScanService(
        prober: _FakeProber({}),
        hubProber: _FakeHubs({}),
        ports: const [1883],
      );
      final progress = (await service.run('192.168.7.42').events.toList())
          .whereType<ScanProgress>()
          .toList();
      for (var i = 1; i < progress.length; i++) {
        expect(
          progress[i].checked,
          greaterThanOrEqualTo(progress[i - 1].checked),
        );
        expect(progress[i].total, progress[i - 1].total);
      }
      expect(progress.last.checked, progress.last.total);
      // 253 brokers + 2 × 253 hubs + 767 wider (blocks 4, 5 and 6 minus .0).
      expect(progress.last.total, 253 + 506 + 767);
    });

    test('scan() is brokers only: no hub probes, same stats', () async {
      final hubs = _FakeHubs({'192.168.7.20:8123': HubKind.homeAssistant});
      final stats = <ScanStats>[];
      final service = BrokerScanService(
        prober: _FakeProber({}),
        hubProber: hubs,
        ports: const [1883],
      );
      await service.scan('8.8.8.8', onDone: stats.add).toList();
      expect(hubs.probed, isEmpty);
      expect(stats.single, (
        widened: false,
        hostsTried: 253,
        brokersFound: 0,
        aliveHosts: 0,
        lateHosts: 0,
      ));
    });
  });
}
