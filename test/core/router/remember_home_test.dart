import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/router/last_dashboard_store.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

void main() {
  testWidgets('a remembered home that no longer exists is forgotten and the '
      'app falls back to the list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await LastDashboardStore(prefs).rememberDashboard('gone', 'd1');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        connectionByIdProvider.overrideWith((ref, id) async => null),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: Routes.homeDashboards('gone'),
          routes: [
            GoRoute(
              path: '/connections/:id/dashboards',
              builder: (_, s) =>
                  RememberHome(connectionId: s.pathParameters['id']!),
            ),
            GoRoute(
              path: Routes.connections,
              builder: (_, __) => const Text('connections list'),
            ),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('connections list'), findsOneWidget);
    final store = LastDashboardStore(prefs);
    expect(store.startLocation, Routes.connections);
    expect(store.lastDashboardOf('gone'), isNull);
  });
}
