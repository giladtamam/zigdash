import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/features/dashboards/screens/dashboards_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

void main() {
  testWidgets(
      'opened straight on a dashboard, the header leads to the broker list',
      (tester) async {
    final router = GoRouter(
      initialLocation: Routes.homeDashboards('c1'),
      routes: [
        GoRoute(
          path: Routes.connections,
          builder: (_, __) => const Scaffold(body: Text('broker list')),
        ),
        GoRoute(
          path: '/connections/:id/dashboards',
          builder: (_, state) =>
              DashboardsScreen(connectionId: state.pathParameters['id']!),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        connectionByIdProvider.overrideWith((ref, id) async => null),
        dashboardsForConnectionProvider
            .overrideWith((ref, id) => Stream.value([])),
        connectionStatusProvider
            .overrideWith((ref, id) => Stream.value(MqttStatus.connected)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BackButton), findsNothing);
    await tester.tap(find.byTooltip('Connections'));
    await tester.pumpAndSettle();
    expect(find.text('broker list'), findsOneWidget);
  });
}
