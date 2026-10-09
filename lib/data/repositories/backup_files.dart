import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saves and opens backup files through Android's own file picker (Storage
/// Access Framework), so ZigDash needs no storage permission. Swapped for a
/// fake in tests.
abstract interface class BackupFiles {
  /// Asks where to save [json] as [fileName]. False when the user cancels.
  Future<bool> save(String fileName, String json);

  /// Asks for a backup file and returns its text, or null when cancelled.
  /// Throws [FormatException] when the file is not UTF-8 text.
  Future<String?> open();
}

class PickerBackupFiles implements BackupFiles {
  const PickerBackupFiles();

  @override
  Future<bool> save(String fileName, String json) async =>
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(json)),
        type: FileType.custom,
        allowedExtensions: const ['json'],
      ) !=
      null;

  @override
  Future<String?> open() async {
    // Any type: Android often labels .json files as text/plain or octet
    // stream, so an extension filter would hide valid backups.
    final picked = await FilePicker.pickFiles(withData: true);
    final bytes = picked?.files.single.bytes;
    if (bytes == null) return null;
    return utf8.decode(bytes);
  }
}

final backupFilesProvider =
    Provider<BackupFiles>((ref) => const PickerBackupFiles());

/// `zigdash-<home>-<yyyy-mm-dd>.json`, with the home name made file-safe.
String backupFileName(String homeName, DateTime day) {
  final safe = homeName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final date = '${day.year}-${day.month.toString().padLeft(2, '0')}'
      '-${day.day.toString().padLeft(2, '0')}';
  return 'zigdash-${safe.isEmpty ? 'home' : safe}-$date.json';
}
