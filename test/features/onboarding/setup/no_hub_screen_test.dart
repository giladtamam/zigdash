import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/onboarding/first_run.dart';
import 'package:zigdash/features/onboarding/setup/no_hub_screen.dart';
import 'package:zigdash/features/onboarding/setup/setup_reminder.dart';
import 'package:zigdash/features/onboarding/setup/setup_screen.dart'
    show openSetupLink;
import 'package:zigdash/l10n/app_localizations.dart';

class _Sink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

class _FirstRun implements FirstRun {
  var demoStarted = 0;
  @override
  Future<String> startDemo() async {
    demoStarted++;
    return 'demo1';
  }

  @override
  Future<void> finish(String connectionId) async {}
}

class _Reminder implements SetupReminder {
  final kinds = <ReminderKind>[];
  @override
  Future<bool> schedule(Locale locale, {ReminderKind kind = ReminderKind.setup}) async {
    kinds.add(kind);
    return true;
  }

  @override
  Future<void> cancel() async {}
  @override
  Future<bool> openedFromReminder() async => false;
}

Future<({_Sink sink, _FirstRun firstRun, _Reminder reminder, List<Uri> opened})> _pump(
  WidgetTester tester, {
  NoHubFrom from = NoHubFrom.welcome,
}) async {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final sink = _Sink();
  final firstRun = _FirstRun();
  final reminder = _Reminder();
  final opened = <Uri>[];
  final original = openSetupLink;
  addTearDown(() => openSetupLink = original);
  openSetupLink = (url) async {
    opened.add(url);
    return true;
  };
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analyticsProvider.overrideWithValue(Analytics(sink, enabled: true)),
        firstRunProvider.overrideWithValue(firstRun),
        setupReminderProvider.overrideWithValue(reminder),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/setup',
          routes: [
            GoRoute(
              path: '/setup',
              builder: (_, __) => const Text('setup'),
              routes: [
                GoRoute(
                  path: 'no-hub',
                  builder: (_, __) => NoHubScreen(from: from),
                ),
              ],
            ),
            GoRoute(
              path: '/connections/:id/dashboards',
              builder: (_, state) =>
                  Text('dashboards of ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ),
    ),
  );
  final router = GoRouter.of(tester.element(find.text('setup')));
  router.push('/setup/no-hub');
  await tester.pumpAndSettle();
  return (sink: sink, firstRun: firstRun, reminder: reminder, opened: opened);
}

List<Map<String, String>> _noHub(_Sink sink) => [
  for (final (name, props) in sink.sent)
    if (name == 'setup_step' && props['step'] == 'no_hub') props,
];

void main() {
  testWidgets('opening it is counted, with where from', (tester) async {
    final t = await _pump(tester, from: NoHubFrom.guide);
    expect(find.text('Get a hub that runs Zigbee2MQTT'), findsOneWidget);
    expect(_noHub(t.sink), [
      {'step': 'no_hub', 'choice': 'guide', 'result': 'opened'},
    ]);
  });

  testWidgets('each way opens its page and is counted', (tester) async {
    final t = await _pump(tester);
    await tester.tap(find.byKey(const Key('no-hub-smhub')));
    await tester.tap(find.byKey(const Key('no-hub-pi')));
    await tester.tap(find.byKey(const Key('no-hub-ha')));
    await tester.pump();
    expect(t.opened.map((u) => u.host), ['zigdash.app', 'www.zigbee2mqtt.io', 'zigdash.app']);
    expect(_noHub(t.sink).map((p) => p['result']), [
      'opened',
      'smhub',
      'pi',
      'home_assistant',
    ]);
  });

  testWidgets('the demo starts the demo home', (tester) async {
    final t = await _pump(tester);
    await tester.tap(find.byKey(const Key('no-hub-demo')));
    await tester.pumpAndSettle();
    expect(t.firstRun.demoStarted, 1);
    expect(find.text('dashboards of demo1'), findsOneWidget);
    expect(_noHub(t.sink).last['result'], 'demo');
  });

  testWidgets('remind me in a week schedules the hub reminder', (tester) async {
    final t = await _pump(tester);
    await tester.tap(find.text('Remind me in a week'));
    await tester.pump();
    expect(t.reminder.kinds, [ReminderKind.hub]);
    expect(find.text("We'll remind you in a week, on this phone."), findsOneWidget);
    expect(_noHub(t.sink).last, {
      'step': 'no_hub',
      'choice': 'welcome',
      'result': 'remind',
    });
    // Counted as the screen's own tap, not as the old Remind me tomorrow.
    expect(t.sink.sent.where((e) => e.$2['step'] == 'remind_later'), isEmpty);
  });

  testWidgets('I have one now goes back', (tester) async {
    final t = await _pump(tester);
    await tester.tap(find.byKey(const Key('no-hub-have-one')));
    await tester.pumpAndSettle();
    expect(find.text('setup'), findsOneWidget);
    expect(_noHub(t.sink).last['result'], 'have_one');
  });
}
