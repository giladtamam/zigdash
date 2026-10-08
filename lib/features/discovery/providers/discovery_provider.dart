import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/z2m_device.dart';

typedef DiscoveryArgs = ({String connectionId, String base});

/// Fetches the retained zigbee2mqtt/bridge/devices list for a connection.
/// Subscribes, takes the first (retained) message, parses, unsubscribes.
final discoveredDevicesProvider =
    FutureProvider.autoDispose.family<List<Z2mDevice>, DiscoveryArgs>(
        (ref, args) async {
  final mgr = await ref.read(mqttManagerProvider(args.connectionId).future);
  final topic = '${args.base}/bridge/devices';
  final stream = mgr.subscribe(topic);
  ref.onDispose(() => mgr.unsubscribe(topic));
  final msg = await stream.first.timeout(const Duration(seconds: 8));
  return parseBridgeDevices(msg.payload);
});

/// How long to wait for the retained `bridge/devices` before calling it missing.
const bridgeDevicesMissingAfter = Duration(seconds: 8);

/// True when no `bridge/devices` list arrives within [bridgeDevicesMissingAfter].
///
/// Zigbee2MQTT publishes the list (retained) when it starts and when devices
/// change. A broker that restarts without persistence drops it, and
/// Zigbee2MQTT only re-sends its state on reconnect, so every device seems
/// gone until Zigbee2MQTT restarts.
final bridgeDevicesMissingProvider =
    FutureProvider.autoDispose.family<bool, DiscoveryArgs>((ref, args) async {
  final mgr = await ref.read(mqttManagerProvider(args.connectionId).future);
  final topic = '${args.base}/bridge/devices';
  final stream = mgr.subscribe(topic);
  ref.onDispose(() => mgr.unsubscribe(topic));
  try {
    await stream.first.timeout(bridgeDevicesMissingAfter);
    return false;
  } on TimeoutException {
    return true;
  }
});

/// Every `bridge/devices` message for a connection: the retained list, then
/// each update (pairing, rename, removal).
final bridgeDevicesStreamProvider = StreamProvider.autoDispose
    .family<List<Z2mDevice>, DiscoveryArgs>((ref, args) async* {
  final mgr = await ref.read(mqttManagerProvider(args.connectionId).future);
  final topic = '${args.base}/bridge/devices';
  final stream = mgr.subscribe(topic);
  ref.onDispose(() => mgr.unsubscribe(topic));
  await for (final msg in stream) {
    yield parseBridgeDevices(msg.payload);
  }
});
