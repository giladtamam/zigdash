import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/router/app_router.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

class _Sink implements AnalyticsSink {
  final sent = <Map<String, String>>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) =>
      sent.add({'event': name, ...props});
}

const _home = 'http://192.168.1.20:8123';
final _link =
    'https://zigdash.app/c#ha=${Uri.encodeQueryComponent(_home)}';

/// A connect link through the real router (docs/design/ha-link.md).
void main() {
  Future<(ProviderContainer, _Sink)> container(Map<String, Object> v) async {
    SharedPreferences.setMockInitialValues(v);
    final prefs = await SharedPreferences.getInstance();
    final sink = _Sink();
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        analyticsAvailableProvider.overrideWithValue(true),
        analyticsSinkProvider.overrideWithValue(sink),
        connectionsStreamProvider.overrideWith(
          (ref) => Stream<List<Connection>>.value(const <Connection>[]),
        ),
      ],
    );
    addTearDown(c.dispose);
    return (c, sink);
  }

  Widget app(ProviderContainer c) => UncontrolledProviderScope(
    container: c,
    child: MaterialApp.router(
      routerConfig: c.read(routerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );

  testWidgets('first run: the link waits on Welcome; one tap on Home '
      'Assistant opens the sign-in with its address', (tester) async {
    final (c, sink) = await container({});
    await tester.pumpWidget(app(c));
    await tester.pumpAndSettle();

    c.read(routerProvider).go(_link);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('setup-link-pending')), findsOneWidget);
    expect(sink.sent, isEmpty);

    await tester.tap(find.byKey(const Key('ask-ha')));
    await tester.pumpAndSettle();

    // Both "which way" sheets skipped: straight to the sign-in.
    expect(find.text(_home), findsOneWidget);
    expect(
      find.text('This is the address from your link. Sign in to connect.'),
      findsOneWidget,
    );
    final steps = sink.sent.map((e) => e['step']).toList();
    expect(steps, containsAllInOrder(['ha_link', 'platform_chosen']));
    expect(
      sink.sent.firstWhere((e) => e['step'] == 'platform_chosen')['platform'],
      'home_assistant',
    );
  });

  testWidgets('with a home: straight to the sign-in, no error page', (
    tester,
  ) async {
    final (c, sink) = await container({
      'onboarding_complete': true,
      'analytics_consent': true,
    });
    await tester.pumpWidget(app(c));
    await tester.pumpAndSettle();

    c.read(routerProvider).go(_link);
    await tester.pumpAndSettle();
    expect(find.text(_home), findsOneWidget);
    expect(find.byKey(const Key('ha-handed-note')), findsOneWidget);
    expect(find.textContaining('Page Not Found'), findsNothing);
    expect(sink.sent.where((e) => e['step'] == 'ha_link'), hasLength(1));
  });
}
