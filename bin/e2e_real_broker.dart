// End-to-end sanity checks of ZigDash's MQTT stack against a real broker with
// Zigbee2MQTT (or tool/e2e/z2m_sim.py) behind it. Runs on the Dart VM through
// the same MqttManager the app uses.
//
//   dart run bin/e2e_real_broker.dart --host localhost --port 1883
//   dart run bin/e2e_real_broker.dart --host 192.168.1.20 --user u --pass p \
//       --device living_light --read-only true
//   dart run bin/e2e_real_broker.dart --protocol ws --port 9001
//   dart run bin/e2e_real_broker.dart --restart-cmd 'tool/e2e/restart_broker.sh'
//
// --read-only true skips every publish, for a real home where commands would
// switch real devices. Exit code 0 only when every check passes.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';

late Map<String, String> opts;
var failures = 0;

void check(String name, bool ok, [String detail = '']) {
  if (!ok) failures++;
  stdout.writeln('${ok ? 'PASS' : 'FAIL'}  $name${detail.isEmpty ? '' : '  ($detail)'}');
}

BrokerConfig config(String id) => BrokerConfig(
  id: id,
  host: opts['host']!,
  port: int.parse(opts['port']!),
  protocol: MqttProtocol.values.byName(opts['protocol']!),
  username: opts['user'],
  keepAliveSeconds: 30,
);

MqttManager manager({String id = '3f2a9c1e-7b4d-4e8a-9c0f-1a2b3c4d5e6f', String? clientId}) =>
    MqttManager(
      config: config(id),
      password: opts['pass'] ?? '',
      clientIdOverride: clientId,
    );

Future<bool> waitStatus(MqttManager m, MqttStatus want, Duration timeout) async {
  if (m.status == want) return true;
  try {
    await m.status$.firstWhere((s) => s == want).timeout(timeout);
    return true;
  } on TimeoutException {
    return false;
  }
}

Future<String?> firstPayload(
  MqttManager m,
  String topic, {
  bool Function(String)? where,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final stream = m.subscribe(topic);
  try {
    final msg = await stream
        .firstWhere((e) => where == null || where(e.payload))
        .timeout(timeout);
    return msg.payload;
  } on TimeoutException {
    return null;
  } finally {
    m.unsubscribe(topic);
  }
}

Future<void> main(List<String> args) async {
  opts = {
    'host': 'localhost',
    'port': '1883',
    'protocol': 'tcp',
    'base': 'zigbee2mqtt',
    'device': 'living_light',
    'read-only': 'false',
  };
  for (var i = 0; i + 1 < args.length; i += 2) {
    opts[args[i].replaceFirst('--', '')] = args[i + 1];
  }
  final base = opts['base']!;
  final device = opts['device']!;
  final readOnly = opts['read-only'] == 'true';
  stdout.writeln('Broker ${opts['host']}:${opts['port']} (${opts['protocol']}), '
      'base "$base"${readOnly ? ', read-only' : ''}');

  // 1. Connect.
  final m = manager();
  unawaited(m.connect());
  final connected = await waitStatus(m, MqttStatus.connected, const Duration(seconds: 10));
  check('connects (MQTT 3.1 CONNECT, client id ${m.clientId})', connected,
      connected ? '' : 'last error: ${m.lastError}');
  if (!connected) {
    await m.dispose();
    exit(1);
  }

  // 2. Zigbee2MQTT bridge.
  final state = await firstPayload(m, '$base/bridge/state');
  check('bridge/state is online', state != null && state.contains('online'),
      state ?? 'nothing received');
  final devicesJson = await firstPayload(m, '$base/bridge/devices');
  var names = <String>[];
  if (devicesJson != null) {
    names = [
      for (final d in jsonDecode(devicesJson) as List)
        if (d['type'] != 'Coordinator') d['friendly_name'] as String,
    ];
  }
  check('bridge/devices lists devices', devicesJson != null,
      devicesJson == null ? 'nothing received' : '${names.length}: ${names.join(', ')}');

  // 3. Device state (retained).
  final hasDevice = names.contains(device);
  if (hasDevice) {
    final s = await firstPayload(m, '$base/$device');
    check('state of $device received', s != null, s ?? 'nothing received');
  } else {
    stdout.writeln('SKIP  device state: "$device" is not paired');
  }

  // 4. Command round trip.
  if (readOnly || !hasDevice) {
    stdout.writeln('SKIP  command round trip${readOnly ? ' (read-only)' : ''}');
  } else {
    // A value that differs from every earlier run, so a retained state can
    // never satisfy the check on its own.
    final target = 20 + DateTime.now().millisecondsSinceEpoch % 200;
    bool isEcho(String p) {
      try {
        final j = jsonDecode(p);
        return j is Map && j['brightness'] == target;
      } on FormatException {
        return false;
      }
    }

    final echoed = firstPayload(m, '$base/$device', where: isEcho);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    m.publish('$base/$device/set', '{"brightness":{value}}', target);
    final got = await echoed;
    check('command round trip ($device brightness $target)', got != null,
        got ?? 'no state update within 5 s');
  }

  // 5. Two clients for the same connection (phone + wall tablet restored from
  // one backup) must both stay connected.
  Future<int> dropsDuring(List<MqttManager> ms, Duration d) async {
    var drops = 0;
    final subs = [
      for (final x in ms)
        x.status$.skip(1).listen((s) {
          if (s == MqttStatus.reconnecting || s == MqttStatus.error) drops++;
        }),
    ];
    await Future<void>.delayed(d);
    for (final s in subs) {
      await s.cancel();
    }
    return drops;
  }

  final a = manager(id: 'same-connection');
  final b = manager(id: 'same-connection');
  unawaited(a.connect());
  unawaited(b.connect());
  final bothUp = await waitStatus(a, MqttStatus.connected, const Duration(seconds: 10)) &&
      await waitStatus(b, MqttStatus.connected, const Duration(seconds: 10));
  final drops = bothUp ? await dropsDuring([a, b], const Duration(seconds: 6)) : -1;
  check('two clients, same connection, both stay connected', bothUp && drops == 0,
      'ids ${a.clientId} / ${b.clientId}, drops in 6 s: $drops');
  await a.dispose();
  await b.dispose();

  // Control: forcing one shared id must reproduce the takeover, proving the
  // check above can see it.
  final c1 = manager(id: 'x', clientId: 'zd-shared-id-test');
  final c2 = manager(id: 'x', clientId: 'zd-shared-id-test');
  unawaited(c1.connect());
  await waitStatus(c1, MqttStatus.connected, const Duration(seconds: 10));
  unawaited(c2.connect());
  final ctrlDrops = await dropsDuring([c1, c2], const Duration(seconds: 6));
  check('control: a shared id is taken over by the broker', ctrlDrops > 0,
      'drops in 6 s: $ctrlDrops');
  await c1.dispose();
  await c2.dispose();

  // 6. Broker restart: reconnect and resubscribe.
  final restart = opts['restart-cmd'];
  if (restart == null) {
    stdout.writeln('SKIP  broker restart (no --restart-cmd)');
  } else {
    final watched = m.subscribe('$base/bridge/state');
    // Wait for the retained state first, so the next "online" can only come
    // from the re-subscription after the restart.
    try {
      await watched
          .firstWhere((e) => e.payload.contains('online'))
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      check('re-subscribe to a released topic gets the retained state', false,
          'nothing within 5 s');
    }
    final afterRestart = watched
        .where((e) => e.payload.contains('online'))
        .skip(1)
        .first
        .timeout(const Duration(seconds: 30));
    final sawReconnect = m.status$
        .firstWhere((s) => s == MqttStatus.reconnecting)
        .timeout(const Duration(seconds: 20));
    final r = await Process.run('bash', ['-c', restart]);
    if (r.exitCode != 0) stdout.writeln('restart command failed: ${r.stderr}');
    var reconnectSeen = true;
    try {
      await sawReconnect;
    } on TimeoutException {
      reconnectSeen = false;
    }
    final back = await waitStatus(m, MqttStatus.connected, const Duration(seconds: 30));
    var resubscribed = true;
    try {
      await afterRestart;
    } on TimeoutException {
      resubscribed = false;
    }
    check('broker restart: detects drop, reconnects, resubscribes',
        reconnectSeen && back && resubscribed,
        'drop seen: $reconnectSeen, reconnected: $back, bridge state again: $resubscribed');
    m.unsubscribe('$base/bridge/state');
  }

  await m.dispose();
  stdout.writeln(failures == 0 ? 'ALL PASSED' : '$failures FAILED');
  exit(failures == 0 ? 0 : 1);
}
