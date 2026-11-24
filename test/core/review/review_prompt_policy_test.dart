import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/review/review_prompt_policy.dart';

/// [d] plus [days] calendar days (a Duration would land at 23:00 the day
/// before across a daylight-saving change).
DateTime _plus(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

void main() {
  const policy = ReviewPromptPolicy();
  final day0 = DateTime(2026, 9, 1);

  test('never prompts before the first session is recorded', () {
    expect(
      policy.shouldPrompt(
        sessions: 10,
        firstSessionDay: null,
        lastPromptDay: null,
        today: day0,
      ),
      isFalse,
    );
  });

  test('needs minSessions distinct sessions (two)', () {
    expect(
      policy.shouldPrompt(
        sessions: 1,
        firstSessionDay: day0,
        lastPromptDay: null,
        today: _plus(day0, 30),
      ),
      isFalse,
    );
    expect(
      policy.shouldPrompt(
        sessions: 2,
        firstSessionDay: day0,
        lastPromptDay: null,
        today: _plus(day0, 30),
      ),
      isTrue,
    );
  });

  test('needs minAge (one day) since the first session', () {
    expect(
      policy.shouldPrompt(
        sessions: 2,
        firstSessionDay: day0,
        lastPromptDay: null,
        today: day0,
      ),
      isFalse,
    );
    expect(
      policy.shouldPrompt(
        sessions: 2,
        firstSessionDay: day0,
        lastPromptDay: null,
        today: _plus(day0, 1),
      ),
      isTrue,
    );
  });

  // The 3.1.9 night-after-setup case (22:35, then 01:00) passes the policy
  // from 3.8.4; the controller's 18-hour setup window holds it (see
  // review_prompt_controller_test.dart).

  test('counts calendar days across a daylight-saving change', () {
    // Europe springs forward on Mar 29, 2026: Mar 28 to Mar 30 is 47 hours
    // where the phone is in that zone. Plain dates keep it at two days.
    expect(
      policy.shouldPrompt(
        sessions: 2,
        firstSessionDay: DateTime(2026, 3, 28),
        lastPromptDay: null,
        today: DateTime(2026, 3, 30),
      ),
      isTrue,
    );
  });

  test('respects the cooldown after a prompt', () {
    final prompted = _plus(day0, 10);
    expect(
      policy.shouldPrompt(
        sessions: 20,
        firstSessionDay: day0,
        lastPromptDay: prompted,
        today: _plus(prompted, 89),
      ),
      isFalse,
    );
    expect(
      policy.shouldPrompt(
        sessions: 20,
        firstSessionDay: day0,
        lastPromptDay: prompted,
        today: _plus(prompted, 90),
      ),
      isTrue,
    );
  });
}
