import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../../engine/engine_installer.dart' show HubLink;

/// Hub backup (docs/design/hub-backup.md): Zigbee2MQTT's own data folder,
/// asked for with `bridge/request/backup`, kept sealed on the phone.

/// How asking Zigbee2MQTT for a backup ended.
sealed class HubBackupAnswer {
  const HubBackupAnswer();
}

/// The zip of Zigbee2MQTT's data folder.
class HubBackupZip extends HubBackupAnswer {
  const HubBackupZip(this.bytes);
  final Uint8List bytes;
}

/// Zigbee2MQTT answered with an error: this adapter or version can't back
/// up. Not retried on its own.
class HubBackupRefused extends HubBackupAnswer {
  const HubBackupRefused();
}

/// No answer in time (Zigbee2MQTT down, or not this base topic).
class HubBackupNoAnswer extends HubBackupAnswer {
  const HubBackupNoAnswer();
}

/// Asks Zigbee2MQTT at [base] for its backup and waits for the answer with
/// the same transaction.
Future<HubBackupAnswer> requestHubBackup(
  HubLink link,
  String base, {
  Duration within = const Duration(seconds: 30),
}) async {
  final tx = 'zigdash-backup-${DateTime.now().millisecondsSinceEpoch}';
  final done = Completer<HubBackupAnswer>();
  final sub = link.listen('$base/bridge/response/backup').listen((raw) {
    if (done.isCompleted || raw.isEmpty) return;
    final answer = decodeBackupResponse(raw, tx);
    if (answer != null) done.complete(answer);
  });
  try {
    link.publish(
      '$base/bridge/request/backup',
      jsonEncode({'transaction': tx}),
    );
    return await done.future.timeout(
      within,
      onTimeout: () => const HubBackupNoAnswer(),
    );
  } finally {
    await sub.cancel();
  }
}

/// The answer in a `bridge/response/backup` payload, or null when it is
/// someone else's (another transaction) or unreadable.
HubBackupAnswer? decodeBackupResponse(String raw, String tx) {
  try {
    final j = jsonDecode(raw);
    if (j is! Map) return null;
    if (j['transaction'] != null && j['transaction'] != tx) return null;
    if (j['status'] != 'ok') return const HubBackupRefused();
    final zip = (j['data'] as Map?)?['zip'];
    if (zip is! String || zip.isEmpty) return const HubBackupRefused();
    return HubBackupZip(base64Decode(zip));
  } catch (_) {
    return null;
  }
}

/// AES-256-GCM over raw bytes, laid out as [RemoteSeal] does: iv(12) |
/// ciphertext | tag(16).
abstract final class BackupSeal {
  static final _random = Random.secure();

  static Uint8List seal(Uint8List key, Uint8List plain) {
    final iv = Uint8List.fromList(
      List<int>.generate(12, (_) => _random.nextInt(256)),
    );
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    return Uint8List.fromList([...iv, ...cipher.process(plain)]);
  }

  /// The bytes inside [sealed], or null when they were not sealed with [key].
  static Uint8List? unseal(Uint8List key, Uint8List sealed) {
    if (sealed.length < 29) return null;
    try {
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false,
          AEADParameters(
            KeyParameter(key),
            128,
            sealed.sublist(0, 12),
            Uint8List(0),
          ),
        );
      return cipher.process(sealed.sublist(12));
    } catch (_) {
      return null;
    }
  }

  static Uint8List newKey() =>
      Uint8List.fromList(List<int>.generate(32, (_) => _random.nextInt(256)));
}

/// One backup kept on the phone.
class HubBackupEntry {
  const HubBackupEntry({required this.at, required this.file});
  final DateTime at;
  final File file;
}

/// Sealed backups in `<root>/<home id>/<UTC stamp>.zdbk`, the newest
/// [keep] per home.
class HubBackupStore {
  HubBackupStore({required this.root, required this.key, this.keep = 7});

  final Directory root;
  final Future<Uint8List> Function() key;
  final int keep;

  Directory _dir(String homeId) => Directory('${root.path}/$homeId');

  /// Newest first.
  Future<List<HubBackupEntry>> list(String homeId) async {
    final dir = _dir(homeId);
    if (!await dir.exists()) return const [];
    final out = <HubBackupEntry>[];
    await for (final f in dir.list()) {
      if (f is! File || !f.path.endsWith('.zdbk')) continue;
      final at = parseStamp(f.uri.pathSegments.last);
      if (at != null) out.add(HubBackupEntry(at: at, file: f));
    }
    out.sort((a, b) => b.at.compareTo(a.at));
    return out;
  }

  Future<HubBackupEntry> save(
    String homeId,
    Uint8List zip,
    DateTime now,
  ) async {
    final dir = _dir(homeId);
    await dir.create(recursive: true);
    final file = File('${dir.path}/${stamp(now)}.zdbk');
    await file.writeAsBytes(BackupSeal.seal(await key(), zip), flush: true);
    final all = await list(homeId);
    for (final old in all.skip(keep)) {
      try {
        await old.file.delete();
      } catch (_) {}
    }
    return HubBackupEntry(at: now.toUtc(), file: file);
  }

  /// The zip inside [entry], or null when it can't be opened (a new key
  /// after reinstalling, or a damaged file).
  Future<Uint8List?> read(HubBackupEntry entry) async =>
      BackupSeal.unseal(await key(), await entry.file.readAsBytes());

  Future<void> deleteHome(String homeId) async {
    final dir = _dir(homeId);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// `20261031T101500Z`.
  static String stamp(DateTime t) {
    final u = t.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${u.year}${two(u.month)}${two(u.day)}T'
        '${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
  }

  static DateTime? parseStamp(String name) {
    final m = RegExp(
      r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z\.zdbk$',
    ).firstMatch(name);
    if (m == null) return null;
    int g(int i) => int.parse(m[i]!);
    return DateTime.utc(g(1), g(2), g(3), g(4), g(5), g(6));
  }
}

/// How long a backup stays fresh before the automatic one takes another.
const hubBackupEvery = Duration(hours: 24);

/// Whether a home whose newest backup is [newest] is due for one at [now].
bool hubBackupDue(DateTime? newest, DateTime now) =>
    newest == null || now.difference(newest) >= hubBackupEvery;

/// `zigbee2mqtt-backup-<home>-<yyyy-mm-dd>.zip` for Save a copy.
String hubBackupFileName(String homeName, DateTime at) {
  final safe = homeName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final l = at.toLocal();
  final date =
      '${l.year}-${l.month.toString().padLeft(2, '0')}'
      '-${l.day.toString().padLeft(2, '0')}';
  return 'zigbee2mqtt-backup-${safe.isEmpty ? 'home' : safe}-$date.zip';
}
