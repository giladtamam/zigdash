import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/data/database/database.dart' show Scene;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/engine/automation.dart';
import 'package:zigdash/engine/automation_editor_screen.dart';
import 'package:zigdash/engine/automations_repo.dart';
import 'package:zigdash/engine/automations_screen.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/engine/town_picker.dart';
import 'package:zigdash/features/devices/devices_providers.dart' show homeBaseTopicProvider;
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/scenes/models/scene.dart';
import 'package:zigdash/features/scenes/scenes_providers.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

class _Recording extends MqttManager {
  _Recording()
      : super(
          config: const BrokerConfig(id: 'c1', host: 'localhost', port: 1883, protocol: MqttProtocol.tcp),
          password: '',
        );
  final published = <(String, String, bool)>[];
  @override
  bool get isConnected => true;
  @override
  void publish(String topic, String template, Object value,
      {mc.MqttQos qos = mc.MqttQos.atLeastOnce, bool retain = false}) {
    published.add((topic, template, retain));
  }
}

List<Z2mDevice> _devices() => parseBridgeDevices(jsonEncode([
      {
        'friendly_name': 'Hallway motion',
        'ieee_address': '0xmotion',
        'type': 'EndDevice',
        'supported': true,
        'definition': {
          'exposes': [
            {'type': 'binary', 'property': 'occupancy', 'access': 1, 'value_on': true, 'value_off': false},
          ],
        },
      },
      {
        'friendly_name': 'Hallway light',
        'ieee_address': '0xlight',
        'type': 'Router',
        'supported': true,
        'definition': {
          'exposes': [
            {
              'type': 'light',
              'features': [
                {'type': 'binary', 'property': 'state', 'access': 7, 'value_on': 'ON', 'value_off': 'OFF'},
              ],
            },
          ],
        },
      },
    ]));

Future<_Recording> _pump(WidgetTester tester, Widget home, {List<Override> extra = const []}) async {
  SharedPreferences.setMockInitialValues({});
  final p = await SharedPreferences.getInstance();
  final mgr = _Recording();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      mqttManagerProvider.overrideWith((ref, _) async => mgr),
      homeBaseTopicProvider.overrideWith((ref, _) => 'zigbee2mqtt'),
      bridgeDevicesStreamProvider.overrideWith((ref, _) => Stream.value(_devices())),
      scenesForConnectionProvider.overrideWith((ref, _) => Stream.value(<Scene>[])),
      automationsRepoProvider.overrideWith(
          (ref) => AutomationsRepo((_) async => mgr, p, timeZone: () async => 'Asia/Jerusalem')),
      ...extra,
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return mgr;
}

Automation _rule(String id) => Automation(
      id: id,
      name: 'Rule $id',
      enabled: true,
      trigger: const TimeTrigger(at: '07:00'),
      action: const AutomationAction(
          kind: ActionKind.device, commands: [EngineCommand(ieee: '0xlight', payload: {'state': 'ON'})], label: 'Hallway light'),
    );

final _engineRunning = engineViewProvider.overrideWith((ref, _) => Stream.value(EngineView(
      phase: HubEnginePhase.running,
      report: EngineReport(
          version: '3.0.0', runningOn: 'hub', rulesLoaded: 0, rulesUnknown: const [], stoppedSelf: false, at: DateTime(2026)),
    )));

void main() {
  testWidgets('motion turns the light on for five minutes: saved retained for the Engine', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    // 3.6.2: with the Engine running, saving goes straight to the hub.
    final mgr = await _pump(tester, const AutomationEditorScreen(connectionId: 'c1'), extra: [_engineRunning]);

    await tester.tap(find.byKey(const Key('auto-trigger-device')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hallway motion').last);
    await tester.pumpAndSettle();
    expect(find.text('motion'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('auto-action-device')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auto-action-device')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hallway light').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Turn off again'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();

    await tester.tap(find.byKey(const Key('auto-save')));
    await tester.pumpAndSettle();

    final meta = mgr.published.firstWhere((p) => p.$1 == EngineTopics.meta);
    expect(jsonDecode(meta.$2), {'timezone': 'Asia/Jerusalem'});
    final rule = mgr.published.firstWhere((p) => p.$1.startsWith('zigdash/automations/rules/'));
    expect(rule.$3, isTrue, reason: 'retained');
    final j = jsonDecode(rule.$2) as Map;
    expect(j['trigger'], {'type': 'device', 'ieee': '0xmotion', 'property': 'occupancy', 'equals': true, 'label': 'Hallway motion'});
    expect(j['action'], {
      'type': 'device',
      'commands': [
        {'ieee': '0xlight', 'payload': {'state': 'ON'}},
      ],
      'offAfter': 5,
      'label': 'Hallway light',
    });
    expect(j['name'], contains('Hallway motion'));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4)); // the manager's unsubscribe grace
  });

  testWidgets('a sunrise rule needs a town first', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    final mgr = await _pump(tester, const AutomationEditorScreen(connectionId: 'c1'));
    await tester.tap(find.text('A time comes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sunrise'));
    await tester.pumpAndSettle();
    expect(find.text('No town set'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('auto-action-device')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auto-action-device')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hallway light').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auto-save')));
    await tester.pumpAndSettle();
    expect(find.text('Set your town for sunrise and sunset.'), findsOneWidget);
    expect(mgr.published, isEmpty);
  });

  testWidgets('the fourth automation without Pro opens the Pro sheet', (tester) async {
    await _pump(
      tester,
      const AutomationsScreen(connectionId: 'c1'),
      extra: [
        engineViewProvider.overrideWith((ref, _) => Stream.value(EngineView(
              phase: HubEnginePhase.running,
              report: EngineReport(
                  version: '3.0.0', runningOn: 'hub', rulesLoaded: 3, rulesUnknown: const [], stoppedSelf: false, at: DateTime(2026)),
            ))),
        automationsProvider.overrideWith((ref, _) => Stream.value([_rule('a'), _rule('b'), _rule('c')])),
        automationRunsProvider.overrideWith((ref, _) => Stream.value(const [])),
        proStatusProvider.overrideWithValue(ProStatus.locked),
      ],
    );
    expect(find.text('Rule a'), findsOneWidget);
    expect(find.text('3 of 3 free automations'), findsOneWidget);
    await tester.tap(find.byKey(const Key('auto-new')));
    await tester.pumpAndSettle();
    expect(find.text('3 automations are free. Want more?'), findsOneWidget);
  });

  // 3.8.7: own tiles the Engine can't send are left out of the commands,
  // and said under the scene picker.
  Scene sceneOf(List<SceneAction> actions) => Scene(
        id: 's1',
        connectionId: 'c1',
        name: 'Evening',
        iconCodepoint: 0,
        colorSeed: 0,
        actions: SceneAction.encodeList(actions),
        sortOrder: 0,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
  const sceneRule = Automation(
    id: 'r1',
    name: 'Evening at 7',
    enabled: true,
    trigger: TimeTrigger(at: '19:00'),
    action: AutomationAction(kind: ActionKind.scene, commands: [], sceneId: 's1', label: 'Evening'),
  );

  testWidgets('a scene with a raw tile: one command, and the note', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    final mgr = await _pump(tester, const AutomationEditorScreen(connectionId: 'c1', existing: sceneRule), extra: [
      _engineRunning,
      scenesForConnectionProvider.overrideWith((ref, _) => Stream.value([
            sceneOf(const [
              SceneAction(setTopic: 'zigbee2mqtt/Hallway light/set', payload: '{"state":"ON"}'),
              SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'ON'),
            ]),
          ])),
    ]);
    final note = find.text("1 of this scene's actions runs only from this phone at home, not from Automations.");
    await tester.scrollUntilVisible(note, 200, scrollable: find.byType(Scrollable).first);
    expect(note, findsOneWidget);
    await tester.tap(find.byKey(const Key('auto-save')));
    await tester.pumpAndSettle();
    final rule = mgr.published.firstWhere((p) => p.$1.startsWith('zigdash/automations/rules/'));
    expect((jsonDecode(rule.$2) as Map)['action']['commands'], [
      {'ieee': '0xlight', 'payload': {'state': 'ON'}},
    ]);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('a scene of only raw tiles has nothing to send', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    final mgr = await _pump(tester, const AutomationEditorScreen(connectionId: 'c1', existing: sceneRule), extra: [
      _engineRunning,
      scenesForConnectionProvider.overrideWith((ref, _) => Stream.value([
            sceneOf(const [
              SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'ON'),
              SceneAction(setTopic: 'zigbee2mqtt/kitchen/set', payload: 'OFF'),
            ]),
          ])),
    ]);
    final note = find.text("2 of this scene's actions run only from this phone at home, not from Automations.");
    await tester.scrollUntilVisible(note, 200, scrollable: find.byType(Scrollable).first);
    expect(note, findsOneWidget);
    await tester.tap(find.byKey(const Key('auto-save')));
    await tester.pumpAndSettle();
    expect(find.text('That scene has nothing to send.'), findsOneWidget);
    expect(mgr.published.where((p) => p.$1.startsWith('zigdash/automations/rules/')), isEmpty);
  });

  test('town search: name or plain-letter name, starts-with first', () {
    final towns = parseTowns('# header\nHaifa\t\tIL\t32.81\t35\nTel Aviv\t\tIL\t32.08\t34.78\nKraków\tKrakow\tPL\t50.06\t19.94\nAl Haifa\t\tXX\t1\t1\n');
    expect(searchTowns(towns, 'haif').map((t) => t.name), ['Haifa', 'Al Haifa']);
    expect(searchTowns(towns, 'krakow').single.name, 'Kraków');
    expect(searchTowns(towns, 'tel').single.toTown().name, 'Tel Aviv, IL');
    expect(searchTowns(towns, ' '), isEmpty);
  });
}
