import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/screens/panel_form_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

void main() {
  group('deviceTopics (Pick a device)', () {
    test('dashboard prefix zigbee2mqtt → the friendly name', () {
      expect(
          deviceTopics(
              deviceTopic: 'zigbee2mqtt/Porch light',
              prefix: 'zigbee2mqtt',
              base: 'zigbee2mqtt'),
          (state: 'Porch light', prefixOverride: null));
    });
    test('no prefix → the whole device topic', () {
      expect(
          deviceTopics(
              deviceTopic: 'zigbee2mqtt/Porch light',
              prefix: '',
              base: 'zigbee2mqtt'),
          (state: 'zigbee2mqtt/Porch light', prefixOverride: null));
    });
    test('an unrelated prefix → a prefix override of the base topic', () {
      expect(
          deviceTopics(
              deviceTopic: 'zigbee2mqtt/Porch light',
              prefix: 'home/sensors',
              base: 'zigbee2mqtt'),
          (state: 'Porch light', prefixOverride: 'zigbee2mqtt'));
    });
    test('the prefix is the device topic → empty state, command "set"', () {
      final t = deviceTopics(
          deviceTopic: 'zigbee2mqtt/lamp',
          prefix: 'zigbee2mqtt/lamp',
          base: 'zigbee2mqtt');
      expect(t.state, '');
      expect(commandFor(t.state), 'set');
    });
  });

  group('the form', () {
    final stamp = DateTime(2026);
    Panel panel({String? prefixOverride, int qos = 1}) => Panel(
          id: 'p1',
          dashboardId: 'd1',
          name: 'Lamp',
          type: PanelType.toggle,
          topic: 'lamp/set',
          subscribeTopic: 'lamp',
          topicPrefixOverride: prefixOverride,
          qos: qos,
          retain: false,
          width: PanelWidth.small,
          sortOrder: 0,
          config: const ToggleConfig().encode(),
          mergeFlags: 0,
          createdAt: stamp,
          updatedAt: stamp,
        );
    final dashboard = Dashboard(
      id: 'd1',
      connectionId: 'c1',
      name: 'Home',
      topicPrefix: 'zigbee2mqtt',
      colorSeed: 0,
      iconCodepoint: 0,
      locked: false,
      sortOrder: 0,
      createdAt: stamp,
      updatedAt: stamp,
    );

    Widget app(Panel p) => ProviderScope(
          overrides: [
            panelRepoProvider.overrideWithValue(_Panels(p)),
            dashboardRepoProvider.overrideWithValue(_Dashboards(dashboard)),
            connectionsStreamProvider
                .overrideWith((ref) => Stream.value(const <Connection>[])),
            dashboardsForConnectionProvider
                .overrideWith((ref, _) => Stream.value([dashboard])),
            mqttManagerProvider.overrideWith((ref, _) => Completer<Never>().future),
            bridgeDevicesStreamProvider.overrideWith((ref, _) => Stream.value(const [
                  Z2mDevice(
                      friendlyName: 'Porch light',
                      type: 'Router',
                      ieeeAddress: '0x01'),
                ])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PanelFormScreen(
                connectionId: 'c1', dashboardId: 'd1', panelId: p.id),
          ),
        );

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('an existing tile opens with its topics, Advanced folded',
        (tester) async {
      await tester.pumpWidget(app(panel()));
      await settle(tester);
      expect(find.text('State topic'), findsOneWidget);
      expect(_field('lamp'), findsOneWidget);
      expect(_field('lamp/set'), findsOneWidget);
      expect(find.text('Pick a device'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Advanced'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Topic prefix override (optional)'), findsNothing,
          reason: 'Advanced stays folded when unused');
    });

    testWidgets('a tile using a prefix override opens Advanced',
        (tester) async {
      await tester.pumpWidget(app(panel(prefixOverride: 'z2m', qos: 0)));
      await settle(tester);
      await tester.scrollUntilVisible(find.text('Retain'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(_field('z2m'), findsOneWidget);
    });
  });
}

Finder _field(String text) => find.byWidgetPredicate(
    (w) => w is EditableText && w.controller.text == text);

class _Panels implements PanelRepo {
  _Panels(this.panel);
  final Panel panel;
  @override
  Future<Panel?> getById(String id) async => panel;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Dashboards implements DashboardRepo {
  _Dashboards(this.dashboard);
  final Dashboard dashboard;
  @override
  Future<Dashboard?> getById(String id) async => dashboard;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
