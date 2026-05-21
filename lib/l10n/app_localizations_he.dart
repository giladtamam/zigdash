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

  @override
  String get dashPlaceholder =>
      'פתח ברוקר מלשונית הברוקרים כדי לראות ולנהל את לוחות המחוונים שלו.';

  @override
  String get dashAddDashboard => 'הוספת לוח';

  @override
  String get dashEditDashboard => 'עריכת לוח';

  @override
  String get dashAddPanel => 'הוספת פאנל';

  @override
  String get dashEmpty =>
      'אין עדיין לוחות.\nהקש \"הוספת לוח\" כדי ליצור אחד לברוקר זה.';

  @override
  String dashLoadFailed(Object error) {
    return 'שגיאה: $error';
  }

  @override
  String get panelPickerTitle => 'הוספת פאנל';

  @override
  String get panelPickerSectionControl => 'שליטה';

  @override
  String get panelPickerSectionState => 'מצב';

  @override
  String get panelPickerToggleTitle => 'מתג';

  @override
  String get panelPickerToggleSubtitle => 'הפעלה/כיבוי של מצב התקן';

  @override
  String get panelPickerSliderBrightnessTitle => 'מחוון — בהירות';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'עמעום תאורה (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'מחוון — מיקום';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'תריס / כיסוי (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'תריס';

  @override
  String get panelPickerCoverSubtitle =>
      'תריס/וילון: פתח·עצור·סגור + מחוון מיקום';

  @override
  String get panelPickerScheduleTitle => 'לוח זמנים';

  @override
  String get panelPickerScheduleSubtitle =>
      'זמני פתיחה/סגירה יומיים, מופעל ב-Hub (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'רב-מצב';

  @override
  String get panelPickerMultiStateSubtitle =>
      'כפתורים מפולחים לערך enum (לדוגמה: פתח/עצור/סגור)';

  @override
  String get panelPickerComboTitle => 'תפריט נפתח';

  @override
  String get panelPickerComboSubtitle => 'בחירה מרשימה נפתחת עבור enum';

  @override
  String get panelPickerRadioTitle => 'בחירה בודדת';

  @override
  String get panelPickerRadioSubtitle => 'רשימת בחירה בודדת עבור enum';

  @override
  String get panelPickerButtonTitle => 'כפתור';

  @override
  String get panelPickerButtonSubtitle => 'שליחת פקודה חד-פעמית';

  @override
  String get panelPickerTextInputTitle => 'שדה טקסט';

  @override
  String get panelPickerTextInputSubtitle => 'פרסום ערך חופשי או JSON';

  @override
  String get panelPickerLedTitle => 'נורית';

  @override
  String get panelPickerLedSubtitle => 'מחוון צבעוני למצב בוליאני (מגע, נזילה)';

  @override
  String get panelPickerNodeStatusTitle => 'סטטוס צומת';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'זמינות התקן Z2M (מקוון/לא מקוון)';

  @override
  String get panelPickerProgressTitle => 'מד התקדמות';

  @override
  String get panelPickerProgressSubtitle => 'מד עמודה לסוללה, איכות קישור וכד׳';

  @override
  String get panelPickerTextLogTitle => 'יומן טקסט';

  @override
  String get panelPickerTextLogSubtitle => 'היסטוריה גוללת של הודעות בנושא';

  @override
  String get dashExportMenu => 'יצוא לוחות';

  @override
  String get dashImportMenu => 'יבוא לוחות';

  @override
  String get dashExportTitle => 'יצוא לוחות';

  @override
  String get dashExportClose => 'סגירה';

  @override
  String get dashExportCopy => 'העתקה';

  @override
  String get dashExportCopied => 'הועתק ללוח';

  @override
  String get dashImportTitle => 'יבוא לוחות';

  @override
  String get dashImportHint => 'הדבק כאן JSON שיוצא';

  @override
  String get dashImportButton => 'יבוא';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'יובאו $count לוחות',
      one: 'יובא לוח אחד',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'יבוא נכשל: $error';
  }

  @override
  String get dashFormNew => 'לוח חדש';

  @override
  String get dashFormEdit => 'עריכת לוח';

  @override
  String get dashFormName => 'שם';

  @override
  String get dashFormNameHint => 'משרד';

  @override
  String get dashFormTopicPrefix => 'קידומת נושא (לא חובה)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/סלון';

  @override
  String get dashFormTopicPrefixHelper => 'מצורפת לתחילת כל נושא פאנל בלוח זה';

  @override
  String get dashFormColorSeed => 'צבע בסיס';

  @override
  String get dashFormIcon => 'אייקון';

  @override
  String get dashFormLock => 'נעילה';

  @override
  String get dashFormLockSubtitle => 'הסתרת פקדי עריכה בזמן נעילה';

  @override
  String get dashFormDelete => 'מחיקת לוח';

  @override
  String get dashDeleteTitle => 'למחוק את הלוח?';

  @override
  String get dashDeleteContent => 'כל הפאנלים תחתיו יוסרו גם כן.';

  @override
  String get dashDeleteConfirm => 'מחיקה';
}
