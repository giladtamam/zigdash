import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Overridden in main() with the preloaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden in main()'),
);

const _kThemeMode = 'theme_mode';
const _kDynamicColor = 'dynamic_color';
const _kLocale = 'locale';

ThemeMode _themeModeFromString(String? s) => switch (s) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

String _themeModeToString(ThemeMode m) => switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

class SettingsController extends Notifier<AppSettings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final code = _prefs.getString(_kLocale);
    return AppSettings(
      themeMode: _themeModeFromString(_prefs.getString(_kThemeMode)),
      dynamicColor: _prefs.getBool(_kDynamicColor) ?? true,
      locale: (code == null || code.isEmpty) ? null : Locale(code),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kThemeMode, _themeModeToString(mode));
  }

  Future<void> setDynamicColor(bool enabled) async {
    state = state.copyWith(dynamicColor: enabled);
    await _prefs.setBool(_kDynamicColor, enabled);
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale);
    if (locale == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, locale.languageCode);
    }
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
