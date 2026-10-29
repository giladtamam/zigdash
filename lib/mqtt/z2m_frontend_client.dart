// SPIKE (spike/z2m-frontend-ws), not for release: answers "can ZigDash talk
// to Zigbee2MQTT through its frontend WebSocket instead of the MQTT broker?"
//
// Looks like an mqtt_client [mc.MqttClient] to MqttManager, but speaks the
// Zigbee2MQTT frontend protocol: ws://host:8080/api(?token=…), where every
// frame is {"topic": "<topic without base topic>", "payload": <JSON>}. On
// connect Zigbee2MQTT sends its retained bridge topics and every device's
// state, then live updates; frames we send are handled as if published to
// "<base>/<topic>" on MQTT (lib/extension/frontend.ts).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:typed_data/typed_data.dart' as typed;

class Z2mFrontendClient extends mc.MqttClient {
  Z2mFrontendClient(this.uri, String clientId) : super(uri.host, clientId);

  /// ws://host:port/api, with ?token= when the frontend has an auth_token.
  final Uri uri;

  WebSocket? _socket;
  final _status = mc.MqttClientConnectionStatus();

  /// Single-subscription, so it buffers: Zigbee2MQTT sends the bridge topics
  /// and device states once, right after the socket opens, before
  /// MqttManager starts listening (it listens after connect returns).
  final _updates =
      StreamController<List<mc.MqttReceivedMessage<mc.MqttMessage>>>();

  /// Zigbee2MQTT strips its base topic from frames; we add it back so the
  /// app sees the same topics as over MQTT. Read from bridge/info; frames
  /// that arrive before it are held back.
  String? _base;
  final _held = <Map<String, Object?>>[];

  /// Spike counters: what could not be expressed over the frontend.
  int droppedPublishes = 0;
  int heldFrames = 0;

  @override
  mc.MqttClientConnectionStatus? get connectionStatus => _status;

  @override
  Stream<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? get updates =>
      _updates.stream;

  @override
  Stream<mc.MqttPublishMessage>? get published => null;

  @override
  void logging({required bool on, bool logPayloads = true}) {}

  @override
  Future<mc.MqttClientConnectionStatus?> connect([
    String? username,
    String? password,
  ]) async {
    _status.state = mc.MqttConnectionState.connecting;
    try {
      final target = password == null || password.isEmpty
          ? uri
          : uri.replace(queryParameters: {'token': password});
      final socket = await WebSocket.connect(
        target.toString(),
      ).timeout(Duration(milliseconds: connectTimeoutPeriod));
      _socket = socket;
      socket.listen(_onFrame, onDone: _onClosed, onError: (_) => _onClosed());
      // A wrong token is not an HTTP 401: Zigbee2MQTT upgrades, then closes
      // with 4401. Wait for bridge/info so a refused socket counts as failed.
      final ok = await _firstInfo.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (!ok) {
        _status
          ..state = mc.MqttConnectionState.faulted
          ..returnCode = socket.closeCode == 4401
              ? mc.MqttConnectReturnCode.notAuthorized
              : mc.MqttConnectReturnCode.noneSpecified;
        await socket.close();
        return _status;
      }
      _status
        ..state = mc.MqttConnectionState.connected
        ..returnCode = mc.MqttConnectReturnCode.connectionAccepted;
    } catch (_) {
      _status.state = mc.MqttConnectionState.faulted;
      rethrow;
    }
    return _status;
  }

  final _firstInfo = Completer<bool>();

  void _onFrame(Object? data) {
    if (data is! String) return;
    final Map<String, Object?> frame;
    try {
      frame = (jsonDecode(data) as Map).cast<String, Object?>();
    } catch (_) {
      return;
    }
    if (_base == null) {
      if (frame['topic'] == 'bridge/info') {
        final config = (frame['payload'] as Map?)?['config'] as Map?;
        _base =
            ((config?['mqtt'] as Map?)?['base_topic'] as String?) ??
            'zigbee2mqtt';
        if (!_firstInfo.isCompleted) _firstInfo.complete(true);
        _deliver(frame);
        for (final f in _held) {
          _deliver(f);
        }
        _held.clear();
      } else {
        heldFrames++;
        _held.add(frame);
      }
      return;
    }
    _deliver(frame);
  }

  void _deliver(Map<String, Object?> frame) {
    final topic = frame['topic'];
    if (topic is! String) return;
    final payload = frame['payload'];
    // MQTT carried JSON text; a bare string was sent as is.
    final text = payload is String ? payload : jsonEncode(payload);
    final bytes = (mc.MqttClientPayloadBuilder()..addUTF8String(text)).payload!;
    final message = mc.MqttPublishMessage()
        .toTopic('$_base/$topic')
        .publishData(bytes);
    if (!_updates.isClosed) {
      _updates.add([mc.MqttReceivedMessage('$_base/$topic', message)]);
    }
  }

  void _onClosed() {
    if (!_firstInfo.isCompleted) _firstInfo.complete(false);
    final wasConnected = _status.state == mc.MqttConnectionState.connected;
    _status.state = mc.MqttConnectionState.disconnected;
    if (wasConnected) onDisconnected?.call();
  }

  /// Everything arrives anyway; MqttManager filters by pattern.
  @override
  mc.Subscription? subscribe(String topic, mc.MqttQos qosLevel) => null;

  @override
  void unsubscribe(String topic, {expectAcknowledge = false}) {}

  @override
  int publishMessage(
    String topic,
    mc.MqttQos qualityOfService,
    typed.Uint8Buffer data, {
    bool retain = false,
  }) {
    final socket = _socket;
    final base = _base;
    // Only "<base>/…" can be sent: the frontend prefixes the base topic.
    // Retained messages (Node-RED automation configs) and other topics are
    // not possible.
    if (socket == null ||
        base == null ||
        !topic.startsWith('$base/') ||
        retain) {
      droppedPublishes++;
      return -1;
    }
    final text = mc.MqttPublishPayload.bytesToStringAsString(data);
    Object? payload;
    try {
      payload = jsonDecode(text);
    } catch (_) {
      payload = text;
    }
    socket.add(
      jsonEncode({
        'topic': topic.substring(base.length + 1),
        'payload': payload,
      }),
    );
    return 0;
  }

  @override
  void disconnect() {
    final wasConnected = _status.state == mc.MqttConnectionState.connected;
    _status.state = mc.MqttConnectionState.disconnected;
    _socket?.close();
    _socket = null;
    if (wasConnected) onDisconnected?.call();
  }
}
