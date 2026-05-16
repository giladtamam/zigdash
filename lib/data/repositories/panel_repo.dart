import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/uuid.dart';
import '../../features/panels/models/panel_config.dart';
import '../database/daos/panel_dao.dart';
import '../database/database.dart';
import '../database/tables/panels.dart';

class PanelRepo {
  PanelRepo(this._dao);
  final PanelDao _dao;

  Stream<List<Panel>> watchByDashboard(String dashboardId) =>
      _dao.watchByDashboard(dashboardId);

  Future<Panel?> getById(String id) => _dao.getById(id);

  Future<String> create({
    required String dashboardId,
    required String name,
    required PanelType type,
    required String topic,
    String? subscribeTopic,
    int qos = 1,
    bool retain = false,
    PanelWidth width = PanelWidth.half,
    int sortOrder = 0,
    required PanelConfig config,
  }) async {
    final id = newId();
    final now = DateTime.now();
    await _dao.insertRow(PanelsCompanion.insert(
      id: id,
      dashboardId: dashboardId,
      name: name,
      type: type,
      topic: topic,
      subscribeTopic: Value(subscribeTopic),
      qos: Value(qos),
      retain: Value(retain),
      width: width,
      sortOrder: Value(sortOrder),
      config: config.encode(),
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> update({
    required String id,
    required String name,
    required String topic,
    String? subscribeTopic,
    int qos = 1,
    bool retain = false,
    PanelWidth width = PanelWidth.half,
    required PanelConfig config,
  }) async {
    await _dao.updateById(
      id,
      PanelsCompanion(
        name: Value(name),
        topic: Value(topic),
        subscribeTopic: Value(subscribeTopic),
        qos: Value(qos),
        retain: Value(retain),
        width: Value(width),
        config: Value(config.encode()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) => _dao.deleteById(id);
}

final panelRepoProvider = Provider<PanelRepo>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PanelRepo(PanelDao(db));
});

final panelsForDashboardProvider =
    StreamProvider.family<List<Panel>, String>((ref, dashboardId) {
  return ref.watch(panelRepoProvider).watchByDashboard(dashboardId);
});

final panelByIdProvider = FutureProvider.family<Panel?, String>((ref, id) {
  return ref.watch(panelRepoProvider).getById(id);
});
