import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/uuid.dart';
import '../../data/database/database.dart';
import '../../data/database/daos/connection_dao.dart';
import '../../data/database/daos/dashboard_dao.dart';
import '../../data/database/daos/panel_dao.dart';
import '../../data/database/tables/connections.dart';
import '../../data/database/tables/panels.dart';
import '../../features/panels/models/panel_config.dart';
import '../../features/settings/providers/settings_controller.dart';

/// Host of the demo home, which never connects to a real broker.
const demoHost = 'demo.local';

/// Whether a connection with [host] is the demo home.
bool isDemoConnection(String? host) => host == demoHost;

class DemoService extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).getBool('demo_mode') ?? false;
  }

  /// Creates the demo home and returns its connection id.
  Future<String> activate() async {
    final db = ref.read(appDatabaseProvider);
    final connDao = ConnectionDao(db);
    // Reuse an existing demo home rather than seeding a second one.
    for (final c in await connDao.watchAll().first) {
      if (isDemoConnection(c.host)) {
        await ref.read(sharedPreferencesProvider).setBool('demo_mode', true);
        state = true;
        return c.id;
      }
    }
    final dashDao = DashboardDao(db);
    final panelDao = PanelDao(db);
    final now = DateTime.now();

    final connId = newId();
    await connDao.insertRow(ConnectionsCompanion.insert(
      id: connId,
      name: 'Demo Smart Home',
      host: demoHost,
      port: 1883,
      protocol: MqttProtocol.tcp,
      autoConnect: const Value(false),
      createdAt: now,
      updatedAt: now,
    ));

    final dashId = newId();
    await dashDao.insertRow(DashboardsCompanion.insert(
      id: dashId,
      connectionId: connId,
      name: 'My Home',
      colorSeed: 0xFF3B82F6,
      iconCodepoint: 0xE88A,
      createdAt: now,
      updatedAt: now,
    ));

    final panels = <PanelsCompanion>[
      _panel(dashId, 'Living Room Light', PanelType.toggle, 'light/living',
          PanelConfig.defaultFor(PanelType.toggle), sortOrder: 0),
      _panel(
          dashId,
          'Brightness',
          PanelType.slider,
          'light/living',
          PanelConfig.defaultFor(PanelType.slider),
          sortOrder: 1,
          width: PanelWidth.small),
      _panel(dashId, 'Living Room Cover', PanelType.cover, 'cover/living',
          PanelConfig.defaultFor(PanelType.cover), sortOrder: 2),
      _panel(
          dashId,
          'Front Door',
          PanelType.led,
          'contact/door',
          const LedConfig(onMatch: 'true', onLabel: 'Open', offLabel: 'Closed'),
          sortOrder: 3,
          width: PanelWidth.small),
      _panel(dashId, 'Zigbee Router', PanelType.nodeStatus, 'router/status',
          PanelConfig.defaultFor(PanelType.nodeStatus),
          sortOrder: 4,
          width: PanelWidth.small),
      _panel(
          dashId,
          'Battery',
          PanelType.progress,
          'sensor/battery',
          const ProgressConfig(min: 0, max: 100, unit: '%'),
          sortOrder: 5,
          width: PanelWidth.small),
      _panel(
          dashId,
          'Fan Mode',
          PanelType.multiState,
          'fan/mode',
          const OptionsConfig(
            jsonPath: 'mode',
            options: [
              SelectOption(label: 'Off', payload: 'OFF', match: 'OFF'),
              SelectOption(label: 'Low', payload: 'LOW', match: 'LOW'),
              SelectOption(label: 'High', payload: 'HIGH', match: 'HIGH'),
            ],
          ),
          sortOrder: 6),
      _panel(dashId, 'Entry Button', PanelType.button, 'button/entry',
          PanelConfig.defaultFor(PanelType.button),
          sortOrder: 7,
          width: PanelWidth.small),
      _panel(dashId, 'Event Log', PanelType.textLog, 'system/log',
          PanelConfig.defaultFor(PanelType.textLog), sortOrder: 8),
    ];

    for (final p in panels) {
      await panelDao.insertRow(p);
    }

    await ref.read(sharedPreferencesProvider).setBool('demo_mode', true);
    await ref.read(sharedPreferencesProvider).setBool('onboarding_complete', true);
    state = true;
    return connId;
  }

  Future<void> deactivate() async {
    final db = ref.read(appDatabaseProvider);
    final connDao = ConnectionDao(db);
    final connections = await connDao.watchAll().first;

    for (final c in connections) {
      if (isDemoConnection(c.host)) {
        await connDao.deleteById(c.id);
      }
    }

    await ref.read(sharedPreferencesProvider).setBool('demo_mode', false);
    state = false;
  }

  PanelsCompanion _panel(
    String dashId,
    String name,
    PanelType type,
    String topic,
    PanelConfig config, {
    int sortOrder = 0,
    PanelWidth width = PanelWidth.full,
  }) {
    final now = DateTime.now();
    return PanelsCompanion.insert(
      id: newId(),
      dashboardId: dashId,
      name: name,
      type: type,
      topic: topic,
      width: width,
      sortOrder: Value(sortOrder),
      config: config.encode(),
      createdAt: now,
      updatedAt: now,
    );
  }
}

final demoServiceProvider = NotifierProvider<DemoService, bool>(
  DemoService.new,
);
