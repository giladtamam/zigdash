import 'dart:async';
import 'dart:math';

import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:rxdart/rxdart.dart';

import 'broker_config.dart';
import 'client_factory.dart';
import 'endpoint.dart';
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
  }) : _clientId = clientIdOverride ?? _shortClientId(config.id);

  // MQTT 3.1 caps client identifiers at 23 chars and some broker builds
  // (notably the Mosquitto shipped on SMLIGHT SMHUB) reject longer IDs with
  // a "protocol error" disconnect even when negotiated as 3.1.1. Compose a
  // stable 23-char ID from the connection's UUID without the dashes.
  static String _shortClientId(String connectionId) {
    final clean = connectionId.replaceAll('-', '');
    final tail = clean.length > 15 ? clean.substring(clean.length - 15) : clean;
    return 'zd-$tail'; // "zd-" (3) + 15 hex = 18 chars, well under 23
  }

  final BrokerConfig config;
  final String password;
  final String _clientId;

  mc.MqttClient? _client;
  StreamSubscription<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? _updatesSub;
  Timer? _reconnectTimer;
  bool _userInitiatedDisconnect = false;
  bool _disposed = false;
  int _backoffMs = _initialBackoffMs;

  static const _initialBackoffMs = 1000;
  static const _maxBackoffMs = 120000;

  final _status = BehaviorSubject<MqttStatus>.seeded(MqttStatus.disconnected);
  Stream<MqttStatus> get status$ => _status.stream;

  /// True only when the underlying client has a live connection — used by
  /// callers (e.g. AutomationConfigPublisher) that need to know whether a
  /// retained publish will actually reach the broker right now.
  bool get isConnected =>
      _client?.connectionStatus?.state == mc.MqttConnectionState.connected;

  MqttStatus get status => _status.value;

  final _endpoint = BehaviorSubject<MqttEndpoint?>.seeded(null);
  Stream<MqttEndpoint?> get endpoint$ => _endpoint.stream;
  MqttEndpoint? get activeEndpoint => _endpoint.valueOrNull;

  void _emitEndpoint(MqttEndpoint? e) {
    if (_disposed || _endpoint.isClosed) return;
    _endpoint.add(e);
  }

  String? _lastError;
  String? get lastError => _lastError;

  final Map<String, _SubEntry> _subs = {};

  // Guarded status emit. After [dispose] every call becomes a no-op so a
  // late-firing reconnect timer or an async tail of an in-flight connect()
  // cannot crash with "Cannot add new events after calling close".
  void _emit(MqttStatus s) {
    if (_disposed || _status.isClosed) return;
    _status.add(s);
  }

  Future<void> connect() async {
    if (_disposed) return;
    _userInitiatedDisconnect = false;
    if (_status.value == MqttStatus.connecting || _status.value == MqttStatus.connected) return;
    _emit(MqttStatus.connecting);
    _emitEndpoint(null);

    for (final cand in endpointCandidates(config)) {
      final mc.MqttClient client;
      try {
        client = _buildClient(cand.host, cand.timeoutMs);
      } on UnsupportedError catch (e) {
        // Configuration mismatch (e.g. TCP requested in a browser) — not
        // transient, and the fallback host shares the same protocol, so abort
        // entirely without scheduling a reconnect.
        _lastError = e.toString();
        _emit(MqttStatus.error);
        return;
      } catch (e) {
        _lastError = e.toString();
        continue; // transient build failure — try the next candidate
      }
      if (_disposed) {
        client.disconnect();
        return;
      }
      _client = client;

      try {
        await client.connect(config.username, password);
      } on Exception catch (e) {
        _lastError = e.toString();
        client.disconnect();
        continue; // unreachable / refused — try the next candidate
      }
      if (_disposed) {
        client.disconnect();
        return;
      }
      if (client.connectionStatus?.state != mc.MqttConnectionState.connected) {
        _lastError = 'Connect failed (no CONNACK)';
        client.disconnect();
        continue;
      }

      // Connected on this candidate.
      _lastError = null;
      _emitEndpoint(cand.kind);
      _backoffMs = _initialBackoffMs;
      await _updatesSub?.cancel();
      _updatesSub = client.updates?.listen(_onUpdates);
      for (final pattern in _subs.keys) {
        client.subscribe(pattern, mc.MqttQos.atLeastOnce);
      }
      _emit(MqttStatus.connected);
      return;
    }

    // All candidates failed.
    _emit(MqttStatus.error);
    _scheduleReconnect();
  }

  void disconnect() {
    _userInitiatedDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _updatesSub?.cancel();
    _updatesSub = null;
    _client?.disconnect();
    _client = null;
    _emitEndpoint(null);
    _emit(MqttStatus.disconnected);
  }

  Future<void> dispose() async {
    _disposed = true;
    disconnect();
    for (final e in _subs.values) {
      await e.subject.close();
    }
    _subs.clear();
    await _endpoint.close();
    await _status.close();
  }

  /// Ref-counted. Returns a broadcast stream filtered to topics matching [pattern].
  /// First watcher triggers a wire SUBSCRIBE; subsequent watchers share it.
  Stream<MqttRxMessage> subscribe(String pattern) {
    final entry = _subs.putIfAbsent(pattern, () {
      final e = _SubEntry(pattern);
      final client = _client;
      if (client?.connectionStatus?.state == mc.MqttConnectionState.connected) {
        try {
          client!.subscribe(pattern, mc.MqttQos.atLeastOnce);
        } catch (e) {
          // ignore: avoid_print
          print('[MqttManager] subscribe failed for pattern "$pattern": $e');
        }
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
    // addUTF8String, NOT addString: addString delegates to addUTF16String,
    // which mangles any code unit > 255 (e.g. Hebrew device/panel names),
    // corrupting the published bytes. addUTF8String encodes proper UTF-8.
    final builder = mc.MqttClientPayloadBuilder()..addUTF8String(payload);
    try {
      client.publishMessage(topic, qos, builder.payload!, retain: retain);
    } catch (e) {
      // mqtt_client's MQTT 3.1 encoding rejects extended UTF-8 in topics
      // with InvalidTopicException. We swallow here so a misconfigured panel
      // doesn't crash the widget tree; callers should ensure ASCII topics.
      // ignore: avoid_print
      print('[MqttManager] publish failed for topic "$topic": $e');
    }
  }

  mc.MqttClient _buildClient(String host, int timeoutMs) {
    final client = buildMqttClient(config, _clientId, host: host);
    client.logging(on: false);
    // Stay on mqtt_client's default protocol (MQTT 3.1, ProtocolName=MQIsdp).
    // The Mosquitto build on SMLIGHT SMHUB silently disconnects 3.1.1
    // CONNECT packets with "protocol error" — even though they're spec-valid.
    client.keepAlivePeriod = config.keepAliveSeconds;
    client.connectTimeoutPeriod = timeoutMs; // ms; per-candidate (LAN probe vs standard)
    client.autoReconnect = false; // we manage reconnects ourselves
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
    if (_userInitiatedDisconnect || _disposed) return;
    _emit(MqttStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_userInitiatedDisconnect || _disposed) return;
    _reconnectTimer?.cancel();
    final delay = _backoffMs;
    _backoffMs = min(_backoffMs * 2, _maxBackoffMs);
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      if (_userInitiatedDisconnect || _disposed) return;
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
