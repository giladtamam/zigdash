import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
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
    final payload = ref
        .watch(panelValueProvider(PanelStreamKey(
          connectionId: connectionId,
          topic: subscribeTopic,
          jsonPath: null,
        )))
        .valueOrNull;
    final state = DeviceState(profile, decodeDeviceState(payload));
    final ieee = panel.deviceIeee;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
                deviceClassIcon(profile.deviceClass, alarm: state.alarm),
                size: 32),
            title: Text(panel.name, style: theme.textTheme.titleLarge),
            subtitle: Text([
              deviceStateLine(state, l10n),
              ?config.model,
            ].join(' · ')),
          ),
          if (ieee != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                icon: const Icon(Icons.info_outline),
                label: Text(l10n.deviceDetails),
                onPressed: () {
                  Navigator.pop(context);
                  context.push(Routes.homeDevice(connectionId, ieee));
                },
              ),
            ),
          DeviceControls(
            connectionId: connectionId,
            publishTopic: publishTopic,
            profile: profile,
            state: state,
          ),
        ],
      ),
    );
  }
}

/// A device's controls and values, as in its tile's sheet: switches (one per
/// endpoint), brightness, white, colour, cover actions and position, the
/// writable exposes of a generic device, then readings and battery. With
/// [readings] false only the controls are drawn (the device page lists
/// values in its own card).
class DeviceControls extends ConsumerWidget {
  const DeviceControls({
    super.key,
    required this.connectionId,
    required this.publishTopic,
    required this.profile,
    required this.state,
    this.readings = true,
  });

  final String connectionId;
  final String publishTopic;
  final DeviceProfile profile;
  final DeviceState state;
  final bool readings;

  /// Whether [DeviceControls] draws anything besides readings for [profile].
  static bool hasControls(DeviceProfile profile) =>
      profile.switches.isNotEmpty ||
      profile.brightness != null ||
      profile.colorTemp != null ||
      profile.deviceClass == DeviceClass.cover ||
      genericControls(profile).isNotEmpty;

  /// A generic device's settable exposes that are not already switches.
  static List<DeviceFeature> genericControls(DeviceProfile profile) =>
      profile.deviceClass != DeviceClass.generic
          ? const []
          : [
              for (final f in profile.normal)
                if (f.settable &&
                    f.type != 'composite' &&
                    !profile.switches.contains(f) &&
                    (f.type == 'binary' ||
                        (f.type == 'numeric' && f.min != null && f.max != null) ||
                        (f.type == 'enum' && (f.values?.isNotEmpty ?? false))))
                  f,
            ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cls = profile.deviceClass;

    Future<void> send(Map<String, Object?> command) => sendDeviceCommand(
        context, ref, connectionId, publishTopic, command);

    final children = <Widget>[];

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

    for (final f in genericControls(profile)) {
      final v = state.values[f.property];
      final label = _humanize(f.property);
      switch (f.type) {
        case 'binary':
          children.add(SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(label),
            value: v != null && v == (f.valueOn ?? true),
            onChanged: (on) => send({
              f.property: on ? (f.valueOn ?? true) : (f.valueOff ?? false),
            }),
          ));
        case 'numeric':
          children.add(_Labeled(
            label: label,
            trailing: v is num ? formatReading(v, f.unit) : '—',
            child: CommitSlider(
              label: label,
              value: v is num ? v.toDouble() : null,
              min: f.min!.toDouble(),
              max: f.max!.toDouble(),
              format: (x) => formatReading(x.round(), f.unit),
              onChanged: (x) => send({f.property: x.round()}),
            ),
          ));
        case 'enum':
          final values = f.values!;
          children.add(_Labeled(
            label: label,
            child: values.length <= 4
                ? SegmentedButton<String>(
                    segments: [
                      for (final o in values)
                        ButtonSegment(value: o, label: Text(_humanize(o))),
                    ],
                    selected: {if (values.contains('$v')) '$v'},
                    emptySelectionAllowed: true,
                    showSelectedIcon: false,
                    onSelectionChanged: (sel) {
                      if (sel.isNotEmpty) send({f.property: sel.first});
                    },
                  )
                : DropdownMenu<String>(
                    initialSelection: values.contains('$v') ? '$v' : null,
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: [
                      for (final o in values)
                        DropdownMenuEntry(value: o, label: _humanize(o)),
                    ],
                    onSelected: (o) {
                      if (o != null) send({f.property: o});
                    },
                  ),
          ));
      }
    }

    if (!readings) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    for (final f in profile.readings) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
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

  static String _humanize(String property) => humanizeProperty(property);
}

/// `device_temperature` → "Device temperature".
String humanizeProperty(String property) {
  final s = property.replaceAll('_', ' ');
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
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
