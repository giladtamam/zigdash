import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/ha_import/ha_auth.dart';
import 'package:zigdash/features/onboarding/setup/ha_connect.dart';
import 'package:zigdash/mqtt/ha_token.dart';

void main() {
  late List<(Uri, String)> probed;
  late List<(Uri, String)> adopted;
  late List<Map<String, String>> events;
  late int browsers;

  HaConnectController make({
    HaSignInResult? signIn,
    HaConnectProblem? problem,
    String address = '',
    HaReach? reach,
    Future<HaConnectProblem?> Function()? slowProbe,
  }) {
    probed = [];
    adopted = [];
    events = [];
    browsers = 0;
    return HaConnectController(
      address: address,
      adopt: (a, s) async => adopted.add((a, s)),
      probe: (base, stored) async {
        probed.add((base, stored));
        return slowProbe != null ? slowProbe() : problem;
      },
      signIn: signIn == null
          ? null
          : (_) async {
              browsers++;
              return signIn;
            },
      reach: reach,
      onEvent: (e) => events.add(e.props),
    );
  }

  List<String?> outcomes() => [
    for (final e in events)
      if (e['step'] == 'ha_connect') e['result'],
  ];

  test('starts asking, with the address the scan saw', () {
    final c = make(address: '192.168.68.52');
    expect((c.value as HaConnectAsk).address, '192.168.68.52');
    expect(c.canSignIn, isFalse);
  });

  test('the login page: keeps the refresh token, checks, hands over', () async {
    final c = make(
      signIn: (accessToken: 'acc', refreshToken: 'ref', error: null),
    );
    await c.signInAndConnect('https://abc.ui.nabu.casa');
    expect(probed.single.$1, Uri.parse('https://abc.ui.nabu.casa'));
    expect(probed.single.$2, haStoredRefresh('ref'));
    expect(adopted.single.$2, haStoredRefresh('ref'));
    expect(c.value, isA<HaConnectDone>());
    expect(outcomes(), ['ok']);
    // Never a token in an event.
    expect(events.join(), isNot(contains('ref')));
  });

  test('a pasted token is kept as is', () async {
    final c = make();
    await c.connectWithToken('192.168.68.52', ' eyJ.long.lived ');
    expect(probed.single.$1, Uri.parse('http://192.168.68.52:8123'));
    expect(probed.single.$2, 'eyJ.long.lived');
    expect(adopted.single.$2, 'eyJ.long.lived');
    expect(outcomes(), ['ok']);
  });

  test('no address, no token: asked again, nothing probed', () async {
    final c = make(
      signIn: (accessToken: 'acc', refreshToken: 'ref', error: null),
    );
    await c.signInAndConnect('   ');
    expect((c.value as HaConnectAsk).problem, HaConnectProblem.noAddress);
    await c.connectWithToken('192.168.68.52', '');
    expect((c.value as HaConnectAsk).problem, HaConnectProblem.noToken);
    expect(probed, isEmpty);
    expect(outcomes(), ['no_address']);
  });

  test(
    'closing the login quietly returns; refused and failed say why',
    () async {
      for (final (error, problem, outcome) in [
        (HaSignInError.cancelled, null, 'sign_in_cancelled'),
        (
          HaSignInError.refused,
          HaConnectProblem.signInRefused,
          'sign_in_refused',
        ),
        (HaSignInError.failed, HaConnectProblem.signInFailed, 'sign_in_failed'),
      ]) {
        final c = make(
          signIn: (accessToken: null, refreshToken: null, error: error),
        );
        await c.signInAndConnect('192.168.68.52');
        expect((c.value as HaConnectAsk).problem, problem);
        expect(adopted, isEmpty);
        expect(outcomes(), [outcome]);
      }
    },
  );

  test(
    'what the check finds is shown and counted, nothing handed over',
    () async {
      for (final (problem, outcome) in [
        (HaConnectProblem.unreachable, 'unreachable'),
        (HaConnectProblem.notHomeAssistant, 'not_home_assistant'),
        (HaConnectProblem.certificate, 'certificate'),
        (HaConnectProblem.badToken, 'bad_token'),
        (HaConnectProblem.notAdmin, 'not_admin'),
        (HaConnectProblem.noMqtt, 'no_mqtt'),
      ]) {
        final c = make(problem: problem);
        await c.connectWithToken('192.168.68.52', 'tok');
        expect((c.value as HaConnectAsk).problem, problem);
        expect((c.value as HaConnectAsk).address, '192.168.68.52');
        expect(adopted, isEmpty);
        expect(outcomes(), [outcome]);
      }
    },
  );

  test('the setup_step event carries only the kind and the outcome', () {
    expect(
      const SetupStep(
        SetupStepKind.haConnect,
        result: HaConnectOutcome.notAdmin,
      ).props,
      {'step': 'ha_connect', 'result': 'not_admin'},
    );
  });

  group('3.1.4: no silent sign-in, a way out', () {
    const ok = (accessToken: 'acc', refreshToken: 'ref', error: null);

    test('nothing answers: says so, the browser never opens', () async {
      final reached = <Uri>[];
      final c = make(
        signIn: ok,
        reach: (base) async {
          reached.add(base);
          return HaConnectProblem.unreachable;
        },
      );
      await c.signInAndConnect('homeassistant.local');
      expect(reached.single, Uri.parse('http://homeassistant.local:8123'));
      expect(browsers, 0);
      expect(c.value, isA<HaConnectAsk>());
      expect((c.value as HaConnectAsk).problem, HaConnectProblem.unreachable);
      expect((c.value as HaConnectAsk).address, 'homeassistant.local');
      expect(outcomes(), ['unreachable']);
    });

    test('an untrusted certificate is named', () async {
      final c = make(
        signIn: ok,
        reach: (_) async => HaConnectProblem.certificate,
      );
      await c.signInAndConnect('https://ha.example');
      expect((c.value as HaConnectAsk).problem, HaConnectProblem.certificate);
      expect(outcomes(), ['certificate']);
    });

    test('Home Assistant answers: on to the browser as before', () async {
      final c = make(signIn: ok, reach: (_) async => null);
      await c.signInAndConnect('192.168.1.20');
      expect(browsers, 1);
      expect(c.value, isA<HaConnectDone>());
    });

    test(
      'cancel while checking: back to the address, nothing handed on',
      () async {
        final answer = Completer<HaConnectProblem?>();
        final c = make(slowProbe: () => answer.future);
        final going = c.connectWithToken('192.168.1.20', 'tok');
        expect(c.value, isA<HaConnectChecking>());
        c.cancel();
        expect(c.value, isA<HaConnectAsk>());
        expect((c.value as HaConnectAsk).address, '192.168.1.20');
        expect((c.value as HaConnectAsk).problem, isNull);
        answer.complete(null);
        await going;
        expect(adopted, isEmpty);
        expect(c.value, isA<HaConnectAsk>());
        expect(outcomes(), isEmpty);
      },
    );

    test('leaving the screen mid-check stops the try', () async {
      final answer = Completer<HaConnectProblem?>();
      final c = make(slowProbe: () => answer.future);
      final going = c.connectWithToken('192.168.1.20', 'tok');
      c.dispose();
      answer.complete(null);
      await going;
      expect(adopted, isEmpty);
    });
  });
}
