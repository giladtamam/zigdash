import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/discovery/address_check.dart';
import 'package:zigdash/features/connections/discovery/address_checker_io.dart';
import 'package:zigdash/features/connections/discovery/broker_probe.dart';
import 'package:zigdash/features/connections/discovery/broker_prober_io.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';

class _FakeProber extends HostProber {
  _FakeProber(this.brokers);
  final Set<String> brokers; // "host:port"
  final probed = <String>[];

  @override
  Future<ProbeResult?> probe(String host, int port) async {
    probed.add('$host:$port');
    return brokers.contains('$host:$port')
        ? ProbeResult(host: host, port: port, needsAuth: port == 1883)
        : null;
  }
}

class _FakeHubs implements HubProber {
  _FakeHubs(this.pages);
  final Map<String, HubKind> pages;
  final probed = <String>[];

  @override
  Future<HubKind?> probe(String host, int port) async {
    probed.add('$host:$port');
    return pages['$host:$port'];
  }
}

void main() {
  group('hostFromAddressInput', () {
    test('an IP, a name, a name with a port, a browser link', () {
      expect(hostFromAddressInput('192.168.1.20'), (
        host: '192.168.1.20',
        port: null,
      ));
      expect(hostFromAddressInput('  HomeAssistant.local '), (
        host: 'homeassistant.local',
        port: null,
      ));
      expect(hostFromAddressInput('homeassistant.local:8123'), (
        host: 'homeassistant.local',
        port: 8123,
      ));
      expect(hostFromAddressInput('http://192.168.1.20:8123/lovelace/0'), (
        host: '192.168.1.20',
        port: 8123,
      ));
      expect(hostFromAddressInput('https://ha.example.com/'), (
        host: 'ha.example.com',
        port: null,
      ));
    });

    test('nothing usable → null', () {
      expect(hostFromAddressInput(''), isNull);
      expect(hostFromAddressInput('   '), isNull);
      expect(hostFromAddressInput('http://'), isNull);
    });

    test('isIpv4Literal', () {
      expect(isIpv4Literal('192.168.1.20'), isTrue);
      expect(isIpv4Literal('192.168.1'), isFalse);
      expect(isIpv4Literal('192.168.1.999'), isFalse);
      expect(isIpv4Literal('homeassistant.local'), isFalse);
    });
  });

  group('createAddressChecker', () {
    test('a broker wins; the hub pages are not even awaited for', () async {
      final prober = _FakeProber({'192.168.1.20:1883'});
      final hubs = _FakeHubs({'192.168.1.20:8123': HubKind.homeAssistant});
      final check = createAddressChecker(prober: prober, hubProber: hubs);
      final r = await check('192.168.1.20', null);
      expect(r.outcome, AddressOutcome.broker);
      expect(r.broker, const ProbeResult(host: '192.168.1.20', port: 1883));
      expect(r.broker!.needsAuth, isTrue);
      expect(prober.probed, ['192.168.1.20:1883', '192.168.1.20:8883']);
    });

    test('a hub page without a broker; Home Assistant first', () async {
      final hubs = _FakeHubs({
        '192.168.1.20:8080': HubKind.zigbee2mqtt,
        '192.168.1.20:8123': HubKind.homeAssistant,
      });
      final check = createAddressChecker(
        prober: _FakeProber({}),
        hubProber: hubs,
      );
      final r = await check('192.168.1.20', null);
      expect(r.outcome, AddressOutcome.hub);
      expect(
        r.hub,
        const HubFound(
          kind: HubKind.homeAssistant,
          host: '192.168.1.20',
          port: 8123,
        ),
      );
      // Every hub port, since no port was typed; 3000 for early SMHUBs.
      expect(hubs.probed, [
        '192.168.1.20:8123',
        '192.168.1.20:8080',
        '192.168.1.20:80',
        '192.168.1.20:3000',
      ]);
    });

    test('a typed web port is the only page tried', () async {
      final hubs = _FakeHubs({'192.168.1.20:8443': HubKind.homeAssistant});
      final check = createAddressChecker(
        prober: _FakeProber({}),
        hubProber: hubs,
      );
      final r = await check('192.168.1.20', 8443);
      expect(r.outcome, AddressOutcome.hub);
      expect(hubs.probed, ['192.168.1.20:8443']);
    });

    test('nothing answers → nothing', () async {
      final check = createAddressChecker(
        prober: _FakeProber({}),
        hubProber: _FakeHubs({}),
      );
      expect(
        (await check('192.168.1.20', null)).outcome,
        AddressOutcome.nothing,
      );
    });

    test('a public address is refused before any probe', () async {
      final prober = _FakeProber({'8.8.8.8:1883'});
      final check = createAddressChecker(
        prober: prober,
        hubProber: _FakeHubs({}),
      );
      expect((await check('8.8.8.8', null)).outcome, AddressOutcome.notLocal);
      expect(prober.probed, isEmpty);
    });

    test('a name that does not resolve', () async {
      final prober = _FakeProber({});
      final check = createAddressChecker(
        prober: prober,
        hubProber: _FakeHubs({}),
      );
      final r = await check('zigdash-no-such-host.invalid', null);
      expect(r.outcome, AddressOutcome.notResolved);
      expect(prober.probed, isEmpty);
    });
  });

  group('SocketMqttProber.isConnectionRefused', () {
    test('a refusal by code or by message; a timeout is neither', () {
      expect(
        SocketMqttProber.isConnectionRefused(
          const SocketException('x', osError: OSError('', 111)),
        ),
        isTrue,
      );
      expect(
        SocketMqttProber.isConnectionRefused(
          const SocketException('x', osError: OSError('Connection refused', 0)),
        ),
        isTrue,
      );
      expect(
        SocketMqttProber.isConnectionRefused(
          const SocketException(
            'x',
            osError: OSError('Connection timed out', 110),
          ),
        ),
        isFalse,
      );
    });
  });
}
