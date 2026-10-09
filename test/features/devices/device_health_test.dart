import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/device_registry_dao.dart';
import 'package:zigdash/features/devices/device_health.dart';
import 'package:zigdash/features/devices/z2m_bridge.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';

const _door = Z2mDevice(
    friendlyName: 'Back door', type: 'EndDevice', ieeeAddress: '0x01');
const _bulb =
    Z2mDevice(friendlyName: 'Hall bulb', type: 'Router', ieeeAddress: '0x02');

({String payload, DateTime at}) _s(Map<String, Object?> state) =>
    (payload: jsonEncode(state), at: DateTime(2026, 9, 27, 12));

DeviceHealth _one(
  Z2mDevice d, {
  Map<String, Object?>? state,
  String? availability,
  bool tracked = false,
  bool notResponding = false,
}) =>
    deviceHealthFrom(
      [d],
      states: {if (state != null) d.friendlyName: _s(state)},
      availability: {if (availability != null) d.friendlyName: availability},
      tracked: (_) => tracked,
      notResponding: {if (notResponding) d.friendlyName},
    ).single;

void main() {
  group('batteryLowIn', () {
    test('battery_low alone decides', () {
      expect(batteryLowIn({'battery_low': true}), isTrue);
      expect(batteryLowIn({'battery_low': false}), isFalse);
    });
    test('battery alone decides at 20 %', () {
      expect(batteryLowIn({'battery': 20}), isTrue);
      expect(batteryLowIn({'battery': 21}), isFalse);
    });
    test('either field saying low is enough', () {
      expect(batteryLowIn({'battery_low': false, 'battery': 8}), isTrue);
      expect(batteryLowIn({'battery_low': true, 'battery': 80}), isTrue);
    });
    test('no battery fields → null, never "fine"', () {
      expect(batteryLowIn({'linkquality': 120}), isNull);
    });
  });

  group('deviceHealthFrom', () {
    test('one row per device, in order, with no state before a report', () {
      final rows = deviceHealthFrom([_door, _bulb]);
      expect(rows.map((r) => r.friendlyName), ['Back door', 'Hall bulb']);
      expect(rows.first.state, isNull);
      expect(rows.first.needsAttention, isFalse,
          reason: '"No report yet" is not attention');
    });

    test('battery, link quality and last heard come from the state', () {
      final h = _one(_door, state: {'battery': 8, 'linkquality': 112});
      expect((h.battery, h.linkQuality), (8, 112));
      expect(h.lastHeard, DateTime(2026, 9, 27, 12));
      expect(h.lowBattery, isTrue);
      expect(h.needsAttention, isTrue);
    });

    test('weak link is shown but is not attention', () {
      final h = _one(_door, state: {'linkquality': 12});
      expect(h.weakLink, isTrue);
      expect(h.needsAttention, isFalse);
    });

    test('availability counts only when the bridge tracks the device', () {
      const off = '{"state":"offline"}';
      expect(_one(_bulb, availability: off).online, isNull,
          reason: 'a retained message from before it was turned off');
      expect(_one(_bulb, availability: off, tracked: true).online, isFalse);
      expect(_one(_bulb, availability: off, tracked: true).needsAttention,
          isTrue);
      expect(_one(_bulb, availability: 'online', tracked: true).online, isTrue);
    });

    test('not responding only while there is no state', () {
      expect(_one(_bulb, notResponding: true).notResponding, isTrue);
      expect(
          _one(_bulb, state: {'state': 'ON'}, notResponding: true)
              .notResponding,
          isFalse);
    });

    test('failed interview and unsupported devices need attention', () {
      expect(
          _one(const Z2mDevice(
                  friendlyName: 'x', type: 'Router', interviewState: 'FAILED'))
              .needsAttention,
          isTrue);
      expect(
          _one(const Z2mDevice(friendlyName: 'y', type: 'Router', supported: false))
              .needsAttention,
          isTrue);
    });

    test('malformed state never throws', () {
      final rows = deviceHealthFrom([_door],
          states: {'Back door': (payload: 'not json', at: DateTime(2026))});
      expect(rows.single.state, isNull);
    });

    test('attention sorts first, then by name', () {
      final rows = deviceHealthFrom([_bulb, _door],
          states: {'Back door': _s({'battery': 5})})
        ..sort(compareHealth);
      expect(rows.map((r) => r.friendlyName), ['Back door', 'Hall bulb']);
    });
  });

  group('parseAvailability', () {
    test('2.x JSON and 1.x strings', () {
      expect(parseAvailability('{"state":"online"}'), isTrue);
      expect(parseAvailability('offline'), isFalse);
      expect(parseAvailability('garbage'), isNull);
    });
  });

  group('parseAvailabilityConfig', () {
    test('off by default, as on the SMHUB (Z2M 2.13)', () {
      final c = parseAvailabilityConfig(jsonEncode({
        'config': {
          'availability': {'enabled': false, 'active': {'timeout': 10}},
        },
      }));
      expect(c.tracks('0x01'), isFalse);
      expect(c.any, isFalse);
    });
    test('enabled globally, with a per-device opt-out', () {
      final c = parseAvailabilityConfig(jsonEncode({
        'config': {
          'availability': {'enabled': true},
          'devices': {
            '0x02': {'availability': false},
            '0x03': {'friendly_name': 'x'},
          },
        },
      }));
      expect(c.tracks('0x01'), isTrue);
      expect(c.tracks('0x02'), isFalse);
      expect(c.tracks('0x03'), isTrue);
    });
    test('off globally, one device opted in with its own timeout', () {
      final c = parseAvailabilityConfig(jsonEncode({
        'config': {
          'devices': {
            '0x02': {
              'availability': {'timeout': 5},
            },
          },
        },
      }));
      expect(c.tracks('0x01'), isFalse);
      expect(c.tracks('0x02'), isTrue);
      expect(c.any, isTrue);
    });
    test('older bridges: availability: true', () {
      expect(
          parseAvailabilityConfig('{"config":{"availability":true}}')
              .tracks('0x01'),
          isTrue);
    });
    test('unreadable info → not tracked', () {
      expect(parseAvailabilityConfig('nope').any, isFalse);
    });
  });

  group('nextBatteryFlag (the Devices dot)', () {
    test('a first report is stored as seen, even when already low', () {
      expect(nextBatteryFlag(null, true), (low: true, ack: true));
      expect(nextBatteryFlag(null, false), (low: false, ack: true));
    });
    test('going low lights the dot', () {
      expect(nextBatteryFlag((low: false, ack: true), true),
          (low: true, ack: false));
    });
    test('recovering clears it', () {
      expect(nextBatteryFlag((low: true, ack: false), false),
          (low: false, ack: true));
    });
    test('no change writes nothing', () {
      expect(nextBatteryFlag((low: true, ack: true), true), isNull);
      expect(nextBatteryFlag((low: false, ack: true), false), isNull);
    });
  });
}
