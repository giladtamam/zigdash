import 'dart:convert';

import '../../../data/database/tables/panels.dart';

/// Type-specific configuration stored as JSON in `Panels.config`. Decoded
/// on the fly in panel widgets. Refactor to a freezed sealed union once
/// the panel-type catalogue gets bigger than three.
sealed class PanelConfig {
  const PanelConfig();

  String encode() => json.encode(toJson());

  Map<String, dynamic> toJson();

  static PanelConfig decode(PanelType type, String raw) {
    final j = json.decode(raw) as Map<String, dynamic>;
    return switch (type) {
      PanelType.button => ButtonConfig.fromJson(j),
      PanelType.toggle => ToggleConfig.fromJson(j),
      PanelType.slider => SliderConfig.fromJson(j),
      PanelType.led => LedConfig.fromJson(j),
      PanelType.nodeStatus => NodeStatusConfig.fromJson(j),
      PanelType.progress => ProgressConfig.fromJson(j),
      PanelType.multiState ||
      PanelType.combo ||
      PanelType.radio =>
        OptionsConfig.fromJson(j),
      PanelType.cover => CoverConfig.fromJson(j),
      PanelType.textInput => TextInputConfig.fromJson(j),
      PanelType.textLog => TextLogConfig.fromJson(j),
      PanelType.schedule => ScheduleConfig.fromJson(j),
      PanelType.scene => SceneConfig.fromJson(j),
    };
  }

  static PanelConfig defaultFor(PanelType type) => switch (type) {
        PanelType.button => const ButtonConfig(payload: 'PRESS'),
        PanelType.toggle => const ToggleConfig(),
        PanelType.slider => const SliderConfig(),
        PanelType.led => const LedConfig(),
        PanelType.nodeStatus => const NodeStatusConfig(),
        PanelType.progress => const ProgressConfig(),
        PanelType.multiState ||
        PanelType.combo ||
        PanelType.radio =>
          OptionsConfig.coverDefault(),
        PanelType.cover => const CoverConfig(),
        PanelType.textInput => const TextInputConfig(),
        PanelType.textLog => const TextLogConfig(),
        PanelType.schedule => const ScheduleConfig(),
        PanelType.scene => const SceneConfig(),
      };
}

class ButtonConfig extends PanelConfig {
  const ButtonConfig({
    required this.payload,
    this.colorArgb,
    this.iconCodepoint,
    this.isJson = false,
  });

  final String payload;
  final int? colorArgb;
  final int? iconCodepoint;
  final bool isJson;

  @override
  Map<String, dynamic> toJson() => {
        'payload': payload,
        if (colorArgb != null) 'color': colorArgb,
        if (iconCodepoint != null) 'icon': iconCodepoint,
        'isJson': isJson,
      };

  static ButtonConfig fromJson(Map<String, dynamic> j) => ButtonConfig(
        payload: j['payload'] as String? ?? 'PRESS',
        colorArgb: j['color'] as int?,
        iconCodepoint: j['icon'] as int?,
        isJson: j['isJson'] as bool? ?? false,
      );
}

class ToggleConfig extends PanelConfig {
  const ToggleConfig({
    this.onPayload = '{"state":"ON"}',
    this.offPayload = '{"state":"OFF"}',
    this.jsonPath = 'state',
    this.onMatch = 'ON',
    this.onIconCodepoint,
    this.offIconCodepoint,
  });

  final String onPayload;
  final String offPayload;
  final String? jsonPath;
  final String onMatch;
  final int? onIconCodepoint;
  final int? offIconCodepoint;

  @override
  Map<String, dynamic> toJson() => {
        'onPayload': onPayload,
        'offPayload': offPayload,
        if (jsonPath != null) 'jsonPath': jsonPath,
        'onMatch': onMatch,
        if (onIconCodepoint != null) 'onIcon': onIconCodepoint,
        if (offIconCodepoint != null) 'offIcon': offIconCodepoint,
      };

  static ToggleConfig fromJson(Map<String, dynamic> j) => ToggleConfig(
        onPayload: j['onPayload'] as String? ?? '{"state":"ON"}',
        offPayload: j['offPayload'] as String? ?? '{"state":"OFF"}',
        jsonPath: j['jsonPath'] as String?,
        onMatch: j['onMatch'] as String? ?? 'ON',
        onIconCodepoint: j['onIcon'] as int?,
        offIconCodepoint: j['offIcon'] as int?,
      );
}

class SliderConfig extends PanelConfig {
  const SliderConfig({
    this.min = 0,
    this.max = 254,
    this.step = 1,
    this.vertical = false,
    this.valueTemplate = '{"brightness":{value}}',
    this.jsonPath = 'brightness',
  });

  final double min;
  final double max;
  final double step;
  final bool vertical;
  final String valueTemplate;
  final String? jsonPath;

  @override
  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'step': step,
        'vertical': vertical,
        'valueTemplate': valueTemplate,
        if (jsonPath != null) 'jsonPath': jsonPath,
      };

  static SliderConfig fromJson(Map<String, dynamic> j) => SliderConfig(
        min: (j['min'] as num?)?.toDouble() ?? 0,
        max: (j['max'] as num?)?.toDouble() ?? 254,
        step: (j['step'] as num?)?.toDouble() ?? 1,
        vertical: j['vertical'] as bool? ?? false,
        valueTemplate: j['valueTemplate'] as String? ?? '{"brightness":{value}}',
        jsonPath: j['jsonPath'] as String?,
      );
}

/// Read-only colored indicator. Subscribes to a topic, extracts a value via
/// [jsonPath], and lights up [onColorArgb] when the extracted value matches
/// [onMatch]. Useful for contact sensors, occupancy, leak alerts, etc.
class LedConfig extends PanelConfig {
  const LedConfig({
    this.jsonPath,
    this.onMatch = 'true',
    this.onColorArgb,
    this.offColorArgb,
    this.onLabel,
    this.offLabel,
  });

  final String? jsonPath;
  final String onMatch;
  final int? onColorArgb;
  final int? offColorArgb;
  final String? onLabel;
  final String? offLabel;

  @override
  Map<String, dynamic> toJson() => {
        if (jsonPath != null) 'jsonPath': jsonPath,
        'onMatch': onMatch,
        if (onColorArgb != null) 'onColor': onColorArgb,
        if (offColorArgb != null) 'offColor': offColorArgb,
        if (onLabel != null) 'onLabel': onLabel,
        if (offLabel != null) 'offLabel': offLabel,
      };

  static LedConfig fromJson(Map<String, dynamic> j) => LedConfig(
        jsonPath: j['jsonPath'] as String?,
        onMatch: j['onMatch'] as String? ?? 'true',
        onColorArgb: j['onColor'] as int?,
        offColorArgb: j['offColor'] as int?,
        onLabel: j['onLabel'] as String?,
        offLabel: j['offLabel'] as String?,
      );
}

/// Z2M device availability indicator. Subscribes to the availability topic
/// (typically `<prefix>/availability`, where Z2M publishes raw `online` /
/// `offline` strings by default).
class NodeStatusConfig extends PanelConfig {
  const NodeStatusConfig({
    this.onlinePayload = 'online',
    this.jsonPath,
  });

  final String onlinePayload;
  final String? jsonPath;

  @override
  Map<String, dynamic> toJson() => {
        'onlinePayload': onlinePayload,
        if (jsonPath != null) 'jsonPath': jsonPath,
      };

  static NodeStatusConfig fromJson(Map<String, dynamic> j) => NodeStatusConfig(
        onlinePayload: j['onlinePayload'] as String? ?? 'online',
        jsonPath: j['jsonPath'] as String?,
      );
}

/// Read-only progress bar. Useful for battery %, link quality, etc.
class ProgressConfig extends PanelConfig {
  const ProgressConfig({
    this.min = 0,
    this.max = 100,
    this.jsonPath,
    this.unit,
  });

  final double min;
  final double max;
  final String? jsonPath;
  final String? unit;

  @override
  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        if (jsonPath != null) 'jsonPath': jsonPath,
        if (unit != null) 'unit': unit,
      };

  static ProgressConfig fromJson(Map<String, dynamic> j) => ProgressConfig(
        min: (j['min'] as num?)?.toDouble() ?? 0,
        max: (j['max'] as num?)?.toDouble() ?? 100,
        jsonPath: j['jsonPath'] as String?,
        unit: j['unit'] as String?,
      );
}

/// A single choice in a Multi-State / Combo / Radio panel. [payload] is what
/// gets published when the option is chosen; [match] is the value at the
/// panel's [OptionsConfig.jsonPath] that marks this option as the current one.
class SelectOption {
  const SelectOption({
    required this.label,
    required this.payload,
    required this.match,
  });

  final String label;
  final String payload;
  final String match;

  Map<String, dynamic> toJson() => {
        'label': label,
        'payload': payload,
        'match': match,
      };

  static SelectOption fromJson(Map<String, dynamic> j) => SelectOption(
        label: j['label'] as String? ?? '',
        payload: j['payload'] as String? ?? '',
        match: j['match'] as String? ?? '',
      );
}

/// Shared config for the enum-selection panel types (Multi-State, Combo,
/// Radio). They differ only in how the same list of [options] is rendered.
class OptionsConfig extends PanelConfig {
  const OptionsConfig({
    this.options = const [],
    this.jsonPath = 'state',
  });

  final List<SelectOption> options;
  final String? jsonPath;

  /// Sensible default for Z2M covers: OPEN / STOP / CLOSE on the `state` field.
  factory OptionsConfig.coverDefault() => const OptionsConfig(
        jsonPath: 'state',
        options: [
          SelectOption(label: 'Open', payload: '{"state":"OPEN"}', match: 'OPEN'),
          SelectOption(label: 'Stop', payload: '{"state":"STOP"}', match: 'STOP'),
          SelectOption(label: 'Close', payload: '{"state":"CLOSE"}', match: 'CLOSE'),
        ],
      );

  @override
  Map<String, dynamic> toJson() => {
        'options': options.map((o) => o.toJson()).toList(),
        if (jsonPath != null) 'jsonPath': jsonPath,
      };

  static OptionsConfig fromJson(Map<String, dynamic> j) => OptionsConfig(
        options: (j['options'] as List?)
                ?.map((e) => SelectOption.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        jsonPath: j['jsonPath'] as String?,
      );
}

/// Composite Z2M cover control: OPEN/STOP/CLOSE buttons + a 0-100 position
/// slider with preset chips, mirroring the Zigbee2MQTT device page. Reads the
/// whole device-state payload and pulls [statePath] and [positionPath] out of
/// it; publishes `{"state":...}` for the buttons and the [positionTemplate]
/// for the slider.
class CoverConfig extends PanelConfig {
  const CoverConfig({
    this.statePath = 'state',
    this.positionPath = 'position',
    this.openPayload = '{"state":"OPEN"}',
    this.stopPayload = '{"state":"STOP"}',
    this.closePayload = '{"state":"CLOSE"}',
    this.positionTemplate = '{"position":{value}}',
    this.presets = const [0, 25, 50, 75, 100],
    this.showSlider = true,
  });

  final String statePath;
  final String positionPath;
  final String openPayload;
  final String stopPayload;
  final String closePayload;
  final String positionTemplate;
  final List<int> presets;
  final bool showSlider;

  @override
  Map<String, dynamic> toJson() => {
        'statePath': statePath,
        'positionPath': positionPath,
        'openPayload': openPayload,
        'stopPayload': stopPayload,
        'closePayload': closePayload,
        'positionTemplate': positionTemplate,
        'presets': presets,
        'showSlider': showSlider,
      };

  static CoverConfig fromJson(Map<String, dynamic> j) => CoverConfig(
        statePath: j['statePath'] as String? ?? 'state',
        positionPath: j['positionPath'] as String? ?? 'position',
        openPayload: j['openPayload'] as String? ?? '{"state":"OPEN"}',
        stopPayload: j['stopPayload'] as String? ?? '{"state":"STOP"}',
        closePayload: j['closePayload'] as String? ?? '{"state":"CLOSE"}',
        positionTemplate:
            j['positionTemplate'] as String? ?? '{"position":{value}}',
        presets: (j['presets'] as List?)?.map((e) => (e as num).toInt()).toList() ??
            const [0, 25, 50, 75, 100],
        showSlider: j['showSlider'] as bool? ?? true,
      );
}

/// Free-form publish field. The typed text is substituted into [template]
/// ({value} placeholder) before publishing — default template is just the raw
/// text. Write-only (no subscription).
class TextInputConfig extends PanelConfig {
  const TextInputConfig({
    this.hint = '',
    this.template = '{value}',
    this.clearOnSend = false,
  });

  final String hint;
  final String template;
  final bool clearOnSend;

  @override
  Map<String, dynamic> toJson() => {
        'hint': hint,
        'template': template,
        'clearOnSend': clearOnSend,
      };

  static TextInputConfig fromJson(Map<String, dynamic> j) => TextInputConfig(
        hint: j['hint'] as String? ?? '',
        template: j['template'] as String? ?? '{value}',
        clearOnSend: j['clearOnSend'] as bool? ?? false,
      );
}

/// Read-only scrolling history of messages on a topic. Keeps the last
/// [maxLines] messages; optionally extracts a [jsonPath] field instead of
/// logging the whole payload.
class TextLogConfig extends PanelConfig {
  const TextLogConfig({
    this.maxLines = 50,
    this.jsonPath,
  });

  final int maxLines;
  final String? jsonPath;

  @override
  Map<String, dynamic> toJson() => {
        'maxLines': maxLines,
        if (jsonPath != null) 'jsonPath': jsonPath,
      };

  static TextLogConfig fromJson(Map<String, dynamic> j) => TextLogConfig(
        maxLines: (j['maxLines'] as num?)?.toInt() ?? 50,
        jsonPath: j['jsonPath'] as String?,
      );
}

/// Configures a server-side daily open/close schedule executed by the
/// Node-RED scheduler flow on the SMHUB. ZigDash publishes this (plus the
/// composed target topic) as retained MQTT config — it never runs the
/// schedule itself. Times are "HH:mm" in the SMHUB's local time.
class ScheduleConfig extends PanelConfig {
  const ScheduleConfig({
    this.openTime = '07:00',
    this.closeTime = '19:00',
    this.openPayload = '{"state":"OPEN"}',
    this.closePayload = '{"state":"CLOSE"}',
    this.enabled = true,
  });

  final String openTime;
  final String closeTime;
  final String openPayload;
  final String closePayload;
  final bool enabled;

  ScheduleConfig copyWith({bool? enabled}) => ScheduleConfig(
        openTime: openTime,
        closeTime: closeTime,
        openPayload: openPayload,
        closePayload: closePayload,
        enabled: enabled ?? this.enabled,
      );

  @override
  Map<String, dynamic> toJson() => {
        'openTime': openTime,
        'closeTime': closeTime,
        'openPayload': openPayload,
        'closePayload': closePayload,
        'enabled': enabled,
      };

  static ScheduleConfig fromJson(Map<String, dynamic> j) => ScheduleConfig(
        openTime: j['openTime'] as String? ?? '07:00',
        closeTime: j['closeTime'] as String? ?? '19:00',
        openPayload: j['openPayload'] as String? ?? '{"state":"OPEN"}',
        closePayload: j['closePayload'] as String? ?? '{"state":"CLOSE"}',
        enabled: j['enabled'] as bool? ?? true,
      );
}

class SceneConfig extends PanelConfig {
  const SceneConfig({this.sceneId = ''});

  /// Id of the Scene this panel activates.
  final String sceneId;

  @override
  Map<String, dynamic> toJson() => {'sceneId': sceneId};

  static SceneConfig fromJson(Map<String, dynamic> j) =>
      SceneConfig(sceneId: j['sceneId'] as String? ?? '');
}

/// Configures a server-side "close device N seconds after it turns on" rule
/// executed by the Node-RED auto-close flow on the SMHUB. ZigDash publishes
/// this (plus the composed target topic) as retained MQTT config — it never
/// runs the timer itself. Delay is in seconds, clamped to [1, 3600].
class AutoCloseConfig extends PanelConfig {
  AutoCloseConfig({
    this.triggerPath = 'state',
    this.triggerValue = 'ON',
    this.closePayload = '{"state":"OFF"}',
    int delaySeconds = 60,
    this.enabled = true,
  }) : delaySeconds = delaySeconds.clamp(1, 3600);

  final String triggerPath;
  final String triggerValue;
  final String closePayload;
  final int delaySeconds;
  final bool enabled;

  AutoCloseConfig copyWith({bool? enabled}) => AutoCloseConfig(
        triggerPath: triggerPath,
        triggerValue: triggerValue,
        closePayload: closePayload,
        delaySeconds: delaySeconds,
        enabled: enabled ?? this.enabled,
      );

  @override
  Map<String, dynamic> toJson() => {
        'triggerPath': triggerPath,
        'triggerValue': triggerValue,
        'closePayload': closePayload,
        'delaySeconds': delaySeconds,
        'enabled': enabled,
      };

  static AutoCloseConfig fromJson(Map<String, dynamic> j) => AutoCloseConfig(
        triggerPath: j['triggerPath'] as String? ?? 'state',
        triggerValue: j['triggerValue'] as String? ?? 'ON',
        closePayload: j['closePayload'] as String? ?? '{"state":"OFF"}',
        delaySeconds: (j['delaySeconds'] as num?)?.toInt() ?? 60,
        enabled: j['enabled'] as bool? ?? true,
      );
}
