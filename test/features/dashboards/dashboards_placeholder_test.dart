import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/dashboards/screens/dashboards_placeholder.dart';
import 'package:zigdash/l10n/app_localizations.dart';

void main() {
  testWidgets('placeholder shows the Dashboards title and empty message',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DashboardsPlaceholder(),
    ));

    expect(find.text('Dashboards'), findsOneWidget);
    expect(find.textContaining('Open a broker'), findsOneWidget);
  });
}
