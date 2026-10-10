import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/daos/device_registry_dao.dart';
import '../data/database/daos/shortcut_dao.dart';
import '../data/database/database.dart';
import '../data/database/tables/panels.dart';
import '../data/database/tables/shortcuts.dart';
import '../features/panels/models/panel_config.dart';
import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../l10n/app_localizations.dart';
import '../features/devices/device_profile.dart';
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
    final device = await resolveShortcutDevice(_db, connectionId, ieee);
    final cover = device?.profile.deviceClass == DeviceClass.cover;
    await _prefs.setString(
        shortcutTileKey(slot),
        encodeTileAssignment(
            connectionId: connectionId,
            ieee: ieee,
            name: name,
            cover: cover,
            position: cover && device?.profile.position != null,
            deviceClass: device?.profile.deviceClass.name));
  }

  /// Rewrites what every tile reads from the database: run at app start,
  /// so tiles follow renames and pick up new fields (e.g. "this is a
  /// shutter") after an update.
  Future<void> resyncTiles() async {
    for (final row in await _dao.watchAll().first) {
      final slot = row.tileSlot;
      final targets = shortcutTargets(row);
      if (slot == null || targets.isEmpty) continue;
      final device =
          await resolveShortcutDevice(_db, row.connectionId, targets.first);
      if (device == null) continue;
      final cover = device.profile.deviceClass == DeviceClass.cover;
      await _prefs.setString(
          shortcutTileKey(slot),
          encodeTileAssignment(
              connectionId: row.connectionId,
              ieee: targets.first,
              name: device.name,
              cover: cover,
              position: cover && device.profile.position != null,
              deviceClass: device.profile.deviceClass.name));
    }
  }

  /// Writes the devices Android's Device Controls offer: every device on a
  /// dashboard, once per Home, in dashboard order.
  Future<void> resyncControls() async {
    final out = <Map<String, Object?>>[];
    for (final conn in await _db.select(_db.connections).get()) {
      final seen = <String>{};
      for (final (panel, _)
          in await DeviceRegistryDao(_db).tilesOfHome(conn.id)) {
        final ieee = panel.deviceIeee;
        if (panel.type != PanelType.device || ieee == null || !seen.add(ieee)) {
          continue;
        }
        final config = PanelConfig.decode(panel.type, panel.config);
        if (config is! DeviceTileConfig) continue;
        out.add(encodeControl(
            connectionId: conn.id,
            home: conn.name,
            ieee: ieee,
            name: panel.name,
            profile: config.profile));
      }
    }
    await _prefs.setString(shortcutControlsKey, jsonEncode(out));
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
        'open': l10n.panelCoverOpen,
        'stop': l10n.panelCoverStop,
        'close': l10n.panelCoverClose,
        'position': l10n.devicePosition,
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
