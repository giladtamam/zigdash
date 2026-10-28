// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Laatst bekend';

  @override
  String get reliabilityControlsUnavailable => 'Bediening niet beschikbaar';

  @override
  String get appTitle => 'ZigDash';

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
  String get connectionsTitle => 'Huizen';

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
  String get connUsername => 'Gebruikersnaam';

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
  String get dashFormLock => 'Bewerkvergrendeling';

  @override
  String get dashFormLockSubtitle => 'Verbergt Bewerken voor dit dashboard';

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
  String get panelTypeDevice => 'Apparaat';

  @override
  String get panelTypeReading => 'Meetwaarde';

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
  String get tileSize => 'Grootte';

  @override
  String get tileSizeSmall => 'Klein';

  @override
  String get tileSizeWide => 'Breed';

  @override
  String get tileSizeFull => 'Volledig';

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
      'Nog geen tegels.\nTik op Tegel toevoegen om je apparaten hier te zetten.';

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
  String get settingsRateApp => 'Beoordeel ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Tevreden? Een korte review helpt anderen de app te vinden.';

  @override
  String get settingsFeatureRequest => 'Functie aanvragen';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Vertel me wat ZigDash beter zou maken.';

  @override
  String get featureRequestGithub => 'Op GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Openbaar: anderen kunnen het zien en erop stemmen.';

  @override
  String get featureRequestEmail => 'Per e-mail';

  @override
  String get featureRequestEmailSubtitle =>
      'Privé, rechtstreeks naar de ontwikkelaar.';

  @override
  String get featureRequestEmailSubject => 'ZigDash: functieverzoek';

  @override
  String get featureRequestEmailPrompt =>
      'Wat zou je willen dat ZigDash doet, en waarom?';

  @override
  String get settingsReportProblem => 'Probleem melden';

  @override
  String get settingsReportProblemSubtitle =>
      'Werkt iets niet of is iets onduidelijk? Laat het me weten.';

  @override
  String get reportProblemEmailSubject => 'ZigDash: probleemmelding';

  @override
  String get reportProblemEmailPrompt =>
      'Wat gebeurde er, en wat verwachtte je?';

  @override
  String get settingsBuyCoffee => 'Trakteer me op een koffie';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Gratis & open source — fooien houden de koffie stromen.';

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
  String get a11yRefresh => 'Vernieuwen';

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
  String get devicesListMissing =>
      'Zigbee2MQTT heeft zijn apparatenlijst niet verstuurd. Dat kan gebeuren nadat de MQTT-broker opnieuw is gestart.';

  @override
  String get devicesRestartZ2m => 'Zigbee2MQTT opnieuw starten';

  @override
  String get devicesRestartingZ2m =>
      'Zigbee2MQTT start opnieuw. Je apparaten verschijnen over een paar seconden.';

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
  String get scenesAllShutters => 'Alle rolluiken';

  @override
  String get sceneCloseAllShutters => 'Alle rolluiken sluiten';

  @override
  String get sceneOpenAllShutters => 'Alle rolluiken openen';

  @override
  String get sceneStopAllShutters => 'Alle rolluiken stoppen';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rolluiken',
      one: '1 rolluik',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Welke rolluiken…';

  @override
  String get sceneWhichShuttersHint =>
      'Alle rolluiken van dit huis doen mee. Vink uit wat erbuiten moet blijven, zoals een garagedeur.';

  @override
  String get scenesYours => 'Jouw scènes';

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
  String get languageFrench => 'Français';

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
      'De broker accepteerde de verbinding niet. Controleer of je MQTT-broker (meestal Mosquitto) draait en verbindingen van andere apparaten accepteert, en of adres en poort (meestal 1883) kloppen.';

  @override
  String get diagTcpTimeout =>
      'Verbinding met de broker verliep te lang. Deze is mogelijk offline of niet bereikbaar.';

  @override
  String get diagConnackFail =>
      'De broker heeft de MQTT-handshake niet voltooid. Zorg dat het een MQTT-broker is (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'De broker antwoordde niet op tijd op de aanmelding. Home Assistant kan een paar seconden nodig hebben om die te controleren, probeer het opnieuw.';

  @override
  String get diagAuthRejected =>
      'De broker heeft gebruikersnaam of wachtwoord geweigerd. Controleer uw gegevens.';

  @override
  String get diagAuthRefused =>
      'De broker heeft de verbinding geweigerd. Controleer de verbindingsinstellingen.';

  @override
  String get diagResolveLocalName =>
      'Je telefoon kon deze naam niet vinden. Android kan namen die op .local eindigen vaak niet opzoeken; vul in plaats daarvan het IP-adres in (Home Assistant toont het onder Instellingen › Systeem › Netwerk).';

  @override
  String get diagTcpHaNoBroker =>
      'Dit is je Home Assistant, maar er draait geen MQTT-broker op. Installeer en start de add-on Mosquitto broker (Instellingen › Add-ons) en probeer het opnieuw.';

  @override
  String get diagTcpSmlightClosed =>
      'Dit is je SMLIGHT-hub, maar de MQTT-broker erop accepteert geen verbindingen van andere apparaten. Open op de webpagina van de hub Settings › MQTT, zet Allow External aan, sla op en probeer het opnieuw.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Op dit adres draait Zigbee2MQTT, maar het bereikt zijn broker onder een andere naam (zie Zigbee2MQTT › Settings › MQTT › Server). Is dat een andere machine, typ dan haar adres, meestal met poort 1883. Is het een container op deze machine, publiceer dan zijn poort (ports: \"1883:1883\") en laat hem op het netwerk luisteren; probeer het daarna opnieuw.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Op dit adres draait Zigbee2MQTT, maar de MQTT-broker accepteert geen verbindingen van andere apparaten. Mosquitto luistert alleen op zijn eigen machine tot je de regels \"listener 1883\" en \"allow_anonymous true\" aan mosquitto.conf toevoegt (of een wachtwoord instelt). Herstart Mosquitto en probeer het opnieuw.';

  @override
  String get diagAuthRejectedHa =>
      'De broker van Home Assistant weigerde deze aanmelding. Gebruik de naam en het wachtwoord van een Home Assistant-gebruiker (Instellingen › Personen › Gebruikers); het liefst een aparte gebruiker alleen voor MQTT.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apparaten gevonden',
      one: '1 apparaat gevonden',
    );
    return '$_temp0';
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
  String get guidedStuckTitle => 'Vast? Vraag het een mens';

  @override
  String get guidedStuckBody =>
      'Twee pogingen zonder verbinding. Vertel ons welke hub je hebt en wat je hebt ingevuld, dan helpen we je hem te vinden.';

  @override
  String get guidedStuckTelegram => 'Vragen in Telegram';

  @override
  String get guidedStuckHelp => 'Tips en e-mail';

  @override
  String ladderTriedHint(Object count) {
    return '$count adressen geprobeerd';
  }

  @override
  String get guidedSaveFailed =>
      'De verbinding kon niet worden opgeslagen. Probeer het opnieuw.';

  @override
  String get setupWelcomeTitle => 'Welkom bij ZigDash';

  @override
  String get setupWelcomeHeadline => 'Je Zigbee-huis, op je telefoon';

  @override
  String get setupWelcomeBody =>
      'Een kleine hub met Zigbee2MQTT is alles wat je nodig hebt: een SMLIGHT-hub, een Raspberry Pi of elke Linux-machine. Geen Home Assistant nodig, en als je het hebt, werkt ZigDash er ook mee. Alles blijft lokaal, zonder cloud.';

  @override
  String get setupFindMySetup => 'Vind mijn installatie';

  @override
  String get setupErrPageTitle => 'De Zigbee2MQTT-pagina antwoordde niet';

  @override
  String get setupErrPageBody =>
      'Op dat adres antwoordde geen Zigbee2MQTT-pagina. Open het in de browser van deze telefoon om het te controleren en kopieer het adres precies (met poort, vaak 8080). Vraagt de pagina om een token, voer dan je brokergegevens in.';

  @override
  String get setupErrPageAction => 'Opnieuw proberen';

  @override
  String get setupLookWider => 'Zoek op het hele netwerk';

  @override
  String get setupAsk => 'Wat stuurt je Zigbee aan?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'Op een Raspberry Pi, een server of Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'Met de Zigbee2MQTT-add-on, of ZHA';

  @override
  String get setupAskSmlight => 'Een SMLIGHT-hub';

  @override
  String get setupAskSmlightSub => 'SLZB of SMHUB met Zigbee2MQTT';

  @override
  String get setupAskNothing => 'Nog niets?';

  @override
  String get setupAskHaWhich => 'Hoe draait je Home Assistant Zigbee?';

  @override
  String get setupAskHaZ2m => 'De Zigbee2MQTT-add-on';

  @override
  String get setupAskHaZ2mSub => 'Inloggen met Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, de eigen Zigbee van Home Assistant';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, zonder Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Verbinden met mijn Zigbee2MQTT-pagina';

  @override
  String get setupManualEntryAdvanced =>
      'Brokergegevens invoeren (geavanceerd)';

  @override
  String get z2mPageTitle => 'Je Zigbee2MQTT-pagina';

  @override
  String get z2mPageBody =>
      'Het adres in je browser als de Zigbee2MQTT-pagina open is, de pagina waarop je apparaten koppelt. Geen MQTT-gebruikersnaam of -wachtwoord nodig.';

  @override
  String get z2mPageLabel => 'Adres van de pagina';

  @override
  String get z2mPageConnect => 'Verbinden';

  @override
  String z2mPageFoundName(String host, String ip) {
    return '$host gevonden op $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Niets antwoordde voor $host op dit netwerk';
  }

  @override
  String get engineNeedsBrokerTitle =>
      'Automatiseringen hebben je MQTT-broker nodig';

  @override
  String get engineNeedsBrokerBody =>
      'Dit huis verbindt via de Zigbee2MQTT-pagina, genoeg voor je dashboards. Automatiseringen, meldingen en geschiedenis draaien in de ZigDash Engine op je hub, die via je MQTT-broker praat. Voer de gegevens één keer in, daarna verbindt ZigDash via de broker.';

  @override
  String get engineNeedsBrokerButton => 'Brokergegevens invoeren';

  @override
  String get connFromPageNote =>
      'Dit huis verbindt via de Zigbee2MQTT-pagina. Voer je MQTT-broker in (meestal hetzelfde apparaat, poort 1883) om automatiseringen, meldingen en geschiedenis aan te zetten. Na opslaan verbindt ZigDash via de broker.';

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
      'SMLIGHT / SMHUB: open de webinterface, ga naar Settings > MQTT, zet Allow External aan zodat je telefoon de broker bereikt, en controleer dat Zigbee2MQTT draait.';

  @override
  String get setupTryAgain => 'Opnieuw proberen';

  @override
  String get reminderButton => 'Herinner me morgen';

  @override
  String get reminderSet => 'We herinneren je morgen, op deze telefoon.';

  @override
  String get reminderNoPermission =>
      'Meldingen staan uit voor ZigDash, dus er komt geen herinnering. Je kunt ze aanzetten in de Android-instellingen.';

  @override
  String get reminderChannel => 'Herinnering voor instellen';

  @override
  String get reminderTitle => 'Rond het instellen van ZigDash af';

  @override
  String get reminderBody =>
      'Thuis op je wifi? Tik om het opnieuw te proberen: het duurt ongeveer een minuut.';

  @override
  String get setupWelcomeNoZ2m => 'Nog geen Zigbee2MQTT?';

  @override
  String get setupWelcomeDemo => 'Probeer het demohuis';

  @override
  String get setupWelcomeHubs => 'Welke hub kiezen';

  @override
  String get haConnectTitle => 'Verbinden via Home Assistant';

  @override
  String get haConnectIntro =>
      'Je telefoon bereikt de broker niet, maar wel Home Assistant. Meld je één keer aan, en ZigDash praat via Home Assistant met Zigbee2MQTT: thuis of onderweg, zonder brokerinstellingen.';

  @override
  String get haConnectAddressHelp =>
      'Het adres waarmee je Home Assistant opent: 192.168.1.20:8123, of een extern adres zoals je Nabu Casa- of Cloudflare-adres';

  @override
  String get haConnectSignInHelp =>
      'De eigen aanmelding van Home Assistant opent in je browser. ZigDash ziet je wachtwoord nooit.';

  @override
  String get haConnectKeeps =>
      'ZigDash bewaart deze aanmelding op je telefoon en handelt als jou in Home Assistant, alleen voor MQTT. Beëindig dit wanneer je wilt in Home Assistant onder Profiel › Beveiliging.';

  @override
  String get haConnectTokenHelp =>
      'Open in Home Assistant je profiel, dan Beveiliging › Langdurige toegangstokens › Token aanmaken. Kopieer het en plak het hier. ZigDash bewaart het op deze telefoon om te verbinden; verwijder het in Home Assistant wanneer je dat wilt beëindigen.';

  @override
  String get haConnectWithToken => 'Verbinden met token';

  @override
  String get haConnectChecking => 'Home Assistant controleren…';

  @override
  String get setupStillChecking =>
      'Nog bezig met controleren. Dit kan tot 30 seconden duren.';

  @override
  String get aiHelpTitle => 'Vast? Vraag je AI-assistent';

  @override
  String get aiHelpBody =>
      'ZigDash zet op een rij wat het vond, voor ChatGPT, Claude, Gemini of een andere AI-app, zonder wachtwoorden of adressen. Je ziet het voordat het gedeeld wordt.';

  @override
  String get aiHelpButton => 'Vraag een AI';

  @override
  String get aiHelpPreviewTitle => 'Wat er gedeeld wordt';

  @override
  String get aiHelpShare => 'Delen met een AI-app';

  @override
  String get aiHelpCopied => 'Gekopieerd. Plak het in een AI-chat naar keuze.';

  @override
  String get haConnectWhereAddress =>
      'Weet je het niet zeker? Open in de Home Assistant-app Instellingen › Companion-app en tik op je server: daar staat het adres. Op een computer is het het adres dat de browser toont als Home Assistant open is.';

  @override
  String get haFindLooking => 'Zoeken naar Home Assistant op dit netwerk…';

  @override
  String get haFindSeveral =>
      'Meer dan één Home Assistant gevonden. Tik op de juiste:';

  @override
  String get haFindNone =>
      'Deze telefoon ziet Home Assistant niet op deze wifi. Gebruik het adres dat je Home Assistant-app opent: vaak een extern adres, zoals https://abcd1234.ui.nabu.casa of https://mijnhuis.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Dat adres zit op een ander netwerk dan deze telefoon, die op $network zit. Gebruik het adres dat je Home Assistant-app opent, vaak een extern adres, of verbind de telefoon met het netwerk van Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Deze telefoon vond die naam niet: Android kan .local-namen vaak niet openen. Typ het IP-adres van Home Assistant (zoals 192.168.1.20:8123) of het externe adres.';

  @override
  String get haConnectRemoteUnreachable =>
      'Er antwoordde niets op dat externe adres. Open het in de browser van deze telefoon om te controleren of het werkt, en kopieer het precies zoals je Home Assistant-app het toont.';

  @override
  String get setupNoWifiHa => 'Gebruik je Home Assistant? Inloggen';

  @override
  String get haConnectNotAdmin =>
      'Je Home Assistant-gebruiker is geen beheerder. ZigDash heeft er een nodig voor de MQTT van Home Assistant. Meld je aan als beheerder, of plak een token dat een beheerder heeft aangemaakt.';

  @override
  String get haConnectNoMqtt =>
      'Deze Home Assistant heeft geen MQTT-integratie. Zigbee2MQTT heeft die ook nodig: voeg in Home Assistant de Mosquitto broker-add-on en de MQTT-integratie toe en probeer het opnieuw.';

  @override
  String get haConnectSignInFailed =>
      'De aanmelding is niet voltooid. Probeer het opnieuw, of gebruik een langdurig token.';

  @override
  String get setupHaShortcut =>
      'Draait Zigbee2MQTT in Home Assistant? Sla de broker en zijn login over: meld je aan met je Home Assistant-beheerdersaccount. Dat werkt vanaf elk netwerk.';

  @override
  String get haConnectButton => 'Verbinden via Home Assistant';

  @override
  String get haConnectManualLink =>
      'Gebruik je Home Assistant? Verbind dan daardoor';

  @override
  String get haConnectEmptyNote =>
      'Bereikt deze telefoon de broker niet? Home Assistant kan de verbinding voor je dragen.';

  @override
  String get haHomeConnected => 'Verbonden via Home Assistant';

  @override
  String get haHomeChange =>
      'Als de aanmelding niet meer werkt, op een nieuwe telefoon of nadat je het token in Home Assistant hebt verwijderd, meld je je hier opnieuw aan. Je kunt het ook beëindigen in Home Assistant onder Profiel › Beveiliging.';

  @override
  String get haHomeSignInAgain => 'Opnieuw aanmelden';

  @override
  String get haHomeRemote => 'Extern adres van Home Assistant (optioneel)';

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
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT logt al in op deze broker: de webpagina toont de gebruikersnaam onder Instellingen › MQTT. Gebruik die gebruiker en het wachtwoord.';

  @override
  String get setupAuthWhich =>
      'Dit is de MQTT-login, niet het wachtwoord van de webpagina van je hub.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: gebruik een Home Assistant-gebruiker. De meesten maken er een speciaal voor MQTT aan onder Instellingen › Personen › Gebruikers, en de Mosquitto-add-on accepteert die.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi of Docker: de gebruiker en het wachtwoord uit het wachtwoordbestand van Mosquitto, dezelfde als in configuration.yaml van Zigbee2MQTT onder mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: de login op de webpagina van de hub onder Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'Verbinding controleren…';

  @override
  String get setupReviewTitle => 'Je apparaten';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apparaten gevonden.',
      one: '1 apparaat gevonden.',
    );
    return '$_temp0 Kies wat op je eerste dashboard komt.';
  }

  @override
  String get setupReviewLastStep =>
      'Laatste stap: vink de apparaten aan die je wilt en tik onderaan op Dashboard maken.';

  @override
  String get setupLeaveTitle => 'Je dashboard maken?';

  @override
  String get setupLeaveBody =>
      'Je apparaten zijn gevonden. Maak het dashboard nu, of begin opnieuw en verlies deze lijst.';

  @override
  String get setupStartOver => 'Opnieuw beginnen';

  @override
  String setupCreateWithCount(Object count) {
    return 'Dashboard maken met $count';
  }

  @override
  String get setupReviewNoneSelected =>
      'Er is nog niets aangevinkt. Vink de apparaten aan die je op het dashboard wilt, of maak het leeg aan en voeg later tegels toe.';

  @override
  String get setupCreateEmpty => 'Leeg dashboard maken';

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
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT stuurde zijn apparatenlijst niet';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT antwoordt, maar zijn apparatenlijst kwam niet. Dat gebeurt meestal nadat de MQTT-broker opnieuw is gestart: Zigbee2MQTT vóór 2.14.2 stuurt de lijst pas opnieuw als het zelf herstart. Herstart Zigbee2MQTT (of werk het bij) en probeer het opnieuw.';

  @override
  String get setupErrListMissingAction => 'Opnieuw proberen';

  @override
  String get setupErrHaNoZ2mTitle => 'Geen Zigbee2MQTT in deze Home Assistant';

  @override
  String get setupErrHaNoZ2mBody =>
      'Je bent ingelogd bij Home Assistant, maar Zigbee2MQTT stuurt niets via zijn MQTT. Staan je Zigbee-apparaten in ZHA (de ingebouwde Zigbee van Home Assistant), dan kan ZigDash ze niet zien: het werkt met Zigbee2MQTT. Gebruik je de Zigbee2MQTT-add-on, open hem dan in Home Assistant, controleer of hij draait en probeer het opnieuw.';

  @override
  String get setupErrHaNoZ2mAction => 'Opnieuw proberen';

  @override
  String get setupErrScanFailedTitle => 'Geen lokaal netwerk';

  @override
  String get setupErrScanFailedBody =>
      'Het lokale netwerk van dit apparaat kon niet worden bepaald. Verbind met wifi en probeer het opnieuw.';

  @override
  String get setupErrScanFailedAction => 'Opnieuw proberen';

  @override
  String get setupNoWifiTitle => 'Je telefoon zit niet op wifi';

  @override
  String get setupNoWifiMobileData =>
      'Hij gebruikt mobiele data en ziet daardoor de apparaten thuis niet. Zet wifi aan en maak verbinding met je thuisnetwerk: de installatie start dan vanzelf opnieuw.';

  @override
  String get setupNoWifiOffline =>
      'Je telefoon heeft geen netwerkverbinding. Zet wifi aan en maak verbinding met je thuisnetwerk: de installatie start dan vanzelf opnieuw.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash vindt het wifi-adres van je telefoon niet. Controleer of wifi aan staat en verbonden is met je thuisnetwerk: de installatie start dan vanzelf opnieuw. Via vpn of niet thuis? Vul de gegevens handmatig in.';

  @override
  String get setupOpenWifiSettings => 'Wifi-instellingen openen';

  @override
  String get setupWaitingForWifi => 'Wachten op wifi…';

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

  @override
  String get setupErrLoginNoAnswerTitle =>
      'De broker antwoordde niet op de aanmelding';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Je broker is gevonden, maar antwoordde niet op tijd op de gebruikersnaam en het wachtwoord. De Mosquitto-add-on van Home Assistant controleert aanmeldingen via Home Assistant, en dat kan op een Raspberry Pi een paar seconden duren. Probeer het opnieuw en controleer of deze gebruiker in Home Assistant bestaat.';

  @override
  String get setupErrLoginNoAnswerAction => 'Opnieuw proberen';

  @override
  String get setupNoZ2mTitle =>
      'Je broker werkt, maar Zigbee2MQTT publiceert hier niet';

  @override
  String setupNoZ2mBody(String base) {
    return 'We luisterden op $base/bridge en hoorden niets.';
  }

  @override
  String get setupBaseTopicQuestion => 'Een ander basistopic?';

  @override
  String get setupGuidesTitle => 'Zigbee2MQTT instellen';

  @override
  String get setupTryDemoMeanwhile => 'Probeer intussen de demo';

  @override
  String get setupPlatformQuestion =>
      'Terwijl we zoeken: waar draait Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => 'Waar draait Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Kies een verbinding';

  @override
  String get setupScanDoneHint =>
      'Meer dan één broker antwoordde. Kies degene die Zigbee2MQTT gebruikt.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'SMLIGHT-hub';

  @override
  String get setupPlatformPi => 'Raspberry Pi of Docker';

  @override
  String get setupPlatformZha => 'ZHA, geen Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash toont apparaten uit Zigbee2MQTT en ziet dus geen apparaten in ZHA, de eigen Zigbee van Home Assistant. Probeer het demohuis om te zien hoe ZigDash werkt.';

  @override
  String get setupPlatformNotSure => 'Weet ik niet';

  @override
  String setupScanProgress(int checked, int total) {
    return '$checked van $total adressen gecontroleerd';
  }

  @override
  String get setupScanHintHa =>
      'Zoeken naar Home Assistant en zijn MQTT-broker…';

  @override
  String get setupScanHintSmlight => 'Zoeken naar je SMLIGHT-hub…';

  @override
  String get setupScanHintPi => 'Zoeken naar een MQTT-broker in je netwerk…';

  @override
  String setupHubSeenHa(String host) {
    return 'Home Assistant gevonden op $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Zigbee2MQTT gevonden op $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Je SMLIGHT-hub gevonden op $host';
  }

  @override
  String get setupHubSeenHint => 'Nog op zoek naar zijn MQTT-broker…';

  @override
  String get setupNoBrokerHaTitle =>
      'Home Assistant gevonden, maar geen MQTT-broker';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant staat op $host, maar niets antwoordt op MQTT-poort 1883. Open in Home Assistant Instellingen › Add-ons, installeer en start de Mosquitto broker-add-on en probeer het opnieuw.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Gebruik je de ingebouwde Zigbee van Home Assistant (ZHA) in plaats van Zigbee2MQTT? ZigDash werkt alleen met Zigbee2MQTT en ziet ZHA-apparaten dus niet. De demo laat zien wat je zou krijgen.';

  @override
  String get setupVpnHint =>
      'Er staat een VPN aan, en die kan je thuisnetwerk voor de scan verbergen. Ben je thuis, zet de VPN dan uit en tik op Opnieuw proberen. Of laat hem aan en sta in de instellingen van de VPN-app toegang tot het lokale netwerk (LAN) toe.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Zigbee2MQTT gevonden, maar zijn broker is niet bereikbaar';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT staat op $host, maar zijn MQTT-broker accepteert geen verbindingen van je telefoon. Mosquitto 2 luistert alleen op de hub zelf totdat de configuratie \'listener 1883\' en \'allow_anonymous true\' (of een login) bevat. Herstart hem en probeer het opnieuw.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'SMLIGHT-hub gevonden, maar MQTT staat uit';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Je hub staat op $host, maar zijn MQTT-broker is niet bereikbaar. Open in de webinterface van de hub Settings › MQTT, zet Allow External aan en controleer of Zigbee2MQTT draait. Probeer het daarna opnieuw.';
  }

  @override
  String get setupZ2mAsking => 'Zigbee2MQTT vragen waar zijn broker is…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Je broker accepteert alleen verbindingen van zijn eigen machine';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT gebruikt $server, en vanaf je telefoon antwoordt daar niets. Mosquitto 2 doet dit standaard. Voeg deze twee regels toe aan mosquitto.conf, herstart Mosquitto en probeer het opnieuw:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Liever een login dan open toegang? Gebruik een password_file in plaats van allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT bereikt zijn broker via een naam die je telefoon niet kan gebruiken';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT gebruikt $server. \"$name\" is een naam die alleen de machine van Zigbee2MQTT kent, een Docker-service of een hostnaam. Typ in plaats daarvan het IP-adres van de broker-machine met poort $port. Draait de broker in een container, dan moet zijn poort ook op de machine gepubliceerd zijn (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'De webpagina van Zigbee2MQTT is beveiligd met een token, dus de app kon niet lezen waar zijn broker is. Typ het broker-adres uit Zigbee2MQTT › Settings › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT gebruikt de broker op $server, maar die antwoordde je telefoon niet. Controleer of de broker draait en je telefoon op hetzelfde netwerk zit.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Verbinden met $host';
  }

  @override
  String get setupNotFoundHa =>
      'Geen Home Assistant gevonden op dit netwerk. Controleer of je telefoon op dezelfde wifi zit als Home Assistant (geen gastnetwerk) en probeer het opnieuw. Ken je het adres, vul het dan hieronder in.';

  @override
  String get setupNotFoundSmlight =>
      'Geen SMLIGHT-hub gevonden op dit netwerk. Controleer of de hub aanstaat en je telefoon op dezelfde wifi zit, en probeer het opnieuw. Ken je het adres, vul het dan hieronder in.';

  @override
  String get setupNotFoundPi =>
      'Geen MQTT-broker gevonden in dit netwerk. Controleer of Mosquitto draait en op het netwerk luistert (poort 1883) en of je telefoon op dezelfde wifi zit. Probeer het daarna opnieuw.';

  @override
  String get setupAddressQuestionHa => 'Waar open je Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'Wat is het adres van je SMLIGHT-hub?';

  @override
  String get setupAddressQuestionPi =>
      'Wat is het adres van de machine waarop Mosquitto draait?';

  @override
  String get setupAddressQuestionAny =>
      'Wat is het adres van je hub, of van de machine waarop Zigbee2MQTT draait?';

  @override
  String get setupAddressHint =>
      'Een adres zoals 192.168.1.20, een naam of de link uit je browser';

  @override
  String get setupAddressCheck => 'Dit adres controleren';

  @override
  String setupAddressNothing(String host) {
    return 'Niets antwoordde op $host. Controleer het adres, en of je telefoon op dezelfde wifi zit.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return '$host kon niet worden opgezocht. Namen die eindigen op .local werken op Android vaak niet; probeer het IP-adres. Home Assistant toont het onder Instellingen › Systeem › Netwerk.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host is vanaf deze telefoon niet te vinden; Android kan .local-namen vaak niet opzoeken. Tik hierboven op $button en gebruik het adres waarmee je Home Assistant in de browser opent, of typ hier het IP-adres. Home Assistant toont het onder Instellingen › Systeem › Netwerk.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host zit niet op je thuisnetwerk. Gebruik het adres dat op je wifi werkt, geen externe link zoals Nabu Casa of DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Vul eerst een adres in.';

  @override
  String get setupChoicesTitle => 'Welke past bij jou?';

  @override
  String get setupChoiceNoHub => 'Ik heb nog geen hub';

  @override
  String get setupChoiceNoHubSub =>
      'Bekijk kleine hubs waarop Zigbee2MQTT draait';

  @override
  String get setupChoiceHa => 'Ik gebruik Home Assistant';

  @override
  String get setupChoiceHaSub => 'Zoek op homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash maakt verbinding met de MQTT-broker van Home Assistant, de Mosquitto broker-add-on onder Instellingen › Add-ons, en Zigbee2MQTT moet die ook gebruiken. Wordt homeassistant.local niet gevonden, vul dan hieronder het IP-adres van Home Assistant in. Dat staat onder Instellingen › Systeem › Netwerk.';

  @override
  String get setupChoiceOther => 'Mijn hub zit op een ander netwerk';

  @override
  String get setupChoiceOtherSub => 'Een gastnetwerk of een tweede router';

  @override
  String get setupChoiceOtherNote =>
      'Je telefoon moet je hub kunnen bereiken. Een gastnetwerk, of een tweede router met eigen wifi, houdt ze gescheiden. Verbind met de wifi waarop je hub zit en tik op Opnieuw proberen. Of vul hieronder het IP-adres van de hub in, of probeer een van deze gebruikelijke namen:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Je telefoon is $ip, dus de hub begint meestal met $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Gebruik je Home Assistant? De host is het adres waarmee je Home Assistant opent, poort 1883.';

  @override
  String get demoBannerText => 'Je zit in demomodus';

  @override
  String get demoBannerAction => 'Verbind je huis';

  @override
  String get deviceOn => 'Aan';

  @override
  String get deviceOff => 'Uit';

  @override
  String get deviceOpen => 'Open';

  @override
  String get deviceClosed => 'Dicht';

  @override
  String get deviceMotion => 'Beweging';

  @override
  String get deviceClear => 'Rustig';

  @override
  String get deviceLeakDetected => 'Lek gedetecteerd';

  @override
  String get deviceSmokeDetected => 'Rook gedetecteerd';

  @override
  String get deviceGasDetected => 'Gas gedetecteerd';

  @override
  String get deviceWaiting => 'Wacht op eerste melding';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on aan · $off uit';
  }

  @override
  String get deviceBrightness => 'Helderheid';

  @override
  String get deviceWhite => 'Wit';

  @override
  String get deviceColor => 'Kleur';

  @override
  String get deviceHue => 'Tint';

  @override
  String get devicePosition => 'Positie';

  @override
  String get deviceControls => 'Bediening';

  @override
  String deviceBattery(int percent) {
    return 'Batterij $percent%';
  }

  @override
  String get deviceToggle => 'Aan- of uitzetten';

  @override
  String get deviceMore => 'Meer';

  @override
  String get sectionLights => 'Verlichting';

  @override
  String get sectionSwitchesCovers => 'Schakelaars en rolluiken';

  @override
  String get sectionSensors => 'Sensoren';

  @override
  String get sectionOther => 'Overig';

  @override
  String get homeFirstName => 'Mijn huis';

  @override
  String homeNumberedName(int number) {
    return 'Huis $number';
  }

  @override
  String get dashAddTile => 'Tegel toevoegen';

  @override
  String get addTileSearch => 'Apparaten zoeken';

  @override
  String get addTileNotOnDashboard => 'Op geen dashboard';

  @override
  String get addTileAllDevices => 'Alle apparaten';

  @override
  String get addTileReading => 'Meetwaarde';

  @override
  String get addTileReadingSubtitle => 'Eén waarde van een apparaat of topic';

  @override
  String get readingShowAs => 'Weergeven als';

  @override
  String get readingStyleValue => 'Waarde';

  @override
  String get readingStyleGauge => 'Meter';

  @override
  String get gaugeBands => 'Kleurzones';

  @override
  String get gaugeBandsHelper =>
      'Maximaal drie. De zone waarin de waarde valt, kleurt de boog.';

  @override
  String get gaugeBandFrom => 'Van';

  @override
  String get gaugeBandTo => 'Tot';

  @override
  String get gaugeBandAdd => 'Zone toevoegen';

  @override
  String get gaugeBandRemove => 'Zone verwijderen';

  @override
  String get gaugeToneNormal => 'Normaal';

  @override
  String get gaugeToneGood => 'Goed';

  @override
  String get gaugeToneAttention => 'Let op';

  @override
  String get addTileCustom => 'Eigen MQTT-tegel';

  @override
  String get addTileCustomSubtitle => 'Elk tegeltype, ingesteld via topic';

  @override
  String get addTileNoDevices =>
      'Geen apparaten. Verbind met je broker of koppel een apparaat in Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Toevoegen';

  @override
  String get addTileName => 'Naam';

  @override
  String addTileNameHint(String model) {
    return 'bijv. $model';
  }

  @override
  String get addTileSection => 'Sectie';

  @override
  String get addTileNoSection => 'Geen sectie';

  @override
  String get addTileSize => 'Grootte';

  @override
  String get deviceClassColorLight => 'Kleurenlamp';

  @override
  String get deviceClassLight => 'Lamp';

  @override
  String get deviceClassSwitch => 'Schakelaar of stekker';

  @override
  String get deviceClassCover => 'Rolluik';

  @override
  String get deviceClassLeak => 'Lek of rook';

  @override
  String get deviceClassContact => 'Contact';

  @override
  String get deviceClassMotion => 'Beweging';

  @override
  String get deviceClassClimate => 'Klimaatsensor';

  @override
  String get deviceClassGeneric => 'Apparaat';

  @override
  String get deviceNotResponding => 'Reageert niet';

  @override
  String get homeAdd => 'Huis toevoegen';

  @override
  String get homeManage => 'Huizen beheren';

  @override
  String get homeSwitch => 'Ander huis';

  @override
  String get navDevices => 'Apparaten';

  @override
  String get navScenes => 'Scènes';

  @override
  String get devicesNewDot => 'Nieuwe apparaten';

  @override
  String get editEditing => 'Bewerken';

  @override
  String get editDashboard => 'Dashboard';

  @override
  String get editDone => 'Klaar';

  @override
  String get editAddSection => 'Sectie toevoegen';

  @override
  String get editSectionName => 'Naam van sectie';

  @override
  String get editRenameSection => 'Sectie hernoemen';

  @override
  String get editDeleteSection => 'Sectie verwijderen';

  @override
  String get editDeleteSectionBody => 'Wat moet er met de tegels gebeuren?';

  @override
  String get editKeepTiles => 'Tegels houden, sectie weghalen';

  @override
  String get editDeleteTiles => 'Tegels ook verwijderen';

  @override
  String get editMoveToSection => 'Naar sectie verplaatsen';

  @override
  String get editEditTile => 'Tegel bewerken';

  @override
  String get editRemove => 'Van dashboard verwijderen';

  @override
  String get editRemoved => 'Tegel verwijderd';

  @override
  String get editUndo => 'Ongedaan maken';

  @override
  String get editReplaceWithDevice => 'Vervangen door apparaattegel';

  @override
  String get editMoveEarlier => 'Naar voren';

  @override
  String get editMoveLater => 'Naar achteren';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apparaten staan op geen dashboard',
      one: '1 apparaat staat op geen dashboard',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Tegelopties';

  @override
  String get editSave => 'Opslaan';

  @override
  String get editCancel => 'Annuleren';

  @override
  String get ageJustNow => 'Zojuist';

  @override
  String ageMinutes(int n) {
    return '$n min geleden';
  }

  @override
  String ageHours(int n) {
    return '$n u geleden';
  }

  @override
  String get statusCantReach => 'Broker niet bereikbaar';

  @override
  String get statusWhy => 'Waarom?';

  @override
  String get statusWhyTitle => 'Je broker reageert niet';

  @override
  String get statusWhyBody =>
      'ZigDash blijft het zelf proberen. Tot die tijd tonen tegels hun laatst bekende waarden, gedimd en met hun leeftijd. Controleer of de broker aan staat en deze telefoon op hetzelfde netwerk zit, of test de verbinding in de instellingen.';

  @override
  String get statusSettings => 'Verbindingsinstellingen';

  @override
  String get deviceAddToDashboard => 'Aan een dashboard toevoegen';

  @override
  String get deviceDismiss => 'Negeren';

  @override
  String get devicesFilterAll => 'Alle';

  @override
  String devicesFilterAttention(int count) {
    return 'Aandacht nodig · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Op geen dashboard · $count';
  }

  @override
  String get devicesNoMatch => 'Geen apparaten gevonden';

  @override
  String get deviceBatteryLow => 'Batterij bijna leeg';

  @override
  String get deviceLinkWeak => 'Zwak';

  @override
  String get deviceUnsupported => 'Niet ondersteund door Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'Koppelen niet voltooid';

  @override
  String get deviceNoReport => 'Nog geen melding';

  @override
  String get devicesAvailabilityOff =>
      'Beschikbaarheid staat uit in Zigbee2MQTT, dus offline apparaten tonen als Reageert niet.';

  @override
  String get devicesAvailabilityHow => 'Zo zet je het aan';

  @override
  String get devicesDotBattery => 'Batterij bijna leeg';

  @override
  String get deviceDetails => 'Apparaatdetails';

  @override
  String get deviceGone => 'Dit apparaat staat niet meer in Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Bediening';

  @override
  String get deviceReadingsTitle => 'Meetwaarden';

  @override
  String get deviceHealthTitle => 'Gezondheid';

  @override
  String get deviceOnDashboards => 'Op dashboards';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT ondersteunt dit apparaat nog niet, dus er valt niets te bedienen.';

  @override
  String get deviceAddReadingTile => 'Toevoegen als meetwaardetegel';

  @override
  String get deviceAddReadingTo => 'Aan welk dashboard toevoegen?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Toegevoegd aan $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Verbindingskwaliteit';

  @override
  String get deviceLinkGood => 'Goed';

  @override
  String get devicePowerSource => 'Voeding';

  @override
  String get devicePowerBattery => 'Batterij';

  @override
  String get devicePowerMains => 'Netstroom';

  @override
  String get deviceLastHeard => 'Laatst gehoord';

  @override
  String get deviceAvailability => 'Beschikbaarheid';

  @override
  String get deviceAvailabilityOff => 'Uit in Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Privacybeleid';

  @override
  String get settingsPrivacySubtitle =>
      'Geen telemetrie. Alles blijft op deze telefoon.';

  @override
  String get homeCurrent => 'Huidig huis';

  @override
  String get homeConnection => 'Verbinding';

  @override
  String get homeSwitchTo => 'Naar dit huis wisselen';

  @override
  String get homeDelete => 'Huis verwijderen';

  @override
  String get devicesSelect => 'Kies een apparaat';

  @override
  String get scenesSelect => 'Kies een scène om te bewerken';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'Apparaat kiezen';

  @override
  String get panelFormStateTopic => 'Status-topic';

  @override
  String get panelFormCommandTopic => 'Commando-topic';

  @override
  String get panelFormCommandTopicDerived =>
      'Overgenomen van het status-topic totdat je het wijzigt.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Gekoppeld aan $device';
  }

  @override
  String get panelFormOpenDevice => 'Apparaat openen';

  @override
  String get panelFormUnlink => 'Ontkoppelen';

  @override
  String get panelFormValueChoices => 'Waarden van dit apparaat';

  @override
  String get panelFormAdvanced => 'Geavanceerd';

  @override
  String get panelFormAdvancedSubtitle => 'Prefix overschrijven, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Leeg = het voorvoegsel zelf (status van een Zigbee2MQTT-apparaat).';

  @override
  String get dashWallDisplay => 'Wandweergave';

  @override
  String get analyticsSetupCheckbox =>
      'Anonieme gebruiksgegevens delen om de installatie te verbeteren';

  @override
  String get analyticsWhatsShared => 'Wat wordt gedeeld';

  @override
  String get analyticsCardTitle => 'ZigDash helpen verbeteren?';

  @override
  String get analyticsCardBody =>
      'Anonieme gebruiksgegevens delen: welke installatiestappen mislukken en welke functies worden gebruikt. Nooit je apparaten, topics of broker.';

  @override
  String get analyticsShare => 'Delen';

  @override
  String get analyticsNoThanks => 'Nee, bedankt';

  @override
  String get settingsAnalytics => 'Anonieme gebruiksgegevens delen';

  @override
  String get settingsAnalyticsSubtitle =>
      'Installatiestappen en gebruikte functies. Nooit je apparaten, topics of broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Anonieme gebruiksgegevens. Zet ze uit met de schakelaar hierboven.';

  @override
  String get dashDefaultName => 'Thuis';

  @override
  String get dashExportSaveFile => 'Bestand opslaan';

  @override
  String get dashExportSaved => 'Back-up opgeslagen';

  @override
  String get dashImportChooseFile => 'Bestand kiezen';

  @override
  String get dashImportFileUnreadable => 'Dat bestand kon niet worden gelezen';

  @override
  String get getHelpTitle => 'Hulp krijgen';

  @override
  String get getHelpTryFirst => 'Probeer eerst dit';

  @override
  String get getHelpPromise =>
      'Kom je er nog steeds niet uit? Ik antwoord meestal binnen 3 dagen, in het Engels of het Hebreeuws. Ik vraag nooit om je wachtwoorden.';

  @override
  String get getHelpIncluded => 'Wat er wordt meegestuurd';

  @override
  String get getHelpContact => 'Contact met support';

  @override
  String get getHelpCopy => 'Gegevens kopiëren';

  @override
  String get getHelpCopied => 'Gegevens gekopieerd';

  @override
  String get getHelpLink => 'Kom je er niet uit? Hulp krijgen';

  @override
  String get getHelpEmailSubject => 'ZigDash: hulp om het werkend te krijgen';

  @override
  String get getHelpEmailPrompt =>
      'Wat probeerde je te doen, en wat gebeurde er?';

  @override
  String get settingsHelpSupport => 'Help & support';

  @override
  String get settingsGetHelp => 'Hulp krijgen';

  @override
  String get settingsGetHelpSubtitle =>
      'Lukt het niet? Eerst tips, dan contact';

  @override
  String get settingsCommunity => 'Word lid van de ZigDash-community';

  @override
  String get settingsCommunitySubtitle =>
      'Telegram-groep: vragen, ideeën en wat eraan komt';

  @override
  String get getHelpCommunity => 'Vraag het in de Telegram-groep';

  @override
  String get demoBannerHelp => 'Hulp krijgen';

  @override
  String get tipSameWifiTitle => 'Zelfde wifi als je hub';

  @override
  String get tipSameWifiBody =>
      'Je telefoon moet op hetzelfde netwerk zitten als de hub, niet op een gastnetwerk. Zet mobiele data uit tijdens het instellen.';

  @override
  String get tipBrokerRunningTitle => 'De broker draait';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: de Mosquitto-add-on is gestart. Raspberry Pi: Mosquitto draait. SMLIGHT: Settings › MQTT staat aan.';

  @override
  String get tipBrokerAcceptsTitle => 'De broker laat je telefoon toe';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: zet Allow External aan. Mosquitto 2 accepteert alleen verbindingen van de hub zelf, totdat het is ingesteld om op het netwerk te luisteren (poort 1883).';

  @override
  String get tipMeshTitle => 'Mesh-wifi of twee routers?';

  @override
  String get tipMeshBody =>
      'Hangt de hub aan een tweede router, dan ziet je telefoon hem misschien niet. Sluit de hub aan op de hoofdrouter, of verbind via zijn adres.';

  @override
  String get tipByAddressTitle => 'Verbinden via adres';

  @override
  String get tipByAddressBody =>
      'Zoek het adres van de hub op in de app van je router en tik dan op „Gegevens handmatig invoeren”.';

  @override
  String get tipSameNetworkTitle => 'Zelfde netwerk';

  @override
  String get tipSameNetworkBody =>
      'Telefoon en hub moeten op dezelfde wifi zitten. Zet mobiele data uit.';

  @override
  String get tipAddressChangedTitle => 'Het adres is veranderd';

  @override
  String get tipAddressChangedBody =>
      'Hubs kunnen na een herstart een nieuw adres krijgen. Controleer het in de app van je router en reserveer het daar, zodat het hetzelfde blijft.';

  @override
  String get tipRightPortTitle => 'De juiste poort';

  @override
  String get tipRightPortBody =>
      'MQTT is meestal 1883 (8883 met TLS). 8080 of 80 is de webinterface van de hub, niet MQTT.';

  @override
  String get tipStartBrokerTitle => 'De broker draait';

  @override
  String get tipStartBrokerBody =>
      'Start Mosquitto of de broker-add-on en probeer het opnieuw.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 accepteert alleen verbindingen van de hub zelf, totdat het is ingesteld om op het netwerk te luisteren (poort 1883).';

  @override
  String get tipMqttLoginTitle => 'De MQTT-login, niet de weblogin';

  @override
  String get tipMqttLoginBody =>
      'Het wachtwoord van de webinterface van je hub is meestal niet dat van MQTT. Home Assistant: gebruik een Home Assistant-gebruiker, of de login uit de Mosquitto-add-on.';

  @override
  String get tipSpacesTitle => 'Let op spaties';

  @override
  String get tipSpacesBody =>
      'Bij het kopiëren van een wachtwoord kan er een spatie aan het eind bij komen.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT gebruikt deze broker';

  @override
  String get tipZ2mBrokerBody =>
      'Controleer in de instellingen van Zigbee2MQTT dat de MQTT-server deze zelfde broker is.';

  @override
  String get tipBaseTopicTitle => 'Basis-topic';

  @override
  String get tipBaseTopicBody =>
      'Heb je het basis-topic „zigbee2mqtt” gewijzigd, vul het dan in bij handmatig instellen.';

  @override
  String get tipPairFirstTitle => 'Eerst apparaten koppelen';

  @override
  String get tipPairFirstBody =>
      'Open de webinterface van Zigbee2MQTT, koppel minstens één apparaat en controleer het daarna opnieuw.';

  @override
  String get tipRestartZ2mTitle => 'Zigbee2MQTT opnieuw starten';

  @override
  String get tipRestartZ2mBody =>
      'Zijn er apparaten gekoppeld maar komt er geen binnen, start Zigbee2MQTT dan opnieuw zodat het zijn apparatenlijst publiceert.';

  @override
  String get tipNumberAddressTitle => 'Gebruik het cijferadres';

  @override
  String get tipNumberAddressBody =>
      'Namen die eindigen op .local werken niet op elke Android-telefoon. Probeer het cijferadres van de hub, zoals 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Poort en protocol';

  @override
  String get tipPortProtocolBody =>
      'TCP op 1883 is gebruikelijk. Kies TLS of WebSocket alleen als je broker daarvoor is ingesteld.';

  @override
  String get tipManualLoginTitle => 'Login';

  @override
  String get tipManualLoginBody =>
      'Laat gebruikersnaam en wachtwoord leeg als je broker er geen heeft. Gebruik anders de MQTT-login, niet de weblogin van de hub.';

  @override
  String get tipHubOnTitle => 'Staat de hub aan?';

  @override
  String get tipHubOnBody =>
      'Een stroomstoring of update kan hem opnieuw hebben gestart. Geef hem een minuut als hij weer aan is.';

  @override
  String get tipAwayTitle => 'Ben je thuis?';

  @override
  String get tipAwayBody =>
      'Buitenshuis heeft de app een extern adres nodig (bijvoorbeeld Tailscale). Stel het in bij de verbindingsinstellingen van het huis.';

  @override
  String get tipTailscaleIpTitle => 'Gebruik het Tailscale-IP, niet de naam';

  @override
  String get tipTailscaleIpBody =>
      'Namen die eindigen op .ts.net worden in apps vaak niet opgelost. Open de Tailscale-app op de telefoon en controleer dat die verbonden is. Gebruik dan het 100.x.y.z-adres van de hub als externe host.';

  @override
  String get tipHomeAddressChangedTitle => 'Is het adres veranderd?';

  @override
  String get tipHomeAddressChangedBody =>
      'Na een herstart van de router kan de hub een nieuw adres krijgen. Reserveer zijn adres in de app van je router en werk daarna het huis bij.';

  @override
  String get tipRestartZ2mButtonTitle => 'Zigbee2MQTT opnieuw starten';

  @override
  String get tipRestartZ2mButtonBody =>
      'Als de broker opnieuw is gestart, is de apparatenlijst van Zigbee2MQTT weg totdat Zigbee2MQTT opnieuw start. Gebruik de knop „Zigbee2MQTT opnieuw starten” op het tabblad Apparaten.';

  @override
  String get tipZ2mRunningTitle => 'Draait Zigbee2MQTT?';

  @override
  String get tipZ2mRunningBody =>
      'Open de webinterface. Laadt die niet, start het dan opnieuw op je hub.';

  @override
  String get tipCantConnectTitle => 'Geen verbinding met mijn hub';

  @override
  String get tipCantConnectBody =>
      'Zelfde wifi, broker draait, Allow External aan of Mosquitto luistert op het netwerk, en dan verbinden via het adres.';

  @override
  String get tipDeviceWrongTitle =>
      'Een apparaat toont iets verkeerds of reageert niet';

  @override
  String get tipDeviceWrongBody =>
      'Controleer het eerst in de webinterface van Zigbee2MQTT. Werkt het daar wel, gebruik dan „Probleem melden”.';

  @override
  String get tipHowDoITitle => 'Hoe doe ik…';

  @override
  String get tipHowDoIBody =>
      'Scènes, Wandweergave, schema\'s en back-ups staan in „Help & Handleiding”.';

  @override
  String get tipRenameHomeTitle => 'Een huis hernoemen';

  @override
  String get tipRenameHomeBody =>
      'Een huis dat naar zijn adres heet? Instellingen › Huizen, tik op het huis en dan op Naam.';

  @override
  String get tipWhatYouNeedTitle => 'Wat je nodig hebt';

  @override
  String get tipWhatYouNeedBody =>
      'Een kleine hub met Zigbee2MQTT en een MQTT-broker (Mosquitto): een SMLIGHT-hub, een Raspberry Pi of elke Linux-machine. Home Assistant kan ook, maar is niet nodig.';

  @override
  String get tipSetupAtHomeTitle => 'Op dezelfde wifi';

  @override
  String get tipSetupAtHomeBody =>
      'Stel alles thuis in, met je telefoon op dezelfde wifi als de hub.';

  @override
  String get tipFindSetupTitle => 'Daarna';

  @override
  String get tipFindSetupBody =>
      'Verlaat de demo en tik op „Vind mijn installatie”. ZigDash zoekt je hub zelf.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Geen e-mailapp gevonden. Kopieer de gegevens en mail naar $email.';
  }

  @override
  String get shortcutWorking => 'bezig…';

  @override
  String get shortcutCantReach => 'Huis niet bereikbaar';

  @override
  String get shortcutNotConfirmed => 'Niet bevestigd';

  @override
  String get shortcutRemoved => 'Verwijderd';

  @override
  String get shortcutSceneSent => 'Verstuurd';

  @override
  String get shortcutSceneConfirmed => 'Bevestigd';

  @override
  String get shortcutChooseDevice => 'Kies een apparaat';

  @override
  String get shortcutChooseScene => 'Kies een scène';

  @override
  String get shortcutOpenAppFirstScene =>
      'Open ZigDash en maak eerst een scène.';

  @override
  String get shortcutChooseGroup => 'Kies een groep';

  @override
  String get shortcutPickDevices => 'Apparaten kiezen…';

  @override
  String get shortcutGroupName => 'Groepsnaam';

  @override
  String get shortcutGroupLimit => 'Tot 5 apparaten en 3 scènes';

  @override
  String get shortcutAddTile => 'Toevoegen aan Snelle instellingen';

  @override
  String get shortcutAddShortcut => 'Snelkoppeling toevoegen';

  @override
  String get shortcutAddToHome => 'Toevoegen aan startscherm';

  @override
  String get shortcutWidgetHowToTitle => 'Widget toevoegen';

  @override
  String get shortcutWidgetHowTo =>
      'Houd een lege plek op je startscherm ingedrukt, tik op Widgets, zoek ZigDash en sleep de widget die je wilt.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name staat op tegel ZigDash $slot in Snelle instellingen';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name staat al op tegel ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Tegel toevoegen';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Open Snelle instellingen (twee keer omlaag vegen), tik op het potlood om te bewerken en sleep „ZigDash $slot” naar je tegels.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Kies een apparaat voor ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Nog geen apparaten om te schakelen. Zet eerst een lamp, stekker of rolluik op een dashboard.';

  @override
  String get shortcutSlotsFull =>
      'Alle 4 ZigDash-tegels zijn in gebruik. Welke moet dit apparaat in plaats daarvan tonen?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Niet in gebruik';

  @override
  String get deviceRename => 'Naam wijzigen';

  @override
  String get deviceRenameTitle => 'Apparaat hernoemen';

  @override
  String get deviceRenameHint =>
      'Een naam voor de kamer of het apparaat, zoals Slaapkamer';

  @override
  String deviceRenamed(Object name) {
    return 'Hernoemd naar $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Hernoemen mislukt: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT gaf geen antwoord';

  @override
  String get shortcutOpenAppFirst =>
      'Open ZigDash en zet eerst een apparaat op een dashboard.';

  @override
  String get pollTitle => 'Wat moet ZigDash hierna doen?';

  @override
  String get pollBody =>
      'Kies wat je het meest zou gebruiken. Je antwoord wordt met je anonieme gebruiksgegevens verstuurd.';

  @override
  String get pollNotifications => 'Meldingen';

  @override
  String get pollHistory => 'Geschiedenisgrafieken';

  @override
  String get pollKiosk => 'Kioskmodus voor een wandtablet';

  @override
  String get pollGroups => 'Zigbee-groepen';

  @override
  String get pollNotNow => 'Niet nu';

  @override
  String get pollThanks => 'Bedankt! Dat helpt kiezen wat er komt.';

  @override
  String get whyTitle => 'Waarom heb je ZigDash geprobeerd?';

  @override
  String get whyBody =>
      'Eén tik helpt kiezen wat we bouwen. Je antwoord wordt met je anonieme gebruiksgegevens verstuurd.';

  @override
  String get whyFaster => 'Sneller dan mijn andere app';

  @override
  String get whyFamily => 'Makkelijk voor het gezin';

  @override
  String get whyWallTablet => 'Een tablet aan de muur';

  @override
  String get whyWithoutHa => 'Werkt zonder Home Assistant';

  @override
  String get whyOther => 'Iets anders';

  @override
  String get whyThanks => 'Bedankt voor je antwoord!';

  @override
  String get pollNoAnalytics =>
      'Gebruiksgegevens staan uit, dus van hier wordt niets verstuurd. Laat het ons weten via Functie aanvragen.';

  @override
  String alertLeak(Object name) {
    return '💧 Lek — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name is weer droog';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Rook — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Geen rook meer bij $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name geopend';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Batterij bijna leeg — $name, $value%';
  }

  @override
  String get alertTest => 'ZigDash-testmelding';

  @override
  String get alertsChannel => 'Alarmen';

  @override
  String get alertsChannelDescription => 'Lekken en rook';

  @override
  String get noticesChannel => 'Berichten';

  @override
  String get noticesChannelDescription => 'Deuren, ramen en batterijen';

  @override
  String get alertsTitle => 'Alarmen';

  @override
  String get alertsStatusOn => 'Alarmen staan aan';

  @override
  String get alertsStatusPaused =>
      'Meldingen gepauzeerd: ZigDash Engine op je hub meldt zich niet';

  @override
  String get alertsStatusNotSetUp => 'Niet ingesteld';

  @override
  String get alertsStatusPhoneOff => 'Deze telefoon krijgt geen meldingen';

  @override
  String get alertsIntro =>
      'Krijg een melding op deze telefoon bij een lek, rook, een geopende deur of een lege batterij, ook als ZigDash dicht is. ZigDash Engine op je hub let op de apparaten; ZigDash stelt het in.';

  @override
  String get alertsSetUpHub => 'Alarmen instellen op de hub';

  @override
  String get alertsHubInstalled => 'Meldingen zijn ingesteld op je hub';

  @override
  String get alertsHubUpdated => 'De alarmflow op de hub is bijgewerkt';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED vraagt om in te loggen, importeer de flow daarom handmatig:';

  @override
  String get alertsHubManualSteps =>
      'Open Node-RED op de hub, kies Importeren, plak de gekopieerde flow, kies je broker in de broker-node en klik op Deploy.';

  @override
  String get alertsCopyFlow => 'Flow kopiëren';

  @override
  String get alertsFlowCopied => 'Flow gekopieerd';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Alarmen hebben Node-RED op de hub nodig, en niets antwoordt op poort 1880 van $host. Op een SMLIGHT SMHUB installeer je het onder Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT nam ZigDash Engine niet aan';

  @override
  String get alertsRecent => 'Recente alarmen';

  @override
  String get alertsRecentNone => 'Nog niets';

  @override
  String get alertsYourAlerts => 'Je alarmen';

  @override
  String get alertsAdd => 'Alarm toevoegen';

  @override
  String get alertsNotificationsOnThisPhone => 'Meldingen op deze telefoon';

  @override
  String get alertsNoGoogle =>
      'Deze telefoon heeft geen Google-diensten, dus ZigDash kan hier geen pushes ontvangen.';

  @override
  String get alertsSendTest => 'Testmelding sturen';

  @override
  String get alertsTestSent => 'Test verstuurd. Hij zou nu moeten aankomen.';

  @override
  String alertsTestFailed(Object status) {
    return 'De hub kon hem niet sturen ($status)';
  }

  @override
  String get alertsTestTimedOut =>
      'Geen antwoord van de hub. Draait de alarmflow?';

  @override
  String get alertsNotConnected => 'Niet verbonden met de hub';

  @override
  String get alertsTurnOff => 'Alarmen uitzetten';

  @override
  String get alertsTurnOffBody =>
      'Alarmen stoppen voor elke telefoon van dit huis.';

  @override
  String get alertKindLeak => 'Lek';

  @override
  String get alertKindSmoke => 'Rook';

  @override
  String get alertKindOpened => 'Deur of raam geopend';

  @override
  String get alertKindBattery => 'Batterij bijna leeg';

  @override
  String get alertsEditTitle => 'Alarm';

  @override
  String get alertsKind => 'Wat';

  @override
  String get alertsDevices => 'Apparaten';

  @override
  String get alertsNoDevicesForKind => 'Geen apparaat van dit huis meldt dat.';

  @override
  String get alertsHours => 'Alleen tussen';

  @override
  String get alertsHoursAny => 'Altijd';

  @override
  String get alertsHoursFrom => 'Van';

  @override
  String get alertsHoursTo => 'Tot';

  @override
  String get alertsThreshold => 'Batterij onder';

  @override
  String get alertsDelete => 'Alarm verwijderen';

  @override
  String get alertsNotifyMe => 'Waarschuw me…';

  @override
  String get alertsWhatLeaves =>
      'Alarmen naar ZigDash zijn end-to-end versleuteld: Googles pushdienst vervoert ze maar kan ze niet lezen. Verder verlaat niets je hub.';

  @override
  String get alertsRestricted =>
      'Android kan ZigDash op de achtergrond stoppen, waardoor meldingen laat of niet aankomen. Sta uitvoeren op de achtergrond toe in de Android-instellingen (op Samsung: Batterij › Apps die nooit slapen).';

  @override
  String get alertsOpenSettings => 'Android-instellingen openen';

  @override
  String get alertsOff => 'Uit';

  @override
  String get alertsSuggested => 'Voorgestelde alarmen';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apparaten',
      one: '1 apparaat',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Aanzetten';

  @override
  String get alertsShare => 'Alarmen delen';

  @override
  String get alertsShareBody =>
      'Iedereen met deze link krijgt de alarmen van dit huis in de ntfy-app, zonder ZigDash. De alarmtekst gaat onversleuteld via ntfy.sh.';

  @override
  String get alertsShareLink => 'Link';

  @override
  String get alertsShareNewLink => 'Nieuwe link';

  @override
  String get alertsShareCopied => 'Link gekopieerd';

  @override
  String get alertsShareOff => 'Stoppen met delen';

  @override
  String get alertsGetWithNtfy => 'Meldingen krijgen via ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Rook- en lekalarmen herhalen tot ze bevestigd zijn. Vereist een Pushover-account (eenmalig \$ 4,99 na een proefperiode); de sleutels blijven op je broker.';

  @override
  String get alertsPushoverUser => 'Gebruikerssleutel';

  @override
  String get alertsPushoverToken => 'App-token';

  @override
  String get alertsHideNames => 'Apparaatnamen verbergen';

  @override
  String get alertsNtfyServer => 'ntfy-server';

  @override
  String get wallSheetTitle => 'Wandweergave';

  @override
  String get wallSheetSubtitle => 'Voor een tablet aan de muur.';

  @override
  String get wallKeepOn => 'Scherm aan houden en balken verbergen';

  @override
  String get wallKeepOnSubtitle =>
      'Ze komen terug bij een aanraking en verdwijnen na 10 seconden weer.';

  @override
  String get wallFullscreen => 'Volledig scherm';

  @override
  String get wallFullscreenSubtitle =>
      'Verbergt ook de status- en navigatiebalk van Android.';

  @override
  String get wallDimAfter => 'Dimmen na';

  @override
  String get wallDimOff => 'Uit';

  @override
  String get wallIdleTitle => 'Als niemand het aanraakt';

  @override
  String get wallIdleAfter => 'Na';

  @override
  String get wallIdleNever => 'Nooit';

  @override
  String get wallIdleShow => 'Tonen';

  @override
  String get wallIdleShowDim => 'Gedimd';

  @override
  String get wallIdleShowClock => 'Klok';

  @override
  String get wallIdleShowBlack => 'Zwart';

  @override
  String get wallIdleShowReadings => 'Metingen';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Dit dashboard heeft nog geen metingen. Voeg eerst een meting- of sensortegel toe.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Metingen op de klok (maximaal $count)';
  }

  @override
  String get wallProNote =>
      'Metingen op de klok, wekken bij beweging, het nachtschema en alarmen horen bij ZigDash Pro, een eenmalige aankoop.';

  @override
  String get wallAlarmLeak => 'Waterlek';

  @override
  String get wallAlarmSmoke => 'Rook';

  @override
  String get wallAlarmGas => 'Gas';

  @override
  String get wallAlarmCo => 'Koolmonoxide';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Wekken bij beweging';

  @override
  String get wallMotionSubtitle =>
      'Een sensor die iemand ziet, wekt het scherm.';

  @override
  String get wallMotionNone =>
      'Geen bewegings-, aanwezigheids- of deursensoren in dit huis.';

  @override
  String get wallAlarmsTitle => 'Alarmen vullen het scherm';

  @override
  String get wallAlarmsSubtitle =>
      'Een lek, rook, gas of koolmonoxide vult het scherm tot iemand op OK tikt. Alleen zolang ZigDash open is op deze tablet; meldingen bereiken telefoons overal.';

  @override
  String get wallAlarmSound => 'Geluid afspelen';

  @override
  String get wallNightTitle => 'Nacht';

  @override
  String get wallNightSubtitle =>
      'Zwart tussen deze tijden. Beweging wekt het alleen gedimd; alarmen altijd volledig.';

  @override
  String get wallNightFrom => 'Van';

  @override
  String get wallNightTo => 'tot';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Kioskvergrendeling';

  @override
  String get kioskLockSubtitle =>
      'Alleen de dashboards van dit huis en hun bediening blijven bereikbaar. Houd de titel ingedrukt om te stoppen.';

  @override
  String get kioskPin => 'Pincode';

  @override
  String get kioskPinSet => 'Instellen';

  @override
  String get kioskPinNotSet => 'Niet ingesteld';

  @override
  String get kioskPinChange => 'Wijzigen';

  @override
  String get kioskPinRemove => 'Verwijderen';

  @override
  String get kioskPinSetTitle => 'Pincode instellen';

  @override
  String get kioskPinEnterTitle => 'Pincode invoeren';

  @override
  String get kioskPinHint => '4 cijfers';

  @override
  String get kioskPinConfirmHint => 'Nog eens';

  @override
  String get kioskPinMismatch => 'De twee pincodes verschillen.';

  @override
  String get kioskPinWrong => 'Verkeerde pincode.';

  @override
  String get kioskPinForgot => 'Pincode vergeten?';

  @override
  String get kioskPinForgotBody =>
      'Een vergeten pincode kun je alleen herstellen door de gegevens van ZigDash te wissen in de Android-instellingen, wat dit huis verwijdert tenzij je een back-up hebt. Exporteer er een voordat je een pincode instelt.';

  @override
  String get kioskExportBackup => 'Back-up exporteren';

  @override
  String get kioskOsPin => 'ZigDash ook vastzetten in Android';

  @override
  String get kioskOsPinSubtitle =>
      'Android blokkeert Home en recente apps tot ZigDash wordt losgemaakt. Een tablet zonder vergrendelscherm maakt het los met een gebaar, dus dit is niet de vergrendeling.';

  @override
  String get kioskOn => 'Kiosk aan. Houd de titel ingedrukt om te stoppen.';

  @override
  String get kioskLeaveTitle => 'Kiosk verlaten?';

  @override
  String get kioskLeave => 'Verlaten';

  @override
  String get kioskStay => 'Blijven';

  @override
  String get a11yKioskLeave => 'Ingedrukt houden om de kiosk te verlaten';

  @override
  String get historyTitle => 'Geschiedenis';

  @override
  String get historyRangeDay => '24 uur';

  @override
  String get historyRangeWeek => '7 dagen';

  @override
  String get historyRangeMonth => '30 dagen';

  @override
  String get historySetupTitle => 'Geschiedenis opnemen op je hub';

  @override
  String get historySetupBody =>
      'ZigDash heeft geen server, dus ZigDash Engine op je hub legt elke 15 minuten de waarden van je dashboards vast. Het bewaart 30 dagen, op je eigen broker.';

  @override
  String get historySetupAction => 'Instellen op de hub';

  @override
  String get historyInstalled =>
      'Opname loopt. De eerste waarden verschijnen binnen 15 minuten.';

  @override
  String historyNoNodeRed(String host) {
    return 'Geschiedenis heeft Node-RED op de hub nodig, en op poort 1880 van $host antwoordt niets. Op een SMLIGHT SMHUB installeer je het onder Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Opgenomen sinds $date';
  }

  @override
  String get historyEmpty =>
      'Nog geen waarden. De recorder slaat elke 15 minuten op.';

  @override
  String get historyRecorderOffline =>
      'De recorder op de hub antwoordt niet, dus recente waarden kunnen ontbreken.';

  @override
  String get historyLocked =>
      'Langere geschiedenis hoort bij ZigDash Pro, een eenmalige aankoop.';

  @override
  String get historyUnlock => 'Ontgrendelen';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Onbeperkte automatiseringen, langere geschiedenis en extra\'s voor de wandtablet. Steunt het opensourceproject.';

  @override
  String get proUnlocked => 'Ontgrendeld. Bedankt dat je ZigDash steunt.';

  @override
  String get proScreenIntro =>
      'ZigDash is gratis en open source, gemaakt door één persoon in de vrije tijd. Pro is een eenmalige aankoop die het project draaiende houdt.';

  @override
  String get proWhatYouGet => 'Wat je krijgt';

  @override
  String get proGetHistory =>
      'Geschiedenis van 7 en 30 dagen, niet alleen van vandaag';

  @override
  String get proGetWall =>
      'Wandtablet: metingen op de klok, wakker worden bij beweging, een nachtschema en alarmen';

  @override
  String get proGetFuture =>
      'Elke Pro-functie die later komt, zonder extra kosten';

  @override
  String get proFreeTitle => 'Altijd gratis';

  @override
  String get proFreeBody =>
      'Instellen, dashboards, de bediening van elk apparaat, widgets, snelle-instellingentegels, meldingen, drie automatiseringen per huis en de wandtablet zelf blijven gratis. Niets wat je vandaag gebruikt, gaat op slot.';

  @override
  String get proBuy => 'Pro nemen';

  @override
  String proBuyPrice(String price) {
    return 'Pro nemen · $price';
  }

  @override
  String get proOnce =>
      'Eén betaling, geen abonnement. Gekocht op een andere telefoon met hetzelfde Google-account? Het wordt automatisch ontgrendeld.';

  @override
  String get historyNotRecorded =>
      'Alleen getallen die op een dashboard staan worden opgenomen. Voeg deze toe als tegel om de geschiedenis te starten.';

  @override
  String get historyRecordHere => 'Opnemen op dit apparaat';

  @override
  String get historyRecordHereHint =>
      'Kan ZigDash Engine niet op je hub? ZigDash kan vastleggen op een telefoon of tablet die open blijft, zoals een wandtablet. Elke telefoon van dit huis ziet de geschiedenis.';

  @override
  String get historyRecordingHere =>
      'Dit apparaat neemt de geschiedenis op zolang ZigDash open is. De eerste waarden verschijnen binnen 15 minuten.';

  @override
  String get wallRecordHistory => 'Geschiedenis opnemen op dit apparaat';

  @override
  String get wallRecordHistorySubtitle =>
      'Elke 15 minuten zolang ZigDash open is, voor elke telefoon van dit huis. Niet nodig als ZigDash Engine op je hub vastlegt.';

  @override
  String historyNeedsPassword(String host) {
    return 'Nog één stap: je broker vraagt om een login. Open Node-RED op $host:1880, dubbelklik op \"ZigDash history broker\", typ het MQTT-wachtwoord op het tabblad Security en klik op Deploy. ZigDash stuurt je wachtwoord nooit naar de hub.';
  }

  @override
  String get historyNotConnected =>
      'De opname meldt zich niet. Open Automatiseringen om ZigDash Engine op je hub te controleren.';

  @override
  String get historyPersistence =>
      'De geschiedenis staat op je broker. Draai je Mosquitto zelf, zorg dan dat de config \"persistence true\" bevat, anders gaat de geschiedenis verloren als de broker herstart.';

  @override
  String get haImportTitle => 'Importeren uit Home Assistant';

  @override
  String get haImportSettingsSubtitle => 'Namen en ruimtes uit Home Assistant';

  @override
  String get haImportIntro =>
      'Haal de namen en ruimtes op die je in Home Assistant hebt ingesteld. ZigDash leest ze één keer en bewaart verder niets uit Home Assistant.';

  @override
  String get haImportAddress => 'Adres van Home Assistant';

  @override
  String get haImportAddressHelp =>
      'Het adres waarmee je Home Assistant opent, zoals 192.168.1.20:8123';

  @override
  String get haImportToken => 'Langlevend toegangstoken';

  @override
  String get haImportTokenHelp =>
      'Open in Home Assistant je profiel, dan Beveiliging › Langlevende toegangstokens › Token aanmaken. Kopieer het en plak het hier. ZigDash gebruikt het één keer en bewaart het niet; daarna kun je het in Home Assistant verwijderen.';

  @override
  String get haImportRead => 'Lezen uit Home Assistant';

  @override
  String get haImportReading => 'Home Assistant lezen…';

  @override
  String get haImportApplying => 'Importeren…';

  @override
  String get haImportNoAddress =>
      'Typ het adres waarmee je Home Assistant opent.';

  @override
  String get haImportNoToken => 'Plak een langlevend toegangstoken.';

  @override
  String get haImportUnreachable =>
      'Niets antwoordde op dat adres. Controleer het, en of je telefoon op het thuisnetwerk zit.';

  @override
  String get haImportNotHa =>
      'Er antwoordde iets op dat adres, maar het is geen Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant weigerde dat token. Maak een nieuw aan en plak het opnieuw.';

  @override
  String get haImportCertificate =>
      'Je telefoon vertrouwt het certificaat van deze Home Assistant niet. Probeer het http://-adres op je thuisnetwerk.';

  @override
  String get haImportFailed =>
      'Home Assistant antwoordde, maar lezen mislukte. Probeer het opnieuw.';

  @override
  String get haImportNoDevices =>
      'ZigDash ziet de apparaten van dit huis nu niet. Maak verbinding met het huis en probeer het opnieuw.';

  @override
  String get haImportAutomations =>
      'Je automatiseringen blijven in Home Assistant en blijven werken.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apparaten gevonden in Home Assistant',
      one: '1 apparaat gevonden in Home Assistant',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'Tegels die nog de naam van hun apparaat hebben, krijgen de naam uit Home Assistant. Dashboards die je zelf maakte, blijven zoals ze zijn.';

  @override
  String get haImportMakeDashboards =>
      'Ook dashboards maken van je verdiepingen en ruimtes';

  @override
  String get haImportOtherRooms => 'Andere ruimtes';

  @override
  String get haImportNoRoom => 'Geen ruimte';

  @override
  String get haImportApply => 'Importeren';

  @override
  String get haImportBack => 'Terug';

  @override
  String get haImportZhaOnly =>
      'Deze apparaten draaien op ZHA, de eigen Zigbee van Home Assistant, niet op Zigbee2MQTT. ZigDash kan ze dus niet tonen.';

  @override
  String get haImportNothing =>
      'Geen van de Zigbee2MQTT-apparaten van dit huis staat in Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Klaar. Hernoemde tegels: $renamed. Toegevoegde dashboards: $dashboards.';
  }

  @override
  String get haImportOpen => 'Dashboards openen';

  @override
  String get haImportOfferTitle =>
      'Namen en ruimtes uit Home Assistant overnemen?';

  @override
  String get haImportOfferBody =>
      'Home Assistant staat op je netwerk. ZigDash kan je tegels een naam geven en een dashboard per verdieping en ruimte toevoegen, zoals je ze daar hebt ingesteld.';

  @override
  String get haImportOfferLater => 'Niet nu';

  @override
  String get haImportOfferGo => 'Importeren';

  @override
  String get haImportSignIn => 'Inloggen met Home Assistant';

  @override
  String get haImportSignInHelp =>
      'De login van Home Assistant opent in je browser. ZigDash ziet je wachtwoord nooit en logt na het lezen weer uit.';

  @override
  String get haImportOrToken => 'Of gebruik een langlevend toegangstoken';

  @override
  String get haImportReadToken => 'Lezen met token';

  @override
  String get haImportSignInRefused =>
      'Home Assistant accepteerde de login niet. Dat gebeurt als Home Assistant geen internettoegang heeft. Gebruik hieronder een langlevend toegangstoken.';

  @override
  String get setupIsolatedHint =>
      'Je telefoon ziet bijna niets anders op deze wifi. Hij zit misschien op een gastnetwerk, of de router houdt apparaten gescheiden (vaak client- of AP-isolatie genoemd). Verbind met je hoofdwifi of zet dat uit, en probeer het opnieuw.';

  @override
  String get setupAuthTrust =>
      'Je login blijft op deze telefoon en gaat alleen naar je eigen broker. ZigDash heeft geen server en geen account, en elke MQTT-app logt zo in. Het veiligst: een aparte MQTT-gebruiker alleen voor ZigDash, die je altijd kunt verwijderen.';

  @override
  String get setupAuthWhatKept => 'Wat ZigDash bewaart';

  @override
  String get setupAuthDemoFirst => 'Eerst de demo proberen';

  @override
  String get automationsTitle => 'Automatiseringen';

  @override
  String get engineRunningOnHub => 'Draait op de hub';

  @override
  String get engineChecking => 'Hub controleren…';

  @override
  String get engineAwayNoHubTitle => 'Je hub is nu niet bereikbaar';

  @override
  String get engineAwayNoHubBody =>
      'Je bent weg en je hub is niet verbonden met de toegang op afstand van ZigDash, of het internet is weg. Je automatiseringen blijven op de hub draaien.';

  @override
  String get engineAwayReinstallAtHome =>
      'Je kunt de Engine opnieuw installeren als je thuis bent.';

  @override
  String get engineNoConnection =>
      'ZigDash bereikt de broker van dit huis nu niet. Automatiseringen stel je thuis in, met verbinding.';

  @override
  String get engineRestarting =>
      'Zigbee2MQTT herstart… Je apparaten zijn over ongeveer 30 seconden terug.';

  @override
  String get engineInstalling => 'Installeren op de hub…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT moet worden bijgewerkt';

  @override
  String engineTooOldBody(Object version) {
    return 'Je Zigbee2MQTT is versie $version. Automatiseringen hebben 2.4 of nieuwer nodig. Werk Zigbee2MQTT op de hub bij en kom dan hier terug.';
  }

  @override
  String get engineIntroTitle =>
      'Automatiseringen draaien op je hub, niet op je telefoon';

  @override
  String get engineIntroBody =>
      'ZigDash zet ZigDash Engine in Zigbee2MQTT op je hub. Het let op je apparaten en voert je regels uit, zodat een lamp aangaat als de deur opengaat, ook met je telefoon uit en zonder internet.';

  @override
  String get engineIntroNothingByHand =>
      'Niets met de hand te installeren. ZigDash doet het via je thuisnetwerk.';

  @override
  String engineIntroVersion(Object version) {
    return 'Je Zigbee2MQTT is versie $version.';
  }

  @override
  String get engineIntroRemove =>
      'Je kunt hem altijd vanaf dit scherm verwijderen.';

  @override
  String get engineInstall => 'Installeren op de hub';

  @override
  String get engineDeclinedTitle => 'Geen automatiseringen op deze hub';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT op je hub staat geen uitbreidingen toe, dus niets kan je regels uitvoeren als je telefoon weg is. Scènes, meldingen en het dashboard werken als voorheen.';

  @override
  String get engineAllowAfterAll => 'Uitbreidingen toch toestaan';

  @override
  String get engineConsentTitle => 'Zigbee2MQTT moet één instelling wijzigen';

  @override
  String get engineConsentBody =>
      'Je Zigbee2MQTT blokkeert uitbreidingen zoals ZigDash Engine, zoals nieuwe installaties doen. Om automatiseringen op de hub te draaien zou ZigDash „Externe JavaScript toestaan” in Zigbee2MQTT aanzetten en het herstarten.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT herstart één keer. Lampen en sensoren zijn ongeveer 30 seconden onbereikbaar.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine is open source. Je kunt het lezen op de Zigbee2MQTT-pagina onder Extensies.';

  @override
  String get engineConsentUndo =>
      'Je kunt de instelling later weer uitzetten. Dan stoppen de automatiseringen.';

  @override
  String get engineConsentYes => 'Instelling wijzigen en herstarten';

  @override
  String get engineConsentNo => 'Niet nu';

  @override
  String get automationsPausedTitle => 'Automatiseringen gepauzeerd';

  @override
  String get automationsPausedBody =>
      'Je hub heeft zich al meer dan een minuut niet gemeld, dus geen automatisering kan draaien tot hij dat weer doet. Je regels blijven bewaard.';

  @override
  String get engineReinstall => 'Opnieuw installeren op de hub';

  @override
  String get engineStoppedTitle =>
      'Automatiseringen gepauzeerd: ZigDash Engine is zelf gestopt';

  @override
  String get engineStoppedBody =>
      'Hij liep drie keer binnen een uur tegen fouten aan en schakelde zich uit zodat Zigbee2MQTT blijft draaien. Je regels blijven bewaard.';

  @override
  String get engineStartAgain => 'Opnieuw starten';

  @override
  String get engineReportProblem => 'Probleem melden';

  @override
  String get engineRunningTitle => 'Je hub is klaar voor automatiseringen';

  @override
  String engineRunningBody(Object count) {
    return 'Regels geladen op de hub: $count. Automatiseringen maken komt in de volgende stap van deze versie.';
  }

  @override
  String get engineClockOff =>
      'De klok van je hub loopt meer dan vijf minuten verkeerd. Tijdgebonden automatiseringen draaien op het verkeerde moment tot dat is opgelost.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Regels die ZigDash Engine op je hub nog niet kan uitvoeren: $count. Installeer het opnieuw om het bij te werken.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT weigerde ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT antwoordde niet. Controleer of het huis verbonden is en probeer opnieuw.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT nam de wijziging niet over of kwam niet terug. Controleer je hub en probeer opnieuw.';

  @override
  String get autoValMotion => 'beweging';

  @override
  String get autoValNoMotion => 'geen beweging';

  @override
  String get autoValClosed => 'dicht';

  @override
  String get autoValOpened => 'open';

  @override
  String get autoValLeak => 'lek';

  @override
  String get autoValDry => 'droog';

  @override
  String get autoValSmoke => 'rook';

  @override
  String get autoValNoSmoke => 'geen rook';

  @override
  String get autoValOn => 'aan';

  @override
  String get autoValOff => 'uit';

  @override
  String get autoValToggle => 'omschakelen';

  @override
  String get autoValOpen => 'openen';

  @override
  String get autoValClose => 'sluiten';

  @override
  String get autoValStop => 'stoppen';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Als $device: $property boven $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Als $device: $property onder $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Als $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'Om $time';
  }

  @override
  String get autoSunrise => 'zonsopkomst';

  @override
  String get autoSunset => 'zonsondergang';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min na $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min voor $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'Bij $sun';
  }

  @override
  String get autoEveryDay => 'elke dag';

  @override
  String get autoWeekdays => 'doordeweeks';

  @override
  String get autoWeekends => 'in het weekend';

  @override
  String autoBetween(Object from, Object to) {
    return 'tussen $from en $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device is $value';
  }

  @override
  String autoRunScene(Object scene) {
    return '„$scene” uitvoeren';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, na $minutes min weer uit';
  }

  @override
  String get autoErrPickTrigger => 'Kies een apparaat en wat het doet.';

  @override
  String get autoErrValue => 'Typ een getal voor de meting.';

  @override
  String get autoErrDays => 'Kies minstens één dag.';

  @override
  String get autoErrTown =>
      'Stel je plaats in voor zonsopkomst en zonsondergang.';

  @override
  String get autoErrPickAction => 'Kies wat er moet gebeuren.';

  @override
  String get autoErrEmptyScene => 'Die scène heeft niets te versturen.';

  @override
  String get autoErrNotConnected =>
      'ZigDash is niet verbonden met dit huis. Probeer het thuis opnieuw.';

  @override
  String get autoNewTitle => 'Nieuwe automatisering';

  @override
  String get autoEditTitle => 'Automatisering bewerken';

  @override
  String get autoName => 'Naam';

  @override
  String get autoNameHint => 'Wat het doet (optioneel)';

  @override
  String get autoWhen => 'Als';

  @override
  String get autoOnlyIf => 'Alleen als';

  @override
  String get autoThen => 'Dan';

  @override
  String get autoEnabled => 'Ingeschakeld';

  @override
  String get autoDelete => 'Automatisering verwijderen';

  @override
  String get autoSave => 'Opslaan';

  @override
  String get autoDeviceChanges => 'Een apparaat verandert';

  @override
  String get autoTimeComes => 'Een tijdstip komt';

  @override
  String get autoDevice => 'Apparaat';

  @override
  String get autoAbove => 'boven';

  @override
  String get autoBelow => 'onder';

  @override
  String get autoClockTime => 'Tijdstip';

  @override
  String get autoAt => 'Om';

  @override
  String get autoShift => 'Verschuiving in minuten (min is ervoor)';

  @override
  String get autoTownNone => 'Geen plaats ingesteld';

  @override
  String autoTownIs(Object town) {
    return 'Zontijden voor $town';
  }

  @override
  String get autoTownSet => 'Plaats instellen';

  @override
  String get autoTownChange => 'Plaats wijzigen';

  @override
  String get autoDays => 'Dagen';

  @override
  String get autoNoConditions => 'Geen voorwaarden. Draait elke keer.';

  @override
  String get autoAddHours => 'Tussen tijden';

  @override
  String get autoFrom => 'Van';

  @override
  String get autoTo => 'Tot';

  @override
  String get autoAddDeviceCondition => 'Een apparaat is…';

  @override
  String get autoRunASceneOption => 'Een scène uitvoeren';

  @override
  String get autoSetADevice => 'Een apparaat instellen';

  @override
  String get autoScene => 'Scène';

  @override
  String get autoTurnOffAgain => 'Weer uitzetten';

  @override
  String get autoStaysAsSet => 'Blijft zo';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minuten erna';
  }

  @override
  String get autoTownSearch => 'Plaats';

  @override
  String get autoTownWhy =>
      'Alleen voor zonsopkomst en zonsondergang. Bewaard op je hub, nooit je locatie.';

  @override
  String get autoNewButton => 'Nieuwe automatisering';

  @override
  String get autoEmptyBody =>
      'Er draait nog niets. Tik op Nieuwe automatisering voor de eerste.';

  @override
  String autoOnlyIfList(Object list) {
    return 'alleen als $list';
  }

  @override
  String get autoEdit => 'Bewerken';

  @override
  String get autoNeverRan => 'nog nooit gedraaid';

  @override
  String autoRanAt(Object time) {
    return 'draaide $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count van $max gratis automatiseringen';
  }

  @override
  String get autoRecentRuns => 'Laatste uitvoeringen';

  @override
  String get autoDeleted => '(verwijderd)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count automatiseringen zijn gratis. Meer nodig?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash is gratis en open source, gemaakt door één persoon. Pro is een eenmalige aankoop: onbeperkte automatiseringen, geschiedenis van 7 en 30 dagen en de extra\'s voor wandtablets. Je automatiseringen blijven draaien, wat je ook kiest.';

  @override
  String get autoCeilingSeePro => 'Pro bekijken';

  @override
  String get engineRemove => 'Van de hub verwijderen';

  @override
  String get engineRemoveTitle => 'ZigDash Engine van de hub verwijderen?';

  @override
  String get engineRemoveBody =>
      'Automatiseringen stoppen. Je regels blijven op de hub, dus ZigDash Engine opnieuw installeren brengt ze terug.';

  @override
  String get autoNoTargets =>
      'Dit huis heeft nog geen lamp, stekker, schakelaar of rolluik om te bedienen.';

  @override
  String get proGetAutomations =>
      'Onbeperkte automatiseringen; drie per huis zijn gratis';

  @override
  String get proGetRemote =>
      'Bediening op afstand van overal, via de ZigDash-relay, zonder maandelijkse kosten';

  @override
  String get proRemoteFair =>
      'Toegang op afstand is inbegrepen zolang de ZigDash-relay draait, voor één huis, tot vijf telefoons en normaal huishoudelijk gebruik. Dit kan met aankondiging veranderen of stoppen.';

  @override
  String get autoDeleteConfirm =>
      'Deze automatisering verwijderen? Hij draait dan niet meer op je hub.';

  @override
  String get statusConnectedRelay => 'Verbonden · Onderweg via ZigDash';

  @override
  String get shareHomeTitle => 'Delen met een andere telefoon';

  @override
  String get shareHomeSubtitle =>
      'Voeg dit huis met één QR-code toe aan een andere telefoon';

  @override
  String get shareHomeIntro =>
      'Scan op de andere telefoon, thuis op dezelfde wifi, de code met de camera. ZigDash voegt dit huis toe met de inloggegevens en je dashboards.';

  @override
  String get shareHomeLoginWarning =>
      'De code bevat de broker-inlog van dit huis. Hij staat 2 minuten in beeld; laat hem alleen zien aan mensen die je vertrouwt.';

  @override
  String get shareHomeShow => 'Code tonen';

  @override
  String get shareHomeAtHome =>
      'Maak eerst thuis verbinding: delen werkt alleen op je thuisnetwerk.';

  @override
  String get shareHomeScanHint =>
      'Scan met de camera van de andere telefoon. De code verdwijnt na 2 minuten.';

  @override
  String get shareHomeHide => 'Code verbergen';

  @override
  String get shareHomeViaHa =>
      'Dit huis maakt verbinding via Home Assistant. Installeer ZigDash op de andere telefoon en log in met Home Assistant.';

  @override
  String get joinHomeTitle => 'Een gedeeld huis toevoegen';

  @override
  String get joinHomeInvalid =>
      'Deze code is geen ZigDash-uitnodiging, of hij is beschadigd.';

  @override
  String joinHomeAlready(String name) {
    return '$name staat al op deze telefoon.';
  }

  @override
  String get joinHomeOpen => 'Openen';

  @override
  String joinHomeAsk(String name) {
    return '$name aan deze telefoon toevoegen?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash voegt het huis toe met dezelfde verbinding en inlog, en neemt de dashboards over van de andere telefoon. Houd deze telefoon op de wifi thuis.';

  @override
  String get joinHomeAdd => 'Huis toevoegen';

  @override
  String get joinHomeNoDashboards =>
      'Huis toegevoegd. De dashboards kwamen niet aan; je apparaten staan op het tabblad Apparaten.';

  @override
  String get remoteTitle => 'Bediening op afstand';

  @override
  String get remoteSettingsSubtitle => 'Bedien dit huis overal, met Pro';

  @override
  String get remoteIntroTitle => 'Bedien je huis overal';

  @override
  String get remoteOfferBody =>
      'Bereik je apparaten als je weg bent, via de versleutelde relay van ZigDash. Onderdeel van Pro: één betaling, geen maandelijkse kosten. Stel het in terwijl je thuis bent.';

  @override
  String get remoteOfferBodyPro =>
      'Je hebt Pro: zet bediening op afstand aan terwijl je thuis bent, en bereik je apparaten daarna overal.';

  @override
  String get remoteOfferShow => 'Laat zien';

  @override
  String get remoteIntroBody =>
      'Je hub houdt één verbinding met de relay van ZigDash. Onderweg bereikt deze telefoon je apparaten daarlangs. Alles wordt versleuteld op je hub en je telefoon, dus de relay kan je apparaten en wat ze doen niet lezen.';

  @override
  String get remoteNeedsEngine =>
      'Bediening op afstand draait in ZigDash Engine. Installeer het eerst onder Automatiseringen.';

  @override
  String get remoteSetUp => 'Bediening op afstand aanzetten';

  @override
  String get remoteNeedsPro => 'Bediening op afstand hoort bij Pro.';

  @override
  String get remoteNotAtHome => 'Zet dit thuis aan, verbonden met je broker.';

  @override
  String get remoteUnreachable =>
      'De relay van ZigDash antwoordde niet. Probeer het later opnieuw.';

  @override
  String get remoteRefused =>
      'De relay weigerde. Probeer opnieuw of meld een probleem.';

  @override
  String get remoteOnTitle => 'Bediening op afstand staat aan';

  @override
  String get remoteOnBody => 'Onderweg verbindt ZigDash vanzelf via de relay.';

  @override
  String get remoteHubOnline => 'Je hub is verbonden met de relay';

  @override
  String get remoteHubOffline => 'Je hub is niet verbonden met de relay';

  @override
  String get remoteTurnOff => 'Bediening op afstand uitzetten';

  @override
  String get remoteViaRelayNow => 'Deze telefoon is nu via de relay verbonden.';

  @override
  String get remotePhones => 'Telefoons met toegang op afstand';

  @override
  String get remoteThisPhone => 'Deze telefoon';

  @override
  String get remoteOtherPhone => 'Een andere telefoon';

  @override
  String remotePhoneAdded(Object date) {
    return 'Toegevoegd op $date';
  }

  @override
  String get remoteRemovePhone => 'Verwijderen';

  @override
  String get remoteRemovePhoneConfirm =>
      'Deze telefoon verwijderen? Hij kan dit huis dan niet meer op afstand bereiken.';

  @override
  String get remoteAddPhone => 'Telefoon toevoegen';

  @override
  String get remoteAddPhoneHint =>
      'Scan dit thuis met de camera van de andere telefoon. Die opent ZigDash en zet daar bediening op afstand aan. Toon het alleen aan je eigen telefoons.';

  @override
  String get remoteAddPhoneFailed =>
      'De relay gaf geen toegang voor nog een telefoon. Een huis kan er tot vijf hebben.';

  @override
  String get remoteBackupSave => 'Sleutelback-up opslaan';

  @override
  String get remoteBackupRestore => 'Herstellen uit een sleutelback-up';

  @override
  String get remoteBackupPassphrase => 'Wachtzin voor de back-up';

  @override
  String get remoteBackupPassphraseHint =>
      'Raak je deze telefoon kwijt, dan brengen de back-up en deze wachtzin bediening op afstand terug op een nieuwe. Minstens 8 tekens, en bewaar de wachtzin ergens anders dan het bestand.';

  @override
  String get remoteBackupPassphraseAsk =>
      'De wachtzin die je koos bij het opslaan.';

  @override
  String get remoteBackupPassphraseAgain => 'Wachtzin nogmaals';

  @override
  String get remoteBackupSaved => 'Sleutelback-up opgeslagen';

  @override
  String get remoteBackupWrong => 'Die wachtzin opent deze back-up niet.';

  @override
  String get remoteBackupWrongFile => 'Dat is geen sleutelback-up van ZigDash.';

  @override
  String get remotePlayOnly =>
      'Bediening op afstand zit voorlopig in de Google Play-versie van ZigDash.';

  @override
  String get remotePairTitle => 'Bediening op afstand toevoegen';

  @override
  String get remotePairBody =>
      'Welk huis is dit? ZigDash bewaart de toegang op afstand daarvoor.';

  @override
  String get remotePairNoHomes =>
      'Stel dit huis eerst in op deze telefoon, thuis. Scan de code dan opnieuw.';

  @override
  String get remotePairInvalid =>
      'Dit is geen code voor bediening op afstand van ZigDash, of hij is afgeknipt.';

  @override
  String remotePairDone(Object home) {
    return 'Bediening op afstand staat aan voor $home';
  }

  @override
  String get remoteReconnectHub => 'Hub opnieuw verbinden';

  @override
  String get remoteTurnOffConfirm =>
      'Deze telefoon stopt met bediening op afstand en je hub verbreekt de verbinding met de relay. Een sleutelback-up van deze telefoon werkt dan niet meer; andere telefoons houden hun toegang tot je ze verwijdert.';

  @override
  String remoteHomeId(Object id) {
    return 'Huis-ID $id';
  }

  @override
  String get alertsHintTitle => 'Meldingen op deze telefoon';

  @override
  String get alertsHintBody =>
      'Een lek, rook, een geopende deur of een bijna lege batterij kan een melding naar deze telefoon sturen, ook als ZigDash dicht is.';

  @override
  String get alertsHintButton => 'Alarmen instellen';

  @override
  String get alertsHintNotNow => 'Niet nu';

  @override
  String get guidedNoZ2mBody =>
      'Hier antwoordt een MQTT-broker, maar Zigbee2MQTT stuurt er niets over. Controleer of Zigbee2MQTT gestart is en deze broker gebruikt, en of het basistopic overeenkomt met de instellingen. Staan je Zigbee-apparaten in ZHA van Home Assistant, dan kan ZigDash ze niet zien: het werkt met Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT staat op deze broker met basistopic ‘$found’, maar dit huis zoekt ‘$current’.';
  }

  @override
  String devicesUseBase(String found) {
    return '‘$found’ gebruiken';
  }

  @override
  String get devicesChangeConnection => 'Verbinding wijzigen';

  @override
  String get updateAvailableTitle => 'Er is een nieuwe versie van ZigDash';

  @override
  String get updateAvailableBody =>
      'Hij wordt gedownload terwijl je ZigDash blijft gebruiken.';

  @override
  String get updateAvailableButton => 'Bijwerken';

  @override
  String get updateDownloading => 'Update downloaden…';

  @override
  String get updateReadyTitle => 'Update gedownload';

  @override
  String get updateReadyButton => 'Opnieuw starten om af te ronden';
}
