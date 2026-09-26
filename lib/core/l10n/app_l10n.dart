import 'dart:ui' show Locale, PlatformDispatcher;

import '../../l10n/app_localizations.dart';

/// The app's strings in the chosen language, else the phone's, else English
/// — for names written into the database outside a widget (setup's home
/// and sections, the demo).
AppLocalizations appL10n(Locale? chosen) {
  final code = (chosen ?? PlatformDispatcher.instance.locale).languageCode;
  final supported =
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);
  return lookupAppLocalizations(Locale(supported ? code : 'en'));
}
