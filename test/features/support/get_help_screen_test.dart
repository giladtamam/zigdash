import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/support/assistant_panel.dart';
import 'package:zigdash/features/support/get_help_screen.dart';
import 'package:zigdash/features/support/help_tips.dart';
import 'package:zigdash/features/support/support_facts.dart';
import 'package:zigdash/features/support/support_log.dart';
import 'package:zigdash/features/support/assistant_client.dart';
import 'package:zigdash/features/support/support_sender.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/l10n/app_localizations.dart';

/// The assistant, replaced: answers at once with [answer], or fails.
AssistantCaller _assistant({String? answer, AssistantOutcome? outcome}) =>
    (request, timeout) async => answer != null
        ? AssistantReply(AssistantOutcome.answered, text: answer)
        : AssistantReply(outcome ?? AssistantOutcome.failed);

late SharedPreferences defaultPrefs;

Widget _app(
  Widget child, {
  SupportLog? log,
  SupportSender? sender,
  AssistantCaller? assistant,
  SharedPreferences? prefs,
}) =>
    ProviderScope(
      overrides: [
        platformFactsProvider.overrideWith((ref) async => (
              appVersion: '2.0.1',
              build: '31',
              android: '15',
              phone: 'Samsung SM-S721B',
            )),
        supportLogProvider.overrideWithValue(
            log ?? SupportLog(read: () async => null, write: (_) async {})),
        if (sender != null) supportSenderProvider.overrideWithValue(sender),
        assistantCallerProvider.overrideWithValue(assistant ?? _assistant()),
        sharedPreferencesProvider.overrideWithValue(prefs ?? defaultPrefs),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

/// Scrolls the screen's list until [finder] is built and visible.
Future<void> _show(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder);
    return;
  }
  await tester.scrollUntilVisible(finder, 200,
      scrollable: find.byType(Scrollable).first);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    defaultPrefs = await SharedPreferences.getInstance();
  });

  testWidgets('a setup error opens straight to its own tips', (tester) async {
    await tester.pumpWidget(_app(const GetHelpScreen(
        from: HelpFrom.setupError, error: SetupErrorKind.portClosed)));
    await tester.pumpAndSettle();
    expect(find.textContaining('reply within 3 days'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('get-help-tips')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('get-help-tips')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('The right port'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('The right port'), findsOneWidget);
    expect(find.text('Mosquitto 2'), findsOneWidget);
    expect(find.text('Same Wi-Fi as your hub'), findsNothing);
  });

  testWidgets('Send is off until there is a message, then delivers it',
      (tester) async {
    SupportMessage? sent;
    await tester.pumpWidget(_app(
      const GetHelpScreen(from: HelpFrom.setupError),
      sender: (m) async {
        sent = m;
        return true;
      },
    ));
    await tester.pumpAndSettle();
    final send = find.byKey(const Key('get-help-send'));
    await _show(tester, send);
    expect(tester.widget<FilledButton>(send).onPressed, isNull);

    await _show(tester, find.byKey(const Key('get-help-message')));
    await tester.enterText(
        find.byKey(const Key('get-help-message')), 'The scan finds nothing');
    await tester.enterText(
        find.byKey(const Key('get-help-email')), 'me@example.com');
    await tester.pump();
    expect(tester.widget<FilledButton>(send).onPressed, isNotNull);
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(sent, isNotNull);
    expect(sent!.text, 'The scan finds nothing');
    expect(sent!.email, 'me@example.com');
    expect(sent!.appVersion, '2.0.1');
    expect(sent!.details, startsWith('ZigDash 2.0.1 (31) · Android 15'));
    expect(find.byKey(const Key('get-help-sent')), findsOneWidget);
    expect(find.byKey(const Key('get-help-message')), findsNothing);
  });

  testWidgets('a failed Send offers Share instead, with the same message',
      (tester) async {
    String? shared;
    final saved = shareText;
    addTearDown(() => shareText = saved);
    shareText = (text, title) async {
      shared = text;
      return true;
    };
    await tester.pumpWidget(_app(
      const GetHelpScreen(from: HelpFrom.manualForm),
      sender: (_) async => false,
    ));
    await tester.pumpAndSettle();
    await _show(tester, find.byKey(const Key('get-help-message')));
    await tester.enterText(
        find.byKey(const Key('get-help-message')), 'Login refused');
    await tester.pump();
    await _show(tester, find.byKey(const Key('get-help-send')));
    await tester.tap(find.byKey(const Key('get-help-send')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('get-help-sent')), findsNothing);
    expect(find.textContaining('Try again in an hour'), findsOneWidget);
    await _show(tester, find.byKey(const Key('get-help-share-instead')));
    await tester.tap(find.byKey(const Key('get-help-share-instead')));
    await tester.pumpAndSettle();
    expect(shared, startsWith('Login refused'));
    expect(shared, contains('— Support details —'));
    expect(shared, contains('ZigDash 2.0.1 (31)'));
  });

  testWidgets('Share details opens the share sheet; without one it copies',
      (tester) async {
    String? shared;
    String? copied;
    final saved = shareText;
    addTearDown(() => shareText = saved);
    shareText = (text, title) async {
      shared = text;
      return false;
    };
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    String? savedLog = '{"failure":"timedOut","scan":{"widened":true,'
        '"hostsTried":1018,"brokersFound":0,"network":"Wi-Fi"}}';
    final log = SupportLog(
        read: () async => savedLog, write: (s) async => savedLog = s);

    await tester.pumpWidget(
        _app(const GetHelpScreen(from: HelpFrom.noConnection), log: log));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Share details'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Share details'));
    await tester.pumpAndSettle();
    expect(shared, startsWith('ZigDash 2.0.1 (31) · Android 15'));
    expect(shared, contains('Last scan: /24 then /22 · 1,018 hosts tried'));
    // No share sheet on this platform: the clipboard, and it says so.
    expect(copied, shared);
    expect(find.text('Details copied'), findsOneWidget);
  });

  testWidgets('from the empty scan it asks whether Zigbee2MQTT runs first',
      (tester) async {
    await tester
        .pumpWidget(_app(const GetHelpScreen(from: HelpFrom.scanEmpty)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Is Zigbee2MQTT running'), findsOneWidget);
    expect(find.byKey(const Key('get-help-message')), findsNothing);

    await tester.tap(find.byKey(const Key('get-help-running-yes')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Is Zigbee2MQTT running'), findsNothing);
    expect(find.byKey(const Key('get-help-message')), findsOneWidget);
    expect(find.textContaining('reply within 3 days'), findsOneWidget);
  });

  testWidgets('"Not sure" shows how to tell and opens the tips',
      (tester) async {
    await tester
        .pumpWidget(_app(const GetHelpScreen(from: HelpFrom.scanEmpty)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('get-help-running-not-sure')));
    await tester.pumpAndSettle();
    expect(find.textContaining('has its own web page'), findsOneWidget);
    await _show(tester, find.byKey(const Key('get-help-message')));
    expect(find.byKey(const Key('get-help-message')), findsOneWidget);
    // The tips are open, not collapsed.
    await tester.scrollUntilVisible(find.text('Same Wi-Fi as your hub'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Same Wi-Fi as your hub'), findsOneWidget);
  });

  testWidgets('ticking a tip is local only', (tester) async {
    await tester.pumpWidget(_app(const GetHelpScreen(from: HelpFrom.demo)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('get-help-tips')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('get-help-tips')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(Checkbox).first, 200,
        scrollable: find.byType(Scrollable).first);
    final box = find.byType(Checkbox).first;
    expect(tester.widget<Checkbox>(box).value, isFalse);
    await tester.tap(box);
    await tester.pump();
    expect(tester.widget<Checkbox>(box).value, isTrue);
  });

  group('assistant (3.5.0)', () {
    testWidgets('on a setup origin it answers first, then takes a reply',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final seen = <AssistantRequest>[];
      await tester.pumpWidget(_app(
        const GetHelpScreen(
            from: HelpFrom.setupError, error: SetupErrorKind.portClosed),
        prefs: prefs,
        assistant: (request, timeout) async {
          seen.add(request);
          return AssistantReply(AssistantOutcome.answered,
              text: seen.length == 1
                  ? 'Check 1: same Wi-Fi. Check 2: port 1883.'
                  : 'Then try the IP address.');
        },
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('Check 1: same Wi-Fi'), findsOneWidget);
      expect(seen.single.turns, isEmpty);
      expect(seen.single.details, startsWith('ZigDash 2.0.1 (31)'));
      // The answer stamps help_seen for the next 24 hours.
      expect(assistantHelpedRecently(prefs), isTrue);

      await tester.enterText(
          find.byKey(const Key('assistant-reply')), 'Same Wi-Fi, yes');
      await tester.pump();
      await tester.tap(find.byKey(const Key('assistant-send')));
      await tester.pumpAndSettle();
      expect(find.text('Then try the IP address.'), findsOneWidget);
      expect(seen.last.turns.map((t) => t.fromUser).toList(),
          [false, true]);
      expect(seen.last.turns.last.text, 'Same Wi-Fi, yes');
    });

    testWidgets('"Did this help? No" hands the answer to Send as a report',
        (tester) async {
      SupportMessage? sent;
      await tester.pumpWidget(_app(
        const GetHelpScreen(from: HelpFrom.manualForm),
        assistant: _assistant(answer: 'Try port 1883.'),
        sender: (m) async {
          sent = m;
          return true;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('assistant-helped-no')));
      await tester.pumpAndSettle();
      await _show(tester, find.byKey(const Key('get-help-message')));
      expect(find.text("What was wrong with the assistant's answer?"),
          findsOneWidget);
      await tester.enterText(
          find.byKey(const Key('get-help-message')), 'Port was right already');
      await tester.pump();
      await _show(tester, find.byKey(const Key('get-help-send')));
      await tester.tap(find.byKey(const Key('get-help-send')));
      await tester.pumpAndSettle();
      expect(sent!.kind, 'ai_report');
      expect(sent!.details, contains('Flagged answer:\nTry port 1883.'));
      expect(sent!.details, startsWith('ZigDash 2.0.1 (31)'));
    });

    testWidgets('Talk to a person attaches the last answers after the details',
        (tester) async {
      SupportMessage? sent;
      await tester.pumpWidget(_app(
        const GetHelpScreen(from: HelpFrom.noConnection),
        assistant: _assistant(answer: 'Join your main Wi-Fi.'),
        sender: (m) async {
          sent = m;
          return true;
        },
      ));
      await tester.pumpAndSettle();
      await _show(tester, find.byKey(const Key('assistant-person')));
      await tester.tap(find.byKey(const Key('assistant-person')));
      await tester.pumpAndSettle();
      await _show(tester, find.byKey(const Key('get-help-message')));
      await tester.enterText(
          find.byKey(const Key('get-help-message')), 'Still nothing');
      await tester.pump();
      await _show(tester, find.byKey(const Key('get-help-send')));
      await tester.tap(find.byKey(const Key('get-help-send')));
      await tester.pumpAndSettle();
      expect(sent!.kind, 'support');
      final i = sent!.details.indexOf('— Assistant —');
      expect(i, greaterThan(0));
      expect(sent!.details.substring(i), contains('Join your main Wi-Fi.'));
    });

    testWidgets('resting and failure leave a person reachable',
        (tester) async {
      await tester.pumpWidget(_app(
        const GetHelpScreen(from: HelpFrom.setupError),
        assistant: _assistant(outcome: AssistantOutcome.resting),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('resting'), findsOneWidget);
      expect(find.byKey(const Key('assistant-reply')), findsNothing);
      await _show(tester, find.byKey(const Key('get-help-send')));
      expect(find.byKey(const Key('get-help-send')), findsOneWidget);
    });

    testWidgets('Settings keeps the plain form, no assistant',
        (tester) async {
      await tester.pumpWidget(_app(const GetHelpScreen(from: HelpFrom.settings)));
      await tester.pumpAndSettle();
      expect(find.text('ZigDash assistant'), findsNothing);
      await _show(tester, find.byKey(const Key('get-help-message')));
      expect(find.byKey(const Key('get-help-message')), findsOneWidget);
    });

    testWidgets('from the empty scan the triage comes before the assistant',
        (tester) async {
      final seen = <AssistantRequest>[];
      await tester.pumpWidget(_app(
        const GetHelpScreen(from: HelpFrom.scanEmpty, platform: 'piOrDocker'),
        assistant: (r, t) async {
          seen.add(r);
          return const AssistantReply(AssistantOutcome.answered, text: 'Hi');
        },
      ));
      await tester.pumpAndSettle();
      expect(find.text('ZigDash assistant'), findsNothing);
      expect(seen, isEmpty);
      await tester.tap(find.byKey(const Key('get-help-running-yes')));
      await tester.pumpAndSettle();
      expect(find.text('ZigDash assistant'), findsOneWidget);
      expect(seen.single.triage.running, 'yes');
      expect(seen.single.triage.platform, 'piOrDocker');
    });
  });

  test('the support email carries subject, prompt and details', () {
    final url = supportMailUrl(
      subject: 'ZigDash: help getting it working',
      prompt: 'What happened?',
      details: 'ZigDash 2.0.1 (31)\nLast error: timed out',
    );
    expect(url.scheme, 'mailto');
    expect(url.path, supportEmail);
    expect(url.query, isNot(contains('+')));
    final body = Uri.decodeComponent(url.query.split('&body=').last);
    expect(body, startsWith('What happened?'));
    expect(body, endsWith('— Support details —\n'
        'ZigDash 2.0.1 (31)\nLast error: timed out'));
  });

  test('a support message as text carries the reply address and details',
      () {
    const m = SupportMessage(
      text: 'Nothing found',
      email: 'me@example.com',
      details: 'ZigDash 2.0.1 (31)',
      appVersion: '2.0.1',
      build: '31',
      locale: 'en-US',
    );
    expect(m.toJson()['email'], 'me@example.com');
    expect(const SupportMessage(
      text: 'x',
      details: 'd',
      appVersion: '1',
      build: '1',
      locale: 'en',
    ).toJson().containsKey('email'), isFalse);
    expect(m.asText(), 'Nothing found\nReply to: me@example.com\n\n'
        '— Support details —\nZigDash 2.0.1 (31)');
  });

  test('every place and setup error has tips', () {
    final l = lookupAppLocalizations(const Locale('en'));
    for (final from in HelpFrom.values) {
      for (final e in [null, ...SetupErrorKind.values]) {
        expect(tipsFor(l, from, e), isNotEmpty, reason: '$from $e');
      }
    }
    // Login required uses the same tips as login rejected.
    expect(tipsFor(l, HelpFrom.setupError, SetupErrorKind.authRequired),
        tipsFor(l, HelpFrom.setupError, SetupErrorKind.authRejected));
    // Errors without their own tips fall back to No connection found.
    expect(tipsFor(l, HelpFrom.setupError, SetupErrorKind.saveFailed),
        tipsFor(l, HelpFrom.noConnection, null));
  });

}
