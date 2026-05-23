import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/scenes/models/scene.dart';
import 'package:zigdash/features/scenes/scene_capture.dart';

// A light device: state + brightness + color_temp are settable (access 7),
// linkquality is read-only (access 1).
const _light = Z2mDevice(
  friendlyName: 'living_lamp',
  type: 'Router',
  exposes: [
    Z2mExpose(type: 'light'),
    Z2mExpose(type: 'binary', property: 'state', access: 7, valueOn: 'ON'),
    Z2mExpose(type: 'numeric', property: 'brightness', access: 7),
    Z2mExpose(type: 'numeric', property: 'color_temp', access: 7),
    Z2mExpose(type: 'numeric', property: 'linkquality', access: 1),
  ],
);

// A battery sensor: everything it reports is read-only (access 1).
const _sensor = Z2mDevice(
  friendlyName: 'door_sensor',
  type: 'EndDevice',
  exposes: [
    Z2mExpose(type: 'binary', property: 'contact', access: 1),
    Z2mExpose(type: 'numeric', property: 'battery', access: 1),
    Z2mExpose(type: 'numeric', property: 'linkquality', access: 1),
  ],
);

void main() {
  group('Z2mExpose.access', () {
    test('parses the access bitmask and isSettable', () {
      final devices = parseBridgeDevices(jsonEncode([
        {
          'friendly_name': 'lamp',
          'type': 'Router',
          'definition': {
            'vendor': 'IKEA',
            'model': 'LED1',
            'exposes': [
              {
                'type': 'light',
                'features': [
                  {'type': 'binary', 'property': 'state', 'access': 7},
                  {'type': 'numeric', 'property': 'brightness', 'access': 7},
                ],
              },
              {'type': 'numeric', 'property': 'linkquality', 'access': 1},
            ],
          },
        },
      ]));

      final lamp = devices.single;
      final state = lamp.exposes.firstWhere((e) => e.property == 'state');
      final lq = lamp.exposes.firstWhere((e) => e.property == 'linkquality');
      expect(state.access, 7);
      expect(state.isSettable, isTrue);
      expect(lq.isSettable, isFalse);
    });

    test('defaults access to 0 (not settable) when absent', () {
      const e = Z2mExpose(type: 'numeric', property: 'foo');
      expect(e.access, 0);
      expect(e.isSettable, isFalse);
    });
  });

  group('captureSettableState', () {
    test('keeps settable keys, drops read-only and unknown keys', () {
      final captured = captureSettableState(_light, {
        'state': 'ON',
        'brightness': 180,
        'color_temp': 370,
        'linkquality': 84, // read-only → dropped
        'update': {'state': 'idle'}, // not exposed → dropped
      });

      expect(captured, {'state': 'ON', 'brightness': 180, 'color_temp': 370});
    });

    test('returns empty for a device with no settable exposes', () {
      final captured = captureSettableState(_sensor, {
        'contact': true,
        'battery': 95,
        'linkquality': 60,
      });
      expect(captured, isEmpty);
    });

    test('returns empty for a device with no exposes at all', () {
      const bare = Z2mDevice(friendlyName: 'x', type: 'Router');
      expect(captureSettableState(bare, {'state': 'ON'}), isEmpty);
    });
  });

  group('buildSceneAction', () {
    test('builds a /set topic and JSON payload', () {
      final action = buildSceneAction(
        base: 'zigbee2mqtt',
        friendlyName: 'living_lamp',
        settableState: {'state': 'ON', 'brightness': 180},
      );
      expect(action, isNotNull);
      expect(action!.setTopic, 'zigbee2mqtt/living_lamp/set');
      expect(jsonDecode(action.payload), {'state': 'ON', 'brightness': 180});
    });

    test('returns null when nothing is settable', () {
      final action = buildSceneAction(
        base: 'zigbee2mqtt',
        friendlyName: 'door_sensor',
        settableState: const {},
      );
      expect(action, isNull);
    });
  });

  group('captureDeviceAction', () {
    test('captures from raw state JSON end to end', () {
      final action = captureDeviceAction(
        base: 'zigbee2mqtt',
        device: _light,
        rawStateJson: '{"state":"ON","brightness":120,"linkquality":50}',
      );
      expect(action!.setTopic, 'zigbee2mqtt/living_lamp/set');
      expect(jsonDecode(action.payload), {'state': 'ON', 'brightness': 120});
    });

    test('returns null on malformed JSON', () {
      expect(
        captureDeviceAction(
          base: 'zigbee2mqtt',
          device: _light,
          rawStateJson: 'not json',
        ),
        isNull,
      );
    });

    test('returns null when the device has nothing settable', () {
      expect(
        captureDeviceAction(
          base: 'zigbee2mqtt',
          device: _sensor,
          rawStateJson: '{"contact":true,"battery":95}',
        ),
        isNull,
      );
    });
  });

  group('buildGetPayload', () {
    test('requests gettable+settable props (access & 6 == 6)', () {
      // _light: state/brightness/color_temp are access 7 (get+set+published),
      // linkquality is access 1 (read-only).
      final payload = buildGetPayload(_light);
      expect(payload.keys.toSet(),
          {'state', 'brightness', 'color_temp'});
      expect(payload.values.every((v) => v == ''), isTrue);
    });

    test('omits set-only props (no get bit) and read-only props', () {
      // A cover: state is access 3 (set, no get) → omitted; position access 7.
      const cover = Z2mDevice(
        friendlyName: 'shutter',
        type: 'Router',
        exposes: [
          Z2mExpose(type: 'cover'),
          Z2mExpose(type: 'enum', property: 'state', access: 3),
          Z2mExpose(type: 'numeric', property: 'position', access: 7),
          Z2mExpose(type: 'numeric', property: 'linkquality', access: 1),
        ],
      );
      expect(buildGetPayload(cover), {'position': ''});
    });

    test('returns empty when nothing is gettable+settable', () {
      expect(buildGetPayload(_sensor), isEmpty);
    });
  });

  group('SceneAction.encodeList / decodeList', () {
    test('round-trips a list of actions', () {
      const actions = [
        SceneAction(setTopic: 'zigbee2mqtt/a/set', payload: '{"state":"ON"}'),
        SceneAction(setTopic: 'zigbee2mqtt/b/set', payload: '{"state":"OFF"}'),
      ];
      final encoded = SceneAction.encodeList(actions);
      final decoded = SceneAction.decodeList(encoded);
      expect(decoded, actions);
    });

    test('decodeList returns empty on malformed input', () {
      expect(SceneAction.decodeList('not json'), isEmpty);
      expect(SceneAction.decodeList('{"not":"a list"}'), isEmpty);
    });
  });
}
