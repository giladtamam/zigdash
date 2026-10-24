import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/features/ha_import/ha_auth.dart';
import 'package:zigdash/features/onboarding/setup/ha_connect.dart';
import 'package:zigdash/features/onboarding/setup/ha_connect_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';

void main() {
  Future<HaConnectController> pump(
    WidgetTester tester, {
    HaSignInResult? signIn,
    HaConnectProblem? problem,
    List<(Uri, String)>? adopted,
    String? initialHost,
    String? again,
    Future<HaConnectProblem?>? slowProbe,
  }) async {
    final controller = HaConnectController(
      address: initialHost ?? '',
      adopt: (a, s) async => adopted?.add((a, s)),
      probe: (_, __) async => slowProbe != null ? await slowProbe : problem,
      signIn: signIn == null ? null : (_) async => signIn,
    );
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Like the app: pushed over setup, and `go`es back to it when done.
    final router = GoRouter(
      initialLocation: Routes.setup,
      routes: [
        GoRoute(path: Routes.setup, builder: (_, __) => const Text('setup')),
        GoRoute(
          path: Routes.haConnect,
          builder: (_, __) => HaConnectScreen(
            initialHost: initialHost,
            controller: controller,
            again: again,
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push(Routes.haConnect);
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('address prefilled, sign-in first, token on request', (
    tester,
  ) async {
    await pump(
      tester,
      initialHost: '192.168.68.52',
      signIn: (accessToken: 'a', refreshToken: 'r', error: null),
    );
    expect(find.text('Connect through Home Assistant'), findsOneWidget);
    expect(find.widgetWithText(TextField, '192.168.68.52'), findsOneWidget);
    expect(find.text('Sign in with Home Assistant'), findsOneWidget);
    expect(find.text('Long-lived access token'), findsNothing);
    expect(
      find.textContaining('keeps this sign-in on your phone'),
      findsOneWidget,
    );
    await tester.tap(find.text('Or use a long-lived token'));
    await tester.pump();
    expect(find.text('Long-lived access token'), findsOneWidget);
    expect(find.text('Connect with token'), findsOneWidget);
  });

  testWidgets('without a browser sign-in only the token way shows', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Sign in with Home Assistant'), findsNothing);
    expect(find.text('Long-lived access token'), findsOneWidget);
  });

  testWidgets('a pasted token that works leaves the screen', (tester) async {
    final adopted = <(Uri, String)>[];
    await pump(tester, adopted: adopted);
    await tester.enterText(
      find.widgetWithText(TextField, 'Home Assistant address'),
      'https://abc.ui.nabu.casa',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Long-lived access token'),
      'eyJ.tok',
    );
    await tester.tap(find.text('Connect with token'));
    await tester.pump();
    await tester.pump();
    expect(adopted.single.$1, Uri.parse('https://abc.ui.nabu.casa'));
    expect(adopted.single.$2, 'eyJ.tok');
    await tester.pumpAndSettle();
    expect(find.text('setup'), findsOneWidget, reason: 'back on setup');
  });

  testWidgets('not an admin: says so, opens the token field', (tester) async {
    await pump(
      tester,
      signIn: (accessToken: 'a', refreshToken: 'r', error: null),
      problem: HaConnectProblem.notAdmin,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Home Assistant address'),
      '192.168.68.52',
    );
    await tester.tap(find.text('Sign in with Home Assistant'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining("isn't an administrator"), findsOneWidget);
    expect(find.text('Long-lived access token'), findsOneWidget);
  });

  testWidgets('no MQTT integration: says what to add', (tester) async {
    await pump(tester, problem: HaConnectProblem.noMqtt);
    await tester.enterText(
      find.widgetWithText(TextField, 'Home Assistant address'),
      '192.168.68.52',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Long-lived access token'),
      'eyJ.tok',
    );
    await tester.tap(find.text('Connect with token'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('no MQTT integration'), findsOneWidget);
  });

  testWidgets('signing in again for a home returns to where it came from', (
    tester,
  ) async {
    final adopted = <(Uri, String)>[];
    await pump(
      tester,
      adopted: adopted,
      again: 'ha1',
      initialHost: 'https://abc.ui.nabu.casa',
    );
    expect(
      find.widgetWithText(TextField, 'https://abc.ui.nabu.casa'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Long-lived access token'),
      'eyJ.new',
    );
    await tester.tap(find.text('Connect with token'));
    await tester.pump();
    await tester.pump();
    expect(adopted.single.$2, 'eyJ.new');
    await tester.pumpAndSettle();
    expect(find.text('setup'), findsOneWidget, reason: 'popped back');
  });

  testWidgets('3.1.4: a long check says so and can be cancelled', (
    tester,
  ) async {
    final answer = Completer<HaConnectProblem?>();
    final adopted = <(Uri, String)>[];
    await pump(tester, adopted: adopted, slowProbe: answer.future);
    await tester.enterText(
      find.widgetWithText(TextField, 'Home Assistant address'),
      '192.168.1.20',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Long-lived access token'),
      'eyJ.tok',
    );
    await tester.tap(find.text('Connect with token'));
    await tester.pump();
    expect(find.text('Checking Home Assistant…'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.textContaining('up to 30 seconds'), findsNothing);
    await tester.pump(const Duration(seconds: 6));
    expect(find.textContaining('up to 30 seconds'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.widgetWithText(TextField, '192.168.1.20'), findsOneWidget);
    answer.complete(null);
    await tester.pumpAndSettle();
    expect(adopted, isEmpty);
    expect(find.text('setup'), findsNothing, reason: 'still on this screen');
  });

  testWidgets('3.1.4: an empty address says where to find it', (tester) async {
    await pump(
      tester,
      signIn: (accessToken: 'a', refreshToken: 'r', error: null),
    );
    expect(find.textContaining('Companion app'), findsNothing);
    await tester.tap(find.text('Sign in with Home Assistant'));
    await tester.pump();
    expect(
      find.text('Type the address you open Home Assistant with.'),
      findsOneWidget,
    );
    expect(find.textContaining('Companion app'), findsOneWidget);
  });
}
