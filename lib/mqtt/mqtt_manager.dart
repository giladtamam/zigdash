import 'dart:async';
import 'dart:math';

import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';

import '../data/database/tables/connections.dart';
import 'broker_config.dart';
import 'mqtt_status.dart';
import 'topic_matcher.dart';

class MqttRxMessage {
  MqttRxMessage(this.topic, this.payload);
  final String topic;
  final String payload;
}

class _SubEntry {
  _SubEntry(this.pattern);
  final String pattern;
  final BehaviorSubject<MqttRxMessage> subject = BehaviorSubject<MqttRxMessage>();
  int refs = 0;
}

/// Owns one MQTT client per [Connection]. Handles connect/disconnect, auto-reconnect
/// with exponential backoff, and ref-counted topic subscriptions multiplexed over a
/// single wire subscription per pattern.
class MqttManager {
  MqttManager({
    required this.config,
    required this.password,
    String? clientIdOverride,
  }) : _clientId = clientIdOverride ?? 'zigdash-${config.id}';

  final BrokerConfig config;
  final String password;
  final String _clientId;

  mc.MqttClient? _client;
  StreamSubscription<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? _updatesSub;
  Timer? _reconnectTimer;
  bool _userInitiatedDisconnect = false;
  int _backoffMs = _initialBackoffMs;

  static const _initialBackoffMs = 1000;
  static const _maxBackoffMs = 120000;

  final _status = BehaviorSubject<MqttStatus>.seeded(MqttStatus.disconnected);
  Stream<MqttStatus> get status$ => _status.stream;
  MqttStatus get status => _status.value;

  final Map<String, _SubEntry> _subs = {};

  Future<void> connect() async {
    _userInitiatedDisconnect = false;
    if (_status.value == MqttStatus.connecting || _status.value == MqttStatus.connected) return;
    _status.add(MqttStatus.connecting);

    final client = _buildClient();
    _client = client;

    try {
      await client.connect(config.username, password);
    } on Exception {
      _status.add(MqttStatus.error);
      _scheduleReconnect();
      return;
    }

    if (client.connectionStatus?.state != mc.MqttConnectionState.connected) {
      _status.add(MqttStatus.error);
      _scheduleReconnect();
      return;
    }

    _backoffMs = _initialBackoffMs;
    await _updatesSub?.cancel();
    _updatesSub = client.updates?.listen(_onUpdates);

    // Re-subscribe to anything we had before (e.g., after a reconnect).
    for (final pattern in _subs.keys) {
      client.subscribe(pattern, mc.MqttQos.atLeastOnce);
    }

    _status.add(MqttStatus.connected);
  }

  void disconnect() {
    _userInitiatedDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _updatesSub?.cancel();
    _updatesSub = null;
    _client?.disconnect();
    _client = null;
    if (!_status.isClosed) _status.add(MqttStatus.disconnected);
  }

  Future<void> dispose() async {
    disconnect();
    for (final e in _subs.values) {
      await e.subject.close();
    }
    _subs.clear();
    await _status.close();
  }

  /// Ref-counted. Returns a broadcast stream filtered to topics matching [pattern].
  /// First watcher triggers a wire SUBSCRIBE; subsequent watchers share it.
  Stream<MqttRxMessage> subscribe(String pattern) {
    final entry = _subs.putIfAbsent(pattern, () {
      final e = _SubEntry(pattern);
      final client = _client;
      if (client?.connectionStatus?.state == mc.MqttConnectionState.connected) {
        client!.subscribe(pattern, mc.MqttQos.atLeastOnce);
      }
      return e;
    });
    entry.refs++;
    return entry.subject.stream;
  }

  /// Decrements ref count; sends UNSUBSCRIBE only on the last release.
  void unsubscribe(String pattern) {
    final e = _subs[pattern];
    if (e == null) return;
    e.refs--;
    if (e.refs <= 0) {
      final client = _client;
      if (client?.connectionStatus?.state == mc.MqttConnectionState.connected) {
        client!.unsubscribe(pattern);
      }
      e.subject.close();
      _subs.remove(pattern);
    }
  }

  /// Publishes [value] using [template], substituting `{value}` with [value]'s string form.
  void publish(
    String topic,
    String template,
    Object value, {
    mc.MqttQos qos = mc.MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    final client = _client;
    if (client == null || client.connectionStatus?.state != mc.MqttConnectionState.connected) {
      return;
    }
    final payload = template.replaceAll('{value}', value.toString());
    final builder = mc.MqttClientPayloadBuilder()..addString(payload);
    client.publishMessage(topic, qos, builder.payload!, retain: retain);
  }

  mc.MqttClient _buildClient() {
    final isSecure = config.protocol == MqttProtocol.tcpSsl || config.protocol == MqttProtocol.wss;
    final isWs = config.protocol == MqttProtocol.ws || config.protocol == MqttProtocol.wss;

    final client = MqttServerClient.withPort(config.host, _clientId, config.port);
    client.logging(on: false);
    client.keepAlivePeriod = config.keepAliveSeconds;
    client.autoReconnect = false; // we manage reconnects ourselves
    client.secure = isSecure;
    if (isWs) {
      client.useWebSocket = true;
      client.websocketProtocols = ['mqtt'];
    }
    client.onDisconnected = _onDisconnected;
    client.connectionMessage = mc.MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .startClean()
        .withWillQos(mc.MqttQos.atLeastOnce);
    return client;
  }

  void _onUpdates(List<mc.MqttReceivedMessage<mc.MqttMessage>> events) {
    for (final event in events) {
      final pub = event.payload;
      if (pub is! mc.MqttPublishMessage) continue;
      final payload = mc.MqttPublishPayload.bytesToStringAsString(pub.payload.message);
      _fanOut(event.topic, payload);
    }
  }

  void _onDisconnected() {
    if (_userInitiatedDisconnect) return;
    _status.add(MqttStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_userInitiatedDisconnect) return;
    _reconnectTimer?.cancel();
    final delay = _backoffMs;
    _backoffMs = min(_backoffMs * 2, _maxBackoffMs);
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      if (_userInitiatedDisconnect) return;
      connect();
    });
  }

  void _fanOut(String topic, String payload) {
    for (final entry in _subs.values) {
      if (topicMatches(entry.pattern, topic)) {
        entry.subject.add(MqttRxMessage(topic, payload));
      }
    }
  }
}
