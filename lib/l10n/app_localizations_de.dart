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
  String get connUsername => 'Benutzername';

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
  String get dashFormLock => 'Bearbeitungssperre';

  @override
  String get dashFormLockSubtitle =>
      'Blendet Bearbeiten für dieses Dashboard aus';

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
  String get settingsFeatureRequest => 'Funktion vorschlagen';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Sag mir, was ZigDash besser machen würde.';

  @override
  String get featureRequestGithub => 'Auf GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Öffentlich: Andere können es sehen und dafür stimmen.';

  @override
  String get featureRequestEmail => 'Per E-Mail';

  @override
  String get featureRequestEmailSubtitle => 'Privat, direkt an den Entwickler.';

  @override
  String get featureRequestEmailSubject => 'ZigDash: Funktionswunsch';

  @override
  String get featureRequestEmailPrompt => 'Was soll ZigDash können, und warum?';

  @override
  String get settingsReportProblem => 'Problem melden';

  @override
  String get settingsReportProblemSubtitle =>
      'Etwas kaputt oder unklar? Sag es mir.';

  @override
  String get reportProblemEmailSubject => 'ZigDash: Problembericht';

  @override
  String get reportProblemEmailPrompt =>
      'Was ist passiert, und was hast du erwartet?';

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
  String get devicesListMissing =>
      'Zigbee2MQTT hat seine Geräteliste nicht gesendet. Das kann nach einem Neustart des MQTT-Brokers passieren.';

  @override
  String get devicesRestartZ2m => 'Zigbee2MQTT neu starten';

  @override
  String get devicesRestartingZ2m =>
      'Zigbee2MQTT wird neu gestartet. Deine Geräte sollten in ein paar Sekunden erscheinen.';

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
  String get scenesAllShutters => 'Alle Rollläden';

  @override
  String get sceneCloseAllShutters => 'Alle Rollläden schließen';

  @override
  String get sceneOpenAllShutters => 'Alle Rollläden öffnen';

  @override
  String get sceneStopAllShutters => 'Alle Rollläden stoppen';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rollläden',
      one: '1 Rollladen',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Welche Rollläden…';

  @override
  String get sceneWhichShuttersHint =>
      'Alle Rollläden dieses Zuhauses sind dabei. Hake ab, was draußen bleiben soll, etwa ein Garagentor.';

  @override
  String get scenesYours => 'Deine Szenen';

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
      'Der Broker hat die Verbindung nicht angenommen. Prüfen Sie, ob Ihr MQTT-Broker (meist Mosquitto) läuft und Verbindungen von anderen Geräten annimmt und ob Adresse und Port (meist 1883) stimmen.';

  @override
  String get diagTcpTimeout =>
      'Zeitüberschreitung beim Verbinden. Der Broker ist möglicherweise offline oder nicht erreichbar.';

  @override
  String get diagConnackFail =>
      'Der Broker hat den MQTT-Handshake nicht abgeschlossen. Stellen Sie sicher, dass es ein MQTT-Broker ist (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'Der Broker hat nicht rechtzeitig auf die Anmeldung geantwortet. Home Assistant braucht manchmal ein paar Sekunden zum Prüfen, versuche es noch einmal.';

  @override
  String get diagAuthRejected =>
      'Der Broker hat Benutzername oder Passwort abgelehnt. Prüfen Sie Ihre Zugangsdaten.';

  @override
  String get diagAuthRefused =>
      'Der Broker hat die Verbindung abgelehnt. Prüfen Sie die Verbindungseinstellungen.';

  @override
  String get diagResolveLocalName =>
      'Ihr Telefon konnte diesen Namen nicht finden. Android kann Namen mit .local oft nicht auflösen. Geben Sie stattdessen die IP-Adresse ein (Home Assistant zeigt sie unter Einstellungen › System › Netzwerk).';

  @override
  String get diagTcpHaNoBroker =>
      'Das ist Ihr Home Assistant, aber darauf läuft kein MQTT-Broker. Installieren und starten Sie das Add-on „Mosquitto broker“ (Einstellungen › Add-ons) und versuchen Sie es erneut.';

  @override
  String get diagTcpSmlightClosed =>
      'Das ist Ihr SMLIGHT-Hub, aber sein MQTT-Broker nimmt keine Verbindungen von anderen Geräten an. Öffnen Sie auf der Weboberfläche des Hubs Settings › MQTT, schalten Sie Allow External ein, speichern Sie und versuchen Sie es erneut.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Unter dieser Adresse läuft Zigbee2MQTT, aber es erreicht seinen Broker unter einem anderen Namen (siehe Zigbee2MQTT › Settings › MQTT › Server). Ist das ein anderer Rechner, gib dessen Adresse ein, meist mit Port 1883. Ist es ein Container auf diesem Rechner, veröffentliche seinen Port (ports: \"1883:1883\") und lass ihn im Netzwerk lauschen, dann versuche es erneut.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Unter dieser Adresse läuft Zigbee2MQTT, aber sein MQTT-Broker nimmt keine Verbindungen von anderen Geräten an. Mosquitto lauscht nur auf dem eigenen Rechner, bis Sie die Zeilen „listener 1883“ und „allow_anonymous true“ in mosquitto.conf eintragen (oder ein Passwort einrichten). Starten Sie Mosquitto neu und versuchen Sie es erneut.';

  @override
  String get diagAuthRejectedHa =>
      'Der Broker von Home Assistant hat diese Anmeldung abgelehnt. Verwenden Sie Name und Passwort eines Home-Assistant-Benutzers (Einstellungen › Personen › Benutzer); am besten einen eigenen Benutzer nur für MQTT.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte gefunden',
      one: '1 Gerät gefunden',
    );
    return '$_temp0';
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
  String get guidedStuckTitle => 'Hängst du fest? Frag einen Menschen';

  @override
  String get guidedStuckBody =>
      'Zwei Versuche ohne Verbindung. Sag uns, welchen Hub du hast und was du eingegeben hast, und wir helfen dir, ihn zu finden.';

  @override
  String get guidedStuckTelegram => 'In Telegram fragen';

  @override
  String get guidedStuckHelp => 'Tipps und E-Mail';

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
  String get setupWelcomeHeadline => 'Dein Zigbee-Zuhause, auf deinem Handy';

  @override
  String get setupWelcomeBody =>
      'Ein kleiner Hub mit Zigbee2MQTT ist alles, was du brauchst: ein SMLIGHT-Hub, ein Raspberry Pi oder ein beliebiger Linux-Rechner. Kein Home Assistant nötig, und wenn du es hast, funktioniert ZigDash auch damit. Alles bleibt lokal, ohne Cloud.';

  @override
  String get setupFindMySetup => 'Mein Setup finden';

  @override
  String get setupErrPageTitle => 'Die Zigbee2MQTT-Seite hat nicht geantwortet';

  @override
  String get setupErrPageBody =>
      'Unter dieser Adresse hat keine Zigbee2MQTT-Seite geantwortet. Öffne sie im Browser dieses Handys, um sie zu prüfen, und kopiere die Adresse genau (mit Port, oft 8080). Wenn die Seite ein Token verlangt, gib stattdessen deine Broker-Daten ein.';

  @override
  String get setupErrPageAction => 'Noch einmal versuchen';

  @override
  String get setupLookWider => 'Im ganzen Netzwerk suchen';

  @override
  String get setupAsk => 'Was steuert dein Zigbee?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub =>
      'Auf einem Raspberry Pi, einem Server oder in Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'Mit dem Zigbee2MQTT-Add-on oder ZHA';

  @override
  String get setupAskSmlight => 'Ein SMLIGHT-Hub';

  @override
  String get setupAskSmlightSub => 'SLZB oder SMHUB mit Zigbee2MQTT';

  @override
  String get setupAskNothing => 'Noch nichts?';

  @override
  String get setupAskHaWhich => 'Wie betreibt dein Home Assistant Zigbee?';

  @override
  String get setupAskHaZ2m => 'Das Zigbee2MQTT-Add-on';

  @override
  String get setupAskHaZ2mSub => 'Mit Home Assistant anmelden';

  @override
  String get setupAskHaZha => 'ZHA, das eigene Zigbee von Home Assistant';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, ohne Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Mit meiner Zigbee2MQTT-Seite verbinden';

  @override
  String get setupManualEntryAdvanced =>
      'Broker-Daten eingeben (für Fortgeschrittene)';

  @override
  String get z2mPageTitle => 'Deine Zigbee2MQTT-Seite';

  @override
  String get z2mPageBody =>
      'Die Adresse in deinem Browser, wenn die Zigbee2MQTT-Seite offen ist – die, auf der du Geräte anlernst. Kein MQTT-Benutzername oder -Passwort nötig.';

  @override
  String get z2mPageLabel => 'Adresse der Seite';

  @override
  String get z2mPageConnect => 'Verbinden';

  @override
  String z2mPageFoundName(String host, String ip) {
    return '$host gefunden unter $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Für $host hat in diesem Netzwerk nichts geantwortet';
  }

  @override
  String get engineNeedsBrokerTitle =>
      'Automationen brauchen deinen MQTT-Broker';

  @override
  String get engineNeedsBrokerBody =>
      'Dieses Zuhause verbindet sich über die Zigbee2MQTT-Seite, das reicht für deine Dashboards. Automationen, Alarme und Verlauf laufen in der ZigDash Engine auf deinem Hub, und die spricht über deinen MQTT-Broker. Gib seine Daten einmal ein, dann verbindet sich ZigDash ab dann über den Broker.';

  @override
  String get engineNeedsBrokerButton => 'Broker-Daten eingeben';

  @override
  String get connFromPageNote =>
      'Dieses Zuhause verbindet sich über die Zigbee2MQTT-Seite. Gib deinen MQTT-Broker ein (meist dasselbe Gerät, Port 1883), um Automationen, Alarme und Verlauf einzuschalten. Nach dem Speichern verbindet sich ZigDash über den Broker.';

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
  String get reminderButton => 'Morgen erinnern';

  @override
  String get reminderSet => 'Wir erinnern dich morgen, auf diesem Telefon.';

  @override
  String get reminderNoPermission =>
      'Benachrichtigungen sind für ZigDash aus, daher gibt es keine Erinnerung. Du kannst sie in den Android-Einstellungen einschalten.';

  @override
  String get reminderChannel => 'Einrichtungserinnerung';

  @override
  String get reminderTitle => 'ZigDash fertig einrichten';

  @override
  String get reminderBody =>
      'Zu Hause in deinem WLAN? Tippe, um es erneut zu versuchen: Es dauert etwa eine Minute.';

  @override
  String get setupWelcomeNoZ2m => 'Noch kein Zigbee2MQTT?';

  @override
  String get setupWelcomeDemo => 'Demo-Zuhause ausprobieren';

  @override
  String get setupWelcomeHubs => 'Welcher Hub passt';

  @override
  String get haConnectTitle => 'Über Home Assistant verbinden';

  @override
  String get haConnectIntro =>
      'Dein Telefon erreicht den Broker nicht, aber Home Assistant schon. Melde dich einmal an, und ZigDash spricht über Home Assistant mit Zigbee2MQTT: zu Hause oder unterwegs, ohne Broker-Einstellungen.';

  @override
  String get haConnectAddressHelp =>
      'Die Adresse, mit der du Home Assistant öffnest: 192.168.1.20:8123 oder eine Fernzugriffsadresse wie deine Nabu-Casa- oder Cloudflare-Adresse';

  @override
  String get haConnectSignInHelp =>
      'Die Anmeldung von Home Assistant öffnet sich in deinem Browser. ZigDash sieht dein Passwort nie.';

  @override
  String get haConnectKeeps =>
      'ZigDash behält diese Anmeldung auf deinem Telefon und handelt in Home Assistant als du, nur für MQTT. Beende das jederzeit in Home Assistant unter Profil › Sicherheit.';

  @override
  String get haConnectTokenHelp =>
      'Öffne in Home Assistant dein Profil, dann Sicherheit › Langlebige Zugangstoken › Token erstellen. Kopiere ihn und füge ihn hier ein. ZigDash behält ihn auf diesem Telefon zum Verbinden; lösche ihn in Home Assistant, wann immer du das beenden willst.';

  @override
  String get haConnectWithToken => 'Mit Token verbinden';

  @override
  String get haConnectChecking => 'Home Assistant wird geprüft…';

  @override
  String get setupStillChecking =>
      'Wird noch geprüft. Das kann bis zu 30 Sekunden dauern.';

  @override
  String get aiHelpTitle => 'Hängst du fest? Frag deinen KI-Assistenten';

  @override
  String get aiHelpBody =>
      'ZigDash fasst zusammen, was es gefunden hat, für ChatGPT, Claude, Gemini oder jede KI-App, ohne Passwörter oder Adressen. Du siehst es, bevor es geteilt wird.';

  @override
  String get aiHelpButton => 'KI fragen';

  @override
  String get aiHelpPreviewTitle => 'Was geteilt wird';

  @override
  String get aiHelpShare => 'An eine KI-App teilen';

  @override
  String get aiHelpCopied =>
      'Kopiert. Füge es in einen beliebigen KI-Chat ein.';

  @override
  String get haConnectWhereAddress =>
      'Nicht sicher, welche? Öffne in der Home-Assistant-App Einstellungen › Companion App und tippe auf deinen Server: Dort steht die Adresse. Am Computer ist es die Adresse, die der Browser bei geöffnetem Home Assistant zeigt.';

  @override
  String get haFindLooking => 'Suche Home Assistant in diesem Netzwerk…';

  @override
  String get haFindSeveral =>
      'Mehr als ein Home Assistant gefunden. Tippe auf den gewünschten:';

  @override
  String get haFindNone =>
      'Dieses Handy sieht Home Assistant in diesem WLAN nicht. Nimm die Adresse, die deine Home-Assistant-App öffnet: oft eine Fernzugriffsadresse wie https://abcd1234.ui.nabu.casa oder https://meinzuhause.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Diese Adresse liegt in einem anderen Netzwerk als dieses Handy, das in $network ist. Nimm die Adresse, die deine Home-Assistant-App öffnet, oft eine Fernzugriffsadresse, oder verbinde das Handy mit dem Netzwerk von Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Dieses Handy hat den Namen nicht gefunden: Android kann .local-Namen oft nicht öffnen. Gib die IP-Adresse von Home Assistant ein (z. B. 192.168.1.20:8123) oder seine Fernzugriffsadresse.';

  @override
  String get haConnectRemoteUnreachable =>
      'Unter dieser Fernzugriffsadresse hat nichts geantwortet. Öffne sie im Browser dieses Handys, um zu prüfen, ob sie funktioniert, und kopiere sie genau so, wie deine Home-Assistant-App sie zeigt.';

  @override
  String get setupNoWifiHa => 'Home Assistant? Anmelden';

  @override
  String get haConnectNotAdmin =>
      'Dein Home-Assistant-Benutzer ist kein Administrator. ZigDash braucht einen für das MQTT von Home Assistant. Melde dich als Administrator an oder füge einen Token ein, den ein Administrator erstellt hat.';

  @override
  String get haConnectNoMqtt =>
      'Dieses Home Assistant hat keine MQTT-Integration. Zigbee2MQTT braucht auch eine: Füge in Home Assistant das Mosquitto-Broker-Add-on und die MQTT-Integration hinzu und versuche es dann erneut.';

  @override
  String get haConnectSignInFailed =>
      'Die Anmeldung wurde nicht abgeschlossen. Versuche es erneut oder nutze einen langlebigen Token.';

  @override
  String get setupHaShortcut =>
      'Zigbee2MQTT läuft in Home Assistant? Broker und MQTT-Login überspringen: mit Ihrem Home-Assistant-Administratorkonto anmelden. Das klappt aus jedem Netzwerk.';

  @override
  String get haConnectButton => 'Über Home Assistant verbinden';

  @override
  String get haConnectManualLink =>
      'Nutzt du Home Assistant? Verbinde dich stattdessen darüber';

  @override
  String get haConnectEmptyNote =>
      'Erreicht dieses Telefon den Broker nicht? Home Assistant kann die Verbindung für dich übernehmen.';

  @override
  String get haHomeConnected => 'Verbunden über Home Assistant';

  @override
  String get haHomeChange =>
      'Wenn die Anmeldung nicht mehr funktioniert, auf einem neuen Telefon oder nachdem du den Token in Home Assistant entfernt hast, melde dich hier erneut an. Beenden kannst du sie auch in Home Assistant unter Profil › Sicherheit.';

  @override
  String get haHomeSignInAgain => 'Erneut anmelden';

  @override
  String get haHomeRemote =>
      'Fernzugriffsadresse von Home Assistant (optional)';

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
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT meldet sich bereits bei diesem Broker an: Seine Weboberfläche zeigt den Benutzernamen unter Einstellungen › MQTT. Nutze diesen Benutzer und sein Passwort.';

  @override
  String get setupAuthWhich =>
      'Das ist der MQTT-Login, nicht das Passwort der Weboberfläche deines Hubs.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: verwende einen Home-Assistant-Benutzer. Die meisten legen unter Einstellungen › Personen › Benutzer einen eigenen für MQTT an; das Mosquitto-Add-on akzeptiert ihn.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi oder Docker: Benutzer und Passwort aus der Passwortdatei von Mosquitto, dieselben wie in der configuration.yaml von Zigbee2MQTT unter mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: der Login auf der Weboberfläche des Hubs unter Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'Verbindung wird geprüft…';

  @override
  String get setupReviewTitle => 'Deine Geräte';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte gefunden.',
      one: '1 Gerät gefunden.',
    );
    return '$_temp0 Wähle, was auf dein erstes Dashboard kommt.';
  }

  @override
  String get setupReviewLastStep =>
      'Letzter Schritt: Hake die gewünschten Geräte an und tippe unten auf Dashboard erstellen.';

  @override
  String get setupLeaveTitle => 'Dashboard erstellen?';

  @override
  String get setupLeaveBody =>
      'Deine Geräte sind gefunden. Erstelle das Dashboard jetzt oder beginne die Einrichtung neu und verliere diese Liste.';

  @override
  String get setupStartOver => 'Neu beginnen';

  @override
  String setupCreateWithCount(Object count) {
    return 'Dashboard mit $count erstellen';
  }

  @override
  String get setupReviewNoneSelected =>
      'Noch nichts ausgewählt. Wähle die Geräte für dein Dashboard aus, oder erstelle es leer und füge Kacheln später hinzu.';

  @override
  String get setupCreateEmpty => 'Leeres Dashboard erstellen';

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
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT hat seine Geräteliste nicht gesendet';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT antwortet, aber seine Geräteliste kam nicht. Das passiert meist nach einem Neustart des MQTT-Brokers: Zigbee2MQTT vor 2.14.2 sendet die Liste erst nach einem eigenen Neustart wieder. Starte Zigbee2MQTT neu (oder aktualisiere es) und versuche es dann noch einmal.';

  @override
  String get setupErrListMissingAction => 'Noch einmal versuchen';

  @override
  String get setupErrHaNoZ2mTitle =>
      'Kein Zigbee2MQTT in diesem Home Assistant';

  @override
  String get setupErrHaNoZ2mBody =>
      'Du bist bei Home Assistant angemeldet, aber Zigbee2MQTT sendet nichts über dessen MQTT. Wenn deine Zigbee-Geräte in ZHA sind (dem eingebauten Zigbee von Home Assistant), kann ZigDash sie nicht sehen: Es arbeitet mit Zigbee2MQTT. Wenn du das Zigbee2MQTT-Add-on nutzt, öffne es in Home Assistant, prüfe, ob es läuft, und versuche es dann noch einmal.';

  @override
  String get setupErrHaNoZ2mAction => 'Noch einmal versuchen';

  @override
  String get setupErrScanFailedTitle => 'Kein lokales Netzwerk';

  @override
  String get setupErrScanFailedBody =>
      'Das lokale Netzwerk dieses Geräts konnte nicht ermittelt werden. Verbinde dich mit WLAN und versuche es erneut.';

  @override
  String get setupErrScanFailedAction => 'Erneut versuchen';

  @override
  String get setupNoWifiTitle => 'Dein Handy ist nicht im WLAN';

  @override
  String get setupNoWifiMobileData =>
      'Es nutzt mobile Daten und sieht deshalb die Geräte zu Hause nicht. Schalte WLAN ein und verbinde dich mit deinem Heimnetz: Die Einrichtung startet dann von selbst neu.';

  @override
  String get setupNoWifiOffline =>
      'Dein Handy hat keine Netzwerkverbindung. Schalte WLAN ein und verbinde dich mit deinem Heimnetz: Die Einrichtung startet dann von selbst neu.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash findet die WLAN-Adresse deines Handys nicht. Prüfe, ob WLAN an und mit deinem Heimnetz verbunden ist: Die Einrichtung startet dann von selbst neu. Im VPN oder unterwegs? Gib die Daten manuell ein.';

  @override
  String get setupOpenWifiSettings => 'WLAN-Einstellungen öffnen';

  @override
  String get setupWaitingForWifi => 'Warte auf WLAN…';

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
  String get setupErrLoginNoAnswerTitle =>
      'Der Broker hat nicht auf die Anmeldung geantwortet';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Dein Broker wurde gefunden, hat aber nicht rechtzeitig auf Benutzername und Passwort geantwortet. Das Mosquitto-Add-on von Home Assistant prüft Anmeldungen über Home Assistant, was auf einem Raspberry Pi ein paar Sekunden dauern kann. Versuche es noch einmal und prüfe, ob dieser Benutzer in Home Assistant existiert.';

  @override
  String get setupErrLoginNoAnswerAction => 'Erneut versuchen';

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
  String get setupPlatformQuestion =>
      'Während wir suchen: Wo läuft Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => 'Wo läuft Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Wähle eine Verbindung';

  @override
  String get setupScanDoneHint =>
      'Mehr als ein Broker hat geantwortet. Wähle den, den Zigbee2MQTT nutzt.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'SMLIGHT-Hub';

  @override
  String get setupPlatformPi => 'Raspberry Pi oder Docker';

  @override
  String get setupPlatformZha => 'ZHA, kein Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash zeigt Geräte aus Zigbee2MQTT und sieht daher keine Geräte in ZHA, dem eigenen Zigbee von Home Assistant. Probiere das Demo-Zuhause aus, um zu sehen, wie ZigDash funktioniert.';

  @override
  String get setupPlatformNotSure => 'Weiß nicht';

  @override
  String setupScanProgress(int checked, int total) {
    return '$checked von $total Adressen geprüft';
  }

  @override
  String get setupScanHintHa => 'Suche Home Assistant und seinen MQTT-Broker…';

  @override
  String get setupScanHintSmlight => 'Suche deinen SMLIGHT-Hub…';

  @override
  String get setupScanHintPi => 'Suche einen MQTT-Broker in deinem Netzwerk…';

  @override
  String setupHubSeenHa(String host) {
    return 'Home Assistant unter $host gefunden';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Zigbee2MQTT unter $host gefunden';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Deinen SMLIGHT-Hub unter $host gefunden';
  }

  @override
  String get setupHubSeenHint => 'Suche noch seinen MQTT-Broker…';

  @override
  String get setupNoBrokerHaTitle =>
      'Home Assistant gefunden, aber kein MQTT-Broker';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant läuft unter $host, aber auf MQTT-Port 1883 antwortet nichts. Öffne in Home Assistant Einstellungen › Add-ons, installiere und starte das Mosquitto-Broker-Add-on und versuche es dann erneut.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Nutzt du das eingebaute Zigbee von Home Assistant (ZHA) statt Zigbee2MQTT? ZigDash funktioniert nur mit Zigbee2MQTT und sieht ZHA-Geräte daher nicht. Die Demo zeigt, was du bekommen würdest.';

  @override
  String get setupVpnHint =>
      'Ein VPN ist aktiv und kann dein Heimnetz vor der Suche verbergen. Wenn du zu Hause bist, schalte das VPN aus und tippe auf Erneut versuchen. Oder lass es an und erlaube in den Einstellungen der VPN-App den Zugriff aufs lokale Netzwerk (LAN).';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Zigbee2MQTT gefunden, aber sein Broker ist nicht erreichbar';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT läuft unter $host, aber sein MQTT-Broker nimmt keine Verbindungen von deinem Handy an. Mosquitto 2 hört nur auf dem Hub selbst, bis in seiner Konfiguration \'listener 1883\' und \'allow_anonymous true\' (oder ein Login) stehen. Starte ihn neu und versuche es dann erneut.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'SMLIGHT-Hub gefunden, aber MQTT ist aus';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Dein Hub läuft unter $host, aber sein MQTT-Broker ist nicht erreichbar. Öffne in der Web-Oberfläche des Hubs Settings › MQTT, schalte Allow External ein und prüfe, dass Zigbee2MQTT läuft. Dann versuche es erneut.';
  }

  @override
  String get setupZ2mAsking => 'Frage Zigbee2MQTT, wo sein Broker ist…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Dein Broker nimmt nur Verbindungen vom eigenen Gerät an';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT nutzt $server, und von deinem Handy aus antwortet dort nichts. Mosquitto 2 macht das standardmäßig so. Füge diese zwei Zeilen in mosquitto.conf ein, starte Mosquitto neu und versuche es dann erneut:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Lieber mit Login statt offenem Zugang? Nutze eine password_file statt allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT erreicht seinen Broker über einen Namen, den dein Handy nicht nutzen kann';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT nutzt $server. „$name“ ist ein Name, den nur der Rechner von Zigbee2MQTT kennt, ein Docker-Dienst oder ein Hostname. Gib stattdessen die IP-Adresse des Broker-Rechners mit Port $port ein. Läuft der Broker in einem Container, muss sein Port auch auf dem Rechner veröffentlicht sein (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'Die Webseite von Zigbee2MQTT ist mit einem Token geschützt, daher konnte die App nicht lesen, wo ihr Broker ist. Gib die Broker-Adresse aus den Zigbee2MQTT-Einstellungen › MQTT ein.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT nutzt den Broker unter $server, aber er hat deinem Handy nicht geantwortet. Prüfe, ob der Broker läuft und dein Handy im selben Netzwerk ist.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Mit $host verbinden';
  }

  @override
  String get setupNotFoundHa =>
      'Kein Home Assistant in diesem Netzwerk gefunden. Prüfe, ob dein Handy im selben WLAN wie Home Assistant ist (kein Gast-WLAN), und versuche es erneut. Wenn du die Adresse kennst, gib sie unten ein.';

  @override
  String get setupNotFoundSmlight =>
      'Kein SMLIGHT-Hub in diesem Netzwerk gefunden. Prüfe, ob der Hub eingeschaltet und dein Handy im selben WLAN ist, und versuche es erneut. Wenn du die Adresse kennst, gib sie unten ein.';

  @override
  String get setupNotFoundPi =>
      'Kein MQTT-Broker in diesem Netzwerk gefunden. Prüfe, ob Mosquitto läuft und im Netzwerk lauscht (Port 1883) und ob dein Handy im selben WLAN ist. Dann versuche es erneut.';

  @override
  String get setupAddressQuestionHa => 'Wo öffnest du Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'Wie lautet die Adresse deines SMLIGHT-Hubs?';

  @override
  String get setupAddressQuestionPi =>
      'Wie lautet die Adresse des Rechners, auf dem Mosquitto läuft?';

  @override
  String get setupAddressQuestionAny =>
      'Wie lautet die Adresse deines Hubs oder des Rechners, auf dem Zigbee2MQTT läuft?';

  @override
  String get setupAddressHint =>
      'Eine Adresse wie 192.168.1.20, ein Name oder der Link aus deinem Browser';

  @override
  String get setupAddressCheck => 'Diese Adresse prüfen';

  @override
  String setupAddressNothing(String host) {
    return 'Unter $host hat nichts geantwortet. Prüfe die Adresse und ob dein Handy im selben WLAN ist.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return '$host konnte nicht aufgelöst werden. Namen auf .local scheitern unter Android oft; versuche stattdessen die IP-Adresse. Home Assistant zeigt sie unter Einstellungen › System › Netzwerk.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host ist von diesem Telefon aus nicht auffindbar; Android kann .local-Namen oft nicht auflösen. Tippe oben auf $button und nutze die Adresse, mit der du Home Assistant im Browser öffnest, oder gib hier die IP-Adresse ein. Home Assistant zeigt sie unter Einstellungen › System › Netzwerk.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host liegt nicht in deinem Heimnetz. Verwende die Adresse, die in deinem WLAN funktioniert, keinen Fernzugriffslink wie Nabu Casa oder DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Gib zuerst eine Adresse ein.';

  @override
  String get setupChoicesTitle => 'Was davon passt zu dir?';

  @override
  String get setupChoiceNoHub => 'Ich habe noch keinen Hub';

  @override
  String get setupChoiceNoHubSub =>
      'Kleine Hubs ansehen, auf denen Zigbee2MQTT läuft';

  @override
  String get setupChoiceHa => 'Ich nutze Home Assistant';

  @override
  String get setupChoiceHaSub => 'Unter homeassistant.local suchen';

  @override
  String get setupChoiceHaNote =>
      'ZigDash verbindet sich mit dem MQTT-Broker von Home Assistant, dem Mosquitto-Broker-Add-on unter Einstellungen › Add-ons, und Zigbee2MQTT muss ihn ebenfalls nutzen. Wird homeassistant.local nicht gefunden, gib unten die IP-Adresse von Home Assistant ein. Sie steht unter Einstellungen › System › Netzwerk.';

  @override
  String get setupChoiceOther => 'Mein Hub ist in einem anderen Netzwerk';

  @override
  String get setupChoiceOtherSub => 'Ein Gast-WLAN oder ein zweiter Router';

  @override
  String get setupChoiceOtherNote =>
      'Dein Handy muss deinen Hub erreichen können. Ein Gast-WLAN oder ein zweiter Router mit eigenem WLAN trennt die beiden. Verbinde dich mit dem WLAN, in dem dein Hub ist, und tippe auf Erneut versuchen. Oder gib unten die IP-Adresse des Hubs ein oder probiere einen dieser üblichen Namen:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Dein Handy hat $ip, der Hub beginnt also meist mit $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Nutzt du Home Assistant? Der Host ist die Adresse, mit der du Home Assistant öffnest, Port 1883.';

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
  String get readingShowAs => 'Anzeigen als';

  @override
  String get readingStyleValue => 'Wert';

  @override
  String get readingStyleGauge => 'Messanzeige';

  @override
  String get gaugeBands => 'Farbbereiche';

  @override
  String get gaugeBandsHelper =>
      'Bis zu drei. Der Bereich, in dem der Wert liegt, färbt den Bogen.';

  @override
  String get gaugeBandFrom => 'Von';

  @override
  String get gaugeBandTo => 'Bis';

  @override
  String get gaugeBandAdd => 'Bereich hinzufügen';

  @override
  String get gaugeBandRemove => 'Bereich entfernen';

  @override
  String get gaugeToneNormal => 'Normal';

  @override
  String get gaugeToneGood => 'Gut';

  @override
  String get gaugeToneAttention => 'Achtung';

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
      'Anonyme Nutzungsdaten. Mit dem Schalter oben abschaltbar.';

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

  @override
  String get getHelpTitle => 'Hilfe holen';

  @override
  String get getHelpTryFirst => 'Probier zuerst das';

  @override
  String get getHelpPromise =>
      'Kommst du immer noch nicht weiter? Ich antworte meist innerhalb von 3 Tagen, auf Englisch oder Hebräisch. Ich frage nie nach deinen Passwörtern.';

  @override
  String get getHelpIncluded => 'Was mitgeschickt wird';

  @override
  String get getHelpContact => 'Support kontaktieren';

  @override
  String get getHelpCopy => 'Details kopieren';

  @override
  String get getHelpCopied => 'Details kopiert';

  @override
  String get getHelpLink => 'Kommst du nicht weiter? Hilfe holen';

  @override
  String get getHelpEmailSubject => 'ZigDash: Hilfe, damit es läuft';

  @override
  String get getHelpEmailPrompt => 'Was wolltest du tun, und was ist passiert?';

  @override
  String get settingsHelpSupport => 'Hilfe & Support';

  @override
  String get settingsGetHelp => 'Hilfe holen';

  @override
  String get settingsGetHelpSubtitle =>
      'Klappt es nicht? Erst Tipps, dann Kontakt';

  @override
  String get settingsCommunity => 'Der ZigDash-Community beitreten';

  @override
  String get settingsCommunitySubtitle =>
      'Telegram-Gruppe: Fragen, Ideen und was kommt';

  @override
  String get getHelpCommunity => 'In der Telegram-Gruppe fragen';

  @override
  String get demoBannerHelp => 'Hilfe holen';

  @override
  String get tipSameWifiTitle => 'Gleiches WLAN wie dein Hub';

  @override
  String get tipSameWifiBody =>
      'Dein Handy muss im selben Netz sein wie der Hub, nicht im Gastnetz. Schalte mobile Daten aus, solange du einrichtest.';

  @override
  String get tipBrokerRunningTitle => 'Der Broker läuft';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: Das Mosquitto-Add-on ist gestartet. Raspberry Pi: Mosquitto läuft. SMLIGHT: Settings › MQTT ist an.';

  @override
  String get tipBrokerAcceptsTitle => 'Der Broker lässt dein Handy zu';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: Aktiviere „Allow External“. Mosquitto 2 nimmt nur Verbindungen vom Hub selbst an, bis es so eingestellt ist, dass es im Netzwerk lauscht (Port 1883).';

  @override
  String get tipMeshTitle => 'Mesh-WLAN oder zwei Router?';

  @override
  String get tipMeshBody =>
      'Hängt der Hub an einem zweiten Router, sieht dein Handy ihn vielleicht nicht. Schließ den Hub am Hauptrouter an oder verbinde dich über seine Adresse.';

  @override
  String get tipByAddressTitle => 'Über die Adresse verbinden';

  @override
  String get tipByAddressBody =>
      'Such die Adresse des Hubs in der App deines Routers und tippe dann auf „Details manuell eingeben“.';

  @override
  String get tipSameNetworkTitle => 'Gleiches Netzwerk';

  @override
  String get tipSameNetworkBody =>
      'Handy und Hub müssen im selben WLAN sein. Schalte mobile Daten aus.';

  @override
  String get tipAddressChangedTitle => 'Die Adresse hat sich geändert';

  @override
  String get tipAddressChangedBody =>
      'Hubs können nach einem Neustart eine neue Adresse bekommen. Prüf sie in der App deines Routers und reserviere sie dort, damit sie gleich bleibt.';

  @override
  String get tipRightPortTitle => 'Der richtige Port';

  @override
  String get tipRightPortBody =>
      'MQTT nutzt meist 1883 (8883 mit TLS). 8080 oder 80 ist die Weboberfläche des Hubs, nicht MQTT.';

  @override
  String get tipStartBrokerTitle => 'Der Broker läuft';

  @override
  String get tipStartBrokerBody =>
      'Starte Mosquitto oder das Broker-Add-on und versuch es dann noch mal.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 nimmt nur Verbindungen vom Hub selbst an, bis es so eingestellt ist, dass es im Netzwerk lauscht (Port 1883).';

  @override
  String get tipMqttLoginTitle => 'Das MQTT-Login, nicht das Web-Login';

  @override
  String get tipMqttLoginBody =>
      'Das Passwort der Weboberfläche deines Hubs ist meist nicht das für MQTT. Home Assistant: Nimm einen Home-Assistant-Benutzer oder das Login aus dem Mosquitto-Add-on.';

  @override
  String get tipSpacesTitle => 'Auf Leerzeichen prüfen';

  @override
  String get tipSpacesBody =>
      'Beim Kopieren eines Passworts kann am Ende ein Leerzeichen hängen bleiben.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT nutzt diesen Broker';

  @override
  String get tipZ2mBrokerBody =>
      'Prüf in den Einstellungen von Zigbee2MQTT, dass sein MQTT-Server genau dieser Broker ist.';

  @override
  String get tipBaseTopicTitle => 'Basis-Topic';

  @override
  String get tipBaseTopicBody =>
      'Wenn du das Basis-Topic von „zigbee2mqtt“ geändert hast, gib es bei der manuellen Einrichtung ein.';

  @override
  String get tipPairFirstTitle => 'Erst Geräte koppeln';

  @override
  String get tipPairFirstBody =>
      'Öffne die Weboberfläche von Zigbee2MQTT, kopple mindestens ein Gerät und prüf dann noch mal.';

  @override
  String get tipRestartZ2mTitle => 'Zigbee2MQTT neu starten';

  @override
  String get tipRestartZ2mBody =>
      'Wenn Geräte gekoppelt sind, aber keine ankommen, starte Zigbee2MQTT neu, damit es seine Geräteliste sendet.';

  @override
  String get tipNumberAddressTitle => 'Die Zahlenadresse nutzen';

  @override
  String get tipNumberAddressBody =>
      'Namen auf .local funktionieren nicht auf jedem Android-Handy. Versuch die Zahlenadresse des Hubs, etwa 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Port und Protokoll';

  @override
  String get tipPortProtocolBody =>
      'Üblich ist TCP auf 1883. Wähl TLS oder WebSocket nur, wenn dein Broker dafür eingerichtet ist.';

  @override
  String get tipManualLoginTitle => 'Login';

  @override
  String get tipManualLoginBody =>
      'Lass Benutzername und Passwort leer, wenn dein Broker keine hat. Sonst nimm das MQTT-Login, nicht das Web-Login des Hubs.';

  @override
  String get tipHubOnTitle => 'Ist der Hub an?';

  @override
  String get tipHubOnBody =>
      'Ein Stromausfall oder ein Update hat ihn vielleicht neu gestartet. Gib ihm eine Minute, wenn er wieder läuft.';

  @override
  String get tipAwayTitle => 'Bist du zu Hause?';

  @override
  String get tipAwayBody =>
      'Unterwegs braucht die App eine Remote-Adresse (zum Beispiel Tailscale). Trag sie in den Verbindungseinstellungen des Zuhauses ein.';

  @override
  String get tipTailscaleIpTitle => 'Tailscale-IP statt Namen verwenden';

  @override
  String get tipTailscaleIpBody =>
      'Namen, die auf .ts.net enden, werden in Apps oft nicht aufgelöst. Öffne die Tailscale-App auf dem Handy und prüfe, dass sie verbunden ist. Trag dann die 100.x.y.z-Adresse des Hubs als Remote-Host ein.';

  @override
  String get tipHomeAddressChangedTitle => 'Hat sich die Adresse geändert?';

  @override
  String get tipHomeAddressChangedBody =>
      'Nach einem Router-Neustart bekommt der Hub vielleicht eine neue Adresse. Reserviere seine Adresse in der App deines Routers und aktualisiere dann das Zuhause.';

  @override
  String get tipRestartZ2mButtonTitle => 'Zigbee2MQTT neu starten';

  @override
  String get tipRestartZ2mButtonBody =>
      'Wenn der Broker neu gestartet ist, fehlt die Geräteliste von Zigbee2MQTT, bis Zigbee2MQTT neu startet. Nutze die Schaltfläche „Zigbee2MQTT neu starten“ im Reiter „Geräte“.';

  @override
  String get tipZ2mRunningTitle => 'Läuft Zigbee2MQTT?';

  @override
  String get tipZ2mRunningBody =>
      'Öffne seine Weboberfläche. Lädt sie nicht, starte es auf deinem Hub neu.';

  @override
  String get tipCantConnectTitle => 'Keine Verbindung zu meinem Hub';

  @override
  String get tipCantConnectBody =>
      'Gleiches WLAN, Broker läuft, „Allow External“ an oder Mosquitto lauscht im Netzwerk, dann über die Adresse verbinden.';

  @override
  String get tipDeviceWrongTitle =>
      'Ein Gerät zeigt Falsches an oder reagiert nicht';

  @override
  String get tipDeviceWrongBody =>
      'Prüf es zuerst in der Weboberfläche von Zigbee2MQTT. Klappt es dort, nutze „Problem melden“.';

  @override
  String get tipHowDoITitle => 'Wie mache ich …';

  @override
  String get tipHowDoIBody =>
      'Szenen, Wandanzeige, Zeitpläne und Sicherungen findest du unter „Hilfe & Anleitung“.';

  @override
  String get tipRenameHomeTitle => 'Ein Zuhause umbenennen';

  @override
  String get tipRenameHomeBody =>
      'Ein Zuhause heißt wie seine Adresse? Einstellungen › Zuhause, auf das Zuhause tippen, dann auf Name.';

  @override
  String get tipWhatYouNeedTitle => 'Was du brauchst';

  @override
  String get tipWhatYouNeedBody =>
      'Ein kleiner Hub mit Zigbee2MQTT und einem MQTT-Broker (Mosquitto): ein SMLIGHT-Hub, ein Raspberry Pi oder ein beliebiger Linux-Rechner. Home Assistant geht auch, ist aber nicht nötig.';

  @override
  String get tipSetupAtHomeTitle => 'Im selben WLAN';

  @override
  String get tipSetupAtHomeBody =>
      'Richte alles zu Hause ein, mit dem Handy im selben WLAN wie der Hub.';

  @override
  String get tipFindSetupTitle => 'Dann';

  @override
  String get tipFindSetupBody =>
      'Verlass die Demo und tippe auf „Mein Setup finden“. ZigDash sucht deinen Hub von selbst.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Keine E-Mail-App gefunden. Kopiere die Angaben und schreib an $email.';
  }

  @override
  String get shortcutWorking => 'läuft…';

  @override
  String get shortcutCantReach => 'Zuhause nicht erreichbar';

  @override
  String get shortcutNotConfirmed => 'Nicht bestätigt';

  @override
  String get shortcutRemoved => 'Entfernt';

  @override
  String get shortcutSceneSent => 'Gesendet';

  @override
  String get shortcutSceneConfirmed => 'Bestätigt';

  @override
  String get shortcutChooseDevice => 'Gerät wählen';

  @override
  String get shortcutChooseScene => 'Szene wählen';

  @override
  String get shortcutOpenAppFirstScene =>
      'Öffne ZigDash und lege zuerst eine Szene an.';

  @override
  String get shortcutChooseGroup => 'Gruppe wählen';

  @override
  String get shortcutPickDevices => 'Geräte auswählen…';

  @override
  String get shortcutGroupName => 'Name der Gruppe';

  @override
  String get shortcutGroupLimit => 'Bis zu 5 Geräte und 3 Szenen';

  @override
  String get shortcutAddTile => 'Zu Schnelleinstellungen hinzufügen';

  @override
  String get shortcutAddShortcut => 'Verknüpfung hinzufügen';

  @override
  String get shortcutAddToHome => 'Zum Startbildschirm hinzufügen';

  @override
  String get shortcutWidgetHowToTitle => 'Widget hinzufügen';

  @override
  String get shortcutWidgetHowTo =>
      'Halte eine freie Stelle auf dem Startbildschirm gedrückt, tippe auf Widgets, suche ZigDash und ziehe das gewünschte Widget.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name liegt auf der Schnelleinstellungs-Kachel ZigDash $slot';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name liegt schon auf der Kachel ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Kachel hinzufügen';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Öffne die Schnelleinstellungen (zweimal nach unten wischen), tippe zum Bearbeiten auf den Stift und ziehe „ZigDash $slot“ zu deinen Kacheln.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Gerät für ZigDash $slot wählen';
  }

  @override
  String get shortcutPickEmpty =>
      'Noch keine schaltbaren Geräte. Lege zuerst eine Lampe, Steckdose oder einen Rollladen auf ein Dashboard.';

  @override
  String get shortcutSlotsFull =>
      'Alle 4 ZigDash-Kacheln sind belegt. Welche soll stattdessen dieses Gerät zeigen?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Nicht belegt';

  @override
  String get deviceRename => 'Umbenennen';

  @override
  String get deviceRenameTitle => 'Gerät umbenennen';

  @override
  String get deviceRenameHint =>
      'Ein Name für den Raum oder das Gerät, z. B. Schlafzimmer';

  @override
  String deviceRenamed(Object name) {
    return 'Umbenannt in $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Umbenennen fehlgeschlagen: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT hat nicht geantwortet';

  @override
  String get shortcutOpenAppFirst =>
      'Öffne ZigDash und lege zuerst ein Gerät auf ein Dashboard.';

  @override
  String get pollTitle => 'Was soll ZigDash als Nächstes können?';

  @override
  String get pollBody =>
      'Wähle, was du am meisten nutzen würdest. Die Antwort wird mit deinen anonymen Nutzungsdaten gesendet.';

  @override
  String get pollNotifications => 'Benachrichtigungen';

  @override
  String get pollHistory => 'Verlaufsdiagramme';

  @override
  String get pollKiosk => 'Kiosk-Modus für ein Wand-Tablet';

  @override
  String get pollGroups => 'Zigbee-Gruppen';

  @override
  String get pollNotNow => 'Nicht jetzt';

  @override
  String get pollThanks =>
      'Danke! Das hilft bei der Entscheidung, was als Nächstes kommt.';

  @override
  String get whyTitle => 'Warum hast du ZigDash ausprobiert?';

  @override
  String get whyBody =>
      'Ein Tipp hilft bei der Entscheidung, was als Nächstes kommt. Die Antwort wird mit deinen anonymen Nutzungsdaten gesendet.';

  @override
  String get whyFaster => 'Schneller als meine andere App';

  @override
  String get whyFamily => 'Einfach für die Familie';

  @override
  String get whyWallTablet => 'Ein Wandtablet';

  @override
  String get whyWithoutHa => 'Läuft ohne Home Assistant';

  @override
  String get whyOther => 'Etwas anderes';

  @override
  String get whyThanks => 'Danke für deine Antwort!';

  @override
  String get pollNoAnalytics =>
      'Nutzungsdaten sind aus, daher wird von hier nichts gesendet. Sag es uns stattdessen über Funktion vorschlagen.';

  @override
  String alertLeak(Object name) {
    return '💧 Leck — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name ist wieder trocken';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Rauch — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Kein Rauch mehr bei $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name geöffnet';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Batterie schwach — $name, $value %';
  }

  @override
  String get alertTest => 'ZigDash-Testbenachrichtigung';

  @override
  String get alertsChannel => 'Alarme';

  @override
  String get alertsChannelDescription => 'Lecks und Rauch';

  @override
  String get noticesChannel => 'Hinweise';

  @override
  String get noticesChannelDescription => 'Türen, Fenster und Batterien';

  @override
  String get alertsTitle => 'Alarme';

  @override
  String get alertsStatusOn => 'Alarme sind an';

  @override
  String get alertsStatusPaused =>
      'Alarme pausiert: ZigDash Engine auf Ihrem Hub meldet sich nicht';

  @override
  String get alertsStatusNotSetUp => 'Nicht eingerichtet';

  @override
  String get alertsStatusPhoneOff =>
      'Dieses Handy bekommt keine Benachrichtigungen';

  @override
  String get alertsIntro =>
      'Erhalten Sie eine Benachrichtigung auf diesem Telefon bei Leck, Rauch, geöffneter Tür oder schwacher Batterie, auch wenn ZigDash geschlossen ist. ZigDash Engine auf Ihrem Hub beobachtet die Geräte; ZigDash richtet es ein.';

  @override
  String get alertsSetUpHub => 'Alarme auf dem Hub einrichten';

  @override
  String get alertsHubInstalled => 'Alarme sind auf Ihrem Hub eingerichtet';

  @override
  String get alertsHubUpdated => 'Der Alarm-Flow auf dem Hub ist aktuell';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED verlangt eine Anmeldung, importiere den Flow daher von Hand:';

  @override
  String get alertsHubManualSteps =>
      'Öffne Node-RED auf dem Hub, wähle Importieren, füge den kopierten Flow ein, wähle im Broker-Knoten deinen Broker und klicke auf Deploy.';

  @override
  String get alertsCopyFlow => 'Flow kopieren';

  @override
  String get alertsFlowCopied => 'Flow kopiert';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Alarme brauchen Node-RED auf dem Hub, aber auf Port 1880 bei $host antwortet nichts. Auf einem SMLIGHT SMHUB installierst du es unter Apps.';
  }

  @override
  String get alertsHubFailed =>
      'Zigbee2MQTT hat ZigDash Engine nicht angenommen';

  @override
  String get alertsRecent => 'Letzte Alarme';

  @override
  String get alertsRecentNone => 'Noch nichts';

  @override
  String get alertsYourAlerts => 'Deine Alarme';

  @override
  String get alertsAdd => 'Alarm hinzufügen';

  @override
  String get alertsNotificationsOnThisPhone =>
      'Benachrichtigungen auf diesem Handy';

  @override
  String get alertsNoGoogle =>
      'Dieses Handy hat keine Google-Dienste, daher kann ZigDash hier keine Pushes empfangen.';

  @override
  String get alertsSendTest => 'Testbenachrichtigung senden';

  @override
  String get alertsTestSent => 'Test gesendet. Sie sollte jetzt ankommen.';

  @override
  String alertsTestFailed(Object status) {
    return 'Der Hub konnte sie nicht senden ($status)';
  }

  @override
  String get alertsTestTimedOut =>
      'Keine Antwort vom Hub. Läuft der Alarm-Flow?';

  @override
  String get alertsNotConnected => 'Nicht mit dem Hub verbunden';

  @override
  String get alertsTurnOff => 'Alarme ausschalten';

  @override
  String get alertsTurnOffBody =>
      'Alarme stoppen für jedes Handy dieses Zuhauses.';

  @override
  String get alertKindLeak => 'Leck';

  @override
  String get alertKindSmoke => 'Rauch';

  @override
  String get alertKindOpened => 'Tür oder Fenster geöffnet';

  @override
  String get alertKindBattery => 'Batterie schwach';

  @override
  String get alertsEditTitle => 'Alarm';

  @override
  String get alertsKind => 'Was';

  @override
  String get alertsDevices => 'Geräte';

  @override
  String get alertsNoDevicesForKind => 'Kein Gerät dieses Zuhauses meldet das.';

  @override
  String get alertsHours => 'Nur zwischen';

  @override
  String get alertsHoursAny => 'Jederzeit';

  @override
  String get alertsHoursFrom => 'Von';

  @override
  String get alertsHoursTo => 'Bis';

  @override
  String get alertsThreshold => 'Batterie unter';

  @override
  String get alertsDelete => 'Alarm löschen';

  @override
  String get alertsNotifyMe => 'Benachrichtige mich…';

  @override
  String get alertsWhatLeaves =>
      'Alarme an ZigDash sind Ende-zu-Ende verschlüsselt: Googles Push-Dienst überträgt sie, kann sie aber nicht lesen. Sonst verlässt nichts deinen Hub.';

  @override
  String get alertsRestricted =>
      'Android könnte ZigDash im Hintergrund beenden, dann kommen Benachrichtigungen spät oder gar nicht. Erlaube in den Android-Einstellungen das Ausführen im Hintergrund (bei Samsung: Akku › Nie schlafende Apps).';

  @override
  String get alertsOpenSettings => 'Android-Einstellungen öffnen';

  @override
  String get alertsOff => 'Aus';

  @override
  String get alertsSuggested => 'Vorgeschlagene Alarme';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte',
      one: '1 Gerät',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Einschalten';

  @override
  String get alertsShare => 'Alarme teilen';

  @override
  String get alertsShareBody =>
      'Wer diesen Link hat, bekommt die Alarme dieses Zuhauses in der ntfy-App, ganz ohne ZigDash. Der Alarmtext läuft unverschlüsselt über ntfy.sh.';

  @override
  String get alertsShareLink => 'Link';

  @override
  String get alertsShareNewLink => 'Neuer Link';

  @override
  String get alertsShareCopied => 'Link kopiert';

  @override
  String get alertsShareOff => 'Teilen beenden';

  @override
  String get alertsGetWithNtfy => 'Benachrichtigungen über ntfy erhalten';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Rauch- und Leck-Alarme wiederholen sich, bis sie bestätigt werden. Braucht ein Pushover-Konto (einmalig 4,99 \$ nach einer Testphase); die Schlüssel bleiben auf deinem Broker.';

  @override
  String get alertsPushoverUser => 'Benutzerschlüssel';

  @override
  String get alertsPushoverToken => 'App-Token';

  @override
  String get alertsHideNames => 'Gerätenamen verbergen';

  @override
  String get alertsNtfyServer => 'ntfy-Server';

  @override
  String get wallSheetTitle => 'Wandanzeige';

  @override
  String get wallSheetSubtitle => 'Für ein Tablet an der Wand.';

  @override
  String get wallKeepOn => 'Bildschirm an lassen und Leisten ausblenden';

  @override
  String get wallKeepOnSubtitle =>
      'Sie kommen bei Berührung zurück und verschwinden nach 10 Sekunden wieder.';

  @override
  String get wallFullscreen => 'Vollbild';

  @override
  String get wallFullscreenSubtitle =>
      'Blendet auch Androids Status- und Navigationsleiste aus.';

  @override
  String get wallDimAfter => 'Abdunkeln nach';

  @override
  String get wallDimOff => 'Aus';

  @override
  String get wallIdleTitle => 'Wenn niemand es berührt';

  @override
  String get wallIdleAfter => 'Nach';

  @override
  String get wallIdleNever => 'Nie';

  @override
  String get wallIdleShow => 'Anzeigen';

  @override
  String get wallIdleShowDim => 'Gedimmt';

  @override
  String get wallIdleShowClock => 'Uhr';

  @override
  String get wallIdleShowBlack => 'Schwarz';

  @override
  String get wallIdleShowReadings => 'Messwerte';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Dieses Dashboard hat noch keine Messwerte. Füge zuerst eine Messwert- oder Sensorkachel hinzu.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Messwerte auf der Uhr (bis zu $count)';
  }

  @override
  String get wallProNote =>
      'Messwerte auf der Uhr, Aufwecken bei Bewegung, der Nachtplan und Alarme gehören zu ZigDash Pro, einem einmaligen Kauf.';

  @override
  String get wallAlarmLeak => 'Wasserleck';

  @override
  String get wallAlarmSmoke => 'Rauch';

  @override
  String get wallAlarmGas => 'Gas';

  @override
  String get wallAlarmCo => 'Kohlenmonoxid';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Bei Bewegung aufwecken';

  @override
  String get wallMotionSubtitle =>
      'Ein Sensor, der jemanden bemerkt, weckt den Bildschirm.';

  @override
  String get wallMotionNone =>
      'Keine Bewegungs-, Präsenz- oder Türsensoren in diesem Zuhause.';

  @override
  String get wallAlarmsTitle => 'Alarme füllen den Bildschirm';

  @override
  String get wallAlarmsSubtitle =>
      'Wasserleck, Rauch, Gas oder Kohlenmonoxid füllt den Bildschirm, bis jemand OK tippt. Nur solange ZigDash auf diesem Tablet geöffnet ist; Benachrichtigungen erreichen Handys überall.';

  @override
  String get wallAlarmSound => 'Ton abspielen';

  @override
  String get wallNightTitle => 'Nacht';

  @override
  String get wallNightSubtitle =>
      'Schwarz zwischen diesen Zeiten. Bewegung weckt nur gedimmt, Alarme immer voll.';

  @override
  String get wallNightFrom => 'Von';

  @override
  String get wallNightTo => 'bis';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes Min.';
  }

  @override
  String get kioskLock => 'Kiosk-Sperre';

  @override
  String get kioskLockSubtitle =>
      'Nur die Dashboards dieses Zuhauses und ihre Bedienelemente bleiben erreichbar. Titel lange drücken, um zu beenden.';

  @override
  String get kioskPin => 'PIN';

  @override
  String get kioskPinSet => 'Festlegen';

  @override
  String get kioskPinNotSet => 'Nicht festgelegt';

  @override
  String get kioskPinChange => 'Ändern';

  @override
  String get kioskPinRemove => 'Entfernen';

  @override
  String get kioskPinSetTitle => 'PIN festlegen';

  @override
  String get kioskPinEnterTitle => 'PIN eingeben';

  @override
  String get kioskPinHint => '4 Ziffern';

  @override
  String get kioskPinConfirmHint => 'Noch einmal';

  @override
  String get kioskPinMismatch => 'Die beiden PINs sind verschieden.';

  @override
  String get kioskPinWrong => 'Falsche PIN.';

  @override
  String get kioskPinForgot => 'PIN vergessen?';

  @override
  String get kioskPinForgotBody =>
      'Eine vergessene PIN lässt sich nur zurücksetzen, indem du die Daten von ZigDash in den Android-Einstellungen löschst. Das entfernt dieses Zuhause, sofern du kein Backup hast. Exportiere eines, bevor du eine PIN festlegst.';

  @override
  String get kioskExportBackup => 'Backup exportieren';

  @override
  String get kioskOsPin => 'ZigDash auch in Android anheften';

  @override
  String get kioskOsPinSubtitle =>
      'Android blockiert Home und die letzten Apps, bis ZigDash gelöst wird. Ein Tablet ohne Sperrbildschirm löst es mit einer Geste, also ist das nicht die Sperre.';

  @override
  String get kioskOn => 'Kiosk an. Titel lange drücken, um zu beenden.';

  @override
  String get kioskLeaveTitle => 'Kiosk beenden?';

  @override
  String get kioskLeave => 'Beenden';

  @override
  String get kioskStay => 'Bleiben';

  @override
  String get a11yKioskLeave => 'Lange drücken, um den Kiosk zu beenden';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get historyRangeDay => '24 Stunden';

  @override
  String get historyRangeWeek => '7 Tage';

  @override
  String get historyRangeMonth => '30 Tage';

  @override
  String get historySetupTitle => 'Verlauf auf deinem Hub aufzeichnen';

  @override
  String get historySetupBody =>
      'ZigDash hat keinen Server, also zeichnet ZigDash Engine auf Ihrem Hub die Werte Ihrer Dashboards alle 15 Minuten auf. Es behält 30 Tage, auf Ihrem eigenen Broker.';

  @override
  String get historySetupAction => 'Auf dem Hub einrichten';

  @override
  String get historyInstalled =>
      'Aufzeichnung läuft. Die ersten Werte erscheinen innerhalb von 15 Minuten.';

  @override
  String historyNoNodeRed(String host) {
    return 'Der Verlauf braucht Node-RED auf dem Hub, und unter $host antwortet nichts auf Port 1880. Auf einem SMLIGHT SMHUB installierst du es unter Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Aufzeichnung seit $date';
  }

  @override
  String get historyEmpty =>
      'Noch keine Werte. Der Recorder speichert alle 15 Minuten.';

  @override
  String get historyRecorderOffline =>
      'Der Recorder auf dem Hub antwortet nicht, daher können neuere Werte fehlen.';

  @override
  String get historyLocked =>
      'Längerer Verlauf ist Teil von ZigDash Pro, einem einmaligen Kauf.';

  @override
  String get historyUnlock => 'Freischalten';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Unbegrenzte Automationen, längerer Verlauf und Extras fürs Wandtablet. Unterstützt das Open-Source-Projekt.';

  @override
  String get proUnlocked =>
      'Freigeschaltet. Danke, dass du ZigDash unterstützt.';

  @override
  String get proScreenIntro =>
      'ZigDash ist kostenlos und Open Source, gebaut von einer Person in ihrer Freizeit. Pro ist ein einmaliger Kauf, der das Projekt am Laufen hält.';

  @override
  String get proWhatYouGet => 'Was Sie bekommen';

  @override
  String get proGetHistory => 'Verlauf für 7 und 30 Tage, nicht nur für heute';

  @override
  String get proGetWall =>
      'Wandtablet: Messwerte auf der Uhr, Aufwecken bei Bewegung, ein Nachtplan und Alarme';

  @override
  String get proGetFuture => 'Jede spätere Pro-Funktion ohne Aufpreis';

  @override
  String get proFreeTitle => 'Für immer kostenlos';

  @override
  String get proFreeBody =>
      'Einrichtung, Dashboards, jede Gerätesteuerung, Widgets, Schnelleinstellungen-Kacheln, Warnungen, drei Automationen pro Zuhause und das Wandtablet selbst bleiben kostenlos. Nichts, was Sie heute nutzen, wird gesperrt.';

  @override
  String get proBuy => 'Pro holen';

  @override
  String proBuyPrice(String price) {
    return 'Pro holen · $price';
  }

  @override
  String get proOnce =>
      'Eine Zahlung, kein Abo. Auf einem anderen Telefon mit demselben Google-Konto gekauft? Es wird automatisch freigeschaltet.';

  @override
  String get historyNotRecorded =>
      'Aufgezeichnet werden nur Zahlen, die auf einem Dashboard stehen. Füge diesen Wert als Kachel hinzu, um seinen Verlauf zu starten.';

  @override
  String get historyRecordHere => 'Auf diesem Gerät aufzeichnen';

  @override
  String get historyRecordHereHint =>
      'ZigDash Engine auf dem Hub nicht möglich? ZigDash kann auf einem Telefon oder Tablet aufzeichnen, das offen bleibt, etwa einem Wandtablet. Jedes Telefon dieses Zuhauses sieht den Verlauf.';

  @override
  String get historyRecordingHere =>
      'Dieses Gerät zeichnet den Verlauf auf, solange ZigDash geöffnet ist. Die ersten Werte erscheinen innerhalb von 15 Minuten.';

  @override
  String get wallRecordHistory => 'Verlauf auf diesem Gerät aufzeichnen';

  @override
  String get wallRecordHistorySubtitle =>
      'Alle 15 Minuten, solange ZigDash offen ist, für jedes Telefon dieses Zuhauses. Nicht nötig, wenn ZigDash Engine auf Ihrem Hub aufzeichnet.';

  @override
  String historyNeedsPassword(String host) {
    return 'Noch ein Schritt: Dein Broker verlangt eine Anmeldung. Öffne Node-RED unter $host:1880, doppelklicke auf „ZigDash history broker“, gib im Tab Security das MQTT-Passwort ein und klicke auf Deploy. ZigDash schickt dein Passwort nie an den Hub.';
  }

  @override
  String get historyNotConnected =>
      'Die Aufzeichnung meldet sich nicht. Öffnen Sie Automationen, um ZigDash Engine auf Ihrem Hub zu prüfen.';

  @override
  String get historyPersistence =>
      'Der Verlauf liegt auf deinem Broker. Betreibst du Mosquitto selbst, achte darauf, dass seine Konfiguration \"persistence true\" enthält, sonst geht der Verlauf beim Neustart des Brokers verloren.';

  @override
  String get haImportTitle => 'Aus Home Assistant importieren';

  @override
  String get haImportSettingsSubtitle => 'Namen und Räume aus Home Assistant';

  @override
  String get haImportIntro =>
      'Übernimm die Namen und Räume, die du in Home Assistant eingerichtet hast. ZigDash liest sie einmal und behält sonst nichts aus Home Assistant.';

  @override
  String get haImportAddress => 'Adresse von Home Assistant';

  @override
  String get haImportAddressHelp =>
      'Die Adresse, mit der du Home Assistant öffnest, z. B. 192.168.1.20:8123';

  @override
  String get haImportToken => 'Langlebiges Zugriffstoken';

  @override
  String get haImportTokenHelp =>
      'Öffne in Home Assistant dein Profil, dann Sicherheit › Langlebige Zugriffstoken › Token erstellen. Kopiere es und füge es hier ein. ZigDash nutzt es einmal und behält es nicht; danach kannst du es in Home Assistant löschen.';

  @override
  String get haImportRead => 'Aus Home Assistant lesen';

  @override
  String get haImportReading => 'Lese Home Assistant…';

  @override
  String get haImportApplying => 'Importiere…';

  @override
  String get haImportNoAddress =>
      'Gib die Adresse ein, mit der du Home Assistant öffnest.';

  @override
  String get haImportNoToken => 'Füge ein langlebiges Zugriffstoken ein.';

  @override
  String get haImportUnreachable =>
      'Unter dieser Adresse antwortet nichts. Prüfe sie und ob dein Handy im Heimnetz ist.';

  @override
  String get haImportNotHa =>
      'Unter dieser Adresse antwortet etwas, aber nicht Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant hat das Token abgelehnt. Erstelle ein neues und füge es erneut ein.';

  @override
  String get haImportCertificate =>
      'Dein Handy vertraut dem Zertifikat dieses Home Assistant nicht. Versuche die http://-Adresse im Heimnetz.';

  @override
  String get haImportFailed =>
      'Home Assistant hat geantwortet, aber das Lesen ist fehlgeschlagen. Versuche es erneut.';

  @override
  String get haImportNoDevices =>
      'ZigDash sieht die Geräte dieses Zuhauses gerade nicht. Verbinde dich mit dem Zuhause und versuche es erneut.';

  @override
  String get haImportAutomations =>
      'Deine Automationen bleiben in Home Assistant und laufen weiter.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte in Home Assistant gefunden',
      one: '1 Gerät in Home Assistant gefunden',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'Kacheln, die noch den Namen ihres Geräts tragen, bekommen den Namen aus Home Assistant. Deine eigenen Dashboards bleiben, wie sie sind.';

  @override
  String get haImportMakeDashboards =>
      'Auch Dashboards aus deinen Etagen und Räumen anlegen';

  @override
  String get haImportOtherRooms => 'Weitere Räume';

  @override
  String get haImportNoRoom => 'Kein Raum';

  @override
  String get haImportApply => 'Importieren';

  @override
  String get haImportBack => 'Zurück';

  @override
  String get haImportZhaOnly =>
      'Diese Geräte laufen über ZHA, das eigene Zigbee von Home Assistant, nicht über Zigbee2MQTT. ZigDash kann sie nicht anzeigen.';

  @override
  String get haImportNothing =>
      'Keines der Zigbee2MQTT-Geräte dieses Zuhauses ist in Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Fertig. Umbenannte Kacheln: $renamed. Neue Dashboards: $dashboards.';
  }

  @override
  String get haImportOpen => 'Dashboards öffnen';

  @override
  String get haImportOfferTitle =>
      'Namen und Räume aus Home Assistant übernehmen?';

  @override
  String get haImportOfferBody =>
      'Home Assistant ist in deinem Netzwerk. ZigDash kann deine Kacheln benennen und ein Dashboard pro Etage und Raum anlegen, so wie du sie dort eingerichtet hast.';

  @override
  String get haImportOfferLater => 'Nicht jetzt';

  @override
  String get haImportOfferGo => 'Importieren';

  @override
  String get haImportSignIn => 'Mit Home Assistant anmelden';

  @override
  String get haImportSignInHelp =>
      'Die Anmeldung von Home Assistant öffnet sich in deinem Browser. ZigDash sieht dein Passwort nie und meldet sich nach dem Lesen wieder ab.';

  @override
  String get haImportOrToken => 'Oder ein langlebiges Zugriffstoken nutzen';

  @override
  String get haImportReadToken => 'Mit Token lesen';

  @override
  String get haImportSignInRefused =>
      'Home Assistant hat die Anmeldung nicht angenommen. Das passiert, wenn Home Assistant keinen Internetzugang hat. Nutze stattdessen unten ein langlebiges Zugriffstoken.';

  @override
  String get setupIsolatedHint =>
      'Dein Handy sieht in diesem WLAN fast nichts anderes. Es ist vielleicht in einem Gastnetz, oder der Router hält Geräte voneinander getrennt (oft Client- oder AP-Isolation genannt). Verbinde dich mit deinem Haupt-WLAN oder schalte das aus und versuche es erneut.';

  @override
  String get setupAuthTrust =>
      'Dein Login bleibt auf diesem Handy und geht nur an deinen eigenen Broker. ZigDash hat keinen Server und kein Konto, und jede MQTT-App meldet sich so an. Am sichersten: ein eigener MQTT-Benutzer nur für ZigDash, den du jederzeit entfernen kannst.';

  @override
  String get setupAuthWhatKept => 'Was ZigDash speichert';

  @override
  String get setupAuthDemoFirst => 'Erst die Demo ansehen';

  @override
  String get automationsTitle => 'Automationen';

  @override
  String get engineRunningOnHub => 'Läuft auf dem Hub';

  @override
  String get engineChecking => 'Hub wird geprüft…';

  @override
  String get engineAwayNoHubTitle => 'Dein Hub ist gerade nicht erreichbar';

  @override
  String get engineAwayNoHubBody =>
      'Du bist unterwegs, und dein Hub ist nicht mit dem Fernzugriff von ZigDash verbunden, oder sein Internet ist weg. Deine Automationen laufen auf dem Hub weiter.';

  @override
  String get engineAwayReinstallAtHome =>
      'Du kannst die Engine neu installieren, wenn du zu Hause bist.';

  @override
  String get engineNoConnection =>
      'ZigDash erreicht den Broker dieses Zuhauses gerade nicht. Automationen richten Sie zu Hause mit Verbindung ein.';

  @override
  String get engineRestarting =>
      'Zigbee2MQTT wird neu gestartet… Ihre Geräte sind in etwa 30 Sekunden zurück.';

  @override
  String get engineInstalling => 'Wird auf dem Hub installiert…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT braucht ein Update';

  @override
  String engineTooOldBody(Object version) {
    return 'Ihr Zigbee2MQTT hat Version $version. Automationen brauchen 2.4 oder neuer. Aktualisieren Sie Zigbee2MQTT auf dem Hub und kommen Sie dann hierher zurück.';
  }

  @override
  String get engineIntroTitle =>
      'Automationen laufen auf Ihrem Hub, nicht auf dem Telefon';

  @override
  String get engineIntroBody =>
      'ZigDash legt ZigDash Engine in Zigbee2MQTT auf Ihrem Hub. Es beobachtet Ihre Geräte und führt Ihre Regeln aus, damit das Licht angeht, wenn die Tür aufgeht, auch bei ausgeschaltetem Telefon und ohne Internet.';

  @override
  String get engineIntroNothingByHand =>
      'Nichts von Hand zu installieren. ZigDash erledigt das über Ihr Heimnetz.';

  @override
  String engineIntroVersion(Object version) {
    return 'Ihr Zigbee2MQTT hat Version $version.';
  }

  @override
  String get engineIntroRemove =>
      'Sie können ihn jederzeit auf diesem Bildschirm entfernen.';

  @override
  String get engineInstall => 'Auf dem Hub installieren';

  @override
  String get engineDeclinedTitle => 'Keine Automationen auf diesem Hub';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT auf Ihrem Hub erlaubt keine Erweiterungen, also kann nichts Ihre Regeln ausführen, wenn Ihr Telefon weg ist. Szenen, Alarme und das Dashboard funktionieren wie bisher.';

  @override
  String get engineAllowAfterAll => 'Erweiterungen doch erlauben';

  @override
  String get engineConsentTitle =>
      'Zigbee2MQTT braucht eine geänderte Einstellung';

  @override
  String get engineConsentBody =>
      'Ihr Zigbee2MQTT blockiert Erweiterungen wie ZigDash Engine, wie es neue Installationen tun. Damit Automationen auf dem Hub laufen, würde ZigDash in Zigbee2MQTT „Externes JavaScript erlauben“ einschalten und es neu starten.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT startet einmal neu. Lichter und Sensoren sind etwa 30 Sekunden nicht erreichbar.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine ist Open Source. Sie können es auf der Zigbee2MQTT-Seite unter Erweiterungen lesen.';

  @override
  String get engineConsentUndo =>
      'Sie können die Einstellung später wieder ausschalten. Dann stoppen die Automationen.';

  @override
  String get engineConsentYes => 'Einstellung ändern und neu starten';

  @override
  String get engineConsentNo => 'Nicht jetzt';

  @override
  String get automationsPausedTitle => 'Automationen pausiert';

  @override
  String get automationsPausedBody =>
      'Ihr Hub hat sich seit über einer Minute nicht gemeldet, deshalb kann keine Automation laufen, bis er es tut. Ihre Regeln bleiben erhalten.';

  @override
  String get engineReinstall => 'Auf dem Hub neu installieren';

  @override
  String get engineStoppedTitle =>
      'Automationen pausiert: ZigDash Engine hat sich selbst gestoppt';

  @override
  String get engineStoppedBody =>
      'Er hatte dreimal in einer Stunde Fehler und hat sich abgeschaltet, damit Zigbee2MQTT weiterläuft. Ihre Regeln bleiben erhalten.';

  @override
  String get engineStartAgain => 'Neu starten';

  @override
  String get engineReportProblem => 'Problem melden';

  @override
  String get engineRunningTitle => 'Ihr Hub ist bereit für Automationen';

  @override
  String engineRunningBody(Object count) {
    return 'Regeln auf dem Hub geladen: $count. Das Erstellen von Automationen kommt im nächsten Schritt dieser Version.';
  }

  @override
  String get engineClockOff =>
      'Die Uhr Ihres Hubs geht mehr als fünf Minuten falsch. Zeitgesteuerte Automationen laufen zur falschen Zeit, bis das behoben ist.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Regeln, die ZigDash Engine auf Ihrem Hub noch nicht ausführen kann: $count. Installieren Sie es neu, um es zu aktualisieren.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT hat ZigDash Engine abgelehnt: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT hat nicht geantwortet. Prüfen Sie, ob das Zuhause verbunden ist, und versuchen Sie es erneut.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT hat die Änderung nicht übernommen oder ist nicht zurückgekommen. Prüfen Sie Ihren Hub und versuchen Sie es erneut.';

  @override
  String get autoValMotion => 'Bewegung';

  @override
  String get autoValNoMotion => 'keine Bewegung';

  @override
  String get autoValClosed => 'geschlossen';

  @override
  String get autoValOpened => 'geöffnet';

  @override
  String get autoValLeak => 'Leck';

  @override
  String get autoValDry => 'trocken';

  @override
  String get autoValSmoke => 'Rauch';

  @override
  String get autoValNoSmoke => 'kein Rauch';

  @override
  String get autoValOn => 'an';

  @override
  String get autoValOff => 'aus';

  @override
  String get autoValToggle => 'umschalten';

  @override
  String get autoValOpen => 'öffnen';

  @override
  String get autoValClose => 'schließen';

  @override
  String get autoValStop => 'stopp';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Wenn $device: $property über $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Wenn $device: $property unter $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Wenn $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'Um $time';
  }

  @override
  String get autoSunrise => 'Sonnenaufgang';

  @override
  String get autoSunset => 'Sonnenuntergang';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes Min. nach $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes Min. vor $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'Bei $sun';
  }

  @override
  String get autoEveryDay => 'jeden Tag';

  @override
  String get autoWeekdays => 'werktags';

  @override
  String get autoWeekends => 'am Wochenende';

  @override
  String autoBetween(Object from, Object to) {
    return 'zwischen $from und $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device ist $value';
  }

  @override
  String autoRunScene(Object scene) {
    return '„$scene“ ausführen';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, nach $minutes Min. wieder aus';
  }

  @override
  String get autoErrPickTrigger => 'Wählen Sie ein Gerät und was es tut.';

  @override
  String get autoErrValue => 'Geben Sie eine Zahl für den Messwert ein.';

  @override
  String get autoErrDays => 'Wählen Sie mindestens einen Tag.';

  @override
  String get autoErrTown =>
      'Legen Sie Ihren Ort für Sonnenauf- und -untergang fest.';

  @override
  String get autoErrPickAction => 'Wählen Sie, was passieren soll.';

  @override
  String get autoErrEmptyScene => 'Diese Szene sendet nichts.';

  @override
  String get autoErrNotConnected =>
      'ZigDash ist nicht mit diesem Zuhause verbunden. Versuchen Sie es zu Hause erneut.';

  @override
  String get autoNewTitle => 'Neue Automation';

  @override
  String get autoEditTitle => 'Automation bearbeiten';

  @override
  String get autoName => 'Name';

  @override
  String get autoNameHint => 'Was sie tut (optional)';

  @override
  String get autoWhen => 'Wenn';

  @override
  String get autoOnlyIf => 'Nur wenn';

  @override
  String get autoThen => 'Dann';

  @override
  String get autoEnabled => 'Aktiviert';

  @override
  String get autoDelete => 'Automation löschen';

  @override
  String get autoSave => 'Speichern';

  @override
  String get autoDeviceChanges => 'Ein Gerät ändert sich';

  @override
  String get autoTimeComes => 'Eine Uhrzeit kommt';

  @override
  String get autoDevice => 'Gerät';

  @override
  String get autoAbove => 'über';

  @override
  String get autoBelow => 'unter';

  @override
  String get autoClockTime => 'Uhrzeit';

  @override
  String get autoAt => 'Um';

  @override
  String get autoShift => 'Verschiebung in Minuten (minus ist davor)';

  @override
  String get autoTownNone => 'Kein Ort festgelegt';

  @override
  String autoTownIs(Object town) {
    return 'Sonnenzeiten für $town';
  }

  @override
  String get autoTownSet => 'Ort festlegen';

  @override
  String get autoTownChange => 'Ort ändern';

  @override
  String get autoDays => 'Tage';

  @override
  String get autoNoConditions => 'Keine Bedingungen. Sie läuft jedes Mal.';

  @override
  String get autoAddHours => 'Zwischen Uhrzeiten';

  @override
  String get autoFrom => 'Von';

  @override
  String get autoTo => 'Bis';

  @override
  String get autoAddDeviceCondition => 'Ein Gerät ist …';

  @override
  String get autoRunASceneOption => 'Szene ausführen';

  @override
  String get autoSetADevice => 'Gerät schalten';

  @override
  String get autoScene => 'Szene';

  @override
  String get autoTurnOffAgain => 'Wieder ausschalten';

  @override
  String get autoStaysAsSet => 'Bleibt so';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes Minuten danach';
  }

  @override
  String get autoTownSearch => 'Ort';

  @override
  String get autoTownWhy =>
      'Nur für Sonnenauf- und -untergang. Auf Ihrem Hub gespeichert, nie Ihr Standort.';

  @override
  String get autoNewButton => 'Neue Automation';

  @override
  String get autoEmptyBody =>
      'Noch läuft nichts. Tippen Sie auf Neue Automation für die erste.';

  @override
  String autoOnlyIfList(Object list) {
    return 'nur wenn $list';
  }

  @override
  String get autoEdit => 'Bearbeiten';

  @override
  String get autoNeverRan => 'noch nie gelaufen';

  @override
  String autoRanAt(Object time) {
    return 'lief $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count von $max kostenlosen Automationen';
  }

  @override
  String get autoRecentRuns => 'Letzte Ausführungen';

  @override
  String get autoDeleted => '(gelöscht)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count Automationen sind kostenlos. Mehr gewünscht?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash ist kostenlos und Open Source, gebaut von einer Person. Pro ist ein Einmalkauf: unbegrenzte Automationen, Verlauf für 7 und 30 Tage und die Extras für Wandtablets. Ihre Automationen laufen weiter, wie auch immer Sie sich entscheiden.';

  @override
  String get autoCeilingSeePro => 'Pro ansehen';

  @override
  String get engineRemove => 'Vom Hub entfernen';

  @override
  String get engineRemoveTitle => 'ZigDash Engine vom Hub entfernen?';

  @override
  String get engineRemoveBody =>
      'Automationen laufen nicht mehr. Ihre Regeln bleiben auf dem Hub, eine Neuinstallation von ZigDash Engine bringt sie zurück.';

  @override
  String get autoNoTargets =>
      'Dieses Zuhause hat noch kein Licht, keine Steckdose, keinen Schalter und keinen Rollladen zum Steuern.';

  @override
  String get proGetAutomations =>
      'Unbegrenzte Automationen; drei pro Zuhause sind kostenlos';

  @override
  String get proGetRemote =>
      'Fernsteuerung von überall, über das ZigDash-Relay, ohne monatliche Gebühr';

  @override
  String get proRemoteFair =>
      'Fernzugriff ist enthalten, solange das ZigDash-Relay läuft, für ein Zuhause, bis zu fünf Telefone und normale Nutzung im Haushalt. Er kann sich mit Vorankündigung ändern oder enden.';

  @override
  String get autoDeleteConfirm =>
      'Diese Automation löschen? Sie läuft dann nicht mehr auf Ihrem Hub.';

  @override
  String get statusConnectedRelay => 'Verbunden · Unterwegs über ZigDash';

  @override
  String get shareHomeTitle => 'Mit einem anderen Handy teilen';

  @override
  String get shareHomeSubtitle =>
      'Dieses Zuhause mit einem QR-Code zu einem anderen Handy hinzufügen';

  @override
  String get shareHomeIntro =>
      'Scanne den Code auf dem anderen Handy zu Hause im selben WLAN mit der Kamera. ZigDash fügt dieses Zuhause mit Login und deinen Dashboards hinzu.';

  @override
  String get shareHomeLoginWarning =>
      'Der Code enthält den Broker-Login dieses Zuhauses. Er wird 2 Minuten angezeigt; zeig ihn nur Leuten, denen du vertraust.';

  @override
  String get shareHomeShow => 'Code anzeigen';

  @override
  String get shareHomeAtHome =>
      'Verbinde dich zuerst zu Hause: Teilen geht nur im Heimnetz.';

  @override
  String get shareHomeScanHint =>
      'Mit der Kamera des anderen Handys scannen. Der Code verschwindet nach 2 Minuten.';

  @override
  String get shareHomeHide => 'Code ausblenden';

  @override
  String get shareHomeViaHa =>
      'Dieses Zuhause verbindet sich über Home Assistant. Installiere ZigDash auf dem anderen Handy und melde dich mit Home Assistant an.';

  @override
  String get joinHomeTitle => 'Geteiltes Zuhause hinzufügen';

  @override
  String get joinHomeInvalid =>
      'Dieser Code ist keine ZigDash-Einladung oder beschädigt.';

  @override
  String joinHomeAlready(String name) {
    return '$name ist schon auf diesem Handy.';
  }

  @override
  String get joinHomeOpen => 'Öffnen';

  @override
  String joinHomeAsk(String name) {
    return '$name zu diesem Handy hinzufügen?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash fügt das Zuhause mit derselben Verbindung und demselben Login hinzu und übernimmt die Dashboards vom anderen Handy. Lass dieses Handy im WLAN zu Hause.';

  @override
  String get joinHomeAdd => 'Zuhause hinzufügen';

  @override
  String get joinHomeNoDashboards =>
      'Zuhause hinzugefügt. Die Dashboards kamen nicht an; deine Geräte findest du im Tab Geräte.';

  @override
  String get remoteTitle => 'Fernsteuerung';

  @override
  String get remoteSettingsSubtitle =>
      'Dieses Zuhause von überall steuern, mit Pro';

  @override
  String get remoteIntroTitle => 'Steuern Sie Ihr Zuhause von überall';

  @override
  String get remoteOfferBody =>
      'Erreichen Sie Ihre Geräte auch unterwegs, über das verschlüsselte ZigDash-Relay. Teil von Pro: einmal zahlen, keine monatliche Gebühr. Richten Sie es zu Hause ein.';

  @override
  String get remoteOfferBodyPro =>
      'Sie haben Pro: Schalten Sie die Fernsteuerung zu Hause ein, dann erreichen Sie Ihre Geräte von überall.';

  @override
  String get remoteOfferShow => 'Zeigen';

  @override
  String get remoteIntroBody =>
      'Ihr Hub hält eine Verbindung zum Relay von ZigDash. Unterwegs erreicht dieses Telefon Ihre Geräte darüber. Alles wird auf Hub und Telefon verschlüsselt, das Relay kann Ihre Geräte und was sie tun nicht lesen.';

  @override
  String get remoteNeedsEngine =>
      'Die Fernsteuerung läuft in ZigDash Engine. Installieren Sie es zuerst unter Automationen.';

  @override
  String get remoteSetUp => 'Fernsteuerung einschalten';

  @override
  String get remoteNeedsPro => 'Die Fernsteuerung gehört zu Pro.';

  @override
  String get remoteNotAtHome =>
      'Schalten Sie das zu Hause ein, mit Verbindung zu Ihrem Broker.';

  @override
  String get remoteUnreachable =>
      'Das Relay von ZigDash hat nicht geantwortet. Versuchen Sie es später erneut.';

  @override
  String get remoteRefused =>
      'Das Relay hat abgelehnt. Versuchen Sie es erneut oder melden Sie ein Problem.';

  @override
  String get remoteOnTitle => 'Die Fernsteuerung ist an';

  @override
  String get remoteOnBody =>
      'Unterwegs verbindet sich ZigDash von selbst über das Relay.';

  @override
  String get remoteHubOnline => 'Ihr Hub ist mit dem Relay verbunden';

  @override
  String get remoteHubOffline => 'Ihr Hub ist nicht mit dem Relay verbunden';

  @override
  String get remoteTurnOff => 'Fernsteuerung ausschalten';

  @override
  String get remoteViaRelayNow =>
      'Dieses Telefon ist gerade über das Relay verbunden.';

  @override
  String get remotePhones => 'Telefone mit Fernzugriff';

  @override
  String get remoteThisPhone => 'Dieses Telefon';

  @override
  String get remoteOtherPhone => 'Ein anderes Telefon';

  @override
  String remotePhoneAdded(Object date) {
    return 'Hinzugefügt am $date';
  }

  @override
  String get remoteRemovePhone => 'Entfernen';

  @override
  String get remoteRemovePhoneConfirm =>
      'Dieses Telefon entfernen? Es erreicht dieses Zuhause dann nicht mehr von unterwegs.';

  @override
  String get remoteAddPhone => 'Telefon hinzufügen';

  @override
  String get remoteAddPhoneHint =>
      'Scannen Sie das zu Hause mit der Kamera des anderen Telefons. Es öffnet ZigDash und richtet dort die Fernsteuerung ein. Zeigen Sie es nur Ihren eigenen Telefonen.';

  @override
  String get remoteAddPhoneFailed =>
      'Das Relay hat keinen Zugang für ein weiteres Telefon vergeben. Ein Zuhause kann bis zu fünf haben.';

  @override
  String get remoteBackupSave => 'Schlüssel-Backup speichern';

  @override
  String get remoteBackupRestore => 'Aus Schlüssel-Backup wiederherstellen';

  @override
  String get remoteBackupPassphrase => 'Backup-Passphrase';

  @override
  String get remoteBackupPassphraseHint =>
      'Geht dieses Telefon verloren, bringen Backup und Passphrase die Fernsteuerung auf ein neues. Mindestens 8 Zeichen, und bewahren Sie die Passphrase woanders auf als die Datei.';

  @override
  String get remoteBackupPassphraseAsk =>
      'Die Passphrase, die Sie beim Speichern gewählt haben.';

  @override
  String get remoteBackupPassphraseAgain => 'Passphrase wiederholen';

  @override
  String get remoteBackupSaved => 'Schlüssel-Backup gespeichert';

  @override
  String get remoteBackupWrong => 'Diese Passphrase öffnet das Backup nicht.';

  @override
  String get remoteBackupWrongFile =>
      'Das ist kein Schlüssel-Backup von ZigDash.';

  @override
  String get remotePlayOnly =>
      'Die Fernsteuerung gibt es vorerst in der Google-Play-Version von ZigDash.';

  @override
  String get remotePairTitle => 'Fernsteuerung hinzufügen';

  @override
  String get remotePairBody =>
      'Welches Zuhause ist das? ZigDash speichert den Fernzugang dafür.';

  @override
  String get remotePairNoHomes =>
      'Richten Sie dieses Zuhause zuerst auf diesem Telefon ein, zu Hause. Scannen Sie den Code dann erneut.';

  @override
  String get remotePairInvalid =>
      'Das ist kein Fernsteuerungs-Code von ZigDash, oder er wurde abgeschnitten.';

  @override
  String remotePairDone(Object home) {
    return 'Fernsteuerung ist an für $home';
  }

  @override
  String get remoteReconnectHub => 'Hub neu verbinden';

  @override
  String get remoteTurnOffConfirm =>
      'Dieses Telefon verlässt die Fernsteuerung, und Ihr Hub trennt sich vom Relay. Ein von diesem Telefon gespeichertes Schlüssel-Backup funktioniert dann nicht mehr; andere Telefone behalten ihren Zugang, bis Sie sie entfernen.';

  @override
  String remoteHomeId(Object id) {
    return 'Zuhause-ID $id';
  }

  @override
  String get alertsHintTitle => 'Benachrichtigungen auf diesem Telefon';

  @override
  String get alertsHintBody =>
      'Ein Leck, Rauch, eine geöffnete Tür oder eine schwache Batterie können eine Benachrichtigung an dieses Telefon senden, auch wenn ZigDash geschlossen ist.';

  @override
  String get alertsHintButton => 'Alarme einrichten';

  @override
  String get alertsHintNotNow => 'Nicht jetzt';

  @override
  String get guidedNoZ2mBody =>
      'Hier antwortet ein MQTT-Broker, aber Zigbee2MQTT sendet nichts darüber. Prüfen Sie, ob Zigbee2MQTT gestartet ist und diesen Broker nutzt und ob das Basis-Topic zu seinen Einstellungen passt. Wenn Ihre Zigbee-Geräte in ZHA von Home Assistant sind, kann ZigDash sie nicht sehen: Es arbeitet mit Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT ist auf diesem Broker mit dem Basis-Topic „$found“, dieses Zuhause sucht aber „$current“.';
  }

  @override
  String devicesUseBase(String found) {
    return '„$found“ verwenden';
  }

  @override
  String get devicesChangeConnection => 'Verbindung ändern';
}
