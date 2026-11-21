/// Decides whether the in-app review dialog may be requested.
///
/// Pure and clock-free so it can be unit-tested exhaustively. All inputs are
/// at calendar-day granularity; nothing finer is ever stored (see
/// [ReviewPromptController]).
class ReviewPromptPolicy {
  const ReviewPromptPolicy({
    this.minSessions = 2,
    this.minAge = const Duration(days: 1),
    this.cooldown = const Duration(days: 90),
  });

  /// Distinct days with live data on a dashboard (the setup day counts; a
  /// confirmed command or a passive report each count the day) before we
  /// ask. One day proves the setup works; coming back on a second day
  /// proves they kept it. Was four days (2026-09 to 2026-10), which produced
  /// no visible rating in three weeks of production.
  final int minSessions;

  /// Minimum time since the first successful session, in calendar days.
  /// One day alone let a setup at 22:35 and a light at 01:00 ask for a
  /// review 2.5 hours after install (3.1.9), so 3.1.10 to 3.8.3 used two.
  /// From 3.8.4 it is one again: the night-after-setup case is held by the
  /// controller's 18-hour setup window instead, and two days left most
  /// installs unasked (8 prompts against 34 setups in 30 days,
  /// weak-points-plan-2026-11.md).
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
    if (_daysBetween(firstSessionDay, today) < minAge.inDays) return false;
    if (lastPromptDay != null &&
        _daysBetween(lastPromptDay, today) < cooldown.inDays) {
      return false;
    }
    return true;
  }

  /// Whole calendar days from [from] to [to]; a daylight-saving change in
  /// between (a 47- or 49-hour "two days") doesn't move the count.
  static int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
}
