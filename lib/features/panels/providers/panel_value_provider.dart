import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../mqtt/json_path.dart';
import '../../onboarding/demo_home.dart' show demoGeneration;
import '../../../mqtt/mqtt_manager.dart';
import '../../../mqtt/mqtt_status.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';

enum PanelFreshness { fresh, stale }

class PanelValueSnapshot {
  const PanelValueSnapshot({
    required this.value,
    required this.receivedAt,
    required this.connectionGeneration,
    required this.freshness,
  });

  factory PanelValueSnapshot.fromMessage({
    required MqttRxMessage message,
    required Object? value,
    required MqttStatus status,
    required int currentGeneration,
  }) => PanelValueSnapshot(
    value: value,
    receivedAt: message.receivedAt,
    connectionGeneration: message.connectionGeneration,
    freshness:
        message.connectionGeneration == demoGeneration ||
            (status == MqttStatus.connected &&
                message.connectionGeneration == currentGeneration)
        ? PanelFreshness.fresh
        : PanelFreshness.stale,
  );

  final Object? value;
  final DateTime receivedAt;
  final int connectionGeneration;
  final PanelFreshness freshness;
}

class _ExtractedPanelMessage {
  const _ExtractedPanelMessage(this.message, this.value);

  final MqttRxMessage message;
  final Object? value;
}

/// Compose an absolute MQTT topic from an optional dashboard prefix and a
/// panel-level suffix. Leading slashes on the suffix are trimmed (they
/// mean nothing here — MQTT topics aren't paths). Empty suffix collapses
/// to just the prefix — useful for Z2M state topics where the state lives
/// at the device's friendly name and commands at `friendlyName/set`.
/// For an absolute topic that ignores the prefix entirely, clear the
/// prefix on the dashboard.
String composeTopic(String? prefix, String suffix) {
  final cleanSuffix = suffix.startsWith('/') ? suffix.replaceFirst(RegExp(r'^/+'), '') : suffix;
  if (prefix == null || prefix.isEmpty) return cleanSuffix;
  if (cleanSuffix.isEmpty) return prefix;
  return '$prefix/$cleanSuffix';
}

/// The topic a panel actually subscribes to, from the dashboard prefix, an
/// optional per-panel prefix override, and the subscribe-topic suffix.
String effectiveSubscribeTopic({
  required String dashboardPrefix,
  required String prefixOverride,
  required String subscribeSuffix,
}) {
  final prefix =
      prefixOverride.trim().isNotEmpty ? prefixOverride.trim() : dashboardPrefix;
  return composeTopic(prefix, subscribeSuffix.trim());
}

/// Key for the panel-value stream. The provider family is keyed on this
/// (not on Panel directly) so equal-but-different Panel objects from
/// successive Drift emissions don't re-create the underlying subscription.
class PanelStreamKey {
  const PanelStreamKey({
    required this.connectionId,
    required this.topic,
    required this.jsonPath,
  });

  final String connectionId;
  final String topic;
  final String? jsonPath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PanelStreamKey &&
          other.connectionId == connectionId &&
          other.topic == topic &&
          other.jsonPath == jsonPath;

  @override
  int get hashCode => Object.hash(connectionId, topic, jsonPath);
}

/// Yields the latest value together with whether it belongs to the manager's
/// current connected session.
final panelValueSnapshotProvider = StreamProvider.autoDispose
    .family<PanelValueSnapshot, PanelStreamKey>((ref, key) async* {
      final mgr = await ref.read(mqttManagerProvider(key.connectionId).future);
      final messages = mgr.subscribe(key.topic);
      ref.onDispose(() => mgr.unsubscribe(key.topic));
      final extractedMessages = messages.map(
        (message) => _ExtractedPanelMessage(
          message,
          extractByPath(message.payload, key.jsonPath),
        ),
      );
      yield* Rx.combineLatest2<
        _ExtractedPanelMessage,
        MqttStatus,
        PanelValueSnapshot
      >(
        extractedMessages,
        mgr.status$,
        (extracted, status) => PanelValueSnapshot.fromMessage(
          message: extracted.message,
          value: extracted.value,
          status: status,
          currentGeneration: mgr.connectionGeneration,
        ),
      );
    });

/// Backwards-compatible value-only projection for existing panel widgets.
final panelValueProvider = StreamProvider.autoDispose
    .family<Object?, PanelStreamKey>((ref, key) {
      // Riverpod 2 has no non-deprecated way for one StreamProvider to project
      // another while retaining the StreamProvider override API used by callers.
      // ignore: deprecated_member_use
      final snapshots = ref.watch(panelValueSnapshotProvider(key).stream);
      return snapshots.map((snapshot) => snapshot.value);
    });
