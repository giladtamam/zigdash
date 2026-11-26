import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/alerts/alerts_service.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/engine/automations_repo.dart';
import 'package:zigdash/engine/automations_screen.dart';
import 'package:zigdash/engine/engine_installer.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/features/devices/devices_providers.dart' show homeBaseTopicProvider;
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

import 'engine_test.dart' show FakeLink;

const _id = 'home-1';

Future<FakeLink> _pump(WidgetTester tester, EngineView view, {Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final link = FakeLink();
  link.onPublish = (topic, payload) {
    if (topic.endsWith('/bridge/request/extension/save')) {
      final tx = (jsonDecode(payload) as Map)['transaction'];
      scheduleMicrotask(() => link.emit('zigbee2mqtt/bridge/response/extension/save',
          jsonEncode({'status': 'ok', 'transaction': tx})));
    }
  };
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      engineViewProvider.overrideWith((ref, _) => Stream.value(view)),
      engineInstallerProvider.overrideWith((ref, _) async => EngineInstaller(link, base: 'zigbee2mqtt')),
      engineSourceProvider.overrideWith((ref) async => "const ENGINE_VERSION = '3.0.0';"),
      automationsProvider.overrideWith((ref, _) => Stream.value(const [])),
      automationRunsProvider.overrideWith((ref, _) => Stream.value(const [])),
      alertsConfigProvider.overrideWith((ref, _) => Stream.value(null)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AutomationsScreen(connectionId: _id),
    ),
  ));
  await tester.pumpAndSettle();
  return link;
}

const _hub = HubInfo(version: '2.8.0', externalJsAllowed: true);

class _Sink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

/// Answers an install with [answer], whenever the test completes it.
class _SlowInstaller extends EngineInstaller {
  _SlowInstaller(FakeLink super.link, this.answer) : super(base: 'zigbee2mqtt');
  final Future<(HubAnswer, String?)> answer;
  @override
  Future<(HubAnswer, String?)> install(String source) => answer;
}

/// 3.8.8: a live view the test drives. Each build of the view (the first
/// one, then one per invalidate) gets its own controller in [builds].
class _Live {
  final builds = <StreamController<EngineView>>[];
  final sink = _Sink();
  final link = FakeLink();
  late ProviderContainer container;

  StreamController<EngineView> get now => builds.last;

  List<String> timeouts() => [
        for (final (name, props) in sink.sent)
          if (name == 'engine_setup' && props['step'] == 'check_timeout') props['why']!,
      ];

  void invalidate() => container.invalidate(engineViewProvider(_id));
}

/// Never settles: "Checking your hub…" spins. [before] runs on the
/// container before the screen mounts.
Future<_Live> _pumpLive(WidgetTester tester,
    {EngineView? first, void Function(_Live)? before, EngineInstaller Function(FakeLink)? installer}) async {
  SharedPreferences.setMockInitialValues({});
  final p = await SharedPreferences.getInstance();
  final live = _Live();
  live.container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(p),
    analyticsProvider.overrideWithValue(Analytics(live.sink, enabled: true)),
    homeBaseTopicProvider.overrideWith((ref, _) => 'home/z2m'),
    engineViewProvider.overrideWith((ref, _) {
      final c = StreamController<EngineView>();
      live.builds.add(c);
      ref.onDispose(c.close);
      return c.stream;
    }),
    engineInstallerProvider.overrideWith(
        (ref, _) async => installer?.call(live.link) ?? EngineInstaller(live.link, base: 'zigbee2mqtt')),
    engineSourceProvider.overrideWith((ref) async => "const ENGINE_VERSION = '3.0.0';"),
    automationsProvider.overrideWith((ref, _) => Stream.value(const [])),
    automationRunsProvider.overrideWith((ref, _) => Stream.value(const [])),
    alertsConfigProvider.overrideWith((ref, _) => Stream.value(null)),
  ]);
  addTearDown(live.container.dispose);
  before?.call(live);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: live.container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AutomationsScreen(connectionId: _id),
    ),
  ));
  if (first != null) live.now.add(first);
  await tester.pump();
  return live;
}

const _checking = EngineView(phase: HubEnginePhase.checking);
const _silent = EngineView(phase: HubEnginePhase.checking, connected: true);
const _noExtensions = EngineView(phase: HubEnginePhase.checking, hub: _hub, connected: true);

void main() {
  // 3.6.2: make the automation first; the install moved to saving it
  // (engine_on_save_test.dart).
  testWidgets('not installed: the slim card and New automation, no install yet', (tester) async {
    final link = await _pump(tester, const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub));
    expect(find.textContaining('ZigDash puts it there when you save your first one'), findsOneWidget);
    expect(find.byKey(const Key('auto-new')), findsOneWidget);
    expect(find.byKey(const Key('engine-install')), findsNothing);
    expect(link.published, isEmpty);
  });

  testWidgets('needs consent: says what happens; Not now remembers the answer', (tester) async {
    await _pump(tester, const EngineView(phase: HubEnginePhase.needsConsent, hub: _hub));
    expect(find.text('Zigbee2MQTT needs one setting changed'), findsOneWidget);
    expect(find.textContaining('30 seconds'), findsOneWidget);
    await tester.tap(find.byKey(const Key('engine-decline')));
    await tester.pumpAndSettle();
    final p = await SharedPreferences.getInstance();
    expect(engineDeclined(p, _id), isTrue);
  });

  testWidgets('declined: plain "no automations" with a way back', (tester) async {
    await _pump(tester, const EngineView(phase: HubEnginePhase.needsConsent, hub: _hub, declined: true));
    expect(find.text('No automations on this hub'), findsOneWidget);
    expect(find.byKey(const Key('engine-allow-after-all')), findsOneWidget);
  });

  testWidgets('too old names the version', (tester) async {
    await _pump(tester, const EngineView(
        phase: HubEnginePhase.tooOld, hub: HubInfo(version: '2.2.0', externalJsAllowed: true)));
    expect(find.textContaining('version 2.2.0'), findsOneWidget);
  });

  testWidgets('paused offers a reinstall', (tester) async {
    await _pump(tester, const EngineView(phase: HubEnginePhase.paused, hub: _hub));
    expect(find.text('Automations paused'), findsOneWidget);
    expect(find.text('Reinstall on hub'), findsOneWidget);
  });

  testWidgets('stopped itself offers Start again', (tester) async {
    final link = await _pump(tester, const EngineView(phase: HubEnginePhase.stoppedSelf, hub: _hub));
    expect(find.text('Automations paused: ZigDash Engine stopped itself'), findsOneWidget);
    await tester.tap(find.text('Start again'));
    await tester.pumpAndSettle();
    expect(link.published.single.$1, EngineTopics.control);
  });

  testWidgets('running shows the hub pill, rule count and a wrong hub clock', (tester) async {
    await _pump(
        tester,
        EngineView(
          phase: HubEnginePhase.running,
          hub: _hub,
          clockOff: true,
          report: EngineReport(
              version: '3.0.0', runningOn: 'hub', rulesLoaded: 2, rulesUnknown: const [],
              stoppedSelf: false, at: DateTime(2026)),
        ));
    expect(find.text('Running on hub'), findsOneWidget);
    expect(find.textContaining('more than five minutes off'), findsOneWidget);
  });

  const running = EngineView(phase: HubEnginePhase.running, hub: _hub);

  testWidgets('running without alerts points to Alerts; Not now hides it for good', (tester) async {
    await _pump(tester, running);
    expect(find.byKey(const Key('alerts-hint')), findsOneWidget);
    expect(find.text('Set up Alerts'), findsOneWidget);
    await tester.tap(find.byKey(const Key('alerts-hint-dismiss')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('alerts-hint')), findsNothing);
    final p = await SharedPreferences.getInstance();
    expect(p.getBool('alerts.hint_dismissed.$_id'), isTrue);
  });

  testWidgets('the Alerts hint stays hidden once dismissed', (tester) async {
    await _pump(tester, running, prefs: {'alerts.hint_dismissed.$_id': true});
    expect(find.byKey(const Key('alerts-hint')), findsNothing);
  });

  testWidgets('no Alerts hint before the Engine runs', (tester) async {
    await _pump(tester, const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub));
    expect(find.byKey(const Key('alerts-hint')), findsNothing);
  });

  // -----------------------------------------------------------------------
  // 3.8.8: the hub check gives up after 20 s (engine-check-timeout.md)
  // -----------------------------------------------------------------------

  group('the hub check gives up after 20 s', () {
    testWidgets('a broker that never connected: no connection, not before 20 s', (tester) async {
      final live = await _pumpLive(tester, first: _checking);
      expect(find.text('Checking your hub…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 19));
      expect(find.byKey(const Key('engine-check-noConnection')), findsNothing);
      expect(live.timeouts(), isEmpty);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key('engine-check-noConnection')), findsOneWidget);
      expect(find.text("Can't reach your hub's broker"), findsOneWidget);
      expect(find.text('Checking your hub…'), findsNothing);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Broker settings'), findsOneWidget);
      expect(live.timeouts(), ['no_connection']);
      final event = live.sink.sent.singleWhere((e) => e.$2['step'] == 'check_timeout');
      expect(event.$2, {'step': 'check_timeout', 'from': 'automations', 'why': 'no_connection'});
    });

    testWidgets('connected, Zigbee2MQTT silent: no info, with the base topic', (tester) async {
      final live = await _pumpLive(tester, first: _silent);
      await tester.pump(const Duration(seconds: 21));
      expect(find.text("Zigbee2MQTT isn't answering"), findsOneWidget);
      expect(find.textContaining('"home/z2m"'), findsOneWidget);
      expect(find.text('Broker settings'), findsOneWidget);
      expect(live.timeouts(), ['no_info']);
    });

    testWidgets('bridge/info without extensions: no extensions, Try again only', (tester) async {
      final live = await _pumpLive(tester, first: _noExtensions);
      await tester.pump(const Duration(seconds: 21));
      expect(find.text("Zigbee2MQTT didn't finish answering"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Broker settings'), findsNothing);
      expect(live.timeouts(), ['no_extensions']);
      expect(live.sink.sent.singleWhere((e) => e.$2['step'] == 'check_timeout').$2['z2m'], '2.8');
    });

    testWidgets('a bare spinner (no manager yet) gives up too: no connection', (tester) async {
      final live = await _pumpLive(tester);
      await tester.pump(const Duration(seconds: 21));
      expect(find.byKey(const Key('engine-check-noConnection')), findsOneWidget);
      expect(live.timeouts(), ['no_connection']);
    });

    testWidgets('the hub answers after the message: the offer, no message', (tester) async {
      final live = await _pumpLive(tester, first: _silent);
      await tester.pump(const Duration(seconds: 21));
      expect(find.byKey(const Key('engine-check-noInfo')), findsOneWidget);
      live.now.add(const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub, connected: true));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('engine-check-noInfo')), findsNothing);
      expect(find.byKey(const Key('engine-slim-card')), findsOneWidget);
    });

    testWidgets('an invalidate after the message hides it and waits 20 s again', (tester) async {
      final live = await _pumpLive(tester, first: _silent);
      await tester.pump(const Duration(seconds: 21));
      expect(find.byKey(const Key('engine-check-noInfo')), findsOneWidget);
      live.invalidate();
      await tester.pump();
      final view = live.container.read(engineViewProvider(_id));
      expect(view.isLoading && view.hasValue, isTrue, reason: 'Riverpod keeps the old value while reloading');
      expect(find.byKey(const Key('engine-check-noInfo')), findsNothing);
      expect(find.text('Checking your hub…'), findsOneWidget);
      live.now.add(_silent);
      await tester.pump(const Duration(seconds: 19));
      expect(find.byKey(const Key('engine-check-noInfo')), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key('engine-check-noInfo')), findsOneWidget);
    });

    testWidgets('Try again hides the message and waits 20 s again', (tester) async {
      final live = await _pumpLive(tester, first: _noExtensions);
      await tester.pump(const Duration(seconds: 21));
      await tester.tap(find.byKey(const Key('engine-check-again')));
      await tester.pump();
      expect(live.builds, hasLength(2));
      expect(find.byKey(const Key('engine-check-noExtensions')), findsNothing);
      live.now.add(_noExtensions);
      await tester.pump(const Duration(seconds: 19));
      expect(find.byKey(const Key('engine-check-noExtensions')), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key('engine-check-noExtensions')), findsOneWidget);
    });

    testWidgets('a reload that never emits: no connection, not the kept value', (tester) async {
      final live = await _pumpLive(tester, first: _silent);
      await tester.pump(const Duration(seconds: 5));
      live.invalidate();
      await tester.pump();
      await tester.pump(const Duration(seconds: 19));
      expect(find.byKey(const Key('engine-check-noConnection')), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key('engine-check-noConnection')), findsOneWidget);
      expect(find.byKey(const Key('engine-check-noInfo')), findsNothing);
      expect(live.timeouts(), ['no_connection']);
    });

    testWidgets('a view already live and checking before the screen: no info after 20 s', (tester) async {
      final live = await _pumpLive(tester, before: (live) {
        live.container.listen(engineViewProvider(_id), (_, __) {});
        live.now.add(_silent);
      });
      expect(live.builds, hasLength(1));
      await tester.pump(const Duration(seconds: 19));
      expect(find.byKey(const Key('engine-check-noInfo')), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key('engine-check-noInfo')), findsOneWidget);
    });

    testWidgets('two Try agains with the same outcome: one check_timeout', (tester) async {
      final live = await _pumpLive(tester, first: _silent);
      for (var i = 0; i < 2; i++) {
        await tester.pump(const Duration(seconds: 21));
        expect(find.byKey(const Key('engine-check-noInfo')), findsOneWidget);
        await tester.tap(find.byKey(const Key('engine-check-again')));
        await tester.pump();
        live.now.add(_silent);
      }
      await tester.pump(const Duration(seconds: 21));
      expect(find.byKey(const Key('engine-check-noInfo')), findsOneWidget);
      expect(live.timeouts(), ['no_info']);
    });

    testWidgets('busy during the 20 s: the message after busy ends, if still checking', (tester) async {
      // Zigbee2MQTT answers the install when the test says: busy until then.
      final answer = Completer<(HubAnswer, String?)>();
      final live = await _pumpLive(tester,
          first: const EngineView(phase: HubEnginePhase.paused, hub: _hub, connected: true),
          installer: (link) => _SlowInstaller(link, answer.future));
      await tester.tap(find.text('Reinstall on hub'));
      await tester.pump();
      live.now.add(_silent);
      await tester.pump();
      expect(find.text('Installing on your hub…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 21));
      expect(find.byKey(const Key('engine-check-noInfo')), findsNothing, reason: 'busy at 20 s');
      expect(live.timeouts(), isEmpty);
      await tester.pump(const Duration(seconds: 9));
      answer.complete((HubAnswer.refused, 'busy'));
      await tester.pump();
      expect(find.text('Installing on your hub…'), findsNothing, reason: 'Zigbee2MQTT answered at 30 s');
      expect(find.text('Checking your hub…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 18));
      expect(find.byKey(const Key('engine-check-noInfo')), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('engine-check-noInfo')), findsOneWidget);
      expect(live.timeouts(), ['no_info']);
    });
  });
}
