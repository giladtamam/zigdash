import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../providers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          _SectionHeader(l10n.settingsAppearance),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeSystem),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (v) => ctrl.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (v) => ctrl.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (v) => ctrl.setThemeMode(v!),
          ),
          SwitchListTile(
            title: Text(l10n.settingsDynamicColor),
            subtitle: Text(l10n.settingsDynamicColorSubtitle),
            value: settings.dynamicColor,
            onChanged: ctrl.setDynamicColor,
          ),
          const Divider(),
          _SectionHeader(l10n.settingsLanguage),
          RadioListTile<String?>(
            title: Text(l10n.languageSystem),
            value: null,
            groupValue: settings.locale?.languageCode,
            onChanged: (_) => ctrl.setLocale(null),
          ),
          RadioListTile<String?>(
            title: Text(l10n.languageEnglish),
            value: 'en',
            groupValue: settings.locale?.languageCode,
            onChanged: (_) => ctrl.setLocale(const Locale('en')),
          ),
          RadioListTile<String?>(
            title: Text(l10n.languageHebrew),
            value: 'he',
            groupValue: settings.locale?.languageCode,
            onChanged: (_) => ctrl.setLocale(const Locale('he')),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsAbout),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.settingsHelp),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.help),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
      child: Text(text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary)),
    );
  }
}
