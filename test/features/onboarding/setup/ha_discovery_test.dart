import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';
import 'package:zigdash/features/onboarding/setup/ha_discovery.dart';

void main() {
  Map<String, Object?> service({
    String host = '192.168.68.64',
    int port = 8123,
    Map<String, String> txt = const {},
  }) => {'name': 'Home', 'host': host, 'port': port, 'txt': txt};

  test('its own internal address, when it needs no .local name', () {
    final f = haFoundOf(
      service(
        txt: {
          'internal_url': 'https://ha.home.lan:8443',
          'location_name': 'Home',
          'uuid': 'abc',
        },
      ),
    )!;
    expect(f.address, 'https://ha.home.lan:8443');
    expect(f.name, 'Home');
    expect(f.uuid, 'abc');
    expect(f.byName, isFalse);
  });

  test('a .local internal address becomes the IP, with its scheme', () {
    final f = haFoundOf(
      service(txt: {'internal_url': 'https://homeassistant.local:8123'}),
    )!;
    expect(f.address, 'https://192.168.68.64:8123');
  });

  test('no TXT record: http on the IP and port it resolved to', () {
    expect(
      haFoundOf(service(port: 8124))!.address,
      'http://192.168.68.64:8124',
    );
  });

  test('an empty name is no name', () {
    expect(haFoundOf(service(txt: {'location_name': ' '}))!.name, isNull);
  });

  test('IPv6 is bracketed', () {
    expect(
      haFoundOf(service(host: 'fe80::1'))!.address,
      'http://[fe80::1]:8123',
    );
  });

  test('nothing usable: null', () {
    expect(haFoundOf({'host': '', 'port': 8123}), isNull);
    expect(haFoundOf({'host': '10.0.0.2'}), isNull);
  });

  test('one per instance: same uuid or same address', () {
    final found = haFoundIn([
      service(txt: {'uuid': 'u1'}),
      service(host: '192.168.68.65', txt: {'uuid': 'u1'}),
      service(),
      service(host: '192.168.68.70', txt: {'uuid': 'u2'}),
      'junk',
    ]);
    expect(found.map((f) => f.address), [
      'http://192.168.68.64:8123',
      'http://192.168.68.70:8123',
    ]);
  });

  group('3.3.1: the sweep of the phone\'s /24 on 8123', () {
    test('finds each Home Assistant, in address order, never the phone', () async {
      final prober = _Prober({
        '192.168.1.40': HubKind.homeAssistant,
        '192.168.1.7': HubKind.homeAssistant,
        '192.168.1.9': HubKind.zigbee2mqtt,
      });
      final found = await sweepForHomeAssistant('192.168.1.23', prober);
      expect(found.map((f) => f.address), [
        'http://192.168.1.7:8123',
        'http://192.168.1.40:8123',
      ]);
      expect(found.every((f) => f.bySweep), isTrue);
      expect(prober.ports, {8123});
      expect(prober.hosts, hasLength(253));
      expect(prober.hosts, isNot(contains('192.168.1.23')));
    });

    test('a probe that throws is nothing found', () async {
      final found = await sweepForHomeAssistant(
        '10.0.0.5',
        _Prober(const {}, throws: true),
      );
      expect(found, isEmpty);
    });
  });
}

class _Prober implements HubProber {
  _Prober(this.kinds, {this.throws = false});
  final Map<String, HubKind> kinds;
  final bool throws;
  final hosts = <String>{};
  final ports = <int>{};

  @override
  Future<HubKind?> probe(String host, int port) async {
    hosts.add(host);
    ports.add(port);
    if (throws) throw StateError('no');
    return kinds[host];
  }
}
