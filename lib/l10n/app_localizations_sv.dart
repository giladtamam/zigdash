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
  String get dashFormLock => 'Lås';

  @override
  String get dashFormLockSubtitle =>
      'Dölj redigeringsfunktioner medan den är låst';

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
      'Det går inte att nå servern (brokern). Körs Zigbee2MQTT? Kontrollera adress och port.';

  @override
  String get diagTcpTimeout =>
      'Anslutningen till servern tog för lång tid. Den kan vara offline eller oåtkomlig.';

  @override
  String get diagConnackFail =>
      'Servern slutförde inte MQTT-handskakningen. Se till att det är en MQTT-server (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'Servern avvisade användarnamn eller lösenord. Kontrollera dina uppgifter.';

  @override
  String get diagAuthRefused =>
      'Servern avvisade anslutningen. Kontrollera anslutningsinställningarna.';

  @override
  String foundDevices(Object count) {
    return 'Hittade $count enheter';
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
  String ladderTriedHint(Object count) {
    return 'Försökte $count adresser';
  }

  @override
  String get guidedSaveFailed =>
      'Det gick inte att spara anslutningen. Försök igen.';

  @override
  String get setupWelcomeTitle => 'Välkommen till ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash styr ditt befintliga Zigbee2MQTT-hem — lokalt, utan moln. Se till att Zigbee2MQTT körs och låt ZigDash hitta det.';

  @override
  String get setupFindMySetup => 'Hitta min installation';

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
  String get setupAuthTitle => 'Den här brokern kräver inloggning';

  @override
  String setupAuthBody(Object host) {
    return 'Ange MQTT-användarnamnet och lösenordet för $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Användarnamnet eller lösenordet avvisades. Kontrollera dem och försök igen.';

  @override
  String get setupVerifyingTitle => 'Kontrollerar anslutningen…';

  @override
  String get setupReviewTitle => 'Dina enheter';

  @override
  String setupReviewSubtitle(Object count) {
    return '$count enheter hittades. Välj vad som hamnar på din första dashboard.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'Skapa dashboard med $count';
  }

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
  String get setupErrScanFailedTitle => 'Inget lokalt nätverk';

  @override
  String get setupErrScanFailedBody =>
      'Kunde inte fastställa den här enhetens lokala nätverk. Anslut till wifi och försök igen.';

  @override
  String get setupErrScanFailedAction => 'Försök igen';

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
  String get dashWallDisplayOn =>
      'Väggvisning på: skärmen förblir på och fälten döljs efter 10 sekunder utan beröring. Tryck för att visa dem igen.';

  @override
  String get dashWallDisplayOff => 'Väggvisning av.';

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
      'Anonym användningsdata bara om du väljer det.';

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
  String get tipWhatYouNeedTitle => 'Det här behöver du';

  @override
  String get tipWhatYouNeedBody =>
      'En MQTT-broker (Mosquitto) och Zigbee2MQTT som körs på en hubb: Home Assistant, en Raspberry Pi eller en SMLIGHT-hubb.';

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
}
