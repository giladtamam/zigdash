import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/theme/signal_colors.dart';
import 'package:zigdash/core/theme/signal_icons.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/panel_tile.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

class _Recorder extends MqttManager {
  _Recorder()
      : super(
          config: const BrokerConfig(
              id: 'c1', host: 'localhost', port: 1883, protocol: MqttProtocol.tcp),
          password: '',
        );

  final sent = <(String, Map<String, Object?>)>[];

  @override
  bool get isConnected => true;

  @override
  void publish(String topic, String template, Object value,
      {mc.MqttQos qos = mc.MqttQos.atLeastOnce, bool retain = false}) {
    // State requests (once per connection) are not commands.
    if (topic.endsWith('/get')) return;
    sent.add((topic, json.decode(template) as Map<String, Object?>));
  }
}

const _bulb = [
  {
    'type': 'light',
    'features': [
      {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7, 'value_on': 'ON', 'value_off': 'OFF', 'value_toggle': 'TOGGLE'},
      {'type': 'numeric', 'name': 'brightness', 'property': 'brightness', 'access': 7, 'value_min': 0, 'value_max': 254},
      {'type': 'numeric', 'name': 'color_temp', 'property': 'color_temp', 'access': 7, 'value_min': 142, 'value_max': 500},
      {'type': 'composite', 'name': 'color_xy', 'property': 'color', 'access': 7},
    ],
  },
];

Panel _device(List<Object?> exposes, {String name = 'Living room bulb'}) => Panel(
      id: 'p1',
      dashboardId: 'd1',
      name: name,
      type: PanelType.device,
      topic: 'set',
      subscribeTopic: '',
      topicPrefixOverride: 'zigbee2mqtt/0xc4d7fdbbfeba0000',
      qos: 1,
      retain: false,
      width: PanelWidth.wide,
      sortOrder: 0,
      config: DeviceTileConfig(profile: classifyExposes(exposes)).encode(),
      mergeFlags: 0,
      createdAt: DateTime(2026, 9, 26),
      updatedAt: DateTime(2026, 9, 26),
      deviceIeee: '0xc4d7fdbbfeba0000',
    );

Widget _wrap(Panel panel, {Object? state, _Recorder? mgr}) => ProviderScope(
      overrides: [
        connectionStatusProvider
            .overrideWith((ref, _) => Stream.value(MqttStatus.connected)),
        if (mgr != null) mqttManagerProvider.overrideWith((ref, _) async => mgr),
        panelValueSnapshotProvider.overrideWith((ref, _) => Stream.value(
              PanelValueSnapshot(
                value: state == null ? null : json.encode(state),
                receivedAt: DateTime(2026, 9, 26),
                connectionGeneration: 1,
                freshness: PanelFreshness.fresh,
              ),
            )),
        panelValueProvider.overrideWith((ref, _) =>
            state == null ? const Stream.empty() : Stream.value(json.encode(state))),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 380,
            child: PanelTile(
              connectionId: 'c1',
              dashboardId: 'd1',
              topicPrefix: 'zigbee2mqtt',
              panel: panel,
              locked: true,
            ),
          ),
        ),
      ),
    );

/// Finds text ignoring the left-to-right isolates wrapped around values.
Finder _text(String s) => find.byWidgetPredicate((w) =>
    w is Text && w.data?.replaceAll(RegExp('[\u2066-\u2069]'), '') == s);

void main() {
  testWidgets('color light shows state, brightness and kelvin; icon toggles',
      (tester) async {
    final mgr = _Recorder();
    addTearDown(mgr.dispose);
    await tester.pumpWidget(_wrap(_device(_bulb), mgr: mgr, state: {
      'state': 'ON',
      'brightness': 254,
      'color_mode': 'color_temp',
      'color_temp': 500,
    }));
    await tester.pumpAndSettle();

    expect(find.text('Living room bulb'), findsOneWidget);
    expect(_text('On · 100% · 2000 K'), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.lightbulb));
    await tester.pumpAndSettle();
    expect(mgr.sent.single.$1, 'zigbee2mqtt/0xc4d7fdbbfeba0000/set');
    expect(mgr.sent.single.$2, {'state': 'TOGGLE'});
  });

  testWidgets('before the first report the tile says so and still toggles',
      (tester) async {
    final mgr = _Recorder();
    addTearDown(mgr.dispose);
    await tester.pumpWidget(_wrap(_device(_bulb), mgr: mgr));
    await tester.pumpAndSettle();

    expect(find.text('Waiting for first report'), findsOneWidget);
    await tester.tap(find.byIcon(Symbols.lightbulb));
    await tester.pumpAndSettle();
    expect(mgr.sent.single.$2, {'state': 'TOGGLE'});
  });

  testWidgets('a device that ignores its state request reads Not responding',
      (tester) async {
    final mgr = _Recorder();
    addTearDown(mgr.dispose);
    await tester.pumpWidget(_wrap(_device(_bulb), mgr: mgr));
    await tester.pumpAndSettle();
    expect(find.text('Waiting for first report'), findsOneWidget);

    await tester.pump(const Duration(seconds: 16));
    await tester.pump();
    expect(find.text('Not responding'), findsOneWidget);
  });

  testWidgets('the color sheet sends a preset as hex', (tester) async {
    final mgr = _Recorder();
    addTearDown(mgr.dispose);
    await tester.pumpWidget(_wrap(_device(_bulb), mgr: mgr,
        state: {'state': 'ON', 'brightness': 100, 'color_mode': 'color_temp', 'color_temp': 300}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Living room bulb'));
    await tester.pumpAndSettle();
    expect(find.text('Brightness'), findsWidgets);
    expect(find.text('White'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('#ff6060'));
    await tester.pumpAndSettle();

    expect(mgr.sent.last.$2, {
      'color': {'hex': '#ff6060'},
    });
  });

  testWidgets('a leak alarm fills the tile with the attention colour',
      (tester) async {
    await tester.pumpWidget(_wrap(
      _device([
        {'type': 'binary', 'name': 'water_leak', 'property': 'water_leak', 'access': 1, 'value_on': true, 'value_off': false},
        {'type': 'numeric', 'name': 'battery', 'property': 'battery', 'access': 1, 'unit': '%', 'category': 'diagnostic'},
      ], name: 'Laundry leak'),
      state: {'water_leak': true, 'battery': 15},
    ));
    await tester.pumpAndSettle();

    expect(_text('Leak detected · 15%'), findsOneWidget);
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color,
        SignalColors.of(tester.element(find.byType(Card))).attention);
  });

  testWidgets('climate leads with the temperature', (tester) async {
    await tester.pumpWidget(_wrap(
      _device([
        {'type': 'numeric', 'name': 'temperature', 'property': 'temperature', 'access': 1, 'unit': '°C'},
        {'type': 'numeric', 'name': 'humidity', 'property': 'humidity', 'access': 1, 'unit': '%'},
      ], name: 'Living room'),
      state: {'temperature': 21.43, 'humidity': 48},
    ));
    await tester.pumpAndSettle();
    expect(_text('21.4°C'), findsOneWidget);
    expect(_text('48%'), findsOneWidget);
  });

  testWidgets('contact true reads Closed', (tester) async {
    await tester.pumpWidget(_wrap(
      _device([
        {'type': 'binary', 'name': 'contact', 'property': 'contact', 'access': 1, 'value_on': true, 'value_off': false},
      ], name: 'Front door'),
      state: {'contact': true},
    ));
    await tester.pumpAndSettle();
    expect(_text('Closed'), findsOneWidget);
  });

  testWidgets('a two-gang switch shows both endpoints and toggles each',
      (tester) async {
    final mgr = _Recorder();
    addTearDown(mgr.dispose);
    await tester.pumpWidget(_wrap(
      _device([
        for (final ep in ['l1', 'l2'])
          {
            'type': 'switch',
            'endpoint': ep,
            'features': [
              {'type': 'binary', 'name': 'state', 'property': 'state_$ep', 'access': 7, 'value_on': 'ON', 'value_off': 'OFF'},
            ],
          },
      ], name: 'Garden relay'),
      mgr: mgr,
      state: {'state_l1': 'ON', 'state_l2': 'OFF'},
    ));
    await tester.pumpAndSettle();

    expect(_text('1 on · 1 off'), findsOneWidget);
    await tester.tap(find.byIcon(Symbols.powerSettingsNew).last);
    await tester.pumpAndSettle();
    expect(mgr.sent.single.$2, {'state_l2': 'ON'});
  });
}
