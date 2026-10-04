import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/theme/app_theme.dart';
import 'package:zigdash/core/theme/font_licenses.dart';
import 'package:zigdash/core/theme/tokens.dart';

/// signal-2.0.md §2: bundled fonts (never fetched), within budget, licensed,
/// and with Hebrew falling back to Plex Hebrew.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  /// family → asset paths, from the pubspec's fonts: section.
  Map<String, List<String>> declaredFonts() {
    final out = <String, List<String>>{};
    String? family;
    for (final line in pubspec.split('\n')) {
      final f = RegExp(r'^\s*- family: (\S+)').firstMatch(line);
      if (f != null) {
        family = f.group(1)!;
        out[family] = [];
      }
      final a = RegExp(r'^\s*- asset: (\S+\.ttf)').firstMatch(line);
      if (a != null && family != null) out[family]!.add(a.group(1)!);
    }
    return out;
  }

  test('every Signal family is bundled from files that exist', () {
    final fonts = declaredFonts();
    for (final family in [
      SignalFonts.display,
      SignalFonts.body,
      SignalFonts.hebrew,
      SignalFonts.symbols,
    ]) {
      expect(fonts[family], isNotEmpty, reason: '$family in pubspec.yaml');
      for (final asset in fonts[family]!) {
        expect(File(asset).existsSync(), isTrue, reason: asset);
      }
    }
  });

  test('the six text fonts fit the 450 KB budget, all fonts 0.6 MB', () {
    final fonts = declaredFonts();
    int sizeOf(Iterable<String> assets) =>
        assets.fold(0, (sum, a) => sum + File(a).lengthSync());
    final text = [
      for (final f in [SignalFonts.display, SignalFonts.body, SignalFonts.hebrew])
        ...fonts[f]!,
    ];
    expect(text, hasLength(6));
    expect(sizeOf(text), lessThanOrEqualTo(450 * 1024));
    expect(sizeOf(fonts.values.expand((a) => a)),
        lessThanOrEqualTo(600 * 1024));
  });

  test('no font is fetched at runtime', () {
    expect(pubspec, isNot(contains('google_fonts')));
  });

  testWidgets('each bundled font ships its licence', (tester) async {
    registerFontLicenses();
    final packages = <String>{};
    await tester.runAsync(() async {
      await for (final entry in LicenseRegistry.licenses) {
        packages.addAll(entry.packages);
      }
    });
    expect(packages, containsAll(<String>[
      'Space Grotesk',
      'IBM Plex Sans',
      'IBM Plex Sans Hebrew',
      'Material Symbols',
    ]));
  });

  test('Hebrew text falls back to Plex Hebrew in both themes', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final styles = [
        theme.textTheme.bodyMedium!,
        theme.textTheme.titleMedium!,
        theme.textTheme.displaySmall!,
      ];
      for (final s in styles) {
        expect(s.fontFamilyFallback, contains(SignalFonts.hebrew));
      }
    }
  });
}
