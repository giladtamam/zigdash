// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingWelcomeTitle => 'Welkom bij ZigDash';

  @override
  String get onboardingWelcomeSubtitle =>
      'Je privé, lokale dashboard voor Zigbee2MQTT.\nGeen cloud. Geen tracking. Gewoon bedienen.';

  @override
  String get onboardingBrokerTitle => 'Verbind je broker';

  @override
  String get onboardingBrokerSubtitle =>
      'Richt ZigDash op je MQTT-broker om rechtstreeks met je Zigbee-apparaten te praten. Werkt met Mosquitto, SMLIGHT en elke MQTT-server.';

  @override
  String get onboardingDashboardTitle => 'Maak je dashboards';

  @override
  String get onboardingDashboardSubtitle =>
      'Maak eigen dashboards met schakelaars, schuifregelaars, rolluiken en meer. Rangschik panelen zoals jij wilt — alles wordt lokaal op je apparaat opgeslagen.';

  @override
  String get onboardingSkip => 'Overslaan';

  @override
  String get onboardingNext => 'Volgende';

  @override
  String get onboardingGetStarted => 'Aan de slag';

  @override
  String get onboardingDemo => 'Demo proberen';

  @override
  String get navBrokers => 'Brokers';

  @override
  String get navDashboards => 'Dashboards';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get settingsAppearance => 'Weergave';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get settingsDynamicColor => 'Material You-kleuren gebruiken';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; anders wordt de app-kleur gebruikt';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get languageSystem => 'Systeem';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Verbindingen';

  @override
  String connLoadFailed(Object error) {
    return 'Laden mislukt: $error';
  }

  @override
  String get connAddBroker => 'Broker toevoegen';

  @override
  String get connEmpty =>
      'Nog geen verbindingen.\nTik op „Broker toevoegen” om ZigDash op je MQTT-server te richten.';

  @override
  String get connNew => 'Nieuwe verbinding';

  @override
  String get connEdit => 'Verbinding bewerken';

  @override
  String get save => 'Opslaan';

  @override
  String get saving => 'Opslaan…';

  @override
  String get fieldRequired => 'Verplicht';

  @override
  String get connName => 'Naam';

  @override
  String get connNameHint => 'Thuisbroker';

  @override
  String get connHost => 'Host';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Lokale host';

  @override
  String get connFindBrokers => 'Brokers zoeken';

  @override
  String get connHowToFind => 'Hoe vind ik dit?';

  @override
  String get connRescan => 'Opnieuw scannen';

  @override
  String get connBrokerNeedsLogin => 'Inloggen vereist';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Scannen van $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return '$count broker(s) gevonden — tik om te gebruiken';
  }

  @override
  String get connFindBrokersNone => 'Geen brokers gevonden op je wifi.';

  @override
  String get connFindBrokersNoIp =>
      'Je wifi-adres kon niet worden gelezen. Zorg dat wifi aanstaat en probeer het opnieuw.';

  @override
  String get connHelpTitle => 'Het IP-adres van je broker vinden';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT in Docker';

  @override
  String get connHelpDockerBody =>
      'Het broker-IP is het LAN-adres van de machine waarop Docker draait (je NAS, Raspberry Pi, enz.). Vind het in de apparaatlijst van je router, of voer \'hostname -I\' / \'ip addr\' uit op die machine. De poort is meestal 1883 (Mosquitto). Gebruik het LAN-IP van de host — niet 127.0.0.1 — ook als Mosquitto in een eigen container draait.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'Het broker-IP is het IP-adres van de hub. Vind het in de SMLIGHT-webinterface onder Instellingen → Netwerk, of in je router. De poort is 1883, standaard zonder gebruikersnaam/wachtwoord.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA heeft geen MQTT-broker — het communiceert rechtstreeks met Home Assistant, dus ZigDash kan er geen verbinding mee maken. Om ZigDash te gebruiken, schakel je over naar Zigbee2MQTT (beschikbaar als Home Assistant-add-on of Docker-container), dat een MQTT-broker levert.';

  @override
  String get connHelpSameNetwork =>
      'Je telefoon en de broker moeten op hetzelfde wifi-netwerk zitten (geen gast- of geïsoleerd VLAN).';

  @override
  String get connRemoteHost => 'Externe host (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Wordt gebruikt wanneer de lokale host niet bereikbaar is. Gebruik bij voorkeur het Tailscale-IP van de hub, bijv. 100.x.y.z';

  @override
  String get connPort => 'Poort';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsernameOptional => 'Gebruikersnaam (optioneel)';

  @override
  String get connPasswordOptional => 'Wachtwoord (optioneel)';

  @override
  String get connPasswordKeepHint => 'Leeg laten om het bestaande te behouden';

  @override
  String get connAutoConnect =>
      'Automatisch verbinden bij het starten van de app';

  @override
  String get advanced => 'Geavanceerd';

  @override
  String get connKeepAlive => 'Keep-alive (seconden)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protocol';

  @override
  String get edit => 'Bewerken';

  @override
  String get delete => 'Verwijderen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get connDeleteTitle => 'Verbinding verwijderen?';

  @override
  String connDeleteContent(Object name) {
    return 'Verwijdert „$name”, de dashboards/panelen en het opgeslagen wachtwoord.';
  }

  @override
  String get statusDisconnected => 'Verbroken';

  @override
  String get statusConnecting => 'Verbinden…';

  @override
  String get statusConnected => 'Verbonden';

  @override
  String get statusReconnecting => 'Opnieuw verbinden…';

  @override
  String get statusError => 'Fout';

  @override
  String get statusConnectedRemote => 'Verbonden · Extern';

  @override
  String get dashPlaceholder =>
      'Open een broker via het tabblad Brokers om de dashboards te bekijken en beheren.';

  @override
  String get dashAddDashboard => 'Dashboard toevoegen';

  @override
  String get dashEditDashboard => 'Dashboard bewerken';

  @override
  String get dashAddPanel => 'Paneel toevoegen';

  @override
  String get dashEmpty =>
      'Nog geen dashboards.\nTik op „Dashboard toevoegen” om er een voor deze broker te maken.';

  @override
  String dashLoadFailed(Object error) {
    return 'Fout: $error';
  }

  @override
  String get panelPickerTitle => 'Paneel toevoegen';

  @override
  String get panelPickerSectionControl => 'Bediening';

  @override
  String get panelPickerSectionState => 'Status';

  @override
  String get panelPickerToggleTitle => 'Schakelaar';

  @override
  String get panelPickerToggleSubtitle =>
      'Aan/uit-schakelaar voor een apparaatstatus';

  @override
  String get panelPickerSliderBrightnessTitle => 'Schuifregelaar — Helderheid';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Licht dimmen (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Schuifregelaar — Positie';

  @override
  String get panelPickerSliderPositionSubtitle => 'Rolluik (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Rolluik';

  @override
  String get panelPickerCoverSubtitle =>
      'Rolluik: OPEN·STOP·DICHT + positieregelaar';

  @override
  String get panelPickerScheduleTitle => 'Schema';

  @override
  String get panelPickerScheduleSubtitle =>
      'Dagelijkse open-/sluittijden, draait op de hub (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Auto-sluitregel';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Sluit een apparaat automatisch N seconden nadat het aangaat, draait op de hub (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Meervoudige status';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Gesegmenteerde knoppen voor een opsomming (bijv. OPEN/STOP/DICHT)';

  @override
  String get panelPickerComboTitle => 'Dropdown';

  @override
  String get panelPickerComboSubtitle => 'Dropdown-selectie voor een opsomming';

  @override
  String get panelPickerRadioTitle => 'Radio';

  @override
  String get panelPickerRadioSubtitle => 'Radioknoplijst voor een opsomming';

  @override
  String get panelPickerButtonTitle => 'Knop';

  @override
  String get panelPickerButtonSubtitle => 'Een eenmalig commando versturen';

  @override
  String get panelPickerTextInputTitle => 'Tekstinvoer';

  @override
  String get panelPickerTextInputSubtitle =>
      'Een vrije waarde of JSON publiceren';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Kleurindicator voor een booleaanse status (contact, lekkage)';

  @override
  String get panelPickerNodeStatusTitle => 'Knooppuntstatus';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Beschikbaarheid van Z2M-apparaten (online/offline)';

  @override
  String get panelPickerProgressTitle => 'Voortgang';

  @override
  String get panelPickerProgressSubtitle =>
      'Numerieke balk voor batterij, verbindingskwaliteit, enz.';

  @override
  String get panelPickerTextLogTitle => 'Tekstlogboek';

  @override
  String get panelPickerTextLogSubtitle =>
      'Doorlopende berichtgeschiedenis op een topic';

  @override
  String get dashExportMenu => 'Dashboards exporteren';

  @override
  String get dashImportMenu => 'Dashboards importeren';

  @override
  String get dashExportTitle => 'Dashboards exporteren';

  @override
  String get dashExportClose => 'Sluiten';

  @override
  String get dashExportCopy => 'Kopiëren';

  @override
  String get dashExportCopied => 'Naar klembord gekopieerd';

  @override
  String get dashImportTitle => 'Dashboards importeren';

  @override
  String get dashImportHint => 'Plak hier geëxporteerde JSON';

  @override
  String get dashImportButton => 'Importeren';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dashboards geïmporteerd',
      one: '1 dashboard geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Importeren mislukt: $error';
  }

  @override
  String get dashFormNew => 'Nieuw dashboard';

  @override
  String get dashFormEdit => 'Dashboard bewerken';

  @override
  String get dashFormName => 'Naam';

  @override
  String get dashFormNameHint => 'Kantoor';

  @override
  String get dashFormTopicPrefix => 'Topic-voorvoegsel (optioneel)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/woonkamer';

  @override
  String get dashFormTopicPrefixHelper =>
      'Wordt voor elk paneel-topic in dit dashboard geplaatst';

  @override
  String get dashFormColorSeed => 'Kleur';

  @override
  String get dashFormIcon => 'Pictogram';

  @override
  String get dashFormLock => 'Vergrendelen';

  @override
  String get dashFormLockSubtitle =>
      'Bewerkopties verbergen zolang vergrendeld';

  @override
  String get dashFormDelete => 'Dashboard verwijderen';

  @override
  String get dashDeleteTitle => 'Dit dashboard verwijderen?';

  @override
  String get dashDeleteContent => 'Alle panelen eronder worden ook verwijderd.';

  @override
  String get dashDeleteConfirm => 'Verwijderen';

  @override
  String panelFormNew(Object type) {
    return 'Nieuw $type';
  }

  @override
  String panelFormEdit(Object type) {
    return '$type bewerken';
  }

  @override
  String get panelTypeButton => 'Knop';

  @override
  String get panelTypeToggle => 'Schakelaar';

  @override
  String get panelTypeSlider => 'Schuifregelaar';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Knooppuntstatus';

  @override
  String get panelTypeProgress => 'Voortgang';

  @override
  String get panelTypeMultiState => 'Meervoudige status';

  @override
  String get panelTypeCombo => 'Dropdown';

  @override
  String get panelTypeRadio => 'Radio';

  @override
  String get panelTypeCover => 'Rolluik';

  @override
  String get panelTypeTextInput => 'Tekstinvoer';

  @override
  String get panelTypeTextLog => 'Tekstlogboek';

  @override
  String get panelTypeSchedule => 'Schema';

  @override
  String get panelTypeAutoClose => 'Auto-sluiten';

  @override
  String get panelFormName => 'Naam';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Dashboard-voorvoegsel: $prefix/ (gebruikt tenzij hieronder overschreven)';
  }

  @override
  String get panelFormTopicPrefixOverride =>
      'Topic-voorvoegsel overschrijven (optioneel)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/rolluik';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Een ander apparaat op dit dashboard gebruiken. Leeg = dashboard-voorvoegsel gebruiken.';

  @override
  String get panelFormPublishTopic => 'Publicatie-topic (achtervoegsel)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Wordt aan het effectieve voorvoegsel toegevoegd. Leeg laten om op het voorvoegsel zelf te publiceren.';

  @override
  String get panelFormTopicSuffix => 'Topic (achtervoegsel)';

  @override
  String get panelFormSubscribeTopic =>
      'Abonnement-topic (achtervoegsel, optioneel)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Wordt aan het dashboard-voorvoegsel toegevoegd. Leeg = op het voorvoegsel zelf abonneren (Z2M-status).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Leeg = op het voorvoegsel zelf abonneren (Z2M-status). Zelfde als Publicatie-topic = dat gebruiken.';

  @override
  String get panelFormWidth => 'Breedte';

  @override
  String get panelFormWidthFull => 'Volledig';

  @override
  String get panelFormWidthHalf => 'Half';

  @override
  String get panelFormWidthThird => 'Derde';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — hoogstens één keer';

  @override
  String get panelFormQos1 => '1 — minstens één keer';

  @override
  String get panelFormQos2 => '2 — precies één keer';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'Aan-payload';

  @override
  String get panelToggleOffPayload => 'Uit-payload';

  @override
  String get panelToggleJsonPath => 'JSON-pad (optioneel)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'Aan-matching';

  @override
  String get panelToggleOnMatchHelper =>
      'Waarde op het JSON-pad die „aan” betekent (bijv. „ON”)';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Max';

  @override
  String get panelSliderStep => 'Stap';

  @override
  String get panelSliderTemplate => 'Waardesjabloon';

  @override
  String get panelSliderTemplateHelper =>
      'Gebruik het woord value als placeholder — het wordt vervangen door de schuifwaarde';

  @override
  String get panelSliderJsonPath => 'JSON-pad (optioneel)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'JSON-pad (optioneel)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'bijv. „contact”, „occupancy”, „water_leak”';

  @override
  String get panelLedOnMatch => 'Aan-matching';

  @override
  String get panelLedOnMatchHelper =>
      'Waarde op het JSON-pad die de LED laat branden (bijv. „true”, „ON”)';

  @override
  String get panelLedOnLabel => 'Aan-label (optioneel)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Uit-label (optioneel)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Online-payload';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Waarde die „online” betekent (Z2M-standaard: „online”)';

  @override
  String get panelNodeJsonPath => 'JSON-pad (optioneel)';

  @override
  String get panelNodeJsonPathHelper =>
      'Leeg laten voor de Z2M-standaard (ruwe „online”/„offline”-string)';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Max';

  @override
  String get panelProgressUnit => 'Eenheid';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'JSON-pad (optioneel)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'bijv. „battery”, „linkquality”';

  @override
  String get panelOptionsJsonPath => 'JSON-pad (optioneel)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Veld in de ontvangen payload dat de huidige waarde bevat';

  @override
  String get panelOptionsHeader => 'Opties';

  @override
  String get panelOptionsLabel => 'Label';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Matching (huidige waarde)';

  @override
  String get panelOptionsAdd => 'Optie toevoegen';

  @override
  String get panelCoverDescription =>
      'OPEN-/STOP-/DICHT-knoppen plus een rij positievoorinstellingen. Gebruikt de standaard Z2M-rolluik-payloads (state en position).';

  @override
  String get panelCoverPresets => 'Positievoorinstellingen';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Kommascheiding, percentages (0–100). Leeg = geen voorinstellingenrij.';

  @override
  String get panelCoverShowSlider => 'Positieregelaar tonen';

  @override
  String get panelTextInputHint => 'Hint (optioneel)';

  @override
  String get panelTextInputHintHint => 'Typ een waarde…';

  @override
  String get panelTextInputTemplate => 'Sjabloon';

  @override
  String get panelTextInputTemplateHelper =>
      'Gebruik het woord value als placeholder — het wordt vervangen door de getypte tekst. Standaard wordt de ruwe tekst gepubliceerd.';

  @override
  String get panelTextInputClearAfterSend => 'Leegmaken na verzenden';

  @override
  String get panelTextLogMaxLines => 'Max. regels';

  @override
  String get panelTextLogMaxLinesHelper =>
      'Hoeveel recente berichten worden bewaard';

  @override
  String get panelTextLogJsonPath => 'JSON-pad (optioneel)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Alleen dit veld loggen in plaats van de hele payload';

  @override
  String get panelScheduleDescription =>
      'Draait op de SMHUB via Node-RED — ook als deze telefoon uitstaat. Het publicatie-topic hierboven is het doel voor rolluikcommando\'s.';

  @override
  String get panelScheduleOpenTime => 'Opentijd';

  @override
  String get panelScheduleCloseTime => 'Sluitijd';

  @override
  String get panelScheduleOpenPayload => 'Open-payload';

  @override
  String get panelScheduleClosePayload => 'Sluit-payload';

  @override
  String get panelScheduleEnabled => 'Ingeschakeld';

  @override
  String get panelScheduleSavedOffline =>
      'Opgeslagen — niet verbonden; het schema wordt gesynchroniseerd zodra online.';

  @override
  String get panelAutoCloseDescription =>
      'Draait op de SMHUB via Node-RED — ook als deze telefoon uitstaat. Het publicatie-topic hierboven is het commando-doel van het apparaat (bijv. deur).';

  @override
  String get panelAutoCloseTriggerPath => 'Trigger-JSON-pad';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Veld in de status-JSON van het apparaat om te volgen (standaard: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Triggerwaarde';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'De timer starten wanneer het triggerveld gelijk is aan deze waarde (standaard: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Sluit-payload';

  @override
  String get panelAutoCloseDelaySeconds => 'Vertraging (seconden)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1–3600. Tijd wachten nadat het apparaat aangaat voordat de sluit-payload wordt gepubliceerd.';

  @override
  String get panelAutoCloseEnabled => 'Ingeschakeld';

  @override
  String get panelAutoCloseSavedOffline =>
      'Opgeslagen — niet verbonden; de regel wordt gesynchroniseerd zodra online.';

  @override
  String get panelTileEdit => 'Paneel bewerken';

  @override
  String get panelTileDuplicate => 'Paneel dupliceren';

  @override
  String get panelTileMoveUp => 'Naar boven';

  @override
  String get panelTileMoveDown => 'Naar beneden';

  @override
  String get panelTileWidth => 'Breedte';

  @override
  String get panelTileWidthFull => 'Volledig';

  @override
  String get panelTileWidthHalf => 'Half';

  @override
  String get panelTileWidthThird => '⅓';

  @override
  String get panelTileDelete => 'Paneel verwijderen';

  @override
  String get panelCoverOpen => 'Openen';

  @override
  String get panelCoverStop => 'Stoppen';

  @override
  String get panelCoverClose => 'Sluiten';

  @override
  String get panelToggleNoState => '(geen status)';

  @override
  String get panelToggleError => 'fout';

  @override
  String get panelStateOn => 'ON';

  @override
  String get panelStateOff => 'OFF';

  @override
  String get panelNodeStatusOnline => 'online';

  @override
  String get panelNodeStatusOffline => 'offline';

  @override
  String get panelNodeStatusUnknown => 'onbekend';

  @override
  String get panelNodeStatusError => 'fout';

  @override
  String get panelMultiStateNoOptions => 'Geen opties geconfigureerd';

  @override
  String get panelTextInputDefaultHint => 'Typ een waarde…';

  @override
  String get panelTextLogWaiting => 'Wachten op berichten…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Opent $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Sluit $time';
  }

  @override
  String get panelScheduleOfflineWarning => 'Scheduler offline — draait niet';

  @override
  String get panelScheduleDisabled => 'Uitgeschakeld';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Volgende: $action om $at';
  }

  @override
  String get panelScheduleActionOpen => 'openen';

  @override
  String get panelScheduleActionClose => 'sluiten';

  @override
  String get panelAutoCloseIdle => 'Inactief';

  @override
  String get panelAutoCloseDisabled => 'Uitgeschakeld';

  @override
  String get panelAutoCloseOffline =>
      'Automatisering offline — regel draait niet';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Sluit over ${seconds}s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Sluiten…';

  @override
  String get panelGridEmpty =>
      'Nog geen panelen.\nTik op + om een Schakelaar, Schuifregelaar of Knop toe te voegen.';

  @override
  String get panelsOffline => 'Offline — laatste waarden worden getoond';

  @override
  String get connectionConnecting => 'Verbinden…';

  @override
  String get connectionReconnecting => 'Opnieuw verbinden…';

  @override
  String get connectionShowingLastKnownValues =>
      'Laatst bekende waarden worden weergegeven';

  @override
  String get connectionFailed => 'Verbinding mislukt';

  @override
  String get connectionAutomaticRetry =>
      'Automatisch opnieuw proberen gaat door';

  @override
  String get connectionReconnectNow => 'Nu opnieuw verbinden';

  @override
  String get settingsAbout => 'Over';

  @override
  String get settingsHelp => 'Help & Handleiding';

  @override
  String get settingsVersion => 'Versie';

  @override
  String get a11yBackupMenu => 'Back-up & herstel';

  @override
  String get a11ySelectColor => 'Kleur selecteren';

  @override
  String get a11ySelectIcon => 'Pictogram selecteren';

  @override
  String get a11yDeleteOption => 'Optie verwijderen';

  @override
  String get a11yPanelOptions => 'Paneelopties';

  @override
  String get a11yMoreOptions => 'Meer opties';

  @override
  String get a11yDeleteConnection => 'Verbinding verwijderen';

  @override
  String get controlNotConnected => 'Niet verbonden — wijziging niet verzonden';

  @override
  String get discoverFromDevice => 'Toevoegen vanaf een apparaat…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Een Zigbee2MQTT-apparaat automatisch detecteren';

  @override
  String get discoverTitle => 'Toevoegen vanaf apparaat';

  @override
  String get discoverBaseTopic => 'Zigbee2MQTT-basis-topic';

  @override
  String get discoverScanning => 'Zoeken naar apparaten…';

  @override
  String get discoverNone => 'Geen apparaten gevonden.';

  @override
  String get discoverFailed =>
      'Geen apparaatlijst gevonden. Controleer het basis-topic en dat de broker is verbonden.';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get previewTitle => 'Livevoorbeeld';

  @override
  String previewWaiting(Object topic) {
    return 'Wachten op een bericht op $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Geëxtraheerd ($path): $value';
  }

  @override
  String get previewNoValue => '(geen waarde op dit pad)';

  @override
  String get connErrorTitle => 'Verbindingsfout';

  @override
  String get connErrorUnknown => 'Geen foutdetails beschikbaar.';

  @override
  String get connTestButton => 'Verbinding testen';

  @override
  String get connTestOk => 'Verbinding geslaagd';

  @override
  String connTestFailed(Object error) {
    return 'Verbinding mislukt: $error';
  }

  @override
  String get devicesTitle => 'Apparaten';

  @override
  String get devicesAddButton => 'Apparaat toevoegen';

  @override
  String get devicesPairingTitle =>
      'Koppelen — druk op de knop van het apparaat';

  @override
  String devicesPairingHint(int seconds) {
    return 'Zoeken naar nieuwe apparaten… ${seconds}s';
  }

  @override
  String get devicesPairingStop => 'Stoppen';

  @override
  String get devicesNone => 'Geen apparaten gevonden.';

  @override
  String get devicesBattery => 'Batterij';

  @override
  String get devicesLinkQuality => 'Link';

  @override
  String get devicesOnline => 'Online';

  @override
  String get devicesOffline => 'Offline';

  @override
  String devicesPaired(Object name) {
    return 'Klaar: $name';
  }

  @override
  String get devicesPairedHint =>
      'Toegevoegd aan je netwerk. Om het op een dashboard te zetten, gebruik je op dat dashboard „Toevoegen vanaf een apparaat”.';

  @override
  String get scenesTitle => 'Scènes';

  @override
  String get scenesNone =>
      'Nog geen scènes. Zet je apparaten naar wens en leg ze daarna vast als scène.';

  @override
  String get scenesNewButton => 'Nieuwe scène';

  @override
  String scenesActivated(Object name) {
    return '$name geactiveerd';
  }

  @override
  String get scenesActivateOffline =>
      'Niet verbonden — de scène kan niet worden geactiveerd';

  @override
  String get sceneFormNewTitle => 'Nieuwe scène';

  @override
  String get sceneFormEditTitle => 'Scène bewerken';

  @override
  String get sceneFormNameLabel => 'Scènenaam';

  @override
  String get sceneFormDevicesHeader => 'Apparaten om vast te leggen';

  @override
  String get sceneFormCaptureHint =>
      'De huidige instelbare status van elk geselecteerd apparaat (aan/uit, helderheid, kleur, positie…) wordt opgeslagen. Alleen-lezen waarden worden genegeerd.';

  @override
  String get sceneFormNoDevices =>
      'Geen bestuurbare apparaten gevonden. Controleer of ze zijn gekoppeld en tik daarna op vernieuwen.';

  @override
  String get sceneFormReadingState => 'Huidige status lezen…';

  @override
  String get sceneCtrlPower => 'Stroom';

  @override
  String get sceneCtrlBrightness => 'Helderheid';

  @override
  String get sceneCtrlPosition => 'Positie';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count geselecteerd';
  }

  @override
  String get sceneFormNoDevicesSelected =>
      'Selecteer minstens één apparaat om vast te leggen.';

  @override
  String get sceneFormNothingCaptured =>
      'Er kon niets instelbaars worden vastgelegd van de geselecteerde apparaten.';

  @override
  String get sceneDeleteTitle => 'Scène verwijderen?';

  @override
  String sceneDeleteMessage(Object name) {
    return '„$name” wordt verwijderd. Apparaten behouden hun huidige status.';
  }

  @override
  String get sceneEditAction => 'Bewerken';

  @override
  String get sceneDeleteAction => 'Verwijderen';

  @override
  String get sceneAddToDashboard => 'Aan dashboard toevoegen';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Toegevoegd aan $name';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count apparaten';
  }

  @override
  String get panelTypeScene => 'Scène';

  @override
  String get panelPickerSceneTitle => 'Scèneknop';

  @override
  String get panelPickerSceneSubtitle =>
      'Eén tik activeert een opgeslagen scène';

  @override
  String get panelSceneChoose => 'Scène';

  @override
  String get panelSceneMissing => 'Scène niet gevonden — kies opnieuw';

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
  String get guidedConnectTitle => 'Broker instellen';

  @override
  String get guidedConnectIntro =>
      'We testen elke stap van de verbinding en tonen uw Zigbee-apparaten.';

  @override
  String get guidedBaseTopic => 'Basis-topic';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Testen en verbinden';

  @override
  String get guidedTesting => 'Verbinding testen…';

  @override
  String get stepResolve => 'Host oplossen';

  @override
  String get stepTcp => 'TCP-verbinding';

  @override
  String get stepConnack => 'MQTT-handshake';

  @override
  String get stepAuth => 'Authenticatie';

  @override
  String get stepDevices => 'Apparaten zoeken';

  @override
  String get diagResolveFail =>
      'De hostnaam kon niet worden opgelost. Controleer het ingevoerde adres.';

  @override
  String get diagResolveTimeout =>
      'Het oplossen van de host duurde te lang. Controleer adres en netwerk.';

  @override
  String get diagTcpFail =>
      'De broker is niet bereikbaar. Draait Zigbee2MQTT? Controleer adres en poort.';

  @override
  String get diagTcpTimeout =>
      'Verbinding met de broker verliep te lang. Deze is mogelijk offline of niet bereikbaar.';

  @override
  String get diagConnackFail =>
      'De broker heeft de MQTT-handshake niet voltooid. Zorg dat het een MQTT-broker is (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'De broker heeft gebruikersnaam of wachtwoord geweigerd. Controleer uw gegevens.';

  @override
  String get diagAuthRefused =>
      'De broker heeft de verbinding geweigerd. Controleer de verbindingsinstellingen.';

  @override
  String foundDevices(Object count) {
    return '$count apparaten gevonden';
  }

  @override
  String get foundDevicesHint =>
      'Uw Zigbee-apparaten zijn zichtbaar. Ga verder met uw dashboard.';

  @override
  String get noDevicesTitle => 'Verbonden – nog geen apparaten gevonden';

  @override
  String get noDevicesHint =>
      'ZigDash ziet de broker, maar heeft nog geen Zigbee-apparaten gevonden. U kunt het koppelen starten.';

  @override
  String get startPairing => 'Koppelen starten';

  @override
  String get pairingEnabled =>
      'Koppelen is ingeschakeld. Druk op de koppelknop van uw apparaat.';

  @override
  String get continueToDashboard => 'Naar dashboard';

  @override
  String get guidedBackToForm => 'Instellingen bewerken';

  @override
  String ladderTriedHint(Object count) {
    return '$count adressen geprobeerd';
  }

  @override
  String get guidedSaveFailed =>
      'De verbinding kon niet worden opgeslagen. Probeer het opnieuw.';

  @override
  String get onboardingConnectBroker => 'Mijn broker verbinden';

  @override
  String get setupWelcomeTitle => 'Welkom bij ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash bedient je bestaande Zigbee2MQTT-woning — lokaal, zonder cloud. Zorg dat Zigbee2MQTT draait en laat ZigDash het vinden.';

  @override
  String get setupFindMySetup => 'Vind mijn installatie';

  @override
  String get setupManualEntry => 'Gegevens handmatig invoeren';

  @override
  String get setupScanningTitle => 'Verbinding zoeken…';

  @override
  String get setupScanningHint =>
      'Houd dit apparaat op hetzelfde lokale netwerk als je Zigbee2MQTT-host.';

  @override
  String get setupCandidateFound => 'Mogelijke verbinding gevonden';

  @override
  String get setupNoCandidatesTitle => 'Geen verbinding gevonden';

  @override
  String get setupNoCandidatesBody => 'Waar draait Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: zorg dat de MQTT-broker-add-on (bijv. Mosquitto) en de Zigbee2MQTT-add-on geïnstalleerd zijn en draaien.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: controleer dat je broker (bijv. Mosquitto) en de Zigbee2MQTT-service draaien en dat poort 1883 bereikbaar is.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: open de webinterface van het apparaat, schakel de MQTT-broker in en controleer dat Zigbee2MQTT als verbonden wordt weergegeven.';

  @override
  String get setupTryAgain => 'Opnieuw proberen';

  @override
  String get setupAuthTitle => 'Deze broker vereist een login';

  @override
  String setupAuthBody(Object host) {
    return 'Voer de MQTT-gebruikersnaam en het wachtwoord voor $host in.';
  }

  @override
  String get setupAuthRejectedBody =>
      'De gebruikersnaam of het wachtwoord is geweigerd. Controleer ze en probeer het opnieuw.';

  @override
  String get setupVerifyingTitle => 'Verbinding controleren…';

  @override
  String get setupReviewTitle => 'Je apparaten';

  @override
  String setupReviewSubtitle(Object count) {
    return '$count apparaten gevonden. Kies wat op je eerste dashboard komt.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'Dashboard maken met $count';
  }

  @override
  String get setupGroupOther => 'Andere apparaten';

  @override
  String get setupGroupUnsupported => 'Niet-ondersteunde apparaten';

  @override
  String get setupCreatingTitle => 'Je dashboard wordt gemaakt…';

  @override
  String get setupReadyTitle => 'Je dashboard is klaar';

  @override
  String setupReadyBody(Object count) {
    return '$count bedieningen gemaakt.';
  }

  @override
  String get setupOpenDashboard => 'Dashboard openen';

  @override
  String get setupErrUnreachableTitle => 'Dit adres is niet bereikbaar';

  @override
  String get setupErrUnreachableBody =>
      'Dit apparaat en de Zigbee2MQTT-host kunnen elkaar niet bereiken. Controleer dat beide op hetzelfde lokale netwerk zitten.';

  @override
  String get setupErrUnreachableAction => 'Opnieuw proberen';

  @override
  String get setupErrPortClosedTitle => 'Niets antwoordt op deze poort';

  @override
  String get setupErrPortClosedBody =>
      'De host is bereikbaar, maar geen MQTT-broker heeft geantwoord. Controleer dat de broker draait en dat de poort klopt.';

  @override
  String get setupErrPortClosedAction => 'Opnieuw proberen';

  @override
  String get setupErrAuthRequiredTitle => 'Login vereist';

  @override
  String get setupErrAuthRequiredBody =>
      'Deze broker vereist een gebruikersnaam en wachtwoord.';

  @override
  String get setupErrAuthRequiredAction => 'Login invoeren';

  @override
  String get setupErrAuthRejectedTitle => 'Login geweigerd';

  @override
  String get setupErrAuthRejectedBody =>
      'De broker heeft deze inloggegevens geweigerd.';

  @override
  String get setupErrAuthRejectedAction => 'Opnieuw proberen';

  @override
  String get setupErrNotZ2mTitle => 'Hier is geen Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'Hier antwoordt een MQTT-broker, maar er zijn geen Zigbee2MQTT-topics gevonden. Het kan een andere broker zijn.';

  @override
  String get setupErrNotZ2mAction => 'Kies een andere';

  @override
  String get setupErrNoDevicesTitle => 'Geen apparaten ontvangen';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT draait, maar er zijn tijdens de controle geen apparaten gepubliceerd. Koppel eerst apparaten in Zigbee2MQTT.';

  @override
  String get setupErrNoDevicesAction => 'Opnieuw controleren';

  @override
  String get setupErrScanFailedTitle => 'Geen lokaal netwerk';

  @override
  String get setupErrScanFailedBody =>
      'Het lokale netwerk van dit apparaat kon niet worden bepaald. Verbind met wifi en probeer het opnieuw.';

  @override
  String get setupErrScanFailedAction => 'Opnieuw proberen';

  @override
  String get setupErrSaveFailedTitle => 'Opslaan mislukt';

  @override
  String get setupErrSaveFailedBody =>
      'Het opslaan van je installatie is mislukt. Er is niets half opgeslagen — je kunt het veilig opnieuw proberen.';

  @override
  String get setupErrSaveFailedAction => 'Opnieuw proberen';

  @override
  String get setupErrUnknownTitle => 'Er is iets misgegaan';

  @override
  String get setupErrUnknownBody => 'Er is een onverwachte fout opgetreden.';

  @override
  String get setupErrUnknownAction => 'Opnieuw proberen';
}
