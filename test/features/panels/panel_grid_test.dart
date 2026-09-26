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
import 'package:zigdash/data/repositories/section_repo.dart';

/// Builds a [Panel] row with defaults, so tests read like fixtures.
Panel _panel(
  String id,
  String name,
  PanelType type,
  PanelWidth width, {
  String? sectionId,
}) =>
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
      sectionId: sectionId,
    );

Section _section(String id, String name) => Section(
      id: id,
      dashboardId: 'd1',
      name: name,
      sortOrder: 0,
      createdAt: DateTime(2026, 8, 5),
      updatedAt: DateTime(2026, 8, 5),
    );

Dashboard _dashboard() => Dashboard(
      id: 'd1',
      connectionId: 'c1',
      name: 'My Home',
      topicPrefix: 'zigbee2mqtt',
      colorSeed: 0xFF3B82F6,
      iconCodepoint: 0xe318,
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
  List<Section> sections = const [],
}) =>
    [
      sectionsForDashboardProvider.overrideWith(
        (ref, _) => Stream<List<Section>>.value(sections),
      ),
      panelsForDashboardProvider.overrideWith(
        (ref, _) => Stream<List<Panel>>.value(panels),
      ),
      connectionStatusProvider.overrideWith(
        (ref, _) => Stream.value(MqttStatus.connected),
      ),
      panelValueSnapshotProvider.overrideWith(
        (ref, _) => Stream.value(PanelValueSnapshot(
          value: null,
          receivedAt: DateTime(2026, 8, 5),
          connectionGeneration: 1,
          freshness: PanelFreshness.fresh,
        )),
      ),
      panelValueProvider.overrideWith(
        (ref, _) => Stream<Object?>.value(null),
      ),
    ];

Widget _wrap({
  required List<Panel> panels,
  List<Section> sections = const [],
}) =>
    ProviderScope(
      overrides: _overrides(panels: panels, sections: sections),
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

    expect(find.textContaining('No tiles yet'), findsOneWidget);
  });

  testWidgets('renders a panel tile per row with its name', (tester) async {
    await tester.pumpWidget(_wrap(panels: [
      _panel('p1', 'Living Room Light', PanelType.toggle, PanelWidth.full),
      _panel('p2', 'Brightness', PanelType.slider, PanelWidth.small),
      _panel('p3', 'Fan Mode', PanelType.multiState, PanelWidth.wide),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Living Room Light'), findsOneWidget);
    expect(find.text('Brightness'), findsOneWidget);
    expect(find.text('Fan Mode'), findsOneWidget);
    expect(find.textContaining('No tiles yet'), findsNothing);
  });

  testWidgets('does not duplicate dashboard connection status copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        panels: [
          _panel('p1', 'Kitchen Plug', PanelType.toggle, PanelWidth.full),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Offline'), findsNothing);
    expect(find.text('Kitchen Plug'), findsOneWidget);
  });

  testWidgets('sizes span 1, 2 and all columns of a 3-column grid',
      (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(panels: [
      _panel('p1', 'Full', PanelType.toggle, PanelWidth.full),
      _panel('p2', 'Small', PanelType.toggle, PanelWidth.small),
      _panel('p3', 'Wide', PanelType.toggle, PanelWidth.wide),
    ]));
    await tester.pumpAndSettle();

    Rect card(String name) => tester.getRect(find.ancestor(
          of: find.text(name),
          matching: find.byType(Card),
        ));

    // 800 dp is medium: 3 columns of (800 - 16 padding - 2 × 8 gap) / 3.
    const column = (800 - 16 - 16) / 3;
    expect(card('Full').width, closeTo(800 - 16, 0.5));
    expect(card('Small').width, closeTo(column, 0.5));
    expect(card('Wide').width, closeTo(2 * column + 8, 0.5));
    // Small and Wide share the second row, at the same height.
    expect(card('Small').top, card('Wide').top);
    expect(card('Small').height, card('Wide').height);
  });

  testWidgets('tiles with no section come first, then each section',
      (tester) async {
    await tester.pumpWidget(_wrap(
      sections: [_section('s1', 'Lights'), _section('s2', 'Sensors')],
      panels: [
        _panel('p1', 'Door', PanelType.led, PanelWidth.small, sectionId: 's2'),
        _panel('p2', 'Lamp', PanelType.toggle, PanelWidth.small,
            sectionId: 's1'),
        _panel('p3', 'Log', PanelType.textLog, PanelWidth.full),
      ],
    ));
    await tester.pumpAndSettle();

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('Log'), lessThan(top('Lights')));
    expect(top('Lights'), lessThan(top('Lamp')));
    expect(top('Lamp'), lessThan(top('Sensors')));
    expect(top('Sensors'), lessThan(top('Door')));
  });
}
