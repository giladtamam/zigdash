import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/router/app_router.dart' show parsePanelTypeToken;
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/dashboards/screens/dashboards_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';

/// Exit check 2 (docs/design/dashboard-1.12.md §11): every raw panel type
/// stays reachable under Custom MQTT tile. Scene tiles are added from the
/// Scenes tab ("Add to dashboard"); device and reading tiles have their own
/// entries in Add tile.
void main() {
  testWidgets('every raw panel type is offered under Custom MQTT tile',
      (tester) async {
    final opened = <PanelType>{};
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => openCustomTilePicker(context,
                    connectionId: 'c1', dashboardId: 'd1'),
                child: const Text('custom'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/connections/:id/dashboards/:d/panels/new',
          builder: (_, state) {
            opened.add(parsePanelTypeToken(state.uri.queryParameters['type']));
            return const Scaffold(body: Text('form'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('custom'));
    await tester.pumpAndSettle();
    final options = tester
        .widgetList<ListTile>(find.descendant(
            of: find.byType(BottomSheet), matching: find.byType(ListTile)))
        .length;
    expect(options, greaterThan(10));
    // Close the sheet before picking each option in turn.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    for (var i = 0; i < options; i++) {
      if (find.text('custom').evaluate().isEmpty) {
        router.go('/');
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('custom'));
      await tester.pumpAndSettle();
      final tile = find
          .descendant(
              of: find.byType(BottomSheet), matching: find.byType(ListTile))
          .at(i);
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }

    expect(opened, {
      for (final t in PanelType.values)
        if (t != PanelType.device &&
            t != PanelType.reading &&
            t != PanelType.scene)
          t,
    });
  });
}
