import 'package:flutter/material.dart';

/// Immutable app-level preferences. [locale] == null means "follow system".
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.dynamicColor = true,
    this.locale,
  });

  final ThemeMode themeMode;
  final bool dynamicColor;
  final Locale? locale;

  static const Object _unset = Object();

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? dynamicColor,
    Object? locale = _unset,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        dynamicColor: dynamicColor ?? this.dynamicColor,
        locale: identical(locale, _unset) ? this.locale : locale as Locale?,
      );
}
