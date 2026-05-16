import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../mqtt/json_path.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';

/// Compose an absolute MQTT topic from an optional dashboard prefix and a
/// panel-level suffix. A leading `/` on [suffix] makes it absolute (the
/// prefix is ignored and the leading `/` stripped). Empty suffix collapses
/// to just the prefix — useful for Z2M state topics where the state lives
/// at the device's friendly name and commands at `friendlyName/set`.
String composeTopic(String? prefix, String suffix) {
  if (suffix.startsWith('/')) return suffix.substring(1);
  if (prefix == null || prefix.isEmpty) return suffix;
  if (suffix.isEmpty) return prefix;
  return '$prefix/$suffix';
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

/// Yields the JSON-path-extracted value of every MQTT message arriving on
/// the given topic for the given connection. Auto-disposes — when the
/// last watcher unmounts the manager's ref-count drops via [onDispose].
final panelValueProvider =
    StreamProvider.autoDispose.family<Object?, PanelStreamKey>((ref, key) async* {
  final mgr = await ref.read(mqttManagerProvider(key.connectionId).future);
  final stream = mgr.subscribe(key.topic);
  ref.onDispose(() => mgr.unsubscribe(key.topic));
  await for (final msg in stream) {
    yield extractByPath(msg.payload, key.jsonPath);
  }
});
