import 'dart:convert';

import '../features/discovery/models/z2m_device.dart';
import '../features/scenes/models/scene.dart';
import '../features/scenes/scene_capture.dart' show engineCanSend, jsonObjectOf;

/// An Automation (CONTEXT.md) as the Engine stores it: one retained
/// `zigdash/automations/rules/<id>` message (zigdash-3.0.md §3). Fields the
/// Engine doesn't read (labels, the scene's id) ride along so the editor can
/// show the rule again without guessing.
class Automation {
  const Automation({
    required this.id,
    required this.name,
    required this.enabled,
    required this.trigger,
    this.conditions = const [],
    required this.action,
  });

  final String id;
  final String name;
  final bool enabled;
  final AutomationTrigger trigger;
  final List<AutomationCondition> conditions;
  final AutomationAction action;

  Automation copyWith({
    String? name,
    bool? enabled,
    AutomationTrigger? trigger,
    List<AutomationCondition>? conditions,
    AutomationAction? action,
  }) =>
      Automation(
        id: id,
        name: name ?? this.name,
        enabled: enabled ?? this.enabled,
        trigger: trigger ?? this.trigger,
        conditions: conditions ?? this.conditions,
        action: action ?? this.action,
      );

  Map<String, Object?> toJson() => {
        'v': 1,
        'id': id,
        'name': name,
        'enabled': enabled,
        'trigger': trigger.toJson(),
        'conditions': [for (final c in conditions) c.toJson()],
        'action': action.toJson(),
      };

  String encode() => jsonEncode(toJson());

  /// Null for a cleared topic, or a rule this app version can't show.
  static Automation? decode(String id, String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      if (j['v'] != 1) return null;
      final trigger = AutomationTrigger.fromJson(j['trigger'] as Map<String, dynamic>);
      final action = AutomationAction.fromJson(j['action'] as Map<String, dynamic>);
      if (trigger == null || action == null) return null;
      return Automation(
        id: id,
        name: '${j['name'] ?? ''}',
        enabled: j['enabled'] != false,
        trigger: trigger,
        conditions: [
          for (final c in (j['conditions'] as List? ?? const []))
            if (c is Map<String, dynamic>) ...[?AutomationCondition.fromJson(c)],
        ],
        action: action,
      );
    } catch (_) {
      return null;
    }
  }
}

sealed class AutomationTrigger {
  const AutomationTrigger();
  Map<String, Object?> toJson();

  static AutomationTrigger? fromJson(Map<String, dynamic> j) => switch (j['type']) {
        'device' => DeviceTrigger(
            ieee: '${j['ieee']}',
            property: '${j['property']}',
            equals: j['equals'],
            above: (j['above'] as num?)?.toDouble(),
            below: (j['below'] as num?)?.toDouble(),
            label: j['label'] as String?,
          ),
        'time' => TimeTrigger(
            at: j['at'] as String?,
            sun: switch (j['sun']) { 'sunrise' => Sun.sunrise, 'sunset' => Sun.sunset, _ => null },
            offset: (j['offset'] as num?)?.toInt() ?? 0,
            days: [for (final d in (j['days'] as List? ?? const [1, 2, 3, 4, 5, 6, 7])) (d as num).toInt()],
          ),
        _ => null,
      };
}

/// A device changes: [property] becomes [equals], or rises above / falls
/// below a value.
class DeviceTrigger extends AutomationTrigger {
  const DeviceTrigger({required this.ieee, required this.property, this.equals, this.above, this.below, this.label});
  final String ieee;
  final String property;
  final Object? equals;
  final double? above;
  final double? below;

  /// The device's name when the rule was saved, for display only.
  final String? label;

  @override
  Map<String, Object?> toJson() => {
        'type': 'device',
        'ieee': ieee,
        'property': property,
        if (above != null) 'above': above else if (below != null) 'below': below else 'equals': equals,
        if (label != null) 'label': label,
      };
}

enum Sun { sunrise, sunset }

/// A time comes: [at] (HH:MM), or sunrise/sunset shifted by [offset]
/// minutes, on [days] (1 = Monday … 7 = Sunday).
class TimeTrigger extends AutomationTrigger {
  const TimeTrigger({this.at, this.sun, this.offset = 0, this.days = const [1, 2, 3, 4, 5, 6, 7]});
  final String? at;
  final Sun? sun;
  final int offset;
  final List<int> days;

  @override
  Map<String, Object?> toJson() => {
        'type': 'time',
        if (sun != null) 'sun': sun!.name else 'at': at,
        'offset': offset,
        'days': days,
      };
}

sealed class AutomationCondition {
  const AutomationCondition();
  Map<String, Object?> toJson();

  static AutomationCondition? fromJson(Map<String, dynamic> j) => switch (j['type']) {
        'hours' => HoursCondition(from: '${j['from']}', to: '${j['to']}'),
        'device' => DeviceCondition(
            ieee: '${j['ieee']}', property: '${j['property']}', equals: j['equals'], label: j['label'] as String?),
        _ => null,
      };
}

class HoursCondition extends AutomationCondition {
  const HoursCondition({required this.from, required this.to});
  final String from;
  final String to;

  @override
  Map<String, Object?> toJson() => {'type': 'hours', 'from': from, 'to': to};
}

class DeviceCondition extends AutomationCondition {
  const DeviceCondition({required this.ieee, required this.property, required this.equals, this.label});
  final String ieee;
  final String property;
  final Object? equals;
  final String? label;

  @override
  Map<String, Object?> toJson() =>
      {'type': 'device', 'ieee': ieee, 'property': property, 'equals': equals, if (label != null) 'label': label};
}

/// One command the Engine sends: to a device by IEEE address, or to a raw
/// `/set` topic when a scene entry matched no device.
class EngineCommand {
  const EngineCommand({this.ieee, this.topic, required this.payload});
  final String? ieee;
  final String? topic;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => {
        if (ieee != null) 'ieee': ieee else 'topic': topic,
        'payload': payload,
      };

  static EngineCommand fromJson(Map<String, dynamic> j) => EngineCommand(
        ieee: j['ieee'] as String?,
        topic: j['topic'] as String?,
        payload: Map<String, Object?>.from(j['payload'] as Map? ?? const {}),
      );
}

enum ActionKind { device, scene }

class AutomationAction {
  const AutomationAction({
    required this.kind,
    required this.commands,
    this.offAfter = 0,
    this.sceneId,
    this.label,
  });

  final ActionKind kind;
  final List<EngineCommand> commands;

  /// Minutes until the action is turned off again; 0 = stays as set.
  final int offAfter;
  final String? sceneId;

  /// The device or scene name when saved, for display only.
  final String? label;

  Map<String, Object?> toJson() => {
        'type': kind.name,
        'commands': [for (final c in commands) c.toJson()],
        if (offAfter > 0) 'offAfter': offAfter,
        if (sceneId != null) 'scene_id': sceneId,
        if (label != null) 'label': label,
      };

  static AutomationAction? fromJson(Map<String, dynamic> j) {
    final kind = switch (j['type']) { 'device' => ActionKind.device, 'scene' => ActionKind.scene, _ => null };
    if (kind == null) return null;
    return AutomationAction(
      kind: kind,
      commands: [
        for (final c in (j['commands'] as List? ?? const []))
          if (c is Map<String, dynamic>) EngineCommand.fromJson(c),
      ],
      offAfter: (j['offAfter'] as num?)?.toInt() ?? 0,
      sceneId: j['scene_id'] as String?,
      label: j['label'] as String?,
    );
  }

  /// The device action's state ("ON", "OFF", "OPEN", …), if it is one.
  String? get deviceState => kind == ActionKind.device && commands.isNotEmpty
      ? commands.first.payload['state'] as String?
      : null;
}

// ---------- what a device offers ----------

/// One thing a device can trigger on, from its exposes.
class TriggerOption {
  const TriggerOption({required this.property, this.choices = const [], this.unit, this.numeric = false});
  final String property;

  /// Values to match for binary and enum exposes (e.g. true/false, "single").
  final List<Object> choices;
  final String? unit;
  final bool numeric;
}

const _numericTriggers = {
  'temperature', 'humidity', 'illuminance', 'illuminance_lux', 'co2', 'pm25', 'voc', 'power', 'battery', 'soil_moisture',
};

/// What [device] can trigger an automation on: binary states (occupancy,
/// contact, water leak…), button actions, on/off state and readings.
List<TriggerOption> triggerOptionsFor(Z2mDevice device) {
  final out = <String, TriggerOption>{};
  void visit(Object? e) {
    if (e is! Map) return;
    final features = e['features'];
    if (features is List) {
      for (final f in features) {
        visit(f);
      }
    }
    final prop = e['property'];
    if (prop is! String || out.containsKey(prop)) return;
    final access = e['access'];
    if (access is int && access & 1 == 0) return; // not published
    switch (e['type']) {
      case 'binary':
        final on = e['value_on'], off = e['value_off'];
        if (on != null && off != null && prop != 'linkquality') {
          out[prop] = TriggerOption(property: prop, choices: [on as Object, off as Object]);
        }
      case 'enum':
        final values = e['values'];
        if (values is List && values.isNotEmpty) {
          out[prop] = TriggerOption(property: prop, choices: [for (final v in values) '$v']);
        }
      case 'numeric':
        if (_numericTriggers.contains(prop)) {
          out[prop] = TriggerOption(property: prop, numeric: true, unit: e['unit'] as String?);
        }
    }
  }

  device.rawExposes.forEach(visit);
  // Lights and switches publish state ON/OFF inside their composite expose.
  for (final x in device.exposes) {
    if ((x.type == 'light' || x.type == 'switch') && !out.containsKey('state')) {
      out['state'] = const TriggerOption(property: 'state', choices: ['ON', 'OFF']);
    }
  }
  return out.values.toList();
}

/// The states an action can set on [device], or empty if it has none.
List<String> actionStatesFor(Z2mDevice device) {
  for (final x in device.exposes) {
    if (x.type == 'light' || x.type == 'switch') return const ['ON', 'OFF', 'TOGGLE'];
    if (x.type == 'cover') return const ['OPEN', 'CLOSE', 'STOP'];
  }
  return const [];
}

/// Resolves a Scene's `/set` topics into Engine commands by IEEE address, so
/// a renamed device keeps working; a topic that matches no device is kept as
/// a raw topic command. Actions the Engine can't send (a raw payload, a
/// topic outside the base: own tiles, 3.8.7) are left out, not sent as `{}`.
List<EngineCommand> sceneCommands(List<SceneAction> actions, List<Z2mDevice> devices, String base) {
  final byTopic = {
    for (final d in devices)
      if (d.ieeeAddress != null) '$base/${d.friendlyName}/set': d.ieeeAddress!,
  };
  return [
    for (final a in actions)
      if (engineCanSend(a, base))
        if (byTopic[a.setTopic] case final ieee?)
          EngineCommand(ieee: ieee, payload: jsonObjectOf(a.payload)!)
        else
          EngineCommand(topic: a.setTopic, payload: jsonObjectOf(a.payload)!),
  ];
}

/// Free Homes get this many Automations (zigdash-3.0.md §1).
const freeAutomations = 3;
