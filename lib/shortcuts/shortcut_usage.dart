import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/analytics.dart';

// Shortcuts are used outside the app, where there is no analytics client.
// The native side notes each use in shared preferences (ShortcutPrefs.kt,
// `mark`); the app sends the notes as events when it next starts (ADR 0006:
// only with consent; without it the notes are dropped).

/// "1" once a shortcut of [kind] was used since the last report.
String shortcutUsedKey(ShortcutEventKind kind) => 'shortcut.used.${kind.name}';

/// "1" once Device Controls showed ZigDash's controls (the user added them).
const shortcutControlsAddedKey = 'shortcut.added.control';
const _controlsAddedReported = 'shortcut.added.control.reported';

/// Sends what the native side noted and clears the notes.
Future<void> reportShortcutUsage(
    SharedPreferences prefs, Analytics analytics) async {
  await prefs.reload(); // the native side wrote behind the plugin's cache
  for (final kind in ShortcutEventKind.values) {
    final key = shortcutUsedKey(kind);
    if (prefs.getString(key) == null) continue;
    analytics.track(ShortcutUsed(kind));
    await prefs.remove(key);
  }
  if (prefs.getString(shortcutControlsAddedKey) != null &&
      prefs.getString(_controlsAddedReported) == null) {
    analytics.track(const ShortcutAdded(ShortcutEventKind.control));
    await prefs.setString(_controlsAddedReported, '1');
  }
}
