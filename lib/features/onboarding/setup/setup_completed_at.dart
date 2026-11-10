import 'package:shared_preferences/shared_preferences.dart';

/// When setup last completed, as epoch milliseconds in SharedPreferences
/// (3.4.8, help-and-review-2026-11.md §3): the review prompt keeps quiet
/// for ten minutes after it. Written by every path that finishes a setup
/// (the scan, the broker form, a shared home); read by the review prompt.
const kSetupCompletedAtMs = 'setup_completed_at_ms';

Future<void> markSetupCompleted(SharedPreferences prefs) =>
    prefs.setInt(kSetupCompletedAtMs, DateTime.now().millisecondsSinceEpoch);
