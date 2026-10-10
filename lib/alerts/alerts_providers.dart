import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shortcuts/shortcut_service.dart' show appChannel;

import '../mqtt/providers/mqtt_manager_provider.dart';
import 'alert_event.dart';
import 'alert_push.dart';
import 'alerts_config.dart';

/// Whether the hub's alerts flow is running (CONTEXT.md: Alerts paused):
/// its retained heartbeat on `zigdash/alerts/bridge/state`.
final alertsBridgeOnlineProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, connectionId) async* {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  const topic = AlertsConfig.bridgeStateTopic;
  final stream = mgr.subscribe(topic);
  ref.onDispose(() => mgr.unsubscribe(topic));
  await for (final m in stream) {
    yield m.payload.trim() == 'online';
  }
});

/// The last alerts that fired, kept by the hub (CONTEXT.md: Recent alerts).
final recentAlertsProvider = StreamProvider.autoDispose
    .family<List<AlertEvent>, String>((ref, connectionId) async* {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  const topic = AlertsConfig.recentTopic;
  final stream = mgr.subscribe(topic);
  ref.onDispose(() => mgr.unsubscribe(topic));
  await for (final m in stream) {
    if (m.payload.trim().isEmpty) {
      yield const [];
      continue;
    }
    try {
      final list = jsonDecode(m.payload) as List;
      yield [
        for (final e in list)
          if (e is Map) ...[?AlertEvent.decode(jsonEncode(e))],
      ];
    } catch (_) {
      yield const [];
    }
  }
});

/// Phones the hub could no longer reach (their push registration is gone).
final deadPhonesProvider = StreamProvider.autoDispose
    .family<Set<String>, String>((ref, connectionId) async* {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  const topic = AlertsConfig.stateTopic;
  final stream = mgr.subscribe(topic);
  ref.onDispose(() => mgr.unsubscribe(topic));
  await for (final m in stream) {
    try {
      final dead = (jsonDecode(m.payload) as Map)['dead'] as Map? ?? const {};
      yield {for (final e in dead.entries) if (e.value == true) '${e.key}'};
    } catch (_) {
      yield const {};
    }
  }
});

/// Whether Android holds ZigDash back in the background, which would stop
/// pushes from arriving (alerts-2.3.md, "Kept alive").
final backgroundRestrictedProvider = FutureProvider.autoDispose<bool>((ref) async {
  try {
    return await appChannel.invokeMethod<bool>('isBackgroundRestricted') ?? false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
});

/// Whether this phone can get pushes (Google services present).
final pushAvailabilityProvider =
    FutureProvider<PushAvailability>((ref) => AlertPush.availability());
