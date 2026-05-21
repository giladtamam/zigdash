import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';

class NodeStatusPanel extends ConsumerWidget {
  const NodeStatusPanel({
    super.key,
    required this.connectionId,
    required this.subscribeTopic,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String subscribeTopic;
  final Panel panel;
  final NodeStatusConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: subscribeTopic,
      jsonPath: config.jsonPath,
    )));

    final scheme = Theme.of(context).colorScheme;
    final (icon, color, label) = valueAsync.when(
      loading: () => (Icons.help_outline, scheme.outline, 'unknown'),
      error: (_, __) => (Icons.error_outline, scheme.error, 'error'),
      data: (v) {
        if (v == null) return (Icons.help_outline, scheme.outline, 'unknown');
        final online = v.toString() == config.onlinePayload;
        return online
            ? (Icons.cloud_done, Colors.green.shade600, 'online')
            : (Icons.cloud_off, scheme.error, 'offline');
      },
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(panel.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
