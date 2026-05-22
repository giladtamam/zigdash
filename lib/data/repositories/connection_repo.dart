import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage.dart';
import '../../core/utils/uuid.dart';
import '../database/daos/connection_dao.dart';
import '../database/database.dart';
import '../database/tables/connections.dart';

class ConnectionRepo {
  ConnectionRepo(this._dao, this._secure);
  final ConnectionDao _dao;
  final SecureStore _secure;

  Stream<List<Connection>> watchAll() => _dao.watchAll();
  Future<Connection?> getById(String id) => _dao.getById(id);
  Future<String?> readPassword(String id) => _secure.readPassword(id);

  /// Inserts a new connection and stores its password (if any) in secure storage.
  /// Returns the generated ID.
  Future<String> create({
    required String name,
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    int keepAliveSeconds = 60,
    bool autoConnect = false,
    String? remoteHost,
  }) async {
    final id = newId();
    final now = DateTime.now();
    await _dao.insertRow(ConnectionsCompanion.insert(
      id: id,
      name: name,
      host: host,
      port: port,
      protocol: protocol,
      username: Value(username),
      keepAliveSeconds: Value(keepAliveSeconds),
      autoConnect: Value(autoConnect),
      remoteHost: Value(remoteHost),
      createdAt: now,
      updatedAt: now,
    ));
    if (password != null && password.isNotEmpty) {
      await _secure.writePassword(id, password);
    }
    return id;
  }

  /// Updates an existing connection. Pass [password] = null to keep existing,
  /// or empty string to clear it.
  Future<void> update({
    required String id,
    required String name,
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    int keepAliveSeconds = 60,
    bool autoConnect = false,
    String? remoteHost,
  }) async {
    await _dao.updateById(
      id,
      ConnectionsCompanion(
        name: Value(name),
        host: Value(host),
        port: Value(port),
        protocol: Value(protocol),
        username: Value(username),
        keepAliveSeconds: Value(keepAliveSeconds),
        autoConnect: Value(autoConnect),
        remoteHost: Value(remoteHost),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (password != null) {
      if (password.isEmpty) {
        await _secure.deletePassword(id);
      } else {
        await _secure.writePassword(id, password);
      }
    }
  }

  Future<void> delete(String id) async {
    await _dao.deleteById(id);
    await _secure.deletePassword(id);
  }
}

final connectionRepoProvider = Provider<ConnectionRepo>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final secure = ref.watch(secureStorageProvider);
  return ConnectionRepo(ConnectionDao(db), secure);
});

final connectionsStreamProvider = StreamProvider<List<Connection>>((ref) {
  return ref.watch(connectionRepoProvider).watchAll();
});

final connectionByIdProvider = FutureProvider.family<Connection?, String>((ref, id) {
  return ref.watch(connectionRepoProvider).getById(id);
});
