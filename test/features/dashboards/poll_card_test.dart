import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/dashboards/widgets/poll_card.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

class _Sink implements AnalyticsSink {
  final sent = <String>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

Connection _home(String host) => Connection(
  transport: ConnectionTransport.mqtt,
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

const _title = 'What should ZigDash do next?';

Future<(SharedPreferences, _Sink)> _pump(
  WidgetTester tester,
  Widget home, {
  Map<String, Object> prefs = const {},
  String host = '192.168.1.2',
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final sink = _Sink();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        analyticsAvailableProvider.overrideWithValue(true),
        analyticsSinkProvider.overrideWithValue(sink),
        connectionByIdProvider.overrideWith((ref, _) async => _home(host)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: home),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (p, sink);
}

Future<(SharedPreferences, _Sink)> _card(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String host = '192.168.1.2',
}) => _pump(
  tester,
  const PollCard(connectionId: 'c1'),
  prefs: prefs,
  host: host,
);

// 3.3.5: "What should ZigDash do next?" asks again, with what isn't built
// yet; pick any, on a card from the second day and in Settings.
void main() {
  const sharing = {'analytics_consent': true, 'review_sessions': 2};

  testWidgets('asked on the second day; each pick is sent once', (
    tester,
  ) async {
    final (prefs, sink) = await _card(tester, prefs: sharing);
    expect(find.text(_title), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('poll-send'))).onPressed,
      isNull,
    );
    await tester.tap(find.text('Pair new devices from ZigDash'));
    await tester.tap(find.text('Control my home from my AI assistant'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('poll-send')));
    await tester.pumpAndSettle();
    expect(sink.sent, [
      'poll_answer {choice: pair, from: card}',
      'poll_answer {choice: ai_assistant, from: card}',
    ]);
    expect(find.text(_title), findsNothing);
    expect(
      find.text('Thanks! That helps decide what comes next.'),
      findsOneWidget,
    );
    expect(prefs.getString(pollDoneKey), '1');
  });

  testWidgets('a pick taken back is not sent', (tester) async {
    final (_, sink) = await _card(tester, prefs: sharing);
    await tester.tap(find.text('Work with ZHA, without Zigbee2MQTT'));
    await tester.tap(find.text('Device settings and firmware updates'));
    await tester.pump();
    await tester.tap(find.text('Work with ZHA, without Zigbee2MQTT'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('poll-send')));
    await tester.pumpAndSettle();
    expect(sink.sent, ['poll_answer {choice: device_settings, from: card}']);
  });

  testWidgets('Something else is sent and asks where to write it', (
    tester,
  ) async {
    final (_, sink) = await _card(tester, prefs: sharing);
    await tester.tap(find.text('Something else'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('poll-send')));
    await tester.pumpAndSettle();
    expect(sink.sent, ['poll_answer {choice: other, from: card}']);
    // Request a feature's where-to-send sheet.
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('not on the first day', (tester) async {
    await _card(
      tester,
      prefs: {'analytics_consent': true, 'review_sessions': 1},
    );
    expect(find.text(_title), findsNothing);
  });

  testWidgets('Not now puts it away for good, sending nothing', (tester) async {
    final (prefs, sink) = await _card(tester, prefs: sharing);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(sink.sent, isEmpty);
    expect(prefs.getString(pollDoneKey), '1');
  });

  testWidgets('without usage data, no choices: Request a feature instead', (
    tester,
  ) async {
    await _card(
      tester,
      prefs: {'analytics_consent': false, 'review_sessions': 5},
    );
    expect(find.text(_title), findsOneWidget);
    expect(find.text('Pair new devices from ZigDash'), findsNothing);
    expect(find.text('Request a feature'), findsOneWidget);
  });

  testWidgets('waits while the usage-data question is open', (tester) async {
    await _card(tester, prefs: {'review_sessions': 5});
    expect(find.text(_title), findsNothing);
  });

  testWidgets('never on the demo Home', (tester) async {
    await _card(tester, prefs: sharing, host: demoHost);
    expect(find.text(_title), findsNothing);
  });

  testWidgets('asked only once; the old poll does not count', (tester) async {
    await _card(tester, prefs: {...sharing, pollDoneKey: '1'});
    expect(find.text(_title), findsNothing);
    await _card(tester, prefs: {...sharing, 'poll_next_done': '1'});
    expect(find.text(_title), findsOneWidget);
  });

  testWidgets('from Settings, the sheet sends with from: settings', (
    tester,
  ) async {
    final (prefs, sink) = await _pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showPollSheet(context),
          child: const Text('open'),
        ),
      ),
      prefs: {...sharing, pollDoneKey: '1'},
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text(_title), findsOneWidget);
    await tester.tap(find.text('Work with ZHA, without Zigbee2MQTT'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('poll-send')));
    await tester.pumpAndSettle();
    expect(sink.sent, ['poll_answer {choice: zha, from: settings}']);
    expect(find.text(_title), findsNothing);
  });
}
