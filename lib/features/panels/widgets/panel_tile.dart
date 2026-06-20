import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/database/tables/panels.dart';
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
import 'progress_panel.dart';
import 'radio_panel.dart';
import 'slider_panel.dart';
import 'text_input_panel.dart';
import 'scene_panel.dart';
import 'schedule_panel.dart';
import 'text_log_panel.dart';
import 'toggle_panel.dart';

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
                            label: Text(l10n.panelTileWidthFull)),
                        ButtonSegment(
                            value: PanelWidth.half,
                            label: Text(l10n.panelTileWidthHalf)),
                        ButtonSegment(
                            value: PanelWidth.third,
                            label: Text(l10n.panelTileWidthThird)),
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
                      .clearConfig(connectionId: connectionId, panelId: panel.id);
                } else if (panel.type == PanelType.autoClose) {
                  await ref
                      .read(autoCloseConfigPublisherProvider)
                      .clearConfig(connectionId: connectionId, panelId: panel.id);
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
    final subscribeTopic =
        composeTopic(effectivePrefix, panel.subscribeTopic ?? panel.topic);
    final config = PanelConfig.decode(panel.type, panel.config);

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
        ),
    };

    return Semantics(
      label: locked ? null : context.l10n.a11yPanelOptions,
      button: !locked,
      child: GestureDetector(
        onLongPress: locked ? null : () => _openOptions(context, ref),
        child: widget,
      ),
    );
  }
}
