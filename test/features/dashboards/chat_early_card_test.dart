import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/dashboards/widgets/chat_early_card.dart';
import 'package:zigdash/features/onboarding/demo_service.dart' show demoHost;
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/features/support/early_access_client.dart';
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

class _Worker {
  EarlyJoin? answer = const EarlyJoin(position: 3, free: true);
  final joins = <String>[];
  final prices = <String>[];

  Future<EarlyJoin?> join({
    required String email,
    required String lang,
    required bool counted,
    required String nonce,
  }) async {
    joins.add('$email $lang counted=$counted nonce=$nonce');
    return answer;
  }

  Future<bool> price({
    required String email,
    required String token,
    required String answer,
  }) async {
    prices.add('$email $answer token=$token');
    return true;
  }
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

const _title = 'Chat with your home';

Future<(SharedPreferences, _Sink, _Worker)> _pump(
  WidgetTester tester,
  Widget home, {
  Map<String, Object> prefs = const {},
  String host = '192.168.1.2',
  bool offered = true,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final sink = _Sink();
  final worker = _Worker();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        analyticsAvailableProvider.overrideWithValue(true),
        analyticsSinkProvider.overrideWithValue(sink),
        connectionByIdProvider.overrideWith((ref, _) async => _home(host)),
        chatEarlyOfferedProvider.overrideWithValue(offered),
        earlyJoinerProvider.overrideWithValue(worker.join),
        earlyPricerProvider.overrideWithValue(worker.price),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: home)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (p, sink, worker);
}

Future<(SharedPreferences, _Sink, _Worker)> _card(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String host = '192.168.1.2',
  bool offered = true,
}) => _pump(
  tester,
  const ChatEarlyCard(connectionId: 'c1'),
  prefs: prefs,
  host: host,
  offered: offered,
);

Future<void> _joinByEmail(WidgetTester tester, String email) async {
  await tester.tap(find.byKey(const Key('chat-early-email')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('chat-early-email-field')),
    email,
  );
  await tester.tap(find.byKey(const Key('chat-early-send')));
  await tester.pumpAndSettle();
}

// 3.5.4: "Chat with your home" early access, docs/design/assistant-early-access.md.
void main() {
  const sharing = {'analytics_consent': true, 'review_sessions': 2};

  test('only the Play build offers it', () {
    expect(chatEarlyOfferedFor('play'), isTrue);
    expect(chatEarlyOfferedFor('foss'), isFalse);
    expect(chatEarlyOfferedFor('appstore'), isFalse);
  });

  test('the Telegram link carries only the counted bit', () {
    expect(
      earlyTelegramLink(counted: true).toString(),
      'https://t.me/ZigDashHomeBot?start=early_c',
    );
    expect(
      earlyTelegramLink(counted: false).toString(),
      'https://t.me/ZigDashHomeBot?start=early_n',
    );
  });

  testWidgets('shown from the second day, counted once per install', (
    tester,
  ) async {
    final (prefs, sink, _) = await _card(tester, prefs: sharing);
    expect(find.text(_title), findsOneWidget);
    expect(sink.sent, ['chat_early {step: shown, from: card}']);
    expect(prefs.getString(chatEarlyShownKey), '1');
    await tester.pumpAndSettle();
    expect(sink.sent, hasLength(1));
  });

  testWidgets('not in the foss or iOS builds', (tester) async {
    await _card(tester, prefs: sharing, offered: false);
    expect(find.text(_title), findsNothing);
  });

  testWidgets('not on the first day', (tester) async {
    await _card(
      tester,
      prefs: {'analytics_consent': true, 'review_sessions': 1},
    );
    expect(find.text(_title), findsNothing);
  });

  testWidgets('never on the demo Home', (tester) async {
    await _card(tester, prefs: sharing, host: demoHost);
    expect(find.text(_title), findsNothing);
  });

  testWidgets('waits while the usage-data question is open', (tester) async {
    final (_, sink, _) = await _card(tester, prefs: {'review_sessions': 5});
    expect(find.text(_title), findsNothing);
    expect(sink.sent, isEmpty);
  });

  testWidgets('Not for me puts it away for good', (tester) async {
    final (prefs, sink, _) = await _card(tester, prefs: sharing);
    await tester.tap(find.byKey(const Key('chat-early-not-for-me')));
    await tester.pumpAndSettle();
    expect(find.text(_title), findsNothing);
    expect(sink.sent.last, 'chat_early {step: not_for_me, from: card}');
    expect(prefs.getString(chatEarlyDoneKey), '1');
  });

  testWidgets('email: joins counted, shows the place, asks the price once', (
    tester,
  ) async {
    final (prefs, sink, worker) = await _card(tester, prefs: sharing);
    await _joinByEmail(tester, 'me@example.com');
    expect(
      worker.joins.single,
      startsWith('me@example.com en counted=true nonce='),
    );
    expect(find.textContaining("You're #3 on the list"), findsOneWidget);
    expect(prefs.getString(chatEarlyDoneKey), '1');
    expect(sink.sent.last, 'chat_early {step: email_sent, from: card}');

    await tester.tap(find.byKey(const Key('chat-early-price-maybe')));
    await tester.pumpAndSettle();
    final nonce = worker.joins.single.split('nonce=').last;
    expect(worker.prices.single, 'me@example.com maybe token=$nonce');
    expect(sink.sent.last, 'chat_early {step: price_maybe, from: card}');
    expect(find.byKey(const Key('chat-early-price-yes')), findsNothing);
    expect(find.text('Thanks, noted.'), findsOneWidget);
  });

  testWidgets('an address already listed from elsewhere gets no number', (
    tester,
  ) async {
    final (_, _, worker) = await _pump(
      tester,
      const ChatEarlyCard(connectionId: 'c1'),
      prefs: sharing,
    );
    worker.answer = const EarlyJoin();
    await _joinByEmail(tester, 'me@example.com');
    expect(find.text('This email is already on the list.'), findsOneWidget);
    expect(find.byKey(const Key('chat-early-price-yes')), findsNothing);
  });

  testWidgets('a bad address is refused before anything is sent', (
    tester,
  ) async {
    final (_, _, worker) = await _card(tester, prefs: sharing);
    await _joinByEmail(tester, 'not-an-email');
    expect(worker.joins, isEmpty);
    expect(
      find.text("That doesn't look like an email address."),
      findsOneWidget,
    );
  });

  testWidgets('a failed send says so and can be retried', (tester) async {
    final (prefs, sink, worker) = await _pump(
      tester,
      const ChatEarlyCard(connectionId: 'c1'),
      prefs: sharing,
    );
    worker.answer = null;
    await _joinByEmail(tester, 'me@example.com');
    expect(find.text("Couldn't send. Try Telegram, or later."), findsOneWidget);
    expect(sink.sent.last, 'chat_early {step: email_failed, from: card}');
    expect(prefs.getString(chatEarlyDoneKey), isNull);
  });

  testWidgets('without usage data, a join is not counted', (tester) async {
    final (_, _, worker) = await _card(
      tester,
      prefs: {'analytics_consent': false, 'review_sessions': 2},
    );
    await _joinByEmail(tester, 'me@example.com');
    expect(worker.joins.single, contains('counted=false'));
  });

  testWidgets('from Settings: offered after the card, never counted', (
    tester,
  ) async {
    final (_, sink, worker) = await _pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showChatEarlySheet(context),
          child: const Text('open'),
        ),
      ),
      prefs: {...sharing, chatEarlyDoneKey: '1'},
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text(_title), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    await _joinByEmail(tester, 'me@example.com');
    expect(worker.joins.single, contains('counted=false'));
    expect(sink.sent.last, 'chat_early {step: email_sent, from: settings}');
  });
}
