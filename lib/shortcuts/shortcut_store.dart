import 'dart:convert';

import '../data/database/daos/device_registry_dao.dart';
import '../data/database/database.dart';
import '../data/database/tables/panels.dart';
import '../features/panels/models/panel_config.dart';
import '../features/panels/providers/panel_value_provider.dart'
    show composeTopic;
import 'shortcut_commander.dart';

// What the app and the headless engine share with the native widget, tile
// and control code, in shared preferences (read natively from
// FlutterSharedPreferences with the plugin's "flutter." prefix; see
// ShortcutPrefs.kt).

/// `{"payload", "at", "line", "on"}`: what a device's shortcuts show.
String shortcutStateKey(String connectionId, String ieee) =>
    'shortcut.state.$connectionId.$ieee';

/// `{"connectionId", "ieee", "name"}`: the device a tile slot controls.
String shortcutTileKey(int slot) => 'shortcut.tile.$slot';

/// The native side's words, in the app's language.
const shortcutStringsKey = 'shortcut.strings';

/// [cover]: a shutter, whose tile opens the slider pop-up instead of
/// toggling; [position]: it can be set to a position.
String encodeTileAssignment(
        {required String connectionId,
        required String ieee,
        required String name,
        bool cover = false,
        bool position = false}) =>
    jsonEncode({
      'connectionId': connectionId,
      'ieee': ieee,
      'name': name,
      if (cover) 'cover': true,
      if (position) 'position': true,
    });

/// The device [ieee] in [connectionId], from its dashboard tile (which
/// follows renames), or null when it has no device tile. Read-only.
Future<ShortcutDevice?> resolveShortcutDevice(
    AppDatabase db, String connectionId, String ieee) async {
  for (final (panel, prefix)
      in await DeviceRegistryDao(db).tilesOfHome(connectionId)) {
    if (panel.deviceIeee != ieee || panel.type != PanelType.device) continue;
    final config = PanelConfig.decode(panel.type, panel.config);
    if (config is! DeviceTileConfig) continue;
    final effective = panel.topicPrefixOverride ?? prefix;
    return ShortcutDevice(
      ieee: ieee,
      name: panel.name,
      publishTopic: composeTopic(effective, panel.topic),
      subscribeTopic:
          composeTopic(effective, panel.subscribeTopic ?? panel.topic),
      profile: config.profile,
    );
  }
  return null;
}
