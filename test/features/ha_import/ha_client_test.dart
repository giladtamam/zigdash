import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/ha_import/ha_client.dart';

/// A fake Home Assistant: the WebSocket handshake and the four registry
/// reads, as Home Assistant answers them. [noFloors] answers the floor
/// read with an error, like a Home Assistant that predates floors.
Future<HttpServer> _fakeHa({
  String token = 'good',
  bool noFloors = false,
  bool batch = false,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    if (request.uri.path != '/api/websocket' ||
        !WebSocketTransformer.isUpgradeRequest(request)) {
      request.response
        ..statusCode = 404
        ..close();
      return;
    }
    final ws = await WebSocketTransformer.upgrade(request);
    ws.add(jsonEncode({'type': 'auth_required', 'ha_version': '2026.1.1'}));
    ws.listen((frame) {
      final m = jsonDecode(frame as String) as Map;
      if (m['type'] == 'auth') {
        ws.add(
          jsonEncode({
            'type': m['access_token'] == token ? 'auth_ok' : 'auth_invalid',
          }),
        );
        return;
      }
      Map<String, Object?> ok(Object? result) => {
        'id': m['id'],
        'type': 'result',
        'success': true,
        'result': result,
      };
      final reply = switch (m['type']) {
        'config/device_registry/list' => ok([
          {
            'id': 'd1',
            'identifiers': [
              ['mqtt', 'zigbee2mqtt_0xa4c13836276df66f'],
            ],
            'name_by_user': 'Living room motion',
            'area_id': 'living_room',
          },
        ]),
        'config/area_registry/list' => ok([
          {
            'area_id': 'living_room',
            'name': 'Living Room',
            'floor_id': 'ground_floor',
          },
        ]),
        'config/floor_registry/list' when noFloors => {
          'id': m['id'],
          'type': 'result',
          'success': false,
          'error': {'code': 'unknown_command', 'message': 'Unknown command.'},
        },
        'config/floor_registry/list' => ok([
          {'floor_id': 'ground_floor', 'name': 'Ground floor', 'level': 0},
        ]),
        'config/entity_registry/list_for_display' => ok({
          'entity_categories': {},
          'entities': <Object?>[],
        }),
        _ => null,
      };
      if (reply == null) return;
      // An unrelated event first, as a live Home Assistant may send.
      final event = {'id': 999, 'type': 'event', 'event': {}};
      ws.add(jsonEncode(batch ? [event, reply] : reply));
    });
  });
  return server;
}

Uri _base(HttpServer s) => Uri.parse('http://127.0.0.1:${s.port}');

void main() {
  group('haBaseUri', () {
    test('what people type becomes Home Assistant\'s address', () {
      expect(
        haBaseUri('192.168.68.52').toString(),
        'http://192.168.68.52:8123',
      );
      expect(
        haBaseUri('http://192.168.68.52:8123/lovelace/0').toString(),
        'http://192.168.68.52:8123',
      );
      expect(
        haBaseUri('https://abc.ui.nabu.casa').toString(),
        'https://abc.ui.nabu.casa',
      );
      expect(haBaseUri(''), isNull);
      expect(haBaseUri('mqtt://broker'), isNull);
    });

    test('3.3.4: a remote name without a scheme is https first', () {
      List<String> c(String s) =>
          haBaseCandidates(s).map((u) => u.toString()).toList();
      expect(c('abc.ui.nabu.casa'), ['https://abc.ui.nabu.casa']);
      expect(c('myhome.duckdns.org'), [
        'https://myhome.duckdns.org:8123',
        'https://myhome.duckdns.org',
        'http://myhome.duckdns.org:8123',
      ]);
      expect(c('ha.example.com'), [
        'https://ha.example.com',
        'https://ha.example.com:8123',
        'http://ha.example.com:8123',
      ]);
      expect(c('myhome.duckdns.org:8123'), [
        'https://myhome.duckdns.org:8123',
        'http://myhome.duckdns.org:8123',
      ]);
      // Home addresses without a port: 8123, then port 80, where Home
      // Assistant OS installed since 2026.8 answers.
      expect(c('homeassistant.local'), [
        'http://homeassistant.local:8123',
        'http://homeassistant.local',
      ]);
      expect(c('ha.lan'), ['http://ha.lan:8123', 'http://ha.lan']);
      expect(c('homeassistant'), [
        'http://homeassistant:8123',
        'http://homeassistant',
      ]);
      expect(c('192.168.1.20'), [
        'http://192.168.1.20:8123',
        'http://192.168.1.20',
      ]);
      expect(c('8.8.8.8'), ['http://8.8.8.8:8123', 'http://8.8.8.8']);
      // A port that was typed is the only one tried.
      expect(c('192.168.1.20:8123'), ['http://192.168.1.20:8123']);
      expect(c('192.168.1.20:80'), ['http://192.168.1.20']);
      expect(c('homeassistant.local:8124'), ['http://homeassistant.local:8124']);
      expect(c('192.168.1.20:80/lovelace/0'), ['http://192.168.1.20']);
      // The same for a remote name: a typed 443 is https there, not 8123.
      expect(c('ha.example.com:443'), [
        'https://ha.example.com',
        'http://ha.example.com:443',
      ]);
      // An IPv6 address is not a host and a port.
      expect(c('[fe80::1]'), ['http://[fe80::1]:8123', 'http://[fe80::1]']);
      expect(c('[fe80::1]:8123'), ['http://[fe80::1]:8123']);
      expect(c('http://ha.example.com:8123'), ['http://ha.example.com:8123']);
      expect(haBaseUri('ha.example.com').toString(), 'https://ha.example.com');
    });

    test('the WebSocket address follows the scheme', () {
      expect(
        haWebSocketUri(haBaseUri('192.168.68.52')!).toString(),
        'ws://192.168.68.52:8123/api/websocket',
      );
      expect(
        haWebSocketUri(haBaseUri('https://abc.ui.nabu.casa')!).toString(),
        'wss://abc.ui.nabu.casa/api/websocket',
      );
    });
  });

  group('readHaRegistry', () {
    test('reads the registries with a good token', () async {
      final ha = await _fakeHa();
      addTearDown(ha.close);
      final r = await readHaRegistry(_base(ha), 'good');
      expect(r.error, isNull);
      expect(r.registry!.devices.single.userName, 'Living room motion');
      expect(r.registry!.devices.single.z2mIeee, '0xa4c13836276df66f');
      expect(r.registry!.floors.single.name, 'Ground floor');
    });

    test('messages batched in one frame are read too', () async {
      final ha = await _fakeHa(batch: true);
      addTearDown(ha.close);
      final r = await readHaRegistry(_base(ha), 'good');
      expect(r.registry!.areas.single.name, 'Living Room');
    });

    test('no floor registry: still imports, without floors', () async {
      final ha = await _fakeHa(noFloors: true);
      addTearDown(ha.close);
      final r = await readHaRegistry(_base(ha), 'good');
      expect(r.error, isNull);
      expect(r.registry!.floors, isEmpty);
    });

    test('a refused token says so', () async {
      final ha = await _fakeHa();
      addTearDown(ha.close);
      final r = await readHaRegistry(_base(ha), 'wrong');
      expect(r.error, HaReadError.badToken);
    });

    test('a web server that is not Home Assistant', () async {
      final web = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(web.close);
      web.listen(
        (r) => r.response
          ..statusCode = 404
          ..close(),
      );
      final r = await readHaRegistry(_base(web), 'good');
      expect(r.error, HaReadError.notHomeAssistant);
    });

    test('nothing at the address', () async {
      final free = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = free.port;
      await free.close();
      final r = await readHaRegistry(
        Uri.parse('http://127.0.0.1:$port'),
        'good',
      );
      expect(r.error, HaReadError.unreachable);
    });
  });
}
