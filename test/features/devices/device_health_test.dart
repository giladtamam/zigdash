import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/devices/device_health.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';

void main() {
  // Helpers to build a minimal Z2mDevice for tests
  Z2mDevice device(String name) => Z2mDevice(
        friendlyName: name,
        type: 'EndDevice',
      );

  group('deviceHealthFrom', () {
    test('returns one row per device', () {
      final devices = [device('sensor_1'), device('sensor_2')];
      final result = deviceHealthFrom(devices, {}, {});
      expect(result.length, equals(2));
    });

    test('row friendlyName matches device', () {
      final devices = [device('my_sensor')];
      final result = deviceHealthFrom(devices, {}, {});
      expect(result.first.friendlyName, equals('my_sensor'));
    });

    test('device with full state: battery, linkQuality, lastSeen extracted', () {
      final devices = [device('sensor_1')];
      const stateJson =
          '{"battery":87,"linkquality":120,"last_seen":"2026-05-23T10:00:00Z"}';
      final result = deviceHealthFrom(
        devices,
        {'sensor_1': stateJson},
        {},
      );
      final health = result.first;
      expect(health.battery, equals(87));
      expect(health.linkQuality, equals(120));
      expect(health.lastSeen, equals('2026-05-23T10:00:00Z'));
    });

    test('device with availability "online" string → online true', () {
      final devices = [device('sensor_1')];
      final result = deviceHealthFrom(
        devices,
        {'sensor_1': '{"battery":50,"linkquality":100}'},
        {'sensor_1': 'online'},
      );
      expect(result.first.online, isTrue);
    });

    test('device with availability "offline" string → online false', () {
      final devices = [device('sensor_1')];
      final result = deviceHealthFrom(
        devices,
        {},
        {'sensor_1': 'offline'},
      );
      expect(result.first.online, isFalse);
    });

    test('device with availability JSON {"state":"online"} → online true', () {
      final devices = [device('sensor_1')];
      final result = deviceHealthFrom(
        devices,
        {},
        {'sensor_1': '{"state":"online"}'},
      );
      expect(result.first.online, isTrue);
    });

    test('device with availability JSON {"state":"offline"} → online false',
        () {
      final devices = [device('sensor_1')];
      final result = deviceHealthFrom(
        devices,
        {},
        {'sensor_1': '{"state":"offline"}'},
      );
      expect(result.first.online, isFalse);
    });

    test('device with no state or availability → all fields null', () {
      final devices = [device('lonely')];
      final result = deviceHealthFrom(devices, {}, {});
      final health = result.first;
      expect(health.battery, isNull);
      expect(health.linkQuality, isNull);
      expect(health.lastSeen, isNull);
      expect(health.online, isNull);
    });

    test('malformed state JSON → no throw, all state fields null', () {
      final devices = [device('bad_device')];
      expect(
        () => deviceHealthFrom(
          devices,
          {'bad_device': '{not valid json!!!'},
          {'bad_device': 'online'},
        ),
        returnsNormally,
      );
      final result = deviceHealthFrom(
        devices,
        {'bad_device': '{not valid json!!!'},
        {'bad_device': 'online'},
      );
      final health = result.first;
      expect(health.battery, isNull);
      expect(health.linkQuality, isNull);
      expect(health.lastSeen, isNull);
      // availability still parsed correctly
      expect(health.online, isTrue);
    });

    test('last_seen as numeric epoch is stringified', () {
      final devices = [device('epoch_device')];
      final result = deviceHealthFrom(
        devices,
        {'epoch_device': '{"last_seen":1716451200000}'},
        {},
      );
      expect(result.first.lastSeen, equals('1716451200000'));
    });

    test('battery as float is rounded to int', () {
      final devices = [device('float_bat')];
      final result = deviceHealthFrom(
        devices,
        {'float_bat': '{"battery":85.7,"linkquality":200}'},
        {},
      );
      expect(result.first.battery, equals(86));
    });

    test('rows are in same order as devices list', () {
      final devices = [device('a'), device('b'), device('c')];
      final result = deviceHealthFrom(devices, {}, {});
      expect(
        result.map((h) => h.friendlyName).toList(),
        equals(['a', 'b', 'c']),
      );
    });

    test('unknown availability string → online null', () {
      final devices = [device('x')];
      final result = deviceHealthFrom(
        devices,
        {},
        {'x': 'some_random_string'},
      );
      expect(result.first.online, isNull);
    });
  });
}
