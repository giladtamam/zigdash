import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/uuid.dart';
import '../database/daos/dashboard_dao.dart';
import '../database/database.dart';

class DashboardRepo {
  DashboardRepo(this._dao);
  final DashboardDao _dao;

  Stream<List<Dashboard>> watchByConnection(String connectionId) =>
      _dao.watchByConnection(connectionId);

  Future<Dashboard?> getById(String id) => _dao.getById(id);

  Future<String> create({
    required String connectionId,
    required String name,
    String? topicPrefix,
    required int colorSeed,
    required int iconCodepoint,
    bool locked = false,
    int sortOrder = 0,
  }) async {
    final id = newId();
    final now = DateTime.now();
    await _dao.insertRow(DashboardsCompanion.insert(
      id: id,
      connectionId: connectionId,
      name: name,
      topicPrefix: Value(topicPrefix),
      colorSeed: colorSeed,
      iconCodepoint: iconCodepoint,
      locked: Value(locked),
      sortOrder: Value(sortOrder),
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> update({
    required String id,
    required String name,
    String? topicPrefix,
    required int colorSeed,
    required int iconCodepoint,
    bool locked = false,
  }) async {
    await _dao.updateById(
      id,
      DashboardsCompanion(
        name: Value(name),
        topicPrefix: Value(topicPrefix),
        colorSeed: Value(colorSeed),
        iconCodepoint: Value(iconCodepoint),
        locked: Value(locked),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) => _dao.deleteById(id);
}

final dashboardRepoProvider = Provider<DashboardRepo>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DashboardRepo(DashboardDao(db));
});

final dashboardsForConnectionProvider =
    StreamProvider.family<List<Dashboard>, String>((ref, connectionId) {
  return ref.watch(dashboardRepoProvider).watchByConnection(connectionId);
});

final dashboardByIdProvider =
    FutureProvider.family<Dashboard?, String>((ref, id) {
  return ref.watch(dashboardRepoProvider).getById(id);
});
