import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/panel_grid.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

// Regressions for the TalkBack defects in docs/design/audit.md.

final _t = DateTime(2026, 9, 26);

Panel _panel(String id, String name, PanelType type, {String? config}) => Panel(
  id: id,
  dashboardId: 'd1',
  name: name,
  type: type,
  topic: id,
  subscribeTopic: null,
  topicPrefixOverride: null,
  qos: 1,
  retain: false,
  width: PanelWidth.full,
  sortOrder: 0,
  config: config ?? PanelConfig.defaultFor(type).encode(),
  mergeFlags: 0,
  createdAt: _t,
  updatedAt: _t,
);

Future<void> _pump(WidgetTester tester, List<Panel> panels, Object? value) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        sectionsForDashboardProvider.overrideWith(
          (ref, _) => Stream<List<Section>>.value(const []),
        ),
        panelsForDashboardProvider.overrideWith(
          (ref, _) => Stream<List<Panel>>.value(panels),
        ),
        connectionStatusProvider.overrideWith(
          (ref, _) => Stream.value(MqttStatus.connected),
        ),
        panelValueSnapshotProvider.overrideWith(
          (ref, _) => Stream.value(
            PanelValueSnapshot(
              value: value,
              receivedAt: _t,
              connectionGeneration: 1,
              freshness: PanelFreshness.fresh,
            ),
          ),
        ),
        panelValueProvider.overrideWith((ref, _) => Stream.value(value)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PanelGrid(
            connectionId: 'c1',
            dashboard: Dashboard(
              id: 'd1',
              connectionId: 'c1',
              name: 'Home',
              topicPrefix: 'zigbee2mqtt',
              colorSeed: 0xFF3B82F6,
              iconCodepoint: 0xE88A,
              locked: false,
              sortOrder: 0,
              createdAt: _t,
              updatedAt: _t,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('read-only tile announces its name, not only "Panel options"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, [_panel('door', 'Front door', PanelType.led)], 'ON');
    await tester.pump();

    // The tile is one merged node: its name plus the long-press action.
    final data = tester
        .getSemantics(
          find.ancestor(
            of: find.text('Front door'),
            matching: find.byType(MergeSemantics),
          ),
        )
        .getSemanticsData();
    expect(data.label, contains('Front door'));
    expect(data.label, isNot(contains('Panel options')));
    expect(data.hasAction(SemanticsAction.longPress), isTrue);
    handle.dispose();
  });

  testWidgets('slider announces the panel name and its real value', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, [
      _panel(
        'dimmer',
        'Brightness',
        PanelType.slider,
        config: const SliderConfig(max: 254).encode(),
      ),
    ], 180);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final data = tester
        .getSemantics(
          find.ancestor(
            of: find.byType(Slider),
            matching: find.byType(MergeSemantics),
          ),
        )
        .getSemanticsData();
    expect(data.label, contains('Brightness'));
    expect(data.value, '180');
    handle.dispose();
  });
}
