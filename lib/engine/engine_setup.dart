import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/routes.dart';
import '../core/analytics/analytics.dart';
import 'engine_installer.dart';
import 'engine_providers.dart';
import 'engine_status.dart';

/// How "make sure the Engine is on the hub" ended.
enum EngineSetup {
  /// The Engine is installed (now or before).
  ready,

  /// The hub needs the user (consent, an update, or it can't be read):
  /// the Automations screen was opened to take them through it.
  needsUser,

  /// Zigbee2MQTT refused or didn't answer.
  failed,
}

/// Alerts, history and automations all run in the Engine (zigdash-3.0.md
/// §4): before setting one up, put the Engine on the hub, installing it
/// directly when Zigbee2MQTT allows it.
Future<EngineSetup> ensureEngine(
  BuildContext context,
  WidgetRef ref,
  String connectionId, {
  EngineFrom from = EngineFrom.automations,
}) async {
  final view = await settledEngineView(ref, connectionId);
  if (view == null) {
    if (context.mounted) context.go(Routes.homeAutomations(connectionId));
    return EngineSetup.needsUser;
  }
  if (view.installed) return EngineSetup.ready;
  if (view.phase != HubEnginePhase.notInstalled) {
    if (context.mounted) context.go(Routes.homeAutomations(connectionId));
    return EngineSetup.needsUser;
  }
  try {
    final installer = await ref.read(
      engineInstallerProvider(connectionId).future,
    );
    final source = await ref.read(engineSourceProvider.future);
    final (answer, _) = await installer.install(source);
    ref
        .read(analyticsProvider)
        .track(
          EngineEvent(
            answer == HubAnswer.ok ? EngineStep.installed : EngineStep.failed,
            z2m: view.hub?.version,
            from: from,
          ),
        );
    return answer == HubAnswer.ok ? EngineSetup.ready : EngineSetup.failed;
  } catch (_) {
    return EngineSetup.failed;
  }
}

/// The first view past "checking", or null if the hub doesn't say within
/// [within].
Future<EngineView?> settledEngineView(
  WidgetRef ref,
  String connectionId, {
  Duration within = const Duration(seconds: 8),
}) {
  final done = Completer<EngineView?>();
  final sub = ref.listenManual<AsyncValue<EngineView>>(
    engineViewProvider(connectionId),
    (_, next) {
      final v = next.valueOrNull;
      if (v != null && v.phase != HubEnginePhase.checking && !done.isCompleted)
        done.complete(v);
    },
    fireImmediately: true,
  );
  return done.future
      .timeout(within, onTimeout: () => null)
      .whenComplete(sub.close);
}
