import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/providers/settings_controller.dart';
import 'review_launcher.dart';
import 'review_prompt_policy.dart';

/// Counts "successful sessions" (days on which the user reached a connected
/// dashboard) and asks for a Play review once [ReviewPromptPolicy] allows it.
///
/// Privacy: everything lives in local SharedPreferences at calendar-day
/// granularity. Four keys, no per-session timestamps, no network calls. The
/// automatic path never opens the store listing; if the platform flow is
/// unavailable it silently does nothing.
class ReviewPromptController {
  ReviewPromptController({
    required SharedPreferences prefs,
    required ReviewLauncher launcher,
    this.policy = const ReviewPromptPolicy(),
    DateTime Function()? now,
  })  : _prefs = prefs,
        _launcher = launcher,
        _now = now ?? DateTime.now;

  static const kSessions = 'review_sessions';
  static const kFirstSessionDay = 'review_first_session_day';
  static const kLastSessionDay = 'review_last_session_day';
  static const kLastPromptDay = 'review_last_prompt_day';

  final SharedPreferences _prefs;
  final ReviewLauncher _launcher;
  final ReviewPromptPolicy policy;
  final DateTime Function() _now;

  bool _inFlight = false;

  int get sessions => _prefs.getInt(kSessions) ?? 0;

  /// Call when the user is looking at a dashboard with a live broker
  /// connection. Idempotent within a calendar day. Returns true only when a
  /// review was actually requested.
  Future<bool> recordSuccessfulSession() async {
    if (_inFlight) return false;
    _inFlight = true;
    try {
      final today = _dayOnly(_now());
      final todayKey = _encode(today);

      if (_prefs.getString(kLastSessionDay) != todayKey) {
        await _prefs.setString(kLastSessionDay, todayKey);
        await _prefs.setInt(kSessions, sessions + 1);
        if (_prefs.getString(kFirstSessionDay) == null) {
          await _prefs.setString(kFirstSessionDay, todayKey);
        }
      }

      final eligible = policy.shouldPrompt(
        sessions: sessions,
        firstSessionDay: _decode(_prefs.getString(kFirstSessionDay)),
        lastPromptDay: _decode(_prefs.getString(kLastPromptDay)),
        today: today,
      );
      if (!eligible) return false;
      if (!await _launcher.isAvailable()) return false;

      await _launcher.requestReview();
      await _prefs.setString(kLastPromptDay, todayKey);
      return true;
    } finally {
      _inFlight = false;
    }
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
  ),
);
