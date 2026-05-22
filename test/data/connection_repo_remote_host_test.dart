import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';

/// In-memory SecureStore stub (no platform channel in unit tests).
class _MemSecure implements SecureStore {
  final _m = <String, String>{};
  @override
  Future<void> writePassword(String id, String pw) async => _m[id] = pw;
  @override
  Future<String?> readPassword(String id) async => _m[id];
  @override
  Future<void> deletePassword(String id) async => _m.remove(id);
}

void main() {
  test('create + read back persists remoteHost', () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ConnectionRepo(ConnectionDao(db), _MemSecure());

    final id = await repo.create(
      name: 'home',
      host: '192.168.7.210',
      port: 1883,
      protocol: MqttProtocol.tcp,
      remoteHost: 'smhub.tailnet.ts.net',
    );

    final row = await repo.getById(id);
    expect(row!.remoteHost, 'smhub.tailnet.ts.net');
  });

  test('null remoteHost stays null', () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ConnectionRepo(ConnectionDao(db), _MemSecure());

    final id = await repo.create(
      name: 'home',
      host: '192.168.7.210',
      port: 1883,
      protocol: MqttProtocol.tcp,
    );
    final row = await repo.getById(id);
    expect(row!.remoteHost, isNull);
  });
}
