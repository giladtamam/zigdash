import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/theme/app_theme.dart';
import 'package:zigdash/core/theme/signal_colors.dart';
import 'package:zigdash/core/utils/material_icon.dart';

void main() {
  group('materialIcon draws stored icons rounded (ADR 0005)', () {
    test('a stored regular icon draws as its rounded variant', () {
      expect(materialIcon(Icons.home.codePoint).codePoint,
          Icons.home_rounded.codePoint);
      expect(materialIcon(Icons.lightbulb.codePoint).codePoint,
          Icons.lightbulb_rounded.codePoint);
    });
    test('a code point without a rounded variant draws unchanged', () {
      expect(materialIcon(Icons.home_rounded.codePoint).codePoint,
          Icons.home_rounded.codePoint);
    });
    test('every icon the pickers offer has a rounded variant', () {
      for (final path in [
        'lib/features/dashboards/screens/dashboard_form_screen.dart',
        'lib/features/scenes/screens/scene_form_screen.dart',
      ]) {
        final src = File(path).readAsStringSync();
        final list = RegExp(r'const _icons = <IconData>\[(.*?)\];', dotAll: true)
            .firstMatch(src)!
            .group(1)!;
        for (final name in RegExp(r'Icons\.(\w+)').allMatches(list)) {
          expect(RegExp('static const IconData ${name.group(1)}_rounded ')
              .hasMatch(_icons), isTrue, reason: '${name.group(1)} in $path');
        }
      }
    });
  });

  test('no hard-coded Material colours in lib/ (signal-2.0.md §1)', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'Colors\.(red|green|orange|amber|blue|grey)').hasMatch(lines[i])) {
          offenders.add('${f.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('both themes carry the state roles', () {
    for (final t in [AppTheme.light(), AppTheme.dark()]) {
      expect(t.extension<SignalColors>(), isNotNull);
    }
    final dyn = AppTheme.light(
        dynamic: ColorScheme.fromSeed(seedColor: const Color(0xFF3A7D44)));
    expect(dyn.extension<SignalColors>()!.active,
        isNot(SignalColors.light.active),
        reason: 'amber is harmonized toward the wallpaper');
  });
}

final _icons = File(
        '${Platform.environment['FLUTTER_ROOT'] ?? '${Platform.environment['HOME']}/development/flutter-3.47.5'}/packages/flutter/lib/src/material/icons.dart')
    .readAsStringSync();
