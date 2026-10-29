// The Zigbee2MQTT page reader against a local WebSocket server: the
// `bridge/info` frame, a page with a token (4401), and silence.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/discovery/z2m_frontend.dart';
import 'package:zigdash/features/connections/discovery/z2m_frontend_fetch.dart';

void main() {
  late HttpServer server;

  Future<void> serve(void Function(WebSocket ws) onSocket) async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path == '/api' &&
          WebSocketTransformer.isUpgradeRequest(req)) {
        onSocket(await WebSocketTransformer.upgrade(req));
      } else {
        req.response.statusCode = 404;
        await req.response.close();
      }
    });
  }

  tearDown(() => server.close(force: true));

  test('reads the mqtt section of bridge/info', () async {
    await serve((ws) {
      ws.add(jsonEncode({'topic': 'bridge/state', 'payload': 'online'}));
      ws.add(
        jsonEncode({
          'topic': 'bridge/info',
          'payload': {
            'config': {
              'mqtt': {'server': 'mqtt://mosquitto:1883', 'user': 'z2m'},
            },
          },
        }),
      );
    });
    final mqtt = await fetchZ2mMqttConfig('127.0.0.1', server.port);
    expect(mqtt?['server'], 'mqtt://mosquitto:1883');
    expect(mqtt?['user'], 'z2m');
  });

  // 2.10.4: Zigbee2MQTT's frontend accepts the socket, then closes it with
  // 4401 when `frontend.auth_token` is set and the token is missing.
  test('a page with a token closes with 4401: locked, not silent', () async {
    await serve((ws) => ws.close(4401, 'Unauthorized'));
    await expectLater(
      fetchZ2mMqttConfig('127.0.0.1', server.port),
      throwsA(isA<Z2mPageLocked>()),
    );
  });

  test('a page that says nothing in time is null', () async {
    await serve((ws) {});
    expect(
      await fetchZ2mMqttConfig(
        '127.0.0.1',
        server.port,
        timeout: const Duration(milliseconds: 300),
      ),
      isNull,
    );
  });

  // 3.1.13: the page replays bridge/devices on connect, even when the
  // broker lost it.
  test('reads the device list the page replays', () async {
    await serve((ws) {
      ws.add(jsonEncode({'topic': 'bridge/state', 'payload': 'online'}));
      ws.add(
        jsonEncode({
          'topic': 'bridge/devices',
          'payload': [
            {'ieee_address': '0x1', 'type': 'Coordinator'},
            {'ieee_address': '0x2', 'friendly_name': 'Lamp', 'type': 'Router'},
          ],
        }),
      );
    });
    final list = await fetchZ2mDeviceList('127.0.0.1', server.port);
    expect(jsonDecode(list!), hasLength(2));
  });

  test('a locked page gives no device list', () async {
    await serve((ws) => ws.close(4401, 'Unauthorized'));
    expect(await fetchZ2mDeviceList('127.0.0.1', server.port), isNull);
  });

  test('other frames only: no list', () {
    expect(z2mDeviceListOf('{"topic":"bridge/info","payload":{}}'), isNull);
    expect(z2mDeviceListOf('{"topic":"bridge/devices","payload":{}}'), isNull);
    expect(z2mDeviceListOf('not json'), isNull);
  });
}
