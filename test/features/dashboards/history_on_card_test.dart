import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/engine/engine_installer.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/features/dashboards/widgets/history_on_card.dart';
import 'package:zigdash/features/history/history_service.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/features/onboarding/setup/setup_completed_at.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

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
  _Rig(this.prefs, this.sink, this.link, this.history);
  final SharedPreferences prefs;
  final _Sink sink;
  final FakeLink link;
  final _History history;
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
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
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
        engineViewProvider.overrideWith((ref, _) => Stream.value(view)),
        engineInstallerProvider.overrideWith(
          (ref, _) async => EngineInstaller(link, base: 'zigbee2mqtt'),
        ),
        engineSourceProvider.overrideWith((ref) async => '// engine'),
        historyServiceProvider.overrideWithValue(history),
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
  return _Rig(p, sink, link, history);
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
