import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/utils/uuid.dart';
import '../../data/database/daos/dashboard_dao.dart';
import '../../data/database/daos/device_registry_dao.dart';
import '../../data/database/daos/scene_dao.dart';
import '../../data/database/database.dart';
import '../../data/database/tables/panels.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../../data/repositories/connection_repo.dart';
import '../../data/repositories/dashboard_repo.dart';
import '../devices/device_tiles.dart' show z2mBase;
import '../devices/devices_providers.dart'
    show baseTopicOverrideProvider, homeBaseTopicProvider;
import '../discovery/models/z2m_device.dart';
import '../discovery/providers/discovery_provider.dart';
import '../settings/providers/settings_controller.dart';
import 'all_shutters.dart';
import 'models/scene.dart';
import 'scene_capture.dart';

/// Repository over [SceneDao]. Maps the create/update args to Drift companions.
class SceneRepo {
  SceneRepo(this._dao);
  final SceneDao _dao;

  Stream<List<Scene>> watchByConnection(String connectionId) =>
      _dao.watchByConnection(connectionId);

  Future<List<Scene>> getByConnection(String connectionId) =>
      _dao.getByConnection(connectionId);

  Future<Scene?> getById(String id) => _dao.getById(id);

  Future<String> create({
    required String connectionId,
    required String name,
    required int iconCodepoint,
    required int colorSeed,
    required List<SceneAction> actions,
    int sortOrder = 0,
  }) async {
    final id = newId();
    final now = DateTime.now();
    await _dao.insertRow(ScenesCompanion.insert(
      id: id,
      connectionId: connectionId,
      name: name,
      iconCodepoint: iconCodepoint,
      colorSeed: colorSeed,
      actions: SceneAction.encodeList(actions),
      sortOrder: Value(sortOrder),
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> update({
    required String id,
    required String name,
    required int iconCodepoint,
    required int colorSeed,
    required List<SceneAction> actions,
  }) async {
    await _dao.updateById(
      id,
      ScenesCompanion(
        name: Value(name),
        iconCodepoint: Value(iconCodepoint),
        colorSeed: Value(colorSeed),
        actions: Value(SceneAction.encodeList(actions)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) => _dao.deleteById(id);
}

final sceneRepoProvider = Provider<SceneRepo>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SceneRepo(SceneDao(db));
});

/// A Home's scenes: the three built-in "All shutters" scenes first
/// (all_shutters.dart; named in the app's language), then the saved ones.
final scenesForConnectionProvider =
    StreamProvider.family<List<Scene>, String>((ref, connectionId) {
  final l10n = appL10n(ref.watch(settingsControllerProvider).locale);
  final builtIn = allShuttersScenes(connectionId, l10n);
  return ref
      .watch(sceneRepoProvider)
      .watchByConnection(connectionId)
      .map((saved) => [...builtIn, ...saved]);
});

/// A Home's tiles for the scene editor (3.8.7): its scene-able tiles in
/// dashboard then tile order, and its device tiles' names by IEEE address
/// (the first in that order). One read of [DeviceRegistryDao.tilesOfHome].
Future<SceneTiles> loadSceneTiles(AppDatabase db, String connectionId) async {
  final dashboards = await DashboardDao(db).getByConnection(connectionId);
  final dashboardNames = {for (final d in dashboards) d.id: d.name};
  final tiles = <SceneTile>[];
  final deviceNames = <String, String>{};
  for (final (panel, prefix)
      in await DeviceRegistryDao(db).tilesOfHome(connectionId)) {
    if (panel.type == PanelType.device) {
      // Reading tiles carry the IEEE too; only a device tile names it.
      final ieee = panel.deviceIeee;
      if (ieee != null) deviceNames.putIfAbsent(ieee, () => panel.name);
      continue;
    }
    final tile = sceneTileOf(panel, prefix,
        dashboardName: dashboardNames[panel.dashboardId]);
    if (tile != null) tiles.add(tile);
  }
  return SceneTiles(
    tiles: tiles,
    deviceNames: deviceNames,
    dashboards: dashboards.length,
  );
}

/// How the scene editor reads a Home's tiles (3.8.7): [loadSceneTiles] over
/// the app's database. The editor awaits it directly when it opens a saved
/// scene; tests replace it.
final sceneTilesLoaderProvider =
    Provider<Future<SceneTiles> Function(String connectionId)>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (connectionId) => loadSceneTiles(db, connectionId);
});

/// A Home's tiles for the scene editor's build (3.8.7).
final sceneTilesProvider =
    FutureProvider.autoDispose.family<SceneTiles, String>(
        (ref, connectionId) => ref.watch(sceneTilesLoaderProvider)(connectionId));

/// The Home's shutters as the bridge reports them right now, or null while
/// unknown (not connected, no device list yet).
final homeShuttersProvider =
    Provider.autoDispose.family<List<Z2mDevice>?, String>((ref, connectionId) {
  final base = ref.watch(homeBaseTopicProvider(connectionId));
  if (base == null) return null;
  final devices = ref
      .watch(bridgeDevicesStreamProvider((connectionId: connectionId, base: base)))
      .valueOrNull;
  return devices == null ? null : shuttersOf(devices);
});

/// A scene's actions right now: a saved scene's stored list, or a built-in
/// resolved against the Home's shutters. Empty when they are unknown, or
/// when the Home's base topic is not known yet: better "Not connected"
/// than commands sent under a guessed base.
Future<List<SceneAction>> resolveSceneActions(
  WidgetRef ref,
  String connectionId,
  Scene scene,
) async {
  final command = allShuttersCommand(scene.id);
  if (command == null) return SceneAction.decodeList(scene.actions);
  final base = await homeBaseTopic(ref, connectionId);
  if (base == null) return const [];
  List<Z2mDevice> devices;
  try {
    devices = await ref
        .read(bridgeDevicesStreamProvider(
                (connectionId: connectionId, base: base))
            .future)
        .timeout(shutterListTimeout);
  } catch (_) {
    devices = const [];
  }
  final excluded =
      excludedShutters(ref.read(sharedPreferencesProvider), connectionId);
  return shutterActions(command, base, devices, excluded);
}

/// The Home's base topic, waiting for the homes and dashboards to load:
/// [homeBaseTopicProvider]'s rule, usable from a tap handler where nothing
/// may be watching that provider.
Future<String?> homeBaseTopic(WidgetRef ref, String connectionId) async {
  try {
    await ref.read(connectionsStreamProvider.future).timeout(shutterListTimeout);
    final set = ref.read(baseTopicOverrideProvider(connectionId));
    if (set != null) return set;
    final first = (await ref
            .read(dashboardsForConnectionProvider(connectionId).future)
            .timeout(shutterListTimeout))
        .firstOrNull;
    return first == null ? null : z2mBase(first.topicPrefix);
  } catch (_) {
    return null;
  }
}

/// Runs [scene] as the Scenes tab and the scene tile do. Returns the number
/// of actions published; 0 when disconnected or, for a built-in, when no
/// shutter is known or included.
Future<int> runScene(WidgetRef ref, String connectionId, Scene scene) async {
  ref.read(analyticsProvider).track(const FeatureUsed(Feature.sceneRun));
  return activateScene(ref, connectionId, await resolveSceneActions(ref, connectionId, scene));
}

/// Asks each device to report its current state by publishing a Z2M `/get`
/// request for its gettable+settable properties. Many Z2M setups don't retain
/// device state, so without this the capture screen would see nothing to
/// snapshot. No-op for devices that have nothing gettable+settable.
Future<void> requestDeviceStates(
  WidgetRef ref,
  String connectionId,
  String base,
  List<Z2mDevice> devices,
) async {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  if (!mgr.isConnected) return;
  for (final device in devices) {
    final payload = buildGetPayload(device);
    if (payload.isEmpty) continue;
    mgr.publish('$base/${device.friendlyName}/get', jsonEncode(payload), '');
  }
}

/// Activates a scene: publishes each action's payload to its `/set` topic,
/// lightly sequenced so the broker isn't flooded. Returns the number of
/// actions published. A no-op (returns 0) when the manager is disconnected.
Future<int> activateScene(
  WidgetRef ref,
  String connectionId,
  List<SceneAction> actions, {
  Duration gap = const Duration(milliseconds: 60),
}) async {
  final mgr = await ref.read(mqttManagerProvider(connectionId).future);
  if (!mgr.isConnected) return 0;
  var sent = 0;
  for (final action in actions) {
    // payload is the full JSON; publish it verbatim ({value} is unused).
    mgr.publish(action.setTopic, action.payload, '');
    sent++;
    if (gap > Duration.zero && action != actions.last) {
      await Future<void>.delayed(gap);
    }
  }
  return sent;
}
