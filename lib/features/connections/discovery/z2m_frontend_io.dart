import 'dart:async';
import 'dart:io';

import 'z2m_frontend.dart';

/// Reads the `mqtt` settings from Zigbee2MQTT's web API at `ws://host:port/api`.
/// Zigbee2MQTT sends `bridge/info` among its first frames on connect; the
/// socket closes as soon as it arrives. Null when nothing answers in
/// [timeout]. Throws [Z2mPageLocked] when the page wants its own token: it
/// accepts the socket, then closes it with 4401 (2.10.4; before, that
/// counted as no answer).
/// Zigbee2MQTT's device list from its web API (3.1.13): on connect the page
/// replays what Zigbee2MQTT keeps in memory, `bridge/devices` included, so
/// it has the list even when the broker lost it. The list's JSON, or null
/// when nothing answers in [timeout], the page is locked, or no list comes.
Future<String?> fetchZ2mDeviceList(
  String host,
  int port, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  WebSocket? socket;
  try {
    socket = await WebSocket.connect('ws://$host:$port/api').timeout(timeout);
    return await socket
        .where((frame) => frame is String)
        .map((frame) => z2mDeviceListOf(frame as String))
        .firstWhere((list) => list != null, orElse: () => null)
        .timeout(timeout);
  } catch (_) {
    return null;
  } finally {
    unawaited(socket?.close());
  }
}

Future<Map<String, dynamic>?> fetchZ2mMqttConfig(
  String host,
  int port, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  WebSocket? socket;
  try {
    socket = await WebSocket.connect('ws://$host:$port/api').timeout(timeout);
    final mqtt = await socket
        .where((frame) => frame is String)
        .map((frame) => z2mMqttConfigOf(frame as String))
        .firstWhere((mqtt) => mqtt != null, orElse: () => null)
        .timeout(timeout);
    if (mqtt == null && socket.closeCode == 4401) throw const Z2mPageLocked();
    return mqtt;
  } on Z2mPageLocked {
    rethrow;
  } catch (_) {
    return null;
  } finally {
    unawaited(socket?.close());
  }
}
