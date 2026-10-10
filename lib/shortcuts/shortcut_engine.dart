import 'dart:async';
import 'dart:convert';
import 'dart:ui' show DartPluginRegistrant, Locale;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/app_l10n.dart';
import '../core/storage/secure_storage.dart';
import '../data/database/daos/connection_dao.dart';
import '../data/database/daos/scene_dao.dart';
import '../data/database/database.dart';
import '../features/scenes/models/scene.dart';
import '../mqtt/broker_config.dart';
import '../mqtt/mqtt_manager.dart';
import 'shortcut_commander.dart';
import 'shortcut_store.dart';

/// The headless command engine for shortcuts (docs/design/roadmap-post-2.0.md,
/// 2.1 §1): a cached FlutterEngine runs this entrypoint, and the native
/// widget, tile and control code calls it over the `zigdash/shortcuts`
/// channel. It reads the app's databases but never writes them; the state a
/// shortcut shows lives in shared preferences, which the native side reads.
@pragma('vm:entry-point')
void shortcutEngine() {
  // When Android freezes the idle app, the broker connection's socket dies
  // and mqtt_client reports it as an uncaught error; the next tap reconnects
  // (ensureConnected), so log it quietly instead.
  runZonedGuarded(_serve, (e, st) => debugPrint('shortcut engine: $e'));
}

void _serve() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final engine = ShortcutEngine();
  const channel = MethodChannel('zigdash/shortcuts');
  channel.setMethodCallHandler((call) async {
    final args = Map<String, Object?>.from(call.arguments as Map? ?? {});
    switch (call.method) {
      case 'toggle':
        return jsonEncode(await engine.toggle(
            args['connectionId'] as String, args['ieee'] as String));
      case 'scene':
        return jsonEncode(await engine.scene(
            args['connectionId'] as String, args['sceneId'] as String));
    }
    throw MissingPluginException(call.method);
  });
  channel.invokeMethod('ready');
}

class ShortcutEngine {
  AppDatabase? _db;
  final _managers = <String, MqttManager>{};

  AppDatabase get _database => _db ??= AppDatabase();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<MqttManager?> _manager(String connectionId) async {
    final cached = _managers[connectionId];
    if (cached != null) return cached;
    final conn = await ConnectionDao(_database).getById(connectionId);
    if (conn == null) return null;
    final password = await createSecureStore().readPassword(connectionId) ?? '';
    return _managers[connectionId] = MqttManager(
      config: BrokerConfig(
        id: conn.id,
        host: conn.host,
        port: conn.port,
        protocol: conn.protocol,
        username: conn.username,
        keepAliveSeconds: conn.keepAliveSeconds,
        remoteHost: conn.remoteHost,
      ),
      password: password,
    );
  }

  Future<ShortcutDevice?> _device(String connectionId, String ieee) =>
      resolveShortcutDevice(_database, connectionId, ieee);

  Future<ShortcutCommander> _commander() async {
    final code = (await _prefs).getString('locale');
    return ShortcutCommander(
        l10n: appL10n(code == null || code.isEmpty ? null : Locale(code)));
  }

  Future<Map<String, Object?>> toggle(String connectionId, String ieee) async {
    final sw = Stopwatch()..start();
    final device = await _device(connectionId, ieee);
    final tDevice = sw.elapsedMilliseconds;
    final mgr = await _manager(connectionId);
    final tManager = sw.elapsedMilliseconds;
    if (device == null || mgr == null) return {'outcome': 'removed'};
    final prefs = await _prefs;
    final key = shortcutStateKey(connectionId, ieee);
    final last = _decode(prefs.getString(key));
    final result = await (await _commander()).toggle(
      mgr,
      device,
      lastPayload: last['payload'] as String?,
      lastAt: last['at'] is int
          ? DateTime.fromMillisecondsSinceEpoch(last['at'] as int)
          : null,
    );
    if (result.outcome == ShortcutOutcome.confirmed) {
      await prefs.setString(key, jsonEncode(result.toJson()));
    }
    return {
      ...result.toJson(),
      // Where the time went, for the debug log (ms since the call).
      'timing': {'device': tDevice, 'manager': tManager, 'done': sw.elapsedMilliseconds},
    };
  }

  Future<Map<String, Object?>> scene(String connectionId, String sceneId) async {
    final scene = await SceneDao(_database).getById(sceneId);
    final mgr = await _manager(connectionId);
    if (scene == null || mgr == null) return {'outcome': 'removed'};
    final outcome = await (await _commander())
        .runScene(mgr, SceneAction.decodeList(scene.actions));
    return {'outcome': outcome.name};
  }

  static Map<String, Object?> _decode(String? raw) {
    if (raw == null) return const {};
    try {
      return Map<String, Object?>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return const {};
    }
  }
}
