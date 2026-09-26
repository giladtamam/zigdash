import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/uuid.dart';
import '../../data/database/database.dart';
import '../../data/database/daos/connection_dao.dart';
import '../../data/database/daos/dashboard_dao.dart';
import '../../data/database/daos/panel_dao.dart';
import '../../data/database/daos/section_dao.dart';
import '../../data/repositories/panel_repo.dart';
import '../../data/repositories/section_repo.dart';
import '../../core/l10n/app_l10n.dart';
import '../../data/database/tables/connections.dart';
import '../../features/settings/providers/settings_controller.dart';
import 'demo_home.dart';

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
      iconCodepoint: 0xe318, // Icons.home
      createdAt: now,
      updatedAt: now,
    ));

    await seedDemoDashboard(
      dashboardId: dashId,
      sections: SectionRepo(SectionDao(db)),
      panels: PanelRepo(PanelDao(db)),
      l10n: appL10n(ref.read(settingsControllerProvider).locale),
    );

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
}

final demoServiceProvider = NotifierProvider<DemoService, bool>(
  DemoService.new,
);
