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

Future<(SharedPreferences, _Sink)> _card(WidgetTester tester,
    {Map<String, Object> prefs = const {}, String host = '192.168.1.2'}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final sink = _Sink();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      analyticsAvailableProvider.overrideWithValue(true),
      analyticsSinkProvider.overrideWithValue(sink),
      connectionByIdProvider.overrideWith((ref, _) async => _home(host)),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PollCard(connectionId: 'c1')),
    ),
  ));
  await tester.pumpAndSettle();
  return (p, sink);
}

void main() {
  const sharing = {'analytics_consent': true, 'review_sessions': 3};

  testWidgets('asked on the third day; a choice is sent once', (tester) async {
    final (prefs, sink) = await _card(tester, prefs: sharing);
    expect(find.text('What should ZigDash do next?'), findsOneWidget);
    await tester.tap(find.text('History graphs'));
    await tester.pumpAndSettle();
    expect(sink.sent, ['poll_answer {choice: history}']);
    expect(find.text('What should ZigDash do next?'), findsNothing);
    expect(prefs.getString(pollDoneKey), '1');
  });

  testWidgets('not before the third day', (tester) async {
    await _card(tester,
        prefs: {'analytics_consent': true, 'review_sessions': 2});
    expect(find.text('What should ZigDash do next?'), findsNothing);
  });

  testWidgets('Not now puts it away for good, sending nothing', (tester) async {
    final (prefs, sink) = await _card(tester, prefs: sharing);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(sink.sent, isEmpty);
    expect(prefs.getString(pollDoneKey), '1');
  });

  testWidgets('without usage data, no choices: Request a feature instead',
      (tester) async {
    await _card(tester,
        prefs: {'analytics_consent': false, 'review_sessions': 5});
    expect(find.text('What should ZigDash do next?'), findsOneWidget);
    expect(find.text('History graphs'), findsNothing);
    expect(find.text('Request a feature'), findsOneWidget);
  });

  testWidgets('waits while the usage-data question is open', (tester) async {
    await _card(tester, prefs: {'review_sessions': 5});
    expect(find.text('What should ZigDash do next?'), findsNothing);
  });

  testWidgets('never on the demo Home', (tester) async {
    await _card(tester, prefs: sharing, host: demoHost);
    expect(find.text('What should ZigDash do next?'), findsNothing);
  });

  testWidgets('asked only once', (tester) async {
    await _card(tester, prefs: {...sharing, pollDoneKey: '1'});
    expect(find.text('What should ZigDash do next?'), findsNothing);
  });
}
