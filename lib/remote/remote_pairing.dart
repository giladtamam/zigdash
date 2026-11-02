import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../core/crypto/aead.dart';
import 'remote_home.dart';

/// Moving a Home's remote login between phones (3.1, zigdash-3.0.md §5):
/// a link for a QR code shown at home, and a passphrase-sealed backup file
/// for a phone that was lost.
abstract final class RemotePairing {
  /// `zigdash://remote/pair-phone?c=<base64url JSON>`
  static const linkPath = '/pair-phone';

  static String link(RemoteHome home) {
    final c = base64Url.encode(utf8.encode(jsonEncode({'v': 1, ...home.toJson()}))).replaceAll('=', '');
    return 'zigdash://remote$linkPath?c=$c';
  }

  /// The login in a pairing link's `c` parameter, or null.
  static RemoteHome? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    try {
      final padded = code.padRight((code.length + 3) ~/ 4 * 4, '=');
      final j = jsonDecode(utf8.decode(base64Url.decode(padded)));
      if (j is! Map || j['v'] != 1) return null;
      return RemoteHome.fromJson(j);
    } catch (_) {
      return null;
    }
  }

  // ---------- backup file ----------

  static const _iterations = 200000;
  static final _random = Random.secure();

  static Uint8List _bytes(int n) => Uint8List.fromList(List<int>.generate(n, (_) => _random.nextInt(256)));

  static Uint8List _derive(String passphrase, Uint8List salt, int iterations) {
    return pbkdf2Sha256(Uint8List.fromList(utf8.encode(passphrase)), salt, iterations, 32);
  }

  /// The backup file's text: the login sealed with a key derived from
  /// [passphrase] (PBKDF2-SHA256, AES-256-GCM). Useless without it.
  static String backup(RemoteHome home, String passphrase) {
    final salt = _bytes(16), iv = _bytes(12);
    final data = gcmSeal(
      _derive(passphrase, salt, _iterations),
      iv,
      Uint8List.fromList(utf8.encode(jsonEncode(home.toJson()))),
    );
    return const JsonEncoder.withIndent('  ').convert({
      'zigdash': 'remote-key-backup',
      'v': 1,
      'kdf': 'pbkdf2-sha256',
      'iterations': _iterations,
      'salt': base64.encode(salt),
      'iv': base64.encode(iv),
      'data': base64.encode(data),
    });
  }

  /// The login in a backup file; null for a wrong passphrase or another file.
  static RemoteHome? restore(String text, String passphrase) {
    try {
      final j = jsonDecode(text) as Map;
      if (j['zigdash'] != 'remote-key-backup' || j['v'] != 1) return null;
      final key = _derive(passphrase, base64.decode('${j['salt']}'), (j['iterations'] as num).toInt());
      final plain = gcmOpen(key, base64.decode('${j['iv']}'), base64.decode('${j['data']}'));
      if (plain == null) return null;
      return RemoteHome.fromJson(jsonDecode(utf8.decode(plain)));
    } catch (_) {
      return null;
    }
  }

  /// Is [text] a ZigDash remote-key backup at all (before asking for a passphrase)?
  static bool isBackup(String text) {
    try {
      return (jsonDecode(text) as Map)['zigdash'] == 'remote-key-backup';
    } catch (_) {
      return false;
    }
  }
}
