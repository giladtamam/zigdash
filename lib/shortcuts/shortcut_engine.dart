import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show DartPluginRegistrant, Locale;

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
import '../features/devices/device_profile.dart';
import '../features/devices/device_state.dart' show DeviceCommand;
import '../features/panels/widgets/device_tile_panel.dart'
    show decodeDeviceState;
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
      case 'cover':
        return jsonEncode(await engine.toggle(
            args['connectionId'] as String, args['ieee'] as String,
            command: {'state': args['action'] as String}));
      case 'position':
        return jsonEncode(await engine.toggle(
            args['connectionId'] as String, args['ieee'] as String,
            command: {'position': args['position'] as int}));
      case 'set':
        return jsonEncode(await engine.control(
            args['connectionId'] as String, args['ieee'] as String,
            on: args['on'] as bool));
      case 'level':
        return jsonEncode(await engine.control(
            args['connectionId'] as String, args['ieee'] as String,
            level: args['level'] as int));
      case 'watch':
        return jsonEncode(await engine.watch(args['connectionId'] as String,
            (args['ieees'] as List).cast<String>()));
      case 'scene':
        return jsonEncode(await engine.scene(
            args['connectionId'] as String, args['sceneId'] as String));
    }
    throw MissingPluginException(call.method);
  });
  channel.invokeMethod('ready');
}

class ShortcutEngine {
  Future<AppDatabase>? _db;

  /// The app's database, read-only: the app may be running (and migrating
  /// after an update) at the same time.
  Future<AppDatabase> get _database => _db ??= _openReadOnly();

  static Future<AppDatabase> _openReadOnly() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'zigdash.sqlite'));
    late final AppDatabase db;
    db = AppDatabase.readOnly(NativeDatabase(file, setup: (raw) {
      db.fileVersion = raw.userVersion;
      raw.execute('PRAGMA query_only = ON');
      raw.execute('PRAGMA busy_timeout = 2000');
    }));
    return db;
  }

  /// The shared preferences, re-read: the app writes them from its own
  /// isolate (a device's state, the language), and the plugin's copy here
  /// would otherwise never see it.
  Future<SharedPreferences> get _prefs async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs;
  }

  /// One manager per home, rebuilt when the home's settings or password
  /// change in the app.
  final _managers = <String, ({String key, MqttManager mgr})>{};

  /// Per home, the setup in progress: two quick taps wait for one setup
  /// instead of each creating a manager.
  final _setups = <String, Future<MqttManager?>>{};

  Future<MqttManager?> _manager(String connectionId) {
    final previous = _setups[connectionId] ?? Future<MqttManager?>.value();
    final next = previous
        .catchError((Object _) => null)
        .then((_) => _setUp(connectionId));
    _setups[connectionId] = next;
    return next;
  }

  Future<MqttManager?> _setUp(String connectionId) async {
    final db = await _database;
    final conn = await ConnectionDao(db).getById(connectionId);
    if (conn == null) return null;
    final password = await createSecureStore().readPassword(connectionId) ?? '';
    final key = [conn.host, conn.port, conn.protocol.name, conn.username,
        conn.keepAliveSeconds, conn.remoteHost, password].join('|');
    final cached = _managers[connectionId];
    if (cached != null && cached.key == key) return cached.mgr;
    unawaited(cached?.mgr.dispose()); // settings changed: stop the old one
    final mgr = MqttManager(
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
    _managers[connectionId] = (key: key, mgr: mgr);
    return mgr;
  }

  Future<ShortcutDevice?> _device(String connectionId, String ieee) async =>
      resolveShortcutDevice(await _database, connectionId, ieee);

  Future<ShortcutCommander> _commander() async {
    final code = (await _prefs).getString('locale');
    return ShortcutCommander(
        l10n: appL10n(code == null || code.isEmpty ? null : Locale(code)));
  }

  Future<Map<String, Object?>> toggle(String connectionId, String ieee,
      {Map<String, Object?>? command}) async {
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
      command: command,
    );
    if (result.outcome == ShortcutOutcome.confirmed) {
      await prefs.setString(key, jsonEncode(result.toJson()));
      // A shutter is confirmed when its motor starts; follow it to the end
      // so the shortcut shows it moving and where it stops.
      if (device.profile.deviceClass == DeviceClass.cover) {
        _follow(mgr, device, key, await _commander());
      }
    } else if (result.outcome == ShortcutOutcome.unconfirmed &&
        command == null &&
        device.profile.deviceClass == DeviceClass.cover) {
      // The shutter didn't move: it was most likely already there (moved by
      // a wall switch or an automation while the app was closed). Record
      // that, so the next tap goes the other way.
      final target = ShortcutCommander.commandFor(
          device, last['payload'] as String?)['state'];
      final assumed = (await _commander()).describe(
          device, jsonEncode({'state': target}), DateTime.now());
      await prefs.setString(key, jsonEncode(assumed.toJson()));
    }
    return {
      ...result.toJson(),
      // Where the time went, for the debug log (ms since the call).
      'timing': {'device': tDevice, 'manager': tManager, 'done': sw.elapsedMilliseconds},
    };
  }

  /// Device Controls: switch [ieee] [on] or off, or set its [level]
  /// (a shutter's position, a light's brightness).
  Future<Map<String, Object?>> control(String connectionId, String ieee,
      {bool? on, int? level}) async {
    final device = await _device(connectionId, ieee);
    if (device == null) return {'outcome': 'removed'};
    final command = on != null
        ? ShortcutCommander.switchTo(device, on: on)
        : ShortcutCommander.levelTo(device, level ?? 0);
    if (command == null) return {'outcome': 'removed'};
    return toggle(connectionId, ieee, command: command);
  }

  /// Device Controls opened: asks [ieees] for their state and writes what
  /// they report for [within], so the controls show the current state.
  Future<Map<String, Object?>> watch(String connectionId, List<String> ieees,
      {Duration within = const Duration(seconds: 30)}) async {
    final mgr = await _manager(connectionId);
    if (mgr == null) return {'outcome': 'removed'};
    if (!await mgr.ensureConnected(maxSilence: const Duration(seconds: 3))) {
      return {'outcome': 'unreachable'};
    }
    final prefs = await _prefs;
    final commander = await _commander();
    for (final ieee in ieees) {
      final d = await _device(connectionId, ieee);
      if (d == null) continue;
      final key = shortcutStateKey(connectionId, ieee);
      final sub = mgr.subscribe(d.subscribeTopic).listen((m) {
        if (m.payload.isEmpty) return;
        prefs.setString(
            key, jsonEncode(commander.describe(d, m.payload, m.receivedAt).toJson()));
      });
      final get = DeviceCommand.refresh(d.profile);
      if (get != null) mgr.publish('${d.subscribeTopic}/get', jsonEncode(get), '');
      Timer(within, () {
        sub.cancel();
        mgr.unsubscribe(d.subscribeTopic);
      });
    }
    return {'outcome': 'sent'};
  }

  /// Writes [d]'s state as it reports it, until its motor stops or after
  /// [limit]; the native tile and widget redraw on each write.
  void _follow(MqttManager mgr, ShortcutDevice d, String key,
      ShortcutCommander commander,
      {Duration limit = const Duration(seconds: 45)}) {
    late final StreamSubscription<MqttRxMessage> sub;
    Timer? stop;
    void end() {
      stop?.cancel();
      sub.cancel();
      mgr.unsubscribe(d.subscribeTopic);
    }

    final since = DateTime.now();
    sub = mgr.subscribe(d.subscribeTopic).listen((m) async {
      // The subscription first replays the last message, from before the
      // tap; its "Stop" would end the follow at once.
      if (m.payload.isEmpty || m.receivedAt.isBefore(since)) return;
      final r = commander.describe(d, m.payload, m.receivedAt);
      (await _prefs).setString(key, jsonEncode(r.toJson()));
      final motor = decodeDeviceState(m.payload)['motor_run_status'];
      if (motor is String && motor.toUpperCase() == 'STOP') end();
    });
    stop = Timer(limit, end);
  }

  Future<Map<String, Object?>> scene(String connectionId, String sceneId) async {
    final scene = await SceneDao(await _database).getById(sceneId);
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
