// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Ultimo valore noto';

  @override
  String get reliabilityControlsUnavailable => 'Controlli non disponibili';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'Prova la demo';

  @override
  String get navBrokers => 'Broker';

  @override
  String get navDashboards => 'Dashboard';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settingsDynamicColor => 'Usa i colori Material You';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; altrimenti usa il colore dell\'app';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Case';

  @override
  String connLoadFailed(Object error) {
    return 'Caricamento non riuscito: $error';
  }

  @override
  String get connAddBroker => 'Aggiungi broker';

  @override
  String get connEmpty =>
      'Ancora nessuna connessione.\nTocca \"Aggiungi broker\" per collegare ZigDash al tuo server MQTT.';

  @override
  String get connNew => 'Nuova connessione';

  @override
  String get connEdit => 'Modifica connessione';

  @override
  String get save => 'Salva';

  @override
  String get saving => 'Salvataggio…';

  @override
  String get fieldRequired => 'Obbligatorio';

  @override
  String get connName => 'Nome';

  @override
  String get connNameHint => 'Broker di casa';

  @override
  String get connHost => 'Host';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Host locale';

  @override
  String get connFindBrokers => 'Trova broker';

  @override
  String get connHowToFind => 'Come lo trovo?';

  @override
  String get connRescan => 'Cerca di nuovo';

  @override
  String get connBrokerNeedsLogin => 'Serve il login';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Scansione di $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return '$count broker trovati: tocca per usarne uno';
  }

  @override
  String get connFindBrokersNone => 'Nessun broker trovato sul tuo Wi-Fi.';

  @override
  String get connFindBrokersNoIp =>
      'Impossibile leggere il tuo indirizzo Wi-Fi. Controlla che il Wi-Fi sia attivo e riprova.';

  @override
  String get connHelpTitle => 'Trovare l\'IP del broker';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT in Docker';

  @override
  String get connHelpDockerBody =>
      'L\'IP del broker è l\'indirizzo LAN della macchina che esegue Docker (il tuo NAS, Raspberry Pi, ecc.). Lo trovi nell\'elenco dei dispositivi del router, oppure esegui \'hostname -I\' / \'ip addr\' su quella macchina. La porta di solito è 1883 (Mosquitto). Usa l\'IP LAN dell\'host, non 127.0.0.1, anche se Mosquitto gira in un suo container.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'L\'IP del broker è l\'indirizzo IP dell\'hub. Lo trovi nell\'interfaccia web SMLIGHT sotto Settings → Network, oppure nel router. La porta è 1883, senza nome utente né password di default.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA non ha un broker MQTT: parla direttamente con Home Assistant, quindi ZigDash non può collegarsi. Per usare ZigDash passa a Zigbee2MQTT (disponibile come componente aggiuntivo di Home Assistant o come container Docker), che fornisce un broker MQTT.';

  @override
  String get connHelpSameNetwork =>
      'Il telefono e il broker devono essere sulla stessa rete Wi-Fi (non una rete ospiti o una VLAN isolata).';

  @override
  String get connRemoteHost => 'Host remoto (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Usato quando l\'host locale non è raggiungibile. Meglio l\'IP Tailscale dell\'hub, es. 100.x.y.z';

  @override
  String get connPort => 'Porta';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsername => 'Nome utente';

  @override
  String get connUsernameOptional => 'Nome utente (facoltativo)';

  @override
  String get connPasswordOptional => 'Password (facoltativa)';

  @override
  String get connPasswordKeepHint =>
      'Lascia vuoto per mantenere quella attuale';

  @override
  String get connAutoConnect => 'Connetti all\'avvio dell\'app';

  @override
  String get advanced => 'Avanzate';

  @override
  String get connKeepAlive => 'Keep-alive (secondi)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protocollo';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get cancel => 'Annulla';

  @override
  String get connDeleteTitle => 'Eliminare la connessione?';

  @override
  String connDeleteContent(Object name) {
    return 'Rimuove \"$name\", le sue dashboard/pannelli e la password salvata.';
  }

  @override
  String get statusDisconnected => 'Disconnesso';

  @override
  String get statusConnecting => 'Connessione in corso';

  @override
  String get statusConnected => 'Connesso';

  @override
  String get statusReconnecting => 'Riconnessione in corso';

  @override
  String get statusError => 'Errore';

  @override
  String get statusConnectedRemote => 'Connesso · Remoto';

  @override
  String get dashPlaceholder =>
      'Apri un broker dalla scheda Broker per vedere e gestire le sue dashboard.';

  @override
  String get dashAddDashboard => 'Aggiungi dashboard';

  @override
  String get dashEditDashboard => 'Modifica dashboard';

  @override
  String get dashAddPanel => 'Aggiungi pannello';

  @override
  String get dashEmpty =>
      'Ancora nessuna dashboard.\nTocca \"Aggiungi dashboard\" per crearne una per questo broker.';

  @override
  String dashLoadFailed(Object error) {
    return 'Non riuscito: $error';
  }

  @override
  String get panelPickerTitle => 'Aggiungi un pannello';

  @override
  String get panelPickerSectionControl => 'Controllo';

  @override
  String get panelPickerSectionState => 'Stato';

  @override
  String get panelPickerToggleTitle => 'Interruttore';

  @override
  String get panelPickerToggleSubtitle =>
      'Interruttore on/off per lo stato di un dispositivo';

  @override
  String get panelPickerSliderBrightnessTitle => 'Cursore — Luminosità';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Regolazione luce (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Cursore — Posizione';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Tapparella / tenda (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Tapparella';

  @override
  String get panelPickerCoverSubtitle =>
      'Tapparella/tenda: APRI·STOP·CHIUDI + cursore di posizione';

  @override
  String get panelPickerScheduleTitle => 'Programma';

  @override
  String get panelPickerScheduleSubtitle =>
      'Orari giornalieri di apertura/chiusura, eseguiti sull\'hub (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Regola di chiusura automatica';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Chiude un dispositivo in automatico N secondi dopo l\'accensione, eseguita sull\'hub (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Multi-stato';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Pulsanti segmentati per un enum (es. OPEN/STOP/CLOSE)';

  @override
  String get panelPickerComboTitle => 'Combo';

  @override
  String get panelPickerComboSubtitle => 'Menu a tendina per un enum';

  @override
  String get panelPickerRadioTitle => 'Radio';

  @override
  String get panelPickerRadioSubtitle => 'Elenco di pulsanti radio per un enum';

  @override
  String get panelPickerButtonTitle => 'Pulsante';

  @override
  String get panelPickerButtonSubtitle => 'Invia un comando singolo';

  @override
  String get panelPickerTextInputTitle => 'Input di testo';

  @override
  String get panelPickerTextInputSubtitle => 'Pubblica un valore libero o JSON';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Indicatore colorato per uno stato booleano (contatto, perdita)';

  @override
  String get panelPickerNodeStatusTitle => 'Stato nodo';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Disponibilità del dispositivo Z2M (online/offline)';

  @override
  String get panelPickerProgressTitle => 'Barra';

  @override
  String get panelPickerProgressSubtitle =>
      'Barra numerica per batteria, qualità del collegamento, ecc.';

  @override
  String get panelPickerTextLogTitle => 'Log di testo';

  @override
  String get panelPickerTextLogSubtitle =>
      'Cronologia scorrevole dei messaggi su un topic';

  @override
  String get dashExportMenu => 'Esporta dashboard';

  @override
  String get dashImportMenu => 'Importa dashboard';

  @override
  String get dashExportTitle => 'Esporta dashboard';

  @override
  String get dashExportClose => 'Chiudi';

  @override
  String get dashExportCopy => 'Copia';

  @override
  String get dashExportCopied => 'Copiato negli appunti';

  @override
  String get dashImportTitle => 'Importa dashboard';

  @override
  String get dashImportHint => 'Incolla qui il JSON esportato';

  @override
  String get dashImportButton => 'Importa';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importate $count dashboard',
      one: 'Importata 1 dashboard',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Importazione non riuscita: $error';
  }

  @override
  String get dashFormNew => 'Nuova dashboard';

  @override
  String get dashFormEdit => 'Modifica dashboard';

  @override
  String get dashFormName => 'Nome';

  @override
  String get dashFormNameHint => 'Ufficio';

  @override
  String get dashFormTopicPrefix => 'Prefisso topic (facoltativo)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/living-room';

  @override
  String get dashFormTopicPrefixHelper =>
      'Aggiunto davanti al topic di ogni pannello di questa dashboard';

  @override
  String get dashFormColorSeed => 'Colore di base';

  @override
  String get dashFormIcon => 'Icona';

  @override
  String get dashFormLock => 'Blocco modifica';

  @override
  String get dashFormLockSubtitle => 'Nasconde Modifica per questa dashboard';

  @override
  String get dashFormDelete => 'Elimina dashboard';

  @override
  String get dashDeleteTitle => 'Eliminare questa dashboard?';

  @override
  String get dashDeleteContent =>
      'Verranno rimossi anche tutti i suoi pannelli.';

  @override
  String get dashDeleteConfirm => 'Elimina';

  @override
  String panelFormNew(Object type) {
    return 'Nuovo $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Modifica $type';
  }

  @override
  String get panelTypeButton => 'Pulsante';

  @override
  String get panelTypeToggle => 'Interruttore';

  @override
  String get panelTypeSlider => 'Cursore';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Stato nodo';

  @override
  String get panelTypeProgress => 'Barra';

  @override
  String get panelTypeMultiState => 'Multi-stato';

  @override
  String get panelTypeCombo => 'Combo';

  @override
  String get panelTypeRadio => 'Radio';

  @override
  String get panelTypeCover => 'Tapparella';

  @override
  String get panelTypeTextInput => 'Input di testo';

  @override
  String get panelTypeTextLog => 'Log di testo';

  @override
  String get panelTypeSchedule => 'Programma';

  @override
  String get panelTypeAutoClose => 'Chiusura automatica';

  @override
  String get panelTypeDevice => 'Dispositivo';

  @override
  String get panelTypeReading => 'Lettura';

  @override
  String get panelFormName => 'Nome';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Prefisso della dashboard: $prefix/ (usato se non lo sostituisci qui sotto)';
  }

  @override
  String get panelFormTopicPrefixOverride =>
      'Prefisso topic alternativo (facoltativo)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/shutter';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Usa un altro dispositivo in questa dashboard. Vuoto = usa il prefisso della dashboard.';

  @override
  String get panelFormPublishTopic => 'Topic di pubblicazione (suffisso)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Aggiunto al prefisso effettivo. Lascia vuoto per pubblicare sul prefisso stesso.';

  @override
  String get panelFormTopicSuffix => 'Topic (suffisso)';

  @override
  String get panelFormSubscribeTopic =>
      'Topic di sottoscrizione (suffisso, facoltativo)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Aggiunto al prefisso della dashboard. Vuoto = sottoscrivi il prefisso stesso (stato Z2M).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Vuoto = sottoscrivi il prefisso stesso (stato Z2M). Uguale al topic di pubblicazione = usa quello.';

  @override
  String get tileSize => 'Dimensione';

  @override
  String get tileSizeSmall => 'Piccola';

  @override
  String get tileSizeWide => 'Larga';

  @override
  String get tileSizeFull => 'Intera';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — al massimo una volta';

  @override
  String get panelFormQos1 => '1 — almeno una volta';

  @override
  String get panelFormQos2 => '2 — esattamente una volta';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'Payload acceso';

  @override
  String get panelToggleOffPayload => 'Payload spento';

  @override
  String get panelToggleJsonPath => 'Percorso JSON (facoltativo)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'Valore acceso';

  @override
  String get panelToggleOnMatchHelper =>
      'Valore nel percorso JSON che significa \"acceso\" (es. \"ON\")';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Max';

  @override
  String get panelSliderStep => 'Passo';

  @override
  String get panelSliderTemplate => 'Modello del valore';

  @override
  String get panelSliderTemplateHelper =>
      'Usa la parola value come segnaposto: viene sostituita con il valore del cursore';

  @override
  String get panelSliderJsonPath => 'Percorso JSON (facoltativo)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'Percorso JSON (facoltativo)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'es. \"contact\", \"occupancy\", \"water_leak\"';

  @override
  String get panelLedOnMatch => 'Valore acceso';

  @override
  String get panelLedOnMatchHelper =>
      'Valore nel percorso JSON che accende il LED (es. \"true\", \"ON\")';

  @override
  String get panelLedOnLabel => 'Etichetta acceso (facoltativa)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Etichetta spento (facoltativa)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Payload online';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Valore che significa \"online\" (default Z2M: \"online\")';

  @override
  String get panelNodeJsonPath => 'Percorso JSON (facoltativo)';

  @override
  String get panelNodeJsonPathHelper =>
      'Lascia vuoto per il default Z2M (stringa semplice \"online\"/\"offline\")';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Max';

  @override
  String get panelProgressUnit => 'Unità';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'Percorso JSON (facoltativo)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'es. \"battery\", \"linkquality\"';

  @override
  String get panelOptionsJsonPath => 'Percorso JSON (facoltativo)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Campo del payload ricevuto che contiene il valore attuale';

  @override
  String get panelOptionsHeader => 'Opzioni';

  @override
  String get panelOptionsLabel => 'Etichetta';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Corrispondenza (valore attuale)';

  @override
  String get panelOptionsAdd => 'Aggiungi opzione';

  @override
  String get panelCoverDescription =>
      'Pulsanti APRI / STOP / CHIUDI più una fila di posizioni predefinite. Usa i payload standard Z2M per tapparelle (state e position).';

  @override
  String get panelCoverPresets => 'Posizioni predefinite';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Percentuali separate da virgole (0–100). Vuoto = nessuna fila di posizioni.';

  @override
  String get panelCoverShowSlider => 'Mostra il cursore di posizione';

  @override
  String get panelTextInputHint => 'Suggerimento (facoltativo)';

  @override
  String get panelTextInputHintHint => 'Scrivi un valore…';

  @override
  String get panelTextInputTemplate => 'Modello';

  @override
  String get panelTextInputTemplateHelper =>
      'Usa la parola value come segnaposto: viene sostituita con il testo digitato. Di default pubblica il testo così com\'è.';

  @override
  String get panelTextInputClearAfterSend => 'Svuota dopo l\'invio';

  @override
  String get panelTextLogMaxLines => 'Righe massime';

  @override
  String get panelTextLogMaxLinesHelper => 'Quanti messaggi recenti conservare';

  @override
  String get panelTextLogJsonPath => 'Percorso JSON (facoltativo)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Registra solo questo campo invece dell\'intero payload';

  @override
  String get panelScheduleDescription =>
      'Gira sullo SMHUB tramite Node-RED: scatta anche quando il telefono è spento. Il topic di pubblicazione qui sopra è la destinazione del comando della tapparella.';

  @override
  String get panelScheduleOpenTime => 'Ora di apertura';

  @override
  String get panelScheduleCloseTime => 'Ora di chiusura';

  @override
  String get panelScheduleOpenPayload => 'Payload di apertura';

  @override
  String get panelScheduleClosePayload => 'Payload di chiusura';

  @override
  String get panelScheduleEnabled => 'Attivo';

  @override
  String get panelScheduleSavedOffline =>
      'Salvato, ma non connesso: il programma si sincronizzerà quando sarai online.';

  @override
  String get panelAutoCloseDescription =>
      'Gira sullo SMHUB tramite Node-RED: scatta anche quando il telefono è spento. Il topic di pubblicazione qui sopra è la destinazione del comando del dispositivo (es. porta).';

  @override
  String get panelAutoCloseTriggerPath => 'Percorso JSON di attivazione';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Campo del JSON di stato del dispositivo da osservare (default: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Valore di attivazione';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Avvia il timer quando il campo di attivazione è uguale a questo valore (default: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Payload di chiusura';

  @override
  String get panelAutoCloseDelaySeconds => 'Ritardo (secondi)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1-3600. Tempo di attesa dopo l\'accensione del dispositivo prima di pubblicare il payload di chiusura.';

  @override
  String get panelAutoCloseEnabled => 'Attiva';

  @override
  String get panelAutoCloseSavedOffline =>
      'Salvata, ma non connesso: la regola si sincronizzerà quando sarai online.';

  @override
  String get panelTileEdit => 'Modifica pannello';

  @override
  String get panelTileDuplicate => 'Duplica pannello';

  @override
  String get panelTileMoveUp => 'Sposta su';

  @override
  String get panelTileMoveDown => 'Sposta giù';

  @override
  String get panelTileDelete => 'Elimina pannello';

  @override
  String get panelCoverOpen => 'Apri';

  @override
  String get panelCoverStop => 'Stop';

  @override
  String get panelCoverClose => 'Chiudi';

  @override
  String get panelToggleNoState => '(nessuno stato)';

  @override
  String get panelToggleError => 'err';

  @override
  String get panelStateOn => 'ON';

  @override
  String get panelStateOff => 'OFF';

  @override
  String get panelNodeStatusOnline => 'online';

  @override
  String get panelNodeStatusOffline => 'offline';

  @override
  String get panelNodeStatusUnknown => 'sconosciuto';

  @override
  String get panelNodeStatusError => 'errore';

  @override
  String get panelMultiStateNoOptions => 'Nessuna opzione configurata';

  @override
  String get panelTextInputDefaultHint => 'Scrivi un valore…';

  @override
  String get panelTextLogWaiting => 'In attesa di messaggi…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Apre alle $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Chiude alle $time';
  }

  @override
  String get panelScheduleOfflineWarning =>
      'Programmatore offline: non verrà eseguito';

  @override
  String get panelScheduleDisabled => 'Disattivato';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Prossimo: $action alle $at';
  }

  @override
  String get panelScheduleActionOpen => 'apertura';

  @override
  String get panelScheduleActionClose => 'chiusura';

  @override
  String get panelAutoCloseIdle => 'In attesa';

  @override
  String get panelAutoCloseDisabled => 'Disattivata';

  @override
  String get panelAutoCloseOffline =>
      'Automazione offline: la regola non verrà eseguita';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Chiusura tra ${seconds}s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Chiusura in corso…';

  @override
  String get panelGridEmpty =>
      'Ancora nessun riquadro.\nTocca Aggiungi riquadro per mettere qui i tuoi dispositivi.';

  @override
  String get panelsOffline => 'Offline: mostro gli ultimi valori';

  @override
  String get connectionConnecting => 'Connessione in corso…';

  @override
  String get connectionReconnecting => 'Riconnessione in corso…';

  @override
  String get connectionShowingLastKnownValues =>
      'Mostro gli ultimi valori noti';

  @override
  String get connectionFailed => 'Connessione non riuscita';

  @override
  String get connectionAutomaticRetry => 'Continuerò a riprovare in automatico';

  @override
  String get connectionReconnectNow => 'Riconnetti ora';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get settingsHelp => 'Aiuto e guida';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get settingsRateApp => 'Valuta ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Ti piace? Una breve recensione aiuta altri a trovarla.';

  @override
  String get settingsFeatureRequest => 'Proponi una funzione';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Dimmi cosa renderebbe ZigDash migliore.';

  @override
  String get featureRequestGithub => 'Su GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Pubblica: altri possono vederla e votarla.';

  @override
  String get featureRequestEmail => 'Via email';

  @override
  String get featureRequestEmailSubtitle =>
      'Privata, direttamente allo sviluppatore.';

  @override
  String get featureRequestEmailSubject => 'Richiesta di funzione ZigDash';

  @override
  String get featureRequestEmailPrompt =>
      'Cosa vorresti che facesse ZigDash, e perché?';

  @override
  String get settingsReportProblem => 'Segnala un problema';

  @override
  String get settingsReportProblemSubtitle =>
      'Qualcosa non funziona o non è chiaro? Dimmelo.';

  @override
  String get reportProblemEmailSubject => 'Segnalazione di problema ZigDash';

  @override
  String get reportProblemEmailPrompt =>
      'Cos\'è successo, e cosa ti aspettavi?';

  @override
  String get settingsBuyCoffee => 'Offrimi un caffè';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Gratis e open source: le mance tengono accesa la moka.';

  @override
  String get a11yBackupMenu => 'Backup e ripristino';

  @override
  String get a11ySelectColor => 'Scegli colore';

  @override
  String get a11ySelectIcon => 'Scegli icona';

  @override
  String get a11yDeleteOption => 'Elimina opzione';

  @override
  String get a11yPanelOptions => 'Opzioni pannello';

  @override
  String get a11yMoreOptions => 'Altre opzioni';

  @override
  String get a11yRefresh => 'Aggiorna';

  @override
  String get a11yDeleteConnection => 'Elimina connessione';

  @override
  String get controlNotConnected => 'Non connesso: modifica non inviata';

  @override
  String get discoverFromDevice => 'Aggiungi da un dispositivo…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Rileva in automatico un dispositivo Zigbee2MQTT';

  @override
  String get discoverTitle => 'Aggiungi da dispositivo';

  @override
  String get discoverBaseTopic => 'Topic base di Zigbee2MQTT';

  @override
  String get discoverScanning => 'Ricerca dispositivi…';

  @override
  String get discoverNone => 'Nessun dispositivo trovato.';

  @override
  String get discoverFailed =>
      'Nessun elenco dispositivi trovato. Controlla il topic base e che il broker sia connesso.';

  @override
  String get retry => 'Riprova';

  @override
  String get previewTitle => 'Anteprima dal vivo';

  @override
  String previewWaiting(Object topic) {
    return 'In attesa di un messaggio su $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Estratto ($path): $value';
  }

  @override
  String get previewNoValue => '(nessun valore in questo percorso)';

  @override
  String get connErrorTitle => 'Errore di connessione';

  @override
  String get connErrorUnknown => 'Nessun dettaglio sull\'errore disponibile.';

  @override
  String get connTestButton => 'Prova connessione';

  @override
  String get connTestOk => 'Connessione riuscita';

  @override
  String connTestFailed(Object error) {
    return 'Connessione non riuscita: $error';
  }

  @override
  String get devicesTitle => 'Dispositivi';

  @override
  String get devicesAddButton => 'Aggiungi dispositivo';

  @override
  String get devicesPairingTitle =>
      'Abbinamento: premi il pulsante del dispositivo';

  @override
  String devicesPairingHint(int seconds) {
    return 'Ricerca di nuovi dispositivi… ${seconds}s';
  }

  @override
  String get devicesPairingStop => 'Stop';

  @override
  String get devicesNone => 'Nessun dispositivo trovato.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT non ha inviato l\'elenco dei dispositivi. Può succedere dopo il riavvio del broker MQTT.';

  @override
  String get devicesRestartZ2m => 'Riavvia Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Riavvio di Zigbee2MQTT. I tuoi dispositivi dovrebbero comparire tra qualche secondo.';

  @override
  String get devicesBattery => 'Batteria';

  @override
  String get devicesLinkQuality => 'Segnale';

  @override
  String get devicesOnline => 'Online';

  @override
  String get devicesOffline => 'Offline';

  @override
  String devicesPaired(Object name) {
    return 'Pronto: $name';
  }

  @override
  String get devicesPairedHint =>
      'Aggiunto alla tua rete. Per metterlo su una dashboard, usa \'Aggiungi da un dispositivo\' in quella dashboard.';

  @override
  String get scenesTitle => 'Scene';

  @override
  String get scenesNone =>
      'Ancora nessuna scena. Imposta i dispositivi come preferisci, poi salvali come scena.';

  @override
  String get scenesNewButton => 'Nuova scena';

  @override
  String scenesActivated(Object name) {
    return '$name attivata';
  }

  @override
  String get scenesActivateOffline =>
      'Non connesso: impossibile attivare la scena';

  @override
  String get sceneFormNewTitle => 'Nuova scena';

  @override
  String get sceneFormEditTitle => 'Modifica scena';

  @override
  String get sceneFormNameLabel => 'Nome della scena';

  @override
  String get sceneFormDevicesHeader => 'Dispositivi da salvare';

  @override
  String get sceneFormCaptureHint =>
      'Viene salvato lo stato impostabile attuale di ogni dispositivo selezionato (acceso/spento, luminosità, colore, posizione…). I valori di sola lettura vengono ignorati.';

  @override
  String get sceneFormNoDevices =>
      'Nessun dispositivo controllabile trovato. Controlla che siano abbinati, poi tocca aggiorna.';

  @override
  String get sceneFormReadingState => 'Lettura dello stato attuale…';

  @override
  String get sceneCtrlPower => 'Accensione';

  @override
  String get sceneCtrlBrightness => 'Luminosità';

  @override
  String get sceneCtrlPosition => 'Posizione';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count selezionati';
  }

  @override
  String get sceneFormNoDevicesSelected =>
      'Seleziona almeno un dispositivo da salvare.';

  @override
  String get sceneFormNothingCaptured =>
      'Non è stato salvato nulla di impostabile dai dispositivi selezionati.';

  @override
  String get sceneDeleteTitle => 'Eliminare la scena?';

  @override
  String sceneDeleteMessage(Object name) {
    return '\"$name\" verrà rimossa. I dispositivi mantengono lo stato attuale.';
  }

  @override
  String get sceneEditAction => 'Modifica';

  @override
  String get sceneDeleteAction => 'Elimina';

  @override
  String get sceneAddToDashboard => 'Aggiungi alla dashboard';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Aggiunta a $name';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count dispositivi';
  }

  @override
  String get scenesAllShutters => 'Tutte le tapparelle';

  @override
  String get sceneCloseAllShutters => 'Chiudi tutte le tapparelle';

  @override
  String get sceneOpenAllShutters => 'Apri tutte le tapparelle';

  @override
  String get sceneStopAllShutters => 'Ferma tutte le tapparelle';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tapparelle',
      one: '1 tapparella',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Quali tapparelle…';

  @override
  String get sceneWhichShuttersHint =>
      'Sono incluse tutte le tapparelle di questa casa. Togli la spunta a quelle da escludere, come la porta del garage.';

  @override
  String get scenesYours => 'Le tue scene';

  @override
  String get panelTypeScene => 'Scena';

  @override
  String get panelPickerSceneTitle => 'Pulsante scena';

  @override
  String get panelPickerSceneSubtitle => 'Un tocco attiva una scena salvata';

  @override
  String get panelSceneChoose => 'Scena';

  @override
  String get panelSceneMissing => 'Scena non trovata: sceglila di nuovo';

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
  String get guidedConnectTitle => 'Configura il tuo broker';

  @override
  String get guidedConnectIntro =>
      'Proveremo ogni passaggio della connessione e mostreremo i tuoi dispositivi Zigbee.';

  @override
  String get guidedBaseTopic => 'Topic base';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Prova e connetti';

  @override
  String get guidedTesting => 'Prova della connessione…';

  @override
  String get stepResolve => 'Risoluzione dell\'host';

  @override
  String get stepTcp => 'Connessione TCP';

  @override
  String get stepConnack => 'Handshake MQTT';

  @override
  String get stepAuth => 'Autenticazione';

  @override
  String get stepDevices => 'Ricerca dispositivi';

  @override
  String get diagResolveFail =>
      'Impossibile risolvere il nome host. Controlla l\'indirizzo che hai inserito.';

  @override
  String get diagResolveTimeout =>
      'Tempo scaduto per la risoluzione dell\'host. Controlla l\'indirizzo e la tua rete.';

  @override
  String get diagTcpFail =>
      'Impossibile raggiungere il broker. Zigbee2MQTT è in esecuzione? Controlla indirizzo e porta.';

  @override
  String get diagTcpTimeout =>
      'Tempo scaduto per la connessione al broker. Potrebbe essere offline o non raggiungibile.';

  @override
  String get diagConnackFail =>
      'Il broker non ha completato l\'handshake MQTT. Controlla che sia un broker MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'Il broker non ha risposto al login in tempo. Home Assistant può impiegare qualche secondo per verificarlo, quindi riprova.';

  @override
  String get diagAuthRejected =>
      'Il broker ha rifiutato nome utente o password. Controlla le credenziali.';

  @override
  String get diagAuthRefused =>
      'Il broker ha rifiutato la connessione. Controlla le impostazioni di connessione.';

  @override
  String get diagResolveLocalName =>
      'Il telefono non ha trovato questo nome. Android spesso non riesce a risolvere i nomi che finiscono in .local, quindi inserisci l\'indirizzo IP (Home Assistant lo mostra in Impostazioni › Sistema › Rete).';

  @override
  String get diagTcpHaNoBroker =>
      'Questo è il tuo Home Assistant, ma non c\'è nessun broker MQTT in esecuzione. Installa e avvia il componente aggiuntivo Mosquitto broker (Impostazioni › Componenti aggiuntivi), poi riprova.';

  @override
  String get diagTcpSmlightClosed =>
      'Questo è il tuo hub SMLIGHT, ma il suo broker MQTT non accetta connessioni da altri dispositivi. Nella pagina web dell\'hub apri Settings › MQTT, attiva Allow External, salva e riprova.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'A questo indirizzo gira Zigbee2MQTT, ma raggiunge il suo broker con un altro nome (vedi Zigbee2MQTT › Settings › MQTT › Server). Se è un\'altra macchina, scrivi il suo indirizzo, di solito con la porta 1883. Se è un container su questa macchina, pubblica la sua porta (ports: \"1883:1883\") e lascialo in ascolto sulla rete, poi riprova.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Zigbee2MQTT gira a questo indirizzo, ma il suo broker MQTT non accetta connessioni da altri dispositivi. Mosquitto ascolta solo sulla propria macchina finché non aggiungi le righe \"listener 1883\" e \"allow_anonymous true\" a mosquitto.conf (o imposti una password). Riavvia Mosquitto e riprova.';

  @override
  String get diagAuthRejectedHa =>
      'Il broker di Home Assistant ha rifiutato questo login. Usa nome e password di un utente di Home Assistant (Impostazioni › Persone › Utenti); un utente separato solo per MQTT è la scelta migliore.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trovati $count dispositivi',
      one: 'Trovato 1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get foundDevicesHint =>
      'I tuoi dispositivi Zigbee sono visibili. Continua per creare la tua dashboard.';

  @override
  String get noDevicesTitle => 'Connesso, ma ancora nessun dispositivo';

  @override
  String get noDevicesHint =>
      'ZigDash vede il tuo broker, ma non ha ancora trovato dispositivi Zigbee. Puoi avviare l\'abbinamento per aggiungerli.';

  @override
  String get startPairing => 'Avvia abbinamento';

  @override
  String get pairingEnabled =>
      'L\'abbinamento è attivo. Premi il pulsante di abbinamento sul dispositivo per collegarlo.';

  @override
  String get continueToDashboard => 'Continua alla dashboard';

  @override
  String get guidedBackToForm => 'Modifica impostazioni';

  @override
  String get guidedStuckTitle => 'Bloccato? Chiedi a una persona';

  @override
  String get guidedStuckBody =>
      'Due tentativi senza connessione. Dicci che hub hai e cosa hai scritto, e ti aiutiamo a trovarlo.';

  @override
  String get guidedStuckTelegram => 'Chiedi su Telegram';

  @override
  String get guidedStuckHelp => 'Consigli ed email';

  @override
  String ladderTriedHint(Object count) {
    return 'Provati $count indirizzi';
  }

  @override
  String get guidedSaveFailed => 'Impossibile salvare la connessione. Riprova.';

  @override
  String get setupWelcomeTitle => 'Benvenuto in ZigDash';

  @override
  String get setupWelcomeHeadline => 'La tua casa Zigbee, sul tuo telefono';

  @override
  String get setupWelcomeBody =>
      'Ti basta un piccolo hub con Zigbee2MQTT: un hub SMLIGHT, un Raspberry Pi o qualsiasi macchina Linux. Home Assistant non serve, e se ce l\'hai, ZigDash funziona anche con quello. Tutto resta in locale, senza cloud.';

  @override
  String get setupFindMySetup => 'Trova la mia configurazione';

  @override
  String get setupErrPageTitle => 'La pagina Zigbee2MQTT non ha risposto';

  @override
  String get setupErrPageBody =>
      'Nessuna pagina Zigbee2MQTT ha risposto a quell\'indirizzo. Aprilo nel browser di questo telefono per controllarlo e copia l\'indirizzo esatto (con la porta, spesso 8080). Se la pagina chiede un token, inserisci invece i dati del broker.';

  @override
  String get setupErrPageAction => 'Riprova';

  @override
  String get setupLookWider => 'Cerca su tutta la rete';

  @override
  String get setupAsk => 'Cosa fa funzionare il tuo Zigbee?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'Su un Raspberry Pi, un server o Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'Con il componente aggiuntivo Zigbee2MQTT, o ZHA';

  @override
  String get setupAskSmlight => 'Un hub SMLIGHT';

  @override
  String get setupAskSmlightSub => 'SLZB o SMHUB con Zigbee2MQTT';

  @override
  String get setupAskNothing => 'Ancora niente?';

  @override
  String get setupAskHaWhich => 'Come gestisce Zigbee il tuo Home Assistant?';

  @override
  String get setupAskHaZ2m => 'Il componente aggiuntivo Zigbee2MQTT';

  @override
  String get setupAskHaZ2mSub => 'Accedi con Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, lo Zigbee integrato di Home Assistant';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, senza Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Collegati alla mia pagina Zigbee2MQTT';

  @override
  String get setupManualEntryAdvanced => 'Dati del broker (avanzato)';

  @override
  String get z2mPageTitle => 'La tua pagina Zigbee2MQTT';

  @override
  String get z2mPageBody =>
      'L\'indirizzo nel browser quando la pagina Zigbee2MQTT è aperta, quella dove abbini i dispositivi. Non servono nome utente né password MQTT.';

  @override
  String get z2mPageLabel => 'Indirizzo della pagina';

  @override
  String get z2mPageConnect => 'Collega';

  @override
  String z2mPageFoundName(String host, String ip) {
    return '$host trovato a $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Nessuna risposta per $host su questa rete';
  }

  @override
  String get engineNeedsBrokerTitle =>
      'Le automazioni hanno bisogno del tuo broker MQTT';

  @override
  String get engineNeedsBrokerBody =>
      'Questa casa si collega tramite la pagina Zigbee2MQTT, che basta per le dashboard. Automazioni, avvisi e cronologia funzionano nel ZigDash Engine sul tuo hub, che comunica tramite il broker MQTT. Inserisci i suoi dati una volta e da allora ZigDash si collegherà tramite il broker.';

  @override
  String get engineNeedsBrokerButton => 'Inserisci i dati del broker';

  @override
  String get connFromPageNote =>
      'Questa casa si collega tramite la pagina Zigbee2MQTT. Inserisci il tuo broker MQTT (di solito la stessa macchina, porta 1883) per attivare automazioni, avvisi e cronologia. Dopo il salvataggio ZigDash si collega tramite il broker.';

  @override
  String get setupManualEntry => 'Inserisci i dati a mano';

  @override
  String get setupScanningTitle => 'Ricerca di una connessione…';

  @override
  String get setupScanningHint =>
      'Tieni questo dispositivo sulla stessa rete locale dell\'host di Zigbee2MQTT.';

  @override
  String get setupCandidateFound => 'Possibile connessione trovata';

  @override
  String get setupNoCandidatesTitle => 'Nessuna connessione trovata';

  @override
  String get setupNoCandidatesBody => 'Dove gira Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: controlla che il componente aggiuntivo del broker MQTT (es. Mosquitto) e quello di Zigbee2MQTT siano installati e in esecuzione.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: controlla che il broker (es. Mosquitto) e il servizio Zigbee2MQTT siano in esecuzione e che la porta 1883 sia raggiungibile.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: apri l\'interfaccia web del dispositivo, vai in Settings > MQTT, attiva Allow External così il telefono può raggiungere il broker, e controlla che Zigbee2MQTT risulti in esecuzione.';

  @override
  String get setupTryAgain => 'Riprova';

  @override
  String get reminderButton => 'Ricordamelo domani';

  @override
  String get reminderSet => 'Te lo ricorderemo domani, su questo telefono.';

  @override
  String get reminderNoPermission =>
      'Le notifiche di ZigDash sono disattivate, quindi niente promemoria. Puoi attivarle nelle impostazioni di Android.';

  @override
  String get reminderChannel => 'Promemoria configurazione';

  @override
  String get reminderTitle => 'Completa la configurazione di ZigDash';

  @override
  String get reminderBody =>
      'A casa sul tuo Wi-Fi? Tocca per riprovare: ci vuole circa un minuto.';

  @override
  String get setupWelcomeNoZ2m => 'Non hai ancora Zigbee2MQTT?';

  @override
  String get setupWelcomeDemo => 'Prova la casa demo';

  @override
  String get setupWelcomeHubs => 'Quale hub scegliere';

  @override
  String get haConnectTitle => 'Connetti tramite Home Assistant';

  @override
  String get haConnectIntro =>
      'Il tuo telefono non raggiunge il broker, ma raggiunge Home Assistant. Accedi una volta e ZigDash parlerà con Zigbee2MQTT tramite Home Assistant: a casa o fuori, senza impostazioni del broker.';

  @override
  String get haConnectAddressHelp =>
      'L\'indirizzo con cui apri Home Assistant: 192.168.1.20:8123, oppure un indirizzo remoto come quello di Nabu Casa o Cloudflare';

  @override
  String get haConnectSignInHelp =>
      'L\'accesso di Home Assistant si apre nel tuo browser. ZigDash non vede mai la tua password.';

  @override
  String get haConnectKeeps =>
      'ZigDash conserva questo accesso sul tuo telefono e agisce come te in Home Assistant, solo per MQTT. Puoi terminarlo in qualsiasi momento in Home Assistant, in Profilo › Sicurezza.';

  @override
  String get haConnectTokenHelp =>
      'In Home Assistant apri il tuo profilo, poi Sicurezza › Token di accesso a lunga durata › Crea token. Copialo e incollalo qui. ZigDash lo conserva su questo telefono per connettersi; eliminalo in Home Assistant quando vuoi terminare.';

  @override
  String get haConnectWithToken => 'Connetti con token';

  @override
  String get haConnectChecking => 'Controllo di Home Assistant…';

  @override
  String get setupStillChecking =>
      'Verifica in corso. Può richiedere fino a 30 secondi.';

  @override
  String get aiHelpTitle => 'Bloccato? Chiedi al tuo assistente IA';

  @override
  String get aiHelpBody =>
      'ZigDash riassume ciò che ha trovato per ChatGPT, Claude, Gemini o qualsiasi app di IA, senza password né indirizzi. Lo vedi prima di condividerlo.';

  @override
  String get aiHelpButton => 'Chiedi a un\'IA';

  @override
  String get aiHelpPreviewTitle => 'Cosa verrà condiviso';

  @override
  String get aiHelpShare => 'Condividi con un\'app di IA';

  @override
  String get aiHelpCopied => 'Copiato. Incollalo in qualsiasi chat di IA.';

  @override
  String get haConnectWhereAddress =>
      'Non sai qual è? Nell\'app Home Assistant apri Impostazioni › App companion e tocca il tuo server: l\'indirizzo è lì. Sul computer, è quello che il browser mostra con Home Assistant aperto.';

  @override
  String get haFindLooking => 'Ricerca di Home Assistant su questa rete…';

  @override
  String get haFindSeveral =>
      'Trovato più di un Home Assistant. Tocca quello da usare:';

  @override
  String get haFindNone =>
      'Questo telefono non vede Home Assistant su questa rete Wi-Fi. Usa l\'indirizzo che apre la tua app Home Assistant: spesso uno remoto, come https://abcd1234.ui.nabu.casa o https://casamia.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Quell\'indirizzo è su una rete diversa da quella di questo telefono, che è su $network. Usa l\'indirizzo che apre la tua app Home Assistant, spesso uno remoto, oppure collega il telefono alla rete di Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Questo telefono non ha trovato quel nome: Android spesso non apre i nomi .local. Digita l\'indirizzo IP di Home Assistant (come 192.168.1.20:8123) o il suo indirizzo remoto.';

  @override
  String get haConnectRemoteUnreachable =>
      'Non ha risposto nulla a quell\'indirizzo remoto. Aprilo nel browser di questo telefono per controllare che funzioni, e copialo esattamente come lo mostra la tua app Home Assistant.';

  @override
  String get setupNoWifiHa => 'Usi Home Assistant? Accedi';

  @override
  String get haConnectNotAdmin =>
      'Il tuo utente Home Assistant non è amministratore. ZigDash ne ha bisogno per l\'MQTT di Home Assistant. Accedi come amministratore, oppure incolla un token creato da un amministratore.';

  @override
  String get haConnectNoMqtt =>
      'Questo Home Assistant non ha l\'integrazione MQTT. Anche Zigbee2MQTT ne ha bisogno: in Home Assistant aggiungi il componente aggiuntivo Mosquitto broker e l\'integrazione MQTT, poi riprova.';

  @override
  String get haConnectSignInFailed =>
      'L\'accesso non è stato completato. Riprova, oppure usa un token a lunga durata.';

  @override
  String get setupHaShortcut =>
      'Zigbee2MQTT gira in Home Assistant? Salta il broker e il suo login: accedi con il tuo account amministratore di Home Assistant. Funziona da qualsiasi rete.';

  @override
  String get haConnectButton => 'Connetti tramite Home Assistant';

  @override
  String get haConnectManualLink =>
      'Usi Home Assistant? Connettiti tramite esso';

  @override
  String get haConnectEmptyNote =>
      'Questo telefono non raggiunge il broker? Home Assistant può portare la connessione per te.';

  @override
  String get haHomeConnected => 'Connesso tramite Home Assistant';

  @override
  String get haHomeChange =>
      'Se l\'accesso smette di funzionare, su un nuovo telefono o dopo aver rimosso il token in Home Assistant, accedi di nuovo qui. Puoi anche terminarlo in Home Assistant, in Profilo › Sicurezza.';

  @override
  String get haHomeSignInAgain => 'Accedi di nuovo';

  @override
  String get haHomeRemote => 'Indirizzo remoto di Home Assistant (facoltativo)';

  @override
  String get setupAuthTitle => 'Questo broker richiede un login';

  @override
  String setupAuthBody(Object host) {
    return 'Inserisci nome utente e password MQTT per $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Nome utente o password rifiutati. Controllali e riprova.';

  @override
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT accede già a questo broker: la sua pagina web mostra il nome utente in Settings › MQTT. Usa quell\'utente e la sua password.';

  @override
  String get setupAuthWhich =>
      'Questo è il login MQTT, non la password della pagina web del tuo hub.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: usa un utente di Home Assistant. Di solito se ne crea uno solo per MQTT in Impostazioni › Persone › Utenti, e il componente aggiuntivo Mosquitto lo accetta.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi o Docker: utente e password dal file delle password di Mosquitto, gli stessi che trovi nel configuration.yaml di Zigbee2MQTT sotto mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: il login mostrato nella pagina web dell\'hub in Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'Verifica della connessione…';

  @override
  String get setupReviewTitle => 'I tuoi dispositivi';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trovati $count dispositivi.',
      one: 'Trovato 1 dispositivo.',
    );
    return '$_temp0 Scegli cosa mettere nella tua prima dashboard.';
  }

  @override
  String get setupReviewLastStep =>
      'Ultimo passo: spunta i dispositivi che vuoi, poi tocca Crea dashboard in basso.';

  @override
  String get setupLeaveTitle => 'Creare la dashboard?';

  @override
  String get setupLeaveBody =>
      'I tuoi dispositivi sono stati trovati. Crea la dashboard ora, oppure ricomincia la configurazione e perdi questo elenco.';

  @override
  String get setupStartOver => 'Ricomincia';

  @override
  String setupCreateWithCount(Object count) {
    return 'Crea la dashboard con $count';
  }

  @override
  String get setupReviewNoneSelected =>
      'Non è ancora selezionato nulla. Seleziona i dispositivi che vuoi nella dashboard, oppure creala vuota e aggiungi i riquadri più tardi.';

  @override
  String get setupCreateEmpty => 'Crea una dashboard vuota';

  @override
  String get setupGroupOther => 'Altri dispositivi';

  @override
  String get setupGroupUnsupported => 'Dispositivi non supportati';

  @override
  String get setupCreatingTitle => 'Creazione della dashboard…';

  @override
  String get setupReadyTitle => 'La tua dashboard è pronta';

  @override
  String setupReadyBody(Object count) {
    return '$count controlli creati.';
  }

  @override
  String get setupOpenDashboard => 'Apri la dashboard';

  @override
  String get setupErrUnreachableTitle =>
      'Impossibile raggiungere questo indirizzo';

  @override
  String get setupErrUnreachableBody =>
      'Questo dispositivo e l\'host di Zigbee2MQTT non riescono a comunicare. Controlla che siano sulla stessa rete locale.';

  @override
  String get setupErrUnreachableAction => 'Riprova';

  @override
  String get setupErrPortClosedTitle => 'Nessuna risposta su questa porta';

  @override
  String get setupErrPortClosedBody =>
      'L\'host è raggiungibile, ma nessun broker MQTT ha risposto. Controlla che il broker sia in esecuzione e che la porta sia giusta.';

  @override
  String get setupErrPortClosedAction => 'Riprova';

  @override
  String get setupErrAuthRequiredTitle => 'Login richiesto';

  @override
  String get setupErrAuthRequiredBody =>
      'Questo broker richiede nome utente e password.';

  @override
  String get setupErrAuthRequiredAction => 'Inserisci login';

  @override
  String get setupErrAuthRejectedTitle => 'Login rifiutato';

  @override
  String get setupErrAuthRejectedBody =>
      'Il broker ha rifiutato queste credenziali.';

  @override
  String get setupErrAuthRejectedAction => 'Riprova';

  @override
  String get setupErrNotZ2mTitle => 'Qui non c\'è Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'Qui risponde un broker MQTT, ma non sono stati trovati topic di Zigbee2MQTT. Potrebbe essere un altro broker.';

  @override
  String get setupErrNotZ2mAction => 'Scegline un altro';

  @override
  String get setupErrNoDevicesTitle => 'Nessun dispositivo ricevuto';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT è in esecuzione, ma durante la verifica non è stato pubblicato nessun dispositivo. Prima abbina i dispositivi in Zigbee2MQTT.';

  @override
  String get setupErrNoDevicesAction => 'Controlla di nuovo';

  @override
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT non ha inviato l\'elenco dei dispositivi';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT risponde, ma l\'elenco dei dispositivi non è arrivato. Succede di solito dopo il riavvio del broker MQTT: prima della 2.14.2, Zigbee2MQTT invia di nuovo l\'elenco solo quando si riavvia. Riavvia Zigbee2MQTT (o aggiornalo), poi riprova.';

  @override
  String get setupErrListMissingAction => 'Riprova';

  @override
  String get setupErrHaNoZ2mTitle =>
      'Nessun Zigbee2MQTT in questo Home Assistant';

  @override
  String get setupErrHaNoZ2mBody =>
      'Hai effettuato l\'accesso a Home Assistant, ma Zigbee2MQTT non invia nulla sul suo MQTT. Se i tuoi dispositivi Zigbee sono in ZHA (lo Zigbee integrato di Home Assistant), ZigDash non può vederli: funziona con Zigbee2MQTT. Se usi il componente aggiuntivo Zigbee2MQTT, aprilo in Home Assistant, controlla che sia avviato, poi riprova.';

  @override
  String get setupErrHaNoZ2mAction => 'Riprova';

  @override
  String get setupErrScanFailedTitle => 'Nessuna rete locale';

  @override
  String get setupErrScanFailedBody =>
      'Impossibile determinare la rete locale di questo dispositivo. Connettiti al Wi-Fi e riprova.';

  @override
  String get setupErrScanFailedAction => 'Riprova';

  @override
  String get setupNoWifiTitle => 'Il tuo telefono non è sul Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'Sta usando i dati mobili, quindi non vede i dispositivi di casa. Attiva il Wi-Fi e collegati alla rete di casa: la configurazione ripartirà da sola.';

  @override
  String get setupNoWifiOffline =>
      'Il tuo telefono non ha connessione di rete. Attiva il Wi-Fi e collegati alla rete di casa: la configurazione ripartirà da sola.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash non trova l\'indirizzo Wi-Fi del tuo telefono. Controlla che il Wi-Fi sia attivo e collegato alla rete di casa: la configurazione ripartirà da sola. Usi una VPN o sei fuori casa? Inserisci i dati a mano.';

  @override
  String get setupOpenWifiSettings => 'Apri impostazioni Wi-Fi';

  @override
  String get setupWaitingForWifi => 'In attesa del Wi-Fi…';

  @override
  String get setupErrSaveFailedTitle => 'Impossibile salvare';

  @override
  String get setupErrSaveFailedBody =>
      'Salvataggio della configurazione non riuscito. Niente è stato salvato a metà: puoi riprovare tranquillamente.';

  @override
  String get setupErrSaveFailedAction => 'Riprova';

  @override
  String get setupErrUnknownTitle => 'Qualcosa è andato storto';

  @override
  String get setupErrUnknownBody => 'Si è verificato un errore imprevisto.';

  @override
  String get setupErrUnknownAction => 'Riprova';

  @override
  String get setupErrLoginNoAnswerTitle => 'Il broker non ha risposto al login';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Il tuo broker è stato trovato, ma non ha risposto in tempo a nome utente e password. Il componente aggiuntivo Mosquitto di Home Assistant verifica i login con Home Assistant, e su un Raspberry Pi può volerci qualche secondo. Riprova, e controlla che questo utente esista in Home Assistant.';

  @override
  String get setupErrLoginNoAnswerAction => 'Riprova';

  @override
  String get setupNoZ2mTitle =>
      'Il tuo broker funziona, ma Zigbee2MQTT non pubblica qui';

  @override
  String setupNoZ2mBody(String base) {
    return 'Abbiamo ascoltato su $base/bridge e non abbiamo sentito nulla.';
  }

  @override
  String get setupBaseTopicQuestion => 'Usi un topic base diverso?';

  @override
  String get setupGuidesTitle => 'Configura Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'Intanto prova la demo';

  @override
  String get setupPlatformQuestion =>
      'Mentre cerchiamo: dove gira Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => 'Dove gira Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Scegli una connessione';

  @override
  String get setupScanDoneHint =>
      'Ha risposto più di un broker. Scegli quello usato da Zigbee2MQTT.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'Hub SMLIGHT';

  @override
  String get setupPlatformPi => 'Raspberry Pi o Docker';

  @override
  String get setupPlatformZha => 'ZHA, senza Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash mostra i dispositivi di Zigbee2MQTT, quindi non vede i dispositivi di ZHA, lo Zigbee integrato di Home Assistant. Puoi provare la casa demo per vedere come funziona ZigDash.';

  @override
  String get setupPlatformNotSure => 'Non so';

  @override
  String setupScanProgress(int checked, int total) {
    return 'Controllati $checked indirizzi su $total';
  }

  @override
  String get setupScanHintHa =>
      'Ricerca di Home Assistant e del suo broker MQTT…';

  @override
  String get setupScanHintSmlight => 'Ricerca del tuo hub SMLIGHT…';

  @override
  String get setupScanHintPi => 'Ricerca di un broker MQTT nella tua rete…';

  @override
  String setupHubSeenHa(String host) {
    return 'Home Assistant trovato su $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Zigbee2MQTT trovato su $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Hub SMLIGHT trovato su $host';
  }

  @override
  String get setupHubSeenHint => 'Sto ancora cercando il suo broker MQTT…';

  @override
  String get setupNoBrokerHaTitle =>
      'Home Assistant trovato, ma nessun broker MQTT';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant è su $host, ma nessuno risponde sulla porta MQTT 1883. In Home Assistant apri Impostazioni › Componenti aggiuntivi, installa e avvia il componente aggiuntivo Mosquitto broker, poi riprova.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Usi lo Zigbee integrato di Home Assistant (ZHA) invece di Zigbee2MQTT? ZigDash funziona solo con Zigbee2MQTT, quindi non vede i dispositivi ZHA. La demo ti mostra cosa otterresti.';

  @override
  String get setupVpnHint =>
      'C\'è una VPN attiva, e può nascondere la rete di casa alla scansione. Se sei a casa, disattiva la VPN e tocca Riprova. Oppure lasciala attiva e consenti l\'accesso alla rete locale (LAN) nelle impostazioni dell\'app VPN.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Zigbee2MQTT trovato, ma il suo broker non è raggiungibile';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT è su $host, ma il suo broker MQTT non accetta connessioni dal tuo telefono. Mosquitto 2 ascolta solo sull\'hub stesso finché la sua configurazione non contiene \'listener 1883\' e \'allow_anonymous true\' (o un login). Riavvialo, poi riprova.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Hub SMLIGHT trovato, ma MQTT è spento';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Il tuo hub è su $host, ma il suo broker MQTT non è raggiungibile. Nell\'interfaccia web dell\'hub apri Settings › MQTT, attiva Allow External e controlla che Zigbee2MQTT sia in esecuzione, poi riprova.';
  }

  @override
  String get setupZ2mAsking => 'Chiedo a Zigbee2MQTT dov\'è il suo broker…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Il tuo broker accetta connessioni solo dalla sua macchina';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT usa $server, e da lì nessuno risponde al tuo telefono. Mosquitto 2 fa così di default. Aggiungi queste due righe a mosquitto.conf, riavvia Mosquitto, poi riprova:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Preferisci un login all\'accesso libero? Usa un password_file al posto di allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT raggiunge il suo broker con un nome che il tuo telefono non può usare';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT usa $server. \"$name\" è un nome che conosce solo la macchina di Zigbee2MQTT, un servizio Docker o un nome host. Scrivi invece l\'indirizzo IP della macchina del broker con la porta $port. Se il broker gira in un container, la sua porta deve anche essere pubblicata sulla macchina (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'La pagina web di Zigbee2MQTT è protetta da un token, quindi l\'app non ha potuto leggere dove si trova il suo broker. Scrivi l\'indirizzo del broker da Zigbee2MQTT › Settings › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT usa il broker su $server, ma non ha risposto al tuo telefono. Controlla che il broker sia in esecuzione e che il telefono sia sulla stessa rete.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Connetti a $host';
  }

  @override
  String get setupNotFoundHa =>
      'Nessun Home Assistant trovato in questa rete. Controlla che il telefono sia sullo stesso Wi-Fi di Home Assistant (non una rete ospiti), poi riprova. Se conosci il suo indirizzo, inseriscilo qui sotto.';

  @override
  String get setupNotFoundSmlight =>
      'Nessun hub SMLIGHT trovato in questa rete. Controlla che l\'hub sia acceso e che il telefono sia sullo stesso Wi-Fi, poi riprova. Se conosci il suo indirizzo, inseriscilo qui sotto.';

  @override
  String get setupNotFoundPi =>
      'Nessun broker MQTT trovato in questa rete. Controlla che Mosquitto sia in esecuzione e in ascolto sulla rete (porta 1883), e che il telefono sia sullo stesso Wi-Fi, poi riprova.';

  @override
  String get setupAddressQuestionHa => 'Da dove apri Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'Qual è l\'indirizzo del tuo hub SMLIGHT?';

  @override
  String get setupAddressQuestionPi =>
      'Qual è l\'indirizzo della macchina su cui gira Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      'Qual è l\'indirizzo del tuo hub, o della macchina su cui gira Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'Un indirizzo come 192.168.1.20, un nome o il link dal browser';

  @override
  String get setupAddressCheck => 'Controlla questo indirizzo';

  @override
  String setupAddressNothing(String host) {
    return 'Nessuna risposta da $host. Controlla l\'indirizzo e che il telefono sia sul suo stesso Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return 'Impossibile risolvere $host. I nomi che finiscono in .local spesso non funzionano su Android; prova invece con l\'indirizzo IP. Home Assistant lo mostra in Impostazioni › Sistema › Rete.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host non si trova da questo telefono; spesso Android non riesce a risolvere i nomi .local. Tocca $button qui sopra e usa l\'indirizzo con cui apri Home Assistant nel browser, oppure scrivi qui il suo indirizzo IP. Home Assistant lo mostra in Impostazioni › Sistema › Rete.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host non è nella rete di casa. Usa l\'indirizzo che funziona sul tuo Wi-Fi, non un link remoto come Nabu Casa o DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Prima inserisci un indirizzo.';

  @override
  String get setupChoicesTitle => 'Quale di queste fa per te?';

  @override
  String get setupChoiceNoHub => 'Non ho ancora un hub';

  @override
  String get setupChoiceNoHubSub =>
      'Guarda i piccoli hub che fanno girare Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'Uso Home Assistant';

  @override
  String get setupChoiceHaSub => 'Cercalo su homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash si collega al broker MQTT di Home Assistant, il componente aggiuntivo Mosquitto broker in Impostazioni › Componenti aggiuntivi, e anche Zigbee2MQTT deve usarlo. Se homeassistant.local non viene trovato, inserisci qui sotto l\'indirizzo IP di Home Assistant. Lo trovi in Impostazioni › Sistema › Rete.';

  @override
  String get setupChoiceOther => 'Il mio hub è su un\'altra rete';

  @override
  String get setupChoiceOtherSub => 'Un Wi-Fi ospiti o un secondo router';

  @override
  String get setupChoiceOtherNote =>
      'Il telefono deve poter raggiungere l\'hub. Un Wi-Fi ospiti, o un secondo router con il suo Wi-Fi, li tiene separati. Collegati al Wi-Fi dell\'hub e tocca Riprova. Oppure inserisci qui sotto l\'indirizzo IP dell\'hub, o prova uno di questi nomi comuni:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Il tuo telefono è $ip, quindi l\'hub di solito inizia con $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Usi Home Assistant? L\'host è l\'indirizzo con cui apri Home Assistant, porta 1883.';

  @override
  String get demoBannerText => 'Sei in modalità demo';

  @override
  String get demoBannerAction => 'Collega la tua casa';

  @override
  String get deviceOn => 'Acceso';

  @override
  String get deviceOff => 'Spento';

  @override
  String get deviceOpen => 'Aperto';

  @override
  String get deviceClosed => 'Chiuso';

  @override
  String get deviceMotion => 'Movimento';

  @override
  String get deviceClear => 'Libero';

  @override
  String get deviceLeakDetected => 'Perdita rilevata';

  @override
  String get deviceSmokeDetected => 'Fumo rilevato';

  @override
  String get deviceGasDetected => 'Gas rilevato';

  @override
  String get deviceWaiting => 'In attesa del primo dato';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on accesi · $off spenti';
  }

  @override
  String get deviceBrightness => 'Luminosità';

  @override
  String get deviceWhite => 'Bianco';

  @override
  String get deviceColor => 'Colore';

  @override
  String get deviceHue => 'Tonalità';

  @override
  String get devicePosition => 'Posizione';

  @override
  String get deviceControls => 'Controlli';

  @override
  String deviceBattery(int percent) {
    return 'Batteria $percent%';
  }

  @override
  String get deviceToggle => 'Accendi o spegni';

  @override
  String get deviceMore => 'Altro';

  @override
  String get sectionLights => 'Luci';

  @override
  String get sectionSwitchesCovers => 'Interruttori e tapparelle';

  @override
  String get sectionSensors => 'Sensori';

  @override
  String get sectionOther => 'Altro';

  @override
  String get homeFirstName => 'Casa mia';

  @override
  String homeNumberedName(int number) {
    return 'Casa $number';
  }

  @override
  String get dashAddTile => 'Aggiungi riquadro';

  @override
  String get addTileSearch => 'Cerca dispositivi';

  @override
  String get addTileNotOnDashboard => 'Non in una dashboard';

  @override
  String get addTileAllDevices => 'Tutti i dispositivi';

  @override
  String get addTileReading => 'Lettura';

  @override
  String get addTileReadingSubtitle =>
      'Un valore da un dispositivo o da un topic';

  @override
  String get readingShowAs => 'Mostra come';

  @override
  String get readingStyleValue => 'Valore';

  @override
  String get readingStyleGauge => 'Indicatore';

  @override
  String get gaugeBands => 'Fasce di colore';

  @override
  String get gaugeBandsHelper =>
      'Fino a tre. La fascia in cui cade il valore colora l\'arco.';

  @override
  String get gaugeBandFrom => 'Da';

  @override
  String get gaugeBandTo => 'A';

  @override
  String get gaugeBandAdd => 'Aggiungi fascia';

  @override
  String get gaugeBandRemove => 'Rimuovi fascia';

  @override
  String get gaugeToneNormal => 'Normale';

  @override
  String get gaugeToneGood => 'Buono';

  @override
  String get gaugeToneAttention => 'Attenzione';

  @override
  String get addTileCustom => 'Riquadro MQTT personalizzato';

  @override
  String get addTileCustomSubtitle =>
      'Qualsiasi tipo di riquadro, configurato per topic';

  @override
  String get addTileNoDevices =>
      'Nessun dispositivo da mostrare. Connettiti al broker, o abbina un dispositivo in Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Aggiungi';

  @override
  String get addTileName => 'Nome';

  @override
  String addTileNameHint(String model) {
    return 'es. $model';
  }

  @override
  String get addTileSection => 'Sezione';

  @override
  String get addTileNoSection => 'Nessuna sezione';

  @override
  String get addTileSize => 'Dimensione';

  @override
  String get deviceClassColorLight => 'Luce colorata';

  @override
  String get deviceClassLight => 'Luce';

  @override
  String get deviceClassSwitch => 'Interruttore o presa';

  @override
  String get deviceClassCover => 'Tapparella';

  @override
  String get deviceClassLeak => 'Perdita o fumo';

  @override
  String get deviceClassContact => 'Contatto';

  @override
  String get deviceClassMotion => 'Movimento';

  @override
  String get deviceClassClimate => 'Sensore clima';

  @override
  String get deviceClassGeneric => 'Dispositivo';

  @override
  String get deviceNotResponding => 'Non risponde';

  @override
  String get homeAdd => 'Aggiungi una casa';

  @override
  String get homeManage => 'Gestisci case';

  @override
  String get homeSwitch => 'Cambia casa';

  @override
  String get navDevices => 'Dispositivi';

  @override
  String get navScenes => 'Scene';

  @override
  String get devicesNewDot => 'Nuovi dispositivi';

  @override
  String get editEditing => 'Modifica in corso';

  @override
  String get editDashboard => 'Dashboard';

  @override
  String get editDone => 'Fatto';

  @override
  String get editAddSection => 'Aggiungi sezione';

  @override
  String get editSectionName => 'Nome della sezione';

  @override
  String get editRenameSection => 'Rinomina sezione';

  @override
  String get editDeleteSection => 'Elimina sezione';

  @override
  String get editDeleteSectionBody => 'Cosa vuoi fare con i suoi riquadri?';

  @override
  String get editKeepTiles => 'Tieni i riquadri, rimuovi la sezione';

  @override
  String get editDeleteTiles => 'Elimina anche i riquadri';

  @override
  String get editMoveToSection => 'Sposta nella sezione';

  @override
  String get editEditTile => 'Modifica riquadro';

  @override
  String get editRemove => 'Rimuovi dalla dashboard';

  @override
  String get editRemoved => 'Riquadro rimosso';

  @override
  String get editUndo => 'Annulla';

  @override
  String get editReplaceWithDevice => 'Sostituisci con un riquadro dispositivo';

  @override
  String get editMoveEarlier => 'Sposta prima';

  @override
  String get editMoveLater => 'Sposta dopo';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivi non sono in nessuna dashboard',
      one: '1 dispositivo non è in nessuna dashboard',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Opzioni riquadro';

  @override
  String get editSave => 'Salva';

  @override
  String get editCancel => 'Annulla';

  @override
  String get ageJustNow => 'Proprio ora';

  @override
  String ageMinutes(int n) {
    return '$n min fa';
  }

  @override
  String ageHours(int n) {
    return '$n h fa';
  }

  @override
  String get statusCantReach => 'Impossibile raggiungere il broker';

  @override
  String get statusWhy => 'Perché?';

  @override
  String get statusWhyTitle => 'Il tuo broker non risponde';

  @override
  String get statusWhyBody =>
      'ZigDash continua a riprovare da solo. Finché non torna, i riquadri mostrano gli ultimi valori noti, attenuati, con la loro età. Controlla che il broker sia acceso e che questo telefono sia sulla stessa rete, oppure prova la connessione nelle sue impostazioni.';

  @override
  String get statusSettings => 'Impostazioni di connessione';

  @override
  String get deviceAddToDashboard => 'Aggiungi a una dashboard';

  @override
  String get deviceDismiss => 'Ignora';

  @override
  String get devicesFilterAll => 'Tutti';

  @override
  String devicesFilterAttention(int count) {
    return 'Da controllare · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Non in una dashboard · $count';
  }

  @override
  String get devicesNoMatch => 'Nessun dispositivo corrisponde';

  @override
  String get deviceBatteryLow => 'Batteria scarica';

  @override
  String get deviceLinkWeak => 'Debole';

  @override
  String get deviceUnsupported => 'Non supportato da Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'L\'abbinamento non è terminato';

  @override
  String get deviceNoReport => 'Ancora nessun dato';

  @override
  String get devicesAvailabilityOff =>
      'La disponibilità di Zigbee2MQTT è disattivata, quindi i dispositivi offline risultano come Non risponde.';

  @override
  String get devicesAvailabilityHow => 'Come attivarla';

  @override
  String get devicesDotBattery => 'Batteria scarica';

  @override
  String get deviceDetails => 'Dettagli dispositivo';

  @override
  String get deviceGone => 'Questo dispositivo non è più in Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Controllo';

  @override
  String get deviceReadingsTitle => 'Letture';

  @override
  String get deviceHealthTitle => 'Stato di salute';

  @override
  String get deviceOnDashboards => 'Nelle dashboard';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT non supporta ancora questo dispositivo, quindi non c\'è niente da controllare.';

  @override
  String get deviceAddReadingTile => 'Aggiungi come riquadro di lettura';

  @override
  String get deviceAddReadingTo => 'A quale dashboard aggiungerlo?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Aggiunto a $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Qualità del collegamento';

  @override
  String get deviceLinkGood => 'Buona';

  @override
  String get devicePowerSource => 'Alimentazione';

  @override
  String get devicePowerBattery => 'Batteria';

  @override
  String get devicePowerMains => 'Rete elettrica';

  @override
  String get deviceLastHeard => 'Ultimo contatto';

  @override
  String get deviceAvailability => 'Disponibilità';

  @override
  String get deviceAvailabilityOff => 'Disattivata in Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Informativa sulla privacy';

  @override
  String get settingsPrivacySubtitle =>
      'Nessuna telemetria. Tutto resta su questo telefono.';

  @override
  String get homeCurrent => 'Casa attuale';

  @override
  String get homeConnection => 'Connessione';

  @override
  String get homeSwitchTo => 'Passa a questa casa';

  @override
  String get homeDelete => 'Elimina casa';

  @override
  String get devicesSelect => 'Seleziona un dispositivo';

  @override
  String get scenesSelect => 'Seleziona una scena da modificare';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'Scegli un dispositivo';

  @override
  String get panelFormStateTopic => 'Topic di stato';

  @override
  String get panelFormCommandTopic => 'Topic di comando';

  @override
  String get panelFormCommandTopicDerived =>
      'Compilato dal topic di stato finché non lo cambi.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Collegato a $device';
  }

  @override
  String get panelFormOpenDevice => 'Apri dispositivo';

  @override
  String get panelFormUnlink => 'Scollega';

  @override
  String get panelFormValueChoices => 'Valori da questo dispositivo';

  @override
  String get panelFormAdvanced => 'Avanzate';

  @override
  String get panelFormAdvancedSubtitle => 'Prefisso alternativo, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Vuoto = il prefisso stesso (lo stato di un dispositivo Zigbee2MQTT).';

  @override
  String get dashWallDisplay => 'Schermo a parete';

  @override
  String get analyticsSetupCheckbox =>
      'Condividi dati di utilizzo anonimi per migliorare la configurazione';

  @override
  String get analyticsWhatsShared => 'Cosa viene condiviso';

  @override
  String get analyticsCardTitle => 'Ci aiuti a migliorare ZigDash?';

  @override
  String get analyticsCardBody =>
      'Condividi dati di utilizzo anonimi: quali passaggi della configurazione falliscono e quali funzioni vengono usate. Mai i tuoi dispositivi, topic o broker.';

  @override
  String get analyticsShare => 'Condividi';

  @override
  String get analyticsNoThanks => 'No, grazie';

  @override
  String get settingsAnalytics => 'Condividi dati di utilizzo anonimi';

  @override
  String get settingsAnalyticsSubtitle =>
      'Passaggi della configurazione e funzioni usate. Mai i tuoi dispositivi, topic o broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Dati di utilizzo anonimi. Disattivali con l\'interruttore qui sopra.';

  @override
  String get dashDefaultName => 'Casa';

  @override
  String get dashExportSaveFile => 'Salva file';

  @override
  String get dashExportSaved => 'Backup salvato';

  @override
  String get dashImportChooseFile => 'Scegli file';

  @override
  String get dashImportFileUnreadable => 'Impossibile leggere quel file';

  @override
  String get getHelpTitle => 'Ottieni aiuto';

  @override
  String get getHelpTryFirst => 'Prova prima questi';

  @override
  String get getHelpPromise =>
      'Ancora bloccato? Di solito rispondo entro 3 giorni, in inglese o ebraico. Non ti chiederò mai le tue password.';

  @override
  String get getHelpIncluded => 'Cosa è incluso';

  @override
  String get getHelpContact => 'Contatta l\'assistenza';

  @override
  String get getHelpCopy => 'Copia i dettagli';

  @override
  String get getHelpCopied => 'Dettagli copiati';

  @override
  String get getHelpLink => 'Ancora bloccato? Ottieni aiuto';

  @override
  String get getHelpEmailSubject => 'ZigDash: aiuto per farlo funzionare';

  @override
  String get getHelpEmailPrompt =>
      'Cosa stavi cercando di fare, e cos\'è successo?';

  @override
  String get settingsHelpSupport => 'Aiuto e assistenza';

  @override
  String get settingsGetHelp => 'Ottieni aiuto';

  @override
  String get settingsGetHelpSubtitle =>
      'Non riesci a farlo funzionare? Prima i consigli, poi il contatto';

  @override
  String get settingsCommunity => 'Unisciti alla community di ZigDash';

  @override
  String get settingsCommunitySubtitle =>
      'Gruppo Telegram: domande, idee e novità in arrivo';

  @override
  String get getHelpCommunity => 'Chiedi nel gruppo Telegram';

  @override
  String get demoBannerHelp => 'Ottieni aiuto';

  @override
  String get tipSameWifiTitle => 'Stesso Wi-Fi del tuo hub';

  @override
  String get tipSameWifiBody =>
      'Il telefono deve essere sulla stessa rete dell\'hub, non su una rete ospiti. Disattiva i dati mobili durante la configurazione.';

  @override
  String get tipBrokerRunningTitle => 'Il broker è in esecuzione';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: il componente aggiuntivo Mosquitto è avviato. Raspberry Pi: Mosquitto è in esecuzione. SMLIGHT: Settings › MQTT è attivo.';

  @override
  String get tipBrokerAcceptsTitle => 'Il broker accetta il tuo telefono';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: attiva Allow External. Mosquitto 2 accetta connessioni solo dall\'hub stesso finché non lo imposti per ascoltare sulla rete (porta 1883).';

  @override
  String get tipMeshTitle => 'Wi-Fi mesh o due router?';

  @override
  String get tipMeshBody =>
      'Se l\'hub è collegato a un secondo router, il telefono potrebbe non vederlo. Collega l\'hub al router principale, oppure connettiti con il suo indirizzo.';

  @override
  String get tipByAddressTitle => 'Connettiti con l\'indirizzo';

  @override
  String get tipByAddressBody =>
      'Trova l\'indirizzo dell\'hub nell\'app del router, poi tocca Inserisci i dati a mano.';

  @override
  String get tipSameNetworkTitle => 'Stessa rete';

  @override
  String get tipSameNetworkBody =>
      'Telefono e hub devono essere sullo stesso Wi-Fi. Disattiva i dati mobili.';

  @override
  String get tipAddressChangedTitle => 'L\'indirizzo è cambiato';

  @override
  String get tipAddressChangedBody =>
      'Gli hub possono ricevere un nuovo indirizzo dopo un riavvio. Controllalo nell\'app del router, e riservalo lì perché resti sempre lo stesso.';

  @override
  String get tipRightPortTitle => 'La porta giusta';

  @override
  String get tipRightPortBody =>
      'MQTT di solito è 1883 (8883 con TLS). 8080 o 80 è la pagina web dell\'hub, non MQTT.';

  @override
  String get tipStartBrokerTitle => 'Il broker è in esecuzione';

  @override
  String get tipStartBrokerBody =>
      'Avvia Mosquitto o il componente aggiuntivo del broker, poi riprova.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 accetta connessioni solo dall\'hub stesso finché non lo imposti per ascoltare sulla rete (porta 1883).';

  @override
  String get tipMqttLoginTitle => 'Il login MQTT, non quello web';

  @override
  String get tipMqttLoginBody =>
      'La password della pagina web dell\'hub di solito non è quella MQTT. Home Assistant: usa un utente di Home Assistant, o il login impostato nel componente aggiuntivo Mosquitto.';

  @override
  String get tipSpacesTitle => 'Controlla gli spazi';

  @override
  String get tipSpacesBody =>
      'Copiando una password può aggiungersi uno spazio alla fine.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT usa questo broker';

  @override
  String get tipZ2mBrokerBody =>
      'Nelle impostazioni di Zigbee2MQTT, controlla che il suo server MQTT sia proprio questo broker.';

  @override
  String get tipBaseTopicTitle => 'Topic base';

  @override
  String get tipBaseTopicBody =>
      'Se hai cambiato il topic base da \"zigbee2mqtt\", inseriscilo nella configurazione manuale.';

  @override
  String get tipPairFirstTitle => 'Prima abbina i dispositivi';

  @override
  String get tipPairFirstBody =>
      'Apri la pagina web di Zigbee2MQTT e abbina almeno un dispositivo, poi controlla di nuovo.';

  @override
  String get tipRestartZ2mTitle => 'Riavvia Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'Se i dispositivi sono abbinati ma non ne arriva nessuno, riavvia Zigbee2MQTT così pubblica l\'elenco dei dispositivi.';

  @override
  String get tipNumberAddressTitle => 'Usa l\'indirizzo numerico';

  @override
  String get tipNumberAddressBody =>
      'I nomi che finiscono in .local non funzionano su tutti i telefoni Android. Prova l\'indirizzo numerico dell\'hub, come 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Porta e protocollo';

  @override
  String get tipPortProtocolBody =>
      'Di solito si usa TCP sulla 1883. Scegli TLS o WebSocket solo se il tuo broker è configurato così.';

  @override
  String get tipManualLoginTitle => 'Login';

  @override
  String get tipManualLoginBody =>
      'Lascia vuoti nome utente e password se il tuo broker non li usa. Altrimenti usa il login MQTT, non quello web dell\'hub.';

  @override
  String get tipHubOnTitle => 'L\'hub è acceso?';

  @override
  String get tipHubOnBody =>
      'Un blackout o un aggiornamento potrebbe averlo riavviato. Dagli un minuto dopo che è tornato.';

  @override
  String get tipAwayTitle => 'Sei a casa?';

  @override
  String get tipAwayBody =>
      'Fuori casa, l\'app ha bisogno di un indirizzo remoto (per esempio Tailscale). Impostalo nelle impostazioni di connessione della casa.';

  @override
  String get tipTailscaleIpTitle => 'Usa l\'IP Tailscale, non il nome';

  @override
  String get tipTailscaleIpBody =>
      'I nomi che finiscono in .ts.net spesso non vengono risolti dentro le app. Apri l\'app Tailscale sul telefono e controlla che sia connessa, poi usa l\'indirizzo 100.x.y.z dell\'hub come Host remoto.';

  @override
  String get tipHomeAddressChangedTitle => 'L\'indirizzo è cambiato?';

  @override
  String get tipHomeAddressChangedBody =>
      'Dopo un riavvio del router l\'hub può ricevere un nuovo indirizzo. Riserva il suo indirizzo nell\'app del router, poi aggiorna la casa.';

  @override
  String get tipRestartZ2mButtonTitle => 'Riavvia Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'Se il broker si è riavviato, l\'elenco dispositivi di Zigbee2MQTT sparisce finché Zigbee2MQTT non si riavvia. Usa il pulsante Riavvia Zigbee2MQTT nella scheda Dispositivi.';

  @override
  String get tipZ2mRunningTitle => 'Zigbee2MQTT è in esecuzione?';

  @override
  String get tipZ2mRunningBody =>
      'Apri la sua pagina web. Se non si carica, riavvialo sull\'hub.';

  @override
  String get tipCantConnectTitle => 'Non riesco a collegarmi al mio hub';

  @override
  String get tipCantConnectBody =>
      'Stesso Wi-Fi, broker in esecuzione, Allow External o Mosquitto in ascolto sulla rete, poi connettiti con l\'indirizzo.';

  @override
  String get tipDeviceWrongTitle =>
      'Un dispositivo si vede male o non risponde';

  @override
  String get tipDeviceWrongBody =>
      'Controllalo prima nella pagina web di Zigbee2MQTT. Se lì funziona, usa Segnala un problema.';

  @override
  String get tipHowDoITitle => 'Come faccio a…';

  @override
  String get tipHowDoIBody =>
      'Scene, Schermo a parete, programmi e backup sono in Aiuto e guida.';

  @override
  String get tipRenameHomeTitle => 'Rinomina una casa';

  @override
  String get tipRenameHomeBody =>
      'Una casa che ha per nome il suo indirizzo? Impostazioni › Case, tocca la casa, poi tocca Nome.';

  @override
  String get tipWhatYouNeedTitle => 'Cosa ti serve';

  @override
  String get tipWhatYouNeedBody =>
      'Un piccolo hub con Zigbee2MQTT e un broker MQTT (Mosquitto): un hub SMLIGHT, un Raspberry Pi o qualsiasi macchina Linux. Funziona anche Home Assistant, ma non è necessario.';

  @override
  String get tipSetupAtHomeTitle => 'Sullo stesso Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Fai la configurazione a casa, con il telefono sullo stesso Wi-Fi dell\'hub.';

  @override
  String get tipFindSetupTitle => 'Poi';

  @override
  String get tipFindSetupBody =>
      'Esci dalla demo e tocca Trova la mia configurazione. ZigDash cerca il tuo hub da solo.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Nessuna app email trovata. Copia i dettagli e scrivi a $email.';
  }

  @override
  String get shortcutWorking => 'in corso…';

  @override
  String get shortcutCantReach => 'Casa non raggiungibile';

  @override
  String get shortcutNotConfirmed => 'Non confermato';

  @override
  String get shortcutRemoved => 'Rimosso';

  @override
  String get shortcutSceneSent => 'Inviata';

  @override
  String get shortcutSceneConfirmed => 'Confermata';

  @override
  String get shortcutChooseDevice => 'Scegli un dispositivo';

  @override
  String get shortcutChooseScene => 'Scegli una scena';

  @override
  String get shortcutOpenAppFirstScene =>
      'Apri ZigDash e crea prima una scena.';

  @override
  String get shortcutChooseGroup => 'Scegli un gruppo';

  @override
  String get shortcutPickDevices => 'Scegli dispositivi…';

  @override
  String get shortcutGroupName => 'Nome del gruppo';

  @override
  String get shortcutGroupLimit => 'Fino a 5 dispositivi e 3 scene';

  @override
  String get shortcutAddTile => 'Aggiungi a Impostazioni rapide';

  @override
  String get shortcutAddShortcut => 'Aggiungi scorciatoia';

  @override
  String get shortcutAddToHome => 'Aggiungi alla schermata Home';

  @override
  String get shortcutWidgetHowToTitle => 'Aggiungi il widget';

  @override
  String get shortcutWidgetHowTo =>
      'Tieni premuto un punto vuoto della schermata Home, tocca Widget, trova ZigDash e trascina il widget che vuoi.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name è nel riquadro ZigDash $slot delle Impostazioni rapide';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name è già nel riquadro ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Aggiungi il riquadro';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Apri le Impostazioni rapide (scorri giù due volte), tocca la matita per modificare e trascina “ZigDash $slot” tra i tuoi riquadri.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Scegli un dispositivo per ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Ancora nessun dispositivo da comandare. Prima metti una luce, una presa o una tapparella su una dashboard.';

  @override
  String get shortcutSlotsFull =>
      'Tutti e 4 i riquadri ZigDash sono in uso. Quale deve mostrare invece questo dispositivo?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Non usato';

  @override
  String get deviceRename => 'Rinomina';

  @override
  String get deviceRenameTitle => 'Rinomina dispositivo';

  @override
  String get deviceRenameHint =>
      'Un nome per la stanza o il dispositivo, come Camera da letto';

  @override
  String deviceRenamed(Object name) {
    return 'Rinominato in $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Impossibile rinominare: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT non ha risposto';

  @override
  String get shortcutOpenAppFirst =>
      'Apri ZigDash e metti prima un dispositivo su una dashboard.';

  @override
  String get pollTitle => 'Cosa dovrebbe fare ZigDash adesso?';

  @override
  String get pollBody =>
      'Scegli quello che useresti di più. La tua risposta viene inviata con i tuoi dati di utilizzo anonimi.';

  @override
  String get pollNotifications => 'Notifiche';

  @override
  String get pollHistory => 'Grafici della cronologia';

  @override
  String get pollKiosk => 'Modalità kiosk per un tablet a parete';

  @override
  String get pollGroups => 'Gruppi Zigbee';

  @override
  String get pollNotNow => 'Non ora';

  @override
  String get pollThanks =>
      'Grazie! Questo aiuta a decidere cosa arriverà dopo.';

  @override
  String get whyTitle => 'Perché hai provato ZigDash?';

  @override
  String get whyBody =>
      'Un tocco aiuta a decidere cosa costruire. La tua risposta viene inviata con i tuoi dati di utilizzo anonimi.';

  @override
  String get whyFaster => 'Più veloce della mia altra app';

  @override
  String get whyFamily => 'Semplice per la famiglia';

  @override
  String get whyWallTablet => 'Un tablet a parete';

  @override
  String get whyWithoutHa => 'Funziona senza Home Assistant';

  @override
  String get whyOther => 'Altro';

  @override
  String get whyThanks => 'Grazie per avercelo detto!';

  @override
  String get pollNoAnalytics =>
      'I dati di utilizzo sono disattivati, quindi da qui non viene inviato nulla. Faccelo sapere invece con Proponi una funzione.';

  @override
  String alertLeak(Object name) {
    return '💧 Perdita — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name è di nuovo asciutto';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Fumo — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Niente più fumo in $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name aperto';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Batteria scarica — $name, $value%';
  }

  @override
  String get alertTest => 'Avviso di prova ZigDash';

  @override
  String get alertsChannel => 'Avvisi';

  @override
  String get alertsChannelDescription => 'Perdite e fumo';

  @override
  String get noticesChannel => 'Notifiche';

  @override
  String get noticesChannelDescription => 'Porte, finestre e batterie';

  @override
  String get alertsTitle => 'Avvisi';

  @override
  String get alertsStatusOn => 'Gli avvisi sono attivi';

  @override
  String get alertsStatusPaused =>
      'Avvisi in pausa: ZigDash Engine sull\'hub non dà notizie';

  @override
  String get alertsStatusNotSetUp => 'Non configurati';

  @override
  String get alertsStatusPhoneOff => 'Questo telefono non riceve notifiche';

  @override
  String get alertsIntro =>
      'Ricevi una notifica su questo telefono per perdite, fumo, porte aperte o batteria scarica, anche con ZigDash chiuso. ZigDash Engine sull\'hub osserva i dispositivi; ZigDash lo configura.';

  @override
  String get alertsSetUpHub => 'Configura gli avvisi sull\'hub';

  @override
  String get alertsHubInstalled => 'Gli avvisi sono configurati sull\'hub';

  @override
  String get alertsHubUpdated => 'Il flow degli avvisi sull\'hub è aggiornato';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED chiede un login, quindi importa il flow a mano:';

  @override
  String get alertsHubManualSteps =>
      'Apri Node-RED sull\'hub, scegli Import, incolla il flow copiato, scegli il tuo broker nel nodo broker e fai Deploy.';

  @override
  String get alertsCopyFlow => 'Copia il flow';

  @override
  String get alertsFlowCopied => 'Flow copiato';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Gli avvisi richiedono Node-RED sull\'hub, e nessuno risponde sulla porta 1880 di $host. Su uno SMLIGHT SMHUB, installalo da Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT non ha accettato ZigDash Engine';

  @override
  String get alertsRecent => 'Avvisi recenti';

  @override
  String get alertsRecentNone => 'Ancora niente';

  @override
  String get alertsYourAlerts => 'I tuoi avvisi';

  @override
  String get alertsAdd => 'Aggiungi avviso';

  @override
  String get alertsNotificationsOnThisPhone => 'Notifiche su questo telefono';

  @override
  String get alertsNoGoogle =>
      'Questo telefono non ha i servizi Google, quindi ZigDash non può ricevere notifiche push qui.';

  @override
  String get alertsSendTest => 'Invia notifica di prova';

  @override
  String get alertsTestSent => 'Prova inviata. Dovrebbe arrivare a momenti.';

  @override
  String alertsTestFailed(Object status) {
    return 'L\'hub non è riuscito a inviarla ($status)';
  }

  @override
  String get alertsTestTimedOut =>
      'Nessuna risposta dall\'hub. Il flow degli avvisi è in esecuzione?';

  @override
  String get alertsNotConnected => 'Non connesso all\'hub';

  @override
  String get alertsTurnOff => 'Disattiva gli avvisi';

  @override
  String get alertsTurnOffBody =>
      'Gli avvisi si fermano per tutti i telefoni di questa casa.';

  @override
  String get alertKindLeak => 'Perdita';

  @override
  String get alertKindSmoke => 'Fumo';

  @override
  String get alertKindOpened => 'Porta o finestra aperta';

  @override
  String get alertKindBattery => 'Batteria scarica';

  @override
  String get alertsEditTitle => 'Avviso';

  @override
  String get alertsKind => 'Cosa';

  @override
  String get alertsDevices => 'Dispositivi';

  @override
  String get alertsNoDevicesForKind =>
      'Nessun dispositivo di questa casa lo segnala.';

  @override
  String get alertsHours => 'Solo tra';

  @override
  String get alertsHoursAny => 'Sempre';

  @override
  String get alertsHoursFrom => 'Dalle';

  @override
  String get alertsHoursTo => 'Alle';

  @override
  String get alertsThreshold => 'Batteria sotto';

  @override
  String get alertsDelete => 'Elimina avviso';

  @override
  String get alertsNotifyMe => 'Avvisami…';

  @override
  String get alertsWhatLeaves =>
      'Gli avvisi verso ZigDash sono cifrati end-to-end: il servizio push di Google li trasporta ma non può leggerli. Nient\'altro esce dal tuo hub.';

  @override
  String get alertsRestricted =>
      'Android potrebbe fermare ZigDash in background, quindi le notifiche potrebbero arrivare in ritardo o andare perse. Consentigli di funzionare in background nelle impostazioni di Android (su Samsung: Batteria › App mai in sospensione).';

  @override
  String get alertsOpenSettings => 'Apri le impostazioni di Android';

  @override
  String get alertsOff => 'Disattivati';

  @override
  String get alertsSuggested => 'Avvisi suggeriti';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivi',
      one: '1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Attiva';

  @override
  String get alertsShare => 'Condividi avvisi';

  @override
  String get alertsShareBody =>
      'Chiunque abbia questo link riceve gli avvisi di questa casa nell\'app ntfy, senza bisogno di ZigDash. Il testo degli avvisi passa da ntfy.sh senza cifratura.';

  @override
  String get alertsShareLink => 'Link';

  @override
  String get alertsShareNewLink => 'Nuovo link';

  @override
  String get alertsShareCopied => 'Link copiato';

  @override
  String get alertsShareOff => 'Smetti di condividere';

  @override
  String get alertsGetWithNtfy => 'Ricevi le notifiche con ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Gli avvisi di fumo e perdite si ripetono finché non li confermi. Serve un account Pushover (4,99 \$ una tantum dopo la prova); le sue chiavi restano sul tuo broker.';

  @override
  String get alertsPushoverUser => 'Chiave utente';

  @override
  String get alertsPushoverToken => 'Token dell\'app';

  @override
  String get alertsHideNames => 'Nascondi i nomi dei dispositivi';

  @override
  String get alertsNtfyServer => 'Server ntfy';

  @override
  String get wallSheetTitle => 'Schermo a parete';

  @override
  String get wallSheetSubtitle => 'Per un tablet a parete.';

  @override
  String get wallKeepOn => 'Tieni lo schermo acceso e nascondi le barre';

  @override
  String get wallKeepOnSubtitle =>
      'Ricompaiono con un tocco e si nascondono di nuovo dopo 10 secondi.';

  @override
  String get wallFullscreen => 'Schermo intero';

  @override
  String get wallFullscreenSubtitle =>
      'Nasconde anche la barra di stato e quella di navigazione di Android.';

  @override
  String get wallDimAfter => 'Attenua dopo';

  @override
  String get wallDimOff => 'Mai';

  @override
  String get wallIdleTitle => 'Quando nessuno lo tocca';

  @override
  String get wallIdleAfter => 'Dopo';

  @override
  String get wallIdleNever => 'Mai';

  @override
  String get wallIdleShow => 'Mostra';

  @override
  String get wallIdleShowDim => 'Attenuato';

  @override
  String get wallIdleShowClock => 'Orologio';

  @override
  String get wallIdleShowBlack => 'Nero';

  @override
  String get wallIdleShowReadings => 'Letture';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Questa dashboard non ha ancora letture. Prima aggiungi un riquadro di lettura o di un sensore.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Letture sull\'orologio (fino a $count)';
  }

  @override
  String get wallProNote =>
      'Letture sull\'orologio, risveglio con il movimento, programma notturno e allarmi fanno parte di ZigDash Pro, un acquisto una tantum.';

  @override
  String get wallAlarmLeak => 'Perdita d\'acqua';

  @override
  String get wallAlarmSmoke => 'Fumo';

  @override
  String get wallAlarmGas => 'Gas';

  @override
  String get wallAlarmCo => 'Monossido di carbonio';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Risveglio con il movimento';

  @override
  String get wallMotionSubtitle =>
      'Un sensore che vede qualcuno riattiva lo schermo.';

  @override
  String get wallMotionNone =>
      'Nessun sensore di movimento, presenza o porta in questa casa.';

  @override
  String get wallAlarmsTitle => 'Gli allarmi occupano lo schermo';

  @override
  String get wallAlarmsSubtitle =>
      'Perdita, fumo, gas o monossido di carbonio riempiono lo schermo finché qualcuno non tocca OK. Solo mentre ZigDash è aperto su questo tablet; gli Avvisi raggiungono i telefoni ovunque.';

  @override
  String get wallAlarmSound => 'Riproduci un suono';

  @override
  String get wallNightTitle => 'Notte';

  @override
  String get wallNightSubtitle =>
      'Nero in queste ore. Il movimento lo riattiva solo attenuato; gli allarmi sempre a piena luminosità.';

  @override
  String get wallNightFrom => 'Dalle';

  @override
  String get wallNightTo => 'alle';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Blocco kiosk';

  @override
  String get kioskLockSubtitle =>
      'Restano raggiungibili solo le dashboard di questa casa e i loro controlli. Tieni premuto il titolo per uscire.';

  @override
  String get kioskPin => 'PIN';

  @override
  String get kioskPinSet => 'Imposta';

  @override
  String get kioskPinNotSet => 'Non impostato';

  @override
  String get kioskPinChange => 'Cambia';

  @override
  String get kioskPinRemove => 'Rimuovi';

  @override
  String get kioskPinSetTitle => 'Imposta un PIN';

  @override
  String get kioskPinEnterTitle => 'Inserisci il PIN';

  @override
  String get kioskPinHint => '4 cifre';

  @override
  String get kioskPinConfirmHint => 'Di nuovo';

  @override
  String get kioskPinMismatch => 'I due PIN sono diversi.';

  @override
  String get kioskPinWrong => 'PIN errato.';

  @override
  String get kioskPinForgot => 'PIN dimenticato?';

  @override
  String get kioskPinForgotBody =>
      'Un PIN dimenticato si può reimpostare solo cancellando i dati di ZigDash nelle impostazioni di Android, il che rimuove questa casa se non hai un backup. Esportane uno prima di impostare un PIN.';

  @override
  String get kioskExportBackup => 'Esporta backup';

  @override
  String get kioskOsPin => 'Blocca anche ZigDash su Android';

  @override
  String get kioskOsPinSubtitle =>
      'Android blocca Home e le app recenti finché ZigDash non viene sbloccato. Un tablet senza blocco schermo si sblocca con un gesto, quindi questo non è il blocco vero e proprio.';

  @override
  String get kioskOn => 'Kiosk attivo. Tieni premuto il titolo per uscire.';

  @override
  String get kioskLeaveTitle => 'Uscire dal kiosk?';

  @override
  String get kioskLeave => 'Esci';

  @override
  String get kioskStay => 'Resta';

  @override
  String get a11yKioskLeave => 'Tieni premuto per uscire dal kiosk';

  @override
  String get historyTitle => 'Cronologia';

  @override
  String get historyRangeDay => '24 ore';

  @override
  String get historyRangeWeek => '7 giorni';

  @override
  String get historyRangeMonth => '30 giorni';

  @override
  String get historySetupTitle => 'Registra la cronologia sul tuo hub';

  @override
  String get historySetupBody =>
      'ZigDash non ha un server, quindi ZigDash Engine sull\'hub registra i valori delle tue dashboard ogni 15 minuti. Conserva 30 giorni, sul tuo broker.';

  @override
  String get historySetupAction => 'Configura sull\'hub';

  @override
  String get historyInstalled =>
      'Registrazione in corso. I primi valori compaiono entro 15 minuti.';

  @override
  String historyNoNodeRed(String host) {
    return 'La cronologia richiede Node-RED sull\'hub, e nessuno risponde sulla porta 1880 di $host. Su uno SMLIGHT SMHUB, installalo da Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Registrazione dal $date';
  }

  @override
  String get historyEmpty =>
      'Ancora nessun valore. Il registratore salva ogni 15 minuti.';

  @override
  String get historyRecorderOffline =>
      'Il registratore sull\'hub non risponde, quindi potrebbero mancare i valori recenti.';

  @override
  String get historyLocked =>
      'La cronologia più lunga fa parte di ZigDash Pro, un acquisto una tantum.';

  @override
  String get historyUnlock => 'Sblocca';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Automazioni illimitate, cronologia più lunga ed extra per lo schermo a parete. Sostiene il progetto open source.';

  @override
  String get proUnlocked => 'Sbloccato. Grazie per sostenere ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash è gratuita e open source, creata da una sola persona nel tempo libero. Pro è un acquisto una tantum che la fa andare avanti.';

  @override
  String get proWhatYouGet => 'Cosa ottieni';

  @override
  String get proGetHistory => 'Cronologia di 7 e 30 giorni, non solo di oggi';

  @override
  String get proGetWall =>
      'Schermo a parete: letture sull\'orologio, risveglio al movimento, orario notturno e allarmi';

  @override
  String get proGetFuture =>
      'Ogni funzione Pro che arriverà in futuro, senza costi aggiuntivi';

  @override
  String get proFreeTitle => 'Gratis per sempre';

  @override
  String get proFreeBody =>
      'Configurazione, dashboard, il controllo di ogni dispositivo, i widget, i riquadri delle impostazioni rapide, gli avvisi, tre automazioni per casa e lo schermo a parete restano gratuiti. Niente di ciò che usi oggi verrà bloccato.';

  @override
  String get proBuy => 'Ottieni Pro';

  @override
  String proBuyPrice(String price) {
    return 'Ottieni Pro · $price';
  }

  @override
  String get proOnce =>
      'Un solo pagamento, nessun abbonamento. L\'hai acquistato su un altro telefono con lo stesso account Google? Si sblocca da solo.';

  @override
  String get historyNotRecorded =>
      'Vengono registrati solo i numeri mostrati su una dashboard. Aggiungi questo come riquadro per iniziare la sua cronologia.';

  @override
  String get historyRecordHere => 'Registra su questo dispositivo';

  @override
  String get historyRecordHereHint =>
      'Non puoi usare ZigDash Engine sull\'hub? ZigDash può registrare su un telefono o tablet che resta aperto, come un tablet a parete. Tutti i telefoni di questa casa vedono la cronologia.';

  @override
  String get historyRecordingHere =>
      'Questo dispositivo registra la cronologia mentre ZigDash è aperto. I primi valori compaiono entro 15 minuti.';

  @override
  String get wallRecordHistory =>
      'Registra la cronologia su questo dispositivo';

  @override
  String get wallRecordHistorySubtitle =>
      'Ogni 15 minuti mentre ZigDash è aperto, per tutti i telefoni di questa casa. Non serve se registra ZigDash Engine sull\'hub.';

  @override
  String historyNeedsPassword(String host) {
    return 'Ancora un passaggio: il tuo broker chiede un login. Apri Node-RED su $host:1880, fai doppio clic su \"ZigDash history broker\", scrivi la password MQTT nella scheda Security, poi fai Deploy. ZigDash non invia mai la tua password all\'hub.';
  }

  @override
  String get historyNotConnected =>
      'La registrazione non dà notizie. Apri Automazioni per controllare ZigDash Engine sull\'hub.';

  @override
  String get historyPersistence =>
      'La cronologia vive sul tuo broker. Se gestisci Mosquitto da solo, controlla che la sua configurazione contenga \"persistence true\", altrimenti la cronologia si perde quando il broker si riavvia.';

  @override
  String get haImportTitle => 'Importa da Home Assistant';

  @override
  String get haImportSettingsSubtitle =>
      'Nomi e stanze che hai impostato in Home Assistant';

  @override
  String get haImportIntro =>
      'Porta qui i nomi e le stanze che hai impostato in Home Assistant. ZigDash li legge una volta e non conserva nient\'altro di Home Assistant.';

  @override
  String get haImportAddress => 'Indirizzo di Home Assistant';

  @override
  String get haImportAddressHelp =>
      'L\'indirizzo con cui apri Home Assistant, come 192.168.1.20:8123';

  @override
  String get haImportToken => 'Token di accesso a lunga durata';

  @override
  String get haImportTokenHelp =>
      'In Home Assistant apri il tuo profilo, poi Sicurezza › Token di accesso a lunga durata › Crea token. Copialo e incollalo qui. ZigDash lo usa una volta e non lo conserva; dopo puoi eliminarlo in Home Assistant.';

  @override
  String get haImportRead => 'Leggi da Home Assistant';

  @override
  String get haImportReading => 'Lettura di Home Assistant…';

  @override
  String get haImportApplying => 'Importazione…';

  @override
  String get haImportNoAddress =>
      'Scrivi l\'indirizzo con cui apri Home Assistant.';

  @override
  String get haImportNoToken => 'Incolla un token di accesso a lunga durata.';

  @override
  String get haImportUnreachable =>
      'Nessuna risposta a quell\'indirizzo. Controllalo, e controlla che il telefono sia sulla rete di casa.';

  @override
  String get haImportNotHa =>
      'A quell\'indirizzo ha risposto qualcosa, ma non è Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant ha rifiutato quel token. Creane uno nuovo e incollalo di nuovo.';

  @override
  String get haImportCertificate =>
      'Il tuo telefono non si fida del certificato di questo Home Assistant. Prova il suo indirizzo http:// sulla rete di casa.';

  @override
  String get haImportFailed =>
      'Home Assistant ha risposto, ma la lettura non è riuscita. Riprova.';

  @override
  String get haImportNoDevices =>
      'ZigDash al momento non vede i dispositivi di questa casa. Connettiti alla casa, poi riprova.';

  @override
  String get haImportAutomations =>
      'Le tue automazioni restano in Home Assistant e continuano a funzionare.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivi trovati in Home Assistant',
      one: '1 dispositivo trovato in Home Assistant',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'I riquadri che hanno ancora il nome del dispositivo prendono il nome da Home Assistant. Le dashboard che hai creato restano come sono.';

  @override
  String get haImportMakeDashboards =>
      'Aggiungi anche dashboard dai tuoi piani e stanze';

  @override
  String get haImportOtherRooms => 'Altre stanze';

  @override
  String get haImportNoRoom => 'Nessuna stanza';

  @override
  String get haImportApply => 'Importa';

  @override
  String get haImportBack => 'Indietro';

  @override
  String get haImportZhaOnly =>
      'Questi dispositivi funzionano con ZHA, lo Zigbee integrato di Home Assistant, non con Zigbee2MQTT, quindi ZigDash non può mostrarli.';

  @override
  String get haImportNothing =>
      'Nessuno dei dispositivi Zigbee2MQTT di questa casa è in Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Fatto. Riquadri rinominati: $renamed. Dashboard aggiunte: $dashboards.';
  }

  @override
  String get haImportOpen => 'Apri le dashboard';

  @override
  String get haImportOfferTitle =>
      'Vuoi portare qui nomi e stanze da Home Assistant?';

  @override
  String get haImportOfferBody =>
      'Home Assistant è nella tua rete. ZigDash può dare un nome ai tuoi riquadri e aggiungere una dashboard per ogni piano e stanza, come li hai impostati lì.';

  @override
  String get haImportOfferLater => 'Non ora';

  @override
  String get haImportOfferGo => 'Importa';

  @override
  String get haImportSignIn => 'Accedi con Home Assistant';

  @override
  String get haImportSignInHelp =>
      'Il login di Home Assistant si apre nel browser. ZigDash non vede mai la tua password e si disconnette di nuovo dopo la lettura.';

  @override
  String get haImportOrToken => 'Oppure usa un token a lunga durata';

  @override
  String get haImportReadToken => 'Leggi con il token';

  @override
  String get haImportSignInRefused =>
      'Home Assistant non ha accettato l\'accesso. Succede quando Home Assistant non ha accesso a internet. Usa invece un token a lunga durata qui sotto.';

  @override
  String get setupIsolatedHint =>
      'Il tuo telefono non vede quasi nient\'altro su questo Wi-Fi. Potrebbe essere su una rete ospiti, oppure il router tiene separati i dispositivi (spesso si chiama isolamento client o AP). Collegati al Wi-Fi principale, o disattiva l\'isolamento, poi riprova.';

  @override
  String get setupAuthTrust =>
      'Il tuo login resta su questo telefono e va solo al tuo broker. ZigDash non ha server né account, e ogni app MQTT accede così. La scelta più sicura: un utente MQTT separato solo per ZigDash, che puoi rimuovere quando vuoi.';

  @override
  String get setupAuthWhatKept => 'Cosa conserva ZigDash';

  @override
  String get setupAuthDemoFirst => 'Prima prova la demo';

  @override
  String get automationsTitle => 'Automazioni';

  @override
  String get engineRunningOnHub => 'Sull\'hub';

  @override
  String get engineChecking => 'Controllo dell\'hub…';

  @override
  String get engineAwayNoHubTitle =>
      'Al momento il tuo hub non è raggiungibile';

  @override
  String get engineAwayNoHubBody =>
      'Sei fuori casa e il tuo hub non è collegato all\'accesso remoto di ZigDash, oppure è senza internet. Le tue automazioni continuano a funzionare sull\'hub.';

  @override
  String get engineAwayReinstallAtHome =>
      'Potrai reinstallare l\'Engine quando sei a casa.';

  @override
  String get engineNoConnection =>
      'ZigDash ora non raggiunge il broker di questa casa. Le automazioni si configurano da connessi, a casa.';

  @override
  String get engineRestarting =>
      'Riavvio di Zigbee2MQTT… I dispositivi tornano in circa 30 secondi.';

  @override
  String get engineInstalling => 'Installazione sull\'hub…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT va aggiornato';

  @override
  String engineTooOldBody(Object version) {
    return 'Il tuo Zigbee2MQTT è la versione $version. Le automazioni richiedono la 2.4 o successiva. Aggiorna Zigbee2MQTT sull\'hub, poi torna qui.';
  }

  @override
  String get engineIntroTitle =>
      'Le automazioni girano sull\'hub, non sul telefono';

  @override
  String get engineIntroBody =>
      'ZigDash mette ZigDash Engine dentro Zigbee2MQTT sul tuo hub. Osserva i dispositivi ed esegue le tue regole, così una luce si accende quando la porta si apre anche col telefono spento e senza internet.';

  @override
  String get engineIntroNothingByHand =>
      'Niente da installare a mano. ZigDash lo fa tramite la rete di casa.';

  @override
  String engineIntroVersion(Object version) {
    return 'Il tuo Zigbee2MQTT è la versione $version.';
  }

  @override
  String get engineIntroRemove =>
      'Puoi rimuoverlo quando vuoi da questa schermata.';

  @override
  String get engineInstall => 'Installa sull\'hub';

  @override
  String get engineDeclinedTitle => 'Nessuna automazione su questo hub';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT sul tuo hub non consente estensioni, quindi niente può eseguire le tue regole quando il telefono è lontano. Scene, avvisi e dashboard funzionano come prima.';

  @override
  String get engineAllowAfterAll => 'Consenti le estensioni';

  @override
  String get engineConsentTitle => 'Zigbee2MQTT deve cambiare un\'impostazione';

  @override
  String get engineConsentBody =>
      'Il tuo Zigbee2MQTT blocca estensioni come ZigDash Engine, come fanno le nuove installazioni. Per eseguire automazioni sull\'hub, ZigDash attiverebbe «Consenti JavaScript esterno» in Zigbee2MQTT e lo riavvierebbe.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT si riavvia una volta. Luci e sensori non sono raggiungibili per circa 30 secondi.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine è open source. Puoi leggerlo nella pagina di Zigbee2MQTT, in Estensioni.';

  @override
  String get engineConsentUndo =>
      'Puoi disattivare l\'impostazione più tardi. Le automazioni allora si fermano.';

  @override
  String get engineConsentYes => 'Cambia l\'impostazione e riavvia';

  @override
  String get engineConsentNo => 'Non ora';

  @override
  String get automationsPausedTitle => 'Automazioni in pausa';

  @override
  String get automationsPausedBody =>
      'Il tuo hub non dà notizie da oltre un minuto, quindi nessuna automazione può partire finché non torna. Le tue regole restano.';

  @override
  String get engineReinstall => 'Reinstalla sull\'hub';

  @override
  String get engineStoppedTitle =>
      'Automazioni in pausa: ZigDash Engine si è fermato';

  @override
  String get engineStoppedBody =>
      'Ha avuto errori tre volte in un\'ora e si è spento perché Zigbee2MQTT continui a funzionare. Le tue regole restano.';

  @override
  String get engineStartAgain => 'Avvia di nuovo';

  @override
  String get engineReportProblem => 'Segnala un problema';

  @override
  String get engineRunningTitle => 'Il tuo hub è pronto per le automazioni';

  @override
  String engineRunningBody(Object count) {
    return 'Regole caricate sull\'hub: $count. La creazione delle automazioni arriva nel prossimo passo di questa versione.';
  }

  @override
  String get engineClockOff =>
      'L\'orologio del tuo hub sbaglia di oltre cinque minuti. Le automazioni a orario partiranno all\'ora sbagliata finché non viene corretto.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Regole che ZigDash Engine sull\'hub non sa ancora eseguire: $count. Reinstallalo per aggiornarlo.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT ha rifiutato ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT non ha risposto. Controlla che la casa sia connessa e riprova.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT non ha accettato la modifica o non è tornato. Controlla l\'hub e riprova.';

  @override
  String get autoValMotion => 'movimento';

  @override
  String get autoValNoMotion => 'nessun movimento';

  @override
  String get autoValClosed => 'chiuso';

  @override
  String get autoValOpened => 'aperto';

  @override
  String get autoValLeak => 'perdita';

  @override
  String get autoValDry => 'asciutto';

  @override
  String get autoValSmoke => 'fumo';

  @override
  String get autoValNoSmoke => 'nessun fumo';

  @override
  String get autoValOn => 'acceso';

  @override
  String get autoValOff => 'spento';

  @override
  String get autoValToggle => 'commuta';

  @override
  String get autoValOpen => 'apri';

  @override
  String get autoValClose => 'chiudi';

  @override
  String get autoValStop => 'ferma';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Quando $device: $property sopra $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Quando $device: $property sotto $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Quando $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'Alle $time';
  }

  @override
  String get autoSunrise => 'alba';

  @override
  String get autoSunset => 'tramonto';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min dopo $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min prima di $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'All\'$sun';
  }

  @override
  String get autoEveryDay => 'ogni giorno';

  @override
  String get autoWeekdays => 'giorni feriali';

  @override
  String get autoWeekends => 'weekend';

  @override
  String autoBetween(Object from, Object to) {
    return 'tra $from e $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device è $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Esegui «$scene»';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, si spegne dopo $minutes min';
  }

  @override
  String get autoErrPickTrigger => 'Scegli un dispositivo e cosa fa.';

  @override
  String get autoErrValue => 'Scrivi un numero per la lettura.';

  @override
  String get autoErrDays => 'Scegli almeno un giorno.';

  @override
  String get autoErrTown => 'Imposta la tua città per alba e tramonto.';

  @override
  String get autoErrPickAction => 'Scegli cosa deve succedere.';

  @override
  String get autoErrEmptyScene => 'Questa scena non ha niente da inviare.';

  @override
  String get autoErrNotConnected =>
      'ZigDash non è connesso a questa casa. Riprova da casa.';

  @override
  String get autoNewTitle => 'Nuova automazione';

  @override
  String get autoEditTitle => 'Modifica automazione';

  @override
  String get autoName => 'Nome';

  @override
  String get autoNameHint => 'Cosa fa (facoltativo)';

  @override
  String get autoWhen => 'Quando';

  @override
  String get autoOnlyIf => 'Solo se';

  @override
  String get autoThen => 'Allora';

  @override
  String get autoEnabled => 'Attiva';

  @override
  String get autoDelete => 'Elimina automazione';

  @override
  String get autoSave => 'Salva';

  @override
  String get autoDeviceChanges => 'Un dispositivo cambia';

  @override
  String get autoTimeComes => 'Arriva un orario';

  @override
  String get autoDevice => 'Dispositivo';

  @override
  String get autoAbove => 'sopra';

  @override
  String get autoBelow => 'sotto';

  @override
  String get autoClockTime => 'Orario';

  @override
  String get autoAt => 'Alle';

  @override
  String get autoShift => 'Spostamento in minuti (meno è prima)';

  @override
  String get autoTownNone => 'Nessuna città';

  @override
  String autoTownIs(Object town) {
    return 'Orari del sole per $town';
  }

  @override
  String get autoTownSet => 'Imposta città';

  @override
  String get autoTownChange => 'Cambia città';

  @override
  String get autoDays => 'Giorni';

  @override
  String get autoNoConditions => 'Nessuna condizione. Si esegue ogni volta.';

  @override
  String get autoAddHours => 'Tra due orari';

  @override
  String get autoFrom => 'Da';

  @override
  String get autoTo => 'A';

  @override
  String get autoAddDeviceCondition => 'Un dispositivo è…';

  @override
  String get autoRunASceneOption => 'Esegui una scena';

  @override
  String get autoSetADevice => 'Imposta un dispositivo';

  @override
  String get autoScene => 'Scena';

  @override
  String get autoTurnOffAgain => 'Spegni di nuovo';

  @override
  String get autoStaysAsSet => 'Resta così';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minuti dopo';
  }

  @override
  String get autoTownSearch => 'Città';

  @override
  String get autoTownWhy =>
      'Usata solo per alba e tramonto. Salvata sull\'hub, mai la tua posizione.';

  @override
  String get autoNewButton => 'Nuova automazione';

  @override
  String get autoEmptyBody =>
      'Non gira ancora niente. Tocca Nuova automazione per creare la prima.';

  @override
  String autoOnlyIfList(Object list) {
    return 'solo se $list';
  }

  @override
  String get autoEdit => 'Modifica';

  @override
  String get autoNeverRan => 'mai eseguita';

  @override
  String autoRanAt(Object time) {
    return 'eseguita alle $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count di $max automazioni gratuite';
  }

  @override
  String get autoRecentRuns => 'Ultime esecuzioni';

  @override
  String get autoDeleted => '(eliminata)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count automazioni sono gratuite. Ne vuoi di più?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash è gratuito e open source, fatto da una persona. Pro è un acquisto unico: automazioni illimitate, cronologia di 7 e 30 giorni e gli extra per tablet a parete. Le tue automazioni continuano qualunque cosa tu scelga.';

  @override
  String get autoCeilingSeePro => 'Vedi Pro';

  @override
  String get engineRemove => 'Rimuovi dall\'hub';

  @override
  String get engineRemoveTitle => 'Rimuovere ZigDash Engine dall\'hub?';

  @override
  String get engineRemoveBody =>
      'Le automazioni smettono di girare. Le regole restano sull\'hub, quindi reinstallando ZigDash Engine tornano.';

  @override
  String get autoNoTargets =>
      'Questa casa non ha ancora luci, prese, interruttori o tapparelle da comandare.';

  @override
  String get proGetAutomations =>
      'Automazioni illimitate; tre per casa sono gratuite';

  @override
  String get proGetRemote =>
      'Controllo remoto ovunque, tramite il relay di ZigDash, senza canone mensile';

  @override
  String get proRemoteFair =>
      'L\'accesso remoto è incluso finché il relay di ZigDash è attivo, per una casa, fino a cinque telefoni e un normale uso domestico. Può cambiare o terminare con preavviso.';

  @override
  String get autoDeleteConfirm =>
      'Eliminare questa automazione? Smette di girare sull\'hub.';

  @override
  String get statusConnectedRelay => 'Connesso · Fuori casa via ZigDash';

  @override
  String get shareHomeTitle => 'Condividi con un altro telefono';

  @override
  String get shareHomeSubtitle =>
      'Aggiungi questa casa a un altro telefono con un codice QR';

  @override
  String get shareHomeIntro =>
      'Sull\'altro telefono, a casa sulla stessa Wi-Fi, inquadra il codice con la fotocamera. ZigDash aggiunge questa casa con il suo accesso e le tue dashboard.';

  @override
  String get shareHomeLoginWarning =>
      'Il codice contiene l\'accesso al broker di questa casa. Resta visibile 2 minuti; mostralo solo a persone di cui ti fidi.';

  @override
  String get shareHomeShow => 'Mostra il codice';

  @override
  String get shareHomeAtHome =>
      'Collegati prima da casa: la condivisione funziona solo sulla rete di casa.';

  @override
  String get shareHomeScanHint =>
      'Inquadralo con la fotocamera dell\'altro telefono. Il codice si nasconde tra 2 minuti.';

  @override
  String get shareHomeHide => 'Nascondi il codice';

  @override
  String get shareHomeViaHa =>
      'Questa casa si collega tramite Home Assistant. Sull\'altro telefono installa ZigDash e accedi con Home Assistant.';

  @override
  String get joinHomeTitle => 'Aggiungi una casa condivisa';

  @override
  String get joinHomeInvalid =>
      'Questo codice non è un invito di ZigDash, oppure è danneggiato.';

  @override
  String joinHomeAlready(String name) {
    return '$name è già su questo telefono.';
  }

  @override
  String get joinHomeOpen => 'Apri';

  @override
  String joinHomeAsk(String name) {
    return 'Aggiungere $name a questo telefono?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash aggiunge la casa con la stessa connessione e lo stesso accesso, e prende le dashboard dall\'altro telefono. Tieni questo telefono sulla Wi-Fi di casa.';

  @override
  String get joinHomeAdd => 'Aggiungi casa';

  @override
  String get joinHomeNoDashboards =>
      'Casa aggiunta. Le dashboard non sono arrivate; i dispositivi sono nella scheda Dispositivi.';

  @override
  String get remoteTitle => 'Controllo remoto';

  @override
  String get remoteSettingsSubtitle =>
      'Controlla questa casa da ovunque, con Pro';

  @override
  String get remoteIntroTitle => 'Controlla la tua casa da ovunque';

  @override
  String get remoteOfferBody =>
      'Raggiungi i tuoi dispositivi quando sei fuori, tramite il relay cifrato di ZigDash. Incluso in Pro: un solo pagamento, nessun canone mensile. Configuralo mentre sei a casa.';

  @override
  String get remoteOfferBodyPro =>
      'Hai Pro: attiva il controllo remoto mentre sei a casa, poi raggiungi i tuoi dispositivi da ovunque.';

  @override
  String get remoteOfferShow => 'Mostra';

  @override
  String get remoteIntroBody =>
      'Il tuo hub mantiene una connessione al relay di ZigDash. Fuori casa, questo telefono raggiunge i dispositivi tramite il relay. Tutto è cifrato sull\'hub e sul telefono, quindi il relay non può leggere i dispositivi né cosa fanno.';

  @override
  String get remoteNeedsEngine =>
      'Il controllo remoto gira in ZigDash Engine. Installalo prima in Automazioni.';

  @override
  String get remoteSetUp => 'Attiva il controllo remoto';

  @override
  String get remoteNeedsPro => 'Il controllo remoto fa parte di Pro.';

  @override
  String get remoteNotAtHome => 'Attivalo a casa, connesso al tuo broker.';

  @override
  String get remoteUnreachable =>
      'Il relay di ZigDash non ha risposto. Riprova più tardi.';

  @override
  String get remoteRefused =>
      'Il relay ha rifiutato. Riprova o segnala un problema.';

  @override
  String get remoteOnTitle => 'Il controllo remoto è attivo';

  @override
  String get remoteOnBody =>
      'Fuori casa, ZigDash si collega da solo tramite il relay.';

  @override
  String get remoteHubOnline => 'L\'hub è connesso al relay';

  @override
  String get remoteHubOffline => 'L\'hub non è connesso al relay';

  @override
  String get remoteTurnOff => 'Disattiva il controllo remoto';

  @override
  String get remoteViaRelayNow =>
      'Questo telefono è connesso tramite il relay in questo momento.';

  @override
  String get remotePhones => 'Telefoni con accesso remoto';

  @override
  String get remoteThisPhone => 'Questo telefono';

  @override
  String get remoteOtherPhone => 'Un altro telefono';

  @override
  String remotePhoneAdded(Object date) {
    return 'Aggiunto il $date';
  }

  @override
  String get remoteRemovePhone => 'Rimuovi';

  @override
  String get remoteRemovePhoneConfirm =>
      'Rimuovere questo telefono? Non potrà più raggiungere questa casa da fuori.';

  @override
  String get remoteAddPhone => 'Aggiungi un telefono';

  @override
  String get remoteAddPhoneHint =>
      'A casa, inquadralo con la fotocamera dell\'altro telefono. Apre ZigDash e attiva lì il controllo remoto. Mostralo solo ai tuoi telefoni.';

  @override
  String get remoteAddPhoneFailed =>
      'Il relay non ha dato un accesso per un altro telefono. Una casa può averne fino a cinque.';

  @override
  String get remoteBackupSave => 'Salva un backup della chiave';

  @override
  String get remoteBackupRestore => 'Ripristina da un backup della chiave';

  @override
  String get remoteBackupPassphrase => 'Passphrase del backup';

  @override
  String get remoteBackupPassphraseHint =>
      'Se perdi questo telefono, il backup e questa passphrase riportano il controllo remoto su uno nuovo. Almeno 8 caratteri, e tieni la passphrase in un posto diverso dal file.';

  @override
  String get remoteBackupPassphraseAsk =>
      'La passphrase scelta quando hai salvato il backup.';

  @override
  String get remoteBackupPassphraseAgain => 'Ripeti la passphrase';

  @override
  String get remoteBackupSaved => 'Backup della chiave salvato';

  @override
  String get remoteBackupWrong => 'Questa passphrase non apre il backup.';

  @override
  String get remoteBackupWrongFile =>
      'Questo non è un backup di chiave di ZigDash.';

  @override
  String get remotePlayOnly =>
      'Per ora il controllo remoto è nella versione Google Play di ZigDash.';

  @override
  String get remotePairTitle => 'Aggiungi il controllo remoto';

  @override
  String get remotePairBody =>
      'Quale casa è? ZigDash conserva l\'accesso remoto per questa.';

  @override
  String get remotePairNoHomes =>
      'Configura prima questa casa su questo telefono, a casa. Poi inquadra di nuovo il codice.';

  @override
  String get remotePairInvalid =>
      'Questo codice non è un codice di controllo remoto ZigDash, oppure è stato tagliato.';

  @override
  String remotePairDone(Object home) {
    return 'Controllo remoto attivo per $home';
  }

  @override
  String get remoteReconnectHub => 'Ricollega l\'hub';

  @override
  String get remoteTurnOffConfirm =>
      'Questo telefono lascia il controllo remoto e l\'hub si scollega dal relay. Un backup della chiave salvato da questo telefono smette di funzionare; gli altri telefoni mantengono l\'accesso finché non li rimuovi.';

  @override
  String remoteHomeId(Object id) {
    return 'ID della casa $id';
  }

  @override
  String get alertsHintTitle => 'Ricevi avvisi su questo telefono';

  @override
  String get alertsHintBody =>
      'Una perdita, fumo, una porta aperta o una batteria scarica possono inviare una notifica a questo telefono, anche con ZigDash chiuso.';

  @override
  String get alertsHintButton => 'Configura gli avvisi';

  @override
  String get alertsHintNotNow => 'Non ora';

  @override
  String get guidedNoZ2mBody =>
      'Qui risponde un broker MQTT, ma Zigbee2MQTT non invia nulla su di esso. Controlla che Zigbee2MQTT sia avviato e usi questo broker, e che il topic di base corrisponda alle sue impostazioni. Se i tuoi dispositivi Zigbee sono in ZHA di Home Assistant, ZigDash non può vederli: funziona con Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT è su questo broker con il topic base «$found», ma questa casa cerca «$current».';
  }

  @override
  String devicesUseBase(String found) {
    return 'Usa «$found»';
  }

  @override
  String get devicesChangeConnection => 'Modifica connessione';

  @override
  String get updateAvailableTitle => 'È pronta una nuova versione di ZigDash';

  @override
  String get updateAvailableBody =>
      'Si scarica mentre continui a usare ZigDash.';

  @override
  String get updateAvailableButton => 'Aggiorna';

  @override
  String get updateDownloading => 'Download dell\'aggiornamento…';

  @override
  String get updateReadyTitle => 'Aggiornamento scaricato';

  @override
  String get updateReadyButton => 'Riavvia per completare';
}
