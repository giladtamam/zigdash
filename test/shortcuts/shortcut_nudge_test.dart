import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/daos/shortcut_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/database/tables/shortcuts.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/shortcuts/add_tile_button.dart';
import 'package:zigdash/shortcuts/shortcut_nudge.dart';

class _Sink implements AnalyticsSink {
  final sent = <String>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

const _plug = [
  {
    'type': 'switch',
    'features': [
      {
        'type': 'binary',
        'name': 'state',
        'property': 'state',
        'value_on': 'ON',
        'value_off': 'OFF',
        'access': 7,
      },
    ],
  },
];
const _sensor = [
  {
    'type': 'numeric',
    'name': 'temperature',
    'property': 'temperature',
    'access': 1,
  },
];

// 3.3.3: a device switched from the app in a few sessions is offered once
// as a home-screen widget or a Quick Settings tile.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final t = DateTime(2026, 11, 3);

  group('policy', () {
    late SharedPreferences prefs;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('due on the third session, counting each session once', () {
      for (var session = 1; session <= 2; session++) {
        final p = ShortcutNudgePolicy(prefs);
        expect(p.noteUse('home', '0x1'), isFalse);
        expect(p.noteUse('home', '0x1'), isFalse); // same session
      }
      expect(ShortcutNudgePolicy(prefs).noteUse('home', '0x1'), isTrue);
    });

    test('offered once per device, and one offer a session', () {
      prefs.setInt('shortcut.nudge.uses.home.0x1', 5);
      prefs.setInt('shortcut.nudge.uses.home.0x2', 5);
      final p = ShortcutNudgePolicy(prefs);
      expect(p.noteUse('home', '0x1'), isTrue);
      p.offered('home', '0x1');
      expect(p.noteUse('home', '0x2'), isFalse);
      final next = ShortcutNudgePolicy(prefs);
      expect(next.noteUse('home', '0x1'), isFalse);
      expect(next.noteUse('home', '0x2'), isTrue);
    });

    test('two Not nows end the offers', () {
      prefs.setInt('shortcut.nudge.uses.home.0x3', 5);
      ShortcutNudgePolicy(prefs)
        ..later()
        ..later();
      expect(ShortcutNudgePolicy(prefs).noteUse('home', '0x3'), isFalse);
    });
  });

  group('banner', () {
    late AppDatabase db;
    late SharedPreferences prefs;
    late _Sink sink;

    setUp(() async {
      AddShortcutButton.debugAvailable = true;
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      sink = _Sink();
      db = AppDatabase.test(NativeDatabase.memory());
      await db
          .into(db.connections)
          .insert(
            ConnectionsCompanion.insert(
              id: 'home',
              name: 'Home',
              host: 'h',
              port: 1883,
              protocol: MqttProtocol.tcp,
              createdAt: t,
              updatedAt: t,
            ),
          );
      await db
          .into(db.dashboards)
          .insert(
            DashboardsCompanion.insert(
              id: 'd',
              connectionId: 'home',
              name: 'Home',
              colorSeed: 0,
              iconCodepoint: 0,
              createdAt: t,
              updatedAt: t,
            ),
          );
      for (final (ieee, name, exposes) in [
        ('0x1', 'Kitchen plug', _plug),
        ('0x2', 'Bedroom sensor', _sensor),
      ]) {
        await db
            .into(db.panels)
            .insert(
              PanelsCompanion.insert(
                id: ieee,
                dashboardId: 'd',
                name: name,
                type: PanelType.device,
                topic: name,
                width: PanelWidth.small,
                config: DeviceTileConfig(
                  profile: classifyExposes(exposes),
                ).encode(),
                createdAt: t,
                updatedAt: t,
                deviceIeee: Value(ieee),
              ),
            );
      }
    });
    tearDown(() async {
      AddShortcutButton.debugAvailable = null;
      await db.close();
    });

    Future<void> pump(WidgetTester tester, String ieee) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
            analyticsProvider.overrideWithValue(Analytics(sink, enabled: true)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => TextButton(
                  onPressed: () => maybeOfferShortcut(
                    context,
                    ref,
                    connectionId: 'home',
                    ieee: ieee,
                  ),
                  child: const Text('switch'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await tester.tap(find.text('switch'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
    }

    testWidgets('a plug switched in three sessions is offered', (tester) async {
      prefs.setInt('shortcut.nudge.uses.home.0x1', 2);
      await pump(tester, '0x1');
      expect(
        find.text('Switch Kitchen plug without opening ZigDash'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('shortcut-nudge-tile')), findsOneWidget);
      expect(find.byKey(const Key('shortcut-nudge-widget')), findsOneWidget);
      expect(sink.sent, ['shortcut_nudge {step: shown}']);

      await tester.tap(find.byKey(const Key('shortcut-nudge-later')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('shortcut-nudge')), findsNothing);
      expect(sink.sent.last, 'shortcut_nudge {step: later}');
      expect(prefs.getInt('shortcut.nudge.later'), 1);
    });

    testWidgets('a device that only reports gets no Quick Settings', (
      tester,
    ) async {
      prefs.setInt('shortcut.nudge.uses.home.0x2', 2);
      await pump(tester, '0x2');
      expect(find.byKey(const Key('shortcut-nudge')), findsOneWidget);
      expect(find.byKey(const Key('shortcut-nudge-tile')), findsNothing);
    });

    testWidgets('not offered before it is due', (tester) async {
      await pump(tester, '0x1');
      expect(find.byKey(const Key('shortcut-nudge')), findsNothing);
      expect(sink.sent, isEmpty);
    });

    testWidgets('not offered for a device with a widget', (tester) async {
      prefs.setInt('shortcut.nudge.uses.home.0x1', 2);
      await db
          .into(db.shortcuts)
          .insert(
            ShortcutsCompanion.insert(
              id: 'widget-7',
              connectionId: 'home',
              kind: ShortcutKind.device,
              surface: ShortcutSurface.widget,
              targets: encodeShortcutTargets(['0x1']),
              appWidgetId: const Value(7),
              createdAt: t,
            ),
          );
      await pump(tester, '0x1');
      expect(find.byKey(const Key('shortcut-nudge')), findsNothing);
    });

    testWidgets('not offered for a device on no dashboard', (tester) async {
      prefs.setInt('shortcut.nudge.uses.home.0x9', 2);
      await pump(tester, '0x9');
      expect(find.byKey(const Key('shortcut-nudge')), findsNothing);
    });
  });
}
