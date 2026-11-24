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

/// A command the user sent was confirmed: what the trigger does on the
/// first one of a visit (3.6.1).
Future<bool> _commandWin(ReviewPromptController c) async {
  await c.recordCommandConfirmed();
  return c.maybeRequest(trigger: ReviewTrigger.command);
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
      // Day 2 (Sep 2): second session, a calendar day after the first
      // (3.8.4; was day 3).
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 1);
      expect(
        prefs.getString(ReviewPromptController.kLastPromptDay),
        '2026-09-02',
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
      await c.maybeRequest(trigger: ReviewTrigger.command);
      expect(c.commandEver, isTrue);
    });
  });

  group('setup window', () {
    test('refuses within 18 hours of setup, asks after', () async {
      final (c, launcher, clock, prefs) = await _setup(initial: _eligible());
      final now = clock.call().millisecondsSinceEpoch;

      await prefs.setInt(
        kSetupCompletedAtMs,
        now - const Duration(hours: 17, minutes: 59).inMilliseconds,
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
        now - const Duration(hours: 18).inMilliseconds,
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

  group('fresh install timing (3.8.4: one day, 18 hours)', () {
    /// A fresh install whose setup finished at [setupAt], on a clock the
    /// test moves to exact times.
    Future<(ReviewPromptController, _FakeLauncher, void Function(DateTime))>
    fresh(DateTime setupAt) async {
      SharedPreferences.setMockInitialValues({
        kSetupCompletedAtMs: setupAt.millisecondsSinceEpoch,
      });
      final prefs = await SharedPreferences.getInstance();
      final launcher = _FakeLauncher();
      var now = setupAt;
      final c = ReviewPromptController(
        prefs: prefs,
        launcher: launcher,
        now: () => now,
      );
      // The setup day's live data counts the first session.
      await c.recordSuccessfulSession();
      return (c, launcher, (DateTime t) => now = t);
    }

    // 3.1.9 in the wild: set up at 22:35, a light switched at 01:00.
    test('does not ask the night after setup (22:35, then 01:00)', () async {
      final (c, launcher, at) = await fresh(DateTime(2026, 10, 24, 22, 35));
      at(DateTime(2026, 10, 25, 1));
      expect(await _commandWin(c), isFalse);
      expect(launcher.requests, 0);
    });

    test('asks the next day once 18 hours have passed', () async {
      final (c, launcher, at) = await fresh(DateTime(2026, 11, 23, 10));
      at(DateTime(2026, 11, 24, 3)); // 17 hours: still quiet
      expect(await _commandWin(c), isFalse);
      at(DateTime(2026, 11, 24, 10)); // 24 hours
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 1);
    });

    test('never on the setup day itself, however late', () async {
      final (c, launcher, at) = await fresh(DateTime(2026, 11, 23, 0, 5));
      at(DateTime(2026, 11, 23, 23, 50)); // 23 h 45 min, same calendar day
      expect(await _commandWin(c), isFalse);
      expect(launcher.requests, 0);
    });

    test('a new setup restarts the 18 hours', () async {
      final (c, launcher, at) = await fresh(DateTime(2026, 11, 23, 10));
      final prefs = await SharedPreferences.getInstance();
      // Another broker set up the next morning.
      await prefs.setInt(
        kSetupCompletedAtMs,
        DateTime(2026, 11, 24, 9).millisecondsSinceEpoch,
      );
      at(DateTime(2026, 11, 24, 12));
      expect(await _commandWin(c), isFalse);
      at(DateTime(2026, 11, 25, 12));
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 1);
    });

    test(
      'an install with no setup time (before 3.4.8) needs only the policy',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final launcher = _FakeLauncher();
        var now = DateTime(2026, 11, 23, 22, 35);
        final c = ReviewPromptController(
          prefs: prefs,
          launcher: launcher,
          now: () => now,
        );
        await c.recordSuccessfulSession();
        now = DateTime(2026, 11, 24, 8);
        expect(await _commandWin(c), isTrue);
        expect(launcher.requests, 1);
      },
    );
  });

  group('sensor-only homes (report trigger)', () {
    test('no command ever, 4 counted days, a report: prompts', () async {
      final (c, launcher, clock, _) = await _setup();
      for (var day = 1; day <= 3; day++) {
        expect(await _reportWin(c), isFalse, reason: 'day $day');
        clock.advance(1);
      }
      expect(c.sessions, 3);
      expect(await _reportWin(c), isTrue);
      expect(launcher.requests, 1);
    });

    test('a report on an eligible day does not prompt once a command was ever '
        'confirmed', () async {
      final (c, launcher, _, _) = await _setup(
        initial: {..._eligible(), ReviewPromptController.kCommandEver: true},
      );
      expect(await _reportWin(c), isFalse);
      expect(launcher.requests, 0);
      // The command path on the same install still asks.
      expect(await _commandWin(c), isTrue);
      expect(launcher.requests, 1);
    });

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

    test('fewer than 4 counted days: no passive ask, however old', () async {
      final (c, launcher, _, _) = await _setup(initial: _eligible(sessions: 2));
      // Today's report makes it 3.
      expect(await _reportWin(c), isFalse);
      expect(c.sessions, 3);
      expect(launcher.requests, 0);
    });

    test('the fourth counted day itself may ask', () async {
      final (c, launcher, _, _) = await _setup(initial: _eligible(sessions: 3));
      // The day is counted (3 -> 4) before the ask.
      expect(await _reportWin(c), isTrue);
      expect(c.sessions, 4);
      expect(launcher.requests, 1);
    });

    test('a report and a command at the same moment ask once', () async {
      final (c, launcher, _, _) = await _setup(initial: _eligible());
      final results = await Future.wait([
        c.maybeRequest(trigger: ReviewTrigger.report),
        c.maybeRequest(trigger: ReviewTrigger.command),
      ]);
      expect(results.where((r) => r), hasLength(1));
      expect(launcher.requests, 1);
    });

    test('the report trigger does not mark the install', () async {
      final (c, _, _, _) = await _setup(initial: _eligible());
      await _reportWin(c);
      expect(c.commandEver, isFalse);
    });
  });

  group('usage event', () {
    test('sent only when the policy is met, with result and trigger', () async {
      final sink = _FakeSink();
      final (c, launcher, clock, _) = await _setup(sink: sink);

      await _commandWin(c);
      expect(sink.sent, isEmpty, reason: 'first day: policy not met');

      clock.advance(1);
      await _commandWin(c);
      expect(sink.sent.length, 1, reason: 'a day later (3.8.4)');
      expect(sink.sent.single.$1, 'review_prompt');
      expect(sink.sent.single.$2, {
        'result': 'requested',
        'trigger': 'command',
      });

      // Unavailable flow: reported as such, nothing requested.
      launcher.available = false;
      clock.advance(90);
      expect(await _commandWin(c), isFalse);
      expect(sink.sent.length, 2);
      expect(sink.sent.last.$1, 'review_prompt');
      expect(sink.sent.last.$2, {
        'result': 'unavailable',
        'trigger': 'command',
      });
      expect(launcher.requests, 1);
    });

    test('a history ask reports the history trigger', () async {
      final sink = _FakeSink();
      final (c, launcher, _, _) = await _setup(
        initial: _eligible(),
        sink: sink,
      );
      expect(await c.maybeRequest(trigger: ReviewTrigger.history), isTrue);
      expect(launcher.requests, 1);
      expect(c.commandEver, isFalse, reason: 'History is not a command');
      expect(sink.sent.single.$2, {
        'result': 'requested',
        'trigger': 'history',
      });
    });

    test('a passive ask reports the report trigger', () async {
      final sink = _FakeSink();
      final (c, _, _, _) = await _setup(initial: _eligible(), sink: sink);
      expect(await _reportWin(c), isTrue);
      expect(sink.sent.single.$2, {'result': 'requested', 'trigger': 'report'});
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
