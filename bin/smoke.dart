// Real-broker smoke test for MqttManager.
// Connects to a broker, subscribes to a wildcard pattern, prints any messages
// received for [seconds] seconds, optionally publishes a test message, then
// disconnects cleanly. Bypasses Drift, Riverpod, and Flutter entirely so it can
// run on the pure Dart VM. Example:
//
//   dart run bin/smoke.dart --host 192.168.7.210 --port 1883
//   dart run bin/smoke.dart --host 192.168.7.210 --sub 'zigbee2mqtt/#' --seconds 8
//   dart run bin/smoke.dart --host 192.168.7.210 --pub-topic 'zigdash/ping' --pub-payload 'pong'

import 'dart:async';
import 'dart:io';

import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';

void main(List<String> args) async {
  final opts = _parse(args);

  final config = BrokerConfig(
    id: 'smoke',
    host: opts['host']!,
    port: int.parse(opts['port']!),
    protocol: _protocolFromString(opts['protocol']!),
    username: opts['user'],
    keepAliveSeconds: 30,
  );

  final mgr = MqttManager(config: config, password: opts['pass'] ?? '');

  final statusSub = mgr.status$.listen((s) {
    stderr.writeln('[status] ${s.name}');
  });

  final connected = mgr.status$.firstWhere(
    (s) => s == MqttStatus.connected || s == MqttStatus.error,
  );
  unawaited(mgr.connect());
  final result = await connected.timeout(const Duration(seconds: 10),
      onTimeout: () => MqttStatus.error);

  if (result != MqttStatus.connected) {
    stderr.writeln('[smoke] failed to connect; exiting');
    await mgr.dispose();
    await statusSub.cancel();
    exit(1);
  }

  final pattern = opts['sub']!;
  stderr.writeln('[smoke] subscribing to "$pattern"');
  final msgSub = mgr.subscribe(pattern).listen((msg) {
    stdout.writeln('${msg.topic}\t${_truncate(msg.payload, 120)}');
  });

  if (opts['pub-topic'] != null) {
    final topic = opts['pub-topic']!;
    final payload = opts['pub-payload'] ?? 'hello-from-zigdash-smoke';
    await Future<void>.delayed(const Duration(milliseconds: 250));
    stderr.writeln('[smoke] publishing to "$topic": $payload');
    mgr.publish(topic, '{value}', payload);
  }

  final seconds = int.parse(opts['seconds']!);
  stderr.writeln('[smoke] listening for ${seconds}s...');
  await Future<void>.delayed(Duration(seconds: seconds));

  stderr.writeln('[smoke] disconnecting');
  await msgSub.cancel();
  await mgr.dispose();
  await statusSub.cancel();
  stderr.writeln('[smoke] done');
}

Map<String, String?> _parse(List<String> args) {
  final defaults = <String, String?>{
    'host': null,
    'port': '1883',
    'protocol': 'tcp',
    'user': null,
    'pass': null,
    'sub': 'zigbee2mqtt/#',
    'pub-topic': null,
    'pub-payload': null,
    'seconds': '10',
  };
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('--')) continue;
    final key = a.substring(2);
    if (!defaults.containsKey(key)) {
      stderr.writeln('unknown flag: $a');
      exit(2);
    }
    if (i + 1 >= args.length) {
      stderr.writeln('flag $a needs a value');
      exit(2);
    }
    defaults[key] = args[++i];
  }
  if (defaults['host'] == null) {
    stderr.writeln('usage: dart run bin/smoke.dart --host <broker> [--port 1883] [--sub zigbee2mqtt/#] [--pub-topic t --pub-payload p] [--seconds 10]');
    exit(2);
  }
  return defaults;
}

MqttProtocol _protocolFromString(String s) {
  return MqttProtocol.values.firstWhere((p) => p.name == s,
      orElse: () => throw ArgumentError('unknown protocol: $s'));
}

String _truncate(String s, int n) => s.length <= n ? s : '${s.substring(0, n)}...';
