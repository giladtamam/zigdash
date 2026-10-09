// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_dao.dart';

// ignore_for_file: type=lint
mixin _$SectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConnectionsTable get connections => attachedDatabase.connections;
  $DashboardsTable get dashboards => attachedDatabase.dashboards;
  $SectionsTable get sections => attachedDatabase.sections;
  $PanelsTable get panels => attachedDatabase.panels;
  SectionDaoManager get managers => SectionDaoManager(this);
}

class SectionDaoManager {
  final _$SectionDaoMixin _db;
  SectionDaoManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db.attachedDatabase, _db.connections);
  $$DashboardsTableTableManager get dashboards =>
      $$DashboardsTableTableManager(_db.attachedDatabase, _db.dashboards);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db.attachedDatabase, _db.panels);
}
