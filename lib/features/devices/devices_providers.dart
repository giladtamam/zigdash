import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/daos/device_registry_dao.dart';
import '../../data/database/database.dart';
import '../../mqtt/mqtt_manager.dart';
import '../onboarding/demo_home.dart' show demoGeneration;
import '../discovery/models/z2m_device.dart';
import 'device_profile.dart';
import 'device_state_refresher.dart';

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

/// Whether the bridge tracks availability, from retained `bridge/info`.
final availabilityConfigProvider = StreamProvider.autoDispose
    .family<AvailabilityConfig, DeviceHealthArgs>((ref, args) async* {
  final mgr = await ref.read(mqttManagerProvider(args.connectionId).future);
  final topic = '${args.base}/bridge/info';
  final stream = mgr.subscribe(topic);
  ref.onDispose(() => mgr.unsubscribe(topic));
  yield AvailabilityConfig.unknown;
  await for (final msg in stream) {
    yield parseAvailabilityConfig(msg.payload);
  }
});

/// A home's devices with their health, live (devices-tablet-1.13.md §2).
///
/// Starts from what is already known (this session's messages, else the
/// last-known store), then follows `$base/#`. Devices with no state yet are
/// asked for it once per connection; one that stays silent past
/// [deviceResponseTimeout] reads "Not responding".
final deviceHealthProvider = StreamProvider.autoDispose
    .family<List<DeviceHealth>, DeviceHealthArgs>((ref, args) {
  final base = args.base;
  final out = StreamController<List<DeviceHealth>>();
  final states = <String, ({String payload, DateTime at})>{};
  final availability = <String, String>{};
  final stale = <String>{};
  var generation = -2;
  var devices = <Z2mDevice>[];
  var config = AvailabilityConfig.unknown;
  DeviceStateRefresher? refresher;
  final timers = <Timer>[];

  Set<String> silent() {
    final now = DateTime.now();
    return {
      for (final d in devices)
        if (!states.containsKey(d.friendlyName) &&
            (refresher?.askedAt('$base/${d.friendlyName}')
                    ?.add(deviceResponseTimeout)
                    .isBefore(now) ??
                false))
          d.friendlyName,
    };
  }

  void emit() {
    if (out.isClosed) return;
    out.add(deviceHealthFrom(devices,
        states: states,
        availability: availability,
        tracked: config.tracks,
        notResponding: silent(),
        stale: stale));
  }

  void ask() {
    final r = refresher;
    if (r == null) return;
    for (final d in devices) {
      if (states.containsKey(d.friendlyName)) continue;
      final topic = '$base/${d.friendlyName}';
      if (r.askedAt(topic) != null) continue;
      r.request(topic, classifyExposes(d.rawExposes));
      timers.add(Timer(deviceResponseTimeout + const Duration(seconds: 1), emit));
    }
  }

  void take(MqttRxMessage m) {
    if (!m.topic.startsWith('$base/')) return;
    final rest = m.topic.substring(base.length + 1);
    if (rest.startsWith('bridge/')) return;
    if (rest.endsWith('/availability')) {
      availability[rest.substring(0, rest.length - 13)] = m.payload;
    } else if (!rest.contains('/') && m.payload.isNotEmpty) {
      states[rest] = (payload: m.payload, at: m.receivedAt);
      // Demo values are current, never last known (see demo_home.dart).
      if (m.connectionGeneration == generation ||
          m.connectionGeneration == demoGeneration) {
        stale.remove(rest);
      } else {
        stale.add(rest);
      }
    }
  }

  ref.listen(
      bridgeDevicesStreamProvider((connectionId: args.connectionId, base: base)),
      (_, next) {
    final d = next.valueOrNull;
    if (d == null) return;
    devices = d;
    ask();
    emit();
  }, fireImmediately: true);
  ref.listen(availabilityConfigProvider(args), (_, next) {
    config = next.valueOrNull ?? AvailabilityConfig.unknown;
    emit();
  }, fireImmediately: true);
  ref.listen(deviceStateRefresherProvider(args.connectionId), (_, next) {
    refresher = next.valueOrNull;
    ask();
  }, fireImmediately: true);

  () async {
    final mgr = await ref.read(mqttManagerProvider(args.connectionId).future);
    if (out.isClosed) return;
    generation = mgr.connectionGeneration;
    for (final m in mgr.latestUnder('$base/')) {
      take(m);
    }
    emit();
    final pattern = '$base/#';
    final sub = mgr.subscribe(pattern).listen((m) {
      generation = mgr.connectionGeneration;
      take(m);
      emit();
    });
    ref.onDispose(() {
      sub.cancel();
      mgr.unsubscribe(pattern);
    });
  }();

  ref.onDispose(() {
    for (final t in timers) {
      t.cancel();
    }
    out.close();
  });
  return out.stream;
});

/// Watches a home's live messages while it is open and records battery
/// readings for the Devices dot ([DeviceRegistryDao.observeBattery]). Uses
/// the messages the app already receives, adding no subscription.
final batteryWatchProvider =
    Provider.autoDispose.family<void, DeviceHealthArgs>((ref, args) {
  final dao = DeviceRegistryDao(ref.watch(appDatabaseProvider));
  final base = args.base;
  var byName = <String, String>{};
  final lastLow = <String, bool>{};
  ref.listen(
      bridgeDevicesStreamProvider((connectionId: args.connectionId, base: base)),
      (_, next) {
    final d = next.valueOrNull;
    if (d == null) return;
    byName = {
      for (final x in d)
        if (x.ieeeAddress != null) x.friendlyName: x.ieeeAddress!,
    };
  }, fireImmediately: true);
  StreamSubscription<MqttRxMessage>? sub;
  ref.listen(mqttManagerProvider(args.connectionId), (_, next) {
    sub?.cancel();
    sub = next.valueOrNull?.messages.listen((m) {
      if (!m.topic.startsWith('$base/')) return;
      final ieee = byName[m.topic.substring(base.length + 1)];
      if (ieee == null) return;
      final state = parseState(m.payload);
      final low = state == null ? null : batteryLowIn(state);
      if (low == null || lastLow[ieee] == low) return;
      lastLow[ieee] = low;
      dao.observeBattery(args.connectionId, ieee, low).ignore();
    });
  }, fireImmediately: true);
  ref.onDispose(() => sub?.cancel());
});

/// Devices whose battery went low while watched and whose page is unseen.
final batteryAlertsProvider =
    StreamProvider.autoDispose.family<Set<String>, String>((ref, connectionId) =>
        DeviceRegistryDao(ref.watch(appDatabaseProvider))
            .watchBatteryAlerts(connectionId));

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

/// Asks Zigbee2MQTT to restart, so it publishes its device list again.
Future<void> restartZigbee2mqtt(
  WidgetRef ref,
  String connectionId,
  String base,
) async {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  final request = restartRequest(base);
  mgr.publish(request.topic, request.payload, '');
}

/// Asks Zigbee2MQTT to rename a device; null when it did, otherwise its
/// error (or that it didn't answer within 5 s). ZigDash's tiles follow the
/// new name through the device registry.
Future<String?> renameDevice(
  WidgetRef ref,
  String connectionId,
  String base, {
  required String from,
  required String to,
}) async {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  final responseTopic = '$base/bridge/response/device/rename';
  final answer = Completer<String?>();
  final sub = mgr.subscribe(responseTopic).listen((m) {
    try {
      final j = jsonDecode(m.payload) as Map<String, dynamic>;
      final data = j['data'];
      if (data is Map && data['to'] != to) return; // another rename
      if (!answer.isCompleted) {
        answer.complete(j['status'] == 'ok' ? null : '${j['error'] ?? '?'}');
      }
    } catch (_) {}
  });
  try {
    final request = renameRequest(base, from, to);
    mgr.publish(request.topic, request.payload, '');
    return await answer.future
        .timeout(const Duration(seconds: 5), onTimeout: () => '');
  } finally {
    unawaited(sub.cancel());
    mgr.unsubscribe(responseTopic);
  }
}

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
