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
    };
  }

  static PanelConfig defaultFor(PanelType type) => switch (type) {
        PanelType.button => const ButtonConfig(payload: 'PRESS'),
        PanelType.toggle => const ToggleConfig(),
        PanelType.slider => const SliderConfig(),
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
