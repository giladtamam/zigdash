import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../devices/device_profile.dart';
import '../../devices/device_state.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'control_action.dart';
import 'device_sheet.dart';

/// Decodes a Zigbee2MQTT state payload; anything else reads as "no state".
Map<String, Object?> decodeDeviceState(Object? payload) {
  if (payload is Map) return payload.cast<String, Object?>();
  if (payload is! String || payload.isEmpty) return const {};
  try {
    final v = json.decode(payload);
    return v is Map ? v.cast<String, Object?>() : const {};
  } catch (_) {
    return const {};
  }
}

/// Publishes a `/set` command for a device tile.
Future<void> sendDeviceCommand(
  BuildContext context,
  WidgetRef ref,
  String connectionId,
  String publishTopic,
  Map<String, Object?> command,
) =>
    runControlAction(
      context,
      ref,
      connectionId,
      (mgr) => mgr.publish(publishTopic, json.encode(command), ''),
    );

/// A whole device on the dashboard. The icon is the quick action (for
/// classes that have one), the body opens the class's controls sheet.
class DeviceTilePanel extends ConsumerWidget {
  const DeviceTilePanel({
    super.key,
    required this.connectionId,
    required this.publishTopic,
    required this.subscribeTopic,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String publishTopic;
  final String subscribeTopic;
  final Panel panel;
  final DeviceTileConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = config.profile;
    final payload = ref
        .watch(panelValueProvider(PanelStreamKey(
          connectionId: connectionId,
          topic: subscribeTopic,
          jsonPath: null,
        )))
        .valueOrNull;
    final state = DeviceState(profile, decodeDeviceState(payload));
    final cls = profile.deviceClass;
    final alarming =
        cls == DeviceClass.leakSmoke && state.alarm == true;

    void openSheet() => showDeviceSheet(
          context,
          connectionId: connectionId,
          publishTopic: publishTopic,
          subscribeTopic: subscribeTopic,
          panel: panel,
          config: config,
        );

    Future<void> toggle(DeviceFeature f) => sendDeviceCommand(
        context, ref, connectionId, publishTopic,
        DeviceCommand.toggle(f, state.isOn(f)));

    final switches = profile.switches;
    final showsSwitches = cls == DeviceClass.light ||
        cls == DeviceClass.colorLight ||
        cls == DeviceClass.switchPlug ||
        (cls == DeviceClass.generic && switches.isNotEmpty);
    final anyOn = switches.any((f) => state.isOn(f) == true);

    final big = _bigValue(state, l10n);
    final line = deviceStateLine(state, l10n);
    final color = cls == DeviceClass.colorLight ? state.lightColor : null;

    return Card(
      color: alarming
          ? scheme.errorContainer
          : anyOn
              ? scheme.primaryContainer
              : null,
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: l10n.deviceControls): openSheet,
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: openSheet,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (showsSwitches && switches.isNotEmpty)
                      for (final f in switches.take(3))
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: _QuickAction(
                            icon: deviceClassIcon(cls),
                            on: state.isOn(f),
                            tooltip: l10n.deviceToggle,
                            onPressed: () => toggle(f),
                          ),
                        )
                    else
                      Icon(
                        deviceClassIcon(cls, alarm: state.alarm),
                        color: alarming ? scheme.error : scheme.onSurfaceVariant,
                      ),
                    const Spacer(),
                    if (color != null)
                      ExcludeSemantics(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Color(0xFF000000 | color),
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (big != null)
                  Text(big, style: theme.textTheme.headlineMedium),
                Text(
                  panel.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  line,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: state.batteryLow ? scheme.error : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (cls == DeviceClass.colorLight && profile.brightness != null)
                  _InlineBrightness(
                    state: state,
                    onChanged: (pct) => sendDeviceCommand(
                        context, ref, connectionId, publishTopic,
                        DeviceCommand.brightnessPercent(
                            profile.brightness!, pct)),
                  ),
                if (cls == DeviceClass.cover)
                  _CoverControls(
                    state: state,
                    onAction: (a) => sendDeviceCommand(context, ref,
                        connectionId, publishTopic, DeviceCommand.cover(a)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The large number some classes lead with (climate, generic readings).
  String? _bigValue(DeviceState state, AppLocalizations l10n) {
    if (state.profile.deviceClass != DeviceClass.climate) return null;
    final f = state.profile.readings.firstOrNull;
    if (f == null) return null;
    final v = state.reading(f);
    return v == null ? '—' : formatReading(v, f.unit);
  }
}

/// The state line under a device tile's name: state · main value · battery.
String deviceStateLine(DeviceState state, AppLocalizations l10n) {
  if (!state.hasReported) return l10n.deviceWaiting;
  final profile = state.profile;
  final parts = <String>[];
  String onOff(bool? on) => on == null
      ? '—'
      : on
          ? l10n.deviceOn
          : l10n.deviceOff;
  switch (profile.deviceClass) {
    case DeviceClass.light:
    case DeviceClass.colorLight:
      final f = profile.switches.firstOrNull;
      parts.add(onOff(f == null ? null : state.isOn(f)));
      final pct = state.brightnessPercent;
      if (pct != null && f != null && state.isOn(f) == true) {
        parts.add(ltr('$pct%'));
      }
      final k = state.kelvin;
      if (k != null && profile.deviceClass == DeviceClass.colorLight) {
        // Nearest 100 K: bulbs report mireds, so exact kelvins read as noise.
        parts.add(ltr('${(k / 100).round() * 100} K'));
      }
    case DeviceClass.switchPlug:
    case DeviceClass.generic:
      final sw = profile.switches;
      if (sw.length > 1) {
        final on = sw.where((f) => state.isOn(f) == true).length;
        parts.add(l10n.deviceEndpointsOnOff(on, sw.length - on));
      } else if (sw.length == 1) {
        parts.add(onOff(state.isOn(sw.single)));
      }
      final r = profile.readings.firstOrNull;
      final v = r == null ? null : state.reading(r);
      if (v != null) parts.add(formatReading(v, r!.unit));
    case DeviceClass.cover:
      final s = state.values['state'];
      if (s is String) {
        parts.add(s.toUpperCase() == 'OPEN'
            ? l10n.deviceOpen
            : s.toUpperCase() == 'CLOSE' || s.toUpperCase() == 'CLOSED'
                ? l10n.deviceClosed
                : s);
      }
      final pos = state.position;
      if (pos != null) parts.add(ltr('$pos%'));
    case DeviceClass.contact:
      final a = state.alarm;
      parts.add(a == null
          ? '—'
          : a
              ? l10n.deviceClosed
              : l10n.deviceOpen);
    case DeviceClass.motion:
      final a = state.alarm;
      parts.add(a == null
          ? '—'
          : a
              ? l10n.deviceMotion
              : l10n.deviceClear);
    case DeviceClass.leakSmoke:
      final a = state.alarm;
      final p = profile.alarm?.property;
      parts.add(a == null
          ? '—'
          : !a
              ? l10n.deviceClear
              : p == 'smoke'
                  ? l10n.deviceSmokeDetected
                  : p == 'gas'
                      ? l10n.deviceGasDetected
                      : l10n.deviceLeakDetected);
    case DeviceClass.climate:
      final rs = profile.readings.skip(1).take(1);
      for (final f in rs) {
        final v = state.reading(f);
        if (v != null) parts.add(formatReading(v, f.unit));
      }
  }
  final b = state.battery;
  if (b != null) parts.add(ltr('$b%'));
  return parts.isEmpty ? '—' : parts.join(' · ');
}

/// A reading with its unit: one decimal at most, no trailing ".0". Wrapped
/// as a left-to-right run so "1200 W" never reorders in Hebrew.
String formatReading(num v, String? unit) {
  final text = v is int || v == v.roundToDouble()
      ? v.round().toString()
      : v.toStringAsFixed(1);
  if (unit == null || unit.isEmpty) return ltr(text);
  return ltr(unit == '°C' || unit == '°F' || unit == '%'
      ? '$text$unit'
      : '$text $unit');
}

/// Isolates [s] as a left-to-right run (U+2066 … U+2069).
String ltr(String s) => '\u2066$s\u2069';

IconData deviceClassIcon(DeviceClass cls, {bool? alarm}) => switch (cls) {
      DeviceClass.colorLight || DeviceClass.light => Icons.lightbulb_outline,
      DeviceClass.switchPlug => Icons.power_settings_new,
      DeviceClass.cover => Icons.blinds,
      DeviceClass.leakSmoke =>
        alarm == true ? Icons.water_damage : Icons.water_drop_outlined,
      DeviceClass.contact =>
        alarm == false ? Icons.door_front_door_outlined : Icons.sensor_door_outlined,
      DeviceClass.motion => Icons.sensors,
      DeviceClass.climate => Icons.thermostat,
      DeviceClass.generic => Icons.device_unknown_outlined,
    };

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.on,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final bool? on;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: on ?? false,
      child: on == true
          ? IconButton.filled(
              onPressed: onPressed,
              tooltip: tooltip,
              icon: Icon(icon),
            )
          : IconButton.filledTonal(
              // Unknown state: disabled until the device reports.
              onPressed: on == null ? null : onPressed,
              tooltip: tooltip,
              icon: Icon(icon),
            ),
    );
  }
}

class _InlineBrightness extends StatelessWidget {
  const _InlineBrightness({required this.state, required this.onChanged});

  final DeviceState state;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final pct = state.brightnessPercent;
    return Row(
      children: [
        const Icon(Icons.brightness_6_outlined, size: 18),
        Expanded(
          child: CommitSlider(
            label: context.l10n.deviceBrightness,
            value: pct?.toDouble(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}

class _CoverControls extends StatelessWidget {
  const _CoverControls({required this.state, required this.onAction});

  final DeviceState state;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pos = state.position;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton.outlined(
              tooltip: l10n.panelCoverOpen,
              onPressed: () => onAction('OPEN'),
              icon: const Icon(Icons.keyboard_arrow_up),
            ),
            IconButton.outlined(
              tooltip: l10n.panelCoverStop,
              onPressed: () => onAction('STOP'),
              icon: const Icon(Icons.stop),
            ),
            IconButton.outlined(
              tooltip: l10n.panelCoverClose,
              onPressed: () => onAction('CLOSE'),
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
        if (pos != null)
          Semantics(
            label: l10n.devicePosition,
            value: '$pos%',
            child: LinearProgressIndicator(value: pos / 100),
          ),
      ],
    );
  }
}

/// A slider that shows the reported value, follows the finger while
/// dragging, and sends once on release (not a command per frame). Disabled
/// while the value is unknown.
class CommitSlider extends StatefulWidget {
  const CommitSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.format,
  });

  final String label;
  final double? value;
  final double min;
  final double max;
  final String Function(double)? format;
  final ValueChanged<double> onChanged;

  @override
  State<CommitSlider> createState() => _CommitSliderState();
}

class _CommitSliderState extends State<CommitSlider> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final v = (_dragging ?? widget.value ?? widget.min)
        .clamp(widget.min, widget.max)
        .toDouble();
    return Semantics(
      label: widget.label,
      child: Slider(
        value: v,
        min: widget.min,
        max: widget.max,
        label: widget.format?.call(v),
        onChanged: widget.value == null
            ? null
            : (x) => setState(() => _dragging = x),
        onChangeEnd: (x) {
          setState(() => _dragging = null);
          widget.onChanged(x);
        },
      ),
    );
  }
}
