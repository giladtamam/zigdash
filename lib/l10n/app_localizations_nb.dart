// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Sist kjente';

  @override
  String get reliabilityControlsUnavailable => 'Kontroller utilgjengelige';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'Prøv demo';

  @override
  String get navBrokers => 'Brokere';

  @override
  String get navDashboards => 'Dashbord';

  @override
  String get navSettings => 'Innstillinger';

  @override
  String get settingsAppearance => 'Utseende';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Lyst';

  @override
  String get themeDark => 'Mørkt';

  @override
  String get settingsDynamicColor => 'Bruk Material You-farger';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; ellers brukes appens farge';

  @override
  String get settingsLanguage => 'Språk';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'Engelsk';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Hjem';

  @override
  String connLoadFailed(Object error) {
    return 'Kunne ikke laste inn: $error';
  }

  @override
  String get connAddBroker => 'Legg til broker';

  @override
  String get connEmpty =>
      'Ingen tilkoblinger ennå.\nTrykk på „Legg til broker” for å peke ZigDash mot MQTT-serveren din.';

  @override
  String get connNew => 'Ny tilkobling';

  @override
  String get connEdit => 'Rediger tilkobling';

  @override
  String get save => 'Lagre';

  @override
  String get saving => 'Lagrer…';

  @override
  String get fieldRequired => 'Påkrevd';

  @override
  String get connName => 'Navn';

  @override
  String get connNameHint => 'Hjemmebroker';

  @override
  String get connHost => 'Vert';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Lokal vert';

  @override
  String get connFindBrokers => 'Finn brokere';

  @override
  String get connHowToFind => 'Hvordan finner jeg dette?';

  @override
  String get connRescan => 'Skann på nytt';

  @override
  String get connBrokerNeedsLogin => 'Innlogging kreves';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Skanner $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return '$count broker(e) funnet – trykk for å bruke';
  }

  @override
  String get connFindBrokersNone =>
      'Fant ingen brokere på Wi-Fi-nettverket ditt.';

  @override
  String get connFindBrokersNoIp =>
      'Kunne ikke lese Wi-Fi-adressen din. Kontroller at Wi-Fi er på, og prøv igjen.';

  @override
  String get connHelpTitle => 'Finne brokerens IP';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT i Docker';

  @override
  String get connHelpDockerBody =>
      'Brokerens IP er LAN-adressen til maskinen som kjører Docker (NAS-en din, Raspberry Pi osv.). Finn den i ruterens enhetsliste, eller kjør \'hostname -I\' / \'ip addr\' på den maskinen. Porten er vanligvis 1883 (Mosquitto). Bruk vertens LAN-IP – ikke 127.0.0.1 – selv om Mosquitto kjører i sin egen container.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'Brokerens IP er hubens IP-adresse. Åpne hubens nettside (smhub.local): på Dashboard viser Network-boksen den ved siden av IPv4. Ruterens app viser også huben som SMHUB. Porten er 1883, uten brukernavn/passord som standard.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA har ingen MQTT-broker – den snakker direkte med Home Assistant, så ZigDash kan ikke koble til. For å bruke ZigDash, bytt til Zigbee2MQTT (tilgjengelig som Home Assistant-app eller Docker-container), som gir en MQTT-broker.';

  @override
  String get connHelpSameNetwork =>
      'Telefonen og brokeren må være på samme Wi-Fi-nettverk (ikke et gjeste- eller isolert VLAN).';

  @override
  String get connRemoteHost => 'Ekstern vert (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Brukes når den lokale verten ikke kan nås. Foretrekk hubens Tailscale-IP, f.eks. 100.x.y.z';

  @override
  String get connPort => 'Port';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsername => 'Brukernavn';

  @override
  String get connUsernameOptional => 'Brukernavn (valgfritt)';

  @override
  String get connPasswordOptional => 'Passord (valgfritt)';

  @override
  String get connPasswordKeepHint => 'La stå tomt for å beholde eksisterende';

  @override
  String get connAutoConnect => 'Koble til automatisk ved appstart';

  @override
  String get advanced => 'Avansert';

  @override
  String get connKeepAlive => 'Keep-alive (sekunder)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protokoll';

  @override
  String get edit => 'Rediger';

  @override
  String get delete => 'Slett';

  @override
  String get cancel => 'Avbryt';

  @override
  String get connDeleteTitle => 'Slette tilkoblingen?';

  @override
  String connDeleteContent(Object name) {
    return 'Fjerner „$name”, dashbordene/panelene og det lagrede passordet.';
  }

  @override
  String get statusDisconnected => 'Frakoblet';

  @override
  String get statusConnecting => 'Kobler til…';

  @override
  String get statusConnected => 'Tilkoblet';

  @override
  String get statusReconnecting => 'Kobler til på nytt…';

  @override
  String get statusError => 'Feil';

  @override
  String get statusConnectedRemote => 'Tilkoblet · Ekstern';

  @override
  String get dashPlaceholder =>
      'Åpne en broker fra Brokere-fanen for å se og administrere dashbordene.';

  @override
  String get dashAddDashboard => 'Legg til dashbord';

  @override
  String get dashEditDashboard => 'Rediger dashbord';

  @override
  String get dashAddPanel => 'Legg til panel';

  @override
  String get dashEmpty =>
      'Ingen dashbord ennå.\nTrykk på „Legg til dashbord” for å opprette ett for denne brokeren.';

  @override
  String dashLoadFailed(Object error) {
    return 'Feil: $error';
  }

  @override
  String get panelPickerTitle => 'Legg til panel';

  @override
  String get panelPickerSectionControl => 'Kontroll';

  @override
  String get panelPickerSectionState => 'Status';

  @override
  String get panelPickerToggleTitle => 'Bryter';

  @override
  String get panelPickerToggleSubtitle => 'På/av-bryter for en enhetsstatus';

  @override
  String get panelPickerSliderBrightnessTitle => 'Glidebryter – Lysstyrke';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Demp lys (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Glidebryter – Posisjon';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Persienne (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Persienne';

  @override
  String get panelPickerCoverSubtitle =>
      'Persienne: ÅPEN·STOPP·LUKKET + posisjonsregulator';

  @override
  String get panelPickerScheduleTitle => 'Plan';

  @override
  String get panelPickerScheduleSubtitle =>
      'Daglige åpne/lukke-tider, kjører på huben (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Auto-lukk-regel';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Lukk en enhet automatisk N sekunder etter at den slås på, kjører på huben (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Flere tilstander';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Segmenterte knapper for en opplisting (f.eks. ÅPEN/STOPP/LUKKET)';

  @override
  String get panelPickerComboTitle => 'Rullemeny';

  @override
  String get panelPickerComboSubtitle => 'Rullemenyvalg for en opplisting';

  @override
  String get panelPickerRadioTitle => 'Radioknapper';

  @override
  String get panelPickerRadioSubtitle => 'Radioknappliste for en opplisting';

  @override
  String get panelPickerButtonTitle => 'Knapp';

  @override
  String get panelPickerButtonSubtitle => 'Send en engangskommando';

  @override
  String get panelPickerTextInputTitle => 'Tekstinntasting';

  @override
  String get panelPickerTextInputSubtitle =>
      'Publiser en fritekstverdi eller JSON';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Farget indikator for en boolsk tilstand (kontakt, lekkasje)';

  @override
  String get panelPickerNodeStatusTitle => 'Nodestatus';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Tilgjengelighet for Z2M-enheter (online/offline)';

  @override
  String get panelPickerProgressTitle => 'Fremdrift';

  @override
  String get panelPickerProgressSubtitle =>
      'Numerisk stolpe for batteri, koblingskvalitet osv.';

  @override
  String get panelPickerTextLogTitle => 'Tekstlogg';

  @override
  String get panelPickerTextLogSubtitle =>
      'Rullerende meldingshistorikk for et emne';

  @override
  String get dashExportMenu => 'Eksporter dashbord';

  @override
  String get dashImportMenu => 'Importer dashbord';

  @override
  String get dashExportTitle => 'Eksporter dashbord';

  @override
  String get dashExportClose => 'Lukk';

  @override
  String get dashExportCopy => 'Kopier';

  @override
  String get dashExportCopied => 'Kopiert til utklippstavlen';

  @override
  String get dashImportTitle => 'Importer dashbord';

  @override
  String get dashImportHint => 'Lim inn eksportert JSON her';

  @override
  String get dashImportButton => 'Importer';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dashbord importert',
      one: '1 dashbord importert',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Importen mislyktes: $error';
  }

  @override
  String get dashFormNew => 'Nytt dashbord';

  @override
  String get dashFormEdit => 'Rediger dashbord';

  @override
  String get dashFormName => 'Navn';

  @override
  String get dashFormNameHint => 'Kontor';

  @override
  String get dashFormTopicPrefix => 'Emneprefiks (valgfritt)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/stue';

  @override
  String get dashFormTopicPrefixHelper =>
      'Settes foran alle panel-emner i dette dashbordet';

  @override
  String get dashFormColorSeed => 'Farge';

  @override
  String get dashFormIcon => 'Ikon';

  @override
  String get dashFormLock => 'Redigeringslås';

  @override
  String get dashFormLockSubtitle => 'Skjuler Rediger for dette dashbordet';

  @override
  String get dashFormDelete => 'Slett dashbord';

  @override
  String get dashDeleteTitle => 'Slette dette dashbordet?';

  @override
  String get dashDeleteContent => 'Alle panelene under det fjernes også.';

  @override
  String get dashDeleteConfirm => 'Slett';

  @override
  String panelFormNew(Object type) {
    return 'Nytt $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Rediger $type';
  }

  @override
  String get panelTypeButton => 'Knapp';

  @override
  String get panelTypeToggle => 'Bryter';

  @override
  String get panelTypeSlider => 'Glidebryter';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Nodestatus';

  @override
  String get panelTypeProgress => 'Fremdrift';

  @override
  String get panelTypeMultiState => 'Flere tilstander';

  @override
  String get panelTypeCombo => 'Rullemeny';

  @override
  String get panelTypeRadio => 'Radioknapper';

  @override
  String get panelTypeCover => 'Persienne';

  @override
  String get panelTypeTextInput => 'Tekstinntasting';

  @override
  String get panelTypeTextLog => 'Tekstlogg';

  @override
  String get panelTypeSchedule => 'Plan';

  @override
  String get panelTypeAutoClose => 'Auto-lukk';

  @override
  String get panelTypeDevice => 'Enhet';

  @override
  String get panelTypeReading => 'Måling';

  @override
  String get panelFormName => 'Navn';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Dashbordprefiks: $prefix/ (brukes med mindre det overstyres nedenfor)';
  }

  @override
  String get panelFormTopicPrefixOverride => 'Overstyr emneprefiks (valgfritt)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/persienne';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Bruk en annen enhet på dette dashbordet. Tomt = bruk dashbordprefiks.';

  @override
  String get panelFormPublishTopic => 'Publiseringsemne (suffiks)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Legges til det effektive prefikset. La stå tomt for å publisere på selve prefikset.';

  @override
  String get panelFormTopicSuffix => 'Emne (suffiks)';

  @override
  String get panelFormSubscribeTopic => 'Abonnementsemne (suffiks, valgfritt)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Legges til dashbordprefikset. Tomt = abonner på selve prefikset (Z2M-status).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Tomt = abonner på selve prefikset (Z2M-status). Samme som Publiseringsemne = bruk det.';

  @override
  String get tileSize => 'Størrelse';

  @override
  String get tileSizeSmall => 'Liten';

  @override
  String get tileSizeWide => 'Bred';

  @override
  String get tileSizeFull => 'Full';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 – høyst én gang';

  @override
  String get panelFormQos1 => '1 – minst én gang';

  @override
  String get panelFormQos2 => '2 – nøyaktig én gang';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'På-payload';

  @override
  String get panelToggleOffPayload => 'Av-payload';

  @override
  String get panelToggleJsonPath => 'JSON-sti (valgfritt)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'På-matching';

  @override
  String get panelToggleOnMatchHelper =>
      'Verdi på JSON-stien som betyr „på” (f.eks. „ON”)';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Maks';

  @override
  String get panelSliderStep => 'Trinn';

  @override
  String get panelSliderTemplate => 'Verdimal';

  @override
  String get panelSliderTemplateHelper =>
      'Bruk ordet value som plassholder – det erstattes med glidebryterverdien';

  @override
  String get panelSliderJsonPath => 'JSON-sti (valgfritt)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'JSON-sti (valgfritt)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'f.eks. „contact”, „occupancy”, „water_leak”';

  @override
  String get panelLedOnMatch => 'På-matching';

  @override
  String get panelLedOnMatchHelper =>
      'Verdi på JSON-stien som tenner lysdioden (f.eks. „true”, „ON”)';

  @override
  String get panelLedOnLabel => 'På-etikett (valgfritt)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Av-etikett (valgfritt)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Online-payload';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Verdi som betyr „online” (Z2M-standard: „online”)';

  @override
  String get panelNodeJsonPath => 'JSON-sti (valgfritt)';

  @override
  String get panelNodeJsonPathHelper =>
      'La stå tomt for Z2M-standard (rå „online”/„offline”-streng)';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Maks';

  @override
  String get panelProgressUnit => 'Enhet';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'JSON-sti (valgfritt)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'f.eks. „battery”, „linkquality”';

  @override
  String get panelOptionsJsonPath => 'JSON-sti (valgfritt)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Felt i den mottatte payloaden som inneholder gjeldende verdi';

  @override
  String get panelOptionsHeader => 'Alternativer';

  @override
  String get panelOptionsLabel => 'Etikett';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Matching (gjeldende verdi)';

  @override
  String get panelOptionsAdd => 'Legg til alternativ';

  @override
  String get panelCoverDescription =>
      'ÅPEN-/STOPP-/LUKKET-knapper pluss en rad med posisjonsforhåndsinnstillinger. Bruker standard Z2M-persienne-payloads (state og position).';

  @override
  String get panelCoverPresets => 'Posisjonsforhåndsinnstillinger';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Kommaatskilte prosenttall (0–100). Tomt = ingen forhåndsinnstillingsrad.';

  @override
  String get panelCoverShowSlider => 'Vis posisjonsregulator';

  @override
  String get panelTextInputHint => 'Ledetekst (valgfritt)';

  @override
  String get panelTextInputHintHint => 'Skriv inn en verdi…';

  @override
  String get panelTextInputTemplate => 'Mal';

  @override
  String get panelTextInputTemplateHelper =>
      'Bruk ordet value som plassholder – det erstattes med den innskrevne teksten. Standard publiserer råteksten.';

  @override
  String get panelTextInputClearAfterSend => 'Tøm etter sending';

  @override
  String get panelTextLogMaxLines => 'Maks. linjer';

  @override
  String get panelTextLogMaxLinesHelper =>
      'Hvor mange siste meldinger som beholdes';

  @override
  String get panelTextLogJsonPath => 'JSON-sti (valgfritt)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Logg bare dette feltet i stedet for hele payloaden';

  @override
  String get panelScheduleDescription =>
      'Kjører på SMHUB via Node-RED – selv når denne telefonen er av. Publiseringsemnet ovenfor er målet for persiennekommandoer.';

  @override
  String get panelScheduleOpenTime => 'Åpningstid';

  @override
  String get panelScheduleCloseTime => 'Lukketid';

  @override
  String get panelScheduleOpenPayload => 'Åpne-payload';

  @override
  String get panelScheduleClosePayload => 'Lukk-payload';

  @override
  String get panelScheduleEnabled => 'Aktivert';

  @override
  String get panelScheduleSavedOffline =>
      'Lagret – ikke tilkoblet; planen synkroniseres når du er online.';

  @override
  String get panelAutoCloseDescription =>
      'Kjører på SMHUB via Node-RED – selv når denne telefonen er av. Publiseringsemnet ovenfor er enhetens kommandomål (f.eks. dør).';

  @override
  String get panelAutoCloseTriggerPath => 'Triggerens JSON-sti';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Felt i enhetens status-JSON å overvåke (standard: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Triggerverdi';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Start timeren når triggerfeltet er lik denne verdien (standard: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Lukk-payload';

  @override
  String get panelAutoCloseDelaySeconds => 'Forsinkelse (sekunder)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1–3600. Tid å vente etter at enheten slås på før lukk-payloaden publiseres.';

  @override
  String get panelAutoCloseEnabled => 'Aktivert';

  @override
  String get panelAutoCloseSavedOffline =>
      'Lagret – ikke tilkoblet; regelen synkroniseres når du er online.';

  @override
  String get panelTileEdit => 'Rediger panel';

  @override
  String get panelTileDuplicate => 'Dupliser panel';

  @override
  String get panelTileMoveUp => 'Flytt opp';

  @override
  String get panelTileMoveDown => 'Flytt ned';

  @override
  String get panelTileDelete => 'Slett panel';

  @override
  String get panelCoverOpen => 'Åpne';

  @override
  String get panelCoverStop => 'Stopp';

  @override
  String get panelCoverClose => 'Lukk';

  @override
  String get panelToggleNoState => '(ingen status)';

  @override
  String get panelToggleError => 'feil';

  @override
  String get panelStateOn => 'ON';

  @override
  String get panelStateOff => 'OFF';

  @override
  String get panelNodeStatusOnline => 'online';

  @override
  String get panelNodeStatusOffline => 'offline';

  @override
  String get panelNodeStatusUnknown => 'ukjent';

  @override
  String get panelNodeStatusError => 'feil';

  @override
  String get panelMultiStateNoOptions => 'Ingen alternativer konfigurert';

  @override
  String get panelTextInputDefaultHint => 'Skriv inn en verdi…';

  @override
  String get panelTextLogWaiting => 'Venter på meldinger…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Åpner $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Lukker $time';
  }

  @override
  String get panelScheduleOfflineWarning =>
      'Planleggeren er offline – kjører ikke';

  @override
  String get panelScheduleDisabled => 'Deaktivert';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Neste: $action kl. $at';
  }

  @override
  String get panelScheduleActionOpen => 'åpne';

  @override
  String get panelScheduleActionClose => 'lukke';

  @override
  String get panelAutoCloseIdle => 'Inaktiv';

  @override
  String get panelAutoCloseDisabled => 'Deaktivert';

  @override
  String get panelAutoCloseOffline =>
      'Automatisering offline – regelen kjører ikke';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Lukker om ${seconds}s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Lukker nå…';

  @override
  String get panelGridEmpty =>
      'Ingen fliser ennå.\nTrykk på Legg til flis for å legge enhetene dine her.';

  @override
  String get panelsOffline => 'Offline – viser siste verdier';

  @override
  String get connectionConnecting => 'Kobler til…';

  @override
  String get connectionReconnecting => 'Kobler til på nytt…';

  @override
  String get connectionShowingLastKnownValues => 'Viser sist kjente verdier';

  @override
  String get connectionFailed => 'Tilkoblingen mislyktes';

  @override
  String get connectionAutomaticRetry => 'Automatiske forsøk fortsetter';

  @override
  String get connectionReconnectNow => 'Koble til på nytt nå';

  @override
  String get settingsAbout => 'Om';

  @override
  String get settingsHelp => 'Hjelp & veiledning';

  @override
  String get settingsVersion => 'Versjon';

  @override
  String get settingsRateApp => 'Vurder ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Liker du den? En rask anmeldelse hjelper andre med å finne appen.';

  @override
  String get settingsFeatureRequest => 'Foreslå en funksjon';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Fortell meg hva som ville gjort ZigDash bedre.';

  @override
  String get featureRequestGithub => 'På GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Offentlig: andre kan se det og stemme.';

  @override
  String get featureRequestEmail => 'På e-post';

  @override
  String get featureRequestEmailSubtitle => 'Privat, rett til utvikleren.';

  @override
  String get featureRequestEmailSubject => 'ZigDash: funksjonsønske';

  @override
  String get featureRequestEmailPrompt =>
      'Hva vil du at ZigDash skal kunne, og hvorfor?';

  @override
  String get settingsReportProblem => 'Rapporter et problem';

  @override
  String get settingsReportProblemSubtitle =>
      'Er noe ødelagt eller forvirrende? Si fra.';

  @override
  String get reportProblemEmailSubject => 'ZigDash: problemrapport';

  @override
  String get reportProblemEmailPrompt => 'Hva skjedde, og hva forventet du?';

  @override
  String get settingsBuyCoffee => 'Kjøp meg en kaffe';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Gratis og åpen kildekode — tips holder kaffen varm.';

  @override
  String get a11yBackupMenu => 'Sikkerhetskopier & gjenopprett';

  @override
  String get a11ySelectColor => 'Velg farge';

  @override
  String get a11ySelectIcon => 'Velg ikon';

  @override
  String get a11yDeleteOption => 'Slett alternativ';

  @override
  String get a11yPanelOptions => 'Panelalternativer';

  @override
  String get a11yMoreOptions => 'Flere alternativer';

  @override
  String get a11yRefresh => 'Oppdater';

  @override
  String get a11yDeleteConnection => 'Slett tilkobling';

  @override
  String get controlNotConnected => 'Ikke tilkoblet – endringen ble ikke sendt';

  @override
  String get discoverFromDevice => 'Legg til fra en enhet…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Oppdag en Zigbee2MQTT-enhet automatisk';

  @override
  String get discoverTitle => 'Legg til fra enhet';

  @override
  String get discoverBaseTopic => 'Zigbee2MQTT-basistemne';

  @override
  String get discoverScanning => 'Søker etter enheter…';

  @override
  String get discoverNone => 'Fant ingen enheter.';

  @override
  String get discoverFailed =>
      'Fant ingen enhetsliste. Kontroller basistemenet og at brokeren er tilkoblet.';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get previewTitle => 'Liveforhåndsvisning';

  @override
  String previewWaiting(Object topic) {
    return 'Venter på en melding på $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Ekstrahert ($path): $value';
  }

  @override
  String get previewNoValue => '(ingen verdi på denne stien)';

  @override
  String get connErrorTitle => 'Tilkoblingsfeil';

  @override
  String get connErrorUnknown => 'Ingen feildetaljer tilgjengelige.';

  @override
  String get connTestButton => 'Test tilkobling';

  @override
  String get connTestOk => 'Tilkoblingen lyktes';

  @override
  String connTestFailed(Object error) {
    return 'Tilkoblingen mislyktes: $error';
  }

  @override
  String get devicesTitle => 'Enheter';

  @override
  String get devicesAddButton => 'Legg til enhet';

  @override
  String get devicesPairingTitle => 'Parer – trykk på enhetens knapp';

  @override
  String devicesPairingHint(int seconds) {
    return 'Søker etter nye enheter… ${seconds}s';
  }

  @override
  String get devicesPairingStop => 'Stopp';

  @override
  String get devicesNone => 'Fant ingen enheter.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT har ikke sendt enhetslisten sin. Det kan skje etter at MQTT-brokeren er startet på nytt.';

  @override
  String get devicesRestartZ2m => 'Start Zigbee2MQTT på nytt';

  @override
  String get devicesRestartingZ2m =>
      'Zigbee2MQTT startes på nytt. Enhetene dine bør dukke opp om noen sekunder.';

  @override
  String get devicesBattery => 'Batteri';

  @override
  String get devicesLinkQuality => 'Kobling';

  @override
  String get devicesOnline => 'Online';

  @override
  String get devicesOffline => 'Offline';

  @override
  String devicesPaired(Object name) {
    return 'Klar: $name';
  }

  @override
  String get devicesPairedHint =>
      'Lagt til i nettverket ditt. For å sette den på et dashbord, bruk „Legg til fra en enhet” på det dashbordet.';

  @override
  String get scenesTitle => 'Scener';

  @override
  String get scenesNone =>
      'Ingen scener ennå. Still inn enhetene dine slik du vil, og lagre dem deretter som en scene.';

  @override
  String get scenesNewButton => 'Ny scene';

  @override
  String scenesActivated(Object name) {
    return '$name aktivert';
  }

  @override
  String get scenesActivateOffline =>
      'Ikke tilkoblet – scenen kan ikke aktiveres';

  @override
  String get sceneFormNewTitle => 'Ny scene';

  @override
  String get sceneFormEditTitle => 'Rediger scene';

  @override
  String get sceneFormNameLabel => 'Scenenavn';

  @override
  String get sceneFormDevicesHeader => 'Enheter å fange';

  @override
  String get sceneFormCaptureHint =>
      'Hver valgte enhets gjeldende innstillbare status (på/av, lysstyrke, farge, posisjon…) lagres. Skrivebeskyttede verdier ignoreres.';

  @override
  String get sceneFormNoDevices =>
      'Fant ingen styrbare enheter. Kontroller at de er paret, og trykk deretter på oppdater.';

  @override
  String get sceneFormReadingState => 'Leser gjeldende status…';

  @override
  String get sceneCtrlPower => 'Strøm';

  @override
  String get sceneCtrlBrightness => 'Lysstyrke';

  @override
  String get sceneCtrlPosition => 'Posisjon';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count valgt';
  }

  @override
  String get sceneFormNoDevicesSelected => 'Velg minst én enhet å fange.';

  @override
  String get sceneFormNothingCaptured =>
      'Ingenting innstillbart ble fanget fra de valgte enhetene.';

  @override
  String get sceneDeleteTitle => 'Slette scenen?';

  @override
  String sceneDeleteMessage(Object name) {
    return '„$name” fjernes. Enhetene beholder sin gjeldende status.';
  }

  @override
  String get sceneEditAction => 'Rediger';

  @override
  String get sceneDeleteAction => 'Slett';

  @override
  String get sceneAddToDashboard => 'Legg til på dashbord';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Lagt til på $name';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count enheter';
  }

  @override
  String get scenesAllShutters => 'Alle persienner';

  @override
  String get sceneCloseAllShutters => 'Lukk alle persienner';

  @override
  String get sceneOpenAllShutters => 'Åpne alle persienner';

  @override
  String get sceneStopAllShutters => 'Stopp alle persienner';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persienner',
      one: '1 persienne',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Hvilke persienner…';

  @override
  String get sceneWhichShuttersHint =>
      'Alle persienner i dette hjemmet er med. Fjern haken på dem som skal holdes utenfor, som en garasjeport.';

  @override
  String get scenesYours => 'Dine scener';

  @override
  String get panelTypeScene => 'Scene';

  @override
  String get panelPickerSceneTitle => 'Sceneknapp';

  @override
  String get panelPickerSceneSubtitle => 'Ett trykk aktiverer en lagret scene';

  @override
  String get panelSceneChoose => 'Scene';

  @override
  String get panelSceneMissing => 'Scenen ble ikke funnet – velg på nytt';

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
  String get guidedConnectTitle => 'Sett opp broker';

  @override
  String get guidedConnectIntro =>
      'Vi tester hvert trinn i tilkoblingen og viser Zigbee-enhetene dine.';

  @override
  String get guidedBaseTopic => 'Basistemae';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Test og koble til';

  @override
  String get guidedTesting => 'Tester tilkoblingen…';

  @override
  String get stepResolve => 'Løse opp vert';

  @override
  String get stepTcp => 'TCP-tilkobling';

  @override
  String get stepConnack => 'MQTT-håndtrykk';

  @override
  String get stepAuth => 'Autentisering';

  @override
  String get stepDevices => 'Søker etter enheter';

  @override
  String get diagResolveFail =>
      'Vertsnavnet kunne ikke løses opp. Kontroller adressen du skrev inn.';

  @override
  String get diagResolveTimeout =>
      'Oppløsningen av verten tok for lang tid. Kontroller adresse og nettverk.';

  @override
  String get diagTcpFail =>
      'Megleren godtok ikke tilkoblingen. Kontroller at MQTT-megleren (vanligvis Mosquitto) kjører og godtar tilkoblinger fra andre enheter, og at adresse og port (vanligvis 1883) stemmer.';

  @override
  String get diagTcpTimeout =>
      'Tilkoblingen til brokeren tok for lang tid. Den kan være frakoblet eller utilgjengelig.';

  @override
  String get diagConnackFail =>
      'Brokeren fullførte ikke MQTT-håndtrykket. Sørg for at det er en MQTT-broker (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'Brokeren svarte ikke på innloggingen i tide. Home Assistant kan bruke noen sekunder på å sjekke den, så prøv igjen.';

  @override
  String get diagAuthRejected =>
      'Brokeren avviste brukernavn eller passord. Kontroller påloggingsinformasjonen.';

  @override
  String get diagAuthRefused =>
      'Brokeren avviste tilkoblingen. Kontroller tilkoblingsinnstillingene.';

  @override
  String get diagResolveLocalName =>
      'Telefonen fant ikke dette navnet. Android klarer ofte ikke å slå opp navn som slutter på .local, så skriv inn IP-adressen i stedet (Home Assistant viser den under Innstillinger › System › Nettverk).';

  @override
  String get diagTcpHaNoBroker =>
      'Dette er Home Assistant-en din, men det kjører ingen MQTT-broker på den. Installer og start appen Mosquitto broker (Innstillinger › Apper), og prøv igjen.';

  @override
  String get diagTcpSmlightClosed =>
      'Dette er SMLIGHT-huben din, men MQTT-megleren på den godtar ikke tilkoblinger fra andre enheter. Åpne Settings › MQTT på hubens nettside, slå på Allow External, lagre og prøv igjen.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Zigbee2MQTT kjører på denne adressen, men når brokeren sin under et annet navn (se Zigbee2MQTT › Settings › MQTT › Server). Er det en annen maskin, skriv inn adressen dens, vanligvis med port 1883. Er det en container på denne maskinen, publiser porten (ports: \"1883:1883\") og la den lytte på nettverket, og prøv igjen.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Zigbee2MQTT kjører på denne adressen, men MQTT-megleren godtar ikke tilkoblinger fra andre enheter. Mosquitto lytter bare på sin egen maskin til du legger linjene «listener 1883» og «allow_anonymous true» til i mosquitto.conf (eller setter opp et passord). Start Mosquitto på nytt og prøv igjen.';

  @override
  String get diagAuthRejectedHa =>
      'Megleren i Home Assistant avviste denne påloggingen. Bruk navnet og passordet til en Home Assistant-bruker (Innstillinger › Personer › Brukere); helst en egen bruker bare for MQTT.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fant $count enheter',
      one: 'Fant 1 enhet',
    );
    return '$_temp0';
  }

  @override
  String get foundDevicesHint =>
      'Zigbee-enhetene dine er synlige. Fortsett til dashbordet.';

  @override
  String get noDevicesTitle => 'Tilkoblet – ingen enheter funnet ennå';

  @override
  String get noDevicesHint =>
      'ZigDash ser brokeren, men har ennå ikke funnet noen Zigbee-enheter. Du kan starte paring.';

  @override
  String get startPairing => 'Start paring';

  @override
  String get pairingEnabled =>
      'Paring er aktivert. Trykk på paringsknappen på enheten din.';

  @override
  String get continueToDashboard => 'Fortsett til dashbordet';

  @override
  String get guidedBackToForm => 'Rediger innstillinger';

  @override
  String get guidedStuckTitle => 'Står du fast? Spør et menneske';

  @override
  String get guidedStuckBody =>
      'To forsøk uten tilkobling. Fortell oss hvilken hub du har og hva du skrev, så hjelper vi deg å finne den.';

  @override
  String get guidedStuckTelegram => 'Spør i Telegram';

  @override
  String get guidedStuckHelp => 'Tips og e-post';

  @override
  String ladderTriedHint(Object count) {
    return 'Prøvde $count adresser';
  }

  @override
  String get guidedSaveFailed => 'Kunne ikke lagre tilkoblingen. Prøv igjen.';

  @override
  String get setupWelcomeTitle => 'Velkommen til ZigDash';

  @override
  String get setupWelcomeHeadline => 'Zigbee-hjemmet ditt, på mobilen';

  @override
  String get setupWelcomeBody =>
      'Alt du trenger er en liten hub som kjører Zigbee2MQTT: en SMLIGHT-hub, en Raspberry Pi eller en hvilken som helst Linux-maskin. Du trenger ikke Home Assistant, og har du det, fungerer ZigDash med det også. Alt blir lokalt, uten sky.';

  @override
  String get setupFindMySetup => 'Finn oppsettet mitt';

  @override
  String get setupErrPageTitle => 'Zigbee2MQTT-siden svarte ikke';

  @override
  String get setupErrPageBody =>
      'Ingen Zigbee2MQTT-side svarte på den adressen. Åpne den i nettleseren på telefonen for å sjekke, og kopier adressen nøyaktig (med port, ofte 8080). Hvis siden ber om et token, skriv inn megler-detaljene i stedet.';

  @override
  String get setupErrPageAction => 'Prøv igjen';

  @override
  String get setupLookWider => 'Søk i hele nettverket';

  @override
  String get setupAsk => 'Hva driver Zigbee-en din?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'På en Raspberry Pi, en server eller i Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'Med Zigbee2MQTT-appen, eller ZHA';

  @override
  String get setupAskSmlight => 'SMLIGHT';

  @override
  String get setupAskSmlightSub => 'En SMHUB eller en SLZB-adapter';

  @override
  String get setupAskSmlightWhich => 'Hvilken SMLIGHT-enhet har du?';

  @override
  String get setupAskSmhub => 'SMHUB';

  @override
  String get setupAskSmhubSub => 'Zigbee2MQTT kjører på selve huben';

  @override
  String get setupAskSlzb => 'En SLZB-adapter';

  @override
  String get setupAskSlzbSub =>
      'SLZB-06, SLZB-MR og andre: bare Zigbee-radioen';

  @override
  String get setupSlzbWhere =>
      'SLZB-en din er Zigbee-radioen. Zigbee2MQTT kjører på en annen maskin: hvilken?';

  @override
  String get setupRunningAsk => 'Kjører Zigbee2MQTT allerede?';

  @override
  String get setupRunningYes => 'Ja, det kjører';

  @override
  String get setupRunningNotYet => 'Ikke ennå';

  @override
  String get setupRunningNotSure => 'Usikker';

  @override
  String get setupRunningYesNote =>
      'Da når ikke denne telefonen den herfra. Oftest er telefonen på et gjestenett eller et annet Wi-Fi, eller megleren godtar bare tilkoblinger fra sin egen maskin (Mosquitto 2 gjør det til konfigurasjonen har \"listener 1883\"). Skriv inn adressen nedenfor for å sjekke den.';

  @override
  String get setupRunningNotYetNote =>
      'ZigDash kobler til en Zigbee2MQTT som allerede kjører. Se hva du trenger for å starte, og prøv demoen så lenge.';

  @override
  String setupRunningNotSureNote(String button) {
    return 'Zigbee2MQTT har sin egen nettside, der du parer Zigbee-enhetene dine. Har du åpnet den, kjører det: trykk på «$button» nedenfor. Har du aldri sett den, er det ikke satt opp ennå.';
  }

  @override
  String get setupRunningWhatToGet => 'Hva du trenger';

  @override
  String get setupAskNothing => 'Ingenting ennå?';

  @override
  String get setupAskHaWhich => 'Hvordan kjører Home Assistant-en din Zigbee?';

  @override
  String get setupAskHaZ2m => 'Zigbee2MQTT-appen';

  @override
  String get setupAskHaZ2mSub => 'Logg inn med Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, Home Assistants egen Zigbee';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, uten Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Koble til Zigbee2MQTT-siden min';

  @override
  String get setupManualEntryAdvanced => 'Skriv inn megler-detaljer (avansert)';

  @override
  String get z2mPageTitle => 'Zigbee2MQTT-siden din';

  @override
  String get z2mPageBody =>
      'Adressen i nettleseren når Zigbee2MQTT-siden er åpen, den du parer enheter på. Ingen MQTT-brukernavn eller passord trengs.';

  @override
  String get z2mPageLabel => 'Sidens adresse';

  @override
  String get z2mPageConnect => 'Koble til';

  @override
  String z2mPageFoundName(String host, String ip) {
    return 'Fant $host på $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Ingenting svarte for $host på dette nettverket';
  }

  @override
  String get engineNeedsBrokerTitle => 'Automasjoner trenger MQTT-megleren din';

  @override
  String get engineNeedsBrokerBody =>
      'Dette hjemmet kobler seg til via Zigbee2MQTT-siden, og det holder for dashbordene. Automasjoner, varsler og historikk kjører i ZigDash Engine på huben din, som snakker via MQTT-megleren. Skriv inn detaljene én gang, så kobler ZigDash seg til via megleren fra da av.';

  @override
  String get engineNeedsBrokerButton => 'Skriv inn megler-detaljer';

  @override
  String get connFromPageNote =>
      'Dette hjemmet kobler seg til via Zigbee2MQTT-siden. Skriv inn MQTT-megleren din (som regel samme maskin, port 1883) for å slå på automasjoner, varsler og historikk. Etter lagring kobler ZigDash seg til via megleren.';

  @override
  String get setupManualEntry => 'Skriv inn detaljer manuelt';

  @override
  String get setupScanningTitle => 'Leter etter en tilkobling…';

  @override
  String get setupScanningHint =>
      'Hold denne enheten på samme lokale nettverk som Zigbee2MQTT-verten din.';

  @override
  String get setupCandidateFound => 'Mulig tilkobling funnet';

  @override
  String get setupNoCandidatesTitle => 'Ingen tilkobling funnet';

  @override
  String get setupNoCandidatesBody => 'Hvor kjører Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: sjekk at appene Mosquitto broker og Zigbee2MQTT er installert og kjører (Innstillinger › Apper).';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: sjekk at brokeren din (f.eks. Mosquitto) og Zigbee2MQTT-tjenesten kjører, og at port 1883 er tilgjengelig.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: åpne webgrensesnittet, gå til Settings > MQTT, slå på Allow External slik at telefonen når brokeren, og sjekk at Zigbee2MQTT kjører.';

  @override
  String get setupTryAgain => 'Prøv igjen';

  @override
  String get reminderButton => 'Minn meg på det i morgen';

  @override
  String get reminderSet =>
      'Vi minner deg på det i morgen, på denne telefonen.';

  @override
  String get reminderNoPermission =>
      'Varsler er slått av for ZigDash, så det blir ingen påminnelse. Du kan slå dem på i Android-innstillingene.';

  @override
  String get reminderChannel => 'Påminnelse om oppsett';

  @override
  String get reminderTitle => 'Fullfør oppsettet av ZigDash';

  @override
  String get reminderBody =>
      'Hjemme på Wi-Fi-en din? Trykk for å prøve igjen: det tar omtrent ett minutt.';

  @override
  String get setupWelcomeNoZ2m => 'Ingen Zigbee2MQTT ennå?';

  @override
  String get setupWelcomeDemo => 'Prøv demohjemmet';

  @override
  String get setupWelcomeHubs => 'Hvilken hub du bør velge';

  @override
  String get haConnectTitle => 'Koble til via Home Assistant';

  @override
  String get haConnectIntro =>
      'Telefonen din når ikke megleren, men den når Home Assistant. Logg inn én gang, så snakker ZigDash med Zigbee2MQTT via Home Assistant: hjemme eller borte, uten meglerinnstillinger.';

  @override
  String get haConnectAddressHelp =>
      'Adressen du åpner Home Assistant med: 192.168.1.20:8123, eller en ekstern adresse som Nabu Casa- eller Cloudflare-adressen din';

  @override
  String get haConnectSignInHelp =>
      'Home Assistants egen innlogging åpnes i nettleseren din. ZigDash ser aldri passordet ditt.';

  @override
  String get haConnectKeeps =>
      'ZigDash beholder denne innloggingen på telefonen din og handler som deg i Home Assistant, bare for MQTT. Avslutt det når som helst i Home Assistant under Profil › Sikkerhet.';

  @override
  String get haConnectTokenHelp =>
      'I Home Assistant åpner du profilen din, deretter Sikkerhet › Langvarige tilgangstokener › Opprett token. Kopier det og lim det inn her. ZigDash beholder det på denne telefonen for å koble til; slett det i Home Assistant når du vil avslutte.';

  @override
  String get haConnectWithToken => 'Koble til med token';

  @override
  String get haConnectChecking => 'Sjekker Home Assistant…';

  @override
  String get setupStillChecking =>
      'Sjekker fortsatt. Dette kan ta opptil 30 sekunder.';

  @override
  String get aiHelpTitle => 'Står du fast? Spør KI-assistenten din';

  @override
  String get aiHelpBody =>
      'ZigDash skriver opp hva den fant for ChatGPT, Claude, Gemini eller en annen KI-app, uten passord eller adresser. Du ser det før det deles.';

  @override
  String get aiHelpButton => 'Spør en KI';

  @override
  String get aiHelpPreviewTitle => 'Dette blir delt';

  @override
  String get aiHelpShare => 'Del til en KI-app';

  @override
  String get aiHelpCopied =>
      'Kopiert. Lim det inn i en hvilken som helst KI-chat.';

  @override
  String get haConnectWhereAddress =>
      'Usikker på hva den er? I Home Assistant-appen åpner du Innstillinger › Companion-app og trykker på serveren din: adressen står der. På en datamaskin er det adressen nettleseren viser når Home Assistant er åpen.';

  @override
  String get haFindLooking => 'Leter etter Home Assistant på dette nettverket…';

  @override
  String get haFindSeveral =>
      'Fant mer enn én Home Assistant. Trykk på den du vil bruke:';

  @override
  String get haFindNone =>
      'Denne telefonen ser ikke Home Assistant på dette wifi-nettet. Bruk adressen Home Assistant-appen din åpner: ofte en ekstern, som https://abcd1234.ui.nabu.casa eller https://mitthjem.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Den adressen er på et annet nettverk enn denne telefonen, som er på $network. Bruk adressen Home Assistant-appen din åpner, ofte en ekstern, eller koble telefonen til nettverket Home Assistant er på.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Telefonen fant ikke det navnet: Android klarer ofte ikke å åpne .local-navn. Skriv inn IP-adressen til Home Assistant (som 192.168.1.20:8123), eller den eksterne adressen.';

  @override
  String get haConnectRemoteUnreachable =>
      'Ingenting svarte på den eksterne adressen. Åpne den i nettleseren på denne telefonen for å sjekke at den virker, og kopier den nøyaktig slik Home Assistant-appen viser den.';

  @override
  String get setupNoWifiHa => 'Bruker du Home Assistant? Logg inn';

  @override
  String get haConnectNotAdmin =>
      'Home Assistant-brukeren din er ikke administrator. ZigDash trenger en for Home Assistants MQTT. Logg inn som administrator, eller lim inn et token en administrator har laget.';

  @override
  String get haConnectNoMqtt =>
      'Denne Home Assistant-en har ingen MQTT-integrasjon. Zigbee2MQTT trenger også en: legg til appen Mosquitto broker (Innstillinger › Apper) og MQTT-integrasjonen i Home Assistant, og prøv igjen.';

  @override
  String get haConnectSignInFailed =>
      'Innloggingen ble ikke fullført. Prøv igjen, eller bruk et langvarig token.';

  @override
  String get setupHaShortcut =>
      'Kjører Zigbee2MQTT i Home Assistant? Hopp over brokeren og innloggingen: logg inn med administratorkontoen din i Home Assistant. Det virker fra alle nettverk.';

  @override
  String get haConnectButton => 'Koble til via Home Assistant';

  @override
  String get haConnectManualLink =>
      'Bruker du Home Assistant? Koble til via den i stedet';

  @override
  String get haConnectEmptyNote =>
      'Når ikke denne telefonen megleren? Home Assistant kan bære tilkoblingen for deg.';

  @override
  String get haHomeConnected => 'Koblet til via Home Assistant';

  @override
  String get haHomeChange =>
      'Hvis innloggingen slutter å virke, på en ny telefon eller etter at du fjernet tokenet i Home Assistant, logger du inn på nytt her. Du kan også avslutte den i Home Assistant under Profil › Sikkerhet.';

  @override
  String get haHomeSignInAgain => 'Logg inn på nytt';

  @override
  String get haHomeRemote => 'Fjernadresse for Home Assistant (valgfritt)';

  @override
  String get setupAuthTitle => 'Denne brokeren krever innlogging';

  @override
  String setupAuthBody(Object host) {
    return 'Skriv inn MQTT-brukernavnet og passordet for $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Brukernavnet eller passordet ble avvist. Sjekk dem og prøv igjen.';

  @override
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT logger allerede inn på denne brokeren: nettsiden viser brukernavnet under Innstillinger › MQTT. Bruk den brukeren og passordet.';

  @override
  String get setupAuthWhich =>
      'Dette er MQTT-innloggingen, ikke passordet til hubens nettside.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: bruk en Home Assistant-bruker. De fleste lager en bare for MQTT under Innstillinger › Personer › Brukere, og appen Mosquitto broker godtar den.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi eller Docker: brukeren og passordet fra Mosquittos passordfil, de samme som i configuration.yaml til Zigbee2MQTT under mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: innloggingen som vises på hubens nettside under Settings › MQTT. Eller slå på Allow Anonymous der og lagre: da trengs ingen innlogging.';

  @override
  String get setupVerifyingTitle => 'Sjekker tilkoblingen…';

  @override
  String get setupReviewTitle => 'Enhetene dine';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enheter funnet.',
      one: '1 enhet funnet.',
    );
    return '$_temp0 Velg hva som kommer på det første dashbordet ditt.';
  }

  @override
  String get setupReviewLastStep =>
      'Siste steg: kryss av enhetene du vil ha, og trykk på Opprett dashbord nederst.';

  @override
  String get setupLeaveTitle => 'Opprette dashbordet?';

  @override
  String get setupLeaveBody =>
      'Enhetene dine er funnet. Opprett dashbordet nå, eller start oppsettet på nytt og mist denne listen.';

  @override
  String get setupStartOver => 'Start på nytt';

  @override
  String setupCreateWithCount(Object count) {
    return 'Lag dashbord med $count';
  }

  @override
  String get setupReviewNoneSelected =>
      'Ingenting er valgt ennå. Velg enhetene du vil ha på dashbordet, eller lag det tomt og legg til fliser senere.';

  @override
  String get setupCreateEmpty => 'Lag et tomt dashbord';

  @override
  String get setupGroupOther => 'Andre enheter';

  @override
  String get setupGroupUnsupported => 'Enheter som ikke støttes';

  @override
  String get setupCreatingTitle => 'Lager dashbordet ditt…';

  @override
  String get setupReadyTitle => 'Dashbordet ditt er klart';

  @override
  String setupReadyBody(Object count) {
    return '$count kontroller opprettet.';
  }

  @override
  String get setupOpenDashboard => 'Åpne dashbord';

  @override
  String get setupErrUnreachableTitle => 'Kan ikke nå denne adressen';

  @override
  String get setupErrUnreachableBody =>
      'Denne enheten og Zigbee2MQTT-verten kan ikke nå hverandre. Sjekk at begge er på samme lokale nettverk.';

  @override
  String get setupErrUnreachableAction => 'Prøv igjen';

  @override
  String get setupErrPortClosedTitle => 'Ingenting svarer på denne porten';

  @override
  String get setupErrPortClosedBody =>
      'Verten er tilgjengelig, men ingen MQTT-broker svarte. Sjekk at brokeren kjører og at porten er riktig.';

  @override
  String get setupErrPortClosedAction => 'Prøv igjen';

  @override
  String get setupErrAuthRequiredTitle => 'Innlogging kreves';

  @override
  String get setupErrAuthRequiredBody =>
      'Denne brokeren krever brukernavn og passord.';

  @override
  String get setupErrAuthRequiredAction => 'Skriv inn innlogging';

  @override
  String get setupErrAuthRejectedTitle => 'Innlogging avvist';

  @override
  String get setupErrAuthRejectedBody =>
      'Brokeren avviste disse påloggingsdetaljene.';

  @override
  String get setupErrAuthRejectedAction => 'Prøv igjen';

  @override
  String get setupErrNotZ2mTitle => 'Her er det ingen Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'En MQTT-broker svarer her, men ingen Zigbee2MQTT-topics ble funnet. Det kan være en annen broker.';

  @override
  String get setupErrNotZ2mAction => 'Velg en annen';

  @override
  String get setupErrNoDevicesTitle => 'Ingen enheter mottatt';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT kjører, men ingen enheter ble publisert under sjekken. Par enheter i Zigbee2MQTT først.';

  @override
  String get setupErrNoDevicesAction => 'Sjekk igjen';

  @override
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT sendte ikke enhetslisten sin';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT svarer, men enhetslisten kom ikke. Dette skjer som regel etter at MQTT-megleren er startet på nytt: Zigbee2MQTT før 2.14.2 sender listen igjen først når det selv starter på nytt. Start Zigbee2MQTT på nytt (eller oppdater det), og prøv igjen.';

  @override
  String get setupErrListMissingAction => 'Prøv igjen';

  @override
  String get setupErrHaNoZ2mTitle => 'Ingen Zigbee2MQTT i denne Home Assistant';

  @override
  String get setupErrHaNoZ2mBody =>
      'Du er logget inn i Home Assistant, men Zigbee2MQTT sender ingenting på MQTT-en sin. Hvis Zigbee-enhetene dine er i ZHA (Home Assistants innebygde Zigbee), kan ZigDash ikke se dem: den fungerer med Zigbee2MQTT. Hvis du bruker Zigbee2MQTT-appen, åpne den under Innstillinger › Apper, sjekk at den er startet, og prøv igjen.';

  @override
  String get setupErrHaNoZ2mAction => 'Prøv igjen';

  @override
  String get setupErrScanFailedTitle => 'Ikke noe lokalt nettverk';

  @override
  String get setupErrScanFailedBody =>
      'Kunne ikke fastslå denne enhetens lokale nettverk. Koble til Wi-Fi og prøv igjen.';

  @override
  String get setupErrScanFailedAction => 'Prøv igjen';

  @override
  String get setupNoWifiTitle => 'Telefonen er ikke på Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'Den bruker mobildata og ser derfor ikke enhetene hjemme. Slå på Wi-Fi og koble til hjemmenettet: oppsettet starter igjen av seg selv.';

  @override
  String get setupNoWifiOffline =>
      'Telefonen har ingen nettverkstilkobling. Slå på Wi-Fi og koble til hjemmenettet: oppsettet starter igjen av seg selv.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash finner ikke telefonens Wi-Fi-adresse. Sjekk at Wi-Fi er på og koblet til hjemmenettet: oppsettet starter igjen av seg selv. På VPN eller borte? Skriv inn detaljene manuelt.';

  @override
  String get setupOpenWifiSettings => 'Åpne Wi-Fi-innstillinger';

  @override
  String get setupWaitingForWifi => 'Venter på Wi-Fi…';

  @override
  String get setupErrSaveFailedTitle => 'Kunne ikke lagre';

  @override
  String get setupErrSaveFailedBody =>
      'Lagring av oppsettet mislyktes. Ingenting ble halvlagret — du kan trygt prøve igjen.';

  @override
  String get setupErrSaveFailedAction => 'Prøv igjen';

  @override
  String get setupErrUnknownTitle => 'Noe gikk galt';

  @override
  String get setupErrUnknownBody => 'Det oppstod en uventet feil.';

  @override
  String get setupErrUnknownAction => 'Prøv igjen';

  @override
  String get setupErrLoginNoAnswerTitle =>
      'Brokeren svarte ikke på innloggingen';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Brokeren ble funnet, men den svarte ikke på brukernavn og passord i tide. Home Assistants app Mosquitto broker sjekker innlogginger mot Home Assistant, noe som kan ta noen sekunder på en Raspberry Pi. Prøv igjen, og sjekk at denne brukeren finnes i Home Assistant. På en SMLIGHT-hub kan du i stedet slå på Allow Anonymous under Settings › MQTT, så trengs ingen innlogging.';

  @override
  String get setupErrLoginNoAnswerAction => 'Prøv igjen';

  @override
  String get setupNoZ2mTitle =>
      'Brokeren din fungerer, men Zigbee2MQTT publiserer ikke her';

  @override
  String setupNoZ2mBody(String base) {
    return 'Vi lyttet på $base/bridge og hørte ingenting.';
  }

  @override
  String get setupBaseTopicQuestion => 'Bruker du et annet basistema?';

  @override
  String get setupGuidesTitle => 'Sett opp Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'Prøv demoen i mellomtiden';

  @override
  String get setupPlatformQuestion => 'Mens vi leter: hvor kjører Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => 'Hvor kjører Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Velg en tilkobling';

  @override
  String get setupScanDoneHint =>
      'Mer enn én broker svarte. Velg den Zigbee2MQTT bruker.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'SMHUB';

  @override
  String get setupPlatformPi => 'Raspberry Pi eller Docker';

  @override
  String get setupPlatformZha => 'ZHA, ikke Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash viser enheter fra Zigbee2MQTT, så den ser ikke enheter i ZHA, Home Assistants egen Zigbee. Du kan prøve demohjemmet for å se hvordan ZigDash fungerer.';

  @override
  String get setupPlatformNotSure => 'Ikke sikker';

  @override
  String setupScanProgress(int checked, int total) {
    return 'Sjekket $checked av $total adresser';
  }

  @override
  String get setupScanHintHa => 'Leter etter Home Assistant og MQTT-brokeren…';

  @override
  String get setupScanHintSmlight => 'Ser etter SMHUB-en din…';

  @override
  String get setupScanHintPi =>
      'Leter etter en MQTT-broker på nettverket ditt…';

  @override
  String setupHubSeenHa(String host) {
    return 'Fant Home Assistant på $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Fant Zigbee2MQTT på $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Fant SMLIGHT-huben din på $host';
  }

  @override
  String get setupHubSeenHint => 'Leter fortsatt etter MQTT-brokeren…';

  @override
  String get setupNoBrokerHaTitle =>
      'Fant Home Assistant, men ingen MQTT-broker';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant er på $host, men ingenting svarer på MQTT-port 1883. Åpne Innstillinger › Apper i Home Assistant, installer og start appen Mosquitto broker, og prøv igjen.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Bruker du Home Assistants innebygde Zigbee (ZHA) i stedet for Zigbee2MQTT? ZigDash fungerer bare med Zigbee2MQTT og ser derfor ikke ZHA-enheter. Demoen viser hva du ville fått.';

  @override
  String get setupNoBrokerHaDocker =>
      'Ingen Apper i innstillingene til Home Assistant-en din? Da kjører den i Docker (Home Assistant Container), som ikke har apper: Mosquitto kjører i sin egen container. Skriv inn adressen til maskinen som kjører den nedenfor.';

  @override
  String get setupVpnHint =>
      'Et VPN er på, og det kan skjule hjemmenettet ditt for søket. Er du hjemme, slå av VPN-et og trykk Prøv igjen. Eller la det være på og tillat tilgang til lokalt nettverk (LAN) i innstillingene til VPN-appen.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Fant Zigbee2MQTT, men brokeren kan ikke nås';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT er på $host, men MQTT-brokeren godtar ikke tilkoblinger fra telefonen din. Mosquitto 2 lytter bare på huben selv til oppsettet har \'listener 1883\' og \'allow_anonymous true\' (eller en innlogging). Start den på nytt og prøv igjen.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Fant SMLIGHT-huben din, men MQTT er av';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Huben din er på $host, men MQTT-brokeren kan ikke nås. Åpne Settings › MQTT i hubens nettgrensesnitt, slå på Allow External og sjekk at Zigbee2MQTT kjører. Prøv så igjen.';
  }

  @override
  String get setupZ2mAsking => 'Spør Zigbee2MQTT hvor brokeren er…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Brokeren godtar bare tilkoblinger fra sin egen maskin';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT bruker $server, og ingenting svarer der fra telefonen din. Mosquitto 2 gjør dette som standard. Legg til disse to linjene i mosquitto.conf, start Mosquitto på nytt og prøv igjen:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Vil du heller ha innlogging enn åpen tilgang? Bruk en password_file i stedet for allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT når brokeren sin via et navn telefonen din ikke kan bruke';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT bruker $server. «$name» er et navn bare maskinen til Zigbee2MQTT kjenner, en Docker-tjeneste eller et vertsnavn. Skriv inn IP-adressen til broker-maskinen med port $port i stedet. Kjører brokeren i en container, må porten også publiseres på maskinen (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'Nettsiden til Zigbee2MQTT er beskyttet med et token, så appen kunne ikke lese hvor brokeren er. Skriv inn broker-adressen fra Zigbee2MQTT › Settings › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT bruker brokeren på $server, men den svarte ikke telefonen din. Sjekk at brokeren kjører og at telefonen er på samme nettverk.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Koble til $host';
  }

  @override
  String get setupNotFoundHa =>
      'Fant ingen Home Assistant på dette nettverket. Sjekk at telefonen er på samme Wi-Fi som Home Assistant (ikke et gjestenett), og prøv igjen. Vet du adressen, skriv den inn nedenfor.';

  @override
  String get setupNotFoundSmlight =>
      'Fant ingen SMLIGHT-hub på dette nettverket. Sjekk at huben er på og at telefonen er på samme Wi-Fi, og prøv igjen. Vet du adressen, skriv den inn nedenfor.';

  @override
  String get setupNotFoundPi =>
      'Fant ingen MQTT-broker på dette nettverket. Sjekk at Mosquitto kjører og lytter på nettverket (port 1883), og at telefonen er på samme Wi-Fi. Prøv så igjen.';

  @override
  String get setupAddressQuestionHa => 'Hvor åpner du Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'Hva er adressen til SMLIGHT-huben din?';

  @override
  String get setupAddressWhereSmlight =>
      'Åpne nettsiden til huben: smhub.local, eller smhub.local:3000 på tidlige huber. På Dashboard viser Network-boksen adressen ved siden av IPv4. Skriv den inn her. Hvis siden ikke åpnes, viser ruterens app huben som SMHUB, med IP-en.';

  @override
  String get setupAddressSlzbSmlight =>
      'En SLZB-06, MR eller UltimaX er bare Zigbee-radioen og har ingen broker. Skriv i stedet adressen til datamaskinen som kjører Zigbee2MQTT og Mosquitto.';

  @override
  String get setupAddressQuestionPi =>
      'Hva er adressen til maskinen som kjører Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      'Hva er adressen til huben din, eller til maskinen som kjører Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'En adresse som 192.168.1.20, et navn eller lenken fra nettleseren din';

  @override
  String get setupAddressCheck => 'Sjekk denne adressen';

  @override
  String setupAddressNothing(String host) {
    return 'Ingenting svarte på $host. Sjekk adressen, og at telefonen er på samme Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return '$host kunne ikke slås opp. Navn som slutter på .local feiler ofte på Android; prøv IP-adressen i stedet. Home Assistant viser den under Innstillinger › System › Nettverk.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host finnes ikke fra denne telefonen; Android klarer ofte ikke å slå opp .local-navn. Trykk på $button ovenfor og bruk adressen du åpner Home Assistant med i nettleseren, eller skriv IP-adressen her. Home Assistant viser den under Innstillinger › System › Nettverk.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host er ikke på hjemmenettet ditt. Bruk adressen som virker på Wi-Fi-en din, ikke en fjernlenke som Nabu Casa eller DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Skriv inn en adresse først.';

  @override
  String get setupChoicesTitle => 'Hva av dette passer for deg?';

  @override
  String get setupChoiceNoHub => 'Jeg har ikke en hub ennå';

  @override
  String get setupChoiceNoHubSub => 'Se små huber som kjører Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'Jeg bruker Home Assistant';

  @override
  String get setupChoiceHaSub => 'Let etter den på homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash kobler til Home Assistants MQTT-broker, appen Mosquitto broker under Innstillinger › Apper, og Zigbee2MQTT må også bruke den. Hvis homeassistant.local ikke blir funnet, skriv inn IP-adressen til Home Assistant nedenfor. Den står under Innstillinger › System › Nettverk.';

  @override
  String get setupChoiceOther => 'Huben min er på et annet nettverk';

  @override
  String get setupChoiceOtherSub => 'Et gjestenett eller en ekstra ruter';

  @override
  String get setupChoiceOtherNote =>
      'Telefonen må nå huben din. Et gjestenett, eller en ekstra ruter med eget Wi-Fi, holder dem adskilt. Koble til Wi-Fi-nettet huben er på, og trykk på Prøv igjen. Eller skriv inn hubens IP-adresse nedenfor, eller prøv et av disse vanlige navnene:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Telefonen din er $ip, så huben begynner vanligvis med $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Bruker du Home Assistant? Verten er adressen du åpner Home Assistant med, port 1883.';

  @override
  String get demoBannerText => 'Du er i demomodus';

  @override
  String get demoBannerAction => 'Koble til hjemmet ditt';

  @override
  String get deviceOn => 'På';

  @override
  String get deviceOff => 'Av';

  @override
  String get deviceOpen => 'Åpen';

  @override
  String get deviceClosed => 'Lukket';

  @override
  String get deviceMotion => 'Bevegelse';

  @override
  String get deviceClear => 'Rolig';

  @override
  String get deviceLeakDetected => 'Lekkasje oppdaget';

  @override
  String get deviceSmokeDetected => 'Røyk oppdaget';

  @override
  String get deviceGasDetected => 'Gass oppdaget';

  @override
  String get deviceWaiting => 'Venter på første rapport';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on på · $off av';
  }

  @override
  String get deviceBrightness => 'Lysstyrke';

  @override
  String get deviceWhite => 'Hvit';

  @override
  String get deviceColor => 'Farge';

  @override
  String get deviceHue => 'Nyanse';

  @override
  String get devicePosition => 'Posisjon';

  @override
  String get deviceControls => 'Kontroller';

  @override
  String deviceBattery(int percent) {
    return 'Batteri $percent %';
  }

  @override
  String get deviceToggle => 'Slå på eller av';

  @override
  String get deviceMore => 'Mer';

  @override
  String get sectionLights => 'Lys';

  @override
  String get sectionSwitchesCovers => 'Brytere og persienner';

  @override
  String get sectionSensors => 'Sensorer';

  @override
  String get sectionOther => 'Annet';

  @override
  String get homeFirstName => 'Mitt hjem';

  @override
  String homeNumberedName(int number) {
    return 'Hjem $number';
  }

  @override
  String get dashAddTile => 'Legg til flis';

  @override
  String get addTileSearch => 'Søk etter enheter';

  @override
  String get addTileNotOnDashboard => 'Ikke på noe dashbord';

  @override
  String get addTileAllDevices => 'Alle enheter';

  @override
  String get addTileReading => 'Måling';

  @override
  String get addTileReadingSubtitle => 'Én verdi fra en enhet eller et topic';

  @override
  String get readingShowAs => 'Vis som';

  @override
  String get readingStyleValue => 'Verdi';

  @override
  String get readingStyleGauge => 'Måler';

  @override
  String get gaugeBands => 'Fargeområder';

  @override
  String get gaugeBandsHelper =>
      'Opptil tre. Området verdien ligger i, farger buen.';

  @override
  String get gaugeBandFrom => 'Fra';

  @override
  String get gaugeBandTo => 'Til';

  @override
  String get gaugeBandAdd => 'Legg til område';

  @override
  String get gaugeBandRemove => 'Fjern område';

  @override
  String get gaugeToneNormal => 'Normal';

  @override
  String get gaugeToneGood => 'Bra';

  @override
  String get gaugeToneAttention => 'Obs';

  @override
  String get addTileCustom => 'Egendefinert MQTT-flis';

  @override
  String get addTileCustomSubtitle =>
      'Hvilken som helst flistype, satt opp med topic';

  @override
  String get addTileNoDevices =>
      'Ingen enheter å vise. Koble til brokeren, eller par en enhet i Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Legg til';

  @override
  String get addTileName => 'Navn';

  @override
  String addTileNameHint(String model) {
    return 'f.eks. $model';
  }

  @override
  String get addTileSection => 'Seksjon';

  @override
  String get addTileNoSection => 'Ingen seksjon';

  @override
  String get addTileSize => 'Størrelse';

  @override
  String get deviceClassColorLight => 'Fargelys';

  @override
  String get deviceClassLight => 'Lys';

  @override
  String get deviceClassSwitch => 'Bryter eller plugg';

  @override
  String get deviceClassCover => 'Persienne';

  @override
  String get deviceClassLeak => 'Lekkasje eller røyk';

  @override
  String get deviceClassContact => 'Kontakt';

  @override
  String get deviceClassMotion => 'Bevegelse';

  @override
  String get deviceClassClimate => 'Klimasensor';

  @override
  String get deviceClassGeneric => 'Enhet';

  @override
  String get deviceNotResponding => 'Svarer ikke';

  @override
  String get homeAdd => 'Legg til et hjem';

  @override
  String get homeManage => 'Administrer hjem';

  @override
  String get homeSwitch => 'Bytt hjem';

  @override
  String get navDevices => 'Enheter';

  @override
  String get navScenes => 'Scener';

  @override
  String get devicesNewDot => 'Nye enheter';

  @override
  String get editEditing => 'Redigerer';

  @override
  String get editDashboard => 'Dashbord';

  @override
  String get editDone => 'Ferdig';

  @override
  String get editAddSection => 'Legg til seksjon';

  @override
  String get editSectionName => 'Navn på seksjon';

  @override
  String get editRenameSection => 'Gi nytt navn';

  @override
  String get editDeleteSection => 'Slett seksjon';

  @override
  String get editDeleteSectionBody => 'Hva skal skje med flisene?';

  @override
  String get editKeepTiles => 'Behold flisene, fjern seksjonen';

  @override
  String get editDeleteTiles => 'Slett flisene også';

  @override
  String get editMoveToSection => 'Flytt til seksjon';

  @override
  String get editEditTile => 'Rediger flis';

  @override
  String get editRemove => 'Fjern fra dashbordet';

  @override
  String get editRemoved => 'Flis fjernet';

  @override
  String get editUndo => 'Angre';

  @override
  String get editReplaceWithDevice => 'Erstatt med enhetsflis';

  @override
  String get editMoveEarlier => 'Flytt fremover';

  @override
  String get editMoveLater => 'Flytt bakover';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enheter er ikke på noe dashbord',
      one: '1 enhet er ikke på noe dashbord',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Flisvalg';

  @override
  String get editSave => 'Lagre';

  @override
  String get editCancel => 'Avbryt';

  @override
  String get ageJustNow => 'Akkurat nå';

  @override
  String ageMinutes(int n) {
    return 'for $n min siden';
  }

  @override
  String ageHours(int n) {
    return 'for $n t siden';
  }

  @override
  String get statusCantReach => 'Får ikke kontakt med brokeren';

  @override
  String get statusWhy => 'Hvorfor?';

  @override
  String get statusWhyTitle => 'Brokeren svarer ikke';

  @override
  String get statusWhyBody =>
      'ZigDash prøver igjen selv. Til da viser flisene sine siste kjente verdier, dempet og med alder. Sjekk at brokeren er på og at telefonen er på samme nett, eller test tilkoblingen i innstillingene.';

  @override
  String get statusSettings => 'Tilkoblingsinnstillinger';

  @override
  String get deviceAddToDashboard => 'Legg til på et dashbord';

  @override
  String get deviceDismiss => 'Avvis';

  @override
  String get devicesFilterAll => 'Alle';

  @override
  String devicesFilterAttention(int count) {
    return 'Trenger tilsyn · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Ikke på noe dashbord · $count';
  }

  @override
  String get devicesNoMatch => 'Ingen enheter samsvarer';

  @override
  String get deviceBatteryLow => 'Lavt batteri';

  @override
  String get deviceLinkWeak => 'Svak';

  @override
  String get deviceUnsupported => 'Støttes ikke av Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'Paringen ble ikke fullført';

  @override
  String get deviceNoReport => 'Ingen rapport ennå';

  @override
  String get devicesAvailabilityOff =>
      'Tilgjengelighet er av i Zigbee2MQTT, så frakoblede enheter vises som Svarer ikke.';

  @override
  String get devicesAvailabilityHow => 'Slik slår du den på';

  @override
  String get devicesDotBattery => 'Lavt batteri';

  @override
  String get deviceDetails => 'Enhetsdetaljer';

  @override
  String get deviceGone => 'Denne enheten finnes ikke lenger i Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Styring';

  @override
  String get deviceReadingsTitle => 'Målinger';

  @override
  String get deviceHealthTitle => 'Helse';

  @override
  String get deviceOnDashboards => 'På dashbord';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT støtter ikke denne enheten ennå, så det er ingenting å styre.';

  @override
  String get deviceAddReadingTile => 'Legg til som målingsflis';

  @override
  String get deviceAddReadingTo => 'Legge til på hvilket dashbord?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Lagt til på $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Koblingskvalitet';

  @override
  String get deviceLinkGood => 'God';

  @override
  String get devicePowerSource => 'Strømkilde';

  @override
  String get devicePowerBattery => 'Batteri';

  @override
  String get devicePowerMains => 'Strømnett';

  @override
  String get deviceLastHeard => 'Sist hørt';

  @override
  String get deviceAvailability => 'Tilgjengelighet';

  @override
  String get deviceAvailabilityOff => 'Av i Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Personvernerklæring';

  @override
  String get settingsPrivacySubtitle =>
      'Ingen telemetri. Alt blir på denne telefonen.';

  @override
  String get homeCurrent => 'Nåværende hjem';

  @override
  String get homeConnection => 'Tilkobling';

  @override
  String get homeSwitchTo => 'Bytt til dette hjemmet';

  @override
  String get homeDelete => 'Slett hjem';

  @override
  String get devicesSelect => 'Velg en enhet';

  @override
  String get scenesSelect => 'Velg en scene å redigere';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'Velg en enhet';

  @override
  String get panelFormStateTopic => 'Status-topic';

  @override
  String get panelFormCommandTopic => 'Kommando-topic';

  @override
  String get panelFormCommandTopicDerived =>
      'Fylles ut fra status-topicet til du endrer det.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Koblet til $device';
  }

  @override
  String get panelFormOpenDevice => 'Åpne enhet';

  @override
  String get panelFormUnlink => 'Koble fra';

  @override
  String get panelFormValueChoices => 'Verdier fra denne enheten';

  @override
  String get panelFormAdvanced => 'Avansert';

  @override
  String get panelFormAdvancedSubtitle => 'Prefiksoverstyring, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Tomt = selve prefikset (status for en Zigbee2MQTT-enhet).';

  @override
  String get dashWallDisplay => 'Veggskjerm';

  @override
  String get analyticsSetupCheckbox =>
      'Del anonyme bruksdata for å forbedre oppsettet';

  @override
  String get analyticsWhatsShared => 'Hva som deles';

  @override
  String get analyticsCardTitle => 'Hjelpe til å forbedre ZigDash?';

  @override
  String get analyticsCardBody =>
      'Del anonyme bruksdata: hvilke oppsettsteg som mislykkes og hvilke funksjoner som brukes. Aldri enhetene, topicene eller brokeren din.';

  @override
  String get analyticsShare => 'Del';

  @override
  String get analyticsNoThanks => 'Nei takk';

  @override
  String get settingsAnalytics => 'Del anonyme bruksdata';

  @override
  String get settingsAnalyticsSubtitle =>
      'Oppsettsteg og funksjoner som brukes. Aldri enhetene, topicene eller brokeren din.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Anonyme bruksdata. Slå av med bryteren over.';

  @override
  String get dashDefaultName => 'Hjem';

  @override
  String get dashExportSaveFile => 'Lagre fil';

  @override
  String get dashExportSaved => 'Sikkerhetskopien er lagret';

  @override
  String get dashImportChooseFile => 'Velg fil';

  @override
  String get dashImportFileUnreadable => 'Kunne ikke lese filen';

  @override
  String get getHelpTitle => 'Få hjelp';

  @override
  String get getHelpTryFirst => 'Prøv dette først';

  @override
  String get getHelpPromise =>
      'Står du fortsatt fast? Jeg svarer vanligvis innen 3 dager, på engelsk eller hebraisk. Jeg ber aldri om passordene dine.';

  @override
  String get getHelpIncluded => 'Dette er med';

  @override
  String get getHelpContact => 'Kontakt brukerstøtte';

  @override
  String get getHelpCopy => 'Kopier detaljer';

  @override
  String get getHelpCopied => 'Detaljer kopiert';

  @override
  String get getHelpLink => 'Står du fortsatt fast? Få hjelp';

  @override
  String get getHelpEmailSubject => 'ZigDash: hjelp til å få det til å fungere';

  @override
  String get getHelpEmailPrompt => 'Hva prøvde du å gjøre, og hva skjedde?';

  @override
  String get settingsHelpSupport => 'Hjelp & støtte';

  @override
  String get settingsGetHelp => 'Få hjelp';

  @override
  String get settingsGetHelpSubtitle =>
      'Får du det ikke til? Tips først, så kontakt';

  @override
  String get settingsCommunity => 'Bli med i ZigDash-fellesskapet';

  @override
  String get settingsCommunitySubtitle =>
      'Telegram-gruppe: spørsmål, ideer og hva som kommer';

  @override
  String get getHelpCommunity => 'Spør i Telegram-gruppen';

  @override
  String get demoBannerHelp => 'Få hjelp';

  @override
  String get tipSameWifiTitle => 'Samme Wi-Fi som huben';

  @override
  String get tipSameWifiBody =>
      'Telefonen må være på samme nettverk som huben, ikke et gjestenettverk. Slå av mobildata mens du setter opp.';

  @override
  String get tipBrokerRunningTitle => 'Brokeren kjører';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: appen Mosquitto broker er startet. Raspberry Pi: Mosquitto kjører. SMLIGHT: Settings › MQTT er på.';

  @override
  String get tipBrokerAcceptsTitle => 'Brokeren godtar telefonen';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: slå på Allow External. Mosquitto 2 godtar bare tilkoblinger fra selve huben til den er satt opp til å lytte på nettverket (port 1883).';

  @override
  String get tipMeshTitle => 'Mesh-Wi-Fi eller to rutere?';

  @override
  String get tipMeshBody =>
      'Hvis huben står på en ekstra ruter, kan det hende telefonen ikke ser den. Koble huben til hovedruteren, eller koble til med adressen.';

  @override
  String get tipByAddressTitle => 'Koble til med adresse';

  @override
  String get tipByAddressBody =>
      'Finn hubens adresse i ruterens app, og trykk så på „Skriv inn detaljer manuelt”.';

  @override
  String get tipSameNetworkTitle => 'Samme nettverk';

  @override
  String get tipSameNetworkBody =>
      'Telefonen og huben må være på samme Wi-Fi. Slå av mobildata.';

  @override
  String get tipAddressChangedTitle => 'Adressen er endret';

  @override
  String get tipAddressChangedBody =>
      'Huber kan få ny adresse etter en omstart. Sjekk den i ruterens app, og reserver den der så den forblir den samme.';

  @override
  String get tipRightPortTitle => 'Riktig port';

  @override
  String get tipRightPortBody =>
      'MQTT er vanligvis 1883 (8883 med TLS). 8080 eller 80 er hubens webgrensesnitt, ikke MQTT.';

  @override
  String get tipStartBrokerTitle => 'Brokeren kjører';

  @override
  String get tipStartBrokerBody =>
      'Start Mosquitto eller appen Mosquitto broker, og prøv igjen.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 godtar bare tilkoblinger fra selve huben til den er satt opp til å lytte på nettverket (port 1883).';

  @override
  String get tipMqttLoginTitle => 'MQTT-innloggingen, ikke web-innloggingen';

  @override
  String get tipMqttLoginBody =>
      'Passordet til hubens nettside er vanligvis ikke MQTT-passordet. Home Assistant: bruk en Home Assistant-bruker, eller innloggingen som er satt i appen Mosquitto broker.';

  @override
  String get tipSpacesTitle => 'Se etter mellomrom';

  @override
  String get tipSpacesBody =>
      'Når du kopierer et passord, kan det følge med et mellomrom på slutten.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT bruker denne brokeren';

  @override
  String get tipZ2mBrokerBody =>
      'Sjekk i innstillingene til Zigbee2MQTT at MQTT-serveren er denne samme brokeren.';

  @override
  String get tipBaseTopicTitle => 'Basistema';

  @override
  String get tipBaseTopicBody =>
      'Hvis du har endret basistemaet fra „zigbee2mqtt”, skriv det inn i det manuelle oppsettet.';

  @override
  String get tipPairFirstTitle => 'Par enheter først';

  @override
  String get tipPairFirstBody =>
      'Åpne webgrensesnittet til Zigbee2MQTT og par minst én enhet, og sjekk så igjen.';

  @override
  String get tipRestartZ2mTitle => 'Start Zigbee2MQTT på nytt';

  @override
  String get tipRestartZ2mBody =>
      'Hvis enhetene er paret, men ingen dukker opp, start Zigbee2MQTT på nytt slik at den publiserer enhetslisten sin.';

  @override
  String get tipNumberAddressTitle => 'Bruk talladressen';

  @override
  String get tipNumberAddressBody =>
      'Navn som slutter på .local fungerer ikke på alle Android-telefoner. Prøv hubens talladresse, for eksempel 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Port og protokoll';

  @override
  String get tipPortProtocolBody =>
      'TCP på 1883 er det vanlige. Velg TLS eller WebSocket bare hvis brokeren er satt opp for det.';

  @override
  String get tipManualLoginTitle => 'Innlogging';

  @override
  String get tipManualLoginBody =>
      'La brukernavn og passord stå tomme hvis brokeren ikke har noen. Ellers bruker du MQTT-innloggingen, ikke innloggingen til hubens webgrensesnitt.';

  @override
  String get tipHubOnTitle => 'Er huben på?';

  @override
  String get tipHubOnBody =>
      'Et strømbrudd eller en oppdatering kan ha startet den på nytt. Gi den et minutt etter at den er tilbake.';

  @override
  String get tipAwayTitle => 'Er du hjemme?';

  @override
  String get tipAwayBody =>
      'Når du er borte fra hjemmet, trenger appen en ekstern adresse (for eksempel Tailscale). Legg den inn i hjemmets tilkoblingsinnstillinger.';

  @override
  String get tipTailscaleIpTitle => 'Bruk Tailscale-IP-en, ikke navnet';

  @override
  String get tipTailscaleIpBody =>
      'Navn som slutter på .ts.net løses ofte ikke opp inne i apper. Åpne Tailscale-appen på telefonen og sjekk at den er tilkoblet. Bruk så hubens 100.x.y.z-adresse som ekstern vert.';

  @override
  String get tipHomeAddressChangedTitle => 'Har adressen endret seg?';

  @override
  String get tipHomeAddressChangedBody =>
      'Etter en omstart av ruteren kan huben få ny adresse. Reserver adressen i ruterens app, og oppdater så hjemmet.';

  @override
  String get tipRestartZ2mButtonTitle => 'Start Zigbee2MQTT på nytt';

  @override
  String get tipRestartZ2mButtonBody =>
      'Hvis brokeren ble startet på nytt, er enhetslisten til Zigbee2MQTT borte til Zigbee2MQTT startes på nytt. Bruk knappen „Start Zigbee2MQTT på nytt” i fanen „Enheter”.';

  @override
  String get tipZ2mRunningTitle => 'Kjører Zigbee2MQTT?';

  @override
  String get tipZ2mRunningBody =>
      'Åpne webgrensesnittet. Hvis det ikke lastes inn, start Zigbee2MQTT på nytt på huben.';

  @override
  String get tipCantConnectTitle => 'Får ikke koblet til huben';

  @override
  String get tipCantConnectBody =>
      'Samme Wi-Fi, brokeren kjører, Allow External eller Mosquitto lytter på nettverket – koble så til med adresse.';

  @override
  String get tipDeviceWrongTitle => 'En enhet vises feil eller svarer ikke';

  @override
  String get tipDeviceWrongBody =>
      'Sjekk den i webgrensesnittet til Zigbee2MQTT først. Hvis den fungerer der, bruk „Rapporter et problem”.';

  @override
  String get tipHowDoITitle => 'Hvordan gjør jeg …';

  @override
  String get tipHowDoIBody =>
      'Scener, veggskjerm, planer og sikkerhetskopier finner du i „Hjelp & veiledning”.';

  @override
  String get tipRenameHomeTitle => 'Gi et hjem nytt navn';

  @override
  String get tipRenameHomeBody =>
      'Et hjem oppkalt etter adressen sin? Innstillinger › Hjem, trykk på hjemmet og så på Navn.';

  @override
  String get tipWhatYouNeedTitle => 'Dette trenger du';

  @override
  String get tipWhatYouNeedBody =>
      'En liten hub som kjører Zigbee2MQTT og en MQTT-broker (Mosquitto): en SMLIGHT-hub, en Raspberry Pi eller en hvilken som helst Linux-maskin. Home Assistant fungerer også, men trengs ikke.';

  @override
  String get tipSetupAtHomeTitle => 'På samme Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Sett opp hjemme, med telefonen på samme Wi-Fi som huben.';

  @override
  String get tipFindSetupTitle => 'Deretter';

  @override
  String get tipFindSetupBody =>
      'Avslutt demoen og trykk på „Finn oppsettet mitt”. ZigDash leter etter huben på egen hånd.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Fant ingen e-postapp. Kopier detaljene og skriv til $email.';
  }

  @override
  String get shortcutWorking => 'jobber…';

  @override
  String get shortcutCantReach => 'Når ikke hjemmet';

  @override
  String get shortcutNotConfirmed => 'Ikke bekreftet';

  @override
  String get shortcutRemoved => 'Fjernet';

  @override
  String get shortcutSceneSent => 'Sendt';

  @override
  String get shortcutSceneConfirmed => 'Bekreftet';

  @override
  String get shortcutChooseDevice => 'Velg en enhet';

  @override
  String get shortcutChooseScene => 'Velg en scene';

  @override
  String get shortcutOpenAppFirstScene => 'Åpne ZigDash og lag en scene først.';

  @override
  String get shortcutChooseGroup => 'Velg en gruppe';

  @override
  String get shortcutPickDevices => 'Velg enheter…';

  @override
  String get shortcutGroupName => 'Gruppenavn';

  @override
  String get shortcutGroupLimit => 'Opptil 5 enheter og 3 scener';

  @override
  String get shortcutAddTile => 'Legg til i Hurtiginnstillinger';

  @override
  String get shortcutAddShortcut => 'Legg til snarvei';

  @override
  String get shortcutAddToHome => 'Legg til på startskjermen';

  @override
  String get shortcutWidgetHowToTitle => 'Legg til widgeten';

  @override
  String get shortcutWidgetHowTo =>
      'Trykk lenge på et tomt sted på startskjermen, trykk på Widgets, finn ZigDash og dra widgeten du vil ha.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name ligger på hurtiginnstillingsflisen ZigDash $slot';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name ligger allerede på flisen ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Legg til flisen';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Åpne Hurtiginnstillinger (sveip ned to ganger), trykk på blyanten for å redigere og dra «ZigDash $slot» inn blant flisene dine.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Velg en enhet for ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Ingen enheter å slå av og på ennå. Legg først en lampe, stikkontakt eller persienne på et dashbord.';

  @override
  String get shortcutSlotsFull =>
      'Alle 4 ZigDash-flisene er i bruk. Hvilken skal vise denne enheten i stedet?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Ikke i bruk';

  @override
  String get deviceRename => 'Gi nytt navn';

  @override
  String get deviceRenameTitle => 'Gi enheten nytt navn';

  @override
  String get deviceRenameHint =>
      'Et navn på rommet eller enheten, for eksempel Soverom';

  @override
  String deviceRenamed(Object name) {
    return 'Nytt navn: $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Kunne ikke endre navn: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT svarte ikke';

  @override
  String get shortcutOpenAppFirst =>
      'Åpne ZigDash og legg først en enhet på et dashbord.';

  @override
  String get pollTitle => 'Hva bør ZigDash gjøre videre?';

  @override
  String get pollBody =>
      'Velg det du ville brukt mest. Svaret sendes med de anonyme bruksdataene dine.';

  @override
  String get pollNotifications => 'Varsler';

  @override
  String get pollHistory => 'Historikkgrafer';

  @override
  String get pollKiosk => 'Kioskmodus for et nettbrett på veggen';

  @override
  String get pollGroups => 'Zigbee-grupper';

  @override
  String get pollNotNow => 'Ikke nå';

  @override
  String get pollThanks => 'Takk! Det hjelper oss å velge hva som kommer.';

  @override
  String get whyTitle => 'Hvorfor prøvde du ZigDash?';

  @override
  String get whyBody =>
      'Ett trykk hjelper oss å velge hva vi lager. Svaret sendes med de anonyme bruksdataene dine.';

  @override
  String get whyFaster => 'Raskere enn den andre appen min';

  @override
  String get whyFamily => 'Enkel for familien';

  @override
  String get whyWallTablet => 'Et nettbrett på veggen';

  @override
  String get whyWithoutHa => 'Virker uten Home Assistant';

  @override
  String get whyOther => 'Noe annet';

  @override
  String get whyThanks => 'Takk for svaret!';

  @override
  String get pollNoAnalytics =>
      'Bruksdata er av, så ingenting sendes herfra. Fortell oss heller via Foreslå en funksjon.';

  @override
  String alertLeak(Object name) {
    return '💧 Lekkasje — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name er tørr igjen';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Røyk — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Ikke mer røyk ved $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name åpnet';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Lavt batteri — $name, $value %';
  }

  @override
  String get alertTest => 'ZigDash-testvarsel';

  @override
  String get alertsChannel => 'Varsler';

  @override
  String get alertsChannelDescription => 'Lekkasjer og røyk';

  @override
  String get noticesChannel => 'Meldinger';

  @override
  String get noticesChannelDescription => 'Dører, vinduer og batterier';

  @override
  String get alertsTitle => 'Varsler';

  @override
  String get alertsStatusOn => 'Varsler er på';

  @override
  String get alertsStatusPaused =>
      'Varsler satt på pause: ZigDash Engine på huben melder seg ikke';

  @override
  String get alertsStatusNotSetUp => 'Ikke satt opp';

  @override
  String get alertsStatusPhoneOff => 'Denne telefonen får ikke varsler';

  @override
  String get alertsIntro =>
      'Få varsel på denne telefonen ved lekkasje, røyk, åpnet dør eller lavt batteri, selv når ZigDash er lukket. ZigDash Engine på huben følger med på enhetene; ZigDash setter det opp.';

  @override
  String get alertsSetUpHub => 'Sett opp varsler på huben';

  @override
  String get alertsHubInstalled => 'Varsler er satt opp på huben';

  @override
  String get alertsHubUpdated => 'Varselflyten på huben er oppdatert';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED ber om innlogging, så importer flyten manuelt:';

  @override
  String get alertsHubManualSteps =>
      'Åpne Node-RED på huben, velg Import, lim inn den kopierte flyten, velg brokeren din i broker-noden og trykk Deploy.';

  @override
  String get alertsCopyFlow => 'Kopier flyten';

  @override
  String get alertsFlowCopied => 'Flyt kopiert';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Varsler trenger Node-RED på huben, og ingenting svarer på port 1880 hos $host. På en SMLIGHT SMHUB installerer du det under Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT godtok ikke ZigDash Engine';

  @override
  String get alertsRecent => 'Siste varsler';

  @override
  String get alertsRecentNone => 'Ingenting ennå';

  @override
  String get alertsYourAlerts => 'Varslene dine';

  @override
  String get alertsAdd => 'Legg til varsel';

  @override
  String get alertsNotificationsOnThisPhone => 'Varsler på denne telefonen';

  @override
  String get alertsNoGoogle =>
      'Denne telefonen har ikke Google-tjenester, så ZigDash kan ikke motta push her.';

  @override
  String get alertsSendTest => 'Send testvarsel';

  @override
  String get alertsTestSent => 'Test sendt. Det bør komme nå.';

  @override
  String alertsTestFailed(Object status) {
    return 'Huben klarte ikke å sende det ($status)';
  }

  @override
  String get alertsTestTimedOut => 'Ingen svar fra huben. Kjører varselflyten?';

  @override
  String get alertsNotConnected => 'Ikke koblet til huben';

  @override
  String get alertsTurnOff => 'Slå av varsler';

  @override
  String get alertsTurnOffBody =>
      'Varslene stopper for alle telefoner i dette hjemmet.';

  @override
  String get alertKindLeak => 'Lekkasje';

  @override
  String get alertKindSmoke => 'Røyk';

  @override
  String get alertKindOpened => 'Dør eller vindu åpnet';

  @override
  String get alertKindBattery => 'Lavt batteri';

  @override
  String get alertsEditTitle => 'Varsel';

  @override
  String get alertsKind => 'Hva';

  @override
  String get alertsDevices => 'Enheter';

  @override
  String get alertsNoDevicesForKind =>
      'Ingen enhet i dette hjemmet rapporterer det.';

  @override
  String get alertsHours => 'Bare mellom';

  @override
  String get alertsHoursAny => 'Når som helst';

  @override
  String get alertsHoursFrom => 'Fra';

  @override
  String get alertsHoursTo => 'Til';

  @override
  String get alertsThreshold => 'Batteri under';

  @override
  String get alertsDelete => 'Slett varsel';

  @override
  String get alertsNotifyMe => 'Varsle meg…';

  @override
  String get alertsWhatLeaves =>
      'Varsler til ZigDash er ende-til-ende-kryptert: Googles push-tjeneste frakter dem, men kan ikke lese dem. Ingenting annet forlater huben.';

  @override
  String get alertsRestricted =>
      'Android kan stoppe ZigDash i bakgrunnen, slik at varsler kommer sent eller uteblir. Tillat kjøring i bakgrunnen i Android-innstillingene (på Samsung: Batteri › Apper som aldri sover).';

  @override
  String get alertsOpenSettings => 'Åpne Android-innstillinger';

  @override
  String get alertsOff => 'Av';

  @override
  String get alertsSuggested => 'Foreslåtte varsler';

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
  String get alertsShare => 'Del varsler';

  @override
  String get alertsShareBody =>
      'Alle med denne lenken får dette hjemmets varsler i ntfy-appen, uten ZigDash. Varselteksten går ukryptert gjennom ntfy.sh.';

  @override
  String get alertsShareLink => 'Lenke';

  @override
  String get alertsShareNewLink => 'Ny lenke';

  @override
  String get alertsShareCopied => 'Lenke kopiert';

  @override
  String get alertsShareOff => 'Slutt å dele';

  @override
  String get alertsGetWithNtfy => 'Få varsler med ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Røyk- og lekkasjevarsler gjentas til de bekreftes. Krever en Pushover-konto (4,99 \$ én gang etter prøveperioden); nøklene lagres på brokeren din.';

  @override
  String get alertsPushoverUser => 'Brukernøkkel';

  @override
  String get alertsPushoverToken => 'App-token';

  @override
  String get alertsHideNames => 'Skjul enhetsnavn';

  @override
  String get alertsNtfyServer => 'ntfy-server';

  @override
  String get wallSheetTitle => 'Veggvisning';

  @override
  String get wallSheetSubtitle => 'For et nettbrett på veggen.';

  @override
  String get wallKeepOn => 'Hold skjermen på og skjul linjene';

  @override
  String get wallKeepOnSubtitle =>
      'De kommer tilbake ved berøring og skjules igjen etter 10 sekunder.';

  @override
  String get wallFullscreen => 'Fullskjerm';

  @override
  String get wallFullscreenSubtitle =>
      'Skjuler også Androids status- og navigasjonslinje.';

  @override
  String get wallDimAfter => 'Demp etter';

  @override
  String get wallDimOff => 'Av';

  @override
  String get wallIdleTitle => 'Når ingen rører den';

  @override
  String get wallIdleAfter => 'Etter';

  @override
  String get wallIdleNever => 'Aldri';

  @override
  String get wallIdleShow => 'Vis';

  @override
  String get wallIdleShowDim => 'Dempet';

  @override
  String get wallIdleShowClock => 'Klokke';

  @override
  String get wallIdleShowBlack => 'Svart';

  @override
  String get wallIdleShowReadings => 'Målinger';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Dette dashbordet har ingen målinger ennå. Legg først til en målings- eller sensorflis.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Målinger på klokken (opptil $count)';
  }

  @override
  String get wallProNote =>
      'Målinger på klokken, vekking ved bevegelse, nattplanen og alarmer er en del av ZigDash Pro, et engangskjøp.';

  @override
  String get wallAlarmLeak => 'Vannlekkasje';

  @override
  String get wallAlarmSmoke => 'Røyk';

  @override
  String get wallAlarmGas => 'Gass';

  @override
  String get wallAlarmCo => 'Karbonmonoksid';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Vekk ved bevegelse';

  @override
  String get wallMotionSubtitle => 'En sensor som ser noen, vekker skjermen.';

  @override
  String get wallMotionNone =>
      'Ingen bevegelses-, tilstedeværelses- eller dørsensorer i dette hjemmet.';

  @override
  String get wallAlarmsTitle => 'Alarmer fyller skjermen';

  @override
  String get wallAlarmsSubtitle =>
      'Lekkasje, røyk, gass eller karbonmonoksid fyller skjermen til noen trykker OK. Bare mens ZigDash er åpen på dette nettbrettet; varsler når telefoner overalt.';

  @override
  String get wallAlarmSound => 'Spill av en lyd';

  @override
  String get wallNightTitle => 'Natt';

  @override
  String get wallNightSubtitle =>
      'Svart mellom disse tidene. Bevegelse vekker den bare svakt; alarmer alltid fullt.';

  @override
  String get wallNightFrom => 'Fra';

  @override
  String get wallNightTo => 'til';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Kiosklås';

  @override
  String get kioskLockSubtitle =>
      'Bare dette hjemmets dashbord og kontrollene deres er tilgjengelige. Hold inne tittelen for å avslutte.';

  @override
  String get kioskPin => 'PIN';

  @override
  String get kioskPinSet => 'Angi';

  @override
  String get kioskPinNotSet => 'Ikke angitt';

  @override
  String get kioskPinChange => 'Endre';

  @override
  String get kioskPinRemove => 'Fjern';

  @override
  String get kioskPinSetTitle => 'Angi en PIN';

  @override
  String get kioskPinEnterTitle => 'Skriv inn PIN';

  @override
  String get kioskPinHint => '4 sifre';

  @override
  String get kioskPinConfirmHint => 'En gang til';

  @override
  String get kioskPinMismatch => 'De to PIN-kodene er ulike.';

  @override
  String get kioskPinWrong => 'Feil PIN.';

  @override
  String get kioskPinForgot => 'Glemt PIN?';

  @override
  String get kioskPinForgotBody =>
      'En glemt PIN kan bare nullstilles ved å slette ZigDash-dataene i Android-innstillingene, noe som fjerner dette hjemmet med mindre du har en sikkerhetskopi. Eksporter én før du angir en PIN.';

  @override
  String get kioskExportBackup => 'Eksporter sikkerhetskopi';

  @override
  String get kioskOsPin => 'Fest også ZigDash i Android';

  @override
  String get kioskOsPinSubtitle =>
      'Android blokkerer Hjem og nylige apper til ZigDash løsnes. Et nettbrett uten låseskjerm løsner med en bevegelse, så dette er ikke låsen.';

  @override
  String get kioskOn => 'Kiosk på. Hold inne tittelen for å avslutte.';

  @override
  String get kioskLeaveTitle => 'Avslutte kiosk?';

  @override
  String get kioskLeave => 'Avslutt';

  @override
  String get kioskStay => 'Bli';

  @override
  String get a11yKioskLeave => 'Hold inne for å avslutte kiosk';

  @override
  String get historyTitle => 'Historikk';

  @override
  String get historyRangeDay => '24 timer';

  @override
  String get historyRangeWeek => '7 dager';

  @override
  String get historyRangeMonth => '30 dager';

  @override
  String get historySetupTitle => 'Ta opp historikk på huben';

  @override
  String get historySetupBody =>
      'ZigDash har ingen server, så ZigDash Engine på huben lagrer verdiene fra dashbordene dine hvert 15. minutt. Det beholder 30 dager, på din egen broker.';

  @override
  String get historySetupAction => 'Sett opp på huben';

  @override
  String get historyInstalled =>
      'Opptak i gang. De første verdiene kommer innen 15 minutter.';

  @override
  String historyNoNodeRed(String host) {
    return 'Historikk trenger Node-RED på huben, og ingenting svarer på port 1880 på $host. På en SMLIGHT SMHUB installerer du det under Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Tatt opp siden $date';
  }

  @override
  String get historyEmpty =>
      'Ingen verdier ennå. Opptakeren lagrer hvert 15. minutt.';

  @override
  String get historyRecorderOffline =>
      'Opptakeren på huben svarer ikke, så nye verdier kan mangle.';

  @override
  String get historyLocked =>
      'Lengre historikk er en del av ZigDash Pro, et engangskjøp.';

  @override
  String get historyUnlock => 'Lås opp';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Ubegrensede automasjoner, lengre historikk og ekstra for veggnettbrettet. Støtter åpen kildekode-prosjektet.';

  @override
  String get proUnlocked => 'Låst opp. Takk for at du støtter ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash er gratis og åpen kildekode, laget av én person på fritiden. Pro er et engangskjøp som holder prosjektet i gang.';

  @override
  String get proWhatYouGet => 'Dette får du';

  @override
  String get proGetHistory => 'Historikk for 7 og 30 dager, ikke bare i dag';

  @override
  String get proGetWall =>
      'Veggnettbrett: målinger på klokken, vekking ved bevegelse, nattplan og alarmer';

  @override
  String get proGetFuture =>
      'Alle Pro-funksjoner som kommer senere, uten ekstra kostnad';

  @override
  String get proFreeTitle => 'Gratis for alltid';

  @override
  String get proFreeBody =>
      'Oppsett, dashbord, styring av alle enheter, moduler, hurtiginnstillingsfliser, varsler, tre automasjoner per hjem og selve veggnettbrettet forblir gratis. Ingenting du bruker i dag blir låst.';

  @override
  String get proBuy => 'Skaff Pro';

  @override
  String proBuyPrice(String price) {
    return 'Skaff Pro · $price';
  }

  @override
  String get proOnce =>
      'Én betaling, ikke abonnement. Kjøpt på en annen telefon med samme Google-konto? Det låses opp automatisk.';

  @override
  String get historyNotRecorded =>
      'Bare tall som vises på et dashbord tas opp. Legg til denne som en flis for å starte historikken.';

  @override
  String get historyRecordHere => 'Ta opp på denne enheten';

  @override
  String get historyRecordHereHint =>
      'Går det ikke å bruke ZigDash Engine på huben? ZigDash kan lagre på en telefon eller et nettbrett som står åpent, som et veggnettbrett. Alle telefonene i hjemmet ser historikken.';

  @override
  String get historyRecordingHere =>
      'Denne enheten tar opp historikk mens ZigDash er åpen. De første verdiene kommer innen 15 minutter.';

  @override
  String get wallRecordHistory => 'Ta opp historikk på denne enheten';

  @override
  String get wallRecordHistorySubtitle =>
      'Hvert 15. minutt mens ZigDash er åpent, for alle telefonene i hjemmet. Ikke nødvendig når ZigDash Engine på huben lagrer.';

  @override
  String historyNeedsPassword(String host) {
    return 'Ett steg til: brokeren din krever innlogging. Åpne Node-RED på $host:1880, dobbeltklikk på «ZigDash history broker», skriv MQTT-passordet i fanen Security og trykk Deploy. ZigDash sender aldri passordet ditt til huben.';
  }

  @override
  String get historyNotConnected =>
      'Opptaket melder seg ikke. Åpne Automasjoner for å sjekke ZigDash Engine på huben.';

  @override
  String get historyPersistence =>
      'Historikken ligger på brokeren din. Kjører du Mosquitto selv, sørg for at konfigurasjonen har \"persistence true\", ellers forsvinner historikken når brokeren starter på nytt.';

  @override
  String get haImportTitle => 'Importer fra Home Assistant';

  @override
  String get haImportSettingsSubtitle => 'Navn og rom fra Home Assistant';

  @override
  String get haImportIntro =>
      'Hent navnene og rommene du har satt opp i Home Assistant. ZigDash leser dem én gang og beholder ikke noe annet fra Home Assistant.';

  @override
  String get haImportAddress => 'Adressen til Home Assistant';

  @override
  String get haImportAddressHelp =>
      'Adressen du åpner Home Assistant med, for eksempel 192.168.1.20:8123';

  @override
  String get haImportToken => 'Langvarig tilgangstoken';

  @override
  String get haImportTokenHelp =>
      'I Home Assistant åpner du profilen din, så Sikkerhet › Langvarige tilgangstokener › Opprett token. Kopier det og lim det inn her. ZigDash bruker det én gang og beholder det ikke; du kan slette det i Home Assistant etterpå.';

  @override
  String get haImportRead => 'Les fra Home Assistant';

  @override
  String get haImportReading => 'Leser Home Assistant…';

  @override
  String get haImportApplying => 'Importerer…';

  @override
  String get haImportNoAddress => 'Skriv adressen du åpner Home Assistant med.';

  @override
  String get haImportNoToken => 'Lim inn et langvarig tilgangstoken.';

  @override
  String get haImportUnreachable =>
      'Ingenting svarte på den adressen. Sjekk den, og at telefonen er på hjemmenettet. Det er adressen du åpner Home Assistant med i nettleseren, som ikke nødvendigvis er meglerens.';

  @override
  String get haImportNotHa =>
      'Noe svarte på den adressen, men det er ikke Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant avviste det tokenet. Opprett et nytt og lim det inn igjen.';

  @override
  String get haImportCertificate =>
      'Telefonen stoler ikke på sertifikatet til denne Home Assistant. Prøv http://-adressen på hjemmenettet.';

  @override
  String get haImportFailed =>
      'Home Assistant svarte, men lesingen mislyktes. Prøv igjen.';

  @override
  String get haImportNoDevices =>
      'ZigDash ser ikke enhetene i dette hjemmet nå. Koble til hjemmet og prøv igjen.';

  @override
  String get haImportAutomations =>
      'Automasjonene dine blir i Home Assistant og fortsetter å kjøre.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fant $count enheter i Home Assistant',
      one: 'Fant 1 enhet i Home Assistant',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'Fliser som fortsatt har enhetens navn, får navnet fra Home Assistant. Dashbord du har laget, forblir som de er.';

  @override
  String get haImportMakeDashboards =>
      'Legg også til dashbord fra etasjene og rommene dine';

  @override
  String get haImportOtherRooms => 'Andre rom';

  @override
  String get haImportNoRoom => 'Uten rom';

  @override
  String get haImportApply => 'Importer';

  @override
  String get haImportBack => 'Tilbake';

  @override
  String get haImportZhaOnly =>
      'Disse enhetene kjører på ZHA, Home Assistants egen Zigbee, ikke på Zigbee2MQTT, så ZigDash kan ikke vise dem.';

  @override
  String get haImportNothing =>
      'Ingen av Zigbee2MQTT-enhetene i dette hjemmet er i Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Ferdig. Fliser med nytt navn: $renamed. Nye dashbord: $dashboards.';
  }

  @override
  String get haImportOpen => 'Åpne dashbord';

  @override
  String get haImportOfferTitle => 'Hente navn og rom fra Home Assistant?';

  @override
  String get haImportOfferBody =>
      'Home Assistant er på nettverket ditt. ZigDash kan gi flisene navn og legge til et dashbord per etasje og rom, slik du har satt dem opp der.';

  @override
  String get haImportOfferLater => 'Ikke nå';

  @override
  String get haImportOfferGo => 'Importer';

  @override
  String get haImportSignIn => 'Logg inn med Home Assistant';

  @override
  String get haImportSignInHelp =>
      'Innloggingen til Home Assistant åpnes i nettleseren. ZigDash ser aldri passordet ditt og logger ut igjen etter lesingen.';

  @override
  String get haImportOrToken => 'Eller bruk et langvarig tilgangstoken';

  @override
  String get haImportReadToken => 'Les med token';

  @override
  String get haImportSignInRefused =>
      'Home Assistant godtok ikke innloggingen. Det skjer når Home Assistant ikke har internettilgang. Bruk et langvarig tilgangstoken nedenfor i stedet.';

  @override
  String get haImportSignInUnfinished =>
      'Innloggingen ble ikke fullført. Hvis siden ikke åpnet seg, sjekk adressen: det er den du åpner Home Assistant med i nettleseren, som ikke nødvendigvis er meglerens. Eller bruk et langvarig token nedenfor.';

  @override
  String get setupIsolatedHint =>
      'Telefonen ser nesten ingenting annet på dette Wi-Fi-et. Den er kanskje på et gjestenett, eller ruteren holder enhetene adskilt (ofte kalt klient- eller AP-isolering). Koble til hoved-Wi-Fi-et eller slå det av, og prøv igjen.';

  @override
  String get setupAuthTrust =>
      'Innloggingen blir på denne telefonen og går bare til din egen broker. ZigDash har ingen server og ingen konto, og alle MQTT-apper logger inn slik. Tryggest: en egen MQTT-bruker bare for ZigDash, som du kan fjerne når som helst.';

  @override
  String get setupAuthWhatKept => 'Hva ZigDash lagrer';

  @override
  String get setupAuthDemoFirst => 'Prøv demoen først';

  @override
  String get automationsTitle => 'Automasjoner';

  @override
  String get engineRunningOnHub => 'Kjører på huben';

  @override
  String get engineChecking => 'Sjekker huben…';

  @override
  String get engineAwayNoHubTitle => 'Huben din kan ikke nås akkurat nå';

  @override
  String get engineAwayNoHubBody =>
      'Du er borte, og huben er ikke koblet til ZigDash sin fjerntilgang, eller den mangler internett. Automasjonene dine fortsetter å kjøre på huben.';

  @override
  String get engineAwayReinstallAtHome =>
      'Du kan installere Engine på nytt når du er hjemme.';

  @override
  String get engineNoConnection =>
      'ZigDash når ikke brokeren i dette hjemmet akkurat nå. Automasjoner settes opp hjemme, med tilkobling.';

  @override
  String get engineRestarting =>
      'Starter Zigbee2MQTT på nytt… Enhetene er tilbake om omtrent 30 sekunder.';

  @override
  String get engineInstalling => 'Installerer på huben…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT må oppdateres';

  @override
  String engineTooOldBody(Object version) {
    return 'Zigbee2MQTT er versjon $version. Automasjoner krever 2.4 eller nyere. Oppdater Zigbee2MQTT på huben, og kom så tilbake hit.';
  }

  @override
  String get engineIntroTitle =>
      'Automasjoner kjører på huben, ikke på telefonen';

  @override
  String get engineIntroBody =>
      'ZigDash legger ZigDash Engine inn i Zigbee2MQTT på huben din. Det følger med på enhetene og kjører reglene dine, så en lampe tennes når døren åpnes selv med telefonen av og uten internett.';

  @override
  String get engineIntroNothingByHand =>
      'Ingenting å installere for hånd. ZigDash gjør det over hjemmenettet.';

  @override
  String engineIntroVersion(Object version) {
    return 'Zigbee2MQTT er versjon $version.';
  }

  @override
  String get engineIntroRemove =>
      'Du kan fjerne den når som helst fra denne skjermen.';

  @override
  String get engineInstall => 'Installer på huben';

  @override
  String get engineDeclinedTitle => 'Ingen automasjoner på denne huben';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT på huben tillater ikke tillegg, så ingenting kan kjøre reglene dine når telefonen er borte. Scener, varsler og dashbordet virker som før.';

  @override
  String get engineAllowAfterAll => 'Tillat tillegg likevel';

  @override
  String get engineConsentTitle => 'Zigbee2MQTT må endre én innstilling';

  @override
  String get engineConsentBody =>
      'Zigbee2MQTT blokkerer tillegg som ZigDash Engine, slik nye installasjoner gjør. For å kjøre automasjoner på huben ville ZigDash slå på «Tillat ekstern JavaScript» i Zigbee2MQTT og starte det på nytt.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT starter på nytt én gang. Lys og sensorer kan ikke nås i omtrent 30 sekunder.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine er åpen kildekode. Du kan lese det på Zigbee2MQTT-siden under Utvidelser.';

  @override
  String get engineConsentUndo =>
      'Du kan slå av innstillingen senere. Da stopper automasjonene.';

  @override
  String get engineConsentYes => 'Endre innstillingen og start på nytt';

  @override
  String get engineConsentNo => 'Ikke nå';

  @override
  String get automationsPausedTitle => 'Automasjoner satt på pause';

  @override
  String get automationsPausedBody =>
      'Huben har ikke meldt seg på over ett minutt, så ingen automasjon kan kjøre før den gjør det. Reglene dine beholdes.';

  @override
  String get engineReinstall => 'Installer på nytt på huben';

  @override
  String get engineStoppedTitle =>
      'Automasjoner satt på pause: ZigDash Engine stoppet seg selv';

  @override
  String get engineStoppedBody =>
      'Den fikk feil tre ganger på en time og slo seg av så Zigbee2MQTT fortsetter å kjøre. Reglene dine beholdes.';

  @override
  String get engineStartAgain => 'Start på nytt';

  @override
  String get engineReportProblem => 'Rapporter et problem';

  @override
  String get engineRunningTitle => 'Huben er klar for automasjoner';

  @override
  String engineRunningBody(Object count) {
    return 'Regler lastet på huben: $count. Å lage automasjoner kommer i neste steg av denne versjonen.';
  }

  @override
  String get engineClockOff =>
      'Klokken på huben går mer enn fem minutter feil. Tidsstyrte automasjoner kjører på feil tidspunkt til det er rettet.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Regler ZigDash Engine på huben ikke kan kjøre ennå: $count. Installer det på nytt for å oppdatere.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT avviste ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT svarte ikke. Sjekk at hjemmet er tilkoblet, og prøv igjen.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT godtok ikke endringen eller kom ikke tilbake. Sjekk huben og prøv igjen.';

  @override
  String get autoValMotion => 'bevegelse';

  @override
  String get autoValNoMotion => 'ingen bevegelse';

  @override
  String get autoValClosed => 'lukket';

  @override
  String get autoValOpened => 'åpnet';

  @override
  String get autoValLeak => 'lekkasje';

  @override
  String get autoValDry => 'tørt';

  @override
  String get autoValSmoke => 'røyk';

  @override
  String get autoValNoSmoke => 'ingen røyk';

  @override
  String get autoValOn => 'på';

  @override
  String get autoValOff => 'av';

  @override
  String get autoValToggle => 'veksle';

  @override
  String get autoValOpen => 'åpne';

  @override
  String get autoValClose => 'lukk';

  @override
  String get autoValStop => 'stopp';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Når $device: $property over $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Når $device: $property under $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Når $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'Kl. $time';
  }

  @override
  String get autoSunrise => 'soloppgang';

  @override
  String get autoSunset => 'solnedgang';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min etter $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min før $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'Ved $sun';
  }

  @override
  String get autoEveryDay => 'hver dag';

  @override
  String get autoWeekdays => 'hverdager';

  @override
  String get autoWeekends => 'helger';

  @override
  String autoBetween(Object from, Object to) {
    return 'mellom $from og $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device er $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Kjør «$scene»';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, av igjen etter $minutes min';
  }

  @override
  String get autoErrPickTrigger => 'Velg en enhet og hva den gjør.';

  @override
  String get autoErrValue => 'Skriv et tall for målingen.';

  @override
  String get autoErrDays => 'Velg minst én dag.';

  @override
  String get autoErrTown => 'Angi stedet ditt for soloppgang og solnedgang.';

  @override
  String get autoErrPickAction => 'Velg hva som skal skje.';

  @override
  String get autoErrEmptyScene => 'Den scenen har ingenting å sende.';

  @override
  String get autoErrNotConnected =>
      'ZigDash er ikke koblet til dette hjemmet. Prøv igjen hjemme.';

  @override
  String get autoNewTitle => 'Ny automasjon';

  @override
  String get autoEditTitle => 'Rediger automasjon';

  @override
  String get autoName => 'Navn';

  @override
  String get autoNameHint => 'Hva den gjør (valgfritt)';

  @override
  String get autoWhen => 'Når';

  @override
  String get autoOnlyIf => 'Bare hvis';

  @override
  String get autoThen => 'Så';

  @override
  String get autoEnabled => 'Aktivert';

  @override
  String get autoDelete => 'Slett automasjon';

  @override
  String get autoSave => 'Lagre';

  @override
  String get autoDeviceChanges => 'En enhet endres';

  @override
  String get autoTimeComes => 'Et klokkeslett kommer';

  @override
  String get autoDevice => 'Enhet';

  @override
  String get autoAbove => 'over';

  @override
  String get autoBelow => 'under';

  @override
  String get autoClockTime => 'Klokkeslett';

  @override
  String get autoAt => 'Kl.';

  @override
  String get autoShift => 'Forskyvning i minutter (minus er før)';

  @override
  String get autoTownNone => 'Ingen sted angitt';

  @override
  String autoTownIs(Object town) {
    return 'Soltider for $town';
  }

  @override
  String get autoTownSet => 'Angi sted';

  @override
  String get autoTownChange => 'Bytt sted';

  @override
  String get autoDays => 'Dager';

  @override
  String get autoNoConditions => 'Ingen betingelser. Kjører hver gang.';

  @override
  String get autoAddHours => 'Mellom klokkeslett';

  @override
  String get autoFrom => 'Fra';

  @override
  String get autoTo => 'Til';

  @override
  String get autoAddDeviceCondition => 'En enhet er…';

  @override
  String get autoRunASceneOption => 'Kjør en scene';

  @override
  String get autoSetADevice => 'Styr en enhet';

  @override
  String get autoScene => 'Scene';

  @override
  String get autoTurnOffAgain => 'Slå av igjen';

  @override
  String get autoStaysAsSet => 'Blir som det er';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minutter etterpå';
  }

  @override
  String get autoTownSearch => 'Sted';

  @override
  String get autoTownWhy =>
      'Brukes bare til soloppgang og solnedgang. Lagres på huben, aldri posisjonen din.';

  @override
  String get autoNewButton => 'Ny automasjon';

  @override
  String get autoEmptyBody =>
      'Ingenting kjører ennå. Trykk på Ny automasjon for å lage den første.';

  @override
  String autoOnlyIfList(Object list) {
    return 'bare hvis $list';
  }

  @override
  String get autoEdit => 'Rediger';

  @override
  String get autoNeverRan => 'har aldri kjørt';

  @override
  String autoRanAt(Object time) {
    return 'kjørte $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count av $max gratis automasjoner';
  }

  @override
  String get autoRecentRuns => 'Siste kjøringer';

  @override
  String get autoDeleted => '(slettet)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count automasjoner er gratis. Vil du ha flere?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash er gratis og åpen kildekode, laget av én person. Pro er et engangskjøp: ubegrensede automasjoner, historikk for 7 og 30 dager og ekstrafunksjonene for veggnettbrett. Automasjonene dine fortsetter å kjøre uansett hva du velger.';

  @override
  String get autoCeilingSeePro => 'Se Pro';

  @override
  String get engineRemove => 'Fjern fra huben';

  @override
  String get engineRemoveTitle => 'Fjerne ZigDash Engine fra huben?';

  @override
  String get engineRemoveBody =>
      'Automasjonene slutter å kjøre. Reglene blir liggende på huben, så en ny installasjon av ZigDash Engine henter dem tilbake.';

  @override
  String get autoNoTargets =>
      'Dette hjemmet har ennå ingen lampe, stikkontakt, bryter eller persienne å styre.';

  @override
  String get proGetAutomations =>
      'Ubegrensede automasjoner; tre per hjem er gratis';

  @override
  String get proGetRemote =>
      'Fjernstyring fra hvor som helst, via ZigDash-reléet, uten månedsavgift';

  @override
  String get proRemoteFair =>
      'Fjerntilgang er inkludert så lenge ZigDash-reléet kjører, for ett hjem, opptil fem telefoner og vanlig bruk i husholdningen. Det kan endres eller avsluttes med varsel.';

  @override
  String get autoDeleteConfirm =>
      'Slette denne automasjonen? Den slutter å kjøre på huben.';

  @override
  String get statusConnectedRelay => 'Tilkoblet · Borte via ZigDash';

  @override
  String get shareHomeTitle => 'Del med en annen telefon';

  @override
  String get shareHomeSubtitle =>
      'Legg til dette hjemmet på en annen telefon med én QR-kode';

  @override
  String get shareHomeIntro =>
      'På den andre telefonen, hjemme på samme Wi-Fi, skann koden med kameraet. ZigDash legger til hjemmet med pålogging og dashbordene dine.';

  @override
  String get shareHomeLoginWarning =>
      'Koden inneholder brokerpåloggingen for dette hjemmet. Den vises i 2 minutter; vis den bare til folk du stoler på.';

  @override
  String get shareHomeShow => 'Vis koden';

  @override
  String get shareHomeAtHome =>
      'Koble til hjemme først: deling fungerer bare på hjemmenettet.';

  @override
  String get shareHomeScanHint =>
      'Skann med kameraet på den andre telefonen. Koden skjules om 2 minutter.';

  @override
  String get shareHomeHide => 'Skjul koden';

  @override
  String get shareHomeViaHa =>
      'Dette hjemmet kobler til via Home Assistant. Installer ZigDash på den andre telefonen og logg inn med Home Assistant.';

  @override
  String get joinHomeTitle => 'Legg til et delt hjem';

  @override
  String get joinHomeInvalid =>
      'Denne koden er ikke en ZigDash-invitasjon, eller den er skadet.';

  @override
  String joinHomeAlready(String name) {
    return '$name er allerede på denne telefonen.';
  }

  @override
  String get joinHomeOpen => 'Åpne';

  @override
  String joinHomeAsk(String name) {
    return 'Legge til $name på denne telefonen?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash legger til hjemmet med samme tilkobling og pålogging, og henter dashbordene fra den andre telefonen. Hold denne telefonen på hjemme-Wi-Fi.';

  @override
  String get joinHomeAdd => 'Legg til hjem';

  @override
  String get joinHomeNoDashboards =>
      'Hjemmet er lagt til. Dashbordene kom ikke; enhetene dine er i fanen Enheter.';

  @override
  String get remoteTitle => 'Fjernstyring';

  @override
  String get remoteSettingsSubtitle =>
      'Styr dette hjemmet fra hvor som helst, med Pro';

  @override
  String get remoteIntroTitle => 'Styr hjemmet fra hvor som helst';

  @override
  String get remoteOfferBody =>
      'Nå enhetene dine når du er borte, via ZigDash sitt krypterte relé. Del av Pro: én betaling, ingen månedsavgift. Sett det opp mens du er hjemme.';

  @override
  String get remoteOfferBodyPro =>
      'Du har Pro: slå på fjernstyring mens du er hjemme, så når du enhetene dine fra hvor som helst.';

  @override
  String get remoteOfferShow => 'Vis meg';

  @override
  String get remoteIntroBody =>
      'Huben holder én tilkobling til ZigDash sitt relé. Borte når denne telefonen enhetene dine gjennom det. Alt krypteres på huben og telefonen, så reléet kan ikke lese enhetene eller hva de gjør.';

  @override
  String get remoteNeedsEngine =>
      'Fjernstyring kjører i ZigDash Engine. Installer det først under Automasjoner.';

  @override
  String get remoteSetUp => 'Slå på fjernstyring';

  @override
  String get remoteNeedsPro => 'Fjernstyring er en del av Pro.';

  @override
  String get remoteNotAtHome => 'Slå det på hjemme, tilkoblet brokeren din.';

  @override
  String get remoteUnreachable =>
      'ZigDash sitt relé svarte ikke. Prøv igjen senere.';

  @override
  String get remoteRefused =>
      'Reléet avviste. Prøv igjen, eller rapporter et problem.';

  @override
  String get remoteOnTitle => 'Fjernstyring er på';

  @override
  String get remoteOnBody =>
      'Borte kobler ZigDash seg til via reléet av seg selv.';

  @override
  String get remoteHubOnline => 'Huben er koblet til reléet';

  @override
  String get remoteHubOffline => 'Huben er ikke koblet til reléet';

  @override
  String get remoteTurnOff => 'Slå av fjernstyring';

  @override
  String get remoteViaRelayNow =>
      'Denne telefonen er koblet til via reléet akkurat nå.';

  @override
  String get remotePhones => 'Telefoner med fjerntilgang';

  @override
  String get remoteThisPhone => 'Denne telefonen';

  @override
  String get remoteOtherPhone => 'En annen telefon';

  @override
  String remotePhoneAdded(Object date) {
    return 'Lagt til $date';
  }

  @override
  String get remoteRemovePhone => 'Fjern';

  @override
  String get remoteRemovePhoneConfirm =>
      'Fjerne denne telefonen? Den når ikke lenger hjemmet utenfra.';

  @override
  String get remoteAddPhone => 'Legg til en telefon';

  @override
  String get remoteAddPhoneHint =>
      'Hjemme: skann dette med kameraet på den andre telefonen. Den åpner ZigDash og slår på fjernstyring der. Vis det bare til dine egne telefoner.';

  @override
  String get remoteAddPhoneFailed =>
      'Reléet ga ingen pålogging for en telefon til. Et hjem kan ha opptil fem.';

  @override
  String get remoteBackupSave => 'Lagre en nøkkelsikkerhetskopi';

  @override
  String get remoteBackupRestore => 'Gjenopprett fra en nøkkelsikkerhetskopi';

  @override
  String get remoteBackupPassphrase => 'Passordfrase for sikkerhetskopien';

  @override
  String get remoteBackupPassphraseHint =>
      'Mister du denne telefonen, gir sikkerhetskopien og passordfrasen fjernstyringen tilbake på en ny. Minst 8 tegn, og ta vare på frasen et annet sted enn filen.';

  @override
  String get remoteBackupPassphraseAsk =>
      'Frasen du valgte da du lagret sikkerhetskopien.';

  @override
  String get remoteBackupPassphraseAgain => 'Passordfrasen igjen';

  @override
  String get remoteBackupSaved => 'Nøkkelsikkerhetskopi lagret';

  @override
  String get remoteBackupWrong => 'Den frasen åpner ikke sikkerhetskopien.';

  @override
  String get remoteBackupWrongFile =>
      'Det er ikke en nøkkelsikkerhetskopi fra ZigDash.';

  @override
  String get remotePlayOnly =>
      'Fjernstyring finnes foreløpig i Google Play-versjonen av ZigDash.';

  @override
  String get remotePairTitle => 'Legg til fjernstyring';

  @override
  String get remotePairBody =>
      'Hvilket hjem er dette? ZigDash lagrer fjernpåloggingen for det.';

  @override
  String get remotePairNoHomes =>
      'Sett opp hjemmet på denne telefonen først, hjemme. Skann så koden igjen.';

  @override
  String get remotePairInvalid =>
      'Koden er ikke en fjernstyringskode fra ZigDash, eller den ble kuttet.';

  @override
  String remotePairDone(Object home) {
    return 'Fjernstyring er på for $home';
  }

  @override
  String get remoteReconnectHub => 'Koble til huben igjen';

  @override
  String get remoteTurnOffConfirm =>
      'Denne telefonen forlater fjernstyringen, og huben kobles fra reléet. En nøkkelsikkerhetskopi lagret fra denne telefonen slutter å virke; andre telefoner beholder tilgangen til du fjerner dem.';

  @override
  String remoteHomeId(Object id) {
    return 'Hjem-ID $id';
  }

  @override
  String get alertsHintTitle => 'Få varsler på denne telefonen';

  @override
  String get alertsHintBody =>
      'En lekkasje, røyk, en åpnet dør eller et svakt batteri kan sende et varsel til denne telefonen, også når ZigDash er lukket.';

  @override
  String get alertsHintButton => 'Sett opp varsler';

  @override
  String get alertsHintNotNow => 'Ikke nå';

  @override
  String get guidedNoZ2mBody =>
      'En MQTT-broker svarer her, men Zigbee2MQTT sender ingenting via den. Sjekk at Zigbee2MQTT er startet og bruker denne brokeren, og at basistopicet stemmer med innstillingene. Hvis Zigbee-enhetene dine er i Home Assistants ZHA, kan ZigDash ikke se dem: det fungerer med Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT er på denne brokeren med basistopic «$found», men dette hjemmet ser etter «$current».';
  }

  @override
  String devicesUseBase(String found) {
    return 'Bruk «$found»';
  }

  @override
  String get devicesChangeConnection => 'Endre tilkobling';

  @override
  String get updateAvailableTitle => 'En ny versjon av ZigDash er klar';

  @override
  String get updateAvailableBody =>
      'Den lastes ned mens du fortsetter å bruke ZigDash.';

  @override
  String get updateAvailableButton => 'Oppdater';

  @override
  String get updateDownloading => 'Laster ned oppdateringen …';

  @override
  String get updateReadyTitle => 'Oppdateringen er lastet ned';

  @override
  String get updateReadyButton => 'Start på nytt for å fullføre';

  @override
  String get nfcWriteTag => 'Skriv til NFC-brikke';

  @override
  String get nfcHoldTitle => 'Hold en brikke mot telefonen';

  @override
  String nfcHoldBody(String name) {
    return 'Hold et tomt NFC-klistremerke mot baksiden av telefonen. Å trykke på det senere kjører $name.';
  }

  @override
  String get nfcWrittenTitle => 'Brikken er klar';

  @override
  String nfcWrittenBody(String name) {
    return 'Trykk telefonen mot brikken for å kjøre $name. Det virker selv om ZigDash er lukket.';
  }

  @override
  String get nfcFailedTitle => 'Kunne ikke skrive til brikken';

  @override
  String get nfcReadonlyBody =>
      'Denne brikken er låst og kan ikke endres. Prøv en annen.';

  @override
  String get nfcTooSmallBody =>
      'Denne brikken er for liten. Bruk et NTAG213-klistremerke eller større.';

  @override
  String get nfcFailedBody =>
      'Hold brikken i ro mot baksiden av telefonen og prøv igjen.';

  @override
  String get nfcOffTitle => 'NFC er av';

  @override
  String get nfcOffBody => 'Slå på NFC i Android-innstillingene og prøv igjen.';

  @override
  String get nfcNoneTitle => 'Ingen NFC på denne telefonen';

  @override
  String get nfcNoneBody =>
      'Denne telefonen kan ikke lese eller skrive NFC-brikker.';

  @override
  String get nfcWriteAnother => 'Skriv en brikke til';

  @override
  String get nfcUnsupportedBody =>
      'Denne telefonen kan ikke skrive til denne typen brikke (ofte MIFARE Classic). Bruk et NTAG213-, 215- eller 216-klistremerke.';

  @override
  String get nfcTagsTitle => 'NFC-brikker';

  @override
  String get nfcTagsSubtitle =>
      'Brikker som kjører en scene eller slår en enhet av og på';

  @override
  String get nfcTagsEmpty =>
      'Ingen brikker ennå. Hold inne en scene-, lys-, stikkontakt- eller persienneflis og velg Skriv til NFC-brikke.';

  @override
  String get nfcTagRunsScene => 'Kjører scenen';

  @override
  String get nfcTagSwitches => 'Slår av og på';

  @override
  String nfcTagWritten(String when) {
    return 'skrevet $when';
  }

  @override
  String nfcTagLastTap(String when) {
    return 'sist brukt $when';
  }

  @override
  String get nfcTagNeverTapped => 'ikke brukt ennå';

  @override
  String get nfcTagOffLabel => 'Av';

  @override
  String get nfcTagRewrite => 'Skriv på nytt';

  @override
  String get nfcTagForget => 'Fjern fra listen';

  @override
  String get nfcTagOffToast => 'Denne brikken er slått av i ZigDash';

  @override
  String get nfcTagsNote =>
      'En brikke som er slått av, gjør ingenting på denne telefonen. Brikker skrevet før denne listen vises ikke: skriv dem på nytt én gang.';

  @override
  String get nfcPopupHeader => 'ZigDash-brikke';

  @override
  String get nfcPopupRunning => 'Kjører …';

  @override
  String get nfcPopupSwitching => 'Slår av/på …';

  @override
  String get nfcPopupDone => 'Ferdig';

  @override
  String get nfcPopupClosing => 'Lukkes om 2 sekunder';

  @override
  String get nfcPopupUnreachable =>
      'Telefonen når ikke hjemmet akkurat nå. Sjekk wifi eller slå på fjernstyring.';

  @override
  String get nfcPopupOffBody =>
      'Ingenting ble slått av eller på. Slå den på igjen i hjemmets innstillinger, under NFC-brikker.';

  @override
  String get nfcPopupOpenApp => 'Åpne ZigDash';

  @override
  String get hubBackupTitle => 'Hub-sikkerhetskopi';

  @override
  String get hubBackupSettingsSubtitle =>
      'En daglig kopi av Zigbee2MQTT-nettverket og enhetsnavnene';

  @override
  String get hubBackupIntro =>
      'ZigDash tar vare på en kopi av innstillingene i Zigbee2MQTT, Zigbee-nettverket og enhetsnavnene fra huben din, så en hub som er tilbakestilt eller slettet kan få nettverket tilbake. En ny kopi tas hver dag du åpner ZigDash hjemme, og de siste 7 lagres på denne telefonen.';

  @override
  String get hubBackupNone => 'Ingen sikkerhetskopi ennå';

  @override
  String hubBackupLast(String when) {
    return 'Siste sikkerhetskopi: $when';
  }

  @override
  String get hubBackupNow => 'Ta sikkerhetskopi nå';

  @override
  String get hubBackupMade => 'Sikkerhetskopiert.';

  @override
  String get hubBackupRefused =>
      'Zigbee2MQTT på denne huben kan ikke lage sikkerhetskopier.';

  @override
  String get hubBackupNoAnswer =>
      'Zigbee2MQTT svarte ikke. Sjekk at det kjører, og prøv igjen.';

  @override
  String get hubBackupOffline =>
      'Dette hjemmet er ikke tilkoblet nå. Koble til og prøv igjen.';

  @override
  String get hubBackupAway =>
      'Sikkerhetskopier tas hjemme: reléet overfører dem ikke.';

  @override
  String get hubBackupNoBroker =>
      'Dette hjemmet kobler til via nettsiden til Zigbee2MQTT. Sikkerhetskopier trenger MQTT-megleren.';

  @override
  String get hubBackupKept => 'Lagret på denne telefonen';

  @override
  String get hubBackupSaveCopy => 'Lagre en kopi';

  @override
  String get hubBackupSaved => 'Kopien er lagret.';

  @override
  String get hubBackupUnreadable =>
      'Denne sikkerhetskopien kan ikke åpnes på denne telefonen.';

  @override
  String get hubBackupRestoreNote =>
      'Gjenopprett legger en sikkerhetskopi tilbake på huben og starter Zigbee2MQTT på nytt. Lagre en kopi gir deg Zigbee2MQTTs egen backup-zip til å oppbevare et annet sted.';

  @override
  String get hubBackupPrivate =>
      'En sikkerhetskopi inneholder nøkkelen til Zigbee-nettverket ditt. Hold lagrede kopier private.';

  @override
  String get hubBackupRestore => 'Gjenopprett';

  @override
  String get hubBackupRestoreTitle => 'Gjenopprette denne sikkerhetskopien?';

  @override
  String hubBackupRestoreBody(String when) {
    return 'Innstillingene i Zigbee2MQTT, Zigbee-nettverket og enhetslisten går tilbake til $when. Zigbee2MQTT starter på nytt, noe som tar omtrent et minutt. Enheter som ble paret etter denne sikkerhetskopien, må pares på nytt.';
  }

  @override
  String get hubBackupRestoreExtensions =>
      'For å skrive sikkerhetskopien legger ZigDash til en liten engangsutvidelse i Zigbee2MQTT. Er utvidelser slått av, slår den dem på først, noe som starter Zigbee2MQTT på nytt én gang til.';

  @override
  String get hubBackupRestoreStageAllow =>
      'Tillater utvidelser og starter Zigbee2MQTT på nytt…';

  @override
  String get hubBackupRestoreStageSend => 'Sender sikkerhetskopien til huben…';

  @override
  String get hubBackupRestoreStageRestart =>
      'Zigbee2MQTT starter igjen fra sikkerhetskopien…';

  @override
  String get hubBackupRestored =>
      'Gjenopprettet. Zigbee2MQTT kjører fra sikkerhetskopien.';

  @override
  String get hubBackupRestoreNotWritten =>
      'Gjenopprettingen gikk ikke gjennom, og ingenting ble endret på huben. Prøv igjen.';

  @override
  String get hubBackupRestoreRefused =>
      'Zigbee2MQTT godtok ikke gjenopprettingsutvidelsen fra ZigDash. Ingenting ble endret på huben.';

  @override
  String get hubBackupRestoreNotBack =>
      'Sikkerhetskopien ble skrevet, men Zigbee2MQTT har ikke startet igjen. Start den på nytt på huben, og sjekk her etterpå.';
}
