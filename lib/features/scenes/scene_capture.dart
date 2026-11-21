import 'dart:convert';

import '../../data/database/database.dart' show Panel;
import '../../data/database/tables/panels.dart';
import '../../mqtt/json_path.dart';
import '../discovery/models/z2m_device.dart';
import '../panels/models/panel_config.dart';
import '../panels/providers/panel_value_provider.dart' show composeTopic;
import '../panels/widgets/panel_tile.dart' show panelReliabilityPolicy;
import 'models/scene.dart';

/// Returns the subset of [currentState] whose keys are *settable* on [device]
/// — i.e. the device exposes that property with the SET access bit. Read-only
/// fields the device reports (e.g. `battery`, `linkquality`, `last_seen`) and
/// keys the device doesn't expose at all are dropped, so the captured payload
/// is safe to publish back to `<device>/set`.
Map<String, dynamic> captureSettableState(
  Z2mDevice device,
  Map<String, dynamic> currentState,
) {
  final settable = <String>{
    for (final e in device.exposes)
      if (e.isSettable) e.property!,
  };
  return {
    for (final entry in currentState.entries)
      if (settable.contains(entry.key)) entry.key: entry.value,
  };
}

/// A single editable control shown for a device in the scene editor.
enum SceneControlKind { toggle, slider }

class SceneControl {
  const SceneControl({
    required this.property,
    required this.kind,
    this.min = 0,
    this.max = 100,
    this.unit,
    this.onValue = 'ON',
    this.offValue = 'OFF',
  });

  final String property;
  final SceneControlKind kind;
  final double min;
  final double max;
  final String? unit;
  final String onValue;
  final String offValue;

  @override
  bool operator ==(Object other) =>
      other is SceneControl &&
      other.property == property &&
      other.kind == kind &&
      other.min == min &&
      other.max == max &&
      other.onValue == onValue &&
      other.offValue == offValue;

  @override
  int get hashCode => Object.hash(property, kind, min, max, onValue, offValue);
}

/// Derives the editable controls for a device from its settable exposes.
/// Covers → a `position` slider (0–100); lights/switches → a `state` on/off
/// toggle and a `brightness` slider (0–254). Other settable props are left to
/// raw capture (not shown as controls) to keep the editor focused.
List<SceneControl> sceneControlsFor(Z2mDevice device) {
  final out = <SceneControl>[];
  final seen = <String>{};
  for (final e in device.exposes) {
    if (!e.isSettable || e.property == null) continue;
    final p = e.property!;
    if (!seen.add(p)) continue;
    switch (p) {
      case 'state':
        if (e.type == 'binary') {
          out.add(SceneControl(
            property: 'state',
            kind: SceneControlKind.toggle,
            onValue: e.valueOn ?? 'ON',
          ));
        }
      case 'brightness':
        out.add(const SceneControl(
            property: 'brightness', kind: SceneControlKind.slider, max: 254));
      case 'position':
        out.add(const SceneControl(
            property: 'position',
            kind: SceneControlKind.slider,
            max: 100,
            unit: '%'));
    }
  }
  return out;
}

/// Seeds the editor's values for a device from its current [state] (when
/// known), falling back to sensible defaults. Toggles resolve to on/off
/// values; sliders to rounded ints.
Map<String, dynamic> initialSceneEdits(
  Z2mDevice device,
  Map<String, dynamic>? state,
) {
  final out = <String, dynamic>{};
  for (final c in sceneControlsFor(device)) {
    final live = state?[c.property];
    if (c.kind == SceneControlKind.toggle) {
      final isOn = live == null ? true : live.toString() == c.onValue;
      out[c.property] = isOn ? c.onValue : c.offValue;
    } else {
      final v = live is num
          ? live.toDouble()
          : (c.max / 2); // mid-range default
      out[c.property] = v.round().clamp(c.min.round(), c.max.round());
    }
  }
  return out;
}

/// Builds a Zigbee2MQTT `/get` payload that asks the device to report the
/// current value of every property that is BOTH readable and settable
/// (`access & 0x06 == 0x06`). Returns an empty map when nothing is both
/// gettable and settable (so callers can skip publishing). Z2M answers a
/// `<device>/get` of `{"position":""}` by reading the device and publishing
/// fresh state to `<device>` — which is what the capture flow then snapshots.
Map<String, String> buildGetPayload(Z2mDevice device) {
  const gettableSettable = 0x06; // get (0x04) | set (0x02)
  return {
    for (final e in device.exposes)
      if (e.property != null && (e.access & gettableSettable) == gettableSettable)
        e.property!: '',
  };
}

/// Builds a [SceneAction] for one device from its settable state snapshot.
/// [base] is the connection/dashboard topic prefix (e.g. `zigbee2mqtt`).
/// Returns null when there's nothing settable to publish.
SceneAction? buildSceneAction({
  required String base,
  required String friendlyName,
  required Map<String, dynamic> settableState,
}) {
  if (settableState.isEmpty) return null;
  return SceneAction(
    setTopic: '$base/$friendlyName/set',
    payload: jsonEncode(settableState),
  );
}

/// Convenience: capture a device's settable state from its raw retained state
/// JSON and turn it into a [SceneAction]. Returns null when the state is
/// malformed or nothing is settable.
SceneAction? captureDeviceAction({
  required String base,
  required Z2mDevice device,
  required String rawStateJson,
}) {
  Map<String, dynamic> state;
  try {
    final decoded = jsonDecode(rawStateJson);
    if (decoded is! Map<String, dynamic>) return null;
    state = decoded;
  } catch (_) {
    return null;
  }
  final settable = captureSettableState(device, state);
  return buildSceneAction(
    base: base,
    friendlyName: device.friendlyName,
    settableState: settable,
  );
}

// ---------------------------------------------------------------------------
// The user's own tiles in scenes (3.8.7, scene-own-tiles-387.md).

/// The tile types a scene can send: controls that publish a command.
/// Text input (owner), schedule/auto-close (config, not commands), scene
/// tiles (a scene in a scene loops), read-only types and device tiles (they
/// are the device rows) stay out.
const sceneTileTypes = {
  PanelType.toggle,
  PanelType.slider,
  PanelType.button,
  PanelType.multiState,
  PanelType.combo,
  PanelType.radio,
  PanelType.cover,
};

/// A tile the user made that a scene can send (3.8.7): its name, where it
/// lives, and the topics it publishes and reads on, composed as the
/// dashboard composes them (`panel_tile.dart`).
class SceneTile {
  const SceneTile({
    required this.panelId,
    required this.name,
    this.dashboardName,
    required this.type,
    required this.config,
    this.deviceIeee,
    required this.publishTopic,
    required this.subscribeTopic,
    this.jsonPath,
  });

  final String panelId;
  final String name;
  final String? dashboardName;
  final PanelType type;
  final PanelConfig config;

  /// Set only when the tile was made with "Pick a device"; matching goes by
  /// topic, never by this.
  final String? deviceIeee;
  final String publishTopic;
  final String subscribeTopic;

  /// The path the tile reads its value at (null: the whole payload, as a
  /// cover reads it).
  final String? jsonPath;

  /// Whether the tile reads a value the editor can seed from.
  bool get subscribes => type != PanelType.button;

  /// A slider with no range or a choice tile with no options can't send
  /// anything, on the dashboard or in a scene: listed, never ticked.
  bool get disabled => switch (config) {
        SliderConfig c => c.min >= c.max,
        OptionsConfig c => c.options.isEmpty,
        _ => false,
      };
}

/// The Home's scene-able tiles, in dashboard then tile order, and the names
/// of its device tiles by IEEE address (the first in that order), which the
/// device rows show (3.8.7).
class SceneTiles {
  const SceneTiles({
    this.tiles = const [],
    this.deviceNames = const {},
    this.dashboards = 1,
  });

  static const empty = SceneTiles();

  final List<SceneTile> tiles;
  final Map<String, String> deviceNames;

  /// How many dashboards the Home has: with more than one, each tile shows
  /// its dashboard's name.
  final int dashboards;
}

/// [panel] as a scene tile, or null for a type a scene doesn't send (or a
/// config that doesn't decode). [dashboardPrefix] is the dashboard's topic
/// prefix; the tile's own override wins, as on the dashboard.
SceneTile? sceneTileOf(
  Panel panel,
  String? dashboardPrefix, {
  String? dashboardName,
}) {
  if (!sceneTileTypes.contains(panel.type)) return null;
  final PanelConfig config;
  try {
    config = PanelConfig.decode(panel.type, panel.config);
  } catch (_) {
    return null;
  }
  final prefix = panel.topicPrefixOverride ?? dashboardPrefix;
  return SceneTile(
    panelId: panel.id,
    name: panel.name,
    dashboardName: dashboardName,
    type: panel.type,
    config: config,
    deviceIeee: panel.deviceIeee,
    publishTopic: composeTopic(prefix, panel.topic),
    subscribeTopic: composeTopic(prefix, panel.subscribeTopic ?? panel.topic),
    jsonPath: panelReliabilityPolicy(panel.type).jsonPath(config),
  );
}

/// A slider tile's divisions, the tile's own rule (`slider_panel.dart`):
/// none when the step is 0 or less.
int? sliderDivisions(SliderConfig c) =>
    c.step > 0 && c.max > c.min ? ((c.max - c.min) / c.step).round() : null;

/// What a cover tile does in a scene.
enum SceneCoverChoice { open, close, stop, position }

/// A cover tile's value in the editor: a button, or a position (0–100).
class SceneCoverValue {
  const SceneCoverValue(this.choice, [this.position = 50]);

  final SceneCoverChoice choice;
  final int position;

  @override
  bool operator ==(Object other) =>
      other is SceneCoverValue &&
      other.choice == choice &&
      (choice != SceneCoverChoice.position || other.position == position);

  @override
  int get hashCode => Object.hash(
      choice, choice == SceneCoverChoice.position ? position : null);

  @override
  String toString() => 'SceneCoverValue($choice, $position)';
}

int _sliderValue(SliderConfig c, Object? value) {
  final v = value is num ? value.toDouble() : (c.min + c.max) / 2;
  return v.clamp(c.min, c.max).round();
}

/// The action [tile] sends for [value] (bool for a toggle, a number for a
/// slider, an option index, a [SceneCoverValue]; ignored for a button):
/// the topic and payload the tile itself publishes, `{value}` resolved now.
/// Null for a disabled tile.
SceneAction? buildTileAction(SceneTile tile, Object? value) {
  if (tile.disabled) return null;
  final payload = switch (tile.config) {
    ToggleConfig c => value == false ? c.offPayload : c.onPayload,
    SliderConfig c =>
      c.valueTemplate.replaceAll('{value}', '${_sliderValue(c, value)}'),
    ButtonConfig c => c.payload,
    OptionsConfig c =>
      c.options[(value is int ? value : 0).clamp(0, c.options.length - 1)]
          .payload,
    CoverConfig c => switch (value) {
        SceneCoverValue(choice: SceneCoverChoice.close) => c.closePayload,
        SceneCoverValue(choice: SceneCoverChoice.stop) => c.stopPayload,
        SceneCoverValue(choice: SceneCoverChoice.position, :final position)
            when c.showSlider =>
          c.positionTemplate
              .replaceAll('{value}', '${position.clamp(0, 100)}'),
        _ => c.openPayload,
      },
    _ => null,
  };
  if (payload == null) return null;
  return SceneAction(setTopic: tile.publishTopic, payload: payload);
}

/// The number [payload] carries where [template] has `{value}`, the rest
/// matched literally; null when it doesn't fit. A template without
/// `{value}` matches only itself and carries no number.
num? templateValue(String template, String payload) {
  final parts = template.split('{value}');
  if (parts.length == 1) return null;
  final pattern = StringBuffer('^');
  for (final (i, part) in parts.indexed) {
    pattern.write(RegExp.escape(part));
    if (i < parts.length - 1) {
      pattern.write(i == 0 ? r'(-?\d+(?:\.\d+)?)' : r'\1');
    }
  }
  pattern.write(r'$');
  final m = RegExp(pattern.toString()).firstMatch(payload);
  return m == null ? null : num.parse(m.group(1)!);
}

/// The editor value [tile] would send [payload] with, or null when the tile
/// can't send it: how a stored scene action finds its tile again.
Object? tileValueOf(SceneTile tile, String payload) {
  if (tile.disabled) return null;
  switch (tile.config) {
    case ToggleConfig c:
      if (payload == c.onPayload) return true;
      if (payload == c.offPayload) return false;
    case SliderConfig c:
      final v = templateValue(c.valueTemplate, payload) ??
          (payload == c.valueTemplate ? c.min : null);
      if (v != null) return v.toDouble().clamp(c.min, c.max);
    case ButtonConfig c:
      if (payload == c.payload) return true;
    case OptionsConfig c:
      final i = c.options.indexWhere((o) => o.payload == payload);
      if (i >= 0) return i;
    case CoverConfig c:
      if (payload == c.openPayload) {
        return const SceneCoverValue(SceneCoverChoice.open);
      }
      if (payload == c.closePayload) {
        return const SceneCoverValue(SceneCoverChoice.close);
      }
      if (payload == c.stopPayload) {
        return const SceneCoverValue(SceneCoverChoice.stop);
      }
      if (c.showSlider) {
        final v = templateValue(c.positionTemplate, payload) ??
            (payload == c.positionTemplate ? 0 : null);
        if (v != null) {
          return SceneCoverValue(
              SceneCoverChoice.position, v.clamp(0, 100).round());
        }
      }
    default:
  }
  return null;
}

/// The editor's first value for [tile] when ticked, from the tile's [live]
/// value (what its stream extracted; a cover's is the whole payload), else
/// the defaults: on, mid-range, the first option, Open.
Object? tileSeedValue(SceneTile tile, Object? live) {
  if (tile.disabled) return null;
  switch (tile.config) {
    case ToggleConfig c:
      return live == null ? true : live.toString() == c.onMatch;
    case SliderConfig c:
      final n = live is num ? live : num.tryParse('${live ?? ''}');
      return (n?.toDouble() ?? (c.min + c.max) / 2).clamp(c.min, c.max);
    case OptionsConfig c:
      if (live == null) return 0;
      final i = c.options.indexWhere((o) => o.match == live.toString());
      return i < 0 ? 0 : i;
    case CoverConfig c:
      if (live == null) return const SceneCoverValue(SceneCoverChoice.open);
      final raw = live.toString();
      final p = extractByPath(raw, c.positionPath);
      final position = p is num ? p : num.tryParse('${p ?? ''}');
      if (c.showSlider && position != null) {
        return SceneCoverValue(
            SceneCoverChoice.position, position.clamp(0, 100).round());
      }
      final state = extractByPath(raw, c.statePath)?.toString().toUpperCase();
      return switch (state) {
        'CLOSE' || 'CLOSED' || 'CLOSING' =>
          const SceneCoverValue(SceneCoverChoice.close),
        'STOP' || 'STOPPED' => const SceneCoverValue(SceneCoverChoice.stop),
        _ => const SceneCoverValue(SceneCoverChoice.open),
      };
    default:
      return true;
  }
}

/// The JSON object a `/set` payload carries, or null when it isn't one.
Map<String, dynamic>? jsonObjectOf(String payload) {
  try {
    final d = jsonDecode(payload);
    return d is Map<String, dynamic> ? d : null;
  } catch (_) {
    return null;
  }
}

/// Whether the Engine on the hub (and the hub away, through the relay)
/// can send [action]: a JSON object to `<base>/…/set`. Anything else runs
/// only from this phone at home (3.8.7). Shared by the scene editor's note,
/// [sceneCommands] and the shortcut confirmation, so the three agree.
bool engineCanSend(SceneAction action, String base) =>
    action.setTopic.startsWith('$base/') &&
    action.setTopic.endsWith('/set') &&
    action.setTopic.length > base.length + 5 &&
    jsonObjectOf(action.payload) != null;

/// The settable-state map [device]'s row would build for [payload]: a
/// non-empty JSON object whose keys are all settable on the device; null
/// when the row couldn't have made it (3.8.7).
Map<String, dynamic>? deviceRowPayload(Z2mDevice device, String payload) {
  final map = jsonObjectOf(payload);
  if (map == null || map.isEmpty) return null;
  return captureSettableState(device, map).length == map.length ? map : null;
}
