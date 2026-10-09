import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'control_action.dart';

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
            RadioGroup<String>(
              groupValue: current,
              onChanged: (match) {
                for (final o in config.options) {
                  if (o.match == match) {
                    _publish(context, ref, o);
                    return;
                  }
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final o in config.options)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(o.label),
                      value: o.match,
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
