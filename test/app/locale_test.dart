import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/features/settings/screens/settings_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';

void main() {
  test('supportedLocales covers every shipped locale', () {
    final codes =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    expect(codes, containsAll(['en', 'he', 'de', 'nl', 'sv', 'nb', 'es', 'fr']));
  });

  testWidgets('Settings renders Hebrew + RTL when locale is he', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(
        locale: Locale('he'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: SettingsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('הגדרות'), findsOneWidget); // navSettings (he)
    expect(find.text('שפה'), findsOneWidget); // settingsLanguage (he)
    expect(Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.rtl);
  });

  testWidgets('Settings renders German when locale is de', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(
        locale: Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: SettingsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Einstellungen'), findsOneWidget); // navSettings (de)
    expect(find.text('Sprache'), findsOneWidget); // settingsLanguage (de)
  });
}
