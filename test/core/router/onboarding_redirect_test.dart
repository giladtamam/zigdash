import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/router/app_router.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/onboarding/onboarding_provider.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

/// The onboarding redirect lives in the router (not in MaterialApp's builder):
/// a builder-wrapped child sits above the InheritedGoRouter, so the old
/// overlay made every onboarding button crash with "No GoRouter found in
/// context" on fresh installs. These tests render through the real router.
void main() {
  Future<ProviderContainer> containerWithPrefs(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Stub the connections stream: no real drift watch stream (those
        // leave pending timers that fail widget-test teardown) and no MQTT.
        connectionsStreamProvider.overrideWith(
          (ref) => Stream<List<Connection>>.value(const <Connection>[]),
        ),
      ],
    );
  }

  Widget app(ProviderContainer c) => UncontrolledProviderScope(
        container: c,
        child: MaterialApp.router(
          routerConfig: c.read(routerProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

  // First-run decision: one door, no carousel.
  testWidgets('a fresh install lands in setup', (tester) async {
    final c = await containerWithPrefs({});
    addTearDown(c.dispose);

    await tester.pumpWidget(app(c));
    await tester.pumpAndSettle();

    expect(find.text('Find my setup'), findsOneWidget);
    expect(find.text('Next'), findsNothing, reason: 'no carousel');
    expect(find.byType(NavigationBar), findsNothing,
        reason: 'setup renders outside the navigation shell');
  });

  testWidgets('during first run the app screens redirect to setup',
      (tester) async {
    final c = await containerWithPrefs({});
    addTearDown(c.dispose);
    await tester.pumpWidget(app(c));
    await tester.pumpAndSettle();

    c.read(routerProvider).go(Routes.settings);
    await tester.pumpAndSettle();
    expect(find.text('Find my setup'), findsOneWidget);
  });

  testWidgets('with first run done and no home remembered, the list opens',
      (tester) async {
    final c = await containerWithPrefs({'onboarding_complete': true});
    addTearDown(c.dispose);

    await tester.pumpWidget(app(c));
    await tester.pumpAndSettle();

    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('Find my setup'), findsNothing);
  });

  testWidgets('the retired onboarding address leads to the start location',
      (tester) async {
    final c = await containerWithPrefs({'onboarding_complete': true});
    addTearDown(c.dispose);
    await tester.pumpWidget(app(c));
    await tester.pumpAndSettle();

    c.read(routerProvider).go(Routes.onboarding);
    await tester.pumpAndSettle();
    expect(find.text('Connections'), findsOneWidget);
  });

  testWidgets('finishing first run mid-session releases the app',
      (tester) async {
    final c = await containerWithPrefs({});
    addTearDown(c.dispose);
    await tester.pumpWidget(app(c));
    await tester.pumpAndSettle();
    expect(find.text('Find my setup'), findsOneWidget);

    await c.read(onboardingProvider.notifier).completeOnboarding();
    c.read(routerProvider).go(Routes.connections);
    await tester.pumpAndSettle();

    expect(find.text('Connections'), findsOneWidget);
  });
}
