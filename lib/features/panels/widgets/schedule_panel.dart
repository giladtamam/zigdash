import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../mqtt/json_path.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import '../services/automation_config_publisher.dart';

/// Dashboard tile for a server-side daily schedule. Shows the open/close
/// times and an enable switch; reflects the Node-RED flow's reported
/// next-action and warns when the scheduler is offline. The actual clock
/// lives in Node-RED — this widget only writes config + reads status.
class SchedulePanel extends ConsumerStatefulWidget {
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
  ConsumerState<SchedulePanel> createState() => _SchedulePanelState();
}

class _SchedulePanelState extends ConsumerState<SchedulePanel> {
  bool _busy = false;

  Future<void> _toggleEnabled(bool v) async {
    if (_busy) return;
    setState(() => _busy = true);
    final panel = widget.panel;
    final next = widget.config.copyWith(enabled: v);
    try {
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
                connectionId: widget.connectionId,
                panelId: panel.id,
                name: panel.name,
                target: widget.target,
                config: next,
              );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Not connected — saved; will sync when online.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final panel = widget.panel;
    final config = widget.config;

    // One subscription to the state topic; pull both fields from the payload.
    final stateAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: AutomationConfigPublisher.stateTopic(panel.id),
      jsonPath: null,
    )));
    final bridgeAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: AutomationConfigPublisher.bridgeStateTopic,
      jsonPath: null,
    )));

    String? nextAction;
    String? nextAt;
    stateAsync.whenData((raw) {
      if (raw == null) return;
      nextAction = extractByPath(raw.toString(), 'nextAction')?.toString();
      nextAt = extractByPath(raw.toString(), 'nextAt')?.toString();
    });

    final offline = bridgeAsync.maybeWhen(
      data: (v) => v?.toString() != 'online',
      orElse: () => true,
    );

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
              Switch(
                value: config.enabled,
                onChanged: _busy ? null : _toggleEnabled,
              ),
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
