// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_dao.dart';

// ignore_for_file: type=lint
mixin _$ConnectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConnectionsTable get connections => attachedDatabase.connections;
  ConnectionDaoManager get managers => ConnectionDaoManager(this);
}

class ConnectionDaoManager {
  final _$ConnectionDaoMixin _db;
  ConnectionDaoManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db.attachedDatabase, _db.connections);
}
