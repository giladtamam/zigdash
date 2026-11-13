import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/analytics.dart';

// Shortcuts are used outside the app, where there is no analytics client.
// The native side notes each use in shared preferences (ShortcutPrefs.kt,
// `mark`); the app sends the notes as events when it next starts (ADR 0006:
// only with consent; without it the notes are dropped).

/// "1" once a shortcut of [kind] was used since the last report.
String shortcutUsedKey(ShortcutEventKind kind) => 'shortcut.used.${kind.wire}';

/// "1" once Device Controls showed ZigDash's controls (the user added them).
const shortcutControlsAddedKey = 'shortcut.added.control';
const _controlsAddedReported = 'shortcut.added.control.reported';
/// "1" once a home-screen widget of a kind was added (the launcher's
/// picker notes it): `shortcut.added.widget`, `.scene_widget`, `.group_widget`.
String _addedKey(ShortcutEventKind kind) => 'shortcut.added.${kind.wire}';

/// Where the last widget the app asked the launcher to pin was asked from,
/// `<from>|<epoch ms>` (3.3.3): the launcher confirms it natively, so the
/// widget is reported when the app next starts.
const shortcutPinFromKey = 'shortcut.pin.from';

/// A pin asked from the app counts for widgets added within this long; one
/// added later came from the launcher's picker.
const _pinFromFor = Duration(hours: 1);

/// Notes that the app asked for a widget from [from].
Future<void> notePinFrom(SharedPreferences prefs, ShortcutFrom from,
        {DateTime? now}) =>
    prefs.setString(shortcutPinFromKey,
        '${from.name}|${(now ?? DateTime.now()).millisecondsSinceEpoch}');

ShortcutFrom _pinFrom(SharedPreferences prefs, DateTime now) {
  final parts = (prefs.getString(shortcutPinFromKey) ?? '').split('|');
  if (parts.length != 2) return ShortcutFrom.outside;
  final at = int.tryParse(parts[1]);
  final from = ShortcutFrom.values.where((f) => f.name == parts[0]).firstOrNull;
  if (at == null || from == null) return ShortcutFrom.outside;
  final age = now.difference(DateTime.fromMillisecondsSinceEpoch(at));
  return age.isNegative || age > _pinFromFor ? ShortcutFrom.outside : from;
}

/// Sends what the native side noted and clears the notes.
Future<void> reportShortcutUsage(
    SharedPreferences prefs, Analytics analytics, {DateTime? now}) async {
  await prefs.reload(); // the native side wrote behind the plugin's cache
  for (final kind in ShortcutEventKind.values) {
    final key = shortcutUsedKey(kind);
    if (prefs.getString(key) == null) continue;
    analytics.track(ShortcutUsed(kind));
    await prefs.remove(key);
  }
  // Home-screen widgets added (the launcher's picker notes them).
  for (final kind in [
    ShortcutEventKind.widget,
    ShortcutEventKind.sceneWidget,
    ShortcutEventKind.groupWidget,
  ]) {
    if (prefs.getString(_addedKey(kind)) == null) continue;
    analytics.track(
        ShortcutAdded(kind, from: _pinFrom(prefs, now ?? DateTime.now())));
    await prefs.remove(_addedKey(kind));
    await prefs.remove(shortcutPinFromKey);
  }
  if (prefs.getString(shortcutControlsAddedKey) != null &&
      prefs.getString(_controlsAddedReported) == null) {
    analytics.track(const ShortcutAdded(ShortcutEventKind.control));
    await prefs.setString(_controlsAddedReported, '1');
  }
}
