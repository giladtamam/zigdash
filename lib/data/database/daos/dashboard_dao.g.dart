// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_dao.dart';

// ignore_for_file: type=lint
mixin _$DashboardDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConnectionsTable get connections => attachedDatabase.connections;
  $DashboardsTable get dashboards => attachedDatabase.dashboards;
  DashboardDaoManager get managers => DashboardDaoManager(this);
}

class DashboardDaoManager {
  final _$DashboardDaoMixin _db;
  DashboardDaoManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db.attachedDatabase, _db.connections);
  $$DashboardsTableTableManager get dashboards =>
      $$DashboardsTableTableManager(_db.attachedDatabase, _db.dashboards);
}
