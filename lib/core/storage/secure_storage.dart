import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _passwordPrefix = 'mqtt_pw::';

class SecureStore {
  SecureStore(this._storage);
  final FlutterSecureStorage _storage;

  Future<String?> readPassword(String connectionId) =>
      _storage.read(key: '$_passwordPrefix$connectionId');

  Future<void> writePassword(String connectionId, String password) =>
      _storage.write(key: '$_passwordPrefix$connectionId', value: password);

  Future<void> deletePassword(String connectionId) =>
      _storage.delete(key: '$_passwordPrefix$connectionId');
}

final secureStorageProvider = Provider<SecureStore>((ref) {
  return SecureStore(const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ));
});
