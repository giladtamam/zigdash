import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/daos/shortcut_dao.dart';
import '../data/database/database.dart';
import '../data/database/tables/shortcuts.dart';
import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../l10n/app_localizations.dart';
import 'shortcut_store.dart';
import 'dart:convert';

/// ZigDash's fixed Quick Settings tile slots (ShortcutTile1–4 in the
/// manifest; Android needs each tile declared ahead).
const shortcutTileSlots = 4;

/// The `zigdash/app` channel (MainActivity.kt).
const appChannel = MethodChannel('zigdash/app');

/// How a request to add a tile went.
enum AddTileResult { added, already, declined, unsupported, failed }

/// Assigns shortcuts and keeps what the native side reads up to date.
class ShortcutService {
  ShortcutService(this._db, this._prefs, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final SharedPreferences _prefs;
  final DateTime Function() _now;

  ShortcutDao get _dao => ShortcutDao(_db);

  /// The first unassigned slot, or null when all are in use.
  Future<int?> freeTileSlot() async {
    final used = await _dao.usedTileSlots();
    for (var s = 1; s <= shortcutTileSlots; s++) {
      if (!used.contains(s)) return s;
    }
    return null;
  }

  /// The slot already showing [ieee] in [connectionId], if any.
  Future<int?> tileSlotOf(String connectionId, String ieee) async {
    for (final s in await _dao.getByConnection(connectionId)) {
      if (s.tileSlot != null && shortcutTargets(s).contains(ieee)) {
        return s.tileSlot;
      }
    }
    return null;
  }

  Future<void> assignTile(int slot,
      {required String connectionId,
      required String ieee,
      required String name}) async {
    await _dao.put(ShortcutsCompanion.insert(
      id: 'tile-$slot',
      connectionId: connectionId,
      kind: ShortcutKind.device,
      surface: ShortcutSurface.tile,
      targets: encodeShortcutTargets([ieee]),
      tileSlot: Value(slot),
      createdAt: _now(),
    ));
    await _prefs.setString(shortcutTileKey(slot),
        encodeTileAssignment(connectionId: connectionId, ieee: ieee, name: name));
  }

  Future<void> clearTile(int slot) async {
    await _dao.deleteByTileSlot(slot);
    await _prefs.remove(shortcutTileKey(slot));
  }

  /// Asks Android to add tile [slot] to Quick Settings (Android 13+).
  Future<AddTileResult> requestAddTile(int slot, String label) async {
    try {
      final r = await appChannel.invokeMethod<String>(
          'requestAddTile', {'slot': slot, 'label': label});
      return AddTileResult.values.asNameMap()[r] ?? AddTileResult.failed;
    } on MissingPluginException {
      return AddTileResult.unsupported;
    } on PlatformException {
      return AddTileResult.failed;
    }
  }

  /// The native side's words, in the app's language.
  Future<void> writeStrings(AppLocalizations l10n) => _prefs.setString(
      shortcutStringsKey,
      jsonEncode({
        'working': l10n.shortcutWorking,
        'cantReach': l10n.shortcutCantReach,
        'notConfirmed': l10n.shortcutNotConfirmed,
        'removed': l10n.shortcutRemoved,
        'chooseDevice': l10n.shortcutChooseDevice,
      }));
}

final shortcutServiceProvider = Provider<ShortcutService>((ref) =>
    ShortcutService(
        ref.watch(appDatabaseProvider), ref.watch(sharedPreferencesProvider)));

/// Asks Android to redraw ZigDash's tiles from shared preferences.
Future<void> refreshShortcutTiles() async {
  try {
    await appChannel.invokeMethod<void>('refreshTiles');
  } on MissingPluginException {
    // Not Android (tests, web): nothing to redraw.
  } on PlatformException {
    // A tile that isn't added can't be asked to listen; harmless.
  }
}
