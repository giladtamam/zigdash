import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Every language carries every string of app_en.arb, and the counts that
// are plurals in English are plurals everywhere (3.8.7).
void main() {
  Map<String, dynamic> read(File f) =>
      jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  Set<String> keys(Map<String, dynamic> arb) => {
    for (final k in arb.keys)
      if (!k.startsWith('@')) k,
  };

  final files = Directory(
    'lib/l10n',
  ).listSync().whereType<File>().where((f) => f.path.endsWith('.arb')).toList();
  final en = read(files.firstWhere((f) => f.path.endsWith('app_en.arb')));

  test('13 languages', () => expect(files, hasLength(13)));

  for (final f in files) {
    final name = f.uri.pathSegments.last;
    test('$name has the same keys as app_en.arb', () {
      final arb = read(f);
      expect(keys(en).difference(keys(arb)), isEmpty, reason: 'missing');
      expect(keys(arb).difference(keys(en)), isEmpty, reason: 'extra');
    });

    test('$name: scene counts are plurals', () {
      final arb = read(f);
      for (final k in [
        'sceneActionsCount',
        'sceneFormKeptActions',
        'autoSceneTilesSkipped',
      ]) {
        expect(arb[k], matches(RegExp(r'^\{count, ?plural,')), reason: k);
      }
    });
  }
}
