import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';

/// The set of binary `property` values that map to a read-only **led** panel
/// (presence/safety sensors).
const _binarySensorProperties = {
  'contact',
  'occupancy',
  'presence',
  'water_leak',
  'vibration',
  'smoke',
  'gas',
  'tamper',
  'battery_low',
};

/// A suggested ZigDash panel derived from a Z2M device's `exposes`.
class PanelSuggestion {
  /// The recommended panel type.
  final PanelType type;

  /// Display name (= device friendly_name).
  final String name;

  /// Full topic prefix to subscribe/publish to:
  /// `"<base>/<friendlyName>"` — e.g. `"zigbee2mqtt/office_light"`.
  final String topicPrefixOverride;

  /// Suffix appended to [topicPrefixOverride] when publishing:
  /// `"set"` for controllable panels, `""` for read-only sensors.
  final String publishTopicSuffix;

  /// Suffix for the subscribe topic.  `""` means subscribe to
  /// [topicPrefixOverride] itself (the Z2M state topic).
  final String subscribeTopicSuffix;

  /// JSON key to extract from the incoming MQTT payload
  /// (e.g. "state", "brightness", "contact", "battery").
  /// `null` for textLog fallback.
  final String? jsonPath;

  /// For toggle / led panels: the string value that represents "on"
  /// (e.g. "ON" or "true").
  final String? onMatch;

  /// For progress panels: the unit label (e.g. "%"). `null` if none.
  final String? unit;

  /// Slider preset hint: `true` = brightness (0–254), `false` = position
  /// (0–100). Only meaningful when [type] == [PanelType.slider].
  final bool sliderIsBrightness;

  const PanelSuggestion({
    required this.type,
    required this.name,
    required this.topicPrefixOverride,
    required this.publishTopicSuffix,
    required this.subscribeTopicSuffix,
    this.jsonPath,
    this.onMatch,
    this.unit,
    this.sliderIsBrightness = false,
  });
}

/// Maps a [Z2mDevice]'s exposes to the most appropriate [PanelSuggestion].
///
/// Rules are applied in priority order; the first match wins.
/// [base] is the Z2M topic base (default `"zigbee2mqtt"`).
PanelSuggestion suggestPanel(Z2mDevice device, {String base = 'zigbee2mqtt'}) {
  final prefix = '$base/${device.friendlyName}';
  final exposes = device.exposes;

  // 1. Light — slider (brightness)
  if (exposes.any((e) => e.type == 'light')) {
    return PanelSuggestion(
      type: PanelType.slider,
      name: device.friendlyName,
      topicPrefixOverride: prefix,
      publishTopicSuffix: 'set',
      subscribeTopicSuffix: '',
      jsonPath: 'brightness',
      sliderIsBrightness: true,
    );
  }

  // 2. Cover — cover panel
  if (exposes.any((e) => e.type == 'cover')) {
    return PanelSuggestion(
      type: PanelType.cover,
      name: device.friendlyName,
      topicPrefixOverride: prefix,
      publishTopicSuffix: 'set',
      subscribeTopicSuffix: '',
      jsonPath: 'position',
    );
  }

  // 3. Switch or binary with property == "state" → toggle
  final hasSwitch = exposes.any((e) => e.type == 'switch');
  final hasBinaryState = exposes.any(
    (e) => e.type == 'binary' && e.property == 'state',
  );
  if (hasSwitch || hasBinaryState) {
    return PanelSuggestion(
      type: PanelType.toggle,
      name: device.friendlyName,
      topicPrefixOverride: prefix,
      publishTopicSuffix: 'set',
      subscribeTopicSuffix: '',
      jsonPath: 'state',
      onMatch: 'ON',
    );
  }

  // 4. Binary sensor expose matching a known presence/safety property → led
  final sensorExpose = exposes.cast<Z2mExpose?>().firstWhere(
        (e) =>
            e != null &&
            e.type == 'binary' &&
            e.property != null &&
            _binarySensorProperties.contains(e.property),
        orElse: () => null,
      );
  if (sensorExpose != null) {
    return PanelSuggestion(
      type: PanelType.led,
      name: device.friendlyName,
      topicPrefixOverride: prefix,
      publishTopicSuffix: '',
      subscribeTopicSuffix: '',
      jsonPath: sensorExpose.property,
      onMatch: sensorExpose.valueOn ?? 'true',
    );
  }

  // 5a. Numeric expose with property == "battery" → progress (%)
  final batteryExpose = exposes.cast<Z2mExpose?>().firstWhere(
        (e) => e != null && e.type == 'numeric' && e.property == 'battery',
        orElse: () => null,
      );
  if (batteryExpose != null) {
    return PanelSuggestion(
      type: PanelType.progress,
      name: device.friendlyName,
      topicPrefixOverride: prefix,
      publishTopicSuffix: '',
      subscribeTopicSuffix: '',
      jsonPath: 'battery',
      unit: '%',
    );
  }

  // 5b. Numeric expose with property == "linkquality" → progress (no unit)
  final lqExpose = exposes.cast<Z2mExpose?>().firstWhere(
        (e) => e != null && e.type == 'numeric' && e.property == 'linkquality',
        orElse: () => null,
      );
  if (lqExpose != null) {
    return PanelSuggestion(
      type: PanelType.progress,
      name: device.friendlyName,
      topicPrefixOverride: prefix,
      publishTopicSuffix: '',
      subscribeTopicSuffix: '',
      jsonPath: 'linkquality',
    );
  }

  // 6. Enum expose → combo
  final enumExpose = exposes.cast<Z2mExpose?>().firstWhere(
        (e) => e != null && e.type == 'enum',
        orElse: () => null,
      );
  if (enumExpose != null) {
    return PanelSuggestion(
      type: PanelType.combo,
      name: device.friendlyName,
      topicPrefixOverride: prefix,
      publishTopicSuffix: 'set',
      subscribeTopicSuffix: '',
      jsonPath: enumExpose.property,
    );
  }

  // 7. Fallback → textLog (read-only)
  return PanelSuggestion(
    type: PanelType.textLog,
    name: device.friendlyName,
    topicPrefixOverride: prefix,
    publishTopicSuffix: '',
    subscribeTopicSuffix: '',
  );
}
