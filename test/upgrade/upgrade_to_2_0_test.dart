import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/theme/dashboard_accent.dart';
import 'package:zigdash/core/utils/material_icon.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

import '../drift/generated/schema.dart';
import '../drift/generated/schema_v5.dart' as v5;

/// Exit check 4 (signal-2.0.md §12): upgrading from 1.9.2 (schema 5, the
/// production build before 1.13) or from 1.13 changes nothing a user stored.
/// Dashboard colours survive as accents, picked icons still draw, and the
/// theme setting is untouched.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('stored data', () {
    late SchemaVerifier verifier;
    setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

    test('a 1.9.2 dashboard and scene keep their colour and icon', () async {
      const purple = 0xFF9C27B0;
      const teal = 0xFF009688;
      final schema = await verifier.schemaAt(5);
      final old = v5.DatabaseAtV5(schema.newConnection());
      await old.into(old.connections).insert(v5.ConnectionsCompanion.insert(
            id: 'c1',
            name: 'home',
            host: '192.168.1.2',
            port: 1883,
            protocol: 'tcp',
            createdAt: 0,
            updatedAt: 0,
          ));
      await old.into(old.dashboards).insert(v5.DashboardsCompanion.insert(
            id: 'd1',
            connectionId: 'c1',
            name: 'Living room',
            colorSeed: purple,
            iconCodepoint: Icons.weekend.codePoint,
            createdAt: 0,
            updatedAt: 0,
          ));
      await old.into(old.scenes).insert(v5.ScenesCompanion.insert(
            id: 's1',
            connectionId: 'c1',
            name: 'Evening',
            iconCodepoint: Icons.nightlight.codePoint,
            colorSeed: teal,
            actions: '[]',
            createdAt: 0,
            updatedAt: 0,
          ));
      await old.close();

      final db = AppDatabase.test(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 7);

      final dash = await db.select(db.dashboards).getSingle();
      expect(dash.colorSeed, purple);
      expect(dash.iconCodepoint, Icons.weekend.codePoint);
      final scene = await db.select(db.scenes).getSingle();
      expect(scene.colorSeed, teal);
      expect(scene.iconCodepoint, Icons.nightlight.codePoint);

      // The stored colour becomes the dashboard's accent in both brightnesses.
      for (final b in Brightness.values) {
        expect(DashboardAccent.fromSeed(dash.colorSeed, b).color,
            ColorScheme.fromSeed(seedColor: const Color(purple), brightness: b)
                .primary);
      }
      // The picked icons draw as their rounded variants.
      expect(materialIcon(dash.iconCodepoint), Icons.weekend_rounded);
      expect(materialIcon(scene.iconCodepoint), Icons.nightlight_rounded);
    });
  });

  group('settings', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    Future<ProviderContainer> upgradeWith(Map<String, Object> prefs) async {
      SharedPreferences.setMockInitialValues(prefs);
      final p = await SharedPreferences.getInstance();
      final c = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(p)]);
      addTearDown(c.dispose);
      return c;
    }

    test('the theme and language a 1.x user chose are kept', () async {
      final c = await upgradeWith(
          {'theme_mode': 'light', 'locale': 'he', 'onboarding_complete': true});
      final s = c.read(settingsControllerProvider);
      expect(s.themeMode, ThemeMode.light);
      expect(s.locale, const Locale('he'));
    });

    test('a 1.x user who never touched Material You gets Signal (ADR 0002)',
        () async {
      // 1.9.2 and 1.13 defaulted the switch to on without storing it.
      final c = await upgradeWith({'onboarding_complete': true});
      expect(c.read(settingsControllerProvider).dynamicColor, isFalse);
    });

    test('an explicit Material You choice survives either way', () async {
      for (final choice in [true, false]) {
        final c = await upgradeWith(
            {'dynamic_color': choice, 'onboarding_complete': true});
        expect(c.read(settingsControllerProvider).dynamicColor, choice);
      }
    });
  });
}
