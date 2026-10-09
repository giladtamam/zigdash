// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get reliabilityLastKnown => 'ערך אחרון ידוע';

  @override
  String get reliabilityControlsUnavailable => 'הפקדים אינם זמינים';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'נסו הדגמה';

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
  String get connectionsTitle => 'בתים';

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
  String get connFindBrokers => 'חיפוש ברוקרים';

  @override
  String get connHowToFind => 'איך מוצאים את זה?';

  @override
  String get connRescan => 'סריקה מחדש';

  @override
  String get connBrokerNeedsLogin => 'דורש התחברות';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'סורק $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return 'נמצאו $count ברוקרים — הקש לבחירה';
  }

  @override
  String get connFindBrokersNone => 'לא נמצאו ברוקרים ברשת ה‑Wi‑Fi.';

  @override
  String get connFindBrokersNoIp =>
      'לא ניתן לקרוא את כתובת ה‑Wi‑Fi. ודא שה‑Wi‑Fi פעיל ונסה שוב.';

  @override
  String get connHelpTitle => 'איתור כתובת ה‑IP של הברוקר';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT ב‑Docker';

  @override
  String get connHelpDockerBody =>
      'כתובת הברוקר היא כתובת ה‑LAN של המכונה שמריצה את Docker (ה‑NAS, ה‑Raspberry Pi וכו\'). מצא אותה ברשימת המכשירים של הנתב, או הרץ \'hostname -I\' / \'ip addr\' על אותה מכונה. הפורט הוא בדרך כלל 1883 (Mosquitto). השתמש בכתובת ה‑LAN של המארח — לא 127.0.0.1 — גם אם Mosquitto רץ בקונטיינר נפרד.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'כתובת הברוקר היא כתובת ה‑IP של ההאב. מצא אותה בממשק הווב של SMLIGHT תחת Settings → Network, או בנתב. הפורט הוא 1883, ללא שם משתמש/סיסמה כברירת מחדל.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ל‑ZHA אין ברוקר MQTT — הוא מתקשר ישירות עם Home Assistant, ולכן ZigDash לא יכול להתחבר אליו. כדי להשתמש ב‑ZigDash, עבור ל‑Zigbee2MQTT (זמין כתוסף ל‑Home Assistant או כקונטיינר Docker), שמספק ברוקר MQTT.';

  @override
  String get connHelpSameNetwork =>
      'הטלפון והברוקר חייבים להיות באותה רשת Wi‑Fi (לא רשת אורחים או VLAN מבודד).';

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
  String get panelPickerAutoCloseTitle => 'סגירה אוטומטית';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'סגירת מכשיר אוטומטית N שניות אחרי הפעלה, רץ בהאב (Node-RED)';

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
  String get panelTypeAutoClose => 'סגירה אוטומטית';

  @override
  String get panelTypeDevice => 'מכשיר';

  @override
  String get panelTypeReading => 'קריאה';

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
  String get tileSize => 'גודל';

  @override
  String get tileSizeSmall => 'קטן';

  @override
  String get tileSizeWide => 'רחב';

  @override
  String get tileSizeFull => 'מלא';

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
  String get panelAutoCloseDescription =>
      'רץ על ה-SMHUB דרך Node-RED — פועל גם כשהטלפון כבוי. נושא הפרסום למעלה הוא נושא הפקודה של המכשיר (למשל door).';

  @override
  String get panelAutoCloseTriggerPath => 'נתיב JSON לטריגר';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'השדה ב-JSON של המכשיר שצריך לעקוב (ברירת מחדל: state)';

  @override
  String get panelAutoCloseTriggerValue => 'ערך טריגר';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'הפעל טיימר כששדה הטריגר שווה לערך הזה (ברירת מחדל: ON)';

  @override
  String get panelAutoCloseClosePayload => 'מטען סגירה';

  @override
  String get panelAutoCloseDelaySeconds => 'השהיה (שניות)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1-3600. זמן להמתין אחרי הפעלת המכשיר לפני פרסום מטען הסגירה.';

  @override
  String get panelAutoCloseEnabled => 'מופעל';

  @override
  String get panelAutoCloseSavedOffline =>
      'נשמר — אין חיבור; החוק יסונכרן ברגע שתחזור החיבור.';

  @override
  String get panelTileEdit => 'עריכת פאנל';

  @override
  String get panelTileDuplicate => 'שכפול פאנל';

  @override
  String get panelTileMoveUp => 'הזזה למעלה';

  @override
  String get panelTileMoveDown => 'הזזה למטה';

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
  String get panelAutoCloseIdle => 'במנוחה';

  @override
  String get panelAutoCloseDisabled => 'מושבת';

  @override
  String get panelAutoCloseOffline => 'אוטומציה לא מחוברת — החוק לא ירוץ';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'סוגר בעוד $seconds שניות';
  }

  @override
  String get panelAutoCloseClosingNow => 'סוגר עכשיו…';

  @override
  String get panelGridEmpty =>
      'אין עדיין אריחים.\nהקישו על \'הוספת אריח\' כדי להציב כאן את המכשירים.';

  @override
  String get panelsOffline => 'לא מקוון — מוצגים הערכים האחרונים';

  @override
  String get connectionConnecting => 'מתחבר…';

  @override
  String get connectionReconnecting => 'מתחבר מחדש…';

  @override
  String get connectionShowingLastKnownValues =>
      'מציג את הערכים הידועים האחרונים';

  @override
  String get connectionFailed => 'החיבור נכשל';

  @override
  String get connectionAutomaticRetry => 'ניסיונות החיבור האוטומטיים יימשכו';

  @override
  String get connectionReconnectNow => 'התחבר עכשיו';

  @override
  String get settingsAbout => 'אודות';

  @override
  String get settingsHelp => 'עזרה ומדריך';

  @override
  String get settingsVersion => 'גרסה';

  @override
  String get settingsRateApp => 'דרגו את ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'נהנים? ביקורת קצרה עוזרת לאחרים למצוא את האפליקציה.';

  @override
  String get settingsFeatureRequest => 'בקשת תכונה';

  @override
  String get settingsFeatureRequestSubtitle => 'ספרו לי מה ישפר את ZigDash.';

  @override
  String get featureRequestGithub => 'ב-GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'ציבורי: אחרים יכולים לראות ולהצביע.';

  @override
  String get featureRequestEmail => 'במייל';

  @override
  String get featureRequestEmailSubtitle => 'פרטי, ישירות למפתח.';

  @override
  String get featureRequestEmailSubject => 'ZigDash: בקשת תכונה';

  @override
  String get featureRequestEmailPrompt =>
      'מה הייתם רוצים ש-ZigDash יעשה, ולמה?';

  @override
  String get settingsReportProblem => 'דיווח על בעיה';

  @override
  String get settingsReportProblemSubtitle =>
      'משהו לא עובד או לא ברור? ספרו לי.';

  @override
  String get reportProblemEmailSubject => 'ZigDash: דיווח על בעיה';

  @override
  String get reportProblemEmailPrompt =>
      'מה קרה, ומה ציפיתם שיקרה? דגם המכשיר וגרסת Zigbee2MQTT עוזרים.';

  @override
  String get settingsBuyCoffee => 'קנו לי קפה';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'חינם ובקוד פתוח — טיפים שומרים על הקפה זורם.';

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
  String get a11yRefresh => 'רענון';

  @override
  String get a11yDeleteConnection => 'מחיקת חיבור';

  @override
  String get controlNotConnected => 'לא מחובר — השינוי לא נשלח';

  @override
  String get discoverFromDevice => 'הוספה מהתקן…';

  @override
  String get discoverFromDeviceSubtitle => 'זיהוי אוטומטי של התקן Zigbee2MQTT';

  @override
  String get discoverTitle => 'הוספה מהתקן';

  @override
  String get discoverBaseTopic => 'נושא בסיס של Zigbee2MQTT';

  @override
  String get discoverScanning => 'סורק התקנים…';

  @override
  String get discoverNone => 'לא נמצאו התקנים.';

  @override
  String get discoverFailed =>
      'רשימת ההתקנים לא נמצאה. בדוק את נושא הבסיס ושהברוקר מחובר.';

  @override
  String get retry => 'נסה שוב';

  @override
  String get previewTitle => 'תצוגה מקדימה חיה';

  @override
  String previewWaiting(Object topic) {
    return 'ממתין להודעה בנושא $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'חולץ ($path): $value';
  }

  @override
  String get previewNoValue => '(אין ערך בנתיב זה)';

  @override
  String get connErrorTitle => 'שגיאת חיבור';

  @override
  String get connErrorUnknown => 'אין פרטי שגיאה זמינים.';

  @override
  String get connTestButton => 'בדיקת חיבור';

  @override
  String get connTestOk => 'החיבור הצליח';

  @override
  String connTestFailed(Object error) {
    return 'החיבור נכשל: $error';
  }

  @override
  String get devicesTitle => 'התקנים';

  @override
  String get devicesAddButton => 'הוספת התקן';

  @override
  String get devicesPairingTitle => 'צימוד — לחץ על כפתור ההתקן';

  @override
  String devicesPairingHint(int seconds) {
    return 'מחפש התקנים חדשים… $secondsש׳';
  }

  @override
  String get devicesPairingStop => 'עצור';

  @override
  String get devicesNone => 'לא נמצאו התקנים.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT לא שלח את רשימת המכשירים. זה יכול לקרות אחרי הפעלה מחדש של ה-broker של MQTT.';

  @override
  String get devicesRestartZ2m => 'הפעלה מחדש של Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Zigbee2MQTT מופעל מחדש. המכשירים אמורים להופיע בעוד כמה שניות.';

  @override
  String get devicesBattery => 'סוללה';

  @override
  String get devicesLinkQuality => 'קישור';

  @override
  String get devicesOnline => 'מקוון';

  @override
  String get devicesOffline => 'לא מקוון';

  @override
  String devicesPaired(Object name) {
    return 'מוכן: $name';
  }

  @override
  String get devicesPairedHint =>
      'נוסף לרשת. כדי להוסיף ללוח, השתמש ב\'הוספה מהתקן\' בלוח.';

  @override
  String get scenesTitle => 'סצנות';

  @override
  String get scenesNone =>
      'אין עדיין סצנות. הגדירו את ההתקנים כרצונכם ולאחר מכן שמרו אותם כסצנה.';

  @override
  String get scenesNewButton => 'סצנה חדשה';

  @override
  String scenesActivated(Object name) {
    return 'הופעלה $name';
  }

  @override
  String get scenesActivateOffline => 'אין חיבור — לא ניתן להפעיל את הסצנה';

  @override
  String get sceneFormNewTitle => 'סצנה חדשה';

  @override
  String get sceneFormEditTitle => 'עריכת סצנה';

  @override
  String get sceneFormNameLabel => 'שם הסצנה';

  @override
  String get sceneFormDevicesHeader => 'התקנים ללכידה';

  @override
  String get sceneFormCaptureHint =>
      'נשמר המצב הניתן לשינוי של כל התקן נבחר (דלוק/כבוי, בהירות, צבע, מיקום…). ערכים לקריאה בלבד מתעלמים מהם.';

  @override
  String get sceneFormNoDevices =>
      'לא נמצאו התקנים הניתנים לשליטה. ודאו שהם משויכים והקישו רענון.';

  @override
  String get sceneFormReadingState => 'קורא מצב נוכחי…';

  @override
  String get sceneCtrlPower => 'הפעלה';

  @override
  String get sceneCtrlBrightness => 'בהירות';

  @override
  String get sceneCtrlPosition => 'מיקום';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count נבחרו';
  }

  @override
  String get sceneFormNoDevicesSelected => 'בחרו לפחות התקן אחד ללכידה.';

  @override
  String get sceneFormNothingCaptured =>
      'לא נלכד דבר הניתן לשינוי מההתקנים שנבחרו.';

  @override
  String get sceneDeleteTitle => 'למחוק סצנה?';

  @override
  String sceneDeleteMessage(Object name) {
    return '\"$name\" יוסר. ההתקנים נשארים במצבם הנוכחי.';
  }

  @override
  String get sceneEditAction => 'עריכה';

  @override
  String get sceneDeleteAction => 'מחיקה';

  @override
  String get sceneAddToDashboard => 'הוספה ללוח';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'נוסף ל-$name';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count התקנים';
  }

  @override
  String get panelTypeScene => 'סצנה';

  @override
  String get panelPickerSceneTitle => 'כפתור סצנה';

  @override
  String get panelPickerSceneSubtitle => 'הקשה אחת מפעילה סצנה שמורה';

  @override
  String get panelSceneChoose => 'סצנה';

  @override
  String get panelSceneMissing => 'הסצנה לא נמצאה — בחרו מחדש';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get languageSwedish => 'Svenska';

  @override
  String get languageNorwegian => 'Norsk';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get guidedConnectTitle => 'הגדרת ברוקר';

  @override
  String get guidedConnectIntro =>
      'נבדוק כל שלב בחיבור ונציג את מכשירי ה-Zigbee שלכם.';

  @override
  String get guidedBaseTopic => 'נושא בסיס';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'בדיקה וחיבור';

  @override
  String get guidedTesting => 'בודקים את החיבור…';

  @override
  String get stepResolve => 'פתרון שם מארח';

  @override
  String get stepTcp => 'חיבור TCP';

  @override
  String get stepConnack => 'לחיצת יד MQTT';

  @override
  String get stepAuth => 'אימות';

  @override
  String get stepDevices => 'חיפוש מכשירים';

  @override
  String get diagResolveFail =>
      'לא ניתן לפתור את שם המארח. בדקו את הכתובת שהזנתם.';

  @override
  String get diagResolveTimeout =>
      'פתרון שם המארח עבר את גבול הזמן. בדקו את הכתובת ואת הרשת.';

  @override
  String get diagTcpFail =>
      'לא ניתן להגיע לברוקר. האם Zigbee2MQTT פעיל? בדקו את הכתובת והיציאה.';

  @override
  String get diagTcpTimeout =>
      'החיבור לברוקר עבר את גבול הזמן. ייתכן שהוא לא זמין או מחוץ לרשת.';

  @override
  String get diagConnackFail =>
      'הברוקר לא השלים את לחיצת היד של MQTT. ודאו שזה ברוקר MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'הברוקר דחה את שם המשתמש או הסיסמה. בדקו את פרטי ההתחברות.';

  @override
  String get diagAuthRefused => 'הברוקר סירב לחיבור. בדקו את הגדרות החיבור.';

  @override
  String foundDevices(Object count) {
    return 'נמצאו $count מכשירים';
  }

  @override
  String get foundDevicesHint =>
      'מכשירי הזיגבי שלכם נראים. המשיכו לבניית לוח המחוונים.';

  @override
  String get noDevicesTitle => 'מחובר — עדיין לא נמצאו מכשירים';

  @override
  String get noDevicesHint =>
      'ZigDash רואה את הברוקר, אך טרם נמצאו מכשירי Zigbee. אפשר להתחיל שיוך מכשירים.';

  @override
  String get startPairing => 'התחלת שיוך';

  @override
  String get pairingEnabled =>
      'השיוך פעיל. לחצו על כפתור השיוך במכשיר כדי לצרף אותו.';

  @override
  String get continueToDashboard => 'המשך ללוח המחוונים';

  @override
  String get guidedBackToForm => 'עריכת הגדרות';

  @override
  String ladderTriedHint(Object count) {
    return 'נוסו $count כתובות';
  }

  @override
  String get guidedSaveFailed => 'לא ניתן היה לשמור את החיבור. נסו שוב.';

  @override
  String get setupWelcomeTitle => 'ברוכים הבאים ל-ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash שולט בבית ה-Zigbee2MQTT הקיים שלך — מקומית, ללא ענן. ודאו ש-Zigbee2MQTT פועל, ותנו ל-ZigDash למצוא אותו.';

  @override
  String get setupFindMySetup => 'מצאו את ההתקנה שלי';

  @override
  String get setupManualEntry => 'הזנת פרטים ידנית';

  @override
  String get setupScanningTitle => 'מחפש חיבור…';

  @override
  String get setupScanningHint =>
      'השאירו מכשיר זה באותה רשת מקומית של מארח ה-Zigbee2MQTT.';

  @override
  String get setupCandidateFound => 'נמצא חיבור אפשרי';

  @override
  String get setupNoCandidatesTitle => 'לא נמצא חיבור';

  @override
  String get setupNoCandidatesBody => 'איפה ה-Zigbee2MQTT שלך פועל?';

  @override
  String get setupGuideHa =>
      'Home Assistant: ודאו שה-add-on של ה-MQTT broker (למשל Mosquitto) וה-add-on של Zigbee2MQTT מותקנים ופועלים.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: בדקו שה-broker (למשל Mosquitto) ושירות ה-Zigbee2MQTT פועלים, ושפורט 1883 נגיש.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: פתחו את ממשק הווב, עברו ל‑Settings > MQTT, הפעילו את Allow External כדי שהטלפון יגיע ל‑broker, וודאו ש‑Zigbee2MQTT פועל.';

  @override
  String get setupTryAgain => 'נסו שוב';

  @override
  String get setupAuthTitle => 'ה-broker דורש התחברות';

  @override
  String setupAuthBody(Object host) {
    return 'הזינו שם משתמש וסיסמה של MQTT עבור $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'שם המשתמש או הסיסמה נדחו. בדקו ונסו שוב.';

  @override
  String get setupVerifyingTitle => 'בודק את החיבור…';

  @override
  String get setupReviewTitle => 'המכשירים שלך';

  @override
  String setupReviewSubtitle(Object count) {
    return 'נמצאו $count מכשירים. בחרו מה ייכנס ללוח הראשון.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'צרו לוח עם $count';
  }

  @override
  String get setupGroupOther => 'מכשירים אחרים';

  @override
  String get setupGroupUnsupported => 'מכשירים לא נתמכים';

  @override
  String get setupCreatingTitle => 'יוצר את הלוח…';

  @override
  String get setupReadyTitle => 'הלוח מוכן';

  @override
  String setupReadyBody(Object count) {
    return 'נוצרו $count פקדים.';
  }

  @override
  String get setupOpenDashboard => 'פתחו את הלוח';

  @override
  String get setupErrUnreachableTitle => 'לא ניתן להגיע לכתובת';

  @override
  String get setupErrUnreachableBody =>
      'מכשיר זה ומארח ה-Zigbee2MQTT לא מגיעים זה לזה. בדקו ששניהם באותה רשת מקומית.';

  @override
  String get setupErrUnreachableAction => 'נסו שוב';

  @override
  String get setupErrPortClosedTitle => 'שום דבר לא עונה בפורט הזה';

  @override
  String get setupErrPortClosedBody =>
      'המארח נגיש, אבל אף MQTT broker לא ענה. בדקו שה-broker פועל ושהפורט נכון.';

  @override
  String get setupErrPortClosedAction => 'נסו שוב';

  @override
  String get setupErrAuthRequiredTitle => 'נדרשת התחברות';

  @override
  String get setupErrAuthRequiredBody => 'ה-broker דורש שם משתמש וסיסמה.';

  @override
  String get setupErrAuthRequiredAction => 'הזינו פרטי התחברות';

  @override
  String get setupErrAuthRejectedTitle => 'ההתחברות נדחתה';

  @override
  String get setupErrAuthRejectedBody => 'ה-broker דחה את פרטי ההתחברות האלה.';

  @override
  String get setupErrAuthRejectedAction => 'נסו שוב';

  @override
  String get setupErrNotZ2mTitle => 'אין כאן Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'MQTT broker עונה כאן, אבל לא נמצאו topics של Zigbee2MQTT. ייתכן שזה broker אחר.';

  @override
  String get setupErrNotZ2mAction => 'בחרו אחר';

  @override
  String get setupErrNoDevicesTitle => 'לא התקבלו מכשירים';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT פועל, אבל אף מכשיר לא פורסם במהלך הבדיקה. צמידו מכשירים ב-Zigbee2MQTT קודם.';

  @override
  String get setupErrNoDevicesAction => 'בדקו שוב';

  @override
  String get setupErrScanFailedTitle => 'אין רשת מקומית';

  @override
  String get setupErrScanFailedBody =>
      'לא ניתן לזהות את הרשת המקומית של מכשיר זה. התחברו ל-Wi-Fi ונסו שוב.';

  @override
  String get setupErrScanFailedAction => 'נסו שוב';

  @override
  String get setupErrSaveFailedTitle => 'השמירה נכשלה';

  @override
  String get setupErrSaveFailedBody =>
      'שמירת ההתקנה נכשלה. דבר לא נשמר חלקית — אפשר לנסות שוב בבטחה.';

  @override
  String get setupErrSaveFailedAction => 'נסו שוב';

  @override
  String get setupErrUnknownTitle => 'משהו השתבש';

  @override
  String get setupErrUnknownBody => 'אירעה שגיאה בלתי צפויה.';

  @override
  String get setupErrUnknownAction => 'נסו שוב';

  @override
  String get setupNoZ2mTitle =>
      'ה‑broker שלך עובד, אבל Zigbee2MQTT לא מפרסם כאן';

  @override
  String setupNoZ2mBody(String base) {
    return 'האזנו ל‑$base/bridge ולא התקבל דבר.';
  }

  @override
  String get setupBaseTopicQuestion => 'משתמשים ב‑base topic אחר?';

  @override
  String get setupGuidesTitle => 'הגדרת Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'בינתיים לנסות את ההדגמה';

  @override
  String get demoBannerText => 'את/ה במצב הדגמה';

  @override
  String get demoBannerAction => 'חיבור הבית שלך';

  @override
  String get deviceOn => 'פועל';

  @override
  String get deviceOff => 'כבוי';

  @override
  String get deviceOpen => 'פתוח';

  @override
  String get deviceClosed => 'סגור';

  @override
  String get deviceMotion => 'תנועה';

  @override
  String get deviceClear => 'שקט';

  @override
  String get deviceLeakDetected => 'זוהתה נזילה';

  @override
  String get deviceSmokeDetected => 'זוהה עשן';

  @override
  String get deviceGasDetected => 'זוהה גז';

  @override
  String get deviceWaiting => 'ממתין לדיווח ראשון';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on פועלים · $off כבויים';
  }

  @override
  String get deviceBrightness => 'בהירות';

  @override
  String get deviceWhite => 'לבן';

  @override
  String get deviceColor => 'צבע';

  @override
  String get deviceHue => 'גוון';

  @override
  String get devicePosition => 'מיקום';

  @override
  String get deviceControls => 'פקדים';

  @override
  String deviceBattery(int percent) {
    return 'סוללה $percent%';
  }

  @override
  String get deviceToggle => 'הפעלה או כיבוי';

  @override
  String get deviceMore => 'עוד';

  @override
  String get sectionLights => 'תאורה';

  @override
  String get sectionSwitchesCovers => 'מתגים ותריסים';

  @override
  String get sectionSensors => 'חיישנים';

  @override
  String get sectionOther => 'אחר';

  @override
  String get homeFirstName => 'הבית שלי';

  @override
  String homeNumberedName(int number) {
    return 'בית $number';
  }

  @override
  String get dashAddTile => 'הוספת אריח';

  @override
  String get addTileSearch => 'חיפוש מכשירים';

  @override
  String get addTileNotOnDashboard => 'לא בשום לוח';

  @override
  String get addTileAllDevices => 'כל המכשירים';

  @override
  String get addTileReading => 'קריאה';

  @override
  String get addTileReadingSubtitle => 'ערך אחד ממכשיר או מ‑topic';

  @override
  String get addTileCustom => 'אריח MQTT מותאם';

  @override
  String get addTileCustomSubtitle => 'כל סוג אריח, מוגדר לפי topic';

  @override
  String get addTileNoDevices =>
      'אין מכשירים להצגה. התחברו ל‑broker או צמדו מכשיר ב‑Zigbee2MQTT.';

  @override
  String get addTileAdd => 'הוספה';

  @override
  String get addTileName => 'שם';

  @override
  String addTileNameHint(String model) {
    return 'למשל $model';
  }

  @override
  String get addTileSection => 'מקטע';

  @override
  String get addTileNoSection => 'ללא מקטע';

  @override
  String get addTileSize => 'גודל';

  @override
  String get deviceClassColorLight => 'נורה צבעונית';

  @override
  String get deviceClassLight => 'תאורה';

  @override
  String get deviceClassSwitch => 'מתג או שקע';

  @override
  String get deviceClassCover => 'תריס';

  @override
  String get deviceClassLeak => 'נזילה או עשן';

  @override
  String get deviceClassContact => 'מגע';

  @override
  String get deviceClassMotion => 'תנועה';

  @override
  String get deviceClassClimate => 'חיישן אקלים';

  @override
  String get deviceClassGeneric => 'מכשיר';

  @override
  String get deviceNotResponding => 'לא מגיב';

  @override
  String get homeAdd => 'הוספת בית';

  @override
  String get homeManage => 'ניהול בתים';

  @override
  String get homeSwitch => 'החלפת בית';

  @override
  String get navDevices => 'מכשירים';

  @override
  String get navScenes => 'סצנות';

  @override
  String get devicesNewDot => 'מכשירים חדשים';

  @override
  String get editEditing => 'עריכה';

  @override
  String get editDashboard => 'לוח בקרה';

  @override
  String get editDone => 'סיום';

  @override
  String get editAddSection => 'הוספת מקטע';

  @override
  String get editSectionName => 'שם המקטע';

  @override
  String get editRenameSection => 'שינוי שם המקטע';

  @override
  String get editDeleteSection => 'מחיקת המקטע';

  @override
  String get editDeleteSectionBody => 'מה לעשות עם האריחים שבו?';

  @override
  String get editKeepTiles => 'להשאיר את האריחים ולהסיר את המקטע';

  @override
  String get editDeleteTiles => 'למחוק גם את האריחים';

  @override
  String get editMoveToSection => 'העברה למקטע';

  @override
  String get editEditTile => 'עריכת האריח';

  @override
  String get editRemove => 'הסרה מהלוח';

  @override
  String get editRemoved => 'האריח הוסר';

  @override
  String get editUndo => 'ביטול';

  @override
  String get editReplaceWithDevice => 'החלפה באריח מכשיר';

  @override
  String get editMoveEarlier => 'הזזה קדימה';

  @override
  String get editMoveLater => 'הזזה אחורה';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count מכשירים לא נמצאים בשום לוח',
      one: 'מכשיר אחד לא נמצא בשום לוח',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'אפשרויות האריח';

  @override
  String get editSave => 'שמירה';

  @override
  String get editCancel => 'ביטול';

  @override
  String get ageJustNow => 'עכשיו';

  @override
  String ageMinutes(int n) {
    return 'לפני $n דק׳';
  }

  @override
  String ageHours(int n) {
    return 'לפני $n שע׳';
  }

  @override
  String get statusCantReach => 'אין גישה ל‑broker';

  @override
  String get statusWhy => 'למה?';

  @override
  String get statusWhyTitle => 'ה‑broker לא עונה';

  @override
  String get statusWhyBody =>
      'ZigDash ממשיכה לנסות לבד. עד אז האריחים מציגים את הערכים הידועים האחרונים, מעומעמים ועם הגיל שלהם. בדקו שה‑broker פועל ושהטלפון באותה רשת, או בדקו את החיבור בהגדרות שלו.';

  @override
  String get statusSettings => 'הגדרות חיבור';

  @override
  String get deviceAddToDashboard => 'הוספה ללוח';

  @override
  String get deviceDismiss => 'הסתרה';

  @override
  String get devicesFilterAll => 'הכול';

  @override
  String devicesFilterAttention(int count) {
    return 'דורשים תשומת לב · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'לא בשום לוח · $count';
  }

  @override
  String get devicesNoMatch => 'אין מכשירים תואמים';

  @override
  String get deviceBatteryLow => 'סוללה חלשה';

  @override
  String get deviceLinkWeak => 'חלש';

  @override
  String get deviceUnsupported => 'לא נתמך ב‑Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'הצימוד לא הושלם';

  @override
  String get deviceNoReport => 'אין דיווח עדיין';

  @override
  String get devicesAvailabilityOff =>
      'הזמינות ב‑Zigbee2MQTT כבויה, ולכן מכשירים מנותקים מוצגים כ„לא מגיב”.';

  @override
  String get devicesAvailabilityHow => 'איך להפעיל אותה';

  @override
  String get devicesDotBattery => 'סוללה חלשה';

  @override
  String get deviceDetails => 'פרטי המכשיר';

  @override
  String get deviceGone => 'המכשיר הזה כבר לא נמצא ב‑Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'שליטה';

  @override
  String get deviceReadingsTitle => 'קריאות';

  @override
  String get deviceHealthTitle => 'תקינות';

  @override
  String get deviceOnDashboards => 'בלוחות';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT עדיין לא תומך במכשיר הזה, אז אין מה לשלוט בו.';

  @override
  String get deviceAddReadingTile => 'הוספה כאריח קריאה';

  @override
  String get deviceAddReadingTo => 'להוסיף לאיזה לוח?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'נוסף ל‑$dashboard';
  }

  @override
  String get deviceLinkQuality => 'איכות קישור';

  @override
  String get deviceLinkGood => 'טוב';

  @override
  String get devicePowerSource => 'מקור מתח';

  @override
  String get devicePowerBattery => 'סוללה';

  @override
  String get devicePowerMains => 'חשמל';

  @override
  String get deviceLastHeard => 'נשמע לאחרונה';

  @override
  String get deviceAvailability => 'זמינות';

  @override
  String get deviceAvailabilityOff => 'כבויה ב‑Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'מדיניות פרטיות';

  @override
  String get settingsPrivacySubtitle => 'בלי טלמטריה. הכול נשאר בטלפון הזה.';

  @override
  String get homeCurrent => 'הבית הנוכחי';

  @override
  String get homeConnection => 'חיבור';

  @override
  String get homeSwitchTo => 'מעבר לבית הזה';

  @override
  String get homeDelete => 'מחיקת הבית';

  @override
  String get devicesSelect => 'בחרו מכשיר';

  @override
  String get scenesSelect => 'בחרו סצנה לעריכה';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'בחירת מכשיר';

  @override
  String get panelFormStateTopic => 'topic מצב';

  @override
  String get panelFormCommandTopic => 'topic פקודה';

  @override
  String get panelFormCommandTopicDerived =>
      'ממולא מ‑topic המצב עד שתשנו אותו.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'מקושר ל‑$device';
  }

  @override
  String get panelFormOpenDevice => 'פתיחת המכשיר';

  @override
  String get panelFormUnlink => 'ביטול קישור';

  @override
  String get panelFormValueChoices => 'ערכים מהמכשיר הזה';

  @override
  String get panelFormAdvanced => 'מתקדם';

  @override
  String get panelFormAdvancedSubtitle => 'עקיפת קידומת, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'ריק = הקידומת עצמה (המצב של מכשיר Zigbee2MQTT).';

  @override
  String get dashWallDisplay => 'תצוגת קיר';

  @override
  String get dashWallDisplayOn =>
      'תצוגת קיר פעילה: המסך נשאר דולק, והסרגלים נעלמים אחרי 10 שניות בלי מגע. הקשה מחזירה אותם.';

  @override
  String get dashWallDisplayOff => 'תצוגת קיר כבויה.';

  @override
  String get analyticsSetupCheckbox =>
      'שיתוף נתוני שימוש אנונימיים לשיפור ההגדרה';

  @override
  String get analyticsWhatsShared => 'מה משותף';

  @override
  String get analyticsCardTitle => 'לעזור לשפר את ZigDash?';

  @override
  String get analyticsCardBody =>
      'שיתוף נתוני שימוש אנונימיים: אילו שלבי הגדרה נכשלים ובאילו תכונות משתמשים. אף פעם לא המכשירים, הנושאים או הברוקר שלך.';

  @override
  String get analyticsShare => 'שיתוף';

  @override
  String get analyticsNoThanks => 'לא תודה';

  @override
  String get settingsAnalytics => 'שיתוף נתוני שימוש אנונימיים';

  @override
  String get settingsAnalyticsSubtitle =>
      'שלבי הגדרה ותכונות בשימוש. אף פעם לא המכשירים, הנושאים או הברוקר שלך.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'נתוני שימוש אנונימיים רק אם בחרת בכך.';

  @override
  String get dashDefaultName => 'בית';

  @override
  String get dashExportSaveFile => 'שמירת קובץ';

  @override
  String get dashExportSaved => 'הגיבוי נשמר';

  @override
  String get dashImportChooseFile => 'בחירת קובץ';

  @override
  String get dashImportFileUnreadable => 'לא ניתן לקרוא את הקובץ';
}
