import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/settings/models/app_settings.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

ProviderContainer _containerWith(SharedPreferences prefs) => ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults when prefs empty: system theme, dynamic on, system locale', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);
    final s = c.read(settingsControllerProvider);
    expect(s.themeMode, ThemeMode.system);
    expect(s.dynamicColor, isTrue);
    expect(s.locale, isNull);
  });

  test('loads persisted values', () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'dynamic_color': false,
      'locale': 'he',
    });
    final prefs = await SharedPreferences.getInstance();
    final s = _containerWith(prefs).read(settingsControllerProvider);
    expect(s.themeMode, ThemeMode.dark);
    expect(s.dynamicColor, isFalse);
    expect(s.locale, const Locale('he'));
  });

  test('setters update state and persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);
    final ctrl = c.read(settingsControllerProvider.notifier);
    await ctrl.setThemeMode(ThemeMode.light);
    await ctrl.setDynamicColor(false);
    await ctrl.setLocale(const Locale('he'));
    final s = c.read(settingsControllerProvider);
    expect(s.themeMode, ThemeMode.light);
    expect(s.dynamicColor, isFalse);
    expect(s.locale, const Locale('he'));
    expect(prefs.getString('theme_mode'), 'light');
    expect(prefs.getBool('dynamic_color'), false);
    expect(prefs.getString('locale'), 'he');
  });

  test('setLocale(null) clears the pref (follow system)', () async {
    SharedPreferences.setMockInitialValues({'locale': 'he'});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);
    await c.read(settingsControllerProvider.notifier).setLocale(null);
    expect(c.read(settingsControllerProvider).locale, isNull);
    expect(prefs.getString('locale'), isNull);
  });
}
