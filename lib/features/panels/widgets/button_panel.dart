import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../data/database/database.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';

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

  Future<void> _press(WidgetRef ref) async {
    final mgr = await ref.read(mqttManagerProvider(connectionId).future);
    mgr.publish(
      publishTopic,
      config.payload,
      '', // template carries the full payload, no {value} substitution
      qos: mc.MqttQos.values[panel.qos.clamp(0, 2)],
      retain: panel.retain,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = config.colorArgb != null ? Color(config.colorArgb!) : null;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _press(ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                config.iconCodepoint != null
                    ? IconData(config.iconCodepoint!, fontFamily: 'MaterialIcons')
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
