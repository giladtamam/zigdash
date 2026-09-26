import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/daos/section_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/onboarding/demo_home.dart';
import 'package:zigdash/features/onboarding/demo_service.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';

void main() {
  test('the demo is sectioned device tiles with current values', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final c = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
    ]);
    addTearDown(c.dispose);

    final connId = await c.read(demoServiceProvider.notifier).activate();

    final dash = (await db.select(db.dashboards).get())
        .singleWhere((d) => d.connectionId == connId);
    final sections = await SectionDao(db).getByDashboard(dash.id);
    expect(sections.map((s) => s.name),
        ['Lights', 'Switches and covers', 'Sensors']);
    final tiles = await PanelDao(db).getByDashboard(dash.id);
    expect(tiles.where((p) => p.type == PanelType.device), hasLength(8));
    expect(tiles.where((p) => p.type == PanelType.reading), hasLength(1));
    expect(tiles.every((p) => p.sectionId != null), isTrue);

    // Every device tile's topic has a demo value, and it reads as current.
    final values = {for (final m in demoValues(DateTime(2026))) m.topic: m};
    for (final t in tiles.where((p) => p.type == PanelType.device)) {
      final m = values[t.topicPrefixOverride];
      expect(m, isNotNull, reason: t.name);
      final snap = PanelValueSnapshot.fromMessage(
        message: m!,
        value: m.payload,
        status: MqttStatus.disconnected,
        currentGeneration: 0,
      );
      expect(snap.freshness, PanelFreshness.fresh, reason: t.name);
    }
  });
}
