// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'ZigDash';

  @override
  String get navBrokers => 'ברוקרים';

  @override
  String get navDashboards => 'לוחות';

  @override
  String get navSettings => 'הגדרות';

  @override
  String get settingsAppearance => 'מראה';

  @override
  String get themeSystem => 'מערכת';

  @override
  String get themeLight => 'בהיר';

  @override
  String get themeDark => 'כהה';

  @override
  String get settingsDynamicColor => 'צבעי Material You';

  @override
  String get settingsDynamicColorSubtitle =>
      'אנדרואיד 12 ומעלה; אחרת נעשה שימוש בצבע האפליקציה';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get languageSystem => 'מערכת';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHebrew => 'עברית';
}
