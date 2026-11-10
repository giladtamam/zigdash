import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/setup/setup_completed_at.dart';
import '../../features/settings/providers/settings_controller.dart';
import '../analytics/analytics.dart';
import 'review_launcher.dart';
import 'review_prompt_policy.dart';

/// Counts "successful sessions" (days on which the user reached a connected
/// dashboard with live data) and asks for a Play review once
/// [ReviewPromptPolicy] allows it.
///
/// Counting and asking are separate (3.4.8). [recordSuccessfulSession] only
/// counts the day; [maybeRequest] applies the policy and asks. The ask comes
/// from the dashboard trigger after a command the user sent was confirmed;
/// a passive device report may ask only on an install that has never
/// confirmed a command (sensor-only homes), after [reportMinSessions] days.
///
/// Privacy: everything lives in local SharedPreferences. Day counts are at
/// calendar-day granularity, no per-session timestamps. Six keys: the four
/// day counters, whether a command was ever confirmed, and the time setup
/// last completed (the one finer value, kept so a fresh setup is never
/// interrupted by a review). The only network call is the `review_prompt`
/// usage event, sent through [Analytics] (so only with consent) when the
/// policy is met: it says whether the dialog was requested or the review
/// flow was unavailable, what triggered it and which command of the session
/// it was, nothing else. The automatic path never opens the store listing;
/// if the platform flow is unavailable it does nothing visible.
class ReviewPromptController {
  ReviewPromptController({
    required SharedPreferences prefs,
    required ReviewLauncher launcher,
    Analytics? analytics,
    this.policy = const ReviewPromptPolicy(),
    this.setupWindow = const Duration(minutes: 10),
    this.reportMinSessions = 7,
    DateTime Function()? now,
  }) : _prefs = prefs,
       _launcher = launcher,
       _analytics = analytics,
       _now = now ?? DateTime.now;

  static const kSessions = 'review_sessions';
  static const kFirstSessionDay = 'review_first_session_day';
  static const kLastSessionDay = 'review_last_session_day';
  static const kLastPromptDay = 'review_last_prompt_day';

  /// True once a command the user sent has been confirmed on this install,
  /// however long ago. While absent the home is treated as sensor-only and a
  /// passive report may ask.
  static const kCommandEver = 'review_command_ever';

  final SharedPreferences _prefs;
  final ReviewLauncher _launcher;
  final Analytics? _analytics;
  final ReviewPromptPolicy policy;

  /// No request within this long after setup completed ([kSetupCompletedAtMs],
  /// written by the setup flow; absent means no window).
  final Duration setupWindow;

  /// Counted days a sensor-only install needs before a passive report may
  /// ask; later than the command path by design.
  final int reportMinSessions;

  final DateTime Function() _now;

  bool _requesting = false;

  int get sessions => _prefs.getInt(kSessions) ?? 0;

  bool get commandEver => _prefs.getBool(kCommandEver) ?? false;

  /// Call when the user is looking at a dashboard with live data. Counts the
  /// calendar day once; never asks for a review.
  Future<void> recordSuccessfulSession() async {
    final todayKey = _encode(_dayOnly(_now()));
    if (_prefs.getString(kLastSessionDay) == todayKey) return;
    // The cache is updated before the write is awaited, so a second caller
    // in the same tick sees today already stamped and does not count twice.
    await _prefs.setString(kLastSessionDay, todayKey);
    await _prefs.setInt(kSessions, sessions + 1);
    if (_prefs.getString(kFirstSessionDay) == null) {
      await _prefs.setString(kFirstSessionDay, todayKey);
    }
  }

  /// Call on every confirmation of a command the user sent: counts the day
  /// and remembers that this install is not sensor-only, whether or not the
  /// policy is met yet.
  Future<void> recordCommandConfirmed() async {
    await _markCommandEver();
    await recordSuccessfulSession();
  }

  /// Asks for a review if everything allows it: not within [setupWindow] of
  /// setup, the sensor-only rule for a [ReviewTrigger.report], then
  /// [policy]. [nth] is which confirmed command of the session this is
  /// (command trigger only). Returns true only when a review was requested.
  Future<bool> maybeRequest({required ReviewTrigger trigger, int? nth}) async {
    if (_requesting) return false;
    _requesting = true;
    try {
      if (trigger == ReviewTrigger.command) await _markCommandEver();
      final now = _now();
      if (_withinSetupWindow(now)) return false;
      if (trigger == ReviewTrigger.report &&
          (commandEver || sessions < reportMinSessions)) {
        return false;
      }

      final today = _dayOnly(now);
      final todayKey = _encode(today);
      final eligible = policy.shouldPrompt(
        sessions: sessions,
        firstSessionDay: _decode(_prefs.getString(kFirstSessionDay)),
        lastPromptDay: _decode(_prefs.getString(kLastPromptDay)),
        today: today,
      );
      if (!eligible) return false;
      if (!await _launcher.isAvailable()) {
        // Stamp the day anyway: without it an install with no Play review
        // flow (GitHub, F-Droid) stays eligible and reports `unavailable` on
        // every eligible win. Now it reports once per cooldown.
        await _prefs.setString(kLastPromptDay, todayKey);
        _analytics?.track(
          ReviewPrompted(
            ReviewPromptResult.unavailable,
            trigger: trigger,
            nth: nth,
          ),
        );
        return false;
      }

      await _launcher.requestReview();
      await _prefs.setString(kLastPromptDay, todayKey);
      _analytics?.track(
        ReviewPrompted(ReviewPromptResult.requested, trigger: trigger, nth: nth),
      );
      return true;
    } finally {
      _requesting = false;
    }
  }

  Future<void> _markCommandEver() async {
    if (!commandEver) await _prefs.setBool(kCommandEver, true);
  }

  bool _withinSetupWindow(DateTime now) {
    final at = _prefs.getInt(kSetupCompletedAtMs);
    if (at == null) return false;
    final elapsed = now.millisecondsSinceEpoch - at;
    return elapsed >= 0 && elapsed < setupWindow.inMilliseconds;
  }

  static DateTime _dayOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  static String _encode(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  static DateTime? _decode(String? s) {
    if (s == null) return null;
    final parts = s.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
}

final reviewPromptControllerProvider = Provider<ReviewPromptController>(
  (ref) => ReviewPromptController(
    prefs: ref.watch(sharedPreferencesProvider),
    launcher: ref.watch(reviewLauncherProvider),
    analytics: ref.watch(analyticsProvider),
  ),
);
