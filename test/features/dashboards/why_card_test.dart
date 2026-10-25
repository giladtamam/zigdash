import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/dashboards/widgets/why_card.dart';
import 'package:zigdash/features/ha_import/ha_import_offer.dart';
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

const _title = 'What made you try ZigDash?';

Future<(SharedPreferences, _Sink)> _card(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
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
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: WhyCard(connectionId: 'c1')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (p, sink);
}

void main() {
  const asked = {'analytics_consent': true, whyAskKey: 'c1'};

  testWidgets('asked on the first home; a choice is sent once', (tester) async {
    final (prefs, sink) = await _card(tester, prefs: asked);
    expect(find.text(_title), findsOneWidget);
    await tester.tap(find.text('Easy for the family'));
    await tester.pumpAndSettle();
    expect(sink.sent, ['why_zigdash {choice: family}']);
    expect(find.text(_title), findsNothing);
    expect(prefs.getString(whyAskKey), isNull);
  });

  testWidgets('Not now puts it away for good, sending nothing', (tester) async {
    final (prefs, sink) = await _card(tester, prefs: asked);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(sink.sent, isEmpty);
    expect(prefs.getString(whyAskKey), isNull);
  });

  testWidgets('not on another home', (tester) async {
    await _card(tester, prefs: {'analytics_consent': true, whyAskKey: 'other'});
    expect(find.text(_title), findsNothing);
  });

  testWidgets('not with usage data off', (tester) async {
    await _card(tester, prefs: {'analytics_consent': false, whyAskKey: 'c1'});
    expect(find.text(_title), findsNothing);
  });

  testWidgets('waits for the usage-data question', (tester) async {
    await _card(tester, prefs: {whyAskKey: 'c1'});
    expect(find.text(_title), findsNothing);
  });

  testWidgets('waits for the Home Assistant import offer', (tester) async {
    await _card(tester, prefs: {...asked, HaImportOffer.key: 'c1'});
    expect(find.text(_title), findsNothing);
  });

  testWidgets('gives way to the poll on day three', (tester) async {
    await _card(tester, prefs: {...asked, 'review_sessions': 3});
    expect(find.text(_title), findsNothing);
  });
}
