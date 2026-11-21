import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/signal_icons.dart';
import '../../../core/utils/material_icon.dart';
import '../../../data/database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../mqtt/json_path.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'control_action.dart';
import 'signal_tile.dart';

/// What a custom toggle knows about its state (3.8.7,
/// own-switch-look-387.md §4).
enum ToggleStateKind {
  on,
  off,

  /// A value that is neither on nor off (`TOGGLE`, `50`).
  raw,

  /// A message arrived with nothing at the tile's path.
  noValue,

  /// No message since the tile subscribed.
  waiting,
}

class ToggleState {
  const ToggleState(this.kind, [this.text]);

  final ToggleStateKind kind;

  /// The raw value's text for [ToggleStateKind.raw], already "—" for JSON.
  final String? text;

  bool get isOn => kind == ToggleStateKind.on;
}

/// A custom toggle's state from its latest [snapshot] (null: no message
/// yet). Values are compared as strings on both sides: `extractByPath`
/// can give a bool or a number (`{"state":true}`, `{"power":0}`).
ToggleState toggleState(ToggleConfig config, PanelValueSnapshot? snapshot) {
  if (snapshot == null) return const ToggleState(ToggleStateKind.waiting);
  final value = snapshot.value;
  if (value == null) return const ToggleState(ToggleStateKind.noValue);
  final text = value.toString();
  if (text == config.onMatch) return const ToggleState(ToggleStateKind.on);
  final path = config.jsonPath;
  final offValue = path == null
      ? config.offPayload
      : extractByPath(config.offPayload, path)?.toString();
  if (text == offValue || text == config.offPayload) {
    return const ToggleState(ToggleStateKind.off);
  }
  // Never a wall of JSON on a tile.
  final trimmed = text.trim();
  final json =
      value is Map ||
      value is List ||
      (path == null && (trimmed.startsWith('{') || trimmed.startsWith('[')));
  return ToggleState(ToggleStateKind.raw, json ? '—' : text);
}

/// The line under a custom toggle's name, in the device tiles' words.
String toggleStateLine(ToggleState state, AppLocalizations l10n) =>
    switch (state.kind) {
      ToggleStateKind.on => l10n.deviceOn,
      ToggleStateKind.off => l10n.deviceOff,
      ToggleStateKind.raw => state.text ?? '—',
      ToggleStateKind.noValue => '—',
      ToggleStateKind.waiting => l10n.deviceWaiting,
    };

/// A custom MQTT toggle, drawn as a device tile is (3.8.7): the chip, the
/// name, the state line, amber when on. A tap anywhere on the tile sends
/// the off payload when on, else the on payload.
class TogglePanel extends ConsumerWidget {
  const TogglePanel({
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
  final ToggleConfig config;

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    bool currentlyOn,
  ) async {
    await runControlAction(
      context,
      ref,
      connectionId,
      (mgr) => mgr.publish(
        publishTopic,
        currentlyOn ? config.offPayload : config.onPayload,
        '',
        qos: mc.MqttQos.values[panel.qos.clamp(0, 2)],
        retain: panel.retain,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // The same key PanelTile watches for the stale frame: no extra
    // subscription. A snapshot (not just the value) tells "no message yet"
    // from "a message without the value".
    final snapshot = ref.watch(
      panelValueSnapshotProvider(
        PanelStreamKey(
          connectionId: connectionId,
          topic: subscribeTopic,
          jsonPath: config.jsonPath,
        ),
      ),
    );
    final state = snapshot.hasError
        ? const ToggleState(ToggleStateKind.noValue)
        : toggleState(config, snapshot.valueOrNull);
    final isOn = state.isOn;
    final line = toggleStateLine(state, l10n);
    final (:fg, :fgVariant) = signalTileForeground(context, on: isOn);
    void tap() => _toggle(context, ref, isOn);

    // One node for the tile, read like a switch (§3).
    return Semantics(
      button: true,
      toggled: isOn,
      label: panel.name,
      value: line,
      onTap: tap,
      onTapHint: l10n.deviceToggle,
      excludeSemantics: true,
      child: SignalTileCard(
        on: isOn,
        onTap: tap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                QuickActionChip(icon: _icon(isOn), on: isOn),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              panel.name,
              style: theme.textTheme.titleMedium?.copyWith(color: fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              line,
              style: theme.textTheme.bodyMedium?.copyWith(color: fgVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Both stored icons: by state. One: that one in both states (the chip's
  /// fill shows the state). None: the switch/plug class icon.
  IconData _icon(bool on) {
    final onCp = config.onIconCodepoint;
    final offCp = config.offIconCodepoint;
    if (onCp != null && offCp != null) return materialIcon(on ? onCp : offCp);
    final one = onCp ?? offCp;
    if (one != null) return materialIcon(one);
    return Symbols.powerSettingsNew;
  }
}
