import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _fallbackSeed = Color(0xFF3B82F6);

  static ThemeData light({ColorScheme? dynamic}) {
    final scheme = dynamic?.harmonized() ??
        ColorScheme.fromSeed(seedColor: _fallbackSeed, brightness: Brightness.light);
    return _build(scheme);
  }

  static ThemeData dark({ColorScheme? dynamic}) {
    final scheme = dynamic?.harmonized() ??
        ColorScheme.fromSeed(seedColor: _fallbackSeed, brightness: Brightness.dark);
    return _build(scheme);
  }

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: scheme.brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
