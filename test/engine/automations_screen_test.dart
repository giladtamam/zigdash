import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/alerts/alerts_service.dart';
import 'package:zigdash/engine/automations_repo.dart';
import 'package:zigdash/engine/automations_screen.dart';
import 'package:zigdash/engine/engine_installer.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';
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

void main() {
  testWidgets('not installed: explains and installs over Zigbee2MQTT', (tester) async {
    final link = await _pump(tester, const EngineView(phase: HubEnginePhase.notInstalled, hub: _hub));
    expect(find.text('Automations run on your hub, not on your phone'), findsOneWidget);
    expect(find.text('Your Zigbee2MQTT is version 2.8.0.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('engine-install')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final save = link.published.singleWhere((p) => p.$1 == 'zigbee2mqtt/bridge/request/extension/save');
    expect((jsonDecode(save.$2) as Map)['name'], engineExtensionName);
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
}
