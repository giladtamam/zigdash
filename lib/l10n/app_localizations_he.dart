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
  String get connLocalHost => 'מארח מקומי';

  @override
  String get connRemoteHost => 'מארח מרוחק (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'בשימוש כשהמארח המקומי אינו זמין. עדיף כתובת ה-Tailscale של הרכזת, למשל 100.x.y.z';

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
  String get statusConnectedRemote => 'מחובר · מרחוק';

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
  String get panelPickerScheduleTitle => 'תזמון';

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

  @override
  String panelFormNew(Object type) {
    return '$type חדש';
  }

  @override
  String panelFormEdit(Object type) {
    return 'עריכת $type';
  }

  @override
  String get panelTypeButton => 'כפתור';

  @override
  String get panelTypeToggle => 'מתג';

  @override
  String get panelTypeSlider => 'מחוון';

  @override
  String get panelTypeLed => 'נורית';

  @override
  String get panelTypeNodeStatus => 'סטטוס צומת';

  @override
  String get panelTypeProgress => 'מד התקדמות';

  @override
  String get panelTypeMultiState => 'רב-מצב';

  @override
  String get panelTypeCombo => 'תפריט נפתח';

  @override
  String get panelTypeRadio => 'בחירה בודדת';

  @override
  String get panelTypeCover => 'תריס';

  @override
  String get panelTypeTextInput => 'שדה טקסט';

  @override
  String get panelTypeTextLog => 'יומן טקסט';

  @override
  String get panelTypeSchedule => 'תזמון';

  @override
  String get panelFormName => 'שם';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'קידומת לוח: $prefix/ (בשימוש אלא אם כן עוקפת למטה)';
  }

  @override
  String get panelFormTopicPrefixOverride => 'עקיפת קידומת נושא (לא חובה)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/shutter';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'שימוש בהתקן אחר בלוח זה. ריק = השתמש בקידומת הלוח.';

  @override
  String get panelFormPublishTopic => 'נושא פרסום (סיומת)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'מצורף לקידומת הפעילה. השאר ריק לפרסום בקידומת עצמה.';

  @override
  String get panelFormTopicSuffix => 'נושא (סיומת)';

  @override
  String get panelFormSubscribeTopic => 'נושא מנוי (סיומת, לא חובה)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'מצורף לקידומת הלוח. ריק = מנוי לקידומת עצמה (מצב Z2M).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'ריק = מנוי לקידומת עצמה (מצב Z2M). זהה לנושא פרסום = שימוש בו.';

  @override
  String get panelFormWidth => 'רוחב';

  @override
  String get panelFormWidthFull => 'מלא';

  @override
  String get panelFormWidthHalf => 'חצי';

  @override
  String get panelFormWidthThird => 'שליש';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — לכל היותר פעם אחת';

  @override
  String get panelFormQos1 => '1 — לפחות פעם אחת';

  @override
  String get panelFormQos2 => '2 — בדיוק פעם אחת';

  @override
  String get panelFormRetain => 'שמירה בברוקר';

  @override
  String get panelToggleOnPayload => 'עומס הפעלה';

  @override
  String get panelToggleOffPayload => 'עומס כיבוי';

  @override
  String get panelToggleJsonPath => 'נתיב JSON (לא חובה)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'ערך הפעלה';

  @override
  String get panelToggleOnMatchHelper =>
      'ערך בנתיב JSON שמסמן \"מופעל\" (לדוגמה: \"ON\")';

  @override
  String get panelSliderMin => 'מינימום';

  @override
  String get panelSliderMax => 'מקסימום';

  @override
  String get panelSliderStep => 'צעד';

  @override
  String get panelSliderTemplate => 'תבנית ערך';

  @override
  String get panelSliderTemplateHelper =>
      'השתמש במילה value כ-placeholder — היא מוחלפת בערך המחוון';

  @override
  String get panelSliderJsonPath => 'נתיב JSON (לא חובה)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'עומס';

  @override
  String get panelLedJsonPath => 'נתיב JSON (לא חובה)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'לדוגמה: \"contact\", \"occupancy\", \"water_leak\"';

  @override
  String get panelLedOnMatch => 'ערך הפעלה';

  @override
  String get panelLedOnMatchHelper =>
      'ערך בנתיב JSON שמדליק את הנורית (לדוגמה: \"true\", \"ON\")';

  @override
  String get panelLedOnLabel => 'תווית הפעלה (לא חובה)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'תווית כיבוי (לא חובה)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'עומס מקוון';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'ערך שמסמן \"מקוון\" (ברירת מחדל Z2M: \"online\")';

  @override
  String get panelNodeJsonPath => 'נתיב JSON (לא חובה)';

  @override
  String get panelNodeJsonPathHelper =>
      'השאר ריק לברירת מחדל Z2M (מחרוזת \"online\"/\"offline\" גולמית)';

  @override
  String get panelProgressMin => 'מינימום';

  @override
  String get panelProgressMax => 'מקסימום';

  @override
  String get panelProgressUnit => 'יחידה';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'נתיב JSON (לא חובה)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper =>
      'לדוגמה: \"battery\", \"linkquality\"';

  @override
  String get panelOptionsJsonPath => 'נתיב JSON (לא חובה)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'שדה בעומס המתקבל המכיל את הערך הנוכחי';

  @override
  String get panelOptionsHeader => 'אפשרויות';

  @override
  String get panelOptionsLabel => 'תווית';

  @override
  String get panelOptionsPayload => 'עומס';

  @override
  String get panelOptionsMatch => 'התאמה (ערך נוכחי)';

  @override
  String get panelOptionsAdd => 'הוספת אפשרות';

  @override
  String get panelCoverDescription =>
      'כפתורי פתיחה / עצירה / סגירה בתוספת שורת גישות מיקום. משתמש בעומסי תריס Z2M סטנדרטיים (state ו-position).';

  @override
  String get panelCoverPresets => 'גישות מיקום';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'אחוזים מופרדים בפסיק (0–100). ריק = ללא שורת גישות.';

  @override
  String get panelCoverShowSlider => 'הצגת מחוון מיקום';

  @override
  String get panelTextInputHint => 'רמז (לא חובה)';

  @override
  String get panelTextInputHintHint => 'הקלד ערך…';

  @override
  String get panelTextInputTemplate => 'תבנית';

  @override
  String get panelTextInputTemplateHelper =>
      'השתמש במילה value כ-placeholder — היא מוחלפת בטקסט שהוקלד. ברירת מחדל מפרסמת את הטקסט הגולמי.';

  @override
  String get panelTextInputClearAfterSend => 'נקה לאחר שליחה';

  @override
  String get panelTextLogMaxLines => 'מספר שורות מקסימלי';

  @override
  String get panelTextLogMaxLinesHelper => 'כמה הודעות אחרונות לשמור';

  @override
  String get panelTextLogJsonPath => 'נתיב JSON (לא חובה)';

  @override
  String get panelTextLogJsonPathHelper => 'רישום שדה זה בלבד במקום כל העומס';

  @override
  String get panelScheduleDescription =>
      'פועל ב-SMHUB דרך Node-RED — מופעל גם כשהטלפון כבוי. נושא הפרסום למעלה הוא יעד פקודת התריס.';

  @override
  String get panelScheduleOpenTime => 'זמן פתיחה';

  @override
  String get panelScheduleCloseTime => 'זמן סגירה';

  @override
  String get panelScheduleOpenPayload => 'עומס פתיחה';

  @override
  String get panelScheduleClosePayload => 'עומס סגירה';

  @override
  String get panelScheduleEnabled => 'מופעל';

  @override
  String get panelScheduleSavedOffline =>
      'נשמר — אין חיבור; לוח הזמנים יסונכרן בעת החיבור.';

  @override
  String get panelTileEdit => 'עריכת פאנל';

  @override
  String get panelTileDuplicate => 'שכפול פאנל';

  @override
  String get panelTileMoveUp => 'הזזה למעלה';

  @override
  String get panelTileMoveDown => 'הזזה למטה';

  @override
  String get panelTileWidth => 'רוחב';

  @override
  String get panelTileWidthFull => 'מלא';

  @override
  String get panelTileWidthHalf => 'חצי';

  @override
  String get panelTileWidthThird => '⅓';

  @override
  String get panelTileDelete => 'מחיקת פאנל';

  @override
  String get panelCoverOpen => 'פתיחה';

  @override
  String get panelCoverStop => 'עצירה';

  @override
  String get panelCoverClose => 'סגירה';

  @override
  String get panelToggleNoState => '(אין מצב)';

  @override
  String get panelToggleError => 'שגיאה';

  @override
  String get panelStateOn => 'פועל';

  @override
  String get panelStateOff => 'כבוי';

  @override
  String get panelNodeStatusOnline => 'מקוון';

  @override
  String get panelNodeStatusOffline => 'לא מקוון';

  @override
  String get panelNodeStatusUnknown => 'לא ידוע';

  @override
  String get panelNodeStatusError => 'שגיאה';

  @override
  String get panelMultiStateNoOptions => 'לא הוגדרו אפשרויות';

  @override
  String get panelTextInputDefaultHint => 'הקלד ערך…';

  @override
  String get panelTextLogWaiting => 'ממתין להודעות…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'פותח בשעה $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'סוגר בשעה $time';
  }

  @override
  String get panelScheduleOfflineWarning => 'המתזמן לא מקוון — לא יפעל';

  @override
  String get panelScheduleDisabled => 'מושבת';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'הבא: $action בשעה $at';
  }

  @override
  String get panelScheduleActionOpen => 'פתיחה';

  @override
  String get panelScheduleActionClose => 'סגירה';

  @override
  String get panelGridEmpty =>
      'אין עדיין פאנלים.\nהקש + כדי להוסיף מתג, מחוון או כפתור.';

  @override
  String get settingsAbout => 'אודות';

  @override
  String get settingsHelp => 'עזרה ומדריך';

  @override
  String get a11yBackupMenu => 'גיבוי ושחזור';

  @override
  String get a11ySelectColor => 'בחירת צבע';

  @override
  String get a11ySelectIcon => 'בחירת אייקון';

  @override
  String get a11yDeleteOption => 'מחיקת אפשרות';

  @override
  String get a11yPanelOptions => 'אפשרויות פאנל';

  @override
  String get a11yMoreOptions => 'אפשרויות נוספות';

  @override
  String get a11yDeleteConnection => 'מחיקת חיבור';

  @override
  String get controlNotConnected => 'לא מחובר — השינוי לא נשלח';
}
