import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../mqtt/mqtt_manager.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';

/// Runs a control action with feedback: light haptic + [publish] when the
/// broker is connected; otherwise a heavier haptic + a "Not connected"
/// snackbar and NO publish (so a silently-dropped tap is visible to the user).
Future<void> runControlAction(
  BuildContext context,
  WidgetRef ref,
  String connectionId,
  void Function(MqttManager mgr) publish,
) async {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  if (mgr.isConnected) {
    // Fire-and-forget: haptics are best-effort; no need to block on them.
    unawaited(HapticFeedback.selectionClick());
    publish(mgr);
  } else {
    unawaited(HapticFeedback.heavyImpact());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.controlNotConnected)),
    );
  }
}
