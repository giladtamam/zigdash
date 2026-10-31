// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Ostatnio znane';

  @override
  String get reliabilityControlsUnavailable => 'Sterowanie niedostępne';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'Wypróbuj demo';

  @override
  String get navBrokers => 'Brokery';

  @override
  String get navDashboards => 'Dashboardy';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get settingsDynamicColor => 'Użyj kolorów Material You';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; w przeciwnym razie kolor aplikacji';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get languageEnglish => 'Angielski';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Domy';

  @override
  String connLoadFailed(Object error) {
    return 'Nie udało się wczytać: $error';
  }

  @override
  String get connAddBroker => 'Dodaj broker';

  @override
  String get connEmpty =>
      'Brak połączeń.\nDotknij „Dodaj broker”, aby połączyć ZigDash z serwerem MQTT.';

  @override
  String get connNew => 'Nowe połączenie';

  @override
  String get connEdit => 'Edytuj połączenie';

  @override
  String get save => 'Zapisz';

  @override
  String get saving => 'Zapisywanie…';

  @override
  String get fieldRequired => 'Wymagane';

  @override
  String get connName => 'Nazwa';

  @override
  String get connNameHint => 'Broker domowy';

  @override
  String get connHost => 'Host';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Host lokalny';

  @override
  String get connFindBrokers => 'Znajdź brokery';

  @override
  String get connHowToFind => 'Jak to znaleźć?';

  @override
  String get connRescan => 'Skanuj ponownie';

  @override
  String get connBrokerNeedsLogin => 'Wymaga logowania';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Skanowanie $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return 'Znalezione brokery: $count — dotknij, aby użyć';
  }

  @override
  String get connFindBrokersNone =>
      'Nie znaleziono brokerów w Twojej sieci Wi-Fi.';

  @override
  String get connFindBrokersNoIp =>
      'Nie udało się odczytać adresu Wi-Fi. Upewnij się, że Wi-Fi jest włączone, i spróbuj ponownie.';

  @override
  String get connHelpTitle => 'Jak znaleźć IP brokera';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT w Dockerze';

  @override
  String get connHelpDockerBody =>
      'IP brokera to adres LAN komputera, na którym działa Docker (NAS, Raspberry Pi itp.). Znajdziesz go na liście urządzeń w routerze lub uruchamiając na tym komputerze \'hostname -I\' / \'ip addr\'. Port to zwykle 1883 (Mosquitto). Użyj adresu LAN hosta — nie 127.0.0.1 — nawet jeśli Mosquitto działa we własnym kontenerze.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'IP brokera to adres IP huba. Otwórz stronę huba (smhub.local): na Dashboard ramka Network pokazuje go obok IPv4. Aplikacja routera też pokazuje hub jako SMHUB. Port to 1883, domyślnie bez nazwy użytkownika i hasła.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA nie ma brokera MQTT — rozmawia bezpośrednio z Home Assistantem, więc ZigDash nie może się z nim połączyć. Aby używać ZigDash, przejdź na Zigbee2MQTT (dostępny jako aplikacja Home Assistanta lub kontener Docker), który zapewnia broker MQTT.';

  @override
  String get connHelpSameNetwork =>
      'Telefon i broker muszą być w tej samej sieci Wi-Fi (nie w sieci dla gości ani w izolowanym VLAN).';

  @override
  String get connRemoteHost => 'Host zdalny (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Używany, gdy host lokalny jest nieosiągalny. Najlepiej adres IP huba w Tailscale, np. 100.x.y.z';

  @override
  String get connPort => 'Port';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsername => 'Nazwa użytkownika';

  @override
  String get connUsernameOptional => 'Nazwa użytkownika (opcjonalnie)';

  @override
  String get connPasswordOptional => 'Hasło (opcjonalnie)';

  @override
  String get connPasswordKeepHint => 'Pozostaw puste, aby zachować obecne';

  @override
  String get connAutoConnect => 'Łącz automatycznie przy starcie';

  @override
  String get advanced => 'Zaawansowane';

  @override
  String get connKeepAlive => 'Keep-alive (sekundy)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protokół';

  @override
  String get edit => 'Edytuj';

  @override
  String get delete => 'Usuń';

  @override
  String get cancel => 'Anuluj';

  @override
  String get connDeleteTitle => 'Usunąć połączenie?';

  @override
  String connDeleteContent(Object name) {
    return 'Usuwa „$name”, jego dashboardy i kafelki oraz zapisane hasło.';
  }

  @override
  String get statusDisconnected => 'Rozłączono';

  @override
  String get statusConnecting => 'Łączenie';

  @override
  String get statusConnected => 'Połączono';

  @override
  String get statusReconnecting => 'Ponowne łączenie';

  @override
  String get statusError => 'Błąd';

  @override
  String get statusConnectedRemote => 'Połączono · Zdalnie';

  @override
  String get dashPlaceholder =>
      'Otwórz broker na karcie Brokery, aby zobaczyć jego dashboardy i nimi zarządzać.';

  @override
  String get dashAddDashboard => 'Dodaj dashboard';

  @override
  String get dashEditDashboard => 'Edytuj dashboard';

  @override
  String get dashAddPanel => 'Dodaj kafelek';

  @override
  String get dashEmpty =>
      'Brak dashboardów.\nDotknij „Dodaj dashboard”, aby utworzyć pierwszy dla tego brokera.';

  @override
  String dashLoadFailed(Object error) {
    return 'Błąd: $error';
  }

  @override
  String get panelPickerTitle => 'Dodaj kafelek';

  @override
  String get panelPickerSectionControl => 'Sterowanie';

  @override
  String get panelPickerSectionState => 'Stan';

  @override
  String get panelPickerToggleTitle => 'Przełącznik';

  @override
  String get panelPickerToggleSubtitle => 'Włącznik wł./wył. stanu urządzenia';

  @override
  String get panelPickerSliderBrightnessTitle => 'Suwak — Jasność';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Ściemnianie światła (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Suwak — Pozycja';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Roleta / żaluzja (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Roleta';

  @override
  String get panelPickerCoverSubtitle =>
      'Roleta/żaluzja: OPEN·STOP·CLOSE + suwak pozycji';

  @override
  String get panelPickerScheduleTitle => 'Harmonogram';

  @override
  String get panelPickerScheduleSubtitle =>
      'Codzienne godziny otwarcia/zamknięcia, wykonywane na hubie (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Reguła autozamykania';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Zamyka urządzenie automatycznie N sekund po włączeniu, wykonywane na hubie (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Wielostanowy';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Przyciski segmentowe dla wartości wyliczeniowej (np. OPEN/STOP/CLOSE)';

  @override
  String get panelPickerComboTitle => 'Lista rozwijana';

  @override
  String get panelPickerComboSubtitle =>
      'Wybór z listy rozwijanej dla wartości wyliczeniowej';

  @override
  String get panelPickerRadioTitle => 'Przyciski opcji';

  @override
  String get panelPickerRadioSubtitle =>
      'Lista przycisków opcji dla wartości wyliczeniowej';

  @override
  String get panelPickerButtonTitle => 'Przycisk';

  @override
  String get panelPickerButtonSubtitle => 'Wysyła jednorazowe polecenie';

  @override
  String get panelPickerTextInputTitle => 'Pole tekstowe';

  @override
  String get panelPickerTextInputSubtitle =>
      'Publikuje dowolną wartość lub JSON';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Kolorowy wskaźnik stanu logicznego (kontaktron, zalanie)';

  @override
  String get panelPickerNodeStatusTitle => 'Status węzła';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Dostępność urządzenia Z2M (online/offline)';

  @override
  String get panelPickerProgressTitle => 'Pasek postępu';

  @override
  String get panelPickerProgressSubtitle =>
      'Pasek liczbowy dla baterii, jakości łącza itp.';

  @override
  String get panelPickerTextLogTitle => 'Dziennik tekstowy';

  @override
  String get panelPickerTextLogSubtitle =>
      'Przewijana historia wiadomości z tematu';

  @override
  String get dashExportMenu => 'Eksportuj dashboardy';

  @override
  String get dashImportMenu => 'Importuj dashboardy';

  @override
  String get dashExportTitle => 'Eksport dashboardów';

  @override
  String get dashExportClose => 'Zamknij';

  @override
  String get dashExportCopy => 'Kopiuj';

  @override
  String get dashExportCopied => 'Skopiowano do schowka';

  @override
  String get dashImportTitle => 'Import dashboardów';

  @override
  String get dashImportHint => 'Wklej tutaj wyeksportowany JSON';

  @override
  String get dashImportButton => 'Importuj';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zaimportowano $count dashboardu',
      many: 'Zaimportowano $count dashboardów',
      few: 'Zaimportowano $count dashboardy',
      one: 'Zaimportowano $count dashboard',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Import nie powiódł się: $error';
  }

  @override
  String get dashFormNew => 'Nowy dashboard';

  @override
  String get dashFormEdit => 'Edytuj dashboard';

  @override
  String get dashFormName => 'Nazwa';

  @override
  String get dashFormNameHint => 'Biuro';

  @override
  String get dashFormTopicPrefix => 'Prefiks tematu (opcjonalnie)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/living-room';

  @override
  String get dashFormTopicPrefixHelper =>
      'Dodawany na początku tematu każdego kafelka na tym dashboardzie';

  @override
  String get dashFormColorSeed => 'Kolor bazowy';

  @override
  String get dashFormIcon => 'Ikona';

  @override
  String get dashFormLock => 'Blokada edycji';

  @override
  String get dashFormLockSubtitle => 'Ukrywa Edytuj dla tego pulpitu';

  @override
  String get dashFormDelete => 'Usuń dashboard';

  @override
  String get dashDeleteTitle => 'Usunąć ten dashboard?';

  @override
  String get dashDeleteContent =>
      'Wszystkie jego kafelki również zostaną usunięte.';

  @override
  String get dashDeleteConfirm => 'Usuń';

  @override
  String panelFormNew(Object type) {
    return 'Nowy kafelek: $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Edytuj kafelek: $type';
  }

  @override
  String get panelTypeButton => 'Przycisk';

  @override
  String get panelTypeToggle => 'Przełącznik';

  @override
  String get panelTypeSlider => 'Suwak';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Status węzła';

  @override
  String get panelTypeProgress => 'Pasek postępu';

  @override
  String get panelTypeMultiState => 'Wielostanowy';

  @override
  String get panelTypeCombo => 'Lista rozwijana';

  @override
  String get panelTypeRadio => 'Przyciski opcji';

  @override
  String get panelTypeCover => 'Roleta';

  @override
  String get panelTypeTextInput => 'Pole tekstowe';

  @override
  String get panelTypeTextLog => 'Dziennik tekstowy';

  @override
  String get panelTypeSchedule => 'Harmonogram';

  @override
  String get panelTypeAutoClose => 'Autozamykanie';

  @override
  String get panelTypeDevice => 'Urządzenie';

  @override
  String get panelTypeReading => 'Odczyt';

  @override
  String get panelFormName => 'Nazwa';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Prefiks dashboardu: $prefix/ (używany, jeśli nie nadpisano poniżej)';
  }

  @override
  String get panelFormTopicPrefixOverride =>
      'Nadpisanie prefiksu tematu (opcjonalnie)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/shutter';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Użyj innego urządzenia na tym dashboardzie. Puste = prefiks dashboardu.';

  @override
  String get panelFormPublishTopic => 'Temat publikacji (sufiks)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Dołączany do efektywnego prefiksu. Pozostaw puste, aby publikować w samym prefiksie.';

  @override
  String get panelFormTopicSuffix => 'Temat (sufiks)';

  @override
  String get panelFormSubscribeTopic =>
      'Temat subskrypcji (sufiks, opcjonalnie)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Dołączany do prefiksu dashboardu. Puste = subskrypcja samego prefiksu (stan Z2M).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Puste = subskrypcja samego prefiksu (stan Z2M). Taki sam jak temat publikacji = użyj go.';

  @override
  String get tileSize => 'Rozmiar';

  @override
  String get tileSizeSmall => 'Mały';

  @override
  String get tileSizeWide => 'Szeroki';

  @override
  String get tileSizeFull => 'Pełny';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — najwyżej raz';

  @override
  String get panelFormQos1 => '1 — co najmniej raz';

  @override
  String get panelFormQos2 => '2 — dokładnie raz';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'Payload włączenia';

  @override
  String get panelToggleOffPayload => 'Payload wyłączenia';

  @override
  String get panelToggleJsonPath => 'Ścieżka JSON (opcjonalnie)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'Wartość „wł.”';

  @override
  String get panelToggleOnMatchHelper =>
      'Wartość pod ścieżką JSON oznaczająca „wł.” (np. „ON”)';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Maks';

  @override
  String get panelSliderStep => 'Krok';

  @override
  String get panelSliderTemplate => 'Szablon wartości';

  @override
  String get panelSliderTemplateHelper =>
      'Użyj słowa value jako symbolu zastępczego — zostanie zastąpione wartością suwaka';

  @override
  String get panelSliderJsonPath => 'Ścieżka JSON (opcjonalnie)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'Ścieżka JSON (opcjonalnie)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'np. „contact”, „occupancy”, „water_leak”';

  @override
  String get panelLedOnMatch => 'Wartość „wł.”';

  @override
  String get panelLedOnMatchHelper =>
      'Wartość pod ścieżką JSON, która zapala LED (np. „true”, „ON”)';

  @override
  String get panelLedOnLabel => 'Etykieta „wł.” (opcjonalnie)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Etykieta „wył.” (opcjonalnie)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Payload online';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Wartość oznaczająca „online” (domyślnie w Z2M: „online”)';

  @override
  String get panelNodeJsonPath => 'Ścieżka JSON (opcjonalnie)';

  @override
  String get panelNodeJsonPathHelper =>
      'Pozostaw puste dla domyślnego Z2M (surowy tekst „online”/„offline”)';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Maks';

  @override
  String get panelProgressUnit => 'Jednostka';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'Ścieżka JSON (opcjonalnie)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'np. „battery”, „linkquality”';

  @override
  String get panelOptionsJsonPath => 'Ścieżka JSON (opcjonalnie)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Pole w odebranym payloadzie z bieżącą wartością';

  @override
  String get panelOptionsHeader => 'Opcje';

  @override
  String get panelOptionsLabel => 'Etykieta';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Dopasowanie (bieżąca wartość)';

  @override
  String get panelOptionsAdd => 'Dodaj opcję';

  @override
  String get panelCoverDescription =>
      'Przyciski OPEN / STOP / CLOSE oraz rząd ustawień pozycji. Używa standardowych payloadów rolet Z2M (state i position).';

  @override
  String get panelCoverPresets => 'Ustawienia pozycji';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Wartości procentowe oddzielone przecinkami (0–100). Puste = bez rzędu ustawień.';

  @override
  String get panelCoverShowSlider => 'Pokaż suwak pozycji';

  @override
  String get panelTextInputHint => 'Podpowiedź (opcjonalnie)';

  @override
  String get panelTextInputHintHint => 'Wpisz wartość…';

  @override
  String get panelTextInputTemplate => 'Szablon';

  @override
  String get panelTextInputTemplateHelper =>
      'Użyj słowa value jako symbolu zastępczego — zostanie zastąpione wpisanym tekstem. Domyślnie publikowany jest surowy tekst.';

  @override
  String get panelTextInputClearAfterSend => 'Wyczyść po wysłaniu';

  @override
  String get panelTextLogMaxLines => 'Maks. liczba linii';

  @override
  String get panelTextLogMaxLinesHelper => 'Ile ostatnich wiadomości zachować';

  @override
  String get panelTextLogJsonPath => 'Ścieżka JSON (opcjonalnie)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Zapisuj tylko to pole zamiast całego payloadu';

  @override
  String get panelScheduleDescription =>
      'Działa na SMHUB przez Node-RED — wykonuje się nawet przy wyłączonym telefonie. Powyższy „Temat publikacji” to cel poleceń rolety.';

  @override
  String get panelScheduleOpenTime => 'Godzina otwarcia';

  @override
  String get panelScheduleCloseTime => 'Godzina zamknięcia';

  @override
  String get panelScheduleOpenPayload => 'Payload otwarcia';

  @override
  String get panelScheduleClosePayload => 'Payload zamknięcia';

  @override
  String get panelScheduleEnabled => 'Włączony';

  @override
  String get panelScheduleSavedOffline =>
      'Zapisano — brak połączenia; harmonogram zsynchronizuje się po połączeniu.';

  @override
  String get panelAutoCloseDescription =>
      'Działa na SMHUB przez Node-RED — wykonuje się nawet przy wyłączonym telefonie. Powyższy „Temat publikacji” to cel poleceń urządzenia (np. drzwi).';

  @override
  String get panelAutoCloseTriggerPath => 'Ścieżka JSON wyzwalacza';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Pole w JSON-ie stanu urządzenia do obserwowania (domyślnie: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Wartość wyzwalacza';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Uruchom licznik, gdy pole wyzwalacza ma tę wartość (domyślnie: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Payload zamknięcia';

  @override
  String get panelAutoCloseDelaySeconds => 'Opóźnienie (sekundy)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1-3600. Czas od włączenia urządzenia do opublikowania payloadu zamknięcia.';

  @override
  String get panelAutoCloseEnabled => 'Włączona';

  @override
  String get panelAutoCloseSavedOffline =>
      'Zapisano — brak połączenia; reguła zsynchronizuje się po połączeniu.';

  @override
  String get panelTileEdit => 'Edytuj kafelek';

  @override
  String get panelTileDuplicate => 'Duplikuj kafelek';

  @override
  String get panelTileMoveUp => 'Przenieś w górę';

  @override
  String get panelTileMoveDown => 'Przenieś w dół';

  @override
  String get panelTileDelete => 'Usuń kafelek';

  @override
  String get panelCoverOpen => 'Otwórz';

  @override
  String get panelCoverStop => 'Stop';

  @override
  String get panelCoverClose => 'Zamknij';

  @override
  String get panelToggleNoState => '(brak stanu)';

  @override
  String get panelToggleError => 'błąd';

  @override
  String get panelStateOn => 'ON';

  @override
  String get panelStateOff => 'OFF';

  @override
  String get panelNodeStatusOnline => 'online';

  @override
  String get panelNodeStatusOffline => 'offline';

  @override
  String get panelNodeStatusUnknown => 'nieznany';

  @override
  String get panelNodeStatusError => 'błąd';

  @override
  String get panelMultiStateNoOptions => 'Brak skonfigurowanych opcji';

  @override
  String get panelTextInputDefaultHint => 'Wpisz wartość…';

  @override
  String get panelTextLogWaiting => 'Oczekiwanie na wiadomości…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Otwarcie $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Zamknięcie $time';
  }

  @override
  String get panelScheduleOfflineWarning =>
      'Harmonogram offline — nie zadziała';

  @override
  String get panelScheduleDisabled => 'Wyłączony';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Następne: $action o $at';
  }

  @override
  String get panelScheduleActionOpen => 'otwarcie';

  @override
  String get panelScheduleActionClose => 'zamknięcie';

  @override
  String get panelAutoCloseIdle => 'Bezczynna';

  @override
  String get panelAutoCloseDisabled => 'Wyłączona';

  @override
  String get panelAutoCloseOffline =>
      'Automatyzacja offline — reguła nie zadziała';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Zamknięcie za $seconds s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Zamykanie…';

  @override
  String get panelGridEmpty =>
      'Brak kafelków.\nDotknij „Dodaj kafelek”, aby umieścić tu swoje urządzenia.';

  @override
  String get panelsOffline => 'Offline — ostatnie wartości';

  @override
  String get connectionConnecting => 'Łączenie…';

  @override
  String get connectionReconnecting => 'Ponowne łączenie…';

  @override
  String get connectionShowingLastKnownValues => 'Ostatnio znane wartości';

  @override
  String get connectionFailed => 'Połączenie nieudane';

  @override
  String get connectionAutomaticRetry =>
      'Ponowne próby będą kontynuowane automatycznie';

  @override
  String get connectionReconnectNow => 'Połącz ponownie';

  @override
  String get settingsAbout => 'Informacje';

  @override
  String get settingsHelp => 'Pomoc i przewodnik';

  @override
  String get settingsVersion => 'Wersja';

  @override
  String get settingsRateApp => 'Oceń ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Podoba Ci się? Krótka opinia pomoże innym ją znaleźć.';

  @override
  String get settingsFeatureRequest => 'Zaproponuj funkcję';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Napisz, co ulepszyłoby ZigDash.';

  @override
  String get featureRequestGithub => 'Na GitHubie';

  @override
  String get featureRequestGithubSubtitle =>
      'Publicznie: inni mogą to zobaczyć i zagłosować.';

  @override
  String get featureRequestEmail => 'E-mailem';

  @override
  String get featureRequestEmailSubtitle => 'Prywatnie, prosto do autora.';

  @override
  String get featureRequestEmailSubject => 'ZigDash: prośba o funkcję';

  @override
  String get featureRequestEmailPrompt =>
      'Co ZigDash powinien robić i dlaczego?';

  @override
  String get settingsReportProblem => 'Zgłoś problem';

  @override
  String get settingsReportProblemSubtitle =>
      'Coś nie działa albo jest niejasne? Napisz.';

  @override
  String get reportProblemEmailSubject => 'ZigDash: zgłoszenie problemu';

  @override
  String get reportProblemEmailPrompt => 'Co się stało i co powinno się stać?';

  @override
  String get settingsBuyCoffee => 'Postaw mi kawę';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Darmowa i open source — napiwki pozwalają ją rozwijać.';

  @override
  String get a11yBackupMenu => 'Kopia zapasowa i przywracanie';

  @override
  String get a11ySelectColor => 'Wybierz kolor';

  @override
  String get a11ySelectIcon => 'Wybierz ikonę';

  @override
  String get a11yDeleteOption => 'Usuń opcję';

  @override
  String get a11yPanelOptions => 'Opcje kafelka';

  @override
  String get a11yMoreOptions => 'Więcej opcji';

  @override
  String get a11yRefresh => 'Odśwież';

  @override
  String get a11yDeleteConnection => 'Usuń połączenie';

  @override
  String get controlNotConnected =>
      'Brak połączenia — zmiana nie została wysłana';

  @override
  String get discoverFromDevice => 'Dodaj z urządzenia…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Automatycznie wykryj urządzenie Zigbee2MQTT';

  @override
  String get discoverTitle => 'Dodaj z urządzenia';

  @override
  String get discoverBaseTopic => 'Temat bazowy Zigbee2MQTT';

  @override
  String get discoverScanning => 'Wyszukiwanie urządzeń…';

  @override
  String get discoverNone => 'Nie znaleziono urządzeń.';

  @override
  String get discoverFailed =>
      'Nie znaleziono listy urządzeń. Sprawdź temat bazowy i czy broker jest połączony.';

  @override
  String get retry => 'Ponów';

  @override
  String get previewTitle => 'Podgląd na żywo';

  @override
  String previewWaiting(Object topic) {
    return 'Oczekiwanie na wiadomość w $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Wyodrębniono ($path): $value';
  }

  @override
  String get previewNoValue => '(brak wartości pod tą ścieżką)';

  @override
  String get connErrorTitle => 'Błąd połączenia';

  @override
  String get connErrorUnknown => 'Brak szczegółów błędu.';

  @override
  String get connTestButton => 'Testuj połączenie';

  @override
  String get connTestOk => 'Połączenie udane';

  @override
  String connTestFailed(Object error) {
    return 'Połączenie nieudane: $error';
  }

  @override
  String get devicesTitle => 'Urządzenia';

  @override
  String get devicesAddButton => 'Dodaj urządzenie';

  @override
  String get devicesPairingTitle => 'Parowanie — naciśnij przycisk urządzenia';

  @override
  String devicesPairingHint(int seconds) {
    return 'Wyszukiwanie nowych urządzeń… $seconds s';
  }

  @override
  String get devicesPairingStop => 'Zatrzymaj';

  @override
  String get devicesNone => 'Nie znaleziono urządzeń.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT nie przesłał listy urządzeń. Może się to zdarzyć po ponownym uruchomieniu brokera MQTT.';

  @override
  String get devicesRestartZ2m => 'Uruchom ponownie Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Zigbee2MQTT uruchamia się ponownie. Urządzenia powinny pojawić się za kilka sekund.';

  @override
  String get devicesBattery => 'Bateria';

  @override
  String get devicesLinkQuality => 'Łącze';

  @override
  String get devicesOnline => 'Online';

  @override
  String get devicesOffline => 'Offline';

  @override
  String devicesPaired(Object name) {
    return 'Gotowe: $name';
  }

  @override
  String get devicesPairedHint =>
      'Dodano do sieci. Aby umieścić je na dashboardzie, użyj „Dodaj z urządzenia…” na tym dashboardzie.';

  @override
  String get scenesTitle => 'Sceny';

  @override
  String get scenesNone =>
      'Brak scen. Ustaw urządzenia tak, jak lubisz, a potem zapisz je jako scenę.';

  @override
  String get scenesNewButton => 'Nowa scena';

  @override
  String scenesActivated(Object name) {
    return 'Aktywowano $name';
  }

  @override
  String get scenesActivateOffline =>
      'Brak połączenia — nie można aktywować sceny';

  @override
  String get sceneFormNewTitle => 'Nowa scena';

  @override
  String get sceneFormEditTitle => 'Edytuj scenę';

  @override
  String get sceneFormNameLabel => 'Nazwa sceny';

  @override
  String get sceneFormDevicesHeader => 'Urządzenia do zapisania';

  @override
  String get sceneFormCaptureHint =>
      'Zapisywany jest bieżący ustawialny stan każdego wybranego urządzenia (wł./wył., jasność, kolor, pozycja…). Wartości tylko do odczytu są pomijane.';

  @override
  String get sceneFormNoDevices =>
      'Nie znaleziono sterowalnych urządzeń. Upewnij się, że są sparowane, i dotknij odśwież.';

  @override
  String get sceneFormReadingState => 'Odczytywanie bieżącego stanu…';

  @override
  String get sceneCtrlPower => 'Zasilanie';

  @override
  String get sceneCtrlBrightness => 'Jasność';

  @override
  String get sceneCtrlPosition => 'Pozycja';

  @override
  String sceneFormSelectedCount(int count) {
    return 'Wybrano: $count';
  }

  @override
  String get sceneFormNoDevicesSelected =>
      'Wybierz co najmniej jedno urządzenie do zapisania.';

  @override
  String get sceneFormNothingCaptured =>
      'Z wybranych urządzeń nie zapisano żadnego ustawialnego stanu.';

  @override
  String get sceneDeleteTitle => 'Usunąć scenę?';

  @override
  String sceneDeleteMessage(Object name) {
    return '„$name” zostanie usunięta. Urządzenia zachowają bieżący stan.';
  }

  @override
  String get sceneEditAction => 'Edytuj';

  @override
  String get sceneDeleteAction => 'Usuń';

  @override
  String get sceneAddToDashboard => 'Dodaj do dashboardu';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Dodano do: $name';
  }

  @override
  String sceneActionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count urządzenia',
      many: '$count urządzeń',
      few: '$count urządzenia',
      one: '$count urządzenie',
    );
    return '$_temp0';
  }

  @override
  String get scenesAllShutters => 'Wszystkie rolety';

  @override
  String get sceneCloseAllShutters => 'Zamknij wszystkie rolety';

  @override
  String get sceneOpenAllShutters => 'Otwórz wszystkie rolety';

  @override
  String get sceneStopAllShutters => 'Zatrzymaj wszystkie rolety';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rolety',
      many: '$count rolet',
      few: '$count rolety',
      one: '1 roleta',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Które rolety…';

  @override
  String get sceneWhichShuttersHint =>
      'Uwzględnione są wszystkie rolety w tym domu. Odznacz te, które mają zostać pominięte, np. bramę garażową.';

  @override
  String get scenesYours => 'Twoje sceny';

  @override
  String get panelTypeScene => 'Scena';

  @override
  String get panelPickerSceneTitle => 'Przycisk sceny';

  @override
  String get panelPickerSceneSubtitle =>
      'Jedno dotknięcie aktywuje zapisaną scenę';

  @override
  String get panelSceneChoose => 'Scena';

  @override
  String get panelSceneMissing => 'Nie znaleziono sceny — wybierz ją ponownie';

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
  String get guidedConnectTitle => 'Skonfiguruj broker';

  @override
  String get guidedConnectIntro =>
      'Przetestujemy każdy etap połączenia i pokażemy Twoje urządzenia Zigbee.';

  @override
  String get guidedBaseTopic => 'Temat bazowy';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Testuj i połącz';

  @override
  String get guidedTesting => 'Testowanie połączenia…';

  @override
  String get stepResolve => 'Rozpoznawanie hosta';

  @override
  String get stepTcp => 'Połączenie TCP';

  @override
  String get stepConnack => 'Uzgadnianie MQTT';

  @override
  String get stepAuth => 'Uwierzytelnianie';

  @override
  String get stepDevices => 'Szukanie urządzeń';

  @override
  String get diagResolveFail =>
      'Nie udało się rozpoznać nazwy hosta. Sprawdź wpisany adres.';

  @override
  String get diagResolveTimeout =>
      'Upłynął limit czasu rozpoznawania hosta. Sprawdź adres i sieć.';

  @override
  String get diagTcpFail =>
      'Broker nie przyjął połączenia. Sprawdź, czy Twój broker MQTT (zwykle Mosquitto) działa i przyjmuje połączenia z innych urządzeń oraz czy adres i port (zwykle 1883) są prawidłowe.';

  @override
  String get diagTcpTimeout =>
      'Upłynął limit czasu łączenia z brokerem. Może być offline lub nieosiągalny.';

  @override
  String get diagConnackFail =>
      'Broker nie zakończył uzgadniania MQTT. Upewnij się, że to broker MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'Broker nie odpowiedział na logowanie na czas. Home Assistant może potrzebować kilku sekund na sprawdzenie, spróbuj ponownie.';

  @override
  String get diagAuthRejected =>
      'Broker odrzucił nazwę użytkownika lub hasło. Sprawdź dane logowania.';

  @override
  String get diagAuthRefused =>
      'Broker odmówił połączenia. Sprawdź ustawienia połączenia.';

  @override
  String get diagResolveLocalName =>
      'Telefon nie znalazł tej nazwy. Android często nie rozpoznaje nazw kończących się na .local, więc wpisz zamiast niej adres IP (Home Assistant pokazuje go w Ustawienia › System › Sieć).';

  @override
  String get diagTcpHaNoBroker =>
      'To Twój Home Assistant, ale nie działa na nim żaden broker MQTT. Zainstaluj i uruchom aplikację Mosquitto broker (Ustawienia › Aplikacje), a potem spróbuj ponownie.';

  @override
  String get diagTcpSmlightClosed =>
      'To jest Twój hub SMLIGHT, ale jego broker MQTT nie przyjmuje połączeń z innych urządzeń. Na stronie internetowej huba otwórz Settings › MQTT, włącz Allow External, zapisz i spróbuj ponownie.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Pod tym adresem działa Zigbee2MQTT, ale ze swoim brokerem łączy się pod inną nazwą (zobacz Zigbee2MQTT › Settings › MQTT › Server). Jeśli to inna maszyna, wpisz jej adres, zwykle z portem 1883. Jeśli to kontener na tej maszynie, opublikuj jego port (ports: \"1883:1883\") i pozwól mu nasłuchiwać w sieci, a potem spróbuj ponownie.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Pod tym adresem działa Zigbee2MQTT, ale jego broker MQTT nie przyjmuje połączeń z innych urządzeń. Mosquitto nasłuchuje tylko na własnym komputerze, dopóki nie dodasz do mosquitto.conf linii „listener 1883” i „allow_anonymous true” (albo nie ustawisz hasła). Uruchom ponownie Mosquitto i spróbuj jeszcze raz.';

  @override
  String get diagAuthRejectedHa =>
      'Broker Home Assistant odrzucił to logowanie. Użyj nazwy i hasła użytkownika Home Assistant (Ustawienia › Osoby › Użytkownicy); najlepiej osobnego użytkownika tylko do MQTT.';

  @override
  String foundDevices(int count) {
    return 'Znalezione urządzenia: $count';
  }

  @override
  String get foundDevicesHint =>
      'Twoje urządzenia Zigbee są widoczne. Przejdź dalej, aby zbudować dashboard.';

  @override
  String get noDevicesTitle => 'Połączono — nie znaleziono jeszcze urządzeń';

  @override
  String get noDevicesHint =>
      'ZigDash widzi Twój broker, ale nie znalazł jeszcze urządzeń Zigbee. Możesz rozpocząć parowanie, aby je dodać.';

  @override
  String get startPairing => 'Rozpocznij parowanie';

  @override
  String get pairingEnabled =>
      'Parowanie włączone. Naciśnij przycisk parowania na urządzeniu, aby je dołączyć.';

  @override
  String get continueToDashboard => 'Przejdź do dashboardu';

  @override
  String get guidedBackToForm => 'Edytuj ustawienia';

  @override
  String get guidedStuckTitle => 'Utknąłeś? Zapytaj człowieka';

  @override
  String get guidedStuckBody =>
      'Dwie próby bez połączenia. Napisz, jaki masz hub i co wpisałeś, a pomożemy go znaleźć.';

  @override
  String get guidedStuckTelegram => 'Zapytaj na Telegramie';

  @override
  String get guidedStuckHelp => 'Porady i e-mail';

  @override
  String ladderTriedHint(Object count) {
    return 'Sprawdzone adresy: $count';
  }

  @override
  String get guidedSaveFailed =>
      'Nie udało się zapisać połączenia. Spróbuj ponownie.';

  @override
  String get setupWelcomeTitle => 'Witaj w ZigDash';

  @override
  String get setupWelcomeHeadline => 'Twój dom Zigbee w telefonie';

  @override
  String get setupWelcomeBody =>
      'Wystarczy mały hub z Zigbee2MQTT: hub SMLIGHT, Raspberry Pi albo dowolny komputer z Linuksem. Home Assistant nie jest potrzebny, a jeśli go masz, ZigDash też z nim działa. Wszystko zostaje lokalnie, bez chmury.';

  @override
  String get setupFindMySetup => 'Znajdź moją instalację';

  @override
  String get setupErrPageTitle => 'Strona Zigbee2MQTT nie odpowiedziała';

  @override
  String get setupErrPageBody =>
      'Pod tym adresem nie odpowiedziała żadna strona Zigbee2MQTT. Otwórz go w przeglądarce tego telefonu, by sprawdzić, i skopiuj adres dokładnie (z portem, często 8080). Jeśli strona prosi o token, podaj zamiast tego dane brokera.';

  @override
  String get setupErrPageAction => 'Spróbuj ponownie';

  @override
  String get setupLookWider => 'Szukaj w całej sieci';

  @override
  String get setupAsk => 'Co obsługuje Twoje Zigbee?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'Na Raspberry Pi, serwerze lub w Dockerze';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'Z aplikacją Zigbee2MQTT lub ZHA';

  @override
  String get setupAskSmlight => 'SMLIGHT';

  @override
  String get setupAskSmlightSub => 'SMHUB albo adapter SLZB';

  @override
  String get setupAskSmlightWhich => 'Jakie urządzenie SMLIGHT masz?';

  @override
  String get setupAskSmhub => 'SMHUB';

  @override
  String get setupAskSmhubSub => 'Zigbee2MQTT działa na samym hubie';

  @override
  String get setupAskSlzb => 'Adapter SLZB';

  @override
  String get setupAskSlzbSub => 'SLZB-06, SLZB-MR i inne: tylko radio Zigbee';

  @override
  String get setupSlzbWhere =>
      'Twój SLZB to radio Zigbee. Zigbee2MQTT działa na innym urządzeniu: na którym?';

  @override
  String get setupRunningAsk => 'Czy Zigbee2MQTT już działa?';

  @override
  String get setupRunningYes => 'Tak, działa';

  @override
  String get setupRunningNotYet => 'Jeszcze nie';

  @override
  String get setupRunningNotSure => 'Nie wiem';

  @override
  String get setupRunningYesNote =>
      'W takim razie ten telefon nie widzi go stąd. Najczęściej telefon jest w sieci dla gości lub w innej sieci Wi-Fi albo broker przyjmuje połączenia tylko z własnego komputera (Mosquitto 2 tak robi, dopóki w konfiguracji nie ma \"listener 1883\"). Wpisz jego adres poniżej, aby go sprawdzić.';

  @override
  String get setupRunningNotYetNote =>
      'ZigDash łączy się z Zigbee2MQTT, które już działa. Zobacz, czego potrzebujesz na start, a w międzyczasie wypróbuj demo.';

  @override
  String setupRunningNotSureNote(String button) {
    return 'Zigbee2MQTT ma własną stronę internetową, na której parujesz urządzenia Zigbee. Jeśli ją otwierałeś, działa: stuknij „$button” poniżej. Jeśli nigdy jej nie widziałeś, nie jest jeszcze skonfigurowane.';
  }

  @override
  String get setupRunningWhatToGet => 'Czego potrzebujesz';

  @override
  String get setupAskNothing => 'Jeszcze nic?';

  @override
  String get setupAskHaWhich => 'Jak Twój Home Assistant obsługuje Zigbee?';

  @override
  String get setupAskHaZ2m => 'Aplikacja Zigbee2MQTT';

  @override
  String get setupAskHaZ2mSub => 'Zaloguj się przez Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, wbudowane Zigbee Home Assistanta';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, bez Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Połącz z moją stroną Zigbee2MQTT';

  @override
  String get setupManualEntryAdvanced => 'Dane brokera (zaawansowane)';

  @override
  String get z2mPageTitle => 'Twoja strona Zigbee2MQTT';

  @override
  String get z2mPageBody =>
      'Adres w przeglądarce, gdy strona Zigbee2MQTT jest otwarta – ta, na której parujesz urządzenia. Nie trzeba nazwy użytkownika ani hasła MQTT.';

  @override
  String get z2mPageLabel => 'Adres strony';

  @override
  String get z2mPageConnect => 'Połącz';

  @override
  String z2mPageFoundName(String host, String ip) {
    return 'Znaleziono $host pod $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Nic nie odpowiedziało dla $host w tej sieci';
  }

  @override
  String get engineNeedsBrokerTitle =>
      'Automatyzacje potrzebują Twojego brokera MQTT';

  @override
  String get engineNeedsBrokerBody =>
      'Ten dom łączy się przez stronę Zigbee2MQTT, co wystarcza dla pulpitów. Automatyzacje, alerty i historia działają w ZigDash Engine na Twoim hubie, który komunikuje się przez broker MQTT. Podaj jego dane raz, a od tej pory ZigDash będzie łączyć się przez broker.';

  @override
  String get engineNeedsBrokerButton => 'Podaj dane brokera';

  @override
  String get connFromPageNote =>
      'Ten dom łączy się przez stronę Zigbee2MQTT. Podaj swój broker MQTT (zwykle to samo urządzenie, port 1883), aby włączyć automatyzacje, alerty i historię. Po zapisaniu ZigDash łączy się przez broker.';

  @override
  String get setupManualEntry => 'Wpisz dane ręcznie';

  @override
  String get setupScanningTitle => 'Szukanie połączenia…';

  @override
  String get setupScanningHint =>
      'To urządzenie musi być w tej samej sieci lokalnej co host Zigbee2MQTT.';

  @override
  String get setupCandidateFound => 'Znaleziono możliwe połączenie';

  @override
  String get setupNoCandidatesTitle => 'Nie znaleziono połączenia';

  @override
  String get setupNoCandidatesBody => 'Gdzie działa Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: sprawdź, czy aplikacje Mosquitto broker i Zigbee2MQTT są zainstalowane i działają (Ustawienia › Aplikacje).';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: sprawdź, czy broker (np. Mosquitto) i usługa Zigbee2MQTT działają oraz czy port 1883 jest osiągalny.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: otwórz interfejs webowy urządzenia, przejdź do Settings > MQTT, włącz Allow External, aby telefon mógł połączyć się z brokerem, i sprawdź, czy Zigbee2MQTT jest uruchomione.';

  @override
  String get setupTryAgain => 'Spróbuj ponownie';

  @override
  String get reminderButton => 'Przypomnij mi jutro';

  @override
  String get reminderSet => 'Przypomnimy Ci jutro, na tym telefonie.';

  @override
  String get reminderNoPermission =>
      'Powiadomienia ZigDash są wyłączone, więc nie będzie przypomnienia. Możesz je włączyć w ustawieniach Androida.';

  @override
  String get reminderChannel => 'Przypomnienie o konfiguracji';

  @override
  String get reminderTitle => 'Dokończ konfigurację ZigDash';

  @override
  String get reminderBody =>
      'Jesteś w domu w swojej sieci Wi-Fi? Dotknij, aby spróbować ponownie: to zajmie około minuty.';

  @override
  String get setupWelcomeNoZ2m => 'Nie masz jeszcze Zigbee2MQTT?';

  @override
  String get setupWelcomeDemo => 'Wypróbuj dom demo';

  @override
  String get setupWelcomeHubs => 'Jaki hub wybrać';

  @override
  String get haConnectTitle => 'Połącz przez Home Assistant';

  @override
  String get haConnectIntro =>
      'Twój telefon nie dociera do brokera, ale dociera do Home Assistant. Zaloguj się raz, a ZigDash będzie rozmawiać z Zigbee2MQTT przez Home Assistant: w domu i poza nim, bez ustawień brokera.';

  @override
  String get haConnectAddressHelp =>
      'Adres, pod którym otwierasz Home Assistant: 192.168.1.20:8123 albo adres zdalny, np. Twój adres Nabu Casa lub Cloudflare';

  @override
  String get haConnectSignInHelp =>
      'Własne logowanie Home Assistant otwiera się w przeglądarce. ZigDash nigdy nie widzi Twojego hasła.';

  @override
  String get haConnectKeeps =>
      'ZigDash zachowuje to logowanie na Twoim telefonie i działa w Home Assistant jako Ty, tylko dla MQTT. Zakończ to w dowolnej chwili w Home Assistant, w Profil › Bezpieczeństwo.';

  @override
  String get haConnectTokenHelp =>
      'W Home Assistant otwórz swój profil, potem Bezpieczeństwo › Długoterminowe tokeny dostępu › Utwórz token. Skopiuj go i wklej tutaj. ZigDash zachowuje go na tym telefonie do łączenia; usuń go w Home Assistant, gdy zechcesz to zakończyć.';

  @override
  String get haConnectWithToken => 'Połącz z tokenem';

  @override
  String get haConnectChecking => 'Sprawdzanie Home Assistant…';

  @override
  String get setupStillChecking =>
      'Nadal sprawdzam. Może to potrwać do 30 sekund.';

  @override
  String get aiHelpTitle => 'Utknąłeś? Zapytaj swojego asystenta AI';

  @override
  String get aiHelpBody =>
      'ZigDash spisze, co znalazł, dla ChatGPT, Claude, Gemini lub innej aplikacji AI, bez haseł i adresów. Zobaczysz to przed udostępnieniem.';

  @override
  String get aiHelpButton => 'Zapytaj AI';

  @override
  String get aiHelpPreviewTitle => 'Co zostanie udostępnione';

  @override
  String get aiHelpShare => 'Udostępnij do aplikacji AI';

  @override
  String get aiHelpCopied => 'Skopiowano. Wklej to do dowolnego czatu AI.';

  @override
  String get haConnectWhereAddress =>
      'Nie wiesz, jaki to adres? W aplikacji Home Assistant otwórz Ustawienia › Aplikacja towarzysząca i stuknij swój serwer: adres jest tam. Na komputerze to adres, który przeglądarka pokazuje przy otwartym Home Assistant.';

  @override
  String get haFindLooking => 'Szukam Home Assistant w tej sieci…';

  @override
  String get haFindSeveral =>
      'Znaleziono więcej niż jeden Home Assistant. Dotknij tego, którego chcesz użyć:';

  @override
  String get haFindNone =>
      'Ten telefon nie widzi Home Assistanta w tej sieci Wi-Fi. Użyj adresu, który otwiera Twoja aplikacja Home Assistant: często zdalnego, np. https://abcd1234.ui.nabu.casa lub https://mojdom.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Ten adres jest w innej sieci niż ten telefon, który jest w $network. Użyj adresu, który otwiera Twoja aplikacja Home Assistant, często zdalnego, albo połącz telefon z siecią, w której jest Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Ten telefon nie znalazł tej nazwy: Android często nie otwiera nazw .local. Wpisz adres IP Home Assistanta (np. 192.168.1.20:8123) albo jego adres zdalny.';

  @override
  String get haConnectRemoteUnreachable =>
      'Nic nie odpowiedziało pod tym adresem zdalnym. Otwórz go w przeglądarce tego telefonu, aby sprawdzić, czy działa, i skopiuj go dokładnie tak, jak pokazuje go aplikacja Home Assistant.';

  @override
  String get setupNoWifiHa => 'Używasz Home Assistant? Zaloguj się';

  @override
  String get haConnectNotAdmin =>
      'Twój użytkownik Home Assistant nie jest administratorem. ZigDash potrzebuje go do MQTT w Home Assistant. Zaloguj się jako administrator albo wklej token utworzony przez administratora.';

  @override
  String get haConnectNoMqtt =>
      'Ten Home Assistant nie ma integracji MQTT. Zigbee2MQTT też jej potrzebuje: w Home Assistancie dodaj aplikację Mosquitto broker (Ustawienia › Aplikacje) i integrację MQTT, a potem spróbuj ponownie.';

  @override
  String get haConnectSignInFailed =>
      'Logowanie nie zostało ukończone. Spróbuj ponownie albo użyj długoterminowego tokenu.';

  @override
  String get setupHaShortcut =>
      'Zigbee2MQTT działa w Home Assistant? Pomiń brokera i jego login: zaloguj się kontem administratora Home Assistant. Działa z każdej sieci.';

  @override
  String get haConnectButton => 'Połącz przez Home Assistant';

  @override
  String get haConnectManualLink =>
      'Używasz Home Assistant? Połącz się przez niego';

  @override
  String get haConnectEmptyNote =>
      'Ten telefon nie dociera do brokera? Home Assistant może przenieść połączenie za Ciebie.';

  @override
  String get haHomeConnected => 'Połączono przez Home Assistant';

  @override
  String get haHomeChange =>
      'Jeśli logowanie przestanie działać, na nowym telefonie albo po usunięciu tokenu w Home Assistant, zaloguj się ponownie tutaj. Możesz je też zakończyć w Home Assistant, w Profil › Bezpieczeństwo.';

  @override
  String get haHomeSignInAgain => 'Zaloguj się ponownie';

  @override
  String get haHomeRemote => 'Zdalny adres Home Assistant (opcjonalnie)';

  @override
  String get setupAuthTitle => 'Ten broker wymaga logowania';

  @override
  String setupAuthBody(Object host) {
    return 'Wpisz nazwę użytkownika i hasło MQTT dla $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Nazwa użytkownika lub hasło zostały odrzucone. Sprawdź je i spróbuj ponownie.';

  @override
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT już loguje się do tego brokera: jego strona WWW pokazuje nazwę użytkownika w Ustawienia › MQTT. Użyj tego użytkownika i jego hasła.';

  @override
  String get setupAuthWhich => 'To login MQTT, a nie hasło do strony WWW huba.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: użyj użytkownika Home Assistanta. Większość osób tworzy jednego tylko dla MQTT w Ustawienia › Osoby › Użytkownicy, a aplikacja Mosquitto broker go akceptuje.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi lub Docker: użytkownik i hasło z pliku haseł Mosquitto, te same co w configuration.yaml Zigbee2MQTT w sekcji mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: login widoczny na stronie WWW huba w Settings › MQTT. Albo włącz tam Allow Anonymous i zapisz: wtedy login nie jest potrzebny.';

  @override
  String get setupVerifyingTitle => 'Sprawdzanie połączenia…';

  @override
  String get setupReviewTitle => 'Twoje urządzenia';

  @override
  String setupReviewSubtitle(int count) {
    return 'Znalezione urządzenia: $count. Wybierz, co trafi na pierwszy dashboard.';
  }

  @override
  String get setupReviewLastStep =>
      'Ostatni krok: zaznacz urządzenia, które chcesz, a potem stuknij Utwórz pulpit na dole.';

  @override
  String get setupLeaveTitle => 'Utworzyć pulpit?';

  @override
  String get setupLeaveBody =>
      'Twoje urządzenia są znalezione. Utwórz pulpit teraz albo zacznij konfigurację od nowa i strać tę listę.';

  @override
  String get setupStartOver => 'Zacznij od nowa';

  @override
  String setupCreateWithCount(Object count) {
    return 'Utwórz dashboard (urządzenia: $count)';
  }

  @override
  String get setupReviewNoneSelected =>
      'Nic nie jest jeszcze zaznaczone. Zaznacz urządzenia, które chcesz mieć na dashboardzie, albo utwórz go pusty i dodaj kafelki później.';

  @override
  String get setupCreateEmpty => 'Utwórz pusty dashboard';

  @override
  String get setupGroupOther => 'Inne urządzenia';

  @override
  String get setupGroupUnsupported => 'Nieobsługiwane urządzenia';

  @override
  String get setupCreatingTitle => 'Tworzenie dashboardu…';

  @override
  String get setupReadyTitle => 'Dashboard jest gotowy';

  @override
  String setupReadyBody(Object count) {
    return 'Utworzone elementy sterujące: $count.';
  }

  @override
  String get setupOpenDashboard => 'Otwórz dashboard';

  @override
  String get setupErrUnreachableTitle => 'Ten adres jest nieosiągalny';

  @override
  String get setupErrUnreachableBody =>
      'To urządzenie i host Zigbee2MQTT nie mogą się połączyć. Sprawdź, czy oba są w tej samej sieci lokalnej.';

  @override
  String get setupErrUnreachableAction => 'Spróbuj ponownie';

  @override
  String get setupErrPortClosedTitle => 'Nic nie odpowiada na tym porcie';

  @override
  String get setupErrPortClosedBody =>
      'Host jest osiągalny, ale żaden broker MQTT nie odpowiedział. Sprawdź, czy broker działa i czy port jest poprawny.';

  @override
  String get setupErrPortClosedAction => 'Spróbuj ponownie';

  @override
  String get setupErrAuthRequiredTitle => 'Wymagane logowanie';

  @override
  String get setupErrAuthRequiredBody =>
      'Ten broker wymaga nazwy użytkownika i hasła.';

  @override
  String get setupErrAuthRequiredAction => 'Zaloguj się';

  @override
  String get setupErrAuthRejectedTitle => 'Logowanie odrzucone';

  @override
  String get setupErrAuthRejectedBody => 'Broker odrzucił te dane logowania.';

  @override
  String get setupErrAuthRejectedAction => 'Spróbuj ponownie';

  @override
  String get setupErrNotZ2mTitle => 'Brak Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'Odpowiada tu broker MQTT, ale nie znaleziono tematów Zigbee2MQTT. Może to być inny broker.';

  @override
  String get setupErrNotZ2mAction => 'Wybierz inny';

  @override
  String get setupErrNoDevicesTitle => 'Nie odebrano urządzeń';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT działa, ale podczas sprawdzania nie opublikowano żadnych urządzeń. Najpierw sparuj urządzenia w Zigbee2MQTT.';

  @override
  String get setupErrNoDevicesAction => 'Sprawdź ponownie';

  @override
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT nie wysłał listy urządzeń';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT odpowiada, ale jego lista urządzeń nie dotarła. Zwykle dzieje się tak po restarcie brokera MQTT: Zigbee2MQTT przed wersją 2.14.2 wysyła listę ponownie dopiero po własnym restarcie. Zrestartuj Zigbee2MQTT (albo go zaktualizuj) i spróbuj ponownie.';

  @override
  String get setupErrListMissingAction => 'Spróbuj ponownie';

  @override
  String get setupErrHaNoZ2mTitle =>
      'W tym Home Assistancie nie ma Zigbee2MQTT';

  @override
  String get setupErrHaNoZ2mBody =>
      'Jesteś zalogowany do Home Assistanta, ale Zigbee2MQTT nic nie wysyła przez swój MQTT. Jeśli Twoje urządzenia Zigbee są w ZHA (wbudowanym Zigbee Home Assistanta), ZigDash ich nie widzi: działa z Zigbee2MQTT. Jeśli używasz aplikacji Zigbee2MQTT, otwórz ją w Ustawienia › Aplikacje, sprawdź, czy jest uruchomiona, i spróbuj ponownie.';

  @override
  String get setupErrHaNoZ2mAction => 'Spróbuj ponownie';

  @override
  String get setupErrScanFailedTitle => 'Brak sieci lokalnej';

  @override
  String get setupErrScanFailedBody =>
      'Nie udało się ustalić sieci lokalnej tego urządzenia. Połącz się z Wi-Fi i spróbuj ponownie.';

  @override
  String get setupErrScanFailedAction => 'Spróbuj ponownie';

  @override
  String get setupNoWifiTitle => 'Telefon nie jest w sieci Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'Używa danych komórkowych, więc nie widzi urządzeń w domu. Włącz Wi-Fi i połącz się z siecią domową: konfiguracja ruszy ponownie sama.';

  @override
  String get setupNoWifiOffline =>
      'Telefon nie ma połączenia z siecią. Włącz Wi-Fi i połącz się z siecią domową: konfiguracja ruszy ponownie sama.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash nie może znaleźć adresu Wi-Fi telefonu. Sprawdź, czy Wi-Fi jest włączone i połączone z siecią domową: konfiguracja ruszy ponownie sama. Masz VPN albo jesteś poza domem? Wpisz dane ręcznie.';

  @override
  String get setupOpenWifiSettings => 'Otwórz ustawienia Wi-Fi';

  @override
  String get setupWaitingForWifi => 'Czekam na Wi-Fi…';

  @override
  String get setupErrSaveFailedTitle => 'Nie udało się zapisać';

  @override
  String get setupErrSaveFailedBody =>
      'Zapisywanie konfiguracji nie powiodło się. Nic nie zostało zapisane połowicznie — możesz bezpiecznie spróbować ponownie.';

  @override
  String get setupErrSaveFailedAction => 'Spróbuj ponownie';

  @override
  String get setupErrUnknownTitle => 'Coś poszło nie tak';

  @override
  String get setupErrUnknownBody => 'Wystąpił nieoczekiwany błąd.';

  @override
  String get setupErrUnknownAction => 'Spróbuj ponownie';

  @override
  String get setupErrLoginNoAnswerTitle =>
      'Broker nie odpowiedział na logowanie';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Broker został znaleziony, ale nie odpowiedział na czas na nazwę użytkownika i hasło. Aplikacja Mosquitto broker w Home Assistancie sprawdza logowania w Home Assistancie, co na Raspberry Pi może potrwać kilka sekund. Spróbuj ponownie i sprawdź, czy ten użytkownik istnieje w Home Assistancie. Na hubie SMLIGHT włącz zamiast tego Allow Anonymous w Settings › MQTT, a login nie będzie potrzebny.';

  @override
  String get setupErrLoginNoAnswerAction => 'Spróbuj ponownie';

  @override
  String get setupNoZ2mTitle =>
      'Broker działa, ale Zigbee2MQTT nic tu nie publikuje';

  @override
  String setupNoZ2mBody(String base) {
    return 'Nasłuchiwaliśmy na $base/bridge i nic nie odebraliśmy.';
  }

  @override
  String get setupBaseTopicQuestion => 'Używasz innego tematu bazowego?';

  @override
  String get setupGuidesTitle => 'Skonfiguruj Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'W międzyczasie wypróbuj demo';

  @override
  String get setupPlatformQuestion =>
      'W trakcie szukania: gdzie działa Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => 'Gdzie działa Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Wybierz połączenie';

  @override
  String get setupScanDoneHint =>
      'Odpowiedział więcej niż jeden broker. Wybierz ten, którego używa Zigbee2MQTT.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'SMHUB';

  @override
  String get setupPlatformPi => 'Raspberry Pi lub Docker';

  @override
  String get setupPlatformZha => 'ZHA, bez Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash pokazuje urządzenia z Zigbee2MQTT, więc nie widzi urządzeń w ZHA, wbudowanym Zigbee Home Assistanta. Możesz wypróbować dom demo, aby zobaczyć, jak działa ZigDash.';

  @override
  String get setupPlatformNotSure => 'Nie wiem';

  @override
  String setupScanProgress(int checked, int total) {
    return 'Sprawdzono $checked z $total adresów';
  }

  @override
  String get setupScanHintHa => 'Szukam Home Assistant i jego brokera MQTT…';

  @override
  String get setupScanHintSmlight => 'Szukam twojego SMHUB…';

  @override
  String get setupScanHintPi => 'Szukam brokera MQTT w Twojej sieci…';

  @override
  String setupHubSeenHa(String host) {
    return 'Znaleziono Home Assistant pod adresem $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Znaleziono Zigbee2MQTT pod adresem $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Znaleziono Twój hub SMLIGHT pod adresem $host';
  }

  @override
  String get setupHubSeenHint => 'Wciąż szukam jego brokera MQTT…';

  @override
  String get setupNoBrokerHaTitle =>
      'Znaleziono Home Assistant, ale brak brokera MQTT';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant jest pod adresem $host, ale nic nie odpowiada na porcie MQTT 1883. W Home Assistancie otwórz Ustawienia › Aplikacje, zainstaluj i uruchom aplikację Mosquitto broker, a potem spróbuj ponownie.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Używasz wbudowanego Zigbee w Home Assistant (ZHA) zamiast Zigbee2MQTT? ZigDash działa tylko z Zigbee2MQTT, więc nie widzi urządzeń ZHA. Demo pokazuje, co byś dostał.';

  @override
  String get setupNoBrokerHaDocker =>
      'Brak Aplikacji w Ustawieniach Twojego Home Assistanta? To znaczy, że działa w Dockerze (Home Assistant Container), który nie ma aplikacji: Mosquitto działa we własnym kontenerze. Wpisz poniżej adres komputera, na którym działa.';

  @override
  String get setupVpnHint =>
      'Włączony jest VPN, który może ukryć sieć domową przed skanowaniem. Jeśli jesteś w domu, wyłącz VPN i dotknij Spróbuj ponownie. Albo zostaw go włączonego i zezwól w ustawieniach aplikacji VPN na dostęp do sieci lokalnej (LAN).';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Znaleziono Zigbee2MQTT, ale jego broker jest nieosiągalny';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT jest pod adresem $host, ale jego broker MQTT nie przyjmuje połączeń z Twojego telefonu. Mosquitto 2 nasłuchuje tylko na samym hubie, dopóki w konfiguracji nie ma \'listener 1883\' i \'allow_anonymous true\' (lub loginu). Uruchom go ponownie i spróbuj jeszcze raz.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Znaleziono hub SMLIGHT, ale MQTT jest wyłączone';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Twój hub jest pod adresem $host, ale jego broker MQTT jest nieosiągalny. W interfejsie webowym huba otwórz Settings › MQTT, włącz Allow External i sprawdź, czy Zigbee2MQTT działa. Potem spróbuj ponownie.';
  }

  @override
  String get setupZ2mAsking => 'Pytamy Zigbee2MQTT, gdzie jest jego broker…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Twój broker przyjmuje połączenia tylko z własnego komputera';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT używa $server, a z twojego telefonu nic tam nie odpowiada. Mosquitto 2 tak działa domyślnie. Dodaj te dwie linie do mosquitto.conf, uruchom ponownie Mosquitto i spróbuj jeszcze raz:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Wolisz logowanie zamiast otwartego dostępu? Użyj password_file zamiast allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT łączy się ze swoim brokerem pod nazwą, której Twój telefon nie może użyć';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT używa $server. „$name” to nazwa, którą zna tylko maszyna Zigbee2MQTT, usługa Dockera lub nazwa hosta. Wpisz zamiast niej adres IP maszyny z brokerem i port $port. Jeśli broker działa w kontenerze, jego port musi być też opublikowany na maszynie (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'Strona Zigbee2MQTT jest chroniona tokenem, więc aplikacja nie mogła odczytać, gdzie jest jej broker. Wpisz adres brokera z ustawień Zigbee2MQTT › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT używa brokera pod adresem $server, ale nie odpowiedział twojemu telefonowi. Sprawdź, czy broker działa i czy telefon jest w tej samej sieci.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Połącz z $host';
  }

  @override
  String get setupNotFoundHa =>
      'Nie znaleziono Home Assistant w tej sieci. Sprawdź, czy telefon jest w tej samej sieci Wi-Fi co Home Assistant (nie w sieci dla gości), i spróbuj ponownie. Jeśli znasz adres, wpisz go poniżej.';

  @override
  String get setupNotFoundSmlight =>
      'Nie znaleziono huba SMLIGHT w tej sieci. Sprawdź, czy hub jest włączony i czy telefon jest w tej samej sieci Wi-Fi, i spróbuj ponownie. Jeśli znasz adres, wpisz go poniżej.';

  @override
  String get setupNotFoundPi =>
      'Nie znaleziono brokera MQTT w tej sieci. Sprawdź, czy Mosquitto działa i nasłuchuje w sieci (port 1883) oraz czy telefon jest w tej samej sieci Wi-Fi. Potem spróbuj ponownie.';

  @override
  String get setupAddressQuestionHa => 'Gdzie otwierasz Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'Jaki jest adres Twojego huba SMLIGHT?';

  @override
  String get setupAddressWhereSmlight =>
      'Otwórz stronę swojego huba: smhub.local, a na pierwszych hubach smhub.local:3000. Na Dashboard ramka Network pokazuje adres obok IPv4. Wpisz go tutaj. Jeśli strona się nie otwiera, aplikacja routera pokazuje hub jako SMHUB, razem z jego IP.';

  @override
  String get setupAddressSlzbSmlight =>
      'SLZB-06, MR lub UltimaX to tylko radio Zigbee i nie ma brokera. Wpisz zamiast tego adres komputera, na którym działają Zigbee2MQTT i Mosquitto.';

  @override
  String get setupAddressQuestionPi =>
      'Jaki jest adres maszyny, na której działa Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      'Jaki jest adres Twojego huba lub maszyny, na której działa Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'Adres taki jak 192.168.1.20, nazwa lub link z przeglądarki';

  @override
  String get setupAddressCheck => 'Sprawdź ten adres';

  @override
  String setupAddressNothing(String host) {
    return 'Nic nie odpowiedziało pod $host. Sprawdź adres i czy telefon jest w tej samej sieci Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return 'Nie udało się rozwiązać $host. Nazwy kończące się na .local często nie działają w Androidzie; spróbuj adresu IP. Home Assistant pokazuje go w Ustawienia › System › Sieć.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return 'Nie można znaleźć $host z tego telefonu; Android często nie rozwiązuje nazw .local. Stuknij $button powyżej i użyj adresu, pod którym otwierasz Home Assistant w przeglądarce, albo wpisz tutaj jego adres IP. Home Assistant pokazuje go w Ustawienia › System › Sieć.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host nie jest w Twojej sieci domowej. Użyj adresu, który działa w Twoim Wi-Fi, a nie zdalnego linku jak Nabu Casa czy DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Najpierw wpisz adres.';

  @override
  String get setupChoicesTitle => 'Co z tego pasuje do Ciebie?';

  @override
  String get setupChoiceNoHub => 'Nie mam jeszcze huba';

  @override
  String get setupChoiceNoHubSub => 'Zobacz małe huby z Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'Używam Home Assistant';

  @override
  String get setupChoiceHaSub => 'Szukaj pod homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash łączy się z brokerem MQTT Home Assistanta, aplikacją Mosquitto broker w Ustawienia › Aplikacje, i Zigbee2MQTT też musi go używać. Jeśli homeassistant.local nie zostanie znaleziony, wpisz poniżej adres IP Home Assistanta. Znajdziesz go w Ustawienia › System › Sieć.';

  @override
  String get setupChoiceOther => 'Mój hub jest w innej sieci';

  @override
  String get setupChoiceOtherSub => 'Sieć Wi-Fi dla gości lub drugi router';

  @override
  String get setupChoiceOtherNote =>
      'Telefon musi mieć dostęp do huba. Sieć Wi-Fi dla gości albo drugi router z własnym Wi-Fi je rozdziela. Połącz się z Wi-Fi, w którym jest hub, i dotknij Spróbuj ponownie. Możesz też wpisać poniżej adres IP huba albo spróbować jednej z tych typowych nazw:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Twój telefon ma $ip, więc hub zwykle zaczyna się od $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Używasz Home Assistant? Host to adres, pod którym otwierasz Home Assistant, port 1883.';

  @override
  String get demoBannerText => 'Jesteś w trybie demo';

  @override
  String get demoBannerAction => 'Połącz swój dom';

  @override
  String get deviceOn => 'Wł.';

  @override
  String get deviceOff => 'Wył.';

  @override
  String get deviceOpen => 'Otwarte';

  @override
  String get deviceClosed => 'Zamknięte';

  @override
  String get deviceMotion => 'Ruch';

  @override
  String get deviceClear => 'Brak ruchu';

  @override
  String get deviceLeakDetected => 'Wykryto zalanie';

  @override
  String get deviceSmokeDetected => 'Wykryto dym';

  @override
  String get deviceGasDetected => 'Wykryto gaz';

  @override
  String get deviceWaiting => 'Oczekiwanie na pierwszy raport';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on wł. · $off wył.';
  }

  @override
  String get deviceBrightness => 'Jasność';

  @override
  String get deviceWhite => 'Biel';

  @override
  String get deviceColor => 'Kolor';

  @override
  String get deviceHue => 'Odcień';

  @override
  String get devicePosition => 'Pozycja';

  @override
  String get deviceControls => 'Sterowanie';

  @override
  String deviceBattery(int percent) {
    return 'Bateria $percent%';
  }

  @override
  String get deviceToggle => 'Włącz lub wyłącz';

  @override
  String get deviceMore => 'Więcej';

  @override
  String get sectionLights => 'Oświetlenie';

  @override
  String get sectionSwitchesCovers => 'Przełączniki i rolety';

  @override
  String get sectionSensors => 'Czujniki';

  @override
  String get sectionOther => 'Inne';

  @override
  String get homeFirstName => 'Mój dom';

  @override
  String homeNumberedName(int number) {
    return 'Dom $number';
  }

  @override
  String get dashAddTile => 'Dodaj kafelek';

  @override
  String get addTileSearch => 'Szukaj urządzeń';

  @override
  String get addTileNotOnDashboard => 'Poza dashboardami';

  @override
  String get addTileAllDevices => 'Wszystkie urządzenia';

  @override
  String get addTileReading => 'Odczyt';

  @override
  String get addTileReadingSubtitle => 'Jedna wartość z urządzenia lub tematu';

  @override
  String get readingShowAs => 'Pokaż jako';

  @override
  String get readingStyleValue => 'Wartość';

  @override
  String get readingStyleGauge => 'Wskaźnik';

  @override
  String get gaugeBands => 'Zakresy kolorów';

  @override
  String get gaugeBandsHelper =>
      'Maksymalnie trzy. Zakres, w którym jest wartość, koloruje łuk.';

  @override
  String get gaugeBandFrom => 'Od';

  @override
  String get gaugeBandTo => 'Do';

  @override
  String get gaugeBandAdd => 'Dodaj zakres';

  @override
  String get gaugeBandRemove => 'Usuń zakres';

  @override
  String get gaugeToneNormal => 'Normalny';

  @override
  String get gaugeToneGood => 'Dobry';

  @override
  String get gaugeToneAttention => 'Uwaga';

  @override
  String get addTileCustom => 'Własny kafelek MQTT';

  @override
  String get addTileCustomSubtitle =>
      'Dowolny typ kafelka, konfigurowany przez temat';

  @override
  String get addTileNoDevices =>
      'Brak urządzeń do pokazania. Połącz się z brokerem lub sparuj urządzenie w Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Dodaj';

  @override
  String get addTileName => 'Nazwa';

  @override
  String addTileNameHint(String model) {
    return 'np. $model';
  }

  @override
  String get addTileSection => 'Sekcja';

  @override
  String get addTileNoSection => 'Bez sekcji';

  @override
  String get addTileSize => 'Rozmiar';

  @override
  String get deviceClassColorLight => 'Światło kolorowe';

  @override
  String get deviceClassLight => 'Światło';

  @override
  String get deviceClassSwitch => 'Przełącznik lub gniazdko';

  @override
  String get deviceClassCover => 'Roleta';

  @override
  String get deviceClassLeak => 'Zalanie lub dym';

  @override
  String get deviceClassContact => 'Kontaktron';

  @override
  String get deviceClassMotion => 'Ruch';

  @override
  String get deviceClassClimate => 'Czujnik klimatu';

  @override
  String get deviceClassGeneric => 'Urządzenie';

  @override
  String get deviceNotResponding => 'Nie odpowiada';

  @override
  String get homeAdd => 'Dodaj dom';

  @override
  String get homeManage => 'Zarządzaj domami';

  @override
  String get homeSwitch => 'Zmień dom';

  @override
  String get navDevices => 'Urządzenia';

  @override
  String get navScenes => 'Sceny';

  @override
  String get devicesNewDot => 'Nowe urządzenia';

  @override
  String get editEditing => 'Edycja';

  @override
  String get editDashboard => 'Dashboard';

  @override
  String get editDone => 'Gotowe';

  @override
  String get editAddSection => 'Dodaj sekcję';

  @override
  String get editSectionName => 'Nazwa sekcji';

  @override
  String get editRenameSection => 'Zmień nazwę sekcji';

  @override
  String get editDeleteSection => 'Usuń sekcję';

  @override
  String get editDeleteSectionBody => 'Co zrobić z jej kafelkami?';

  @override
  String get editKeepTiles => 'Zachowaj kafelki, usuń sekcję';

  @override
  String get editDeleteTiles => 'Usuń też kafelki';

  @override
  String get editMoveToSection => 'Przenieś do sekcji';

  @override
  String get editEditTile => 'Edytuj kafelek';

  @override
  String get editRemove => 'Usuń z dashboardu';

  @override
  String get editRemoved => 'Usunięto kafelek';

  @override
  String get editUndo => 'Cofnij';

  @override
  String get editReplaceWithDevice => 'Zastąp kafelkiem urządzenia';

  @override
  String get editMoveEarlier => 'Przenieś wcześniej';

  @override
  String get editMoveLater => 'Przenieś później';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count urządzenia nie jest na żadnym dashboardzie',
      many: '$count urządzeń nie jest na żadnym dashboardzie',
      few: '$count urządzenia nie są na żadnym dashboardzie',
      one: '$count urządzenie nie jest na żadnym dashboardzie',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Opcje kafelka';

  @override
  String get editSave => 'Zapisz';

  @override
  String get editCancel => 'Anuluj';

  @override
  String get ageJustNow => 'Przed chwilą';

  @override
  String ageMinutes(int n) {
    return '$n min temu';
  }

  @override
  String ageHours(int n) {
    return '$n godz. temu';
  }

  @override
  String get statusCantReach => 'Brak połączenia z brokerem';

  @override
  String get statusWhy => 'Dlaczego?';

  @override
  String get statusWhyTitle => 'Broker nie odpowiada';

  @override
  String get statusWhyBody =>
      'ZigDash ponawia próby samodzielnie. Do tego czasu kafelki pokazują ostatnio znane wartości, przygaszone, z ich wiekiem. Sprawdź, czy broker jest włączony, a telefon jest w tej samej sieci, lub przetestuj połączenie w jego ustawieniach.';

  @override
  String get statusSettings => 'Ustawienia połączenia';

  @override
  String get deviceAddToDashboard => 'Dodaj do dashboardu';

  @override
  String get deviceDismiss => 'Odrzuć';

  @override
  String get devicesFilterAll => 'Wszystkie';

  @override
  String devicesFilterAttention(int count) {
    return 'Wymaga uwagi · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Poza dashboardami · $count';
  }

  @override
  String get devicesNoMatch => 'Brak pasujących urządzeń';

  @override
  String get deviceBatteryLow => 'Słaba bateria';

  @override
  String get deviceLinkWeak => 'Słabe';

  @override
  String get deviceUnsupported => 'Nieobsługiwane przez Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'Parowanie nie zostało ukończone';

  @override
  String get deviceNoReport => 'Brak raportu';

  @override
  String get devicesAvailabilityOff =>
      'Dostępność w Zigbee2MQTT jest wyłączona, więc urządzenia offline mają status „Nie odpowiada”.';

  @override
  String get devicesAvailabilityHow => 'Jak ją włączyć';

  @override
  String get devicesDotBattery => 'Słaba bateria';

  @override
  String get deviceDetails => 'Szczegóły urządzenia';

  @override
  String get deviceGone => 'Tego urządzenia nie ma już w Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Sterowanie';

  @override
  String get deviceReadingsTitle => 'Odczyty';

  @override
  String get deviceHealthTitle => 'Kondycja';

  @override
  String get deviceOnDashboards => 'Na dashboardach';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT nie obsługuje jeszcze tego urządzenia, więc nie ma czym sterować.';

  @override
  String get deviceAddReadingTile => 'Dodaj jako kafelek odczytu';

  @override
  String get deviceAddReadingTo => 'Do którego dashboardu?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Dodano do: $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Jakość łącza';

  @override
  String get deviceLinkGood => 'Dobre';

  @override
  String get devicePowerSource => 'Źródło zasilania';

  @override
  String get devicePowerBattery => 'Bateria';

  @override
  String get devicePowerMains => 'Sieć';

  @override
  String get deviceLastHeard => 'Ostatni kontakt';

  @override
  String get deviceAvailability => 'Dostępność';

  @override
  String get deviceAvailabilityOff => 'Wyłączona w Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Polityka prywatności';

  @override
  String get settingsPrivacySubtitle =>
      'Bez telemetrii. Wszystko zostaje na tym telefonie.';

  @override
  String get homeCurrent => 'Bieżący dom';

  @override
  String get homeConnection => 'Połączenie';

  @override
  String get homeSwitchTo => 'Przełącz na ten dom';

  @override
  String get homeDelete => 'Usuń dom';

  @override
  String get devicesSelect => 'Wybierz urządzenie';

  @override
  String get scenesSelect => 'Wybierz scenę do edycji';

  @override
  String get panelFormTopic => 'Temat';

  @override
  String get panelFormPickDevice => 'Wybierz urządzenie';

  @override
  String get panelFormStateTopic => 'Temat stanu';

  @override
  String get panelFormCommandTopic => 'Temat poleceń';

  @override
  String get panelFormCommandTopicDerived =>
      'Wypełniany z tematu stanu, dopóki go nie zmienisz.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Powiązano z: $device';
  }

  @override
  String get panelFormOpenDevice => 'Otwórz urządzenie';

  @override
  String get panelFormUnlink => 'Odłącz';

  @override
  String get panelFormValueChoices => 'Wartości z tego urządzenia';

  @override
  String get panelFormAdvanced => 'Zaawansowane';

  @override
  String get panelFormAdvancedSubtitle => 'Nadpisanie prefiksu, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Puste = sam prefiks (stan urządzenia Zigbee2MQTT).';

  @override
  String get dashWallDisplay => 'Tryb ekranu ściennego';

  @override
  String get analyticsSetupCheckbox =>
      'Udostępniaj anonimowe dane o użyciu, aby pomóc ulepszyć konfigurację';

  @override
  String get analyticsWhatsShared => 'Co jest udostępniane';

  @override
  String get analyticsCardTitle => 'Pomożesz ulepszyć ZigDash?';

  @override
  String get analyticsCardBody =>
      'Udostępniaj anonimowe dane o użyciu: które etapy konfiguracji zawodzą i które funkcje są używane. Nigdy Twoje urządzenia, tematy ani broker.';

  @override
  String get analyticsShare => 'Udostępniaj';

  @override
  String get analyticsNoThanks => 'Nie, dziękuję';

  @override
  String get settingsAnalytics => 'Udostępniaj anonimowe dane o użyciu';

  @override
  String get settingsAnalyticsSubtitle =>
      'Etapy konfiguracji i używane funkcje. Nigdy Twoje urządzenia, tematy ani broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Anonimowe dane o użyciu. Wyłącz je przełącznikiem powyżej.';

  @override
  String get dashDefaultName => 'Dom';

  @override
  String get dashExportSaveFile => 'Zapisz plik';

  @override
  String get dashExportSaved => 'Kopia zapisana';

  @override
  String get dashImportChooseFile => 'Wybierz plik';

  @override
  String get dashImportFileUnreadable => 'Nie udało się odczytać pliku';

  @override
  String get getHelpTitle => 'Uzyskaj pomoc';

  @override
  String get getHelpTryFirst => 'Najpierw spróbuj tego';

  @override
  String get getHelpPromise =>
      'Nadal nie działa? Zwykle odpowiadam w ciągu 3 dni, po angielsku lub hebrajsku. Nigdy nie poproszę o Twoje hasła.';

  @override
  String get getHelpIncluded => 'Co zostanie dołączone';

  @override
  String get getHelpContact => 'Skontaktuj się z pomocą';

  @override
  String get getHelpCopy => 'Kopiuj szczegóły';

  @override
  String get getHelpCopied => 'Skopiowano szczegóły';

  @override
  String get getHelpLink => 'Nadal nie działa? Uzyskaj pomoc';

  @override
  String get getHelpEmailSubject => 'ZigDash: pomoc w uruchomieniu';

  @override
  String get getHelpEmailPrompt => 'Co chcesz zrobić i co się stało?';

  @override
  String get settingsHelpSupport => 'Pomoc i wsparcie';

  @override
  String get settingsGetHelp => 'Uzyskaj pomoc';

  @override
  String get settingsGetHelpSubtitle =>
      'Coś nie działa? Najpierw wskazówki, potem kontakt';

  @override
  String get settingsCommunity => 'Dołącz do społeczności ZigDash';

  @override
  String get settingsCommunitySubtitle =>
      'Grupa na Telegramie: pytania, pomysły i co dalej';

  @override
  String get getHelpCommunity => 'Zapytaj w grupie na Telegramie';

  @override
  String get demoBannerHelp => 'Uzyskaj pomoc';

  @override
  String get tipSameWifiTitle => 'To samo Wi-Fi co hub';

  @override
  String get tipSameWifiBody =>
      'Telefon musi być w tej samej sieci co hub, nie w sieci dla gości. Na czas konfiguracji wyłącz dane komórkowe.';

  @override
  String get tipBrokerRunningTitle => 'Broker działa';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: aplikacja Mosquitto broker jest uruchomiona. Raspberry Pi: Mosquitto działa. SMLIGHT: Settings › MQTT jest włączone.';

  @override
  String get tipBrokerAcceptsTitle => 'Broker przyjmuje połączenia z telefonu';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: włącz Allow External. Mosquitto 2 przyjmuje połączenia tylko z samego huba, dopóki nie ustawisz go tak, by nasłuchiwał w sieci (port 1883).';

  @override
  String get tipMeshTitle => 'Wi-Fi mesh lub dwa routery?';

  @override
  String get tipMeshBody =>
      'Jeśli hub jest podłączony do drugiego routera, telefon może go nie widzieć. Podłącz hub do głównego routera albo połącz się przez jego adres.';

  @override
  String get tipByAddressTitle => 'Połącz przez adres';

  @override
  String get tipByAddressBody =>
      'Znajdź adres huba w aplikacji routera, a potem dotknij „Wpisz dane ręcznie”.';

  @override
  String get tipSameNetworkTitle => 'Ta sama sieć';

  @override
  String get tipSameNetworkBody =>
      'Telefon i hub muszą być w tej samej sieci Wi-Fi. Wyłącz dane komórkowe.';

  @override
  String get tipAddressChangedTitle => 'Adres się zmienił';

  @override
  String get tipAddressChangedBody =>
      'Po ponownym uruchomieniu hub może dostać nowy adres. Sprawdź go w aplikacji routera i zarezerwuj go tam, żeby się nie zmieniał.';

  @override
  String get tipRightPortTitle => 'Właściwy port';

  @override
  String get tipRightPortBody =>
      'MQTT to zwykle port 1883 (8883 z TLS). 8080 lub 80 to interfejs webowy huba, a nie MQTT.';

  @override
  String get tipStartBrokerTitle => 'Broker działa';

  @override
  String get tipStartBrokerBody =>
      'Uruchom Mosquitto lub aplikację Mosquitto broker, a potem spróbuj ponownie.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 przyjmuje połączenia tylko z samego huba, dopóki nie ustawisz go tak, by nasłuchiwał w sieci (port 1883).';

  @override
  String get tipMqttLoginTitle => 'Login MQTT, a nie login do strony';

  @override
  String get tipMqttLoginBody =>
      'Hasło do strony huba zwykle nie jest hasłem MQTT. Home Assistant: użyj użytkownika Home Assistanta albo loginu ustawionego w aplikacji Mosquitto broker.';

  @override
  String get tipSpacesTitle => 'Sprawdź spacje';

  @override
  String get tipSpacesBody =>
      'Przy kopiowaniu hasła na końcu może dodać się spacja.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT używa tego brokera';

  @override
  String get tipZ2mBrokerBody =>
      'W ustawieniach Zigbee2MQTT sprawdź, czy jego serwer MQTT to ten sam broker.';

  @override
  String get tipBaseTopicTitle => 'Temat bazowy';

  @override
  String get tipBaseTopicBody =>
      'Jeśli temat bazowy jest inny niż „zigbee2mqtt”, wpisz go w konfiguracji ręcznej.';

  @override
  String get tipPairFirstTitle => 'Najpierw sparuj urządzenia';

  @override
  String get tipPairFirstBody =>
      'Otwórz interfejs webowy Zigbee2MQTT i sparuj co najmniej jedno urządzenie, a potem sprawdź ponownie.';

  @override
  String get tipRestartZ2mTitle => 'Uruchom ponownie Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'Jeśli urządzenia są sparowane, ale żadne się nie pojawia, uruchom ponownie Zigbee2MQTT, aby opublikował listę urządzeń.';

  @override
  String get tipNumberAddressTitle => 'Użyj adresu liczbowego';

  @override
  String get tipNumberAddressBody =>
      'Nazwy kończące się na .local nie działają na każdym telefonie z Androidem. Spróbuj adresu liczbowego huba, np. 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Port i protokół';

  @override
  String get tipPortProtocolBody =>
      'Standardowo jest to TCP na porcie 1883. Wybierz TLS lub WebSocket tylko wtedy, gdy Twój broker jest tak skonfigurowany.';

  @override
  String get tipManualLoginTitle => 'Logowanie';

  @override
  String get tipManualLoginBody =>
      'Zostaw nazwę użytkownika i hasło puste, jeśli broker ich nie ma. W przeciwnym razie użyj loginu MQTT, a nie loginu do interfejsu webowego huba.';

  @override
  String get tipHubOnTitle => 'Czy hub jest włączony?';

  @override
  String get tipHubOnBody =>
      'Przerwa w zasilaniu lub aktualizacja mogła go zrestartować. Gdy znów się włączy, daj mu minutę.';

  @override
  String get tipAwayTitle => 'Czy jesteś w domu?';

  @override
  String get tipAwayBody =>
      'Poza domem aplikacja potrzebuje adresu zdalnego (na przykład Tailscale). Ustaw go w ustawieniach połączenia domu.';

  @override
  String get tipTailscaleIpTitle => 'Użyj adresu IP Tailscale, nie nazwy';

  @override
  String get tipTailscaleIpBody =>
      'Nazwy kończące się na .ts.net często nie są rozwiązywane w aplikacjach. Otwórz aplikację Tailscale na telefonie i sprawdź, czy jest połączona. Potem użyj adresu 100.x.y.z huba jako hosta zdalnego.';

  @override
  String get tipHomeAddressChangedTitle => 'Czy adres się zmienił?';

  @override
  String get tipHomeAddressChangedBody =>
      'Po ponownym uruchomieniu routera hub może dostać nowy adres. Zarezerwuj jego adres w aplikacji routera, a potem zaktualizuj dom.';

  @override
  String get tipRestartZ2mButtonTitle => 'Uruchom ponownie Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'Jeśli broker został uruchomiony ponownie, lista urządzeń Zigbee2MQTT znika do czasu ponownego uruchomienia Zigbee2MQTT. Użyj przycisku „Uruchom ponownie Zigbee2MQTT” na karcie „Urządzenia”.';

  @override
  String get tipZ2mRunningTitle => 'Czy Zigbee2MQTT działa?';

  @override
  String get tipZ2mRunningBody =>
      'Otwórz jego interfejs webowy. Jeśli się nie wczytuje, uruchom ponownie Zigbee2MQTT na hubie.';

  @override
  String get tipCantConnectTitle => 'Nie mogę połączyć się z hubem';

  @override
  String get tipCantConnectBody =>
      'To samo Wi-Fi, działający broker, włączone Allow External lub Mosquitto nasłuchujący w sieci, a potem połączenie przez adres.';

  @override
  String get tipDeviceWrongTitle =>
      'Urządzenie pokazuje złe dane lub nie odpowiada';

  @override
  String get tipDeviceWrongBody =>
      'Najpierw sprawdź je w interfejsie webowym Zigbee2MQTT. Jeśli tam działa, użyj opcji „Zgłoś problem”.';

  @override
  String get tipHowDoITitle => 'Jak mogę…';

  @override
  String get tipHowDoIBody =>
      'Sceny, tryb ekranu ściennego, harmonogramy i kopie zapasowe znajdziesz w sekcji „Pomoc i przewodnik”.';

  @override
  String get tipRenameHomeTitle => 'Zmień nazwę domu';

  @override
  String get tipRenameHomeBody =>
      'Dom nazwany od swojego adresu? Ustawienia › Domy, dotknij domu, a potem Nazwa.';

  @override
  String get tipWhatYouNeedTitle => 'Czego potrzebujesz';

  @override
  String get tipWhatYouNeedBody =>
      'Mały hub z Zigbee2MQTT i brokerem MQTT (Mosquitto): hub SMLIGHT, Raspberry Pi albo dowolny komputer z Linuksem. Home Assistant też się nada, ale nie jest potrzebny.';

  @override
  String get tipSetupAtHomeTitle => 'W tej samej sieci Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Konfiguruj w domu, z telefonem w tej samej sieci Wi-Fi co hub.';

  @override
  String get tipFindSetupTitle => 'Potem';

  @override
  String get tipFindSetupBody =>
      'Wyjdź z trybu demo i dotknij „Znajdź moją instalację”. ZigDash sam znajdzie Twój hub.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Nie znaleziono aplikacji pocztowej. Skopiuj dane i napisz na $email.';
  }

  @override
  String get shortcutWorking => 'trwa…';

  @override
  String get shortcutCantReach => 'Brak połączenia z domem';

  @override
  String get shortcutNotConfirmed => 'Nie potwierdzono';

  @override
  String get shortcutRemoved => 'Usunięto';

  @override
  String get shortcutSceneSent => 'Wysłano';

  @override
  String get shortcutSceneConfirmed => 'Potwierdzono';

  @override
  String get shortcutChooseDevice => 'Wybierz urządzenie';

  @override
  String get shortcutChooseScene => 'Wybierz scenę';

  @override
  String get shortcutOpenAppFirstScene =>
      'Otwórz ZigDash i najpierw utwórz scenę.';

  @override
  String get shortcutChooseGroup => 'Wybierz grupę';

  @override
  String get shortcutPickDevices => 'Wybierz urządzenia…';

  @override
  String get shortcutGroupName => 'Nazwa grupy';

  @override
  String get shortcutGroupLimit => 'Do 5 urządzeń i 3 scen';

  @override
  String get shortcutAddTile => 'Dodaj do Szybkich ustawień';

  @override
  String get shortcutAddShortcut => 'Dodaj skrót';

  @override
  String get shortcutAddToHome => 'Dodaj do ekranu głównego';

  @override
  String get shortcutWidgetHowToTitle => 'Dodaj widżet';

  @override
  String get shortcutWidgetHowTo =>
      'Przytrzymaj puste miejsce na ekranie głównym, dotknij Widżety, znajdź ZigDash i przeciągnij wybrany widżet.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name jest na kafelku ZigDash $slot w Szybkich ustawieniach';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name jest już na kafelku ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Dodaj kafelek';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Otwórz Szybkie ustawienia (przesuń dwa razy w dół), dotknij ołówka, aby edytować, i przeciągnij „ZigDash $slot” do swoich kafelków.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Wybierz urządzenie dla ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Nie ma jeszcze urządzeń do przełączania. Najpierw dodaj lampę, gniazdko lub roletę do dashboardu.';

  @override
  String get shortcutSlotsFull =>
      'Wszystkie 4 kafelki ZigDash są zajęte. Który ma zamiast tego pokazywać to urządzenie?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Nieużywany';

  @override
  String get deviceRename => 'Zmień nazwę';

  @override
  String get deviceRenameTitle => 'Zmień nazwę urządzenia';

  @override
  String get deviceRenameHint => 'Nazwa pokoju lub urządzenia, np. Sypialnia';

  @override
  String deviceRenamed(Object name) {
    return 'Zmieniono nazwę na $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Nie udało się zmienić nazwy: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT nie odpowiedział';

  @override
  String get shortcutOpenAppFirst =>
      'Otwórz ZigDash i najpierw dodaj urządzenie do dashboardu.';

  @override
  String get pollTitle => 'Co ZigDash powinien robić dalej?';

  @override
  String get pollBody =>
      'Wybierz to, z czego korzystałbyś najczęściej. Odpowiedź zostanie wysłana z anonimowymi danymi o użyciu.';

  @override
  String get pollNotifications => 'Powiadomienia';

  @override
  String get pollHistory => 'Wykresy historii';

  @override
  String get pollKiosk => 'Tryb kiosku dla tabletu na ścianie';

  @override
  String get pollGroups => 'Grupy Zigbee';

  @override
  String get pollNotNow => 'Nie teraz';

  @override
  String get pollThanks => 'Dzięki! To pomaga zdecydować, co dalej.';

  @override
  String get whyTitle => 'Dlaczego wypróbowałeś ZigDash?';

  @override
  String get whyBody =>
      'Jedno dotknięcie pomoże zdecydować, co budować. Odpowiedź zostanie wysłana z anonimowymi danymi o użyciu.';

  @override
  String get whyFaster => 'Szybszy niż moja inna aplikacja';

  @override
  String get whyFamily => 'Prosty dla rodziny';

  @override
  String get whyWallTablet => 'Tablet na ścianie';

  @override
  String get whyWithoutHa => 'Działa bez Home Assistant';

  @override
  String get whyOther => 'Coś innego';

  @override
  String get whyThanks => 'Dzięki za odpowiedź!';

  @override
  String get pollNoAnalytics =>
      'Dane o użyciu są wyłączone, więc nic stąd nie zostanie wysłane. Napisz nam przez Zaproponuj funkcję.';

  @override
  String alertLeak(Object name) {
    return '💧 Wyciek — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name znów jest suchy';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Dym — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Nie ma już dymu przy $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name otwarte';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Słaba bateria — $name, $value%';
  }

  @override
  String get alertTest => 'Testowe powiadomienie ZigDash';

  @override
  String get alertsChannel => 'Alarmy';

  @override
  String get alertsChannelDescription => 'Wycieki i dym';

  @override
  String get noticesChannel => 'Powiadomienia';

  @override
  String get noticesChannelDescription => 'Drzwi, okna i baterie';

  @override
  String get alertsTitle => 'Alarmy';

  @override
  String get alertsStatusOn => 'Alarmy są włączone';

  @override
  String get alertsStatusPaused =>
      'Alerty wstrzymane: ZigDash Engine na hubie się nie odzywa';

  @override
  String get alertsStatusNotSetUp => 'Nie skonfigurowano';

  @override
  String get alertsStatusPhoneOff => 'Ten telefon nie dostaje powiadomień';

  @override
  String get alertsIntro =>
      'Otrzymuj powiadomienie na tym telefonie o wycieku, dymie, otwartych drzwiach lub słabej baterii, nawet gdy ZigDash jest zamknięty. ZigDash Engine na hubie obserwuje urządzenia; ZigDash go konfiguruje.';

  @override
  String get alertsSetUpHub => 'Skonfiguruj alarmy na hubie';

  @override
  String get alertsHubInstalled => 'Alerty są skonfigurowane na hubie';

  @override
  String get alertsHubUpdated => 'Przepływ alarmów na hubie jest aktualny';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED wymaga logowania, więc zaimportuj przepływ ręcznie:';

  @override
  String get alertsHubManualSteps =>
      'Otwórz Node-RED na hubie, wybierz Import, wklej skopiowany przepływ, wybierz swój broker w węźle brokera i kliknij Deploy.';

  @override
  String get alertsCopyFlow => 'Kopiuj przepływ';

  @override
  String get alertsFlowCopied => 'Przepływ skopiowany';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Alarmy wymagają Node-RED na hubie, a nic nie odpowiada na porcie 1880 pod $host. Na SMLIGHT SMHUB zainstaluj go w Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT nie przyjął ZigDash Engine';

  @override
  String get alertsRecent => 'Ostatnie alarmy';

  @override
  String get alertsRecentNone => 'Jeszcze nic';

  @override
  String get alertsYourAlerts => 'Twoje alarmy';

  @override
  String get alertsAdd => 'Dodaj alarm';

  @override
  String get alertsNotificationsOnThisPhone => 'Powiadomienia na tym telefonie';

  @override
  String get alertsNoGoogle =>
      'Ten telefon nie ma usług Google, więc ZigDash nie może tu odbierać powiadomień push.';

  @override
  String get alertsSendTest => 'Wyślij powiadomienie testowe';

  @override
  String get alertsTestSent => 'Test wysłany. Powinien zaraz dotrzeć.';

  @override
  String alertsTestFailed(Object status) {
    return 'Hub nie mógł go wysłać ($status)';
  }

  @override
  String get alertsTestTimedOut =>
      'Brak odpowiedzi z huba. Czy przepływ alarmów działa?';

  @override
  String get alertsNotConnected => 'Brak połączenia z hubem';

  @override
  String get alertsTurnOff => 'Wyłącz alarmy';

  @override
  String get alertsTurnOffBody =>
      'Alarmy przestaną działać na każdym telefonie w tym domu.';

  @override
  String get alertKindLeak => 'Wyciek';

  @override
  String get alertKindSmoke => 'Dym';

  @override
  String get alertKindOpened => 'Otwarte drzwi lub okno';

  @override
  String get alertKindBattery => 'Słaba bateria';

  @override
  String get alertsEditTitle => 'Alarm';

  @override
  String get alertsKind => 'Co';

  @override
  String get alertsDevices => 'Urządzenia';

  @override
  String get alertsNoDevicesForKind =>
      'Żadne urządzenie w tym domu tego nie zgłasza.';

  @override
  String get alertsHours => 'Tylko między';

  @override
  String get alertsHoursAny => 'O każdej porze';

  @override
  String get alertsHoursFrom => 'Od';

  @override
  String get alertsHoursTo => 'Do';

  @override
  String get alertsThreshold => 'Bateria poniżej';

  @override
  String get alertsDelete => 'Usuń alarm';

  @override
  String get alertsNotifyMe => 'Powiadom mnie…';

  @override
  String get alertsWhatLeaves =>
      'Alarmy do ZigDash są szyfrowane od końca do końca: usługa push Google je przenosi, ale nie może ich odczytać. Nic więcej nie opuszcza huba.';

  @override
  String get alertsRestricted =>
      'Android może zatrzymać ZigDash w tle, przez co powiadomienia przyjdą późno lub wcale. Zezwól na działanie w tle w ustawieniach Androida (Samsung: Bateria › Aplikacje nigdy nieusypiane).';

  @override
  String get alertsOpenSettings => 'Otwórz ustawienia Androida';

  @override
  String get alertsOff => 'Wył.';

  @override
  String get alertsSuggested => 'Proponowane alarmy';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count urządzeń',
      few: '$count urządzenia',
      one: '1 urządzenie',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Włącz';

  @override
  String get alertsShare => 'Udostępnij alarmy';

  @override
  String get alertsShareBody =>
      'Każdy z tym linkiem dostaje alarmy tego domu w aplikacji ntfy, bez ZigDash. Treść alarmu przechodzi przez ntfy.sh bez szyfrowania.';

  @override
  String get alertsShareLink => 'Link';

  @override
  String get alertsShareNewLink => 'Nowy link';

  @override
  String get alertsShareCopied => 'Link skopiowany';

  @override
  String get alertsShareOff => 'Przestań udostępniać';

  @override
  String get alertsGetWithNtfy => 'Odbieraj powiadomienia przez ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Alarmy dymu i wycieku powtarzają się do potwierdzenia. Wymaga konta Pushover (4,99 \$ jednorazowo po okresie próbnym); klucze są trzymane na Twoim brokerze.';

  @override
  String get alertsPushoverUser => 'Klucz użytkownika';

  @override
  String get alertsPushoverToken => 'Token aplikacji';

  @override
  String get alertsHideNames => 'Ukryj nazwy urządzeń';

  @override
  String get alertsNtfyServer => 'Serwer ntfy';

  @override
  String get wallSheetTitle => 'Wyświetlacz ścienny';

  @override
  String get wallSheetSubtitle => 'Dla tabletu na ścianie.';

  @override
  String get wallKeepOn => 'Nie wygaszaj ekranu i ukryj paski';

  @override
  String get wallKeepOnSubtitle =>
      'Wracają po dotknięciu i znikają znów po 10 sekundach.';

  @override
  String get wallFullscreen => 'Pełny ekran';

  @override
  String get wallFullscreenSubtitle =>
      'Ukrywa też paski stanu i nawigacji Androida.';

  @override
  String get wallDimAfter => 'Przyciemnij po';

  @override
  String get wallDimOff => 'Wył.';

  @override
  String get wallIdleTitle => 'Gdy nikt go nie dotyka';

  @override
  String get wallIdleAfter => 'Po';

  @override
  String get wallIdleNever => 'Nigdy';

  @override
  String get wallIdleShow => 'Pokaż';

  @override
  String get wallIdleShowDim => 'Przyciemniony';

  @override
  String get wallIdleShowClock => 'Zegar';

  @override
  String get wallIdleShowBlack => 'Czarny';

  @override
  String get wallIdleShowReadings => 'Odczyty';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Ten pulpit nie ma jeszcze odczytów. Najpierw dodaj kafelek odczytu lub czujnika.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Odczyty na zegarze (do $count)';
  }

  @override
  String get wallProNote =>
      'Odczyty na zegarze, wybudzanie ruchem, harmonogram nocny i alarmy są częścią ZigDash Pro, jednorazowego zakupu.';

  @override
  String get wallAlarmLeak => 'Wyciek wody';

  @override
  String get wallAlarmSmoke => 'Dym';

  @override
  String get wallAlarmGas => 'Gaz';

  @override
  String get wallAlarmCo => 'Tlenek węgla';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Wybudzanie ruchem';

  @override
  String get wallMotionSubtitle =>
      'Czujnik, który kogoś wykryje, wybudza ekran.';

  @override
  String get wallMotionNone =>
      'W tym domu nie ma czujników ruchu, obecności ani drzwi.';

  @override
  String get wallAlarmsTitle => 'Alarmy wypełniają ekran';

  @override
  String get wallAlarmsSubtitle =>
      'Wyciek, dym, gaz lub tlenek węgla wypełnia ekran, aż ktoś stuknie OK. Tylko gdy ZigDash jest otwarty na tym tablecie; powiadomienia docierają do telefonów wszędzie.';

  @override
  String get wallAlarmSound => 'Odtwórz dźwięk';

  @override
  String get wallNightTitle => 'Noc';

  @override
  String get wallNightSubtitle =>
      'Czarny między tymi godzinami. Ruch wybudza go tylko przyciemniony; alarmy zawsze w pełni.';

  @override
  String get wallNightFrom => 'Od';

  @override
  String get wallNightTo => 'do';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Blokada kiosku';

  @override
  String get kioskLockSubtitle =>
      'Dostępne są tylko pulpity tego domu i ich sterowanie. Przytrzymaj tytuł, aby wyjść.';

  @override
  String get kioskPin => 'PIN';

  @override
  String get kioskPinSet => 'Ustaw';

  @override
  String get kioskPinNotSet => 'Nie ustawiono';

  @override
  String get kioskPinChange => 'Zmień';

  @override
  String get kioskPinRemove => 'Usuń';

  @override
  String get kioskPinSetTitle => 'Ustaw PIN';

  @override
  String get kioskPinEnterTitle => 'Wpisz PIN';

  @override
  String get kioskPinHint => '4 cyfry';

  @override
  String get kioskPinConfirmHint => 'Jeszcze raz';

  @override
  String get kioskPinMismatch => 'Oba kody PIN się różnią.';

  @override
  String get kioskPinWrong => 'Błędny PIN.';

  @override
  String get kioskPinForgot => 'Nie pamiętasz PIN-u?';

  @override
  String get kioskPinForgotBody =>
      'Zapomniany PIN można zresetować tylko przez wyczyszczenie danych ZigDash w ustawieniach Androida, co usuwa ten dom, chyba że masz kopię zapasową. Wyeksportuj ją przed ustawieniem PIN-u.';

  @override
  String get kioskExportBackup => 'Eksportuj kopię';

  @override
  String get kioskOsPin => 'Przypnij też ZigDash w Androidzie';

  @override
  String get kioskOsPinSubtitle =>
      'Android blokuje przycisk Home i ostatnie aplikacje, dopóki ZigDash nie zostanie odpięty. Tablet bez ekranu blokady odpina gestem, więc to nie jest blokada.';

  @override
  String get kioskOn => 'Kiosk włączony. Przytrzymaj tytuł, aby wyjść.';

  @override
  String get kioskLeaveTitle => 'Wyjść z kiosku?';

  @override
  String get kioskLeave => 'Wyjdź';

  @override
  String get kioskStay => 'Zostań';

  @override
  String get a11yKioskLeave => 'Przytrzymaj, aby wyjść z kiosku';

  @override
  String get historyTitle => 'Historia';

  @override
  String get historyRangeDay => '24 godziny';

  @override
  String get historyRangeWeek => '7 dni';

  @override
  String get historyRangeMonth => '30 dni';

  @override
  String get historySetupTitle => 'Zapisuj historię na hubie';

  @override
  String get historySetupBody =>
      'ZigDash nie ma serwera, więc ZigDash Engine na hubie co 15 minut zapisuje wartości z Twoich pulpitów. Przechowuje 30 dni, na Twoim brokerze.';

  @override
  String get historySetupAction => 'Skonfiguruj na hubie';

  @override
  String get historyInstalled =>
      'Nagrywanie trwa. Pierwsze wartości pojawią się w ciągu 15 minut.';

  @override
  String historyNoNodeRed(String host) {
    return 'Historia wymaga Node-RED na hubie, a na porcie 1880 pod adresem $host nic nie odpowiada. Na SMLIGHT SMHUB zainstaluj go w Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Zapisywane od $date';
  }

  @override
  String get historyEmpty => 'Brak wartości. Rejestrator zapisuje co 15 minut.';

  @override
  String get historyRecorderOffline =>
      'Rejestrator na hubie nie odpowiada, więc może brakować ostatnich wartości.';

  @override
  String get historyLocked =>
      'Dłuższa historia jest częścią ZigDash Pro, jednorazowego zakupu.';

  @override
  String get historyUnlock => 'Odblokuj';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Bez limitu automatyzacji, dłuższa historia i dodatki do tabletu na ścianie. Wspiera projekt open source.';

  @override
  String get proUnlocked => 'Odblokowane. Dziękujemy za wspieranie ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash jest darmowy i open source, tworzony przez jedną osobę w wolnym czasie. Pro to jednorazowy zakup, dzięki któremu projekt może trwać.';

  @override
  String get proWhatYouGet => 'Co dostajesz';

  @override
  String get proGetHistory => 'Historię z 7 i 30 dni, nie tylko z dzisiaj';

  @override
  String get proGetWall =>
      'Tablet na ścianie: odczyty na zegarze, wybudzanie ruchem, harmonogram nocny i alarmy';

  @override
  String get proGetFuture => 'Każdą przyszłą funkcję Pro bez dopłaty';

  @override
  String get proFreeTitle => 'Za darmo na zawsze';

  @override
  String get proFreeBody =>
      'Konfiguracja, pulpity, sterowanie każdym urządzeniem, widżety, kafelki szybkich ustawień, alerty, trzy automatyzacje na dom i sam tablet na ścianie pozostają darmowe. Nic, czego używasz dziś, nie zostanie zablokowane.';

  @override
  String get proBuy => 'Kup Pro';

  @override
  String proBuyPrice(String price) {
    return 'Kup Pro · $price';
  }

  @override
  String get proOnce =>
      'Jedna płatność, bez subskrypcji. Kupione na innym telefonie z tym samym kontem Google? Odblokuje się automatycznie.';

  @override
  String get historyNotRecorded =>
      'Zapisywane są tylko liczby widoczne na pulpicie. Dodaj tę wartość jako kafelek, aby zacząć jej historię.';

  @override
  String get historyRecordHere => 'Nagrywaj na tym urządzeniu';

  @override
  String get historyRecordHereHint =>
      'Nie da się użyć ZigDash Engine na hubie? ZigDash może zapisywać na telefonie lub tablecie, który zostaje otwarty, np. na tablecie na ścianie. Każdy telefon tego domu widzi historię.';

  @override
  String get historyRecordingHere =>
      'To urządzenie nagrywa historię, gdy ZigDash jest otwarty. Pierwsze wartości pojawią się w ciągu 15 minut.';

  @override
  String get wallRecordHistory => 'Nagrywaj historię na tym urządzeniu';

  @override
  String get wallRecordHistorySubtitle =>
      'Co 15 minut, gdy ZigDash jest otwarty, dla każdego telefonu tego domu. Niepotrzebne, gdy zapisuje ZigDash Engine na hubie.';

  @override
  String historyNeedsPassword(String host) {
    return 'Jeszcze jeden krok: broker wymaga logowania. Otwórz Node-RED pod $host:1880, kliknij dwukrotnie „ZigDash history broker”, wpisz hasło MQTT na karcie Security i kliknij Deploy. ZigDash nigdy nie wysyła hasła do huba.';
  }

  @override
  String get historyNotConnected =>
      'Zapis się nie odzywa. Otwórz Automatyzacje, aby sprawdzić ZigDash Engine na hubie.';

  @override
  String get historyPersistence =>
      'Historia jest przechowywana na brokerze. Jeśli sam uruchamiasz Mosquitto, upewnij się, że konfiguracja zawiera \"persistence true\", inaczej historia zniknie po restarcie brokera.';

  @override
  String get haImportTitle => 'Import z Home Assistant';

  @override
  String get haImportSettingsSubtitle =>
      'Nazwy i pomieszczenia z Home Assistant';

  @override
  String get haImportIntro =>
      'Przenieś nazwy i pomieszczenia ustawione w Home Assistant. ZigDash odczytuje je raz i nie zatrzymuje niczego innego z Home Assistant.';

  @override
  String get haImportAddress => 'Adres Home Assistant';

  @override
  String get haImportAddressHelp =>
      'Adres, pod którym otwierasz Home Assistant, np. 192.168.1.20:8123';

  @override
  String get haImportToken => 'Token dostępu długoterminowego';

  @override
  String get haImportTokenHelp =>
      'W Home Assistant otwórz swój profil, potem Bezpieczeństwo › Tokeny dostępu długoterminowego › Utwórz token. Skopiuj go i wklej tutaj. ZigDash użyje go raz i go nie zachowa; potem możesz go usunąć w Home Assistant.';

  @override
  String get haImportRead => 'Odczytaj z Home Assistant';

  @override
  String get haImportReading => 'Odczytywanie Home Assistant…';

  @override
  String get haImportApplying => 'Importowanie…';

  @override
  String get haImportNoAddress =>
      'Wpisz adres, pod którym otwierasz Home Assistant.';

  @override
  String get haImportNoToken => 'Wklej token dostępu długoterminowego.';

  @override
  String get haImportUnreachable =>
      'Pod tym adresem nic nie odpowiada. Sprawdź go i czy telefon jest w sieci domowej.';

  @override
  String get haImportNotHa =>
      'Coś odpowiedziało pod tym adresem, ale to nie Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant odrzucił ten token. Utwórz nowy i wklej go ponownie.';

  @override
  String get haImportCertificate =>
      'Telefon nie ufa certyfikatowi tego Home Assistant. Spróbuj adresu http:// w sieci domowej.';

  @override
  String get haImportFailed =>
      'Home Assistant odpowiedział, ale odczyt się nie udał. Spróbuj ponownie.';

  @override
  String get haImportNoDevices =>
      'ZigDash nie widzi teraz urządzeń tego domu. Połącz się z domem i spróbuj ponownie.';

  @override
  String get haImportAutomations =>
      'Twoje automatyzacje zostają w Home Assistant i dalej działają.';

  @override
  String haImportFound(int count) {
    return 'Urządzenia znalezione w Home Assistant: $count';
  }

  @override
  String get haImportRenameNote =>
      'Kafelki, które wciąż mają nazwę urządzenia, dostaną nazwę z Home Assistant. Twoje własne dashboardy zostają bez zmian.';

  @override
  String get haImportMakeDashboards =>
      'Dodaj też dashboardy z pięter i pomieszczeń';

  @override
  String get haImportOtherRooms => 'Inne pomieszczenia';

  @override
  String get haImportNoRoom => 'Bez pomieszczenia';

  @override
  String get haImportApply => 'Importuj';

  @override
  String get haImportBack => 'Wstecz';

  @override
  String get haImportZhaOnly =>
      'Te urządzenia działają w ZHA, wbudowanym Zigbee Home Assistant, a nie w Zigbee2MQTT, więc ZigDash nie może ich pokazać.';

  @override
  String get haImportNothing =>
      'Żadne z urządzeń Zigbee2MQTT tego domu nie jest w Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Gotowe. Kafelki ze zmienioną nazwą: $renamed. Dodane dashboardy: $dashboards.';
  }

  @override
  String get haImportOpen => 'Otwórz dashboardy';

  @override
  String get haImportOfferTitle =>
      'Przenieść nazwy i pomieszczenia z Home Assistant?';

  @override
  String get haImportOfferBody =>
      'Home Assistant jest w twojej sieci. ZigDash może nazwać kafelki i dodać dashboard na każde piętro i pomieszczenie, tak jak je tam ustawiłeś.';

  @override
  String get haImportOfferLater => 'Nie teraz';

  @override
  String get haImportOfferGo => 'Importuj';

  @override
  String get haImportSignIn => 'Zaloguj się przez Home Assistant';

  @override
  String get haImportSignInHelp =>
      'Logowanie Home Assistant otworzy się w przeglądarce. ZigDash nigdy nie widzi twojego hasła i po odczycie wylogowuje się.';

  @override
  String get haImportOrToken => 'Albo użyj tokena dostępu długoterminowego';

  @override
  String get haImportReadToken => 'Odczytaj z tokenem';

  @override
  String get haImportSignInRefused =>
      'Home Assistant nie przyjął logowania. Zdarza się to, gdy Home Assistant nie ma dostępu do internetu. Użyj poniżej tokena dostępu długoterminowego.';

  @override
  String get setupIsolatedHint =>
      'Telefon prawie nic więcej nie widzi w tej sieci Wi-Fi. Może być w sieci dla gości albo router oddziela urządzenia od siebie (często zwane izolacją klientów lub AP). Połącz się z główną siecią Wi-Fi albo to wyłącz i spróbuj ponownie.';

  @override
  String get setupAuthTrust =>
      'Twój login zostaje na tym telefonie i trafia tylko do twojego brokera. ZigDash nie ma serwera ani konta, a każda aplikacja MQTT loguje się w ten sposób. Najbezpieczniej: osobny użytkownik MQTT tylko dla ZigDash, którego możesz w każdej chwili usunąć.';

  @override
  String get setupAuthWhatKept => 'Co ZigDash zachowuje';

  @override
  String get setupAuthDemoFirst => 'Najpierw wypróbuj demo';

  @override
  String get automationsTitle => 'Automatyzacje';

  @override
  String get engineRunningOnHub => 'Działa na hubie';

  @override
  String get engineChecking => 'Sprawdzanie huba…';

  @override
  String get engineAwayNoHubTitle => 'Teraz nie można połączyć się z hubem';

  @override
  String get engineAwayNoHubBody =>
      'Jesteś poza domem, a hub nie jest połączony ze zdalnym dostępem ZigDash albo nie ma internetu. Twoje automatyzacje nadal działają na hubie.';

  @override
  String get engineAwayReinstallAtHome =>
      'Engine możesz zainstalować ponownie, gdy będziesz w domu.';

  @override
  String get engineNoConnection =>
      'ZigDash nie łączy się teraz z brokerem tego domu. Automatyzacje konfiguruje się w domu, z połączeniem.';

  @override
  String get engineRestarting =>
      'Ponowne uruchamianie Zigbee2MQTT… Urządzenia wrócą za około 30 sekund.';

  @override
  String get engineInstalling => 'Instalowanie na hubie…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT wymaga aktualizacji';

  @override
  String engineTooOldBody(Object version) {
    return 'Twój Zigbee2MQTT ma wersję $version. Automatyzacje wymagają 2.4 lub nowszej. Zaktualizuj Zigbee2MQTT na hubie i wróć tutaj.';
  }

  @override
  String get engineIntroTitle =>
      'Automatyzacje działają na hubie, nie na telefonie';

  @override
  String get engineIntroBody =>
      'ZigDash umieszcza ZigDash Engine w Zigbee2MQTT na Twoim hubie. Obserwuje urządzenia i wykonuje reguły, więc światło zapali się po otwarciu drzwi, nawet gdy telefon jest wyłączony, a internet nie działa.';

  @override
  String get engineIntroNothingByHand =>
      'Nic do instalowania ręcznie. ZigDash zrobi to przez sieć domową.';

  @override
  String engineIntroVersion(Object version) {
    return 'Twój Zigbee2MQTT ma wersję $version.';
  }

  @override
  String get engineIntroRemove =>
      'Możesz go w każdej chwili usunąć z tego ekranu.';

  @override
  String get engineInstall => 'Zainstaluj na hubie';

  @override
  String get engineDeclinedTitle => 'Brak automatyzacji na tym hubie';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT na Twoim hubie nie pozwala na rozszerzenia, więc nic nie wykona reguł, gdy telefonu nie ma. Sceny, alerty i pulpit działają jak dotąd.';

  @override
  String get engineAllowAfterAll => 'Jednak zezwól na rozszerzenia';

  @override
  String get engineConsentTitle =>
      'Zigbee2MQTT wymaga zmiany jednego ustawienia';

  @override
  String get engineConsentBody =>
      'Twój Zigbee2MQTT blokuje rozszerzenia, takie jak ZigDash Engine, jak robią to nowe instalacje. Aby uruchamiać automatyzacje na hubie, ZigDash włączy w Zigbee2MQTT „Zezwalaj na zewnętrzny JavaScript” i uruchomi go ponownie.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT uruchomi się ponownie raz. Światła i czujniki będą nieosiągalne przez około 30 sekund.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine jest open source. Możesz go przeczytać na stronie Zigbee2MQTT w sekcji Rozszerzenia.';

  @override
  String get engineConsentUndo =>
      'Możesz później wyłączyć to ustawienie. Wtedy automatyzacje się zatrzymają.';

  @override
  String get engineConsentYes => 'Zmień ustawienie i uruchom ponownie';

  @override
  String get engineConsentNo => 'Nie teraz';

  @override
  String get automationsPausedTitle => 'Automatyzacje wstrzymane';

  @override
  String get automationsPausedBody =>
      'Hub nie odzywa się od ponad minuty, więc żadna automatyzacja nie zadziała, dopóki nie wróci. Reguły zostają zachowane.';

  @override
  String get engineReinstall => 'Zainstaluj ponownie na hubie';

  @override
  String get engineStoppedTitle =>
      'Automatyzacje wstrzymane: ZigDash Engine sam się zatrzymał';

  @override
  String get engineStoppedBody =>
      'Trzy razy w ciągu godziny napotkał błędy i wyłączył się, żeby Zigbee2MQTT dalej działał. Reguły zostają zachowane.';

  @override
  String get engineStartAgain => 'Uruchom ponownie';

  @override
  String get engineReportProblem => 'Zgłoś problem';

  @override
  String get engineRunningTitle => 'Twój hub jest gotowy na automatyzacje';

  @override
  String engineRunningBody(Object count) {
    return 'Reguły załadowane na hubie: $count. Tworzenie automatyzacji pojawi się w kolejnym kroku tej wersji.';
  }

  @override
  String get engineClockOff =>
      'Zegar huba różni się o ponad pięć minut. Automatyzacje czasowe będą działać o złej porze, dopóki tego nie naprawisz.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Reguły, których ZigDash Engine na hubie jeszcze nie obsługuje: $count. Zainstaluj go ponownie, aby go zaktualizować.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT odrzucił ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT nie odpowiedział. Sprawdź, czy dom jest połączony, i spróbuj ponownie.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT nie przyjął zmiany albo nie wrócił. Sprawdź hub i spróbuj ponownie.';

  @override
  String get autoValMotion => 'ruch';

  @override
  String get autoValNoMotion => 'brak ruchu';

  @override
  String get autoValClosed => 'zamknięte';

  @override
  String get autoValOpened => 'otwarte';

  @override
  String get autoValLeak => 'wyciek';

  @override
  String get autoValDry => 'sucho';

  @override
  String get autoValSmoke => 'dym';

  @override
  String get autoValNoSmoke => 'brak dymu';

  @override
  String get autoValOn => 'wł.';

  @override
  String get autoValOff => 'wył.';

  @override
  String get autoValToggle => 'przełącz';

  @override
  String get autoValOpen => 'otwórz';

  @override
  String get autoValClose => 'zamknij';

  @override
  String get autoValStop => 'zatrzymaj';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Gdy $device: $property powyżej $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Gdy $device: $property poniżej $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Gdy $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'O $time';
  }

  @override
  String get autoSunrise => 'wschód słońca';

  @override
  String get autoSunset => 'zachód słońca';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min po: $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min przed: $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return '$sun';
  }

  @override
  String get autoEveryDay => 'codziennie';

  @override
  String get autoWeekdays => 'w dni robocze';

  @override
  String get autoWeekends => 'w weekendy';

  @override
  String autoBetween(Object from, Object to) {
    return 'między $from a $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device: $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Uruchom „$scene”';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, wyłączy się po $minutes min';
  }

  @override
  String get autoErrPickTrigger => 'Wybierz urządzenie i to, co robi.';

  @override
  String get autoErrValue => 'Wpisz liczbę dla odczytu.';

  @override
  String get autoErrDays => 'Wybierz co najmniej jeden dzień.';

  @override
  String get autoErrTown => 'Ustaw miejscowość dla wschodu i zachodu słońca.';

  @override
  String get autoErrPickAction => 'Wybierz, co ma się stać.';

  @override
  String get autoErrEmptyScene => 'Ta scena nie ma nic do wysłania.';

  @override
  String get autoErrNotConnected =>
      'ZigDash nie jest połączony z tym domem. Spróbuj ponownie w domu.';

  @override
  String get autoNewTitle => 'Nowa automatyzacja';

  @override
  String get autoEditTitle => 'Edytuj automatyzację';

  @override
  String get autoName => 'Nazwa';

  @override
  String get autoNameHint => 'Co robi (opcjonalnie)';

  @override
  String get autoWhen => 'Gdy';

  @override
  String get autoOnlyIf => 'Tylko jeśli';

  @override
  String get autoThen => 'Wtedy';

  @override
  String get autoEnabled => 'Włączona';

  @override
  String get autoDelete => 'Usuń automatyzację';

  @override
  String get autoSave => 'Zapisz';

  @override
  String get autoDeviceChanges => 'Urządzenie się zmienia';

  @override
  String get autoTimeComes => 'Nadchodzi godzina';

  @override
  String get autoDevice => 'Urządzenie';

  @override
  String get autoAbove => 'powyżej';

  @override
  String get autoBelow => 'poniżej';

  @override
  String get autoClockTime => 'Godzina';

  @override
  String get autoAt => 'O';

  @override
  String get autoShift => 'Przesunięcie w minutach (minus to wcześniej)';

  @override
  String get autoTownNone => 'Brak miejscowości';

  @override
  String autoTownIs(Object town) {
    return 'Godziny słońca dla: $town';
  }

  @override
  String get autoTownSet => 'Ustaw miejscowość';

  @override
  String get autoTownChange => 'Zmień miejscowość';

  @override
  String get autoDays => 'Dni';

  @override
  String get autoNoConditions => 'Brak warunków. Działa za każdym razem.';

  @override
  String get autoAddHours => 'Między godzinami';

  @override
  String get autoFrom => 'Od';

  @override
  String get autoTo => 'Do';

  @override
  String get autoAddDeviceCondition => 'Urządzenie jest…';

  @override
  String get autoRunASceneOption => 'Uruchom scenę';

  @override
  String get autoSetADevice => 'Ustaw urządzenie';

  @override
  String get autoScene => 'Scena';

  @override
  String get autoTurnOffAgain => 'Wyłącz ponownie';

  @override
  String get autoStaysAsSet => 'Zostaje tak';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minut później';
  }

  @override
  String get autoTownSearch => 'Miejscowość';

  @override
  String get autoTownWhy =>
      'Tylko do wschodu i zachodu słońca. Zapisana na hubie, nigdy Twoja lokalizacja.';

  @override
  String get autoNewButton => 'Nowa automatyzacja';

  @override
  String get autoEmptyBody =>
      'Nic jeszcze nie działa. Stuknij Nowa automatyzacja, aby utworzyć pierwszą.';

  @override
  String autoOnlyIfList(Object list) {
    return 'tylko jeśli $list';
  }

  @override
  String get autoEdit => 'Edytuj';

  @override
  String get autoNeverRan => 'jeszcze nie działała';

  @override
  String autoRanAt(Object time) {
    return 'działała o $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count z $max darmowych automatyzacji';
  }

  @override
  String get autoRecentRuns => 'Ostatnie uruchomienia';

  @override
  String get autoDeleted => '(usunięta)';

  @override
  String autoCeilingTitle(Object count) {
    return 'Darmowe automatyzacje: $count. Chcesz więcej?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash jest darmowy i open source, tworzony przez jedną osobę. Pro to jednorazowy zakup: bez limitu automatyzacji, historia z 7 i 30 dni oraz dodatki do tabletu na ścianie. Twoje automatyzacje działają dalej, cokolwiek wybierzesz.';

  @override
  String get autoCeilingSeePro => 'Zobacz Pro';

  @override
  String get engineRemove => 'Usuń z huba';

  @override
  String get engineRemoveTitle => 'Usunąć ZigDash Engine z huba?';

  @override
  String get engineRemoveBody =>
      'Automatyzacje przestaną działać. Reguły zostają na hubie, więc ponowna instalacja ZigDash Engine je przywróci.';

  @override
  String get autoNoTargets =>
      'Ten dom nie ma jeszcze światła, gniazdka, przełącznika ani rolety do sterowania.';

  @override
  String get proGetAutomations =>
      'Bez limitu automatyzacji; trzy na dom są darmowe';

  @override
  String get proGetRemote =>
      'Zdalne sterowanie z dowolnego miejsca przez przekaźnik ZigDash, bez miesięcznej opłaty';

  @override
  String get proRemoteFair =>
      'Dostęp zdalny jest wliczony, dopóki działa przekaźnik ZigDash, dla jednego domu, do pięciu telefonów i zwykłego domowego użytku. Może się zmienić lub zakończyć po wcześniejszym powiadomieniu.';

  @override
  String get autoDeleteConfirm =>
      'Usunąć tę automatyzację? Przestanie działać na hubie.';

  @override
  String get statusConnectedRelay => 'Połączono · Poza domem przez ZigDash';

  @override
  String get shareHomeTitle => 'Udostępnij innemu telefonowi';

  @override
  String get shareHomeSubtitle =>
      'Dodaj ten dom do innego telefonu jednym kodem QR';

  @override
  String get shareHomeIntro =>
      'Na drugim telefonie, w domu w tej samej sieci Wi-Fi, zeskanuj kod aparatem. ZigDash doda ten dom z danymi logowania i Twoimi pulpitami.';

  @override
  String get shareHomeLoginWarning =>
      'Kod zawiera dane logowania do brokera tego domu. Jest widoczny przez 2 minuty; pokazuj go tylko zaufanym osobom.';

  @override
  String get shareHomeShow => 'Pokaż kod';

  @override
  String get shareHomeAtHome =>
      'Najpierw połącz się w domu: udostępnianie działa tylko w sieci domowej.';

  @override
  String get shareHomeScanHint =>
      'Zeskanuj aparatem drugiego telefonu. Kod zniknie za 2 minuty.';

  @override
  String get shareHomeHide => 'Ukryj kod';

  @override
  String get shareHomeViaHa =>
      'Ten dom łączy się przez Home Assistant. Na drugim telefonie zainstaluj ZigDash i zaloguj się przez Home Assistant.';

  @override
  String get joinHomeTitle => 'Dodaj udostępniony dom';

  @override
  String get joinHomeInvalid =>
      'Ten kod nie jest zaproszeniem ZigDash albo jest uszkodzony.';

  @override
  String joinHomeAlready(String name) {
    return '$name jest już na tym telefonie.';
  }

  @override
  String get joinHomeOpen => 'Otwórz';

  @override
  String joinHomeAsk(String name) {
    return 'Dodać $name do tego telefonu?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash doda dom z tym samym połączeniem i logowaniem oraz pobierze pulpity z drugiego telefonu. Zostań w domowej sieci Wi-Fi.';

  @override
  String get joinHomeAdd => 'Dodaj dom';

  @override
  String get joinHomeNoDashboards =>
      'Dom dodany. Pulpity nie dotarły; urządzenia są na karcie Urządzenia.';

  @override
  String get remoteTitle => 'Sterowanie zdalne';

  @override
  String get remoteSettingsSubtitle =>
      'Steruj tym domem z dowolnego miejsca, z Pro';

  @override
  String get remoteIntroTitle => 'Steruj domem z dowolnego miejsca';

  @override
  String get remoteOfferBody =>
      'Steruj urządzeniami poza domem, przez szyfrowany przekaźnik ZigDash. Część Pro: jedna płatność, bez miesięcznej opłaty. Skonfiguruj to, będąc w domu.';

  @override
  String get remoteOfferBodyPro =>
      'Masz Pro: włącz zdalne sterowanie, będąc w domu, a potem steruj urządzeniami z dowolnego miejsca.';

  @override
  String get remoteOfferShow => 'Pokaż';

  @override
  String get remoteIntroBody =>
      'Hub utrzymuje jedno połączenie z przekaźnikiem ZigDash. Poza domem ten telefon dociera przez niego do urządzeń. Wszystko jest szyfrowane na hubie i telefonie, więc przekaźnik nie może odczytać urządzeń ani tego, co robią.';

  @override
  String get remoteNeedsEngine =>
      'Sterowanie zdalne działa w ZigDash Engine. Najpierw zainstaluj go w Automatyzacjach.';

  @override
  String get remoteSetUp => 'Włącz sterowanie zdalne';

  @override
  String get remoteNeedsPro => 'Sterowanie zdalne jest częścią Pro.';

  @override
  String get remoteNotAtHome => 'Włącz to w domu, z połączeniem z brokerem.';

  @override
  String get remoteUnreachable =>
      'Przekaźnik ZigDash nie odpowiedział. Spróbuj później.';

  @override
  String get remoteRefused =>
      'Przekaźnik odmówił. Spróbuj ponownie lub zgłoś problem.';

  @override
  String get remoteOnTitle => 'Sterowanie zdalne jest włączone';

  @override
  String get remoteOnBody =>
      'Poza domem ZigDash sam łączy się przez przekaźnik.';

  @override
  String get remoteHubOnline => 'Hub jest połączony z przekaźnikiem';

  @override
  String get remoteHubOffline => 'Hub nie jest połączony z przekaźnikiem';

  @override
  String get remoteTurnOff => 'Wyłącz sterowanie zdalne';

  @override
  String get remoteViaRelayNow =>
      'Ten telefon jest teraz połączony przez przekaźnik.';

  @override
  String get remotePhones => 'Telefony z dostępem zdalnym';

  @override
  String get remoteThisPhone => 'Ten telefon';

  @override
  String get remoteOtherPhone => 'Inny telefon';

  @override
  String remotePhoneAdded(Object date) {
    return 'Dodano $date';
  }

  @override
  String get remoteRemovePhone => 'Usuń';

  @override
  String get remoteRemovePhoneConfirm =>
      'Usunąć ten telefon? Nie dotrze już do tego domu z zewnątrz.';

  @override
  String get remoteAddPhone => 'Dodaj telefon';

  @override
  String get remoteAddPhoneHint =>
      'W domu zeskanuj to aparatem drugiego telefonu. Otworzy ZigDash i włączy tam sterowanie zdalne. Pokazuj tylko swoim telefonom.';

  @override
  String get remoteAddPhoneFailed =>
      'Przekaźnik nie wydał dostępu dla kolejnego telefonu. Dom może mieć do pięciu.';

  @override
  String get remoteBackupSave => 'Zapisz kopię klucza';

  @override
  String get remoteBackupRestore => 'Przywróć z kopii klucza';

  @override
  String get remoteBackupPassphrase => 'Hasło kopii';

  @override
  String get remoteBackupPassphraseHint =>
      'Gdy zgubisz ten telefon, kopia i to hasło przywrócą sterowanie zdalne na nowym. Co najmniej 8 znaków; trzymaj hasło gdzie indziej niż plik.';

  @override
  String get remoteBackupPassphraseAsk =>
      'Hasło wybrane przy zapisywaniu kopii.';

  @override
  String get remoteBackupPassphraseAgain => 'Powtórz hasło';

  @override
  String get remoteBackupSaved => 'Kopia klucza zapisana';

  @override
  String get remoteBackupWrong => 'To hasło nie otwiera tej kopii.';

  @override
  String get remoteBackupWrongFile => 'To nie jest kopia klucza ZigDash.';

  @override
  String get remotePlayOnly =>
      'Sterowanie zdalne jest na razie w wersji ZigDash z Google Play.';

  @override
  String get remotePairTitle => 'Dodaj sterowanie zdalne';

  @override
  String get remotePairBody =>
      'Który to dom? ZigDash zachowa dla niego dostęp zdalny.';

  @override
  String get remotePairNoHomes =>
      'Najpierw skonfiguruj ten dom na tym telefonie, w domu. Potem zeskanuj kod ponownie.';

  @override
  String get remotePairInvalid =>
      'To nie jest kod sterowania zdalnego ZigDash albo został ucięty.';

  @override
  String remotePairDone(Object home) {
    return 'Sterowanie zdalne włączone dla: $home';
  }

  @override
  String get remoteReconnectHub => 'Połącz hub ponownie';

  @override
  String get remoteTurnOffConfirm =>
      'Ten telefon opuszcza sterowanie zdalne, a hub rozłącza się z przekaźnikiem. Kopia klucza zapisana z tego telefonu przestanie działać; inne telefony zachowają dostęp, dopóki ich nie usuniesz.';

  @override
  String remoteHomeId(Object id) {
    return 'ID domu $id';
  }

  @override
  String get alertsHintTitle => 'Powiadomienia na tym telefonie';

  @override
  String get alertsHintBody =>
      'Wyciek, dym, otwarte drzwi lub słaba bateria mogą wysłać powiadomienie na ten telefon, nawet gdy ZigDash jest zamknięty.';

  @override
  String get alertsHintButton => 'Skonfiguruj alarmy';

  @override
  String get alertsHintNotNow => 'Nie teraz';

  @override
  String get guidedNoZ2mBody =>
      'Odpowiada tu broker MQTT, ale Zigbee2MQTT nic przez niego nie wysyła. Sprawdź, czy Zigbee2MQTT jest uruchomiony i używa tego brokera oraz czy temat bazowy zgadza się z jego ustawieniami. Jeśli Twoje urządzenia Zigbee są w ZHA w Home Assistant, ZigDash ich nie widzi: działa z Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT jest na tym brokerze z tematem bazowym „$found”, ale ten dom szuka „$current”.';
  }

  @override
  String devicesUseBase(String found) {
    return 'Użyj „$found”';
  }

  @override
  String get devicesChangeConnection => 'Zmień połączenie';

  @override
  String get updateAvailableTitle => 'Jest nowa wersja ZigDash';

  @override
  String get updateAvailableBody =>
      'Pobiera się, gdy dalej korzystasz z ZigDash.';

  @override
  String get updateAvailableButton => 'Aktualizuj';

  @override
  String get updateDownloading => 'Pobieranie aktualizacji…';

  @override
  String get updateReadyTitle => 'Aktualizacja pobrana';

  @override
  String get updateReadyButton => 'Uruchom ponownie, aby dokończyć';

  @override
  String get nfcWriteTag => 'Zapisz na tagu NFC';

  @override
  String get nfcHoldTitle => 'Przyłóż tag do telefonu';

  @override
  String nfcHoldBody(String name) {
    return 'Przyłóż pustą naklejkę NFC do tyłu telefonu. Dotknięcie jej później uruchomi $name.';
  }

  @override
  String get nfcWrittenTitle => 'Tag gotowy';

  @override
  String nfcWrittenBody(String name) {
    return 'Dotknij telefonem tego tagu, aby uruchomić $name. Działa nawet przy zamkniętym ZigDash.';
  }

  @override
  String get nfcFailedTitle => 'Nie udało się zapisać tagu';

  @override
  String get nfcReadonlyBody =>
      'Ten tag jest zablokowany i nie da się go zmienić. Spróbuj innego.';

  @override
  String get nfcTooSmallBody =>
      'Ten tag jest za mały. Użyj naklejki NTAG213 lub większej.';

  @override
  String get nfcFailedBody =>
      'Przytrzymaj tag nieruchomo przy tyle telefonu i spróbuj ponownie.';

  @override
  String get nfcOffTitle => 'NFC jest wyłączone';

  @override
  String get nfcOffBody =>
      'Włącz NFC w ustawieniach Androida i spróbuj ponownie.';

  @override
  String get nfcNoneTitle => 'Ten telefon nie ma NFC';

  @override
  String get nfcNoneBody =>
      'Ten telefon nie może czytać ani zapisywać tagów NFC.';

  @override
  String get nfcWriteAnother => 'Zapisz kolejny tag';

  @override
  String get nfcUnsupportedBody =>
      'Ten telefon nie zapisze tego rodzaju tagu (często MIFARE Classic). Użyj naklejki NTAG213, 215 lub 216.';

  @override
  String get nfcTagsTitle => 'Tagi NFC';

  @override
  String get nfcTagsSubtitle =>
      'Tagi, które uruchamiają scenę lub przełączają urządzenie';

  @override
  String get nfcTagsEmpty =>
      'Brak tagów. Przytrzymaj kafelek sceny, światła, gniazdka lub rolety i wybierz Zapisz na tagu NFC.';

  @override
  String get nfcTagRunsScene => 'Uruchamia scenę';

  @override
  String get nfcTagSwitches => 'Włącza i wyłącza';

  @override
  String nfcTagWritten(String when) {
    return 'zapisany $when';
  }

  @override
  String nfcTagLastTap(String when) {
    return 'ostatnio dotknięty $when';
  }

  @override
  String get nfcTagNeverTapped => 'jeszcze nieużyty';

  @override
  String get nfcTagOffLabel => 'Wyłączony';

  @override
  String get nfcTagRewrite => 'Zapisz ponownie';

  @override
  String get nfcTagForget => 'Usuń z listy';

  @override
  String get nfcTagOffToast => 'Ten tag jest wyłączony w ZigDash';

  @override
  String get nfcTagsNote =>
      'Wyłączony tag nic nie robi na tym telefonie. Tagów zapisanych przed tą listą tu nie ma: zapisz je raz ponownie.';

  @override
  String get nfcPopupHeader => 'Tag ZigDash';

  @override
  String get nfcPopupRunning => 'Uruchamianie…';

  @override
  String get nfcPopupSwitching => 'Przełączanie…';

  @override
  String get nfcPopupDone => 'Gotowe';

  @override
  String get nfcPopupClosing => 'Zamknie się za 2 sekundy';

  @override
  String get nfcPopupUnreachable =>
      'Ten telefon nie łączy się teraz z domem. Sprawdź Wi-Fi albo włącz sterowanie zdalne.';

  @override
  String get nfcPopupOffBody =>
      'Nic nie zostało przełączone. Włącz go ponownie w ustawieniach domu, w sekcji Tagi NFC.';

  @override
  String get nfcPopupOpenApp => 'Otwórz ZigDash';
}
