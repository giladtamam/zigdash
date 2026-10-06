import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/settings_controller.dart';

/// The app's languages, each in its own name.
const appLanguages = {
  'en': 'English',
  'he': 'עברית',
  'de': 'Deutsch',
  'nl': 'Nederlands',
  'sv': 'Svenska',
  'nb': 'Norsk bokmål',
  'es': 'Español',
  'fr': 'Français',
  'pt': 'Português (Brasil)',
  'ru': 'Русский',
  'pl': 'Polski',
};

/// "System (English)" or the chosen language's own name.
String languageLabel(Locale? locale, AppLocalizations l10n) {
  final code = locale?.languageCode;
  if (code == null) {
    return '${l10n.languageSystem} (${appLanguages[l10n.localeName.split('_').first] ?? l10n.localeName})';
  }
  return appLanguages[code] ?? code;
}

/// Picks the app language: System, then each language in its own name.
/// A choice applies at once and returns to Settings.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current =
        ref.watch(settingsControllerProvider.select((s) => s.locale));
    final ctrl = ref.read(settingsControllerProvider.notifier);
    Future<void> pick(String? code) async {
      await ctrl.setLocale(code == null ? null : Locale(code));
      if (context.mounted) Navigator.of(context).maybePop();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsLanguage)),
      body: RadioGroup<String?>(
        groupValue: current?.languageCode,
        onChanged: pick,
        child: ListView(
          children: [
            RadioListTile<String?>(
              title: Text(l10n.languageSystem),
              value: null,
            ),
            for (final MapEntry(key: code, value: name) in appLanguages.entries)
              RadioListTile<String?>(
                title: Text(name,
                    textDirection:
                        code == 'he' ? TextDirection.rtl : TextDirection.ltr),
                value: code,
              ),
          ],
        ),
      ),
    );
  }
}
