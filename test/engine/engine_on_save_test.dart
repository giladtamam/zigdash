import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart' show Scene;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart' show connectionsStreamProvider;
import 'package:zigdash/engine/automation.dart';
import 'package:zigdash/engine/automation_editor_screen.dart';
import 'package:zigdash/engine/automations_repo.dart';
import 'package:zigdash/engine/automations_screen.dart';
import 'package:zigdash/engine/engine_installer.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_setup.dart';
import 'package:zigdash/engine/engine_sheet.dart' show waitingRulesWait;
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/features/devices/devices_providers.dart' show homeBaseTopicProvider;
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/scenes/scenes_providers.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

import 'engine_test.dart' show FakeLink;

/// A connected broker that records what is published.
class RecordingManager extends MqttManager {
  RecordingManager()
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

  /// The rules published, in order: id and enabled.
  List<(String, bool)> get rules => [
        for (final p in published)
          if (p.$1.startsWith('zigdash/automations/rules/'))
            (p.$1.split('/').last, (jsonDecode(p.$2) as Map)['enabled'] as bool? ?? true),
      ];
}

class _Sink implements AnalyticsSink {
  final sent = <String>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

List<Z2mDevice> _devices() => parseBridgeDevices(jsonEncode([
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

Automation _rule(String id, {String name = 'Heater at 7', bool enabled = true}) => Automation(
      id: id,
      name: name,
      enabled: enabled,
      trigger: const TimeTrigger(at: '07:00'),
      action: const AutomationAction(
          kind: ActionKind.device, commands: [EngineCommand(ieee: '0xlight', payload: {'state': 'ON'})], label: 'Hallway light'),
    );

const _hub = HubInfo(version: '2.14.0', externalJsAllowed: true);

class _Rig {
  _Rig(this.prefs, this.mgr, this.link, this.sink);
  final SharedPreferences prefs;
  final RecordingManager mgr;
  final FakeLink link;
  final _Sink sink;

  List<String> get requests => [
        for (final p in link.published)
          if (p.$1.contains('/bridge/request/')) p.$1.split('/bridge/request/').last,
      ];
}

Future<_Rig> _pump(
  WidgetTester tester,
  Widget home, {
  required Stream<EngineView> Function() view,
  List<Automation> rules = const [],
  Stream<List<Automation>> Function()? rulesLater,
  Map<String, Object> prefs = const {},
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'analytics_consent': true, ...prefs});
  final p = await SharedPreferences.getInstance();
  final mgr = RecordingManager();
  final link = FakeLink();
  final sink = _Sink();
  link.onPublish = (topic, payload) {
    if (!topic.contains('/bridge/request/')) return;
    final what = topic.split('/bridge/request/').last;
    if (what == 'restart') {
      scheduleMicrotask(() {
        link.emit('zigbee2mqtt/bridge/state', '{"state":"offline"}');
        link.emit('zigbee2mqtt/bridge/state', '{"state":"online"}');
      });
      return;
    }
    final tx = (jsonDecode(payload) as Map)['transaction'];
    scheduleMicrotask(() =>
        link.emit('zigbee2mqtt/bridge/response/$what', jsonEncode({'status': 'ok', 'transaction': tx})));
  };
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      analyticsAvailableProvider.overrideWithValue(true),
      analyticsSinkProvider.overrideWithValue(sink),
      mqttManagerProvider.overrideWith((ref, _) async => mgr),
      homeBaseTopicProvider.overrideWith((ref, _) => 'zigbee2mqtt'),
      bridgeDevicesStreamProvider.overrideWith((ref, _) => Stream.value(_devices())),
      scenesForConnectionProvider.overrideWith((ref, _) => Stream.value(<Scene>[])),
      automationsRepoProvider.overrideWith((ref) => AutomationsRepo((_) async => mgr, p, timeZone: () async => 'UTC')),
      automationsProvider.overrideWith((ref, _) => rulesLater?.call() ?? Stream.value(rules)),
      automationRunsProvider.overrideWith((ref, _) => Stream.value(const [])),
      engineViewProvider.overrideWith((ref, _) => view()),
      engineInstallerProvider.overrideWith((ref, _) async => EngineInstaller(link, base: 'zigbee2mqtt')),
      engineSourceProvider.overrideWith((ref) async => "const ENGINE_VERSION = '3.4.5';"),
      connectionsStreamProvider.overrideWith((ref) => Stream.value(const [])),
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
  return _Rig(p, mgr, link, sink);
}

/// A "07:00 → Hallway light on" rule in the editor, then Save.
Future<void> _makeAndSave(WidgetTester tester) async {
  await tester.tap(find.text('A time comes'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.byKey(const Key('auto-action-device')), 200,
      scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('auto-action-device')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Hallway light').last);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('auto-save')));
  await tester.pump();
  // An empty broker: the rules' wait (waitingRulesWait) runs out first.
  await tester.pump(waitingRulesWait);
  await tester.pumpAndSettle();
}

/// The install's futures run partly outside the test's fake clock.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _end(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 4)); // the manager's unsubscribe grace
}

const _editor = AutomationEditorScreen(connectionId: 'c1');
Stream<EngineView> Function() _view(EngineView v) => () => Stream.value(v);

// 3.6.2: the Engine when it's needed, docs/design/engine-on-save-362.md.
void main() {
  group('saving without the Engine', () {
    testWidgets('the sheet says what the Engine is; Install and save installs, then the rule runs', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)));
      await _makeAndSave(tester);
      expect(find.textContaining('one open-source file'), findsOneWidget);
      expect(find.byKey(const Key('engine-source')), findsOneWidget);
      expect(rig.mgr.rules, isEmpty, reason: 'nothing saved before a choice');

      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await _settle(tester);
      expect(rig.mgr.rules.single.$2, isTrue);
      expect(rig.requests, ['extension/save']);
      expect(find.byKey(const Key('engine-sheet-install')), findsNothing);
      expect(rig.sink.sent, containsAll([
        'engine_setup {step: install_tapped, from: save, z2m: 2.14}',
        'engine_setup {step: installed, from: save, z2m: 2.14}',
      ]));
      expect(rig.sink.sent.where((e) => e.startsWith('automation_saved')).single, contains('running: yes'));
      await _end(tester);
    });

    testWidgets('Save without running keeps the rule on the broker, not running', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)));
      await _makeAndSave(tester);
      await tester.tap(find.byKey(const Key('engine-sheet-save')));
      await tester.pumpAndSettle();
      expect(rig.mgr.rules.single.$2, isTrue);
      expect(rig.requests, isEmpty);
      expect(rig.sink.sent.where((e) => e.startsWith('automation_saved')).single, contains('running: no'));
      await _end(tester);
    });

    testWidgets('closing the sheet saves nothing and stays in the editor', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)));
      await _makeAndSave(tester);
      await tester.tapAt(const Offset(20, 20)); // the barrier
      await tester.pumpAndSettle();
      expect(rig.mgr.rules, isEmpty);
      expect(find.byKey(const Key('auto-save')), findsOneWidget);
      await _end(tester);
    });

    testWidgets('add-ons blocked: the consent screen first; Not now keeps the rule, not running', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(
              phase: HubEnginePhase.needsConsent, hub: HubInfo(version: '2.14.0', externalJsAllowed: false))));
      await _makeAndSave(tester);
      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await tester.pumpAndSettle();
      expect(find.text('Zigbee2MQTT needs one setting changed'), findsOneWidget);
      expect(find.textContaining('30 seconds'), findsOneWidget);
      await tester.tap(find.byKey(const Key('engine-sheet-decline')));
      await tester.pumpAndSettle();
      expect(rig.mgr.rules.single.$2, isTrue);
      expect(rig.requests, isEmpty);
      expect(engineDeclined(rig.prefs, 'c1'), isTrue);
      expect(rig.sink.sent, contains('engine_setup {step: declined, from: save, z2m: 2.14}'));
      expect(rig.sink.sent.where((e) => e.startsWith('automation_saved')).single, contains('running: no'));
      await _end(tester);
    });

    testWidgets('add-ons blocked: allowed, Zigbee2MQTT restarts, then the Engine goes on', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(
              phase: HubEnginePhase.needsConsent, hub: HubInfo(version: '2.14.0', externalJsAllowed: false))));
      await _makeAndSave(tester);
      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('engine-sheet-consent')));
      await _settle(tester);
      expect(rig.requests, ['options', 'restart', 'extension/save']);
      expect(rig.sink.sent.where((e) => e.startsWith('automation_saved')).single, contains('running: yes'));
      await _end(tester);
    });

    testWidgets('Zigbee2MQTT too old: the update message, the rule kept', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(
              phase: HubEnginePhase.tooOld, hub: HubInfo(version: '2.3.0', externalJsAllowed: true))));
      await _makeAndSave(tester);
      expect(find.text('Zigbee2MQTT needs an update'), findsOneWidget);
      expect(find.textContaining('version 2.3.0'), findsOneWidget);
      expect(find.byKey(const Key('engine-sheet-install')), findsNothing);
      await tester.tap(find.byKey(const Key('engine-sheet-save')));
      await tester.pumpAndSettle();
      expect(rig.mgr.rules, hasLength(1));
      expect(rig.requests, isEmpty);
      await _end(tester);
    });

    testWidgets('away (through the relay), no Engine seen: nothing saved, made at home', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(phase: HubEnginePhase.unreachable, away: true)));
      await _makeAndSave(tester);
      expect(find.byKey(const Key('engine-sheet-save')), findsNothing);
      expect(find.textContaining('Make automations at home'), findsOneWidget);
      expect(rig.mgr.rules, isEmpty);
      expect(rig.requests, isEmpty);
      expect(rig.prefs.getKeys().where((k) => k.startsWith('automations.away')), isEmpty);
      await _end(tester);
    });

    testWidgets('"Not now" to add-ons kept: no install offered, the rule kept, not running', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(
              phase: HubEnginePhase.needsConsent,
              hub: HubInfo(version: '2.14.0', externalJsAllowed: false),
              declined: true)));
      await _makeAndSave(tester);
      expect(find.text('No automations on this hub'), findsOneWidget);
      expect(find.byKey(const Key('engine-sheet-install')), findsNothing);
      await tester.tap(find.byKey(const Key('engine-sheet-save')));
      await tester.pumpAndSettle();
      expect(rig.mgr.rules, hasLength(1));
      expect(rig.requests, isEmpty);
      await _end(tester);
    });

    testWidgets('add-ons blocked with rules waiting: switches first, then the consent screen, then the install',
        (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(
              phase: HubEnginePhase.needsConsent, hub: HubInfo(version: '2.14.0', externalJsAllowed: false))),
          rules: [_rule('old')]);
      await _makeAndSave(tester);
      await tester.tap(find.byKey(const Key('engine-waiting-old')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await tester.pumpAndSettle();
      expect(find.textContaining('30 seconds'), findsOneWidget);
      expect(rig.requests, isEmpty, reason: 'nothing on the hub before the consent');
      await tester.tap(find.byKey(const Key('engine-sheet-consent')));
      await _settle(tester);
      expect(rig.mgr.rules.first, ('old', false));
      expect(rig.requests, ['options', 'restart', 'extension/save']);
      await _end(tester);
    });

    testWidgets('rules waiting from before: a switch each; paused ones saved disabled before the install',
        (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)),
          rules: [_rule('old'), _rule('kept', name: 'Porch at dusk')]);
      await _makeAndSave(tester);
      expect(find.text('Heater at 7'), findsOneWidget);
      expect(find.text('Porch at dusk'), findsOneWidget);
      await tester.tap(find.byKey(const Key('engine-waiting-old')));
      await tester.pumpAndSettle();
      expect(find.text('Stays paused'), findsOneWidget);
      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await _settle(tester);
      expect(rig.mgr.rules.first, ('old', false));
      expect(rig.mgr.rules.where((r) => r.$1 == 'kept'), isEmpty, reason: 'unchanged, not re-saved');
      expect(rig.mgr.rules.last.$2, isTrue, reason: 'the new rule runs');
      expect(rig.requests, ['extension/save']);
      await _end(tester);
    });

    testWidgets('with the Engine running: saved straight away, running', (tester) async {
      final rig = await _pump(tester, _editor,
          view: _view(EngineView(
            phase: HubEnginePhase.running,
            hub: _hub,
            report: EngineReport(
                version: '3.4.5', runningOn: 'hub', rulesLoaded: 0, rulesUnknown: const [], stoppedSelf: false,
                at: DateTime(2026)),
          )));
      await _makeAndSave(tester);
      expect(find.byKey(const Key('engine-sheet-install')), findsNothing);
      expect(rig.mgr.rules, hasLength(1));
      expect(rig.sink.sent.where((e) => e.startsWith('automation_saved')).single, contains('running: yes'));
      await _end(tester);
    });
  });

  group('the Automations tab without the Engine', () {
    const tab = AutomationsScreen(connectionId: 'c1');

    testWidgets('the slim card and New automation, no install before there is a rule', (tester) async {
      final rig = await _pump(tester, tab, view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)));
      expect(find.byKey(const Key('engine-slim-card')), findsOneWidget);
      expect(find.textContaining('when you save your first one'), findsOneWidget);
      expect(find.byKey(const Key('engine-source')), findsOneWidget);
      expect(find.byKey(const Key('auto-new')), findsOneWidget);
      expect(find.byKey(const Key('engine-install')), findsNothing);
      expect(rig.sink.sent, contains('engine_setup {step: offered, from: automations, z2m: 2.14}'));
    });

    testWidgets('saved rules are listed under "None of these run yet"; Install asks about each, then installs',
        (tester) async {
      final rig = await _pump(tester, tab,
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)), rules: [_rule('old')]);
      expect(find.text('NONE OF THESE RUN YET'), findsOneWidget);
      expect(find.byKey(const Key('engine-slim-card')), findsNothing, reason: 'a rule waits: outdated');
      expect(find.textContaining('a broker without persistence'), findsOneWidget);
      expect(find.text('Not running'), findsOneWidget);
      await tester.tap(find.byKey(const Key('engine-install')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('engine-waiting-old')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await _settle(tester);
      expect(rig.mgr.rules, [('old', false)]);
      expect(rig.requests, ['extension/save']);
      expect(rig.sink.sent, containsAll([
        'engine_setup {step: install_tapped, from: automations, z2m: 2.14}',
        'engine_setup {step: installed, from: automations, z2m: 2.14}',
      ]));
    });

    testWidgets('Not now on the waiting rules installs nothing', (tester) async {
      final rig = await _pump(tester, tab,
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)), rules: [_rule('old')]);
      await tester.tap(find.byKey(const Key('engine-install')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('engine-sheet-save')));
      await tester.pumpAndSettle();
      expect(rig.requests, isEmpty);
      expect(rig.mgr.rules, isEmpty);
    });

    testWidgets('away, Engine never seen here: made at home; no New automation, no list', (tester) async {
      await _pump(tester, tab,
          view: _view(const EngineView(phase: HubEnginePhase.unreachable, away: true)), rules: [_rule('old')]);
      expect(find.byKey(const Key('engine-away-slim-card')), findsOneWidget);
      expect(find.textContaining('Make automations at home'), findsOneWidget);
      expect(find.byKey(const Key('auto-new')), findsNothing);
      expect(find.text('NONE OF THESE RUN YET'), findsNothing);
      expect(find.byKey(const Key('engine-install')), findsNothing);
      expect(find.byKey(const Key('engine-away-unreachable')), findsNothing);
    });

    testWidgets('away, Engine seen here before: the hub is unreachable, as before', (tester) async {
      await _pump(tester, tab,
          view: _view(const EngineView(phase: HubEnginePhase.unreachable, away: true)),
          prefs: {'engine.installed.c1': true});
      expect(find.byKey(const Key('engine-away-unreachable')), findsOneWidget);
      expect(find.byKey(const Key('auto-new')), findsNothing);
    });

    testWidgets('add-ons blocked with rules waiting: the consent screen, switches, then restart and install',
        (tester) async {
      final rig = await _pump(tester, tab,
          view: _view(const EngineView(
              phase: HubEnginePhase.needsConsent, hub: HubInfo(version: '2.14.0', externalJsAllowed: false))),
          rules: [_rule('old')]);
      expect(find.text('Zigbee2MQTT needs one setting changed'), findsOneWidget);
      expect(find.byKey(const Key('auto-new')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('engine-consent')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('engine-consent')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('engine-waiting-old')));
      await tester.pumpAndSettle();
      expect(rig.requests, isEmpty);
      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await _settle(tester);
      expect(rig.mgr.rules, [('old', false)]);
      expect(rig.requests, ['options', 'restart', 'extension/save']);
    });

    testWidgets('"Allow add-ons after all" goes back to the consent screen, nothing changed yet', (tester) async {
      final views = StreamController<EngineView>.broadcast();
      final rig = await _pump(tester, tab,
          view: () => views.stream,
          prefs: {'engine.declined.c1': true});
      const hub = HubInfo(version: '2.14.0', externalJsAllowed: false);
      views.add(const EngineView(phase: HubEnginePhase.needsConsent, hub: hub, declined: true));
      await tester.pump();
      await tester.tap(find.byKey(const Key('engine-allow-after-all')));
      await tester.pump();
      views.add(const EngineView(phase: HubEnginePhase.needsConsent, hub: hub));
      await tester.pump();
      expect(find.text('Zigbee2MQTT needs one setting changed'), findsOneWidget);
      expect(engineDeclined(rig.prefs, 'c1'), isFalse);
      expect(rig.requests, isEmpty);
      unawaited(views.close());
    });

    testWidgets('Zigbee2MQTT-page home: the broker step, no New automation', (tester) async {
      await _pump(tester, tab, view: _view(const EngineView(phase: HubEnginePhase.needsBroker)));
      expect(find.byKey(const Key('engine-needs-broker')), findsOneWidget);
      expect(find.byKey(const Key('auto-new')), findsNothing);
    });

    testWidgets('the free three still stop a 4th automation before the editor, Engine or not', (tester) async {
      await _pump(tester, tab,
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)),
          rules: [_rule('a'), _rule('b'), _rule('c')],
          extra: [proStatusProvider.overrideWithValue(ProStatus.locked)]);
      expect(find.text('3 of 3 free automations'), findsOneWidget);
      await tester.tap(find.byKey(const Key('auto-new')));
      await tester.pumpAndSettle();
      expect(find.text('3 automations are free. Want more?'), findsOneWidget);
      expect(find.text('New automation'), findsOneWidget, reason: 'the button, not the editor');
    });
  });

  // The History sheet and Alerts put the Engine on through ensureEngine.
  group('ensureEngine (History sheet, Alerts) with rules waiting', () {
    for (final from in [EngineFrom.history, EngineFrom.alerts]) {
      testWidgets('from ${from.name}: switches before the install; Not now installs nothing', (tester) async {
        EngineSetup? result;
        final opener = Consumer(builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await ensureEngine(context, ref, 'c1', from: from),
                child: const Text('set up'),
              ),
            ));
        final rig = await _pump(tester, opener,
            view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)), rules: [_rule('old')]);
        await tester.tap(find.text('set up'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('engine-waiting-old')), findsOneWidget);
        await tester.tap(find.byKey(const Key('engine-sheet-save'))); // Not now
        await tester.pumpAndSettle();
        expect(result, EngineSetup.cancelled);
        expect(rig.requests, isEmpty);

        await tester.tap(find.text('set up'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('engine-waiting-old')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('engine-sheet-install')));
        await _settle(tester);
        expect(result, EngineSetup.ready);
        expect(rig.mgr.rules, [('old', false)]);
        expect(rig.requests, ['extension/save']);
        expect(rig.sink.sent, contains('engine_setup {step: install_tapped, from: ${from.name}, z2m: 2.14}'));
      });
    }
  });

  // Re-review: the hub check can settle before the broker's retained rules
  // arrive; the install still waits for them (WaitingRulesWatch).
  group('rules arriving after the hub check', () {
    Stream<List<Automation>> late() async* {
      yield const [];
      await Future<void>.delayed(const Duration(seconds: 1));
      yield [_rule('old')];
    }

    Widget opener(void Function(EngineSetup) done) => Consumer(builder: (context, ref, _) => Scaffold(
          body: TextButton(
            onPressed: () async => done(await ensureEngine(context, ref, 'c1', from: EngineFrom.alerts)),
            child: const Text('set up'),
          ),
        ));

    testWidgets('the check settles first, the rules come 1 s later: the sheet still lists them', (tester) async {
      EngineSetup? result;
      final rig = await _pump(tester, opener((r) => result = r),
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)), rulesLater: late);
      await tester.tap(find.text('set up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('engine-waiting-old')), findsNothing);
      expect(rig.requests, isEmpty, reason: 'no install while the rules may still come');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('engine-waiting-old')), findsOneWidget);
      await tester.tap(find.byKey(const Key('engine-sheet-save'))); // Not now
      await tester.pumpAndSettle();
      expect(result, EngineSetup.cancelled);
      expect(rig.requests, isEmpty);
    });

    testWidgets('an empty broker: the install goes on after about 2 s, no sheet', (tester) async {
      EngineSetup? result;
      final rig = await _pump(tester, opener((r) => result = r),
          view: _view(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub)));
      await tester.tap(find.text('set up'));
      await tester.pump();
      expect(rig.requests, isEmpty);
      await tester.pump(waitingRulesWait);
      await _settle(tester);
      expect(find.byKey(const Key('engine-sheet-install')), findsNothing);
      expect(rig.requests, ['extension/save']);
      expect(result, EngineSetup.ready);
    });
  });

  group('the hub check (20 s) and why', () {
    Future<EngineCheck> check(WidgetTester tester, Stream<EngineView> Function() view) async {
      late WidgetRef ref;
      SharedPreferences.setMockInitialValues({});
      final p = await SharedPreferences.getInstance();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(p),
          engineViewProvider.overrideWith((r, _) => view()),
        ],
        child: Consumer(builder: (_, r, __) {
          ref = r;
          return const SizedBox();
        }),
      ));
      EngineCheck? out;
      unawaited(checkEngine(ref, 'c1').then((c) => out = c));
      await tester.pump(const Duration(seconds: 19));
      expect(out, isNull, reason: 'still waiting at 19 s');
      await tester.pump(const Duration(seconds: 2));
      return out!;
    }

    testWidgets('a silent hub: no_info', (tester) async {
      final c = await check(
          tester, () => Stream.value(const EngineView(phase: HubEnginePhase.checking, connected: true)));
      expect(c.view, isNull);
      expect(engineWhy(c), EngineWhy.noInfo);
    });

    testWidgets('bridge/info but no bridge/extensions: no_extensions', (tester) async {
      final c = await check(
          tester, () => Stream.value(const EngineView(phase: HubEnginePhase.checking, hub: _hub, connected: true)));
      expect(engineWhy(c), EngineWhy.noExtensions);
    });

    // 3.8.8: a broker that never connected (the friend's case).
    testWidgets('a broker never connected: no_connection', (tester) async {
      final c = await check(tester, () => Stream.value(const EngineView(phase: HubEnginePhase.checking)));
      expect(c.view, isNull);
      expect(engineWhy(c), EngineWhy.noConnection);
    });

    testWidgets('through the relay: unreachable after 15 s, inside the wait: relay', (tester) async {
      late WidgetRef ref;
      SharedPreferences.setMockInitialValues({});
      final p = await SharedPreferences.getInstance();
      final views = StreamController<EngineView>();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(p),
          engineViewProvider.overrideWith((r, _) => views.stream),
        ],
        child: Consumer(builder: (_, r, __) {
          ref = r;
          return const SizedBox();
        }),
      ));
      EngineCheck? out;
      unawaited(checkEngine(ref, 'c1').then((c) => out = c));
      views.add(const EngineView(phase: HubEnginePhase.checking, away: true));
      await tester.pump(const Duration(seconds: 15));
      expect(out, isNull, reason: 'the old 8 s wait would have given up here');
      views.add(const EngineView(phase: HubEnginePhase.unreachable, away: true));
      await tester.pump(const Duration(milliseconds: 200));
      expect(out!.view?.phase, HubEnginePhase.unreachable);
      expect(engineWhy(out!), EngineWhy.relay);
      unawaited(views.close());
    });

    test('settled phases and install answers', () {
      EngineWhy why(HubEnginePhase phase) => engineWhy((view: EngineView(phase: phase), last: null));
      expect(why(HubEnginePhase.tooOld), EngineWhy.tooOld);
      expect(why(HubEnginePhase.needsConsent), EngineWhy.blocked);
      expect(installWhy(HubAnswer.refused), EngineWhy.refused);
      expect(installWhy(HubAnswer.noAnswer), EngineWhy.noAnswer);
      expect(engineWhy((view: null, last: null)), EngineWhy.noConnection);
    });

    // 3.8.8: why a timed-out check gave up, from the last view seen.
    test('timed out: why from the last view', () {
      EngineWhy why(EngineView? last) => engineWhy((view: null, last: last));
      const checking = HubEnginePhase.checking;
      expect(why(null), EngineWhy.noConnection);
      expect(why(const EngineView(phase: checking)), EngineWhy.noConnection);
      expect(why(const EngineView(phase: checking, connected: true)), EngineWhy.noInfo);
      expect(why(const EngineView(phase: checking, hub: _hub, connected: true)), EngineWhy.noExtensions);
      expect(why(const EngineView(phase: checking, hub: _hub, connected: true, heardExtensions: true)),
          EngineWhy.other);
      expect(why(const EngineView(phase: checking, away: true)), EngineWhy.relay);
      expect(why(const EngineView(phase: checking, away: true, connected: true)), EngineWhy.relay);
    });

    test('the source link names a release tag, never main', () {
      expect(engineSourceUrl.toString(), 'https://github.com/giladtamam/zigdash/blob/v3.7.0/hub/zigdash-engine.js');
    });
  });
}
