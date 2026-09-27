import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:rxdart/rxdart.dart';

import 'broker_config.dart';
import 'client_factory.dart';
import 'endpoint.dart';
import 'mqtt_status.dart';
import 'topic_matcher.dart';

class MqttRxMessage {
  const MqttRxMessage({
    required this.topic,
    required this.payload,
    required this.receivedAt,
    required this.connectionGeneration,
  });
  final String topic;
  final String payload;
  final DateTime receivedAt;
  final int connectionGeneration;
}

class _SubEntry {
  _SubEntry(this.pattern);
  final String pattern;
  final BehaviorSubject<MqttRxMessage> subject =
      BehaviorSubject<MqttRxMessage>();
  int refs = 0;

  /// Pending wire UNSUBSCRIBE after the last watcher left (see
  /// [MqttManager.releaseGrace]); cancelled if a watcher returns in time.
  Timer? release;
}

/// Builds the platform [mc.MqttClient] for a candidate host. Defaults to the
/// real [buildMqttClient]; tests inject a fake to exercise connect/timeout
/// behavior without a live broker.
typedef MqttClientFactory =
    mc.MqttClient Function(
      BrokerConfig config,
      String clientId, {
      String? host,
    });

typedef Now = DateTime Function();

/// Owns one MQTT client per [Connection]. Handles connect/disconnect, auto-reconnect
/// with exponential backoff, and ref-counted topic subscriptions multiplexed over a
/// single wire subscription per pattern.
class MqttManager {
  MqttManager({
    required this.config,
    required this.password,
    String? clientIdOverride,
    MqttClientFactory? clientFactory,
    Now? now,
  }) : _clientId = clientIdOverride ?? _shortClientId(config.id),
       _clientFactory = clientFactory ?? buildMqttClient,
       _now = now ?? DateTime.now;

  // MQTT 3.1 caps client identifiers at 23 chars and some broker builds
  // (notably the Mosquitto shipped on SMLIGHT SMHUB) reject longer IDs with
  // a "protocol error" disconnect even when negotiated as 3.1.1.
  //
  // The ID must also be unique per running client, not just per connection.
  // Two installs holding the same connection row (Android Auto Backup restored
  // onto a second phone or wall tablet, or two browser tabs of the web build)
  // used to send the same ID; the broker drops the older session on every
  // CONNECT, each side auto-reconnects, and both loop forever. Sessions are
  // clean, so a stable ID buys nothing: keep the connection tail for broker
  // logs and add a per-manager random part.
  //
  // Shape: "zd-" + 10 hex (connection) + 8 hex (instance) = 21 chars. The
  // "zd-" prefix is unchanged so prefix-based broker ACLs keep working.
  static final Random _idRandom = Random.secure();

  static String _shortClientId(String connectionId) {
    final clean = connectionId.replaceAll('-', '').toLowerCase();
    final tail = clean.length > 10 ? clean.substring(clean.length - 10) : clean;
    final rnd = _idRandom;
    final instance = List.generate(
      8,
      (_) => rnd.nextInt(16).toRadixString(16),
    ).join();
    return 'zd-$tail$instance';
  }

  /// Visible for tests: the client identifier this manager sends in CONNECT.
  String get clientId => _clientId;

  final BrokerConfig config;
  final String password;
  final String _clientId;
  final MqttClientFactory _clientFactory;
  final Now _now;

  mc.MqttClient? _client;
  StreamSubscription<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? _updatesSub;
  Timer? _reconnectTimer;
  bool _userInitiatedDisconnect = false;
  bool _connectInFlight = false;
  bool _reconnectInProgress = false;
  bool _disposed = false;
  int _backoffMs = _initialBackoffMs;
  int _connectionGeneration = 0;

  int get connectionGeneration => _connectionGeneration;

  static const _initialBackoffMs = 1000;
  // Capped low for a foreground app: a 2-minute ceiling meant that after a few
  // failures the user could open the app and sit disconnected for minutes.
  static const _maxBackoffMs = 30000;

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

  /// Values saved from earlier sessions, by exact topic, until live data
  /// replaces them. They carry connection generation -1, so readers treat
  /// them as last known, never fresh.
  final Map<String, MqttRxMessage> _lastKnown = {};

  /// The newest message per topic received in this app session.
  final Map<String, MqttRxMessage> _latest = {};

  /// The newest message for every topic starting with [prefix]: this
  /// session's live messages, else saved last-known values. Lets a
  /// wildcard subscriber start from what is already known, since only
  /// exact-topic subscriptions replay.
  List<MqttRxMessage> latestUnder(String prefix) => [
        for (final m in _latest.values)
          if (m.topic.startsWith(prefix)) m,
        for (final m in _lastKnown.values)
          if (m.topic.startsWith(prefix) && !_latest.containsKey(m.topic)) m,
      ];

  /// Seeds saved values (loaded before [connect]). A later subscription to
  /// an exact topic starts with its saved value.
  void seedLastKnown(Iterable<MqttRxMessage> messages) {
    for (final m in messages) {
      _lastKnown[m.topic] = m;
      final entry = _subs[m.topic];
      if (entry != null && !entry.subject.hasValue) entry.subject.add(m);
    }
  }

  final _commandsSent = StreamController<String>.broadcast();
  final _messages = StreamController<MqttRxMessage>.broadcast();

  /// Topics of commands published through [publish], as they are sent.
  Stream<String> get commandsSent => _commandsSent.stream;

  /// Every message received on this connection's subscriptions.
  Stream<MqttRxMessage> get messages => _messages.stream;

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
    if (_connectInFlight || _status.value == MqttStatus.connected) return;
    _connectInFlight = true;
    try {
      await _connect();
    } finally {
      _connectInFlight = false;
    }
  }

  Future<void> _connect() async {
    final attemptStatus = _reconnectInProgress
        ? MqttStatus.reconnecting
        : MqttStatus.connecting;
    if (_status.value != attemptStatus) _emit(attemptStatus);
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
        // Hard wall on the whole connect. mqtt_client's connectTimeoutPeriod
        // only bounds the post-TCP CONNACK wait — the underlying Socket.connect
        // has NO timeout, so a remote host whose SYN goes unanswered (Tailscale
        // re-establishing, node asleep, blackholed LAN IP) would otherwise hang
        // for the OS default (tens of seconds), wedging us in `connecting` while
        // the guard above turns every reconnect into a no-op. Timing out here
        // makes the per-candidate budgets in endpoint.dart actually effective.
        await client
            .connect(config.username, password)
            .timeout(Duration(milliseconds: cand.timeoutMs));
      } on TimeoutException catch (_) {
        _lastError =
            'Connect timed out (${cand.timeoutMs} ms) for ${cand.host}';
        client.disconnect();
        continue; // host unreachable within budget — try the next candidate
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

      // Connected on this candidate. Only now wire the disconnect handler:
      // calling client.disconnect() on a *failed* candidate above fires
      // mqtt_client's onDisconnected (solicited) while _userInitiatedDisconnect
      // is false, which would otherwise schedule a phantom reconnect during
      // normal candidate fallback.
      client.onDisconnected = () => _onDisconnected(client);
      final connectionGeneration = ++_connectionGeneration;
      _lastError = null;
      _emitEndpoint(cand.kind);
      _backoffMs = _initialBackoffMs;
      await _updatesSub?.cancel();
      _updatesSub = client.updates?.listen(
        (events) => _onUpdates(events, connectionGeneration),
      );
      for (final pattern in _subs.keys) {
        client.subscribe(pattern, mc.MqttQos.atLeastOnce);
      }
      _emit(MqttStatus.connected);
      _reconnectInProgress = false;
      return;
    }

    // All candidates failed.
    _emit(MqttStatus.error);
    _scheduleReconnect();
  }

  /// Force an immediate reconnect, bypassing any pending backoff timer. Called
  /// when the app returns to the foreground: a backgrounded socket is usually
  /// dead and the next scheduled attempt may be up to [_maxBackoffMs] away, so
  /// we reset the backoff and retry now. No-op if already connected/connecting
  /// or if the user explicitly disconnected.
  void reconnectNow() {
    if (_disposed || _userInitiatedDisconnect) return;
    if (_status.value == MqttStatus.connected ||
        _status.value == MqttStatus.connecting) {
      return;
    }
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _backoffMs = _initialBackoffMs;
    connect();
  }

  void disconnect() {
    _userInitiatedDisconnect = true;
    _reconnectInProgress = false;
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
    for (final e in _subs.values) {
      e.release?.cancel();
    }
    disconnect();
    // Iterate a copy: closing a subject runs listeners' onDone, which can
    // synchronously unsubscribe (and remove from _subs) — mutating the map
    // during iteration crashed with ConcurrentModificationError on shutdown
    // or broker switch.
    for (final e in _subs.values.toList()) {
      await e.subject.close();
    }
    _subs.clear();
    await _endpoint.close();
    await _status.close();
    await _commandsSent.close();
    await _messages.close();
  }

  /// Ref-counted. Returns a broadcast stream filtered to topics matching [pattern].
  /// First watcher triggers a wire SUBSCRIBE; subsequent watchers share it.
  Stream<MqttRxMessage> subscribe(String pattern) {
    final pending = _subs[pattern];
    if (pending != null && pending.release != null) {
      // A watcher came back within the grace period: keep the live wire
      // subscription and replay the last value from the subject.
      pending.release!.cancel();
      pending.release = null;
    }
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
      final saved = _lastKnown[pattern];
      if (saved != null) e.subject.add(saved);
      return e;
    });
    entry.refs++;
    return entry.subject.stream;
  }

  /// How long a topic stays subscribed after its last watcher leaves.
  ///
  /// Screens rebuild and tiles re-subscribe within a frame. Sending
  /// UNSUBSCRIBE and SUBSCRIBE back to back loses live updates on aedes (the
  /// broker in Node-RED's aedes node): it applies the UNSUBSCRIBE after the
  /// new SUBSCRIBE. Waiting avoids that, keeps the last value for a returning
  /// tile, and saves SUBSCRIBE churn when navigating back and forth.
  static const releaseGrace = Duration(seconds: 3);

  /// Decrements the ref count. After the last release the topic keeps its
  /// wire subscription for [releaseGrace], then UNSUBSCRIBE is sent.
  void unsubscribe(String pattern) {
    final e = _subs[pattern];
    if (e == null || e.refs <= 0) return;
    e.refs--;
    if (e.refs > 0) return;
    e.release?.cancel();
    e.release = Timer(releaseGrace, () {
      if (_subs[pattern] != e || e.refs > 0) return;
      final client = _client;
      if (client?.connectionStatus?.state == mc.MqttConnectionState.connected) {
        sendUnsubscribe(client!, pattern);
      }
      e.subject.close();
      _subs.remove(pattern);
    });
  }

  /// Sends UNSUBSCRIBE with the QoS 1 flag the spec requires.
  ///
  /// mqtt_client only sets that flag in MQTT 3.1.1 mode, and ZigDash speaks
  /// MQTT 3.1 (MQIsdp) for SMLIGHT brokers, so the packet went out as 0xA0
  /// instead of 0xA2. Mosquitto 2 rejects that as a malformed packet and drops
  /// the connection, so every tile leaving the screen forced a reconnect.
  ///
  /// The library picks the header from the global [mc.Protocol.version] while
  /// it writes the packet, synchronously inside [mc.MqttClient.unsubscribe].
  /// Switching it for exactly that call fixes the header and changes nothing
  /// else: the rest of the UNSUBSCRIBE is identical in 3.1 and 3.1.1.
  @visibleForTesting
  static void sendUnsubscribe(mc.MqttClient client, String pattern) {
    final saved = mc.Protocol.version;
    mc.Protocol.version = mc.MqttClientConstants.mqttV311ProtocolVersion;
    try {
      client.unsubscribe(pattern);
    } finally {
      mc.Protocol.version = saved;
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
    if (client == null ||
        client.connectionStatus?.state != mc.MqttConnectionState.connected) {
      return;
    }
    final payload = template.replaceAll('{value}', value.toString());
    // addUTF8String, NOT addString: addString delegates to addUTF16String,
    // which mangles any code unit > 255 (e.g. Hebrew device/panel names),
    // corrupting the published bytes. addUTF8String encodes proper UTF-8.
    final builder = mc.MqttClientPayloadBuilder()..addUTF8String(payload);
    try {
      client.publishMessage(topic, qos, builder.payload!, retain: retain);
      if (!_commandsSent.isClosed) _commandsSent.add(topic);
    } catch (e) {
      // mqtt_client's MQTT 3.1 encoding rejects extended UTF-8 in topics
      // with InvalidTopicException. We swallow here so a misconfigured panel
      // doesn't crash the widget tree; callers should ensure ASCII topics.
      // ignore: avoid_print
      print('[MqttManager] publish failed for topic "$topic": $e');
    }
  }

  mc.MqttClient _buildClient(String host, int timeoutMs) {
    final client = _clientFactory(config, _clientId, host: host);
    client.logging(on: false);
    // Stay on mqtt_client's default protocol (MQTT 3.1, ProtocolName=MQIsdp).
    // The Mosquitto build on SMLIGHT SMHUB silently disconnects 3.1.1
    // CONNECT packets with "protocol error" — even though they're spec-valid.
    client.keepAlivePeriod = config.keepAliveSeconds;
    client.connectTimeoutPeriod =
        timeoutMs; // ms; per-candidate (LAN probe vs standard)
    client.autoReconnect = false; // we manage reconnects ourselves
    // onDisconnected is wired in connect() only after a candidate reaches
    // `connected`, so failed-candidate disconnects don't trigger a reconnect.
    client.connectionMessage = mc.MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .startClean();
    return client;
  }

  void _onUpdates(
    List<mc.MqttReceivedMessage<mc.MqttMessage>> events,
    int connectionGeneration,
  ) {
    for (final event in events) {
      final pub = event.payload;
      if (pub is! mc.MqttPublishMessage) continue;
      final payload = mc.MqttPublishPayload.bytesToStringAsString(
        pub.payload.message,
      );
      _fanOut(
        MqttRxMessage(
          topic: event.topic,
          payload: payload,
          receivedAt: _now(),
          connectionGeneration: connectionGeneration,
        ),
      );
    }
  }

  void _onDisconnected(mc.MqttClient client) {
    if (!identical(client, _client)) return;
    if (_userInitiatedDisconnect || _disposed) return;
    _reconnectInProgress = true;
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

  void _fanOut(MqttRxMessage message) {
    _lastKnown.remove(message.topic);
    _latest[message.topic] = message;
    if (!_messages.isClosed) _messages.add(message);
    for (final entry in _subs.values) {
      if (topicMatches(entry.pattern, message.topic)) {
        entry.subject.add(message);
      }
    }
  }
}
