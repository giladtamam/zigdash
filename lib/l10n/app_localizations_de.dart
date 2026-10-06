// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Zuletzt bekannt';

  @override
  String get reliabilityControlsUnavailable => 'Steuerung nicht verfügbar';

  @override
  String get appTitle => 'ZigDash';

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
  String get connectionsTitle => 'Zuhause';

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
  String get panelTypeDevice => 'Gerät';

  @override
  String get panelTypeReading => 'Messwert';

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
  String get tileSize => 'Größe';

  @override
  String get tileSizeSmall => 'Klein';

  @override
  String get tileSizeWide => 'Breit';

  @override
  String get tileSizeFull => 'Voll';

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
      'Noch keine Kacheln.\nTippe auf „Kachel hinzufügen“, um deine Geräte hier abzulegen.';

  @override
  String get panelsOffline => 'Offline – letzte Werte werden angezeigt';

  @override
  String get connectionConnecting => 'Verbindung wird hergestellt…';

  @override
  String get connectionReconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String get connectionShowingLastKnownValues =>
      'Letzte bekannte Werte werden angezeigt';

  @override
  String get connectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get connectionAutomaticRetry =>
      'Automatische Wiederholungsversuche werden fortgesetzt';

  @override
  String get connectionReconnectNow => 'Jetzt neu verbinden';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsHelp => 'Hilfe & Anleitung';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsRateApp => 'ZigDash bewerten';

  @override
  String get settingsRateAppSubtitle =>
      'Gefällt sie dir? Eine kurze Bewertung hilft anderen, die App zu finden.';

  @override
  String get settingsBuyCoffee => 'Spendiere mir einen Kaffee';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Kostenlos & Open Source — Trinkgeld hält den Kaffee am Fließen.';

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
  String get a11yRefresh => 'Aktualisieren';

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
  String get languageFrench => 'Français';

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
  String get setupWelcomeTitle => 'Willkommen bei ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash steuert dein bestehendes Zigbee2MQTT-Zuhause — lokal, ohne Cloud. Stelle sicher, dass Zigbee2MQTT läuft, und lass ZigDash es finden.';

  @override
  String get setupFindMySetup => 'Mein Setup finden';

  @override
  String get setupManualEntry => 'Details manuell eingeben';

  @override
  String get setupScanningTitle => 'Verbindung wird gesucht…';

  @override
  String get setupScanningHint =>
      'Halte dieses Gerät im selben lokalen Netzwerk wie deinen Zigbee2MQTT-Host.';

  @override
  String get setupCandidateFound => 'Mögliche Verbindung gefunden';

  @override
  String get setupNoCandidatesTitle => 'Keine Verbindung gefunden';

  @override
  String get setupNoCandidatesBody => 'Wo läuft Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: Stelle sicher, dass das MQTT-Broker-Add-on (z. B. Mosquitto) und das Zigbee2MQTT-Add-on installiert sind und laufen.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: Prüfe, ob dein Broker (z. B. Mosquitto) und der Zigbee2MQTT-Dienst laufen und Port 1883 erreichbar ist.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: Öffne die Weboberfläche, gehe zu Einstellungen > MQTT, aktiviere „Allow External“, damit dein Handy den Broker erreicht, und prüfe, dass Zigbee2MQTT läuft.';

  @override
  String get setupTryAgain => 'Erneut versuchen';

  @override
  String get setupAuthTitle => 'Dieser Broker benötigt einen Login';

  @override
  String setupAuthBody(Object host) {
    return 'Gib den MQTT-Benutzernamen und das Passwort für $host ein.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Benutzername oder Passwort wurden abgelehnt. Prüfe sie und versuche es erneut.';

  @override
  String get setupVerifyingTitle => 'Verbindung wird geprüft…';

  @override
  String get setupReviewTitle => 'Deine Geräte';

  @override
  String setupReviewSubtitle(Object count) {
    return '$count Geräte gefunden. Wähle, was auf dein erstes Dashboard kommt.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'Dashboard mit $count erstellen';
  }

  @override
  String get setupGroupOther => 'Andere Geräte';

  @override
  String get setupGroupUnsupported => 'Nicht unterstützte Geräte';

  @override
  String get setupCreatingTitle => 'Dein Dashboard wird erstellt…';

  @override
  String get setupReadyTitle => 'Dein Dashboard ist bereit';

  @override
  String setupReadyBody(Object count) {
    return '$count Steuerelemente erstellt.';
  }

  @override
  String get setupOpenDashboard => 'Dashboard öffnen';

  @override
  String get setupErrUnreachableTitle => 'Diese Adresse ist nicht erreichbar';

  @override
  String get setupErrUnreachableBody =>
      'Dieses Gerät und der Zigbee2MQTT-Host können sich gegenseitig nicht erreichen. Prüfe, ob beide im selben lokalen Netzwerk sind.';

  @override
  String get setupErrUnreachableAction => 'Erneut versuchen';

  @override
  String get setupErrPortClosedTitle => 'Auf diesem Port antwortet nichts';

  @override
  String get setupErrPortClosedBody =>
      'Der Host ist erreichbar, aber kein MQTT-Broker hat geantwortet. Prüfe, ob der Broker läuft und der Port stimmt.';

  @override
  String get setupErrPortClosedAction => 'Erneut versuchen';

  @override
  String get setupErrAuthRequiredTitle => 'Login erforderlich';

  @override
  String get setupErrAuthRequiredBody =>
      'Dieser Broker benötigt Benutzername und Passwort.';

  @override
  String get setupErrAuthRequiredAction => 'Login eingeben';

  @override
  String get setupErrAuthRejectedTitle => 'Login abgelehnt';

  @override
  String get setupErrAuthRejectedBody =>
      'Der Broker hat diese Zugangsdaten abgelehnt.';

  @override
  String get setupErrAuthRejectedAction => 'Erneut versuchen';

  @override
  String get setupErrNotZ2mTitle => 'Hier ist kein Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'Hier antwortet ein MQTT-Broker, aber es wurden keine Zigbee2MQTT-Topics gefunden. Es könnte ein anderer Broker sein.';

  @override
  String get setupErrNotZ2mAction => 'Anderen wählen';

  @override
  String get setupErrNoDevicesTitle => 'Keine Geräte empfangen';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT läuft, aber während der Prüfung wurden keine Geräte veröffentlicht. Kopple zuerst Geräte in Zigbee2MQTT.';

  @override
  String get setupErrNoDevicesAction => 'Erneut prüfen';

  @override
  String get setupErrScanFailedTitle => 'Kein lokales Netzwerk';

  @override
  String get setupErrScanFailedBody =>
      'Das lokale Netzwerk dieses Geräts konnte nicht ermittelt werden. Verbinde dich mit WLAN und versuche es erneut.';

  @override
  String get setupErrScanFailedAction => 'Erneut versuchen';

  @override
  String get setupErrSaveFailedTitle => 'Speichern fehlgeschlagen';

  @override
  String get setupErrSaveFailedBody =>
      'Das Speichern deines Setups ist fehlgeschlagen. Es wurde nichts zur Hälfte gespeichert — du kannst es sicher erneut versuchen.';

  @override
  String get setupErrSaveFailedAction => 'Erneut versuchen';

  @override
  String get setupErrUnknownTitle => 'Etwas ist schiefgelaufen';

  @override
  String get setupErrUnknownBody => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get setupErrUnknownAction => 'Erneut versuchen';

  @override
  String get setupNoZ2mTitle =>
      'Dein Broker funktioniert, aber Zigbee2MQTT veröffentlicht hier nichts';

  @override
  String setupNoZ2mBody(String base) {
    return 'Wir haben auf $base/bridge gelauscht und nichts gehört.';
  }

  @override
  String get setupBaseTopicQuestion => 'Anderes Basis-Topic?';

  @override
  String get setupGuidesTitle => 'Zigbee2MQTT einrichten';

  @override
  String get setupTryDemoMeanwhile => 'Solange die Demo ausprobieren';

  @override
  String get demoBannerText => 'Du bist im Demomodus';

  @override
  String get demoBannerAction => 'Dein Zuhause verbinden';

  @override
  String get deviceOn => 'An';

  @override
  String get deviceOff => 'Aus';

  @override
  String get deviceOpen => 'Offen';

  @override
  String get deviceClosed => 'Geschlossen';

  @override
  String get deviceMotion => 'Bewegung';

  @override
  String get deviceClear => 'Ruhig';

  @override
  String get deviceLeakDetected => 'Leck erkannt';

  @override
  String get deviceSmokeDetected => 'Rauch erkannt';

  @override
  String get deviceGasDetected => 'Gas erkannt';

  @override
  String get deviceWaiting => 'Wartet auf erste Meldung';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on an · $off aus';
  }

  @override
  String get deviceBrightness => 'Helligkeit';

  @override
  String get deviceWhite => 'Weiß';

  @override
  String get deviceColor => 'Farbe';

  @override
  String get deviceHue => 'Farbton';

  @override
  String get devicePosition => 'Position';

  @override
  String get deviceControls => 'Steuerung';

  @override
  String deviceBattery(int percent) {
    return 'Batterie $percent %';
  }

  @override
  String get deviceToggle => 'Ein- oder ausschalten';

  @override
  String get deviceMore => 'Mehr';

  @override
  String get sectionLights => 'Licht';

  @override
  String get sectionSwitchesCovers => 'Schalter und Rollos';

  @override
  String get sectionSensors => 'Sensoren';

  @override
  String get sectionOther => 'Sonstiges';

  @override
  String get homeFirstName => 'Mein Zuhause';

  @override
  String homeNumberedName(int number) {
    return 'Zuhause $number';
  }

  @override
  String get dashAddTile => 'Kachel hinzufügen';

  @override
  String get addTileSearch => 'Geräte suchen';

  @override
  String get addTileNotOnDashboard => 'Auf keinem Dashboard';

  @override
  String get addTileAllDevices => 'Alle Geräte';

  @override
  String get addTileReading => 'Messwert';

  @override
  String get addTileReadingSubtitle => 'Ein Wert von einem Gerät oder Topic';

  @override
  String get addTileCustom => 'Eigene MQTT-Kachel';

  @override
  String get addTileCustomSubtitle => 'Jeder Kacheltyp, per Topic eingerichtet';

  @override
  String get addTileNoDevices =>
      'Keine Geräte. Verbinde dich mit deinem Broker oder kopple ein Gerät in Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Hinzufügen';

  @override
  String get addTileName => 'Name';

  @override
  String addTileNameHint(String model) {
    return 'z. B. $model';
  }

  @override
  String get addTileSection => 'Bereich';

  @override
  String get addTileNoSection => 'Kein Bereich';

  @override
  String get addTileSize => 'Größe';

  @override
  String get deviceClassColorLight => 'Farblicht';

  @override
  String get deviceClassLight => 'Licht';

  @override
  String get deviceClassSwitch => 'Schalter oder Steckdose';

  @override
  String get deviceClassCover => 'Rollo';

  @override
  String get deviceClassLeak => 'Leck oder Rauch';

  @override
  String get deviceClassContact => 'Kontakt';

  @override
  String get deviceClassMotion => 'Bewegung';

  @override
  String get deviceClassClimate => 'Klimasensor';

  @override
  String get deviceClassGeneric => 'Gerät';

  @override
  String get deviceNotResponding => 'Reagiert nicht';

  @override
  String get homeAdd => 'Zuhause hinzufügen';

  @override
  String get homeManage => 'Zuhause verwalten';

  @override
  String get homeSwitch => 'Zuhause wechseln';

  @override
  String get navDevices => 'Geräte';

  @override
  String get navScenes => 'Szenen';

  @override
  String get devicesNewDot => 'Neue Geräte';

  @override
  String get editEditing => 'Bearbeiten';

  @override
  String get editDashboard => 'Dashboard';

  @override
  String get editDone => 'Fertig';

  @override
  String get editAddSection => 'Bereich hinzufügen';

  @override
  String get editSectionName => 'Name des Bereichs';

  @override
  String get editRenameSection => 'Bereich umbenennen';

  @override
  String get editDeleteSection => 'Bereich löschen';

  @override
  String get editDeleteSectionBody => 'Was soll mit seinen Kacheln passieren?';

  @override
  String get editKeepTiles => 'Kacheln behalten, Bereich entfernen';

  @override
  String get editDeleteTiles => 'Kacheln auch löschen';

  @override
  String get editMoveToSection => 'In Bereich verschieben';

  @override
  String get editEditTile => 'Kachel bearbeiten';

  @override
  String get editRemove => 'Vom Dashboard entfernen';

  @override
  String get editRemoved => 'Kachel entfernt';

  @override
  String get editUndo => 'Rückgängig';

  @override
  String get editReplaceWithDevice => 'Durch Gerätekachel ersetzen';

  @override
  String get editMoveEarlier => 'Nach vorne';

  @override
  String get editMoveLater => 'Nach hinten';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte sind auf keinem Dashboard',
      one: '1 Gerät ist auf keinem Dashboard',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Kacheloptionen';

  @override
  String get editSave => 'Speichern';

  @override
  String get editCancel => 'Abbrechen';

  @override
  String get ageJustNow => 'Gerade eben';

  @override
  String ageMinutes(int n) {
    return 'vor $n Min.';
  }

  @override
  String ageHours(int n) {
    return 'vor $n Std.';
  }

  @override
  String get statusCantReach => 'Broker nicht erreichbar';

  @override
  String get statusWhy => 'Warum?';

  @override
  String get statusWhyTitle => 'Dein Broker antwortet nicht';

  @override
  String get statusWhyBody =>
      'ZigDash versucht es selbst weiter. Bis dahin zeigen die Kacheln ihre letzten bekannten Werte, abgeblendet und mit Alter. Prüfe, ob der Broker läuft und das Handy im selben Netz ist, oder teste die Verbindung in ihren Einstellungen.';

  @override
  String get statusSettings => 'Verbindungseinstellungen';

  @override
  String get deviceAddToDashboard => 'Zu einem Dashboard hinzufügen';

  @override
  String get deviceDismiss => 'Ausblenden';

  @override
  String get devicesFilterAll => 'Alle';

  @override
  String devicesFilterAttention(int count) {
    return 'Braucht Aufmerksamkeit · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Auf keinem Dashboard · $count';
  }

  @override
  String get devicesNoMatch => 'Keine passenden Geräte';

  @override
  String get deviceBatteryLow => 'Akku schwach';

  @override
  String get deviceLinkWeak => 'Schwach';

  @override
  String get deviceUnsupported => 'Von Zigbee2MQTT nicht unterstützt';

  @override
  String get deviceInterviewFailed => 'Kopplung nicht abgeschlossen';

  @override
  String get deviceNoReport => 'Noch keine Meldung';

  @override
  String get devicesAvailabilityOff =>
      'Die Verfügbarkeit in Zigbee2MQTT ist aus, daher werden Offline-Geräte als „Reagiert nicht“ angezeigt.';

  @override
  String get devicesAvailabilityHow => 'So schaltest du sie ein';

  @override
  String get devicesDotBattery => 'Akku schwach';

  @override
  String get deviceDetails => 'Gerätedetails';

  @override
  String get deviceGone => 'Dieses Gerät ist nicht mehr in Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Steuerung';

  @override
  String get deviceReadingsTitle => 'Messwerte';

  @override
  String get deviceHealthTitle => 'Zustand';

  @override
  String get deviceOnDashboards => 'Auf Dashboards';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT unterstützt dieses Gerät noch nicht, daher gibt es nichts zu steuern.';

  @override
  String get deviceAddReadingTile => 'Als Messwert-Kachel hinzufügen';

  @override
  String get deviceAddReadingTo => 'Zu welchem Dashboard hinzufügen?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Zu $dashboard hinzugefügt';
  }

  @override
  String get deviceLinkQuality => 'Linkqualität';

  @override
  String get deviceLinkGood => 'Gut';

  @override
  String get devicePowerSource => 'Stromquelle';

  @override
  String get devicePowerBattery => 'Akku';

  @override
  String get devicePowerMains => 'Netzstrom';

  @override
  String get deviceLastHeard => 'Zuletzt gehört';

  @override
  String get deviceAvailability => 'Verfügbarkeit';

  @override
  String get deviceAvailabilityOff => 'In Zigbee2MQTT aus';

  @override
  String get settingsPrivacy => 'Datenschutzerklärung';

  @override
  String get settingsPrivacySubtitle =>
      'Keine Telemetrie. Alles bleibt auf diesem Handy.';

  @override
  String get homeCurrent => 'Aktuelles Zuhause';

  @override
  String get homeConnection => 'Verbindung';

  @override
  String get homeSwitchTo => 'Zu diesem Zuhause wechseln';

  @override
  String get homeDelete => 'Zuhause löschen';

  @override
  String get devicesSelect => 'Wähle ein Gerät';

  @override
  String get scenesSelect => 'Wähle eine Szene zum Bearbeiten';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'Gerät auswählen';

  @override
  String get panelFormStateTopic => 'Status-Topic';

  @override
  String get panelFormCommandTopic => 'Befehls-Topic';

  @override
  String get panelFormCommandTopicDerived =>
      'Wird aus dem Status-Topic übernommen, bis du es änderst.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Verknüpft mit $device';
  }

  @override
  String get panelFormOpenDevice => 'Gerät öffnen';

  @override
  String get panelFormUnlink => 'Verknüpfung lösen';

  @override
  String get panelFormValueChoices => 'Werte von diesem Gerät';

  @override
  String get panelFormAdvanced => 'Erweitert';

  @override
  String get panelFormAdvancedSubtitle => 'Präfix-Überschreibung, QoS, Retain';

  @override
  String get panelFormStateTopicHelper =>
      'Leer = das Präfix selbst (Status eines Zigbee2MQTT-Geräts).';

  @override
  String get dashWallDisplay => 'Wandanzeige';

  @override
  String get analyticsSetupCheckbox =>
      'Anonyme Nutzungsdaten teilen, um die Einrichtung zu verbessern';

  @override
  String get analyticsWhatsShared => 'Was geteilt wird';

  @override
  String get analyticsCardTitle => 'ZigDash verbessern helfen?';

  @override
  String get analyticsCardBody =>
      'Anonyme Nutzungsdaten teilen: welche Einrichtungsschritte scheitern und welche Funktionen genutzt werden. Nie deine Geräte, Topics oder dein Broker.';

  @override
  String get analyticsShare => 'Teilen';

  @override
  String get analyticsNoThanks => 'Nein danke';

  @override
  String get settingsAnalytics => 'Anonyme Nutzungsdaten teilen';

  @override
  String get settingsAnalyticsSubtitle =>
      'Einrichtungsschritte und genutzte Funktionen. Nie deine Geräte, Topics oder dein Broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Anonyme Nutzungsdaten nur mit deiner Zustimmung.';

  @override
  String get dashDefaultName => 'Zuhause';

  @override
  String get dashExportSaveFile => 'Datei speichern';

  @override
  String get dashExportSaved => 'Sicherung gespeichert';

  @override
  String get dashImportChooseFile => 'Datei wählen';

  @override
  String get dashImportFileUnreadable =>
      'Die Datei konnte nicht gelesen werden';
}
