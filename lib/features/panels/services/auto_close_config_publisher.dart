import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';
import 'automation_config_publisher.dart';

/// Owns the ZigDash<->Node-RED MQTT contract for auto-close rules. Sibling of
/// [AutomationConfigPublisher] (which owns the daily-schedule contract). The
/// bridge heartbeat is published by the scheduler flow — this publisher only
/// reuses its topic constant for reads.
class AutoCloseConfigPublisher {
  AutoCloseConfigPublisher(this._ref);
  final Ref _ref;

  static String configTopic(String panelId) =>
      'zigdash/automation/autoclose/$panelId/config';

  static String stateTopic(String panelId) =>
      'zigdash/automation/autoclose/$panelId/state';

  static const String bridgeStateTopic =
      AutomationConfigPublisher.bridgeStateTopic;

  /// The retained JSON the Node-RED flow expects.
  static String buildPayload({
    required String name,
    required String triggerTopic,
    required String target,
    required AutoCloseConfig config,
  }) =>
      json.encode({
        'name': name,
        'triggerTopic': triggerTopic,
        'triggerPath': config.triggerPath,
        'triggerValue': config.triggerValue,
        'target': target,
        'closePayload': config.closePayload,
        'delaySeconds': config.delaySeconds,
        'enabled': config.enabled,
      });

  /// Publishes the retained config. Returns false if the broker isn't
  /// connected (caller can surface a hint via snackbar). The bridge heartbeat
  /// chip on the panel is the real "is it running" safety net.
  Future<bool> publishConfig({
    required String connectionId,
    required String panelId,
    required String name,
    required String triggerTopic,
    required String target,
    required AutoCloseConfig config,
  }) async {
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (!mgr.isConnected) return false;
    mgr.publish(
      configTopic(panelId),
      buildPayload(
        name: name,
        triggerTopic: triggerTopic,
        target: target,
        config: config,
      ),
      '',
      qos: mc.MqttQos.atLeastOnce,
      retain: true,
    );
    return true;
  }

  /// Tombstone: clears the retained config so the Node-RED flow drops the rule
  /// and cancels any pending timer. Best-effort if disconnected.
  Future<void> clearConfig({
    required String connectionId,
    required String panelId,
  }) async {
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (!mgr.isConnected) return;
    mgr.publish(configTopic(panelId), '', '', retain: true);
  }
}

final autoCloseConfigPublisherProvider = Provider<AutoCloseConfigPublisher>(
  (ref) => AutoCloseConfigPublisher(ref),
);
