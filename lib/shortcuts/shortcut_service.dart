import 'package:drift/drift.dart' show OrderingTerm, Value;
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

/// What asking the launcher to pin a widget did: [requested] opened its
/// prompt (the widget is set up natively once confirmed).
enum PinWidgetResult { requested, unsupported }

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
    final rows = await _dao.watchAll().first;
    // A slot whose row is gone (its Home was deleted) goes back to "Choose
    // a device" instead of showing "Removed" forever.
    final used = {for (final r in rows) r.tileSlot};
    for (var s = 1; s <= shortcutTileSlots; s++) {
      if (!used.contains(s)) await _prefs.remove(shortcutTileKey(s));
    }
    for (final row in rows) {
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

  /// Writes the scenes the scene widget's picker offers.
  Future<void> resyncScenes() async {
    final out = <Map<String, Object?>>[];
    for (final conn in await _db.select(_db.connections).get()) {
      final scenes = await (_db.select(_db.scenes)
            ..where((s) => s.connectionId.equals(conn.id))
            ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
          .get();
      for (final scene in scenes) {
        out.add({
          'connectionId': conn.id,
          'home': conn.name,
          'sceneId': scene.id,
          'name': scene.name,
        });
      }
    }
    await _prefs.setString(shortcutScenesKey, jsonEncode(out));
  }

  /// Writes the groups the group widget's picker offers: each dashboard
  /// section's first devices and scenes, in dashboard order.
  Future<void> resyncGroups() async {
    final out = <Map<String, Object?>>[];
    for (final conn in await _db.select(_db.connections).get()) {
      final dashboards = await (_db.select(_db.dashboards)
            ..where((d) => d.connectionId.equals(conn.id))
            ..orderBy([(d) => OrderingTerm(expression: d.sortOrder)]))
          .get();
      for (final dash in dashboards) {
        final sections = await (_db.select(_db.sections)
              ..where((s) => s.dashboardId.equals(dash.id))
              ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
            .get();
        final panels = await (_db.select(_db.panels)
              ..where((p) => p.dashboardId.equals(dash.id))
              ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
            .get();
        // Tiles outside a section come first on the dashboard, too.
        for (final (sectionId, name) in [
          (null, dash.name),
          for (final sec in sections) (sec.id, sec.name),
        ]) {
          final ieees = <String>[], scenes = <String>[];
          for (final p in panels.where((p) => p.sectionId == sectionId)) {
            final ieee = p.deviceIeee;
            if (p.type == PanelType.device && ieee != null) {
              if (ieees.length < groupDevices && !ieees.contains(ieee)) {
                ieees.add(ieee);
              }
            } else if (p.type == PanelType.scene) {
              final c = PanelConfig.decode(p.type, p.config);
              if (c is SceneConfig &&
                  c.sceneId.isNotEmpty &&
                  scenes.length < groupScenes &&
                  !scenes.contains(c.sceneId)) {
                scenes.add(c.sceneId);
              }
            }
          }
          if (ieees.isEmpty && scenes.isEmpty) continue;
          out.add({
            'connectionId': conn.id,
            'home': conn.name,
            'dashboard': dash.name,
            'name': name,
            'ieees': ieees,
            'scenes': scenes,
          });
        }
      }
    }
    await _prefs.setString(shortcutGroupsKey, jsonEncode(out));
  }

  /// Home-screen widgets are set up by the launcher's picker on the native
  /// side (`shortcut.widget.<id>`); this copies them into the shortcuts table
  /// so the running app keeps them current, and drops widgets that were
  /// removed from the home screen.
  Future<void> syncWidgets() async {
    await _prefs.reload(); // written natively, behind the plugin's cache
    final homes = {
      for (final c in await _db.select(_db.connections).get()) c.id,
    };
    final seen = <int>{};
    for (final key in _prefs.getKeys()) {
      final id = int.tryParse(key.replaceFirst('shortcut.widget.', ''));
      if (!key.startsWith('shortcut.widget.') || id == null) continue;
      final Map<String, dynamic> w;
      try {
        w = jsonDecode(_prefs.getString(key) ?? '') as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      final home = w['connectionId'];
      // A device widget names its device, a scene widget its scene, a group
      // widget its devices (its scenes need no following).
      final (kind, targets) = switch (w['kind']) {
        'scene' => (ShortcutKind.scene, [w['sceneId']]),
        'group' => (
            ShortcutKind.group,
            w['ieees'] is List ? w['ieees'] as List : const <Object?>[]
          ),
        _ => (ShortcutKind.device, [w['ieee']]),
      };
      if (home is! String ||
          !homes.contains(home) ||
          targets.any((t) => t is! String) ||
          (kind != ShortcutKind.group && targets.isEmpty)) {
        continue;
      }
      final target = targets.cast<String>();
      seen.add(id);
      final row = await _dao.getByWidget(id);
      if (row != null &&
          row.connectionId == home &&
          row.kind == kind &&
          shortcutTargets(row).join(',') == target.join(',')) {
        continue;
      }
      await _dao.put(ShortcutsCompanion.insert(
        id: 'widget-$id',
        connectionId: home,
        kind: kind,
        surface: ShortcutSurface.widget,
        targets: encodeShortcutTargets(target),
        appWidgetId: Value(id),
        createdAt: _now(),
      ));
    }
    for (final row in await _dao.watchAll().first) {
      final id = row.appWidgetId;
      if (id != null && !seen.contains(id)) await _dao.deleteByWidget(id);
    }
  }

  Future<void> clearTile(int slot) async {
    await _dao.deleteByTileSlot(slot);
    await _prefs.remove(shortcutTileKey(slot));
  }

  /// Asks the launcher to pin a home-screen widget: [kind] `device` (an
  /// IEEE address in [target]) or `scene` (a scene id).
  Future<PinWidgetResult> requestPinWidget(
      {required String kind,
      required String connectionId,
      required String target,
      required String name}) async {
    try {
      final r = await appChannel.invokeMethod<String>('requestPinWidget', {
        'kind': kind,
        'connectionId': connectionId,
        'target': target,
        'name': name,
      });
      return r == 'requested'
          ? PinWidgetResult.requested
          : PinWidgetResult.unsupported;
    } on MissingPluginException {
      return PinWidgetResult.unsupported;
    } on PlatformException {
      return PinWidgetResult.unsupported;
    }
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
        'openAppFirst': l10n.shortcutOpenAppFirst,
        'chooseScene': l10n.shortcutChooseScene,
        'openAppFirstScene': l10n.shortcutOpenAppFirstScene,
        'chooseGroup': l10n.shortcutChooseGroup,
        'pickDevices': l10n.shortcutPickDevices,
        'groupName': l10n.shortcutGroupName,
        'groupLimit': l10n.shortcutGroupLimit,
        'save': l10n.save,
        'scenes': l10n.scenesTitle,
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
