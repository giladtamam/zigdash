import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/onboarding/setup/ha_address_shape.dart';
import 'package:zigdash/mqtt/ha_address.dart';

void main() {
  const phone = '192.168.68.40';

  HaAddressShape shape(String typed, {String? phoneIp = phone}) =>
      haAddressShapeOf(typed, phoneIp: phoneIp);

  test('nothing usable is empty', () {
    expect(shape(''), HaAddressShape.empty);
    expect(shape('  '), HaAddressShape.empty);
    expect(shape('http://'), HaAddressShape.empty);
  });

  test("a private IP is judged against the phone's /22", () {
    expect(shape('192.168.68.58'), HaAddressShape.sameNetwork);
    // A Deco mesh's /22: 68–71 is one network.
    expect(shape('http://192.168.71.2:8123/lovelace'), HaAddressShape.sameNetwork);
    expect(shape('192.168.1.20'), HaAddressShape.otherNetwork);
    expect(shape('10.0.0.5'), HaAddressShape.otherNetwork);
    expect(shape('192.168.1.20', phoneIp: null), HaAddressShape.privateIp);
  });

  test('names and remote addresses', () {
    expect(shape('homeassistant.local'), HaAddressShape.localName);
    expect(shape('homeassistant:8123'), HaAddressShape.localName);
    expect(shape('https://abcd.ui.nabu.casa/'), HaAddressShape.nabuCasa);
    expect(shape('https://home.duckdns.org:8443'), HaAddressShape.remoteName);
    expect(shape('8.8.8.8'), HaAddressShape.publicIp);
  });

  test('the port class', () {
    expect(haPortClassOf(haBaseUri('192.168.1.20')!), '8123');
    expect(haPortClassOf(haBaseUri('https://a.ui.nabu.casa')!), '443');
    expect(haPortClassOf(haBaseUri('https://h.duckdns.org:8443')!), 'other');
  });
}
