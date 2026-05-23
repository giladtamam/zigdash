import 'dart:convert';

/// One device's part of a scene: a full MQTT publish topic and the JSON
/// payload to send to it. [setTopic] is the complete topic including the
/// trailing `/set` (e.g. `zigbee2mqtt/living_lamp/set`), so activation needs
/// no base/prefix resolution.
class SceneAction {
  final String setTopic;
  final String payload;

  const SceneAction({required this.setTopic, required this.payload});

  Map<String, dynamic> toJson() => {'setTopic': setTopic, 'payload': payload};

  factory SceneAction.fromJson(Map<String, dynamic> json) => SceneAction(
        setTopic: (json['setTopic'] as String?) ?? '',
        payload: (json['payload'] as String?) ?? '{}',
      );

  @override
  bool operator ==(Object other) =>
      other is SceneAction &&
      other.setTopic == setTopic &&
      other.payload == payload;

  @override
  int get hashCode => Object.hash(setTopic, payload);

  @override
  String toString() => 'SceneAction($setTopic, $payload)';
}

/// A named, icon'd bundle of device actions. Activating a scene publishes each
/// action's [payload] to its [setTopic].
class Scene {
  final String id;
  final String connectionId;
  final String name;
  final int iconCodepoint;
  final int colorSeed;
  final List<SceneAction> actions;
  final int sortOrder;

  const Scene({
    required this.id,
    required this.connectionId,
    required this.name,
    required this.iconCodepoint,
    required this.colorSeed,
    required this.actions,
    this.sortOrder = 0,
  });

  /// Serialises [actions] for storage in a single text column.
  static String encodeActions(List<SceneAction> actions) =>
      jsonEncode(actions.map((a) => a.toJson()).toList());

  /// Parses an actions JSON array; returns empty on malformed input.
  static List<SceneAction> decodeActions(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SceneAction.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
