import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/features/devices/device_state.dart';

// Captured from the reference SMHUB (Z2M 2.13, 2026-09-26); see
// docs/design/research/device-classes.md.
const _bulbExposes = '''
[{"type":"enum","property":"power_on_behavior","name":"power_on_behavior","access":7,"category":"config","values":["off","on","toggle","previous"]},
 {"type":"light","features":[
   {"type":"binary","name":"state","property":"state","access":7,"value_on":"ON","value_off":"OFF","value_toggle":"TOGGLE"},
   {"type":"numeric","name":"brightness","property":"brightness","access":7,"value_min":0,"value_max":254},
   {"type":"numeric","name":"color_temp","property":"color_temp","access":7,"unit":"mired","value_min":142,"value_max":500},
   {"type":"composite","name":"color_xy","property":"color","access":7,"features":[{"type":"numeric","name":"x","property":"x","access":7},{"type":"numeric","name":"y","property":"y","access":7}]}]},
 {"type":"enum","name":"effect","property":"effect","access":2,"values":["blink","breathe"]},
 {"type":"binary","name":"do_not_disturb","property":"do_not_disturb","access":3,"category":"config","value_on":true,"value_off":false},
 {"type":"numeric","name":"linkquality","property":"linkquality","access":1,"category":"diagnostic","unit":"lqi"}]
''';
const _bulbState =
    '{"brightness":253,"color":{"hue":25,"saturation":95},"color_mode":"color_temp","color_temp":500,"linkquality":68,"state":"ON"}';

const _sonoffExposes = '''
[{"type":"switch","features":[{"type":"binary","name":"state","property":"state","access":7,"value_on":"ON","value_off":"OFF","value_toggle":"TOGGLE"}]},
 {"type":"enum","name":"power_on_behavior","property":"power_on_behavior","access":7,"category":"config"},
 {"type":"binary","name":"turbo_mode","property":"turbo_mode","access":7,"category":"config","value_on":true,"value_off":false},
 {"type":"composite","name":"inching_control_set","property":"inching_control_set","access":2,"features":[]},
 {"type":"enum","name":"action","property":"action","access":1,"category":"diagnostic","values":["toggle"]},
 {"type":"numeric","name":"linkquality","property":"linkquality","access":1,"category":"diagnostic","unit":"lqi"}]
''';

List<Object?> _j(String s) => json.decode(s) as List<Object?>;

Map<String, Object?> _binary(String p, {int access = 1, String? category}) => {
      'type': 'binary',
      'name': p,
      'property': p,
      'access': access,
      'value_on': true,
      'value_off': false,
      'category': ?category,
    };

Map<String, Object?> _numeric(String p, {String? unit, String? category}) => {
      'type': 'numeric',
      'name': p,
      'property': p,
      'access': 1,
      'unit': ?unit,
      'category': ?category,
    };

void main() {
  group('classifies the captured SMHUB devices', () {
    test('Tuya CK-BL702 bulb is a color light', () {
      final p = classifyExposes(_j(_bulbExposes));
      expect(p.deviceClass, DeviceClass.colorLight);
      expect(p.switches.single.property, 'state');
      expect(p.brightness?.max, 254);
      expect(p.colorTemp?.min, 142);
    });

    test('SONOFF MINI-ZBD is a switch; config binaries never decide', () {
      final p = classifyExposes(_j(_sonoffExposes));
      expect(p.deviceClass, DeviceClass.switchPlug);
      expect(p.switches.map((f) => f.property), ['state']);
    });

    test('the bulb reports color_temp mode, so the swatch is warm white', () {
      final p = classifyExposes(_j(_bulbExposes));
      final s = DeviceState(p, json.decode(_bulbState) as Map<String, Object?>);
      expect(s.isOn(p.switches.single), isTrue);
      expect(s.brightnessPercent, 100);
      expect(s.kelvin, 2000);
      final rgb = s.lightColor!;
      expect(rgb >> 16, 255, reason: 'warm white is red-heavy');
      expect(rgb & 0xFF, lessThan(80));
    });
  });

  group('research edge cases', () {
    test('multi-endpoint switch keeps one toggle per endpoint property', () {
      final p = classifyExposes([
        for (final ep in ['l1', 'l2'])
          {
            'type': 'switch',
            'endpoint': ep,
            'features': [
              {
                'type': 'binary',
                'name': 'state',
                'property': 'state_$ep',
                'access': 7,
                'value_on': 'ON',
                'value_off': 'OFF',
                'value_toggle': 'TOGGLE',
              },
            ],
          },
      ]);
      expect(p.deviceClass, DeviceClass.switchPlug);
      expect(p.switches.map((f) => (f.property, f.endpoint)),
          [('state_l1', 'l1'), ('state_l2', 'l2')]);
      expect(DeviceCommand.toggle(p.switches[1], true), {'state_l2': 'TOGGLE'});
    });

    test('a plug with power stays a switch and offers power as a reading', () {
      final p = classifyExposes([
        {
          'type': 'switch',
          'features': [
            {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7},
          ],
        },
        _numeric('power', unit: 'W'),
        _numeric('energy', unit: 'kWh'),
      ]);
      expect(p.deviceClass, DeviceClass.switchPlug);
      expect(p.readings.map((f) => f.property), ['power', 'energy']);
    });

    test('motion with temperature stays motion', () {
      final p = classifyExposes([
        _binary('occupancy'),
        _numeric('temperature', unit: '°C'),
        _numeric('battery', unit: '%', category: 'diagnostic'),
      ]);
      expect(p.deviceClass, DeviceClass.motion);
      expect(p.alarm?.property, 'occupancy');
      expect(p.readings.single.property, 'temperature');
    });

    test('leak wins over contact; device_temperature is not climate', () {
      final p = classifyExposes([
        _binary('battery_low'),
        _binary('contact'),
        _binary('water_leak'),
        _numeric('device_temperature', unit: '°C'),
      ]);
      expect(p.deviceClass, DeviceClass.leakSmoke);
      expect(p.alarm?.property, 'water_leak');
    });

    test('a leak sensor with only device_temperature is never climate', () {
      final p = classifyExposes([_numeric('device_temperature')]);
      expect(p.deviceClass, DeviceClass.generic);
    });

    test('a temperature/humidity sensor is climate', () {
      final p = classifyExposes([
        _numeric('temperature', unit: '°C'),
        _numeric('humidity', unit: '%'),
        _numeric('pressure', unit: 'hPa'),
      ]);
      expect(p.deviceClass, DeviceClass.climate);
      expect(p.readings.map((f) => f.property),
          ['temperature', 'humidity', 'pressure']);
    });

    test('a TRV (climate composite) goes to generic in 1.12', () {
      final p = classifyExposes([
        {
          'type': 'climate',
          'features': [
            {'type': 'numeric', 'name': 'local_temperature', 'property': 'local_temperature', 'access': 5},
          ],
        },
        _numeric('temperature'),
      ]);
      expect(p.deviceClass, DeviceClass.generic);
    });

    test('a cover without readable position reports none', () {
      final p = classifyExposes([
        {
          'type': 'cover',
          'features': [
            {'type': 'enum', 'name': 'state', 'property': 'state', 'access': 3, 'values': ['OPEN', 'CLOSE', 'STOP']},
            {'type': 'numeric', 'name': 'position', 'property': 'position', 'access': 2},
          ],
        },
      ]);
      expect(p.deviceClass, DeviceClass.cover);
      expect(DeviceState(p, const {'position': 40}).position, isNull);
    });

    test('contact: true means closed', () {
      final p = classifyExposes([_binary('contact')]);
      expect(p.deviceClass, DeviceClass.contact);
      expect(DeviceState(p, const {'contact': true}).alarm, isTrue);
      expect(DeviceState(p, const {}).alarm, isNull);
    });

    test('a light without brightness is still a light, with no slider', () {
      final p = classifyExposes([
        {
          'type': 'light',
          'features': [
            {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7, 'value_on': 'ON', 'value_off': 'OFF'},
          ],
        },
      ]);
      expect(p.deviceClass, DeviceClass.light);
      expect(p.brightness, isNull);
    });
  });

  group('commands', () {
    final bulb = classifyExposes(_j(_bulbExposes));

    test('toggle falls back to on/off without value_toggle', () {
      const f = DeviceFeature(
          type: 'binary', property: 'state', valueOn: 'ON', valueOff: 'OFF');
      expect(DeviceCommand.toggle(f, true), {'state': 'OFF'});
      expect(DeviceCommand.toggle(f, null), {'state': 'ON'});
    });

    test('brightness percent maps onto value_min..value_max', () {
      expect(DeviceCommand.brightnessPercent(bulb.brightness!, 50),
          {'brightness': 127});
    });

    test('kelvin converts to mired and clamps to the range', () {
      expect(DeviceCommand.kelvin(bulb.colorTemp!, 4000), {'color_temp': 250});
      expect(DeviceCommand.kelvin(bulb.colorTemp!, 1000), {'color_temp': 500});
    });

    test('color is sent as hex', () {
      expect(DeviceCommand.color(0xFF8800), {
        'color': {'hex': '#ff8800'},
      });
    });

    test('refresh asks only for gettable readable properties', () {
      expect(DeviceCommand.refresh(bulb)?.keys,
          containsAll(['state', 'brightness', 'color_temp', 'color']));
      expect(DeviceCommand.refresh(bulb)?.keys, isNot(contains('effect')));
    });
  });

  test('a profile round-trips through the tile config JSON', () {
    final p = classifyExposes(_j(_bulbExposes));
    final back = DeviceProfile.fromJson(json.decode(json.encode(p.toJson())));
    expect(back.deviceClass, DeviceClass.colorLight);
    expect(back.brightness?.max, 254);
    expect(back.switches.single.valueToggle, 'TOGGLE');
  });

  test('colour conversions land on the expected hues', () {
    expect(hsToRgb(0, 100), 0xFF0000);
    expect(hsToRgb(120, 100), 0x00FF00);
    final white = xyToRgb(0.3127, 0.3290);
    expect(white >> 16, greaterThan(240));
    expect(white & 0xFF, greaterThan(240));
  });
}
