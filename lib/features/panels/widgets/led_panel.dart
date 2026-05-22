import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';

class LedPanel extends ConsumerWidget {
  const LedPanel({
    super.key,
    required this.connectionId,
    required this.subscribeTopic,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String subscribeTopic;
  final Panel panel;
  final LedConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: subscribeTopic,
      jsonPath: config.jsonPath,
    )));

    final isOn = valueAsync.maybeWhen(
      data: (v) => v?.toString() == config.onMatch,
      orElse: () => false,
    );
    final hasValue = valueAsync.maybeWhen(
      data: (v) => v != null,
      orElse: () => false,
    );

    final scheme = Theme.of(context).colorScheme;
    final onColor = config.onColorArgb != null
        ? Color(config.onColorArgb!)
        : scheme.primary;
    final offColor = config.offColorArgb != null
        ? Color(config.offColorArgb!)
        : scheme.outlineVariant;
    final dotColor = !hasValue
        ? scheme.outline.withValues(alpha: 0.4)
        : (isOn ? onColor : offColor);

    final stateLabel = !hasValue
        ? '…'
        : (isOn
            ? (config.onLabel ?? context.l10n.panelStateOn)
            : (config.offLabel ?? context.l10n.panelStateOff));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(isOn),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: isOn && hasValue
                      ? [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      stateLabel,
                      key: ValueKey(stateLabel),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
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
