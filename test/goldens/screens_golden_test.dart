import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/panel_grid.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/features/settings/screens/settings_screen.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

import 'golden_harness.dart';

// Baselines of the 1.9.x UI, recorded on Flutter 3.47.5 before any redesign
// work, so each redesign phase is diffed against a known picture.

final _stamp = DateTime(2026, 9, 26);

Panel _panel(String id, String name, PanelType type, PanelWidth width) =>
    Panel(
      id: id,
      dashboardId: 'd1',
      name: name,
      type: type,
      topic: id,
      subscribeTopic: null,
      topicPrefixOverride: null,
      qos: 1,
      retain: false,
      width: width,
      sortOrder: 0,
      config: PanelConfig.defaultFor(type).encode(),
      mergeFlags: 0,
      createdAt: _stamp,
      updatedAt: _stamp,
    );

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

final _panels = [
  _panel('living_light', 'Living room', PanelType.toggle, PanelWidth.small),
  _panel('kitchen_light', 'Kitchen', PanelType.toggle, PanelWidth.small),
  _panel('dimmer', 'Brightness', PanelType.slider, PanelWidth.full),
  _panel('shutter', 'Living room shutter', PanelType.cover, PanelWidth.full),
  _panel('door', 'Front door', PanelType.led, PanelWidth.small),
  _panel('battery', 'Climate battery', PanelType.progress, PanelWidth.small),
  _panel('log', 'Hallway motion', PanelType.textLog, PanelWidth.full),
];

/// Last received value per device. Panels resolve their topic against the
/// dashboard prefix, so values are matched on the last topic segment.
const _values = <String, Object?>{
  'living_light': 'ON',
  'kitchen_light': 'OFF',
  'dimmer': 180,
  'shutter': 40,
  'door': 'ON',
  'battery': 23,
  'log': 'Motion detected',
};

Object? _valueFor(String topic) {
  for (final e in _values.entries) {
    if (topic == e.key || topic.endsWith('/${e.key}') ||
        topic.contains('/${e.key}/')) {
      return e.value;
    }
  }
  return null;
}

List<Override> _dashboardOverrides() => [
  sectionsForDashboardProvider.overrideWith(
    (ref, _) => Stream<List<Section>>.value(const []),
  ),
  panelsForDashboardProvider.overrideWith(
    (ref, _) => Stream<List<Panel>>.value(_panels),
  ),
  connectionStatusProvider.overrideWith(
    (ref, _) => Stream.value(MqttStatus.connected),
  ),
  panelValueSnapshotProvider.overrideWith(
    (ref, key) => Stream.value(
      PanelValueSnapshot(
        value: _valueFor(key.topic),
        receivedAt: _stamp,
        connectionGeneration: 1,
        freshness: PanelFreshness.fresh,
      ),
    ),
  ),
  panelValueProvider.overrideWith(
    (ref, key) => Stream<Object?>.value(_valueFor(key.topic)),
  ),
];

Widget _dashboardScreen() => Scaffold(
  appBar: AppBar(title: Text(_dashboard.name)),
  body: PanelGrid(connectionId: 'c1', dashboard: _dashboard),
);

late SharedPreferences _prefs;

List<Override> _settingsOverrides() => [
  sharedPreferencesProvider.overrideWithValue(_prefs),
];

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  group('dashboard tiles', () {
    goldenTest(
      'phone',
      fileName: 'dashboard_phone',
      // Streams resolve on the first frames; a fixed pump avoids waiting on
      // any indeterminate progress animation.
      pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
      builder: () => goldenMatrix(
        variants: phoneMatrix,
        overrides: _dashboardOverrides,
        screen: _dashboardScreen,
      ),
    );
    goldenTest(
      'tablet',
      fileName: 'dashboard_tablet',
      // Streams resolve on the first frames; a fixed pump avoids waiting on
      // any indeterminate progress animation.
      pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
      builder: () => goldenMatrix(
        variants: tabletMatrix,
        overrides: _dashboardOverrides,
        screen: _dashboardScreen,
      ),
    );
    goldenTest(
      'dynamic color',
      fileName: 'dashboard_dynamic_color',
      // Streams resolve on the first frames; a fixed pump avoids waiting on
      // any indeterminate progress animation.
      pumpBeforeTest: pumpNTimes(10, const Duration(milliseconds: 50)),
      builder: () => goldenMatrix(
        variants: dynamicColorMatrix,
        overrides: _dashboardOverrides,
        screen: _dashboardScreen,
      ),
    );
  });

  group('settings', () {
    goldenTest(
      'phone',
      fileName: 'settings_phone',
      builder: () => goldenMatrix(
        variants: phoneMatrix,
        overrides: _settingsOverrides,
        screen: () => const SettingsScreen(),
      ),
    );
    goldenTest(
      'tablet',
      fileName: 'settings_tablet',
      builder: () => goldenMatrix(
        variants: tabletMatrix,
        overrides: _settingsOverrides,
        screen: () => const SettingsScreen(),
      ),
    );
  });
}
