import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/connections.dart';
import '../tables/dashboards.dart';
import '../tables/device_dismissals.dart';
import '../tables/panels.dart';

part 'device_registry_dao.g.dart';

/// Home-wide queries over tiles and devices: which devices a home's tiles
/// show, dismissed devices, and the once-per-home "devices seen" marker.
@DriftAccessor(tables: [Connections, Dashboards, Panels, DeviceDismissals])
class DeviceRegistryDao extends DatabaseAccessor<AppDatabase>
    with _$DeviceRegistryDaoMixin {
  DeviceRegistryDao(super.db);

  /// Every tile of [connectionId]'s dashboards, with its dashboard's prefix.
  Future<List<(Panel, String?)>> tilesOfHome(String connectionId) {
    final q = select(panels).join([
      innerJoin(dashboards, dashboards.id.equalsExp(panels.dashboardId)),
    ])
      ..where(dashboards.connectionId.equals(connectionId));
    return q
        .map((r) => (r.readTable(panels), r.readTable(dashboards).topicPrefix))
        .get();
  }

  Stream<Set<String>> watchLinkedIeees(String connectionId) {
    final q = selectOnly(panels).join([
      innerJoin(dashboards, dashboards.id.equalsExp(panels.dashboardId)),
    ])
      ..addColumns([panels.deviceIeee])
      ..where(dashboards.connectionId.equals(connectionId) &
          panels.deviceIeee.isNotNull());
    return q
        .map((r) => r.read(panels.deviceIeee)!)
        .watch()
        .map((l) => l.toSet());
  }

  Stream<Set<String>> watchDismissed(String connectionId) =>
      (select(deviceDismissals)
            ..where((d) => d.connectionId.equals(connectionId)))
          .map((d) => d.ieee)
          .watch()
          .map((l) => l.toSet());

  Future<void> setLink(String panelId, String ieee) =>
      (update(panels)..where((p) => p.id.equals(panelId)))
          .write(PanelsCompanion(deviceIeee: Value(ieee)));

  Future<void> setPrefix(String panelId, String prefix) =>
      (update(panels)..where((p) => p.id.equals(panelId))).write(
          PanelsCompanion(
              topicPrefixOverride: Value(prefix),
              updatedAt: Value(DateTime.now())));

  Future<void> dismiss(String connectionId, Iterable<String> ieees) async {
    final now = DateTime.now();
    await batch((b) => b.insertAll(
          deviceDismissals,
          [
            for (final ieee in ieees)
              DeviceDismissalsCompanion.insert(
                  connectionId: connectionId, ieee: ieee, dismissedAt: now),
          ],
          mode: InsertMode.insertOrIgnore,
        ));
  }

  Future<DateTime?> devicesSeenAt(String connectionId) async =>
      (await (select(connections)..where((c) => c.id.equals(connectionId)))
              .getSingleOrNull())
          ?.devicesSeenAt;

  Future<void> markDevicesSeen(String connectionId) =>
      (update(connections)..where((c) => c.id.equals(connectionId)))
          .write(ConnectionsCompanion(devicesSeenAt: Value(DateTime.now())));
}
