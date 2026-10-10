import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show Locale;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import '../core/l10n/app_l10n.dart';
import 'alert_event.dart';

/// Where this phone's notifications come from (docs/design/alerts-2.3.md,
/// "Notifications on this phone").
enum PushAvailability {
  /// Google's push, with ZigDash as its own distributor.
  push,

  /// No Google services: only the ntfy fallback can reach this phone.
  none,
}

/// A registration's endpoint and keys, as the hub needs them.
class PushRegistration {
  const PushRegistration(
      {required this.endpoint, required this.p256dh, required this.auth});
  final String endpoint;
  final String p256dh;
  final String auth;
  Map<String, String> toJson() =>
      {'endpoint': endpoint, 'p256dh': p256dh, 'auth': auth};
  static PushRegistration? fromJson(String? raw) {
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map;
      return PushRegistration(
          endpoint: j['endpoint'] as String,
          p256dh: j['p256dh'] as String,
          auth: j['auth'] as String);
    } catch (_) {
      return null;
    }
  }
}

/// The phone side of alerts: registers with Google's push (UnifiedPush,
/// ZigDash being its own distributor, so no second app), and shows each
/// push as a ZigDash notification, also when the push starts the app
/// headless (`--unifiedpush-bg`). One registration per Home, since each
/// Home has its own keys.
abstract final class AlertPush {
  static const _phoneIdKey = 'alerts.phone.id';
  static String _endpointKey(String connectionId) =>
      'alerts.endpoint.$connectionId';
  static String _failedKey(String connectionId) =>
      'alerts.failed.$connectionId';
  static const urgentChannel = 'alerts';
  static const noticeChannel = 'notices';

  static final _notes = FlutterLocalNotificationsPlugin();
  static SharedPreferences? _prefs;
  static bool _ready = false;

  /// A Home's registration arrived or changed: (connectionId, registration).
  static final endpoints =
      StreamController<(String, PushRegistration)>.broadcast();

  /// A notification was tapped while the app runs: (connectionId, ieee,
  /// Home name). The id is the writing phone's; the name finds the Home
  /// when the id isn't this phone's.
  static final taps = StreamController<(String, String?, String)>.broadcast();

  static bool get available => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Sets up notifications and the push callbacks. In the headless start
  /// ([background]) only messages matter.
  static Future<void> init(SharedPreferences prefs,
      {required bool background}) async {
    if (!available || _ready) return;
    _prefs = prefs;
    _ready = true;
    await _notes.initialize(
      settings: const InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_shortcut_tile')),
      onDidReceiveNotificationResponse: (r) {
        final t = _parsePayload(r.payload);
        if (t != null) taps.add(t);
      },
    );
    final push = UnifiedPushPlatform.instance;
    await push.initializeCallback(
      onNewEndpoint: (endpoint, instance) {
        final conn = _connectionOf(instance);
        final keys = endpoint.pubKeySet;
        if (conn == null || keys == null) return;
        final reg = PushRegistration(
            endpoint: endpoint.url, p256dh: keys.pubKey, auth: keys.auth);
        prefs.setString(_endpointKey(conn), jsonEncode(reg.toJson()));
        prefs.remove(_failedKey(conn));
        endpoints.add((conn, reg));
      },
      onRegistrationFailed: (reason, instance) {
        final conn = _connectionOf(instance);
        if (conn != null) prefs.setString(_failedKey(conn), reason.name);
        debugPrint('alerts: registration failed: $reason');
      },
      onUnregistered: (instance) {
        final conn = _connectionOf(instance);
        if (conn != null) prefs.remove(_endpointKey(conn));
      },
      onMessage: (message, instance) async {
        final event = AlertEvent.decode(
            utf8.decode(message.content, allowMalformed: true));
        if (event == null || !message.decrypted) {
          debugPrint('alerts: unreadable push');
          return;
        }
        await show(event);
      },
    );
    await push.initializeOnTempUnavailable((_) {});
    if (background) return;
    await _channels();
  }

  /// This phone's id in a Home's config, made once.
  static String phoneId(SharedPreferences prefs) {
    var id = prefs.getString(_phoneIdKey);
    if (id == null) {
      final r = Random.secure();
      id = List.generate(16, (_) => r.nextInt(16).toRadixString(16)).join();
      prefs.setString(_phoneIdKey, id);
    }
    return id;
  }

  /// "Galaxy S24 FE", for the Home's list of phones.
  static Future<String> phoneName() async {
    try {
      final a = await DeviceInfoPlugin().androidInfo;
      return a.model.isEmpty ? 'Android' : a.model;
    } catch (_) {
      return 'Android';
    }
  }

  static Future<PushAvailability> availability() async {
    if (!available) return PushAvailability.none;
    try {
      final own = (await PackageInfo.fromPlatform()).packageName;
      final list = await UnifiedPushPlatform.instance.getDistributors(const []);
      return list.contains(own) ? PushAvailability.push : PushAvailability.none;
    } on UnimplementedError {
      return PushAvailability.none; // no push plugin (tests, other platforms)
    } on MissingPluginException {
      return PushAvailability.none;
    }
  }

  static Future<bool> askPermission() async {
    final android = _notes.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Registers this phone for [connectionId]'s alerts with the Home's VAPID
  /// public key. The endpoint comes back on [endpoints].
  static Future<void> register(String connectionId, String vapidPublicKey) async {
    try {
      final own = (await PackageInfo.fromPlatform()).packageName;
      final push = UnifiedPushPlatform.instance;
      await push.saveDistributor(own);
      await push.register(_instance(connectionId), const [], null, vapidPublicKey);
    } on UnimplementedError {
      // No push plugin (tests, other platforms).
    } on MissingPluginException {
      // Same.
    }
  }

  static Future<void> unregister(String connectionId) async {
    try {
      await UnifiedPushPlatform.instance.unregister(_instance(connectionId));
    } on UnimplementedError {
      // No push plugin (tests, other platforms).
    } on MissingPluginException {
      // Same.
    }
    await _prefs?.remove(_endpointKey(connectionId));
  }

  /// The registration this phone holds for [connectionId], if any.
  static PushRegistration? registration(SharedPreferences prefs, String connectionId) =>
      PushRegistration.fromJson(prefs.getString(_endpointKey(connectionId)));

  static String? registrationFailure(SharedPreferences prefs, String connectionId) =>
      prefs.getString(_failedKey(connectionId));

  /// If the app was started by a tap on a notification.
  static Future<(String, String?, String)?> takeLaunchTap() async {
    if (!available) return null;
    final d = await _notes.getNotificationAppLaunchDetails();
    if (d == null || !d.didNotificationLaunchApp) return null;
    return _parsePayload(d.notificationResponse?.payload);
  }

  /// Shows [event] as a ZigDash notification in the app's language.
  static Future<void> show(AlertEvent event) async {
    final prefs = _prefs;
    final code = prefs?.getString('locale');
    final l10n = appL10n(code == null || code.isEmpty ? null : Locale(code));
    final urgent = event.urgent;
    await _channels();
    await _notes.show(
      id: event.device?.hashCode ?? event.at.millisecondsSinceEpoch ~/ 1000,
      title: event.home.isEmpty ? 'ZigDash' : event.home,
      body: event.text(l10n, oneHome: true),
      payload: '${event.connectionId ?? ''}|${event.device ?? ''}|${event.home}',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          urgent ? urgentChannel : noticeChannel,
          urgent ? l10n.alertsChannel : l10n.noticesChannel,
          channelDescription:
              urgent ? l10n.alertsChannelDescription : l10n.noticesChannelDescription,
          importance: urgent ? Importance.max : Importance.high,
          priority: urgent ? Priority.max : Priority.high,
          category: urgent ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.status,
          when: event.at.millisecondsSinceEpoch,
        ),
      ),
    );
  }

  static Future<void> _channels() async {
    final prefs = _prefs;
    final code = prefs?.getString('locale');
    final l10n = appL10n(code == null || code.isEmpty ? null : Locale(code));
    final android = _notes.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    await android.createNotificationChannel(AndroidNotificationChannel(
        urgentChannel, l10n.alertsChannel,
        description: l10n.alertsChannelDescription, importance: Importance.max));
    await android.createNotificationChannel(AndroidNotificationChannel(
        noticeChannel, l10n.noticesChannel,
        description: l10n.noticesChannelDescription, importance: Importance.high));
  }

  static String _instance(String connectionId) => 'alerts:$connectionId';
  static String? _connectionOf(String instance) =>
      instance.startsWith('alerts:') ? instance.substring(7) : null;

  static (String, String?, String)? _parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    final parts = payload.split('|');
    if (parts.length < 2 || parts[0].isEmpty) return null;
    return (parts[0], parts[1].isEmpty ? null : parts[1], parts.length > 2 ? parts[2] : '');
  }
}
