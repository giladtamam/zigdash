import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/mqtt/ha_address.dart';

// docs/design/ha-share-paste.md: Home Assistant's address in text that was
// pasted or shared.
void main() {
  group("the Home Assistant app's Share server link", () {
    test('the server address inside it is taken, decoded', () {
      expect(
        haAddressIn(
          'https://my.home-assistant.io/invite/#url=http%3A%2F%2F192.168.1.20%3A8123',
        ),
        'http://192.168.1.20:8123',
      );
      // As seen on a phone, 2026-11-06 (app 2026.10.1): not encoded, with
      // a trailing slash.
      expect(
        haAddressIn('https://my.home-assistant.io/invite/#url=http://ha.example.com/'),
        'http://ha.example.com',
      );
      expect(
        haAddressIn('https://my.home-assistant.io/invite/#url=https://abc.ui.nabu.casa'),
        'https://abc.ui.nabu.casa',
      );
    });

    test('other things in the link, or around it, do not matter', () {
      expect(
        haAddressIn(
          'My Home Assistant\nhttps://my.home-assistant.io/invite/#name=Home&url=https%3A%2F%2Fha.example.com%3A8443&x=1',
        ),
        'https://ha.example.com:8443',
      );
      expect(
        haAddressIn('https://my.home-assistant.io/invite/?url=http%3A%2F%2F10.0.0.5%3A8123'),
        'http://10.0.0.5:8123',
      );
    });

    test('a My Home Assistant page that is not an invite is no address', () {
      expect(
        haAddressIn('https://my.home-assistant.io/redirect/config/'),
        isNull,
      );
      expect(haAddressIn('https://my.home-assistant.io/invite/'), isNull);
      expect(haAddressIn('https://my.home-assistant.io/invite/#url='), isNull);
    });

    test('an http link to a remote name is tried on https first', () {
      List<String> c(String s) =>
          haBaseCandidates(s).map((u) => u.toString()).toList();
      expect(c('http://ha.example.com'), [
        'https://ha.example.com',
        'http://ha.example.com',
      ]);
      // A port or a home address is taken as given.
      expect(c('http://ha.example.com:8123'), ['http://ha.example.com:8123']);
      expect(c('http://192.168.1.20'), ['http://192.168.1.20']);
      expect(c('https://ha.example.com'), ['https://ha.example.com']);
    });
  });

  group('a page shared or copied from a browser', () {
    test('the link, without its path', () {
      expect(
        haAddressIn('http://192.168.1.20:8123/lovelace/0'),
        'http://192.168.1.20:8123',
      );
      expect(
        haAddressIn('https://abc.ui.nabu.casa/config/dashboard?x=1#y'),
        'https://abc.ui.nabu.casa',
      );
      expect(haAddressIn('HTTP://HomeAssistant.local:8123/'), 'http://homeassistant.local:8123');
    });

    test('a title before the link, as some browsers send it', () {
      expect(
        haAddressIn('Overview – Home Assistant\nhttp://192.168.1.20:8123/lovelace/0'),
        'http://192.168.1.20:8123',
      );
      expect(
        haAddressIn('Look at this: https://ha.example.com/lovelace, nice.'),
        'https://ha.example.com',
      );
    });

    test('of two links, the first', () {
      expect(
        haAddressIn('http://192.168.1.20:8123 or https://abc.ui.nabu.casa'),
        'http://192.168.1.20:8123',
      );
    });
  });

  group('one word that reads as a host', () {
    test('an address or a name, with or without a port, as typed', () {
      expect(haAddressIn('192.168.1.20'), '192.168.1.20');
      expect(haAddressIn(' 192.168.1.20:8123 \n'), '192.168.1.20:8123');
      expect(haAddressIn('homeassistant.local:8123'), 'homeassistant.local:8123');
      expect(haAddressIn('homeassistant'), 'homeassistant');
      expect(haAddressIn('abc.ui.nabu.casa'), 'abc.ui.nabu.casa');
    });

    test('anything else is no address', () {
      expect(haAddressIn(''), isNull);
      expect(haAddressIn('   '), isNull);
      expect(haAddressIn('milk, eggs, bread'), isNull);
      expect(haAddressIn('password123'), isNull);
      expect(haAddressIn('me@example.com'), isNull);
      expect(haAddressIn('two words'), isNull);
      expect(haAddressIn('mqtt://broker.local'), isNull);
      // A long-lived token is not an address.
      expect(
        haAddressIn('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhIn0.abc'),
        isNull,
      );
    });
  });
}
