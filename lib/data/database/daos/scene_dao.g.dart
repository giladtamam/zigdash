// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_dao.dart';

// ignore_for_file: type=lint
mixin _$SceneDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConnectionsTable get connections => attachedDatabase.connections;
  $ScenesTable get scenes => attachedDatabase.scenes;
  SceneDaoManager get managers => SceneDaoManager(this);
}

class SceneDaoManager {
  final _$SceneDaoMixin _db;
  SceneDaoManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db.attachedDatabase, _db.connections);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db.attachedDatabase, _db.scenes);
}
