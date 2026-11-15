import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../mqtt/endpoint.dart';
import '../../mqtt/mqtt_manager.dart';
import '../../mqtt/relay_mqtt_client.dart' show defaultRelayTransport;
import '../../remote/remote_home.dart';
import 'chat_api.dart';
import 'chat_wire.dart';

/// One entry of the Engine's Chat audit: an action, a refusal or a
/// rejected request.
class ChatAuditEntry {
  const ChatAuditEntry({required this.at, required this.client, required this.tool, this.device, required this.result});

  final DateTime at;
  final String client;
  final String tool;
  final String? device;
  final String result;

  static ChatAuditEntry? fromJson(Object? j) {
    if (j is! Map) return null;
    final at = DateTime.tryParse('${j['at']}');
    if (at == null) return null;
    return ChatAuditEntry(
      at: at,
      client: '${j['client'] ?? ''}',
      tool: '${j['tool'] ?? '-'}',
      device: j['device'] is String ? j['device'] as String : null,
      result: '${j['result'] ?? ''}',
    );
  }
}

/// A line to the hub's Engine for Chat requests: the home broker, or the
/// relay's opaque topics.
abstract class ChatPipe {
  Stream<String> listen(String topic);
  void publish(String topic, String payload);
  Future<void> close();
}

/// One sealed request to a Chat client's Engine side, as
/// tool/zigdash-chat/link.mjs sends it: a fresh id and the time, the
/// client's token; a "stale" answer is retried once with the Engine's
/// time. Null when the hub doesn't answer; throws [ChatException]
/// (`refused`) for a client the Engine doesn't have.
Future<Map<String, Object?>?> chatRequest(
  ChatPipe pipe, {
  required String requestTopic,
  required String answerTopic,
  required String token,
  required Uint8List key,
  required String tool,
  Map<String, Object?> args = const {},
  Duration timeout = const Duration(seconds: 8),
  DateTime Function() now = DateTime.now,
}) async {
  var offset = 0;
  var id = '';
  final done = Completer<Map<String, Object?>?>();
  void send() {
    id = ChatWire.newRequestId();
    pipe.publish(requestTopic, ChatWire.seal(key, {
      'id': id,
      'at': now().millisecondsSinceEpoch + offset,
      'token': token,
      'tool': tool,
      'args': args,
    }));
  }

  var retried = false;
  final sub = pipe.listen(answerTopic).listen((text) {
    if (done.isCompleted) return;
    if (text.trimLeft().startsWith('{')) {
      try {
        if ((jsonDecode(text) as Map)['error'] == 'not_linked') {
          done.completeError(const ChatException(ChatFail.refused));
        }
      } catch (_) {}
      return;
    }
    final msg = ChatWire.unseal(key, text);
    if (msg == null || msg['id'] != id) return;
    final at = msg['at'];
    if (at is num) offset = at.toInt() - now().millisecondsSinceEpoch;
    if (msg['error'] == 'stale' && !retried) {
      retried = true;
      send();
      return;
    }
    done.complete(msg);
  });
  try {
    send();
    return await done.future.timeout(timeout, onTimeout: () => null);
  } finally {
    await sub.cancel();
  }
}

/// What the app does on the hub for Chat (chat-linking.md §1, §3).
abstract class ChatHub {
  /// Publishes the client's config, retained, on the home broker; the
  /// Engine takes it in and clears it. Throws [ChatException] `notAtHome`
  /// when the phone isn't on the home network: through the relay the hub
  /// would never get it.
  Future<void> createClient(String connectionId, String clientId, String config);

  /// Deletes the client on the hub (an empty retained config); false when
  /// the phone isn't at home, so it has to wait.
  Future<bool> revokeClient(String connectionId, String clientId);

  /// The client's own audit entries, at home or through the relay; null
  /// when the hub didn't answer.
  Future<List<ChatAuditEntry>?> audit(
    String connectionId, {
    required String clientId,
    required String token,
    required Uint8List key,
    RemoteHome? relay,
  });
}

class _ManagerPipe implements ChatPipe {
  _ManagerPipe(this._mgr);
  final MqttManager _mgr;
  final _topics = <String>{};

  @override
  Stream<String> listen(String topic) {
    _topics.add(topic);
    return _mgr.subscribe(topic).map((m) => m.payload);
  }

  @override
  void publish(String topic, String payload) => _mgr.publish(topic, payload, '', qos: mc.MqttQos.atLeastOnce);

  @override
  Future<void> close() async {
    for (final t in _topics) {
      _mgr.unsubscribe(t);
    }
  }
}

/// Straight to the relay with this phone's login: the phone's usual relay
/// connection only carries the sealed device states (`homes/<id>/s/#`).
class _RelayPipe implements ChatPipe {
  _RelayPipe(this._client);
  final mc.MqttClient _client;

  static Future<_RelayPipe?> open(RemoteHome home) async {
    final id = 'zdchat-${Random.secure().nextInt(1 << 32).toRadixString(16)}';
    final client = defaultRelayTransport(home, id)
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..connectTimeoutPeriod = 8000
      ..connectionMessage = mc.MqttConnectMessage().withClientIdentifier(id).startClean();
    try {
      await client.connect(home.username, home.password).timeout(const Duration(seconds: 10));
    } catch (_) {
      client.disconnect();
      return null;
    }
    if (client.connectionStatus?.state != mc.MqttConnectionState.connected) return null;
    return _RelayPipe(client);
  }

  @override
  Stream<String> listen(String topic) {
    _client.subscribe(topic, mc.MqttQos.atLeastOnce);
    return (_client.updates ?? const Stream.empty())
        .expand((list) => list)
        .where((e) => e.topic == topic && e.payload is mc.MqttPublishMessage)
        .map((e) => utf8.decode((e.payload as mc.MqttPublishMessage).payload.message.toList(), allowMalformed: true));
  }

  @override
  void publish(String topic, String payload) {
    final builder = mc.MqttClientPayloadBuilder()..addUTF8String(payload);
    _client.publishMessage(topic, mc.MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  Future<void> close() async => _client.disconnect();
}

class MqttChatHub implements ChatHub {
  MqttChatHub(this._managerOf);

  final Future<MqttManager> Function(String connectionId) _managerOf;

  Future<MqttManager?> _atHome(String connectionId) async {
    final mgr = await _managerOf(connectionId);
    return mgr.isConnected && mgr.activeEndpoint == MqttEndpoint.local ? mgr : null;
  }

  @override
  Future<void> createClient(String connectionId, String clientId, String config) async {
    final mgr = await _atHome(connectionId);
    if (mgr == null) throw const ChatException(ChatFail.notAtHome);
    mgr.publish(ChatWire.clientTopic(clientId), config, '', qos: mc.MqttQos.atLeastOnce, retain: true);
  }

  @override
  Future<bool> revokeClient(String connectionId, String clientId) async {
    final mgr = await _atHome(connectionId);
    if (mgr == null) return false;
    mgr.publish(ChatWire.clientTopic(clientId), '', '', qos: mc.MqttQos.atLeastOnce, retain: true);
    return true;
  }

  @override
  Future<List<ChatAuditEntry>?> audit(
    String connectionId, {
    required String clientId,
    required String token,
    required Uint8List key,
    RemoteHome? relay,
  }) async {
    final mgr = await _atHome(connectionId);
    ChatPipe? pipe;
    String req, res;
    if (mgr != null) {
      pipe = _ManagerPipe(mgr);
      req = ChatWire.requestTopic(clientId);
      res = ChatWire.answerTopic(clientId);
    } else if (relay != null) {
      pipe = await _RelayPipe.open(relay);
      final t = ChatWire.relayTopics(relay.homeId, clientId, key);
      req = t.req;
      res = t.res;
    } else {
      return null;
    }
    if (pipe == null) return null;
    try {
      final answer = await chatRequest(pipe,
          requestTopic: req, answerTopic: res, token: token, key: key, tool: 'audit', args: {'limit': 50});
      final entries = (answer?['result'] as Map?)?['entries'];
      if (answer == null || entries is! List) return null;
      return [for (final e in entries) ?ChatAuditEntry.fromJson(e)];
    } finally {
      await pipe.close();
    }
  }
}
