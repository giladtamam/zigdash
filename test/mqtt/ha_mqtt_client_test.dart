// HaMqttClient against an in-process fake of Home Assistant's WebSocket
// API: sign-in, the admin and MQTT probe, subscriptions, publishes as
// mqtt.publish, pings, and the refresh-token exchange.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/mqtt/ha_mqtt_client.dart';
import 'package:zigdash/mqtt/ha_token.dart';

/// What the fake Home Assistant does.
class _FakeHa {
  _FakeHa({
    this.accessToken = 'access',
    this.refreshToken = 'refresh',
    this.admin = true,
    this.mqtt = true,
    this.refreshWorks = true,
    this.refreshDelay = Duration.zero,
  });

  final String accessToken;
  final String refreshToken;
  final bool admin;
  final bool mqtt;
  final bool refreshWorks;

  /// How long the token exchange takes to answer.
  final Duration refreshDelay;

  late HttpServer server;
  final received = <Map<String, Object?>>[];
  final sockets = <WebSocket>[];
  var refreshCalls = 0;

  Uri get wsUri => Uri.parse('ws://127.0.0.1:${server.port}/api/websocket');

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      if (request.uri.path == '/auth/token') {
        refreshCalls++;
        if (refreshDelay > Duration.zero) await Future<void>.delayed(refreshDelay);
        final body = Uri.splitQueryString(await utf8.decodeStream(request));
        final ok =
            refreshWorks &&
            body['grant_type'] == 'refresh_token' &&
            body['refresh_token'] == refreshToken &&
            body['client_id'] == haClientId;
        request.response.statusCode = ok ? 200 : 400;
        request.response.write(
          jsonEncode(
            ok
                ? {'access_token': accessToken, 'expires_in': 1800}
                : {'error': 'invalid_grant'},
          ),
        );
        await request.response.close();
        return;
      }
      if (request.uri.path != '/api/websocket') {
        request.response.statusCode = 404;
        await request.response.close();
        return;
      }
      final socket = await WebSocketTransformer.upgrade(request);
      sockets.add(socket);
      socket.add(jsonEncode({'type': 'auth_required', 'ha_version': '2026.1'}));
      socket.listen((frame) {
        final m = Map<String, Object?>.from(jsonDecode(frame as String) as Map);
        received.add(m);
        // A ping can arrive after a test closed this socket.
        try {
          switch (m['type']) {
            case 'auth':
              socket.add(
                jsonEncode(
                  m['access_token'] == accessToken
                      ? {'type': 'auth_ok', 'ha_version': '2026.1'}
                      : {'type': 'auth_invalid', 'message': 'Invalid'},
                ),
              );
            case 'auth/current_user':
              socket.add(
                jsonEncode({
                  'id': m['id'],
                  'type': 'result',
                  'success': true,
                  'result': {'is_admin': admin},
                }),
              );
            case 'mqtt/subscribe':
              if (!mqtt) {
                socket.add(
                  jsonEncode({
                    'id': m['id'],
                    'type': 'result',
                    'success': false,
                    'error': {'code': 'unknown_command'},
                  }),
                );
              } else if (!admin) {
                socket.add(
                  jsonEncode({
                    'id': m['id'],
                    'type': 'result',
                    'success': false,
                    'error': {'code': 'unauthorized'},
                  }),
                );
              } else {
                socket.add(
                  jsonEncode({
                    'id': m['id'],
                    'type': 'result',
                    'success': true,
                  }),
                );
                if (m['topic'] == 'zigbee2mqtt/bridge/state') {
                  socket.add(
                    jsonEncode({
                      'id': m['id'],
                      'type': 'event',
                      'event': {
                        'topic': 'zigbee2mqtt/bridge/state',
                        'payload': '{"state":"online"}',
                        'qos': 0,
                        'retain': true,
                      },
                    }),
                  );
                }
              }
            case 'ping':
              socket.add(jsonEncode({'id': m['id'], 'type': 'pong'}));
            case 'call_service' || 'unsubscribe_events':
              socket.add(
                jsonEncode({'id': m['id'], 'type': 'result', 'success': true}),
              );
          }
        } catch (_) {}
      });
    });
  }

  Future<void> stop() => server.close(force: true);
}

void main() {
  late _FakeHa ha;

  Future<HaMqttClient> connect(String stored) async {
    final client = HaMqttClient(ha.wsUri, 'zd-test')
      ..connectTimeoutPeriod = 3000
      ..keepAlivePeriod = 1;
    await client.connect(null, stored);
    return client;
  }

  // flutter_test answers every HttpClient request with 400; the refresh
  // exchange needs the real one to reach the fake.
  setUp(() => HttpOverrides.global = null);
  tearDown(() => ha.stop());

  test(
    'signs in with a long-lived token and probes MQTT before connected',
    () async {
      ha = _FakeHa();
      await ha.start();
      final client = await connect('access');
      expect(client.connectionStatus?.state, mc.MqttConnectionState.connected);
      expect(client.isAdmin, isTrue);
      expect(client.haVersion, '2026.1');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final types = ha.received.map((m) => m['type']).toList();
      expect(types, [
        'auth',
        'auth/current_user',
        'mqtt/subscribe',
        'unsubscribe_events',
      ]);
      expect(
        ha.received.firstWhere((m) => m['type'] == 'mqtt/subscribe')['topic'],
        HaMqttClient.probeTopic,
      );
      expect(ha.refreshCalls, 0);
      client.disconnect();
    },
  );

  test('a refresh token is traded for an access token first', () async {
    ha = _FakeHa();
    await ha.start();
    final client = await connect(haStoredRefresh('refresh'));
    expect(client.connectionStatus?.state, mc.MqttConnectionState.connected);
    expect(ha.refreshCalls, 1);
    client.disconnect();
  });

  test('a refused refresh token is a rejected sign-in, no socket', () async {
    ha = _FakeHa(refreshWorks: false);
    await ha.start();
    final client = await connect(haStoredRefresh('refresh'));
    expect(client.connectionStatus?.state, mc.MqttConnectionState.faulted);
    expect(client.problem, HaClientProblem.signInRejected);
    expect(
      client.connectionStatus?.returnCode,
      mc.MqttConnectReturnCode.badUsernameOrPassword,
    );
    expect(ha.sockets, isEmpty);
  });

  test('a wrong token is a rejected sign-in', () async {
    ha = _FakeHa();
    await ha.start();
    final client = await connect('stale');
    expect(client.problem, HaClientProblem.signInRejected);
    expect(client.connectionStatus?.state, mc.MqttConnectionState.faulted);
  });

  test('not an admin: never reported connected', () async {
    ha = _FakeHa(admin: false);
    await ha.start();
    final client = await connect('access');
    expect(client.connectionStatus?.state, mc.MqttConnectionState.faulted);
    expect(client.problem, HaClientProblem.notAdmin);
    expect(
      client.connectionStatus?.returnCode,
      mc.MqttConnectReturnCode.notAuthorized,
    );
  });

  test('no MQTT integration: not MQTT', () async {
    ha = _FakeHa(mqtt: false);
    await ha.start();
    final client = await connect('access');
    expect(client.connectionStatus?.state, mc.MqttConnectionState.faulted);
    expect(client.problem, HaClientProblem.noMqtt);
    expect(
      client.connectionStatus?.returnCode,
      mc.MqttConnectReturnCode.noneSpecified,
    );
  });

  test(
    'subscribes, delivers events with retain, publishes as mqtt.publish',
    () async {
      ha = _FakeHa();
      await ha.start();
      final client = await connect('access');
      final got = <mc.MqttReceivedMessage<mc.MqttMessage>>[];
      final sub = client.updates!.listen(got.addAll);
      var acked = <String>[];
      client.onSubscribed = acked.add;
      client.subscribe('zigbee2mqtt/bridge/state', mc.MqttQos.atLeastOnce);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(acked, ['zigbee2mqtt/bridge/state']);
      expect(got.single.topic, 'zigbee2mqtt/bridge/state');
      final pub = got.single.payload as mc.MqttPublishMessage;
      expect(
        mc.MqttPublishPayload.bytesToStringAsString(pub.payload.message),
        '{"state":"online"}',
      );
      expect(pub.header!.retain, isTrue);

      final payload =
          (mc.MqttClientPayloadBuilder()..addUTF8String('{"state":"OPEN"}'))
              .payload!;
      client.publishMessage(
        'zigbee2mqtt/תריס/set',
        mc.MqttQos.atLeastOnce,
        payload,
        retain: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final call = ha.received.lastWhere((m) => m['type'] == 'call_service');
      expect(call['domain'], 'mqtt');
      expect(call['service'], 'publish');
      expect(call['service_data'], {
        'topic': 'zigbee2mqtt/תריס/set',
        'payload': '{"state":"OPEN"}',
        'qos': 1,
        'retain': true,
      });
      await sub.cancel();
      client.disconnect();
    },
  );

  test('pings every keep-alive period and reports pongs', () async {
    ha = _FakeHa();
    await ha.start();
    final client = await connect('access');
    var pongs = 0;
    client.pongCallback = () => pongs++;
    await Future<void>.delayed(const Duration(milliseconds: 2300));
    expect(
      ha.received.where((m) => m['type'] == 'ping').length,
      greaterThanOrEqualTo(2),
    );
    expect(pongs, greaterThanOrEqualTo(2));
    client.disconnect();
  });

  test(
    'disconnected mid-exchange: the attempt stops, no socket, no sign-in',
    () async {
      // The manager's budget ran out while the token exchange was still on
      // its way: the attempt it gave up on must not finish on its own.
      ha = _FakeHa(refreshDelay: const Duration(milliseconds: 300));
      await ha.start();
      final client = HaMqttClient(ha.wsUri, 'zd-test')
        ..connectTimeoutPeriod = 3000
        ..keepAlivePeriod = 1;
      var dropped = 0;
      client.onDisconnected = () => dropped++;
      final attempt = client.connect(null, haStoredRefresh('refresh'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      client.disconnect();
      final status = await attempt;
      expect(status?.state, mc.MqttConnectionState.disconnected);
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      expect(ha.sockets, isEmpty);
      expect(ha.received, isEmpty);
      expect(dropped, 0);
      expect(client.connectionStatus?.state, mc.MqttConnectionState.disconnected);
    },
  );

  test('the server closing the socket reports a disconnect', () async {
    ha = _FakeHa();
    await ha.start();
    final client = await connect('access');
    var dropped = 0;
    client.onDisconnected = () => dropped++;
    await ha.sockets.single.close();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(dropped, 1);
    expect(client.connectionStatus?.state, mc.MqttConnectionState.disconnected);
  });
}
