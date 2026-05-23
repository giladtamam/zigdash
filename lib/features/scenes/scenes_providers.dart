import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/uuid.dart';
import '../../data/database/daos/scene_dao.dart';
import '../../data/database/database.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import 'models/scene.dart';

/// Repository over [SceneDao]. Maps the create/update args to Drift companions.
class SceneRepo {
  SceneRepo(this._dao);
  final SceneDao _dao;

  Stream<List<Scene>> watchByConnection(String connectionId) =>
      _dao.watchByConnection(connectionId);

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

final scenesForConnectionProvider =
    StreamProvider.family<List<Scene>, String>((ref, connectionId) {
  return ref.watch(sceneRepoProvider).watchByConnection(connectionId);
});

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
