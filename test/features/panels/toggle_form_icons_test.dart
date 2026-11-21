import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/screens/panel_form_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

// Editing a custom toggle keeps its stored icons (3.8.7,
// own-switch-look-387.md §5): no picker sets them, but the tile honours
// them, so Save must not drop them.

final _stamp = DateTime(2026, 10, 11);

Panel _toggle(ToggleConfig config) => Panel(
  id: 'r1',
  dashboardId: 'd1',
  name: 'Hall light',
  type: PanelType.toggle,
  topic: 'hall/set',
  subscribeTopic: 'hall',
  topicPrefixOverride: null,
  qos: 1,
  retain: false,
  width: PanelWidth.small,
  sortOrder: 0,
  config: config.encode(),
  mergeFlags: 0,
  createdAt: _stamp,
  updatedAt: _stamp,
);

final _dashboard = Dashboard(
  id: 'd1',
  connectionId: 'c1',
  name: 'Home',
  topicPrefix: 'zigbee2mqtt',
  colorSeed: 0,
  iconCodepoint: 0,
  locked: false,
  sortOrder: 0,
  createdAt: _stamp,
  updatedAt: _stamp,
);

Widget _app(_Panels panels) => ProviderScope(
  overrides: [
    panelRepoProvider.overrideWithValue(panels),
    dashboardRepoProvider.overrideWithValue(_Dashboards()),
    connectionsStreamProvider.overrideWith(
      (ref) => Stream.value(const <Connection>[]),
    ),
    dashboardsForConnectionProvider.overrideWith(
      (ref, _) => Stream.value([_dashboard]),
    ),
    mqttManagerProvider.overrideWith((ref, _) => Completer<Never>().future),
    bridgeDevicesStreamProvider.overrideWith(
      (ref, _) => Stream.value(const []),
    ),
  ],
  child: MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    // Save pops the form, so it needs a route under it.
    routerConfig: GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('dashboard')),
          routes: [
            GoRoute(
              path: 'form',
              builder: (_, __) => const PanelFormScreen(
                connectionId: 'c1',
                dashboardId: 'd1',
                panelId: 'r1',
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('a renamed toggle keeps both stored icons', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final panels = _Panels(
      _toggle(
        const ToggleConfig(onIconCodepoint: 0xe37b, offIconCodepoint: 0xe37c),
      ),
    );
    await tester.pumpWidget(_app(panels));
    await _settle(tester);
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is EditableText && w.controller.text == 'Hall light',
      ),
      'Hallway light',
    );
    await tester.scrollUntilVisible(
      find.text('Save'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save'));
    await _settle(tester);
    final saved = panels.updated as ToggleConfig;
    expect(saved.onIconCodepoint, 0xe37b);
    expect(saved.offIconCodepoint, 0xe37c);
  });
}

class _Panels implements PanelRepo {
  _Panels(this.panel);
  final Panel panel;
  PanelConfig? updated;
  @override
  Future<Panel?> getById(String id) async => panel;
  @override
  Future<void> update({
    required String id,
    required String name,
    required String topic,
    String? subscribeTopic,
    String? topicPrefixOverride,
    int qos = 1,
    bool retain = false,
    PanelWidth width = PanelWidth.small,
    required PanelConfig config,
  }) async {
    updated = config;
  }

  @override
  Future<void> setDevice(String id, String? ieee) async {}

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Dashboards implements DashboardRepo {
  @override
  Future<Dashboard?> getById(String id) async => _dashboard;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
