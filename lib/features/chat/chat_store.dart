import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A Chat client this phone made: its token and key are needed to read
/// what Chat did. Kept in the phone's secure storage only.
class LocalChatClient {
  const LocalChatClient({
    required this.clientId,
    required this.token,
    required this.key,
    required this.scope,
    required this.created,
    this.confirmed = false,
  });

  final String clientId;
  final String token;
  final Uint8List key;
  final String scope;
  final DateTime created;

  /// The back-code was accepted: the link is live.
  final bool confirmed;

  LocalChatClient confirm() =>
      LocalChatClient(clientId: clientId, token: token, key: key, scope: scope, created: created, confirmed: true);

  Map<String, Object?> toJson() => {
        'client_id': clientId,
        'token': token,
        'key': base64.encode(key),
        'scope': scope,
        'created': created.millisecondsSinceEpoch,
        'confirmed': confirmed,
      };

  static LocalChatClient? fromJson(Object? j) {
    if (j is! Map) return null;
    try {
      final key = base64.decode('${j['key']}');
      if (key.length != 32 || j['client_id'] is! String || j['token'] is! String) return null;
      return LocalChatClient(
        clientId: j['client_id'] as String,
        token: j['token'] as String,
        key: Uint8List.fromList(key),
        scope: j['scope'] == 'control' ? 'control' : 'read',
        created: DateTime.fromMillisecondsSinceEpoch((j['created'] as num).toInt()),
        confirmed: j['confirmed'] == true,
      );
    } catch (_) {
      return null;
    }
  }
}

/// What this phone keeps about a Home's Chat: its clients, and the hub
/// deletions still owed (removed while away; done at home).
class ChatHomeRecord {
  const ChatHomeRecord({this.clients = const [], this.revokeOnHub = const {}});

  final List<LocalChatClient> clients;
  final Set<String> revokeOnHub;

  Map<String, Object?> toJson() => {
        'clients': [for (final c in clients) c.toJson()],
        'revoke': revokeOnHub.toList(),
      };

  static ChatHomeRecord fromJson(Object? j) {
    if (j is! Map) return const ChatHomeRecord();
    return ChatHomeRecord(
      clients: [for (final c in (j['clients'] as List? ?? const [])) ?LocalChatClient.fromJson(c)],
      revokeOnHub: {for (final r in (j['revoke'] as List? ?? const [])) '$r'},
    );
  }
}

abstract class ChatStore {
  Future<ChatHomeRecord> read(String connectionId);
  Future<void> write(String connectionId, ChatHomeRecord record);
}

const _chatPrefix = 'chat_home::';

class SecureChatStore implements ChatStore {
  SecureChatStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final FlutterSecureStorage _storage;

  @override
  Future<ChatHomeRecord> read(String connectionId) async {
    try {
      final raw = await _storage.read(key: '$_chatPrefix$connectionId');
      return raw == null ? const ChatHomeRecord() : ChatHomeRecord.fromJson(jsonDecode(raw));
    } catch (_) {
      return const ChatHomeRecord();
    }
  }

  @override
  Future<void> write(String connectionId, ChatHomeRecord record) =>
      _storage.write(key: '$_chatPrefix$connectionId', value: jsonEncode(record.toJson()));
}

/// In memory, for tests and the demo.
class MemoryChatStore implements ChatStore {
  final records = <String, ChatHomeRecord>{};

  @override
  Future<ChatHomeRecord> read(String connectionId) async => records[connectionId] ?? const ChatHomeRecord();

  @override
  Future<void> write(String connectionId, ChatHomeRecord record) async => records[connectionId] = record;
}
