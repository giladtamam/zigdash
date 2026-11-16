import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/pro/pro_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';

/// Play's answer to Restore purchase, without a channel.
class _Restoring extends ProBilling {
  _Restoring(this.answer);
  final String? answer;
  @override
  ProStatus build() => ProStatus.locked;
  @override
  Future<String?> refresh() async => answer;
}

Future<void> _pump(
  WidgetTester tester, {
  required ProStatus status,
  VoidCallback? buy,
  String? price,
  String? restoreAnswer,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        proStatusProvider.overrideWithValue(status),
        proPurchaseProvider.overrideWithValue(buy),
        proPriceProvider.overrideWith((ref) async => price),
        proBillingProvider.overrideWith(() => _Restoring(restoreAnswer)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  // A reinstall or a new phone: Restore purchase asks Play again and says
  // what it found.
  for (final (answer, says) in [
    ('unlocked', 'Pro is unlocked on this phone.'),
    ('locked', 'Google Play has no Pro purchase for this Google account.'),
    ('error', "Couldn't reach Google Play."),
  ]) {
    testWidgets('Restore purchase: $answer', (tester) async {
      await _pump(tester, status: ProStatus.locked, buy: () {}, price: '€7.99', restoreAnswer: answer);
      await tester.scrollUntilVisible(find.byKey(const Key('pro-restore')), 100,
          scrollable: find.byType(Scrollable).first);
      tester.widget<TextButton>(find.byKey(const Key('pro-restore'))).onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining(says), findsOneWidget);
    });
  }

  // 2.9.6: Unlock used to open Play's sheet straight away; now Pro says
  // what it adds, what stays free, and why it exists, first.
  testWidgets('says what Pro adds and what stays free, with Play\'s price', (
    tester,
  ) async {
    var bought = 0;
    await _pump(
      tester,
      status: ProStatus.locked,
      buy: () => bought++,
      price: '€7.99',
    );
    expect(find.textContaining('open source'), findsOneWidget);
    expect(
      find.text('History for 7 and 30 days, not just today'),
      findsOneWidget,
    );
    expect(find.text('Free forever'), findsOneWidget);
    await tester.tap(find.text('Get Pro · €7.99'));
    expect(bought, 1);
  });

  testWidgets('no price from Play: the button still works', (tester) async {
    await _pump(tester, status: ProStatus.locked, buy: () {});
    expect(find.text('Get Pro'), findsOneWidget);
  });

  testWidgets('bought: thanks, and nothing to buy', (tester) async {
    await _pump(tester, status: ProStatus.unlocked);
    expect(
      find.text('Unlocked. Thank you for supporting ZigDash.'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsNothing);
  });
}
