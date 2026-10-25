import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/review/review_launcher.dart';
import 'package:zigdash/core/review/review_prompt_controller.dart';

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
_setup({Map<String, Object> initial = const {}, bool available = true}) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final launcher = _FakeLauncher(available: available);
  final clock = _Clock(DateTime(2026, 9, 1));
  final c = ReviewPromptController(
    prefs: prefs,
    launcher: launcher,
    now: clock.call,
  );
  return (c, launcher, clock, prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'first session stores count, first day and last day; no prompt',
    () async {
      final (c, launcher, _, prefs) = await _setup();
      expect(await c.recordSuccessfulSession(), isFalse);
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
    await c.recordSuccessfulSession();
    await c.recordSuccessfulSession();
    expect(prefs.getInt(ReviewPromptController.kSessions), 1);
  });

  test('prompts once policy is met and records the prompt day', () async {
    final (c, launcher, clock, prefs) = await _setup();
    // Day 1 (Sep 1): first confirmed command. Never on the first day.
    expect(await c.recordSuccessfulSession(), isFalse);
    expect(launcher.requests, 0);
    clock.advance(1);
    // Day 2 (Sep 2): second session, but only a day after the first.
    expect(await c.recordSuccessfulSession(), isFalse);
    expect(launcher.requests, 0);
    clock.advance(1);
    // Day 3 (Sep 3): two days after the first.
    expect(await c.recordSuccessfulSession(), isTrue);
    expect(launcher.requests, 1);
    expect(
      prefs.getString(ReviewPromptController.kLastPromptDay),
      '2026-09-03',
    );

    // Same day again: nothing new.
    expect(await c.recordSuccessfulSession(), isFalse);
    expect(launcher.requests, 1);
  });

  test(
    'does not request when the platform flow is unavailable, but stamps the day',
    () async {
      final (c, launcher, _, prefs) = await _setup(
        initial: {
          ReviewPromptController.kSessions: 9,
          ReviewPromptController.kFirstSessionDay: '2026-01-01',
          ReviewPromptController.kLastSessionDay: '2026-08-01',
        },
        available: false,
      );
      expect(await c.recordSuccessfulSession(), isFalse);
      expect(launcher.requests, 0);
      // Stamped so the cooldown applies: `unavailable` is reported once per
      // 90 days, not on every successful day.
      expect(
        prefs.getString(ReviewPromptController.kLastPromptDay),
        '2026-09-01',
      );
    },
  );

  test('honours the 90-day cooldown between prompts', () async {
    final (c, launcher, clock, _) = await _setup(
      initial: {
        ReviewPromptController.kSessions: 9,
        ReviewPromptController.kFirstSessionDay: '2026-01-01',
        ReviewPromptController.kLastSessionDay: '2026-08-01',
      },
    );
    expect(await c.recordSuccessfulSession(), isTrue);
    clock.advance(89);
    expect(await c.recordSuccessfulSession(), isFalse);
    clock.advance(1);
    expect(await c.recordSuccessfulSession(), isTrue);
    expect(launcher.requests, 2);
  });

  test(
    'sends review_prompt only when the policy is met, with the result',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final sink = _FakeSink();
      final launcher = _FakeLauncher();
      final clock = _Clock(DateTime(2026, 9, 1));
      final c = ReviewPromptController(
        prefs: prefs,
        launcher: launcher,
        analytics: Analytics(sink, enabled: true),
        now: clock.call,
      );

      await c.recordSuccessfulSession();
      expect(sink.sent, isEmpty, reason: 'first day: policy not met');

      clock.advance(1);
      await c.recordSuccessfulSession();
      expect(sink.sent, isEmpty, reason: 'a day later: still too soon');

      clock.advance(1);
      await c.recordSuccessfulSession();
      expect(sink.sent.length, 1);
      expect(sink.sent.single.$1, 'review_prompt');
      expect(sink.sent.single.$2, {'result': 'requested'});

      // Unavailable flow: reported as such, nothing requested.
      launcher.available = false;
      clock.advance(90);
      expect(await c.recordSuccessfulSession(), isFalse);
      expect(sink.sent.length, 2);
      expect(sink.sent.last.$1, 'review_prompt');
      expect(sink.sent.last.$2, {'result': 'unavailable'});
      expect(launcher.requests, 1);
    },
  );

  test('stores only day-granularity keys', () async {
    final (c, _, _, prefs) = await _setup();
    await c.recordSuccessfulSession();
    expect(prefs.getKeys(), {
      ReviewPromptController.kSessions,
      ReviewPromptController.kFirstSessionDay,
      ReviewPromptController.kLastSessionDay,
    });
  });
}
