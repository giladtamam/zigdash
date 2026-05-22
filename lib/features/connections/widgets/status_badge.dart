import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../mqtt/endpoint.dart';
import '../../../mqtt/mqtt_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.endpoint});
  final MqttStatus status;
  final MqttEndpoint? endpoint;

  static const _colors = {
    MqttStatus.disconnected: Colors.grey,
    MqttStatus.connecting: Colors.amber,
    MqttStatus.connected: Colors.green,
    MqttStatus.reconnecting: Colors.amber,
    MqttStatus.error: Colors.red,
  };

  String _label(BuildContext context) {
    final l10n = context.l10n;
    switch (status) {
      case MqttStatus.disconnected:
        return l10n.statusDisconnected;
      case MqttStatus.connecting:
        return l10n.statusConnecting;
      case MqttStatus.connected:
        return endpoint == MqttEndpoint.remote
            ? l10n.statusConnectedRemote
            : l10n.statusConnected;
      case MqttStatus.reconnecting:
        return l10n.statusReconnecting;
      case MqttStatus.error:
        return l10n.statusError;
    }
  }

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
        Text(_label(context), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
