import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/onboarding/demo_banner.dart';
import 'package:zigdash/l10n/app_localizations.dart';

Connection _conn(String host) => Connection(
      id: 'c1',
      name: 'Home',
      host: host,
      port: 1883,
      protocol: MqttProtocol.tcp,
      keepAliveSeconds: 60,
      autoConnect: true,
      createdAt: DateTime(2026, 9, 26),
      updatedAt: DateTime(2026, 9, 26),
    );

Future<void> _pump(WidgetTester tester, String host) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectionByIdProvider.overrideWith((ref, id) async => _conn(host)),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const Scaffold(
                body: DemoBanner(connectionId: 'c1'),
              ),
            ),
            GoRoute(
              path: Routes.setup,
              builder: (_, __) => const Text('setup'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // First-run decision: demo mode is persistent but marked, with a way out.
  testWidgets('a demo home shows the demo bar, which opens setup',
      (tester) async {
    await _pump(tester, 'demo.local');
    expect(find.text("You're in demo mode"), findsOneWidget);

    await tester.tap(find.text('Connect your home'));
    await tester.pumpAndSettle();
    expect(find.text('setup'), findsOneWidget);
  });

  testWidgets('a real home shows no demo bar', (tester) async {
    await _pump(tester, '192.168.1.20');
    expect(find.text("You're in demo mode"), findsNothing);
  });
}
