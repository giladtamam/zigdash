import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/features/ha_import/ha_auth.dart';
import 'package:zigdash/features/onboarding/setup/ha_connect.dart';
import 'package:zigdash/features/onboarding/setup/ha_connect_screen.dart';
import 'package:zigdash/features/onboarding/setup/ha_discovery.dart';
import 'package:zigdash/features/onboarding/setup/ha_handover.dart';
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
    HaFind? findHa,
    bool settle = true,
    bool offWifi = false,
    HaReach? reach,
    String? phoneIp,
    List<Override> overrides = const [],
    bool shared = false,
    bool shareTarget = false,
    void Function(AnalyticsEvent event)? onEvent,
  }) async {
    final controller = HaConnectController(
      address: initialHost ?? '',
      adopt: (a, s) async => adopted?.add((a, s)),
      probe: (_, __) async => slowProbe != null ? await slowProbe : problem,
      signIn: signIn == null ? null : (_) async => signIn,
      find: findHa,
      reach: reach,
      phoneIp: phoneIp == null ? null : () async => phoneIp,
      onEvent: onEvent,
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
            shared: shared,
            controller: controller,
            again: again,
            offWifi: offWifi,
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Whether ZigDash is in other apps' share sheets: no database
          // behind it in these tests.
          haShareTargetProvider.overrideWith(
            (ref) => Stream.value(shareTarget),
          ),
          ...overrides,
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push(Routes.haConnect);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      // A spinner never settles: past the route's transition.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }
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
    await tester.pump();
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
    await tester.pump();
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
    await tester.pump();
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
    await tester.pump();
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
    await tester.pump();
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

  testWidgets('3.3.1: an empty address says where to find it, and the '
      'sign-in waits for one', (tester) async {
    await pump(
      tester,
      signIn: (accessToken: 'a', refreshToken: 'r', error: null),
    );
    FilledButton button() =>
        tester.widget<FilledButton>(find.byKey(const Key('ha-sign-in')));
    expect(find.textContaining('Companion app'), findsOneWidget);
    expect(button().onPressed, isNull);
    await tester.enterText(find.byType(TextField).first, '192.168.1.20');
    await tester.pump();
    expect(button().onPressed, isNotNull);
    expect(find.textContaining('Companion app'), findsNothing);
  });

  group('3.1.8: Home Assistant found on the network', () {
    const signIn = (accessToken: 'a', refreshToken: 'r', error: null);
    TextField field(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField).first);

    testWidgets('one: fills the address and says so', (tester) async {
      final found = Completer<List<HaFound>>();
      await pump(
        tester,
        signIn: signIn,
        findHa: () => found.future,
        settle: false,
      );
      expect(
        find.text('Looking for Home Assistant on this network…'),
        findsOneWidget,
      );
      found.complete([
        const HaFound(address: 'http://192.168.68.64:8123', name: 'Home'),
      ]);
      await tester.pumpAndSettle();
      expect(field(tester).controller!.text, 'http://192.168.68.64:8123');
      expect(
        find.text('Found Home Assistant at 192.168.68.64:8123'),
        findsOneWidget,
      );
    });

    testWidgets('a typed address is not replaced, and no look', (tester) async {
      var looks = 0;
      await pump(
        tester,
        signIn: signIn,
        initialHost: '192.168.1.5',
        findHa: () async {
          looks++;
          return [];
        },
      );
      expect(looks, 0);
      expect(field(tester).controller!.text, '192.168.1.5');
    });

    testWidgets('several: one chip each, a tap fills it', (tester) async {
      await pump(
        tester,
        signIn: signIn,
        findHa: () async => const [
          HaFound(address: 'http://192.168.68.64:8123', name: 'Home'),
          HaFound(address: 'http://192.168.68.70:8123'),
        ],
      );
      expect(
        find.text('Found more than one Home Assistant. Tap the one to use:'),
        findsOneWidget,
      );
      await tester.tap(find.text('192.168.68.70:8123'));
      await tester.pump();
      expect(field(tester).controller!.text, 'http://192.168.68.70:8123');
      expect(find.text('Home · 192.168.68.64:8123'), findsOneWidget);
    });

    testWidgets('3.1.12: none says so at once, and names the remote address', (
      tester,
    ) async {
      await pump(tester, signIn: signIn, findHa: () async => []);
      expect(
        find.textContaining("can't see Home Assistant on this Wi-Fi"),
        findsOneWidget,
      );
      expect(find.textContaining('ui.nabu.casa'), findsWidgets);
      expect(find.textContaining('Companion app'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('ha-sign-in')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('3.3.4: where they open it says what to type and where '
        'to find it', (tester) async {
      final sent = <String>[];
      await pump(
        tester,
        signIn: signIn,
        findHa: () async => [],
        overrides: [
          analyticsProvider.overrideWithValue(
            Analytics(_Sink(sent), enabled: true),
          ),
        ],
      );
      expect(find.text('Where do you open Home Assistant?'), findsOneWidget);
      expect(find.textContaining('Remote access'), findsNothing);
      await tester.tap(find.byKey(const Key('ha-where-nabuCasa')));
      await tester.pump();
      expect(find.textContaining('Remote access'), findsOneWidget);
      expect(field(tester).decoration?.hintText, contains('ui.nabu.casa'));
      expect(sent, ['setup_step {step: ha_where, choice: nabu_casa}']);

      await tester.tap(find.byKey(const Key('ha-where-duckDns')));
      await tester.pump();
      expect(find.textContaining('duckdns.org:8123'), findsWidgets);
      expect(sent.last, 'setup_step {step: ha_where, choice: duck_dns}');

      // The chip's help stays while the address is typed.
      await tester.enterText(find.byType(TextField).first, 'x.duckdns.org');
      await tester.pump();
      expect(find.textContaining('duckdns.org:8123'), findsWidgets);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('ha-sign-in')))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('3.4.8: while looking, the button says so and waits', (
      tester,
    ) async {
      // Until 3.4.7 a tap during the look waited for what it found; most
      // looks find nothing, so the tap was wasted. Now the button is off
      // and says it is looking, and comes back once the look ends.
      final found = Completer<List<HaFound>>();
      await pump(
        tester,
        signIn: signIn,
        findHa: () => found.future,
        settle: false,
      );
      final button = find.byKey(const Key('ha-sign-in'));
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(find.text('Looking for Home Assistant…'), findsOneWidget);
      found.complete(const []);
      await tester.pumpAndSettle();
      expect(find.text('Looking for Home Assistant…'), findsNothing);
      expect(find.text('Sign in with Home Assistant'), findsOneWidget);
      // Still no address: still off, and where to find it shows.
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
    });
  });

  testWidgets('3.1.9: from the no-Wi-Fi screen, no look; remote is named', (
    tester,
  ) async {
    var looks = 0;
    await pump(
      tester,
      signIn: (accessToken: 'a', refreshToken: 'r', error: null),
      offWifi: true,
      findHa: () async {
        looks++;
        return [];
      },
    );
    expect(looks, 0);
    expect(
      find.text('Looking for Home Assistant on this network…'),
      findsNothing,
    );
    expect(find.textContaining('Nabu Casa or Cloudflare'), findsOneWidget);
  });

  group('3.1.12: nothing answered, told by the kind of address', () {
    const signIn = (accessToken: 'acc', refreshToken: 'ref', error: null);

    Future<void> tryAddress(WidgetTester tester, String address) async {
      await tester.enterText(find.byType(TextField).first, address);
      await tester.pump();
      await tester.tap(find.text('Sign in with Home Assistant'));
      await tester.pumpAndSettle();
    }

    testWidgets("another network: names the phone's", (tester) async {
      await pump(
        tester,
        signIn: signIn,
        phoneIp: '192.168.68.40',
        reach: (_) async => HaConnectProblem.unreachable,
      );
      await tryAddress(tester, '192.168.1.20');
      expect(
        find.textContaining('different network from this phone'),
        findsOneWidget,
      );
      expect(find.textContaining('192.168.68.x'), findsOneWidget);
    });

    testWidgets('a .local name: type the IP', (tester) async {
      await pump(
        tester,
        signIn: signIn,
        reach: (_) async => HaConnectProblem.unreachable,
      );
      await tryAddress(tester, 'homeassistant.local');
      expect(find.textContaining('.local names'), findsOneWidget);
    });

    testWidgets("a remote address: try it in the phone's browser", (
      tester,
    ) async {
      await pump(
        tester,
        signIn: signIn,
        reach: (_) async => HaConnectProblem.unreachable,
      );
      await tryAddress(tester, 'https://home.duckdns.org');
      expect(find.textContaining('remote address'), findsWidgets);
      expect(find.textContaining("this phone's browser"), findsOneWidget);
    });
  });

  // docs/design/ha-share-paste.md: the address is handed over, not typed.
  group('Paste and Share', () {
    late List<(String, Map<String, String>)> sent;

    Override analytics() {
      sent = [];
      return analyticsProvider.overrideWithValue(
        Analytics(_PropsSink(sent), enabled: true),
      );
    }

    void copied(WidgetTester tester, String? text) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => call.method == 'Clipboard.getData'
            ? (text == null ? null : {'text': text})
            : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
    }

    List<Map<String, String>> steps(String step) => [
      for (final (name, props) in sent)
        if (name == 'setup_step' && props['step'] == step) props,
    ];

    const ok = (accessToken: 'a', refreshToken: 'r', error: null);
    const sharedNote = 'This is the address you shared. Sign in to connect.';

    testWidgets("Paste takes the Home Assistant app's Share server link", (
      tester,
    ) async {
      copied(
        tester,
        'https://my.home-assistant.io/invite/#url=http%3A%2F%2F192.168.1.20%3A8123',
      );
      final events = <Map<String, String>>[];
      final adopted = <(Uri, String)>[];
      await pump(
        tester,
        signIn: ok,
        adopted: adopted,
        overrides: [analytics()],
        onEvent: (e) => events.add(e.props),
      );
      // Nothing was read before the tap.
      expect(
        find.widgetWithText(TextField, 'http://192.168.1.20:8123'),
        findsNothing,
      );
      await tester.tap(find.byKey(const Key('ha-paste')));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, 'http://192.168.1.20:8123'),
        findsOneWidget,
      );
      expect(steps('ha_paste'), [
        {'step': 'ha_paste', 'result': 'address'},
      ]);
      await tester.tap(find.byKey(const Key('ha-sign-in')));
      await tester.pumpAndSettle();
      expect(adopted.single.$1, Uri.parse('http://192.168.1.20:8123'));
      final tried = events.where((e) => e['step'] == 'ha_connect').single;
      expect(tried['from'], 'pasted');
      expect(tried['path'], 'pasted/ok');
    });

    testWidgets('Paste with no address in the clipboard says so', (
      tester,
    ) async {
      copied(tester, 'milk, eggs, bread');
      await pump(tester, signIn: ok, overrides: [analytics()]);
      await tester.tap(find.byKey(const Key('ha-paste')));
      await tester.pumpAndSettle();
      expect(find.text('No address in what you copied.'), findsOneWidget);
      expect(steps('ha_paste').single['result'], 'no_address');
      final signIn = tester.widget<FilledButton>(
        find.byKey(const Key('ha-sign-in')),
      );
      expect(signIn.onPressed, isNull, reason: 'still nothing to sign in to');
      // Typing clears the line.
      await tester.enterText(find.byType(TextField).first, '192.168.1.9');
      await tester.pump();
      expect(find.text('No address in what you copied.'), findsNothing);
    });

    testWidgets('an empty clipboard is no address either', (tester) async {
      copied(tester, null);
      await pump(tester, signIn: ok, overrides: [analytics()]);
      await tester.tap(find.byKey(const Key('ha-paste')));
      await tester.pumpAndSettle();
      expect(find.text('No address in what you copied.'), findsOneWidget);
    });

    testWidgets('a pasted address edited by hand counts as typed', (
      tester,
    ) async {
      copied(tester, 'http://192.168.1.20:8123/lovelace/0');
      final events = <Map<String, String>>[];
      await pump(
        tester,
        signIn: ok,
        overrides: [analytics()],
        onEvent: (e) => events.add(e.props),
      );
      await tester.tap(find.byKey(const Key('ha-paste')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '192.168.1.21');
      await tester.pump();
      await tester.tap(find.byKey(const Key('ha-sign-in')));
      await tester.pumpAndSettle();
      expect(
        events.where((e) => e['step'] == 'ha_connect').single['from'],
        'typed',
      );
    });

    testWidgets('a shared address fills the field, says so, and is counted '
        'as shared', (tester) async {
      final events = <Map<String, String>>[];
      var looks = 0;
      await pump(
        tester,
        signIn: ok,
        initialHost: 'https://abc.ui.nabu.casa',
        shared: true,
        findHa: () async {
          looks++;
          return const [];
        },
        onEvent: (e) => events.add(e.props),
      );
      expect(
        find.widgetWithText(TextField, 'https://abc.ui.nabu.casa'),
        findsOneWidget,
      );
      expect(find.text(sharedNote), findsOneWidget);
      expect(looks, 0, reason: 'the address is here: nothing to look for');
      await tester.tap(find.byKey(const Key('ha-sign-in')));
      await tester.pumpAndSettle();
      final tried = events.where((e) => e['step'] == 'ha_connect').single;
      expect(tried['from'], 'shared');
      expect(tried['path'], 'shared/ok');
    });

    testWidgets('a share that held no address says how to share one', (
      tester,
    ) async {
      await pump(tester, signIn: ok, shared: true);
      expect(find.textContaining("That didn't hold an address"), findsOneWidget);
      expect(find.text(sharedNote), findsNothing);
    });

    testWidgets('the address the scan saw counts as found', (tester) async {
      final events = <Map<String, String>>[];
      await pump(
        tester,
        signIn: ok,
        initialHost: '192.168.68.52',
        onEvent: (e) => events.add(e.props),
      );
      expect(find.text(sharedNote), findsNothing);
      await tester.tap(find.byKey(const Key('ha-sign-in')));
      await tester.pumpAndSettle();
      expect(
        events.where((e) => e['step'] == 'ha_connect').single['from'],
        'found',
      );
    });

    testWidgets('the help says to share while ZigDash is in the share sheet', (
      tester,
    ) async {
      await pump(tester, signIn: ok, shareTarget: true);
      expect(find.textContaining('and pick ZigDash'), findsOneWidget);
      expect(find.textContaining('and Copy link'), findsNothing);
    });

    testWidgets('with a home already, the help is copy and paste', (
      tester,
    ) async {
      await pump(tester, signIn: ok);
      expect(find.textContaining('and Copy link'), findsOneWidget);
      expect(find.textContaining('and pick ZigDash'), findsNothing);
    });
  });
}

class _Sink implements AnalyticsSink {
  _Sink(this.sent);
  final List<String> sent;
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

/// Keeps each event's name and properties.
class _PropsSink implements AnalyticsSink {
  _PropsSink(this.sent);
  final List<(String, Map<String, String>)> sent;
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}
