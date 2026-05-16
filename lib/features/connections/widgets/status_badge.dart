import 'package:flutter/material.dart';

import '../../../mqtt/mqtt_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final MqttStatus status;

  static const _colors = {
    MqttStatus.disconnected: Colors.grey,
    MqttStatus.connecting: Colors.amber,
    MqttStatus.connected: Colors.green,
    MqttStatus.reconnecting: Colors.amber,
    MqttStatus.error: Colors.red,
  };

  static const _labels = {
    MqttStatus.disconnected: 'Disconnected',
    MqttStatus.connecting: 'Connecting',
    MqttStatus.connected: 'Connected',
    MqttStatus.reconnecting: 'Reconnecting',
    MqttStatus.error: 'Error',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: _colors[status], shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(_labels[status]!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
