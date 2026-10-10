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
      'IP brokera to adres IP huba. Znajdziesz go w interfejsie webowym SMLIGHT w Settings → Network lub w routerze. Port to 1883, domyślnie bez nazwy użytkownika i hasła.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA nie ma brokera MQTT — komunikuje się bezpośrednio z Home Assistant, więc ZigDash nie może się z nim połączyć. Aby używać ZigDash, przejdź na Zigbee2MQTT (dostępne jako dodatek Home Assistant lub kontener Docker), który udostępnia broker MQTT.';

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
  String get dashFormLock => 'Zablokuj';

  @override
  String get dashFormLockSubtitle => 'Ukryj opcje edycji, gdy zablokowany';

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
      'Nie można połączyć się z brokerem. Czy Zigbee2MQTT działa? Sprawdź adres i port.';

  @override
  String get diagTcpTimeout =>
      'Upłynął limit czasu łączenia z brokerem. Może być offline lub nieosiągalny.';

  @override
  String get diagConnackFail =>
      'Broker nie zakończył uzgadniania MQTT. Upewnij się, że to broker MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'Broker odrzucił nazwę użytkownika lub hasło. Sprawdź dane logowania.';

  @override
  String get diagAuthRefused =>
      'Broker odmówił połączenia. Sprawdź ustawienia połączenia.';

  @override
  String foundDevices(Object count) {
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
  String ladderTriedHint(Object count) {
    return 'Sprawdzone adresy: $count';
  }

  @override
  String get guidedSaveFailed =>
      'Nie udało się zapisać połączenia. Spróbuj ponownie.';

  @override
  String get setupWelcomeTitle => 'Witaj w ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash steruje Twoim istniejącym domem z Zigbee2MQTT — lokalnie, bez chmury. Upewnij się, że Zigbee2MQTT działa, a ZigDash go znajdzie.';

  @override
  String get setupFindMySetup => 'Znajdź moją instalację';

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
      'Home Assistant: upewnij się, że dodatek brokera MQTT (np. Mosquitto) i dodatek Zigbee2MQTT są zainstalowane i uruchomione.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: sprawdź, czy broker (np. Mosquitto) i usługa Zigbee2MQTT działają oraz czy port 1883 jest osiągalny.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: otwórz interfejs webowy urządzenia, przejdź do Settings > MQTT, włącz Allow External, aby telefon mógł połączyć się z brokerem, i sprawdź, czy Zigbee2MQTT jest uruchomione.';

  @override
  String get setupTryAgain => 'Spróbuj ponownie';

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
  String get setupVerifyingTitle => 'Sprawdzanie połączenia…';

  @override
  String get setupReviewTitle => 'Twoje urządzenia';

  @override
  String setupReviewSubtitle(Object count) {
    return 'Znalezione urządzenia: $count. Wybierz, co trafi na pierwszy dashboard.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'Utwórz dashboard (urządzenia: $count)';
  }

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
  String get setupErrScanFailedTitle => 'Brak sieci lokalnej';

  @override
  String get setupErrScanFailedBody =>
      'Nie udało się ustalić sieci lokalnej tego urządzenia. Połącz się z Wi-Fi i spróbuj ponownie.';

  @override
  String get setupErrScanFailedAction => 'Spróbuj ponownie';

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
  String get dashWallDisplayOn =>
      'Wyświetlacz ścienny włączony: ekran nie gaśnie, a paski chowają się po 10 sekundach bez dotyku. Dotknij, aby je przywrócić.';

  @override
  String get dashWallDisplayOff => 'Wyświetlacz ścienny wyłączony.';

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
      'Anonimowe dane o użyciu tylko za Twoją zgodą.';

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
      'Home Assistant: dodatek Mosquitto jest uruchomiony. Raspberry Pi: Mosquitto działa. SMLIGHT: Settings › MQTT jest włączone.';

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
      'Uruchom Mosquitto lub dodatek brokera i spróbuj ponownie.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 przyjmuje połączenia tylko z samego huba, dopóki nie ustawisz go tak, by nasłuchiwał w sieci (port 1883).';

  @override
  String get tipMqttLoginTitle => 'Login MQTT, a nie login do strony';

  @override
  String get tipMqttLoginBody =>
      'Hasło do interfejsu webowego huba zwykle nie jest hasłem MQTT. Home Assistant: użyj użytkownika Home Assistant albo loginu ustawionego w dodatku Mosquitto.';

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
  String get tipWhatYouNeedTitle => 'Czego potrzebujesz';

  @override
  String get tipWhatYouNeedBody =>
      'Brokera MQTT (Mosquitto) i Zigbee2MQTT działających na hubie: Home Assistant, Raspberry Pi lub hubie SMLIGHT.';

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
  String get pollNoAnalytics =>
      'Dane o użyciu są wyłączone, więc nic stąd nie zostanie wysłane. Napisz nam przez Zaproponuj funkcję.';
}
