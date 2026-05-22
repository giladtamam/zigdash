import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/models/device_panel_suggestion.dart';

// Re-use the same fixture used in z2m_device_test.dart
const _bridgeDevicesJson = r'''
[
  {
    "friendly_name": "office_light",
    "type": "Router",
    "definition": {
      "vendor": "IKEA", "model": "LED1545G12",
      "exposes": [
        {
          "type": "light",
          "features": [
            { "type": "binary",  "property": "state",      "value_on": "ON", "value_off": "OFF" },
            { "type": "numeric", "property": "brightness",  "value_min": 0,   "value_max": 254  }
          ]
        }
      ]
    }
  },
  {
    "friendly_name": "kitchen_plug",
    "type": "EndDevice",
    "definition": {
      "vendor": "Tuya", "model": "TS0001",
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
      "vendor": "Somfy", "model": "ZRTSI",
      "exposes": [
        {
          "type": "cover",
          "features": [
            { "type": "binary",  "property": "state",    "value_on": "OPEN",  "value_off": "CLOSE" },
            { "type": "numeric", "property": "position", "value_min": 0,      "value_max": 100    }
          ]
        }
      ]
    }
  },
  {
    "friendly_name": "door_sensor",
    "type": "EndDevice",
    "definition": {
      "vendor": "Aqara", "model": "MCCGQ11LM",
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
      "vendor": "Acme", "model": "XY-99",
      "exposes": [
        { "type": "enum", "property": "mode", "values": ["auto", "manual", "off"] }
      ]
    }
  },
  {
    "friendly_name": "battery_only",
    "type": "EndDevice",
    "definition": {
      "vendor": "Generic", "model": "SN-01",
      "exposes": [
        { "type": "numeric", "property": "battery", "unit": "%" },
        { "type": "numeric", "property": "linkquality" }
      ]
    }
  },
  {
    "friendly_name": "Coordinator",
    "type": "Coordinator"
  }
]
''';

void main() {
  late List<Z2mDevice> devices;

  setUp(() {
    devices = parseBridgeDevices(_bridgeDevicesJson);
  });

  group('parseBridgeDevices (integration check for suggestion tests)', () {
    test('excludes Coordinator; 6 devices total', () {
      expect(devices.length, 6);
    });
  });

  group('suggestPanel', () {
    PanelSuggestion suggest(String name) =>
        suggestPanel(devices.firstWhere((d) => d.friendlyName == name));

    // Helper to also test topic fields
    PanelSuggestion suggestWithBase(String name, String base) =>
        suggestPanel(devices.firstWhere((d) => d.friendlyName == name), base: base);

    test('office_light → slider with brightness preset', () {
      final s = suggest('office_light');
      expect(s.type, PanelType.slider);
      expect(s.sliderIsBrightness, isTrue);
      expect(s.jsonPath, 'brightness');
      expect(s.publishTopicSuffix, 'set');
      expect(s.subscribeTopicSuffix, '');
    });

    test('living_cover → cover panel', () {
      final s = suggest('living_cover');
      expect(s.type, PanelType.cover);
      expect(s.jsonPath, 'position');
      expect(s.publishTopicSuffix, 'set');
      expect(s.subscribeTopicSuffix, '');
    });

    test('kitchen_plug → toggle panel', () {
      final s = suggest('kitchen_plug');
      expect(s.type, PanelType.toggle);
      expect(s.jsonPath, 'state');
      expect(s.onMatch, 'ON');
      expect(s.publishTopicSuffix, 'set');
      expect(s.subscribeTopicSuffix, '');
    });

    test('door_sensor → led panel for contact (binary sensor wins over battery)', () {
      final s = suggest('door_sensor');
      expect(s.type, PanelType.led);
      expect(s.jsonPath, 'contact');
      expect(s.onMatch, 'true');
      expect(s.publishTopicSuffix, '');
      expect(s.subscribeTopicSuffix, '');
    });

    test('mode_switch → combo panel', () {
      final s = suggest('mode_switch');
      expect(s.type, PanelType.combo);
      expect(s.jsonPath, 'mode');
      expect(s.publishTopicSuffix, 'set');
    });

    test('battery_only → progress panel with % unit', () {
      final s = suggest('battery_only');
      expect(s.type, PanelType.progress);
      expect(s.jsonPath, 'battery');
      expect(s.unit, '%');
      expect(s.publishTopicSuffix, '');
    });

    test('topicPrefixOverride uses base + friendly_name', () {
      final s = suggestWithBase('office_light', 'zigbee2mqtt');
      expect(s.topicPrefixOverride, 'zigbee2mqtt/office_light');
      expect(s.name, 'office_light');
    });

    test('topicPrefixOverride respects custom base', () {
      final s = suggestWithBase('kitchen_plug', 'myhome/z2m');
      expect(s.topicPrefixOverride, 'myhome/z2m/kitchen_plug');
    });

    test('fallback device → textLog panel', () {
      // Build a device with no meaningful exposes
      const bare = Z2mDevice(
        friendlyName: 'unknown_thing',
        type: 'EndDevice',
        exposes: [],
      );
      final s = suggestPanel(bare);
      expect(s.type, PanelType.textLog);
      expect(s.jsonPath, isNull);
      expect(s.publishTopicSuffix, '');
    });

    test('linkquality-only → progress with no unit', () {
      // Build a device with only linkquality
      const lq = Z2mDevice(
        friendlyName: 'lq_device',
        type: 'EndDevice',
        exposes: [
          Z2mExpose(type: 'numeric', property: 'linkquality'),
        ],
      );
      final s = suggestPanel(lq);
      expect(s.type, PanelType.progress);
      expect(s.jsonPath, 'linkquality');
      expect(s.unit, isNull);
    });
  });
}
