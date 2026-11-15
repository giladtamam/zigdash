import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:shared_preferences/shared_preferences.dart';

import '../features/settings/providers/settings_controller.dart' show sharedPreferencesProvider;
import '../mqtt/mqtt_manager.dart';
import '../mqtt/providers/mqtt_manager_provider.dart';
import '../shortcuts/shortcut_service.dart' show appChannel;
import 'automation.dart';
import 'engine_status.dart';

/// A town for sunrise and sunset (zigdash-3.0.md §1): typed once, kept on
/// this phone and written to the hub's meta. Never the phone's location.
class Town {
  const Town({required this.name, required this.lat, required this.lon});
  final String name;
  final double lat;
  final double lon;

  Map<String, Object?> toJson() => {'name': name, 'lat': lat, 'lon': lon};
  static Town? fromJson(Object? j) => j is Map
      ? Town(name: '${j['name']}', lat: (j['lat'] as num).toDouble(), lon: (j['lon'] as num).toDouble())
      : null;
}

/// One run the Engine kept (CONTEXT.md: Recent runs).
class AutomationRun {
  const AutomationRun({required this.id, required this.at, required this.commands});
  final String id;
  final DateTime at;
  final int commands;
}

List<AutomationRun> decodeRuns(String raw) {
  try {
    return [
      for (final r in jsonDecode(raw) as List)
        if (r is Map && DateTime.tryParse('${r['at']}') != null)
          AutomationRun(
              id: '${r['id']}',
              at: DateTime.parse('${r['at']}').toLocal(),
              commands: (r['commands'] as num?)?.toInt() ?? 0),
    ];
  } catch (_) {
    return const [];
  }
}

/// Reads and writes a Home's Automations on its broker. The hub's retained
/// topics are the truth (zigdash-3.0.md §3): every phone sees the same list.
class AutomationsRepo {
  AutomationsRepo(this._managerOf, this._prefs, {Future<String?> Function()? timeZone})
      : _timeZone = timeZone ?? _nativeTimeZone;

  final Future<MqttManager> Function(String connectionId) _managerOf;
  final SharedPreferences _prefs;
  final Future<String?> Function() _timeZone;

  static const _rulesPattern = 'zigdash/automations/rules/+';

  Stream<List<Automation>> watch(String connectionId) async* {
    final mgr = await _managerOf(connectionId);
    final rules = <String, Automation>{};
    final stream = mgr.subscribe(_rulesPattern);
    List<Automation> sorted() =>
        rules.values.toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    // 3.1.7: through the relay the rules arrived once, at connect, before
    // this screen listened. Start from this session's copies (never saved
    // ones: a rule deleted elsewhere must not come back).
    for (final m in mgr.liveUnder('zigdash/automations/rules/')) {
      final rule = Automation.decode(m.topic.split('/').last, m.payload);
      if (rule != null) rules[rule.id] = rule;
    }
    try {
      yield sorted();
      await for (final m in stream) {
        final id = m.topic.split('/').last;
        final rule = Automation.decode(id, m.payload);
        if (rule == null) {
          rules.remove(id);
        } else {
          rules[id] = rule;
        }
        yield sorted();
      }
    } finally {
      mgr.unsubscribe(_rulesPattern);
    }
  }

  Stream<List<AutomationRun>> watchRuns(String connectionId) async* {
    final mgr = await _managerOf(connectionId);
    try {
      await for (final m in mgr.subscribe(EngineTopics.recent)) {
        yield decodeRuns(m.payload);
      }
    } finally {
      mgr.unsubscribe(EngineTopics.recent);
    }
  }

  /// Publishes [rule] retained, and the Home's meta with it. False when the
  /// broker isn't connected.
  Future<bool> save(String connectionId, Automation rule) async {
    final mgr = await _managerOf(connectionId);
    if (!mgr.isConnected) return false;
    await publishMeta(connectionId, mgr: mgr);
    mgr.publish(EngineTopics.rule(rule.id), rule.encode(), '', qos: mc.MqttQos.atLeastOnce, retain: true);
    return true;
  }

  Future<bool> delete(String connectionId, String id) async {
    final mgr = await _managerOf(connectionId);
    if (!mgr.isConnected) return false;
    mgr.publish(EngineTopics.rule(id), '', '', qos: mc.MqttQos.atLeastOnce, retain: true);
    return true;
  }

  Town? town(String connectionId) {
    final raw = _prefs.getString('automations.town.$connectionId');
    if (raw == null) return null;
    try {
      return Town.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> setTown(String connectionId, Town town) async {
    await _prefs.setString('automations.town.$connectionId', jsonEncode(town.toJson()));
    await publishMeta(connectionId);
  }

  /// The Home's timezone and town for the Engine's clock and sun times.
  Future<void> publishMeta(String connectionId, {MqttManager? mgr}) async {
    final m = mgr ?? await _managerOf(connectionId);
    if (!m.isConnected) return;
    final t = town(connectionId);
    final meta = {
      'timezone': await _timeZone() ?? 'UTC',
      if (t != null) ...{'lat': t.lat, 'lon': t.lon, 'town': t.name},
    };
    m.publish(EngineTopics.meta, jsonEncode(meta), '', qos: mc.MqttQos.atLeastOnce, retain: true);
  }

  static Future<String?> _nativeTimeZone() async {
    try {
      return await appChannel.invokeMethod<String>('timeZoneId');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}

final automationsRepoProvider = Provider<AutomationsRepo>((ref) => AutomationsRepo(
      (id) => ref.read(mqttManagerProvider(id).future),
      ref.watch(sharedPreferencesProvider),
    ));

final automationsProvider = StreamProvider.autoDispose.family<List<Automation>, String>((ref, connectionId) {
  ref.watch(mqttManagerProvider(connectionId)); // follow a rebuilt connection
  return ref.watch(automationsRepoProvider).watch(connectionId);
});

final automationRunsProvider = StreamProvider.autoDispose.family<List<AutomationRun>, String>((ref, connectionId) {
  ref.watch(mqttManagerProvider(connectionId));
  return ref.watch(automationsRepoProvider).watchRuns(connectionId);
});

/// A new rule id: short, unique enough per Home, safe as a topic level.
String newAutomationId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);
