import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/uuid.dart';
import '../database/daos/section_dao.dart';
import '../database/database.dart';

class SectionRepo {
  SectionRepo(this._dao);
  final SectionDao _dao;

  Stream<List<Section>> watchByDashboard(String dashboardId) =>
      _dao.watchByDashboard(dashboardId);

  Future<List<Section>> getByDashboard(String dashboardId) =>
      _dao.getByDashboard(dashboardId);

  Future<String> create({
    required String dashboardId,
    required String name,
    int sortOrder = 0,
  }) async {
    final id = newId();
    final now = DateTime.now();
    await _dao.insertRow(
      SectionsCompanion.insert(
        id: id,
        dashboardId: dashboardId,
        name: name,
        sortOrder: Value(sortOrder),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  Future<void> rename(String id, String name) => _dao.updateById(
    id,
    SectionsCompanion(name: Value(name), updatedAt: Value(DateTime.now())),
  );

  Future<void> reorder(List<String> sectionIds) async {
    for (var i = 0; i < sectionIds.length; i++) {
      await _dao.updateById(
        sectionIds[i],
        SectionsCompanion(
          sortOrder: Value(i),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> delete(String id, {required bool deleteTiles}) =>
      _dao.deleteById(id, deleteTiles: deleteTiles);
}

final sectionRepoProvider = Provider<SectionRepo>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SectionRepo(SectionDao(db));
});

final sectionsForDashboardProvider =
    StreamProvider.family<List<Section>, String>((ref, dashboardId) {
      return ref.watch(sectionRepoProvider).watchByDashboard(dashboardId);
    });
