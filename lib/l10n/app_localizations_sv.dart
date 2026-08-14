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
  String get onboardingWelcomeTitle => 'Välkommen till ZigDash';

  @override
  String get onboardingWelcomeSubtitle =>
      'Din privata, lokala dashboard för Zigbee2MQTT.\nIngen molntjänst. Ingen spårning. Bara kontroll.';

  @override
  String get onboardingBrokerTitle => 'Anslut din broker';

  @override
  String get onboardingBrokerSubtitle =>
      'Peka ZigDash mot din MQTT-broker för att prata direkt med dina Zigbee-enheter. Fungerar med Mosquitto, SMLIGHT och alla MQTT-servrar.';

  @override
  String get onboardingDashboardTitle => 'Skapa dina dashboards';

  @override
  String get onboardingDashboardSubtitle =>
      'Skapa egna dashboards med strömbrytare, reglage, rullgardiner med mera. Ordna paneler som du vill – allt sparas lokalt på din enhet.';

  @override
  String get onboardingSkip => 'Hoppa över';

  @override
  String get onboardingNext => 'Nästa';

  @override
  String get onboardingGetStarted => 'Kom igång';

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
  String get connectionsTitle => 'Anslutningar';

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
  String get panelFormWidth => 'Bredd';

  @override
  String get panelFormWidthFull => 'Full';

  @override
  String get panelFormWidthHalf => 'Halv';

  @override
  String get panelFormWidthThird => 'Tredjedel';

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
  String get panelTileWidth => 'Bredd';

  @override
  String get panelTileWidthFull => 'Full';

  @override
  String get panelTileWidthHalf => 'Halv';

  @override
  String get panelTileWidthThird => '⅓';

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
      'Inga paneler ännu.\nTryck på + för att lägga till en Strömbrytare, ett Reglage eller en Knapp.';

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
  String get onboardingConnectBroker => 'Anslut min server';

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
      'SMLIGHT / SMHUB: öppna enhetens webbgränssnitt, aktivera MQTT-brokern och kontrollera att Zigbee2MQTT visas som ansluten.';

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
}
