import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/features/devices/device_state_refresher.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';

class _Mgr extends MqttManager {
  _Mgr()
      : super(
          config: const BrokerConfig(
              id: 'c1', host: 'h', port: 1883, protocol: MqttProtocol.tcp),
          password: '',
        );
  int generation = 1;
  final sent = <(String, String)>[];
  @override
  bool get isConnected => true;
  @override
  int get connectionGeneration => generation;
  @override
  void publish(String topic, String template, Object value,
          {mc.MqttQos qos = mc.MqttQos.atLeastOnce, bool retain = false}) =>
      sent.add((topic, template));
}

final _bulb = classifyExposes([
  {
    'type': 'light',
    'features': [
      {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7},
      {'type': 'numeric', 'name': 'brightness', 'property': 'brightness', 'access': 7},
    ],
  },
  {'type': 'enum', 'name': 'effect', 'property': 'effect', 'access': 2},
]);

void main() {
  test('asks once per connection, only for gettable properties, spaced out',
      () {
    fakeAsync((async) {
      final mgr = _Mgr();
      final r = DeviceStateRefresher(mgr);
      r.request('zigbee2mqtt/bulb', _bulb);
      r.request('zigbee2mqtt/bulb', _bulb);
      r.request('zigbee2mqtt/lamp', _bulb);
      async.flushMicrotasks();
      expect(mgr.sent, [('zigbee2mqtt/bulb/get', '{"state":"","brightness":""}')]);
      async.elapse(const Duration(milliseconds: 300));
      expect(mgr.sent.map((s) => s.$1),
          ['zigbee2mqtt/bulb/get', 'zigbee2mqtt/lamp/get']);

      // Reconnect: a new generation asks again.
      mgr.generation = 2;
      r.request('zigbee2mqtt/bulb', _bulb);
      async.elapse(const Duration(seconds: 1));
      expect(mgr.sent, hasLength(3));
      mgr.dispose();
    });
  });

  test('a device with nothing gettable is never asked', () {
    fakeAsync((async) {
      final mgr = _Mgr();
      DeviceStateRefresher(mgr).request('zigbee2mqtt/door', classifyExposes([
        {'type': 'binary', 'name': 'contact', 'property': 'contact', 'access': 1},
      ]));
      async.elapse(const Duration(seconds: 1));
      expect(mgr.sent, isEmpty);
      mgr.dispose();
    });
  });
}
