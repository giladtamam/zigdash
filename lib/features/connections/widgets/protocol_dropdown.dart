import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
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
        MqttProtocol.tcp => 1883,      // MQTT standard
        MqttProtocol.tcpSsl => 8883,   // MQTT-over-TLS standard
        MqttProtocol.ws => 9001,       // Mosquitto WebSocket convention
        MqttProtocol.wss => 8884,      // Mosquitto WebSocket-over-TLS convention
      };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MqttProtocol>(
      value: value,
      decoration: InputDecoration(labelText: context.l10n.connProtocol),
      items: MqttProtocol.values
          .map((p) => DropdownMenuItem(value: p, child: Text(_labels[p]!)))
          .toList(),
      onChanged: (p) {
        if (p != null) onChanged(p);
      },
    );
  }
}
