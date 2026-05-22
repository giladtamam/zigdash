import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'control_action.dart';

class ComboPanel extends ConsumerWidget {
  const ComboPanel({
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

  Future<void> _publish(BuildContext context, WidgetRef ref, SelectOption opt) async {
    await runControlAction(context, ref, connectionId, (mgr) => mgr.publish(
      publishTopic,
      opt.payload,
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
    final current = valueAsync.maybeWhen(
      data: (v) => v?.toString(),
      orElse: () => null,
    );
    final value = config.options.any((o) => o.match == current) ? current : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(panel.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: value,
              hint: const Text('—'),
              underline: const SizedBox.shrink(),
              items: config.options
                  .map((o) => DropdownMenuItem<String>(
                        value: o.match,
                        child: Text(o.label),
                      ))
                  .toList(),
              onChanged: (sel) {
                if (sel == null) return;
                final opt = config.options.firstWhere((o) => o.match == sel);
                _publish(context, ref, opt);
              },
            ),
          ],
        ),
      ),
    );
  }
}
