import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/database/tables/panels.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'button_panel.dart';
import 'slider_panel.dart';
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
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit panel'),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push(
                  '/connections/$connectionId/dashboards/$dashboardId/panels/${panel.id}/edit',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete panel'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await ref.read(panelRepoProvider).delete(panel.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishTopic = composeTopic(topicPrefix, panel.topic);
    final subscribeTopic =
        composeTopic(topicPrefix, panel.subscribeTopic ?? panel.topic);
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
    };

    return GestureDetector(
      onLongPress: locked ? null : () => _openOptions(context, ref),
      child: widget,
    );
  }
}
