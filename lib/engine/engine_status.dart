import 'dart:convert';

/// The ZigDash Engine (CONTEXT.md: Engine; docs/design/zigdash-3.0.md §2):
/// what the hub says about it, and what the app should show.

/// The extension's file name in Zigbee2MQTT (`bridge/extensions`).
const engineExtensionName = 'zigdash-engine.js';

/// The oldest Zigbee2MQTT the Engine supports (zigdash-3.0.md §2).
const engineMinZ2m = (2, 4);

/// Topics of the rules contract (zigdash-3.0.md §3), at the broker root.
abstract final class EngineTopics {
  static const state = 'zigdash/automations/state';
  static const recent = 'zigdash/automations/recent';
  static const meta = 'zigdash/automations/meta';
  static const control = 'zigdash/automations/control';
  static String rule(String id) => 'zigdash/automations/rules/$id';
}

/// What the Engine last reported on `zigdash/automations/state`.
class EngineReport {
  const EngineReport({
    required this.version,
    required this.runningOn,
    required this.rulesLoaded,
    required this.rulesUnknown,
    required this.stoppedSelf,
    required this.at,
    this.flows = const {},
    this.remoteConnected,
  });

  final String version;
  final String runningOn;
  final int rulesLoaded;
  final List<String> rulesUnknown;
  final bool stoppedSelf;

  /// Alerts and history in the Engine: "active", or "passive" while a
  /// Node-RED copy still runs them.
  final Map<String, String> flows;

  /// Whether the Engine is connected to the ZigDash relay (3.1); null when
  /// remote control isn't set up on the hub.
  final bool? remoteConnected;

  /// The hub's clock when it reported.
  final DateTime? at;

  /// Null for an empty (cleared) or unreadable payload.
  static EngineReport? decode(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final j = jsonDecode(raw) as Map;
      return EngineReport(
        version: '${j['engine'] ?? ''}',
        runningOn: '${j['running_on'] ?? 'hub'}',
        rulesLoaded: (j['rules_loaded'] as num?)?.toInt() ?? 0,
        rulesUnknown: [for (final r in (j['rules_unknown'] as List? ?? const [])) '$r'],
        stoppedSelf: j['stopped_self'] == true,
        at: DateTime.tryParse('${j['at'] ?? ''}'),
        flows: {for (final e in ((j['flows'] as Map?) ?? const {}).entries) '${e.key}': '${e.value}'},
        remoteConnected: (j['remote'] as Map?)?['connected'] as bool?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// What the app needs from Zigbee2MQTT's retained `bridge/info`.
class HubInfo {
  const HubInfo({required this.version, required this.externalJsAllowed});

  /// e.g. "2.8.0"; empty when not reported.
  final String version;

  /// `advanced.enable_external_js`: false on fresh installs of 2.11 and
  /// later; absent (allowed) before 2.11.
  final bool externalJsAllowed;

  static HubInfo? decode(String raw) {
    try {
      final j = jsonDecode(raw) as Map;
      final advanced = ((j['config'] as Map?)?['advanced'] as Map?) ?? const {};
      return HubInfo(
        version: '${j['version'] ?? ''}',
        externalJsAllowed: advanced['enable_external_js'] != false,
      );
    } catch (_) {
      return null;
    }
  }

  /// True when the version is at least [engineMinZ2m]; true for an unknown
  /// version (don't block on what we can't read).
  bool get versionSupported {
    final v = parseVersion(version);
    if (v == null) return true;
    return compareVersions(v, [engineMinZ2m.$1, engineMinZ2m.$2, 0]) >= 0;
  }
}

/// Extension names from `bridge/extensions`.
List<String> decodeExtensionNames(String raw) {
  try {
    return [
      for (final e in jsonDecode(raw) as List)
        if (e is Map && e['name'] != null) '${e['name']}',
    ];
  } catch (_) {
    return const [];
  }
}

/// "2.10.3" → [2, 10, 3]; null when unreadable.
List<int>? parseVersion(String v) {
  final m = RegExp(r'^(\d+)\.(\d+)(?:\.(\d+))?').firstMatch(v.trim());
  if (m == null) return null;
  return [int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3] ?? '0')];
}

int compareVersions(List<int> a, List<int> b) {
  for (var i = 0; i < 3; i++) {
    final d = (i < a.length ? a[i] : 0) - (i < b.length ? b[i] : 0);
    if (d != 0) return d.sign;
  }
  return 0;
}

/// The Engine's version inside the bundled `hub/zigdash-engine.js`.
String? bundledEngineVersion(String source) =>
    RegExp(r"const ENGINE_VERSION = '([^']+)'").firstMatch(source)?[1];

/// What the app shows for a Home's Engine.
enum HubEnginePhase {
  /// Waiting for `bridge/info` or `bridge/extensions`.
  checking,

  /// Zigbee2MQTT older than 2.4: "update Zigbee2MQTT".
  tooOld,

  /// Not installed, and Zigbee2MQTT allows extensions: offer Install.
  notInstalled,

  /// The Home is connected through the Zigbee2MQTT page (3.2): the Engine
  /// talks over the broker, so its details come first.
  needsBroker,

  /// Not installed, and Zigbee2MQTT blocks extensions: the consent screen.
  needsConsent,

  /// Installed and reporting.
  running,

  /// Installed but silent for over [EngineHealth.pausedAfter]
  /// (CONTEXT.md: Automations paused).
  paused,

  /// The Engine stopped itself after repeated errors.
  stoppedSelf,

  /// Away, through the relay, and no word from the Engine (3.1.7): the hub
  /// isn't connected to the relay, or its internet is down. Automations
  /// still run on the hub.
  unreachable,
}

/// Decides the phase from what the hub reported. Pure, so it is tested
/// without a broker.
abstract final class EngineHealth {
  /// Same threshold as Alerts paused.
  static const pausedAfter = Duration(seconds: 90);

  /// A retained report older than this by the hub's clock is stale on arrival
  /// (the Engine stopped long ago), whatever the phone's receive time says.
  static const staleReport = Duration(minutes: 10);

  static HubEnginePhase phase({
    required HubInfo? hub,
    required List<String>? extensions,
    required EngineReport? report,
    required DateTime? lastHeardAt,
    required DateTime now,
    bool viaRelay = false,
    bool gaveUp = false,
  }) {
    // 3.1.7: through the relay Zigbee2MQTT's bridge topics never arrive;
    // the Engine's own report, forwarded by the Engine, is all there is.
    if (viaRelay) {
      if (report == null || lastHeardAt == null) {
        return gaveUp ? HubEnginePhase.unreachable : HubEnginePhase.checking;
      }
      if (report.stoppedSelf) return HubEnginePhase.stoppedSelf;
      if (now.difference(lastHeardAt) > pausedAfter) return HubEnginePhase.paused;
      final at = report.at;
      if (at != null && now.difference(at) > staleReport) return HubEnginePhase.paused;
      return HubEnginePhase.running;
    }
    if (hub == null || extensions == null) return HubEnginePhase.checking;
    if (!hub.versionSupported) return HubEnginePhase.tooOld;
    if (!extensions.contains(engineExtensionName)) {
      return hub.externalJsAllowed ? HubEnginePhase.notInstalled : HubEnginePhase.needsConsent;
    }
    if (report == null || lastHeardAt == null) return HubEnginePhase.paused;
    if (report.stoppedSelf) return HubEnginePhase.stoppedSelf;
    if (now.difference(lastHeardAt) > pausedAfter) return HubEnginePhase.paused;
    final at = report.at;
    if (at != null && now.difference(at) > staleReport) return HubEnginePhase.paused;
    return HubEnginePhase.running;
  }

  /// True when the hub runs an older Engine than the one bundled.
  static bool outdated(EngineReport? report, String? bundled) {
    if (report == null || bundled == null) return false;
    final have = parseVersion(report.version), want = parseVersion(bundled);
    if (have == null || want == null) return false;
    return compareVersions(have, want) < 0;
  }

  /// The hub's clock differs from the phone's by more than five minutes
  /// (zigdash-3.0.md §3): time triggers would fire at the wrong time.
  static bool clockOff(EngineReport? report, DateTime receivedAt) {
    final at = report?.at;
    if (at == null) return false;
    return receivedAt.difference(at).abs() > const Duration(minutes: 5);
  }
}
