import '../data/repositories/connection_repo.dart';
import '../data/database/tables/connections.dart';
import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:shared_preferences/shared_preferences.dart';

import '../features/devices/devices_providers.dart' show homeBaseTopicProvider;
import '../features/settings/providers/settings_controller.dart' show sharedPreferencesProvider;
import '../mqtt/endpoint.dart';
import '../mqtt/mqtt_manager.dart';
import '../mqtt/providers/mqtt_manager_provider.dart';
import 'engine_installer.dart';
import 'engine_status.dart';

/// [HubLink] over a Home's live broker connection.
class MqttHubLink implements HubLink {
  MqttHubLink(this._mgr);
  final MqttManager _mgr;

  @override
  Stream<String> listen(String topic) {
    final controller = StreamController<String>();
    final sub = _mgr.subscribe(topic).listen((m) => controller.add(m.payload));
    controller.onCancel = () async {
      await sub.cancel();
      _mgr.unsubscribe(topic);
    };
    return controller.stream;
  }

  @override
  void publish(String topic, String payload, {bool retain = false}) =>
      _mgr.publish(topic, payload, '', qos: mc.MqttQos.atLeastOnce, retain: retain);
}

/// The Engine shipped inside this app (`hub/zigdash-engine.js`).
final engineSourceProvider =
    FutureProvider<String>((ref) => rootBundle.loadString(engineAsset));
const engineAsset = 'hub/zigdash-engine.js';

/// Everything the Automations screen and the dashboard banner show about a
/// Home's Engine.
class EngineView {
  const EngineView({
    required this.phase,
    this.hub,
    this.report,
    this.clockOff = false,
    this.declined = false,
    this.away = false,
  });

  /// Reached through the relay (3.1.7): installing, reinstalling and
  /// consent wait until the phone is home.
  final bool away;

  final HubEnginePhase phase;
  final HubInfo? hub;
  final EngineReport? report;

  /// The hub's clock is more than five minutes off the phone's.
  final bool clockOff;

  /// The user said "Not now" to the consent screen on this phone.
  final bool declined;

  bool get installed =>
      phase == HubEnginePhase.running ||
      phase == HubEnginePhase.paused ||
      phase == HubEnginePhase.stoppedSelf;
}

/// Watches `bridge/info`, `bridge/extensions` and the Engine's state for a
/// Home and re-decides the phase every 15 s, so silence turns into
/// "paused" without a new message. Silently re-saves an older Engine.
final engineViewProvider =
    StreamProvider.autoDispose.family<EngineView, String>((ref, connectionId) async* {
  // 3.2: through Zigbee2MQTT's page there is no broker for the Engine's
  // topics (Automations, Alerts, history): ask for it before anything.
  final home = await ref.read(connectionRepoProvider).getById(connectionId);
  if (transportOf(home?.transport) == ConnectionTransport.z2mPage) {
    yield const EngineView(phase: HubEnginePhase.needsBroker);
    return;
  }
  final mgr = await ref.watch(mqttManagerProvider(connectionId).future);
  final base = ref.read(homeBaseTopicProvider(connectionId)) ?? 'zigbee2mqtt';
  final prefs = ref.read(sharedPreferencesProvider);
  final link = MqttHubLink(mgr);

  HubInfo? hub;
  List<String>? extensions;
  EngineReport? report;
  DateTime? heardAt;
  var clockOff = false;
  var updateTried = false;
  final startedAt = DateTime.now();
  bool viaRelay() => mgr.activeEndpoint == MqttEndpoint.relay;

  /// How long to wait for the Engine's word through the relay (3.1.7).
  const relayWait = Duration(seconds: 15);

  final out = StreamController<EngineView>();
  EngineView view() {
    final now = DateTime.now();
    final away = viaRelay();
    return EngineView(
      phase: EngineHealth.phase(
          hub: hub,
          extensions: extensions,
          report: report,
          lastHeardAt: heardAt,
          now: now,
          viaRelay: away,
          gaveUp: now.difference(startedAt) > relayWait),
      hub: hub,
      report: report,
      clockOff: clockOff,
      declined: engineDeclined(prefs, connectionId),
      away: away,
    );
  }
  void emit() {
    if (out.isClosed) return;
    final v = view();
    out.add(v);
    if (v.installed) {
      unawaited(prefs.setBool(_installedKey(connectionId), true));
    } else if (v.phase == HubEnginePhase.notInstalled || v.phase == HubEnginePhase.needsConsent) {
      unawaited(prefs.remove(_installedKey(connectionId)));
    }
    // A silent update needs Zigbee2MQTT's bridge, which the relay never
    // carries: it waits until the phone is home.
    if (!updateTried && v.phase == HubEnginePhase.running && !v.away) {
      updateTried = true;
      unawaited(_updateIfOutdated(ref, link, base, report));
    }
  }

  final subs = <StreamSubscription<String>>[
    link.listen('$base/bridge/info').listen((raw) {
      hub = HubInfo.decode(raw) ?? hub;
      emit();
    }),
    link.listen('$base/bridge/extensions').listen((raw) {
      extensions = decodeExtensionNames(raw);
      emit();
    }),
    link.listen(EngineTopics.state).listen((raw) {
      report = EngineReport.decode(raw);
      final now = DateTime.now();
      heardAt = report == null ? null : now;
      clockOff = EngineHealth.clockOff(report, now);
      emit();
    }),
  ];
  final ticker = Timer.periodic(const Duration(seconds: 15), (_) => emit());
  // Through the relay, the wait for the Engine ends on time, not on a tick.
  final gaveUpTimer = Timer(relayWait + const Duration(milliseconds: 100), emit);
  ref.onDispose(() {
    ticker.cancel();
    gaveUpTimer.cancel();
    for (final s in subs) {
      unawaited(s.cancel());
    }
    unawaited(out.close());
  });
  emit();
  yield* out.stream;
});

Future<void> _updateIfOutdated(Ref ref, HubLink link, String base, EngineReport? report) async {
  try {
    final source = await ref.read(engineSourceProvider.future);
    if (EngineHealth.outdated(report, bundledEngineVersion(source))) {
      await EngineInstaller(link, base: base).install(source);
    }
  } catch (_) {
    // A failed silent update leaves the running Engine in place.
  }
}

/// The installer for a Home, over its live broker connection.
final engineInstallerProvider =
    FutureProvider.autoDispose.family<EngineInstaller, String>((ref, connectionId) async {
  final mgr = await ref.watch(mqttManagerProvider(connectionId).future);
  final base = ref.read(homeBaseTopicProvider(connectionId)) ?? 'zigbee2mqtt';
  return EngineInstaller(MqttHubLink(mgr), base: base);
});

String _installedKey(String connectionId) => 'engine.installed.$connectionId';

/// This phone has seen the Engine installed on the Home's hub.
bool engineKnownInstalled(SharedPreferences prefs, String connectionId) =>
    prefs.getBool(_installedKey(connectionId)) ?? false;

String _declinedKey(String connectionId) => 'engine.declined.$connectionId';

bool engineDeclined(SharedPreferences prefs, String connectionId) =>
    prefs.getBool(_declinedKey(connectionId)) ?? false;

Future<void> setEngineDeclined(SharedPreferences prefs, String connectionId, bool declined) =>
    declined ? prefs.setBool(_declinedKey(connectionId), true) : prefs.remove(_declinedKey(connectionId));
