import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../alerts/node_red_installer.dart';
import '../../data/database/daos/device_registry_dao.dart';
import '../../data/database/database.dart';
import '../../data/repositories/connection_repo.dart';
import '../../mqtt/mqtt_manager.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../../shortcuts/shortcut_service.dart' show appChannel;
import 'history_config.dart';
import 'history_record.dart';

/// Installs the recorder and keeps its config current
/// (docs/design/history-2.7.md). The config is computed from the Home's
/// dashboards every time; nothing about history is stored on the phone.
class HistoryService {
  HistoryService(this._db, this._connections, this._managerOf);

  final AppDatabase _db;
  final ConnectionRepo _connections;
  final Future<MqttManager?> Function(String connectionId) _managerOf;

  /// Installs the "ZigDash history" tab in the hub's Node-RED, then
  /// publishes the config so it starts recording at once.
  Future<NodeRedInstall> installRecorder(String connectionId) async {
    final conn = await _connections.getById(connectionId);
    if (conn == null) return NodeRedInstall.failed;
    final r = await NodeRedInstaller.history(host: conn.host).install(
      brokerHost: conn.host,
      brokerPort: conn.port,
      username: conn.username,
      baseTopic: conn.z2mBaseTopic ?? 'zigbee2mqtt',
    );
    if (r == NodeRedInstall.installed || r == NodeRedInstall.updated) {
      await publishConfig(connectionId);
    }
    return r;
  }

  /// The recorder as Node-RED's Import wants it, with the Home's broker and
  /// base topic filled in: for hubs where Node-RED asks for a login.
  Future<String?> importJson(String connectionId, String flowJson) async {
    final conn = await _connections.getById(connectionId);
    if (conn == null) return null;
    final tab = NodeRedInstaller.tabFor(
      flowJson,
      brokerHost: conn.host,
      brokerPort: conn.port,
      username: conn.username,
      baseTopic: conn.z2mBaseTopic ?? 'zigbee2mqtt',
    );
    const id = 'zigdash_history_tab';
    return const JsonEncoder.withIndent(' ').convert([
      {'id': id, 'type': 'tab', 'label': tab['label'], 'info': tab['info']},
      for (final n in tab['configs'] as List) n,
      for (final n in tab['nodes'] as List) {...n as Map, 'z': id},
    ]);
  }

  /// Whether the Home's broker uses a login: the recorder then needs the
  /// password typed into Node-RED, which ZigDash never sends.
  Future<bool> brokerHasLogin(String connectionId) async {
    final u = (await _connections.getById(connectionId))?.username;
    return u != null && u.isNotEmpty;
  }

  /// The Home's broker address, for messages.
  Future<String?> hostOf(String connectionId) async =>
      (await _connections.getById(connectionId))?.host;

  /// The config payload for the Home as its dashboards are now, merged
  /// with the readings already recorded for it ([retained], the payload on
  /// the broker) so phones with different dashboards don't undo each other.
  Future<String?> configFor(String connectionId, {String retained = ''}) async {
    final conn = await _connections.getById(connectionId);
    if (conn == null) return null;
    final tiles = await DeviceRegistryDao(_db).tilesOfHome(connectionId);
    String? zone;
    try {
      zone = await appChannel.invokeMethod<String>('timeZoneId');
    } on PlatformException {
      zone = null;
    } on MissingPluginException {
      zone = null;
    }
    return encodeHistoryConfig(
      home: conn.name,
      base: conn.z2mBaseTopic ?? 'zigbee2mqtt',
      timeZone: zone ?? 'UTC',
      readings: mergeHistoryReadings(
        decodeHistoryReadings(retained),
        historyReadingsOf([for (final (tile, _) in tiles) tile]),
      ),
      tallies: mergeHistoryTallies(
        decodeHistoryTallies(retained),
        historyTalliesOf([for (final (tile, _) in tiles) tile]),
      ),
    );
  }

  /// Publishes the config retained when its readings or tallies differ from
  /// those in [current] (the retained copy on the broker). Only those count: two
  /// phones in different time zones must not flip the config back and forth.
  /// False when not connected.
  Future<bool> publishConfig(String connectionId, {String? current}) async {
    final payload = await configFor(connectionId, retained: current ?? '');
    final mgr = await _managerOf(connectionId);
    if (payload == null || mgr == null || !mgr.isConnected) return false;
    if (current != null &&
        current.isNotEmpty &&
        _sameReadings(payload, current)) {
      return true;
    }
    mgr.publish(
      historyConfigTopic,
      payload,
      '',
      qos: mc.MqttQos.atLeastOnce,
      retain: true,
    );
    return true;
  }
}

final historyServiceProvider = Provider<HistoryService>(
  (ref) => HistoryService(
    ref.watch(appDatabaseProvider),
    ref.watch(connectionRepoProvider),
    (id) => ref.read(mqttManagerProvider(id).future),
  ),
);

/// Whether the recorder runs: its heartbeat says `online`. Null until the
/// broker answered (or never, when there is no recorder).
final historyRecorderOnlineProvider = StreamProvider.autoDispose
    .family<bool, String>((ref, connectionId) async* {
      final mgr = await ref.watch(mqttManagerProvider(connectionId).future);
      ref.onDispose(() => mgr.unsubscribe(historyBridgeTopic));
      yield* mgr
          .subscribe(historyBridgeTopic)
          .map((m) => m.payload == 'online');
    });

/// The retained recorder config on the broker, as text ('' when none).
final historyRetainedConfigProvider = StreamProvider.autoDispose
    .family<String, String>((ref, connectionId) async* {
      final mgr = await ref.watch(mqttManagerProvider(connectionId).future);
      ref.onDispose(() => mgr.unsubscribe(historyConfigTopic));
      yield* mgr.subscribe(historyConfigTopic).map((m) => m.payload);
    });

/// Which reading's history to show.
typedef HistoryKey = ({
  String connectionId,
  String ieee,
  String attr,
  HistoryRange range,
});

/// The parsed day records a view needs, keyed by `YYYY-MM-DD`; updates as
/// records arrive (each is retained, so they come at once) and when the
/// recorder republishes today's.
final historyDaysProvider = StreamProvider.autoDispose
    .family<Map<String, List<HistoryPoint>>, HistoryKey>((ref, key) async* {
      final mgr = await ref.watch(mqttManagerProvider(key.connectionId).future);
      final days = historyDays(key.range, DateTime.now());
      final out = <String, List<HistoryPoint>>{};
      final controller = StreamController<Map<String, List<HistoryPoint>>>();
      final subs = <StreamSubscription<MqttRxMessage>>[];
      final topics = <String>[];
      for (final d in days) {
        final topic = historyRecordTopic(key.ieee, key.attr, d);
        topics.add(topic);
        subs.add(
          mgr.subscribe(topic).listen((m) {
            final points = parseDayRecord(m.payload, d);
            if (points == null) {
              out.remove(historyDate(d));
            } else {
              out[historyDate(d)] = points;
            }
            controller.add(Map.of(out));
          }),
        );
      }
      ref.onDispose(() {
        for (final s in subs) {
          s.cancel();
        }
        for (final t in topics) {
          mgr.unsubscribe(t);
        }
        controller.close();
      });
      yield const {};
      yield* controller.stream;
    });

bool _sameReadings(String a, String b) {
  final x = decodeHistoryReadings(a), y = decodeHistoryReadings(b);
  if (x.length != y.length) return false;
  for (var i = 0; i < x.length; i++) {
    if (x[i] != y[i]) return false;
  }
  final tx = decodeHistoryTallies(a), ty = decodeHistoryTallies(b);
  if (tx.length != ty.length) return false;
  for (var i = 0; i < tx.length; i++) {
    if (tx[i] != ty[i]) return false;
  }
  return true;
}
