import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/dashboards/edit_mode.dart';
import 'package:zigdash/features/devices/device_registry.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/panel_grid.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

class _Recording extends PanelRepo {
  _Recording(super.dao);
  final calls = <String>[];

  @override
  Future<void> delete(String id) async => calls.add('delete $id');
  @override
  Future<void> restore(Panel panel) async => calls.add('restore ${panel.id}');
  @override
  Future<void> moveWithinSection(
          String dashboardId, String panelId, int delta) async =>
      calls.add('move $panelId $delta');
  @override
  Future<void> setWidth(String id, PanelWidth width) async =>
      calls.add('size $id ${width.name}');
}

final _stamp = DateTime(2026, 9, 26);
Panel _panel(String id, String name, {String? section}) => Panel(
      id: id,
      dashboardId: 'd1',
      name: name,
      type: PanelType.toggle,
      topic: id,
      subscribeTopic: null,
      topicPrefixOverride: null,
      qos: 1,
      retain: false,
      width: PanelWidth.small,
      sortOrder: 0,
      config: PanelConfig.defaultFor(PanelType.toggle).encode(),
      mergeFlags: 0,
      createdAt: _stamp,
      updatedAt: _stamp,
      sectionId: section,
    );

final _dashboard = Dashboard(
  id: 'd1',
  connectionId: 'c1',
  name: 'Home',
  topicPrefix: 'zigbee2mqtt',
  colorSeed: 0xFF3B82F6,
  iconCodepoint: 0xe318,
  locked: false,
  sortOrder: 0,
  createdAt: _stamp,
  updatedAt: _stamp,
);

void main() {
  late AppDatabase db;
  late _Recording repo;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    repo = _Recording(PanelDao(db));
    container = ProviderContainer(overrides: [
      panelRepoProvider.overrideWithValue(repo),
      panelsForDashboardProvider.overrideWith((ref, _) => Stream.value([
            _panel('p1', 'Desk lamp', section: 's1'),
            _panel('p2', 'Hallway', section: 's1'),
          ])),
      sectionsForDashboardProvider.overrideWith((ref, _) => Stream.value([
            Section(
                id: 's1',
                dashboardId: 'd1',
                name: 'Lights',
                sortOrder: 0,
                createdAt: _stamp,
                updatedAt: _stamp),
          ])),
      unassignedDevicesProvider.overrideWith((ref, _) => const AsyncValue.data([
            Z2mDevice(friendlyName: 'plug', type: 'Router', ieeeAddress: '0x9'),
          ])),
      connectionStatusProvider
          .overrideWith((ref, _) => Stream.value(MqttStatus.connected)),
      panelValueSnapshotProvider.overrideWith((ref, _) => Stream.value(
          PanelValueSnapshot(
              value: 'OFF',
              receivedAt: _stamp,
              connectionGeneration: 1,
              freshness: PanelFreshness.fresh))),
      panelValueProvider.overrideWith((ref, _) => Stream<Object?>.value('OFF')),
    ]);
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  Widget app() => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PanelGrid(connectionId: 'c1', dashboard: _dashboard),
          ),
        ),
      );

  testWidgets('outside Edit mode tiles carry no editing chrome',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.byTooltip('Tile options'), findsNothing);
    expect(find.textContaining("isn't on any dashboard"), findsNothing);
  });

  testWidgets('Edit mode: badges, section tools and the unassigned card',
      (tester) async {
    container.read(editModeProvider.notifier).enter('d1');
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Tile options'), findsNWidgets(2));
    expect(find.byTooltip('Rename section'), findsOneWidget);
    expect(find.text("1 device isn't on any dashboard"), findsOneWidget);
  });

  testWidgets('remove takes effect at once and Undo restores the tile',
      (tester) async {
    container.read(editModeProvider.notifier).enter('d1');
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tile options').first);
    await tester.pumpAndSettle();
    expect(find.text('Move to section'), findsOneWidget);
    await tester.tap(find.text('Remove from dashboard'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['delete p1']);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['delete p1', 'restore p1']);
  });

  testWidgets('screen readers can move a tile without dragging',
      (tester) async {
    final semantics = tester.ensureSemantics();
    container.read(editModeProvider.notifier).enter('d1');
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final node = tester.getSemantics(find
        .ancestor(
            of: find.byTooltip('Tile options').last,
            matching: find.byWidgetPredicate((w) =>
                w is Semantics &&
                (w.properties.customSemanticsActions?.length ?? 0) == 2))
        .first);
    final later = node.getSemanticsData().customSemanticsActionIds!.map(
        CustomSemanticsAction.getAction).firstWhere((a) => a!.label == 'Move earlier');
    tester.binding.renderViews.first.owner!.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.customAction,
        CustomSemanticsAction.getIdentifier(later!));
    await tester.pumpAndSettle();
    expect(repo.calls, ['move p2 -1']);
    semantics.dispose();
  });
}
