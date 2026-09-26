import 'dart:async';
import 'dart:convert';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/features/devices/device_state_refresher.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/panel_grid.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

import 'golden_harness.dart';

// 1.12 device tiles in every class, sectioned as setup generates them
// (docs/design/screens/1.12/tiles.png, interim look).

final _stamp = DateTime(2026, 9, 26);

Map<String, Object?> _binary(String p, {int access = 1, Object on = true, Object off = false}) =>
    {'type': 'binary', 'name': p, 'property': p, 'access': access, 'value_on': on, 'value_off': off};
Map<String, Object?> _numeric(String p, String unit, {String? category}) =>
    {'type': 'numeric', 'name': p, 'property': p, 'access': 1, 'unit': unit, 'category': ?category};
Map<String, Object?> _light({bool color = false}) => {
      'type': 'light',
      'features': [
        _binary('state', access: 7, on: 'ON', off: 'OFF')..['value_toggle'] = 'TOGGLE',
        {'type': 'numeric', 'name': 'brightness', 'property': 'brightness', 'access': 7, 'value_min': 0, 'value_max': 254},
        if (color) ...[
          {'type': 'numeric', 'name': 'color_temp', 'property': 'color_temp', 'access': 7, 'value_min': 142, 'value_max': 500},
          {'type': 'composite', 'name': 'color_xy', 'property': 'color', 'access': 7},
        ],
      ],
    };
final _battery = _numeric('battery', '%', category: 'diagnostic');

typedef _Tile = (String id, String name, String? section, PanelWidth size,
    List<Object?> exposes, Map<String, Object?>? state);

final List<_Tile> _tiles = [
  ('desk', 'Desk lamp', 's1', PanelWidth.small, [_light()], {'state': 'ON', 'brightness': 178}),
  ('hall', 'Hallway', 's1', PanelWidth.small, [_light()], {'state': 'OFF', 'brightness': 254}),
  ('bulb', 'Living room bulb', 's1', PanelWidth.wide, [_light(color: true)],
      {'state': 'ON', 'brightness': 254, 'color_mode': 'color_temp', 'color_temp': 454}),
  ('kitchen', 'Kitchen switch', 's2', PanelWidth.small, [
    {'type': 'switch', 'features': [_binary('state', access: 7, on: 'ON', off: 'OFF')]},
  ], {'state': 'OFF'}),
  ('relay', 'Garden relay', 's2', PanelWidth.small, [
    for (final ep in ['l1', 'l2'])
      {
        'type': 'switch',
        'endpoint': ep,
        'features': [
          {..._binary('state', access: 7, on: 'ON', off: 'OFF'), 'property': 'state_$ep'},
        ],
      },
  ], {'state_l1': 'ON', 'state_l2': 'OFF'}),
  ('blinds', 'Bedroom blinds', 's2', PanelWidth.wide, [
    {
      'type': 'cover',
      'features': [
        {'type': 'enum', 'name': 'state', 'property': 'state', 'access': 3},
        {'type': 'numeric', 'name': 'position', 'property': 'position', 'access': 7},
      ],
    },
  ], {'state': 'CLOSE', 'position': 0}),
  ('climate', 'Living room', 's3', PanelWidth.small,
      [_numeric('temperature', '°C'), _numeric('humidity', '%'), _battery],
      {'temperature': 21.4, 'humidity': 48}),
  ('door', 'Front door', 's3', PanelWidth.small, [_binary('contact'), _battery],
      {'contact': true, 'battery': 91}),
  ('leak', 'Laundry leak', 's3', PanelWidth.small, [_binary('water_leak'), _battery],
      {'water_leak': true, 'battery': 64}),
  ('motion', 'Hallway motion', 's3', PanelWidth.small, [_binary('occupancy'), _battery],
      {'occupancy': false, 'battery': 12}),
  ('unknown', '0xe8ca50de0db10000', 's3', PanelWidth.small,
      [_numeric('pm25', 'µg/m³')], null),
];

final _sections = [
  for (final (i, (id, name)) in [('s1', 'Lights'), ('s2', 'Switches and covers'), ('s3', 'Sensors')].indexed)
    Section(id: id, dashboardId: 'd1', name: name, sortOrder: i, createdAt: _stamp, updatedAt: _stamp),
];

final _panels = [
  for (final (i, (id, name, section, size, exposes, _)) in _tiles.indexed)
    Panel(
      id: id,
      dashboardId: 'd1',
      name: name,
      type: PanelType.device,
      topic: 'set',
      subscribeTopic: '',
      topicPrefixOverride: 'zigbee2mqtt/$id',
      qos: 1,
      retain: false,
      width: size,
      sortOrder: i,
      config: DeviceTileConfig(profile: classifyExposes(exposes)).encode(),
      mergeFlags: 0,
      createdAt: _stamp,
      updatedAt: _stamp,
      sectionId: section,
      deviceIeee: '0x$id',
    ),
  Panel(
    id: 'power',
    dashboardId: 'd1',
    name: 'Washer power',
    type: PanelType.reading,
    topic: '',
    subscribeTopic: '',
    topicPrefixOverride: 'zigbee2mqtt/washer',
    qos: 1,
    retain: false,
    width: PanelWidth.small,
    sortOrder: 99,
    config: const ReadingConfig(jsonPath: 'power', unit: 'W').encode(),
    mergeFlags: 0,
    createdAt: _stamp,
    updatedAt: _stamp,
    sectionId: 's3',
  ),
];

Object? _valueFor(PanelStreamKey key) {
  if (key.topic == 'zigbee2mqtt/washer') return key.jsonPath == 'power' ? 1200 : null;
  for (final (id, _, _, _, _, state) in _tiles) {
    if (key.topic == 'zigbee2mqtt/$id') return state == null ? null : json.encode(state);
  }
  return null;
}

final _dashboard = Dashboard(
  id: 'd1',
  connectionId: 'c1',
  name: 'My Home',
  topicPrefix: 'zigbee2mqtt',
  colorSeed: 0xFF3B82F6,
  iconCodepoint: 0xE88A,
  locked: false,
  sortOrder: 0,
  createdAt: _stamp,
  updatedAt: _stamp,
);

List<Override> _overrides() => [
      sectionsForDashboardProvider.overrideWith((ref, _) => Stream.value(_sections)),
      panelsForDashboardProvider.overrideWith((ref, _) => Stream.value(_panels)),
      connectionStatusProvider.overrideWith((ref, _) => Stream.value(MqttStatus.connected)),
      // No broker: tiles never ask for state in a golden.
      deviceStateRefresherProvider
          .overrideWith((ref, _) => Completer<DeviceStateRefresher>().future),
      panelValueSnapshotProvider.overrideWith((ref, key) => Stream.value(PanelValueSnapshot(
            value: _valueFor(key),
            receivedAt: _stamp,
            connectionGeneration: 1,
            freshness: PanelFreshness.fresh,
          ))),
      panelValueProvider.overrideWith((ref, key) => Stream<Object?>.value(_valueFor(key))),
    ];

const _tall = Size(412, 1500);
const _variants = [
  GoldenVariant(name: 'light en', size: _tall),
  GoldenVariant(name: 'dark en', size: _tall, brightness: Brightness.dark),
  GoldenVariant(name: 'light he', size: _tall, locale: Locale('he')),
  GoldenVariant(name: 'light en 2x', size: Size(412, 2600), textScale: 2),
];

void main() {
  goldenTest(
    'device tiles by class',
    fileName: 'device_tiles_phone',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: _variants,
      overrides: _overrides,
      screen: () => Scaffold(
        appBar: AppBar(title: Text(_dashboard.name)),
        body: PanelGrid(connectionId: 'c1', dashboard: _dashboard),
      ),
    ),
  );
}
