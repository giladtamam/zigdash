import 'dart:convert';

/// A Home's alerts as the hub's flow reads them (docs/design/alerts-2.3.md,
/// "The config contract"). This is the JSON published retained on
/// `zigdash/alerts/config`; every phone keeps a copy and the last writer
/// wins, except that [phones] are merged by id so one phone can't drop
/// another.
class AlertsConfig {
  const AlertsConfig({
    required this.connectionId,
    required this.home,
    required this.base,
    required this.timeZone,
    this.vapid,
    this.phones = const [],
    this.ntfy,
    this.pushover,
    this.hideNames = false,
    this.text = const {},
    this.alerts = const [],
  });

  static const version = 1;
  static const configTopic = 'zigdash/alerts/config';
  static const stateTopic = 'zigdash/alerts/state';
  static const recentTopic = 'zigdash/alerts/recent';
  static const bridgeStateTopic = 'zigdash/alerts/bridge/state';
  static const testTopic = 'zigdash/alerts/test';
  static const testResultTopic = 'zigdash/alerts/test/result';

  final String connectionId;
  final String home;

  /// The Home's Zigbee2MQTT base topic.
  final String base;

  /// IANA zone for an alert's hours (the hub's Node-RED runs in UTC).
  final String timeZone;
  final VapidKeys? vapid;
  final List<AlertPhone> phones;
  final NtfySettings? ntfy;
  final PushoverSettings? pushover;
  final bool hideNames;

  /// Texts for ntfy and Pushover, which show raw text: `{name}`, `{home}`
  /// and `{value}` are filled in by the flow.
  final Map<String, String> text;
  final List<AlertRule> alerts;

  Map<String, Object?> toJson() => {
        'version': version,
        'connection': connectionId,
        'home': home,
        'base': base,
        'timeZone': timeZone,
        'vapid': vapid?.toJson(),
        'phones': [for (final p in phones) p.toJson()],
        'ntfy': ntfy?.toJson(),
        'pushover': pushover?.toJson(),
        'hideNames': hideNames,
        'text': text,
        'alerts': [for (final a in alerts) a.toJson()],
      };

  String encode() => jsonEncode(toJson());

  static AlertsConfig fromJson(Map<String, dynamic> j) => AlertsConfig(
        connectionId: j['connection'] as String? ?? '',
        home: j['home'] as String? ?? '',
        base: j['base'] as String? ?? 'zigbee2mqtt',
        timeZone: j['timeZone'] as String? ?? 'UTC',
        vapid: j['vapid'] is Map
            ? VapidKeys.fromJson(Map<String, dynamic>.from(j['vapid'] as Map))
            : null,
        phones: [
          for (final p in (j['phones'] as List? ?? const []))
            if (p is Map) AlertPhone.fromJson(Map<String, dynamic>.from(p)),
        ],
        ntfy: j['ntfy'] is Map
            ? NtfySettings.fromJson(Map<String, dynamic>.from(j['ntfy'] as Map))
            : null,
        pushover: j['pushover'] is Map
            ? PushoverSettings.fromJson(
                Map<String, dynamic>.from(j['pushover'] as Map))
            : null,
        hideNames: j['hideNames'] == true,
        text: {
          for (final e in (j['text'] as Map? ?? const {}).entries)
            '${e.key}': '${e.value}',
        },
        alerts: [
          for (final a in (j['alerts'] as List? ?? const []))
            if (a is Map) AlertRule.fromJson(Map<String, dynamic>.from(a)),
        ],
      );

  /// Parses a retained payload; null for an empty one (alerts turned off).
  static AlertsConfig? decode(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final j = jsonDecode(raw);
      return j is Map ? fromJson(Map<String, dynamic>.from(j)) : null;
    } catch (_) {
      return null;
    }
  }

  AlertsConfig copyWith({
    String? home,
    String? base,
    String? timeZone,
    VapidKeys? vapid,
    List<AlertPhone>? phones,
    NtfySettings? Function()? ntfy,
    PushoverSettings? Function()? pushover,
    bool? hideNames,
    Map<String, String>? text,
    List<AlertRule>? alerts,
  }) =>
      AlertsConfig(
        connectionId: connectionId,
        home: home ?? this.home,
        base: base ?? this.base,
        timeZone: timeZone ?? this.timeZone,
        vapid: vapid ?? this.vapid,
        phones: phones ?? this.phones,
        ntfy: ntfy != null ? ntfy() : this.ntfy,
        pushover: pushover != null ? pushover() : this.pushover,
        hideNames: hideNames ?? this.hideNames,
        text: text ?? this.text,
        alerts: alerts ?? this.alerts,
      );

  /// This copy with [phone] added or replaced (by id).
  AlertsConfig withPhone(AlertPhone phone) => copyWith(phones: [
        for (final p in phones)
          if (p.id != phone.id) p,
        phone,
      ]);

  AlertsConfig withoutPhone(String id) =>
      copyWith(phones: [for (final p in phones) if (p.id != id) p]);

  /// Takes [retained] (what the broker holds, possibly written by another
  /// phone) as the truth, keeping this phone's own entry ([myPhoneId]) as
  /// it is here: last writer wins, phones merged by id.
  AlertsConfig mergedFrom(AlertsConfig retained, {required String myPhoneId}) {
    final mine = phones.where((p) => p.id == myPhoneId).toList();
    final theirs = retained.phones.where((p) => p.id != myPhoneId);
    return AlertsConfig(
      connectionId: connectionId,
      home: retained.home,
      base: retained.base,
      timeZone: retained.timeZone,
      vapid: retained.vapid ?? vapid,
      phones: [...theirs, ...mine],
      ntfy: retained.ntfy,
      pushover: retained.pushover,
      hideNames: retained.hideNames,
      text: retained.text,
      alerts: retained.alerts,
    );
  }
}

/// The key pair the hub signs pushes with; the public key is what every
/// phone registers with (so it lives in the config, on the user's broker).
class VapidKeys {
  const VapidKeys({required this.publicKey, required this.privateJwk});
  final String publicKey;
  final Map<String, String> privateJwk;

  Map<String, Object?> toJson() =>
      {'publicKey': publicKey, 'privateJwk': privateJwk};
  static VapidKeys fromJson(Map<String, dynamic> j) => VapidKeys(
        publicKey: j['publicKey'] as String? ?? '',
        privateJwk: {
          for (final e in (j['privateJwk'] as Map? ?? const {}).entries)
            '${e.key}': '${e.value}',
        },
      );
}

/// One phone that gets this Home's notifications: its Web Push endpoint
/// and the keys the hub encrypts to.
class AlertPhone {
  const AlertPhone({
    required this.id,
    required this.name,
    required this.endpoint,
    required this.p256dh,
    required this.auth,
  });
  final String id;
  final String name;
  final String endpoint;
  final String p256dh;
  final String auth;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'endpoint': endpoint,
        'p256dh': p256dh,
        'auth': auth,
      };
  static AlertPhone fromJson(Map<String, dynamic> j) => AlertPhone(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        endpoint: j['endpoint'] as String? ?? '',
        p256dh: j['p256dh'] as String? ?? '',
        auth: j['auth'] as String? ?? '',
      );
}

class NtfySettings {
  const NtfySettings({required this.topic, this.server = 'https://ntfy.sh'});
  final String server;
  final String topic;
  Map<String, Object?> toJson() => {'server': server, 'topic': topic};
  static NtfySettings fromJson(Map<String, dynamic> j) => NtfySettings(
      server: j['server'] as String? ?? 'https://ntfy.sh',
      topic: j['topic'] as String? ?? '');
}

class PushoverSettings {
  const PushoverSettings({required this.user, required this.token});
  final String user;
  final String token;
  Map<String, Object?> toJson() => {'user': user, 'token': token};
  static PushoverSettings fromJson(Map<String, dynamic> j) => PushoverSettings(
      user: j['user'] as String? ?? '', token: j['token'] as String? ?? '');
}

/// What an alert watches for (CONTEXT.md: Alert).
enum AlertKind { leak, smoke, opened, battery }

/// One device an alert watches: Zigbee2MQTT publishes its state under the
/// friendly name, so the topic travels with the IEEE address.
class AlertDevice {
  const AlertDevice(
      {required this.ieee, required this.topic, required this.name});
  final String ieee;
  final String topic;
  final String name;
  Map<String, Object?> toJson() => {'ieee': ieee, 'topic': topic, 'name': name};
  static AlertDevice fromJson(Map<String, dynamic> j) => AlertDevice(
      ieee: j['ieee'] as String? ?? '',
      topic: j['topic'] as String? ?? '',
      name: j['name'] as String? ?? '');
}

/// One alert: a kind, its devices, and for a door its hours ("23:00" to
/// "06:00", crossing midnight allowed) or for a battery its threshold.
class AlertRule {
  const AlertRule({
    required this.id,
    required this.kind,
    required this.devices,
    this.from,
    this.to,
    this.threshold = 20,
    this.enabled = true,
  });
  final String id;
  final AlertKind kind;
  final List<AlertDevice> devices;
  final String? from;
  final String? to;
  final int threshold;

  /// Off: kept, shown, but the hub ignores it.
  final bool enabled;

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'devices': [for (final d in devices) d.toJson()],
        if (from != null && to != null) ...{'from': from, 'to': to},
        if (kind == AlertKind.battery) 'threshold': threshold,
        'enabled': enabled,
      };
  static AlertRule fromJson(Map<String, dynamic> j) => AlertRule(
        id: j['id'] as String? ?? '',
        kind: AlertKind.values.asNameMap()[j['kind']] ?? AlertKind.leak,
        devices: [
          for (final d in (j['devices'] as List? ?? const []))
            if (d is Map) AlertDevice.fromJson(Map<String, dynamic>.from(d)),
        ],
        from: j['from'] as String?,
        to: j['to'] as String?,
        threshold: (j['threshold'] as num?)?.toInt() ?? 20,
        enabled: j['enabled'] != false,
      );

  AlertRule copyWith(
          {AlertKind? kind,
          List<AlertDevice>? devices,
          String? Function()? from,
          String? Function()? to,
          int? threshold,
          bool? enabled}) =>
      AlertRule(
        id: id,
        kind: kind ?? this.kind,
        devices: devices ?? this.devices,
        from: from != null ? from() : this.from,
        to: to != null ? to() : this.to,
        threshold: threshold ?? this.threshold,
        enabled: enabled ?? this.enabled,
      );
}
