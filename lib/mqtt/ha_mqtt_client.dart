// Reaches Zigbee2MQTT through Home Assistant, for phones that cannot reach
// the broker (docs/design/ha-route.md, route A).
//
// Looks like an mqtt_client [mc.MqttClient] to MqttManager and the setup
// probe, but speaks Home Assistant's WebSocket API
// (ws(s)://host:8123/api/websocket):
//   - signs in with the access token (the password slot holds either a
//     long-lived token or `refresh:<token>`, traded first; ha_token.dart);
//   - `mqtt/subscribe` per pattern, and `call_service` mqtt.publish for
//     every publish, any topic, retain allowed. Both need an admin user;
//     a probe subscription on connect finds that out, so a refused sign-in
//     and a missing MQTT integration surface as connect failures, never as
//     a silent connection;
//   - Home Assistant re-sends SUBSCRIBE to its broker for every new
//     subscription, so retained topics (bridge/devices) replay as over MQTT;
//   - pings every keep-alive period, so MqttManager's silence check holds.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:typed_data/typed_data.dart' as typed;

import 'ha_token.dart';

/// Why the probe after sign-in failed, for a more exact message than the
/// return code carries.
enum HaClientProblem {
  /// The stored sign-in no longer works (revoked, or signed out).
  signInRejected,

  /// Signed in, but not as an administrator: Home Assistant's MQTT needs one.
  notAdmin,

  /// Home Assistant has no MQTT integration set up.
  noMqtt,

  /// Nothing answered, or not Home Assistant.
  unreachable,
}

/// What setup's check read from a Home Assistant it can't use
/// (zha-migration.md, Phase 0), for advice that fits it. Nothing is stored.
class HaFacts {
  const HaFacts({this.apps, this.zhaDevices});

  /// Whether the installation has apps (Home Assistant OS or Supervised):
  /// `hassio` is among its components. Null when the read didn't answer.
  final bool? apps;

  /// Devices in ZHA, Home Assistant's own Zigbee, not counting the
  /// coordinator (the only ZHA entry with no parent device). Null when the
  /// read didn't answer.
  final int? zhaDevices;
}

class HaMqttClient extends mc.MqttClient {
  HaMqttClient(this.uri, String clientId) : super(uri.host, clientId);

  /// ws(s)://host:port/api/websocket
  final Uri uri;

  /// Topic the connect probe subscribes to; nothing publishes there.
  static const probeTopic = 'zigdash/probe';

  WebSocket? _socket;
  final _status = mc.MqttClientConnectionStatus();

  /// Single-subscription, so it buffers until the manager listens.
  final _updates =
      StreamController<List<mc.MqttReceivedMessage<mc.MqttMessage>>>();

  var _id = 0;
  final _pending = <int, Completer<Map<String, Object?>>>{};

  /// Home Assistant subscription id per pattern.
  final _subs = <String, int>{};
  Timer? _ping;

  String? haVersion;
  bool? isAdmin;
  HaClientProblem? problem;

  /// Set only by setup's check: read [facts] before closing, whether the
  /// MQTT probe worked or failed as [noMqtt] or [notAdmin]. 3.8.1: a Home
  /// Assistant with the MQTT integration can still keep its Zigbee in ZHA.
  /// Live homes never read them.
  bool readFacts = false;

  /// What the check read, when [readFacts] is set.
  HaFacts? facts;

  @override
  mc.MqttClientConnectionStatus? get connectionStatus => _status;

  @override
  Stream<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? get updates =>
      _updates.stream;

  @override
  Stream<mc.MqttPublishMessage>? get published => null;

  @override
  void logging({required bool on, bool logPayloads = true}) {}

  Completer<Map<String, Object?>>? _auth;

  /// [password] is the stored sign-in; [username] is ignored.
  @override
  Future<mc.MqttClientConnectionStatus?> connect([
    String? username,
    String? password,
  ]) async {
    final attempt = ++_attempt;
    _status
      ..state = mc.MqttConnectionState.connecting
      ..returnCode = mc.MqttConnectReturnCode.noneSpecified;
    problem = null;
    facts = null;
    final base = uri.replace(
      scheme: uri.scheme == 'wss' ? 'https' : 'http',
      path: '/',
    );
    // The exchange first, so the socket's budget is only the socket's.
    final access = await haAccessTokenFor(base, password ?? '');
    if (attempt != _attempt) return _abandoned();
    final token = access.token;
    if (token == null) {
      return _fail(
        access.error == HaTokenError.rejected
            ? HaClientProblem.signInRejected
            : HaClientProblem.unreachable,
      );
    }
    final WebSocket socket;
    try {
      socket = await WebSocket.connect(uri.toString())
          .timeout(Duration(milliseconds: connectTimeoutPeriod));
    } on TimeoutException {
      rethrow;
    } catch (e) {
      problem = HaClientProblem.unreachable;
      _status.state = mc.MqttConnectionState.faulted;
      rethrow;
    }
    if (attempt != _attempt) return _abandoned(socket);
    _socket = socket;
    final auth = _auth = Completer<Map<String, Object?>>();
    socket.listen(
      (frame) => _onFrame(frame, token),
      onDone: _onClosed,
      onError: (_) => _onClosed(),
    );
    final hello = await auth.future.timeout(
      Duration(milliseconds: connectTimeoutPeriod),
      onTimeout: () => const {},
    );
    if (attempt != _attempt) return _abandoned(socket);
    if (hello['type'] != 'auth_ok') {
      await socket.close();
      return _fail(
        hello['type'] == 'auth_invalid'
            ? HaClientProblem.signInRejected
            : HaClientProblem.unreachable,
      );
    }
    haVersion = hello['ha_version'] as String?;

    // Admin and the MQTT integration, found out now rather than on the
    // first real subscription.
    final user = await _call({'type': 'auth/current_user'});
    if (attempt != _attempt) return _abandoned(socket);
    isAdmin = (user?['result'] as Map?)?['is_admin'] as bool?;
    final probe = await _call({'type': 'mqtt/subscribe', 'topic': probeTopic});
    if (attempt != _attempt) return _abandoned(socket);
    if (probe?['success'] != true) {
      final code = ((probe?['error'] as Map?)?['code']).toString();
      if (readFacts) {
        final read = await _readFacts();
        if (attempt != _attempt) return _abandoned(socket);
        facts = read;
      }
      await socket.close();
      return _fail(
        code == 'unauthorized' || isAdmin == false
            ? HaClientProblem.notAdmin
            : HaClientProblem.noMqtt,
      );
    }
    _send({'type': 'unsubscribe_events', 'subscription': probe!['id']});
    if (readFacts) {
      final read = await _readFacts();
      if (attempt != _attempt) return _abandoned(socket);
      facts = read;
    }

    _status
      ..state = mc.MqttConnectionState.connected
      ..returnCode = mc.MqttConnectReturnCode.connectionAccepted;
    _ping?.cancel();
    if (keepAlivePeriod > 0) {
      _ping = Timer.periodic(
        Duration(seconds: keepAlivePeriod),
        (_) => _send({'type': 'ping'}),
      );
    }
    return _status;
  }

  /// Counts connect attempts; [disconnect] moves it on, so an attempt the
  /// owner gave up on (the manager's budget ran out mid-exchange) finds out
  /// at its next step and stops, instead of finishing on its own: an open
  /// socket, a sign-in and a ping timer that nobody holds.
  var _attempt = 0;

  mc.MqttClientConnectionStatus _abandoned([WebSocket? socket]) {
    socket?.close();
    _status
      ..state = mc.MqttConnectionState.disconnected
      ..returnCode = mc.MqttConnectReturnCode.noneSpecified;
    return _status;
  }

  mc.MqttClientConnectionStatus _fail(HaClientProblem why) {
    problem = why;
    _status
      ..state = mc.MqttConnectionState.faulted
      ..returnCode = switch (why) {
        HaClientProblem.signInRejected =>
          mc.MqttConnectReturnCode.badUsernameOrPassword,
        HaClientProblem.notAdmin => mc.MqttConnectReturnCode.notAuthorized,
        HaClientProblem.noMqtt ||
        HaClientProblem.unreachable => mc.MqttConnectReturnCode.noneSpecified,
      };
    return _status;
  }

  /// Two reads that need no admin, side by side, 3 s for both.
  Future<HaFacts> _readFacts() async {
    const limit = Duration(seconds: 3);
    final (config, registry) = await (
      _call({'type': 'get_config'}, limit),
      _call({'type': 'config/device_registry/list'}, limit),
    ).wait;
    bool? apps;
    if (config?['success'] == true) {
      final components = (config!['result'] as Map?)?['components'];
      if (components is List) apps = components.contains('hassio');
    }
    int? zha;
    if (registry?['success'] == true) {
      final devices = registry!['result'];
      if (devices is List) {
        zha = devices.where((d) {
          if (d is! Map || d['via_device_id'] == null) return false;
          final ids = d['identifiers'];
          return ids is List &&
              ids.any((i) => i is List && i.isNotEmpty && i.first == 'zha');
        }).length;
      }
    }
    return HaFacts(apps: apps, zhaDevices: zha);
  }

  int _send(Map<String, Object?> command) {
    final id = ++_id;
    _socket?.add(jsonEncode({'id': id, ...command}));
    return id;
  }

  Future<Map<String, Object?>?> _call(
    Map<String, Object?> command, [
    Duration limit = const Duration(seconds: 10),
  ]) {
    if (_socket == null) return Future.value(null);
    final completer = Completer<Map<String, Object?>>();
    final id = _send(command);
    _pending[id] = completer;
    return completer.future.timeout(
      limit,
      onTimeout: () => <String, Object?>{},
    );
  }

  void _onFrame(Object? data, String token) {
    if (data is! String) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(data);
    } catch (_) {
      return;
    }
    // Home Assistant may batch messages into one array.
    for (final m in decoded is List ? decoded : [decoded]) {
      if (m is! Map) continue;
      final message = Map<String, Object?>.from(m);
      switch (message['type']) {
        case 'auth_required':
          _socket?.add(jsonEncode({'type': 'auth', 'access_token': token}));
        case 'auth_ok' || 'auth_invalid':
          if (_auth?.isCompleted == false) _auth!.complete(message);
        case 'result':
          final id = message['id'];
          _pending.remove(id)?.complete({...message, 'id': id});
        case 'pong':
          pongCallback?.call();
        case 'event':
          final event = message['event'];
          if (event is Map && event['topic'] is String) _deliver(event);
      }
    }
  }

  void _deliver(Map event) {
    final topic = event['topic'] as String;
    final payload = event['payload'];
    final text = payload is String ? payload : jsonEncode(payload);
    final bytes = (mc.MqttClientPayloadBuilder()..addUTF8String(text)).payload!;
    final message = mc.MqttPublishMessage().toTopic(topic).publishData(bytes);
    if (event['retain'] == true) message.setRetain(state: true);
    if (!_updates.isClosed) {
      _updates.add([mc.MqttReceivedMessage(topic, message)]);
    }
  }

  void _onClosed() {
    _ping?.cancel();
    if (_auth?.isCompleted == false) _auth!.complete(const {});
    final wasConnected = _status.state == mc.MqttConnectionState.connected;
    _status.state = mc.MqttConnectionState.disconnected;
    for (final c in _pending.values) {
      if (!c.isCompleted) c.complete(const {});
    }
    _pending.clear();
    _subs.clear();
    if (wasConnected) onDisconnected?.call();
  }

  @override
  mc.Subscription? subscribe(String topic, mc.MqttQos qosLevel) {
    if (_subs.containsKey(topic)) return null;
    final completer = Completer<Map<String, Object?>>();
    final id = _send({
      'type': 'mqtt/subscribe',
      'topic': topic,
      'qos': qosLevel.index,
    });
    _subs[topic] = id;
    _pending[id] = completer;
    completer.future.then((r) {
      if (r['success'] == true) {
        onSubscribed?.call(topic);
      } else {
        onSubscribeFail?.call(topic);
      }
    });
    return null;
  }

  @override
  void unsubscribe(String topic, {expectAcknowledge = false}) {
    final id = _subs.remove(topic);
    if (id == null) return;
    _send({'type': 'unsubscribe_events', 'subscription': id});
  }

  @override
  int publishMessage(
    String topic,
    mc.MqttQos qualityOfService,
    typed.Uint8Buffer data, {
    bool retain = false,
  }) {
    if (_socket == null) return -1;
    return _send({
      'type': 'call_service',
      'domain': 'mqtt',
      'service': 'publish',
      'service_data': {
        'topic': topic,
        'payload': mc.MqttPublishPayload.bytesToStringAsString(data),
        'qos': qualityOfService.index,
        'retain': retain,
      },
    });
  }

  @override
  void disconnect() {
    _attempt++;
    _ping?.cancel();
    final wasConnected = _status.state == mc.MqttConnectionState.connected;
    _status.state = mc.MqttConnectionState.disconnected;
    final socket = _socket;
    _socket = null;
    socket?.close();
    _subs.clear();
    if (wasConnected) onDisconnected?.call();
  }
}
