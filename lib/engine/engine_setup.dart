import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/routes.dart';
import '../core/analytics/analytics.dart';
import 'engine_installer.dart';
import 'engine_providers.dart';
import 'engine_status.dart';
import 'engine_sheet.dart' show WaitingRulesWatch, confirmWaitingRules;

/// How "make sure the Engine is on the hub" ended.
enum EngineSetup {
  /// The Engine is installed (now or before).
  ready,

  /// The hub needs the user (consent, an update, or it can't be read):
  /// the Automations screen was opened to take them through it.
  needsUser,

  /// Zigbee2MQTT refused or didn't answer.
  failed,

  /// 3.6.2: the user stopped it (Not now on the waiting rules, or this
  /// phone instead while the hub was checked).
  cancelled,
}

/// Alerts, history and automations all run in the Engine (zigdash-3.0.md
/// §4): before setting one up, put the Engine on the hub, installing it
/// directly when Zigbee2MQTT allows it.
///
/// 3.6.2: [onChecked] runs once the hub answered; [abandoned] is asked
/// after the hub check (the user chose this phone meanwhile, or left);
/// [failedWhy] hears why it failed; rules waiting for the Engine are
/// asked about before the install ([confirmWaitingRules]).
Future<EngineSetup> ensureEngine(BuildContext context, WidgetRef ref, String connectionId,
    {EngineFrom from = EngineFrom.automations,
    VoidCallback? onChecked,
    bool Function()? abandoned,
    void Function(EngineWhy why)? failedWhy}) async {
  final rules = WaitingRulesWatch(ref, connectionId);
  try {
    final check = await checkEngine(ref, connectionId);
    if (!context.mounted || (abandoned?.call() ?? false)) return EngineSetup.cancelled;
    onChecked?.call();
    final view = check.view;
    // 3.6.2: a hub that doesn't say in 20 s fails with why; the
    // Automations screen would only say "Checking your hub…" too.
    if (view == null) {
      failedWhy?.call(engineWhy(check));
      return EngineSetup.failed;
    }
    if (view.installed) return EngineSetup.ready;
    if (view.phase != HubEnginePhase.notInstalled) {
      if (context.mounted) context.go(Routes.homeAutomations(connectionId));
      return EngineSetup.needsUser;
    }
    final waiting = await rules.rules();
    if (!context.mounted || !await confirmWaitingRules(context, ref, connectionId, waiting)) {
      return EngineSetup.cancelled;
    }
    if (!context.mounted) return EngineSetup.cancelled;
    ref.read(analyticsProvider).track(EngineEvent(EngineStep.installTapped, z2m: view.hub?.version, from: from));
    try {
      final installer = await ref.read(engineInstallerProvider(connectionId).future);
      final source = await ref.read(engineSourceProvider.future);
      final (answer, _) = await installer.install(source);
      if (!context.mounted) return answer == HubAnswer.ok ? EngineSetup.ready : EngineSetup.failed;
      ref.read(analyticsProvider).track(EngineEvent(
          answer == HubAnswer.ok ? EngineStep.installed : EngineStep.failed,
          z2m: view.hub?.version, from: from, why: answer == HubAnswer.ok ? null : installWhy(answer)));
      if (answer != HubAnswer.ok) failedWhy?.call(installWhy(answer));
      return answer == HubAnswer.ok ? EngineSetup.ready : EngineSetup.failed;
    } catch (_) {
      failedWhy?.call(EngineWhy.other);
      return EngineSetup.failed;
    }
  } finally {
    rules.close();
  }
}

/// How long a hub check waits for Zigbee2MQTT (3.6.2: was 8 s). Longer
/// than the relay's 15 s, so away ends as "unreachable", not a timeout.
const engineCheckWait = Duration(seconds: 20);

/// A hub check: the first view past "checking", or null when the hub
/// didn't say within the wait, with the last view seen (for why).
typedef EngineCheck = ({EngineView? view, EngineView? last});

/// Waits up to [within] for the hub to say whether the Engine is there.
Future<EngineCheck> checkEngine(WidgetRef ref, String connectionId, {Duration within = engineCheckWait}) {
  EngineView? last;
  final done = Completer<EngineView?>();
  final sub = ref.listenManual<AsyncValue<EngineView>>(engineViewProvider(connectionId), (_, next) {
    final v = next.valueOrNull;
    if (v != null) last = v;
    if (v != null && v.phase != HubEnginePhase.checking && !done.isCompleted) done.complete(v);
  }, fireImmediately: true);
  return done.future
      .timeout(within, onTimeout: () => null)
      .whenComplete(sub.close)
      .then((v) => (view: v, last: last));
}

/// Why a hub check gave no Engine (3.6.2): away through the relay, no
/// `bridge/info`, info without `bridge/extensions`, or the phase it ended in.
EngineWhy engineWhy(EngineCheck check) {
  final view = check.view;
  if (view == null) {
    final last = check.last;
    // No view at all: the broker connection never came up.
    if (last == null) return EngineWhy.noConnection;
    if (last.away) return EngineWhy.relay;
    // 3.8.8: a broker that never connected is no connection, not no info.
    if (!last.connected) return EngineWhy.noConnection;
    if (last.hub == null) return EngineWhy.noInfo;
    return last.heardExtensions ? EngineWhy.other : EngineWhy.noExtensions;
  }
  return switch (view.phase) {
    HubEnginePhase.unreachable => EngineWhy.relay,
    HubEnginePhase.tooOld => EngineWhy.tooOld,
    HubEnginePhase.needsConsent => EngineWhy.blocked,
    _ => view.away ? EngineWhy.relay : EngineWhy.other,
  };
}

/// Why an install failed: Zigbee2MQTT said no, or never answered (on a hub
/// that showed add-ons allowed, so not "blocked").
EngineWhy installWhy(HubAnswer answer) =>
    answer == HubAnswer.refused ? EngineWhy.refused : answer == HubAnswer.noAnswer ? EngineWhy.noAnswer : EngineWhy.other;
