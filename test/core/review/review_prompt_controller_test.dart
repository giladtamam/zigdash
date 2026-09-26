import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/review/review_launcher.dart';
import 'package:zigdash/core/review/review_prompt_controller.dart';

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

  test('first session stores count, first day and last day; no prompt', () async {
    final (c, launcher, _, prefs) = await _setup();
    expect(await c.recordSuccessfulSession(), isFalse);
    expect(prefs.getInt(ReviewPromptController.kSessions), 1);
    expect(prefs.getString(ReviewPromptController.kFirstSessionDay), '2026-09-01');
    expect(prefs.getString(ReviewPromptController.kLastSessionDay), '2026-09-01');
    expect(prefs.getString(ReviewPromptController.kLastPromptDay), isNull);
    expect(launcher.requests, 0);
  });

  test('repeat calls on the same day count once', () async {
    final (c, _, _, prefs) = await _setup();
    await c.recordSuccessfulSession();
    await c.recordSuccessfulSession();
    await c.recordSuccessfulSession();
    expect(prefs.getInt(ReviewPromptController.kSessions), 1);
  });

  test('prompts once policy is met and records the prompt day', () async {
    final (c, launcher, clock, prefs) = await _setup();
    for (var i = 0; i < 3; i++) {
      await c.recordSuccessfulSession();
      clock.advance(1);
    }
    // Day 4 (Sep 4): 4th session, 3 days after the first.
    expect(await c.recordSuccessfulSession(), isTrue);
    expect(launcher.requests, 1);
    expect(prefs.getString(ReviewPromptController.kLastPromptDay), '2026-09-04');

    // Same day again: nothing new.
    expect(await c.recordSuccessfulSession(), isFalse);
    expect(launcher.requests, 1);
  });

  test('does not request or record when the platform flow is unavailable',
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
    expect(prefs.getString(ReviewPromptController.kLastPromptDay), isNull);
  });

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

  test('stores only day-granularity keys', () async {
    final (c, _, _, prefs) = await _setup();
    await c.recordSuccessfulSession();
    expect(
      prefs.getKeys(),
      {
        ReviewPromptController.kSessions,
        ReviewPromptController.kFirstSessionDay,
        ReviewPromptController.kLastSessionDay,
      },
    );
  });
}
