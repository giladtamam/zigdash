import 'package:flutter/material.dart';

import '../../../data/database/tables/connections.dart';

class ProtocolDropdown extends StatelessWidget {
  const ProtocolDropdown({super.key, required this.value, required this.onChanged});

  final MqttProtocol value;
  final ValueChanged<MqttProtocol> onChanged;

  static const _labels = {
    MqttProtocol.tcp: 'TCP',
    MqttProtocol.tcpSsl: 'TCP + SSL/TLS',
    MqttProtocol.ws: 'WebSocket',
    MqttProtocol.wss: 'WebSocket + SSL/TLS',
  };

  static int defaultPort(MqttProtocol p) => switch (p) {
        MqttProtocol.tcp => 1883,
        MqttProtocol.tcpSsl => 8883,
        MqttProtocol.ws => 8000,
        MqttProtocol.wss => 8084,
      };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MqttProtocol>(
      value: value,
      decoration: const InputDecoration(labelText: 'Protocol'),
      items: MqttProtocol.values
          .map((p) => DropdownMenuItem(value: p, child: Text(_labels[p]!)))
          .toList(),
      onChanged: (p) {
        if (p != null) onChanged(p);
      },
    );
  }
}
