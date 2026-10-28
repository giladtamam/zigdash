// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Senast kända';

  @override
  String get reliabilityControlsUnavailable => 'Kontroller inte tillgängliga';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'Prova demo';

  @override
  String get navBrokers => 'Brokers';

  @override
  String get navDashboards => 'Dashboards';

  @override
  String get navSettings => 'Inställningar';

  @override
  String get settingsAppearance => 'Utseende';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Ljust';

  @override
  String get themeDark => 'Mörkt';

  @override
  String get settingsDynamicColor => 'Använd Material You-färger';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; annars används appens färg';

  @override
  String get settingsLanguage => 'Språk';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'Engelska';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Hem';

  @override
  String connLoadFailed(Object error) {
    return 'Kunde inte ladda: $error';
  }

  @override
  String get connAddBroker => 'Lägg till broker';

  @override
  String get connEmpty =>
      'Inga anslutningar ännu.\nTryck på „Lägg till broker” för att peka ZigDash mot din MQTT-server.';

  @override
  String get connNew => 'Ny anslutning';

  @override
  String get connEdit => 'Redigera anslutning';

  @override
  String get save => 'Spara';

  @override
  String get saving => 'Sparar…';

  @override
  String get fieldRequired => 'Obligatoriskt';

  @override
  String get connName => 'Namn';

  @override
  String get connNameHint => 'Hemmabroker';

  @override
  String get connHost => 'Värd';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Lokal värd';

  @override
  String get connFindBrokers => 'Sök efter brokers';

  @override
  String get connHowToFind => 'Hur hittar jag detta?';

  @override
  String get connRescan => 'Skanna igen';

  @override
  String get connBrokerNeedsLogin => 'Inloggning krävs';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Skannar $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return '$count broker(s) hittade – tryck för att använda';
  }

  @override
  String get connFindBrokersNone => 'Inga brokers hittades på ditt Wi-Fi.';

  @override
  String get connFindBrokersNoIp =>
      'Kunde inte läsa din Wi-Fi-adress. Kontrollera att Wi-Fi är på och försök igen.';

  @override
  String get connHelpTitle => 'Hitta din brokers IP';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT i Docker';

  @override
  String get connHelpDockerBody =>
      'Brokerns IP är LAN-adressen till maskinen där Docker körs (din NAS, Raspberry Pi osv.). Hitta den i routerns enhetslista eller kör \'hostname -I\' / \'ip addr\' på den maskinen. Porten är vanligtvis 1883 (Mosquitto). Använd värdens LAN-IP – inte 127.0.0.1 – även om Mosquitto körs i en egen container.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'Brokerns IP är hubbens IP-adress. Hitta den i SMLIGHT:s webbgränssnitt under Inställningar → Nätverk, eller i din router. Porten är 1883, utan användarnamn/lösenord som standard.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA har ingen MQTT-broker – den pratar direkt med Home Assistant, så ZigDash kan inte ansluta till den. För att använda ZigDash, byt till Zigbee2MQTT (tillgängligt som Home Assistant-tillägg eller Docker-container), som tillhandahåller en MQTT-broker.';

  @override
  String get connHelpSameNetwork =>
      'Din telefon och brokern måste vara på samma Wi-Fi-nätverk (inte ett gäst- eller isolerat VLAN).';

  @override
  String get connRemoteHost => 'Extern värd (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Används när den lokala värden inte kan nås. Föredra hubbens Tailscale-IP, t.ex. 100.x.y.z';

  @override
  String get connPort => 'Port';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsername => 'Användarnamn';

  @override
  String get connUsernameOptional => 'Användarnamn (valfritt)';

  @override
  String get connPasswordOptional => 'Lösenord (valfritt)';

  @override
  String get connPasswordKeepHint => 'Lämna tomt för att behålla befintligt';

  @override
  String get connAutoConnect => 'Anslut automatiskt vid appstart';

  @override
  String get advanced => 'Avancerat';

  @override
  String get connKeepAlive => 'Keep-alive (sekunder)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protokoll';

  @override
  String get edit => 'Redigera';

  @override
  String get delete => 'Ta bort';

  @override
  String get cancel => 'Avbryt';

  @override
  String get connDeleteTitle => 'Ta bort anslutningen?';

  @override
  String connDeleteContent(Object name) {
    return 'Tar bort „$name”, dess dashboards/paneler och det sparade lösenordet.';
  }

  @override
  String get statusDisconnected => 'Frånkopplad';

  @override
  String get statusConnecting => 'Ansluter…';

  @override
  String get statusConnected => 'Ansluten';

  @override
  String get statusReconnecting => 'Återansluter…';

  @override
  String get statusError => 'Fel';

  @override
  String get statusConnectedRemote => 'Ansluten · Extern';

  @override
  String get dashPlaceholder =>
      'Öppna en broker från fliken Brokers för att se och hantera dess dashboards.';

  @override
  String get dashAddDashboard => 'Lägg till dashboard';

  @override
  String get dashEditDashboard => 'Redigera dashboard';

  @override
  String get dashAddPanel => 'Lägg till panel';

  @override
  String get dashEmpty =>
      'Inga dashboards ännu.\nTryck på „Lägg till dashboard” för att skapa en för den här brokern.';

  @override
  String dashLoadFailed(Object error) {
    return 'Fel: $error';
  }

  @override
  String get panelPickerTitle => 'Lägg till panel';

  @override
  String get panelPickerSectionControl => 'Kontroll';

  @override
  String get panelPickerSectionState => 'Status';

  @override
  String get panelPickerToggleTitle => 'Strömbrytare';

  @override
  String get panelPickerToggleSubtitle => 'På/av-brytare för en enhetsstatus';

  @override
  String get panelPickerSliderBrightnessTitle => 'Reglage – Ljusstyrka';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Dämpa ljus (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Reglage – Position';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Rullgardin (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Rullgardin';

  @override
  String get panelPickerCoverSubtitle =>
      'Rullgardin: ÖPPEN·STOPP·STÄNGD + positionsreglage';

  @override
  String get panelPickerScheduleTitle => 'Schema';

  @override
  String get panelPickerScheduleSubtitle =>
      'Dagliga öppna/stäng-tider, körs på hubben (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Auto-stäng-regel';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Stäng en enhet automatiskt N sekunder efter att den sätts på, körs på hubben (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Flera lägen';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Segmenterade knappar för en uppräkning (t.ex. ÖPPEN/STOPP/STÄNGD)';

  @override
  String get panelPickerComboTitle => 'Dropdown';

  @override
  String get panelPickerComboSubtitle => 'Rullgardinsväljare för en uppräkning';

  @override
  String get panelPickerRadioTitle => 'Radioknappar';

  @override
  String get panelPickerRadioSubtitle => 'Radioknappslista för en uppräkning';

  @override
  String get panelPickerButtonTitle => 'Knapp';

  @override
  String get panelPickerButtonSubtitle => 'Skicka ett engångskommando';

  @override
  String get panelPickerTextInputTitle => 'Textinmatning';

  @override
  String get panelPickerTextInputSubtitle =>
      'Publicera ett fritextvärde eller JSON';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Färgad indikator för ett booleskt läge (kontakt, läckage)';

  @override
  String get panelPickerNodeStatusTitle => 'Nodstatus';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Z2M-enheters tillgänglighet (online/offline)';

  @override
  String get panelPickerProgressTitle => 'Förlopp';

  @override
  String get panelPickerProgressSubtitle =>
      'Numerisk stapel för batteri, länkkvalitet osv.';

  @override
  String get panelPickerTextLogTitle => 'Textlogg';

  @override
  String get panelPickerTextLogSubtitle =>
      'Rullande meddelandehistorik för ett ämne';

  @override
  String get dashExportMenu => 'Exportera dashboards';

  @override
  String get dashImportMenu => 'Importera dashboards';

  @override
  String get dashExportTitle => 'Exportera dashboards';

  @override
  String get dashExportClose => 'Stäng';

  @override
  String get dashExportCopy => 'Kopiera';

  @override
  String get dashExportCopied => 'Kopierat till urklipp';

  @override
  String get dashImportTitle => 'Importera dashboards';

  @override
  String get dashImportHint => 'Klistra in exporterad JSON här';

  @override
  String get dashImportButton => 'Importera';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dashboards importerade',
      one: '1 dashboard importerad',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Importen misslyckades: $error';
  }

  @override
  String get dashFormNew => 'Ny dashboard';

  @override
  String get dashFormEdit => 'Redigera dashboard';

  @override
  String get dashFormName => 'Namn';

  @override
  String get dashFormNameHint => 'Kontor';

  @override
  String get dashFormTopicPrefix => 'Ämnesprefix (valfritt)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/vardagsrum';

  @override
  String get dashFormTopicPrefixHelper =>
      'Läggs framför varje panelämne i den här dashboarden';

  @override
  String get dashFormColorSeed => 'Färg';

  @override
  String get dashFormIcon => 'Ikon';

  @override
  String get dashFormLock => 'Redigeringslås';

  @override
  String get dashFormLockSubtitle => 'Döljer Redigera för den här panelen';

  @override
  String get dashFormDelete => 'Ta bort dashboard';

  @override
  String get dashDeleteTitle => 'Ta bort den här dashboarden?';

  @override
  String get dashDeleteContent => 'Alla paneler under den tas också bort.';

  @override
  String get dashDeleteConfirm => 'Ta bort';

  @override
  String panelFormNew(Object type) {
    return 'Ny $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Redigera $type';
  }

  @override
  String get panelTypeButton => 'Knapp';

  @override
  String get panelTypeToggle => 'Strömbrytare';

  @override
  String get panelTypeSlider => 'Reglage';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Nodstatus';

  @override
  String get panelTypeProgress => 'Förlopp';

  @override
  String get panelTypeMultiState => 'Flera lägen';

  @override
  String get panelTypeCombo => 'Dropdown';

  @override
  String get panelTypeRadio => 'Radioknappar';

  @override
  String get panelTypeCover => 'Rullgardin';

  @override
  String get panelTypeTextInput => 'Textinmatning';

  @override
  String get panelTypeTextLog => 'Textlogg';

  @override
  String get panelTypeSchedule => 'Schema';

  @override
  String get panelTypeAutoClose => 'Auto-stäng';

  @override
  String get panelTypeDevice => 'Enhet';

  @override
  String get panelTypeReading => 'Mätvärde';

  @override
  String get panelFormName => 'Namn';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Dashboardprefix: $prefix/ (används om det inte åsidosätts nedan)';
  }

  @override
  String get panelFormTopicPrefixOverride => 'Åsidosätt ämnesprefix (valfritt)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/rullgardin';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Använd en annan enhet på den här dashboarden. Tomt = använd dashboardprefixet.';

  @override
  String get panelFormPublishTopic => 'Publiceringsämne (suffix)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Läggs till det effektiva prefixet. Lämna tomt för att publicera på själva prefixet.';

  @override
  String get panelFormTopicSuffix => 'Ämne (suffix)';

  @override
  String get panelFormSubscribeTopic => 'Prenumerationsämne (suffix, valfritt)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Läggs till dashboardprefixet. Tomt = prenumerera på själva prefixet (Z2M-status).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Tomt = prenumerera på själva prefixet (Z2M-status). Samma som Publiceringsämne = använd det.';

  @override
  String get tileSize => 'Storlek';

  @override
  String get tileSizeSmall => 'Liten';

  @override
  String get tileSizeWide => 'Bred';

  @override
  String get tileSizeFull => 'Hel';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 – högst en gång';

  @override
  String get panelFormQos1 => '1 – minst en gång';

  @override
  String get panelFormQos2 => '2 – exakt en gång';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'På-payload';

  @override
  String get panelToggleOffPayload => 'Av-payload';

  @override
  String get panelToggleJsonPath => 'JSON-sökväg (valfritt)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'På-matchning';

  @override
  String get panelToggleOnMatchHelper =>
      'Värde på JSON-sökvägen som betyder „på” (t.ex. „ON”)';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Max';

  @override
  String get panelSliderStep => 'Steg';

  @override
  String get panelSliderTemplate => 'Värdemall';

  @override
  String get panelSliderTemplateHelper =>
      'Använd ordet value som platshållare – det ersätts med reglagets värde';

  @override
  String get panelSliderJsonPath => 'JSON-sökväg (valfritt)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'JSON-sökväg (valfritt)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      't.ex. „contact”, „occupancy”, „water_leak”';

  @override
  String get panelLedOnMatch => 'På-matchning';

  @override
  String get panelLedOnMatchHelper =>
      'Värde på JSON-sökvägen som tänder lysdioden (t.ex. „true”, „ON”)';

  @override
  String get panelLedOnLabel => 'På-etikett (valfritt)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Av-etikett (valfritt)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Online-payload';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Värde som betyder „online” (Z2M-standard: „online”)';

  @override
  String get panelNodeJsonPath => 'JSON-sökväg (valfritt)';

  @override
  String get panelNodeJsonPathHelper =>
      'Lämna tomt för Z2M-standard (rå „online”/„offline”-sträng)';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Max';

  @override
  String get panelProgressUnit => 'Enhet';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'JSON-sökväg (valfritt)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 't.ex. „battery”, „linkquality”';

  @override
  String get panelOptionsJsonPath => 'JSON-sökväg (valfritt)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Fält i den mottagna payloaden som innehåller aktuellt värde';

  @override
  String get panelOptionsHeader => 'Alternativ';

  @override
  String get panelOptionsLabel => 'Etikett';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Matchning (aktuellt värde)';

  @override
  String get panelOptionsAdd => 'Lägg till alternativ';

  @override
  String get panelCoverDescription =>
      'ÖPPEN-/STOPP-/STÄNGD-knappar plus en rad positionsförinställningar. Använder standard Z2M-rullgardin-payloads (state och position).';

  @override
  String get panelCoverPresets => 'Positionsförinställningar';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Kommaavgränsade procenttal (0–100). Tomt = ingen förinställningsrad.';

  @override
  String get panelCoverShowSlider => 'Visa positionsreglage';

  @override
  String get panelTextInputHint => 'Ledtext (valfritt)';

  @override
  String get panelTextInputHintHint => 'Skriv ett värde…';

  @override
  String get panelTextInputTemplate => 'Mall';

  @override
  String get panelTextInputTemplateHelper =>
      'Använd ordet value som platshållare – det ersätts med den inskrivna texten. Standard publicerar råtexten.';

  @override
  String get panelTextInputClearAfterSend => 'Rensa efter sändning';

  @override
  String get panelTextLogMaxLines => 'Max rader';

  @override
  String get panelTextLogMaxLinesHelper =>
      'Hur många senaste meddelanden som behålls';

  @override
  String get panelTextLogJsonPath => 'JSON-sökväg (valfritt)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Logga bara det här fältet i stället för hela payloaden';

  @override
  String get panelScheduleDescription =>
      'Körs på SMHUB via Node-RED – även när den här telefonen är avstängd. Publiceringsämnet ovan är målet för rullgardinskommandon.';

  @override
  String get panelScheduleOpenTime => 'Öppningstid';

  @override
  String get panelScheduleCloseTime => 'Stängningstid';

  @override
  String get panelScheduleOpenPayload => 'Öppna-payload';

  @override
  String get panelScheduleClosePayload => 'Stäng-payload';

  @override
  String get panelScheduleEnabled => 'Aktiverad';

  @override
  String get panelScheduleSavedOffline =>
      'Sparat – inte ansluten; schemat synkroniseras när du är online.';

  @override
  String get panelAutoCloseDescription =>
      'Körs på SMHUB via Node-RED – även när den här telefonen är avstängd. Publiceringsämnet ovan är enhetens kommandomål (t.ex. dörr).';

  @override
  String get panelAutoCloseTriggerPath => 'Utlösarens JSON-sökväg';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Fält i enhetens status-JSON att bevaka (standard: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Utlösarvärde';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Starta timern när utlösarfältet är lika med detta värde (standard: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Stäng-payload';

  @override
  String get panelAutoCloseDelaySeconds => 'Fördröjning (sekunder)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1–3600. Tid att vänta efter att enheten sätts på innan stäng-payloaden publiceras.';

  @override
  String get panelAutoCloseEnabled => 'Aktiverad';

  @override
  String get panelAutoCloseSavedOffline =>
      'Sparat – inte ansluten; regeln synkroniseras när du är online.';

  @override
  String get panelTileEdit => 'Redigera panel';

  @override
  String get panelTileDuplicate => 'Duplicera panel';

  @override
  String get panelTileMoveUp => 'Flytta upp';

  @override
  String get panelTileMoveDown => 'Flytta ned';

  @override
  String get panelTileDelete => 'Ta bort panel';

  @override
  String get panelCoverOpen => 'Öppna';

  @override
  String get panelCoverStop => 'Stopp';

  @override
  String get panelCoverClose => 'Stäng';

  @override
  String get panelToggleNoState => '(ingen status)';

  @override
  String get panelToggleError => 'fel';

  @override
  String get panelStateOn => 'ON';

  @override
  String get panelStateOff => 'OFF';

  @override
  String get panelNodeStatusOnline => 'online';

  @override
  String get panelNodeStatusOffline => 'offline';

  @override
  String get panelNodeStatusUnknown => 'okänd';

  @override
  String get panelNodeStatusError => 'fel';

  @override
  String get panelMultiStateNoOptions => 'Inga alternativ konfigurerade';

  @override
  String get panelTextInputDefaultHint => 'Skriv ett värde…';

  @override
  String get panelTextLogWaiting => 'Väntar på meddelanden…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Öppnar $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Stänger $time';
  }

  @override
  String get panelScheduleOfflineWarning =>
      'Schemaläggaren offline – körs inte';

  @override
  String get panelScheduleDisabled => 'Inaktiverad';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Nästa: $action kl. $at';
  }

  @override
  String get panelScheduleActionOpen => 'öppna';

  @override
  String get panelScheduleActionClose => 'stäng';

  @override
  String get panelAutoCloseIdle => 'Inaktiv';

  @override
  String get panelAutoCloseDisabled => 'Inaktiverad';

  @override
  String get panelAutoCloseOffline =>
      'Automatisering offline – regeln körs inte';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Stänger om ${seconds}s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Stänger nu…';

  @override
  String get panelGridEmpty =>
      'Inga rutor ännu.\nTryck på Lägg till ruta för att lägga dina enheter här.';

  @override
  String get panelsOffline => 'Offline – visar senaste värden';

  @override
  String get connectionConnecting => 'Ansluter…';

  @override
  String get connectionReconnecting => 'Återansluter…';

  @override
  String get connectionShowingLastKnownValues => 'Visar senast kända värden';

  @override
  String get connectionFailed => 'Anslutningen misslyckades';

  @override
  String get connectionAutomaticRetry => 'Automatiska försök fortsätter';

  @override
  String get connectionReconnectNow => 'Anslut igen nu';

  @override
  String get settingsAbout => 'Om';

  @override
  String get settingsHelp => 'Hjälp & guide';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsRateApp => 'Betygsätt ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Gillar du den? En snabb recension hjälper andra att hitta appen.';

  @override
  String get settingsFeatureRequest => 'Föreslå en funktion';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Berätta vad som skulle göra ZigDash bättre.';

  @override
  String get featureRequestGithub => 'På GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Offentligt: andra kan se det och rösta.';

  @override
  String get featureRequestEmail => 'Via e-post';

  @override
  String get featureRequestEmailSubtitle => 'Privat, direkt till utvecklaren.';

  @override
  String get featureRequestEmailSubject => 'ZigDash: funktionsönskemål';

  @override
  String get featureRequestEmailPrompt =>
      'Vad vill du att ZigDash ska kunna, och varför?';

  @override
  String get settingsReportProblem => 'Rapportera ett problem';

  @override
  String get settingsReportProblemSubtitle =>
      'Är något trasigt eller förvirrande? Berätta.';

  @override
  String get reportProblemEmailSubject => 'ZigDash: problemrapport';

  @override
  String get reportProblemEmailPrompt =>
      'Vad hände, och vad förväntade du dig?';

  @override
  String get settingsBuyCoffee => 'Bjud mig på en kaffe';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Gratis & öppen källkod — dricks håller kaffet varmt.';

  @override
  String get a11yBackupMenu => 'Säkerhetskopiera & återställ';

  @override
  String get a11ySelectColor => 'Välj färg';

  @override
  String get a11ySelectIcon => 'Välj ikon';

  @override
  String get a11yDeleteOption => 'Ta bort alternativ';

  @override
  String get a11yPanelOptions => 'Panelalternativ';

  @override
  String get a11yMoreOptions => 'Fler alternativ';

  @override
  String get a11yRefresh => 'Uppdatera';

  @override
  String get a11yDeleteConnection => 'Ta bort anslutning';

  @override
  String get controlNotConnected => 'Inte ansluten – ändringen skickades inte';

  @override
  String get discoverFromDevice => 'Lägg till från en enhet…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Identifiera en Zigbee2MQTT-enhet automatiskt';

  @override
  String get discoverTitle => 'Lägg till från enhet';

  @override
  String get discoverBaseTopic => 'Zigbee2MQTT-basämne';

  @override
  String get discoverScanning => 'Söker efter enheter…';

  @override
  String get discoverNone => 'Inga enheter hittades.';

  @override
  String get discoverFailed =>
      'Ingen enhetslista hittades. Kontrollera basämnet och att brokern är ansluten.';

  @override
  String get retry => 'Försök igen';

  @override
  String get previewTitle => 'Liveförhandsvisning';

  @override
  String previewWaiting(Object topic) {
    return 'Väntar på ett meddelande på $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Extraherad ($path): $value';
  }

  @override
  String get previewNoValue => '(inget värde på den här sökvägen)';

  @override
  String get connErrorTitle => 'Anslutningsfel';

  @override
  String get connErrorUnknown => 'Inga feluppgifter tillgängliga.';

  @override
  String get connTestButton => 'Testa anslutning';

  @override
  String get connTestOk => 'Anslutningen lyckades';

  @override
  String connTestFailed(Object error) {
    return 'Anslutningen misslyckades: $error';
  }

  @override
  String get devicesTitle => 'Enheter';

  @override
  String get devicesAddButton => 'Lägg till enhet';

  @override
  String get devicesPairingTitle => 'Parar – tryck på enhetens knapp';

  @override
  String devicesPairingHint(int seconds) {
    return 'Söker efter nya enheter… ${seconds}s';
  }

  @override
  String get devicesPairingStop => 'Stopp';

  @override
  String get devicesNone => 'Inga enheter hittades.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT har inte skickat sin enhetslista. Det kan hända när MQTT-brokern har startats om.';

  @override
  String get devicesRestartZ2m => 'Starta om Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Zigbee2MQTT startas om. Dina enheter bör visas om några sekunder.';

  @override
  String get devicesBattery => 'Batteri';

  @override
  String get devicesLinkQuality => 'Länk';

  @override
  String get devicesOnline => 'Online';

  @override
  String get devicesOffline => 'Offline';

  @override
  String devicesPaired(Object name) {
    return 'Redo: $name';
  }

  @override
  String get devicesPairedHint =>
      'Tillagd i ditt nätverk. För att sätta den på en dashboard, använd „Lägg till från en enhet” på den dashboarden.';

  @override
  String get scenesTitle => 'Scener';

  @override
  String get scenesNone =>
      'Inga scener ännu. Ställ in dina enheter som du vill och spara dem sedan som en scen.';

  @override
  String get scenesNewButton => 'Ny scen';

  @override
  String scenesActivated(Object name) {
    return '$name aktiverad';
  }

  @override
  String get scenesActivateOffline =>
      'Inte ansluten – scenen kan inte aktiveras';

  @override
  String get sceneFormNewTitle => 'Ny scen';

  @override
  String get sceneFormEditTitle => 'Redigera scen';

  @override
  String get sceneFormNameLabel => 'Scennamn';

  @override
  String get sceneFormDevicesHeader => 'Enheter att fånga';

  @override
  String get sceneFormCaptureHint =>
      'Varje vald enhets aktuella inställningsbara status (på/av, ljusstyrka, färg, position…) sparas. Skrivskyddade värden ignoreras.';

  @override
  String get sceneFormNoDevices =>
      'Inga styrbara enheter hittades. Kontrollera att de är parade och tryck sedan på uppdatera.';

  @override
  String get sceneFormReadingState => 'Läser aktuell status…';

  @override
  String get sceneCtrlPower => 'Ström';

  @override
  String get sceneCtrlBrightness => 'Ljusstyrka';

  @override
  String get sceneCtrlPosition => 'Position';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count valda';
  }

  @override
  String get sceneFormNoDevicesSelected => 'Välj minst en enhet att fånga.';

  @override
  String get sceneFormNothingCaptured =>
      'Inget inställningsbart kunde fångas från de valda enheterna.';

  @override
  String get sceneDeleteTitle => 'Ta bort scenen?';

  @override
  String sceneDeleteMessage(Object name) {
    return '„$name” tas bort. Enheterna behåller sin aktuella status.';
  }

  @override
  String get sceneEditAction => 'Redigera';

  @override
  String get sceneDeleteAction => 'Ta bort';

  @override
  String get sceneAddToDashboard => 'Lägg till på dashboard';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Tillagd på $name';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count enheter';
  }

  @override
  String get scenesAllShutters => 'Alla jalusier';

  @override
  String get sceneCloseAllShutters => 'Stäng alla jalusier';

  @override
  String get sceneOpenAllShutters => 'Öppna alla jalusier';

  @override
  String get sceneStopAllShutters => 'Stoppa alla jalusier';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jalusier',
      one: '1 jalusi',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Vilka jalusier…';

  @override
  String get sceneWhichShuttersHint =>
      'Alla jalusier i det här hemmet ingår. Avmarkera de som ska lämnas utanför, som en garageport.';

  @override
  String get scenesYours => 'Dina scener';

  @override
  String get panelTypeScene => 'Scen';

  @override
  String get panelPickerSceneTitle => 'Scenknapp';

  @override
  String get panelPickerSceneSubtitle => 'Ett tryck aktiverar en sparad scen';

  @override
  String get panelSceneChoose => 'Scen';

  @override
  String get panelSceneMissing => 'Scenen hittades inte – välj igen';

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
  String get guidedConnectTitle => 'Konfigurera broker';

  @override
  String get guidedConnectIntro =>
      'Vi testar varje steg i anslutningen och visar dina Zigbee-enheter.';

  @override
  String get guidedBaseTopic => 'Bastopic';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Testa och anslut';

  @override
  String get guidedTesting => 'Testar anslutningen…';

  @override
  String get stepResolve => 'Lösa upp värd';

  @override
  String get stepTcp => 'TCP-anslutning';

  @override
  String get stepConnack => 'MQTT-handskakning';

  @override
  String get stepAuth => 'Autentisering';

  @override
  String get stepDevices => 'Söker efter enheter';

  @override
  String get diagResolveFail =>
      'Värdnamnet kunde inte lösas upp. Kontrollera adressen du angav.';

  @override
  String get diagResolveTimeout =>
      'Upplösningen av värden tog för lång tid. Kontrollera adress och nätverk.';

  @override
  String get diagTcpFail =>
      'Brokern tog inte emot anslutningen. Kontrollera att din MQTT-broker (oftast Mosquitto) körs och tar emot anslutningar från andra enheter, och att adress och port (oftast 1883) stämmer.';

  @override
  String get diagTcpTimeout =>
      'Anslutningen till servern tog för lång tid. Den kan vara offline eller oåtkomlig.';

  @override
  String get diagConnackFail =>
      'Servern slutförde inte MQTT-handskakningen. Se till att det är en MQTT-server (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'Brokern svarade inte på inloggningen i tid. Home Assistant kan behöva några sekunder för att kontrollera den, försök igen.';

  @override
  String get diagAuthRejected =>
      'Servern avvisade användarnamn eller lösenord. Kontrollera dina uppgifter.';

  @override
  String get diagAuthRefused =>
      'Servern avvisade anslutningen. Kontrollera anslutningsinställningarna.';

  @override
  String get diagResolveLocalName =>
      'Telefonen hittade inte det här namnet. Android kan ofta inte slå upp namn som slutar på .local, så ange IP-adressen i stället (Home Assistant visar den under Inställningar › System › Nätverk).';

  @override
  String get diagTcpHaNoBroker =>
      'Det här är din Home Assistant, men ingen MQTT-broker körs på den. Installera och starta tillägget Mosquitto broker (Inställningar › Tillägg) och försök igen.';

  @override
  String get diagTcpSmlightClosed =>
      'Det här är din SMLIGHT-hubb, men dess MQTT-broker tar inte emot anslutningar från andra enheter. Öppna Settings › MQTT på hubbens webbsida, slå på Allow External, spara och försök igen.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Zigbee2MQTT kör på den här adressen men når sin broker under ett annat namn (se Zigbee2MQTT › Settings › MQTT › Server). Är det en annan maskin, skriv in dess adress, oftast med port 1883. Är det en container på den här maskinen, publicera dess port (ports: \"1883:1883\") och låt den lyssna på nätverket, och försök sedan igen.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Zigbee2MQTT körs på den här adressen, men dess MQTT-broker tar inte emot anslutningar från andra enheter. Mosquitto lyssnar bara på sin egen dator tills du lägger till raderna ”listener 1883” och ”allow_anonymous true” i mosquitto.conf (eller ställer in ett lösenord). Starta om Mosquitto och försök igen.';

  @override
  String get diagAuthRejectedHa =>
      'Home Assistants broker nekade inloggningen. Använd namn och lösenord för en Home Assistant-användare (Inställningar › Personer › Användare); helst en egen användare bara för MQTT.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hittade $count enheter',
      one: 'Hittade 1 enhet',
    );
    return '$_temp0';
  }

  @override
  String get foundDevicesHint =>
      'Dina Zigbee-enheter är synliga. Fortsätt till din instrumentpanel.';

  @override
  String get noDevicesTitle => 'Ansluten – inga enheter hittade ännu';

  @override
  String get noDevicesHint =>
      'ZigDash ser servern men har ännu inte hittat några Zigbee-enheter. Du kan starta ihopparning.';

  @override
  String get startPairing => 'Starta ihopparning';

  @override
  String get pairingEnabled =>
      'Ihopparning är aktiverad. Tryck på ihopparningsknappen på din enhet.';

  @override
  String get continueToDashboard => 'Fortsätt till instrumentpanelen';

  @override
  String get guidedBackToForm => 'Redigera inställningar';

  @override
  String get guidedStuckTitle => 'Fastnat? Fråga en människa';

  @override
  String get guidedStuckBody =>
      'Två försök utan anslutning. Berätta vilken hubb du har och vad du skrev, så hjälper vi dig att hitta den.';

  @override
  String get guidedStuckTelegram => 'Fråga i Telegram';

  @override
  String get guidedStuckHelp => 'Tips och e-post';

  @override
  String ladderTriedHint(Object count) {
    return 'Försökte $count adresser';
  }

  @override
  String get guidedSaveFailed =>
      'Det gick inte att spara anslutningen. Försök igen.';

  @override
  String get setupWelcomeTitle => 'Välkommen till ZigDash';

  @override
  String get setupWelcomeHeadline => 'Ditt Zigbee-hem, i mobilen';

  @override
  String get setupWelcomeBody =>
      'Allt du behöver är en liten hubb som kör Zigbee2MQTT: en SMLIGHT-hubb, en Raspberry Pi eller vilken Linux-dator som helst. Ingen Home Assistant behövs, och har du det fungerar ZigDash med det också. Allt stannar lokalt, utan moln.';

  @override
  String get setupFindMySetup => 'Hitta min installation';

  @override
  String get setupErrPageTitle => 'Zigbee2MQTT-sidan svarade inte';

  @override
  String get setupErrPageBody =>
      'Ingen Zigbee2MQTT-sida svarade på den adressen. Öppna den i telefonens webbläsare för att kontrollera och kopiera adressen exakt (med port, ofta 8080). Om sidan ber om en token, ange brokeruppgifterna i stället.';

  @override
  String get setupErrPageAction => 'Försök igen';

  @override
  String get setupLookWider => 'Sök i hela nätverket';

  @override
  String get setupAsk => 'Vad driver ditt Zigbee?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'På en Raspberry Pi, en server eller i Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'Med tillägget Zigbee2MQTT, eller ZHA';

  @override
  String get setupAskSmlight => 'En SMLIGHT-hubb';

  @override
  String get setupAskSmlightSub => 'SLZB eller SMHUB med Zigbee2MQTT';

  @override
  String get setupAskNothing => 'Inget ännu?';

  @override
  String get setupAskHaWhich => 'Hur kör din Home Assistant Zigbee?';

  @override
  String get setupAskHaZ2m => 'Tillägget Zigbee2MQTT';

  @override
  String get setupAskHaZ2mSub => 'Logga in med Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, Home Assistants egna Zigbee';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, utan Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Anslut till min Zigbee2MQTT-sida';

  @override
  String get setupManualEntryAdvanced => 'Ange brokeruppgifter (avancerat)';

  @override
  String get z2mPageTitle => 'Din Zigbee2MQTT-sida';

  @override
  String get z2mPageBody =>
      'Adressen i webbläsaren när Zigbee2MQTT-sidan är öppen, den där du parkopplar enheter. Inget MQTT-användarnamn eller lösenord behövs.';

  @override
  String get z2mPageLabel => 'Sidans adress';

  @override
  String get z2mPageConnect => 'Anslut';

  @override
  String z2mPageFoundName(String host, String ip) {
    return 'Hittade $host på $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Inget svarade för $host i det här nätverket';
  }

  @override
  String get engineNeedsBrokerTitle => 'Automationer behöver din MQTT-broker';

  @override
  String get engineNeedsBrokerBody =>
      'Det här hemmet ansluter via Zigbee2MQTT-sidan, vilket räcker för dina instrumentpaneler. Automationer, larm och historik körs i ZigDash Engine på din hubb, som pratar via din MQTT-broker. Ange dess uppgifter en gång, så ansluter ZigDash via brokern från och med då.';

  @override
  String get engineNeedsBrokerButton => 'Ange brokeruppgifter';

  @override
  String get connFromPageNote =>
      'Det här hemmet ansluter via Zigbee2MQTT-sidan. Ange din MQTT-broker (oftast samma maskin, port 1883) för att slå på automationer, larm och historik. När du sparat ansluter ZigDash via brokern.';

  @override
  String get setupManualEntry => 'Ange uppgifter manuellt';

  @override
  String get setupScanningTitle => 'Letar efter en anslutning…';

  @override
  String get setupScanningHint =>
      'Håll den här enheten på samma lokala nätverk som din Zigbee2MQTT-värd.';

  @override
  String get setupCandidateFound => 'Möjlig anslutning hittad';

  @override
  String get setupNoCandidatesTitle => 'Ingen anslutning hittades';

  @override
  String get setupNoCandidatesBody => 'Var kör Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: se till att MQTT-broker-tillägget (t.ex. Mosquitto) och Zigbee2MQTT-tillägget är installerade och körs.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: kontrollera att din broker (t.ex. Mosquitto) och Zigbee2MQTT-tjänsten körs och att port 1883 är nåbar.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: öppna webbgränssnittet, gå till Settings > MQTT, slå på Allow External så att telefonen når brokern, och kontrollera att Zigbee2MQTT körs.';

  @override
  String get setupTryAgain => 'Försök igen';

  @override
  String get reminderButton => 'Påminn mig i morgon';

  @override
  String get reminderSet => 'Vi påminner dig i morgon, på den här telefonen.';

  @override
  String get reminderNoPermission =>
      'Aviseringar är avstängda för ZigDash, så det blir ingen påminnelse. Du kan slå på dem i Androids inställningar.';

  @override
  String get reminderChannel => 'Påminnelse om konfiguration';

  @override
  String get reminderTitle => 'Slutför konfigurationen av ZigDash';

  @override
  String get reminderBody =>
      'Hemma på ditt wifi? Tryck för att försöka igen: det tar ungefär en minut.';

  @override
  String get setupWelcomeNoZ2m => 'Inget Zigbee2MQTT än?';

  @override
  String get setupWelcomeDemo => 'Prova demohemmet';

  @override
  String get setupWelcomeHubs => 'Vilken hubb som passar';

  @override
  String get haConnectTitle => 'Anslut via Home Assistant';

  @override
  String get haConnectIntro =>
      'Din telefon når inte mäklaren, men den når Home Assistant. Logga in en gång, så pratar ZigDash med Zigbee2MQTT via Home Assistant: hemma eller borta, utan mäklarinställningar.';

  @override
  String get haConnectAddressHelp =>
      'Adressen du öppnar Home Assistant med: 192.168.1.20:8123, eller en fjärradress som din Nabu Casa- eller Cloudflare-adress';

  @override
  String get haConnectSignInHelp =>
      'Home Assistants egen inloggning öppnas i din webbläsare. ZigDash ser aldrig ditt lösenord.';

  @override
  String get haConnectKeeps =>
      'ZigDash behåller den här inloggningen på din telefon och agerar som du i Home Assistant, bara för MQTT. Avsluta det när som helst i Home Assistant under Profil › Säkerhet.';

  @override
  String get haConnectTokenHelp =>
      'I Home Assistant öppnar du din profil, sedan Säkerhet › Långlivade åtkomsttoken › Skapa token. Kopiera den och klistra in den här. ZigDash behåller den på den här telefonen för att ansluta; ta bort den i Home Assistant när du vill avsluta.';

  @override
  String get haConnectWithToken => 'Anslut med token';

  @override
  String get haConnectChecking => 'Kontrollerar Home Assistant…';

  @override
  String get setupStillChecking =>
      'Kontrollerar fortfarande. Det kan ta upp till 30 sekunder.';

  @override
  String get aiHelpTitle => 'Fastnat? Fråga din AI-assistent';

  @override
  String get aiHelpBody =>
      'ZigDash skriver ihop vad den hittade för ChatGPT, Claude, Gemini eller en annan AI-app, utan lösenord eller adresser. Du ser det innan det delas.';

  @override
  String get aiHelpButton => 'Fråga en AI';

  @override
  String get aiHelpPreviewTitle => 'Det här delas';

  @override
  String get aiHelpShare => 'Dela till en AI-app';

  @override
  String get aiHelpCopied => 'Kopierat. Klistra in det i valfri AI-chatt.';

  @override
  String get haConnectWhereAddress =>
      'Osäker på vilken den är? I Home Assistant-appen öppnar du Inställningar › Companion-app och trycker på din server: adressen finns där. På en dator är det adressen webbläsaren visar när Home Assistant är öppet.';

  @override
  String get haFindLooking => 'Letar efter Home Assistant i det här nätverket…';

  @override
  String get haFindSeveral =>
      'Hittade mer än en Home Assistant. Tryck på den du vill använda:';

  @override
  String get haFindNone =>
      'Den här telefonen ser inte Home Assistant på det här wifi-nätverket. Använd adressen som din Home Assistant-app öppnar: ofta en fjärradress, som https://abcd1234.ui.nabu.casa eller https://mitthem.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Adressen ligger i ett annat nätverk än den här telefonen, som är på $network. Använd adressen som din Home Assistant-app öppnar, ofta en fjärradress, eller anslut telefonen till nätverket där Home Assistant finns.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Telefonen hittade inte det namnet: Android kan ofta inte öppna .local-namn. Skriv Home Assistants IP-adress (som 192.168.1.20:8123) eller dess fjärradress.';

  @override
  String get haConnectRemoteUnreachable =>
      'Inget svarade på den fjärradressen. Öppna den i telefonens webbläsare för att kontrollera att den fungerar, och kopiera den exakt som din Home Assistant-app visar den.';

  @override
  String get setupNoWifiHa => 'Använder du Home Assistant? Logga in';

  @override
  String get haConnectNotAdmin =>
      'Din Home Assistant-användare är inte administratör. ZigDash behöver en för Home Assistants MQTT. Logga in som administratör, eller klistra in en token som en administratör skapat.';

  @override
  String get haConnectNoMqtt =>
      'Den här Home Assistant har ingen MQTT-integration. Zigbee2MQTT behöver också en: lägg till tillägget Mosquitto broker och MQTT-integrationen i Home Assistant och försök igen.';

  @override
  String get haConnectSignInFailed =>
      'Inloggningen slutfördes inte. Försök igen, eller använd en långlivad token.';

  @override
  String get setupHaShortcut =>
      'Kör Zigbee2MQTT i Home Assistant? Hoppa över brokern och dess inloggning: logga in med ditt administratörskonto i Home Assistant. Det fungerar från alla nätverk.';

  @override
  String get haConnectButton => 'Anslut via Home Assistant';

  @override
  String get haConnectManualLink =>
      'Använder du Home Assistant? Anslut via den i stället';

  @override
  String get haConnectEmptyNote =>
      'Når den här telefonen inte mäklaren? Home Assistant kan bära anslutningen åt dig.';

  @override
  String get haHomeConnected => 'Ansluten via Home Assistant';

  @override
  String get haHomeChange =>
      'Om inloggningen slutar fungera, på en ny telefon eller efter att du tagit bort token i Home Assistant, logga in igen här. Du kan också avsluta den i Home Assistant under Profil › Säkerhet.';

  @override
  String get haHomeSignInAgain => 'Logga in igen';

  @override
  String get haHomeRemote => 'Fjärradress för Home Assistant (valfritt)';

  @override
  String get setupAuthTitle => 'Den här brokern kräver inloggning';

  @override
  String setupAuthBody(Object host) {
    return 'Ange MQTT-användarnamnet och lösenordet för $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Användarnamnet eller lösenordet avvisades. Kontrollera dem och försök igen.';

  @override
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT loggar redan in på den här brokern: webbsidan visar användarnamnet under Inställningar › MQTT. Använd den användaren och dess lösenord.';

  @override
  String get setupAuthWhich =>
      'Det här är MQTT-inloggningen, inte lösenordet till hubbens webbsida.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: använd en Home Assistant-användare. De flesta skapar en bara för MQTT under Inställningar › Personer › Användare, och Mosquitto-tillägget godtar den.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi eller Docker: användaren och lösenordet från Mosquittos lösenordsfil, samma som i configuration.yaml för Zigbee2MQTT under mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: inloggningen som visas på hubbens webbsida under Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'Kontrollerar anslutningen…';

  @override
  String get setupReviewTitle => 'Dina enheter';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enheter hittades.',
      one: '1 enhet hittades.',
    );
    return '$_temp0 Välj vad som hamnar på din första dashboard.';
  }

  @override
  String get setupReviewLastStep =>
      'Sista steget: bocka för enheterna du vill ha och tryck på Skapa instrumentpanel längst ner.';

  @override
  String get setupLeaveTitle => 'Skapa instrumentpanelen?';

  @override
  String get setupLeaveBody =>
      'Dina enheter är hittade. Skapa instrumentpanelen nu, eller börja om och förlora den här listan.';

  @override
  String get setupStartOver => 'Börja om';

  @override
  String setupCreateWithCount(Object count) {
    return 'Skapa dashboard med $count';
  }

  @override
  String get setupReviewNoneSelected =>
      'Inget är markerat ännu. Markera enheterna du vill ha på dashboarden, eller skapa den tom och lägg till brickor senare.';

  @override
  String get setupCreateEmpty => 'Skapa en tom dashboard';

  @override
  String get setupGroupOther => 'Andra enheter';

  @override
  String get setupGroupUnsupported => 'Enheter som inte stöds';

  @override
  String get setupCreatingTitle => 'Skapar din dashboard…';

  @override
  String get setupReadyTitle => 'Din dashboard är klar';

  @override
  String setupReadyBody(Object count) {
    return '$count kontroller skapade.';
  }

  @override
  String get setupOpenDashboard => 'Öppna dashboard';

  @override
  String get setupErrUnreachableTitle => 'Kan inte nå den här adressen';

  @override
  String get setupErrUnreachableBody =>
      'Den här enheten och Zigbee2MQTT-värden kan inte nå varandra. Kontrollera att båda är på samma lokala nätverk.';

  @override
  String get setupErrUnreachableAction => 'Försök igen';

  @override
  String get setupErrPortClosedTitle => 'Inget svarar på den här porten';

  @override
  String get setupErrPortClosedBody =>
      'Värden är nåbar, men ingen MQTT-broker svarade. Kontrollera att brokern körs och att porten är rätt.';

  @override
  String get setupErrPortClosedAction => 'Försök igen';

  @override
  String get setupErrAuthRequiredTitle => 'Inloggning krävs';

  @override
  String get setupErrAuthRequiredBody =>
      'Den här brokern kräver användarnamn och lösenord.';

  @override
  String get setupErrAuthRequiredAction => 'Ange inloggning';

  @override
  String get setupErrAuthRejectedTitle => 'Inloggning avvisad';

  @override
  String get setupErrAuthRejectedBody => 'Brokern avvisade dessa uppgifter.';

  @override
  String get setupErrAuthRejectedAction => 'Försök igen';

  @override
  String get setupErrNotZ2mTitle => 'Här finns inget Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'En MQTT-broker svarar här, men inga Zigbee2MQTT-topics hittades. Det kan vara en annan broker.';

  @override
  String get setupErrNotZ2mAction => 'Välj en annan';

  @override
  String get setupErrNoDevicesTitle => 'Inga enheter mottogs';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT körs, men inga enheter publicerades under kontrollen. Parkoppla enheter i Zigbee2MQTT först.';

  @override
  String get setupErrNoDevicesAction => 'Kontrollera igen';

  @override
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT skickade inte sin enhetslista';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT svarar, men enhetslistan kom inte. Det händer oftast efter att MQTT-brokern startats om: Zigbee2MQTT före 2.14.2 skickar listan igen först när det själv startar om. Starta om Zigbee2MQTT (eller uppdatera det) och försök igen.';

  @override
  String get setupErrListMissingAction => 'Försök igen';

  @override
  String get setupErrHaNoZ2mTitle =>
      'Inget Zigbee2MQTT i den här Home Assistant';

  @override
  String get setupErrHaNoZ2mBody =>
      'Du är inloggad i Home Assistant, men Zigbee2MQTT skickar inget via dess MQTT. Om dina Zigbee-enheter finns i ZHA (Home Assistants inbyggda Zigbee) kan ZigDash inte se dem: det fungerar med Zigbee2MQTT. Om du använder tillägget Zigbee2MQTT, öppna det i Home Assistant, kontrollera att det är igång och försök igen.';

  @override
  String get setupErrHaNoZ2mAction => 'Försök igen';

  @override
  String get setupErrScanFailedTitle => 'Inget lokalt nätverk';

  @override
  String get setupErrScanFailedBody =>
      'Kunde inte fastställa den här enhetens lokala nätverk. Anslut till wifi och försök igen.';

  @override
  String get setupErrScanFailedAction => 'Försök igen';

  @override
  String get setupNoWifiTitle => 'Telefonen är inte på wifi';

  @override
  String get setupNoWifiMobileData =>
      'Den använder mobildata och ser därför inte enheterna hemma. Slå på wifi och anslut till hemnätverket: installationen börjar om av sig själv.';

  @override
  String get setupNoWifiOffline =>
      'Telefonen har ingen nätverksanslutning. Slå på wifi och anslut till hemnätverket: installationen börjar om av sig själv.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash hittar inte telefonens wifi-adress. Kontrollera att wifi är på och anslutet till hemnätverket: installationen börjar om av sig själv. På VPN eller borta? Ange uppgifterna manuellt.';

  @override
  String get setupOpenWifiSettings => 'Öppna wifi-inställningar';

  @override
  String get setupWaitingForWifi => 'Väntar på wifi…';

  @override
  String get setupErrSaveFailedTitle => 'Kunde inte spara';

  @override
  String get setupErrSaveFailedBody =>
      'Det gick inte att spara din installation. Inget sparades halvfärdigt — du kan tryggt försöka igen.';

  @override
  String get setupErrSaveFailedAction => 'Försök igen';

  @override
  String get setupErrUnknownTitle => 'Något gick fel';

  @override
  String get setupErrUnknownBody => 'Ett oväntat fel uppstod.';

  @override
  String get setupErrUnknownAction => 'Försök igen';

  @override
  String get setupErrLoginNoAnswerTitle =>
      'Brokern svarade inte på inloggningen';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Din broker hittades, men den svarade inte på användarnamn och lösenord i tid. Mosquitto-tillägget i Home Assistant kontrollerar inloggningar mot Home Assistant, vilket kan ta några sekunder på en Raspberry Pi. Försök igen och kontrollera att användaren finns i Home Assistant.';

  @override
  String get setupErrLoginNoAnswerAction => 'Försök igen';

  @override
  String get setupNoZ2mTitle =>
      'Din broker fungerar, men Zigbee2MQTT publicerar inte här';

  @override
  String setupNoZ2mBody(String base) {
    return 'Vi lyssnade på $base/bridge och hörde ingenting.';
  }

  @override
  String get setupBaseTopicQuestion => 'Använder du ett annat basämne?';

  @override
  String get setupGuidesTitle => 'Konfigurera Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'Prova demon så länge';

  @override
  String get setupPlatformQuestion => 'Medan vi letar: var kör Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => 'Var kör Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Välj en anslutning';

  @override
  String get setupScanDoneHint =>
      'Mer än en broker svarade. Välj den som Zigbee2MQTT använder.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'SMLIGHT-hubb';

  @override
  String get setupPlatformPi => 'Raspberry Pi eller Docker';

  @override
  String get setupPlatformZha => 'ZHA, inget Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash visar enheter från Zigbee2MQTT och ser därför inte enheter i ZHA, Home Assistants egen Zigbee. Du kan prova demohemmet för att se hur ZigDash fungerar.';

  @override
  String get setupPlatformNotSure => 'Vet inte';

  @override
  String setupScanProgress(int checked, int total) {
    return 'Kontrollerade $checked av $total adresser';
  }

  @override
  String get setupScanHintHa =>
      'Letar efter Home Assistant och dess MQTT-broker…';

  @override
  String get setupScanHintSmlight => 'Letar efter din SMLIGHT-hubb…';

  @override
  String get setupScanHintPi => 'Letar efter en MQTT-broker i ditt nätverk…';

  @override
  String setupHubSeenHa(String host) {
    return 'Hittade Home Assistant på $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Hittade Zigbee2MQTT på $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Hittade din SMLIGHT-hubb på $host';
  }

  @override
  String get setupHubSeenHint => 'Letar fortfarande efter dess MQTT-broker…';

  @override
  String get setupNoBrokerHaTitle =>
      'Hittade Home Assistant, men ingen MQTT-broker';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant finns på $host, men inget svarar på MQTT-port 1883. Öppna Inställningar › Tillägg i Home Assistant, installera och starta tillägget Mosquitto broker och försök igen.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Använder du Home Assistants inbyggda Zigbee (ZHA) i stället för Zigbee2MQTT? ZigDash fungerar bara med Zigbee2MQTT och ser därför inte ZHA-enheter. Demon visar vad du skulle få.';

  @override
  String get setupVpnHint =>
      'En VPN är på, och den kan dölja ditt hemnätverk för sökningen. Är du hemma, stäng av VPN:en och tryck på Försök igen. Eller låt den vara på och tillåt åtkomst till lokalt nätverk (LAN) i VPN-appens inställningar.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Hittade Zigbee2MQTT, men dess broker går inte att nå';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT finns på $host, men dess MQTT-broker tar inte emot anslutningar från din telefon. Mosquitto 2 lyssnar bara på själva hubben tills konfigurationen har \'listener 1883\' och \'allow_anonymous true\' (eller en inloggning). Starta om den och försök igen.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Hittade din SMLIGHT-hubb, men MQTT är av';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Din hubb finns på $host, men dess MQTT-broker går inte att nå. Öppna Settings › MQTT i hubbens webbgränssnitt, slå på Allow External och kontrollera att Zigbee2MQTT kör. Försök sedan igen.';
  }

  @override
  String get setupZ2mAsking => 'Frågar Zigbee2MQTT var dess broker finns…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Din broker tar bara emot anslutningar från sin egen maskin';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT använder $server, och inget svarar där från din telefon. Mosquitto 2 gör så som standard. Lägg till de här två raderna i mosquitto.conf, starta om Mosquitto och försök igen:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Hellre inloggning än öppen åtkomst? Använd en password_file i stället för allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT når sin broker via ett namn som din telefon inte kan använda';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT använder $server. ”$name” är ett namn som bara Zigbee2MQTT:s maskin känner till, en Docker-tjänst eller ett värdnamn. Skriv i stället in broker-maskinens IP-adress med port $port. Kör brokern i en container måste dess port också publiceras på maskinen (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'Zigbee2MQTT:s webbsida är skyddad med en token, så appen kunde inte läsa var dess broker finns. Skriv in broker-adressen från Zigbee2MQTT › Settings › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT använder brokern på $server, men den svarade inte din telefon. Kontrollera att brokern körs och att telefonen är på samma nätverk.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Anslut till $host';
  }

  @override
  String get setupNotFoundHa =>
      'Ingen Home Assistant hittades på det här nätverket. Kontrollera att telefonen är på samma Wi-Fi som Home Assistant (inte ett gästnät) och försök igen. Vet du adressen, ange den nedan.';

  @override
  String get setupNotFoundSmlight =>
      'Ingen SMLIGHT-hubb hittades på det här nätverket. Kontrollera att hubben är på och att telefonen är på samma Wi-Fi, och försök igen. Vet du adressen, ange den nedan.';

  @override
  String get setupNotFoundPi =>
      'Ingen MQTT-broker hittades i det här nätverket. Kontrollera att Mosquitto kör och lyssnar på nätverket (port 1883) och att telefonen är på samma Wi-Fi. Försök sedan igen.';

  @override
  String get setupAddressQuestionHa => 'Var öppnar du Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'Vilken adress har din SMLIGHT-hubb?';

  @override
  String get setupAddressQuestionPi =>
      'Vilken adress har datorn som kör Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      'Vilken adress har din hubb, eller datorn som kör Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'En adress som 192.168.1.20, ett namn eller länken från din webbläsare';

  @override
  String get setupAddressCheck => 'Kontrollera den här adressen';

  @override
  String setupAddressNothing(String host) {
    return 'Inget svarade på $host. Kontrollera adressen och att telefonen är på samma Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return '$host kunde inte slås upp. Namn som slutar på .local misslyckas ofta på Android; prova IP-adressen i stället. Home Assistant visar den under Inställningar › System › Nätverk.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host går inte att hitta från den här telefonen; Android kan ofta inte slå upp .local-namn. Tryck på $button ovan och använd adressen du öppnar Home Assistant med i webbläsaren, eller skriv IP-adressen här. Home Assistant visar den under Inställningar › System › Nätverk.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host finns inte på ditt hemnätverk. Använd adressen som fungerar på ditt Wi-Fi, inte en fjärrlänk som Nabu Casa eller DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Ange en adress först.';

  @override
  String get setupChoicesTitle => 'Vilket av dessa passar dig?';

  @override
  String get setupChoiceNoHub => 'Jag har ingen hubb än';

  @override
  String get setupChoiceNoHubSub => 'Se små hubbar som kör Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'Jag använder Home Assistant';

  @override
  String get setupChoiceHaSub => 'Leta efter den på homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash ansluter till MQTT-mäklaren i Home Assistant, tillägget Mosquitto broker under Inställningar › Tillägg, och Zigbee2MQTT måste också använda den. Om homeassistant.local inte hittas anger du Home Assistants IP-adress nedan. Den finns under Inställningar › System › Nätverk.';

  @override
  String get setupChoiceOther => 'Min hubb är på ett annat nätverk';

  @override
  String get setupChoiceOtherSub => 'Ett gästnätverk eller en andra router';

  @override
  String get setupChoiceOtherNote =>
      'Telefonen måste nå din hubb. Ett gästnätverk, eller en andra router med eget wifi, håller dem isär. Anslut till det wifi som hubben är på och tryck på Försök igen. Eller ange hubbens IP-adress nedan, eller prova något av dessa vanliga namn:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Din telefon är $ip, så hubben börjar oftast med $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Använder du Home Assistant? Värden är adressen du öppnar Home Assistant med, port 1883.';

  @override
  String get demoBannerText => 'Du är i demoläge';

  @override
  String get demoBannerAction => 'Anslut ditt hem';

  @override
  String get deviceOn => 'På';

  @override
  String get deviceOff => 'Av';

  @override
  String get deviceOpen => 'Öppen';

  @override
  String get deviceClosed => 'Stängd';

  @override
  String get deviceMotion => 'Rörelse';

  @override
  String get deviceClear => 'Lugnt';

  @override
  String get deviceLeakDetected => 'Läcka upptäckt';

  @override
  String get deviceSmokeDetected => 'Rök upptäckt';

  @override
  String get deviceGasDetected => 'Gas upptäckt';

  @override
  String get deviceWaiting => 'Väntar på första rapport';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on på · $off av';
  }

  @override
  String get deviceBrightness => 'Ljusstyrka';

  @override
  String get deviceWhite => 'Vit';

  @override
  String get deviceColor => 'Färg';

  @override
  String get deviceHue => 'Nyans';

  @override
  String get devicePosition => 'Position';

  @override
  String get deviceControls => 'Reglage';

  @override
  String deviceBattery(int percent) {
    return 'Batteri $percent %';
  }

  @override
  String get deviceToggle => 'Slå på eller av';

  @override
  String get deviceMore => 'Mer';

  @override
  String get sectionLights => 'Belysning';

  @override
  String get sectionSwitchesCovers => 'Brytare och persienner';

  @override
  String get sectionSensors => 'Sensorer';

  @override
  String get sectionOther => 'Övrigt';

  @override
  String get homeFirstName => 'Mitt hem';

  @override
  String homeNumberedName(int number) {
    return 'Hem $number';
  }

  @override
  String get dashAddTile => 'Lägg till ruta';

  @override
  String get addTileSearch => 'Sök enheter';

  @override
  String get addTileNotOnDashboard => 'Inte på någon panel';

  @override
  String get addTileAllDevices => 'Alla enheter';

  @override
  String get addTileReading => 'Mätvärde';

  @override
  String get addTileReadingSubtitle =>
      'Ett värde från en enhet eller ett topic';

  @override
  String get readingShowAs => 'Visa som';

  @override
  String get readingStyleValue => 'Värde';

  @override
  String get readingStyleGauge => 'Mätare';

  @override
  String get gaugeBands => 'Färgintervall';

  @override
  String get gaugeBandsHelper =>
      'Upp till tre. Intervallet som värdet ligger i färgar bågen.';

  @override
  String get gaugeBandFrom => 'Från';

  @override
  String get gaugeBandTo => 'Till';

  @override
  String get gaugeBandAdd => 'Lägg till intervall';

  @override
  String get gaugeBandRemove => 'Ta bort intervall';

  @override
  String get gaugeToneNormal => 'Normal';

  @override
  String get gaugeToneGood => 'Bra';

  @override
  String get gaugeToneAttention => 'Obs';

  @override
  String get addTileCustom => 'Egen MQTT-ruta';

  @override
  String get addTileCustomSubtitle => 'Valfri rutetyp, inställd med topic';

  @override
  String get addTileNoDevices =>
      'Inga enheter att visa. Anslut till din broker eller para en enhet i Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Lägg till';

  @override
  String get addTileName => 'Namn';

  @override
  String addTileNameHint(String model) {
    return 't.ex. $model';
  }

  @override
  String get addTileSection => 'Sektion';

  @override
  String get addTileNoSection => 'Ingen sektion';

  @override
  String get addTileSize => 'Storlek';

  @override
  String get deviceClassColorLight => 'Färglampa';

  @override
  String get deviceClassLight => 'Lampa';

  @override
  String get deviceClassSwitch => 'Brytare eller uttag';

  @override
  String get deviceClassCover => 'Persienn';

  @override
  String get deviceClassLeak => 'Läcka eller rök';

  @override
  String get deviceClassContact => 'Kontakt';

  @override
  String get deviceClassMotion => 'Rörelse';

  @override
  String get deviceClassClimate => 'Klimatsensor';

  @override
  String get deviceClassGeneric => 'Enhet';

  @override
  String get deviceNotResponding => 'Svarar inte';

  @override
  String get homeAdd => 'Lägg till ett hem';

  @override
  String get homeManage => 'Hantera hem';

  @override
  String get homeSwitch => 'Byt hem';

  @override
  String get navDevices => 'Enheter';

  @override
  String get navScenes => 'Scener';

  @override
  String get devicesNewDot => 'Nya enheter';

  @override
  String get editEditing => 'Redigerar';

  @override
  String get editDashboard => 'Panel';

  @override
  String get editDone => 'Klar';

  @override
  String get editAddSection => 'Lägg till sektion';

  @override
  String get editSectionName => 'Sektionens namn';

  @override
  String get editRenameSection => 'Byt namn på sektion';

  @override
  String get editDeleteSection => 'Ta bort sektion';

  @override
  String get editDeleteSectionBody => 'Vad ska hända med rutorna?';

  @override
  String get editKeepTiles => 'Behåll rutorna, ta bort sektionen';

  @override
  String get editDeleteTiles => 'Ta bort rutorna också';

  @override
  String get editMoveToSection => 'Flytta till sektion';

  @override
  String get editEditTile => 'Redigera ruta';

  @override
  String get editRemove => 'Ta bort från panelen';

  @override
  String get editRemoved => 'Ruta borttagen';

  @override
  String get editUndo => 'Ångra';

  @override
  String get editReplaceWithDevice => 'Ersätt med enhetsruta';

  @override
  String get editMoveEarlier => 'Flytta framåt';

  @override
  String get editMoveLater => 'Flytta bakåt';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enheter finns inte på någon panel',
      one: '1 enhet finns inte på någon panel',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Rutalternativ';

  @override
  String get editSave => 'Spara';

  @override
  String get editCancel => 'Avbryt';

  @override
  String get ageJustNow => 'Nyss';

  @override
  String ageMinutes(int n) {
    return 'för $n min sedan';
  }

  @override
  String ageHours(int n) {
    return 'för $n tim sedan';
  }

  @override
  String get statusCantReach => 'Når inte din broker';

  @override
  String get statusWhy => 'Varför?';

  @override
  String get statusWhyTitle => 'Din broker svarar inte';

  @override
  String get statusWhyBody =>
      'ZigDash fortsätter försöka själv. Tills dess visar rutorna sina senast kända värden, nedtonade och med ålder. Kontrollera att brokern är på och att telefonen är på samma nätverk, eller testa anslutningen i dess inställningar.';

  @override
  String get statusSettings => 'Anslutningsinställningar';

  @override
  String get deviceAddToDashboard => 'Lägg till på en dashboard';

  @override
  String get deviceDismiss => 'Avfärda';

  @override
  String get devicesFilterAll => 'Alla';

  @override
  String devicesFilterAttention(int count) {
    return 'Behöver åtgärd · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Inte på någon panel · $count';
  }

  @override
  String get devicesNoMatch => 'Inga enheter matchar';

  @override
  String get deviceBatteryLow => 'Lågt batteri';

  @override
  String get deviceLinkWeak => 'Svag';

  @override
  String get deviceUnsupported => 'Stöds inte av Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'Parkopplingen slutfördes inte';

  @override
  String get deviceNoReport => 'Ingen rapport än';

  @override
  String get devicesAvailabilityOff =>
      'Tillgänglighet är avstängd i Zigbee2MQTT, så offline-enheter visas som Svarar inte.';

  @override
  String get devicesAvailabilityHow => 'Så slår du på den';

  @override
  String get devicesDotBattery => 'Lågt batteri';

  @override
  String get deviceDetails => 'Enhetsdetaljer';

  @override
  String get deviceGone => 'Den här enheten finns inte längre i Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Styrning';

  @override
  String get deviceReadingsTitle => 'Mätvärden';

  @override
  String get deviceHealthTitle => 'Hälsa';

  @override
  String get deviceOnDashboards => 'På dashboards';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT stöder inte den här enheten än, så det finns inget att styra.';

  @override
  String get deviceAddReadingTile => 'Lägg till som mätvärdesruta';

  @override
  String get deviceAddReadingTo => 'Lägga till på vilken dashboard?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Tillagd på $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Länkkvalitet';

  @override
  String get deviceLinkGood => 'Bra';

  @override
  String get devicePowerSource => 'Strömkälla';

  @override
  String get devicePowerBattery => 'Batteri';

  @override
  String get devicePowerMains => 'Elnät';

  @override
  String get deviceLastHeard => 'Senast hörd';

  @override
  String get deviceAvailability => 'Tillgänglighet';

  @override
  String get deviceAvailabilityOff => 'Av i Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Integritetspolicy';

  @override
  String get settingsPrivacySubtitle =>
      'Ingen telemetri. Allt stannar på den här telefonen.';

  @override
  String get homeCurrent => 'Nuvarande hem';

  @override
  String get homeConnection => 'Anslutning';

  @override
  String get homeSwitchTo => 'Byt till det här hemmet';

  @override
  String get homeDelete => 'Ta bort hem';

  @override
  String get devicesSelect => 'Välj en enhet';

  @override
  String get scenesSelect => 'Välj en scen att redigera';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'Välj en enhet';

  @override
  String get panelFormStateTopic => 'Status-topic';

  @override
  String get panelFormCommandTopic => 'Kommando-topic';

  @override
  String get panelFormCommandTopicDerived =>
      'Fylls i från status-topicen tills du ändrar den.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Kopplad till $device';
  }

  @override
  String get panelFormOpenDevice => 'Öppna enhet';

  @override
  String get panelFormUnlink => 'Koppla från';

  @override
  String get panelFormValueChoices => 'Värden från den här enheten';

  @override
  String get panelFormAdvanced => 'Avancerat';

  @override
  String get panelFormAdvancedSubtitle => 'Prefix-åsidosättning, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Tomt = själva prefixet (status för en Zigbee2MQTT-enhet).';

  @override
  String get dashWallDisplay => 'Väggskärm';

  @override
  String get analyticsSetupCheckbox =>
      'Dela anonym användningsdata för att förbättra installationen';

  @override
  String get analyticsWhatsShared => 'Vad som delas';

  @override
  String get analyticsCardTitle => 'Hjälpa till att förbättra ZigDash?';

  @override
  String get analyticsCardBody =>
      'Dela anonym användningsdata: vilka installationssteg som misslyckas och vilka funktioner som används. Aldrig dina enheter, topics eller din broker.';

  @override
  String get analyticsShare => 'Dela';

  @override
  String get analyticsNoThanks => 'Nej tack';

  @override
  String get settingsAnalytics => 'Dela anonym användningsdata';

  @override
  String get settingsAnalyticsSubtitle =>
      'Installationssteg och använda funktioner. Aldrig dina enheter, topics eller din broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Anonym användningsdata. Stäng av med reglaget ovan.';

  @override
  String get dashDefaultName => 'Hem';

  @override
  String get dashExportSaveFile => 'Spara fil';

  @override
  String get dashExportSaved => 'Säkerhetskopian sparades';

  @override
  String get dashImportChooseFile => 'Välj fil';

  @override
  String get dashImportFileUnreadable => 'Det gick inte att läsa filen';

  @override
  String get getHelpTitle => 'Få hjälp';

  @override
  String get getHelpTryFirst => 'Prova det här först';

  @override
  String get getHelpPromise =>
      'Kommer du fortfarande inte vidare? Jag svarar oftast inom 3 dagar, på engelska eller hebreiska. Jag kommer aldrig att be om dina lösenord.';

  @override
  String get getHelpIncluded => 'Det här skickas med';

  @override
  String get getHelpContact => 'Kontakta support';

  @override
  String get getHelpCopy => 'Kopiera uppgifter';

  @override
  String get getHelpCopied => 'Uppgifterna kopierades';

  @override
  String get getHelpLink => 'Kommer du inte vidare? Få hjälp';

  @override
  String get getHelpEmailSubject => 'ZigDash: hjälp att få det att fungera';

  @override
  String get getHelpEmailPrompt => 'Vad försökte du göra, och vad hände?';

  @override
  String get settingsHelpSupport => 'Hjälp & support';

  @override
  String get settingsGetHelp => 'Få hjälp';

  @override
  String get settingsGetHelpSubtitle =>
      'Fungerar det inte? Först tips, sedan kontakt';

  @override
  String get settingsCommunity => 'Gå med i ZigDash-communityn';

  @override
  String get settingsCommunitySubtitle =>
      'Telegram-grupp: frågor, idéer och vad som kommer';

  @override
  String get getHelpCommunity => 'Fråga i Telegram-gruppen';

  @override
  String get demoBannerHelp => 'Få hjälp';

  @override
  String get tipSameWifiTitle => 'Samma Wi-Fi som hubben';

  @override
  String get tipSameWifiBody =>
      'Telefonen måste vara på samma nätverk som hubben, inte ett gästnätverk. Stäng av mobildata medan du konfigurerar.';

  @override
  String get tipBrokerRunningTitle => 'Brokern körs';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: Mosquitto-tillägget är startat. Raspberry Pi: Mosquitto körs. SMLIGHT: Settings › MQTT är påslaget.';

  @override
  String get tipBrokerAcceptsTitle => 'Brokern släpper in telefonen';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: slå på Allow External. Mosquitto 2 tar bara emot anslutningar från själva hubben tills den är inställd på att lyssna på nätverket (port 1883).';

  @override
  String get tipMeshTitle => 'Mesh-Wi-Fi eller två routrar?';

  @override
  String get tipMeshBody =>
      'Om hubben sitter på en andra router kanske telefonen inte ser den. Anslut hubben till huvudroutern, eller anslut via dess adress.';

  @override
  String get tipByAddressTitle => 'Anslut via adress';

  @override
  String get tipByAddressBody =>
      'Hitta hubbens adress i routerns app och tryck sedan på „Ange uppgifter manuellt”.';

  @override
  String get tipSameNetworkTitle => 'Samma nätverk';

  @override
  String get tipSameNetworkBody =>
      'Telefonen och hubben måste vara på samma Wi-Fi. Stäng av mobildata.';

  @override
  String get tipAddressChangedTitle => 'Adressen har ändrats';

  @override
  String get tipAddressChangedBody =>
      'Hubbar kan få en ny adress efter en omstart. Kontrollera den i routerns app och reservera den där så att den förblir densamma.';

  @override
  String get tipRightPortTitle => 'Rätt port';

  @override
  String get tipRightPortBody =>
      'MQTT är oftast 1883 (8883 med TLS). 8080 eller 80 är hubbens webbgränssnitt, inte MQTT.';

  @override
  String get tipStartBrokerTitle => 'Brokern körs';

  @override
  String get tipStartBrokerBody =>
      'Starta Mosquitto eller broker-tillägget och försök igen.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 tar bara emot anslutningar från själva hubben tills den är inställd på att lyssna på nätverket (port 1883).';

  @override
  String get tipMqttLoginTitle => 'MQTT-inloggningen, inte webbinloggningen';

  @override
  String get tipMqttLoginBody =>
      'Lösenordet till hubbens webbgränssnitt är oftast inte MQTT-lösenordet. Home Assistant: använd en Home Assistant-användare, eller inloggningen som är angiven i Mosquitto-tillägget.';

  @override
  String get tipSpacesTitle => 'Leta efter mellanslag';

  @override
  String get tipSpacesBody =>
      'När du kopierar ett lösenord kan ett mellanslag följa med i slutet.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT använder den här brokern';

  @override
  String get tipZ2mBrokerBody =>
      'Kontrollera i Zigbee2MQTT:s inställningar att dess MQTT-server är samma broker.';

  @override
  String get tipBaseTopicTitle => 'Basämne';

  @override
  String get tipBaseTopicBody =>
      'Om du har ändrat basämnet från „zigbee2mqtt”, ange det i den manuella konfigurationen.';

  @override
  String get tipPairFirstTitle => 'Parkoppla enheter först';

  @override
  String get tipPairFirstBody =>
      'Öppna Zigbee2MQTT:s webbgränssnitt och parkoppla minst en enhet, kontrollera sedan igen.';

  @override
  String get tipRestartZ2mTitle => 'Starta om Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'Om enheter är parkopplade men inga dyker upp, starta om Zigbee2MQTT så att den publicerar sin enhetslista.';

  @override
  String get tipNumberAddressTitle => 'Använd sifferadressen';

  @override
  String get tipNumberAddressBody =>
      'Namn som slutar på .local fungerar inte på alla Android-telefoner. Prova hubbens sifferadress, till exempel 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Port och protokoll';

  @override
  String get tipPortProtocolBody =>
      'TCP på 1883 är det vanliga. Välj TLS eller WebSocket bara om din broker är inställd för det.';

  @override
  String get tipManualLoginTitle => 'Inloggning';

  @override
  String get tipManualLoginBody =>
      'Lämna användarnamn och lösenord tomma om din broker inte har några. Annars använder du MQTT-inloggningen, inte inloggningen till hubbens webbgränssnitt.';

  @override
  String get tipHubOnTitle => 'Är hubben på?';

  @override
  String get tipHubOnBody =>
      'Ett strömavbrott eller en uppdatering kan ha startat om den. Ge den en minut efter att den är tillbaka.';

  @override
  String get tipAwayTitle => 'Är du hemma?';

  @override
  String get tipAwayBody =>
      'När du är borta behöver appen en extern adress (till exempel Tailscale). Ange den i hemmets anslutningsinställningar.';

  @override
  String get tipTailscaleIpTitle => 'Använd Tailscale-IP:n, inte namnet';

  @override
  String get tipTailscaleIpBody =>
      'Namn som slutar på .ts.net löses ofta inte upp inuti appar. Öppna Tailscale-appen på telefonen och kontrollera att den är ansluten. Använd sedan hubbens 100.x.y.z-adress som extern värd.';

  @override
  String get tipHomeAddressChangedTitle => 'Har adressen ändrats?';

  @override
  String get tipHomeAddressChangedBody =>
      'Efter en omstart av routern kan hubben få en ny adress. Reservera adressen i routerns app och uppdatera sedan hemmet.';

  @override
  String get tipRestartZ2mButtonTitle => 'Starta om Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'Om brokern har startats om är Zigbee2MQTT:s enhetslista borta tills Zigbee2MQTT startas om. Använd knappen „Starta om Zigbee2MQTT” på fliken „Enheter”.';

  @override
  String get tipZ2mRunningTitle => 'Körs Zigbee2MQTT?';

  @override
  String get tipZ2mRunningBody =>
      'Öppna dess webbgränssnitt. Om det inte laddas, starta om Zigbee2MQTT på hubben.';

  @override
  String get tipCantConnectTitle => 'Kan inte ansluta till hubben';

  @override
  String get tipCantConnectBody =>
      'Samma Wi-Fi, brokern körs, Allow External eller Mosquitto lyssnar på nätverket – anslut sedan via adress.';

  @override
  String get tipDeviceWrongTitle => 'En enhet visas fel eller svarar inte';

  @override
  String get tipDeviceWrongBody =>
      'Kontrollera den först i Zigbee2MQTT:s webbgränssnitt. Om den fungerar där, använd „Rapportera ett problem”.';

  @override
  String get tipHowDoITitle => 'Hur gör jag …';

  @override
  String get tipHowDoIBody =>
      'Scener, väggskärm, scheman och säkerhetskopior finns i „Hjälp & guide”.';

  @override
  String get tipRenameHomeTitle => 'Byt namn på ett hem';

  @override
  String get tipRenameHomeBody =>
      'Ett hem döpt efter sin adress? Inställningar › Hem, tryck på hemmet och sedan på Namn.';

  @override
  String get tipWhatYouNeedTitle => 'Det här behöver du';

  @override
  String get tipWhatYouNeedBody =>
      'En liten hubb som kör Zigbee2MQTT och en MQTT-broker (Mosquitto): en SMLIGHT-hubb, en Raspberry Pi eller vilken Linux-dator som helst. Home Assistant fungerar också, men behövs inte.';

  @override
  String get tipSetupAtHomeTitle => 'På samma Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Konfigurera hemma, med telefonen på samma Wi-Fi som hubben.';

  @override
  String get tipFindSetupTitle => 'Sedan';

  @override
  String get tipFindSetupBody =>
      'Lämna demon och tryck på „Hitta min installation”. ZigDash letar själv efter din hubb.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Ingen e-postapp hittades. Kopiera uppgifterna och skriv till $email.';
  }

  @override
  String get shortcutWorking => 'arbetar…';

  @override
  String get shortcutCantReach => 'Når inte hemmet';

  @override
  String get shortcutNotConfirmed => 'Inte bekräftad';

  @override
  String get shortcutRemoved => 'Borttagen';

  @override
  String get shortcutSceneSent => 'Skickad';

  @override
  String get shortcutSceneConfirmed => 'Bekräftad';

  @override
  String get shortcutChooseDevice => 'Välj en enhet';

  @override
  String get shortcutChooseScene => 'Välj en scen';

  @override
  String get shortcutOpenAppFirstScene =>
      'Öppna ZigDash och skapa en scen först.';

  @override
  String get shortcutChooseGroup => 'Välj en grupp';

  @override
  String get shortcutPickDevices => 'Välj enheter…';

  @override
  String get shortcutGroupName => 'Gruppnamn';

  @override
  String get shortcutGroupLimit => 'Upp till 5 enheter och 3 scener';

  @override
  String get shortcutAddTile => 'Lägg till i Snabbinställningar';

  @override
  String get shortcutAddShortcut => 'Lägg till genväg';

  @override
  String get shortcutAddToHome => 'Lägg till på hemskärmen';

  @override
  String get shortcutWidgetHowToTitle => 'Lägg till widgeten';

  @override
  String get shortcutWidgetHowTo =>
      'Håll ned en tom plats på hemskärmen, tryck på Widgetar, hitta ZigDash och dra den widget du vill ha.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name finns på snabbinställningsrutan ZigDash $slot';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name finns redan på rutan ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Lägg till rutan';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Öppna Snabbinställningar (svep nedåt två gånger), tryck på pennan för att redigera och dra ”ZigDash $slot” till dina rutor.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Välj en enhet för ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Inga enheter att slå på och av ännu. Lägg först en lampa, ett uttag eller en rullgardin på en dashboard.';

  @override
  String get shortcutSlotsFull =>
      'Alla 4 ZigDash-rutor används. Vilken ska visa den här enheten i stället?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Används inte';

  @override
  String get deviceRename => 'Byt namn';

  @override
  String get deviceRenameTitle => 'Byt namn på enheten';

  @override
  String get deviceRenameHint =>
      'Ett namn på rummet eller enheten, till exempel Sovrum';

  @override
  String deviceRenamed(Object name) {
    return 'Nytt namn: $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Kunde inte byta namn: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT svarade inte';

  @override
  String get shortcutOpenAppFirst =>
      'Öppna ZigDash och lägg först en enhet på en dashboard.';

  @override
  String get pollTitle => 'Vad ska ZigDash göra härnäst?';

  @override
  String get pollBody =>
      'Välj det du skulle använda mest. Svaret skickas med dina anonyma användningsdata.';

  @override
  String get pollNotifications => 'Aviseringar';

  @override
  String get pollHistory => 'Historikgrafer';

  @override
  String get pollKiosk => 'Kioskläge för en surfplatta på väggen';

  @override
  String get pollGroups => 'Zigbee-grupper';

  @override
  String get pollNotNow => 'Inte nu';

  @override
  String get pollThanks => 'Tack! Det hjälper oss att välja vad som kommer.';

  @override
  String get whyTitle => 'Varför testade du ZigDash?';

  @override
  String get whyBody =>
      'Ett tryck hjälper oss att välja vad vi bygger. Svaret skickas med dina anonyma användningsdata.';

  @override
  String get whyFaster => 'Snabbare än min andra app';

  @override
  String get whyFamily => 'Enkelt för familjen';

  @override
  String get whyWallTablet => 'En surfplatta på väggen';

  @override
  String get whyWithoutHa => 'Fungerar utan Home Assistant';

  @override
  String get whyOther => 'Något annat';

  @override
  String get whyThanks => 'Tack för svaret!';

  @override
  String get pollNoAnalytics =>
      'Användningsdata är avstängt, så inget skickas härifrån. Berätta för oss via Föreslå en funktion istället.';

  @override
  String alertLeak(Object name) {
    return '💧 Läcka — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name är torr igen';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Rök — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Ingen rök längre vid $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name öppnad';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Lågt batteri — $name, $value %';
  }

  @override
  String get alertTest => 'ZigDash-testavisering';

  @override
  String get alertsChannel => 'Larm';

  @override
  String get alertsChannelDescription => 'Läckor och rök';

  @override
  String get noticesChannel => 'Meddelanden';

  @override
  String get noticesChannelDescription => 'Dörrar, fönster och batterier';

  @override
  String get alertsTitle => 'Larm';

  @override
  String get alertsStatusOn => 'Larmen är på';

  @override
  String get alertsStatusPaused =>
      'Larm pausade: ZigDash Engine på hubben hör inte av sig';

  @override
  String get alertsStatusNotSetUp => 'Inte inställt';

  @override
  String get alertsStatusPhoneOff => 'Den här telefonen får inga aviseringar';

  @override
  String get alertsIntro =>
      'Få en avisering på den här telefonen vid läcka, rök, öppnad dörr eller svagt batteri, även när ZigDash är stängt. ZigDash Engine på hubben bevakar enheterna; ZigDash ställer in det.';

  @override
  String get alertsSetUpHub => 'Ställ in larm på hubben';

  @override
  String get alertsHubInstalled => 'Larm är inställda på hubben';

  @override
  String get alertsHubUpdated => 'Larmflödet på hubben är uppdaterat';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED kräver inloggning, så importera flödet för hand:';

  @override
  String get alertsHubManualSteps =>
      'Öppna Node-RED på hubben, välj Import, klistra in det kopierade flödet, välj din broker i broker-noden och tryck Deploy.';

  @override
  String get alertsCopyFlow => 'Kopiera flödet';

  @override
  String get alertsFlowCopied => 'Flöde kopierat';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Larm kräver Node-RED på hubben, och inget svarar på port 1880 hos $host. På en SMLIGHT SMHUB installerar du det under Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT tog inte emot ZigDash Engine';

  @override
  String get alertsRecent => 'Senaste larmen';

  @override
  String get alertsRecentNone => 'Inget ännu';

  @override
  String get alertsYourAlerts => 'Dina larm';

  @override
  String get alertsAdd => 'Lägg till larm';

  @override
  String get alertsNotificationsOnThisPhone =>
      'Aviseringar på den här telefonen';

  @override
  String get alertsNoGoogle =>
      'Den här telefonen saknar Google-tjänster, så ZigDash kan inte ta emot push här.';

  @override
  String get alertsSendTest => 'Skicka testavisering';

  @override
  String get alertsTestSent => 'Test skickat. Det bör komma nu.';

  @override
  String alertsTestFailed(Object status) {
    return 'Hubben kunde inte skicka det ($status)';
  }

  @override
  String get alertsTestTimedOut => 'Inget svar från hubben. Kör larmflödet?';

  @override
  String get alertsNotConnected => 'Inte ansluten till hubben';

  @override
  String get alertsTurnOff => 'Stäng av larmen';

  @override
  String get alertsTurnOffBody =>
      'Larmen stoppas för alla telefoner i det här hemmet.';

  @override
  String get alertKindLeak => 'Läcka';

  @override
  String get alertKindSmoke => 'Rök';

  @override
  String get alertKindOpened => 'Dörr eller fönster öppnat';

  @override
  String get alertKindBattery => 'Lågt batteri';

  @override
  String get alertsEditTitle => 'Larm';

  @override
  String get alertsKind => 'Vad';

  @override
  String get alertsDevices => 'Enheter';

  @override
  String get alertsNoDevicesForKind =>
      'Ingen enhet i det här hemmet rapporterar det.';

  @override
  String get alertsHours => 'Bara mellan';

  @override
  String get alertsHoursAny => 'När som helst';

  @override
  String get alertsHoursFrom => 'Från';

  @override
  String get alertsHoursTo => 'Till';

  @override
  String get alertsThreshold => 'Batteri under';

  @override
  String get alertsDelete => 'Ta bort larm';

  @override
  String get alertsNotifyMe => 'Meddela mig…';

  @override
  String get alertsWhatLeaves =>
      'Larm till ZigDash är totalsträckskrypterade: Googles push-tjänst bär dem men kan inte läsa dem. Inget annat lämnar din hubb.';

  @override
  String get alertsRestricted =>
      'Android kan stoppa ZigDash i bakgrunden, så aviseringar kan komma sent eller utebli. Tillåt körning i bakgrunden i Android-inställningarna (på Samsung: Batteri › Appar som aldrig sover).';

  @override
  String get alertsOpenSettings => 'Öppna Android-inställningar';

  @override
  String get alertsOff => 'Av';

  @override
  String get alertsSuggested => 'Föreslagna larm';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enheter',
      one: '1 enhet',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Slå på';

  @override
  String get alertsShare => 'Dela larm';

  @override
  String get alertsShareBody =>
      'Alla med den här länken får hemmets larm i ntfy-appen, utan ZigDash. Larmtexten går okrypterad via ntfy.sh.';

  @override
  String get alertsShareLink => 'Länk';

  @override
  String get alertsShareNewLink => 'Ny länk';

  @override
  String get alertsShareCopied => 'Länk kopierad';

  @override
  String get alertsShareOff => 'Sluta dela';

  @override
  String get alertsGetWithNtfy => 'Få aviseringar med ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Rök- och läcklarm upprepas tills de kvitteras. Kräver ett Pushover-konto (4,99 \$ en gång efter provperioden); nycklarna sparas på din broker.';

  @override
  String get alertsPushoverUser => 'Användarnyckel';

  @override
  String get alertsPushoverToken => 'App-token';

  @override
  String get alertsHideNames => 'Dölj enhetsnamn';

  @override
  String get alertsNtfyServer => 'ntfy-server';

  @override
  String get wallSheetTitle => 'Väggvisning';

  @override
  String get wallSheetSubtitle => 'För en surfplatta på väggen.';

  @override
  String get wallKeepOn => 'Håll skärmen tänd och dölj fälten';

  @override
  String get wallKeepOnSubtitle =>
      'De kommer tillbaka vid beröring och döljs igen efter 10 sekunder.';

  @override
  String get wallFullscreen => 'Helskärm';

  @override
  String get wallFullscreenSubtitle =>
      'Döljer även Androids status- och navigeringsfält.';

  @override
  String get wallDimAfter => 'Dämpa efter';

  @override
  String get wallDimOff => 'Av';

  @override
  String get wallIdleTitle => 'När ingen rör den';

  @override
  String get wallIdleAfter => 'Efter';

  @override
  String get wallIdleNever => 'Aldrig';

  @override
  String get wallIdleShow => 'Visa';

  @override
  String get wallIdleShowDim => 'Dämpad';

  @override
  String get wallIdleShowClock => 'Klocka';

  @override
  String get wallIdleShowBlack => 'Svart';

  @override
  String get wallIdleShowReadings => 'Mätvärden';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Den här instrumentpanelen har inga mätvärden än. Lägg först till en mätvärdes- eller sensorruta.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Mätvärden på klockan (upp till $count)';
  }

  @override
  String get wallProNote =>
      'Mätvärden på klockan, väckning vid rörelse, nattschemat och larm ingår i ZigDash Pro, ett engångsköp.';

  @override
  String get wallAlarmLeak => 'Vattenläcka';

  @override
  String get wallAlarmSmoke => 'Rök';

  @override
  String get wallAlarmGas => 'Gas';

  @override
  String get wallAlarmCo => 'Kolmonoxid';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Väck vid rörelse';

  @override
  String get wallMotionSubtitle => 'En sensor som ser någon väcker skärmen.';

  @override
  String get wallMotionNone =>
      'Inga rörelse-, närvaro- eller dörrsensorer i det här hemmet.';

  @override
  String get wallAlarmsTitle => 'Larm fyller skärmen';

  @override
  String get wallAlarmsSubtitle =>
      'Läcka, rök, gas eller kolmonoxid fyller skärmen tills någon trycker på OK. Bara medan ZigDash är öppen på den här surfplattan; aviseringar når telefoner var som helst.';

  @override
  String get wallAlarmSound => 'Spela upp ett ljud';

  @override
  String get wallNightTitle => 'Natt';

  @override
  String get wallNightSubtitle =>
      'Svart mellan dessa tider. Rörelse väcker den bara dämpat; larm alltid fullt.';

  @override
  String get wallNightFrom => 'Från';

  @override
  String get wallNightTo => 'till';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Kiosklås';

  @override
  String get kioskLockSubtitle =>
      'Bara det här hemmets paneler och deras reglage går att nå. Håll in titeln för att avsluta.';

  @override
  String get kioskPin => 'PIN';

  @override
  String get kioskPinSet => 'Ange';

  @override
  String get kioskPinNotSet => 'Inte angiven';

  @override
  String get kioskPinChange => 'Ändra';

  @override
  String get kioskPinRemove => 'Ta bort';

  @override
  String get kioskPinSetTitle => 'Ange en PIN';

  @override
  String get kioskPinEnterTitle => 'Ange PIN';

  @override
  String get kioskPinHint => '4 siffror';

  @override
  String get kioskPinConfirmHint => 'En gång till';

  @override
  String get kioskPinMismatch => 'De två PIN-koderna skiljer sig.';

  @override
  String get kioskPinWrong => 'Fel PIN.';

  @override
  String get kioskPinForgot => 'Glömt PIN?';

  @override
  String get kioskPinForgotBody =>
      'En glömd PIN kan bara återställas genom att rensa ZigDashs data i Androids inställningar, vilket tar bort det här hemmet om du inte har en säkerhetskopia. Exportera en innan du anger en PIN.';

  @override
  String get kioskExportBackup => 'Exportera säkerhetskopia';

  @override
  String get kioskOsPin => 'Fäst även ZigDash i Android';

  @override
  String get kioskOsPinSubtitle =>
      'Android spärrar Hem och senaste appar tills ZigDash lossas. En surfplatta utan låsskärm lossar med en gest, så det här är inte låset.';

  @override
  String get kioskOn => 'Kiosk på. Håll in titeln för att avsluta.';

  @override
  String get kioskLeaveTitle => 'Avsluta kiosk?';

  @override
  String get kioskLeave => 'Avsluta';

  @override
  String get kioskStay => 'Stanna';

  @override
  String get a11yKioskLeave => 'Håll in för att avsluta kiosk';

  @override
  String get historyTitle => 'Historik';

  @override
  String get historyRangeDay => '24 timmar';

  @override
  String get historyRangeWeek => '7 dagar';

  @override
  String get historyRangeMonth => '30 dagar';

  @override
  String get historySetupTitle => 'Spela in historik på hubben';

  @override
  String get historySetupBody =>
      'ZigDash har ingen server, så ZigDash Engine på hubben sparar värdena från dina instrumentpaneler var 15:e minut. Det sparar 30 dagar, på din egen broker.';

  @override
  String get historySetupAction => 'Ställ in på hubben';

  @override
  String get historyInstalled =>
      'Inspelning pågår. De första värdena syns inom 15 minuter.';

  @override
  String historyNoNodeRed(String host) {
    return 'Historik kräver Node-RED på hubben, och inget svarar på port 1880 på $host. På en SMLIGHT SMHUB installerar du det under Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Inspelat sedan $date';
  }

  @override
  String get historyEmpty =>
      'Inga värden än. Inspelaren sparar var 15:e minut.';

  @override
  String get historyRecorderOffline =>
      'Inspelaren på hubben svarar inte, så nya värden kan saknas.';

  @override
  String get historyLocked =>
      'Längre historik ingår i ZigDash Pro, ett engångsköp.';

  @override
  String get historyUnlock => 'Lås upp';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Obegränsade automationer, längre historik och extra för väggplattan. Stöder projektet med öppen källkod.';

  @override
  String get proUnlocked => 'Upplåst. Tack för att du stöder ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash är gratis och öppen källkod, byggd av en person på fritiden. Pro är ett engångsköp som håller projektet igång.';

  @override
  String get proWhatYouGet => 'Det här får du';

  @override
  String get proGetHistory => 'Historik för 7 och 30 dagar, inte bara i dag';

  @override
  String get proGetWall =>
      'Väggplatta: mätvärden på klockan, väckning vid rörelse, nattschema och alarm';

  @override
  String get proGetFuture =>
      'Alla Pro-funktioner som kommer senare, utan extra kostnad';

  @override
  String get proFreeTitle => 'Gratis för alltid';

  @override
  String get proFreeBody =>
      'Konfiguration, instrumentpaneler, styrning av alla enheter, widgetar, snabbinställningsrutor, aviseringar, tre automationer per hem och själva väggplattan förblir gratis. Inget du använder i dag låses.';

  @override
  String get proBuy => 'Skaffa Pro';

  @override
  String proBuyPrice(String price) {
    return 'Skaffa Pro · $price';
  }

  @override
  String get proOnce =>
      'En betalning, ingen prenumeration. Köpt på en annan telefon med samma Google-konto? Det låses upp automatiskt.';

  @override
  String get historyNotRecorded =>
      'Bara siffror som visas på en instrumentpanel spelas in. Lägg till den här som en ruta för att starta historiken.';

  @override
  String get historyRecordHere => 'Spela in på den här enheten';

  @override
  String get historyRecordHereHint =>
      'Går ZigDash Engine inte att använda på hubben? ZigDash kan spara på en telefon eller platta som är öppen, som en väggplatta. Alla telefoner i hemmet ser historiken.';

  @override
  String get historyRecordingHere =>
      'Den här enheten spelar in historik medan ZigDash är öppen. De första värdena kommer inom 15 minuter.';

  @override
  String get wallRecordHistory => 'Spela in historik på den här enheten';

  @override
  String get wallRecordHistorySubtitle =>
      'Var 15:e minut medan ZigDash är öppet, för alla telefoner i hemmet. Behövs inte när ZigDash Engine på hubben sparar.';

  @override
  String historyNeedsPassword(String host) {
    return 'Ett steg till: din broker kräver inloggning. Öppna Node-RED på $host:1880, dubbelklicka på ”ZigDash history broker”, skriv MQTT-lösenordet på fliken Security och klicka på Deploy. ZigDash skickar aldrig ditt lösenord till hubben.';
  }

  @override
  String get historyNotConnected =>
      'Inspelningen hör inte av sig. Öppna Automationer för att kontrollera ZigDash Engine på hubben.';

  @override
  String get historyPersistence =>
      'Historiken finns på din broker. Kör du Mosquitto själv, se till att konfigurationen har \"persistence true\", annars försvinner historiken när brokern startar om.';

  @override
  String get haImportTitle => 'Importera från Home Assistant';

  @override
  String get haImportSettingsSubtitle => 'Namn och rum från Home Assistant';

  @override
  String get haImportIntro =>
      'Hämta namnen och rummen du har satt upp i Home Assistant. ZigDash läser dem en gång och sparar inget annat från Home Assistant.';

  @override
  String get haImportAddress => 'Adress till Home Assistant';

  @override
  String get haImportAddressHelp =>
      'Adressen du öppnar Home Assistant med, till exempel 192.168.1.20:8123';

  @override
  String get haImportToken => 'Långlivad åtkomsttoken';

  @override
  String get haImportTokenHelp =>
      'Öppna din profil i Home Assistant, sedan Säkerhet › Långlivade åtkomsttokens › Skapa token. Kopiera den och klistra in den här. ZigDash använder den en gång och sparar den inte; efteråt kan du ta bort den i Home Assistant.';

  @override
  String get haImportRead => 'Läs från Home Assistant';

  @override
  String get haImportReading => 'Läser Home Assistant…';

  @override
  String get haImportApplying => 'Importerar…';

  @override
  String get haImportNoAddress =>
      'Skriv adressen du öppnar Home Assistant med.';

  @override
  String get haImportNoToken => 'Klistra in en långlivad åtkomsttoken.';

  @override
  String get haImportUnreachable =>
      'Inget svarade på den adressen. Kontrollera den, och att telefonen är på hemnätverket.';

  @override
  String get haImportNotHa =>
      'Något svarade på den adressen, men det är inte Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant nekade den token. Skapa en ny och klistra in den igen.';

  @override
  String get haImportCertificate =>
      'Telefonen litar inte på certifikatet för den här Home Assistant. Prova dess http://-adress på hemnätverket.';

  @override
  String get haImportFailed =>
      'Home Assistant svarade, men läsningen misslyckades. Försök igen.';

  @override
  String get haImportNoDevices =>
      'ZigDash ser inte det här hemmets enheter just nu. Anslut till hemmet och försök igen.';

  @override
  String get haImportAutomations =>
      'Dina automationer stannar i Home Assistant och fortsätter att köras.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enheter hittades i Home Assistant',
      one: '1 enhet hittades i Home Assistant',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'Rutor som fortfarande har enhetens namn får namnet från Home Assistant. Dashboards du själv har byggt förblir som de är.';

  @override
  String get haImportMakeDashboards =>
      'Lägg också till dashboards från dina våningar och rum';

  @override
  String get haImportOtherRooms => 'Andra rum';

  @override
  String get haImportNoRoom => 'Inget rum';

  @override
  String get haImportApply => 'Importera';

  @override
  String get haImportBack => 'Tillbaka';

  @override
  String get haImportZhaOnly =>
      'De här enheterna körs på ZHA, Home Assistants eget Zigbee, inte på Zigbee2MQTT, så ZigDash kan inte visa dem.';

  @override
  String get haImportNothing =>
      'Ingen av det här hemmets Zigbee2MQTT-enheter finns i Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Klart. Rutor med nytt namn: $renamed. Tillagda dashboards: $dashboards.';
  }

  @override
  String get haImportOpen => 'Öppna dashboards';

  @override
  String get haImportOfferTitle => 'Hämta namn och rum från Home Assistant?';

  @override
  String get haImportOfferBody =>
      'Home Assistant finns på ditt nätverk. ZigDash kan namnge dina rutor och lägga till en dashboard per våning och rum, så som du har satt upp dem där.';

  @override
  String get haImportOfferLater => 'Inte nu';

  @override
  String get haImportOfferGo => 'Importera';

  @override
  String get haImportSignIn => 'Logga in med Home Assistant';

  @override
  String get haImportSignInHelp =>
      'Home Assistants egen inloggning öppnas i webbläsaren. ZigDash ser aldrig ditt lösenord och loggar ut igen efter läsningen.';

  @override
  String get haImportOrToken => 'Eller använd en långlivad åtkomsttoken';

  @override
  String get haImportReadToken => 'Läs med token';

  @override
  String get haImportSignInRefused =>
      'Home Assistant godtog inte inloggningen. Det händer när Home Assistant saknar internetåtkomst. Använd en långlivad åtkomsttoken nedan i stället.';

  @override
  String get setupIsolatedHint =>
      'Telefonen ser nästan inget annat på det här wifi-nätet. Den kan vara på ett gästnät, eller så håller routern enheterna isär (kallas ofta klient- eller AP-isolering). Anslut till ditt huvudwifi eller stäng av det och försök igen.';

  @override
  String get setupAuthTrust =>
      'Din inloggning stannar på den här telefonen och går bara till din egen broker. ZigDash har ingen server och inget konto, och alla MQTT-appar loggar in så här. Säkrast: en egen MQTT-användare bara för ZigDash, som du kan ta bort när som helst.';

  @override
  String get setupAuthWhatKept => 'Vad ZigDash sparar';

  @override
  String get setupAuthDemoFirst => 'Prova demon först';

  @override
  String get automationsTitle => 'Automationer';

  @override
  String get engineRunningOnHub => 'Körs på hubben';

  @override
  String get engineChecking => 'Kontrollerar hubben…';

  @override
  String get engineAwayNoHubTitle => 'Din hubb går inte att nå just nu';

  @override
  String get engineAwayNoHubBody =>
      'Du är borta, och hubben är inte ansluten till ZigDash fjärråtkomst, eller så saknar den internet. Dina automatiseringar fortsätter att köras på hubben.';

  @override
  String get engineAwayReinstallAtHome =>
      'Du kan installera om Engine när du är hemma.';

  @override
  String get engineNoConnection =>
      'ZigDash når inte hemmets broker just nu. Automationer ställs in hemma, med anslutning.';

  @override
  String get engineRestarting =>
      'Startar om Zigbee2MQTT… Dina enheter är tillbaka om cirka 30 sekunder.';

  @override
  String get engineInstalling => 'Installerar på hubben…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT behöver uppdateras';

  @override
  String engineTooOldBody(Object version) {
    return 'Din Zigbee2MQTT är version $version. Automationer kräver 2.4 eller nyare. Uppdatera Zigbee2MQTT på hubben och kom sedan tillbaka hit.';
  }

  @override
  String get engineIntroTitle =>
      'Automationer körs på hubben, inte på telefonen';

  @override
  String get engineIntroBody =>
      'ZigDash lägger ZigDash Engine i Zigbee2MQTT på din hubb. Det bevakar dina enheter och kör dina regler, så att en lampa tänds när dörren öppnas även med telefonen avstängd och utan internet.';

  @override
  String get engineIntroNothingByHand =>
      'Inget att installera för hand. ZigDash gör det via hemnätverket.';

  @override
  String engineIntroVersion(Object version) {
    return 'Din Zigbee2MQTT är version $version.';
  }

  @override
  String get engineIntroRemove =>
      'Du kan ta bort den när som helst från den här skärmen.';

  @override
  String get engineInstall => 'Installera på hubben';

  @override
  String get engineDeclinedTitle => 'Inga automationer på den här hubben';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT på din hubb tillåter inga tillägg, så inget kan köra dina regler när telefonen är borta. Scener, larm och instrumentpanelen fungerar som förut.';

  @override
  String get engineAllowAfterAll => 'Tillåt tillägg ändå';

  @override
  String get engineConsentTitle => 'Zigbee2MQTT behöver ändra en inställning';

  @override
  String get engineConsentBody =>
      'Din Zigbee2MQTT blockerar tillägg som ZigDash Engine, som nya installationer gör. För att köra automationer på hubben skulle ZigDash slå på ”Tillåt extern JavaScript” i Zigbee2MQTT och starta om det.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT startar om en gång. Lampor och sensorer går inte att nå i cirka 30 sekunder.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine är öppen källkod. Du kan läsa det på Zigbee2MQTT-sidan under Tillägg.';

  @override
  String get engineConsentUndo =>
      'Du kan stänga av inställningen senare. Då stoppas automationerna.';

  @override
  String get engineConsentYes => 'Ändra inställningen och starta om';

  @override
  String get engineConsentNo => 'Inte nu';

  @override
  String get automationsPausedTitle => 'Automationer pausade';

  @override
  String get automationsPausedBody =>
      'Hubben har inte hört av sig på över en minut, så ingen automation kan köras förrän den gör det. Dina regler sparas.';

  @override
  String get engineReinstall => 'Installera om på hubben';

  @override
  String get engineStoppedTitle =>
      'Automationer pausade: ZigDash Engine stoppade sig själv';

  @override
  String get engineStoppedBody =>
      'Den fick fel tre gånger på en timme och stängde av sig så att Zigbee2MQTT fortsätter köra. Dina regler sparas.';

  @override
  String get engineStartAgain => 'Starta igen';

  @override
  String get engineReportProblem => 'Rapportera ett problem';

  @override
  String get engineRunningTitle => 'Din hubb är redo för automationer';

  @override
  String engineRunningBody(Object count) {
    return 'Regler inlästa på hubben: $count. Att skapa automationer kommer i nästa steg av den här versionen.';
  }

  @override
  String get engineClockOff =>
      'Hubbens klocka går mer än fem minuter fel. Tidsstyrda automationer körs vid fel tid tills det är åtgärdat.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Regler som ZigDash Engine på hubben inte kan köra än: $count. Installera om det för att uppdatera.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT avvisade ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT svarade inte. Kontrollera att hemmet är anslutet och försök igen.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT tog inte emot ändringen eller kom inte tillbaka. Kontrollera hubben och försök igen.';

  @override
  String get autoValMotion => 'rörelse';

  @override
  String get autoValNoMotion => 'ingen rörelse';

  @override
  String get autoValClosed => 'stängd';

  @override
  String get autoValOpened => 'öppnad';

  @override
  String get autoValLeak => 'läcka';

  @override
  String get autoValDry => 'torrt';

  @override
  String get autoValSmoke => 'rök';

  @override
  String get autoValNoSmoke => 'ingen rök';

  @override
  String get autoValOn => 'på';

  @override
  String get autoValOff => 'av';

  @override
  String get autoValToggle => 'växla';

  @override
  String get autoValOpen => 'öppna';

  @override
  String get autoValClose => 'stäng';

  @override
  String get autoValStop => 'stopp';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'När $device: $property över $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'När $device: $property under $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'När $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'Kl. $time';
  }

  @override
  String get autoSunrise => 'soluppgång';

  @override
  String get autoSunset => 'solnedgång';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min efter $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min före $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'Vid $sun';
  }

  @override
  String get autoEveryDay => 'varje dag';

  @override
  String get autoWeekdays => 'vardagar';

  @override
  String get autoWeekends => 'helger';

  @override
  String autoBetween(Object from, Object to) {
    return 'mellan $from och $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device är $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Kör ”$scene”';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, av igen efter $minutes min';
  }

  @override
  String get autoErrPickTrigger => 'Välj en enhet och vad den gör.';

  @override
  String get autoErrValue => 'Skriv ett tal för mätvärdet.';

  @override
  String get autoErrDays => 'Välj minst en dag.';

  @override
  String get autoErrTown => 'Ange din ort för soluppgång och solnedgång.';

  @override
  String get autoErrPickAction => 'Välj vad som ska hända.';

  @override
  String get autoErrEmptyScene => 'Den scenen har inget att skicka.';

  @override
  String get autoErrNotConnected =>
      'ZigDash är inte anslutet till det här hemmet. Försök igen hemma.';

  @override
  String get autoNewTitle => 'Ny automation';

  @override
  String get autoEditTitle => 'Redigera automation';

  @override
  String get autoName => 'Namn';

  @override
  String get autoNameHint => 'Vad den gör (valfritt)';

  @override
  String get autoWhen => 'När';

  @override
  String get autoOnlyIf => 'Bara om';

  @override
  String get autoThen => 'Då';

  @override
  String get autoEnabled => 'Aktiverad';

  @override
  String get autoDelete => 'Ta bort automation';

  @override
  String get autoSave => 'Spara';

  @override
  String get autoDeviceChanges => 'En enhet ändras';

  @override
  String get autoTimeComes => 'En tid kommer';

  @override
  String get autoDevice => 'Enhet';

  @override
  String get autoAbove => 'över';

  @override
  String get autoBelow => 'under';

  @override
  String get autoClockTime => 'Klockslag';

  @override
  String get autoAt => 'Kl.';

  @override
  String get autoShift => 'Förskjutning i minuter (minus är före)';

  @override
  String get autoTownNone => 'Ingen ort angiven';

  @override
  String autoTownIs(Object town) {
    return 'Soltider för $town';
  }

  @override
  String get autoTownSet => 'Ange ort';

  @override
  String get autoTownChange => 'Byt ort';

  @override
  String get autoDays => 'Dagar';

  @override
  String get autoNoConditions => 'Inga villkor. Körs varje gång.';

  @override
  String get autoAddHours => 'Mellan klockslag';

  @override
  String get autoFrom => 'Från';

  @override
  String get autoTo => 'Till';

  @override
  String get autoAddDeviceCondition => 'En enhet är…';

  @override
  String get autoRunASceneOption => 'Kör en scen';

  @override
  String get autoSetADevice => 'Styr en enhet';

  @override
  String get autoScene => 'Scen';

  @override
  String get autoTurnOffAgain => 'Stäng av igen';

  @override
  String get autoStaysAsSet => 'Förblir så';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minuter efteråt';
  }

  @override
  String get autoTownSearch => 'Ort';

  @override
  String get autoTownWhy =>
      'Används bara för soluppgång och solnedgång. Sparas på hubben, aldrig din plats.';

  @override
  String get autoNewButton => 'Ny automation';

  @override
  String get autoEmptyBody =>
      'Inget körs än. Tryck på Ny automation för att skapa den första.';

  @override
  String autoOnlyIfList(Object list) {
    return 'bara om $list';
  }

  @override
  String get autoEdit => 'Redigera';

  @override
  String get autoNeverRan => 'har aldrig körts';

  @override
  String autoRanAt(Object time) {
    return 'kördes $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count av $max gratis automationer';
  }

  @override
  String get autoRecentRuns => 'Senaste körningar';

  @override
  String get autoDeleted => '(borttagen)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count automationer är gratis. Vill du ha fler?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash är gratis och öppen källkod, byggt av en person. Pro är ett engångsköp: obegränsade automationer, historik för 7 och 30 dagar och extrafunktionerna för väggplatta. Dina automationer fortsätter köras vad du än väljer.';

  @override
  String get autoCeilingSeePro => 'Se Pro';

  @override
  String get engineRemove => 'Ta bort från hubben';

  @override
  String get engineRemoveTitle => 'Ta bort ZigDash Engine från hubben?';

  @override
  String get engineRemoveBody =>
      'Automationerna slutar köras. Dina regler ligger kvar på hubben, så en ny installation av ZigDash Engine tar tillbaka dem.';

  @override
  String get autoNoTargets =>
      'Det här hemmet har ännu ingen lampa, kontakt, strömbrytare eller rullgardin att styra.';

  @override
  String get proGetAutomations =>
      'Obegränsade automationer; tre per hem är gratis';

  @override
  String get proGetRemote =>
      'Fjärrstyrning var du än är, via ZigDash-reläet, utan månadsavgift';

  @override
  String get proRemoteFair =>
      'Fjärråtkomst ingår så länge ZigDash-reläet körs, för ett hem, upp till fem telefoner och normal användning i hushållet. Den kan ändras eller upphöra med förvarning.';

  @override
  String get autoDeleteConfirm =>
      'Ta bort den här automationen? Den slutar köras på hubben.';

  @override
  String get statusConnectedRelay => 'Ansluten · Borta via ZigDash';

  @override
  String get shareHomeTitle => 'Dela med en annan telefon';

  @override
  String get shareHomeSubtitle =>
      'Lägg till hemmet på en annan telefon med en QR-kod';

  @override
  String get shareHomeIntro =>
      'På den andra telefonen, hemma på samma wifi, skanna koden med kameran. ZigDash lägger till hemmet med inloggning och dina instrumentpaneler.';

  @override
  String get shareHomeLoginWarning =>
      'Koden innehåller hemmets broker-inloggning. Den visas i 2 minuter; visa den bara för personer du litar på.';

  @override
  String get shareHomeShow => 'Visa koden';

  @override
  String get shareHomeAtHome =>
      'Anslut hemma först: delning fungerar bara på hemnätverket.';

  @override
  String get shareHomeScanHint =>
      'Skanna med den andra telefonens kamera. Koden döljs om 2 minuter.';

  @override
  String get shareHomeHide => 'Dölj koden';

  @override
  String get shareHomeViaHa =>
      'Det här hemmet ansluter via Home Assistant. Installera ZigDash på den andra telefonen och logga in med Home Assistant.';

  @override
  String get joinHomeTitle => 'Lägg till ett delat hem';

  @override
  String get joinHomeInvalid =>
      'Koden är ingen ZigDash-inbjudan, eller så är den skadad.';

  @override
  String joinHomeAlready(String name) {
    return '$name finns redan på den här telefonen.';
  }

  @override
  String get joinHomeOpen => 'Öppna';

  @override
  String joinHomeAsk(String name) {
    return 'Lägga till $name på den här telefonen?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash lägger till hemmet med samma anslutning och inloggning och hämtar instrumentpanelerna från den andra telefonen. Håll telefonen på hemmets wifi.';

  @override
  String get joinHomeAdd => 'Lägg till hem';

  @override
  String get joinHomeNoDashboards =>
      'Hemmet är tillagt. Instrumentpanelerna kom inte fram; dina enheter finns under fliken Enheter.';

  @override
  String get remoteTitle => 'Fjärrstyrning';

  @override
  String get remoteSettingsSubtitle =>
      'Styr det här hemmet var du än är, med Pro';

  @override
  String get remoteIntroTitle => 'Styr ditt hem var du än är';

  @override
  String get remoteOfferBody =>
      'Nå dina enheter när du är borta, via ZigDashs krypterade relä. Ingår i Pro: en betalning, ingen månadsavgift. Ställ in det medan du är hemma.';

  @override
  String get remoteOfferBodyPro =>
      'Du har Pro: slå på fjärrstyrning medan du är hemma, så når du dina enheter var du än är.';

  @override
  String get remoteOfferShow => 'Visa';

  @override
  String get remoteIntroBody =>
      'Hubben håller en anslutning till ZigDashs relä. Borta når den här telefonen dina enheter genom det. Allt krypteras på hubben och telefonen, så reläet kan inte läsa dina enheter eller vad de gör.';

  @override
  String get remoteNeedsEngine =>
      'Fjärrstyrning körs i ZigDash Engine. Installera det först under Automationer.';

  @override
  String get remoteSetUp => 'Slå på fjärrstyrning';

  @override
  String get remoteNeedsPro => 'Fjärrstyrning ingår i Pro.';

  @override
  String get remoteNotAtHome => 'Slå på det hemma, ansluten till din broker.';

  @override
  String get remoteUnreachable =>
      'ZigDashs relä svarade inte. Försök igen senare.';

  @override
  String get remoteRefused =>
      'Reläet nekade. Försök igen eller rapportera ett problem.';

  @override
  String get remoteOnTitle => 'Fjärrstyrning är på';

  @override
  String get remoteOnBody => 'Borta ansluter ZigDash själv via reläet.';

  @override
  String get remoteHubOnline => 'Hubben är ansluten till reläet';

  @override
  String get remoteHubOffline => 'Hubben är inte ansluten till reläet';

  @override
  String get remoteTurnOff => 'Stäng av fjärrstyrning';

  @override
  String get remoteViaRelayNow =>
      'Den här telefonen är ansluten via reläet just nu.';

  @override
  String get remotePhones => 'Telefoner med fjärråtkomst';

  @override
  String get remoteThisPhone => 'Den här telefonen';

  @override
  String get remoteOtherPhone => 'En annan telefon';

  @override
  String remotePhoneAdded(Object date) {
    return 'Tillagd $date';
  }

  @override
  String get remoteRemovePhone => 'Ta bort';

  @override
  String get remoteRemovePhoneConfirm =>
      'Ta bort den här telefonen? Den når inte längre hemmet på distans.';

  @override
  String get remoteAddPhone => 'Lägg till en telefon';

  @override
  String get remoteAddPhoneHint =>
      'Hemma: skanna det här med den andra telefonens kamera. Den öppnar ZigDash och slår på fjärrstyrning där. Visa det bara för dina egna telefoner.';

  @override
  String get remoteAddPhoneFailed =>
      'Reläet gav ingen inloggning för en till telefon. Ett hem kan ha upp till fem.';

  @override
  String get remoteBackupSave => 'Spara en nyckelbackup';

  @override
  String get remoteBackupRestore => 'Återställ från en nyckelbackup';

  @override
  String get remoteBackupPassphrase => 'Lösenfras för backupen';

  @override
  String get remoteBackupPassphraseHint =>
      'Tappar du den här telefonen ger backupen och lösenfrasen tillbaka fjärrstyrningen på en ny. Minst 8 tecken, och förvara lösenfrasen någon annanstans än filen.';

  @override
  String get remoteBackupPassphraseAsk =>
      'Lösenfrasen du valde när du sparade backupen.';

  @override
  String get remoteBackupPassphraseAgain => 'Lösenfrasen igen';

  @override
  String get remoteBackupSaved => 'Nyckelbackup sparad';

  @override
  String get remoteBackupWrong => 'Den lösenfrasen öppnar inte backupen.';

  @override
  String get remoteBackupWrongFile =>
      'Det där är ingen nyckelbackup från ZigDash.';

  @override
  String get remotePlayOnly =>
      'Fjärrstyrning finns tills vidare i Google Play-versionen av ZigDash.';

  @override
  String get remotePairTitle => 'Lägg till fjärrstyrning';

  @override
  String get remotePairBody =>
      'Vilket hem är det här? ZigDash sparar fjärrinloggningen för det.';

  @override
  String get remotePairNoHomes =>
      'Ställ först in hemmet på den här telefonen, hemma. Skanna sedan koden igen.';

  @override
  String get remotePairInvalid =>
      'Koden är ingen fjärrstyrningskod från ZigDash, eller så klipptes den av.';

  @override
  String remotePairDone(Object home) {
    return 'Fjärrstyrning är på för $home';
  }

  @override
  String get remoteReconnectHub => 'Anslut hubben igen';

  @override
  String get remoteTurnOffConfirm =>
      'Den här telefonen lämnar fjärrstyrningen och hubben kopplas från reläet. En nyckelbackup sparad från den här telefonen slutar fungera; andra telefoner behåller sin åtkomst tills du tar bort dem.';

  @override
  String remoteHomeId(Object id) {
    return 'Hem-ID $id';
  }

  @override
  String get alertsHintTitle => 'Få aviseringar på den här telefonen';

  @override
  String get alertsHintBody =>
      'En läcka, rök, en öppnad dörr eller ett svagt batteri kan skicka en avisering till den här telefonen, även när ZigDash är stängt.';

  @override
  String get alertsHintButton => 'Ställ in larm';

  @override
  String get alertsHintNotNow => 'Inte nu';

  @override
  String get guidedNoZ2mBody =>
      'En MQTT-broker svarar här, men Zigbee2MQTT skickar inget via den. Kontrollera att Zigbee2MQTT är startat och använder den här brokern, och att bastopicet stämmer med dess inställningar. Om dina Zigbee-enheter finns i Home Assistants ZHA kan ZigDash inte se dem: det fungerar med Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT finns på den här brokern med bastopic ”$found”, men det här hemmet letar efter ”$current”.';
  }

  @override
  String devicesUseBase(String found) {
    return 'Använd ”$found”';
  }

  @override
  String get devicesChangeConnection => 'Ändra anslutning';

  @override
  String get updateAvailableTitle => 'En ny version av ZigDash finns';

  @override
  String get updateAvailableBody =>
      'Den laddas ner medan du fortsätter använda ZigDash.';

  @override
  String get updateAvailableButton => 'Uppdatera';

  @override
  String get updateDownloading => 'Laddar ner uppdateringen …';

  @override
  String get updateReadyTitle => 'Uppdateringen är nedladdad';

  @override
  String get updateReadyButton => 'Starta om för att slutföra';

  @override
  String get nfcWriteTag => 'Skriv till NFC-tagg';

  @override
  String get nfcHoldTitle => 'Håll en tagg mot telefonen';

  @override
  String nfcHoldBody(String name) {
    return 'Håll ett tomt NFC-klistermärke mot baksidan av telefonen. Att trycka på det sedan kör $name.';
  }

  @override
  String get nfcWrittenTitle => 'Taggen är klar';

  @override
  String nfcWrittenBody(String name) {
    return 'Tryck telefonen mot taggen för att köra $name. Det fungerar även när ZigDash är stängt.';
  }

  @override
  String get nfcFailedTitle => 'Taggen kunde inte skrivas';

  @override
  String get nfcReadonlyBody =>
      'Taggen är låst och kan inte ändras. Prova en annan.';

  @override
  String get nfcTooSmallBody =>
      'Taggen är för liten. Använd ett NTAG213-klistermärke eller större.';

  @override
  String get nfcFailedBody =>
      'Håll taggen stilla mot telefonens baksida och försök igen.';

  @override
  String get nfcOffTitle => 'NFC är avstängt';

  @override
  String get nfcOffBody =>
      'Slå på NFC i Androids inställningar och försök igen.';

  @override
  String get nfcNoneTitle => 'Ingen NFC i den här telefonen';

  @override
  String get nfcNoneBody =>
      'Den här telefonen kan inte läsa eller skriva NFC-taggar.';

  @override
  String get nfcWriteAnother => 'Skriv en tagg till';
}
