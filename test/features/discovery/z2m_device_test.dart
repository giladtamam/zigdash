import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';

// Fixture: a realistic bridge/devices payload with:
//   - an IKEA light (Router, light expose with state+brightness)
//   - an on/off plug (EndDevice, switch expose with binary state)
//   - a cover (EndDevice, cover expose with state+position)
//   - a contact sensor (EndDevice, top-level binary contact + numeric battery + linkquality)
//   - an enum-only device (EndDevice, top-level enum expose)
//   - a Coordinator (should be excluded)
const _bridgeDevicesJson = r'''
[
  {
    "friendly_name": "office_light",
    "type": "Router",
    "definition": {
      "vendor": "IKEA",
      "model": "LED1545G12",
      "exposes": [
        {
          "type": "light",
          "features": [
            { "type": "binary", "property": "state", "value_on": "ON", "value_off": "OFF" },
            { "type": "numeric", "property": "brightness", "value_min": 0, "value_max": 254 }
          ]
        }
      ]
    }
  },
  {
    "friendly_name": "kitchen_plug",
    "type": "EndDevice",
    "definition": {
      "vendor": "Tuya",
      "model": "TS0001",
      "exposes": [
        {
          "type": "switch",
          "features": [
            { "type": "binary", "property": "state", "value_on": "ON", "value_off": "OFF" }
          ]
        }
      ]
    }
  },
  {
    "friendly_name": "living_cover",
    "type": "Router",
    "definition": {
      "vendor": "Somfy",
      "model": "ZRTSI",
      "exposes": [
        {
          "type": "cover",
          "features": [
            { "type": "binary", "property": "state", "value_on": "OPEN", "value_off": "CLOSE" },
            { "type": "numeric", "property": "position", "value_min": 0, "value_max": 100 }
          ]
        }
      ]
    }
  },
  {
    "friendly_name": "door_sensor",
    "type": "EndDevice",
    "definition": {
      "vendor": "Aqara",
      "model": "MCCGQ11LM",
      "exposes": [
        { "type": "binary",  "property": "contact",     "value_on": true,  "value_off": false },
        { "type": "numeric", "property": "battery",     "unit": "%"         },
        { "type": "numeric", "property": "linkquality"                       }
      ]
    }
  },
  {
    "friendly_name": "mode_switch",
    "type": "EndDevice",
    "definition": {
      "vendor": "Acme",
      "model": "XY-99",
      "exposes": [
        { "type": "enum", "property": "mode", "values": ["auto", "manual", "off"] }
      ]
    }
  },
  {
    "friendly_name": "Coordinator",
    "type": "Coordinator"
  }
]
''';

// Malformed JSON
const _badJson = 'not json at all {{}}';

// Device with no definition field
const _noDefinitionJson = r'''
[
  { "friendly_name": "bare_device", "type": "EndDevice" }
]
''';

void main() {
  group('parseBridgeDevices', () {
    test('excludes Coordinator; returns 5 devices', () {
      final devices = parseBridgeDevices(_bridgeDevicesJson);
      expect(devices.length, 5);
      expect(devices.any((d) => d.type == 'Coordinator'), isFalse);
    });

    test('parses office_light fields correctly', () {
      final devices = parseBridgeDevices(_bridgeDevicesJson);
      final light = devices.firstWhere((d) => d.friendlyName == 'office_light');
      expect(light.vendor, 'IKEA');
      expect(light.model, 'LED1545G12');
      expect(light.type, 'Router');
    });

    test('flattens composite light exposes into Z2mExpose list', () {
      final devices = parseBridgeDevices(_bridgeDevicesJson);
      final light = devices.firstWhere((d) => d.friendlyName == 'office_light');
      // composite light expose itself + 2 features flattened
      // We keep the parent type too so suggestPanel can match on "light"
      expect(light.exposes.any((e) => e.type == 'light'), isTrue);
      expect(light.exposes.any((e) => e.property == 'brightness'), isTrue);
      expect(light.exposes.any((e) => e.property == 'state' && e.type == 'binary'), isTrue);
    });

    test('parses top-level binary expose with valueOn', () {
      final devices = parseBridgeDevices(_bridgeDevicesJson);
      final sensor = devices.firstWhere((d) => d.friendlyName == 'door_sensor');
      final contact = sensor.exposes.firstWhere((e) => e.property == 'contact');
      expect(contact.type, 'binary');
      expect(contact.valueOn, 'true'); // boolean true → "true"
    });

    test('parses numeric expose with unit', () {
      final devices = parseBridgeDevices(_bridgeDevicesJson);
      final sensor = devices.firstWhere((d) => d.friendlyName == 'door_sensor');
      final battery = sensor.exposes.firstWhere((e) => e.property == 'battery');
      expect(battery.type, 'numeric');
      expect(battery.unit, '%');
    });

    test('parses enum expose property', () {
      final devices = parseBridgeDevices(_bridgeDevicesJson);
      final mode = devices.firstWhere((d) => d.friendlyName == 'mode_switch');
      final modeExpose = mode.exposes.firstWhere((e) => e.property == 'mode');
      expect(modeExpose.type, 'enum');
    });

    test('device with no definition yields empty exposes, no crash', () {
      final devices = parseBridgeDevices(_noDefinitionJson);
      expect(devices.length, 1);
      expect(devices.first.friendlyName, 'bare_device');
      expect(devices.first.exposes, isEmpty);
      expect(devices.first.vendor, isNull);
      expect(devices.first.model, isNull);
    });

    test('malformed JSON returns empty list without throwing', () {
      final devices = parseBridgeDevices(_badJson);
      expect(devices, isEmpty);
    });

    test('empty array returns empty list', () {
      final devices = parseBridgeDevices('[]');
      expect(devices, isEmpty);
    });
  });
}
