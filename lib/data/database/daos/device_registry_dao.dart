import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/connections.dart';
import '../tables/dashboards.dart';
import '../tables/device_dismissals.dart';
import '../tables/device_health_flags.dart';
import '../tables/panels.dart';
import '../tables/sections.dart';

part 'device_registry_dao.g.dart';

/// Home-wide queries over tiles and devices: which devices a home's tiles
/// show, dismissed devices, and the once-per-home "devices seen" marker.
@DriftAccessor(
    tables: [
  Connections,
  Dashboards,
  Panels,
  Sections,
  DeviceDismissals,
  DeviceHealthFlags,
])
class DeviceRegistryDao extends DatabaseAccessor<AppDatabase>
    with _$DeviceRegistryDaoMixin {
  DeviceRegistryDao(super.db);

  /// Every tile of [connectionId]'s dashboards, with its dashboard's prefix.
  Future<List<(Panel, String?)>> tilesOfHome(String connectionId) {
    final q = select(panels).join([
      innerJoin(dashboards, dashboards.id.equalsExp(panels.dashboardId)),
    ])
      ..where(dashboards.connectionId.equals(connectionId))
      ..orderBy([
        OrderingTerm.asc(dashboards.sortOrder),
        OrderingTerm.asc(panels.sortOrder),
      ]);
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

  /// The tiles of a home that show [ieee], with their dashboard and section,
  /// in dashboard then tile order.
  Stream<List<(Panel, Dashboard, Section?)>> watchTilesOfDevice(
      String connectionId, String ieee) {
    final q = select(panels).join([
      innerJoin(dashboards, dashboards.id.equalsExp(panels.dashboardId)),
      leftOuterJoin(sections, sections.id.equalsExp(panels.sectionId)),
    ])
      ..where(dashboards.connectionId.equals(connectionId) &
          panels.deviceIeee.equals(ieee))
      ..orderBy([
        OrderingTerm.asc(dashboards.sortOrder),
        OrderingTerm.asc(panels.sortOrder),
      ]);
    return q
        .map((r) => (
              r.readTable(panels),
              r.readTable(dashboards),
              r.readTableOrNull(sections),
            ))
        .watch();
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

  Future<void> setName(String panelId, String name) =>
      (update(panels)..where((p) => p.id.equals(panelId))).write(
          PanelsCompanion(name: Value(name), updatedAt: Value(DateTime.now())));

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

  /// Records a battery reading's low state for the Devices dot, following
  /// [nextBatteryFlag]. Returns true when the stored flag changed.
  Future<bool> observeBattery(String connectionId, String ieee, bool low) =>
      transaction(() async {
        final row = await (select(deviceHealthFlags)
              ..where((f) =>
                  f.connectionId.equals(connectionId) & f.ieee.equals(ieee)))
            .getSingleOrNull();
        final next = nextBatteryFlag(
            row == null ? null : (low: row.batteryLow, ack: row.acknowledged),
            low);
        if (next == null) return false;
        await into(deviceHealthFlags).insertOnConflictUpdate(
            DeviceHealthFlagsCompanion.insert(
                connectionId: connectionId,
                ieee: ieee,
                batteryLow: next.low,
                acknowledged: next.ack,
                changedAt: DateTime.now()));
        return true;
      });

  /// The user has seen the device (its page opened): its low battery no
  /// longer lights the dot.
  Future<void> acknowledgeBattery(String connectionId, String ieee) =>
      (update(deviceHealthFlags)
            ..where((f) =>
                f.connectionId.equals(connectionId) & f.ieee.equals(ieee)))
          .write(const DeviceHealthFlagsCompanion(acknowledged: Value(true)));

  /// Devices whose battery went low while the app watched, not yet seen.
  Stream<Set<String>> watchBatteryAlerts(String connectionId) =>
      (select(deviceHealthFlags)
            ..where((f) =>
                f.connectionId.equals(connectionId) &
                f.batteryLow.equals(true) &
                f.acknowledged.equals(false)))
          .map((f) => f.ieee)
          .watch()
          .map((l) => l.toSet());
}

/// The battery part of the Devices dot (devices-tablet-1.13.md §3).
///
/// - no flag yet → store the reading as seen: a first report, including
///   every battery already low when 1.13 is installed, never lights the dot;
/// - not low → low: unacknowledged, so the dot lights;
/// - low → not low: cleared;
/// - unchanged: nothing to write (null).
({bool low, bool ack})? nextBatteryFlag(
    ({bool low, bool ack})? current, bool low) {
  if (current == null) return (low: low, ack: true);
  if (current.low == low) return null;
  return low ? (low: true, ack: false) : (low: false, ack: true);
}
