import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';

/// Owns the ZigDash<->Node-RED MQTT contract for scheduled automations.
/// ZigDash writes a retained config the always-on Node-RED flow consumes;
/// it never executes the schedule itself.
class AutomationConfigPublisher {
  AutomationConfigPublisher(this._ref);
  final Ref _ref;

  static String configTopic(String panelId) =>
      'zigdash/automation/schedule/$panelId/config';

  static String stateTopic(String panelId) =>
      'zigdash/automation/schedule/$panelId/state';

  static const String bridgeStateTopic = 'zigdash/automation/bridge/state';

  /// The retained JSON the Node-RED flow expects.
  static String buildPayload({
    required String name,
    required String target,
    required ScheduleConfig config,
  }) =>
      json.encode({
        'name': name,
        'target': target,
        'openTime': config.openTime,
        'closeTime': config.closeTime,
        'openPayload': config.openPayload,
        'closePayload': config.closePayload,
        'enabled': config.enabled,
      });

  /// Publishes the retained config. Returns false if the broker isn't
  /// connected (caller can surface a hint). The heartbeat chip on the
  /// panel is the real "is it running" safety net.
  Future<bool> publishConfig({
    required String connectionId,
    required String panelId,
    required String name,
    required String target,
    required ScheduleConfig config,
  }) async {
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (!mgr.isConnected) return false;
    mgr.publish(
      configTopic(panelId),
      buildPayload(name: name, target: target, config: config),
      '',
      qos: mc.MqttQos.atLeastOnce,
      retain: true,
    );
    return true;
  }

  /// Tombstone: clears the retained config so the flow drops the schedule.
  Future<void> clearConfig({
    required String connectionId,
    required String panelId,
  }) async {
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (!mgr.isConnected) return;
    mgr.publish(configTopic(panelId), '', '', retain: true);
  }
}

final automationConfigPublisherProvider = Provider<AutomationConfigPublisher>(
  (ref) => AutomationConfigPublisher(ref),
);
