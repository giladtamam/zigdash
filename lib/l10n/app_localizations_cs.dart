// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Naposledy známé';

  @override
  String get reliabilityControlsUnavailable => 'Ovládání není dostupné';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'Vyzkoušet demo';

  @override
  String get navBrokers => 'Brokery';

  @override
  String get navDashboards => 'Nástěnky';

  @override
  String get navSettings => 'Nastavení';

  @override
  String get settingsAppearance => 'Vzhled';

  @override
  String get themeSystem => 'Systém';

  @override
  String get themeLight => 'Světlý';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get settingsDynamicColor => 'Použít barvy Material You';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; jinak se použije barva aplikace';

  @override
  String get settingsLanguage => 'Jazyk';

  @override
  String get languageSystem => 'Systém';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Domovy';

  @override
  String connLoadFailed(Object error) {
    return 'Načtení selhalo: $error';
  }

  @override
  String get connAddBroker => 'Přidat broker';

  @override
  String get connEmpty =>
      'Zatím žádná připojení.\nKlepni na „Přidat broker“ a nasměruj ZigDash na svůj MQTT server.';

  @override
  String get connNew => 'Nové připojení';

  @override
  String get connEdit => 'Upravit připojení';

  @override
  String get save => 'Uložit';

  @override
  String get saving => 'Ukládám…';

  @override
  String get fieldRequired => 'Povinné';

  @override
  String get connName => 'Název';

  @override
  String get connNameHint => 'Domácí broker';

  @override
  String get connHost => 'Hostitel';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Místní hostitel';

  @override
  String get connFindBrokers => 'Najít brokery';

  @override
  String get connHowToFind => 'Jak to zjistím?';

  @override
  String get connRescan => 'Hledat znovu';

  @override
  String get connBrokerNeedsLogin => 'Vyžaduje přihlášení';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Prohledávám $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return 'Nalezené brokery: $count — klepnutím použiješ';
  }

  @override
  String get connFindBrokersNone => 'Na tvé Wi-Fi nebyl nalezen žádný broker.';

  @override
  String get connFindBrokersNoIp =>
      'Nepodařilo se zjistit tvou adresu Wi-Fi. Zkontroluj, že je Wi-Fi zapnutá, a zkus to znovu.';

  @override
  String get connHelpTitle => 'Jak najít IP adresu brokeru';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT v Dockeru';

  @override
  String get connHelpDockerBody =>
      'IP adresa brokeru je adresa v místní síti (LAN) počítače, na kterém běží Docker (tvůj NAS, Raspberry Pi atd.). Najdeš ji v seznamu zařízení v routeru, nebo na tom počítači spusť \'hostname -I\' / \'ip addr\'. Port je obvykle 1883 (Mosquitto). Použij LAN IP hostitele — ne 127.0.0.1 — i když Mosquitto běží ve vlastním kontejneru.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'IP adresa brokeru je IP adresa hubu. Najdeš ji ve webovém rozhraní SMLIGHT v Settings → Network, nebo v routeru. Port je 1883, ve výchozím stavu bez uživatelského jména a hesla.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA nemá MQTT broker — komunikuje přímo s Home Assistantem, takže se k němu ZigDash nemůže připojit. Pokud chceš ZigDash používat, přejdi na Zigbee2MQTT (dostupné jako doplněk Home Assistantu nebo jako kontejner Dockeru), který MQTT broker poskytuje.';

  @override
  String get connHelpSameNetwork =>
      'Telefon a broker musí být ve stejné Wi-Fi síti (ne v síti pro hosty ani v izolované VLAN).';

  @override
  String get connRemoteHost => 'Vzdálený hostitel (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Použije se, když místní hostitel není dostupný. Nejlépe Tailscale IP hubu, např. 100.x.y.z';

  @override
  String get connPort => 'Port';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsername => 'Uživatelské jméno';

  @override
  String get connUsernameOptional => 'Uživatelské jméno (volitelné)';

  @override
  String get connPasswordOptional => 'Heslo (volitelné)';

  @override
  String get connPasswordKeepHint =>
      'Nech prázdné, pokud chceš zachovat stávající';

  @override
  String get connAutoConnect => 'Připojit automaticky při spuštění aplikace';

  @override
  String get advanced => 'Pokročilé';

  @override
  String get connKeepAlive => 'Keep-alive (sekundy)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protokol';

  @override
  String get edit => 'Upravit';

  @override
  String get delete => 'Smazat';

  @override
  String get cancel => 'Zrušit';

  @override
  String get connDeleteTitle => 'Smazat připojení?';

  @override
  String connDeleteContent(Object name) {
    return 'Odstraní „$name“, jeho nástěnky a panely i uložené heslo.';
  }

  @override
  String get statusDisconnected => 'Odpojeno';

  @override
  String get statusConnecting => 'Připojování';

  @override
  String get statusConnected => 'Připojeno';

  @override
  String get statusReconnecting => 'Znovu se připojuje';

  @override
  String get statusError => 'Chyba';

  @override
  String get statusConnectedRemote => 'Připojeno · Vzdáleně';

  @override
  String get dashPlaceholder =>
      'Otevři broker na kartě Brokery, abys viděl a spravoval jeho nástěnky.';

  @override
  String get dashAddDashboard => 'Přidat nástěnku';

  @override
  String get dashEditDashboard => 'Upravit nástěnku';

  @override
  String get dashAddPanel => 'Přidat panel';

  @override
  String get dashEmpty =>
      'Zatím žádné nástěnky.\nKlepni na „Přidat nástěnku“ a vytvoř si ji pro tento broker.';

  @override
  String dashLoadFailed(Object error) {
    return 'Chyba: $error';
  }

  @override
  String get panelPickerTitle => 'Přidat panel';

  @override
  String get panelPickerSectionControl => 'Ovládání';

  @override
  String get panelPickerSectionState => 'Stav';

  @override
  String get panelPickerToggleTitle => 'Přepínač';

  @override
  String get panelPickerToggleSubtitle => 'Vypínač zap/vyp pro stav zařízení';

  @override
  String get panelPickerSliderBrightnessTitle => 'Posuvník — Jas';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Stmívání světla (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Posuvník — Poloha';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Roleta / žaluzie (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Roleta';

  @override
  String get panelPickerCoverSubtitle =>
      'Roleta/žaluzie: OTEVŘÍT·STOP·ZAVŘÍT + posuvník polohy';

  @override
  String get panelPickerScheduleTitle => 'Plán';

  @override
  String get panelPickerScheduleSubtitle =>
      'Denní časy otevření/zavření, běží na hubu (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Pravidlo automatického zavření';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Automaticky zavře zařízení N sekund po zapnutí, běží na hubu (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Více stavů';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Segmentová tlačítka pro výčet (např. OPEN/STOP/CLOSE)';

  @override
  String get panelPickerComboTitle => 'Rozbalovací seznam';

  @override
  String get panelPickerComboSubtitle => 'Rozbalovací výběr pro výčet';

  @override
  String get panelPickerRadioTitle => 'Přepínače';

  @override
  String get panelPickerRadioSubtitle => 'Seznam přepínačů (radio) pro výčet';

  @override
  String get panelPickerButtonTitle => 'Tlačítko';

  @override
  String get panelPickerButtonSubtitle => 'Odešle jednorázový příkaz';

  @override
  String get panelPickerTextInputTitle => 'Textové pole';

  @override
  String get panelPickerTextInputSubtitle =>
      'Publikuje libovolnou hodnotu nebo JSON';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Barevný indikátor pro stav ano/ne (kontakt, únik vody)';

  @override
  String get panelPickerNodeStatusTitle => 'Stav uzlu';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Dostupnost zařízení v Z2M (online/offline)';

  @override
  String get panelPickerProgressTitle => 'Průběh';

  @override
  String get panelPickerProgressSubtitle =>
      'Číselný pruh pro baterii, kvalitu spojení atd.';

  @override
  String get panelPickerTextLogTitle => 'Textový záznam';

  @override
  String get panelPickerTextLogSubtitle =>
      'Posouvající se historie zpráv na tématu';

  @override
  String get dashExportMenu => 'Exportovat nástěnky';

  @override
  String get dashImportMenu => 'Importovat nástěnky';

  @override
  String get dashExportTitle => 'Exportovat nástěnky';

  @override
  String get dashExportClose => 'Zavřít';

  @override
  String get dashExportCopy => 'Kopírovat';

  @override
  String get dashExportCopied => 'Zkopírováno do schránky';

  @override
  String get dashImportTitle => 'Importovat nástěnky';

  @override
  String get dashImportHint => 'Sem vlož exportovaný JSON';

  @override
  String get dashImportButton => 'Importovat';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importováno $count nástěnek',
      few: 'Importovány $count nástěnky',
      one: 'Importována 1 nástěnka',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Import selhal: $error';
  }

  @override
  String get dashFormNew => 'Nová nástěnka';

  @override
  String get dashFormEdit => 'Upravit nástěnku';

  @override
  String get dashFormName => 'Název';

  @override
  String get dashFormNameHint => 'Kancelář';

  @override
  String get dashFormTopicPrefix => 'Prefix tématu (volitelný)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/living-room';

  @override
  String get dashFormTopicPrefixHelper =>
      'Přidá se před téma každého panelu na této nástěnce';

  @override
  String get dashFormColorSeed => 'Základní barva';

  @override
  String get dashFormIcon => 'Ikona';

  @override
  String get dashFormLock => 'Zámek úprav';

  @override
  String get dashFormLockSubtitle => 'Skryje Upravit pro tuto nástěnku';

  @override
  String get dashFormDelete => 'Smazat nástěnku';

  @override
  String get dashDeleteTitle => 'Smazat tuto nástěnku?';

  @override
  String get dashDeleteContent => 'Odstraní se i všechny její panely.';

  @override
  String get dashDeleteConfirm => 'Smazat';

  @override
  String panelFormNew(Object type) {
    return 'Nový: $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Upravit: $type';
  }

  @override
  String get panelTypeButton => 'Tlačítko';

  @override
  String get panelTypeToggle => 'Přepínač';

  @override
  String get panelTypeSlider => 'Posuvník';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Stav uzlu';

  @override
  String get panelTypeProgress => 'Průběh';

  @override
  String get panelTypeMultiState => 'Více stavů';

  @override
  String get panelTypeCombo => 'Rozbalovací seznam';

  @override
  String get panelTypeRadio => 'Přepínače';

  @override
  String get panelTypeCover => 'Roleta';

  @override
  String get panelTypeTextInput => 'Textové pole';

  @override
  String get panelTypeTextLog => 'Textový záznam';

  @override
  String get panelTypeSchedule => 'Plán';

  @override
  String get panelTypeAutoClose => 'Automatické zavření';

  @override
  String get panelTypeDevice => 'Zařízení';

  @override
  String get panelTypeReading => 'Měření';

  @override
  String get panelFormName => 'Název';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Prefix nástěnky: $prefix/ (použije se, pokud ho níže nepřepíšeš)';
  }

  @override
  String get panelFormTopicPrefixOverride =>
      'Vlastní prefix tématu (volitelný)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/shutter';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Použij na této nástěnce jiné zařízení. Prázdné = prefix nástěnky.';

  @override
  String get panelFormPublishTopic => 'Téma pro publikování (přípona)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Připojí se za platný prefix. Nech prázdné, pokud chceš publikovat přímo na prefix.';

  @override
  String get panelFormTopicSuffix => 'Téma (přípona)';

  @override
  String get panelFormSubscribeTopic => 'Téma pro odběr (přípona, volitelné)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Připojí se za prefix nástěnky. Prázdné = odebírat přímo prefix (stav Z2M).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Prázdné = odebírat přímo prefix (stav Z2M). Stejné jako téma pro publikování = použije se to.';

  @override
  String get tileSize => 'Velikost';

  @override
  String get tileSizeSmall => 'Malá';

  @override
  String get tileSizeWide => 'Široká';

  @override
  String get tileSizeFull => 'Plná';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — nejvýše jednou';

  @override
  String get panelFormQos1 => '1 — alespoň jednou';

  @override
  String get panelFormQos2 => '2 — právě jednou';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'Payload pro zapnuto';

  @override
  String get panelToggleOffPayload => 'Payload pro vypnuto';

  @override
  String get panelToggleJsonPath => 'Cesta JSON (volitelná)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'Shoda pro zapnuto';

  @override
  String get panelToggleOnMatchHelper =>
      'Hodnota na cestě JSON, která znamená „zapnuto“ (např. „ON“)';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Max';

  @override
  String get panelSliderStep => 'Krok';

  @override
  String get panelSliderTemplate => 'Šablona hodnoty';

  @override
  String get panelSliderTemplateHelper =>
      'Slovo value použij jako zástupný symbol — nahradí se hodnotou posuvníku';

  @override
  String get panelSliderJsonPath => 'Cesta JSON (volitelná)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'Cesta JSON (volitelná)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'např. „contact“, „occupancy“, „water_leak“';

  @override
  String get panelLedOnMatch => 'Shoda pro zapnuto';

  @override
  String get panelLedOnMatchHelper =>
      'Hodnota na cestě JSON, která rozsvítí LED (např. „true“, „ON“)';

  @override
  String get panelLedOnLabel => 'Popisek pro zapnuto (volitelný)';

  @override
  String get panelLedOnLabelHint => 'ZAP';

  @override
  String get panelLedOffLabel => 'Popisek pro vypnuto (volitelný)';

  @override
  String get panelLedOffLabelHint => 'VYP';

  @override
  String get panelNodeOnlinePayload => 'Payload pro online';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Hodnota, která znamená „online“ (výchozí v Z2M: „online“)';

  @override
  String get panelNodeJsonPath => 'Cesta JSON (volitelná)';

  @override
  String get panelNodeJsonPathHelper =>
      'Nech prázdné pro výchozí chování Z2M (prostý řetězec „online“/„offline“)';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Max';

  @override
  String get panelProgressUnit => 'Jednotka';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'Cesta JSON (volitelná)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'např. „battery“, „linkquality“';

  @override
  String get panelOptionsJsonPath => 'Cesta JSON (volitelná)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Pole v přijatém payloadu, které obsahuje aktuální hodnotu';

  @override
  String get panelOptionsHeader => 'Možnosti';

  @override
  String get panelOptionsLabel => 'Popisek';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Shoda (aktuální hodnota)';

  @override
  String get panelOptionsAdd => 'Přidat možnost';

  @override
  String get panelCoverDescription =>
      'Tlačítka OTEVŘÍT / STOP / ZAVŘÍT a řada předvoleb polohy. Používá standardní payloady rolet ze Z2M (state a position).';

  @override
  String get panelCoverPresets => 'Předvolby polohy';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Procenta oddělená čárkou (0–100). Prázdné = bez řady předvoleb.';

  @override
  String get panelCoverShowSlider => 'Zobrazit posuvník polohy';

  @override
  String get panelTextInputHint => 'Nápověda (volitelná)';

  @override
  String get panelTextInputHintHint => 'Zadej hodnotu…';

  @override
  String get panelTextInputTemplate => 'Šablona';

  @override
  String get panelTextInputTemplateHelper =>
      'Slovo value použij jako zástupný symbol — nahradí se zadaným textem. Ve výchozím stavu se publikuje samotný text.';

  @override
  String get panelTextInputClearAfterSend => 'Po odeslání vymazat';

  @override
  String get panelTextLogMaxLines => 'Max. řádků';

  @override
  String get panelTextLogMaxLinesHelper => 'Kolik posledních zpráv uchovat';

  @override
  String get panelTextLogJsonPath => 'Cesta JSON (volitelná)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Zaznamenávat jen toto pole místo celého payloadu';

  @override
  String get panelScheduleDescription =>
      'Běží na SMHUB přes Node-RED — spustí se, i když je telefon vypnutý. Téma pro publikování výše je cíl příkazů pro roletu.';

  @override
  String get panelScheduleOpenTime => 'Čas otevření';

  @override
  String get panelScheduleCloseTime => 'Čas zavření';

  @override
  String get panelScheduleOpenPayload => 'Payload pro otevření';

  @override
  String get panelScheduleClosePayload => 'Payload pro zavření';

  @override
  String get panelScheduleEnabled => 'Zapnuto';

  @override
  String get panelScheduleSavedOffline =>
      'Uloženo — bez připojení; plán se synchronizuje, až budeš online.';

  @override
  String get panelAutoCloseDescription =>
      'Běží na SMHUB přes Node-RED — spustí se, i když je telefon vypnutý. Téma pro publikování výše je cíl příkazů zařízení (např. dveří).';

  @override
  String get panelAutoCloseTriggerPath => 'Cesta JSON spouštěče';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Pole ve stavovém JSON zařízení, které se sleduje (výchozí: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Hodnota spouštěče';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Spustí časovač, když se pole spouštěče rovná této hodnotě (výchozí: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Payload pro zavření';

  @override
  String get panelAutoCloseDelaySeconds => 'Prodleva (sekundy)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1-3600. Jak dlouho po zapnutí zařízení čekat, než se publikuje payload pro zavření.';

  @override
  String get panelAutoCloseEnabled => 'Zapnuto';

  @override
  String get panelAutoCloseSavedOffline =>
      'Uloženo — bez připojení; pravidlo se synchronizuje, až budeš online.';

  @override
  String get panelTileEdit => 'Upravit panel';

  @override
  String get panelTileDuplicate => 'Duplikovat panel';

  @override
  String get panelTileMoveUp => 'Posunout nahoru';

  @override
  String get panelTileMoveDown => 'Posunout dolů';

  @override
  String get panelTileDelete => 'Smazat panel';

  @override
  String get panelCoverOpen => 'Otevřít';

  @override
  String get panelCoverStop => 'Stop';

  @override
  String get panelCoverClose => 'Zavřít';

  @override
  String get panelToggleNoState => '(bez stavu)';

  @override
  String get panelToggleError => 'chyba';

  @override
  String get panelStateOn => 'ZAP';

  @override
  String get panelStateOff => 'VYP';

  @override
  String get panelNodeStatusOnline => 'online';

  @override
  String get panelNodeStatusOffline => 'offline';

  @override
  String get panelNodeStatusUnknown => 'neznámý';

  @override
  String get panelNodeStatusError => 'chyba';

  @override
  String get panelMultiStateNoOptions => 'Nejsou nastavené žádné možnosti';

  @override
  String get panelTextInputDefaultHint => 'Zadej hodnotu…';

  @override
  String get panelTextLogWaiting => 'Čekám na zprávy…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Otevře v $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Zavře v $time';
  }

  @override
  String get panelScheduleOfflineWarning => 'Plánovač je offline — nespustí se';

  @override
  String get panelScheduleDisabled => 'Vypnuto';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Další: $action v $at';
  }

  @override
  String get panelScheduleActionOpen => 'otevřít';

  @override
  String get panelScheduleActionClose => 'zavřít';

  @override
  String get panelAutoCloseIdle => 'Nečinné';

  @override
  String get panelAutoCloseDisabled => 'Vypnuto';

  @override
  String get panelAutoCloseOffline =>
      'Automatizace je offline — pravidlo se nespustí';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Zavře se za $seconds s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Zavírám…';

  @override
  String get panelGridEmpty =>
      'Zatím žádné dlaždice.\nKlepni na Přidat dlaždici a dej sem svá zařízení.';

  @override
  String get panelsOffline => 'Offline — zobrazují se poslední hodnoty';

  @override
  String get connectionConnecting => 'Připojování…';

  @override
  String get connectionReconnecting => 'Znovu se připojuje…';

  @override
  String get connectionShowingLastKnownValues =>
      'Zobrazují se naposledy známé hodnoty';

  @override
  String get connectionFailed => 'Připojení selhalo';

  @override
  String get connectionAutomaticRetry => 'Automatické opakování pokračuje';

  @override
  String get connectionReconnectNow => 'Znovu připojit';

  @override
  String get settingsAbout => 'O aplikaci';

  @override
  String get settingsHelp => 'Nápověda a průvodce';

  @override
  String get settingsVersion => 'Verze';

  @override
  String get settingsRateApp => 'Ohodnotit ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Líbí se ti? Krátká recenze pomůže ostatním ho najít.';

  @override
  String get settingsFeatureRequest => 'Navrhnout funkci';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Napiš mi, co by ZigDash vylepšilo.';

  @override
  String get featureRequestGithub => 'Na GitHubu';

  @override
  String get featureRequestGithubSubtitle =>
      'Veřejně: ostatní to uvidí a můžou pro to hlasovat.';

  @override
  String get featureRequestEmail => 'E-mailem';

  @override
  String get featureRequestEmailSubtitle => 'Soukromě, přímo vývojáři.';

  @override
  String get featureRequestEmailSubject => 'ZigDash – návrh funkce';

  @override
  String get featureRequestEmailPrompt =>
      'Co bys chtěl, aby ZigDash uměl, a proč?';

  @override
  String get settingsReportProblem => 'Nahlásit problém';

  @override
  String get settingsReportProblemSubtitle =>
      'Něco nefunguje nebo je to matoucí? Napiš mi.';

  @override
  String get reportProblemEmailSubject => 'ZigDash – hlášení problému';

  @override
  String get reportProblemEmailPrompt => 'Co se stalo a co jsi čekal?';

  @override
  String get settingsBuyCoffee => 'Kup mi kávu';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Zdarma a open source — díky spropitnému to jede dál.';

  @override
  String get a11yBackupMenu => 'Záloha a obnovení';

  @override
  String get a11ySelectColor => 'Vybrat barvu';

  @override
  String get a11ySelectIcon => 'Vybrat ikonu';

  @override
  String get a11yDeleteOption => 'Smazat možnost';

  @override
  String get a11yPanelOptions => 'Možnosti panelu';

  @override
  String get a11yMoreOptions => 'Další možnosti';

  @override
  String get a11yRefresh => 'Obnovit';

  @override
  String get a11yDeleteConnection => 'Smazat připojení';

  @override
  String get controlNotConnected => 'Bez připojení — změna nebyla odeslána';

  @override
  String get discoverFromDevice => 'Přidat ze zařízení…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Automaticky rozpoznat zařízení Zigbee2MQTT';

  @override
  String get discoverTitle => 'Přidat ze zařízení';

  @override
  String get discoverBaseTopic => 'Základní téma Zigbee2MQTT';

  @override
  String get discoverScanning => 'Hledám zařízení…';

  @override
  String get discoverNone => 'Nenalezena žádná zařízení.';

  @override
  String get discoverFailed =>
      'Seznam zařízení nenalezen. Zkontroluj základní téma a jestli je broker připojený.';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get previewTitle => 'Živý náhled';

  @override
  String previewWaiting(Object topic) {
    return 'Čekám na zprávu na $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Získáno ($path): $value';
  }

  @override
  String get previewNoValue => '(na této cestě není hodnota)';

  @override
  String get connErrorTitle => 'Chyba připojení';

  @override
  String get connErrorUnknown => 'Podrobnosti o chybě nejsou k dispozici.';

  @override
  String get connTestButton => 'Otestovat připojení';

  @override
  String get connTestOk => 'Připojení proběhlo úspěšně';

  @override
  String connTestFailed(Object error) {
    return 'Připojení selhalo: $error';
  }

  @override
  String get devicesTitle => 'Zařízení';

  @override
  String get devicesAddButton => 'Přidat zařízení';

  @override
  String get devicesPairingTitle => 'Párování — stiskni tlačítko na zařízení';

  @override
  String devicesPairingHint(int seconds) {
    return 'Hledám nová zařízení… $seconds s';
  }

  @override
  String get devicesPairingStop => 'Stop';

  @override
  String get devicesNone => 'Nenalezena žádná zařízení.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT neposlal seznam zařízení. To se může stát po restartu MQTT brokeru.';

  @override
  String get devicesRestartZ2m => 'Restartovat Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Restartuji Zigbee2MQTT. Tvoje zařízení by se měla za pár sekund objevit.';

  @override
  String get devicesBattery => 'Baterie';

  @override
  String get devicesLinkQuality => 'Signál';

  @override
  String get devicesOnline => 'Online';

  @override
  String get devicesOffline => 'Offline';

  @override
  String devicesPaired(Object name) {
    return 'Připraveno: $name';
  }

  @override
  String get devicesPairedHint =>
      'Přidáno do tvé sítě. Pokud ho chceš dát na nástěnku, použij na té nástěnce „Přidat ze zařízení“.';

  @override
  String get scenesTitle => 'Scény';

  @override
  String get scenesNone =>
      'Zatím žádné scény. Nastav zařízení podle sebe a pak je ulož jako scénu.';

  @override
  String get scenesNewButton => 'Nová scéna';

  @override
  String scenesActivated(Object name) {
    return 'Aktivováno: $name';
  }

  @override
  String get scenesActivateOffline => 'Bez připojení — scénu nelze aktivovat';

  @override
  String get sceneFormNewTitle => 'Nová scéna';

  @override
  String get sceneFormEditTitle => 'Upravit scénu';

  @override
  String get sceneFormNameLabel => 'Název scény';

  @override
  String get sceneFormDevicesHeader => 'Zařízení k uložení';

  @override
  String get sceneFormCaptureHint =>
      'Uloží se aktuální nastavitelný stav každého vybraného zařízení (zap/vyp, jas, barva, poloha…). Hodnoty jen pro čtení se ignorují.';

  @override
  String get sceneFormNoDevices =>
      'Nenalezena žádná ovladatelná zařízení. Zkontroluj, že jsou spárovaná, a klepni na obnovit.';

  @override
  String get sceneFormReadingState => 'Načítám aktuální stav…';

  @override
  String get sceneCtrlPower => 'Napájení';

  @override
  String get sceneCtrlBrightness => 'Jas';

  @override
  String get sceneCtrlPosition => 'Poloha';

  @override
  String sceneFormSelectedCount(int count) {
    return 'Vybráno: $count';
  }

  @override
  String get sceneFormNoDevicesSelected =>
      'Vyber aspoň jedno zařízení k uložení.';

  @override
  String get sceneFormNothingCaptured =>
      'Z vybraných zařízení se nepodařilo uložit nic nastavitelného.';

  @override
  String get sceneDeleteTitle => 'Smazat scénu?';

  @override
  String sceneDeleteMessage(Object name) {
    return '„$name“ bude odstraněna. Zařízení si ponechají aktuální stav.';
  }

  @override
  String get sceneEditAction => 'Upravit';

  @override
  String get sceneDeleteAction => 'Smazat';

  @override
  String get sceneAddToDashboard => 'Přidat na nástěnku';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Přidáno na $name';
  }

  @override
  String sceneActionsCount(int count) {
    return 'Zařízení: $count';
  }

  @override
  String get scenesAllShutters => 'Všechny rolety';

  @override
  String get sceneCloseAllShutters => 'Zavřít všechny rolety';

  @override
  String get sceneOpenAllShutters => 'Otevřít všechny rolety';

  @override
  String get sceneStopAllShutters => 'Zastavit všechny rolety';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rolet',
      few: '$count rolety',
      one: '1 roleta',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Které rolety…';

  @override
  String get sceneWhichShuttersHint =>
      'Zahrnuté jsou všechny rolety v tomto domově. Odškrtni ty, které mají zůstat stranou, třeba garážová vrata.';

  @override
  String get scenesYours => 'Tvoje scény';

  @override
  String get panelTypeScene => 'Scéna';

  @override
  String get panelPickerSceneTitle => 'Tlačítko scény';

  @override
  String get panelPickerSceneSubtitle =>
      'Jedno klepnutí aktivuje uloženou scénu';

  @override
  String get panelSceneChoose => 'Scéna';

  @override
  String get panelSceneMissing => 'Scéna nenalezena — vyber ji znovu';

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
  String get guidedConnectTitle => 'Nastav svůj broker';

  @override
  String get guidedConnectIntro =>
      'Otestujeme každý krok připojení a ukážeme tvoje zařízení Zigbee.';

  @override
  String get guidedBaseTopic => 'Základní téma';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Otestovat a připojit';

  @override
  String get guidedTesting => 'Testuji připojení…';

  @override
  String get stepResolve => 'Překlad adresy hostitele';

  @override
  String get stepTcp => 'Připojení TCP';

  @override
  String get stepConnack => 'MQTT handshake';

  @override
  String get stepAuth => 'Ověření';

  @override
  String get stepDevices => 'Hledání zařízení';

  @override
  String get diagResolveFail =>
      'Název hostitele se nepodařilo přeložit. Zkontroluj zadanou adresu.';

  @override
  String get diagResolveTimeout =>
      'Překlad názvu hostitele vypršel. Zkontroluj adresu a svou síť.';

  @override
  String get diagTcpFail =>
      'Broker není dostupný. Běží Zigbee2MQTT? Zkontroluj adresu a port.';

  @override
  String get diagTcpTimeout =>
      'Připojení k brokeru vypršelo. Může být offline nebo nedostupný.';

  @override
  String get diagConnackFail =>
      'Broker nedokončil MQTT handshake. Zkontroluj, že jde o MQTT broker (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'Broker neodpověděl na přihlášení včas. Home Assistantu může ověření trvat pár sekund, tak to zkus znovu.';

  @override
  String get diagAuthRejected =>
      'Broker odmítl uživatelské jméno nebo heslo. Zkontroluj přihlašovací údaje.';

  @override
  String get diagAuthRefused =>
      'Broker odmítl připojení. Zkontroluj nastavení připojení.';

  @override
  String get diagResolveLocalName =>
      'Telefon tento název nenašel. Android často neumí vyhledat názvy končící na .local, takže místo toho zadej IP adresu (Home Assistant ji ukazuje v Nastavení › Systém › Síť).';

  @override
  String get diagTcpHaNoBroker =>
      'Tohle je tvůj Home Assistant, ale neběží na něm žádný MQTT broker. Nainstaluj a spusť doplněk Mosquitto broker (Nastavení › Doplňky) a zkus to znovu.';

  @override
  String get diagTcpSmlightClosed =>
      'Tohle je tvůj hub SMLIGHT, ale jeho MQTT broker nepřijímá připojení z jiných zařízení. Na webové stránce hubu otevři Settings › MQTT, zapni Allow External, ulož a zkus to znovu.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Na této adrese běží Zigbee2MQTT, ale ke svému brokeru se připojuje pod jiným jménem (viz Zigbee2MQTT › Settings › MQTT › Server). Pokud je to jiný počítač, zadejte jeho adresu, obvykle s portem 1883. Pokud je to kontejner na tomto počítači, zveřejněte jeho port (ports: \"1883:1883\") a povolte mu naslouchat v síti, pak to zkuste znovu.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Na této adrese běží Zigbee2MQTT, ale jeho MQTT broker nepřijímá připojení z jiných zařízení. Mosquitto naslouchá jen na svém vlastním počítači, dokud do mosquitto.conf nepřidáš řádky \"listener 1883\" a \"allow_anonymous true\" (nebo nenastavíš heslo). Restartuj Mosquitto a zkus to znovu.';

  @override
  String get diagAuthRejectedHa =>
      'Broker Home Assistantu toto přihlášení odmítl. Použij jméno a heslo uživatele Home Assistantu (Nastavení › Osoby › Uživatelé); nejlépe funguje samostatný uživatel jen pro MQTT.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nalezeno $count zařízení',
      few: 'Nalezena $count zařízení',
      one: 'Nalezeno 1 zařízení',
    );
    return '$_temp0';
  }

  @override
  String get foundDevicesHint =>
      'Tvoje zařízení Zigbee jsou vidět. Pokračuj a sestav si nástěnku.';

  @override
  String get noDevicesTitle => 'Připojeno — zatím žádná zařízení';

  @override
  String get noDevicesHint =>
      'ZigDash vidí tvůj broker, ale zatím nenašel žádná zařízení Zigbee. Můžeš spustit párování a přidat je.';

  @override
  String get startPairing => 'Spustit párování';

  @override
  String get pairingEnabled =>
      'Párování je zapnuté. Stiskni párovací tlačítko na zařízení, aby se připojilo.';

  @override
  String get continueToDashboard => 'Pokračovat na nástěnku';

  @override
  String get guidedBackToForm => 'Upravit nastavení';

  @override
  String get guidedStuckTitle => 'Zasekl ses? Zeptej se člověka';

  @override
  String get guidedStuckBody =>
      'Dva pokusy bez připojení. Napiš nám, jaký máš hub a co jsi zadal, a pomůžeme ti ho najít.';

  @override
  String get guidedStuckTelegram => 'Zeptat se na Telegramu';

  @override
  String get guidedStuckHelp => 'Tipy a e-mail';

  @override
  String ladderTriedHint(Object count) {
    return 'Vyzkoušené adresy: $count';
  }

  @override
  String get guidedSaveFailed =>
      'Připojení se nepodařilo uložit. Zkus to prosím znovu.';

  @override
  String get setupWelcomeTitle => 'Vítej v ZigDash';

  @override
  String get setupWelcomeHeadline => 'Tvůj Zigbee domov v telefonu';

  @override
  String get setupWelcomeBody =>
      'Stačí malý hub se Zigbee2MQTT: hub SMLIGHT, Raspberry Pi nebo jakýkoli linuxový počítač. Home Assistant nepotřebuješ, a pokud ho máš, ZigDash s ním funguje taky. Všechno zůstává lokálně, bez cloudu.';

  @override
  String get setupFindMySetup => 'Najít moje zařízení';

  @override
  String get setupErrPageTitle => 'Stránka Zigbee2MQTT neodpověděla';

  @override
  String get setupErrPageBody =>
      'Na této adrese neodpověděla žádná stránka Zigbee2MQTT. Otevřete ji v prohlížeči tohoto telefonu a zkontrolujte ji, a adresu zkopírujte přesně (i s portem, často 8080). Pokud stránka chce token, zadejte místo toho údaje brokeru.';

  @override
  String get setupErrPageAction => 'Zkusit znovu';

  @override
  String get setupLookWider => 'Hledat v celé síti';

  @override
  String get setupAsk => 'Co pohání vaše Zigbee?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'Na Raspberry Pi, serveru nebo v Dockeru';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'S doplňkem Zigbee2MQTT, nebo ZHA';

  @override
  String get setupAskSmlight => 'Hub SMLIGHT';

  @override
  String get setupAskSmlightSub => 'SLZB nebo SMHUB se Zigbee2MQTT';

  @override
  String get setupAskNothing => 'Zatím nic?';

  @override
  String get setupAskHaWhich => 'Jak váš Home Assistant provozuje Zigbee?';

  @override
  String get setupAskHaZ2m => 'Doplněk Zigbee2MQTT';

  @override
  String get setupAskHaZ2mSub => 'Přihlásit se přes Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, vlastní Zigbee Home Assistantu';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, bez Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Připojit se k mé stránce Zigbee2MQTT';

  @override
  String get setupManualEntryAdvanced => 'Zadat údaje brokeru (pokročilé)';

  @override
  String get z2mPageTitle => 'Vaše stránka Zigbee2MQTT';

  @override
  String get z2mPageBody =>
      'Adresa v prohlížeči, když máte otevřenou stránku Zigbee2MQTT – tu, kde párujete zařízení. Není potřeba uživatelské jméno ani heslo MQTT.';

  @override
  String get z2mPageLabel => 'Adresa stránky';

  @override
  String get z2mPageConnect => 'Připojit';

  @override
  String z2mPageFoundName(String host, String ip) {
    return '$host nalezen na $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Pro $host v této síti nic neodpovědělo';
  }

  @override
  String get engineNeedsBrokerTitle => 'Automatizace potřebují váš MQTT broker';

  @override
  String get engineNeedsBrokerBody =>
      'Tento domov se připojuje přes stránku Zigbee2MQTT, což dashboardům stačí. Automatizace, upozornění a historie běží v ZigDash Engine na vašem hubu, který komunikuje přes váš MQTT broker. Zadejte jeho údaje jednou a ZigDash se od té doby bude připojovat přes broker.';

  @override
  String get engineNeedsBrokerButton => 'Zadat údaje brokeru';

  @override
  String get connFromPageNote =>
      'Tento domov se připojuje přes stránku Zigbee2MQTT. Zadejte svůj MQTT broker (obvykle stejný stroj, port 1883), abyste zapnuli automatizace, upozornění a historii. Po uložení se ZigDash připojuje přes broker.';

  @override
  String get setupManualEntry => 'Zadat údaje ručně';

  @override
  String get setupScanningTitle => 'Hledám připojení…';

  @override
  String get setupScanningHint =>
      'Měj toto zařízení ve stejné místní síti jako hostitele se Zigbee2MQTT.';

  @override
  String get setupCandidateFound => 'Nalezeno možné připojení';

  @override
  String get setupNoCandidatesTitle => 'Nenalezeno žádné připojení';

  @override
  String get setupNoCandidatesBody => 'Kde běží Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: zkontroluj, že doplněk MQTT brokeru (např. Mosquitto) a doplněk Zigbee2MQTT jsou nainstalované a běží.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: zkontroluj, že tvůj broker (např. Mosquitto) a služba Zigbee2MQTT běží a že je port 1883 dostupný.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: otevři webové rozhraní zařízení, jdi do Settings > MQTT, zapni Allow External, aby telefon na broker dosáhl, a zkontroluj, že Zigbee2MQTT běží.';

  @override
  String get setupTryAgain => 'Zkusit znovu';

  @override
  String get reminderButton => 'Připomeň mi to zítra';

  @override
  String get reminderSet => 'Zítra ti to připomeneme, na tomto telefonu.';

  @override
  String get reminderNoPermission =>
      'Oznámení ZigDash jsou vypnutá, takže připomenutí nebude. Můžeš je zapnout v nastavení Androidu.';

  @override
  String get reminderChannel => 'Připomenutí nastavení';

  @override
  String get reminderTitle => 'Dokonči nastavení ZigDash';

  @override
  String get reminderBody =>
      'Jsi doma na své Wi-Fi? Klepni a zkus to znovu: zabere to asi minutu.';

  @override
  String get setupWelcomeNoZ2m => 'Ještě nemáš Zigbee2MQTT?';

  @override
  String get setupWelcomeDemo => 'Vyzkoušet ukázkovou domácnost';

  @override
  String get setupWelcomeHubs => 'Jaký hub vybrat';

  @override
  String get haConnectTitle => 'Připojit přes Home Assistant';

  @override
  String get haConnectIntro =>
      'Tvůj telefon na broker nedosáhne, ale na Home Assistant ano. Přihlas se jednou a ZigDash bude se Zigbee2MQTT mluvit přes Home Assistant: doma i mimo domov, bez nastavení brokeru.';

  @override
  String get haConnectAddressHelp =>
      'Adresa, kterou otevíráš Home Assistant: 192.168.1.20:8123, nebo vzdálená adresa, třeba tvoje adresa Nabu Casa nebo Cloudflare';

  @override
  String get haConnectSignInHelp =>
      'Vlastní přihlášení Home Assistantu se otevře v prohlížeči. ZigDash tvoje heslo nikdy nevidí.';

  @override
  String get haConnectKeeps =>
      'ZigDash si toto přihlášení ponechá v telefonu a jedná v Home Assistantu tvým jménem, jen pro MQTT. Ukončit to můžeš kdykoli v Home Assistantu v Profil › Zabezpečení.';

  @override
  String get haConnectTokenHelp =>
      'V Home Assistantu otevři svůj profil, pak Zabezpečení › Dlouhodobé přístupové tokeny › Vytvořit token. Zkopíruj ho a vlož sem. ZigDash si ho ponechá v tomto telefonu pro připojení; smaž ho v Home Assistantu, kdykoli to budeš chtít ukončit.';

  @override
  String get haConnectWithToken => 'Připojit s tokenem';

  @override
  String get haConnectChecking => 'Kontroluji Home Assistant…';

  @override
  String get setupStillChecking => 'Stále ověřuji. Může to trvat až 30 sekund.';

  @override
  String get aiHelpTitle => 'Zaseknuto? Zeptejte se svého AI asistenta';

  @override
  String get aiHelpBody =>
      'ZigDash sepíše, co našel, pro ChatGPT, Claude, Gemini nebo jinou AI aplikaci, bez hesel a adres. Uvidíte to dřív, než to sdílíte.';

  @override
  String get aiHelpButton => 'Zeptat se AI';

  @override
  String get aiHelpPreviewTitle => 'Co se bude sdílet';

  @override
  String get aiHelpShare => 'Sdílet do AI aplikace';

  @override
  String get aiHelpCopied => 'Zkopírováno. Vložte to do libovolného AI chatu.';

  @override
  String get haConnectWhereAddress =>
      'Nevíte, jaká je? V aplikaci Home Assistant otevřete Nastavení › Doprovodná aplikace a klepněte na svůj server: adresa je tam. Na počítači je to adresa, kterou prohlížeč ukazuje při otevřeném Home Assistantu.';

  @override
  String get haFindLooking => 'Hledám Home Assistant v této síti…';

  @override
  String get haFindSeveral =>
      'Nalezeno více instancí Home Assistant. Klepněte na tu, kterou chcete použít:';

  @override
  String get haFindNone =>
      'Tento telefon v této Wi-Fi Home Assistant nevidí. Použijte adresu, kterou otevírá vaše aplikace Home Assistant: často vzdálenou, například https://abcd1234.ui.nabu.casa nebo https://mujdum.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Tato adresa je v jiné síti než tento telefon, který je v $network. Použijte adresu, kterou otevírá vaše aplikace Home Assistant, často vzdálenou, nebo připojte telefon k síti, ve které je Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Tento telefon to jméno nenašel: Android často neotevře jména .local. Zadejte IP adresu Home Assistantu (například 192.168.1.20:8123) nebo jeho vzdálenou adresu.';

  @override
  String get haConnectRemoteUnreachable =>
      'Na této vzdálené adrese nic neodpovědělo. Otevřete ji v prohlížeči tohoto telefonu a ověřte, že funguje, a zkopírujte ji přesně tak, jak ji ukazuje vaše aplikace Home Assistant.';

  @override
  String get setupNoWifiHa => 'Používáte Home Assistant? Přihlásit se';

  @override
  String get haConnectNotAdmin =>
      'Tvůj uživatel v Home Assistantu není správce. ZigDash správce potřebuje pro MQTT Home Assistantu. Přihlas se jako správce, nebo vlož token, který správce vytvořil.';

  @override
  String get haConnectNoMqtt =>
      'Tento Home Assistant nemá integraci MQTT. Zigbee2MQTT ji potřebuje taky: v Home Assistantu přidej doplněk Mosquitto broker a integraci MQTT a zkus to znovu.';

  @override
  String get haConnectSignInFailed =>
      'Přihlášení se nedokončilo. Zkus to znovu, nebo použij dlouhodobý token.';

  @override
  String get setupHaShortcut =>
      'Zigbee2MQTT běží v Home Assistant? Přeskočte broker a jeho přihlášení: přihlaste se účtem správce Home Assistant. Funguje z jakékoli sítě.';

  @override
  String get haConnectButton => 'Připojit přes Home Assistant';

  @override
  String get haConnectManualLink =>
      'Používáš Home Assistant? Připoj se raději přes něj';

  @override
  String get haConnectEmptyNote =>
      'Tento telefon na broker nedosáhne? Home Assistant může připojení přenést za tebe.';

  @override
  String get haHomeConnected => 'Připojeno přes Home Assistant';

  @override
  String get haHomeChange =>
      'Pokud přihlášení přestane fungovat, na novém telefonu nebo po odstranění tokenu v Home Assistantu, přihlas se znovu zde. Ukončit ho můžeš i v Home Assistantu v Profil › Zabezpečení.';

  @override
  String get haHomeSignInAgain => 'Přihlásit se znovu';

  @override
  String get haHomeRemote => 'Vzdálená adresa Home Assistantu (nepovinné)';

  @override
  String get setupAuthTitle => 'Tento broker vyžaduje přihlášení';

  @override
  String setupAuthBody(Object host) {
    return 'Zadej uživatelské jméno a heslo MQTT pro $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Uživatelské jméno nebo heslo bylo odmítnuto. Zkontroluj je a zkus to znovu.';

  @override
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT se k tomuto brokeru už přihlašuje: jeho webová stránka ukazuje uživatelské jméno v Settings › MQTT. Použij tohoto uživatele a jeho heslo.';

  @override
  String get setupAuthWhich =>
      'Jde o přihlášení k MQTT, ne o heslo k webové stránce hubu.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: použij uživatele Home Assistantu. Většina lidí si vytvoří samostatného jen pro MQTT v Nastavení › Osoby › Uživatelé a doplněk Mosquitto ho přijme.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi nebo Docker: uživatel a heslo ze souboru s hesly Mosquitta, stejné jako v configuration.yaml Zigbee2MQTT v sekci mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: přihlášení zobrazené na webové stránce hubu v Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'Kontroluji připojení…';

  @override
  String get setupReviewTitle => 'Tvoje zařízení';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nalezeno $count zařízení.',
      few: 'Nalezena $count zařízení.',
      one: 'Nalezeno 1 zařízení.',
    );
    return '$_temp0 Vyber, co bude na tvé první nástěnce.';
  }

  @override
  String get setupReviewLastStep =>
      'Poslední krok: zaškrtněte zařízení, která chcete, a dole klepněte na Vytvořit nástěnku.';

  @override
  String get setupLeaveTitle => 'Vytvořit nástěnku?';

  @override
  String get setupLeaveBody =>
      'Vaše zařízení jsou nalezena. Vytvořte nástěnku hned, nebo začněte nastavení znovu a tento seznam ztratíte.';

  @override
  String get setupStartOver => 'Začít znovu';

  @override
  String setupCreateWithCount(Object count) {
    return 'Vytvořit nástěnku ($count)';
  }

  @override
  String get setupReviewNoneSelected =>
      'Zatím není nic zaškrtnuto. Zaškrtněte zařízení, která chcete na nástěnce, nebo ji vytvořte prázdnou a dlaždice přidejte později.';

  @override
  String get setupCreateEmpty => 'Vytvořit prázdnou nástěnku';

  @override
  String get setupGroupOther => 'Další zařízení';

  @override
  String get setupGroupUnsupported => 'Nepodporovaná zařízení';

  @override
  String get setupCreatingTitle => 'Vytvářím tvou nástěnku…';

  @override
  String get setupReadyTitle => 'Tvoje nástěnka je připravená';

  @override
  String setupReadyBody(Object count) {
    return 'Vytvořené ovládací prvky: $count.';
  }

  @override
  String get setupOpenDashboard => 'Otevřít nástěnku';

  @override
  String get setupErrUnreachableTitle => 'Tato adresa není dostupná';

  @override
  String get setupErrUnreachableBody =>
      'Toto zařízení a hostitel se Zigbee2MQTT se navzájem nevidí. Zkontroluj, že jsou oba ve stejné místní síti.';

  @override
  String get setupErrUnreachableAction => 'Zkusit znovu';

  @override
  String get setupErrPortClosedTitle => 'Na tomto portu nic neodpovídá';

  @override
  String get setupErrPortClosedBody =>
      'Hostitel je dostupný, ale žádný MQTT broker neodpověděl. Zkontroluj, že broker běží a že je port správně.';

  @override
  String get setupErrPortClosedAction => 'Zkusit znovu';

  @override
  String get setupErrAuthRequiredTitle => 'Vyžaduje se přihlášení';

  @override
  String get setupErrAuthRequiredBody =>
      'Tento broker vyžaduje uživatelské jméno a heslo.';

  @override
  String get setupErrAuthRequiredAction => 'Zadat přihlášení';

  @override
  String get setupErrAuthRejectedTitle => 'Přihlášení odmítnuto';

  @override
  String get setupErrAuthRejectedBody =>
      'Broker tyto přihlašovací údaje odmítl.';

  @override
  String get setupErrAuthRejectedAction => 'Zkusit znovu';

  @override
  String get setupErrNotZ2mTitle => 'Tady není Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'Odpovídá tu MQTT broker, ale témata Zigbee2MQTT nebyla nalezena. Možná jde o jiný broker.';

  @override
  String get setupErrNotZ2mAction => 'Vybrat jiný';

  @override
  String get setupErrNoDevicesTitle => 'Nepřišla žádná zařízení';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT běží, ale během kontroly nepublikoval žádná zařízení. Nejdřív spáruj zařízení v Zigbee2MQTT.';

  @override
  String get setupErrNoDevicesAction => 'Zkontrolovat znovu';

  @override
  String get setupErrListMissingTitle => 'Zigbee2MQTT neposlal seznam zařízení';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT odpovídá, ale jeho seznam zařízení nepřišel. Obvykle se to stane po restartu MQTT brokeru: Zigbee2MQTT před verzí 2.14.2 pošle seznam znovu až po svém vlastním restartu. Restartujte Zigbee2MQTT (nebo ho aktualizujte) a zkuste to znovu.';

  @override
  String get setupErrListMissingAction => 'Zkusit znovu';

  @override
  String get setupErrHaNoZ2mTitle => 'V tomto Home Assistantu není Zigbee2MQTT';

  @override
  String get setupErrHaNoZ2mBody =>
      'Jste přihlášeni do Home Assistantu, ale Zigbee2MQTT přes jeho MQTT nic neposílá. Pokud máte zařízení Zigbee v ZHA (vestavěném Zigbee Home Assistantu), ZigDash je nevidí: pracuje se Zigbee2MQTT. Pokud používáte doplněk Zigbee2MQTT, otevřete ho v Home Assistantu, zkontrolujte, že běží, a zkuste to znovu.';

  @override
  String get setupErrHaNoZ2mAction => 'Zkusit znovu';

  @override
  String get setupErrScanFailedTitle => 'Žádná místní síť';

  @override
  String get setupErrScanFailedBody =>
      'Nepodařilo se zjistit místní síť tohoto zařízení. Připoj se k Wi-Fi a zkus to znovu.';

  @override
  String get setupErrScanFailedAction => 'Zkusit znovu';

  @override
  String get setupNoWifiTitle => 'Tvůj telefon není na Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'Používá mobilní data, takže nevidí zařízení doma. Zapni Wi-Fi a připoj se k domácí síti: nastavení se spustí znovu samo.';

  @override
  String get setupNoWifiOffline =>
      'Tvůj telefon nemá připojení k síti. Zapni Wi-Fi a připoj se k domácí síti: nastavení se spustí znovu samo.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash nemůže najít Wi-Fi adresu tvého telefonu. Zkontroluj, že je Wi-Fi zapnutá a připojená k domácí síti: nastavení se spustí znovu samo. Máš zapnutou VPN nebo nejsi doma? Zadej údaje ručně.';

  @override
  String get setupOpenWifiSettings => 'Otevřít nastavení Wi-Fi';

  @override
  String get setupWaitingForWifi => 'Čekám na Wi-Fi…';

  @override
  String get setupErrSaveFailedTitle => 'Uložení se nepodařilo';

  @override
  String get setupErrSaveFailedBody =>
      'Uložení nastavení selhalo. Nic nezůstalo napůl uložené — můžeš to klidně zkusit znovu.';

  @override
  String get setupErrSaveFailedAction => 'Zkusit znovu';

  @override
  String get setupErrUnknownTitle => 'Něco se pokazilo';

  @override
  String get setupErrUnknownBody => 'Došlo k neočekávané chybě.';

  @override
  String get setupErrUnknownAction => 'Zkusit znovu';

  @override
  String get setupErrLoginNoAnswerTitle => 'Broker neodpověděl na přihlášení';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Tvůj broker byl nalezen, ale na uživatelské jméno a heslo neodpověděl včas. Doplněk Mosquitto v Home Assistantu ověřuje přihlášení přes Home Assistant, což na Raspberry Pi může trvat pár sekund. Zkus to znovu a zkontroluj, že tento uživatel v Home Assistantu existuje.';

  @override
  String get setupErrLoginNoAnswerAction => 'Zkusit znovu';

  @override
  String get setupNoZ2mTitle =>
      'Tvůj broker funguje, ale Zigbee2MQTT sem nepublikuje';

  @override
  String setupNoZ2mBody(String base) {
    return 'Poslouchali jsme na $base/bridge a nic jsme nezachytili.';
  }

  @override
  String get setupBaseTopicQuestion => 'Používáš jiné základní téma?';

  @override
  String get setupGuidesTitle => 'Nastavit Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'Mezitím si vyzkoušej demo';

  @override
  String get setupPlatformQuestion => 'Zatímco hledáme: kde běží Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => 'Kde běží Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Vyber připojení';

  @override
  String get setupScanDoneHint =>
      'Odpověděl víc než jeden broker. Vyber ten, který používá Zigbee2MQTT.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'Hub SMLIGHT';

  @override
  String get setupPlatformPi => 'Raspberry Pi nebo Docker';

  @override
  String get setupPlatformZha => 'ZHA, bez Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash zobrazuje zařízení ze Zigbee2MQTT, takže nevidí zařízení v ZHA, vlastním Zigbee Home Assistantu. Můžeš vyzkoušet ukázkovou domácnost a podívat se, jak ZigDash funguje.';

  @override
  String get setupPlatformNotSure => 'Nevím';

  @override
  String setupScanProgress(int checked, int total) {
    return 'Zkontrolováno $checked z $total adres';
  }

  @override
  String get setupScanHintHa => 'Hledám Home Assistant a jeho MQTT broker…';

  @override
  String get setupScanHintSmlight => 'Hledám tvůj hub SMLIGHT…';

  @override
  String get setupScanHintPi => 'Hledám MQTT broker ve tvé síti…';

  @override
  String setupHubSeenHa(String host) {
    return 'Nalezen Home Assistant na $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Nalezen Zigbee2MQTT na $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Nalezen tvůj hub SMLIGHT na $host';
  }

  @override
  String get setupHubSeenHint => 'Ještě hledám jeho MQTT broker…';

  @override
  String get setupNoBrokerHaTitle =>
      'Home Assistant nalezen, ale bez MQTT brokeru';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant je na $host, ale na MQTT portu 1883 nic neodpovídá. V Home Assistantu otevři Nastavení › Doplňky, nainstaluj a spusť doplněk Mosquitto broker a zkus to znovu.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Používáš vlastní Zigbee Home Assistantu (ZHA) místo Zigbee2MQTT? ZigDash funguje jen se Zigbee2MQTT, takže zařízení ZHA nevidí. Demo ukazuje, co bys dostal.';

  @override
  String get setupVpnHint =>
      'Máš zapnutou VPN a ta může domácí síť před hledáním skrýt. Pokud jsi doma, vypni VPN a klepni na Zkusit znovu. Nebo ji nech zapnutou a v nastavení aplikace VPN povol přístup k místní síti (LAN).';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Zigbee2MQTT nalezen, ale jeho broker není dostupný';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT je na $host, ale jeho MQTT broker nepřijímá připojení z tvého telefonu. Mosquitto 2 poslouchá jen na samotném hubu, dokud jeho konfigurace neobsahuje \'listener 1883\' a \'allow_anonymous true\' (nebo přihlášení). Restartuj ho a zkus to znovu.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Hub SMLIGHT nalezen, ale MQTT je vypnuté';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Tvůj hub je na $host, ale jeho MQTT broker není dostupný. Ve webovém rozhraní hubu otevři Settings › MQTT, zapni Allow External, zkontroluj, že Zigbee2MQTT běží, a zkus to znovu.';
  }

  @override
  String get setupZ2mAsking => 'Ptám se Zigbee2MQTT, kde je jeho broker…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Tvůj broker přijímá připojení jen ze svého vlastního počítače';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT používá $server a z tvého telefonu tam nic neodpovídá. Mosquitto 2 to tak dělá ve výchozím stavu. Přidej tyto dva řádky do mosquitto.conf, restartuj Mosquitto a zkus to znovu:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Chceš raději přihlášení než otevřený přístup? Místo allow_anonymous použij password_file.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT se ke svému brokeru připojuje pod jménem, které váš telefon nemůže použít';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT používá $server. „$name“ je jméno, které zná jen počítač se Zigbee2MQTT, služba Dockeru nebo název hostitele. Zadejte místo něj IP adresu počítače s brokerem a port $port. Pokud broker běží v kontejneru, musí být jeho port také zveřejněn na počítači (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'Webová stránka Zigbee2MQTT je chráněna tokenem, takže aplikace nemohla zjistit, kde je její broker. Zadejte adresu brokeru z nastavení Zigbee2MQTT › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT používá broker na $server, ale z tvého telefonu neodpověděl. Zkontroluj, že broker běží a že je telefon ve stejné síti.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Připojit k $host';
  }

  @override
  String get setupNotFoundHa =>
      'V této síti nebyl nalezen žádný Home Assistant. Zkontroluj, že je telefon ve stejné Wi-Fi jako Home Assistant (ne v síti pro hosty), a zkus to znovu. Pokud znáš jeho adresu, zadej ji níže.';

  @override
  String get setupNotFoundSmlight =>
      'V této síti nebyl nalezen žádný hub SMLIGHT. Zkontroluj, že je hub zapnutý a telefon ve stejné Wi-Fi, a zkus to znovu. Pokud znáš jeho adresu, zadej ji níže.';

  @override
  String get setupNotFoundPi =>
      'V této síti nebyl nalezen žádný MQTT broker. Zkontroluj, že Mosquitto běží a poslouchá v síti (port 1883) a že je telefon ve stejné Wi-Fi, a zkus to znovu.';

  @override
  String get setupAddressQuestionHa => 'Kde otevíráš Home Assistant?';

  @override
  String get setupAddressQuestionSmlight => 'Jakou adresu má tvůj hub SMLIGHT?';

  @override
  String get setupAddressQuestionPi =>
      'Jakou adresu má počítač, na kterém běží Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      'Jakou adresu má tvůj hub nebo počítač, na kterém běží Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'Adresa jako 192.168.1.20, název nebo odkaz z prohlížeče';

  @override
  String get setupAddressCheck => 'Zkontrolovat adresu';

  @override
  String setupAddressNothing(String host) {
    return 'Na $host nic neodpovědělo. Zkontroluj adresu a jestli je telefon ve stejné Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return '$host se nepodařilo vyhledat. Názvy končící na .local na Androidu často nefungují; zkus místo toho IP adresu. Home Assistant ji ukazuje v Nastavení › Systém › Síť.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host z tohoto telefonu nelze najít; Android často neumí vyhledat názvy .local. Klepni výše na $button a použij adresu, kterou Home Assistant otevíráš v prohlížeči, nebo sem napiš jeho IP adresu. Home Assistant ji ukazuje v Nastavení › Systém › Síť.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host není ve tvé domácí síti. Použij adresu, která funguje na tvé Wi-Fi, ne vzdálený odkaz jako Nabu Casa nebo DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Nejdřív zadej adresu.';

  @override
  String get setupChoicesTitle => 'Co z toho na tebe sedí?';

  @override
  String get setupChoiceNoHub => 'Zatím nemám hub';

  @override
  String get setupChoiceNoHubSub =>
      'Podívej se na malé huby, na kterých běží Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'Používám Home Assistant';

  @override
  String get setupChoiceHaSub => 'Hledat ho na homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash se připojuje k MQTT brokeru Home Assistantu, doplňku Mosquitto broker v Nastavení › Doplňky, a Zigbee2MQTT ho musí používat také. Pokud se homeassistant.local nenajde, zadej níže IP adresu Home Assistantu. Najdeš ji v Nastavení › Systém › Síť.';

  @override
  String get setupChoiceOther => 'Můj hub je v jiné síti';

  @override
  String get setupChoiceOtherSub => 'Wi-Fi pro hosty nebo druhý router';

  @override
  String get setupChoiceOtherNote =>
      'Telefon musí na hub dosáhnout. Wi-Fi pro hosty nebo druhý router s vlastní Wi-Fi je od sebe oddělí. Připoj se k Wi-Fi, ve které je hub, a klepni na Zkusit znovu. Nebo níže zadej IP adresu hubu, případně zkus některý z těchto běžných názvů:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Tvůj telefon má $ip, takže adresa hubu obvykle začíná na $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Používáš Home Assistant? Hostitel je adresa, na které Home Assistant otevíráš, port 1883.';

  @override
  String get demoBannerText => 'Jsi v demo režimu';

  @override
  String get demoBannerAction => 'Připojit svůj domov';

  @override
  String get deviceOn => 'Zapnuto';

  @override
  String get deviceOff => 'Vypnuto';

  @override
  String get deviceOpen => 'Otevřeno';

  @override
  String get deviceClosed => 'Zavřeno';

  @override
  String get deviceMotion => 'Pohyb';

  @override
  String get deviceClear => 'Klid';

  @override
  String get deviceLeakDetected => 'Zjištěn únik vody';

  @override
  String get deviceSmokeDetected => 'Zjištěn kouř';

  @override
  String get deviceGasDetected => 'Zjištěn plyn';

  @override
  String get deviceWaiting => 'Čekám na první hlášení';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on zap · $off vyp';
  }

  @override
  String get deviceBrightness => 'Jas';

  @override
  String get deviceWhite => 'Bílá';

  @override
  String get deviceColor => 'Barva';

  @override
  String get deviceHue => 'Odstín';

  @override
  String get devicePosition => 'Poloha';

  @override
  String get deviceControls => 'Ovládání';

  @override
  String deviceBattery(int percent) {
    return 'Baterie $percent %';
  }

  @override
  String get deviceToggle => 'Zapnout nebo vypnout';

  @override
  String get deviceMore => 'Více';

  @override
  String get sectionLights => 'Světla';

  @override
  String get sectionSwitchesCovers => 'Spínače a rolety';

  @override
  String get sectionSensors => 'Senzory';

  @override
  String get sectionOther => 'Ostatní';

  @override
  String get homeFirstName => 'Můj domov';

  @override
  String homeNumberedName(int number) {
    return 'Domov $number';
  }

  @override
  String get dashAddTile => 'Přidat dlaždici';

  @override
  String get addTileSearch => 'Hledat zařízení';

  @override
  String get addTileNotOnDashboard => 'Není na nástěnce';

  @override
  String get addTileAllDevices => 'Všechna zařízení';

  @override
  String get addTileReading => 'Měření';

  @override
  String get addTileReadingSubtitle => 'Jedna hodnota ze zařízení nebo tématu';

  @override
  String get readingShowAs => 'Zobrazit jako';

  @override
  String get readingStyleValue => 'Hodnota';

  @override
  String get readingStyleGauge => 'Budík';

  @override
  String get gaugeBands => 'Barevná pásma';

  @override
  String get gaugeBandsHelper =>
      'Až tři. Pásmo, ve kterém je hodnota, obarví oblouk.';

  @override
  String get gaugeBandFrom => 'Od';

  @override
  String get gaugeBandTo => 'Do';

  @override
  String get gaugeBandAdd => 'Přidat pásmo';

  @override
  String get gaugeBandRemove => 'Odebrat pásmo';

  @override
  String get gaugeToneNormal => 'Normální';

  @override
  String get gaugeToneGood => 'Dobré';

  @override
  String get gaugeToneAttention => 'Pozor';

  @override
  String get addTileCustom => 'Vlastní MQTT dlaždice';

  @override
  String get addTileCustomSubtitle =>
      'Jakýkoli typ dlaždice, nastavený podle tématu';

  @override
  String get addTileNoDevices =>
      'Žádná zařízení k zobrazení. Připoj se k brokeru nebo spáruj zařízení v Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Přidat';

  @override
  String get addTileName => 'Název';

  @override
  String addTileNameHint(String model) {
    return 'např. $model';
  }

  @override
  String get addTileSection => 'Sekce';

  @override
  String get addTileNoSection => 'Bez sekce';

  @override
  String get addTileSize => 'Velikost';

  @override
  String get deviceClassColorLight => 'Barevné světlo';

  @override
  String get deviceClassLight => 'Světlo';

  @override
  String get deviceClassSwitch => 'Spínač nebo zásuvka';

  @override
  String get deviceClassCover => 'Roleta';

  @override
  String get deviceClassLeak => 'Únik vody nebo kouř';

  @override
  String get deviceClassContact => 'Kontakt';

  @override
  String get deviceClassMotion => 'Pohyb';

  @override
  String get deviceClassClimate => 'Senzor klimatu';

  @override
  String get deviceClassGeneric => 'Zařízení';

  @override
  String get deviceNotResponding => 'Neodpovídá';

  @override
  String get homeAdd => 'Přidat domov';

  @override
  String get homeManage => 'Spravovat domovy';

  @override
  String get homeSwitch => 'Přepnout domov';

  @override
  String get navDevices => 'Zařízení';

  @override
  String get navScenes => 'Scény';

  @override
  String get devicesNewDot => 'Nová zařízení';

  @override
  String get editEditing => 'Úpravy';

  @override
  String get editDashboard => 'Nástěnka';

  @override
  String get editDone => 'Hotovo';

  @override
  String get editAddSection => 'Přidat sekci';

  @override
  String get editSectionName => 'Název sekce';

  @override
  String get editRenameSection => 'Přejmenovat sekci';

  @override
  String get editDeleteSection => 'Smazat sekci';

  @override
  String get editDeleteSectionBody => 'Co se má stát s jejími dlaždicemi?';

  @override
  String get editKeepTiles => 'Ponechat dlaždice, odstranit sekci';

  @override
  String get editDeleteTiles => 'Smazat i dlaždice';

  @override
  String get editMoveToSection => 'Přesunout do sekce';

  @override
  String get editEditTile => 'Upravit dlaždici';

  @override
  String get editRemove => 'Odebrat z nástěnky';

  @override
  String get editRemoved => 'Dlaždice odebrána';

  @override
  String get editUndo => 'Zpět';

  @override
  String get editReplaceWithDevice => 'Nahradit dlaždicí zařízení';

  @override
  String get editMoveEarlier => 'Posunout dřív';

  @override
  String get editMoveLater => 'Posunout později';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zařízení není na žádné nástěnce',
      few: '$count zařízení nejsou na žádné nástěnce',
      one: '1 zařízení není na žádné nástěnce',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Možnosti dlaždice';

  @override
  String get editSave => 'Uložit';

  @override
  String get editCancel => 'Zrušit';

  @override
  String get ageJustNow => 'Právě teď';

  @override
  String ageMinutes(int n) {
    return 'před $n min';
  }

  @override
  String ageHours(int n) {
    return 'před $n h';
  }

  @override
  String get statusCantReach => 'Tvůj broker není dostupný';

  @override
  String get statusWhy => 'Proč?';

  @override
  String get statusWhyTitle => 'Tvůj broker neodpovídá';

  @override
  String get statusWhyBody =>
      'ZigDash to sám zkouší dál. Než se broker vrátí, dlaždice ukazují naposledy známé hodnoty, ztlumené a s jejich stářím. Zkontroluj, že je broker zapnutý a telefon ve stejné síti, nebo otestuj připojení v jeho nastavení.';

  @override
  String get statusSettings => 'Nastavení připojení';

  @override
  String get deviceAddToDashboard => 'Přidat na nástěnku';

  @override
  String get deviceDismiss => 'Zavřít';

  @override
  String get devicesFilterAll => 'Vše';

  @override
  String devicesFilterAttention(int count) {
    return 'Vyžaduje pozornost · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Není na nástěnce · $count';
  }

  @override
  String get devicesNoMatch => 'Žádné zařízení neodpovídá';

  @override
  String get deviceBatteryLow => 'Slabá baterie';

  @override
  String get deviceLinkWeak => 'Slabý';

  @override
  String get deviceUnsupported => 'Zigbee2MQTT nepodporuje';

  @override
  String get deviceInterviewFailed => 'Párování se nedokončilo';

  @override
  String get deviceNoReport => 'Zatím bez hlášení';

  @override
  String get devicesAvailabilityOff =>
      'Dostupnost (availability) je v Zigbee2MQTT vypnutá, takže zařízení offline se zobrazují jako Neodpovídá.';

  @override
  String get devicesAvailabilityHow => 'Jak ji zapnout';

  @override
  String get devicesDotBattery => 'Slabá baterie';

  @override
  String get deviceDetails => 'Podrobnosti zařízení';

  @override
  String get deviceGone => 'Toto zařízení už v Zigbee2MQTT není.';

  @override
  String get deviceControlTitle => 'Ovládání';

  @override
  String get deviceReadingsTitle => 'Měření';

  @override
  String get deviceHealthTitle => 'Stav';

  @override
  String get deviceOnDashboards => 'Na nástěnkách';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT toto zařízení zatím nepodporuje, takže není co ovládat.';

  @override
  String get deviceAddReadingTile => 'Přidat jako dlaždici měření';

  @override
  String get deviceAddReadingTo => 'Na kterou nástěnku přidat?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Přidáno na $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Kvalita signálu';

  @override
  String get deviceLinkGood => 'Dobrý';

  @override
  String get devicePowerSource => 'Zdroj napájení';

  @override
  String get devicePowerBattery => 'Baterie';

  @override
  String get devicePowerMains => 'Síť';

  @override
  String get deviceLastHeard => 'Naposledy ozvalo';

  @override
  String get deviceAvailability => 'Dostupnost';

  @override
  String get deviceAvailabilityOff => 'Vypnuto v Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Zásady ochrany soukromí';

  @override
  String get settingsPrivacySubtitle =>
      'Žádná telemetrie. Všechno zůstává v tomto telefonu.';

  @override
  String get homeCurrent => 'Aktuální domov';

  @override
  String get homeConnection => 'Připojení';

  @override
  String get homeSwitchTo => 'Přepnout na tento domov';

  @override
  String get homeDelete => 'Smazat domov';

  @override
  String get devicesSelect => 'Vyber zařízení';

  @override
  String get scenesSelect => 'Vyber scénu k úpravě';

  @override
  String get panelFormTopic => 'Téma';

  @override
  String get panelFormPickDevice => 'Vybrat zařízení';

  @override
  String get panelFormStateTopic => 'Téma stavu';

  @override
  String get panelFormCommandTopic => 'Téma příkazů';

  @override
  String get panelFormCommandTopicDerived =>
      'Vyplněno z tématu stavu, dokud ho nezměníš.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Propojeno se zařízením $device';
  }

  @override
  String get panelFormOpenDevice => 'Otevřít zařízení';

  @override
  String get panelFormUnlink => 'Odpojit';

  @override
  String get panelFormValueChoices => 'Hodnoty z tohoto zařízení';

  @override
  String get panelFormAdvanced => 'Pokročilé';

  @override
  String get panelFormAdvancedSubtitle => 'Vlastní prefix, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Prázdné = samotný prefix (stav zařízení Zigbee2MQTT).';

  @override
  String get dashWallDisplay => 'Nástěnný displej';

  @override
  String get analyticsSetupCheckbox =>
      'Sdílet anonymní data o používání a pomoct vylepšit nastavení';

  @override
  String get analyticsWhatsShared => 'Co se sdílí';

  @override
  String get analyticsCardTitle => 'Pomůžeš vylepšit ZigDash?';

  @override
  String get analyticsCardBody =>
      'Sdílej anonymní data o používání: které kroky nastavení selhávají a které funkce se používají. Nikdy tvoje zařízení, témata ani broker.';

  @override
  String get analyticsShare => 'Sdílet';

  @override
  String get analyticsNoThanks => 'Ne, díky';

  @override
  String get settingsAnalytics => 'Sdílet anonymní data o používání';

  @override
  String get settingsAnalyticsSubtitle =>
      'Kroky nastavení a používané funkce. Nikdy tvoje zařízení, témata ani broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Anonymní data o používání. Vypneš je přepínačem výše.';

  @override
  String get dashDefaultName => 'Domov';

  @override
  String get dashExportSaveFile => 'Uložit soubor';

  @override
  String get dashExportSaved => 'Záloha uložena';

  @override
  String get dashImportChooseFile => 'Vybrat soubor';

  @override
  String get dashImportFileUnreadable => 'Ten soubor se nepodařilo přečíst';

  @override
  String get getHelpTitle => 'Získat pomoc';

  @override
  String get getHelpTryFirst => 'Nejdřív zkus tohle';

  @override
  String get getHelpPromise =>
      'Pořád se nedaří? Obvykle odpovídám do 3 dnů, anglicky nebo hebrejsky. Nikdy tě nebudu žádat o hesla.';

  @override
  String get getHelpIncluded => 'Co je přiloženo';

  @override
  String get getHelpContact => 'Kontaktovat podporu';

  @override
  String get getHelpCopy => 'Kopírovat podrobnosti';

  @override
  String get getHelpCopied => 'Podrobnosti zkopírovány';

  @override
  String get getHelpLink => 'Pořád se nedaří? Získej pomoc';

  @override
  String get getHelpEmailSubject => 'ZigDash: pomoc se zprovozněním';

  @override
  String get getHelpEmailPrompt => 'Co ses snažil udělat a co se stalo?';

  @override
  String get settingsHelpSupport => 'Nápověda a podpora';

  @override
  String get settingsGetHelp => 'Získat pomoc';

  @override
  String get settingsGetHelpSubtitle =>
      'Nedaří se to zprovoznit? Nejdřív tipy, pak kontakt';

  @override
  String get settingsCommunity => 'Přidej se ke komunitě ZigDash';

  @override
  String get settingsCommunitySubtitle =>
      'Skupina na Telegramu: otázky, nápady a co se chystá';

  @override
  String get getHelpCommunity => 'Zeptat se ve skupině na Telegramu';

  @override
  String get demoBannerHelp => 'Získat pomoc';

  @override
  String get tipSameWifiTitle => 'Stejná Wi-Fi jako hub';

  @override
  String get tipSameWifiBody =>
      'Telefon musí být ve stejné síti jako hub, ne v síti pro hosty. Během nastavení vypni mobilní data.';

  @override
  String get tipBrokerRunningTitle => 'Broker běží';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: doplněk Mosquitto je spuštěný. Raspberry Pi: Mosquitto běží. SMLIGHT: Settings › MQTT je zapnuté.';

  @override
  String get tipBrokerAcceptsTitle => 'Broker přijímá tvůj telefon';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: zapni Allow External. Mosquitto 2 přijímá připojení jen ze samotného hubu, dokud ho nenastavíš, aby poslouchal v síti (port 1883).';

  @override
  String get tipMeshTitle => 'Mesh Wi-Fi nebo dva routery?';

  @override
  String get tipMeshBody =>
      'Pokud je hub připojený k druhému routeru, telefon ho nemusí vidět. Zapoj hub do hlavního routeru, nebo se připoj přes jeho adresu.';

  @override
  String get tipByAddressTitle => 'Připojení přes adresu';

  @override
  String get tipByAddressBody =>
      'Najdi adresu hubu v aplikaci routeru a pak klepni na Zadat údaje ručně.';

  @override
  String get tipSameNetworkTitle => 'Stejná síť';

  @override
  String get tipSameNetworkBody =>
      'Telefon a hub musí být ve stejné Wi-Fi. Vypni mobilní data.';

  @override
  String get tipAddressChangedTitle => 'Adresa se změnila';

  @override
  String get tipAddressChangedBody =>
      'Huby můžou po restartu dostat novou adresu. Zkontroluj ji v aplikaci routeru a rezervuj ji tam, aby zůstala stejná.';

  @override
  String get tipRightPortTitle => 'Správný port';

  @override
  String get tipRightPortBody =>
      'MQTT je obvykle na 1883 (8883 s TLS). 8080 nebo 80 je webová stránka hubu, ne MQTT.';

  @override
  String get tipStartBrokerTitle => 'Broker běží';

  @override
  String get tipStartBrokerBody =>
      'Spusť Mosquitto nebo doplněk brokeru a zkus to znovu.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 přijímá připojení jen ze samotného hubu, dokud ho nenastavíš, aby poslouchal v síti (port 1883).';

  @override
  String get tipMqttLoginTitle => 'Přihlášení k MQTT, ne k webu';

  @override
  String get tipMqttLoginBody =>
      'Heslo k webové stránce hubu obvykle není heslo k MQTT. Home Assistant: použij uživatele Home Assistantu nebo přihlášení nastavené v doplňku Mosquitto.';

  @override
  String get tipSpacesTitle => 'Zkontroluj mezery';

  @override
  String get tipSpacesBody =>
      'Při kopírování hesla se může na konec přidat mezera.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT používá tento broker';

  @override
  String get tipZ2mBrokerBody =>
      'V nastavení Zigbee2MQTT zkontroluj, že jeho MQTT server je tentýž broker.';

  @override
  String get tipBaseTopicTitle => 'Základní téma';

  @override
  String get tipBaseTopicBody =>
      'Pokud jsi základní téma změnil z „zigbee2mqtt“, zadej ho v ručním nastavení.';

  @override
  String get tipPairFirstTitle => 'Nejdřív spáruj zařízení';

  @override
  String get tipPairFirstBody =>
      'Otevři webovou stránku Zigbee2MQTT, spáruj aspoň jedno zařízení a zkontroluj to znovu.';

  @override
  String get tipRestartZ2mTitle => 'Restartuj Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'Pokud jsou zařízení spárovaná, ale žádné nepřichází, restartuj Zigbee2MQTT, aby publikoval seznam zařízení.';

  @override
  String get tipNumberAddressTitle => 'Použij číselnou adresu';

  @override
  String get tipNumberAddressBody =>
      'Názvy končící na .local nefungují na každém telefonu s Androidem. Zkus číselnou adresu hubu, třeba 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Port a protokol';

  @override
  String get tipPortProtocolBody =>
      'Obvyklé je TCP na 1883. TLS nebo WebSocket vyber, jen pokud je na to tvůj broker nastavený.';

  @override
  String get tipManualLoginTitle => 'Přihlášení';

  @override
  String get tipManualLoginBody =>
      'Pokud tvůj broker nemá uživatelské jméno ani heslo, nech je prázdné. Jinak použij přihlášení k MQTT, ne k webu hubu.';

  @override
  String get tipHubOnTitle => 'Je hub zapnutý?';

  @override
  String get tipHubOnBody =>
      'Výpadek proudu nebo aktualizace ho mohly restartovat. Až naběhne, dej mu minutu.';

  @override
  String get tipAwayTitle => 'Jsi doma?';

  @override
  String get tipAwayBody =>
      'Mimo domov aplikace potřebuje vzdálenou adresu (například Tailscale). Nastav ji v nastavení připojení domova.';

  @override
  String get tipTailscaleIpTitle => 'Použij Tailscale IP, ne název';

  @override
  String get tipTailscaleIpBody =>
      'Názvy končící na .ts.net se v aplikacích často nepřeloží. Otevři v telefonu aplikaci Tailscale, zkontroluj, že je připojená, a jako Vzdálený hostitel použij adresu hubu 100.x.y.z.';

  @override
  String get tipHomeAddressChangedTitle => 'Změnila se adresa?';

  @override
  String get tipHomeAddressChangedBody =>
      'Po restartu routeru může hub dostat novou adresu. Rezervuj jeho adresu v aplikaci routeru a pak domov aktualizuj.';

  @override
  String get tipRestartZ2mButtonTitle => 'Restartuj Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'Pokud se broker restartoval, seznam zařízení Zigbee2MQTT zmizí, dokud se Zigbee2MQTT nerestartuje. Použij tlačítko Restartovat Zigbee2MQTT na kartě Zařízení.';

  @override
  String get tipZ2mRunningTitle => 'Běží Zigbee2MQTT?';

  @override
  String get tipZ2mRunningBody =>
      'Otevři jeho webovou stránku. Pokud se nenačte, restartuj ho na hubu.';

  @override
  String get tipCantConnectTitle => 'Nemůžu se připojit k hubu';

  @override
  String get tipCantConnectBody =>
      'Stejná Wi-Fi, běžící broker, Allow External nebo Mosquitto poslouchající v síti, a pak připojení přes adresu.';

  @override
  String get tipDeviceWrongTitle => 'Zařízení ukazuje špatně nebo neodpovídá';

  @override
  String get tipDeviceWrongBody =>
      'Nejdřív ho zkontroluj na webové stránce Zigbee2MQTT. Pokud tam funguje, použij Nahlásit problém.';

  @override
  String get tipHowDoITitle => 'Jak na…';

  @override
  String get tipHowDoIBody =>
      'Scény, Nástěnný displej, plány a zálohy najdeš v Nápověda a průvodce.';

  @override
  String get tipRenameHomeTitle => 'Přejmenovat domov';

  @override
  String get tipRenameHomeBody =>
      'Domov pojmenovaný podle adresy? Nastavení › Domovy, klepni na domov a pak na Název.';

  @override
  String get tipWhatYouNeedTitle => 'Co potřebuješ';

  @override
  String get tipWhatYouNeedBody =>
      'Malý hub se Zigbee2MQTT a MQTT brokerem (Mosquitto): hub SMLIGHT, Raspberry Pi nebo jakýkoli linuxový počítač. Home Assistant funguje taky, ale nepotřebuješ ho.';

  @override
  String get tipSetupAtHomeTitle => 'Na stejné Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Nastavuj doma, s telefonem na stejné Wi-Fi jako hub.';

  @override
  String get tipFindSetupTitle => 'Potom';

  @override
  String get tipFindSetupBody =>
      'Opusť demo a klepni na Najít moje zařízení. ZigDash tvůj hub najde sám.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Nenalezena žádná e-mailová aplikace. Zkopíruj podrobnosti a napiš na $email.';
  }

  @override
  String get shortcutWorking => 'pracuji…';

  @override
  String get shortcutCantReach => 'Domov není dostupný';

  @override
  String get shortcutNotConfirmed => 'Nepotvrzeno';

  @override
  String get shortcutRemoved => 'Odebráno';

  @override
  String get shortcutSceneSent => 'Odesláno';

  @override
  String get shortcutSceneConfirmed => 'Potvrzeno';

  @override
  String get shortcutChooseDevice => 'Vyber zařízení';

  @override
  String get shortcutChooseScene => 'Vyber scénu';

  @override
  String get shortcutOpenAppFirstScene =>
      'Otevři ZigDash a nejdřív vytvoř scénu.';

  @override
  String get shortcutChooseGroup => 'Vyber skupinu';

  @override
  String get shortcutPickDevices => 'Vybrat zařízení…';

  @override
  String get shortcutGroupName => 'Název skupiny';

  @override
  String get shortcutGroupLimit => 'Až 5 zařízení a 3 scény';

  @override
  String get shortcutAddTile => 'Přidat do Rychlého nastavení';

  @override
  String get shortcutAddShortcut => 'Přidat zkratku';

  @override
  String get shortcutAddToHome => 'Přidat na plochu';

  @override
  String get shortcutWidgetHowToTitle => 'Přidej widget';

  @override
  String get shortcutWidgetHowTo =>
      'Dlouze podrž prázdné místo na ploše, klepni na Widgety, najdi ZigDash a přetáhni widget, který chceš.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name je na dlaždici Rychlého nastavení ZigDash $slot';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name už je na dlaždici ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Přidej dlaždici';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Otevři Rychlé nastavení (dvakrát přejeď dolů), klepni na tužku pro úpravy a přetáhni „ZigDash $slot“ mezi své dlaždice.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Vyber zařízení pro ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Zatím žádná zařízení k přepínání. Nejdřív dej na nástěnku světlo, zásuvku nebo roletu.';

  @override
  String get shortcutSlotsFull =>
      'Všechny 4 dlaždice ZigDash se používají. Která z nich má místo toho ukazovat toto zařízení?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Nepoužito';

  @override
  String get deviceRename => 'Přejmenovat';

  @override
  String get deviceRenameTitle => 'Přejmenovat zařízení';

  @override
  String get deviceRenameHint => 'Název místnosti nebo zařízení, třeba Ložnice';

  @override
  String deviceRenamed(Object name) {
    return 'Přejmenováno na $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Přejmenování se nepodařilo: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT neodpověděl';

  @override
  String get shortcutOpenAppFirst =>
      'Otevři ZigDash a nejdřív dej zařízení na nástěnku.';

  @override
  String get pollTitle => 'Co by měl ZigDash umět dál?';

  @override
  String get pollBody =>
      'Vyber tu věc, kterou bys používal nejvíc. Tvoje odpověď se odešle s anonymními daty o používání.';

  @override
  String get pollNotifications => 'Oznámení';

  @override
  String get pollHistory => 'Grafy historie';

  @override
  String get pollKiosk => 'Kiosk režim pro tablet na zdi';

  @override
  String get pollGroups => 'Skupiny Zigbee';

  @override
  String get pollNotNow => 'Teď ne';

  @override
  String get pollThanks => 'Díky! Pomůže to rozhodnout, co přijde dál.';

  @override
  String get whyTitle => 'Proč jsi vyzkoušel ZigDash?';

  @override
  String get whyBody =>
      'Jedno klepnutí pomůže rozhodnout, co dál. Tvoje odpověď se odešle s anonymními daty o používání.';

  @override
  String get whyFaster => 'Rychlejší než moje jiná aplikace';

  @override
  String get whyFamily => 'Jednoduchý pro rodinu';

  @override
  String get whyWallTablet => 'Tablet na zdi';

  @override
  String get whyWithoutHa => 'Funguje bez Home Assistantu';

  @override
  String get whyOther => 'Něco jiného';

  @override
  String get whyThanks => 'Díky za odpověď!';

  @override
  String get pollNoAnalytics =>
      'Data o používání jsou vypnutá, takže odsud se nic neodešle. Napiš nám raději přes Navrhnout funkci.';

  @override
  String alertLeak(Object name) {
    return '💧 Únik vody — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name je zase suché';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Kouř — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Už žádný kouř: $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 Otevřeno: $name';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Slabá baterie — $name, $value %';
  }

  @override
  String get alertTest => 'Testovací upozornění ZigDash';

  @override
  String get alertsChannel => 'Upozornění';

  @override
  String get alertsChannelDescription => 'Úniky vody a kouř';

  @override
  String get noticesChannel => 'Oznámení';

  @override
  String get noticesChannelDescription => 'Dveře, okna a baterie';

  @override
  String get alertsTitle => 'Upozornění';

  @override
  String get alertsStatusOn => 'Upozornění jsou zapnutá';

  @override
  String get alertsStatusPaused =>
      'Upozornění pozastavena: ZigDash Engine na hubu se nehlásí';

  @override
  String get alertsStatusNotSetUp => 'Nenastaveno';

  @override
  String get alertsStatusPhoneOff => 'Tento telefon nedostává oznámení';

  @override
  String get alertsIntro =>
      'Dostanete upozornění na tento telefon při úniku vody, kouři, otevřených dveřích nebo slabé baterii, i když je ZigDash zavřený. ZigDash Engine na hubu sleduje zařízení; ZigDash ho nastaví.';

  @override
  String get alertsSetUpHub => 'Nastavit upozornění na hubu';

  @override
  String get alertsHubInstalled => 'Upozornění jsou na hubu nastavena';

  @override
  String get alertsHubUpdated => 'Flow upozornění na hubu je aktuální';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED vyžaduje přihlášení, tak flow importuj ručně:';

  @override
  String get alertsHubManualSteps =>
      'Otevři Node-RED na hubu, zvol Import, vlož zkopírovaný flow, v uzlu brokeru vyber svůj broker a dej Deploy.';

  @override
  String get alertsCopyFlow => 'Kopírovat flow';

  @override
  String get alertsFlowCopied => 'Flow zkopírován';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Upozornění potřebují na hubu Node-RED, ale na portu 1880 na $host nic neodpovídá. Na SMLIGHT SMHUB ho nainstaluješ v Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT nepřijal ZigDash Engine';

  @override
  String get alertsRecent => 'Nedávná upozornění';

  @override
  String get alertsRecentNone => 'Zatím nic';

  @override
  String get alertsYourAlerts => 'Tvoje upozornění';

  @override
  String get alertsAdd => 'Přidat upozornění';

  @override
  String get alertsNotificationsOnThisPhone => 'Oznámení na tomto telefonu';

  @override
  String get alertsNoGoogle =>
      'Tento telefon nemá služby Google, takže sem ZigDash nemůže dostávat push oznámení.';

  @override
  String get alertsSendTest => 'Poslat testovací oznámení';

  @override
  String get alertsTestSent => 'Test odeslán. Měl by dorazit hned.';

  @override
  String alertsTestFailed(Object status) {
    return 'Hub ho nedokázal odeslat ($status)';
  }

  @override
  String get alertsTestTimedOut => 'Hub neodpovídá. Běží flow upozornění?';

  @override
  String get alertsNotConnected => 'Nepřipojeno k hubu';

  @override
  String get alertsTurnOff => 'Vypnout upozornění';

  @override
  String get alertsTurnOffBody =>
      'Upozornění se zastaví pro všechny telefony tohoto domova.';

  @override
  String get alertKindLeak => 'Únik vody';

  @override
  String get alertKindSmoke => 'Kouř';

  @override
  String get alertKindOpened => 'Otevřené dveře nebo okno';

  @override
  String get alertKindBattery => 'Slabá baterie';

  @override
  String get alertsEditTitle => 'Upozornění';

  @override
  String get alertsKind => 'Co';

  @override
  String get alertsDevices => 'Zařízení';

  @override
  String get alertsNoDevicesForKind =>
      'Žádné zařízení tohoto domova to nehlásí.';

  @override
  String get alertsHours => 'Jen mezi';

  @override
  String get alertsHoursAny => 'Kdykoli';

  @override
  String get alertsHoursFrom => 'Od';

  @override
  String get alertsHoursTo => 'Do';

  @override
  String get alertsThreshold => 'Baterie pod';

  @override
  String get alertsDelete => 'Smazat upozornění';

  @override
  String get alertsNotifyMe => 'Upozornit mě…';

  @override
  String get alertsWhatLeaves =>
      'Upozornění pro ZigDash jsou šifrovaná end-to-end: push služba Googlu je doručí, ale nemůže je přečíst. Nic jiného tvůj hub neopouští.';

  @override
  String get alertsRestricted =>
      'Android může ZigDash na pozadí zastavit, takže oznámení můžou přijít pozdě nebo vůbec. Povol mu běh na pozadí v nastavení Androidu (na Samsungu: Baterie › Aplikace, které nikdy nebudou uspány).';

  @override
  String get alertsOpenSettings => 'Otevřít nastavení Androidu';

  @override
  String get alertsOff => 'Vypnuto';

  @override
  String get alertsSuggested => 'Navrhovaná upozornění';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zařízení',
      few: '$count zařízení',
      one: '1 zařízení',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Zapnout';

  @override
  String get alertsShare => 'Sdílet upozornění';

  @override
  String get alertsShareBody =>
      'Kdokoli s tímto odkazem dostane upozornění tohoto domova v aplikaci ntfy, bez potřeby ZigDash. Text upozornění jde přes ntfy.sh nešifrovaně.';

  @override
  String get alertsShareLink => 'Odkaz';

  @override
  String get alertsShareNewLink => 'Nový odkaz';

  @override
  String get alertsShareCopied => 'Odkaz zkopírován';

  @override
  String get alertsShareOff => 'Přestat sdílet';

  @override
  String get alertsGetWithNtfy => 'Dostávat oznámení přes ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Upozornění na kouř a únik vody se opakují, dokud je nepotvrdíš. Vyžaduje účet Pushover (jednorázově 4,99 \$ po zkušební době); jeho klíče jsou uložené na tvém brokeru.';

  @override
  String get alertsPushoverUser => 'Uživatelský klíč';

  @override
  String get alertsPushoverToken => 'Token aplikace';

  @override
  String get alertsHideNames => 'Skrýt názvy zařízení';

  @override
  String get alertsNtfyServer => 'Server ntfy';

  @override
  String get wallSheetTitle => 'Nástěnný displej';

  @override
  String get wallSheetSubtitle => 'Pro tablet na zdi.';

  @override
  String get wallKeepOn => 'Nechat obrazovku zapnutou a skrýt lišty';

  @override
  String get wallKeepOnSubtitle =>
      'Vrátí se po dotyku a po 10 sekundách se znovu skryjí.';

  @override
  String get wallFullscreen => 'Celá obrazovka';

  @override
  String get wallFullscreenSubtitle =>
      'Skryje i stavový a navigační panel Androidu.';

  @override
  String get wallDimAfter => 'Ztlumit po';

  @override
  String get wallDimOff => 'Vypnuto';

  @override
  String get wallIdleTitle => 'Když se ho nikdo nedotýká';

  @override
  String get wallIdleAfter => 'Po';

  @override
  String get wallIdleNever => 'Nikdy';

  @override
  String get wallIdleShow => 'Zobrazit';

  @override
  String get wallIdleShowDim => 'Ztlumeno';

  @override
  String get wallIdleShowClock => 'Hodiny';

  @override
  String get wallIdleShowBlack => 'Černá';

  @override
  String get wallIdleShowReadings => 'Měření';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Tato nástěnka zatím nemá žádná měření. Nejdřív přidej dlaždici měření nebo senzoru.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Měření na hodinách (až $count)';
  }

  @override
  String get wallProNote =>
      'Měření na hodinách, probuzení pohybem, noční plán a alarmy jsou součástí ZigDash Pro, jednorázového nákupu.';

  @override
  String get wallAlarmLeak => 'Únik vody';

  @override
  String get wallAlarmSmoke => 'Kouř';

  @override
  String get wallAlarmGas => 'Plyn';

  @override
  String get wallAlarmCo => 'Oxid uhelnatý';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Probudit pohybem';

  @override
  String get wallMotionSubtitle =>
      'Senzor, který někoho zaznamená, probudí obrazovku.';

  @override
  String get wallMotionNone =>
      'V tomto domově nejsou žádné senzory pohybu, přítomnosti ani dveří.';

  @override
  String get wallAlarmsTitle => 'Alarmy převezmou obrazovku';

  @override
  String get wallAlarmsSubtitle =>
      'Únik vody, kouř, plyn nebo oxid uhelnatý zaplní obrazovku, dokud někdo neklepne na OK. Jen když je ZigDash na tomto tabletu otevřený; Upozornění dorazí na telefony kdekoli.';

  @override
  String get wallAlarmSound => 'Přehrát zvuk';

  @override
  String get wallNightTitle => 'Noc';

  @override
  String get wallNightSubtitle =>
      'V těchto hodinách černá. Pohyb ji probudí jen ztlumeně; alarmy vždy naplno.';

  @override
  String get wallNightFrom => 'Od';

  @override
  String get wallNightTo => 'do';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Kiosk zámek';

  @override
  String get kioskLockSubtitle =>
      'Dostupné zůstanou jen nástěnky tohoto domova a jejich ovládání. Pro odchod dlouze podrž název.';

  @override
  String get kioskPin => 'PIN';

  @override
  String get kioskPinSet => 'Nastaven';

  @override
  String get kioskPinNotSet => 'Nenastaven';

  @override
  String get kioskPinChange => 'Změnit';

  @override
  String get kioskPinRemove => 'Odstranit';

  @override
  String get kioskPinSetTitle => 'Nastav PIN';

  @override
  String get kioskPinEnterTitle => 'Zadej PIN';

  @override
  String get kioskPinHint => '4 číslice';

  @override
  String get kioskPinConfirmHint => 'Znovu';

  @override
  String get kioskPinMismatch => 'Oba PINy se liší.';

  @override
  String get kioskPinWrong => 'Špatný PIN.';

  @override
  String get kioskPinForgot => 'Zapomněl jsi PIN?';

  @override
  String get kioskPinForgotBody =>
      'Zapomenutý PIN jde resetovat jen vymazáním dat ZigDash v nastavení Androidu, což odstraní tento domov, pokud nemáš zálohu. Než PIN nastavíš, zálohu si vyexportuj.';

  @override
  String get kioskExportBackup => 'Exportovat zálohu';

  @override
  String get kioskOsPin => 'Připnout ZigDash i v Androidu';

  @override
  String get kioskOsPinSubtitle =>
      'Android zablokuje Domů a nedávné aplikace, dokud ZigDash neodepneš. Tablet bez zámku obrazovky se odepne gestem, takže tohle zámek není.';

  @override
  String get kioskOn => 'Kiosk zapnutý. Pro odchod dlouze podrž název.';

  @override
  String get kioskLeaveTitle => 'Opustit kiosk?';

  @override
  String get kioskLeave => 'Opustit';

  @override
  String get kioskStay => 'Zůstat';

  @override
  String get a11yKioskLeave => 'Dlouhým podržením opustíš kiosk';

  @override
  String get historyTitle => 'Historie';

  @override
  String get historyRangeDay => '24 hodin';

  @override
  String get historyRangeWeek => '7 dní';

  @override
  String get historyRangeMonth => '30 dní';

  @override
  String get historySetupTitle => 'Zaznamenávat historii na hubu';

  @override
  String get historySetupBody =>
      'ZigDash nemá server, takže ZigDash Engine na hubu každých 15 minut zaznamenává hodnoty z vašich nástěnek. Uchovává 30 dní, na vašem brokeru.';

  @override
  String get historySetupAction => 'Nastavit na hubu';

  @override
  String get historyInstalled =>
      'Zaznamenává se. První hodnoty se objeví do 15 minut.';

  @override
  String historyNoNodeRed(String host) {
    return 'Historie potřebuje na hubu Node-RED, ale na portu 1880 na $host nic neodpovídá. Na SMLIGHT SMHUB ho nainstaluješ v Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Zaznamenává se od $date';
  }

  @override
  String get historyEmpty =>
      'Zatím žádné hodnoty. Záznam se ukládá každých 15 minut.';

  @override
  String get historyRecorderOffline =>
      'Záznamník na hubu neodpovídá, takže nedávné hodnoty můžou chybět.';

  @override
  String get historyLocked =>
      'Delší historie je součástí ZigDash Pro, jednorázového nákupu.';

  @override
  String get historyUnlock => 'Odemknout';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Neomezené automatizace, delší historie a doplňky pro tablet na zdi. Podpoříš tím open source projekt.';

  @override
  String get proUnlocked => 'Odemčeno. Děkuju, že podporuješ ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash je zdarma a open source a ve volném čase ho vyvíjí jeden člověk. Pro je jednorázový nákup, který ho drží při životě.';

  @override
  String get proWhatYouGet => 'Co dostaneš';

  @override
  String get proGetHistory => 'Historie za 7 a 30 dní, ne jen za dnešek';

  @override
  String get proGetWall =>
      'Tablet na zdi: měření na hodinách, probuzení pohybem, noční plán a alarmy';

  @override
  String get proGetFuture =>
      'Každá funkce Pro, která přijde později, bez příplatku';

  @override
  String get proFreeTitle => 'Navždy zdarma';

  @override
  String get proFreeBody =>
      'Nastavení, nástěnky, ovládání všech zařízení, widgety, dlaždice Rychlého nastavení, upozornění, tři automatizace na domácnost i samotný tablet na zdi zůstávají zdarma. Nic, co dnes používáš, se nezamkne.';

  @override
  String get proBuy => 'Získat Pro';

  @override
  String proBuyPrice(String price) {
    return 'Získat Pro · $price';
  }

  @override
  String get proOnce =>
      'Jedna platba, žádné předplatné. Koupil jsi to na jiném telefonu se stejným účtem Google? Odemkne se automaticky.';

  @override
  String get historyNotRecorded =>
      'Zaznamenávají se jen čísla zobrazená na nástěnce. Přidej tohle jako dlaždici a začne se zaznamenávat jeho historie.';

  @override
  String get historyRecordHere => 'Zaznamenávat na tomto zařízení';

  @override
  String get historyRecordHereHint =>
      'ZigDash Engine na hubu nelze použít? ZigDash může zaznamenávat na telefonu nebo tabletu, který zůstane otevřený, třeba na nástěnném tabletu. Historii vidí každý telefon této domácnosti.';

  @override
  String get historyRecordingHere =>
      'Toto zařízení zaznamenává historii, dokud je ZigDash otevřený. První hodnoty se objeví do 15 minut.';

  @override
  String get wallRecordHistory => 'Zaznamenávat historii na tomto zařízení';

  @override
  String get wallRecordHistorySubtitle =>
      'Každých 15 minut, dokud je ZigDash otevřený, pro každý telefon této domácnosti. Není potřeba, když zaznamenává ZigDash Engine na hubu.';

  @override
  String historyNeedsPassword(String host) {
    return 'Ještě jeden krok: tvůj broker vyžaduje přihlášení. Otevři Node-RED na $host:1880, dvakrát klikni na „ZigDash history broker“, na kartě Security zadej heslo k MQTT a dej Deploy. ZigDash tvoje heslo na hub nikdy neposílá.';
  }

  @override
  String get historyNotConnected =>
      'Záznam se nehlásí. Otevřete Automatizace a zkontrolujte ZigDash Engine na hubu.';

  @override
  String get historyPersistence =>
      'Historie je uložená na tvém brokeru. Pokud provozuješ Mosquitto sám, zkontroluj, že jeho konfigurace obsahuje „persistence true“, jinak se historie po restartu brokeru ztratí.';

  @override
  String get haImportTitle => 'Import z Home Assistantu';

  @override
  String get haImportSettingsSubtitle =>
      'Názvy a místnosti, které máš nastavené v Home Assistantu';

  @override
  String get haImportIntro =>
      'Přenes názvy a místnosti, které máš nastavené v Home Assistantu. ZigDash je jednou načte a nic dalšího z Home Assistantu si neponechá.';

  @override
  String get haImportAddress => 'Adresa Home Assistantu';

  @override
  String get haImportAddressHelp =>
      'Adresa, na které Home Assistant otevíráš, třeba 192.168.1.20:8123';

  @override
  String get haImportToken => 'Dlouhodobý přístupový token';

  @override
  String get haImportTokenHelp =>
      'V Home Assistantu otevři svůj profil a pak Zabezpečení › Dlouhodobé přístupové tokeny › Vytvořit token. Zkopíruj ho a vlož sem. ZigDash ho použije jednou a neuchovává ho; v Home Assistantu ho pak můžeš smazat.';

  @override
  String get haImportRead => 'Načíst z Home Assistantu';

  @override
  String get haImportReading => 'Načítám Home Assistant…';

  @override
  String get haImportApplying => 'Importuji…';

  @override
  String get haImportNoAddress =>
      'Zadej adresu, na které Home Assistant otevíráš.';

  @override
  String get haImportNoToken => 'Vlož dlouhodobý přístupový token.';

  @override
  String get haImportUnreachable =>
      'Na té adrese nic neodpovědělo. Zkontroluj ji a jestli je telefon v domácí síti.';

  @override
  String get haImportNotHa =>
      'Na té adrese něco odpovědělo, ale není to Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant ten token odmítl. Vytvoř nový a vlož ho znovu.';

  @override
  String get haImportCertificate =>
      'Tvůj telefon nedůvěřuje certifikátu tohoto Home Assistantu. Zkus jeho adresu http:// v domácí síti.';

  @override
  String get haImportFailed =>
      'Home Assistant odpověděl, ale načtení selhalo. Zkus to znovu.';

  @override
  String get haImportNoDevices =>
      'ZigDash teď nevidí zařízení tohoto domova. Připoj se k domovu a zkus to znovu.';

  @override
  String get haImportAutomations =>
      'Tvoje automatizace zůstávají v Home Assistantu a běží dál.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'V Home Assistantu nalezeno $count zařízení',
      few: 'V Home Assistantu nalezena $count zařízení',
      one: 'V Home Assistantu nalezeno 1 zařízení',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'Dlaždice, které se pořád jmenují podle zařízení, převezmou název z Home Assistantu. Nástěnky, které sis sestavil, zůstanou, jak jsou.';

  @override
  String get haImportMakeDashboards =>
      'Přidat i nástěnky podle podlaží a místností';

  @override
  String get haImportOtherRooms => 'Ostatní místnosti';

  @override
  String get haImportNoRoom => 'Bez místnosti';

  @override
  String get haImportApply => 'Importovat';

  @override
  String get haImportBack => 'Zpět';

  @override
  String get haImportZhaOnly =>
      'Tato zařízení běží na ZHA, vlastním Zigbee Home Assistantu, ne na Zigbee2MQTT, takže je ZigDash nemůže zobrazit.';

  @override
  String get haImportNothing =>
      'Žádné ze zařízení Zigbee2MQTT tohoto domova není v Home Assistantu.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Hotovo. Přejmenované dlaždice: $renamed. Přidané nástěnky: $dashboards.';
  }

  @override
  String get haImportOpen => 'Otevřít nástěnky';

  @override
  String get haImportOfferTitle =>
      'Přenést názvy a místnosti z Home Assistantu?';

  @override
  String get haImportOfferBody =>
      'Home Assistant je ve tvé síti. ZigDash může pojmenovat tvoje dlaždice a přidat nástěnku pro každé podlaží a místnost tak, jak je tam máš nastavené.';

  @override
  String get haImportOfferLater => 'Teď ne';

  @override
  String get haImportOfferGo => 'Importovat';

  @override
  String get haImportSignIn => 'Přihlásit se přes Home Assistant';

  @override
  String get haImportSignInHelp =>
      'Vlastní přihlášení Home Assistantu se otevře v prohlížeči. ZigDash tvoje heslo nikdy nevidí a po načtení se zase odhlásí.';

  @override
  String get haImportOrToken => 'Nebo použij dlouhodobý token';

  @override
  String get haImportReadToken => 'Načíst pomocí tokenu';

  @override
  String get haImportSignInRefused =>
      'Home Assistant přihlášení nepřijal. To se stává, když Home Assistant nemá přístup k internetu. Použij místo toho dlouhodobý token níže.';

  @override
  String get setupIsolatedHint =>
      'Tvůj telefon v této Wi-Fi nevidí skoro nic jiného. Může být v síti pro hosty, nebo router drží zařízení odděleně (často se tomu říká izolace klientů nebo AP). Připoj se k hlavní Wi-Fi, nebo to vypni, a zkus to znovu.';

  @override
  String get setupAuthTrust =>
      'Tvoje přihlášení zůstává v tomto telefonu a jde jen na tvůj vlastní broker. ZigDash nemá server ani účet a každá MQTT aplikace se přihlašuje stejně. Nejbezpečnější: samostatný MQTT uživatel jen pro ZigDash, kterého můžeš kdykoli odstranit.';

  @override
  String get setupAuthWhatKept => 'Co si ZigDash uchovává';

  @override
  String get setupAuthDemoFirst => 'Nejdřív vyzkoušej demo';

  @override
  String get automationsTitle => 'Automatizace';

  @override
  String get engineRunningOnHub => 'Běží na hubu';

  @override
  String get engineChecking => 'Kontrola hubu…';

  @override
  String get engineAwayNoHubTitle => 'Teď se nedaří spojit s vaším hubem';

  @override
  String get engineAwayNoHubBody =>
      'Jste pryč a váš hub není připojen ke vzdálenému přístupu ZigDash, nebo nemá internet. Vaše automatizace na hubu dál běží.';

  @override
  String get engineAwayReinstallAtHome =>
      'Engine můžete přeinstalovat, až budete doma.';

  @override
  String get engineNoConnection =>
      'ZigDash teď nedosáhne na broker této domácnosti. Automatizace se nastavují doma, s připojením.';

  @override
  String get engineRestarting =>
      'Restart Zigbee2MQTT… Zařízení budou zpět asi za 30 sekund.';

  @override
  String get engineInstalling => 'Instalace na hub…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT potřebuje aktualizaci';

  @override
  String engineTooOldBody(Object version) {
    return 'Váš Zigbee2MQTT má verzi $version. Automatizace vyžadují 2.4 nebo novější. Aktualizujte Zigbee2MQTT na hubu a vraťte se sem.';
  }

  @override
  String get engineIntroTitle => 'Automatizace běží na hubu, ne v telefonu';

  @override
  String get engineIntroBody =>
      'ZigDash vloží ZigDash Engine do Zigbee2MQTT na vašem hubu. Sleduje vaše zařízení a spouští pravidla, takže se světlo rozsvítí při otevření dveří, i když je telefon vypnutý a nejde internet.';

  @override
  String get engineIntroNothingByHand =>
      'Nic se neinstaluje ručně. ZigDash to udělá přes domácí síť.';

  @override
  String engineIntroVersion(Object version) {
    return 'Váš Zigbee2MQTT má verzi $version.';
  }

  @override
  String get engineIntroRemove => 'Kdykoli ho můžete odebrat z této obrazovky.';

  @override
  String get engineInstall => 'Nainstalovat na hub';

  @override
  String get engineDeclinedTitle => 'Na tomto hubu nejsou automatizace';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT na vašem hubu nepovoluje rozšíření, takže nic nespustí vaše pravidla, když telefon není doma. Scény, upozornění a nástěnka fungují jako dřív.';

  @override
  String get engineAllowAfterAll => 'Přece jen povolit rozšíření';

  @override
  String get engineConsentTitle =>
      'Zigbee2MQTT potřebuje změnit jedno nastavení';

  @override
  String get engineConsentBody =>
      'Váš Zigbee2MQTT blokuje rozšíření jako ZigDash Engine, jak to dělají nové instalace. Aby automatizace běžely na hubu, ZigDash by v Zigbee2MQTT zapnul „Povolit externí JavaScript“ a restartoval ho.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT se jednou restartuje. Světla a senzory budou asi 30 sekund nedostupné.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine má otevřený kód. Můžete si ho přečíst na stránce Zigbee2MQTT v části Rozšíření.';

  @override
  String get engineConsentUndo =>
      'Nastavení můžete později zase vypnout. Automatizace se pak zastaví.';

  @override
  String get engineConsentYes => 'Změnit nastavení a restartovat';

  @override
  String get engineConsentNo => 'Teď ne';

  @override
  String get automationsPausedTitle => 'Automatizace pozastaveny';

  @override
  String get automationsPausedBody =>
      'Hub se přes minutu neozval, takže žádná automatizace nepoběží, dokud se neozve. Vaše pravidla zůstávají.';

  @override
  String get engineReinstall => 'Znovu nainstalovat na hub';

  @override
  String get engineStoppedTitle =>
      'Automatizace pozastaveny: ZigDash Engine se sám zastavil';

  @override
  String get engineStoppedBody =>
      'Během hodiny třikrát narazil na chybu a vypnul se, aby Zigbee2MQTT dál běžel. Vaše pravidla zůstávají.';

  @override
  String get engineStartAgain => 'Spustit znovu';

  @override
  String get engineReportProblem => 'Nahlásit problém';

  @override
  String get engineRunningTitle => 'Váš hub je připraven na automatizace';

  @override
  String engineRunningBody(Object count) {
    return 'Pravidel načtených na hubu: $count. Vytváření automatizací přijde v dalším kroku této verze.';
  }

  @override
  String get engineClockOff =>
      'Hodiny hubu se liší o víc než pět minut. Časové automatizace poběží ve špatnou dobu, dokud se to neopraví.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Pravidla, která ZigDash Engine na hubu zatím neumí spustit: $count. Nainstalujte ho znovu, aby se aktualizoval.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT odmítl ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT neodpověděl. Zkontrolujte, že je domácnost připojená, a zkuste to znovu.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT změnu nepřijal nebo se nevrátil. Zkontrolujte hub a zkuste to znovu.';

  @override
  String get autoValMotion => 'pohyb';

  @override
  String get autoValNoMotion => 'bez pohybu';

  @override
  String get autoValClosed => 'zavřeno';

  @override
  String get autoValOpened => 'otevřeno';

  @override
  String get autoValLeak => 'únik vody';

  @override
  String get autoValDry => 'sucho';

  @override
  String get autoValSmoke => 'kouř';

  @override
  String get autoValNoSmoke => 'bez kouře';

  @override
  String get autoValOn => 'zap.';

  @override
  String get autoValOff => 'vyp.';

  @override
  String get autoValToggle => 'přepnout';

  @override
  String get autoValOpen => 'otevřít';

  @override
  String get autoValClose => 'zavřít';

  @override
  String get autoValStop => 'zastavit';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Když $device: $property nad $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Když $device: $property pod $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Když $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'V $time';
  }

  @override
  String get autoSunrise => 'východ slunce';

  @override
  String get autoSunset => 'západ slunce';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min po: $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min před: $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return '$sun';
  }

  @override
  String get autoEveryDay => 'každý den';

  @override
  String get autoWeekdays => 'pracovní dny';

  @override
  String get autoWeekends => 'víkendy';

  @override
  String autoBetween(Object from, Object to) {
    return 'mezi $from a $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device: $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Spustit „$scene“';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, po $minutes min zase vypnout';
  }

  @override
  String get autoErrPickTrigger => 'Vyberte zařízení a co dělá.';

  @override
  String get autoErrValue => 'Zadejte číslo pro hodnotu.';

  @override
  String get autoErrDays => 'Vyberte aspoň jeden den.';

  @override
  String get autoErrTown => 'Nastavte město pro východ a západ slunce.';

  @override
  String get autoErrPickAction => 'Vyberte, co se má stát.';

  @override
  String get autoErrEmptyScene => 'Tato scéna nemá co odeslat.';

  @override
  String get autoErrNotConnected =>
      'ZigDash není připojen k této domácnosti. Zkuste to znovu doma.';

  @override
  String get autoNewTitle => 'Nová automatizace';

  @override
  String get autoEditTitle => 'Upravit automatizaci';

  @override
  String get autoName => 'Název';

  @override
  String get autoNameHint => 'Co dělá (nepovinné)';

  @override
  String get autoWhen => 'Když';

  @override
  String get autoOnlyIf => 'Jen pokud';

  @override
  String get autoThen => 'Pak';

  @override
  String get autoEnabled => 'Zapnuto';

  @override
  String get autoDelete => 'Smazat automatizaci';

  @override
  String get autoSave => 'Uložit';

  @override
  String get autoDeviceChanges => 'Zařízení se změní';

  @override
  String get autoTimeComes => 'Přijde čas';

  @override
  String get autoDevice => 'Zařízení';

  @override
  String get autoAbove => 'nad';

  @override
  String get autoBelow => 'pod';

  @override
  String get autoClockTime => 'Čas';

  @override
  String get autoAt => 'V';

  @override
  String get autoShift => 'Posun v minutách (mínus je dříve)';

  @override
  String get autoTownNone => 'Město není nastaveno';

  @override
  String autoTownIs(Object town) {
    return 'Časy slunce pro: $town';
  }

  @override
  String get autoTownSet => 'Nastavit město';

  @override
  String get autoTownChange => 'Změnit město';

  @override
  String get autoDays => 'Dny';

  @override
  String get autoNoConditions => 'Bez podmínek. Spustí se pokaždé.';

  @override
  String get autoAddHours => 'Mezi časy';

  @override
  String get autoFrom => 'Od';

  @override
  String get autoTo => 'Do';

  @override
  String get autoAddDeviceCondition => 'Zařízení je…';

  @override
  String get autoRunASceneOption => 'Spustit scénu';

  @override
  String get autoSetADevice => 'Nastavit zařízení';

  @override
  String get autoScene => 'Scéna';

  @override
  String get autoTurnOffAgain => 'Zase vypnout';

  @override
  String get autoStaysAsSet => 'Zůstane tak';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minut poté';
  }

  @override
  String get autoTownSearch => 'Město';

  @override
  String get autoTownWhy =>
      'Jen pro východ a západ slunce. Uloží se na hub, nikdy vaše poloha.';

  @override
  String get autoNewButton => 'Nová automatizace';

  @override
  String get autoEmptyBody =>
      'Zatím nic neběží. Klepněte na Nová automatizace a vytvořte první.';

  @override
  String autoOnlyIfList(Object list) {
    return 'jen pokud $list';
  }

  @override
  String get autoEdit => 'Upravit';

  @override
  String get autoNeverRan => 'ještě neběžela';

  @override
  String autoRanAt(Object time) {
    return 'běžela v $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count z $max automatizací zdarma';
  }

  @override
  String get autoRecentRuns => 'Poslední spuštění';

  @override
  String get autoDeleted => '(smazána)';

  @override
  String autoCeilingTitle(Object count) {
    return 'Zdarma jsou $count automatizace. Chcete víc?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash je zdarma a s otevřeným kódem, vytváří ho jeden člověk. Pro je jednorázový nákup: neomezené automatizace, historie za 7 a 30 dní a doplňky pro nástěnný tablet. Vaše automatizace poběží dál, ať zvolíte cokoli.';

  @override
  String get autoCeilingSeePro => 'Zobrazit Pro';

  @override
  String get engineRemove => 'Odebrat z hubu';

  @override
  String get engineRemoveTitle => 'Odebrat ZigDash Engine z hubu?';

  @override
  String get engineRemoveBody =>
      'Automatizace přestanou běžet. Pravidla zůstanou na hubu, takže je nová instalace ZigDash Engine vrátí.';

  @override
  String get autoNoTargets =>
      'Tato domácnost zatím nemá žádné světlo, zásuvku, vypínač ani roletu k ovládání.';

  @override
  String get proGetAutomations =>
      'Neomezené automatizace; tři na domácnost jsou zdarma';

  @override
  String get proGetRemote =>
      'Ovládání odkudkoli přes relay ZigDash, bez měsíčního poplatku';

  @override
  String get proRemoteFair =>
      'Vzdálený přístup je zahrnut, dokud relay ZigDash běží, pro jeden domov, až pět telefonů a běžné domácí použití. Může se změnit nebo skončit s předchozím oznámením.';

  @override
  String get autoDeleteConfirm =>
      'Smazat tuto automatizaci? Přestane běžet na hubu.';

  @override
  String get statusConnectedRelay => 'Připojeno · Mimo domov přes ZigDash';

  @override
  String get shareHomeTitle => 'Sdílet s dalším telefonem';

  @override
  String get shareHomeSubtitle =>
      'Přidejte tento domov do dalšího telefonu jedním QR kódem';

  @override
  String get shareHomeIntro =>
      'Na druhém telefonu, doma na stejné Wi-Fi, naskenujte kód fotoaparátem. ZigDash přidá tento domov s přihlášením i vašimi nástěnkami.';

  @override
  String get shareHomeLoginWarning =>
      'Kód obsahuje přihlášení k brokeru tohoto domova. Zobrazí se na 2 minuty; ukazujte ho jen lidem, kterým věříte.';

  @override
  String get shareHomeShow => 'Zobrazit kód';

  @override
  String get shareHomeAtHome =>
      'Nejdřív se připojte doma: sdílení funguje jen ve vaší domácí síti.';

  @override
  String get shareHomeScanHint =>
      'Naskenujte fotoaparátem druhého telefonu. Kód se za 2 minuty skryje.';

  @override
  String get shareHomeHide => 'Skrýt kód';

  @override
  String get shareHomeViaHa =>
      'Tento domov se připojuje přes Home Assistant. Na druhém telefonu nainstalujte ZigDash a přihlaste se přes Home Assistant.';

  @override
  String get joinHomeTitle => 'Přidat sdílený domov';

  @override
  String get joinHomeInvalid =>
      'Tento kód není pozvánka do domova ZigDash, nebo je poškozený.';

  @override
  String joinHomeAlready(String name) {
    return '$name už v tomto telefonu je.';
  }

  @override
  String get joinHomeOpen => 'Otevřít';

  @override
  String joinHomeAsk(String name) {
    return 'Přidat $name do tohoto telefonu?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash přidá domov se stejným připojením a přihlášením a převezme nástěnky z druhého telefonu. Nechte tento telefon na domácí Wi-Fi.';

  @override
  String get joinHomeAdd => 'Přidat domov';

  @override
  String get joinHomeNoDashboards =>
      'Domov přidán. Nástěnky nedorazily; zařízení najdete na kartě Zařízení.';

  @override
  String get remoteTitle => 'Dálkové ovládání';

  @override
  String get remoteSettingsSubtitle =>
      'Ovládejte tuto domácnost odkudkoli, s Pro';

  @override
  String get remoteIntroTitle => 'Ovládejte domácnost odkudkoli';

  @override
  String get remoteOfferBody =>
      'Ovládejte zařízení i mimo domov, přes šifrovaný relay ZigDash. Součást Pro: jedna platba, žádný měsíční poplatek. Nastavte to, když jste doma.';

  @override
  String get remoteOfferBodyPro =>
      'Máte Pro: zapněte ovládání na dálku, když jste doma, a pak ovládejte zařízení odkudkoli.';

  @override
  String get remoteOfferShow => 'Ukázat';

  @override
  String get remoteIntroBody =>
      'Hub drží jedno spojení s relé ZigDash. Mimo domov se tento telefon dostane k zařízením přes něj. Vše se šifruje na hubu a v telefonu, takže relé nemůže číst vaše zařízení ani co dělají.';

  @override
  String get remoteNeedsEngine =>
      'Dálkové ovládání běží v ZigDash Engine. Nejdřív ho nainstalujte v Automatizacích.';

  @override
  String get remoteSetUp => 'Zapnout dálkové ovládání';

  @override
  String get remoteNeedsPro => 'Dálkové ovládání je součástí Pro.';

  @override
  String get remoteNotAtHome => 'Zapněte to doma, připojení k brokeru.';

  @override
  String get remoteUnreachable =>
      'Relé ZigDash neodpovědělo. Zkuste to později.';

  @override
  String get remoteRefused =>
      'Relé odmítlo. Zkuste to znovu nebo nahlaste problém.';

  @override
  String get remoteOnTitle => 'Dálkové ovládání je zapnuté';

  @override
  String get remoteOnBody => 'Mimo domov se ZigDash připojí přes relé sám.';

  @override
  String get remoteHubOnline => 'Hub je připojen k relé';

  @override
  String get remoteHubOffline => 'Hub není připojen k relé';

  @override
  String get remoteTurnOff => 'Vypnout dálkové ovládání';

  @override
  String get remoteViaRelayNow => 'Tento telefon je teď připojen přes relé.';

  @override
  String get remotePhones => 'Telefony se vzdáleným přístupem';

  @override
  String get remoteThisPhone => 'Tento telefon';

  @override
  String get remoteOtherPhone => 'Jiný telefon';

  @override
  String remotePhoneAdded(Object date) {
    return 'Přidán $date';
  }

  @override
  String get remoteRemovePhone => 'Odebrat';

  @override
  String get remoteRemovePhoneConfirm =>
      'Odebrat tento telefon? Už se k této domácnosti nedostane zvenku.';

  @override
  String get remoteAddPhone => 'Přidat telefon';

  @override
  String get remoteAddPhoneHint =>
      'Doma to naskenujte fotoaparátem druhého telefonu. Otevře ZigDash a zapne tam dálkové ovládání. Ukazujte jen vlastním telefonům.';

  @override
  String get remoteAddPhoneFailed =>
      'Relé nevydalo přístup pro další telefon. Domácnost jich může mít až pět.';

  @override
  String get remoteBackupSave => 'Uložit zálohu klíče';

  @override
  String get remoteBackupRestore => 'Obnovit ze zálohy klíče';

  @override
  String get remoteBackupPassphrase => 'Heslo zálohy';

  @override
  String get remoteBackupPassphraseHint =>
      'Když tento telefon ztratíte, záloha a toto heslo vrátí dálkové ovládání na nový. Aspoň 8 znaků; heslo mějte jinde než soubor.';

  @override
  String get remoteBackupPassphraseAsk => 'Heslo zvolené při ukládání zálohy.';

  @override
  String get remoteBackupPassphraseAgain => 'Heslo znovu';

  @override
  String get remoteBackupSaved => 'Záloha klíče uložena';

  @override
  String get remoteBackupWrong => 'Toto heslo zálohu neotevře.';

  @override
  String get remoteBackupWrongFile => 'To není záloha klíče ZigDash.';

  @override
  String get remotePlayOnly =>
      'Dálkové ovládání je zatím ve verzi ZigDash z Google Play.';

  @override
  String get remotePairTitle => 'Přidat dálkové ovládání';

  @override
  String get remotePairBody =>
      'Která je to domácnost? ZigDash pro ni uloží vzdálený přístup.';

  @override
  String get remotePairNoHomes =>
      'Nejdřív tuto domácnost nastavte na tomto telefonu, doma. Pak kód naskenujte znovu.';

  @override
  String get remotePairInvalid =>
      'Tento kód není kód dálkového ovládání ZigDash, nebo byl useknutý.';

  @override
  String remotePairDone(Object home) {
    return 'Dálkové ovládání zapnuto pro $home';
  }

  @override
  String get remoteReconnectHub => 'Znovu připojit hub';

  @override
  String get remoteTurnOffConfirm =>
      'Tento telefon opustí dálkové ovládání a hub se odpojí od relé. Záloha klíče uložená z tohoto telefonu přestane fungovat; ostatní telefony si přístup ponechají, dokud je neodeberete.';

  @override
  String remoteHomeId(Object id) {
    return 'ID domova $id';
  }

  @override
  String get alertsHintTitle => 'Upozornění na tento telefon';

  @override
  String get alertsHintBody =>
      'Únik vody, kouř, otevřené dveře nebo slabá baterie mohou poslat upozornění na tento telefon, i když je ZigDash zavřený.';

  @override
  String get alertsHintButton => 'Nastavit upozornění';

  @override
  String get alertsHintNotNow => 'Teď ne';

  @override
  String get guidedNoZ2mBody =>
      'Odpovídá tu MQTT broker, ale Zigbee2MQTT přes něj nic neposílá. Zkontrolujte, že Zigbee2MQTT běží a používá tento broker a že základní topic odpovídá jeho nastavení. Pokud máte zařízení Zigbee v ZHA v Home Assistantu, ZigDash je nevidí: pracuje se Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT je na tomto brokeru se základním topicem „$found“, ale tento domov hledá „$current“.';
  }

  @override
  String devicesUseBase(String found) {
    return 'Použít „$found“';
  }

  @override
  String get devicesChangeConnection => 'Změnit připojení';

  @override
  String get updateAvailableTitle => 'Je tu nová verze ZigDash';

  @override
  String get updateAvailableBody => 'Stáhne se, zatímco ZigDash dál používáš.';

  @override
  String get updateAvailableButton => 'Aktualizovat';

  @override
  String get updateDownloading => 'Stahuji aktualizaci…';

  @override
  String get updateReadyTitle => 'Aktualizace stažena';

  @override
  String get updateReadyButton => 'Dokončit restartem';

  @override
  String get nfcWriteTag => 'Zapsat na NFC tag';

  @override
  String get nfcHoldTitle => 'Přilož tag k telefonu';

  @override
  String nfcHoldBody(String name) {
    return 'Přilož prázdnou NFC nálepku k zadní straně telefonu. Klepnutím na ni pak spustíš $name.';
  }

  @override
  String get nfcWrittenTitle => 'Tag je hotový';

  @override
  String nfcWrittenBody(String name) {
    return 'Klepni telefonem na tento tag a spustíš $name. Funguje to i se zavřenou aplikací.';
  }

  @override
  String get nfcFailedTitle => 'Tag se nepodařilo zapsat';

  @override
  String get nfcReadonlyBody =>
      'Tento tag je zamčený a nejde změnit. Zkus jiný.';

  @override
  String get nfcTooSmallBody =>
      'Tento tag je moc malý. Použij nálepku NTAG213 nebo větší.';

  @override
  String get nfcFailedBody =>
      'Drž tag v klidu u zadní strany telefonu a zkus to znovu.';

  @override
  String get nfcOffTitle => 'NFC je vypnuté';

  @override
  String get nfcOffBody => 'Zapni NFC v nastavení Androidu a zkus to znovu.';

  @override
  String get nfcNoneTitle => 'Tento telefon nemá NFC';

  @override
  String get nfcNoneBody => 'Tento telefon neumí číst ani zapisovat NFC tagy.';

  @override
  String get nfcWriteAnother => 'Zapsat další tag';

  @override
  String get nfcUnsupportedBody =>
      'Tento telefon tento typ tagu neumí zapsat (často MIFARE Classic). Použij nálepku NTAG213, 215 nebo 216.';

  @override
  String get nfcTagsTitle => 'NFC tagy';

  @override
  String get nfcTagsSubtitle =>
      'Tagy, které spustí scénu nebo přepnou zařízení';

  @override
  String get nfcTagsEmpty =>
      'Zatím žádné tagy. Podrž dlaždici scény, světla, zásuvky nebo rolety a zvol Zapsat na NFC tag.';

  @override
  String get nfcTagRunsScene => 'Spustí scénu';

  @override
  String get nfcTagSwitches => 'Zapíná a vypíná';

  @override
  String nfcTagWritten(String when) {
    return 'zapsáno $when';
  }

  @override
  String nfcTagLastTap(String when) {
    return 'naposledy použito $when';
  }

  @override
  String get nfcTagNeverTapped => 'zatím nepoužito';

  @override
  String get nfcTagOffLabel => 'Vypnuto';

  @override
  String get nfcTagRewrite => 'Přepsat';

  @override
  String get nfcTagForget => 'Odebrat ze seznamu';

  @override
  String get nfcTagOffToast => 'Tento tag je v ZigDash vypnutý';

  @override
  String get nfcTagsNote =>
      'Vypnutý tag na tomto telefonu nic neudělá. Tagy zapsané před tímto seznamem tu nejsou: jednou je přepiš.';
}
