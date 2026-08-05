import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/panel_grid.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';

/// Builds a [Panel] row with defaults, so tests read like fixtures.
Panel _panel(
  String id,
  String name,
  PanelType type,
  PanelWidth width,
) =>
    Panel(
      id: id,
      dashboardId: 'd1',
      name: name,
      type: type,
      topic: 'light/$id',
      subscribeTopic: null,
      topicPrefixOverride: null,
      qos: 1,
      retain: false,
      width: width,
      sortOrder: 0,
      config: PanelConfig.defaultFor(type).encode(),
      mergeFlags: 0,
      createdAt: DateTime(2026, 8, 5),
      updatedAt: DateTime(2026, 8, 5),
    );

Dashboard _dashboard() => Dashboard(
      id: 'd1',
      connectionId: 'c1',
      name: 'My Home',
      topicPrefix: 'zigbee2mqtt',
      colorSeed: 0xFF3B82F6,
      iconCodepoint: 0xE88A,
      locked: false,
      sortOrder: 0,
      createdAt: DateTime(2026, 8, 5),
      updatedAt: DateTime(2026, 8, 5),
    );

/// Faked providers: panels come from a plain value stream (no drift watch
/// streams — those leave pending timers that fail widget-test teardown), the
/// MQTT status is faked so no real client connects, and every panel-value
/// stream yields null so tiles render in a deterministic "no data" state.
List<Override> _overrides({
  required List<Panel> panels,
  MqttStatus status = MqttStatus.connected,
}) =>
    [
      panelsForDashboardProvider.overrideWith(
        (ref, _) => Stream<List<Panel>>.value(panels),
      ),
      connectionStatusProvider.overrideWith(
        (ref, _) => Stream<MqttStatus>.value(status),
      ),
      panelValueProvider.overrideWith(
        (ref, _) => Stream<Object?>.value(null),
      ),
    ];

Widget _wrap({required List<Panel> panels, MqttStatus status = MqttStatus.connected}) =>
    ProviderScope(
      overrides: _overrides(panels: panels, status: status),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PanelGrid(connectionId: 'c1', dashboard: _dashboard()),
        ),
      ),
    );

void main() {
  testWidgets('empty dashboard shows the no-panels message', (tester) async {
    await tester.pumpWidget(_wrap(panels: []));
    await tester.pumpAndSettle();

    expect(find.textContaining('No panels yet'), findsOneWidget);
  });

  testWidgets('renders a panel tile per row with its name', (tester) async {
    await tester.pumpWidget(_wrap(panels: [
      _panel('p1', 'Living Room Light', PanelType.toggle, PanelWidth.full),
      _panel('p2', 'Brightness', PanelType.slider, PanelWidth.half),
      _panel('p3', 'Fan Mode', PanelType.multiState, PanelWidth.third),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Living Room Light'), findsOneWidget);
    expect(find.text('Brightness'), findsOneWidget);
    expect(find.text('Fan Mode'), findsOneWidget);
    expect(find.textContaining('No panels yet'), findsNothing);
  });

  testWidgets('shows the offline banner when the broker is disconnected',
      (tester) async {
    await tester.pumpWidget(_wrap(
      panels: [_panel('p1', 'Kitchen Plug', PanelType.toggle, PanelWidth.full)],
      status: MqttStatus.disconnected,
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Offline'), findsOneWidget);
    // Panel tile still renders while offline.
    expect(find.text('Kitchen Plug'), findsOneWidget);
  });

  testWidgets('no offline banner while connected', (tester) async {
    await tester.pumpWidget(_wrap(panels: [
      _panel('p1', 'Kitchen Plug', PanelType.toggle, PanelWidth.full),
    ]));
    await tester.pumpAndSettle();

    expect(find.textContaining('Offline'), findsNothing);
  });

  testWidgets('full / half / third widths map to the expected tile sizes',
      (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(panels: [
      _panel('p1', 'Full', PanelType.toggle, PanelWidth.full),
      _panel('p2', 'Half', PanelType.toggle, PanelWidth.half),
      _panel('p3', 'Third', PanelType.toggle, PanelWidth.third),
    ]));
    await tester.pumpAndSettle();

    double cardWidth(String name) => tester
        .getSize(find.ancestor(
          of: find.text(name),
          matching: find.byType(Card),
        ))
        .width;

    // Grid padding 8 per side; spacing 8 between items.
    expect(cardWidth('Full'), closeTo(800 - 16, 0.5));
    expect(cardWidth('Half'), closeTo((800 - 24) / 2, 0.5));
    expect(cardWidth('Third'), closeTo((800 - 32) / 3, 0.5));
  });
}
