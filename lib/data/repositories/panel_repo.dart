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

  Future<List<Panel>> getByDashboard(String dashboardId) =>
      _dao.getByDashboard(dashboardId);

  Future<String> create({
    required String dashboardId,
    required String name,
    required PanelType type,
    required String topic,
    String? subscribeTopic,
    String? topicPrefixOverride,
    int qos = 1,
    bool retain = false,
    PanelWidth width = PanelWidth.small,
    int sortOrder = 0,
    String? sectionId,
    String? deviceIeee,
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
      topicPrefixOverride: Value(topicPrefixOverride),
      qos: Value(qos),
      retain: Value(retain),
      width: width,
      sortOrder: Value(sortOrder),
      sectionId: Value(sectionId),
      deviceIeee: Value(deviceIeee),
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
    String? topicPrefixOverride,
    int qos = 1,
    bool retain = false,
    PanelWidth width = PanelWidth.small,
    required PanelConfig config,
  }) async {
    await _dao.updateById(
      id,
      PanelsCompanion(
        name: Value(name),
        topic: Value(topic),
        subscribeTopic: Value(subscribeTopic),
        topicPrefixOverride: Value(topicPrefixOverride),
        qos: Value(qos),
        retain: Value(retain),
        width: Value(width),
        config: Value(config.encode()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) => _dao.deleteById(id);

  Future<void> duplicate(String id) async {
    final p = await _dao.getById(id);
    if (p == null) return;
    await create(
      dashboardId: p.dashboardId,
      name: '${p.name} copy',
      type: p.type,
      topic: p.topic,
      subscribeTopic: p.subscribeTopic,
      topicPrefixOverride: p.topicPrefixOverride,
      qos: p.qos,
      retain: p.retain,
      width: p.width,
      sortOrder: p.sortOrder + 1,
      sectionId: p.sectionId,
      deviceIeee: p.deviceIeee,
      config: PanelConfig.decode(p.type, p.config),
    );
  }

  Future<void> setWidth(String id, PanelWidth width) => _dao.updateById(
        id,
        PanelsCompanion(
          width: Value(width),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Moves [panelId] by [delta] positions within its dashboard, then rewrites
  /// every sibling's sortOrder to the new contiguous order.
  Future<void> move(String dashboardId, String panelId, int delta) async {
    final list = await _dao.getByDashboard(dashboardId);
    final idx = list.indexWhere((p) => p.id == panelId);
    if (idx < 0) return;
    final target = idx + delta;
    if (target < 0 || target >= list.length) return;
    final reordered = [...list];
    final moved = reordered.removeAt(idx);
    reordered.insert(target, moved);
    for (var i = 0; i < reordered.length; i++) {
      await _dao.updateById(
        reordered[i].id,
        PanelsCompanion(
          sortOrder: Value(i),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> reorder(String dashboardId, List<String> panelIds) async {
    for (var i = 0; i < panelIds.length; i++) {
      await _dao.updateById(
        panelIds[i],
        PanelsCompanion(
          sortOrder: Value(i),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }
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
