import 'dart:convert';

import '../data/database/daos/device_registry_dao.dart';
import '../data/database/database.dart';
import '../data/database/tables/panels.dart';
import '../features/devices/device_profile.dart';
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

/// The devices offered to Android's Device Controls, a JSON list of
/// [encodeControl] maps.
const shortcutControlsKey = 'shortcut.controls';

/// One device for Device Controls. [kind] picks its control: `switch`
/// (on/off), `dimmer` (on/off and brightness), `cover` (position, or open
/// and close without [position]) or `sensor` (its reading only).
Map<String, Object?> encodeControl(
        {required String connectionId,
        required String home,
        required String ieee,
        required String name,
        required DeviceProfile profile}) {
  final cover = profile.deviceClass == DeviceClass.cover;
  final kind = cover
      ? 'cover'
      : profile.switches.isEmpty
          ? 'sensor'
          : profile.brightness != null
              ? 'dimmer'
              : 'switch';
  return {
    'connectionId': connectionId,
    'home': home,
    'ieee': ieee,
    'name': name,
    'class': profile.deviceClass.name,
    'kind': kind,
    if (cover && profile.position != null) 'position': true,
  };
}

/// The scenes offered to the scene widget's picker, a JSON list of
/// `{"connectionId", "home", "sceneId", "name"}`, per Home in the app's
/// order.
const shortcutScenesKey = 'shortcut.scenes';

/// The groups offered to the group widget's picker: one per dashboard
/// section (tiles outside a section form one named after the dashboard), a
/// JSON list of `{"connectionId", "home", "dashboard", "name", "ieees",
/// "scenes"}` with at most [groupDevices] devices and [groupScenes] scenes.
const shortcutGroupsKey = 'shortcut.groups';
const groupDevices = 5;
const groupScenes = 3;

/// The native side's words, in the app's language.
const shortcutStringsKey = 'shortcut.strings';

/// [cover]: a shutter, whose tile opens the slider pop-up instead of
/// toggling; [position]: it can be set to a position; [deviceClass]: picks
/// the tile's icon (a shutter, a bulb, a plug).
String encodeTileAssignment(
        {required String connectionId,
        required String ieee,
        required String name,
        bool cover = false,
        bool position = false,
        String? deviceClass}) =>
    jsonEncode({
      'connectionId': connectionId,
      'ieee': ieee,
      'name': name,
      if (deviceClass != null) 'class': deviceClass,
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
