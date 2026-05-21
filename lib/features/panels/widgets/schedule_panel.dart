import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import '../services/automation_config_publisher.dart';

/// Dashboard tile for a server-side daily schedule. Shows the open/close
/// times and an enable switch; reflects the Node-RED flow's reported
/// next-action and warns when the scheduler is offline. The actual clock
/// lives in Node-RED — this widget only writes config + reads status.
class SchedulePanel extends ConsumerWidget {
  const SchedulePanel({
    super.key,
    required this.connectionId,
    required this.target,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String target; // composed shutter command topic (publish topic)
  final Panel panel;
  final ScheduleConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final nextActionAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: AutomationConfigPublisher.stateTopic(panel.id),
      jsonPath: 'nextAction',
    )));
    final nextAtAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: AutomationConfigPublisher.stateTopic(panel.id),
      jsonPath: 'nextAt',
    )));
    final bridgeAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: AutomationConfigPublisher.bridgeStateTopic,
      jsonPath: null,
    )));

    final offline = bridgeAsync.maybeWhen(
      data: (v) => v?.toString() != 'online',
      orElse: () => true,
    );
    final nextAction = nextActionAsync.asData?.value?.toString();
    final nextAt = nextAtAsync.asData?.value?.toString();

    Future<void> toggleEnabled(bool v) async {
      final next = config.copyWith(enabled: v);
      await ref.read(panelRepoProvider).update(
            id: panel.id,
            name: panel.name,
            topic: panel.topic,
            subscribeTopic: panel.subscribeTopic,
            topicPrefixOverride: panel.topicPrefixOverride,
            qos: panel.qos,
            retain: panel.retain,
            width: panel.width,
            config: next,
          );
      final ok =
          await ref.read(automationConfigPublisherProvider).publishConfig(
                connectionId: connectionId,
                panelId: panel.id,
                name: panel.name,
                target: target,
                config: next,
              );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Not connected — saved; will sync when online.'),
        ));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(Icons.schedule, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(panel.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Switch(value: config.enabled, onChanged: toggleEnabled),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.wb_sunny_outlined, size: 18),
              const SizedBox(width: 6),
              Text('Opens ${config.openTime}'),
              const SizedBox(width: 16),
              const Icon(Icons.nightlight_outlined, size: 18),
              const SizedBox(width: 6),
              Text('Closes ${config.closeTime}'),
            ]),
            const SizedBox(height: 8),
            if (offline)
              Row(children: [
                Icon(Icons.cloud_off, size: 16, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text("Scheduler offline — won't run",
                      style: TextStyle(color: scheme.error, fontSize: 12)),
                ),
              ])
            else if (config.enabled && nextAction != null && nextAt != null)
              Text('Next: $nextAction at $nextAt',
                  style: TextStyle(color: scheme.outline, fontSize: 12))
            else if (!config.enabled)
              Text('Disabled',
                  style: TextStyle(color: scheme.outline, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
