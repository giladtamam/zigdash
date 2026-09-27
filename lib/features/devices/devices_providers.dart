import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/connection_repo.dart';
import '../../data/repositories/dashboard_repo.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../discovery/providers/discovery_provider.dart';
import 'device_health.dart';
import 'device_tiles.dart';
import 'z2m_bridge.dart';

/// The base topic set for a home in Settings, or null when none is set
/// (or the homes have not loaded yet).
final baseTopicOverrideProvider =
    Provider.autoDispose.family<String?, String>((ref, connectionId) {
  final homes = ref.watch(connectionsStreamProvider).valueOrNull;
  final set = homes
      ?.where((c) => c.id == connectionId)
      .firstOrNull
      ?.z2mBaseTopic
      ?.trim();
  return set == null || set.isEmpty ? null : set;
});

/// A home's Zigbee2MQTT base topic: the one set in Settings, else derived
/// from its first dashboard's topic prefix (the pre-1.13 rule). Null until
/// the homes and dashboards have loaded, or while the home has no dashboard
/// and no base topic set.
final homeBaseTopicProvider =
    Provider.autoDispose.family<String?, String>((ref, connectionId) {
  if (ref.watch(connectionsStreamProvider).valueOrNull == null) return null;
  final set = ref.watch(baseTopicOverrideProvider(connectionId));
  if (set != null) return set;
  final first = ref
      .watch(dashboardsForConnectionProvider(connectionId))
      .valueOrNull
      ?.firstOrNull;
  return first == null ? null : z2mBase(first.topicPrefix);
});

typedef DeviceHealthArgs = ({String connectionId, String base});
typedef BridgeEventArgs = ({String connectionId, String base});

/// Streams a continuously-updated list of [DeviceHealth] for all devices
/// under [base].  Subscribes to `$base/#` for state and availability updates.
final deviceHealthProvider = StreamProvider.autoDispose
    .family<List<DeviceHealth>, DeviceHealthArgs>((ref, args) async* {
  final connectionId = args.connectionId;
  final base = args.base;

  // Resolve MQTT manager.
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);

  // Fetch the device list (reuse discovery provider).
  final devices = await ref
      .watch(discoveredDevicesProvider((connectionId: connectionId, base: base)).future);

  final stateByName = <String, String>{};
  final availabilityByName = <String, String>{};

  // Yield initial snapshot immediately (before any state arrives).
  yield deviceHealthFrom(devices, stateByName, availabilityByName);

  final pattern = '$base/#';
  final stream = mgr.subscribe(pattern);
  ref.onDispose(() => mgr.unsubscribe(pattern));

  await for (final msg in stream) {
    final topic = msg.topic;
    // Strip the "$base/" prefix to get "rest".
    if (topic.length <= base.length + 1) continue;
    final rest = topic.substring(base.length + 1);

    if (rest.startsWith('bridge')) continue;

    if (rest.endsWith('/availability')) {
      final name = rest.substring(0, rest.length - '/availability'.length);
      availabilityByName[name] = msg.payload;
    } else if (!rest.contains('/')) {
      stateByName[rest] = msg.payload;
    }

    yield deviceHealthFrom(devices, stateByName, availabilityByName);
  }
});

/// Streams a map of `friendlyName -> latest raw state JSON` for all devices
/// under [base]. Used by the scene-capture flow to snapshot device state.
/// Subscribes to `$base/#`, ignoring `bridge/*` and `/availability` topics.
final deviceStatesProvider = StreamProvider.autoDispose
    .family<Map<String, String>, DeviceHealthArgs>((ref, args) async* {
  final mgr = await ref.read(mqttManagerProvider(args.connectionId).future);
  final base = args.base;
  final stateByName = <String, String>{};

  yield Map.unmodifiable(stateByName);

  final pattern = '$base/#';
  final stream = mgr.subscribe(pattern);
  ref.onDispose(() => mgr.unsubscribe(pattern));

  await for (final msg in stream) {
    final topic = msg.topic;
    if (topic.length <= base.length + 1) continue;
    final rest = topic.substring(base.length + 1);
    if (rest.startsWith('bridge')) continue;
    if (rest.contains('/')) continue; // availability, /set echoes, etc.
    stateByName[rest] = msg.payload;
    yield Map.unmodifiable(stateByName);
  }
});

/// Streams [BridgeEvent]s from `$base/bridge/event`.
final bridgeEventsProvider = StreamProvider.autoDispose
    .family<BridgeEvent, BridgeEventArgs>((ref, args) async* {
  final mgr = await ref.read(mqttManagerProvider(args.connectionId).future);
  final topic = '${args.base}/bridge/event';
  final stream = mgr.subscribe(topic);
  ref.onDispose(() => mgr.unsubscribe(topic));
  await for (final msg in stream) {
    yield parseBridgeEvent(msg.payload);
  }
});

/// Sets permit-join on or off for the given connection + base topic.
Future<void> setPermitJoin(
  WidgetRef ref,
  String connectionId,
  String base, {
  required bool enable,
}) async {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  final request = permitJoinRequest(base, enable: enable);
  mgr.publish(request.topic, request.payload, '');
}
