import 'dart:convert';

import '../../data/database/tables/panels.dart';
import '../../data/repositories/panel_repo.dart';
import '../../data/repositories/section_repo.dart';
import '../../l10n/app_localizations.dart';
import '../../mqtt/mqtt_manager.dart';
import '../devices/device_tiles.dart';
import '../discovery/models/z2m_device.dart';
import '../panels/models/panel_config.dart';

/// The demo home's devices (docs/design/dashboard-1.12.md §9): one of each
/// class, in the sections setup would make, with values that look like a
/// lived-in home. The demo never connects.
const demoBase = 'zigbee2mqtt';

/// Messages carrying this generation are demo values: shown as current,
/// never as last known.
const demoGeneration = -2;

Map<String, Object?> _binary(String p, {int access = 1, Object on = true, Object off = false}) =>
    {'type': 'binary', 'name': p, 'property': p, 'access': access, 'value_on': on, 'value_off': off};
Map<String, Object?> _numeric(String p, String unit, {String? category}) =>
    {'type': 'numeric', 'name': p, 'property': p, 'access': 1, 'unit': unit, 'category': ?category};
Map<String, Object?> _light({bool color = false}) => {
      'type': 'light',
      'features': [
        {..._binary('state', access: 7, on: 'ON', off: 'OFF'), 'value_toggle': 'TOGGLE'},
        {'type': 'numeric', 'name': 'brightness', 'property': 'brightness', 'access': 7, 'value_min': 0, 'value_max': 254},
        if (color) ...[
          {'type': 'numeric', 'name': 'color_temp', 'property': 'color_temp', 'access': 7, 'value_min': 142, 'value_max': 500},
          {'type': 'composite', 'name': 'color_xy', 'property': 'color', 'access': 7},
        ],
      ],
    };
final _battery = _numeric('battery', '%', category: 'diagnostic');

typedef _DemoDevice = ({
  String name,
  int group, // 0 lights, 1 switches and covers, 2 sensors
  List<Object?> exposes,
  Map<String, Object?> state,
});

final List<_DemoDevice> _devices = [
  (name: 'Desk lamp', group: 0, exposes: [_light()], state: {'state': 'ON', 'brightness': 178}),
  (
    name: 'Living room bulb',
    group: 0,
    exposes: [_light(color: true)],
    state: {'state': 'ON', 'brightness': 254, 'color_mode': 'color_temp', 'color_temp': 454},
  ),
  (
    name: 'Kitchen plug',
    group: 1,
    exposes: [
      {'type': 'switch', 'features': [_binary('state', access: 7, on: 'ON', off: 'OFF')]},
      _numeric('power', 'W'),
    ],
    state: {'state': 'ON', 'power': 42},
  ),
  (
    name: 'Bedroom blinds',
    group: 1,
    exposes: [
      {
        'type': 'cover',
        'features': [
          {'type': 'enum', 'name': 'state', 'property': 'state', 'access': 3},
          {'type': 'numeric', 'name': 'position', 'property': 'position', 'access': 7},
        ],
      },
    ],
    state: {'state': 'OPEN', 'position': 70},
  ),
  (
    name: 'Living room',
    group: 2,
    exposes: [_numeric('temperature', '°C'), _numeric('humidity', '%'), _battery],
    state: {'temperature': 21.4, 'humidity': 48, 'battery': 87},
  ),
  (name: 'Front door', group: 2, exposes: [_binary('contact'), _battery], state: {'contact': true, 'battery': 15}),
  (name: 'Hallway motion', group: 2, exposes: [_binary('occupancy'), _battery], state: {'occupancy': false, 'battery': 64}),
  (name: 'Laundry leak', group: 2, exposes: [_binary('water_leak'), _battery], state: {'water_leak': false, 'battery': 78}),
];

/// A demo device's topic. Zigbee2MQTT friendly names may hold spaces, and
/// the demo uses them, so the Devices tab reads "Front door".
String _topic(String name) => '$demoBase/$name';

/// The topic demo homes made before 2.0 used ("front_door"). Their tiles
/// still subscribe to it, so the demo keeps publishing values there too.
String _legacyTopic(String name) =>
    '$demoBase/${name.toLowerCase().replaceAll(' ', '_')}';

String _ieee(int order) => '0xdemo${order.toString().padLeft(12, '0')}';

/// Creates the demo dashboard's sections and device tiles.
Future<void> seedDemoDashboard({
  required String dashboardId,
  required SectionRepo sections,
  required PanelRepo panels,
  required AppLocalizations l10n,
}) async {
  final sectionIds = [
    await sections.create(dashboardId: dashboardId, name: l10n.sectionLights),
    await sections.create(
        dashboardId: dashboardId, name: l10n.sectionSwitchesCovers, sortOrder: 1),
    await sections.create(
        dashboardId: dashboardId, name: l10n.sectionSensors, sortOrder: 2),
  ];
  var order = 0;
  for (final d in _devices) {
    final friendly = _topic(d.name).substring(demoBase.length + 1);
    await createDeviceTile(
      panels,
      dashboardId: dashboardId,
      base: demoBase,
      device: Z2mDevice(
        friendlyName: friendly,
        type: 'EndDevice',
        ieeeAddress: _ieee(order),
        rawExposes: d.exposes,
      ),
      name: d.name,
      sectionId: sectionIds[d.group],
      sortOrder: order++,
    );
  }
  await panels.create(
    dashboardId: dashboardId,
    name: 'Kitchen plug power',
    type: PanelType.reading,
    topic: '',
    subscribeTopic: '',
    topicPrefixOverride: _topic('Kitchen plug'),
    sortOrder: order,
    sectionId: sectionIds[2],
    config: const ReadingConfig(jsonPath: 'power', unit: 'W'),
  );
}

/// The demo's device states, as current values for its tiles, and the
/// bridge's device list, so the Devices tab and device pages have the demo
/// devices too.
List<MqttRxMessage> demoValues(DateTime now) {
  MqttRxMessage message(String topic, Object payload) => MqttRxMessage(
        topic: topic,
        payload: json.encode(payload),
        receivedAt: now,
        connectionGeneration: demoGeneration,
      );
  return [
    for (final d in _devices) ...[
      message(_topic(d.name), d.state),
      message(_legacyTopic(d.name), d.state),
      message('${_topic(d.name)}/availability', {'state': 'online'}),
    ],
    // Availability on, so the Devices tab shows every device online.
    message('$demoBase/bridge/info', {
      'config': {
        'availability': {'enabled': true},
      },
    }),
    message('$demoBase/bridge/devices', [
      for (final (i, d) in _devices.indexed)
        {
          'friendly_name': _topic(d.name).substring(demoBase.length + 1),
          'ieee_address': _ieee(i),
          'type': d.group == 2 ? 'EndDevice' : 'Router',
          'supported': true,
          'interview_completed': true,
          'power_source': d.group == 2 ? 'Battery' : 'Mains (single phase)',
          'definition': {'exposes': d.exposes},
        },
    ]),
  ];
}
