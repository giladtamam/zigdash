import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'device_tile_panel.dart';

/// One numeric value with its unit, large, with the tile name below.
class ReadingPanel extends ConsumerWidget {
  const ReadingPanel({
    super.key,
    required this.connectionId,
    required this.subscribeTopic,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String subscribeTopic;
  final Panel panel;
  final ReadingConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final raw = ref
        .watch(panelValueProvider(PanelStreamKey(
          connectionId: connectionId,
          topic: subscribeTopic,
          jsonPath: config.jsonPath,
        )))
        .valueOrNull;
    final value = raw is num ? raw : num.tryParse('$raw');
    final text = value == null
        ? '—'
        : config.decimals == null
            ? formatReading(value, config.unit)
            : ltr('${value.toStringAsFixed(config.decimals!)}'
                '${config.unit == null ? '' : ' ${config.unit}'}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: theme.textTheme.headlineMedium),
            Text(
              panel.name,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
