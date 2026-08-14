import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/panel_reliability_frame.dart';
import 'package:zigdash/features/panels/widgets/panel_tile.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

Panel _panel(PanelType type, {PanelConfig? config}) => Panel(
  id: 'p1',
  dashboardId: 'd1',
  name: 'Test panel',
  type: type,
  topic: 'device',
  subscribeTopic: null,
  topicPrefixOverride: null,
  qos: 1,
  retain: false,
  width: PanelWidth.full,
  sortOrder: 0,
  config: (config ?? PanelConfig.defaultFor(type)).encode(),
  mergeFlags: 0,
  createdAt: DateTime(2026, 8, 14),
  updatedAt: DateTime(2026, 8, 14),
);

Widget _wrap(
  PanelType type, {
  required MqttStatus status,
  PanelFreshness? freshness,
  Object? snapshotValue,
  PanelConfig? config,
}) => ProviderScope(
  key: ValueKey((type, status, freshness)),
  overrides: [
    connectionStatusProvider.overrideWith((ref, _) => Stream.value(status)),
    panelValueSnapshotProvider.overrideWith(
      (ref, _) => freshness == null
          ? const Stream<PanelValueSnapshot>.empty()
          : Stream.value(PanelValueSnapshot(
              value: snapshotValue ?? 'ON',
              receivedAt: DateTime(2026, 8, 14),
              connectionGeneration: 1,
              freshness: freshness,
            )),
    ),
    panelValueProvider.overrideWith((ref, _) => Stream.value('ON')),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: PanelTile(
        connectionId: 'c1',
        dashboardId: 'd1',
        topicPrefix: 'home',
        panel: _panel(type, config: config),
        locked: true,
      ),
    ),
  ),
);

AbsorbPointer _gate(WidgetTester tester) => tester.widget<AbsorbPointer>(
  find
      .descendant(
        of: find.byType(PanelReliabilityFrame),
        matching: find.byType(AbsorbPointer),
      )
      .first,
);

void main() {
  test('text log reliability label does not expose structured payloads', () {
    expect(
      panelReliabilityValueLabel(
        const TextLogConfig(),
        '{"event":"door opened"}',
      ),
      isNull,
    );
    expect(
      panelReliabilityValueLabel(const TextLogConfig(), 'door opened'),
      'door opened',
    );
  });

  testWidgets('subscribed interactive panel requires a fresh snapshot', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PanelType.toggle,
        status: MqttStatus.connected,
        freshness: PanelFreshness.stale,
      ),
    );
    await tester.pump();

    expect(find.text('Last known'), findsOneWidget);
    expect(_gate(tester).absorbing, isTrue);
  });

  testWidgets('fresh subscribed interactive panel enables controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PanelType.toggle,
        status: MqttStatus.connected,
        freshness: PanelFreshness.fresh,
      ),
    );
    await tester.pump();

    expect(find.text('Last known'), findsNothing);
    expect(_gate(tester).absorbing, isFalse);
  });

  testWidgets('read-only subscribed panel shows stale value without a gate', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PanelType.led,
        status: MqttStatus.disconnected,
        freshness: PanelFreshness.stale,
      ),
    );
    await tester.pump();

    expect(find.text('Last known'), findsOneWidget);
    expect(_gate(tester).absorbing, isFalse);
  });

  testWidgets('publish-only panel follows broker connection status', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(PanelType.button, status: MqttStatus.disconnected),
    );
    await tester.pump();
    expect(_gate(tester).absorbing, isTrue);

    await tester.pumpWidget(
      _wrap(PanelType.button, status: MqttStatus.connected),
    );
    await tester.pump();
    expect(_gate(tester).absorbing, isFalse);
  });

  testWidgets('stale cover semantics describe state and position, not JSON', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        PanelType.cover,
        status: MqttStatus.disconnected,
        freshness: PanelFreshness.stale,
        snapshotValue: '{"motor":{"state":"OPEN","position":42}}',
        config: const CoverConfig(
          statePath: 'motor.state',
          positionPath: 'motor.position',
        ),
      ),
    );
    await tester.pump();

    final label = tester
        .getSemantics(find.byType(PanelReliabilityFrame))
        .label;
    expect(label, contains('OPEN'));
    expect(label, contains('42%'));
    expect(label, isNot(contains('motor')));
    expect(label, isNot(contains('{')));
    semantics.dispose();
  });
}
