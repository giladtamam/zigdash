import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/router/last_dashboard_store.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/features/onboarding/demo_service.dart';
import 'package:zigdash/features/onboarding/first_run.dart';
import 'package:zigdash/features/onboarding/onboarding_provider.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

void main() {
  late ProviderContainer c;
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.test(NativeDatabase.memory());
    c = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
    ]);
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  test('a fresh install needs setup', () {
    expect(c.read(onboardingProvider).needsOnboarding, isTrue);
  });

  // First-run decision: the demo is offered from the none-found and no-Z2M
  // outcomes and is persistent but marked.
  test('trying the demo ends first run and opens the demo home', () async {
    final id = await c.read(firstRunProvider).startDemo();

    expect(c.read(onboardingProvider).isDemo, isTrue);
    expect(c.read(onboardingProvider).needsOnboarding, isFalse);
    expect(c.read(lastDashboardStoreProvider).startLocation,
        '/connections/$id/dashboards');
    final hosts = (await ConnectionDao(db).watchAll().first).map((x) => x.host);
    expect(hosts, ['demo.local']);
  });

  test('trying the demo twice keeps a single demo home', () async {
    final first = await c.read(firstRunProvider).startDemo();
    final second = await c.read(firstRunProvider).startDemo();

    expect(second, first);
    final hosts = (await ConnectionDao(db).watchAll().first).map((x) => x.host);
    expect(hosts, ['demo.local']);
  });

  // First-run decision: completing real setup deletes the demo connection.
  test('finishing first run from demo removes the demo home and opens the '
      'new one', () async {
    await c.read(demoServiceProvider.notifier).activate();
    await c.read(onboardingProvider.notifier).enableDemo();
    final realId = await _insertConnection(db, host: '192.168.1.20');

    await c.read(firstRunProvider).finish(realId);

    final hosts =
        (await ConnectionDao(db).watchAll().first).map((x) => x.host).toList();
    expect(hosts, ['192.168.1.20']);
    expect(c.read(demoServiceProvider), isFalse);
    expect(c.read(onboardingProvider).isDemo, isFalse);
    expect(c.read(onboardingProvider).needsOnboarding, isFalse);
    expect(c.read(lastDashboardStoreProvider).startLocation,
        '/connections/$realId/dashboards');
  });

  test('finishing first run without a demo just completes it', () async {
    final realId = await _insertConnection(db, host: '10.0.0.2');
    await c.read(firstRunProvider).finish(realId);

    expect(c.read(onboardingProvider).needsOnboarding, isFalse);
    expect(c.read(lastDashboardStoreProvider).startLocation,
        '/connections/$realId/dashboards');
  });
}

Future<String> _insertConnection(AppDatabase db, {required String host}) async {
  final now = DateTime(2026, 9, 26);
  const id = 'real-home';
  await db.into(db.connections).insert(ConnectionsCompanion.insert(
        id: id,
        name: 'Home',
        host: host,
        port: 1883,
        protocol: MqttProtocol.tcp,
        createdAt: now,
        updatedAt: now,
      ));
  return id;
}
