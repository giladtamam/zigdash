import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/features/onboarding/screens/onboarding_screen.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

GoRouter _router() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: Routes.connections,
          builder: (_, __) => const Scaffold(body: Text('STUB_CONNECTIONS')),
        ),
      ],
    );

Widget _wrap(AppDatabase db, SharedPreferences prefs) => ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp.router(
        routerConfig: _router(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

void main() {
  testWidgets('renders the welcome page with all actions', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db, prefs));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to ZigDash'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Try demo'), findsOneWidget);
  });

  testWidgets('Next advances through the three pages, last shows Get Started',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db, prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Connect your broker'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Build your dashboards'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Skip completes onboarding and navigates to connections',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db, prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('STUB_CONNECTIONS'), findsOneWidget);
    expect(prefs.getBool('onboarding_complete'), isTrue);
  });

  testWidgets('Get Started on the last page completes and navigates',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db, prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('STUB_CONNECTIONS'), findsOneWidget);
    expect(prefs.getBool('onboarding_complete'), isTrue);
  });

  testWidgets('Try demo seeds demo data, completes onboarding, navigates',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db, prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try demo'));
    await tester.pumpAndSettle();

    expect(find.text('STUB_CONNECTIONS'), findsOneWidget);

    expect(prefs.getBool('onboarding_complete'), isTrue);
    expect(prefs.getBool('demo_mode'), isTrue);

    // The demo connection was seeded into the local database.
    // Plain query (not a drift watch stream — those leave pending timers that
    // fail widget-test teardown).
    final conns = await db.select(db.connections).get();
    expect(conns.map((c) => c.name), contains('Demo Smart Home'));
    expect(conns.single.host, 'demo.local');
  });
}
