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
  String get connUsername => 'שם משתמש';

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
  String get dashFormLock => 'נעילת עריכה';

  @override
  String get dashFormLockSubtitle => 'מסתיר את העריכה בלוח הזה';

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
  String get reportProblemEmailPrompt => 'מה קרה, ומה ציפיתם שיקרה?';

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
  String get scenesAllShutters => 'כל התריסים';

  @override
  String get sceneCloseAllShutters => 'סגירת כל התריסים';

  @override
  String get sceneOpenAllShutters => 'פתיחת כל התריסים';

  @override
  String get sceneStopAllShutters => 'עצירת כל התריסים';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count תריסים',
      one: 'תריס אחד',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'אילו תריסים…';

  @override
  String get sceneWhichShuttersHint =>
      'כל התריסים בבית הזה כלולים. בטלו את הסימון של מה שצריך להישאר בחוץ, למשל דלת מוסך.';

  @override
  String get scenesYours => 'הסצנות שלך';

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
      'הברוקר לא קיבל את החיבור. בדקו שברוקר ה‑MQTT שלכם (בדרך כלל Mosquitto) פועל ומקבל חיבורים ממכשירים אחרים, ושהכתובת והיציאה (בדרך כלל 1883) נכונות.';

  @override
  String get diagTcpTimeout =>
      'החיבור לברוקר עבר את גבול הזמן. ייתכן שהוא לא זמין או מחוץ לרשת.';

  @override
  String get diagConnackFail =>
      'הברוקר לא השלים את לחיצת היד של MQTT. ודאו שזה ברוקר MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'הברוקר לא ענה להתחברות בזמן. ל-Home Assistant לוקח לפעמים כמה שניות לבדוק אותה, נסו שוב.';

  @override
  String get diagAuthRejected =>
      'הברוקר דחה את שם המשתמש או הסיסמה. בדקו את פרטי ההתחברות.';

  @override
  String get diagAuthRefused => 'הברוקר סירב לחיבור. בדקו את הגדרות החיבור.';

  @override
  String get diagResolveLocalName =>
      'הטלפון לא מצא את השם הזה. אנדרואיד לרוב לא מזהה שמות שמסתיימים ב‑.local, אז הזינו את כתובת ה‑IP במקום (Home Assistant מציג אותה תחת הגדרות › מערכת › רשת).';

  @override
  String get diagTcpHaNoBroker =>
      'זה ה‑Home Assistant שלכם, אבל לא פועל בו ברוקר MQTT. התקינו והפעילו את התוסף Mosquitto broker (הגדרות › תוספים), ונסו שוב.';

  @override
  String get diagTcpSmlightClosed =>
      'זה ה‑hub של SMLIGHT שלכם, אבל ברוקר ה‑MQTT שלו לא מקבל חיבורים ממכשירים אחרים. בדף האינטרנט של ה‑hub פתחו Settings › MQTT, הפעילו Allow External, שמרו ונסו שוב.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Zigbee2MQTT רץ בכתובת הזו, אבל מגיע לברוקר שלו דרך שם אחר (ראו Zigbee2MQTT › Settings › MQTT › Server). אם זה מחשב אחר, הקלידו את הכתובת שלו, בדרך כלל עם פורט 1883. אם זה קונטיינר על המחשב הזה, פרסמו את הפורט שלו (ports: \"1883:1883\") ואפשרו לו להאזין לרשת, ואז נסו שוב.';

  @override
  String get diagTcpZ2mNoBroker =>
      'בכתובת הזו פועל Zigbee2MQTT, אבל ברוקר ה‑MQTT שלו לא מקבל חיבורים ממכשירים אחרים. Mosquitto מאזין רק במחשב שלו עד שמוסיפים לקובץ mosquitto.conf את השורות \"listener 1883\" ו‑\"allow_anonymous true\" (או מגדירים סיסמה). הפעילו מחדש את Mosquitto ונסו שוב.';

  @override
  String get diagAuthRejectedHa =>
      'הברוקר של Home Assistant דחה את ההתחברות. השתמשו בשם ובסיסמה של משתמש Home Assistant (הגדרות › אנשים › משתמשים); הכי טוב משתמש נפרד רק ל‑MQTT.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נמצאו $count מכשירים',
      one: 'נמצא מכשיר אחד',
    );
    return '$_temp0';
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
  String get guidedStuckTitle => 'נתקעתם? שאלו אדם';

  @override
  String get guidedStuckBody =>
      'שני ניסיונות בלי חיבור. ספרו לנו איזו רכזת יש לכם ומה הקלדתם, ונעזור למצוא אותה.';

  @override
  String get guidedStuckTelegram => 'לשאול בטלגרם';

  @override
  String get guidedStuckHelp => 'טיפים ואימייל';

  @override
  String ladderTriedHint(Object count) {
    return 'נוסו $count כתובות';
  }

  @override
  String get guidedSaveFailed => 'לא ניתן היה לשמור את החיבור. נסו שוב.';

  @override
  String get setupWelcomeTitle => 'ברוכים הבאים ל-ZigDash';

  @override
  String get setupWelcomeHeadline => 'בית ה-Zigbee שלך, בטלפון';

  @override
  String get setupWelcomeBody =>
      'כל מה שצריך הוא רכזת קטנה שמריצה Zigbee2MQTT: רכזת SMLIGHT, ‏Raspberry Pi או כל מחשב Linux. לא צריך Home Assistant, ואם יש לך, ZigDash עובד גם איתו. הכול נשאר מקומי, בלי ענן.';

  @override
  String get setupFindMySetup => 'מצאו את ההתקנה שלי';

  @override
  String get setupErrPageTitle => 'דף ה-Zigbee2MQTT לא ענה';

  @override
  String get setupErrPageBody =>
      'אף דף Zigbee2MQTT לא ענה בכתובת הזו. פתחו אותה בדפדפן של הטלפון כדי לבדוק, והעתיקו את הכתובת בדיוק (עם הפורט, לרוב 8080). אם הדף מבקש טוקן, הזינו במקום זאת את פרטי הברוקר.';

  @override
  String get setupErrPageAction => 'לנסות שוב';

  @override
  String get setupLookWider => 'חיפוש בכל הרשת';

  @override
  String get setupAsk => 'מה מריץ את ה-Zigbee שלכם?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'על Raspberry Pi, שרת או Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'עם התוסף Zigbee2MQTT, או ZHA';

  @override
  String get setupAskSmlight => 'רכזת SMLIGHT';

  @override
  String get setupAskSmlightSub => 'SLZB או SMHUB עם Zigbee2MQTT';

  @override
  String get setupAskNothing => 'עוד אין כלום?';

  @override
  String get setupAskHaWhich => 'איך ה-Home Assistant שלכם מריץ Zigbee?';

  @override
  String get setupAskHaZ2m => 'התוסף Zigbee2MQTT';

  @override
  String get setupAskHaZ2mSub => 'התחברות עם Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, ה-Zigbee המובנה של Home Assistant';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, בלי Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'התחברות לדף ה-Zigbee2MQTT שלי';

  @override
  String get setupManualEntryAdvanced => 'פרטי ברוקר (מתקדם)';

  @override
  String get z2mPageTitle => 'דף ה-Zigbee2MQTT שלכם';

  @override
  String get z2mPageBody =>
      'הכתובת בדפדפן כשדף ה-Zigbee2MQTT פתוח, זה שבו אתם מצמידים מכשירים. לא צריך שם משתמש או סיסמה של MQTT.';

  @override
  String get z2mPageLabel => 'כתובת הדף';

  @override
  String get z2mPageConnect => 'התחברות';

  @override
  String z2mPageFoundName(String host, String ip) {
    return '$host נמצא בכתובת $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'אף אחד לא ענה עבור $host ברשת הזו';
  }

  @override
  String get engineNeedsBrokerTitle => 'אוטומציות צריכות את ברוקר ה-MQTT שלכם';

  @override
  String get engineNeedsBrokerBody =>
      'הבית הזה מתחבר דרך דף ה-Zigbee2MQTT, וזה מספיק ללוחות שלכם. אוטומציות, התראות והיסטוריה רצות ב-ZigDash Engine שעל הרכזת, שמדבר דרך ברוקר ה-MQTT. הוסיפו את פרטיו פעם אחת, ומאז ZigDash יתחבר דרך הברוקר.';

  @override
  String get engineNeedsBrokerButton => 'הוספת פרטי ברוקר';

  @override
  String get connFromPageNote =>
      'הבית הזה מתחבר דרך דף ה-Zigbee2MQTT. הזינו את ברוקר ה-MQTT שלכם (בדרך כלל אותו מחשב, פורט 1883) כדי להפעיל אוטומציות, התראות והיסטוריה. אחרי השמירה ZigDash מתחבר דרך הברוקר.';

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
  String get reminderButton => 'תזכירו לי מחר';

  @override
  String get reminderSet => 'נזכיר לכם מחר, בטלפון הזה.';

  @override
  String get reminderNoPermission =>
      'ההתראות של ZigDash כבויות, ולכן לא תהיה תזכורת. אפשר להפעיל אותן בהגדרות של Android.';

  @override
  String get reminderChannel => 'תזכורת להגדרה';

  @override
  String get reminderTitle => 'סיימו להגדיר את ZigDash';

  @override
  String get reminderBody =>
      'בבית, ברשת ה-Wi-Fi שלכם? הקישו כדי לנסות שוב: זה לוקח בערך דקה.';

  @override
  String get setupWelcomeNoZ2m => 'עדיין אין Zigbee2MQTT?';

  @override
  String get setupWelcomeDemo => 'לנסות את בית ההדגמה';

  @override
  String get setupWelcomeHubs => 'איזו רכזת לבחור';

  @override
  String get haConnectTitle => 'התחברות דרך Home Assistant';

  @override
  String get haConnectIntro =>
      'הטלפון לא מגיע לברוקר, אבל כן מגיע ל-Home Assistant. היכנסו פעם אחת, ו-ZigDash ידבר עם Zigbee2MQTT דרך Home Assistant: בבית או בחוץ, בלי הגדרות ברוקר.';

  @override
  String get haConnectAddressHelp =>
      'הכתובת שאיתה אתם פותחים את Home Assistant: 192.168.1.20:8123, או כתובת מרוחקת כמו כתובת Nabu Casa או Cloudflare שלכם';

  @override
  String get haConnectSignInHelp =>
      'דף הכניסה של Home Assistant עצמו נפתח בדפדפן. ZigDash לעולם לא רואה את הסיסמה שלכם.';

  @override
  String get haConnectKeeps =>
      'ZigDash שומר את הכניסה הזו בטלפון ופועל בשמכם ב-Home Assistant, ל-MQTT בלבד. אפשר לסיים זאת בכל עת ב-Home Assistant, תחת פרופיל › אבטחה.';

  @override
  String get haConnectTokenHelp =>
      'ב-Home Assistant פתחו את הפרופיל שלכם, ואז אבטחה › אסימוני גישה ארוכי טווח › יצירת אסימון. העתיקו והדביקו אותו כאן. ZigDash שומר אותו בטלפון הזה כדי להתחבר; מחקו אותו ב-Home Assistant כשתרצו לסיים.';

  @override
  String get haConnectWithToken => 'התחברות עם אסימון';

  @override
  String get haConnectChecking => 'בודק את Home Assistant…';

  @override
  String get setupStillChecking => 'עדיין בודקים. זה יכול לקחת עד 30 שניות.';

  @override
  String get aiHelpTitle => 'נתקעתם? שאלו את עוזר ה-AI שלכם';

  @override
  String get aiHelpBody =>
      'ZigDash מסכם את מה שמצא עבור ChatGPT, Claude, Gemini או כל אפליקציית AI, בלי סיסמאות או כתובות. תראו את הטקסט לפני השיתוף.';

  @override
  String get aiHelpButton => 'שאלו AI';

  @override
  String get aiHelpPreviewTitle => 'מה ישותף';

  @override
  String get aiHelpShare => 'שיתוף לאפליקציית AI';

  @override
  String get aiHelpCopied => 'הועתק. הדביקו בכל צ\'אט AI.';

  @override
  String get haConnectWhereAddress =>
      'לא בטוחים מה הכתובת? באפליקציית Home Assistant פתחו הגדרות › אפליקציה נלווית והקישו על השרת שלכם: הכתובת מופיעה שם. במחשב, זו הכתובת שהדפדפן מציג כש-Home Assistant פתוח.';

  @override
  String get haFindLooking => 'מחפש את Home Assistant ברשת הזו…';

  @override
  String get haFindSeveral =>
      'נמצא יותר מ-Home Assistant אחד. הקש על זה שבו להשתמש:';

  @override
  String get haFindNone =>
      'הטלפון הזה לא רואה את Home Assistant ברשת ה-Wi-Fi הזו. השתמשו בכתובת שאפליקציית Home Assistant שלכם פותחת: לרוב כתובת מרוחקת, כמו https://abcd1234.ui.nabu.casa או https://myhome.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'הכתובת הזו נמצאת ברשת אחרת מזו של הטלפון, שנמצא ב-$network. השתמשו בכתובת שאפליקציית Home Assistant שלכם פותחת, לרוב כתובת מרוחקת, או חברו את הטלפון לרשת שבה נמצא Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'הטלפון לא מצא את השם הזה: אנדרואיד לרוב לא פותח שמות ‎.local. הקלידו את כתובת ה-IP של Home Assistant (למשל 192.168.1.20:8123), או את הכתובת המרוחקת שלו.';

  @override
  String get haConnectRemoteUnreachable =>
      'אף אחד לא ענה בכתובת המרוחקת הזו. פתחו אותה בדפדפן של הטלפון כדי לבדוק שהיא עובדת, והעתיקו אותה בדיוק כפי שאפליקציית Home Assistant מציגה אותה.';

  @override
  String get setupNoWifiHa => 'משתמש ב-Home Assistant? התחבר';

  @override
  String get haConnectNotAdmin =>
      'המשתמש שלכם ב-Home Assistant אינו מנהל. ZigDash צריך מנהל בשביל ה-MQTT של Home Assistant. היכנסו כמנהל, או הדביקו אסימון שמנהל יצר.';

  @override
  String get haConnectNoMqtt =>
      'ל-Home Assistant הזה אין אינטגרציית MQTT. גם Zigbee2MQTT צריך אותה: ב-Home Assistant הוסיפו את התוסף Mosquitto broker ואת אינטגרציית MQTT, ואז נסו שוב.';

  @override
  String get haConnectSignInFailed =>
      'הכניסה לא הושלמה. נסו שוב, או השתמשו באסימון ארוך טווח.';

  @override
  String get setupHaShortcut =>
      'Zigbee2MQTT רץ בתוך Home Assistant? אפשר לדלג על הברוקר ועל ההתחברות אליו: היכנסו עם חשבון המנהל שלכם ב-Home Assistant. זה עובד מכל רשת.';

  @override
  String get haConnectButton => 'התחברות דרך Home Assistant';

  @override
  String get haConnectManualLink =>
      'משתמשים ב-Home Assistant? התחברו דרכו במקום';

  @override
  String get haConnectEmptyNote =>
      'הטלפון הזה לא מגיע לברוקר? Home Assistant יכול לשאת את החיבור בשבילכם.';

  @override
  String get haHomeConnected => 'מחובר דרך Home Assistant';

  @override
  String get haHomeChange =>
      'אם הכניסה מפסיקה לעבוד, בטלפון חדש או אחרי שהסרתם את האסימון ב-Home Assistant, היכנסו שוב כאן. אפשר גם לסיים אותה ב-Home Assistant תחת פרופיל › אבטחה.';

  @override
  String get haHomeSignInAgain => 'כניסה מחדש';

  @override
  String get haHomeRemote => 'כתובת מרוחקת של Home Assistant (לא חובה)';

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
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT כבר מתחבר לברוקר הזה: בדף הווב שלו, תחת Settings › MQTT, מופיע שם המשתמש. השתמשו במשתמש הזה ובסיסמה שלו.';

  @override
  String get setupAuthWhich =>
      'זו ההתחברות ל‑MQTT, לא הסיסמה של דף הווב של ה‑hub.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: השתמשו במשתמש של Home Assistant. רוב האנשים יוצרים אחד רק ל‑MQTT תחת הגדרות › אנשים › משתמשים, והתוסף Mosquitto מקבל אותו.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi או Docker: שם המשתמש והסיסמה מקובץ הסיסמאות של Mosquitto, אותם ערכים שב‑configuration.yaml של Zigbee2MQTT תחת mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: ההתחברות שמופיעה בדף הווב של ה‑hub תחת Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'בודק את החיבור…';

  @override
  String get setupReviewTitle => 'המכשירים שלך';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נמצאו $count מכשירים.',
      one: 'נמצא מכשיר אחד.',
    );
    return '$_temp0 בחרו מה ייכנס ללוח הראשון.';
  }

  @override
  String get setupReviewLastStep =>
      'שלב אחרון: סמנו את המכשירים שאתם רוצים, ואז הקישו על יצירת לוח בקרה למטה.';

  @override
  String get setupLeaveTitle => 'ליצור את לוח הבקרה?';

  @override
  String get setupLeaveBody =>
      'המכשירים שלכם נמצאו. צרו את לוח הבקרה עכשיו, או התחילו את ההגדרה מחדש ותאבדו את הרשימה הזו.';

  @override
  String get setupStartOver => 'להתחיל מחדש';

  @override
  String setupCreateWithCount(Object count) {
    return 'צרו לוח עם $count';
  }

  @override
  String get setupReviewNoneSelected =>
      'עדיין לא סומן דבר. סמנו את המכשירים שתרצו בלוח, או צרו אותו ריק והוסיפו אריחים אחר כך.';

  @override
  String get setupCreateEmpty => 'צרו לוח ריק';

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
  String get setupErrListMissingTitle => 'Zigbee2MQTT לא שלח את רשימת המכשירים';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT עונה, אבל רשימת המכשירים שלו לא הגיעה. זה קורה בדרך כלל אחרי הפעלה מחדש של ברוקר ה-MQTT: גרסאות Zigbee2MQTT לפני 2.14.2 שולחות את הרשימה שוב רק כשהן עצמן מופעלות מחדש. הפעילו מחדש את Zigbee2MQTT (או עדכנו אותו) ונסו שוב.';

  @override
  String get setupErrListMissingAction => 'לנסות שוב';

  @override
  String get setupErrHaNoZ2mTitle => 'אין Zigbee2MQTT ב-Home Assistant הזה';

  @override
  String get setupErrHaNoZ2mBody =>
      'התחברתם ל-Home Assistant, אבל Zigbee2MQTT לא שולח כלום ב-MQTT שלו. אם מכשירי ה-Zigbee שלכם נמצאים ב-ZHA (ה-Zigbee המובנה של Home Assistant), ‏ZigDash לא יכול לראות אותם: הוא עובד עם Zigbee2MQTT. אם אתם משתמשים בתוסף Zigbee2MQTT, פתחו אותו ב-Home Assistant, ודאו שהוא פועל ונסו שוב.';

  @override
  String get setupErrHaNoZ2mAction => 'לנסות שוב';

  @override
  String get setupErrScanFailedTitle => 'אין רשת מקומית';

  @override
  String get setupErrScanFailedBody =>
      'לא ניתן לזהות את הרשת המקומית של מכשיר זה. התחברו ל-Wi-Fi ונסו שוב.';

  @override
  String get setupErrScanFailedAction => 'נסו שוב';

  @override
  String get setupNoWifiTitle => 'הטלפון לא מחובר ל-Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'הוא משתמש בנתונים סלולריים, ולכן לא רואה את המכשירים בבית. הפעילו Wi-Fi והתחברו לרשת הביתית: ההגדרה תתחיל מחדש מעצמה.';

  @override
  String get setupNoWifiOffline =>
      'לטלפון אין חיבור לרשת. הפעילו Wi-Fi והתחברו לרשת הביתית: ההגדרה תתחיל מחדש מעצמה.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash לא מוצא את כתובת ה-Wi-Fi של הטלפון. ודאו שה-Wi-Fi פועל ומחובר לרשת הביתית: ההגדרה תתחיל מחדש מעצמה. מחוברים ל-VPN או מחוץ לבית? הזינו את הפרטים ידנית.';

  @override
  String get setupOpenWifiSettings => 'פתיחת הגדרות Wi-Fi';

  @override
  String get setupWaitingForWifi => 'ממתין ל-Wi-Fi…';

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
  String get setupErrLoginNoAnswerTitle => 'הברוקר לא ענה להתחברות';

  @override
  String get setupErrLoginNoAnswerBody =>
      'הברוקר שלכם נמצא, אבל הוא לא ענה לשם המשתמש והסיסמה בזמן. תוסף Mosquitto של Home Assistant בודק התחברויות מול Home Assistant, וב-Raspberry Pi זה יכול לקחת כמה שניות. נסו שוב, ובדקו שהמשתמש הזה קיים ב-Home Assistant.';

  @override
  String get setupErrLoginNoAnswerAction => 'לנסות שוב';

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
  String get setupPlatformQuestion => 'בזמן החיפוש: איפה Zigbee2MQTT פועל?';

  @override
  String get setupPlatformQuestionDone => 'איפה Zigbee2MQTT פועל?';

  @override
  String get setupScanDoneTitle => 'בחרו חיבור';

  @override
  String get setupScanDoneHint =>
      'יותר מברוקר אחד ענה. בחרו את זה ש‑Zigbee2MQTT משתמש בו.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'רכזת SMLIGHT';

  @override
  String get setupPlatformPi => 'Raspberry Pi או Docker';

  @override
  String get setupPlatformZha => 'ZHA, בלי Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash מציג מכשירים מ‑Zigbee2MQTT, ולכן הוא לא רואה מכשירים ב‑ZHA, ה‑Zigbee המובנה של Home Assistant. אפשר לנסות את בית ההדגמה כדי לראות איך ZigDash עובד.';

  @override
  String get setupPlatformNotSure => 'לא בטוח';

  @override
  String setupScanProgress(int checked, int total) {
    return 'נבדקו $checked מתוך $total כתובות';
  }

  @override
  String get setupScanHintHa =>
      'מחפשים את Home Assistant ואת ה-MQTT broker שלו…';

  @override
  String get setupScanHintSmlight => 'מחפשים את רכזת ה-SMLIGHT שלכם…';

  @override
  String get setupScanHintPi => 'מחפשים MQTT broker ברשת שלכם…';

  @override
  String setupHubSeenHa(String host) {
    return 'נמצא Home Assistant בכתובת $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'נמצא Zigbee2MQTT בכתובת $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'נמצאה רכזת SMLIGHT בכתובת $host';
  }

  @override
  String get setupHubSeenHint => 'עדיין מחפשים את ה-MQTT broker שלו…';

  @override
  String get setupNoBrokerHaTitle => 'נמצא Home Assistant, אבל אין MQTT broker';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant נמצא בכתובת $host, אבל שום דבר לא עונה בפורט MQTT 1883. ב-Home Assistant פתחו הגדרות › תוספים, התקינו והפעילו את התוסף Mosquitto broker ונסו שוב.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'משתמשים ב-Zigbee המובנה של Home Assistant ‏(ZHA) במקום Zigbee2MQTT? ZigDash עובד רק עם Zigbee2MQTT, ולכן לא רואה מכשירי ZHA. ההדגמה מראה מה הייתם מקבלים.';

  @override
  String get setupVpnHint =>
      'VPN פועל, והוא יכול להסתיר את הרשת הביתית מהסריקה. אם אתם בבית, כבו את ה-VPN והקישו על נסו שוב. או השאירו אותו פועל ואפשרו גישה לרשת המקומית (LAN) בהגדרות אפליקציית ה-VPN.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'נמצא Zigbee2MQTT, אבל אי אפשר להגיע ל-broker שלו';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT נמצא בכתובת $host, אבל ה-MQTT broker שלו לא מקבל חיבורים מהטלפון. Mosquitto 2 מאזין רק ברכזת עצמה עד שבקובץ ההגדרות יופיעו \'listener 1883\' ו-\'allow_anonymous true\' (או פרטי התחברות). הפעילו אותו מחדש ונסו שוב.';
  }

  @override
  String get setupNoBrokerSmlightTitle => 'נמצאה רכזת SMLIGHT, אבל MQTT כבוי';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'הרכזת נמצאת בכתובת $host, אבל אי אפשר להגיע ל-MQTT broker שלה. בממשק הווב של הרכזת פתחו Settings › MQTT, הפעילו Allow External ובדקו ש-Zigbee2MQTT פועל. אחר כך נסו שוב.';
  }

  @override
  String get setupZ2mAsking => 'שואלים את Zigbee2MQTT איפה ה-broker שלו…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'ה-broker שלכם מקבל חיבורים רק מהמכשיר שעליו הוא רץ';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT משתמש ב-$server, ומהטלפון שלכם שום דבר לא עונה שם. כך Mosquitto 2 מתנהג כברירת מחדל. הוסיפו את שתי השורות האלה ל-mosquitto.conf, הפעילו מחדש את Mosquitto ונסו שוב:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'מעדיפים התחברות עם סיסמה במקום גישה פתוחה? השתמשו ב-password_file במקום allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT מגיע לברוקר שלו דרך שם שהטלפון שלכם לא יכול להשתמש בו';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT משתמש ב־$server. \"$name\" הוא שם שרק המחשב של Zigbee2MQTT מכיר, שירות Docker או שם מארח. הקלידו במקומו את כתובת ה־IP של מחשב הברוקר עם פורט $port. אם הברוקר רץ בקונטיינר, הפורט שלו חייב להיות מפורסם גם על המחשב (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'עמוד האינטרנט של Zigbee2MQTT מוגן בטוקן, ולכן האפליקציה לא הצליחה לקרוא היכן הברוקר שלו. הקלידו את כתובת הברוקר מתוך Zigbee2MQTT › Settings › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT משתמש ב-broker בכתובת $server, אבל הוא לא ענה לטלפון שלכם. בדקו שה-broker פועל ושהטלפון באותה רשת.';
  }

  @override
  String setupConnectTo(String host) {
    return 'התחברות אל $host';
  }

  @override
  String get setupNotFoundHa =>
      'לא נמצא Home Assistant ברשת הזו. ודאו שהטלפון מחובר לאותה רשת Wi-Fi כמו Home Assistant (לא רשת אורחים), ונסו שוב. אם אתם יודעים את הכתובת, הזינו אותה למטה.';

  @override
  String get setupNotFoundSmlight =>
      'לא נמצא hub של SMLIGHT ברשת הזו. ודאו שה‑hub דולק ושהטלפון מחובר לאותה רשת Wi-Fi, ונסו שוב. אם אתם יודעים את הכתובת, הזינו אותה למטה.';

  @override
  String get setupNotFoundPi =>
      'לא נמצא MQTT broker ברשת הזו. בדקו ש-Mosquitto פועל ומאזין ברשת (פורט 1883) ושהטלפון מחובר לאותו Wi-Fi. אחר כך נסו שוב.';

  @override
  String get setupAddressQuestionHa => 'איפה אתם פותחים את Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'מה הכתובת של ה‑hub של SMLIGHT שלכם?';

  @override
  String get setupAddressQuestionPi => 'מה הכתובת של המחשב שמריץ את Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      'מה הכתובת של ה‑hub שלכם, או של המחשב שמריץ את Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'כתובת כמו 192.168.1.20, שם, או הקישור מהדפדפן שלכם';

  @override
  String get setupAddressCheck => 'לבדוק את הכתובת הזו';

  @override
  String setupAddressNothing(String host) {
    return 'שום דבר לא ענה בכתובת $host. בדקו את הכתובת, ושהטלפון מחובר לאותה רשת Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return 'לא ניתן היה לפענח את $host. שמות שמסתיימים ב‑.local נכשלים לעיתים קרובות באנדרואיד; נסו את כתובת ה‑IP במקום. Home Assistant מציג אותה תחת הגדרות › מערכת › רשת.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return 'לא ניתן למצוא את $host מהטלפון הזה; אנדרואיד לרוב לא מצליח לפענח שמות ‎.local. הקישו על $button למעלה והשתמשו בכתובת שבה אתם פותחים את Home Assistant בדפדפן, או הקלידו כאן את כתובת ה‑IP שלו. Home Assistant מציג אותה תחת הגדרות › מערכת › רשת.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host אינו ברשת הביתית שלכם. השתמשו בכתובת שעובדת ב‑Wi-Fi שלכם, לא בקישור מרוחק כמו Nabu Casa או DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'קודם הזינו כתובת.';

  @override
  String get setupChoicesTitle => 'מה מהבאים מתאים לכם?';

  @override
  String get setupChoiceNoHub => 'עדיין אין לי רכזת';

  @override
  String get setupChoiceNoHubSub => 'הצגת רכזות קטנות שמריצות Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'יש לי Home Assistant';

  @override
  String get setupChoiceHaSub => 'חיפוש בכתובת homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash מתחבר לשרת ה-MQTT של Home Assistant, התוסף Mosquitto broker תחת הגדרות › תוספים, וגם Zigbee2MQTT צריך להשתמש בו. אם homeassistant.local לא נמצא, הזינו למטה את כתובת ה‑IP של Home Assistant. היא מופיעה תחת הגדרות › מערכת › רשת.';

  @override
  String get setupChoiceOther => 'הרכזת שלי ברשת אחרת';

  @override
  String get setupChoiceOtherSub => 'Wi-Fi לאורחים או נתב שני';

  @override
  String get setupChoiceOtherNote =>
      'הטלפון צריך להגיע לרכזת. Wi-Fi לאורחים, או נתב שני עם Wi-Fi משלו, מפריד ביניהם. התחברו ל-Wi-Fi שהרכזת נמצאת בו והקישו על נסו שוב. אפשר גם להזין למטה את כתובת ה‑IP של הרכזת, או לנסות אחד מהשמות המקובלים האלה:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'הטלפון שלכם הוא $ip, אז הרכזת מתחילה בדרך כלל ב-$prefix.';
  }

  @override
  String get guidedHostHa =>
      'משתמשים ב-Home Assistant? המארח הוא הכתובת שבה אתם פותחים את Home Assistant, פורט 1883.';

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
  String get readingShowAs => 'הצגה כ';

  @override
  String get readingStyleValue => 'ערך';

  @override
  String get readingStyleGauge => 'מד';

  @override
  String get gaugeBands => 'טווחי צבע';

  @override
  String get gaugeBandsHelper => 'עד שלושה. הטווח שבו נמצא הערך צובע את הקשת.';

  @override
  String get gaugeBandFrom => 'מ';

  @override
  String get gaugeBandTo => 'עד';

  @override
  String get gaugeBandAdd => 'הוספת טווח';

  @override
  String get gaugeBandRemove => 'הסרת טווח';

  @override
  String get gaugeToneNormal => 'רגיל';

  @override
  String get gaugeToneGood => 'תקין';

  @override
  String get gaugeToneAttention => 'שימו לב';

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
      'נתוני שימוש אנונימיים. אפשר לכבות במתג שלמעלה.';

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

  @override
  String get getHelpTitle => 'קבלת עזרה';

  @override
  String get getHelpTryFirst => 'נסו קודם את אלה';

  @override
  String get getHelpPromise =>
      'עדיין תקועים? בדרך כלל אני עונה תוך 3 ימים, באנגלית או בעברית. לעולם לא אבקש את הסיסמאות שלכם.';

  @override
  String get getHelpIncluded => 'מה נכלל';

  @override
  String get getHelpContact => 'פנייה לתמיכה';

  @override
  String get getHelpCopy => 'העתקת הפרטים';

  @override
  String get getHelpCopied => 'הפרטים הועתקו';

  @override
  String get getHelpLink => 'עדיין תקועים? קבלו עזרה';

  @override
  String get getHelpEmailSubject => 'ZigDash: עזרה בהפעלה';

  @override
  String get getHelpEmailPrompt => 'מה ניסיתם לעשות, ומה קרה?';

  @override
  String get settingsHelpSupport => 'עזרה ותמיכה';

  @override
  String get settingsGetHelp => 'קבלת עזרה';

  @override
  String get settingsGetHelpSubtitle =>
      'לא מצליחים להפעיל? קודם טיפים, אחר כך פנייה';

  @override
  String get settingsCommunity => 'הצטרפו לקהילת ZigDash';

  @override
  String get settingsCommunitySubtitle =>
      'קבוצת טלגרם: שאלות, רעיונות ומה בדרך';

  @override
  String get getHelpCommunity => 'לשאול בקבוצת הטלגרם';

  @override
  String get demoBannerHelp => 'קבלת עזרה';

  @override
  String get tipSameWifiTitle => 'אותה רשת Wi-Fi כמו ההאב';

  @override
  String get tipSameWifiBody =>
      'הטלפון חייב להיות באותה רשת כמו ההאב, לא ברשת אורחים. כבו את הנתונים הסלולריים בזמן ההגדרה.';

  @override
  String get tipBrokerRunningTitle => 'ה‑broker פועל';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: ה‑add-on של Mosquitto הופעל. Raspberry Pi: Mosquitto פועל. SMLIGHT: Settings › MQTT מופעל.';

  @override
  String get tipBrokerAcceptsTitle => 'ה‑broker מקבל את הטלפון';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: הפעילו את Allow External. Mosquitto 2 מקבל חיבורים רק מההאב עצמו, עד שמגדירים אותו להאזין ברשת (פורט 1883).';

  @override
  String get tipMeshTitle => 'רשת Mesh או שני נתבים?';

  @override
  String get tipMeshBody =>
      'אם ההאב מחובר לנתב שני, ייתכן שהטלפון לא יראה אותו. חברו את ההאב לנתב הראשי, או התחברו לפי הכתובת שלו.';

  @override
  String get tipByAddressTitle => 'חיבור לפי כתובת';

  @override
  String get tipByAddressBody =>
      'מצאו את הכתובת של ההאב באפליקציה של הנתב, ואז הקישו על \"הזנת פרטים ידנית\".';

  @override
  String get tipSameNetworkTitle => 'אותה רשת';

  @override
  String get tipSameNetworkBody =>
      'הטלפון וההאב חייבים להיות באותה רשת Wi-Fi. כבו את הנתונים הסלולריים.';

  @override
  String get tipAddressChangedTitle => 'הכתובת השתנתה';

  @override
  String get tipAddressChangedBody =>
      'האב יכול לקבל כתובת חדשה אחרי הפעלה מחדש. בדקו אותה באפליקציה של הנתב, ושריינו אותה שם כדי שלא תשתנה.';

  @override
  String get tipRightPortTitle => 'הפורט הנכון';

  @override
  String get tipRightPortBody =>
      'MQTT הוא בדרך כלל בפורט 1883 (8883 עם TLS). 8080 או 80 הם ממשק הווב של ההאב, לא MQTT.';

  @override
  String get tipStartBrokerTitle => 'ה‑broker פועל';

  @override
  String get tipStartBrokerBody =>
      'הפעילו את Mosquitto או את ה‑add-on של ה‑broker, ונסו שוב.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 מקבל חיבורים רק מההאב עצמו, עד שמגדירים אותו להאזין ברשת (פורט 1883).';

  @override
  String get tipMqttLoginTitle => 'פרטי ההתחברות של MQTT, לא של ממשק הווב';

  @override
  String get tipMqttLoginBody =>
      'הסיסמה של ממשק הווב של ההאב היא בדרך כלל לא הסיסמה של MQTT. ב‑Home Assistant: השתמשו במשתמש של Home Assistant, או בפרטי ההתחברות שהוגדרו ב‑add-on של Mosquitto.';

  @override
  String get tipSpacesTitle => 'בדקו שאין רווחים';

  @override
  String get tipSpacesBody => 'בהעתקת סיסמה עלול להתווסף רווח בסוף.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT משתמש ב‑broker הזה';

  @override
  String get tipZ2mBrokerBody =>
      'בהגדרות של Zigbee2MQTT, ודאו ששרת ה‑MQTT שלו הוא אותו broker.';

  @override
  String get tipBaseTopicTitle => 'נושא בסיס';

  @override
  String get tipBaseTopicBody =>
      'אם שיניתם את נושא הבסיס מ‑\"zigbee2mqtt\", הזינו אותו בהגדרה הידנית.';

  @override
  String get tipPairFirstTitle => 'קודם שייכו מכשירים';

  @override
  String get tipPairFirstBody =>
      'פתחו את ממשק הווב של Zigbee2MQTT ושייכו לפחות מכשיר אחד, ואז בדקו שוב.';

  @override
  String get tipRestartZ2mTitle => 'הפעלה מחדש של Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'אם יש מכשירים משויכים אבל אף אחד לא מגיע, הפעילו מחדש את Zigbee2MQTT כדי שיפרסם את רשימת המכשירים שלו.';

  @override
  String get tipNumberAddressTitle => 'השתמשו בכתובת המספרית';

  @override
  String get tipNumberAddressBody =>
      'שמות שמסתיימים ב‑.local לא עובדים בכל טלפון Android. נסו את הכתובת המספרית של ההאב, למשל 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'פורט ופרוטוקול';

  @override
  String get tipPortProtocolBody =>
      'בדרך כלל זה TCP בפורט 1883. בחרו TLS או WebSocket רק אם ה‑broker מוגדר לכך.';

  @override
  String get tipManualLoginTitle => 'התחברות';

  @override
  String get tipManualLoginBody =>
      'השאירו את שם המשתמש והסיסמה ריקים אם אין ל‑broker כאלה. אחרת השתמשו בפרטי ההתחברות של MQTT, לא של ממשק הווב של ההאב.';

  @override
  String get tipHubOnTitle => 'ההאב דולק?';

  @override
  String get tipHubOnBody =>
      'ייתכן שהפסקת חשמל או עדכון הפעילו אותו מחדש. תנו לו דקה אחרי שהוא חוזר.';

  @override
  String get tipAwayTitle => 'אתם בבית?';

  @override
  String get tipAwayBody =>
      'מחוץ לבית, האפליקציה צריכה כתובת מרוחקת (למשל Tailscale). הגדירו אותה בהגדרות החיבור של הבית.';

  @override
  String get tipTailscaleIpTitle => 'השתמשו ב-IP של Tailscale, לא בשם';

  @override
  String get tipTailscaleIpBody =>
      'שמות שמסתיימים ב-.ts.net לעיתים קרובות לא נפתרים בתוך אפליקציות. פתחו את אפליקציית Tailscale בטלפון וודאו שהיא מחוברת, ואז השתמשו בכתובת 100.x.y.z של הרכזת כמארח מרוחק.';

  @override
  String get tipHomeAddressChangedTitle => 'הכתובת השתנתה?';

  @override
  String get tipHomeAddressChangedBody =>
      'אחרי הפעלה מחדש של הנתב, ההאב עלול לקבל כתובת חדשה. שריינו את הכתובת שלו באפליקציה של הנתב, ואז עדכנו את הבית.';

  @override
  String get tipRestartZ2mButtonTitle => 'הפעלה מחדש של Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'אם ה‑broker הופעל מחדש, רשימת המכשירים של Zigbee2MQTT חסרה עד ש‑Zigbee2MQTT מופעל מחדש. השתמשו בכפתור \"הפעלה מחדש של Zigbee2MQTT\" בלשונית \"מכשירים\".';

  @override
  String get tipZ2mRunningTitle => 'Zigbee2MQTT פועל?';

  @override
  String get tipZ2mRunningBody =>
      'פתחו את ממשק הווב שלו. אם הוא לא נטען, הפעילו אותו מחדש בהאב.';

  @override
  String get tipCantConnectTitle => 'אין חיבור להאב שלי';

  @override
  String get tipCantConnectBody =>
      'אותה רשת Wi-Fi, ה‑broker פועל, Allow External מופעל או ש‑Mosquitto מאזין ברשת, ואז חיבור לפי כתובת.';

  @override
  String get tipDeviceWrongTitle => 'מכשיר מוצג לא נכון או לא מגיב';

  @override
  String get tipDeviceWrongBody =>
      'בדקו אותו קודם בממשק הווב של Zigbee2MQTT. אם שם הוא עובד, השתמשו ב\"דיווח על בעיה\".';

  @override
  String get tipHowDoITitle => 'איך עושים…';

  @override
  String get tipHowDoIBody =>
      'סצנות, תצוגת קיר, תזמונים וגיבויים נמצאים ב\"עזרה ומדריך\".';

  @override
  String get tipRenameHomeTitle => 'שינוי שם של בית';

  @override
  String get tipRenameHomeBody =>
      'בית שנקרא על שם הכתובת שלו? הגדרות › בתים, הקישו על הבית ואז על שם.';

  @override
  String get tipWhatYouNeedTitle => 'מה צריך';

  @override
  String get tipWhatYouNeedBody =>
      'רכזת קטנה שמריצה Zigbee2MQTT ו-broker של MQTT ‏(Mosquitto): רכזת SMLIGHT, ‏Raspberry Pi או כל מחשב Linux. גם Home Assistant מתאים, אבל לא חובה.';

  @override
  String get tipSetupAtHomeTitle => 'באותה רשת Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'בצעו את ההגדרה בבית, כשהטלפון באותה רשת Wi-Fi כמו ההאב.';

  @override
  String get tipFindSetupTitle => 'ואז';

  @override
  String get tipFindSetupBody =>
      'צאו מההדגמה והקישו על \"מצאו את ההתקנה שלי\". ZigDash יחפש את ההאב בעצמו.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'לא נמצאה אפליקציית דואר. העתיקו את הפרטים וכתבו אל $email.';
  }

  @override
  String get shortcutWorking => 'פועל…';

  @override
  String get shortcutCantReach => 'אין חיבור לבית';

  @override
  String get shortcutNotConfirmed => 'לא אושר';

  @override
  String get shortcutRemoved => 'הוסר';

  @override
  String get shortcutSceneSent => 'נשלחה';

  @override
  String get shortcutSceneConfirmed => 'אושרה';

  @override
  String get shortcutChooseDevice => 'בחרו מכשיר';

  @override
  String get shortcutChooseScene => 'בחירת סצנה';

  @override
  String get shortcutOpenAppFirstScene => 'פתחו את ZigDash וצרו סצנה קודם.';

  @override
  String get shortcutChooseGroup => 'בחירת קבוצה';

  @override
  String get shortcutPickDevices => 'בחירת מכשירים…';

  @override
  String get shortcutGroupName => 'שם הקבוצה';

  @override
  String get shortcutGroupLimit => 'עד 5 מכשירים ו-3 סצנות';

  @override
  String get shortcutAddTile => 'הוספה להגדרות המהירות';

  @override
  String get shortcutAddShortcut => 'הוספת קיצור דרך';

  @override
  String get shortcutAddToHome => 'הוספה למסך הבית';

  @override
  String get shortcutWidgetHowToTitle => 'הוספת הווידג\'ט';

  @override
  String get shortcutWidgetHowTo =>
      'לחצו לחיצה ארוכה על מקום ריק במסך הבית, הקישו על ווידג\'טים, מצאו את ZigDash וגררו את הווידג\'ט הרצוי.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name נמצא באריח ZigDash $slot בהגדרות המהירות';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name כבר נמצא באריח ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'הוספת האריח';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'פתחו את ההגדרות המהירות (החליקו למטה פעמיים), הקישו על העיפרון לעריכה וגררו את „ZigDash $slot” לאריחים שלכם.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'בחירת מכשיר עבור ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'עדיין אין מכשירים להפעלה. הוסיפו קודם נורה, שקע או תריס ללוח.';

  @override
  String get shortcutSlotsFull =>
      'כל 4 האריחים של ZigDash בשימוש. איזה מהם יציג את המכשיר הזה במקום?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'לא בשימוש';

  @override
  String get deviceRename => 'שינוי שם';

  @override
  String get deviceRenameTitle => 'שינוי שם המכשיר';

  @override
  String get deviceRenameHint => 'שם לחדר או למכשיר, למשל חדר שינה';

  @override
  String deviceRenamed(Object name) {
    return 'השם שונה ל-$name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'לא ניתן לשנות את השם: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT לא ענה';

  @override
  String get shortcutOpenAppFirst => 'פתחו את ZigDash והוסיפו קודם מכשיר ללוח.';

  @override
  String get pollTitle => 'מה ZigDash צריכה לעשות בהמשך?';

  @override
  String get pollBody =>
      'בחרו את מה שהייתם משתמשים בו הכי הרבה. התשובה נשלחת עם נתוני השימוש האנונימיים שלכם.';

  @override
  String get pollNotifications => 'התראות';

  @override
  String get pollHistory => 'גרפים של היסטוריה';

  @override
  String get pollKiosk => 'מצב קיוסק לטאבלט על הקיר';

  @override
  String get pollGroups => 'קבוצות Zigbee';

  @override
  String get pollNotNow => 'לא עכשיו';

  @override
  String get pollThanks => 'תודה! זה עוזר להחליט מה יגיע בהמשך.';

  @override
  String get whyTitle => 'למה ניסיתם את ZigDash?';

  @override
  String get whyBody =>
      'הקשה אחת עוזרת להחליט מה לבנות. התשובה נשלחת עם נתוני השימוש האנונימיים שלכם.';

  @override
  String get whyFaster => 'מהיר יותר מהאפליקציה שהייתה לי';

  @override
  String get whyFamily => 'פשוט לכל המשפחה';

  @override
  String get whyWallTablet => 'טאבלט על הקיר';

  @override
  String get whyWithoutHa => 'עובד בלי Home Assistant';

  @override
  String get whyOther => 'משהו אחר';

  @override
  String get whyThanks => 'תודה ששיתפתם!';

  @override
  String get pollNoAnalytics =>
      'נתוני השימוש כבויים, לכן שום דבר לא נשלח מכאן. ספרו לנו דרך בקשת תכונה.';

  @override
  String alertLeak(Object name) {
    return '💧 נזילה — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name יבש שוב';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 עשן — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ אין יותר עשן ב-$name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name נפתח';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 סוללה חלשה — $name, $value%';
  }

  @override
  String get alertTest => 'התראת בדיקה של ZigDash';

  @override
  String get alertsChannel => 'התראות';

  @override
  String get alertsChannelDescription => 'נזילות ועשן';

  @override
  String get noticesChannel => 'הודעות';

  @override
  String get noticesChannelDescription => 'דלתות, חלונות וסוללות';

  @override
  String get alertsTitle => 'התראות';

  @override
  String get alertsStatusOn => 'ההתראות פועלות';

  @override
  String get alertsStatusPaused =>
      'ההתראות מושהות: ZigDash Engine ברכזת לא מדווח';

  @override
  String get alertsStatusNotSetUp => 'לא הוגדר';

  @override
  String get alertsStatusPhoneOff => 'הטלפון הזה לא מקבל התראות';

  @override
  String get alertsIntro =>
      'קבלת התראה בטלפון הזה על נזילה, עשן, דלת שנפתחה או סוללה חלשה, גם כש־ZigDash סגור. ZigDash Engine ברכזת עוקב אחרי המכשירים; ZigDash מגדיר אותו.';

  @override
  String get alertsSetUpHub => 'הגדרת התראות על הרכזת';

  @override
  String get alertsHubInstalled => 'ההתראות מוגדרות ברכזת';

  @override
  String get alertsHubUpdated => 'זרימת ההתראות על הרכזת מעודכנת';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED מבקש התחברות, לכן ייבאו את הזרימה ידנית:';

  @override
  String get alertsHubManualSteps =>
      'פתחו את Node-RED על הרכזת, בחרו Import, הדביקו את הזרימה שהועתקה, בחרו את ה-broker שלכם בצומת ה-broker ולחצו Deploy.';

  @override
  String get alertsCopyFlow => 'העתקת הזרימה';

  @override
  String get alertsFlowCopied => 'הזרימה הועתקה';

  @override
  String alertsNoNodeRed(Object host) {
    return 'התראות דורשות Node-RED על הרכזת, ושום דבר לא עונה בפורט 1880 בכתובת $host. ב-SMLIGHT SMHUB מתקינים אותו תחת Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT לא קיבל את ZigDash Engine';

  @override
  String get alertsRecent => 'התראות אחרונות';

  @override
  String get alertsRecentNone => 'עדיין אין';

  @override
  String get alertsYourAlerts => 'ההתראות שלכם';

  @override
  String get alertsAdd => 'הוספת התראה';

  @override
  String get alertsNotificationsOnThisPhone => 'התראות בטלפון הזה';

  @override
  String get alertsNoGoogle =>
      'בטלפון הזה אין שירותי Google, לכן ZigDash לא יכולה לקבל כאן הודעות דחיפה.';

  @override
  String get alertsSendTest => 'שליחת התראת בדיקה';

  @override
  String get alertsTestSent => 'הבדיקה נשלחה. היא אמורה להגיע עכשיו.';

  @override
  String alertsTestFailed(Object status) {
    return 'הרכזת לא הצליחה לשלוח ($status)';
  }

  @override
  String get alertsTestTimedOut => 'אין תשובה מהרכזת. האם זרימת ההתראות רצה?';

  @override
  String get alertsNotConnected => 'אין חיבור לרכזת';

  @override
  String get alertsTurnOff => 'כיבוי ההתראות';

  @override
  String get alertsTurnOffBody => 'ההתראות ייפסקו בכל הטלפונים של הבית הזה.';

  @override
  String get alertKindLeak => 'נזילה';

  @override
  String get alertKindSmoke => 'עשן';

  @override
  String get alertKindOpened => 'דלת או חלון נפתחו';

  @override
  String get alertKindBattery => 'סוללה חלשה';

  @override
  String get alertsEditTitle => 'התראה';

  @override
  String get alertsKind => 'מה';

  @override
  String get alertsDevices => 'מכשירים';

  @override
  String get alertsNoDevicesForKind => 'אף מכשיר בבית הזה לא מדווח על כך.';

  @override
  String get alertsHours => 'רק בין';

  @override
  String get alertsHoursAny => 'בכל שעה';

  @override
  String get alertsHoursFrom => 'מ-';

  @override
  String get alertsHoursTo => 'עד';

  @override
  String get alertsThreshold => 'סוללה מתחת ל-';

  @override
  String get alertsDelete => 'מחיקת ההתראה';

  @override
  String get alertsNotifyMe => 'להודיע לי…';

  @override
  String get alertsWhatLeaves =>
      'התראות ל-ZigDash מוצפנות מקצה לקצה: שירות הדחיפה של Google מעביר אותן אך לא יכול לקרוא אותן. שום דבר אחר לא יוצא מהרכזת.';

  @override
  String get alertsRestricted =>
      'Android עלול לעצור את ZigDash ברקע, ואז התראות יגיעו באיחור או לא יגיעו. אפשרו ריצה ברקע בהגדרות Android (בסמסונג: סוללה › אפליקציות שלעולם לא ישנות).';

  @override
  String get alertsOpenSettings => 'פתיחת הגדרות Android';

  @override
  String get alertsOff => 'כבויה';

  @override
  String get alertsSuggested => 'התראות מוצעות';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count מכשירים',
      one: 'מכשיר אחד',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'הפעלה';

  @override
  String get alertsShare => 'שיתוף התראות';

  @override
  String get alertsShareBody =>
      'כל מי שיש לו את הקישור מקבל את ההתראות של הבית הזה באפליקציית ntfy, בלי צורך ב-ZigDash. טקסט ההתראה עובר דרך ntfy.sh ללא הצפנה.';

  @override
  String get alertsShareLink => 'קישור';

  @override
  String get alertsShareNewLink => 'קישור חדש';

  @override
  String get alertsShareCopied => 'הקישור הועתק';

  @override
  String get alertsShareOff => 'הפסקת השיתוף';

  @override
  String get alertsGetWithNtfy => 'קבלת התראות עם ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'התראות עשן ונזילה חוזרות עד שמאשרים אותן. נדרש חשבון Pushover (‏4.99 \$ פעם אחת אחרי תקופת ניסיון); המפתחות נשמרים ב-broker שלכם.';

  @override
  String get alertsPushoverUser => 'מפתח משתמש';

  @override
  String get alertsPushoverToken => 'טוקן אפליקציה';

  @override
  String get alertsHideNames => 'הסתרת שמות מכשירים';

  @override
  String get alertsNtfyServer => 'שרת ntfy';

  @override
  String get wallSheetTitle => 'תצוגת קיר';

  @override
  String get wallSheetSubtitle => 'לטאבלט על הקיר.';

  @override
  String get wallKeepOn => 'להשאיר את המסך דולק ולהסתיר את הסרגלים';

  @override
  String get wallKeepOnSubtitle =>
      'הם חוזרים בנגיעה ונעלמים שוב אחרי 10 שניות.';

  @override
  String get wallFullscreen => 'מסך מלא';

  @override
  String get wallFullscreenSubtitle =>
      'מסתיר גם את סרגלי המצב והניווט של אנדרואיד.';

  @override
  String get wallDimAfter => 'עמעום אחרי';

  @override
  String get wallDimOff => 'כבוי';

  @override
  String get wallIdleTitle => 'כשאף אחד לא נוגע';

  @override
  String get wallIdleAfter => 'אחרי';

  @override
  String get wallIdleNever => 'אף פעם';

  @override
  String get wallIdleShow => 'להציג';

  @override
  String get wallIdleShowDim => 'מעומעם';

  @override
  String get wallIdleShowClock => 'שעון';

  @override
  String get wallIdleShowBlack => 'שחור';

  @override
  String get wallIdleShowReadings => 'מדידות';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'בלוח הזה עדיין אין מדידות. הוסיפו קודם אריח מדידה או חיישן.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'מדידות על השעון (עד $count)';
  }

  @override
  String get wallProNote =>
      'מדידות על השעון, התעוררות בתנועה, מצב לילה והתראות הם חלק מ-ZigDash Pro, רכישה חד-פעמית.';

  @override
  String get wallAlarmLeak => 'נזילת מים';

  @override
  String get wallAlarmSmoke => 'עשן';

  @override
  String get wallAlarmGas => 'גז';

  @override
  String get wallAlarmCo => 'פחמן חד-חמצני';

  @override
  String get wallAlarmOk => 'אישור';

  @override
  String get wallMotionTitle => 'להעיר בתנועה';

  @override
  String get wallMotionSubtitle => 'חיישן שמזהה מישהו מעיר את המסך.';

  @override
  String get wallMotionNone => 'אין בבית הזה חיישני תנועה, נוכחות או דלת.';

  @override
  String get wallAlarmsTitle => 'התראות ממלאות את המסך';

  @override
  String get wallAlarmsSubtitle =>
      'נזילה, עשן, גז או פחמן חד-חמצני ממלאים את המסך עד שמישהו לוחץ אישור. רק כש-ZigDash פתוח בטאבלט הזה; ההתראות מגיעות לטלפונים בכל מקום.';

  @override
  String get wallAlarmSound => 'להשמיע צליל';

  @override
  String get wallNightTitle => 'לילה';

  @override
  String get wallNightSubtitle =>
      'שחור בין השעות האלה. תנועה מעירה רק בעמעום; התראות תמיד במלואן.';

  @override
  String get wallNightFrom => 'מ-';

  @override
  String get wallNightTo => 'עד';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes דק׳';
  }

  @override
  String get kioskLock => 'נעילת קיוסק';

  @override
  String get kioskLockSubtitle =>
      'רק לוחות הבית הזה והפקדים שלהם נשארים זמינים. לחיצה ארוכה על הכותרת כדי לצאת.';

  @override
  String get kioskPin => 'קוד PIN';

  @override
  String get kioskPinSet => 'הגדרה';

  @override
  String get kioskPinNotSet => 'לא הוגדר';

  @override
  String get kioskPinChange => 'שינוי';

  @override
  String get kioskPinRemove => 'הסרה';

  @override
  String get kioskPinSetTitle => 'הגדרת קוד PIN';

  @override
  String get kioskPinEnterTitle => 'הזנת קוד PIN';

  @override
  String get kioskPinHint => '4 ספרות';

  @override
  String get kioskPinConfirmHint => 'שוב';

  @override
  String get kioskPinMismatch => 'שני הקודים שונים.';

  @override
  String get kioskPinWrong => 'קוד שגוי.';

  @override
  String get kioskPinForgot => 'שכחתם את הקוד?';

  @override
  String get kioskPinForgotBody =>
      'קוד שנשכח אפשר לאפס רק במחיקת הנתונים של ZigDash בהגדרות אנדרואיד, וזה מסיר את הבית הזה אלא אם יש לכם גיבוי. ייצאו גיבוי לפני הגדרת קוד.';

  @override
  String get kioskExportBackup => 'ייצוא גיבוי';

  @override
  String get kioskOsPin => 'להצמיד את ZigDash גם באנדרואיד';

  @override
  String get kioskOsPinSubtitle =>
      'אנדרואיד חוסם את כפתור הבית והאפליקציות האחרונות עד לביטול ההצמדה של ZigDash. טאבלט בלי מסך נעילה מבטל את ההצמדה במחווה, כך שזו לא הנעילה.';

  @override
  String get kioskOn => 'קיוסק פעיל. לחיצה ארוכה על הכותרת כדי לצאת.';

  @override
  String get kioskLeaveTitle => 'לצאת מהקיוסק?';

  @override
  String get kioskLeave => 'יציאה';

  @override
  String get kioskStay => 'להישאר';

  @override
  String get a11yKioskLeave => 'לחיצה ארוכה כדי לצאת מהקיוסק';

  @override
  String get historyTitle => 'היסטוריה';

  @override
  String get historyRangeDay => '24 שעות';

  @override
  String get historyRangeWeek => '7 ימים';

  @override
  String get historyRangeMonth => '30 יום';

  @override
  String get historySetupTitle => 'הקליטו היסטוריה ב-hub';

  @override
  String get historySetupBody =>
      'ל־ZigDash אין שרת, ולכן ZigDash Engine ברכזת שומר את הערכים מלוחות הבקרה כל 15 דקות. הוא שומר 30 יום, בברוקר שלך.';

  @override
  String get historySetupAction => 'התקנה ב-hub';

  @override
  String get historyInstalled =>
      'ההקלטה התחילה. הערכים הראשונים יופיעו תוך 15 דקות.';

  @override
  String historyNoNodeRed(String host) {
    return 'ההיסטוריה צריכה Node-RED ב-hub, ושום דבר לא עונה בפורט 1880 בכתובת $host. ב-SMLIGHT SMHUB מתקינים אותו תחת Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'מוקלט מאז $date';
  }

  @override
  String get historyEmpty => 'אין עדיין ערכים. המקליט שומר כל 15 דקות.';

  @override
  String get historyRecorderOffline =>
      'המקליט ב-hub לא עונה, כך שייתכן שחסרים ערכים אחרונים.';

  @override
  String get historyLocked =>
      'היסטוריה ארוכה יותר היא חלק מ-ZigDash Pro, רכישה חד-פעמית.';

  @override
  String get historyUnlock => 'פתיחה';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'אוטומציות ללא הגבלה, היסטוריה ארוכה יותר ותוספות לטאבלט קיר. תומך בפרויקט הקוד הפתוח.';

  @override
  String get proUnlocked => 'פתוח. תודה שאתם תומכים ב-ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash חינמית וקוד פתוח, ונבנית על ידי אדם אחד בזמנו הפנוי. Pro היא רכישה חד־פעמית שמאפשרת להמשיך לפתח אותה.';

  @override
  String get proWhatYouGet => 'מה מקבלים';

  @override
  String get proGetHistory => 'היסטוריה של 7 ו־30 ימים, לא רק של היום';

  @override
  String get proGetWall =>
      'טאבלט קיר: מדידות על השעון, התעוררות בתנועה, לוח זמנים לילי והתראות קוליות';

  @override
  String get proGetFuture => 'כל תכונת Pro שתגיע בהמשך, בלי תוספת תשלום';

  @override
  String get proFreeTitle => 'חינם לתמיד';

  @override
  String get proFreeBody =>
      'ההגדרה, הדשבורדים, השליטה בכל מכשיר, הווידג\'טים, אריחי ההגדרות המהירות, ההתראות, שלוש אוטומציות לכל בית וטאבלט הקיר עצמו נשארים בחינם. שום דבר שאתם משתמשים בו היום לא ננעל.';

  @override
  String get proBuy => 'לקבלת Pro';

  @override
  String proBuyPrice(String price) {
    return 'לקבלת Pro · $price';
  }

  @override
  String get proOnce =>
      'תשלום אחד, בלי מנוי. קניתם בטלפון אחר עם אותו חשבון Google? זה נפתח אוטומטית.';

  @override
  String get historyNotRecorded =>
      'מוקלטים רק מספרים שמוצגים בלוח בקרה. הוסיפו את הערך הזה כאריח כדי להתחיל את ההיסטוריה שלו.';

  @override
  String get historyRecordHere => 'להקליט במכשיר הזה';

  @override
  String get historyRecordHereHint =>
      'אי אפשר להשתמש ב־ZigDash Engine ברכזת? ZigDash יכול לשמור בטלפון או בטאבלט שנשאר פתוח, כמו טאבלט קיר. כל הטלפונים של הבית רואים את ההיסטוריה.';

  @override
  String get historyRecordingHere =>
      'המכשיר הזה מקליט היסטוריה כל עוד ZigDash פתוח. הערכים הראשונים יופיעו תוך 15 דקות.';

  @override
  String get wallRecordHistory => 'להקליט היסטוריה במכשיר הזה';

  @override
  String get wallRecordHistorySubtitle =>
      'כל 15 דקות כש־ZigDash פתוח, לכל הטלפונים של הבית. לא נחוץ כש־ZigDash Engine ברכזת שומר.';

  @override
  String historyNeedsPassword(String host) {
    return 'עוד צעד אחד: ה-broker דורש התחברות. פתחו את Node-RED בכתובת $host:1880, לחצו פעמיים על \"ZigDash history broker\", הקלידו את סיסמת ה-MQTT בלשונית Security ולחצו Deploy. ZigDash אף פעם לא שולח את הסיסמה ל-hub.';
  }

  @override
  String get historyNotConnected =>
      'השמירה לא מדווחת. אפשר לפתוח את „אוטומציות” כדי לבדוק את ZigDash Engine ברכזת.';

  @override
  String get historyPersistence =>
      'ההיסטוריה נשמרת ב-broker. אם אתם מריצים Mosquitto בעצמכם, ודאו שבהגדרות שלו יש \"persistence true\", אחרת ההיסטוריה תימחק כשה-broker יופעל מחדש.';

  @override
  String get haImportTitle => 'ייבוא מ-Home Assistant';

  @override
  String get haImportSettingsSubtitle => 'שמות וחדרים שהגדרתם ב-Home Assistant';

  @override
  String get haImportIntro =>
      'הביאו את השמות והחדרים שהגדרתם ב-Home Assistant. ‏ZigDash קורא אותם פעם אחת ולא שומר שום דבר אחר מ-Home Assistant.';

  @override
  String get haImportAddress => 'הכתובת של Home Assistant';

  @override
  String get haImportAddressHelp =>
      'הכתובת שבה אתם פותחים את Home Assistant, למשל 192.168.1.20:8123';

  @override
  String get haImportToken => 'אסימון גישה ארוך טווח';

  @override
  String get haImportTokenHelp =>
      'ב-Home Assistant פתחו את הפרופיל שלכם, ואז Security › Long-lived access tokens › Create token. העתיקו אותו והדביקו כאן. ‏ZigDash משתמש בו פעם אחת ולא שומר אותו; אחר כך אפשר למחוק אותו ב-Home Assistant.';

  @override
  String get haImportRead => 'קריאה מ-Home Assistant';

  @override
  String get haImportReading => 'קורא את Home Assistant…';

  @override
  String get haImportApplying => 'מייבא…';

  @override
  String get haImportNoAddress =>
      'הקלידו את הכתובת שבה אתם פותחים את Home Assistant.';

  @override
  String get haImportNoToken => 'הדביקו אסימון גישה ארוך טווח.';

  @override
  String get haImportUnreachable =>
      'שום דבר לא ענה בכתובת הזו. בדקו אותה, ושהטלפון ברשת של הבית.';

  @override
  String get haImportNotHa => 'משהו ענה בכתובת הזו, אבל זה לא Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant דחה את האסימון. צרו אסימון חדש והדביקו שוב.';

  @override
  String get haImportCertificate =>
      'הטלפון לא סומך על התעודה של Home Assistant הזה. נסו את כתובת ה-http:// שלו ברשת של הבית.';

  @override
  String get haImportFailed => 'Home Assistant ענה, אבל הקריאה נכשלה. נסו שוב.';

  @override
  String get haImportNoDevices =>
      'ZigDash לא רואה כרגע את המכשירים של הבית הזה. התחברו לבית ונסו שוב.';

  @override
  String get haImportAutomations =>
      'האוטומציות שלכם נשארות ב-Home Assistant וממשיכות לעבוד.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נמצאו $count מכשירים ב-Home Assistant',
      one: 'נמצא מכשיר אחד ב-Home Assistant',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'אריחים שעדיין נקראים בשם המכשיר שלהם יקבלו את השם מ-Home Assistant. לוחות שבניתם נשארים כמו שהם.';

  @override
  String get haImportMakeDashboards => 'להוסיף גם לוחות לפי הקומות והחדרים';

  @override
  String get haImportOtherRooms => 'חדרים נוספים';

  @override
  String get haImportNoRoom => 'בלי חדר';

  @override
  String get haImportApply => 'ייבוא';

  @override
  String get haImportBack => 'חזרה';

  @override
  String get haImportZhaOnly =>
      'המכשירים האלה עובדים עם ZHA, ה-Zigbee המובנה של Home Assistant, ולא עם Zigbee2MQTT, ולכן ZigDash לא יכול להציג אותם.';

  @override
  String get haImportNothing =>
      'אף אחד ממכשירי ה-Zigbee2MQTT של הבית הזה לא נמצא ב-Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'בוצע. אריחים ששמם שונה: $renamed. לוחות שנוספו: $dashboards.';
  }

  @override
  String get haImportOpen => 'פתיחת הלוחות';

  @override
  String get haImportOfferTitle => 'להביא את השמות והחדרים מ-Home Assistant?';

  @override
  String get haImportOfferBody =>
      'Home Assistant נמצא ברשת שלכם. ‏ZigDash יכול לתת לאריחים את השמות ולהוסיף לוח לכל קומה וחדר, כמו שהגדרתם שם.';

  @override
  String get haImportOfferLater => 'לא עכשיו';

  @override
  String get haImportOfferGo => 'ייבוא';

  @override
  String get haImportSignIn => 'התחברות עם Home Assistant';

  @override
  String get haImportSignInHelp =>
      'מסך ההתחברות של Home Assistant נפתח בדפדפן. ‏ZigDash לא רואה את הסיסמה שלכם ומתנתק שוב אחרי הקריאה.';

  @override
  String get haImportOrToken => 'או להשתמש באסימון גישה ארוך טווח';

  @override
  String get haImportReadToken => 'קריאה עם אסימון';

  @override
  String get haImportSignInRefused =>
      'Home Assistant לא קיבל את ההתחברות. זה קורה כשאין ל-Home Assistant גישה לאינטרנט. השתמשו במקום זה באסימון גישה ארוך טווח למטה.';

  @override
  String get setupIsolatedHint =>
      'הטלפון שלכם כמעט לא רואה שום דבר אחר ברשת ה-Wi-Fi הזו. ייתכן שהוא ברשת אורחים, או שהנתב מפריד בין המכשירים (נקרא לרוב client isolation או AP isolation). התחברו ל-Wi-Fi הראשי או כבו את זה, ונסו שוב.';

  @override
  String get setupAuthTrust =>
      'פרטי ההתחברות נשארים בטלפון הזה ועוברים רק ל-broker שלכם. ל-ZigDash אין שרת ואין חשבון, וכל אפליקציית MQTT מתחברת כך. הכי בטוח: משתמש MQTT נפרד רק ל-ZigDash, שאפשר למחוק בכל רגע.';

  @override
  String get setupAuthWhatKept => 'מה ZigDash שומר';

  @override
  String get setupAuthDemoFirst => 'לנסות קודם את ההדגמה';

  @override
  String get automationsTitle => 'אוטומציות';

  @override
  String get engineRunningOnHub => 'פועל ברכזת';

  @override
  String get engineChecking => 'בודק את הרכזת…';

  @override
  String get engineAwayNoHubTitle => 'אי אפשר להגיע לרכזת כרגע';

  @override
  String get engineAwayNoHubBody =>
      'אתם מחוץ לבית, והרכזת לא מחוברת לגישה מרחוק של ZigDash, או שאין לה אינטרנט. האוטומציות ממשיכות לרוץ ברכזת.';

  @override
  String get engineAwayReinstallAtHome =>
      'אפשר להתקין מחדש את ה-Engine כשתהיו בבית.';

  @override
  String get engineNoConnection =>
      'ZigDash לא מצליח להגיע כרגע לברוקר של הבית הזה. אוטומציות מגדירים בבית, עם חיבור.';

  @override
  String get engineRestarting =>
      'מפעיל מחדש את Zigbee2MQTT… המכשירים יחזרו בעוד כ־30 שניות.';

  @override
  String get engineInstalling => 'מתקין ברכזת…';

  @override
  String get engineTooOldTitle => 'צריך לעדכן את Zigbee2MQTT';

  @override
  String engineTooOldBody(Object version) {
    return 'גרסת Zigbee2MQTT שלך היא $version. אוטומציות דורשות 2.4 ומעלה. יש לעדכן את Zigbee2MQTT ברכזת ולחזור לכאן.';
  }

  @override
  String get engineIntroTitle => 'אוטומציות רצות ברכזת, לא בטלפון';

  @override
  String get engineIntroBody =>
      'ZigDash מוסיף את ZigDash Engine בתוך Zigbee2MQTT ברכזת. הוא עוקב אחרי המכשירים ומריץ את הכללים, כך שאור נדלק כשהדלת נפתחת גם כשהטלפון כבוי ואין אינטרנט.';

  @override
  String get engineIntroNothingByHand =>
      'אין מה להתקין ידנית. ZigDash עושה את זה דרך הרשת הביתית.';

  @override
  String engineIntroVersion(Object version) {
    return 'גרסת Zigbee2MQTT שלך היא $version.';
  }

  @override
  String get engineIntroRemove => 'אפשר להסיר אותו בכל עת מהמסך הזה.';

  @override
  String get engineInstall => 'התקנה ברכזת';

  @override
  String get engineDeclinedTitle => 'אין אוטומציות ברכזת הזו';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT ברכזת לא מאפשר תוספים, כך ששום דבר לא יריץ את הכללים כשהטלפון לא בבית. סצנות, התראות ולוח הבקרה עובדים כרגיל.';

  @override
  String get engineAllowAfterAll => 'בכל זאת לאפשר תוספים';

  @override
  String get engineConsentTitle => 'צריך לשנות הגדרה אחת ב־Zigbee2MQTT';

  @override
  String get engineConsentBody =>
      'Zigbee2MQTT שלך חוסם תוספים כמו ZigDash Engine, כמו בהתקנות חדשות. כדי להריץ אוטומציות ברכזת, ZigDash יפעיל ב־Zigbee2MQTT את „אפשר JavaScript חיצוני” ויפעיל אותו מחדש.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT יופעל מחדש פעם אחת. האורות והחיישנים לא יהיו זמינים כ־30 שניות.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine בקוד פתוח. אפשר לקרוא אותו בעמוד של Zigbee2MQTT, תחת Extensions.';

  @override
  String get engineConsentUndo =>
      'אפשר לכבות את ההגדרה מאוחר יותר. אז האוטומציות ייעצרו.';

  @override
  String get engineConsentYes => 'לשנות את ההגדרה ולהפעיל מחדש';

  @override
  String get engineConsentNo => 'לא עכשיו';

  @override
  String get automationsPausedTitle => 'האוטומציות מושהות';

  @override
  String get automationsPausedBody =>
      'הרכזת לא דיווחה כבר יותר מדקה, כך שאף אוטומציה לא תרוץ עד שתחזור. הכללים נשמרים.';

  @override
  String get engineReinstall => 'התקנה מחדש ברכזת';

  @override
  String get engineStoppedTitle =>
      'האוטומציות מושהות: ZigDash Engine עצר את עצמו';

  @override
  String get engineStoppedBody =>
      'הוא נתקל בשגיאות שלוש פעמים בשעה ונכבה כדי ש־Zigbee2MQTT ימשיך לפעול. הכללים נשמרים.';

  @override
  String get engineStartAgain => 'להפעיל שוב';

  @override
  String get engineReportProblem => 'דיווח על בעיה';

  @override
  String get engineRunningTitle => 'הרכזת מוכנה לאוטומציות';

  @override
  String engineRunningBody(Object count) {
    return 'כללים שנטענו ברכזת: $count. יצירת אוטומציות מגיעה בשלב הבא של הגרסה.';
  }

  @override
  String get engineClockOff =>
      'השעון של הרכזת סוטה ביותר מחמש דקות. אוטומציות לפי שעה ירוצו בזמן הלא נכון עד שזה יתוקן.';

  @override
  String engineRulesUnknown(Object count) {
    return 'כללים ש־ZigDash Engine ברכזת עוד לא יודע להריץ: $count. יש להתקין אותו מחדש כדי לעדכן.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT דחה את ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT לא ענה. יש לוודא שהבית מחובר ולנסות שוב.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT לא קיבל את השינוי או לא חזר. יש לבדוק את הרכזת ולנסות שוב.';

  @override
  String get autoValMotion => 'תנועה';

  @override
  String get autoValNoMotion => 'אין תנועה';

  @override
  String get autoValClosed => 'סגור';

  @override
  String get autoValOpened => 'נפתח';

  @override
  String get autoValLeak => 'נזילה';

  @override
  String get autoValDry => 'יבש';

  @override
  String get autoValSmoke => 'עשן';

  @override
  String get autoValNoSmoke => 'אין עשן';

  @override
  String get autoValOn => 'דלוק';

  @override
  String get autoValOff => 'כבוי';

  @override
  String get autoValToggle => 'החלפה';

  @override
  String get autoValOpen => 'פתיחה';

  @override
  String get autoValClose => 'סגירה';

  @override
  String get autoValStop => 'עצירה';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'כאשר $device: $property מעל $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'כאשר $device: $property מתחת ל־$value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'כאשר $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'ב־$time';
  }

  @override
  String get autoSunrise => 'זריחה';

  @override
  String get autoSunset => 'שקיעה';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes דק׳ אחרי $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes דק׳ לפני $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'ב$sun';
  }

  @override
  String get autoEveryDay => 'כל יום';

  @override
  String get autoWeekdays => 'ימי חול';

  @override
  String get autoWeekends => 'סופי שבוע';

  @override
  String autoBetween(Object from, Object to) {
    return 'בין $from ל־$to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device: $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'הפעלת „$scene”';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, כיבוי אחרי $minutes דק׳';
  }

  @override
  String get autoErrPickTrigger => 'יש לבחור מכשיר ומה הוא עושה.';

  @override
  String get autoErrValue => 'יש להקליד מספר לערך.';

  @override
  String get autoErrDays => 'יש לבחור לפחות יום אחד.';

  @override
  String get autoErrTown => 'יש להגדיר עיר לזריחה ולשקיעה.';

  @override
  String get autoErrPickAction => 'יש לבחור מה יקרה.';

  @override
  String get autoErrEmptyScene => 'בסצנה הזו אין מה לשלוח.';

  @override
  String get autoErrNotConnected =>
      'ZigDash לא מחובר לבית הזה. אפשר לנסות שוב בבית.';

  @override
  String get autoNewTitle => 'אוטומציה חדשה';

  @override
  String get autoEditTitle => 'עריכת אוטומציה';

  @override
  String get autoName => 'שם';

  @override
  String get autoNameHint => 'מה היא עושה (לא חובה)';

  @override
  String get autoWhen => 'כאשר';

  @override
  String get autoOnlyIf => 'רק אם';

  @override
  String get autoThen => 'אז';

  @override
  String get autoEnabled => 'פעילה';

  @override
  String get autoDelete => 'מחיקת אוטומציה';

  @override
  String get autoSave => 'שמירה';

  @override
  String get autoDeviceChanges => 'מכשיר משתנה';

  @override
  String get autoTimeComes => 'מגיעה שעה';

  @override
  String get autoDevice => 'מכשיר';

  @override
  String get autoAbove => 'מעל';

  @override
  String get autoBelow => 'מתחת';

  @override
  String get autoClockTime => 'שעה';

  @override
  String get autoAt => 'ב־';

  @override
  String get autoShift => 'הזזה בדקות (מינוס זה לפני)';

  @override
  String get autoTownNone => 'לא הוגדרה עיר';

  @override
  String autoTownIs(Object town) {
    return 'זמני השמש עבור $town';
  }

  @override
  String get autoTownSet => 'הגדרת עיר';

  @override
  String get autoTownChange => 'שינוי עיר';

  @override
  String get autoDays => 'ימים';

  @override
  String get autoNoConditions => 'אין תנאים. רצה בכל פעם.';

  @override
  String get autoAddHours => 'בין שעות';

  @override
  String get autoFrom => 'מ־';

  @override
  String get autoTo => 'עד';

  @override
  String get autoAddDeviceCondition => 'מכשיר נמצא במצב…';

  @override
  String get autoRunASceneOption => 'הפעלת סצנה';

  @override
  String get autoSetADevice => 'שליטה במכשיר';

  @override
  String get autoScene => 'סצנה';

  @override
  String get autoTurnOffAgain => 'לכבות שוב';

  @override
  String get autoStaysAsSet => 'נשאר כך';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes דקות אחרי ההפעלה';
  }

  @override
  String get autoTownSearch => 'עיר';

  @override
  String get autoTownWhy =>
      'משמשת רק לזריחה ולשקיעה. נשמרת ברכזת, אף פעם לא המיקום שלך.';

  @override
  String get autoNewButton => 'אוטומציה חדשה';

  @override
  String get autoEmptyBody =>
      'עוד לא רץ כלום. אפשר להקיש על „אוטומציה חדשה” כדי ליצור את הראשונה.';

  @override
  String autoOnlyIfList(Object list) {
    return 'רק אם $list';
  }

  @override
  String get autoEdit => 'עריכה';

  @override
  String get autoNeverRan => 'עוד לא רצה';

  @override
  String autoRanAt(Object time) {
    return 'רצה ב־$time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count מתוך $max אוטומציות חינם';
  }

  @override
  String get autoRecentRuns => 'הפעלות אחרונות';

  @override
  String get autoDeleted => '(נמחקה)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count אוטומציות בחינם. רוצים עוד?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash חינמי ובקוד פתוח, ונבנה על ידי אדם אחד. Pro הוא רכישה חד־פעמית: אוטומציות ללא הגבלה, היסטוריה של 7 ו־30 ימים ותוספות לטאבלט קיר. האוטומציות שלך ימשיכו לרוץ, מה שלא תבחרו.';

  @override
  String get autoCeilingSeePro => 'ל־Pro';

  @override
  String get engineRemove => 'הסרה מהרכזת';

  @override
  String get engineRemoveTitle => 'להסיר את ZigDash Engine מהרכזת?';

  @override
  String get engineRemoveBody =>
      'האוטומציות יפסיקו לרוץ. הכללים נשארים ברכזת, כך שהתקנה מחדש של ZigDash Engine תחזיר אותם.';

  @override
  String get autoNoTargets => 'בבית הזה עוד אין אור, שקע, מתג או תריס לשליטה.';

  @override
  String get proGetAutomations => 'אוטומציות ללא הגבלה; שלוש לכל בית בחינם';

  @override
  String get proGetRemote =>
      'שליטה מרחוק מכל מקום, דרך הממסר של ZigDash, בלי תשלום חודשי';

  @override
  String get proRemoteFair =>
      'גישה מרחוק כלולה כל עוד הממסר של ZigDash פועל, לבית אחד, עד חמישה טלפונים ושימוש ביתי רגיל. היא עשויה להשתנות או להסתיים בהודעה מראש.';

  @override
  String get autoDeleteConfirm =>
      'למחוק את האוטומציה הזו? היא תפסיק לרוץ ברכזת.';

  @override
  String get statusConnectedRelay => 'מחובר · מחוץ לבית דרך ZigDash';

  @override
  String get shareHomeTitle => 'שיתוף עם טלפון נוסף';

  @override
  String get shareHomeSubtitle => 'הוספת הבית הזה לטלפון נוסף עם קוד QR אחד';

  @override
  String get shareHomeIntro =>
      'בטלפון השני, בבית על אותה רשת Wi-Fi, סרקו את הקוד במצלמה. ZigDash מוסיף את הבית עם פרטי ההתחברות ולוחות הבקרה שלכם.';

  @override
  String get shareHomeLoginWarning =>
      'הקוד כולל את פרטי ההתחברות לברוקר של הבית. הוא מוצג 2 דקות; הראו אותו רק לאנשים שאתם סומכים עליהם.';

  @override
  String get shareHomeShow => 'הצגת הקוד';

  @override
  String get shareHomeAtHome => 'התחברו קודם מהבית: שיתוף עובד רק ברשת הביתית.';

  @override
  String get shareHomeScanHint =>
      'סרקו במצלמה של הטלפון השני. הקוד יוסתר בעוד 2 דקות.';

  @override
  String get shareHomeHide => 'הסתרת הקוד';

  @override
  String get shareHomeViaHa =>
      'הבית הזה מתחבר דרך Home Assistant. בטלפון השני התקינו את ZigDash והתחברו עם Home Assistant.';

  @override
  String get joinHomeTitle => 'הוספת בית משותף';

  @override
  String get joinHomeInvalid =>
      'הקוד הזה אינו הזמנה לבית של ZigDash, או שהוא פגום.';

  @override
  String joinHomeAlready(String name) {
    return '$name כבר נמצא בטלפון הזה.';
  }

  @override
  String get joinHomeOpen => 'פתיחה';

  @override
  String joinHomeAsk(String name) {
    return 'להוסיף את $name לטלפון הזה?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash מוסיף את הבית עם אותו חיבור ואותם פרטי התחברות, ולוקח את לוחות הבקרה מהטלפון השני. השאירו את הטלפון ב-Wi-Fi של הבית.';

  @override
  String get joinHomeAdd => 'הוספת בית';

  @override
  String get joinHomeNoDashboards =>
      'הבית נוסף. לוחות הבקרה לא הגיעו; המכשירים נמצאים בלשונית מכשירים.';

  @override
  String get remoteTitle => 'שליטה מרחוק';

  @override
  String get remoteSettingsSubtitle => 'שליטה בבית הזה מכל מקום, עם Pro';

  @override
  String get remoteIntroTitle => 'שליטה בבית מכל מקום';

  @override
  String get remoteOfferBody =>
      'גישה למכשירים גם כשאתם לא בבית, דרך הממסר המוצפן של ZigDash. חלק מ-Pro: תשלום אחד, בלי תשלום חודשי. הגדירו את זה כשאתם בבית.';

  @override
  String get remoteOfferBodyPro =>
      'יש לכם Pro: הפעילו שליטה מרחוק כשאתם בבית, ואז תוכלו לשלוט במכשירים מכל מקום.';

  @override
  String get remoteOfferShow => 'הראו לי';

  @override
  String get remoteIntroBody =>
      'הרכזת שומרת חיבור אחד לממסר של ZigDash. מחוץ לבית, הטלפון הזה מגיע למכשירים דרכו. הכול מוצפן ברכזת ובטלפון, כך שהממסר לא יכול לקרוא את המכשירים או מה הם עושים.';

  @override
  String get remoteNeedsEngine =>
      'שליטה מרחוק רצה ב־ZigDash Engine. יש להתקין אותו קודם תחת „אוטומציות”.';

  @override
  String get remoteSetUp => 'הפעלת שליטה מרחוק';

  @override
  String get remoteNeedsPro => 'שליטה מרחוק היא חלק מ־Pro.';

  @override
  String get remoteNotAtHome => 'יש להפעיל את זה בבית, כשמחוברים לברוקר.';

  @override
  String get remoteUnreachable =>
      'הממסר של ZigDash לא ענה. אפשר לנסות שוב מאוחר יותר.';

  @override
  String get remoteRefused => 'הממסר סירב. אפשר לנסות שוב או לדווח על בעיה.';

  @override
  String get remoteOnTitle => 'שליטה מרחוק פעילה';

  @override
  String get remoteOnBody => 'מחוץ לבית, ZigDash מתחבר דרך הממסר לבד.';

  @override
  String get remoteHubOnline => 'הרכזת מחוברת לממסר';

  @override
  String get remoteHubOffline => 'הרכזת לא מחוברת לממסר';

  @override
  String get remoteTurnOff => 'כיבוי שליטה מרחוק';

  @override
  String get remoteViaRelayNow => 'הטלפון הזה מחובר עכשיו דרך הממסר.';

  @override
  String get remotePhones => 'טלפונים עם גישה מרחוק';

  @override
  String get remoteThisPhone => 'הטלפון הזה';

  @override
  String get remoteOtherPhone => 'טלפון אחר';

  @override
  String remotePhoneAdded(Object date) {
    return 'נוסף ב־$date';
  }

  @override
  String get remoteRemovePhone => 'הסרה';

  @override
  String get remoteRemovePhoneConfirm =>
      'להסיר את הטלפון הזה? הוא לא יוכל להגיע לבית הזה מבחוץ.';

  @override
  String get remoteAddPhone => 'הוספת טלפון';

  @override
  String get remoteAddPhoneHint =>
      'בבית, יש לסרוק את זה במצלמה של הטלפון השני. היא תפתח את ZigDash ותפעיל שם שליטה מרחוק. להציג רק לטלפונים שלך.';

  @override
  String get remoteAddPhoneFailed =>
      'הממסר לא נתן גישה לטלפון נוסף. לבית יכולים להיות עד חמישה.';

  @override
  String get remoteBackupSave => 'שמירת גיבוי מפתח';

  @override
  String get remoteBackupRestore => 'שחזור מגיבוי מפתח';

  @override
  String get remoteBackupPassphrase => 'סיסמת הגיבוי';

  @override
  String get remoteBackupPassphraseHint =>
      'אם הטלפון הזה ילך לאיבוד, הגיבוי והסיסמה הזו יחזירו את השליטה מרחוק בטלפון חדש. לפחות 8 תווים, ולשמור את הסיסמה במקום אחר מהקובץ.';

  @override
  String get remoteBackupPassphraseAsk => 'הסיסמה שבחרת כששמרת את הגיבוי.';

  @override
  String get remoteBackupPassphraseAgain => 'הסיסמה שוב';

  @override
  String get remoteBackupSaved => 'גיבוי המפתח נשמר';

  @override
  String get remoteBackupWrong => 'הסיסמה הזו לא פותחת את הגיבוי.';

  @override
  String get remoteBackupWrongFile => 'זה לא גיבוי מפתח של ZigDash.';

  @override
  String get remotePlayOnly =>
      'בינתיים שליטה מרחוק נמצאת בגרסת Google Play של ZigDash.';

  @override
  String get remotePairTitle => 'הוספת שליטה מרחוק';

  @override
  String get remotePairBody =>
      'איזה בית זה? ZigDash ישמור עבורו את הגישה מרחוק.';

  @override
  String get remotePairNoHomes =>
      'יש להגדיר קודם את הבית בטלפון הזה, בבית. אחר כך לסרוק שוב את הקוד.';

  @override
  String get remotePairInvalid =>
      'הקוד הזה אינו קוד שליטה מרחוק של ZigDash, או שהוא נחתך.';

  @override
  String remotePairDone(Object home) {
    return 'שליטה מרחוק פעילה עבור $home';
  }

  @override
  String get remoteReconnectHub => 'חיבור הרכזת מחדש';

  @override
  String get remoteTurnOffConfirm =>
      'הטלפון הזה יוצא מהשליטה מרחוק והרכזת מתנתקת מהממסר. גיבוי מפתח שנשמר מהטלפון הזה יפסיק לעבוד; טלפונים אחרים שומרים על הגישה עד שמסירים אותם.';

  @override
  String remoteHomeId(Object id) {
    return 'מזהה בית $id';
  }

  @override
  String get alertsHintTitle => 'קבלו התראות בטלפון הזה';

  @override
  String get alertsHintBody =>
      'נזילה, עשן, דלת שנפתחה או סוללה חלשה יכולים לשלוח התראה לטלפון הזה, גם כש-ZigDash סגור.';

  @override
  String get alertsHintButton => 'הגדרת התראות';

  @override
  String get alertsHintNotNow => 'לא עכשיו';

  @override
  String get guidedNoZ2mBody =>
      'ברוקר MQTT עונה כאן, אבל Zigbee2MQTT לא שולח דרכו כלום. בדקו ש-Zigbee2MQTT פועל ומשתמש בברוקר הזה, ושה-base topic תואם להגדרות שלו. אם מכשירי ה-Zigbee שלכם נמצאים ב-ZHA של Home Assistant, ‏ZigDash לא יכול לראות אותם: הוא עובד עם Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT נמצא על הברוקר הזה עם נושא הבסיס ‎“$found”‎, אבל הבית הזה מחפש ‎“$current”‎.';
  }

  @override
  String devicesUseBase(String found) {
    return 'להשתמש ב-‎“$found”‎';
  }

  @override
  String get devicesChangeConnection => 'שינוי החיבור';

  @override
  String get updateAvailableTitle => 'גרסה חדשה של ZigDash מוכנה';

  @override
  String get updateAvailableBody =>
      'היא יורדת בזמן שאתם ממשיכים להשתמש ב-ZigDash.';

  @override
  String get updateAvailableButton => 'עדכון';

  @override
  String get updateDownloading => 'מוריד את העדכון…';

  @override
  String get updateReadyTitle => 'העדכון ירד';

  @override
  String get updateReadyButton => 'הפעלה מחדש לסיום';

  @override
  String get nfcWriteTag => 'כתיבה לתג NFC';

  @override
  String get nfcHoldTitle => 'קרבו תג לטלפון';

  @override
  String nfcHoldBody(String name) {
    return 'קרבו מדבקת NFC ריקה לגב הטלפון. נגיעה בה בהמשך תפעיל את $name.';
  }

  @override
  String get nfcWrittenTitle => 'התג מוכן';

  @override
  String nfcWrittenBody(String name) {
    return 'געו בתג הזה עם הטלפון כדי להפעיל את $name. זה עובד גם כש-ZigDash סגור.';
  }

  @override
  String get nfcFailedTitle => 'לא ניתן לכתוב לתג';

  @override
  String get nfcReadonlyBody => 'התג הזה נעול ואי אפשר לשנות אותו. נסו תג אחר.';

  @override
  String get nfcTooSmallBody =>
      'התג הזה קטן מדי. השתמשו במדבקת NTAG213 או גדולה יותר.';

  @override
  String get nfcFailedBody => 'החזיקו את התג יציב על גב הטלפון ונסו שוב.';

  @override
  String get nfcOffTitle => 'ה-NFC כבוי';

  @override
  String get nfcOffBody => 'הפעילו NFC בהגדרות של אנדרואיד ונסו שוב.';

  @override
  String get nfcNoneTitle => 'אין NFC בטלפון הזה';

  @override
  String get nfcNoneBody => 'הטלפון הזה לא יכול לקרוא או לכתוב תגי NFC.';

  @override
  String get nfcWriteAnother => 'כתיבת תג נוסף';
}
