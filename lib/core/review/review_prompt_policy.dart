/// Decides whether the in-app review dialog may be requested.
///
/// Pure and clock-free so it can be unit-tested exhaustively. All inputs are
/// at calendar-day granularity; nothing finer is ever stored (see
/// [ReviewPromptController]).
class ReviewPromptPolicy {
  const ReviewPromptPolicy({
    this.minSessions = 4,
    this.minAge = const Duration(days: 3),
    this.cooldown = const Duration(days: 90),
  });

  /// Distinct days on which the user reached a connected dashboard before we
  /// ask. Four is enough to know the app actually works for them.
  final int minSessions;

  /// Minimum time since the first successful session. Stops a burst of
  /// same-week sessions from prompting someone still evaluating the app.
  final Duration minAge;

  /// Minimum gap between review requests. Google gives no signal whether the
  /// dialog was shown, so every request counts against the cooldown.
  final Duration cooldown;

  bool shouldPrompt({
    required int sessions,
    required DateTime? firstSessionDay,
    required DateTime? lastPromptDay,
    required DateTime today,
  }) {
    if (firstSessionDay == null || sessions < minSessions) return false;
    if (today.difference(firstSessionDay) < minAge) return false;
    if (lastPromptDay != null && today.difference(lastPromptDay) < cooldown) {
      return false;
    }
    return true;
  }
}
