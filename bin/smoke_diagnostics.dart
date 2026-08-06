// Real-broker smoke test for ConnectDiagnostics (the guided-connect ladder).
// Runs the full 5-step ladder against a real host with zero fakes — real DNS
// lookup, real TCP probe, real MQTT client — and prints each step. Bypasses
// Flutter entirely so it runs on the pure Dart VM. Example:
//
//   dart run bin/smoke_diagnostics.dart --host localhost --port 1883
//   dart run bin/smoke_diagnostics.dart --host 192.168.7.210 --base zigbee2mqtt
//   dart run bin/smoke_diagnostics.dart --host 192.168.7.210 --user mqtt --pass secret
//   dart run bin/smoke_diagnostics.dart --host localhost --v311  # 3.1.1-only brokers

import 'dart:io';

import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/client_factory.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart' show MqttClientFactory;

Future<void> main(List<String> args) async {
  final opts = _parse(args);

  final config = BrokerConfig(
    id: 'diag-smoke',
    host: opts['host']!,
    port: int.parse(opts['port']!),
    protocol: _protocolFromString(opts['protocol']!),
    username: opts['user'],
    keepAliveSeconds: 30,
  );

  // ZigDash's manager deliberately speaks MQTT 3.1 (SMLIGHT Mosquitto). Some
  // test brokers (e.g. aedes) are 3.1.1-only — force 3.1.1 for those.
  MqttClientFactory factory = buildMqttClient;
  if (opts['v311'] == 'true') {
    factory = (cfg, clientId, {host}) {
      final client = buildMqttClient(cfg, clientId, host: host);
      client.setProtocolV311();
      return client;
    };
  }

  stdout.writeln(
      'Running ladder against ${opts['host']}:${opts['port']} (base "${opts['base']}")${opts['v311'] == 'true' ? ' [v3.1.1]' : ''}…');
  final diag = ConnectDiagnostics(
    deviceWindow: const Duration(seconds: 5),
    clientFactory: factory,
  );
  final report = await diag.run(
    config: config,
    password: opts['pass'] ?? '',
    base: opts['base']!,
  );

  for (final step in report.steps) {
    final count = step.deviceCount != null ? ' (devices: ${step.deviceCount})' : '';
    stdout.writeln(
        '  ${step.step.name.padRight(8)} ${step.status.name.padRight(8)} ${step.detailKey ?? ''}$count');
  }
  stdout.writeln(
      'connected: ${report.connected}  candidates tried: ${report.candidatesTried}');
  if (report.deviceNames.isNotEmpty) {
    stdout.writeln('devices: ${report.deviceNames.join(', ')}');
  }
}

Map<String, String> _parse(List<String> args) {
  String? get(String key) {
    final i = args.indexOf('--$key');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  return {
    'host': get('host') ?? 'localhost',
    'port': get('port') ?? '1883',
    'base': get('base') ?? 'zigbee2mqtt',
    'protocol': get('protocol') ?? 'tcp',
    'user': get('user') ?? '',
    'pass': get('pass') ?? '',
    'v311': args.contains('--v311') ? 'true' : 'false',
  };
}

MqttProtocol _protocolFromString(String s) => switch (s) {
      'tcpSsl' => MqttProtocol.tcpSsl,
      'ws' => MqttProtocol.ws,
      'wss' => MqttProtocol.wss,
      _ => MqttProtocol.tcp,
    };
