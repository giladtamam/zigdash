// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_dao.dart';

// ignore_for_file: type=lint
mixin _$PanelDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConnectionsTable get connections => attachedDatabase.connections;
  $DashboardsTable get dashboards => attachedDatabase.dashboards;
  $PanelsTable get panels => attachedDatabase.panels;
  PanelDaoManager get managers => PanelDaoManager(this);
}

class PanelDaoManager {
  final _$PanelDaoMixin _db;
  PanelDaoManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db.attachedDatabase, _db.connections);
  $$DashboardsTableTableManager get dashboards =>
      $$DashboardsTableTableManager(_db.attachedDatabase, _db.dashboards);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db.attachedDatabase, _db.panels);
}
