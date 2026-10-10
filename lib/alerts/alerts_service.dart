import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database.dart';
import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../l10n/app_localizations.dart';
import '../mqtt/mqtt_manager.dart';
import '../mqtt/providers/mqtt_manager_provider.dart';
import '../shortcuts/shortcut_service.dart' show appChannel;
import 'alert_push.dart';
import 'alerts_config.dart';

/// What the hub answered to a test notification.
class AlertTestResult {
  const AlertTestResult({required this.ok, this.status, this.body, this.timedOut = false});
  final bool ok;
  final int? status;
  final String? body;
  final bool timedOut;
}

/// Keeps a Home's alerts config (docs/design/alerts-2.3.md): this phone's
/// copy in the database, and the retained copy on the broker that the hub's
/// flow reads. Registers this phone for pushes and puts its endpoint into
/// the config.
class AlertsService {
  AlertsService(this._db, this._prefs, this._managerOf);

  final AppDatabase _db;
  final SharedPreferences _prefs;
  final Future<MqttManager?> Function(String connectionId) _managerOf;

  String get phoneId => AlertPush.phoneId(_prefs);

  Future<AlertsConfig?> load(String connectionId) async {
    final row = await (_db.select(_db.alertConfigs)
          ..where((t) => t.connectionId.equals(connectionId)))
        .getSingleOrNull();
    return row == null ? null : AlertsConfig.decode(row.config);
  }

  Stream<AlertsConfig?> watch(String connectionId) => (_db.select(_db.alertConfigs)
        ..where((t) => t.connectionId.equals(connectionId)))
      .watchSingleOrNull()
      .map((row) => row == null ? null : AlertsConfig.decode(row.config));

  Future<void> save(AlertsConfig config) async {
    await _db.into(_db.alertConfigs).insertOnConflictUpdate(
        AlertConfigsCompanion.insert(
            connectionId: config.connectionId,
            config: config.encode(),
            updatedAt: DateTime.now()));
    // The notification's title is this phone's own name for the Home.
    final conn = await (_db.select(_db.connections)
          ..where((c) => c.id.equals(config.connectionId)))
        .getSingleOrNull();
    if (conn != null) await AlertPush.rememberHomeName(_prefs, config.connectionId, conn.name);
  }

  /// The Home's config, made from the Connection on first use (with a fresh
  /// key pair, the Home's name, base topic and this phone's time zone).
  Future<AlertsConfig> ensure(String connectionId, AppLocalizations l10n) async {
    final existing = await load(connectionId);
    if (existing != null && existing.vapid != null) return existing;
    final conn = await (_db.select(_db.connections)
          ..where((c) => c.id.equals(connectionId)))
        .getSingle();
    final keys = await _native<Map>('generateVapidKeys');
    final zone = await _native<String>('timeZoneId');
    final config = (existing ??
            AlertsConfig(
                connectionId: connectionId,
                home: conn.name,
                base: conn.z2mBaseTopic ?? 'zigbee2mqtt',
                timeZone: zone ?? 'UTC'))
        .copyWith(
      vapid: existing?.vapid ??
          VapidKeys.fromJson(Map<String, dynamic>.from(keys ?? {})),
      text: textsFor(l10n),
    );
    await save(config);
    return config;
  }

  /// The raw-text phrases for ntfy and Pushover, in the app's language.
  static Map<String, String> textsFor(AppLocalizations l10n) => {
        'leak': l10n.alertLeak('{name}'),
        'leakCleared': l10n.alertLeakCleared('{name}'),
        'smoke': l10n.alertSmoke('{name}'),
        'smokeCleared': l10n.alertSmokeCleared('{name}'),
        'opened': l10n.alertOpened('{name}'),
        'battery': l10n.alertBattery('{name}', '{value}'),
        'test': l10n.alertTest,
      };

  /// Publishes the Home's config retained for the hub. False when the
  /// broker isn't connected (the caller says so; the next connect retries).
  Future<bool> publish(String connectionId) async {
    final config = await load(connectionId);
    final mgr = await _managerOf(connectionId);
    if (mgr == null || !mgr.isConnected) return false;
    mgr.publish(AlertsConfig.configTopic, config?.encode() ?? '', '',
        qos: mc.MqttQos.atLeastOnce, retain: true);
    return true;
  }

  /// Turns alerts off for the Home: the config goes, on the broker too.
  Future<void> turnOff(String connectionId) async {
    await (_db.delete(_db.alertConfigs)
          ..where((t) => t.connectionId.equals(connectionId)))
        .go();
    await publish(connectionId);
    await AlertPush.unregister(connectionId);
  }

  bool thisPhoneIn(AlertsConfig config) =>
      config.phones.any((p) => p.id == phoneId);

  /// Registers this phone for the Home's pushes; its endpoint lands in the
  /// config through [onEndpoint] when Google answers.
  Future<void> enableThisPhone(String connectionId, AppLocalizations l10n) async {
    final config = await ensure(connectionId, l10n);
    final key = config.vapid?.publicKey;
    if (key == null) return;
    final known = AlertPush.registration(_prefs, connectionId);
    if (known != null) await onEndpoint(connectionId, known);
    await AlertPush.register(connectionId, key);
  }

  Future<void> disableThisPhone(String connectionId) async {
    final config = await load(connectionId);
    if (config != null) {
      await save(config.withoutPhone(phoneId));
      await publish(connectionId);
    }
    await AlertPush.unregister(connectionId);
  }

  /// A registration arrived: put this phone into the Home's config.
  Future<void> onEndpoint(String connectionId, PushRegistration reg) async {
    final config = await load(connectionId);
    if (config == null) return;
    final mine = config.phones.where((p) => p.id == phoneId).firstOrNull;
    if (mine != null &&
        mine.endpoint == reg.endpoint &&
        mine.p256dh == reg.p256dh &&
        mine.auth == reg.auth) {
      return;
    }
    await save(config.withPhone(AlertPhone(
        id: phoneId,
        name: mine?.name ?? await AlertPush.phoneName(),
        endpoint: reg.endpoint,
        p256dh: reg.p256dh,
        auth: reg.auth)));
    await publish(connectionId);
  }

  /// The broker's retained config arrived (maybe from another phone): take
  /// it as the truth, keeping this phone's own entry.
  Future<void> onRetained(String connectionId, String raw) async {
    final retained = AlertsConfig.decode(raw);
    final local = await load(connectionId);
    // Pushes name the Home by the writing phone's id: map it to ours.
    if (retained != null && retained.connectionId != connectionId) {
      await AlertPush.rememberAlias(_prefs, retained.connectionId, connectionId);
    }
    if (retained == null) {
      // Another phone turned alerts off.
      if (local != null) {
        await (_db.delete(_db.alertConfigs)
              ..where((t) => t.connectionId.equals(connectionId)))
            .go();
      }
      return;
    }
    // The broker's copy carries the Home id of the phone that wrote it; here
    // it lives under this phone's id for the same Home.
    final merged = (local ??
            AlertsConfig(
                connectionId: connectionId,
                home: retained.home,
                base: retained.base,
                timeZone: retained.timeZone))
        .mergedFrom(retained, myPhoneId: phoneId);
    if (local == null || merged.encode() != local.encode()) await save(merged);
  }

  /// Follows the broker's retained copy of the Home's config while the Home
  /// is connected, so another phone's changes reach this one.
  Future<StreamSubscription<Object?>?> followRetained(String connectionId) async {
    final mgr = await _managerOf(connectionId);
    if (mgr == null) return null;
    final sub = mgr.subscribe(AlertsConfig.configTopic).listen((m) {
      unawaited(onRetained(connectionId, m.payload));
    });
    sub.onDone(() => mgr.unsubscribe(AlertsConfig.configTopic));
    return sub;
  }

  /// Asks the hub to push a test alert to this phone and waits for its
  /// answer on the result topic.
  Future<AlertTestResult> sendTest(String connectionId,
      {Duration within = const Duration(seconds: 15)}) async {
    final mgr = await _managerOf(connectionId);
    if (mgr == null || !mgr.isConnected) return const AlertTestResult(ok: false);
    final answer = Completer<AlertTestResult>();
    final sub = mgr.subscribe(AlertsConfig.testResultTopic).listen((m) {
      if (m.payload.isEmpty || answer.isCompleted) return;
      try {
        final j = jsonDecode(m.payload) as Map;
        if (j['phone'] != null && j['phone'] != phoneId) return;
        answer.complete(AlertTestResult(
            ok: j['ok'] == true,
            status: (j['status'] as num?)?.toInt(),
            body: j['body'] as String?));
      } catch (_) {}
    });
    try {
      mgr.publish(AlertsConfig.testTopic, jsonEncode({'phone': phoneId}), '',
          qos: mc.MqttQos.atLeastOnce);
      return await answer.future
          .timeout(within, onTimeout: () => const AlertTestResult(ok: false, timedOut: true));
    } finally {
      unawaited(sub.cancel());
      mgr.unsubscribe(AlertsConfig.testResultTopic);
    }
  }

  Future<T?> _native<T>(String method) async {
    try {
      return await appChannel.invokeMethod<T>(method);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}

final alertsServiceProvider = Provider<AlertsService>((ref) => AlertsService(
      ref.watch(appDatabaseProvider),
      ref.watch(sharedPreferencesProvider),
      (id) => ref.read(mqttManagerProvider(id).future),
    ));

/// This phone's copy of a Home's alerts config.
final alertsConfigProvider =
    StreamProvider.family<AlertsConfig?, String>((ref, connectionId) =>
        ref.watch(alertsServiceProvider).watch(connectionId));
