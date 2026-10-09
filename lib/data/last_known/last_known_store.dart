import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mqtt/mqtt_manager.dart';
import 'last_known_db.dart';

/// Keeps the last payload of every subscribed topic per home, on the phone
/// only (docs/design/dashboard-1.12.md §5, ADR 0004).
///
/// Writes are batched: payloads collect in memory and are written at most
/// every [flushEvery] (and on [flush], called when the app goes to the
/// background). Values older than [retention] are pruned, and a home keeps
/// at most [maxTopics], oldest dropped first.
class LastKnownStore {
  LastKnownStore(
    LastKnownDb Function() openDb, {
    this.flushEvery = const Duration(seconds: 5),
    DateTime Function()? now,
  })  : _openDb = openDb,
        _now = now ?? DateTime.now;

  /// Opened on first use: a store with nothing to save never touches disk.
  final LastKnownDb Function() _openDb;
  late final LastKnownDb _db = _openDb();
  final Duration flushEvery;
  final DateTime Function() _now;

  static const retention = Duration(days: 30);
  static const maxTopics = 2000;

  /// Payloads above this size (e.g. Zigbee2MQTT's device definitions) are
  /// not tile values and are never stored.
  static const maxPayload = 16 * 1024;

  final _pending = <(String, String), (String, DateTime)>{};
  Timer? _timer;

  /// Whether a message is a tile value worth keeping: not Zigbee2MQTT's
  /// bridge metadata, not our own commands echoed back, not huge.
  static bool keeps(MqttRxMessage m) =>
      !m.topic.contains('/bridge/') &&
      !m.topic.endsWith('/bridge') &&
      !m.topic.endsWith('/set') &&
      !m.topic.endsWith('/get') &&
      !m.topic.contains('/set/') &&
      m.payload.length <= maxPayload;

  void record(String connectionId, MqttRxMessage m) {
    if (!keeps(m)) return;
    _pending[(connectionId, m.topic)] = (m.payload, m.receivedAt);
    _timer ??= Timer(flushEvery, () => flush());
  }

  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    if (_pending.isEmpty) return;
    final rows = Map.of(_pending);
    _pending.clear();
    await _db.batch((b) => b.insertAllOnConflictUpdate(_db.lastKnownValues, [
          for (final MapEntry(key: (cid, topic), value: (payload, at))
              in rows.entries)
            LastKnownValuesCompanion.insert(
              connectionId: cid,
              topic: topic,
              payload: payload,
              receivedAt: at,
            ),
        ]));
    for (final cid in {for (final k in rows.keys) k.$1}) {
      await prune(cid);
    }
  }

  /// The saved values of a home, as messages from no live connection
  /// (generation -1), so tiles show them as last known until fresh data.
  Future<List<MqttRxMessage>> load(String connectionId) async {
    await prune(connectionId);
    final rows = await (_db.select(_db.lastKnownValues)
          ..where((v) => v.connectionId.equals(connectionId)))
        .get();
    return [
      for (final r in rows)
        MqttRxMessage(
          topic: r.topic,
          payload: r.payload,
          receivedAt: r.receivedAt,
          connectionGeneration: -1,
        ),
    ];
  }

  Future<void> prune(String connectionId) async {
    final cutoff = _now().subtract(retention);
    await (_db.delete(_db.lastKnownValues)
          ..where((v) =>
              v.connectionId.equals(connectionId) &
              v.receivedAt.isSmallerThanValue(cutoff)))
        .go();
    await _db.customStatement(
      'DELETE FROM last_known_values WHERE connection_id = ? AND topic NOT IN '
      '(SELECT topic FROM last_known_values WHERE connection_id = ? '
      'ORDER BY received_at DESC LIMIT $maxTopics)',
      [connectionId, connectionId],
    );
  }

  /// Drops the values of homes that no longer exist.
  Future<void> keepOnly(Set<String> connectionIds) async {
    _pending.removeWhere((k, _) => !connectionIds.contains(k.$1));
    await (_db.delete(_db.lastKnownValues)
          ..where((v) => v.connectionId.isNotIn(connectionIds)))
        .go();
  }
}

final lastKnownStoreProvider = Provider<LastKnownStore>((ref) {
  LastKnownDb? db;
  ref.onDispose(() => db?.close());
  return LastKnownStore(() => db = LastKnownDb());
});
