import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hash;
import 'package:pointycastle/export.dart';

/// Sealing for the ZigDash relay (zigdash-3.0.md §5), byte-compatible with
/// hub/src/engine.js: AES-256-GCM with a 12-byte IV, laid out as
/// iv | ciphertext | tag(16), over the UTF-8 JSON of the message. The relay
/// only ever carries these bytes.
abstract final class RemoteSeal {
  static final _random = Random.secure();

  /// [iv] is for tests only (fixed vectors); every real seal gets a fresh one.
  static Uint8List seal(Uint8List key, Map<String, Object?> message, {Uint8List? iv}) {
    iv ??= Uint8List.fromList(List<int>.generate(12, (_) => _random.nextInt(256)));
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    final sealed = cipher.process(Uint8List.fromList(utf8.encode(jsonEncode(message))));
    return Uint8List.fromList([...iv, ...sealed]); // pointycastle appends the tag
  }

  /// The message inside [bytes], or null when it wasn't sealed with [key].
  static Map<String, Object?>? unseal(Uint8List key, Uint8List bytes) {
    if (bytes.length < 29) return null;
    try {
      final cipher = GCMBlockCipher(AESEngine())
        ..init(false, AEADParameters(KeyParameter(key), 128, bytes.sublist(0, 12), Uint8List(0)));
      final plain = cipher.process(bytes.sublist(12));
      final decoded = jsonDecode(utf8.decode(plain));
      return decoded is Map<String, Object?> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// The relay topic id for a real topic: HMAC-SHA256 with the home key,
  /// first 24 hex characters (as the Engine computes it).
  static String opaqueId(Uint8List key, String topic) =>
      hash.Hmac(hash.sha256, key).convert(utf8.encode(topic)).toString().substring(0, 24);

  /// A fresh home key.
  static Uint8List newKey() => Uint8List.fromList(List<int>.generate(32, (_) => _random.nextInt(256)));
}
