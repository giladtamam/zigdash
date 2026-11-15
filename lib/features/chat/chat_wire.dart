import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hash;

import '../../remote/remote_seal.dart';

/// ZigDash Chat's wire format, byte-compatible with hub/src/chat.js and
/// tool/zigdash-chat/wire.mjs (docs/design/chat-linking.md): AES-256-GCM
/// seals (iv(12) | ciphertext | tag(16)) as base64 text, opaque relay ids
/// made with the client's own key, and the topics on the home broker.
abstract final class ChatWire {
  static final _random = Random.secure();

  /// Where a Chat client's config goes, retained, on the home broker; an
  /// empty retained payload deletes the client (the Engine forgets it).
  static String clientTopic(String clientId) => 'zigdash/chat/clients/$clientId';

  static String requestTopic(String clientId) => 'zigdash/chat/req/$clientId';
  static String answerTopic(String clientId) => 'zigdash/chat/res/$clientId';

  /// The request and answer topics through the relay: opaque ids under
  /// `homes/<home>/x/`, made with the client's key (as `chatTopics` in wire.mjs).
  static ({String req, String res}) relayTopics(String homeId, String clientId, Uint8List key) => (
        req: 'homes/$homeId/x/${RemoteSeal.opaqueId(key, requestTopic(clientId))}',
        res: 'homes/$homeId/x/${RemoteSeal.opaqueId(key, answerTopic(clientId))}',
      );

  /// Base64 of seal(key, message), as the Engine reads it.
  static String seal(Uint8List key, Map<String, Object?> message, {Uint8List? iv}) =>
      base64.encode(RemoteSeal.seal(key, message, iv: iv));

  /// The message inside a base64 seal, or null when it wasn't sealed with [key].
  static Map<String, Object?>? unseal(Uint8List key, String text) {
    try {
      return RemoteSeal.unseal(key, base64.decode(text.trim()));
    } catch (_) {
      return null;
    }
  }

  static String sha256(String text) => hash.sha256.convert(utf8.encode(text)).toString();

  static Uint8List _bytes(int n) => Uint8List.fromList(List<int>.generate(n, (_) => _random.nextInt(256)));

  /// A client's token: 32 random bytes, base64url without padding (as cli.mjs).
  static String newToken() => base64Url.encode(_bytes(32)).replaceAll('=', '');

  /// A client's own 32-byte sealing key (never the Home's key).
  static Uint8List newKey() => _bytes(32);

  /// `tg-` and six hex digits, as cli.mjs names clients.
  static String newClientId() =>
      'tg-${_bytes(3).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

  /// A request id the Engine accepts (8 to 64 of [A-Za-z0-9_-]).
  static String newRequestId() => base64Url.encode(_bytes(12)).replaceAll('=', '');

  /// The retained config the Engine takes a client from (`chatParseClient`).
  static String clientConfig({
    required String name,
    required String token,
    required Uint8List key,
    required String scope,
    required List<String> controls,
  }) =>
      jsonEncode({
        'v': 1,
        'name': name,
        'hash': sha256(token),
        'key': base64.encode(key),
        'scope': scope,
        'controls': controls,
      });
}
