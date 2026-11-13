import 'package:shared_preferences/shared_preferences.dart';

/// When setup last completed, as epoch milliseconds in SharedPreferences
/// (3.4.8, help-and-review-2026-11.md §3): the review prompt keeps quiet
/// for ten minutes after it. Written by every path that finishes a setup
/// (the scan, the broker form, a shared home); read by the review prompt.
const kSetupCompletedAtMs = 'setup_completed_at_ms';

/// Best effort: [prefs] is called lazily and any failure is swallowed, so a
/// finished setup is never held up by bookkeeping (and widget tests without
/// SharedPreferences keep working).
Future<void> markSetupCompleted(SharedPreferences Function() prefs) async {
  try {
    await prefs().setInt(
      kSetupCompletedAtMs,
      DateTime.now().millisecondsSinceEpoch,
    );
  } catch (_) {}
}
