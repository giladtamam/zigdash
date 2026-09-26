import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mqtt/mqtt_manager.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import 'device_profile.dart';
import 'device_state.dart';

/// Asks each device on screen for its current state once per connection
/// (`<device>/get` for gettable properties only), because Zigbee2MQTT does
/// not retain device state: without this a tile can wait for its first
/// report indefinitely. Requests are spaced out so a dashboard of devices
/// does not flood the Zigbee network. Custom MQTT tiles are never polled.
class DeviceStateRefresher {
  DeviceStateRefresher(this._mgr, {this.spacing = const Duration(milliseconds: 250)});

  final MqttManager _mgr;
  final Duration spacing;
  final _asked = <String>{};
  int _generation = -1;
  Future<void> _queue = Future.value();

  /// Requests [stateTopic]'s state unless already asked on this connection.
  void request(String stateTopic, DeviceProfile profile) {
    if (!_mgr.isConnected) return;
    if (_mgr.connectionGeneration != _generation) {
      _generation = _mgr.connectionGeneration;
      _asked.clear();
    }
    final payload = DeviceCommand.refresh(profile);
    if (payload == null || !_asked.add(stateTopic)) return;
    final generation = _generation;
    _queue = _queue.then((_) async {
      if (!_mgr.isConnected || _mgr.connectionGeneration != generation) return;
      _mgr.publish('$stateTopic/get', json.encode(payload), '');
      await Future<void>.delayed(spacing);
    });
  }
}

final deviceStateRefresherProvider =
    FutureProvider.family<DeviceStateRefresher, String>((ref, connectionId) async =>
        DeviceStateRefresher(
            await ref.watch(mqttManagerProvider(connectionId).future)));
