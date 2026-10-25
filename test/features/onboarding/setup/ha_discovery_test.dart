import 'package:flutter_test/flutter_test.dart';
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
}
