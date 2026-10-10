import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'support_details.dart';

/// The last connection failure kind and broker scan, kept for Support details
/// until the next successful connection (docs/design/support.md §4). Stored
/// in `support_last.json`, which the Android backup rules exclude; never sent
/// anywhere by the app. Storage errors are swallowed: support must never
/// break connecting.
class SupportLog {
  SupportLog({required this.read, required this.write});

  /// The file's contents, or null when there is none.
  final Future<String?> Function() read;

  /// Replaces the contents; null deletes the file.
  final Future<void> Function(String? contents) write;

  FailureKind? _failure;
  ScanSummary? _scan;
  bool _loaded = false;

  FailureKind? get lastFailure => _failure;
  ScanSummary? get lastScan => _scan;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = await read();
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, Object?>;
      final f = j['failure'];
      if (f is String) {
        _failure = FailureKind.values.asNameMap()[f];
      }
      final s = j['scan'];
      if (s is Map<String, Object?>) _scan = ScanSummary.fromJson(s);
    } catch (_) {}
  }

  Future<void> recordFailure(FailureKind kind) async {
    await load();
    _failure = kind;
    await _save();
  }

  Future<void> recordScan(ScanSummary scan) async {
    await load();
    _scan = scan;
    await _save();
  }

  Future<void> clear() async {
    _loaded = true;
    if (_failure == null && _scan == null) return;
    _failure = null;
    _scan = null;
    await _save();
  }

  Future<void> _save() async {
    try {
      await write(_failure == null && _scan == null
          ? null
          : jsonEncode({
              if (_failure != null) 'failure': _failure!.name,
              if (_scan != null) 'scan': _scan!.toJson(),
            }));
    } catch (_) {}
  }
}

const supportLogFileName = 'support_last.json';

Future<File> _file() async =>
    File(p.join((await getApplicationDocumentsDirectory()).path,
        supportLogFileName));

final supportLogProvider = Provider<SupportLog>((ref) => SupportLog(
      read: () async {
        final f = await _file();
        return await f.exists() ? f.readAsString() : null;
      },
      write: (contents) async {
        final f = await _file();
        if (contents == null) {
          if (await f.exists()) await f.delete();
        } else {
          await f.writeAsString(contents);
        }
      },
    ));
