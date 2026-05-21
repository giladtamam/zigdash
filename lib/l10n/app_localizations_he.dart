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

  @override
  String get connectionsTitle => 'חיבורים';

  @override
  String connLoadFailed(Object error) {
    return 'טעינה נכשלה: $error';
  }

  @override
  String get connAddBroker => 'הוספת ברוקר';

  @override
  String get connEmpty =>
      'אין עדיין חיבורים.\nהקש \"הוספת ברוקר\" כדי לחבר את ZigDash לשרת ה-MQTT שלך.';

  @override
  String get connNew => 'חיבור חדש';

  @override
  String get connEdit => 'עריכת חיבור';

  @override
  String get save => 'שמירה';

  @override
  String get saving => 'שומר…';

  @override
  String get fieldRequired => 'שדה חובה';

  @override
  String get connName => 'שם';

  @override
  String get connNameHint => 'ברוקר הבית';

  @override
  String get connHost => 'מארח';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connPort => 'פורט';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsernameOptional => 'שם משתמש (לא חובה)';

  @override
  String get connPasswordOptional => 'סיסמה (לא חובה)';

  @override
  String get connPasswordKeepHint => 'השאר ריק כדי לשמור את הקיימת';

  @override
  String get connAutoConnect => 'התחברות אוטומטית בהפעלה';

  @override
  String get advanced => 'מתקדם';

  @override
  String get connKeepAlive => 'Keep-alive (שניות)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'פרוטוקול';

  @override
  String get edit => 'עריכה';

  @override
  String get delete => 'מחיקה';

  @override
  String get cancel => 'ביטול';

  @override
  String get connDeleteTitle => 'מחיקת חיבור?';

  @override
  String connDeleteContent(Object name) {
    return 'מסיר את \"$name\", לוחות המחוונים והפאנלים שלו, והסיסמה השמורה.';
  }

  @override
  String get statusDisconnected => 'מנותק';

  @override
  String get statusConnecting => 'מתחבר';

  @override
  String get statusConnected => 'מחובר';

  @override
  String get statusReconnecting => 'מתחבר מחדש';

  @override
  String get statusError => 'שגיאה';
}
