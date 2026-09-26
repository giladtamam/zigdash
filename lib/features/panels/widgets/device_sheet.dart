import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../devices/device_profile.dart';
import '../../devices/device_state.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'device_tile_panel.dart';

/// Preset colours offered for colour lights (warm first, as on the board).
const deviceColorPresets = [
  0xFFA040,
  0xFFD060,
  0xFFFFFF,
  0x9EC5FF,
  0xFF6060,
  0xC080FF,
  0x80E890,
  0x4A90FF,
];

/// Opens the full controls for a device tile.
Future<void> showDeviceSheet(
  BuildContext context, {
  required String connectionId,
  required String publishTopic,
  required String subscribeTopic,
  required Panel panel,
  required DeviceTileConfig config,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DeviceSheet(
        connectionId: connectionId,
        publishTopic: publishTopic,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config,
      ),
    );

class DeviceSheet extends ConsumerWidget {
  const DeviceSheet({
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
    final profile = config.profile;
    final cls = profile.deviceClass;
    final payload = ref
        .watch(panelValueProvider(PanelStreamKey(
          connectionId: connectionId,
          topic: subscribeTopic,
          jsonPath: null,
        )))
        .valueOrNull;
    final state = DeviceState(profile, decodeDeviceState(payload));

    Future<void> send(Map<String, Object?> command) => sendDeviceCommand(
        context, ref, connectionId, publishTopic, command);

    final children = <Widget>[
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(deviceClassIcon(cls, alarm: state.alarm), size: 32),
        title: Text(panel.name, style: theme.textTheme.titleLarge),
        subtitle: Text([
          deviceStateLine(state, l10n),
          ?config.model,
        ].join(' · ')),
      ),
    ];

    final switches = profile.switches;
    for (final (i, f) in switches.indexed) {
      children.add(SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(switches.length > 1
            ? _endpointLabel(f.endpoint, i)
            : l10n.deviceToggle),
        value: state.isOn(f) ?? false,
        onChanged: (_) => send(DeviceCommand.toggle(f, state.isOn(f))),
      ));
    }

    final brightness = profile.brightness;
    if (brightness != null) {
      children.add(_Labeled(
        label: l10n.deviceBrightness,
        trailing: state.brightnessPercent == null
            ? '—'
            : '${state.brightnessPercent}%',
        child: CommitSlider(
          label: l10n.deviceBrightness,
          value: state.brightnessPercent?.toDouble(),
          format: (v) => '${v.round()}%',
          onChanged: (v) =>
              send(DeviceCommand.brightnessPercent(brightness, v.round())),
        ),
      ));
    }

    final colorTemp = profile.colorTemp;
    if (colorTemp != null) {
      // Kelvin runs opposite to mired: warmest (max mired) is the lowest K.
      final kMin = 1e6 / (colorTemp.max ?? 500);
      final kMax = 1e6 / (colorTemp.min ?? 153);
      final kelvin = state.kelvin?.toDouble();
      children.add(_Labeled(
        label: l10n.deviceWhite,
        trailing: kelvin == null ? '—' : '${kelvin.round()} K',
        child: CommitSlider(
          label: l10n.deviceWhite,
          // A bulb in colour mode still takes a white command.
          value: kelvin ?? (state.hasReported ? (kMin + kMax) / 2 : null),
          min: kMin,
          max: kMax,
          format: (v) => '${v.round()} K',
          onChanged: (v) => send(DeviceCommand.kelvin(colorTemp, v.round())),
        ),
      ));
    }

    if (cls == DeviceClass.colorLight) {
      final current = state.lightColor;
      children.add(_Labeled(
        label: l10n.deviceColor,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final c in deviceColorPresets)
              _Swatch(
                rgb: c,
                selected: current == c,
                label: '#${c.toRadixString(16).padLeft(6, '0')}',
                onTap: () => send(DeviceCommand.color(c)),
              ),
          ],
        ),
      ));
      children.add(_Labeled(
        label: l10n.deviceHue,
        child: CommitSlider(
          label: l10n.deviceHue,
          value: state.hasReported ? _hueOf(state) : null,
          max: 359,
          format: (v) => '${v.round()}°',
          onChanged: (h) => send(DeviceCommand.color(hsToRgb(h, 100))),
        ),
      ));
    }

    if (cls == DeviceClass.cover) {
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (action, icon, label) in [
            ('OPEN', Icons.keyboard_arrow_up, l10n.panelCoverOpen),
            ('STOP', Icons.stop, l10n.panelCoverStop),
            ('CLOSE', Icons.keyboard_arrow_down, l10n.panelCoverClose),
          ])
            FilledButton.tonalIcon(
              onPressed: () => send(DeviceCommand.cover(action)),
              icon: Icon(icon),
              label: Text(label),
            ),
        ],
      ));
      final position = profile.position;
      if (position != null && position.settable) {
        children.add(_Labeled(
          label: l10n.devicePosition,
          trailing: state.position == null ? '—' : '${state.position}%',
          child: CommitSlider(
            label: l10n.devicePosition,
            value: state.position?.toDouble() ?? (state.hasReported ? 0 : null),
            format: (v) => '${v.round()}%',
            onChanged: (v) => send(DeviceCommand.position(position, v.round())),
          ),
        ));
      }
    }

    final readings = profile.readings;
    for (final f in readings) {
      final v = state.reading(f);
      children.add(ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(_humanize(f.property)),
        trailing: Text(v == null ? '—' : formatReading(v, f.unit),
            style: theme.textTheme.titleMedium),
      ));
    }
    if (state.battery != null) {
      children.add(ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: Icon(state.batteryLow ? Icons.battery_alert : Icons.battery_std,
            color: state.batteryLow ? theme.colorScheme.error : null),
        title: Text(l10n.deviceBattery(state.battery!)),
      ));
    }

    final more = [
      for (final f in profile.features)
        if (!f.normal && f.readable && state.values[f.property] != null) f,
    ];
    if (more.isNotEmpty) {
      children.add(ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(l10n.deviceMore),
        children: [
          for (final f in more)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(_humanize(f.property)),
              trailing: Text('${state.values[f.property]}'
                  '${f.unit == null ? '' : ' ${f.unit}'}'),
            ),
        ],
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  static double? _hueOf(DeviceState state) {
    final color = state.values['color'];
    if (color is Map && color['hue'] is num) {
      return (color['hue'] as num).toDouble();
    }
    return 0;
  }

  /// `l1` → "1", `left` → "Left"; falls back to the position.
  static String _endpointLabel(String? endpoint, int index) {
    if (endpoint == null || endpoint.isEmpty) return '${index + 1}';
    final digits = RegExp(r'\d+$').firstMatch(endpoint)?.group(0);
    if (digits != null) return digits;
    return endpoint[0].toUpperCase() + endpoint.substring(1);
  }

  static String _humanize(String property) {
    final s = property.replaceAll('_', ' ');
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child, this.trailing});

  final String label;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
              if (trailing != null)
                Text(trailing!, style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.rgb,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final int rgb;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Color(0xFF000000 | rgb),
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 3 : 1,
            ),
          ),
        ),
      ),
    );
  }
}
