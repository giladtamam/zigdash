// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registry_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceRegistryDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConnectionsTable get connections => attachedDatabase.connections;
  $DashboardsTable get dashboards => attachedDatabase.dashboards;
  $SectionsTable get sections => attachedDatabase.sections;
  $PanelsTable get panels => attachedDatabase.panels;
  $DeviceDismissalsTable get deviceDismissals =>
      attachedDatabase.deviceDismissals;
  $DeviceHealthFlagsTable get deviceHealthFlags =>
      attachedDatabase.deviceHealthFlags;
  DeviceRegistryDaoManager get managers => DeviceRegistryDaoManager(this);
}

class DeviceRegistryDaoManager {
  final _$DeviceRegistryDaoMixin _db;
  DeviceRegistryDaoManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db.attachedDatabase, _db.connections);
  $$DashboardsTableTableManager get dashboards =>
      $$DashboardsTableTableManager(_db.attachedDatabase, _db.dashboards);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db.attachedDatabase, _db.panels);
  $$DeviceDismissalsTableTableManager get deviceDismissals =>
      $$DeviceDismissalsTableTableManager(
        _db.attachedDatabase,
        _db.deviceDismissals,
      );
  $$DeviceHealthFlagsTableTableManager get deviceHealthFlags =>
      $$DeviceHealthFlagsTableTableManager(
        _db.attachedDatabase,
        _db.deviceHealthFlags,
      );
}
