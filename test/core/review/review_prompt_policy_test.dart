import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/review/review_prompt_policy.dart';

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

  test('needs minSessions distinct sessions', () {
    expect(
      policy.shouldPrompt(
        sessions: 3,
        firstSessionDay: day0,
        lastPromptDay: null,
        today: day0.add(const Duration(days: 30)),
      ),
      isFalse,
    );
    expect(
      policy.shouldPrompt(
        sessions: 4,
        firstSessionDay: day0,
        lastPromptDay: null,
        today: day0.add(const Duration(days: 30)),
      ),
      isTrue,
    );
  });

  test('needs minAge since the first session even with enough sessions', () {
    expect(
      policy.shouldPrompt(
        sessions: 4,
        firstSessionDay: day0,
        lastPromptDay: null,
        today: day0.add(const Duration(days: 2)),
      ),
      isFalse,
    );
    expect(
      policy.shouldPrompt(
        sessions: 4,
        firstSessionDay: day0,
        lastPromptDay: null,
        today: day0.add(const Duration(days: 3)),
      ),
      isTrue,
    );
  });

  test('respects the cooldown after a prompt', () {
    final prompted = day0.add(const Duration(days: 10));
    expect(
      policy.shouldPrompt(
        sessions: 20,
        firstSessionDay: day0,
        lastPromptDay: prompted,
        today: prompted.add(const Duration(days: 89)),
      ),
      isFalse,
    );
    expect(
      policy.shouldPrompt(
        sessions: 20,
        firstSessionDay: day0,
        lastPromptDay: prompted,
        today: prompted.add(const Duration(days: 90)),
      ),
      isTrue,
    );
  });
}
