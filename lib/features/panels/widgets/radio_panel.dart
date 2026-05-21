import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../data/database/database.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';

class RadioPanel extends ConsumerWidget {
  const RadioPanel({
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(panel.name,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            for (final o in config.options)
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(o.label),
                value: o.match,
                groupValue: current,
                onChanged: (_) => _publish(ref, o),
              ),
          ],
        ),
      ),
    );
  }
}
