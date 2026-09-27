import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/theme/app_theme.dart';
import 'package:zigdash/core/theme/signal_colors.dart';

/// WCAG contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  double lum(Color c) {
    double ch(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final l1 = lum(a), l2 = lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

/// The fallback scheme and the two golden "wallpapers" (golden_harness.dart).
final _wallpapers = <String, Color?>{
  'fallback': null,
  'wallpaper green': const Color(0xFF3A7D44),
  'wallpaper rose': const Color(0xFFC2185B),
};

void main() {
  // signal-2.0.md §8: 4.5:1 for text; 3:1 for icons and large text.
  for (final MapEntry(key: name, value: seed) in _wallpapers.entries) {
    for (final b in Brightness.values) {
      test('$name ${b.name}: state roles and text meet contrast', () {
        final dynamic =
            seed == null ? null : ColorScheme.fromSeed(seedColor: seed, brightness: b);
        final theme = b == Brightness.light
            ? AppTheme.light(dynamic: dynamic)
            : AppTheme.dark(dynamic: dynamic);
        final s = theme.colorScheme;
        final r = theme.extension<SignalColors>()!;
        final pairs = <String, (Color, Color, double)>{
          'onSurface/surface': (s.onSurface, s.surface, 4.5),
          'onSurfaceVariant/surface': (s.onSurfaceVariant, s.surface, 4.5),
          'onIdle/idle': (r.onIdle, r.idle, 4.5),
          'onSurfaceVariant/idle': (s.onSurfaceVariant, r.idle, 4.5),
          'onActive/active': (r.onActive, r.active, 4.5),
          'onAttention/attention': (r.onAttention, r.attention, 4.5),
          'onAttention/idle (battery text)': (r.onAttention, r.idle, 4.5),
          'onStale/stale': (r.onStale, r.stale, 4.5),
          'onHealthy/healthy': (r.onHealthy, r.healthy, 4.5),
          'offline/idle (muted text)': (r.offline, r.idle, 4.5),
          'active on ink (quick action icon)': (r.active, r.onActive, 3),
          'primary/onPrimary (nav indicator)': (s.onPrimary, s.primary, 3),
        };
        final failures = [
          for (final MapEntry(key: k, value: (fg, bg, min)) in pairs.entries)
            if (contrast(fg, bg) < min)
              '$k ${contrast(fg, bg).toStringAsFixed(2)} < $min',
        ];
        expect(failures, isEmpty);
      });
    }
  }
}
