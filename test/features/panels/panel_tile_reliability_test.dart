import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/panel_reliability_frame.dart';
import 'package:zigdash/features/panels/widgets/panel_tile.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

class _RecordingMqttManager extends MqttManager {
  _RecordingMqttManager()
    : super(
        config: const BrokerConfig(
          id: 'c1',
          host: 'localhost',
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
      );

  bool connected = false;
  String? publishedTopic;
  String? publishedTemplate;
  Object? publishedValue;

  @override
  bool get isConnected => connected;

  @override
  void publish(
    String topic,
    String template,
    Object value, {
    mc.MqttQos qos = mc.MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    publishedTopic = topic;
    publishedTemplate = template;
    publishedValue = value;
  }
}

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
  Stream<MqttStatus>? statusStream,
  MqttManager? manager,
  Object? panelValue,
}) => ProviderScope(
  key: ValueKey((type, status, freshness)),
  overrides: [
    connectionStatusProvider.overrideWith(
      (ref, _) => statusStream ?? Stream.value(status),
    ),
    if (manager != null)
      mqttManagerProvider.overrideWith((ref, _) async => manager),
    panelValueSnapshotProvider.overrideWith(
      (ref, _) => freshness == null
          ? const Stream<PanelValueSnapshot>.empty()
          : Stream.value(
              PanelValueSnapshot(
                value: snapshotValue ?? 'ON',
                receivedAt: DateTime(2026, 8, 14),
                connectionGeneration: 1,
                freshness: freshness,
              ),
            ),
    ),
    panelValueProvider.overrideWith(
      (ref, _) => Stream.value(panelValue ?? 'ON'),
    ),
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

/// The stale chip: it shows the value's age (a date for these fixtures).
final _staleChip = find.descendant(
  of: find.byType(PanelReliabilityFrame),
  matching: find.byType(Chip),
);

void main() {
  test('every panel type has an intentional reliability policy', () {
    const expected = <PanelType, PanelReliabilityPolicy>{
      PanelType.button: PanelReliabilityPolicy.publishOnly(),
      PanelType.toggle: PanelReliabilityPolicy.interactiveSubscription(),
      PanelType.slider: PanelReliabilityPolicy.interactiveSubscription(),
      PanelType.led: PanelReliabilityPolicy.readOnlySubscription(),
      PanelType.nodeStatus: PanelReliabilityPolicy.readOnlySubscription(),
      PanelType.progress: PanelReliabilityPolicy.readOnlySubscription(),
      PanelType.multiState: PanelReliabilityPolicy.interactiveSubscription(),
      PanelType.combo: PanelReliabilityPolicy.interactiveSubscription(),
      PanelType.radio: PanelReliabilityPolicy.interactiveSubscription(),
      PanelType.cover: PanelReliabilityPolicy.interactiveSubscription(
        jsonPathSource: PanelJsonPathSource.none,
      ),
      PanelType.textInput: PanelReliabilityPolicy.publishOnly(),
      PanelType.textLog: PanelReliabilityPolicy.readOnlySubscription(),
      PanelType.schedule: PanelReliabilityPolicy.publishOnly(),
      PanelType.scene: PanelReliabilityPolicy.publishOnly(),
      PanelType.autoClose: PanelReliabilityPolicy.autoClose(),
      // Device tiles read the whole state payload and send /set commands.
      PanelType.device: PanelReliabilityPolicy.deviceTile(),
      PanelType.reading: PanelReliabilityPolicy.readOnlySubscription(),
    };

    expect(expected.keys, containsAll(PanelType.values));
    expect(expected.length, PanelType.values.length);
    for (final type in PanelType.values) {
      expect(panelReliabilityPolicy(type), expected[type], reason: type.name);
    }
  });

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
    expect(
      panelReliabilityValueLabel(const TextLogConfig(jsonPath: 'event'), {
        'kind': 'door',
        'open': true,
      }),
      isNull,
    );
  });

  testWidgets('reconnect enables a stale interactive control immediately', (
    tester,
  ) async {
    final statuses = StreamController<MqttStatus>.broadcast();
    final manager = _RecordingMqttManager();
    addTearDown(statuses.close);
    addTearDown(manager.dispose);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(
        PanelType.toggle,
        status: MqttStatus.disconnected,
        freshness: PanelFreshness.stale,
        snapshotValue: 'OFF',
        statusStream: statuses.stream,
        manager: manager,
        panelValue: 'OFF',
      ),
    );
    statuses.add(MqttStatus.disconnected);
    await tester.pump();

    expect(_staleChip, findsOneWidget);
    expect(_gate(tester).absorbing, isTrue);

    manager.connected = true;
    statuses.add(MqttStatus.connected);
    await tester.pump();

    expect(_staleChip, findsOneWidget);
    expect(_gate(tester).absorbing, isFalse);
    final semanticsLabel = tester
        .getSemantics(find.byType(PanelReliabilityFrame))
        .label;
    expect(semanticsLabel, contains('Last known'));
    expect(semanticsLabel, isNot(contains('Controls unavailable')));

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(manager.publishedTopic, 'home/device');
    expect(manager.publishedTemplate, '{"state":"ON"}');
    expect(manager.publishedValue, '');
    semantics.dispose();
  });

  testWidgets('disconnected interactive panel keeps controls unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PanelType.toggle,
        status: MqttStatus.disconnected,
        freshness: PanelFreshness.stale,
      ),
    );
    await tester.pump();

    expect(_staleChip, findsOneWidget);
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

    expect(_staleChip, findsNothing);
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

    expect(_staleChip, findsOneWidget);
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

    final label = tester.getSemantics(find.byType(PanelReliabilityFrame)).label;
    expect(label, contains('OPEN'));
    expect(label, contains('42%'));
    expect(label, isNot(contains('motor')));
    expect(label, isNot(contains('{')));
    semantics.dispose();
  });

  testWidgets('a stale value shows its age', (tester) async {
    final now = DateTime(2026, 9, 27, 12);
    Future<void> show(DateTime at) => tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PanelReliabilityFrame(
              stale: true,
              controlsEnabled: true,
              receivedAt: at,
              now: () => now,
              child: const SizedBox(width: 200, height: 100),
            ),
          ),
        ));
    await show(now.subtract(const Duration(seconds: 20)));
    expect(find.text('Just now'), findsOneWidget);
    await show(now.subtract(const Duration(minutes: 12)));
    expect(find.text('12 min ago'), findsOneWidget);
    await show(now.subtract(const Duration(hours: 2, minutes: 5)));
    expect(find.text('2 h ago'), findsOneWidget);
    await show(DateTime(2026, 9, 20));
    expect(find.text('Sep 20'), findsOneWidget);
  });
}
