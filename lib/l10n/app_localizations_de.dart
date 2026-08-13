// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei ZigDash';

  @override
  String get onboardingWelcomeSubtitle =>
      'Dein privates, lokales Dashboard für Zigbee2MQTT.\nKeine Cloud. Kein Tracking. Nur Steuerung.';

  @override
  String get onboardingBrokerTitle => 'Broker verbinden';

  @override
  String get onboardingBrokerSubtitle =>
      'Richte ZigDash auf deinen MQTT-Broker aus, um direkt mit deinen Zigbee-Geräten zu sprechen. Funktioniert mit Mosquitto, SMLIGHT und jedem MQTT-Server.';

  @override
  String get onboardingDashboardTitle => 'Dashboards erstellen';

  @override
  String get onboardingDashboardSubtitle =>
      'Erstelle eigene Dashboards mit Schaltern, Reglern, Rollläden und mehr. Ordne Panels nach deinen Wünschen an – alles wird lokal auf deinem Gerät gespeichert.';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingDemo => 'Demo testen';

  @override
  String get navBrokers => 'Broker';

  @override
  String get navDashboards => 'Dashboards';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get settingsDynamicColor => 'Material-You-Farben verwenden';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; sonst wird die App-Farbe verwendet';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Verbindungen';

  @override
  String connLoadFailed(Object error) {
    return 'Laden fehlgeschlagen: $error';
  }

  @override
  String get connAddBroker => 'Broker hinzufügen';

  @override
  String get connEmpty =>
      'Noch keine Verbindungen.\nTippe auf „Broker hinzufügen“, um ZigDash mit deinem MQTT-Server zu verbinden.';

  @override
  String get connNew => 'Neue Verbindung';

  @override
  String get connEdit => 'Verbindung bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get saving => 'Wird gespeichert…';

  @override
  String get fieldRequired => 'Erforderlich';

  @override
  String get connName => 'Name';

  @override
  String get connNameHint => 'Broker zu Hause';

  @override
  String get connHost => 'Host';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Lokaler Host';

  @override
  String get connFindBrokers => 'Broker suchen';

  @override
  String get connHowToFind => 'Wo finde ich das?';

  @override
  String get connRescan => 'Erneut suchen';

  @override
  String get connBrokerNeedsLogin => 'Anmeldung erforderlich';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Suche in $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return '$count Broker gefunden – tippen zum Verwenden';
  }

  @override
  String get connFindBrokersNone => 'Keine Broker in deinem WLAN gefunden.';

  @override
  String get connFindBrokersNoIp =>
      'Deine WLAN-Adresse konnte nicht gelesen werden. Stelle sicher, dass WLAN aktiviert ist, und versuche es erneut.';

  @override
  String get connHelpTitle => 'Die Broker-IP finden';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT in Docker';

  @override
  String get connHelpDockerBody =>
      'Die Broker-IP ist die LAN-Adresse des Rechners, auf dem Docker läuft (dein NAS, Raspberry Pi usw.). Finde sie in der Geräteliste deines Routers oder führe auf dem Rechner „hostname -I“ / „ip addr“ aus. Der Port ist normalerweise 1883 (Mosquitto). Verwende die LAN-IP des Hosts – nicht 127.0.0.1 – auch wenn Mosquitto in einem eigenen Container läuft.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'Die Broker-IP ist die IP-Adresse des Hubs. Finde sie in der SMLIGHT-Weboberfläche unter Einstellungen → Netzwerk oder in deinem Router. Der Port ist 1883, standardmäßig ohne Benutzername/Passwort.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA hat keinen MQTT-Broker – es kommuniziert direkt mit Home Assistant, daher kann ZigDash nicht darauf zugreifen. Um ZigDash zu nutzen, wechsle zu Zigbee2MQTT (als Home-Assistant-Add-on oder Docker-Container verfügbar), das einen MQTT-Broker bereitstellt.';

  @override
  String get connHelpSameNetwork =>
      'Dein Telefon und der Broker müssen sich im selben WLAN befinden (kein Gast- oder isoliertes VLAN).';

  @override
  String get connRemoteHost => 'Remote-Host (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Wird verwendet, wenn der lokale Host nicht erreichbar ist. Bevorzugt die Tailscale-IP des Hubs, z. B. 100.x.y.z';

  @override
  String get connPort => 'Port';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsernameOptional => 'Benutzername (optional)';

  @override
  String get connPasswordOptional => 'Passwort (optional)';

  @override
  String get connPasswordKeepHint =>
      'Leer lassen, um das vorhandene zu behalten';

  @override
  String get connAutoConnect => 'Beim App-Start automatisch verbinden';

  @override
  String get advanced => 'Erweitert';

  @override
  String get connKeepAlive => 'Keep-alive (Sekunden)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protokoll';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get connDeleteTitle => 'Verbindung löschen?';

  @override
  String connDeleteContent(Object name) {
    return 'Entfernt „$name“ samt Dashboards/Panels und gespeichertem Passwort.';
  }

  @override
  String get statusDisconnected => 'Getrennt';

  @override
  String get statusConnecting => 'Verbinde…';

  @override
  String get statusConnected => 'Verbunden';

  @override
  String get statusReconnecting => 'Verbinde erneut…';

  @override
  String get statusError => 'Fehler';

  @override
  String get statusConnectedRemote => 'Verbunden · Remote';

  @override
  String get dashPlaceholder =>
      'Öffne einen Broker über den Reiter „Broker“, um seine Dashboards zu sehen und zu verwalten.';

  @override
  String get dashAddDashboard => 'Dashboard hinzufügen';

  @override
  String get dashEditDashboard => 'Dashboard bearbeiten';

  @override
  String get dashAddPanel => 'Panel hinzufügen';

  @override
  String get dashEmpty =>
      'Noch keine Dashboards.\nTippe auf „Dashboard hinzufügen“, um eines für diesen Broker zu erstellen.';

  @override
  String dashLoadFailed(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get panelPickerTitle => 'Panel hinzufügen';

  @override
  String get panelPickerSectionControl => 'Steuerung';

  @override
  String get panelPickerSectionState => 'Status';

  @override
  String get panelPickerToggleTitle => 'Schalter';

  @override
  String get panelPickerToggleSubtitle =>
      'Ein/Aus-Schalter für einen Gerätestatus';

  @override
  String get panelPickerSliderBrightnessTitle => 'Regler – Helligkeit';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Licht dimmen (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Regler – Position';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Rollladen (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Rollladen';

  @override
  String get panelPickerCoverSubtitle =>
      'Rollladen: AUF·STOP·ZU + Positionsregler';

  @override
  String get panelPickerScheduleTitle => 'Zeitplan';

  @override
  String get panelPickerScheduleSubtitle =>
      'Tägliche Öffnungs-/Schließzeiten, läuft auf dem Hub (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Auto-Schließen-Regel';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Gerät N Sekunden nach dem Einschalten automatisch schließen, läuft auf dem Hub (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Mehrfachstatus';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Segmentierte Schaltflächen für einen Aufzählungstyp (z. B. AUF/STOP/ZU)';

  @override
  String get panelPickerComboTitle => 'Dropdown';

  @override
  String get panelPickerComboSubtitle =>
      'Dropdown-Auswahl für einen Aufzählungstyp';

  @override
  String get panelPickerRadioTitle => 'Radio';

  @override
  String get panelPickerRadioSubtitle =>
      'Optionsliste für einen Aufzählungstyp';

  @override
  String get panelPickerButtonTitle => 'Taste';

  @override
  String get panelPickerButtonSubtitle => 'Einmaligen Befehl senden';

  @override
  String get panelPickerTextInputTitle => 'Texteingabe';

  @override
  String get panelPickerTextInputSubtitle =>
      'Freien Wert oder JSON veröffentlichen';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Farbige Anzeige für einen booleschen Status (Kontakt, Leck)';

  @override
  String get panelPickerNodeStatusTitle => 'Gerätestatus';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Verfügbarkeit von Z2M-Geräten (online/offline)';

  @override
  String get panelPickerProgressTitle => 'Fortschritt';

  @override
  String get panelPickerProgressSubtitle =>
      'Numerischer Balken für Akku, Verbindungsqualität usw.';

  @override
  String get panelPickerTextLogTitle => 'Textprotokoll';

  @override
  String get panelPickerTextLogSubtitle =>
      'Laufende Nachrichtenhistorie zu einem Thema';

  @override
  String get dashExportMenu => 'Dashboards exportieren';

  @override
  String get dashImportMenu => 'Dashboards importieren';

  @override
  String get dashExportTitle => 'Dashboards exportieren';

  @override
  String get dashExportClose => 'Schließen';

  @override
  String get dashExportCopy => 'Kopieren';

  @override
  String get dashExportCopied => 'In die Zwischenablage kopiert';

  @override
  String get dashImportTitle => 'Dashboards importieren';

  @override
  String get dashImportHint => 'Exportiertes JSON hier einfügen';

  @override
  String get dashImportButton => 'Importieren';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dashboards importiert',
      one: '1 Dashboard importiert',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get dashFormNew => 'Neues Dashboard';

  @override
  String get dashFormEdit => 'Dashboard bearbeiten';

  @override
  String get dashFormName => 'Name';

  @override
  String get dashFormNameHint => 'Büro';

  @override
  String get dashFormTopicPrefix => 'Topic-Präfix (optional)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/wohnzimmer';

  @override
  String get dashFormTopicPrefixHelper =>
      'Wird jedem Panel-Topic in diesem Dashboard vorangestellt';

  @override
  String get dashFormColorSeed => 'Farbbasis';

  @override
  String get dashFormIcon => 'Symbol';

  @override
  String get dashFormLock => 'Sperren';

  @override
  String get dashFormLockSubtitle =>
      'Bearbeitungsfunktionen bei gesperrtem Dashboard ausblenden';

  @override
  String get dashFormDelete => 'Dashboard löschen';

  @override
  String get dashDeleteTitle => 'Dieses Dashboard löschen?';

  @override
  String get dashDeleteContent =>
      'Alle darunter liegenden Panels werden ebenfalls entfernt.';

  @override
  String get dashDeleteConfirm => 'Löschen';

  @override
  String panelFormNew(Object type) {
    return 'Neues $type';
  }

  @override
  String panelFormEdit(Object type) {
    return '$type bearbeiten';
  }

  @override
  String get panelTypeButton => 'Taste';

  @override
  String get panelTypeToggle => 'Schalter';

  @override
  String get panelTypeSlider => 'Regler';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Gerätestatus';

  @override
  String get panelTypeProgress => 'Fortschritt';

  @override
  String get panelTypeMultiState => 'Mehrfachstatus';

  @override
  String get panelTypeCombo => 'Dropdown';

  @override
  String get panelTypeRadio => 'Radio';

  @override
  String get panelTypeCover => 'Rollladen';

  @override
  String get panelTypeTextInput => 'Texteingabe';

  @override
  String get panelTypeTextLog => 'Textprotokoll';

  @override
  String get panelTypeSchedule => 'Zeitplan';

  @override
  String get panelTypeAutoClose => 'Auto-Schließen';

  @override
  String get panelFormName => 'Name';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Dashboard-Präfix: $prefix/ (verwendet, sofern unten nicht überschrieben)';
  }

  @override
  String get panelFormTopicPrefixOverride =>
      'Topic-Präfix-Überschreibung (optional)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/rollladen';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Ein anderes Gerät in diesem Dashboard verwenden. Leer = Dashboard-Präfix verwenden.';

  @override
  String get panelFormPublishTopic => 'Veröffentlichungs-Topic (Suffix)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Wird an das effektive Präfix angehängt. Leer lassen, um direkt am Präfix zu veröffentlichen.';

  @override
  String get panelFormTopicSuffix => 'Topic (Suffix)';

  @override
  String get panelFormSubscribeTopic => 'Abonnement-Topic (Suffix, optional)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Wird an das Dashboard-Präfix angehängt. Leer = das Präfix selbst abonnieren (Z2M-Status).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Leer = das Präfix selbst abonnieren (Z2M-Status). Gleich wie Veröffentlichungs-Topic = dieses verwenden.';

  @override
  String get panelFormWidth => 'Breite';

  @override
  String get panelFormWidthFull => 'Voll';

  @override
  String get panelFormWidthHalf => 'Halb';

  @override
  String get panelFormWidthThird => 'Drittel';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 – höchstens einmal';

  @override
  String get panelFormQos1 => '1 – mindestens einmal';

  @override
  String get panelFormQos2 => '2 – genau einmal';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'On-Payload';

  @override
  String get panelToggleOffPayload => 'Off-Payload';

  @override
  String get panelToggleJsonPath => 'JSON-Pfad (optional)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'On-Abgleich';

  @override
  String get panelToggleOnMatchHelper =>
      'Wert am JSON-Pfad, der „an“ bedeutet (z. B. „ON“)';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Max';

  @override
  String get panelSliderStep => 'Schritt';

  @override
  String get panelSliderTemplate => 'Wertvorlage';

  @override
  String get panelSliderTemplateHelper =>
      'Verwende das Wort value als Platzhalter – es wird durch den Reglerwert ersetzt';

  @override
  String get panelSliderJsonPath => 'JSON-Pfad (optional)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'JSON-Pfad (optional)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'z. B. „contact“, „occupancy“, „water_leak“';

  @override
  String get panelLedOnMatch => 'On-Abgleich';

  @override
  String get panelLedOnMatchHelper =>
      'Wert am JSON-Pfad, der die LED einschaltet (z. B. „true“, „ON“)';

  @override
  String get panelLedOnLabel => 'On-Label (optional)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Off-Label (optional)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Online-Payload';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Wert, der „online“ bedeutet (Z2M-Standard: „online“)';

  @override
  String get panelNodeJsonPath => 'JSON-Pfad (optional)';

  @override
  String get panelNodeJsonPathHelper =>
      'Für den Z2M-Standard leer lassen (roher „online“/„offline“-String)';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Max';

  @override
  String get panelProgressUnit => 'Einheit';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'JSON-Pfad (optional)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'z. B. „battery“, „linkquality“';

  @override
  String get panelOptionsJsonPath => 'JSON-Pfad (optional)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Feld in der empfangenen Nachricht, das den aktuellen Wert enthält';

  @override
  String get panelOptionsHeader => 'Optionen';

  @override
  String get panelOptionsLabel => 'Beschriftung';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Abgleich (aktueller Wert)';

  @override
  String get panelOptionsAdd => 'Option hinzufügen';

  @override
  String get panelCoverDescription =>
      'AUF-/STOP-/ZU-Tasten plus eine Reihe von Positionsvorgaben. Verwendet die standardmäßigen Z2M-Rollladen-Payloads (state und position).';

  @override
  String get panelCoverPresets => 'Positionsvorgaben';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Kommagetrennte Prozentsätze (0–100). Leer = keine Vorgabenreihe.';

  @override
  String get panelCoverShowSlider => 'Positionsregler anzeigen';

  @override
  String get panelTextInputHint => 'Hinweis (optional)';

  @override
  String get panelTextInputHintHint => 'Wert eingeben…';

  @override
  String get panelTextInputTemplate => 'Vorlage';

  @override
  String get panelTextInputTemplateHelper =>
      'Verwende das Wort value als Platzhalter – es wird durch den eingegebenen Text ersetzt. Standardmäßig wird der Rohtext veröffentlicht.';

  @override
  String get panelTextInputClearAfterSend => 'Nach dem Senden leeren';

  @override
  String get panelTextLogMaxLines => 'Max. Zeilen';

  @override
  String get panelTextLogMaxLinesHelper =>
      'Wie viele letzte Nachrichten behalten werden';

  @override
  String get panelTextLogJsonPath => 'JSON-Pfad (optional)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Nur dieses Feld statt der gesamten Nachricht protokollieren';

  @override
  String get panelScheduleDescription =>
      'Läuft über Node-RED auf dem SMHUB – auch wenn dieses Telefon aus ist. Das obige Veröffentlichungs-Topic ist das Ziel für Rollladen-Befehle.';

  @override
  String get panelScheduleOpenTime => 'Öffnungszeit';

  @override
  String get panelScheduleCloseTime => 'Schließzeit';

  @override
  String get panelScheduleOpenPayload => 'Öffnen-Payload';

  @override
  String get panelScheduleClosePayload => 'Schließen-Payload';

  @override
  String get panelScheduleEnabled => 'Aktiviert';

  @override
  String get panelScheduleSavedOffline =>
      'Gespeichert – nicht verbunden; der Zeitplan wird synchronisiert, sobald online.';

  @override
  String get panelAutoCloseDescription =>
      'Läuft über Node-RED auf dem SMHUB – auch wenn dieses Telefon aus ist. Das obige Veröffentlichungs-Topic ist das Befehlsziel des Geräts (z. B. Tür).';

  @override
  String get panelAutoCloseTriggerPath => 'Trigger-JSON-Pfad';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Feld im Status-JSON des Geräts, das überwacht werden soll (Standard: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Trigger-Wert';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Timer auslösen, wenn das Trigger-Feld diesem Wert entspricht (Standard: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Schließen-Payload';

  @override
  String get panelAutoCloseDelaySeconds => 'Verzögerung (Sekunden)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1–3600. Wartezeit nach dem Einschalten des Geräts, bevor die Schließen-Payload veröffentlicht wird.';

  @override
  String get panelAutoCloseEnabled => 'Aktiviert';

  @override
  String get panelAutoCloseSavedOffline =>
      'Gespeichert – nicht verbunden; die Regel wird synchronisiert, sobald online.';

  @override
  String get panelTileEdit => 'Panel bearbeiten';

  @override
  String get panelTileDuplicate => 'Panel duplizieren';

  @override
  String get panelTileMoveUp => 'Nach oben';

  @override
  String get panelTileMoveDown => 'Nach unten';

  @override
  String get panelTileWidth => 'Breite';

  @override
  String get panelTileWidthFull => 'Voll';

  @override
  String get panelTileWidthHalf => 'Halb';

  @override
  String get panelTileWidthThird => '⅓';

  @override
  String get panelTileDelete => 'Panel löschen';

  @override
  String get panelCoverOpen => 'Öffnen';

  @override
  String get panelCoverStop => 'Stopp';

  @override
  String get panelCoverClose => 'Schließen';

  @override
  String get panelToggleNoState => '(kein Status)';

  @override
  String get panelToggleError => 'Fehler';

  @override
  String get panelStateOn => 'ON';

  @override
  String get panelStateOff => 'OFF';

  @override
  String get panelNodeStatusOnline => 'online';

  @override
  String get panelNodeStatusOffline => 'offline';

  @override
  String get panelNodeStatusUnknown => 'unbekannt';

  @override
  String get panelNodeStatusError => 'fehler';

  @override
  String get panelMultiStateNoOptions => 'Keine Optionen konfiguriert';

  @override
  String get panelTextInputDefaultHint => 'Wert eingeben…';

  @override
  String get panelTextLogWaiting => 'Warte auf Nachrichten…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Öffnet $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Schließt $time';
  }

  @override
  String get panelScheduleOfflineWarning =>
      'Zeitplan offline – wird nicht ausgeführt';

  @override
  String get panelScheduleDisabled => 'Deaktiviert';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Nächster: $action um $at';
  }

  @override
  String get panelScheduleActionOpen => 'öffnen';

  @override
  String get panelScheduleActionClose => 'schließen';

  @override
  String get panelAutoCloseIdle => 'Inaktiv';

  @override
  String get panelAutoCloseDisabled => 'Deaktiviert';

  @override
  String get panelAutoCloseOffline =>
      'Automatisierung offline – Regel wird nicht ausgeführt';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Schließt in ${seconds}s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Schließe jetzt…';

  @override
  String get panelGridEmpty =>
      'Noch keine Panels.\nTippe auf +, um einen Schalter, Regler oder eine Taste hinzuzufügen.';

  @override
  String get panelsOffline => 'Offline – letzte Werte werden angezeigt';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsHelp => 'Hilfe & Anleitung';

  @override
  String get settingsVersion => 'Version';

  @override
  String get a11yBackupMenu => 'Sichern & Wiederherstellen';

  @override
  String get a11ySelectColor => 'Farbe auswählen';

  @override
  String get a11ySelectIcon => 'Symbol auswählen';

  @override
  String get a11yDeleteOption => 'Option löschen';

  @override
  String get a11yPanelOptions => 'Panel-Optionen';

  @override
  String get a11yMoreOptions => 'Weitere Optionen';

  @override
  String get a11yDeleteConnection => 'Verbindung löschen';

  @override
  String get controlNotConnected => 'Nicht verbunden – Änderung nicht gesendet';

  @override
  String get discoverFromDevice => 'Von einem Gerät hinzufügen…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Ein Zigbee2MQTT-Gerät automatisch erkennen';

  @override
  String get discoverTitle => 'Von Gerät hinzufügen';

  @override
  String get discoverBaseTopic => 'Zigbee2MQTT-Basis-Topic';

  @override
  String get discoverScanning => 'Suche nach Geräten…';

  @override
  String get discoverNone => 'Keine Geräte gefunden.';

  @override
  String get discoverFailed =>
      'Keine Geräteliste gefunden. Überprüfe das Basis-Topic und dass der Broker verbunden ist.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get previewTitle => 'Live-Vorschau';

  @override
  String previewWaiting(Object topic) {
    return 'Warte auf eine Nachricht zu $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Extrahiert ($path): $value';
  }

  @override
  String get previewNoValue => '(kein Wert an diesem Pfad)';

  @override
  String get connErrorTitle => 'Verbindungsfehler';

  @override
  String get connErrorUnknown => 'Keine Fehlerdetails verfügbar.';

  @override
  String get connTestButton => 'Verbindung testen';

  @override
  String get connTestOk => 'Verbindung erfolgreich';

  @override
  String connTestFailed(Object error) {
    return 'Verbindung fehlgeschlagen: $error';
  }

  @override
  String get devicesTitle => 'Geräte';

  @override
  String get devicesAddButton => 'Gerät hinzufügen';

  @override
  String get devicesPairingTitle => 'Koppeln – drücke die Taste am Gerät';

  @override
  String devicesPairingHint(int seconds) {
    return 'Suche nach neuen Geräten… ${seconds}s';
  }

  @override
  String get devicesPairingStop => 'Stopp';

  @override
  String get devicesNone => 'Keine Geräte gefunden.';

  @override
  String get devicesBattery => 'Akku';

  @override
  String get devicesLinkQuality => 'Link';

  @override
  String get devicesOnline => 'Online';

  @override
  String get devicesOffline => 'Offline';

  @override
  String devicesPaired(Object name) {
    return 'Bereit: $name';
  }

  @override
  String get devicesPairedHint =>
      'Zu deinem Netzwerk hinzugefügt. Um es auf ein Dashboard zu legen, verwende auf diesem Dashboard „Von einem Gerät hinzufügen“.';

  @override
  String get scenesTitle => 'Szenen';

  @override
  String get scenesNone =>
      'Noch keine Szenen. Stelle deine Geräte wie gewünscht ein und speichere sie dann als Szene.';

  @override
  String get scenesNewButton => 'Neue Szene';

  @override
  String scenesActivated(Object name) {
    return '$name aktiviert';
  }

  @override
  String get scenesActivateOffline =>
      'Nicht verbunden – die Szene kann nicht aktiviert werden';

  @override
  String get sceneFormNewTitle => 'Neue Szene';

  @override
  String get sceneFormEditTitle => 'Szene bearbeiten';

  @override
  String get sceneFormNameLabel => 'Szenenname';

  @override
  String get sceneFormDevicesHeader => 'Zu erfassende Geräte';

  @override
  String get sceneFormCaptureHint =>
      'Der aktuelle einstellbare Status jedes ausgewählten Geräts (an/aus, Helligkeit, Farbe, Position usw.) wird gespeichert. Nur-Lese-Werte werden ignoriert.';

  @override
  String get sceneFormNoDevices =>
      'Keine steuerbaren Geräte gefunden. Stelle sicher, dass sie gekoppelt sind, und tippe dann auf Aktualisieren.';

  @override
  String get sceneFormReadingState => 'Aktuellen Status lesen…';

  @override
  String get sceneCtrlPower => 'Strom';

  @override
  String get sceneCtrlBrightness => 'Helligkeit';

  @override
  String get sceneCtrlPosition => 'Position';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get sceneFormNoDevicesSelected =>
      'Wähle mindestens ein Gerät aus, das erfasst werden soll.';

  @override
  String get sceneFormNothingCaptured =>
      'Von den ausgewählten Geräten konnte nichts Einstellbares erfasst werden.';

  @override
  String get sceneDeleteTitle => 'Szene löschen?';

  @override
  String sceneDeleteMessage(Object name) {
    return '„$name“ wird entfernt. Geräte behalten ihren aktuellen Status.';
  }

  @override
  String get sceneEditAction => 'Bearbeiten';

  @override
  String get sceneDeleteAction => 'Löschen';

  @override
  String get sceneAddToDashboard => 'Zum Dashboard hinzufügen';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Zu $name hinzugefügt';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count Geräte';
  }

  @override
  String get panelTypeScene => 'Szene';

  @override
  String get panelPickerSceneTitle => 'Szenen-Taste';

  @override
  String get panelPickerSceneSubtitle =>
      'Ein Tipp aktiviert eine gespeicherte Szene';

  @override
  String get panelSceneChoose => 'Szene';

  @override
  String get panelSceneMissing => 'Szene nicht gefunden – neu auswählen';

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
  String get guidedConnectTitle => 'Broker einrichten';

  @override
  String get guidedConnectIntro =>
      'Wir testen jeden Schritt der Verbindung und zeigen Ihre Zigbee-Geräte.';

  @override
  String get guidedBaseTopic => 'Basis-Topic';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Testen & verbinden';

  @override
  String get guidedTesting => 'Verbindung wird getestet …';

  @override
  String get stepResolve => 'Host auflösen';

  @override
  String get stepTcp => 'TCP-Verbindung';

  @override
  String get stepConnack => 'MQTT-Handshake';

  @override
  String get stepAuth => 'Authentifizierung';

  @override
  String get stepDevices => 'Geräte suchen';

  @override
  String get diagResolveFail =>
      'Der Hostname konnte nicht aufgelöst werden. Überprüfen Sie die eingegebene Adresse.';

  @override
  String get diagResolveTimeout =>
      'Das Auflösen des Hosts ist abgelaufen. Prüfen Sie Adresse und Netzwerk.';

  @override
  String get diagTcpFail =>
      'Der Broker ist nicht erreichbar. Läuft Zigbee2MQTT? Prüfen Sie Adresse und Port.';

  @override
  String get diagTcpTimeout =>
      'Zeitüberschreitung beim Verbinden. Der Broker ist möglicherweise offline oder nicht erreichbar.';

  @override
  String get diagConnackFail =>
      'Der Broker hat den MQTT-Handshake nicht abgeschlossen. Stellen Sie sicher, dass es ein MQTT-Broker ist (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'Der Broker hat Benutzername oder Passwort abgelehnt. Prüfen Sie Ihre Zugangsdaten.';

  @override
  String get diagAuthRefused =>
      'Der Broker hat die Verbindung abgelehnt. Prüfen Sie die Verbindungseinstellungen.';

  @override
  String foundDevices(Object count) {
    return '$count Geräte gefunden';
  }

  @override
  String get foundDevicesHint =>
      'Ihre Zigbee-Geräte sind sichtbar. Fahren Sie mit Ihrem Dashboard fort.';

  @override
  String get noDevicesTitle => 'Verbunden – noch keine Geräte gefunden';

  @override
  String get noDevicesHint =>
      'ZigDash sieht den Broker, hat aber noch keine Zigbee-Geräte gefunden. Sie können das Pairing starten.';

  @override
  String get startPairing => 'Pairing starten';

  @override
  String get pairingEnabled =>
      'Pairing ist aktiviert. Drücken Sie die Pairing-Taste an Ihrem Gerät.';

  @override
  String get continueToDashboard => 'Zum Dashboard';

  @override
  String get guidedBackToForm => 'Einstellungen bearbeiten';

  @override
  String ladderTriedHint(Object count) {
    return '$count Adressen versucht';
  }

  @override
  String get guidedSaveFailed =>
      'Die Verbindung konnte nicht gespeichert werden. Bitte versuchen Sie es erneut.';

  @override
  String get onboardingConnectBroker => 'Meinen Broker verbinden';

  @override
  String get setupWelcomeTitle => 'Welcome to ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash controls your existing Zigbee2MQTT home — locally, with no cloud. Make sure Zigbee2MQTT is running, then let ZigDash find it.';

  @override
  String get setupFindMySetup => 'Find my setup';

  @override
  String get setupManualEntry => 'Enter details manually';

  @override
  String get setupScanningTitle => 'Looking for a connection…';

  @override
  String get setupScanningHint =>
      'Keep this device on the same local network as your Zigbee2MQTT host.';

  @override
  String get setupCandidateFound => 'Possible connection found';

  @override
  String get setupNoCandidatesTitle => 'No connection found';

  @override
  String get setupNoCandidatesBody => 'Where does Zigbee2MQTT run?';

  @override
  String get setupGuideHa =>
      'Home Assistant: make sure the MQTT broker add-on (e.g. Mosquitto) and the Zigbee2MQTT add-on are installed and running.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: check that your broker (e.g. Mosquitto) and the Zigbee2MQTT service are running, and that port 1883 is reachable.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: open the device\'s web UI, enable the MQTT broker, and check that Zigbee2MQTT shows as connected.';

  @override
  String get setupTryAgain => 'Try again';

  @override
  String get setupAuthTitle => 'This broker needs a login';

  @override
  String setupAuthBody(Object host) {
    return 'Enter the MQTT username and password for $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'The username or password was rejected. Check them and try again.';

  @override
  String get setupVerifyingTitle => 'Checking the connection…';

  @override
  String get setupReviewTitle => 'Your devices';

  @override
  String setupReviewSubtitle(Object count) {
    return '$count devices found. Choose what goes on your first dashboard.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'Create dashboard with $count';
  }

  @override
  String get setupGroupOther => 'Other devices';

  @override
  String get setupGroupUnsupported => 'Unsupported devices';

  @override
  String get setupCreatingTitle => 'Creating your dashboard…';

  @override
  String get setupReadyTitle => 'Your dashboard is ready';

  @override
  String setupReadyBody(Object count) {
    return '$count controls created.';
  }

  @override
  String get setupOpenDashboard => 'Open dashboard';

  @override
  String get setupErrUnreachableTitle => 'Can\'t reach this address';

  @override
  String get setupErrUnreachableBody =>
      'This device and the Zigbee2MQTT host can\'t reach each other. Check that both are on the same local network.';

  @override
  String get setupErrUnreachableAction => 'Try again';

  @override
  String get setupErrPortClosedTitle => 'Nothing answers on this port';

  @override
  String get setupErrPortClosedBody =>
      'The host is reachable, but no MQTT broker answered. Check that the broker is running and that the port is correct.';

  @override
  String get setupErrPortClosedAction => 'Try again';

  @override
  String get setupErrAuthRequiredTitle => 'Login required';

  @override
  String get setupErrAuthRequiredBody =>
      'This broker needs a username and password.';

  @override
  String get setupErrAuthRequiredAction => 'Enter login';

  @override
  String get setupErrAuthRejectedTitle => 'Login rejected';

  @override
  String get setupErrAuthRejectedBody =>
      'The broker rejected these credentials.';

  @override
  String get setupErrAuthRejectedAction => 'Try again';

  @override
  String get setupErrNotZ2mTitle => 'No Zigbee2MQTT here';

  @override
  String get setupErrNotZ2mBody =>
      'An MQTT broker answers here, but Zigbee2MQTT topics weren\'t found. It may be a different broker.';

  @override
  String get setupErrNotZ2mAction => 'Pick another';

  @override
  String get setupErrNoDevicesTitle => 'No devices received';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT is running, but no devices were published during the check. Pair devices in Zigbee2MQTT first.';

  @override
  String get setupErrNoDevicesAction => 'Check again';

  @override
  String get setupErrScanFailedTitle => 'No local network';

  @override
  String get setupErrScanFailedBody =>
      'Couldn\'t determine this device\'s local network. Connect to Wi-Fi and try again.';

  @override
  String get setupErrScanFailedAction => 'Try again';

  @override
  String get setupErrSaveFailedTitle => 'Couldn\'t save';

  @override
  String get setupErrSaveFailedBody =>
      'Saving your setup failed. Nothing was half-saved — you can safely retry.';

  @override
  String get setupErrSaveFailedAction => 'Try again';

  @override
  String get setupErrUnknownTitle => 'Something went wrong';

  @override
  String get setupErrUnknownBody => 'An unexpected error occurred.';

  @override
  String get setupErrUnknownAction => 'Try again';
}
