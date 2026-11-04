import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/analytics.dart';
import '../core/l10n/l10n_ext.dart';
import '../data/database/database.dart';
import '../data/database/tables/panels.dart';
import '../data/database/tables/shortcuts.dart';
import '../data/database/daos/shortcut_dao.dart';
import '../features/devices/device_profile.dart';
import '../features/panels/models/panel_config.dart';
import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'add_tile_button.dart';
import 'shortcut_service.dart';

/// When to offer a shortcut for a device (3.3.3). Widgets and Quick
/// Settings tiles were added once in 30 days: the only way in was a device
/// page's app bar, and most switching happens on dashboard tiles. So after a
/// device was switched from the app in [sessions] sessions, it is offered
/// once, at most once a session; two Not nows end the offers.
class ShortcutNudgePolicy {
  ShortcutNudgePolicy(this._prefs);

  final SharedPreferences _prefs;

  /// Sessions a device is switched in before it is offered.
  static const sessions = 3;

  /// Not nows after which nothing more is offered.
  static const maxLater = 2;

  static const _laterKey = 'shortcut.nudge.later';
  static String _usesKey(String home, String ieee) =>
      'shortcut.nudge.uses.$home.$ieee';
  static String _offeredKey(String home, String ieee) =>
      'shortcut.nudge.offered.$home.$ieee';

  final _countedThisSession = <String>{};
  bool _offeredThisSession = false;

  /// Notes that [ieee] was switched from the app; true when it is due an
  /// offer now. Counts each device once a session.
  bool noteUse(String home, String ieee) {
    if (_offeredThisSession ||
        (_prefs.getInt(_laterKey) ?? 0) >= maxLater ||
        _prefs.getBool(_offeredKey(home, ieee)) == true ||
        !_countedThisSession.add('$home/$ieee')) {
      return false;
    }
    final uses = (_prefs.getInt(_usesKey(home, ieee)) ?? 0) + 1;
    _prefs.setInt(_usesKey(home, ieee), uses);
    return uses >= sessions;
  }

  /// The offer for [ieee] was shown: it isn't shown again.
  void offered(String home, String ieee) {
    _offeredThisSession = true;
    _prefs.setBool(_offeredKey(home, ieee), true);
  }

  /// The offer was turned down with Not now.
  void later() => _prefs.setInt(_laterKey, (_prefs.getInt(_laterKey) ?? 0) + 1);
}

final shortcutNudgePolicyProvider = Provider<ShortcutNudgePolicy>(
  (ref) => ShortcutNudgePolicy(ref.watch(sharedPreferencesProvider)),
);

/// The dashboard tile that shows [ieee] in [home], or null when the device
/// isn't on a dashboard (widgets and tiles follow a dashboard tile).
Future<Panel?> _deviceTile(AppDatabase db, String home, String ieee) async {
  final dashboards = await (db.select(
    db.dashboards,
  )..where((d) => d.connectionId.equals(home))).get();
  final ids = {for (final d in dashboards) d.id};
  final panels = await (db.select(
    db.panels,
  )..where((p) => p.deviceIeee.equals(ieee))).get();
  return panels
      .where((p) => p.type == PanelType.device && ids.contains(p.dashboardId))
      .firstOrNull;
}

/// Whether [ieee] already has a home-screen widget or a Quick Settings tile.
Future<bool> _hasShortcut(AppDatabase db, String home, String ieee) async {
  for (final s in await ShortcutDao(db).getByConnection(home)) {
    if ((s.surface == ShortcutSurface.widget || s.tileSlot != null) &&
        shortcutTargets(s).contains(ieee)) {
      return true;
    }
  }
  return false;
}

/// Offers a shortcut for [ieee] when it is due ([ShortcutNudgePolicy]), is
/// on a dashboard and has none yet: a banner with Home screen, Quick
/// Settings (for a device that switches or moves) and Not now.
Future<void> maybeOfferShortcut(
  BuildContext context,
  WidgetRef ref, {
  required String connectionId,
  required String ieee,
}) async {
  if (!AddShortcutButton.available) return;
  final policy = ref.read(shortcutNudgePolicyProvider);
  if (!policy.noteUse(connectionId, ieee)) return;
  final db = ref.read(appDatabaseProvider);
  final tile = await _deviceTile(db, connectionId, ieee);
  if (tile == null || await _hasShortcut(db, connectionId, ieee)) return;
  if (!context.mounted) return;
  final config = PanelConfig.decode(tile.type, tile.config);
  final canTile =
      config is DeviceTileConfig &&
      (config.profile.switches.isNotEmpty ||
          config.profile.deviceClass == DeviceClass.cover);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final read = ref.read;
  final analytics = ref.read(analyticsProvider);
  final service = ref.read(shortcutServiceProvider);
  policy.offered(connectionId, ieee);
  analytics.track(const ShortcutNudge(ShortcutNudgeStep.shown));

  void answer(ShortcutNudgeStep step) {
    messenger.hideCurrentMaterialBanner();
    analytics.track(ShortcutNudge(step));
  }

  messenger.showMaterialBanner(
    MaterialBanner(
      key: const Key('shortcut-nudge'),
      leading: const Icon(Icons.add_to_home_screen),
      content: Text(l10n.shortcutNudge(tile.name)),
      actions: [
        TextButton(
          key: const Key('shortcut-nudge-later'),
          onPressed: () {
            policy.later();
            answer(ShortcutNudgeStep.later);
          },
          child: Text(l10n.shortcutNudgeLater),
        ),
        if (canTile)
          TextButton(
            key: const Key('shortcut-nudge-tile'),
            onPressed: () {
              answer(ShortcutNudgeStep.tile);
              AddTileButton.add(
                context,
                read,
                connectionId: connectionId,
                ieee: ieee,
                name: tile.name,
                from: ShortcutFrom.nudge,
              );
            },
            child: Text(l10n.shortcutNudgeTile),
          ),
        TextButton(
          key: const Key('shortcut-nudge-widget'),
          onPressed: () {
            answer(ShortcutNudgeStep.widget);
            addHomeScreenWidget(
              context,
              service,
              kind: 'device',
              connectionId: connectionId,
              target: ieee,
              name: tile.name,
              from: ShortcutFrom.nudge,
            );
          },
          child: Text(l10n.shortcutNudgeWidget),
        ),
      ],
    ),
  );
}
