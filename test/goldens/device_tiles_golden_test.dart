import 'dart:async';
import 'dart:convert';

import 'package:alchemist/alchemist.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/alerts/alerts_service.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/features/scenes/scenes_providers.dart';
import 'package:zigdash/features/dashboards/screens/dashboards_screen.dart';
import 'package:zigdash/features/devices/device_health.dart';
import 'package:zigdash/features/devices/devices_providers.dart';
import 'package:zigdash/features/devices/screens/device_page.dart';
import 'package:zigdash/features/devices/z2m_bridge.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/home/home_shell.dart';
import 'package:zigdash/features/home/list_detail.dart';
import 'package:zigdash/features/panels/screens/panel_form_screen.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/features/settings/screens/home_settings_screen.dart';
import 'package:zigdash/features/settings/screens/language_screen.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/dashboards/edit_mode.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/features/devices/device_registry.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
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
  iconCodepoint: 0xe318,
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

class _Editing extends EditModeController {
  @override
  String? build() => 'd1';
}

List<Override> _editOverrides() => [
      ..._overrides(),
      editModeProvider.overrideWith(_Editing.new),
      unassignedDevicesProvider.overrideWith((ref, _) => const AsyncValue.data([
            Z2mDevice(
                friendlyName: 'new_plug', type: 'Router', ieeeAddress: '0x77'),
          ])),
    ];

// Tablet and medium windows (devices-tablet-1.13.md §7): the rail, dashboard
// chips, 4 or 3 columns, Edit mode with the header buttons, and Devices and
// Scenes as list-detail.

late SharedPreferences _prefs;

final _homes = [
  Connection(
    id: 'c1',
    name: 'My Home',
    host: '192.168.68.55',
    port: 1883,
    protocol: MqttProtocol.tcp,
    keepAliveSeconds: 60,
    autoConnect: true,
    createdAt: _stamp,
    updatedAt: _stamp,
  ),
];

final _upstairs = Dashboard(
  id: 'd2',
  connectionId: 'c1',
  name: 'Upstairs',
  topicPrefix: 'zigbee2mqtt',
  colorSeed: 0xFF3B82F6,
  iconCodepoint: 0xe318,
  locked: false,
  sortOrder: 1,
  createdAt: _stamp,
  updatedAt: _stamp,
);

final _devices = [
  for (final (id, name, _, _, exposes, _) in _tiles)
    Z2mDevice(
      friendlyName: name,
      type: 'Router',
      ieeeAddress: '0x$id',
      rawExposes: exposes,
      powerSource: id == 'door' || id == 'motion' ? 'Battery' : 'Mains (single phase)',
    ),
];

final _health = deviceHealthFrom(_devices, states: {
  for (final (_, name, _, _, _, state) in _tiles)
    if (state != null)
      name: (payload: json.encode({...state, 'linkquality': 96}), at: _stamp),
});

class _Idle extends EditModeController {
  @override
  String? build() => null;
}

List<Override> _shellOverrides({bool editing = false}) => [
      ..._overrides(),
      appDatabaseProvider.overrideWith((ref) {
        final db = AppDatabase.test(NativeDatabase.memory());
        ref.onDispose(db.close);
        return db;
      }),
      sharedPreferencesProvider.overrideWithValue(_prefs),
      editModeProvider.overrideWith(editing ? _Editing.new : _Idle.new),
      connectionsStreamProvider.overrideWith((ref) => Stream.value(_homes)),
      connectionByIdProvider.overrideWith((ref, _) async => _homes.single),
      dashboardsForConnectionProvider
          .overrideWith((ref, _) => Stream.value([_dashboard, _upstairs])),
      mqttManagerProvider.overrideWith((ref, _) => Completer<Never>().future),
      // No alerts: the dashboard's paused banner stays hidden (and no drift
      // stream is opened for it).
      alertsConfigProvider.overrideWith((ref, _) => Stream.value(null)),
      bridgeDevicesStreamProvider.overrideWith((ref, _) => Stream.value(_devices)),
      deviceHealthProvider.overrideWith((ref, _) => Stream.value(_health)),
      availabilityConfigProvider.overrideWith(
          (ref, _) => Stream.value(AvailabilityConfig.unknown)),
      batteryWatchProvider.overrideWith((ref, _) {}),
      batteryAlertsProvider.overrideWith((ref, _) => Stream.value(const {})),
      homeDeviceSyncProvider.overrideWith((ref, _) {}),
      linkedIeeesProvider.overrideWith(
          (ref, _) => Stream.value({for (final d in _devices) d.ieeeAddress!})),
      unassignedDevicesProvider.overrideWith((ref, _) => editing
          ? const AsyncValue.data([
              Z2mDevice(friendlyName: 'new_plug', type: 'Router', ieeeAddress: '0x77'),
            ])
          : const AsyncValue.data([])),
      unassignedCountProvider.overrideWith((ref, _) => const AsyncValue.data(0)),
      deviceTilesProvider.overrideWith((ref, key) => Stream.value([
            for (final p in _panels)
              if (p.deviceIeee == key.ieee)
                (p, _dashboard, _sections.firstWhere((x) => x.id == p.sectionId)),
          ])),
      scenesForConnectionProvider
          .overrideWith((ref, _) => Stream.value(const <Scene>[])),
    ];

const _medium = Size(700, 1000);
const _tabletVariants = [
  ...tabletMatrix,
  GoldenVariant(name: 'medium light en', size: _medium),
];

Widget _home(String location, Widget child) =>
    HomeShell(connectionId: 'c1', location: location, child: child);

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  goldenTest(
    'tablet dashboard with the rail and chips',
    fileName: 'dashboard_shell_tablet',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: _tabletVariants,
      overrides: _shellOverrides,
      screen: () => _home('/connections/c1/dashboards',
          const DashboardsScreen(connectionId: 'c1')),
    ),
  );

  goldenTest(
    'tablet edit mode',
    fileName: 'edit_mode_tablet',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: tabletMatrix.take(2).toList(),
      overrides: () => _shellOverrides(editing: true),
      screen: () => _home('/connections/c1/dashboards',
          const DashboardsScreen(connectionId: 'c1')),
    ),
  );

  goldenTest(
    'tablet devices list-detail',
    fileName: 'devices_tablet',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: tabletMatrix,
      overrides: _shellOverrides,
      screen: () => _home('/connections/c1/devices',
          const DevicesDestination(connectionId: 'c1', initialIeee: '0xmotion')),
    ),
  );

  goldenTest(
    'tablet scenes list-detail',
    fileName: 'scenes_tablet',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: tabletMatrix.take(1).toList(),
      overrides: _shellOverrides,
      screen: () => _home('/connections/c1/scenes',
          const ScenesDestination(connectionId: 'c1')),
    ),
  );

  goldenTest(
    'device page',
    fileName: 'device_page_phone',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: const [
        GoldenVariant(name: 'color light, light en', size: _tall),
        GoldenVariant(name: 'color light, light he', size: _tall, locale: Locale('he')),
        GoldenVariant(name: 'color light, en 2x', size: Size(412, 2600), textScale: 2),
      ],
      overrides: _shellOverrides,
      screen: () => const DevicePage(connectionId: 'c1', ieee: '0xbulb'),
    ),
  );

  goldenTest(
    'device page, low battery, dark',
    fileName: 'device_page_battery_phone',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: const [
        GoldenVariant(name: 'dark en', size: phone, brightness: Brightness.dark),
        GoldenVariant(
            name: 'dark he', size: phone, brightness: Brightness.dark, locale: Locale('he')),
      ],
      overrides: _shellOverrides,
      screen: () => const DevicePage(connectionId: 'c1', ieee: '0xmotion'),
    ),
  );

  goldenTest(
    'settings: a home',
    fileName: 'home_page_phone',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: phoneMatrix.take(3).toList(),
      overrides: _shellOverrides,
      screen: () => const HomeSettingsScreen(connectionId: 'c1'),
    ),
  );

  goldenTest(
    'settings: the language picker',
    fileName: 'language_phone',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: phoneMatrix.take(3).toList(),
      overrides: _shellOverrides,
      screen: () => const LanguageScreen(),
    ),
  );

  goldenTest(
    'custom MQTT tile form',
    fileName: 'custom_form_phone',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: [...phoneMatrix.take(3), phoneMatrix[4]],
      overrides: () => [
        ..._shellOverrides(),
        dashboardRepoProvider.overrideWithValue(_OneDashboard()),
      ],
      screen: () => const PanelFormScreen(
          connectionId: 'c1', dashboardId: 'd1', initialType: PanelType.toggle),
    ),
  );

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

  goldenTest(
    'edit mode',
    fileName: 'edit_mode_phone',
    pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
    builder: () => goldenMatrix(
      variants: const [
        GoldenVariant(name: 'light en', size: _tall),
        GoldenVariant(name: 'dark en', size: _tall, brightness: Brightness.dark),
        GoldenVariant(name: 'light he', size: _tall, locale: Locale('he')),
      ],
      overrides: _editOverrides,
      screen: () => Scaffold(
        appBar: AppBar(title: const Text('Editing')),
        body: PanelGrid(connectionId: 'c1', dashboard: _dashboard),
      ),
    ),
  );
}

class _OneDashboard implements DashboardRepo {
  @override
  Future<Dashboard?> getById(String id) async => _dashboard;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
