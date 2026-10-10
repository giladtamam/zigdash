// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortcut_dao.dart';

// ignore_for_file: type=lint
mixin _$ShortcutDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConnectionsTable get connections => attachedDatabase.connections;
  $ShortcutsTable get shortcuts => attachedDatabase.shortcuts;
  ShortcutDaoManager get managers => ShortcutDaoManager(this);
}

class ShortcutDaoManager {
  final _$ShortcutDaoMixin _db;
  ShortcutDaoManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db.attachedDatabase, _db.connections);
  $$ShortcutsTableTableManager get shortcuts =>
      $$ShortcutsTableTableManager(_db.attachedDatabase, _db.shortcuts);
}
