import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/material_icon.dart';
import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'control_action.dart';
import '../../../core/theme/motion.dart';

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

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool currentlyOn) async {
    await runControlAction(context, ref, connectionId, (mgr) => mgr.publish(
      publishTopic,
      currentlyOn ? config.offPayload : config.onPayload,
      '',
      qos: mc.MqttQos.values[panel.qos.clamp(0, 2)],
      retain: panel.retain,
    ));
  }

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

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggle(context, ref, isOn),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                _icon(isOn),
                size: 28,
                color: isOn ? Theme.of(context).colorScheme.primary : null,
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
                      duration: SignalMotion.of(context, SignalMotion.stateChange),
                      child: Text(
                        valueAsync.when(
                          loading: () => '…',
                          error: (_, __) => context.l10n.panelToggleError,
                          data: (v) => v == null
                              ? context.l10n.panelToggleNoState
                              : (isOn ? context.l10n.panelStateOn : context.l10n.panelStateOff),
                        ),
                        key: ValueKey(isOn),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isOn,
                onChanged: (_) => _toggle(context, ref, isOn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(bool on) {
    final cp = on ? config.onIconCodepoint : config.offIconCodepoint;
    if (cp != null) return materialIcon(cp);
    return on ? Icons.power_settings_new : Icons.power_off;
  }
}
