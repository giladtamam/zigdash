import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/support/get_help_screen.dart';
import 'package:zigdash/features/support/help_tips.dart';
import 'package:zigdash/features/support/support_facts.dart';
import 'package:zigdash/features/support/support_log.dart';
import 'package:zigdash/l10n/app_localizations.dart';

Widget _app(Widget child, {SupportLog? log}) => ProviderScope(
      overrides: [
        platformFactsProvider.overrideWith((ref) async => (
              appVersion: '2.0.1',
              build: '31',
              android: '15',
              phone: 'Samsung SM-S721B',
            )),
        supportLogProvider.overrideWithValue(
            log ?? SupportLog(read: () async => null, write: (_) async {})),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

void main() {
  testWidgets('a setup error opens straight to its own tips', (tester) async {
    await tester.pumpWidget(_app(const GetHelpScreen(
        from: HelpFrom.setupError, error: SetupErrorKind.portClosed)));
    await tester.pumpAndSettle();
    expect(find.text('The right port'), findsOneWidget);
    expect(find.text('Mosquitto 2'), findsOneWidget);
    expect(find.text('Same Wi-Fi as your hub'), findsNothing);
    expect(find.textContaining('reply within 3 days'), findsOneWidget);
  });

  testWidgets('What\'s included shows the details; Copy copies them',
      (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    String? saved = '{"failure":"timedOut","scan":{"widened":true,'
        '"hostsTried":1018,"brokersFound":0,"network":"Wi-Fi"}}';
    final log = SupportLog(read: () async => saved, write: (s) async => saved = s);

    await tester.pumpWidget(
        _app(const GetHelpScreen(from: HelpFrom.noConnection), log: log));
    await tester.pumpAndSettle();
    expect(find.text('Same Wi-Fi as your hub'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Copy details'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text("What's included"));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('Opened from: Setup › No connection found'),
        findsOneWidget);
    expect(find.textContaining('Last error: timed out'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Copy details'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Copy details'));
    await tester.pumpAndSettle();
    expect(copied, startsWith('ZigDash 2.0.1 (31) · Android 15'));
    expect(copied, contains('Last scan: /24 then /22 · 1,018 hosts tried'));
    expect(find.text('Details copied'), findsOneWidget);
  });

  testWidgets('ticking a tip is local only', (tester) async {
    await tester.pumpWidget(_app(const GetHelpScreen(from: HelpFrom.demo)));
    await tester.pumpAndSettle();
    final box = find.byType(Checkbox).first;
    expect(tester.widget<Checkbox>(box).value, isFalse);
    await tester.tap(box);
    await tester.pump();
    expect(tester.widget<Checkbox>(box).value, isTrue);
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
