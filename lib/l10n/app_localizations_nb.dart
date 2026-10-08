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
      'Brokerens IP er hubens IP-adresse. Finn den i SMLIGHT-nettgrensesnittet under Innstillinger → Nettverk, eller i ruteren. Porten er 1883, uten brukernavn/passord som standard.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA har ingen MQTT-broker – den snakker direkte med Home Assistant, så ZigDash kan ikke koble til den. For å bruke ZigDash, bytt til Zigbee2MQTT (tilgjengelig som Home Assistant-tillegg eller Docker-container), som gir deg en MQTT-broker.';

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
  String get dashFormLock => 'Lås';

  @override
  String get dashFormLockSubtitle =>
      'Skjul redigeringsfunksjoner mens den er låst';

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
      'Brokeren er ikke tilgjengelig. Kjører Zigbee2MQTT? Kontroller adresse og port.';

  @override
  String get diagTcpTimeout =>
      'Tilkoblingen til brokeren tok for lang tid. Den kan være frakoblet eller utilgjengelig.';

  @override
  String get diagConnackFail =>
      'Brokeren fullførte ikke MQTT-håndtrykket. Sørg for at det er en MQTT-broker (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'Brokeren avviste brukernavn eller passord. Kontroller påloggingsinformasjonen.';

  @override
  String get diagAuthRefused =>
      'Brokeren avviste tilkoblingen. Kontroller tilkoblingsinnstillingene.';

  @override
  String foundDevices(Object count) {
    return 'Fant $count enheter';
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
  String ladderTriedHint(Object count) {
    return 'Prøvde $count adresser';
  }

  @override
  String get guidedSaveFailed => 'Kunne ikke lagre tilkoblingen. Prøv igjen.';

  @override
  String get setupWelcomeTitle => 'Velkommen til ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash styrer det eksisterende Zigbee2MQTT-hjemmet ditt — lokalt, uten sky. Sørg for at Zigbee2MQTT kjører, og la ZigDash finne det.';

  @override
  String get setupFindMySetup => 'Finn oppsettet mitt';

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
      'Home Assistant: sørg for at MQTT-broker-tillegget (f.eks. Mosquitto) og Zigbee2MQTT-tillegget er installert og kjører.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: sjekk at brokeren din (f.eks. Mosquitto) og Zigbee2MQTT-tjenesten kjører, og at port 1883 er tilgjengelig.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: åpne webgrensesnittet, gå til Settings > MQTT, slå på Allow External slik at telefonen når brokeren, og sjekk at Zigbee2MQTT kjører.';

  @override
  String get setupTryAgain => 'Prøv igjen';

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
  String get setupVerifyingTitle => 'Sjekker tilkoblingen…';

  @override
  String get setupReviewTitle => 'Enhetene dine';

  @override
  String setupReviewSubtitle(Object count) {
    return '$count enheter funnet. Velg hva som kommer på det første dashbordet ditt.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'Lag dashbord med $count';
  }

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
  String get setupErrScanFailedTitle => 'Ikke noe lokalt nettverk';

  @override
  String get setupErrScanFailedBody =>
      'Kunne ikke fastslå denne enhetens lokale nettverk. Koble til Wi-Fi og prøv igjen.';

  @override
  String get setupErrScanFailedAction => 'Prøv igjen';

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
      'Anonyme bruksdata bare hvis du velger det.';

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
}
