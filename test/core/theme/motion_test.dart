import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/theme/motion.dart';

/// signal-2.0.md §6: with MediaQuery.disableAnimations set, every animation
/// becomes an instant change.
void main() {
  Future<Duration> durationUnder(WidgetTester tester, {required bool off}) async {
    late Duration d;
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(disableAnimations: off),
      child: Builder(builder: (context) {
        d = SignalMotion.of(context, SignalMotion.stateChange);
        return const SizedBox();
      }),
    ));
    return d;
  }

  testWidgets('animations run at M3 timing by default', (tester) async {
    expect(await durationUnder(tester, off: false), SignalMotion.stateChange);
  });

  testWidgets('animations are instant when the system turns them off',
      (tester) async {
    expect(await durationUnder(tester, off: true), Duration.zero);
  });

  test('every animated widget in lib/ takes its duration from SignalMotion',
      () {
    final animated = RegExp(
        r'\b(Animated[A-Z]\w*|TweenAnimationBuilder<[^>]*>|AnimationController)\(');
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (!animated.hasMatch(lines[i])) continue;
        // The duration argument follows within 8 lines; one written further
        // down (a long AnimationController(...) call) is not checked.
        for (var j = i; j < lines.length && j <= i + 8; j++) {
          if (lines[j].contains('duration:')) {
            if (!lines[j].contains('SignalMotion.of(')) {
              offenders.add('${f.path}:${j + 1}');
            }
            break;
          }
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
