import 'dart:async';
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
  final _askedAt = <String, DateTime>{};
  final _askedController = StreamController<String>.broadcast();
  int _generation = -1;
  Future<void> _queue = Future.value();

  /// State topics as their request goes out.
  Stream<String> get asked => _askedController.stream;

  /// When [stateTopic] was asked on the current connection, if it was.
  DateTime? askedAt(String stateTopic) => _askedAt[stateTopic];

  /// Requests [stateTopic]'s state unless already asked on this connection.
  void request(String stateTopic, DeviceProfile profile) {
    if (!_mgr.isConnected) return;
    if (_mgr.connectionGeneration != _generation) {
      _generation = _mgr.connectionGeneration;
      _asked.clear();
      _askedAt.clear();
    }
    final payload = DeviceCommand.refresh(profile);
    if (payload == null || !_asked.add(stateTopic)) return;
    final generation = _generation;
    _queue = _queue.then((_) async {
      if (!_mgr.isConnected || _mgr.connectionGeneration != generation) return;
      _mgr.publish('$stateTopic/get', json.encode(payload), '');
      _askedAt[stateTopic] = DateTime.now();
      if (!_askedController.isClosed) _askedController.add(stateTopic);
      await Future<void>.delayed(spacing);
    });
  }
}

/// How long a device has to answer its state request before its tile says
/// "Not responding".
const deviceResponseTimeout = Duration(seconds: 15);

/// True once [DeviceStateRefresher] asked the device at `topic` for its
/// state and [deviceResponseTimeout] has passed; reset by each new request.
/// The tile shows "Not responding" only while it still has no state.
final deviceSilentProvider = StreamProvider.autoDispose
    .family<bool, ({String connectionId, String topic})>((ref, key) {
  final out = StreamController<bool>();
  Timer? timer;
  StreamSubscription<String>? sub;
  void arm(DateTime at) {
    timer?.cancel();
    out.add(false);
    final left = at.add(deviceResponseTimeout).difference(DateTime.now());
    timer = Timer(left.isNegative ? Duration.zero : left, () => out.add(true));
  }

  ref.listen(deviceStateRefresherProvider(key.connectionId), (_, next) {
    final r = next.valueOrNull;
    if (r == null) return;
    final at = r.askedAt(key.topic);
    if (at != null) arm(at);
    sub?.cancel();
    sub = r.asked
        .where((t) => t == key.topic)
        .listen((t) => arm(r.askedAt(t) ?? DateTime.now()));
  }, fireImmediately: true);
  ref.onDispose(() {
    timer?.cancel();
    sub?.cancel();
    out.close();
  });
  out.add(false);
  return out.stream;
});

final deviceStateRefresherProvider =
    FutureProvider.family<DeviceStateRefresher, String>((ref, connectionId) async =>
        DeviceStateRefresher(
            await ref.watch(mqttManagerProvider(connectionId).future)));
