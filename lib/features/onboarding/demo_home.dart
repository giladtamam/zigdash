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
  (name: 'Front door', group: 2, exposes: [_binary('contact'), _battery], state: {'contact': true, 'battery': 91}),
  (name: 'Hallway motion', group: 2, exposes: [_binary('occupancy'), _battery], state: {'occupancy': false, 'battery': 64}),
  (name: 'Laundry leak', group: 2, exposes: [_binary('water_leak'), _battery], state: {'water_leak': false, 'battery': 78}),
];

String _topic(String name) => '$demoBase/${name.toLowerCase().replaceAll(' ', '_')}';

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
        ieeeAddress: '0xdemo${order.toString().padLeft(12, '0')}',
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

/// The demo's device states, as current values for its tiles.
List<MqttRxMessage> demoValues(DateTime now) => [
      for (final d in _devices)
        MqttRxMessage(
          topic: _topic(d.name),
          payload: json.encode(d.state),
          receivedAt: now,
          connectionGeneration: demoGeneration,
        ),
    ];
