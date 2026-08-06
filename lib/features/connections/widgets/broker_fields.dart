import 'package:flutter/material.dart';

import '../../../data/database/tables/connections.dart';
import '../discovery/broker_probe.dart';
import 'protocol_dropdown.dart';

/// Shared broker-form field helpers, used by both the guided-connect wizard
/// and the manual connection form.

/// When the protocol changes and the port still holds the previous protocol's
/// default, swap it to the new protocol's default.
void applyProtocolPortDefault(
  TextEditingController port,
  MqttProtocol from,
  MqttProtocol to,
) {
  if (port.text == ProtocolDropdown.defaultPort(from).toString()) {
    port.text = ProtocolDropdown.defaultPort(to).toString();
  }
}

/// Fills the host/port/protocol fields from a [BrokerScanSheet] result.
void applyScanResult({
  required TextEditingController host,
  required TextEditingController port,
  required ValueChanged<MqttProtocol> onProtocol,
  required ProbeResult result,
}) {
  host.text = result.host;
  port.text = result.port.toString();
  onProtocol(result.port == 8883 ? MqttProtocol.tcpSsl : MqttProtocol.tcp);
}
