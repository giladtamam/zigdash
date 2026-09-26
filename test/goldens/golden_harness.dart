import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zigdash/core/theme/app_theme.dart';
import 'package:zigdash/l10n/app_localizations.dart';

import '../flutter_test_config.dart' show hebrewFallbackFont;

/// One cell of the golden matrix.
class GoldenVariant {
  const GoldenVariant({
    required this.name,
    required this.size,
    this.brightness = Brightness.light,
    this.locale = const Locale('en'),
    this.textScale = 1.0,
    this.dynamicScheme,
  });

  final String name;
  final Size size;
  final Brightness brightness;
  final Locale locale;
  final double textScale;

  /// Stands in for a Material You wallpaper scheme; null uses the fallback.
  final ColorScheme? dynamicScheme;
}

const phone = Size(412, 915);
const tablet = Size(1280, 800);

/// Light/dark x English/Hebrew x text scale 1.0/2.0 on a phone.
const phoneMatrix = [
  GoldenVariant(name: 'light en', size: phone),
  GoldenVariant(name: 'dark en', size: phone, brightness: Brightness.dark),
  GoldenVariant(name: 'light he', size: phone, locale: Locale('he')),
  GoldenVariant(
    name: 'dark he',
    size: phone,
    brightness: Brightness.dark,
    locale: Locale('he'),
  ),
  GoldenVariant(name: 'light en 2x', size: phone, textScale: 2),
  GoldenVariant(
    name: 'dark en 2x',
    size: phone,
    brightness: Brightness.dark,
    textScale: 2,
  ),
  GoldenVariant(
    name: 'light he 2x',
    size: phone,
    locale: Locale('he'),
    textScale: 2,
  ),
  GoldenVariant(
    name: 'dark he 2x',
    size: phone,
    brightness: Brightness.dark,
    locale: Locale('he'),
    textScale: 2,
  ),
];

/// Light/dark x English/Hebrew on a landscape tablet.
const tabletMatrix = [
  GoldenVariant(name: 'tablet light en', size: tablet),
  GoldenVariant(
    name: 'tablet dark en',
    size: tablet,
    brightness: Brightness.dark,
  ),
  GoldenVariant(name: 'tablet light he', size: tablet, locale: Locale('he')),
  GoldenVariant(
    name: 'tablet dark he',
    size: tablet,
    brightness: Brightness.dark,
    locale: Locale('he'),
  ),
];

/// Two fixed "wallpaper" schemes plus the fallback, so harmonized colors are
/// checked under Material You without depending on a device.
final dynamicColorMatrix = [
  const GoldenVariant(name: 'fallback', size: phone),
  GoldenVariant(
    name: 'wallpaper green',
    size: phone,
    dynamicScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A7D44)),
  ),
  GoldenVariant(
    name: 'wallpaper rose',
    size: phone,
    dynamicScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC2185B)),
  ),
];

/// Builds a scenario grid for [variants], each rendering [screen] inside the
/// app's real theme, localizations and text scaling.
GoldenTestGroup goldenMatrix({
  required List<GoldenVariant> variants,
  required List<Override> Function() overrides,
  required Widget Function() screen,
}) {
  return GoldenTestGroup(
    columns: variants.first.size.width > 800 ? 2 : 4,
    children: [
      for (final v in variants)
        GoldenTestScenario(
          name: v.name,
          constraints: BoxConstraints.tight(v.size),
          child: ProviderScope(
            overrides: overrides(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: _withHebrewFallback(
                v.brightness == Brightness.light
                    ? AppTheme.light(dynamic: v.dynamicScheme)
                    : AppTheme.dark(dynamic: v.dynamicScheme),
              ),
              locale: v.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: v.size,
                  textScaler: TextScaler.linear(v.textScale),
                ),
                child: child!,
              ),
              home: screen(),
            ),
          ),
        ),
    ],
  );
}

/// Adds the test-only Hebrew fallback font, standing in for Android's system
/// fallback. Everything else in the app theme is unchanged.
ThemeData _withHebrewFallback(ThemeData theme) => theme.copyWith(
  textTheme: theme.textTheme.apply(fontFamilyFallback: [hebrewFallbackFont]),
  primaryTextTheme: theme.primaryTextTheme.apply(
    fontFamilyFallback: [hebrewFallbackFont],
  ),
);
