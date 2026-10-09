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

  /// Links a tile to a device by IEEE address, or unlinks it (null).
  Future<void> setDevice(String id, String? ieee) => _dao.updateById(
        id,
        PanelsCompanion(
          deviceIeee: Value(ieee),
          updatedAt: Value(DateTime.now()),
        ),
      );

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

  /// Puts [panelId] into [sectionId] (null: no section), before
  /// [beforeId] or after [afterId] — or last in the section when neither is
  /// given — and rewrites the dashboard's order. The grid shows each
  /// section's tiles in this order.
  Future<void> moveTile(
    String dashboardId,
    String panelId, {
    required String? sectionId,
    String? beforeId,
    String? afterId,
  }) async {
    final list = await _dao.getByDashboard(dashboardId);
    final moving = list.where((p) => p.id == panelId).firstOrNull;
    if (moving == null || panelId == beforeId || panelId == afterId) return;
    final rest = [...list]..remove(moving);
    var at = rest.length;
    if (beforeId != null) {
      final i = rest.indexWhere((p) => p.id == beforeId);
      if (i >= 0) at = i;
    } else if (afterId != null) {
      final i = rest.indexWhere((p) => p.id == afterId);
      if (i >= 0) at = i + 1;
    } else {
      final last = rest.lastIndexWhere((p) => p.sectionId == sectionId);
      if (last >= 0) at = last + 1;
    }
    rest.insert(at, moving);
    await _dao.transaction(() async {
      for (var i = 0; i < rest.length; i++) {
        final p = rest[i];
        await _dao.updateById(
          p.id,
          PanelsCompanion(
            sortOrder: Value(i),
            sectionId: p.id == panelId ? Value(sectionId) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Moves [panelId] one place earlier (-1) or later (+1) among the tiles
  /// of its own section — the non-drag path for screen readers.
  Future<void> moveWithinSection(
      String dashboardId, String panelId, int delta) async {
    final list = await _dao.getByDashboard(dashboardId);
    final moving = list.where((p) => p.id == panelId).firstOrNull;
    if (moving == null) return;
    final section =
        list.where((p) => p.sectionId == moving.sectionId).toList();
    final i = section.indexOf(moving);
    final j = i + delta;
    if (j < 0 || j >= section.length) return;
    await moveTile(
      dashboardId,
      panelId,
      sectionId: moving.sectionId,
      beforeId: delta < 0 ? section[j].id : null,
      afterId: delta > 0 ? section[j].id : null,
    );
  }

  /// Puts a removed tile back exactly as it was (Undo).
  Future<void> restore(Panel panel) =>
      _dao.insertRow(panel.toCompanion(true));

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
