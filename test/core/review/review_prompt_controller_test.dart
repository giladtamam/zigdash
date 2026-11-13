import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/review/review_launcher.dart';
import 'package:zigdash/core/review/review_prompt_controller.dart';
import 'package:zigdash/features/onboarding/setup/setup_completed_at.dart';

class _FakeSink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

class _FakeLauncher implements ReviewLauncher {
  _FakeLauncher({this.available = true});
  bool available;
  int requests = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async => requests++;
}

/// Mutable clock at day granularity.
class _Clock {
  _Clock(this.day);
  DateTime day;
  void advance(int days) => day = day.add(Duration(days: days));
  DateTime call() => day.add(const Duration(hours: 13, minutes: 7));
}

Future<(ReviewPromptController, _FakeLauncher, _Clock, SharedPreferences)>
_setup({
  Map<String, Object> initial = const {},
  bool available = true,
  _FakeSink? sink,
}) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final launcher = _FakeLauncher(available: available);
  final clock = _Clock(DateTime(2026, 9, 1));
  final c = ReviewPromptController(
    prefs: prefs,
    launcher: launcher,
    analytics: sink == null ? null : Analytics(sink, enabled: true),
    now: clock.call,
  );
  return (c, launcher, clock, prefs);
}

/// A command the user sent was confirmed, and it was the [nth] of the
/// session: what the trigger does on the third one.
Future<bool> _commandWin(ReviewPromptController c, {int nth = 3}) async {
  await c.recordCommandConfirmed();
  return c.maybeRequest(trigger: ReviewTrigger.command, nth: nth);
}

/// A device reported on its own: counts the day, then the passive ask.
Future<bool> _reportWin(ReviewPromptController c) async {
  await c.recordSuccessfulSession();
  return c.maybeRequest(trigger: ReviewTrigger.report);
}

/// An install old enough and used enough for the default policy.
Map<String, Object> _eligible({int sessions = 9}) => {
  ReviewPromptController.kSessions: sessions,
  ReviewPromptController.kFirstSessionDay: '2026-01-01',
  ReviewPromptController.kLastSessionDay: '2026-08-01',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('counting', () {
    test(
      'first session stores count, first day and last day; no prompt',
      () async {
        final (c, launcher, _, prefs) = await _setup();
        await c.recordSuccessfulSession();
        expect(prefs.getInt(ReviewPromptController.kSessions), 1);
        expect(
          prefs.getString(ReviewPromptController.kFirstSessionDay),
          '2026-09-01',
        );
        expect(
          prefs.getString(ReviewPromptController.kLastSessionDay),
          '2026-09-01',
        );
        expect(prefs.getString(ReviewPromptController.kLastPromptDay), isNull);
        expect(launcher.requests, 0);
      },
    );

    test('repeat calls on the same day count once', () async {
      final (c, _, _, prefs) = await _setup();
      await c.recordSuccessfulSession();
      await c.recordCommandConfirmed();
      await c.recordSuccessfulSession();
      expect(prefs.getInt(ReviewPromptController.kSessions), 1);
    });

    test('counting never requests, however eligible the install', () async {
      final (c, launcher, _, _) = await _setup(initial: _eligible());
      await c.recordSuccessfulSession();
      await c.recordCommandConfirmed();
      expect(launcher.requests, 0);
    });

    test('stores only day-granularity keys', () async {
      final (c, _, _, prefs) = await _setup();
      await c.recordSuccessfulSession();
      expect(prefs.getKeys(), {
        ReviewPromptController.kSessions,
        ReviewPromptController.kFirstSessionDay,
        ReviewPromptController.kLastSessionDay,
      });
    });

    test('a confirmed command adds only the command-ever flag', () async {
      final (c, _, _, prefs) = await _setup();
      expect(c.commandEver, isFalse);
      await c.recordCommandConfirmed();
      expect(c.commandEver, isTrue);
      expect(prefs.getKeys(), {
        ReviewPromptController.kSessions,
        ReviewPromptController.kFirstSessionDay,
        ReviewPromptController.kLastSessionDay,
        ReviewPromptController.kCommandEver,
      });
    });
  });

  group('command trigger', () {
    test('prompts once policy is met and records the prompt day', () async {
      final (c, launcher, clock, prefs) = await _setup();
      // Day 1 (Sep 1): first confirmed command. Never on the first day.
      expect(await _commandWin(c), isFalse);
      expect(launcher.requests, 0);
      clock.advance(1);
      // Day 2 (Sep 2): second session, but only a day after the first.
      expect(await _commandWin(c), isFalse);
      expect(launcher.requests, 0);
      clock.advance(1);
      // Day 3 (Sep 3): two days after the first.
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 1);
      expect(
        prefs.getString(ReviewPromptController.kLastPromptDay),
        '2026-09-03',
      );

      // Same day again: nothing new.
      expect(await _commandWin(c), isFalse);
      expect(launcher.requests, 1);
    });

    test(
      'does not request when the platform flow is unavailable, but stamps the day',
      () async {
        final (c, launcher, _, prefs) = await _setup(
          initial: _eligible(),
          available: false,
        );
        expect(await _commandWin(c), isFalse);
        expect(launcher.requests, 0);
        // Stamped so the cooldown applies: `unavailable` is reported once
        // per 90 days, not on every win.
        expect(
          prefs.getString(ReviewPromptController.kLastPromptDay),
          '2026-09-01',
        );
      },
    );

    test('honours the 90-day cooldown between prompts', () async {
      final (c, launcher, clock, _) = await _setup(initial: _eligible());
      expect(await _commandWin(c), isTrue);
      clock.advance(89);
      expect(await _commandWin(c), isFalse);
      clock.advance(1);
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 2);
    });

    test('maybeRequest with a command trigger marks the install', () async {
      final (c, _, _, _) = await _setup();
      await c.maybeRequest(trigger: ReviewTrigger.command, nth: 3);
      expect(c.commandEver, isTrue);
    });
  });

  group('setup window', () {
    test('refuses within 10 minutes of setup, asks after', () async {
      final (c, launcher, clock, prefs) = await _setup(initial: _eligible());
      final now = clock.call().millisecondsSinceEpoch;

      await prefs.setInt(
        kSetupCompletedAtMs,
        now - const Duration(minutes: 9, seconds: 59).inMilliseconds,
      );
      expect(await _commandWin(c), isFalse);
      expect(launcher.requests, 0);
      expect(
        prefs.getString(ReviewPromptController.kLastPromptDay),
        isNull,
        reason: 'a refusal in the window must not spend the cooldown',
      );

      await prefs.setInt(
        kSetupCompletedAtMs,
        now - const Duration(minutes: 10).inMilliseconds,
      );
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 1);
    });

    test('a setup just now blocks the passive ask too', () async {
      final (c, launcher, clock, prefs) = await _setup(initial: _eligible());
      await prefs.setInt(
        kSetupCompletedAtMs,
        clock.call().millisecondsSinceEpoch - 1000,
      );
      expect(await _reportWin(c), isFalse);
      expect(launcher.requests, 0);
    });

    test('no setup time stored means no window', () async {
      final (c, launcher, _, _) = await _setup(initial: _eligible());
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 1);
    });

    test('the window is read from the controller clock', () async {
      final (c, launcher, clock, prefs) = await _setup(initial: _eligible());
      // Setup 5 minutes before the controller's clock; then a day passes on
      // that clock, whatever the wall clock says.
      await prefs.setInt(
        kSetupCompletedAtMs,
        clock.call().millisecondsSinceEpoch -
            const Duration(minutes: 5).inMilliseconds,
      );
      expect(await _commandWin(c), isFalse);
      clock.advance(1);
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 1);
    });
  });

  group('sensor-only homes (report trigger)', () {
    test('no command ever, 7 counted days, a report: prompts', () async {
      final (c, launcher, clock, _) = await _setup();
      for (var day = 1; day <= 6; day++) {
        expect(await _reportWin(c), isFalse, reason: 'day $day');
        clock.advance(1);
      }
      expect(c.sessions, 6);
      expect(await _reportWin(c), isTrue);
      expect(launcher.requests, 1);
    });

    test(
      'a report on an eligible day does not prompt once a command was ever '
      'confirmed',
      () async {
        final (c, launcher, _, _) = await _setup(
          initial: {..._eligible(), ReviewPromptController.kCommandEver: true},
        );
        expect(await _reportWin(c), isFalse);
        expect(launcher.requests, 0);
        // The command path on the same install still asks.
        expect(await _commandWin(c), isTrue);
        expect(launcher.requests, 1);
      },
    );

    test('commands on day 1, then reports: day 7 must NOT prompt', () async {
      final (c, launcher, clock, _) = await _setup();
      // Day 1: the user taps a couple of tiles; the policy is far from met,
      // but the install is marked as one that sends commands.
      await c.recordCommandConfirmed();
      await c.recordCommandConfirmed();
      expect(c.commandEver, isTrue);
      clock.advance(1);
      // Days 2..7: sensors only.
      for (var day = 2; day <= 7; day++) {
        expect(await _reportWin(c), isFalse, reason: 'day $day');
        clock.advance(1);
      }
      expect(c.sessions, 7);
      // Day 8 and later: still no passive ask on this install.
      expect(await _reportWin(c), isFalse);
      expect(launcher.requests, 0);
    });

    test('fewer than 7 counted days: no passive ask, however old', () async {
      final (c, launcher, _, _) = await _setup(
        initial: _eligible(sessions: 5),
      );
      // Today's report makes it 6.
      expect(await _reportWin(c), isFalse);
      expect(c.sessions, 6);
      expect(launcher.requests, 0);
    });

    test('the seventh counted day itself may ask', () async {
      final (c, launcher, _, _) = await _setup(
        initial: _eligible(sessions: 6),
      );
      // The day is counted (6 -> 7) before the ask.
      expect(await _reportWin(c), isTrue);
      expect(c.sessions, 7);
      expect(launcher.requests, 1);
    });

    test('the report trigger does not mark the install', () async {
      final (c, _, _, _) = await _setup(initial: _eligible());
      await _reportWin(c);
      expect(c.commandEver, isFalse);
    });
  });

  group('usage event', () {
    test(
      'sent only when the policy is met, with result, trigger and nth',
      () async {
        final sink = _FakeSink();
        final (c, launcher, clock, _) = await _setup(sink: sink);

        await _commandWin(c);
        expect(sink.sent, isEmpty, reason: 'first day: policy not met');

        clock.advance(1);
        await _commandWin(c);
        expect(sink.sent, isEmpty, reason: 'a day later: still too soon');

        clock.advance(1);
        await _commandWin(c);
        expect(sink.sent.length, 1);
        expect(sink.sent.single.$1, 'review_prompt');
        expect(sink.sent.single.$2, {
          'result': 'requested',
          'trigger': 'command',
          'nth': '3',
        });

        // Unavailable flow: reported as such, nothing requested.
        launcher.available = false;
        clock.advance(90);
        expect(await _commandWin(c, nth: 12), isFalse);
        expect(sink.sent.length, 2);
        expect(sink.sent.last.$1, 'review_prompt');
        expect(sink.sent.last.$2, {
          'result': 'unavailable',
          'trigger': 'command',
          'nth': '10+',
        });
        expect(launcher.requests, 1);
      },
    );

    test('a passive ask reports the report trigger and no nth', () async {
      final sink = _FakeSink();
      final (c, _, _, _) = await _setup(initial: _eligible(), sink: sink);
      expect(await _reportWin(c), isTrue);
      expect(sink.sent.single.$2, {
        'result': 'requested',
        'trigger': 'report',
      });
    });

    test('a refusal before the policy sends nothing', () async {
      final sink = _FakeSink();
      final (c, _, clock, prefs) = await _setup(
        initial: _eligible(),
        sink: sink,
      );
      await prefs.setInt(
        kSetupCompletedAtMs,
        clock.call().millisecondsSinceEpoch,
      );
      expect(await _commandWin(c), isFalse);
      expect(sink.sent, isEmpty);
    });
  });
}
