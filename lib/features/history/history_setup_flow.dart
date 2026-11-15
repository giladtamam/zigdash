import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../data/database/tables/connections.dart';
import '../../data/repositories/connection_repo.dart';
import '../../engine/automation.dart' show Automation;
import '../../engine/engine_providers.dart';
import '../../engine/engine_sheet.dart' show watchWaitingRules;
import '../../engine/engine_setup.dart';
import '../../engine/engine_status.dart';
import '../../engine/engine_installer.dart' show EngineInstaller, HubAnswer;
import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../pro/pro_trial.dart' show ProTrialFrom, proTrialProvider;
import 'app_history_recorder.dart' show historyRecordHereProvider;
import 'history_service.dart';

/// Putting a History recorder on a Home (3.6, docs/design/pro-trial-360.md
/// §2), shared by the "Turn on History" card and the Automations screen.

/// Installs ZigDash Engine on the hub and counts it. The error text is
/// Zigbee2MQTT's own, for the Automations screen's message.
Future<(HubAnswer, String?)> installEngineOn(
  WidgetRef ref,
  String connectionId, {
  required EngineFrom from,
  String? z2m,
}) async {
  final installer = await _installer(ref, connectionId);
  final source = await ref.read(engineSourceProvider.future);
  final (answer, error) = await installer.install(source);
  ref
      .read(analyticsProvider)
      .track(
        EngineEvent(
          answer == HubAnswer.ok ? EngineStep.installed : EngineStep.failed,
          z2m: z2m,
          from: from,
          why: answer == HubAnswer.ok ? null : installWhy(answer),
        ),
      );
  return (answer, error);
}

/// The consent was given: forget an earlier "Not now", turn on external
/// JavaScript in Zigbee2MQTT and restart it. Install comes after.
Future<HubAnswer> allowEngineAndRestart(
  WidgetRef ref,
  String connectionId, {
  required EngineFrom from,
}) async {
  await setEngineDeclined(
    ref.read(sharedPreferencesProvider),
    connectionId,
    false,
  );
  ref
      .read(analyticsProvider)
      .track(EngineEvent(EngineStep.consented, from: from));
  final installer = await _installer(ref, connectionId);
  return installer.allowExtensionsAndRestart();
}

/// The installer, kept alive while it is fetched: the provider is
/// auto-disposed, and from a card nothing else may be watching it.
Future<EngineInstaller> _installer(WidgetRef ref, String connectionId) async {
  final keep = ref.listenManual(
    engineInstallerProvider(connectionId),
    (_, _) {},
  );
  try {
    return await ref.read(engineInstallerProvider(connectionId).future);
  } finally {
    keep.close();
  }
}

/// What "Turn on History" ended in.
enum HistoryOn {
  /// The Engine records (now or before); the readings were published.
  on,

  /// Zigbee2MQTT blocks add-ons: the card asks first, in its own words.
  needsConsent,

  /// Through Zigbee2MQTT's page there is no broker: ask for it.
  needsBroker,

  /// The Engine can't go on this hub (too old, refused, no answer): this
  /// phone can record instead, while ZigDash is open.
  phoneInstead,

  /// 3.6.2: the user stopped it (this phone instead while the hub was
  /// checked, or Not now on the rules waiting for the Engine).
  cancelled,
}

/// The recorder for [connectionId], by how the Home is connected: an MQTT
/// broker or Home Assistant (which carries MQTT) get the Engine; a Home
/// reached through Zigbee2MQTT's page needs a broker first.
///
/// 3.6.2: the hub check waits up to 20 s; [onChecked] runs when it ends,
/// [abandoned] is asked then (this phone was chosen meanwhile, or the card
/// left), and [beforeInstall] sees the rules waiting for the Engine.
Future<HistoryOn> turnOnHistory(
  WidgetRef ref,
  String connectionId, {
  required HistorySetupFrom from,
  void Function()? onChecked,
  bool Function()? abandoned,
  Future<bool> Function(List<Automation> waiting)? beforeInstall,
}) async {
  final home = await ref.read(connectionRepoProvider).getById(connectionId);
  if (abandoned?.call() ?? false) return HistoryOn.cancelled;
  if (transportOf(home?.transport) == ConnectionTransport.z2mPage) {
    return HistoryOn.needsBroker;
  }
  final rules = watchWaitingRules(ref, connectionId);
  try {
    final check = await checkEngine(ref, connectionId);
    if (abandoned?.call() ?? false) return HistoryOn.cancelled;
    onChecked?.call();
    final view = check.view;
    if (view != null && view.installed) {
      return await _publish(
        ref,
        connectionId,
        from,
        HistorySetupResult.installed,
      );
    }
    switch (view?.phase) {
      // "Not now" to add-ons on this phone is kept: this phone instead.
      case HubEnginePhase.needsConsent when view!.declined:
        _track(ref, HistorySetupResult.failed, from, why: EngineWhy.blocked);
        return HistoryOn.phoneInstead;
      case HubEnginePhase.needsConsent:
        return HistoryOn.needsConsent;
      case HubEnginePhase.needsBroker:
        return HistoryOn.needsBroker;
      case HubEnginePhase.notInstalled:
        final go =
            await beforeInstall?.call(rules.read().valueOrNull ?? const []) ??
            true;
        if (!go || (abandoned?.call() ?? false)) return HistoryOn.cancelled;
        ref
            .read(analyticsProvider)
            .track(
              EngineEvent(
                EngineStep.installTapped,
                z2m: view?.hub?.version,
                from: EngineFrom.historyOn,
              ),
            );
        return await installThenPublish(
          ref,
          connectionId,
          from: from,
          z2m: view?.hub?.version,
        );
      default:
        _track(ref, HistorySetupResult.failed, from, why: engineWhy(check));
        return HistoryOn.phoneInstead;
    }
  } finally {
    rules.close();
  }
}

/// After the install (or the consent and restart): publish the readings,
/// or offer this phone when the hub said no.
Future<HistoryOn> installThenPublish(
  WidgetRef ref,
  String connectionId, {
  required HistorySetupFrom from,
  String? z2m,
}) async {
  try {
    final (answer, _) = await installEngineOn(
      ref,
      connectionId,
      from: EngineFrom.historyOn,
      z2m: z2m,
    );
    if (answer != HubAnswer.ok) {
      _track(ref, HistorySetupResult.failed, from, why: installWhy(answer));
      return HistoryOn.phoneInstead;
    }
  } catch (_) {
    _track(ref, HistorySetupResult.failed, from, why: EngineWhy.other);
    return HistoryOn.phoneInstead;
  }
  return _publish(ref, connectionId, from, HistorySetupResult.installed);
}

/// This phone records while ZigDash is open (app_history_recorder.dart).
Future<void> recordOnThisPhone(
  WidgetRef ref,
  String connectionId, {
  required HistorySetupFrom from,
}) async {
  await ref.read(historyRecordHereProvider(connectionId).notifier).set(true);
  _track(ref, HistorySetupResult.thisDevice, from);
  await markHistoryTurnedOn(ref, from);
}

Future<HistoryOn> _publish(
  WidgetRef ref,
  String connectionId,
  HistorySetupFrom from,
  HistorySetupResult result,
) async {
  await ref.read(historyServiceProvider).publishConfig(connectionId);
  _track(ref, result, from);
  await markHistoryTurnedOn(ref, from);
  return HistoryOn.on;
}

/// This install turned History on itself: the 14-day trial starts when a
/// recorder first reports online (pro_trial.dart).
Future<void> markHistoryTurnedOn(WidgetRef ref, HistorySetupFrom from) => ref
    .read(proTrialProvider.notifier)
    .markOwnAction(switch (from) {
      HistorySetupFrom.finish => ProTrialFrom.finish,
      HistorySetupFrom.card => ProTrialFrom.card,
      HistorySetupFrom.sheet => ProTrialFrom.sheet,
    });

void _track(
  WidgetRef ref,
  HistorySetupResult r,
  HistorySetupFrom from, {
  EngineWhy? why,
}) => ref.read(analyticsProvider).track(HistorySetup(r, from: from, why: why));
