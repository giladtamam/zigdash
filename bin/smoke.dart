// Real-broker smoke test for MqttManager.
// Connects to a broker, subscribes to a wildcard pattern, prints any messages
// received for [seconds] seconds, optionally publishes a test message, then
// disconnects cleanly. Bypasses Drift, Riverpod, and Flutter entirely so it can
// run on the pure Dart VM. Example:
//
//   dart run bin/smoke.dart --host 192.168.7.210 --port 1883
//   dart run bin/smoke.dart --host 192.168.7.210 --sub 'zigbee2mqtt/#' --seconds 8
//   dart run bin/smoke.dart --host 192.168.7.210 --pub-topic 'zigdash/ping' --pub-payload 'pong'
//   dart run bin/smoke.dart --host 192.168.7.210 --outage-checklist true

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
  final result = await connected.timeout(
    const Duration(seconds: 10),
    onTimeout: () => MqttStatus.error,
  );

  if (result != MqttStatus.connected) {
    stderr.writeln('[smoke] failed to connect; exiting');
    await mgr.dispose();
    await statusSub.cancel();
    exit(1);
  }

  final pattern = opts['sub']!;
  final outageChecklist = opts['outage-checklist'] == 'true';
  stderr.writeln('[smoke] subscribing to "$pattern"');
  var deliveryCount = 0;
  final msgSub = mgr.subscribe(pattern).listen((msg) {
    final payload = _truncate(msg.payload, 120);
    if (outageChecklist) {
      deliveryCount++;
      stdout.writeln(
        formatSmokeDelivery(msg.topic, payload, deliveryNumber: deliveryCount),
      );
    } else {
      stdout.writeln(formatSmokeDelivery(msg.topic, payload));
    }
  });

  if (opts['pub-topic'] != null) {
    final topic = opts['pub-topic']!;
    final payload = opts['pub-payload'] ?? 'hello-from-zigdash-smoke';
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final retain = opts['retain'] == 'true';
    stderr.writeln('[smoke] publishing to "$topic" (retain=$retain): $payload');
    mgr.publish(topic, '{value}', payload, retain: retain);
  }

  var checklistCompleted = true;
  if (outageChecklist) {
    checklistCompleted = _runOutageChecklist(opts, () => deliveryCount);
  } else {
    final seconds = int.parse(opts['seconds']!);
    stderr.writeln('[smoke] listening for ${seconds}s...');
    await Future<void>.delayed(Duration(seconds: seconds));
  }

  stderr.writeln('[smoke] disconnecting');
  await msgSub.cancel();
  await mgr.dispose();
  await statusSub.cancel();
  if (!checklistCompleted) {
    stderr.writeln('[smoke] outage checklist aborted');
    exitCode = 1;
    return;
  }
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
    'retain': 'false',
    'seconds': '10',
    'outage-checklist': 'false',
  };
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--help' || a == '-h') {
      _printUsage();
      exit(0);
    }
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
    _printUsage();
    exit(2);
  }
  return defaults;
}

void _printUsage() {
  stderr.writeln(
    'usage: dart run bin/smoke.dart --host <broker> [--port 1883] '
    '[--sub zigbee2mqtt/#] [--pub-topic t --pub-payload p] [--seconds 10] '
    '[--outage-checklist true]',
  );
  stderr.writeln(
    '  --outage-checklist true  Run opt-in, Enter-driven broker outage checks.',
  );
}

bool _runOutageChecklist(
  Map<String, String?> opts,
  int Function() deliveryCount, {
  String? Function()? readLine,
}) {
  stderr.writeln('''
[outage checklist] Keep the ZigDash app open on a dashboard that uses this broker.
This mode never controls the broker; perform each broker action yourself.

Checkpoint 1 — note the current delivery count (${deliveryCount()}).
Stop the external broker now. In ZigDash, confirm the connection shows
"Reconnecting" and existing values remain visible as "Last known".
Press Enter only after both UI states have been observed.''');
  if (!_waitForEnter(readLine: readLine)) return false;

  stderr.writeln('''
Checkpoint 2 — restart the external broker now.
Wait for ZigDash and this smoke client to reconnect, then press Enter.''');
  if (!_waitForEnter(readLine: readLine)) return false;

  final suggestedTopic = opts['pub-topic'];
  final topicInstruction = suggestedTopic == null
      ? 'a topic matched by "${opts['sub']}"'
      : '"$suggestedTopic"';
  stderr.writeln('''
Checkpoint 3 — publish a NEW retained value to $topicInstruction using an
external publisher (for example mosquitto_pub with the retain flag). Do not
reuse the pre-outage payload. In ZigDash, confirm the new value replaces the
last-known value and the stale/"Last known" indication clears.
Press Enter after the new retained value is visible.''');
  if (!_waitForEnter(readLine: readLine)) return false;

  stderr.writeln('''
Checkpoint 4 — verify the new retained publish appeared exactly once in
ZigDash and exactly once in the numbered smoke deliveries above. A single
publish must not create duplicate deliveries after reconnect.
Current smoke delivery count: ${deliveryCount()}.
Press Enter to finish and disconnect.''');
  return _waitForEnter(readLine: readLine);
}

bool _waitForEnter({String? Function()? readLine}) {
  if (checkpointConfirmed(readLine ?? stdin.readLineSync)) return true;
  stderr.writeln(
    '[outage checklist] stdin closed before confirmation; aborting safely',
  );
  return false;
}

String formatSmokeDelivery(
  String topic,
  String payload, {
  int? deliveryNumber,
}) => deliveryNumber == null
    ? '$topic\t$payload'
    : '[delivery $deliveryNumber]\t$topic\t$payload';

bool checkpointConfirmed(String? Function() readLine) => readLine() != null;

MqttProtocol _protocolFromString(String s) {
  return MqttProtocol.values.firstWhere(
    (p) => p.name == s,
    orElse: () => throw ArgumentError('unknown protocol: $s'),
  );
}

String _truncate(String s, int n) =>
    s.length <= n ? s : '${s.substring(0, n)}...';
