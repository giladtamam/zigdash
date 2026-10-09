import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../core/utils/material_icon.dart';
import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import 'control_action.dart';

class ButtonPanel extends ConsumerWidget {
  const ButtonPanel({
    super.key,
    required this.connectionId,
    required this.publishTopic,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String publishTopic;
  final Panel panel;
  final ButtonConfig config;

  Future<void> _press(BuildContext context, WidgetRef ref) async {
    await runControlAction(context, ref, connectionId, (mgr) => mgr.publish(
      publishTopic,
      config.payload,
      '', // template carries the full payload, no {value} substitution
      qos: mc.MqttQos.values[panel.qos.clamp(0, 2)],
      retain: panel.retain,
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = config.colorArgb != null ? Color(config.colorArgb!) : null;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _press(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                config.iconCodepoint != null
                    ? materialIcon(config.iconCodepoint!)
                    : Icons.send,
                size: 28,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                panel.name,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
