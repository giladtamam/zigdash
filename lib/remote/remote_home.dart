import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// What one phone needs to reach a Home through the ZigDash relay: the
/// Home's relay id, this phone's relay login and the Home's key. Kept in
/// the phone's secure storage only; the key never reaches the relay.
class RemoteHome {
  const RemoteHome({
    required this.homeId,
    required this.url,
    required this.username,
    required this.password,
    required this.key,
  });

  final String homeId;

  /// wss://relay.zigdash.app/mqtt (or a test relay).
  final String url;
  final String username;
  final String password;

  /// The Home's 32-byte key.
  final Uint8List key;

  String get prefix => 'homes/$homeId';

  Map<String, Object?> toJson() => {
        'homeId': homeId,
        'url': url,
        'username': username,
        'password': password,
        'key': base64.encode(key),
      };

  static RemoteHome? fromJson(Object? j) {
    if (j is! Map) return null;
    try {
      final key = base64.decode('${j['key']}');
      if (key.length != 32) return null;
      return RemoteHome(
        homeId: '${j['homeId']}',
        url: '${j['url']}',
        username: '${j['username']}',
        password: '${j['password']}',
        key: Uint8List.fromList(key),
      );
    } catch (_) {
      return null;
    }
  }
}

const _remotePrefix = 'remote_home::';
const _founderPrefix = 'remote_founder::';
const _noncePrefix = 'remote_redeem_nonce::';

/// Remote homes by connection id, in secure storage.
class RemoteHomeStore {
  RemoteHomeStore(this._storage);
  final FlutterSecureStorage _storage;

  Future<RemoteHome?> read(String connectionId) async {
    final raw = await _storage.read(key: '$_remotePrefix$connectionId');
    if (raw == null) return null;
    try {
      return RemoteHome.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String connectionId, RemoteHome home) =>
      _storage.write(key: '$_remotePrefix$connectionId', value: jsonEncode(home.toJson()));

  /// Forgets the login, and with it the founder status and any redeem
  /// nonce kept beside it.
  Future<void> delete(String connectionId) async {
    await _storage.delete(key: '$_remotePrefix$connectionId');
    await _storage.delete(key: '$_founderPrefix$connectionId');
    await _storage.delete(key: '$_noncePrefix$connectionId');
  }

  /// The founder status (founder.dart) as the relay last gave it.
  Future<Map<String, Object?>?> readFounderJson(String connectionId) async {
    final raw = await _storage.read(key: '$_founderPrefix$connectionId');
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw);
      return j is Map<String, Object?> ? j : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeFounderJson(String connectionId, Map<String, Object?> status) =>
      _storage.write(key: '$_founderPrefix$connectionId', value: jsonEncode(status));

  /// The `redeem_nonce` of a founder's code not yet answered with success:
  /// a retry after a lost answer sends the same one.
  Future<String?> readRedeemNonce(String connectionId) => _storage.read(key: '$_noncePrefix$connectionId');

  Future<void> writeRedeemNonce(String connectionId, String nonce) =>
      _storage.write(key: '$_noncePrefix$connectionId', value: nonce);

  Future<void> deleteRedeemNonce(String connectionId) => _storage.delete(key: '$_noncePrefix$connectionId');
}

RemoteHomeStore createRemoteHomeStore() => RemoteHomeStore(
      const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true)),
    );

final remoteHomeStoreProvider = Provider<RemoteHomeStore>((ref) => createRemoteHomeStore());
