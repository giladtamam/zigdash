import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/engine/automation.dart';
import 'package:zigdash/engine/automations_repo.dart';
import 'package:zigdash/engine/engine_installer.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/features/dashboards/widgets/history_on_card.dart';
import 'package:zigdash/features/history/history_service.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/features/onboarding/setup/setup_completed_at.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

import '../../engine/engine_on_save_test.dart' show RecordingManager;
import '../../engine/engine_test.dart' show FakeLink;

class _Sink implements AnalyticsSink {
  final sent = <String>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

class _History implements HistoryService {
  final published = <String>[];
  @override
  Future<bool> publishConfig(String connectionId, {String? current}) async {
    published.add(connectionId);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Repo implements ConnectionRepo {
  _Repo(this.home);
  final Connection home;
  @override
  Future<Connection?> getById(String id) async => home;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Connection _home(String host, {ConnectionTransport? transport}) => Connection(
  transport: transport ?? ConnectionTransport.mqtt,
  id: 'c1',
  name: 'Home',
  host: host,
  port: 1883,
  protocol: MqttProtocol.tcp,
  keepAliveSeconds: 60,
  autoConnect: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

const _hub = HubInfo(version: '2.14.0', externalJsAllowed: true);
const _title = 'See your home over days';

class _Rig {
  _Rig(this.prefs, this.sink, this.link, this.history, this.mgr);
  final SharedPreferences prefs;
  final _Sink sink;
  final FakeLink link;
  final _History history;
  final RecordingManager mgr;
}

Future<_Rig> _pump(
  WidgetTester tester, {
  EngineView view = const EngineView(
    phase: HubEnginePhase.notInstalled,
    hub: _hub,
  ),
  bool? online,
  Map<String, Object> prefs = const {'analytics_consent': true},
  String host = '192.168.1.2',
  ConnectionTransport? transport,
  bool answerInstall = true,
  List<Automation> rules = const [],
  Stream<EngineView> Function()? views,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final mgr = RecordingManager();
  final sink = _Sink();
  final link = FakeLink();
  final history = _History();
  final home = _home(host, transport: transport);
  link.onPublish = (topic, payload) {
    if (!answerInstall) return;
    final what = topic.split('/bridge/request/').last;
    final tx = (jsonDecode(payload) as Map)['transaction'];
    link.emit(
      'zigbee2mqtt/bridge/response/$what',
      jsonEncode({'status': 'ok', 'transaction': tx}),
    );
  };
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        analyticsAvailableProvider.overrideWithValue(true),
        analyticsSinkProvider.overrideWithValue(sink),
        connectionByIdProvider.overrideWith((ref, _) async => home),
        connectionRepoProvider.overrideWithValue(_Repo(home)),
        historyRecorderOnlineProvider.overrideWith(
          (ref, _) =>
              online == null ? const Stream.empty() : Stream.value(online),
        ),
        engineViewProvider.overrideWith(
          (ref, _) => views?.call() ?? Stream.value(view),
        ),
        engineInstallerProvider.overrideWith(
          (ref, _) async => EngineInstaller(link, base: 'zigbee2mqtt'),
        ),
        engineSourceProvider.overrideWith((ref) async => '// engine'),
        historyServiceProvider.overrideWithValue(history),
        // 3.6.2: rules waiting for the Engine are asked about first.
        automationsProvider.overrideWith((ref, _) => Stream.value(rules)),
        automationsRepoProvider.overrideWith(
          (ref) => AutomationsRepo((_) async => mgr, p, timeZone: () async => 'UTC'),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: HistoryOnCard(connectionId: 'c1')),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(historyOnGrace);
  await tester.pump();
  return _Rig(p, sink, link, history, mgr);
}

// 3.6: Turn on History, docs/design/pro-trial-360.md §2.
void main() {
  testWidgets('offered once the hub shows no recorder, counted once', (
    tester,
  ) async {
    final rig = await _pump(tester);
    expect(find.text(_title), findsOneWidget);
    expect(rig.sink.sent, ['history_on {step: shown, from: card}']);
  });

  testWidgets('right after setup it counts as from: finish', (tester) async {
    final rig = await _pump(
      tester,
      prefs: {
        'analytics_consent': true,
        kSetupCompletedAtMs: DateTime.now().millisecondsSinceEpoch,
      },
    );
    expect(rig.sink.sent, ['history_on {step: shown, from: finish}']);
  });

  testWidgets('not when a recorder already runs', (tester) async {
    await _pump(tester, online: true);
    expect(find.text(_title), findsNothing);
  });

  testWidgets('not on the demo, nor before the usage-data question', (
    tester,
  ) async {
    await _pump(tester, host: demoHost);
    expect(find.text(_title), findsNothing);
  });

  testWidgets('waits while the usage-data question is open', (tester) async {
    await _pump(tester, prefs: const {});
    expect(find.text(_title), findsNothing);
  });

  testWidgets('broker: installs the Engine, publishes the readings', (
    tester,
  ) async {
    final rig = await _pump(tester);
    await tester.tap(find.byKey(const Key('history-on-turn-on')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The install's futures run partly outside the test's fake clock.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      rig.link.published.map((p) => p.$1),
      contains('zigbee2mqtt/bridge/request/extension/save'),
    );
    expect(rig.history.published, ['c1']);
    expect(find.textContaining('Recording.'), findsOneWidget);
    expect(rig.prefs.getString(historyOnDoneKey('c1')), '1');
    expect(
      rig.sink.sent,
      containsAll([
        'history_on {step: tapped, from: card}',
        'engine_setup {step: installed, from: history_on, z2m: 2.14}',
        'history_setup {result: installed, from: card}',
      ]),
    );
  });

  testWidgets('add-ons blocked: asks in its own words; Not now remembers', (
    tester,
  ) async {
    final rig = await _pump(
      tester,
      view: const EngineView(
        phase: HubEnginePhase.needsConsent,
        hub: HubInfo(version: '2.14.0', externalJsAllowed: false),
      ),
    );
    await tester.tap(find.byKey(const Key('history-on-turn-on')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Allow external JavaScript'), findsOneWidget);
    expect(find.textContaining('30 seconds'), findsOneWidget);
    expect(
      rig.sink.sent,
      contains('history_on {step: consent_shown, from: card}'),
    );
    await tester.tap(find.byKey(const Key('history-on-decline')));
    await tester.pumpAndSettle();
    expect(engineDeclined(rig.prefs, 'c1'), isTrue);
    expect(rig.prefs.getString(historyOnDoneKey('c1')), '1');
    expect(find.text(_title), findsNothing);
  });

  testWidgets('hub too old: offers this phone, which then records', (
    tester,
  ) async {
    final rig = await _pump(
      tester,
      view: const EngineView(
        phase: HubEnginePhase.tooOld,
        hub: HubInfo(version: '2.3.0', externalJsAllowed: true),
      ),
    );
    await tester.tap(find.byKey(const Key('history-on-turn-on')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-on-phone')), findsOneWidget);
    await tester.tap(find.byKey(const Key('history-on-phone')));
    await tester.pumpAndSettle();
    expect(rig.prefs.getBool('history_record_here_c1'), isTrue);
    expect(
      rig.sink.sent,
      contains('history_setup {result: this_device, from: card}'),
    );
    expect(find.textContaining('This device records history'), findsOneWidget);
  });

  testWidgets('Zigbee2MQTT page: asks for the broker, no phone fallback', (
    tester,
  ) async {
    await _pump(tester, transport: ConnectionTransport.z2mPage);
    await tester.tap(find.byKey(const Key('history-on-turn-on')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-on-broker')), findsOneWidget);
    expect(find.byKey(const Key('history-on-phone')), findsNothing);
  });

  testWidgets('Not now puts it away for the Home', (tester) async {
    final rig = await _pump(tester);
    await tester.tap(find.byKey(const Key('history-on-later')));
    await tester.pumpAndSettle();
    expect(find.text(_title), findsNothing);
    expect(rig.prefs.getString(historyOnDoneKey('c1')), '1');
    expect(rig.sink.sent.last, 'history_on {step: later, from: card}');
  });

  group('3.6.2: the hub check waits 20 s and says why', () {
    Future<_Rig> silent(WidgetTester tester, EngineView view) async {
      final rig = await _pump(tester, views: () => Stream.value(view));
      await tester.tap(find.byKey(const Key('history-on-turn-on')));
      await tester.pump();
      expect(find.text('Checking your hub…'), findsOneWidget);
      expect(find.byKey(const Key('history-on-use-phone')), findsOneWidget);
      await tester.pump(const Duration(seconds: 19));
      expect(find.byKey(const Key('history-on-phone')), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.byKey(const Key('history-on-phone')), findsOneWidget);
      return rig;
    }

    testWidgets('a silent hub: failed, why no_info; this phone offered', (
      tester,
    ) async {
      final rig = await silent(
        tester,
        const EngineView(phase: HubEnginePhase.checking),
      );
      expect(
        rig.sink.sent,
        contains('history_setup {result: failed, from: card, why: no_info}'),
      );
    });

    testWidgets('info without extensions: why no_extensions', (tester) async {
      final rig = await silent(
        tester,
        const EngineView(phase: HubEnginePhase.checking, hub: _hub),
      );
      expect(
        rig.sink.sent,
        contains(
          'history_setup {result: failed, from: card, why: no_extensions}',
        ),
      );
    });

    testWidgets('through the relay: why relay', (tester) async {
      final rig = await _pump(
        tester,
        view: const EngineView(phase: HubEnginePhase.unreachable, away: true),
      );
      await tester.tap(find.byKey(const Key('history-on-turn-on')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('history-on-phone')), findsOneWidget);
      expect(
        rig.sink.sent,
        contains('history_setup {result: failed, from: card, why: relay}'),
      );
    });

    testWidgets('Use this phone instead while the hub is checked', (
      tester,
    ) async {
      final rig = await _pump(
        tester,
        views: () =>
            Stream.value(const EngineView(phase: HubEnginePhase.checking)),
      );
      await tester.tap(find.byKey(const Key('history-on-turn-on')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('history-on-use-phone')));
      await tester.pump();
      await tester.pump();
      expect(rig.prefs.getBool('history_record_here_c1'), isTrue);
      expect(find.textContaining('This device records history'), findsOneWidget);
      // The check ends later: nothing else happens.
      await tester.pump(const Duration(seconds: 21));
      await tester.pump();
      expect(find.textContaining('This device records history'), findsOneWidget);
      expect(rig.link.published, isEmpty);
      expect(
        rig.sink.sent.where((e) => e.contains('result: failed')),
        isEmpty,
      );
      expect(
        rig.sink.sent,
        contains('history_setup {result: this_device, from: card}'),
      );
    });

    testWidgets('rules waiting for the Engine: asked about before the install', (
      tester,
    ) async {
      final rig = await _pump(
        tester,
        rules: [
          const Automation(
            id: 'heater',
            name: 'Heater at 7',
            enabled: true,
            trigger: TimeTrigger(at: '07:00'),
            action: AutomationAction(
              kind: ActionKind.device,
              commands: [
                EngineCommand(ieee: '0xh', payload: {'state': 'ON'}),
              ],
            ),
          ),
        ],
      );
      await tester.tap(find.byKey(const Key('history-on-turn-on')));
      // The card's progress spins under the sheet: no pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Heater at 7'), findsOneWidget);
      expect(rig.link.published, isEmpty, reason: 'nothing before a tap');
      await tester.tap(find.byKey(const Key('engine-waiting-heater')));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(rig.mgr.rules, [('heater', false)]);
      expect(
        rig.link.published.map((p) => p.$1),
        contains('zigbee2mqtt/bridge/request/extension/save'),
      );
      expect(
        rig.sink.sent,
        contains('engine_setup {step: install_tapped, from: history_on, z2m: 2.14}'),
      );
    });
  });

  group('3.6.2: consent and rules waiting for the Engine', () {
    const blocked = EngineView(
      phase: HubEnginePhase.needsConsent,
      hub: HubInfo(version: '2.14.0', externalJsAllowed: false),
    );
    const heater = Automation(
      id: 'heater',
      name: 'Heater at 7',
      enabled: true,
      trigger: TimeTrigger(at: '07:00'),
      action: AutomationAction(
        kind: ActionKind.device,
        commands: [
          EngineCommand(ieee: '0xh', payload: {'state': 'ON'}),
        ],
      ),
    );

    Future<_Rig> toConsent(WidgetTester tester) async {
      final rig = await _pump(tester, view: blocked, rules: [heater]);
      await tester.tap(find.byKey(const Key('history-on-turn-on')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('history-on-allow')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('engine-waiting-heater')), findsOneWidget);
      return rig;
    }

    testWidgets('Allow: the waiting rules first; Not now goes back to the offer', (
      tester,
    ) async {
      final rig = await toConsent(tester);
      await tester.tap(find.byKey(const Key('engine-sheet-save')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('history-on-turn-on')), findsOneWidget);
      expect(rig.link.published, isEmpty);
    });

    testWidgets('Allow: a rule kept paused is saved disabled before the restart', (
      tester,
    ) async {
      final rig = await toConsent(tester);
      await tester.tap(find.byKey(const Key('engine-waiting-heater')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('engine-sheet-install')));
      await tester.pump();
      expect(rig.mgr.rules, [('heater', false)]);
      expect(
        rig.link.published.map((p) => p.$1).first,
        'zigbee2mqtt/bridge/request/options',
      );
    });

    testWidgets('"Not now" to add-ons kept on this phone: this phone instead', (
      tester,
    ) async {
      final rig = await _pump(
        tester,
        view: const EngineView(
          phase: HubEnginePhase.needsConsent,
          hub: HubInfo(version: '2.14.0', externalJsAllowed: false),
          declined: true,
        ),
      );
      await tester.tap(find.byKey(const Key('history-on-turn-on')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('history-on-allow')), findsNothing);
      expect(find.byKey(const Key('history-on-phone')), findsOneWidget);
      expect(
        rig.sink.sent,
        contains('history_setup {result: failed, from: card, why: blocked}'),
      );
    });
  });

  testWidgets('a Home already recording on this phone is not asked', (
    tester,
  ) async {
    await _pump(
      tester,
      prefs: {'analytics_consent': true, 'history_record_here_c1': true},
    );
    expect(find.text(_title), findsNothing);
  });
}
