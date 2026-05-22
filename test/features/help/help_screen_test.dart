import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/help/screens/help_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';

void main() {
  testWidgets('Help screen renders the bundled guide heading', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HelpScreen(),
    ));
    await tester.pumpAndSettle();
    // AppBar title is localized:
    expect(find.text('Help & Guide'), findsWidgets);
    // A known heading from docs/USER_GUIDE.md body:
    expect(find.textContaining('ZigDash'), findsWidgets);
  });
}
