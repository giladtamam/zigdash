import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/devices/device_registry.dart';
import 'package:zigdash/features/devices/devices_providers.dart';
import 'package:zigdash/features/home/home_shell.dart';
import 'package:zigdash/l10n/app_localizations.dart';

final _stamp = DateTime(2026, 9, 26);
Connection _home(String id, String name) => Connection(
      id: id,
      name: name,
      host: 'h',
      port: 1883,
      protocol: MqttProtocol.tcp,
      keepAliveSeconds: 60,
      autoConnect: true,
      createdAt: _stamp,
      updatedAt: _stamp,
    );

Widget _app(List<Connection> homes,
    {int newDevices = 0, Set<String> lowBatteries = const {}}) {
  Widget page(String label, String id) => Scaffold(
        appBar: AppBar(title: HomeTitle(connectionId: id)),
        body: Text(label),
      );
  GoRoute tab(String name) => GoRoute(
        path: '/connections/:id/$name',
        builder: (_, s) =>
            page('$name ${s.pathParameters['id']}', s.pathParameters['id']!),
      );
  final router = GoRouter(
    initialLocation: Routes.homeDashboards('c1'),
    routes: [
      ShellRoute(
        builder: (_, state, child) => HomeShell(
          connectionId: state.pathParameters['id']!,
          location: state.matchedLocation,
          child: child,
        ),
        routes: [tab('dashboards'), tab('devices'), tab('scenes')],
      ),
      GoRoute(path: Routes.setup, builder: (_, __) => const Text('setup')),
      GoRoute(
          path: Routes.settings, builder: (_, __) => const Text('homes')),
    ],
  );
  return ProviderScope(
    overrides: [
      connectionsStreamProvider.overrideWith((ref) => Stream.value(homes)),
      unassignedCountProvider
          .overrideWith((ref, _) => AsyncValue.data(newDevices)),
      homeBaseTopicProvider.overrideWith((ref, _) => null),
      batteryAlertsProvider
          .overrideWith((ref, _) => Stream.value(lowBatteries)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('one home: plain name, no switcher', (tester) async {
    await tester.pumpWidget(_app([_home('c1', 'My Home')]));
    await tester.pumpAndSettle();
    expect(find.text('My Home'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
  });

  testWidgets('two homes: the name switches home; tabs follow the home',
      (tester) async {
    await tester
        .pumpWidget(_app([_home('c1', 'My Home'), _home('c2', 'SMHUB')]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Home'));
    await tester.pumpAndSettle();
    expect(find.text('Add a home'), findsOneWidget);
    expect(find.text('Manage homes'), findsOneWidget);
    await tester.tap(find.text('SMHUB').last);
    await tester.pumpAndSettle();
    expect(find.text('dashboards c2'), findsOneWidget);

    await tester.tap(find.text('Scenes'));
    await tester.pumpAndSettle();
    expect(find.text('scenes c2'), findsOneWidget);
  });

  testWidgets('the Devices destination carries a dot for new devices',
      (tester) async {
    await tester.pumpWidget(_app([_home('c1', 'My Home')], newDevices: 2));
    await tester.pumpAndSettle();
    final badges = tester.widgetList<Badge>(find.byType(Badge));
    expect(badges.any((b) => b.isLabelVisible), isTrue);
  });

  testWidgets('a battery that went low also lights the dot, and says so',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        _app([_home('c1', 'My Home')], lowBatteries: {'0x01'}));
    await tester.pumpAndSettle();
    final badges = tester.widgetList<Badge>(find.byType(Badge));
    expect(badges.first.isLabelVisible, isTrue);
    final devices = tester.widget<NavigationBar>(find.byType(NavigationBar))
        .destinations[1] as NavigationDestination;
    expect(devices.tooltip, 'Devices, Battery low');
  });

  testWidgets('from 600 dp a navigation rail replaces the bar, dot included',
      (tester) async {
    tester.view.physicalSize = const Size(700, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app([_home('c1', 'My Home')], newDevices: 1));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    // TalkBack reaches the rail beside the page (regression: the page's
    // route hid it).
    expect(find.bySemanticsLabel(RegExp('^Scenes')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Devices')), findsOneWidget);
    expect(
        tester.widgetList<Badge>(find.byType(Badge)).first.isLabelVisible,
        isTrue);
    await tester.tap(find.text('Scenes'));
    await tester.pumpAndSettle();
    expect(find.text('scenes c1'), findsOneWidget);
  });
}
