import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/database/tables/panels.dart';
import '../../../mqtt/mqtt_status.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../../../mqtt/json_path.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import '../services/auto_close_config_publisher.dart';
import '../services/automation_config_publisher.dart';
import 'auto_close_panel.dart';
import 'button_panel.dart';
import 'combo_panel.dart';
import 'cover_panel.dart';
import 'led_panel.dart';
import 'multi_state_panel.dart';
import 'node_status_panel.dart';
import 'panel_reliability_frame.dart';
import 'progress_panel.dart';
import 'radio_panel.dart';
import 'slider_panel.dart';
import 'text_input_panel.dart';
import 'scene_panel.dart';
import 'schedule_panel.dart';
import 'text_log_panel.dart';
import 'toggle_panel.dart';

enum PanelSubscriptionMode { none, readOnly, interactive }

enum PanelControlGate { always, connected, autoClose }

enum PanelJsonPathSource { none, config }

@immutable
class PanelReliabilityPolicy {
  const PanelReliabilityPolicy._({
    required this.subscriptionMode,
    required this.controlGate,
    required this.jsonPathSource,
  });

  const PanelReliabilityPolicy.publishOnly()
    : this._(
        subscriptionMode: PanelSubscriptionMode.none,
        controlGate: PanelControlGate.connected,
        jsonPathSource: PanelJsonPathSource.none,
      );

  const PanelReliabilityPolicy.interactiveSubscription({
    this.jsonPathSource = PanelJsonPathSource.config,
  }) : subscriptionMode = PanelSubscriptionMode.interactive,
       controlGate = PanelControlGate.connected;

  const PanelReliabilityPolicy.readOnlySubscription()
    : this._(
        subscriptionMode: PanelSubscriptionMode.readOnly,
        controlGate: PanelControlGate.always,
        jsonPathSource: PanelJsonPathSource.config,
      );

  const PanelReliabilityPolicy.autoClose()
    : this._(
        subscriptionMode: PanelSubscriptionMode.none,
        controlGate: PanelControlGate.autoClose,
        jsonPathSource: PanelJsonPathSource.none,
      );

  final PanelSubscriptionMode subscriptionMode;
  final PanelControlGate controlGate;
  final PanelJsonPathSource jsonPathSource;

  bool get subscribes => subscriptionMode != PanelSubscriptionMode.none;

  String? jsonPath(PanelConfig config) {
    if (jsonPathSource == PanelJsonPathSource.none) return null;
    return switch (config) {
      ToggleConfig config => config.jsonPath,
      SliderConfig config => config.jsonPath,
      LedConfig config => config.jsonPath,
      NodeStatusConfig config => config.jsonPath,
      ProgressConfig config => config.jsonPath,
      OptionsConfig config => config.jsonPath,
      TextLogConfig config => config.jsonPath,
      _ => null,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is PanelReliabilityPolicy &&
      other.subscriptionMode == subscriptionMode &&
      other.controlGate == controlGate &&
      other.jsonPathSource == jsonPathSource;

  @override
  int get hashCode =>
      Object.hash(subscriptionMode, controlGate, jsonPathSource);
}

PanelReliabilityPolicy panelReliabilityPolicy(PanelType type) => switch (type) {
  PanelType.button ||
  PanelType.textInput ||
  PanelType.schedule ||
  PanelType.scene => const PanelReliabilityPolicy.publishOnly(),
  PanelType.toggle ||
  PanelType.slider ||
  PanelType.multiState ||
  PanelType.combo ||
  PanelType.radio => const PanelReliabilityPolicy.interactiveSubscription(),
  PanelType.cover => const PanelReliabilityPolicy.interactiveSubscription(
    jsonPathSource: PanelJsonPathSource.none,
  ),
  PanelType.led ||
  PanelType.nodeStatus ||
  PanelType.progress ||
  PanelType.textLog => const PanelReliabilityPolicy.readOnlySubscription(),
  PanelType.autoClose => const PanelReliabilityPolicy.autoClose(),
};

String? panelReliabilityValueLabel(PanelConfig config, Object? value) {
  if (value == null) return null;
  return switch (config) {
    CoverConfig config => _coverReliabilityValueLabel(config, value),
    TextLogConfig() => _textLogReliabilityValueLabel(value),
    _ => value.toString(),
  };
}

String? _textLogReliabilityValueLabel(Object value) {
  if (value is Map || value is List) return null;
  final text = value.toString();
  try {
    final decoded = json.decode(text);
    if (decoded is Map || decoded is List) return null;
  } catch (_) {
    // Plain text is already the meaningful display label.
  }
  return text;
}

String? _coverReliabilityValueLabel(CoverConfig config, Object value) {
  final raw = value.toString();
  final state = extractByPath(raw, config.statePath)?.toString();
  final positionValue = extractByPath(raw, config.positionPath);
  final position = positionValue is num
      ? positionValue.round()
      : int.tryParse(positionValue?.toString() ?? '');
  final parts = [
    if (state != null && state.isNotEmpty) state,
    if (position != null) '$position%',
  ];
  return parts.isEmpty ? null : parts.join(', ');
}

/// Dispatcher that picks the right concrete panel widget based on
/// [Panel.type], decoded config, and the effective publish/subscribe topics
/// derived from the parent dashboard's prefix.
class PanelTile extends ConsumerWidget {
  const PanelTile({
    super.key,
    required this.connectionId,
    required this.dashboardId,
    required this.topicPrefix,
    required this.panel,
    required this.locked,
  });

  final String connectionId;
  final String dashboardId;
  final String? topicPrefix;
  final Panel panel;
  final bool locked;

  void _openOptions(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repo = ref.read(panelRepoProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.panelTileEdit),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push(
                  '/connections/$connectionId/dashboards/$dashboardId/panels/${panel.id}/edit',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: Text(l10n.panelTileDuplicate),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await repo.duplicate(panel.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: Text(l10n.panelTileMoveUp),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await repo.move(dashboardId, panel.id, -1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: Text(l10n.panelTileMoveDown),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await repo.move(dashboardId, panel.id, 1);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Text(l10n.panelTileWidth),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SegmentedButton<PanelWidth>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: PanelWidth.full,
                          label: Text(l10n.panelTileWidthFull),
                        ),
                        ButtonSegment(
                          value: PanelWidth.half,
                          label: Text(l10n.panelTileWidthHalf),
                        ),
                        ButtonSegment(
                          value: PanelWidth.third,
                          label: Text(l10n.panelTileWidthThird),
                        ),
                      ],
                      selected: {panel.width},
                      onSelectionChanged: (sel) async {
                        Navigator.pop(sheetCtx);
                        await repo.setWidth(panel.id, sel.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.panelTileDelete),
              onTap: () async {
                Navigator.pop(sheetCtx);
                if (panel.type == PanelType.schedule) {
                  await ref
                      .read(automationConfigPublisherProvider)
                      .clearConfig(
                        connectionId: connectionId,
                        panelId: panel.id,
                      );
                } else if (panel.type == PanelType.autoClose) {
                  await ref
                      .read(autoCloseConfigPublisherProvider)
                      .clearConfig(
                        connectionId: connectionId,
                        panelId: panel.id,
                      );
                }
                await repo.delete(panel.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectivePrefix = panel.topicPrefixOverride ?? topicPrefix;
    final publishTopic = composeTopic(effectivePrefix, panel.topic);
    final subscribeTopic = composeTopic(
      effectivePrefix,
      panel.subscribeTopic ?? panel.topic,
    );
    final config = PanelConfig.decode(panel.type, panel.config);
    final reliability = panelReliabilityPolicy(panel.type);
    final connectionStatus = ref
        .watch(connectionStatusProvider(connectionId))
        .valueOrNull;
    final snapshot = reliability.subscribes
        ? ref
              .watch(
                panelValueSnapshotProvider(
                  PanelStreamKey(
                    connectionId: connectionId,
                    topic: subscribeTopic,
                    jsonPath: reliability.jsonPath(config),
                  ),
                ),
              )
              .valueOrNull
        : null;
    final stale = snapshot?.freshness == PanelFreshness.stale;
    final controlsEnabled = switch (reliability.controlGate) {
      PanelControlGate.connected => connectionStatus == MqttStatus.connected,
      PanelControlGate.always || PanelControlGate.autoClose => true,
    };

    final widget = switch (panel.type) {
      PanelType.button => ButtonPanel(
        connectionId: connectionId,
        publishTopic: publishTopic,
        panel: panel,
        config: config as ButtonConfig,
      ),
      PanelType.toggle => TogglePanel(
        connectionId: connectionId,
        publishTopic: publishTopic,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as ToggleConfig,
      ),
      PanelType.slider => SliderPanel(
        connectionId: connectionId,
        publishTopic: publishTopic,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as SliderConfig,
      ),
      PanelType.led => LedPanel(
        connectionId: connectionId,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as LedConfig,
      ),
      PanelType.nodeStatus => NodeStatusPanel(
        connectionId: connectionId,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as NodeStatusConfig,
      ),
      PanelType.progress => ProgressPanel(
        connectionId: connectionId,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as ProgressConfig,
      ),
      PanelType.multiState => MultiStatePanel(
        connectionId: connectionId,
        publishTopic: publishTopic,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as OptionsConfig,
      ),
      PanelType.combo => ComboPanel(
        connectionId: connectionId,
        publishTopic: publishTopic,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as OptionsConfig,
      ),
      PanelType.radio => RadioPanel(
        connectionId: connectionId,
        publishTopic: publishTopic,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as OptionsConfig,
      ),
      PanelType.cover => CoverPanel(
        connectionId: connectionId,
        publishTopic: publishTopic,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as CoverConfig,
      ),
      PanelType.textInput => TextInputPanel(
        connectionId: connectionId,
        publishTopic: publishTopic,
        panel: panel,
        config: config as TextInputConfig,
      ),
      PanelType.textLog => TextLogPanel(
        connectionId: connectionId,
        subscribeTopic: subscribeTopic,
        panel: panel,
        config: config as TextLogConfig,
      ),
      PanelType.schedule => SchedulePanel(
        connectionId: connectionId,
        target: publishTopic,
        panel: panel,
        config: config as ScheduleConfig,
      ),
      PanelType.scene => ScenePanel(
        connectionId: connectionId,
        panel: panel,
        config: config as SceneConfig,
      ),
      PanelType.autoClose => AutoClosePanel(
        connectionId: connectionId,
        triggerTopic: subscribeTopic,
        target: publishTopic,
        panel: panel,
        config: config as AutoCloseConfig,
        brokerPublishEnabled:
            reliability.controlGate == PanelControlGate.autoClose &&
            connectionStatus == MqttStatus.connected,
      ),
    };

    // "Panel options" is the long-press hint, not the tile's label: labelling
    // the wrapper as a "Panel options" button hid the name and state of
    // read-only tiles (LED, node status, progress, text log) from TalkBack.
    // Read-only tiles merge into one node (name, state, long-press); tiles
    // with controls keep each control as its own node.
    final tile = Semantics(
      onLongPressHint: locked ? null : context.l10n.a11yPanelOptions,
      child: GestureDetector(
        onLongPress: locked ? null : () => _openOptions(context, ref),
        child: PanelReliabilityFrame(
          stale: stale,
          controlsEnabled: controlsEnabled,
          valueLabel: panelReliabilityValueLabel(config, snapshot?.value),
          child: widget,
        ),
      ),
    );
    return reliability.subscriptionMode == PanelSubscriptionMode.readOnly
        ? MergeSemantics(child: tile)
        : Semantics(container: true, child: tile);
  }
}
