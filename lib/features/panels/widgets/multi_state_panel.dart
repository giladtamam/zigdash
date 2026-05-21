import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';

class MultiStatePanel extends ConsumerWidget {
  const MultiStatePanel({
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
  final OptionsConfig config;

  Future<void> _publish(WidgetRef ref, SelectOption opt) async {
    final mgr = await ref.read(mqttManagerProvider(connectionId).future);
    mgr.publish(
      publishTopic,
      opt.payload,
      '',
      qos: mc.MqttQos.values[panel.qos.clamp(0, 2)],
      retain: panel.retain,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: subscribeTopic,
      jsonPath: config.jsonPath,
    )));
    final current = valueAsync.maybeWhen(
      data: (v) => v?.toString(),
      orElse: () => null,
    );
    final selected = <String>{
      for (final o in config.options)
        if (o.match == current) o.match,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(panel.name,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            if (config.options.isEmpty)
              Text(context.l10n.panelMultiStateNoOptions,
                  style: Theme.of(context).textTheme.bodySmall)
            else
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: config.options
                      .map((o) => ButtonSegment<String>(
                            value: o.match,
                            label: Text(o.label,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  selected: selected,
                  onSelectionChanged: (sel) {
                    if (sel.isEmpty) return;
                    final opt = config.options
                        .firstWhere((o) => o.match == sel.first);
                    _publish(ref, opt);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
