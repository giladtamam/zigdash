// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Последнее известное';

  @override
  String get reliabilityControlsUnavailable => 'Управление недоступно';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'Попробовать демо';

  @override
  String get navBrokers => 'Брокеры';

  @override
  String get navDashboards => 'Дашборды';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsDynamicColor => 'Цвета Material You';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; иначе используется цвет приложения';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Дома';

  @override
  String connLoadFailed(Object error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get connAddBroker => 'Добавить брокер';

  @override
  String get connEmpty =>
      'Подключений пока нет.\nНажмите «Добавить брокер», чтобы подключить ZigDash к вашему MQTT-серверу.';

  @override
  String get connNew => 'Новое подключение';

  @override
  String get connEdit => 'Изменить подключение';

  @override
  String get save => 'Сохранить';

  @override
  String get saving => 'Сохранение…';

  @override
  String get fieldRequired => 'Обязательно';

  @override
  String get connName => 'Название';

  @override
  String get connNameHint => 'Домашний брокер';

  @override
  String get connHost => 'Хост';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Локальный хост';

  @override
  String get connFindBrokers => 'Найти брокеры';

  @override
  String get connHowToFind => 'Где это найти?';

  @override
  String get connRescan => 'Искать снова';

  @override
  String get connBrokerNeedsLogin => 'Нужен вход';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Сканирование $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return 'Найдено брокеров: $count — нажмите, чтобы выбрать';
  }

  @override
  String get connFindBrokersNone => 'В вашей сети Wi-Fi брокеры не найдены.';

  @override
  String get connFindBrokersNoIp =>
      'Не удалось определить ваш адрес в Wi-Fi. Убедитесь, что Wi-Fi включён, и повторите попытку.';

  @override
  String get connHelpTitle => 'Как найти IP брокера';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT в Docker';

  @override
  String get connHelpDockerBody =>
      'IP брокера — это адрес в локальной сети компьютера, на котором работает Docker (NAS, Raspberry Pi и т. п.). Его можно найти в списке устройств роутера или командой \'hostname -I\' / \'ip addr\' на этом компьютере. Порт обычно 1883 (Mosquitto). Указывайте LAN-IP хоста, а не 127.0.0.1, даже если Mosquitto работает в отдельном контейнере.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'IP брокера — это IP-адрес хаба. Его можно найти в веб-интерфейсе SMLIGHT в разделе Settings → Network или в роутере. Порт 1883, по умолчанию без логина и пароля.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'В ZHA нет MQTT-брокера — она работает напрямую с Home Assistant, поэтому ZigDash не может к ней подключиться. Чтобы пользоваться ZigDash, перейдите на Zigbee2MQTT (доступен как дополнение Home Assistant или Docker-контейнер) с MQTT-брокером.';

  @override
  String get connHelpSameNetwork =>
      'Телефон и брокер должны быть в одной сети Wi-Fi (не в гостевой и не в изолированной VLAN).';

  @override
  String get connRemoteHost => 'Удалённый хост (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Используется, если локальный хост недоступен. Лучше указать Tailscale-IP хаба, например 100.x.y.z';

  @override
  String get connPort => 'Порт';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsername => 'Имя пользователя';

  @override
  String get connUsernameOptional => 'Имя пользователя (необязательно)';

  @override
  String get connPasswordOptional => 'Пароль (необязательно)';

  @override
  String get connPasswordKeepHint => 'Оставьте пустым, чтобы не менять';

  @override
  String get connAutoConnect => 'Подключаться при запуске';

  @override
  String get advanced => 'Дополнительно';

  @override
  String get connKeepAlive => 'Keep-alive (секунды)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Протокол';

  @override
  String get edit => 'Изменить';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get connDeleteTitle => 'Удалить подключение?';

  @override
  String connDeleteContent(Object name) {
    return 'Будут удалены «$name», его дашборды и панели, а также сохранённый пароль.';
  }

  @override
  String get statusDisconnected => 'Отключено';

  @override
  String get statusConnecting => 'Подключение';

  @override
  String get statusConnected => 'Подключено';

  @override
  String get statusReconnecting => 'Переподключение';

  @override
  String get statusError => 'Ошибка';

  @override
  String get statusConnectedRemote => 'Подключено · Удалённо';

  @override
  String get dashPlaceholder =>
      'Откройте брокер на вкладке «Брокеры», чтобы просматривать его дашборды и управлять ими.';

  @override
  String get dashAddDashboard => 'Добавить дашборд';

  @override
  String get dashEditDashboard => 'Изменить дашборд';

  @override
  String get dashAddPanel => 'Добавить панель';

  @override
  String get dashEmpty =>
      'Дашбордов пока нет.\nНажмите «Добавить дашборд», чтобы создать его для этого брокера.';

  @override
  String dashLoadFailed(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get panelPickerTitle => 'Добавить панель';

  @override
  String get panelPickerSectionControl => 'Управление';

  @override
  String get panelPickerSectionState => 'Состояние';

  @override
  String get panelPickerToggleTitle => 'Переключатель';

  @override
  String get panelPickerToggleSubtitle => 'Вкл/выкл для состояния устройства';

  @override
  String get panelPickerSliderBrightnessTitle => 'Ползунок — яркость';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Диммирование света (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Ползунок — положение';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Шторы / жалюзи (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Шторы';

  @override
  String get panelPickerCoverSubtitle =>
      'Шторы/жалюзи: ОТКР·СТОП·ЗАКР + ползунок положения';

  @override
  String get panelPickerScheduleTitle => 'Расписание';

  @override
  String get panelPickerScheduleSubtitle =>
      'Ежедневное время открытия/закрытия, выполняется на хабе (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Правило автозакрытия';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Автоматически закрывает устройство через N секунд после включения, выполняется на хабе (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Мультисостояние';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Группа кнопок для перечисления (например, OPEN/STOP/CLOSE)';

  @override
  String get panelPickerComboTitle => 'Список';

  @override
  String get panelPickerComboSubtitle => 'Выпадающий список для перечисления';

  @override
  String get panelPickerRadioTitle => 'Радиокнопки';

  @override
  String get panelPickerRadioSubtitle => 'Список радиокнопок для перечисления';

  @override
  String get panelPickerButtonTitle => 'Кнопка';

  @override
  String get panelPickerButtonSubtitle => 'Отправляет разовую команду';

  @override
  String get panelPickerTextInputTitle => 'Ввод текста';

  @override
  String get panelPickerTextInputSubtitle =>
      'Публикует произвольное значение или JSON';

  @override
  String get panelPickerLedTitle => 'Индикатор';

  @override
  String get panelPickerLedSubtitle =>
      'Цветной индикатор логического состояния (контакт, протечка)';

  @override
  String get panelPickerNodeStatusTitle => 'Статус узла';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Доступность устройства Z2M (онлайн/офлайн)';

  @override
  String get panelPickerProgressTitle => 'Шкала';

  @override
  String get panelPickerProgressSubtitle =>
      'Числовая шкала для батареи, качества связи и т. п.';

  @override
  String get panelPickerTextLogTitle => 'Текстовый журнал';

  @override
  String get panelPickerTextLogSubtitle =>
      'Прокручиваемая история сообщений топика';

  @override
  String get dashExportMenu => 'Экспорт дашбордов';

  @override
  String get dashImportMenu => 'Импорт дашбордов';

  @override
  String get dashExportTitle => 'Экспорт дашбордов';

  @override
  String get dashExportClose => 'Закрыть';

  @override
  String get dashExportCopy => 'Копировать';

  @override
  String get dashExportCopied => 'Скопировано в буфер обмена';

  @override
  String get dashImportTitle => 'Импорт дашбордов';

  @override
  String get dashImportHint => 'Вставьте сюда экспортированный JSON';

  @override
  String get dashImportButton => 'Импортировать';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count дашборда',
      many: 'Импортировано $count дашбордов',
      few: 'Импортировано $count дашборда',
      one: 'Импортирован $count дашборд',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get dashFormNew => 'Новый дашборд';

  @override
  String get dashFormEdit => 'Изменить дашборд';

  @override
  String get dashFormName => 'Название';

  @override
  String get dashFormNameHint => 'Кабинет';

  @override
  String get dashFormTopicPrefix => 'Префикс топика (необязательно)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/living-room';

  @override
  String get dashFormTopicPrefixHelper =>
      'Добавляется в начало топика каждой панели этого дашборда';

  @override
  String get dashFormColorSeed => 'Базовый цвет';

  @override
  String get dashFormIcon => 'Значок';

  @override
  String get dashFormLock => 'Блокировка редактирования';

  @override
  String get dashFormLockSubtitle => 'Скрывает «Изменить» для этой панели';

  @override
  String get dashFormDelete => 'Удалить дашборд';

  @override
  String get dashDeleteTitle => 'Удалить этот дашборд?';

  @override
  String get dashDeleteContent => 'Все его панели тоже будут удалены.';

  @override
  String get dashDeleteConfirm => 'Удалить';

  @override
  String panelFormNew(Object type) {
    return 'Новая панель: $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Изменить: $type';
  }

  @override
  String get panelTypeButton => 'Кнопка';

  @override
  String get panelTypeToggle => 'Переключатель';

  @override
  String get panelTypeSlider => 'Ползунок';

  @override
  String get panelTypeLed => 'Индикатор';

  @override
  String get panelTypeNodeStatus => 'Статус узла';

  @override
  String get panelTypeProgress => 'Шкала';

  @override
  String get panelTypeMultiState => 'Мультисостояние';

  @override
  String get panelTypeCombo => 'Список';

  @override
  String get panelTypeRadio => 'Радиокнопки';

  @override
  String get panelTypeCover => 'Шторы';

  @override
  String get panelTypeTextInput => 'Ввод текста';

  @override
  String get panelTypeTextLog => 'Текстовый журнал';

  @override
  String get panelTypeSchedule => 'Расписание';

  @override
  String get panelTypeAutoClose => 'Автозакрытие';

  @override
  String get panelTypeDevice => 'Устройство';

  @override
  String get panelTypeReading => 'Показание';

  @override
  String get panelFormName => 'Название';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Префикс дашборда: $prefix/ (если не переопределён ниже)';
  }

  @override
  String get panelFormTopicPrefixOverride =>
      'Свой префикс топика (необязательно)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/shutter';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Другое устройство на этом дашборде. Пусто = префикс дашборда.';

  @override
  String get panelFormPublishTopic => 'Топик публикации (суффикс)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Добавляется к действующему префиксу. Оставьте пустым, чтобы публиковать в сам префикс.';

  @override
  String get panelFormTopicSuffix => 'Топик (суффикс)';

  @override
  String get panelFormSubscribeTopic =>
      'Топик подписки (суффикс, необязательно)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Добавляется к префиксу дашборда. Пусто = подписка на сам префикс (состояние Z2M).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Пусто = подписка на сам префикс (состояние Z2M). Как топик публикации = он же.';

  @override
  String get tileSize => 'Размер';

  @override
  String get tileSizeSmall => 'Малая';

  @override
  String get tileSizeWide => 'Широкая';

  @override
  String get tileSizeFull => 'Во всю ширину';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — не более одного раза';

  @override
  String get panelFormQos1 => '1 — хотя бы один раз';

  @override
  String get panelFormQos2 => '2 — ровно один раз';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'Payload «вкл»';

  @override
  String get panelToggleOffPayload => 'Payload «выкл»';

  @override
  String get panelToggleJsonPath => 'Путь JSON (необязательно)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'Значение «вкл»';

  @override
  String get panelToggleOnMatchHelper =>
      'Значение по пути JSON, означающее «вкл» (например, \"ON\")';

  @override
  String get panelSliderMin => 'Мин.';

  @override
  String get panelSliderMax => 'Макс.';

  @override
  String get panelSliderStep => 'Шаг';

  @override
  String get panelSliderTemplate => 'Шаблон значения';

  @override
  String get panelSliderTemplateHelper =>
      'Слово value — подстановка: оно заменяется значением ползунка';

  @override
  String get panelSliderJsonPath => 'Путь JSON (необязательно)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'Путь JSON (необязательно)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'например, \"contact\", \"occupancy\", \"water_leak\"';

  @override
  String get panelLedOnMatch => 'Значение «вкл»';

  @override
  String get panelLedOnMatchHelper =>
      'Значение по пути JSON, при котором индикатор горит (например, \"true\", \"ON\")';

  @override
  String get panelLedOnLabel => 'Подпись «вкл» (необязательно)';

  @override
  String get panelLedOnLabelHint => 'ВКЛ';

  @override
  String get panelLedOffLabel => 'Подпись «выкл» (необязательно)';

  @override
  String get panelLedOffLabelHint => 'ВЫКЛ';

  @override
  String get panelNodeOnlinePayload => 'Payload «онлайн»';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Значение, означающее «онлайн» (по умолчанию в Z2M: \"online\")';

  @override
  String get panelNodeJsonPath => 'Путь JSON (необязательно)';

  @override
  String get panelNodeJsonPathHelper =>
      'Оставьте пустым для значения Z2M по умолчанию (строка \"online\"/\"offline\")';

  @override
  String get panelProgressMin => 'Мин.';

  @override
  String get panelProgressMax => 'Макс.';

  @override
  String get panelProgressUnit => 'Единица';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'Путь JSON (необязательно)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper =>
      'например, \"battery\", \"linkquality\"';

  @override
  String get panelOptionsJsonPath => 'Путь JSON (необязательно)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Поле полученного payload с текущим значением';

  @override
  String get panelOptionsHeader => 'Варианты';

  @override
  String get panelOptionsLabel => 'Подпись';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Совпадение (текущее значение)';

  @override
  String get panelOptionsAdd => 'Добавить вариант';

  @override
  String get panelCoverDescription =>
      'Кнопки «Открыть / Стоп / Закрыть» и ряд предустановок положения. Использует стандартные payload штор Z2M (state и position).';

  @override
  String get panelCoverPresets => 'Предустановки положения';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Проценты через запятую (0–100). Пусто = без ряда предустановок.';

  @override
  String get panelCoverShowSlider => 'Показывать ползунок положения';

  @override
  String get panelTextInputHint => 'Подсказка (необязательно)';

  @override
  String get panelTextInputHintHint => 'Введите значение…';

  @override
  String get panelTextInputTemplate => 'Шаблон';

  @override
  String get panelTextInputTemplateHelper =>
      'Слово value — подстановка: оно заменяется введённым текстом. По умолчанию публикуется сам текст.';

  @override
  String get panelTextInputClearAfterSend => 'Очищать после отправки';

  @override
  String get panelTextLogMaxLines => 'Макс. строк';

  @override
  String get panelTextLogMaxLinesHelper =>
      'Сколько последних сообщений хранить';

  @override
  String get panelTextLogJsonPath => 'Путь JSON (необязательно)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Записывать только это поле, а не весь payload';

  @override
  String get panelScheduleDescription =>
      'Выполняется на SMHUB через Node-RED — срабатывает, даже когда телефон выключен. Топик публикации выше — адрес команд для штор.';

  @override
  String get panelScheduleOpenTime => 'Время открытия';

  @override
  String get panelScheduleCloseTime => 'Время закрытия';

  @override
  String get panelScheduleOpenPayload => 'Payload открытия';

  @override
  String get panelScheduleClosePayload => 'Payload закрытия';

  @override
  String get panelScheduleEnabled => 'Включено';

  @override
  String get panelScheduleSavedOffline =>
      'Сохранено — нет подключения; расписание синхронизируется, когда появится связь.';

  @override
  String get panelAutoCloseDescription =>
      'Выполняется на SMHUB через Node-RED — срабатывает, даже когда телефон выключен. Топик публикации выше — адрес команд устройства (например, двери).';

  @override
  String get panelAutoCloseTriggerPath => 'Путь JSON триггера';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Поле JSON состояния устройства для отслеживания (по умолчанию: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Значение триггера';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Запускать таймер, когда поле триггера равно этому значению (по умолчанию: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Payload закрытия';

  @override
  String get panelAutoCloseDelaySeconds => 'Задержка (секунды)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1-3600. Сколько ждать после включения устройства перед публикацией payload закрытия.';

  @override
  String get panelAutoCloseEnabled => 'Включено';

  @override
  String get panelAutoCloseSavedOffline =>
      'Сохранено — нет подключения; правило синхронизируется, когда появится связь.';

  @override
  String get panelTileEdit => 'Изменить панель';

  @override
  String get panelTileDuplicate => 'Дублировать панель';

  @override
  String get panelTileMoveUp => 'Переместить вверх';

  @override
  String get panelTileMoveDown => 'Переместить вниз';

  @override
  String get panelTileDelete => 'Удалить панель';

  @override
  String get panelCoverOpen => 'Открыть';

  @override
  String get panelCoverStop => 'Стоп';

  @override
  String get panelCoverClose => 'Закрыть';

  @override
  String get panelToggleNoState => '(нет состояния)';

  @override
  String get panelToggleError => 'ошибка';

  @override
  String get panelStateOn => 'ВКЛ';

  @override
  String get panelStateOff => 'ВЫКЛ';

  @override
  String get panelNodeStatusOnline => 'онлайн';

  @override
  String get panelNodeStatusOffline => 'офлайн';

  @override
  String get panelNodeStatusUnknown => 'неизвестно';

  @override
  String get panelNodeStatusError => 'ошибка';

  @override
  String get panelMultiStateNoOptions => 'Варианты не настроены';

  @override
  String get panelTextInputDefaultHint => 'Введите значение…';

  @override
  String get panelTextLogWaiting => 'Ожидание сообщений…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Открытие в $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Закрытие в $time';
  }

  @override
  String get panelScheduleOfflineWarning => 'Планировщик офлайн — не сработает';

  @override
  String get panelScheduleDisabled => 'Отключено';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Далее: $action в $at';
  }

  @override
  String get panelScheduleActionOpen => 'открытие';

  @override
  String get panelScheduleActionClose => 'закрытие';

  @override
  String get panelAutoCloseIdle => 'Ожидание';

  @override
  String get panelAutoCloseDisabled => 'Отключено';

  @override
  String get panelAutoCloseOffline =>
      'Автоматизация офлайн — правило не сработает';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Закрытие через $seconds с';
  }

  @override
  String get panelAutoCloseClosingNow => 'Закрывается…';

  @override
  String get panelGridEmpty =>
      'Плиток пока нет.\nНажмите «Добавить плитку», чтобы разместить здесь устройства.';

  @override
  String get panelsOffline => 'Офлайн — показаны последние значения';

  @override
  String get connectionConnecting => 'Подключение…';

  @override
  String get connectionReconnecting => 'Переподключение…';

  @override
  String get connectionShowingLastKnownValues =>
      'Показаны последние известные значения';

  @override
  String get connectionFailed => 'Не удалось подключиться';

  @override
  String get connectionAutomaticRetry =>
      'Попытки подключения продолжатся автоматически';

  @override
  String get connectionReconnectNow => 'Подключиться сейчас';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsHelp => 'Помощь и руководство';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get settingsRateApp => 'Оценить ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Нравится? Короткий отзыв поможет другим найти приложение.';

  @override
  String get settingsFeatureRequest => 'Предложить функцию';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Расскажите, что сделает ZigDash лучше.';

  @override
  String get featureRequestGithub => 'На GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Публично: другие увидят и смогут проголосовать.';

  @override
  String get featureRequestEmail => 'По почте';

  @override
  String get featureRequestEmailSubtitle => 'Лично, напрямую разработчику.';

  @override
  String get featureRequestEmailSubject => 'ZigDash: предложение функции';

  @override
  String get featureRequestEmailPrompt =>
      'Что вы хотели бы видеть в ZigDash и зачем?';

  @override
  String get settingsReportProblem => 'Сообщить о проблеме';

  @override
  String get settingsReportProblemSubtitle =>
      'Что-то не работает или непонятно? Напишите.';

  @override
  String get reportProblemEmailSubject => 'ZigDash: сообщение о проблеме';

  @override
  String get reportProblemEmailPrompt => 'Что произошло и чего вы ожидали?';

  @override
  String get settingsBuyCoffee => 'Угостить кофе';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Бесплатно и с открытым кодом — чаевые помогают развитию.';

  @override
  String get a11yBackupMenu => 'Резервная копия';

  @override
  String get a11ySelectColor => 'Выбрать цвет';

  @override
  String get a11ySelectIcon => 'Выбрать значок';

  @override
  String get a11yDeleteOption => 'Удалить вариант';

  @override
  String get a11yPanelOptions => 'Параметры панели';

  @override
  String get a11yMoreOptions => 'Другие параметры';

  @override
  String get a11yRefresh => 'Обновить';

  @override
  String get a11yDeleteConnection => 'Удалить подключение';

  @override
  String get controlNotConnected => 'Нет подключения — изменение не отправлено';

  @override
  String get discoverFromDevice => 'Добавить из устройства…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Автоопределение устройства Zigbee2MQTT';

  @override
  String get discoverTitle => 'Добавить из устройства';

  @override
  String get discoverBaseTopic => 'Базовый топик Zigbee2MQTT';

  @override
  String get discoverScanning => 'Поиск устройств…';

  @override
  String get discoverNone => 'Устройства не найдены.';

  @override
  String get discoverFailed =>
      'Список устройств не найден. Проверьте базовый топик и подключение к брокеру.';

  @override
  String get retry => 'Повторить';

  @override
  String get previewTitle => 'Предпросмотр';

  @override
  String previewWaiting(Object topic) {
    return 'Ожидание сообщения в $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Извлечено ($path): $value';
  }

  @override
  String get previewNoValue => '(нет значения по этому пути)';

  @override
  String get connErrorTitle => 'Ошибка подключения';

  @override
  String get connErrorUnknown => 'Подробности ошибки недоступны.';

  @override
  String get connTestButton => 'Проверить подключение';

  @override
  String get connTestOk => 'Подключение успешно';

  @override
  String connTestFailed(Object error) {
    return 'Не удалось подключиться: $error';
  }

  @override
  String get devicesTitle => 'Устройства';

  @override
  String get devicesAddButton => 'Добавить устройство';

  @override
  String get devicesPairingTitle => 'Сопряжение — нажмите кнопку на устройстве';

  @override
  String devicesPairingHint(int seconds) {
    return 'Поиск новых устройств… $seconds с';
  }

  @override
  String get devicesPairingStop => 'Стоп';

  @override
  String get devicesNone => 'Устройства не найдены.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT не прислал список устройств. Так бывает после перезапуска MQTT-брокера.';

  @override
  String get devicesRestartZ2m => 'Перезапустить Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Zigbee2MQTT перезапускается. Устройства появятся через несколько секунд.';

  @override
  String get devicesBattery => 'Батарея';

  @override
  String get devicesLinkQuality => 'Связь';

  @override
  String get devicesOnline => 'Онлайн';

  @override
  String get devicesOffline => 'Офлайн';

  @override
  String devicesPaired(Object name) {
    return 'Готово: $name';
  }

  @override
  String get devicesPairedHint =>
      'Устройство добавлено в сеть. Чтобы разместить его на дашборде, используйте «Добавить из устройства» на этом дашборде.';

  @override
  String get scenesTitle => 'Сцены';

  @override
  String get scenesNone =>
      'Сцен пока нет. Настройте устройства как нужно и сохраните их состояние как сцену.';

  @override
  String get scenesNewButton => 'Новая сцена';

  @override
  String scenesActivated(Object name) {
    return 'Сцена «$name» включена';
  }

  @override
  String get scenesActivateOffline => 'Нет подключения — сцену не включить';

  @override
  String get sceneFormNewTitle => 'Новая сцена';

  @override
  String get sceneFormEditTitle => 'Изменить сцену';

  @override
  String get sceneFormNameLabel => 'Название сцены';

  @override
  String get sceneFormDevicesHeader => 'Устройства для сцены';

  @override
  String get sceneFormCaptureHint =>
      'Для каждого выбранного устройства сохраняется текущее изменяемое состояние (вкл/выкл, яркость, цвет, положение…). Значения только для чтения игнорируются.';

  @override
  String get sceneFormNoDevices =>
      'Управляемые устройства не найдены. Убедитесь, что они сопряжены, и нажмите «Обновить».';

  @override
  String get sceneFormReadingState => 'Чтение текущего состояния…';

  @override
  String get sceneCtrlPower => 'Питание';

  @override
  String get sceneCtrlBrightness => 'Яркость';

  @override
  String get sceneCtrlPosition => 'Положение';

  @override
  String sceneFormSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get sceneFormNoDevicesSelected => 'Выберите хотя бы одно устройство.';

  @override
  String get sceneFormNothingCaptured =>
      'У выбранных устройств не нашлось изменяемых состояний.';

  @override
  String get sceneDeleteTitle => 'Удалить сцену?';

  @override
  String sceneDeleteMessage(Object name) {
    return 'Сцена «$name» будет удалена. Устройства сохранят текущее состояние.';
  }

  @override
  String get sceneEditAction => 'Изменить';

  @override
  String get sceneDeleteAction => 'Удалить';

  @override
  String get sceneAddToDashboard => 'Добавить на дашборд';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Добавлено на «$name»';
  }

  @override
  String sceneActionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count устройства',
      many: '$count устройств',
      few: '$count устройства',
      one: '$count устройство',
    );
    return '$_temp0';
  }

  @override
  String get scenesAllShutters => 'Все рольставни';

  @override
  String get sceneCloseAllShutters => 'Закрыть все рольставни';

  @override
  String get sceneOpenAllShutters => 'Открыть все рольставни';

  @override
  String get sceneStopAllShutters => 'Остановить все рольставни';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рольставни',
      many: '$count рольставен',
      few: '$count рольставни',
      one: '1 рольставня',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Какие рольставни…';

  @override
  String get sceneWhichShuttersHint =>
      'Включены все рольставни этого дома. Снимите отметку с тех, что должны остаться в стороне, например с гаражных ворот.';

  @override
  String get scenesYours => 'Ваши сцены';

  @override
  String get panelTypeScene => 'Сцена';

  @override
  String get panelPickerSceneTitle => 'Кнопка сцены';

  @override
  String get panelPickerSceneSubtitle =>
      'Включает сохранённую сцену одним нажатием';

  @override
  String get panelSceneChoose => 'Сцена';

  @override
  String get panelSceneMissing => 'Сцена не найдена — выберите заново';

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
  String get guidedConnectTitle => 'Настройка брокера';

  @override
  String get guidedConnectIntro =>
      'Мы проверим каждый этап подключения и покажем ваши Zigbee-устройства.';

  @override
  String get guidedBaseTopic => 'Базовый топик';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Проверить и подключить';

  @override
  String get guidedTesting => 'Проверка подключения…';

  @override
  String get stepResolve => 'Разрешение имени хоста';

  @override
  String get stepTcp => 'TCP-соединение';

  @override
  String get stepConnack => 'Рукопожатие MQTT';

  @override
  String get stepAuth => 'Аутентификация';

  @override
  String get stepDevices => 'Поиск устройств';

  @override
  String get diagResolveFail =>
      'Не удалось разрешить имя хоста. Проверьте введённый адрес.';

  @override
  String get diagResolveTimeout =>
      'Истекло время разрешения имени хоста. Проверьте адрес и сеть.';

  @override
  String get diagTcpFail =>
      'Брокер не принял подключение. Проверьте, что ваш MQTT-брокер (обычно Mosquitto) запущен и принимает подключения с других устройств, а адрес и порт (обычно 1883) указаны верно.';

  @override
  String get diagTcpTimeout =>
      'Истекло время подключения к брокеру. Возможно, он выключен или недоступен.';

  @override
  String get diagConnackFail =>
      'Брокер не завершил рукопожатие MQTT. Убедитесь, что это MQTT-брокер (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'Брокер не ответил на вход вовремя. Home Assistant может проверять его несколько секунд, попробуйте ещё раз.';

  @override
  String get diagAuthRejected =>
      'Брокер отклонил имя пользователя или пароль. Проверьте учётные данные.';

  @override
  String get diagAuthRefused =>
      'Брокер отказал в подключении. Проверьте настройки подключения.';

  @override
  String get diagResolveLocalName =>
      'Телефон не нашёл это имя. Android часто не распознаёт имена, оканчивающиеся на .local, поэтому введите IP-адрес (Home Assistant показывает его в Настройки › Система › Сеть).';

  @override
  String get diagTcpHaNoBroker =>
      'Это ваш Home Assistant, но MQTT-брокер на нём не запущен. Установите и запустите дополнение Mosquitto broker (Настройки › Дополнения) и попробуйте снова.';

  @override
  String get diagTcpSmlightClosed =>
      'Это ваш хаб SMLIGHT, но его MQTT-брокер не принимает подключения с других устройств. На веб-странице хаба откройте Settings › MQTT, включите Allow External, сохраните и попробуйте снова.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'По этому адресу работает Zigbee2MQTT, но к брокеру он обращается по другому имени (см. Zigbee2MQTT › Settings › MQTT › Server). Если это другая машина, введите её адрес, обычно с портом 1883. Если это контейнер на этой машине, опубликуйте его порт (ports: \"1883:1883\") и разрешите ему слушать сеть, затем попробуйте снова.';

  @override
  String get diagTcpZ2mNoBroker =>
      'По этому адресу работает Zigbee2MQTT, но его MQTT-брокер не принимает подключения с других устройств. Mosquitto слушает только на своей машине, пока вы не добавите в mosquitto.conf строки «listener 1883» и «allow_anonymous true» (или не настроите пароль). Перезапустите Mosquitto и попробуйте снова.';

  @override
  String get diagAuthRejectedHa =>
      'Брокер Home Assistant отклонил вход. Используйте имя и пароль пользователя Home Assistant (Настройки › Люди › Пользователи); лучше всего отдельного пользователя только для MQTT.';

  @override
  String foundDevices(int count) {
    return 'Найдено устройств: $count';
  }

  @override
  String get foundDevicesHint =>
      'Ваши Zigbee-устройства видны. Продолжите, чтобы собрать дашборд.';

  @override
  String get noDevicesTitle => 'Подключено — устройств пока нет';

  @override
  String get noDevicesHint =>
      'ZigDash видит ваш брокер, но пока не нашёл Zigbee-устройств. Начните сопряжение, чтобы добавить их.';

  @override
  String get startPairing => 'Начать сопряжение';

  @override
  String get pairingEnabled =>
      'Сопряжение включено. Нажмите кнопку сопряжения на устройстве, чтобы подключить его.';

  @override
  String get continueToDashboard => 'Перейти к дашборду';

  @override
  String get guidedBackToForm => 'Изменить настройки';

  @override
  String get guidedStuckTitle => 'Застряли? Спросите человека';

  @override
  String get guidedStuckBody =>
      'Две попытки без подключения. Напишите, какой у вас хаб и что вы ввели, и мы поможем его найти.';

  @override
  String get guidedStuckTelegram => 'Спросить в Telegram';

  @override
  String get guidedStuckHelp => 'Советы и почта';

  @override
  String ladderTriedHint(Object count) {
    return 'Проверено адресов: $count';
  }

  @override
  String get guidedSaveFailed =>
      'Не удалось сохранить подключение. Повторите попытку.';

  @override
  String get setupWelcomeTitle => 'Добро пожаловать в ZigDash';

  @override
  String get setupWelcomeHeadline => 'Ваш дом на Zigbee — в телефоне';

  @override
  String get setupWelcomeBody =>
      'Нужен только маленький хаб с Zigbee2MQTT: хаб SMLIGHT, Raspberry Pi или любой компьютер с Linux. Home Assistant не нужен, а если он у вас есть, ZigDash работает и с ним. Всё остаётся локально, без облака.';

  @override
  String get setupFindMySetup => 'Найти мою систему';

  @override
  String get setupErrPageTitle => 'Страница Zigbee2MQTT не ответила';

  @override
  String get setupErrPageBody =>
      'По этому адресу не ответила страница Zigbee2MQTT. Откройте его в браузере телефона, чтобы проверить, и скопируйте адрес точно (с портом, часто 8080). Если страница просит токен, введите вместо этого данные брокера.';

  @override
  String get setupErrPageAction => 'Попробовать ещё раз';

  @override
  String get setupLookWider => 'Искать во всей сети';

  @override
  String get setupAsk => 'Что управляет вашим Zigbee?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'На Raspberry Pi, сервере или в Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'С дополнением Zigbee2MQTT или ZHA';

  @override
  String get setupAskSmlight => 'Хаб SMLIGHT';

  @override
  String get setupAskSmlightSub => 'SLZB или SMHUB с Zigbee2MQTT';

  @override
  String get setupAskNothing => 'Пока ничего?';

  @override
  String get setupAskHaWhich => 'Как ваш Home Assistant работает с Zigbee?';

  @override
  String get setupAskHaZ2m => 'Дополнение Zigbee2MQTT';

  @override
  String get setupAskHaZ2mSub => 'Войти через Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, встроенный Zigbee Home Assistant';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, без Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Подключиться к моей странице Zigbee2MQTT';

  @override
  String get setupManualEntryAdvanced => 'Данные брокера (для опытных)';

  @override
  String get z2mPageTitle => 'Ваша страница Zigbee2MQTT';

  @override
  String get z2mPageBody =>
      'Адрес в браузере, когда открыта страница Zigbee2MQTT — та, где вы сопрягаете устройства. Имя пользователя и пароль MQTT не нужны.';

  @override
  String get z2mPageLabel => 'Адрес страницы';

  @override
  String get z2mPageConnect => 'Подключиться';

  @override
  String z2mPageFoundName(String host, String ip) {
    return '$host найден по адресу $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Для $host в этой сети никто не ответил';
  }

  @override
  String get engineNeedsBrokerTitle => 'Автоматизациям нужен ваш MQTT-брокер';

  @override
  String get engineNeedsBrokerBody =>
      'Этот дом подключается через страницу Zigbee2MQTT, и этого хватает для панелей. Автоматизации, оповещения и история работают в ZigDash Engine на хабе, который общается через MQTT-брокер. Введите его данные один раз, и дальше ZigDash будет подключаться через брокер.';

  @override
  String get engineNeedsBrokerButton => 'Ввести данные брокера';

  @override
  String get connFromPageNote =>
      'Этот дом подключается через страницу Zigbee2MQTT. Введите ваш MQTT-брокер (обычно та же машина, порт 1883), чтобы включить автоматизации, оповещения и историю. После сохранения ZigDash подключается через брокер.';

  @override
  String get setupManualEntry => 'Ввести вручную';

  @override
  String get setupScanningTitle => 'Поиск подключения…';

  @override
  String get setupScanningHint =>
      'Это устройство должно быть в одной локальной сети с хостом Zigbee2MQTT.';

  @override
  String get setupCandidateFound => 'Найдено возможное подключение';

  @override
  String get setupNoCandidatesTitle => 'Подключение не найдено';

  @override
  String get setupNoCandidatesBody => 'Где работает Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: убедитесь, что дополнения MQTT-брокера (например, Mosquitto) и Zigbee2MQTT установлены и запущены.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: проверьте, что брокер (например, Mosquitto) и служба Zigbee2MQTT запущены, а порт 1883 доступен.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: откройте веб-интерфейс устройства, перейдите в Settings > MQTT, включите Allow External, чтобы телефон мог подключиться к брокеру, и проверьте, что Zigbee2MQTT запущен.';

  @override
  String get setupTryAgain => 'Повторить';

  @override
  String get reminderButton => 'Напомнить завтра';

  @override
  String get reminderSet => 'Мы напомним вам завтра, на этом телефоне.';

  @override
  String get reminderNoPermission =>
      'Уведомления ZigDash выключены, поэтому напоминания не будет. Их можно включить в настройках Android.';

  @override
  String get reminderChannel => 'Напоминание о настройке';

  @override
  String get reminderTitle => 'Завершите настройку ZigDash';

  @override
  String get reminderBody =>
      'Вы дома, в своей сети Wi-Fi? Нажмите, чтобы попробовать снова: это займёт около минуты.';

  @override
  String get setupWelcomeNoZ2m => 'Ещё нет Zigbee2MQTT?';

  @override
  String get setupWelcomeDemo => 'Попробовать демо-дом';

  @override
  String get setupWelcomeHubs => 'Какой хаб выбрать';

  @override
  String get haConnectTitle => 'Подключиться через Home Assistant';

  @override
  String get haConnectIntro =>
      'Ваш телефон не достаёт до брокера, но достаёт до Home Assistant. Войдите один раз, и ZigDash будет общаться с Zigbee2MQTT через Home Assistant: дома или вне дома, без настроек брокера.';

  @override
  String get haConnectAddressHelp =>
      'Адрес, по которому вы открываете Home Assistant: 192.168.1.20:8123 или удалённый адрес, например ваш адрес Nabu Casa или Cloudflare';

  @override
  String get haConnectSignInHelp =>
      'Собственная страница входа Home Assistant откроется в браузере. ZigDash никогда не видит ваш пароль.';

  @override
  String get haConnectKeeps =>
      'ZigDash хранит этот вход на вашем телефоне и действует в Home Assistant от вашего имени, только для MQTT. Завершить это можно в любой момент в Home Assistant: Профиль › Безопасность.';

  @override
  String get haConnectTokenHelp =>
      'В Home Assistant откройте свой профиль, затем Безопасность › Долгосрочные токены доступа › Создать токен. Скопируйте его и вставьте сюда. ZigDash хранит его на этом телефоне для подключения; удалите его в Home Assistant, когда захотите это завершить.';

  @override
  String get haConnectWithToken => 'Подключиться с токеном';

  @override
  String get haConnectChecking => 'Проверяем Home Assistant…';

  @override
  String get setupStillChecking =>
      'Проверка ещё идёт. Это может занять до 30 секунд.';

  @override
  String get aiHelpTitle => 'Застряли? Спросите своего ИИ-помощника';

  @override
  String get aiHelpBody =>
      'ZigDash опишет, что нашёл, для ChatGPT, Claude, Gemini или любого ИИ-приложения, без паролей и адресов. Вы увидите текст до отправки.';

  @override
  String get aiHelpButton => 'Спросить ИИ';

  @override
  String get aiHelpPreviewTitle => 'Что будет отправлено';

  @override
  String get aiHelpShare => 'Отправить в ИИ-приложение';

  @override
  String get aiHelpCopied => 'Скопировано. Вставьте в любой ИИ-чат.';

  @override
  String get haConnectWhereAddress =>
      'Не знаете адрес? В приложении Home Assistant откройте Настройки › Приложение-компаньон и нажмите на свой сервер: адрес там. На компьютере это адрес, который браузер показывает при открытом Home Assistant.';

  @override
  String get haFindLooking => 'Ищем Home Assistant в этой сети…';

  @override
  String get haFindSeveral =>
      'Найдено несколько Home Assistant. Нажмите на нужный:';

  @override
  String get haFindNone =>
      'Этот телефон не видит Home Assistant в этой сети Wi-Fi. Используйте адрес, который открывает ваше приложение Home Assistant: часто удалённый, например https://abcd1234.ui.nabu.casa или https://myhome.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Этот адрес в другой сети, чем телефон, который находится в $network. Используйте адрес, который открывает ваше приложение Home Assistant, часто удалённый, или подключите телефон к сети, где работает Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Телефон не нашёл это имя: Android часто не открывает имена .local. Введите IP-адрес Home Assistant (например, 192.168.1.20:8123) или его удалённый адрес.';

  @override
  String get haConnectRemoteUnreachable =>
      'По этому удалённому адресу ничего не ответило. Откройте его в браузере этого телефона, чтобы проверить, что он работает, и скопируйте его точно так, как показывает приложение Home Assistant.';

  @override
  String get setupNoWifiHa => 'Используете Home Assistant? Войти';

  @override
  String get haConnectNotAdmin =>
      'Ваш пользователь Home Assistant не администратор. ZigDash нужен администратор для MQTT в Home Assistant. Войдите как администратор или вставьте токен, созданный администратором.';

  @override
  String get haConnectNoMqtt =>
      'В этом Home Assistant нет интеграции MQTT. Zigbee2MQTT она тоже нужна: добавьте в Home Assistant дополнение Mosquitto broker и интеграцию MQTT, затем попробуйте снова.';

  @override
  String get haConnectSignInFailed =>
      'Вход не завершился. Попробуйте снова или используйте долгосрочный токен.';

  @override
  String get setupHaShortcut =>
      'Zigbee2MQTT работает в Home Assistant? Пропустите брокер и его логин: войдите с учётной записью администратора Home Assistant. Работает из любой сети.';

  @override
  String get haConnectButton => 'Подключиться через Home Assistant';

  @override
  String get haConnectManualLink =>
      'Используете Home Assistant? Подключитесь через него';

  @override
  String get haConnectEmptyNote =>
      'Этот телефон не достаёт до брокера? Home Assistant может взять подключение на себя.';

  @override
  String get haHomeConnected => 'Подключено через Home Assistant';

  @override
  String get haHomeChange =>
      'Если вход перестал работать, на новом телефоне или после удаления токена в Home Assistant, войдите заново здесь. Завершить его можно и в Home Assistant: Профиль › Безопасность.';

  @override
  String get haHomeSignInAgain => 'Войти заново';

  @override
  String get haHomeRemote => 'Удалённый адрес Home Assistant (необязательно)';

  @override
  String get setupAuthTitle => 'Брокеру нужен вход';

  @override
  String setupAuthBody(Object host) {
    return 'Введите имя пользователя и пароль MQTT для $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Имя пользователя или пароль отклонены. Проверьте их и повторите попытку.';

  @override
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT уже подключается к этому брокеру: на его веб-странице в Настройки › MQTT указано имя пользователя. Используйте этого пользователя и его пароль.';

  @override
  String get setupAuthWhich =>
      'Это логин MQTT, а не пароль от веб-страницы вашего хаба.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: используйте пользователя Home Assistant. Обычно для MQTT создают отдельного в Настройки › Люди › Пользователи, и дополнение Mosquitto его принимает.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi или Docker: пользователь и пароль из файла паролей Mosquitto, те же, что в configuration.yaml Zigbee2MQTT в разделе mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: логин, показанный на веб-странице хаба в Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'Проверка подключения…';

  @override
  String get setupReviewTitle => 'Ваши устройства';

  @override
  String setupReviewSubtitle(int count) {
    return 'Найдено устройств: $count. Выберите, что будет на первом дашборде.';
  }

  @override
  String get setupReviewLastStep =>
      'Последний шаг: отметьте нужные устройства и нажмите «Создать панель» внизу.';

  @override
  String get setupLeaveTitle => 'Создать панель?';

  @override
  String get setupLeaveBody =>
      'Ваши устройства найдены. Создайте панель сейчас или начните настройку заново и потеряйте этот список.';

  @override
  String get setupStartOver => 'Начать заново';

  @override
  String setupCreateWithCount(Object count) {
    return 'Создать дашборд ($count)';
  }

  @override
  String get setupReviewNoneSelected =>
      'Пока ничего не отмечено. Отметьте устройства для дашборда или создайте его пустым и добавьте плитки позже.';

  @override
  String get setupCreateEmpty => 'Создать пустой дашборд';

  @override
  String get setupGroupOther => 'Другие устройства';

  @override
  String get setupGroupUnsupported => 'Неподдерживаемые устройства';

  @override
  String get setupCreatingTitle => 'Создание дашборда…';

  @override
  String get setupReadyTitle => 'Дашборд готов';

  @override
  String setupReadyBody(Object count) {
    return 'Создано элементов управления: $count.';
  }

  @override
  String get setupOpenDashboard => 'Открыть дашборд';

  @override
  String get setupErrUnreachableTitle => 'Адрес недоступен';

  @override
  String get setupErrUnreachableBody =>
      'Это устройство и хост Zigbee2MQTT не видят друг друга. Проверьте, что они в одной локальной сети.';

  @override
  String get setupErrUnreachableAction => 'Повторить';

  @override
  String get setupErrPortClosedTitle => 'На этом порту никто не отвечает';

  @override
  String get setupErrPortClosedBody =>
      'Хост доступен, но MQTT-брокер не ответил. Проверьте, что брокер запущен и порт указан верно.';

  @override
  String get setupErrPortClosedAction => 'Повторить';

  @override
  String get setupErrAuthRequiredTitle => 'Требуется вход';

  @override
  String get setupErrAuthRequiredBody =>
      'Для этого брокера нужны имя пользователя и пароль.';

  @override
  String get setupErrAuthRequiredAction => 'Войти';

  @override
  String get setupErrAuthRejectedTitle => 'Вход отклонён';

  @override
  String get setupErrAuthRejectedBody => 'Брокер отклонил эти учётные данные.';

  @override
  String get setupErrAuthRejectedAction => 'Повторить';

  @override
  String get setupErrNotZ2mTitle => 'Здесь нет Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'Здесь отвечает MQTT-брокер, но топики Zigbee2MQTT не найдены. Возможно, это другой брокер.';

  @override
  String get setupErrNotZ2mAction => 'Выбрать другой';

  @override
  String get setupErrNoDevicesTitle => 'Устройства не получены';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT запущен, но во время проверки не опубликовал ни одного устройства. Сначала выполните сопряжение устройств в Zigbee2MQTT.';

  @override
  String get setupErrNoDevicesAction => 'Проверить снова';

  @override
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT не прислал список устройств';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT отвечает, но список устройств не пришёл. Обычно так бывает после перезапуска MQTT-брокера: Zigbee2MQTT до версии 2.14.2 снова присылает список только после собственного перезапуска. Перезапустите Zigbee2MQTT (или обновите его) и попробуйте ещё раз.';

  @override
  String get setupErrListMissingAction => 'Попробовать ещё раз';

  @override
  String get setupErrHaNoZ2mTitle => 'В этом Home Assistant нет Zigbee2MQTT';

  @override
  String get setupErrHaNoZ2mBody =>
      'Вы вошли в Home Assistant, но Zigbee2MQTT ничего не отправляет через его MQTT. Если ваши Zigbee-устройства в ZHA (встроенный Zigbee Home Assistant), ZigDash их не видит: он работает с Zigbee2MQTT. Если вы используете дополнение Zigbee2MQTT, откройте его в Home Assistant, проверьте, что оно запущено, и попробуйте ещё раз.';

  @override
  String get setupErrHaNoZ2mAction => 'Попробовать ещё раз';

  @override
  String get setupErrScanFailedTitle => 'Нет локальной сети';

  @override
  String get setupErrScanFailedBody =>
      'Не удалось определить локальную сеть этого устройства. Подключитесь к Wi-Fi и повторите попытку.';

  @override
  String get setupErrScanFailedAction => 'Повторить';

  @override
  String get setupNoWifiTitle => 'Телефон не подключён к Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'Он использует мобильный интернет и поэтому не видит устройства дома. Включите Wi-Fi и подключитесь к домашней сети: настройка начнётся снова сама.';

  @override
  String get setupNoWifiOffline =>
      'У телефона нет подключения к сети. Включите Wi-Fi и подключитесь к домашней сети: настройка начнётся снова сама.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash не может найти Wi-Fi-адрес телефона. Проверьте, что Wi-Fi включён и подключён к домашней сети: настройка начнётся снова сама. Через VPN или не дома? Введите данные вручную.';

  @override
  String get setupOpenWifiSettings => 'Открыть настройки Wi-Fi';

  @override
  String get setupWaitingForWifi => 'Ожидание Wi-Fi…';

  @override
  String get setupErrSaveFailedTitle => 'Не удалось сохранить';

  @override
  String get setupErrSaveFailedBody =>
      'Не удалось сохранить настройку. Ничего не сохранилось частично — можно спокойно повторить.';

  @override
  String get setupErrSaveFailedAction => 'Повторить';

  @override
  String get setupErrUnknownTitle => 'Что-то пошло не так';

  @override
  String get setupErrUnknownBody => 'Произошла непредвиденная ошибка.';

  @override
  String get setupErrUnknownAction => 'Повторить';

  @override
  String get setupErrLoginNoAnswerTitle => 'Брокер не ответил на вход';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Ваш брокер найден, но он не ответил на имя пользователя и пароль вовремя. Дополнение Mosquitto в Home Assistant проверяет вход через Home Assistant, и на Raspberry Pi это может занять несколько секунд. Попробуйте ещё раз и проверьте, что такой пользователь есть в Home Assistant.';

  @override
  String get setupErrLoginNoAnswerAction => 'Повторить';

  @override
  String get setupNoZ2mTitle =>
      'Брокер работает, но Zigbee2MQTT здесь ничего не публикует';

  @override
  String setupNoZ2mBody(String base) {
    return 'Мы слушали $base/bridge и ничего не получили.';
  }

  @override
  String get setupBaseTopicQuestion => 'Используете другой базовый топик?';

  @override
  String get setupGuidesTitle => 'Настройка Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'А пока попробуйте демо';

  @override
  String get setupPlatformQuestion => 'Пока мы ищем: где работает Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => 'Где работает Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Выберите подключение';

  @override
  String get setupScanDoneHint =>
      'Ответило несколько брокеров. Выберите тот, который использует Zigbee2MQTT.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'Хаб SMLIGHT';

  @override
  String get setupPlatformPi => 'Raspberry Pi или Docker';

  @override
  String get setupPlatformZha => 'ZHA, без Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash показывает устройства из Zigbee2MQTT, поэтому не видит устройства в ZHA, встроенном Zigbee Home Assistant. Попробуйте демо-дом, чтобы увидеть, как работает ZigDash.';

  @override
  String get setupPlatformNotSure => 'Не знаю';

  @override
  String setupScanProgress(int checked, int total) {
    return 'Проверено $checked из $total адресов';
  }

  @override
  String get setupScanHintHa => 'Ищем Home Assistant и его MQTT-брокер…';

  @override
  String get setupScanHintSmlight => 'Ищем ваш хаб SMLIGHT…';

  @override
  String get setupScanHintPi => 'Ищем MQTT-брокер в вашей сети…';

  @override
  String setupHubSeenHa(String host) {
    return 'Найден Home Assistant по адресу $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Найден Zigbee2MQTT по адресу $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Найден ваш хаб SMLIGHT по адресу $host';
  }

  @override
  String get setupHubSeenHint => 'Всё ещё ищем его MQTT-брокер…';

  @override
  String get setupNoBrokerHaTitle =>
      'Home Assistant найден, но MQTT-брокера нет';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant находится по адресу $host, но на MQTT-порту 1883 никто не отвечает. В Home Assistant откройте Настройки › Дополнения, установите и запустите дополнение Mosquitto broker, затем попробуйте снова.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Используете встроенный Zigbee в Home Assistant (ZHA) вместо Zigbee2MQTT? ZigDash работает только с Zigbee2MQTT, поэтому не видит устройства ZHA. Демо покажет, что вы получите.';

  @override
  String get setupVpnHint =>
      'Включён VPN, и он может скрыть домашнюю сеть от поиска. Если вы дома, выключите VPN и нажмите «Повторить». Или оставьте его включённым и разрешите доступ к локальной сети (LAN) в настройках VPN-приложения.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Zigbee2MQTT найден, но его брокер недоступен';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT находится по адресу $host, но его MQTT-брокер не принимает подключения с вашего телефона. Mosquitto 2 слушает только на самом хабе, пока в его конфигурации нет \'listener 1883\' и \'allow_anonymous true\' (или логина). Перезапустите его и попробуйте снова.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Хаб SMLIGHT найден, но MQTT выключен';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Ваш хаб находится по адресу $host, но его MQTT-брокер недоступен. В веб-интерфейсе хаба откройте Settings › MQTT, включите Allow External и проверьте, что Zigbee2MQTT запущен. Затем попробуйте снова.';
  }

  @override
  String get setupZ2mAsking => 'Спрашиваем Zigbee2MQTT, где его брокер…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Ваш брокер принимает подключения только со своей машины';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT использует $server, и с вашего телефона там никто не отвечает. Mosquitto 2 так работает по умолчанию. Добавьте эти две строки в mosquitto.conf, перезапустите Mosquitto и попробуйте снова:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Нужен логин вместо открытого доступа? Используйте password_file вместо allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT обращается к брокеру по имени, которое телефон использовать не может';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT использует $server. «$name» — имя, известное только машине с Zigbee2MQTT: сервис Docker или имя хоста. Введите вместо него IP-адрес машины с брокером и порт $port. Если брокер работает в контейнере, его порт должен быть также опубликован на машине (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'Веб-страница Zigbee2MQTT защищена токеном, поэтому приложение не смогло узнать, где её брокер. Введите адрес брокера из настроек Zigbee2MQTT › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT использует брокер по адресу $server, но он не ответил вашему телефону. Проверьте, что брокер запущен и телефон в той же сети.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Подключиться к $host';
  }

  @override
  String get setupNotFoundHa =>
      'Home Assistant в этой сети не найден. Проверьте, что телефон в той же сети Wi-Fi, что и Home Assistant (не гостевой), и попробуйте снова. Если знаете адрес, введите его ниже.';

  @override
  String get setupNotFoundSmlight =>
      'Хаб SMLIGHT в этой сети не найден. Проверьте, что хаб включён и телефон в той же сети Wi-Fi, и попробуйте снова. Если знаете адрес, введите его ниже.';

  @override
  String get setupNotFoundPi =>
      'MQTT-брокер в этой сети не найден. Проверьте, что Mosquitto запущен и слушает сеть (порт 1883), а телефон подключён к той же сети Wi-Fi. Затем попробуйте снова.';

  @override
  String get setupAddressQuestionHa => 'Где вы открываете Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'Какой адрес у вашего хаба SMLIGHT?';

  @override
  String get setupAddressQuestionPi =>
      'Какой адрес у машины, на которой работает Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      'Какой адрес у вашего хаба или машины, на которой работает Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'Адрес вроде 192.168.1.20, имя или ссылка из браузера';

  @override
  String get setupAddressCheck => 'Проверить этот адрес';

  @override
  String setupAddressNothing(String host) {
    return 'По адресу $host никто не ответил. Проверьте адрес и что телефон в той же сети Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return 'Не удалось разрешить $host. Имена на .local часто не работают в Android; попробуйте IP-адрес. Home Assistant показывает его в Настройки › Система › Сеть.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host не находится с этого телефона: Android часто не умеет разрешать имена .local. Нажмите «$button» выше и укажите адрес, по которому открываете Home Assistant в браузере, или введите здесь его IP-адрес. Home Assistant показывает его в Настройки › Система › Сеть.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host не в вашей домашней сети. Используйте адрес, который работает в вашем Wi-Fi, а не удалённую ссылку вроде Nabu Casa или DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Сначала введите адрес.';

  @override
  String get setupChoicesTitle => 'Что из этого про вас?';

  @override
  String get setupChoiceNoHub => 'У меня ещё нет хаба';

  @override
  String get setupChoiceNoHubSub => 'Посмотреть небольшие хабы с Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'У меня Home Assistant';

  @override
  String get setupChoiceHaSub => 'Искать по адресу homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash подключается к MQTT-брокеру Home Assistant, дополнению Mosquitto broker в Настройки › Дополнения, и Zigbee2MQTT тоже должен его использовать. Если homeassistant.local не найден, введите ниже IP-адрес Home Assistant. Он указан в Настройки › Система › Сеть.';

  @override
  String get setupChoiceOther => 'Мой хаб в другой сети';

  @override
  String get setupChoiceOtherSub => 'Гостевой Wi-Fi или второй роутер';

  @override
  String get setupChoiceOtherNote =>
      'Телефон должен видеть ваш хаб. Гостевой Wi-Fi или второй роутер со своим Wi-Fi разделяют их. Подключитесь к Wi-Fi, в котором находится хаб, и нажмите Повторить. Или введите ниже IP-адрес хаба, или попробуйте одно из этих обычных имён:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Ваш телефон — $ip, значит адрес хаба обычно начинается с $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Используете Home Assistant? Хост — это адрес, по которому вы открываете Home Assistant, порт 1883.';

  @override
  String get demoBannerText => 'Вы в демо-режиме';

  @override
  String get demoBannerAction => 'Подключить свой дом';

  @override
  String get deviceOn => 'Вкл';

  @override
  String get deviceOff => 'Выкл';

  @override
  String get deviceOpen => 'Открыто';

  @override
  String get deviceClosed => 'Закрыто';

  @override
  String get deviceMotion => 'Движение';

  @override
  String get deviceClear => 'Нет';

  @override
  String get deviceLeakDetected => 'Протечка';

  @override
  String get deviceSmokeDetected => 'Обнаружен дым';

  @override
  String get deviceGasDetected => 'Обнаружен газ';

  @override
  String get deviceWaiting => 'Ожидание первых данных';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return 'Вкл: $on · выкл: $off';
  }

  @override
  String get deviceBrightness => 'Яркость';

  @override
  String get deviceWhite => 'Белый';

  @override
  String get deviceColor => 'Цвет';

  @override
  String get deviceHue => 'Оттенок';

  @override
  String get devicePosition => 'Положение';

  @override
  String get deviceControls => 'Управление';

  @override
  String deviceBattery(int percent) {
    return 'Батарея $percent%';
  }

  @override
  String get deviceToggle => 'Включить или выключить';

  @override
  String get deviceMore => 'Ещё';

  @override
  String get sectionLights => 'Освещение';

  @override
  String get sectionSwitchesCovers => 'Выключатели и шторы';

  @override
  String get sectionSensors => 'Датчики';

  @override
  String get sectionOther => 'Другое';

  @override
  String get homeFirstName => 'Мой дом';

  @override
  String homeNumberedName(int number) {
    return 'Дом $number';
  }

  @override
  String get dashAddTile => 'Добавить плитку';

  @override
  String get addTileSearch => 'Поиск устройств';

  @override
  String get addTileNotOnDashboard => 'Не на дашборде';

  @override
  String get addTileAllDevices => 'Все устройства';

  @override
  String get addTileReading => 'Показание';

  @override
  String get addTileReadingSubtitle => 'Одно значение с устройства или топика';

  @override
  String get readingShowAs => 'Показывать как';

  @override
  String get readingStyleValue => 'Значение';

  @override
  String get readingStyleGauge => 'Шкала';

  @override
  String get gaugeBands => 'Цветовые диапазоны';

  @override
  String get gaugeBandsHelper =>
      'До трёх. Диапазон, в который попадает значение, окрашивает дугу.';

  @override
  String get gaugeBandFrom => 'От';

  @override
  String get gaugeBandTo => 'До';

  @override
  String get gaugeBandAdd => 'Добавить диапазон';

  @override
  String get gaugeBandRemove => 'Удалить диапазон';

  @override
  String get gaugeToneNormal => 'Обычный';

  @override
  String get gaugeToneGood => 'Хорошо';

  @override
  String get gaugeToneAttention => 'Внимание';

  @override
  String get addTileCustom => 'Своя MQTT-плитка';

  @override
  String get addTileCustomSubtitle => 'Любой тип плитки, настройка по топику';

  @override
  String get addTileNoDevices =>
      'Нет устройств для показа. Подключитесь к брокеру или выполните сопряжение устройства в Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Добавить';

  @override
  String get addTileName => 'Название';

  @override
  String addTileNameHint(String model) {
    return 'например, $model';
  }

  @override
  String get addTileSection => 'Раздел';

  @override
  String get addTileNoSection => 'Без раздела';

  @override
  String get addTileSize => 'Размер';

  @override
  String get deviceClassColorLight => 'Цветной свет';

  @override
  String get deviceClassLight => 'Свет';

  @override
  String get deviceClassSwitch => 'Выключатель или розетка';

  @override
  String get deviceClassCover => 'Шторы';

  @override
  String get deviceClassLeak => 'Протечка или дым';

  @override
  String get deviceClassContact => 'Контакт';

  @override
  String get deviceClassMotion => 'Движение';

  @override
  String get deviceClassClimate => 'Датчик климата';

  @override
  String get deviceClassGeneric => 'Устройство';

  @override
  String get deviceNotResponding => 'Не отвечает';

  @override
  String get homeAdd => 'Добавить дом';

  @override
  String get homeManage => 'Управление домами';

  @override
  String get homeSwitch => 'Сменить дом';

  @override
  String get navDevices => 'Устройства';

  @override
  String get navScenes => 'Сцены';

  @override
  String get devicesNewDot => 'Новые устройства';

  @override
  String get editEditing => 'Редактирование';

  @override
  String get editDashboard => 'Дашборд';

  @override
  String get editDone => 'Готово';

  @override
  String get editAddSection => 'Добавить раздел';

  @override
  String get editSectionName => 'Название раздела';

  @override
  String get editRenameSection => 'Переименовать раздел';

  @override
  String get editDeleteSection => 'Удалить раздел';

  @override
  String get editDeleteSectionBody => 'Что сделать с его плитками?';

  @override
  String get editKeepTiles => 'Оставить плитки, удалить раздел';

  @override
  String get editDeleteTiles => 'Удалить и плитки';

  @override
  String get editMoveToSection => 'Переместить в раздел';

  @override
  String get editEditTile => 'Изменить плитку';

  @override
  String get editRemove => 'Убрать с дашборда';

  @override
  String get editRemoved => 'Плитка убрана';

  @override
  String get editUndo => 'Отменить';

  @override
  String get editReplaceWithDevice => 'Заменить плиткой устройства';

  @override
  String get editMoveEarlier => 'Переместить раньше';

  @override
  String get editMoveLater => 'Переместить позже';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count устройства не добавлено ни на один дашборд',
      many: '$count устройств не добавлено ни на один дашборд',
      few: '$count устройства не добавлены ни на один дашборд',
      one: '$count устройство не добавлено ни на один дашборд',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Действия с плиткой';

  @override
  String get editSave => 'Сохранить';

  @override
  String get editCancel => 'Отмена';

  @override
  String get ageJustNow => 'Только что';

  @override
  String ageMinutes(int n) {
    return '$n мин назад';
  }

  @override
  String ageHours(int n) {
    return '$n ч назад';
  }

  @override
  String get statusCantReach => 'Брокер недоступен';

  @override
  String get statusWhy => 'Почему?';

  @override
  String get statusWhyTitle => 'Брокер не отвечает';

  @override
  String get statusWhyBody =>
      'ZigDash продолжает попытки сам. Пока связь не восстановится, плитки показывают последние известные значения — приглушённо и с указанием давности. Проверьте, что брокер включён и телефон в той же сети, или проверьте подключение в его настройках.';

  @override
  String get statusSettings => 'Настройки подключения';

  @override
  String get deviceAddToDashboard => 'Добавить на дашборд';

  @override
  String get deviceDismiss => 'Скрыть';

  @override
  String get devicesFilterAll => 'Все';

  @override
  String devicesFilterAttention(int count) {
    return 'Требуют внимания · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Не на дашборде · $count';
  }

  @override
  String get devicesNoMatch => 'Нет подходящих устройств';

  @override
  String get deviceBatteryLow => 'Батарея разряжена';

  @override
  String get deviceLinkWeak => 'Слабая';

  @override
  String get deviceUnsupported => 'Не поддерживается Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'Сопряжение не завершено';

  @override
  String get deviceNoReport => 'Данных пока нет';

  @override
  String get devicesAvailabilityOff =>
      'Доступность в Zigbee2MQTT выключена, поэтому отключённые устройства отображаются как «Не отвечает».';

  @override
  String get devicesAvailabilityHow => 'Как её включить';

  @override
  String get devicesDotBattery => 'Батарея разряжена';

  @override
  String get deviceDetails => 'Об устройстве';

  @override
  String get deviceGone => 'Этого устройства больше нет в Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Управление';

  @override
  String get deviceReadingsTitle => 'Показания';

  @override
  String get deviceHealthTitle => 'Состояние';

  @override
  String get deviceOnDashboards => 'На дашбордах';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT пока не поддерживает это устройство, поэтому управлять нечем.';

  @override
  String get deviceAddReadingTile => 'Добавить как плитку показаний';

  @override
  String get deviceAddReadingTo => 'На какой дашборд добавить?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Добавлено на «$dashboard»';
  }

  @override
  String get deviceLinkQuality => 'Качество связи';

  @override
  String get deviceLinkGood => 'Хорошая';

  @override
  String get devicePowerSource => 'Питание';

  @override
  String get devicePowerBattery => 'Батарея';

  @override
  String get devicePowerMains => 'Сеть';

  @override
  String get deviceLastHeard => 'Последний сигнал';

  @override
  String get deviceAvailability => 'Доступность';

  @override
  String get deviceAvailabilityOff => 'Выключена в Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Политика конфиденциальности';

  @override
  String get settingsPrivacySubtitle =>
      'Без телеметрии. Всё остаётся на этом телефоне.';

  @override
  String get homeCurrent => 'Текущий дом';

  @override
  String get homeConnection => 'Подключение';

  @override
  String get homeSwitchTo => 'Перейти в этот дом';

  @override
  String get homeDelete => 'Удалить дом';

  @override
  String get devicesSelect => 'Выберите устройство';

  @override
  String get scenesSelect => 'Выберите сцену для изменения';

  @override
  String get panelFormTopic => 'Топик';

  @override
  String get panelFormPickDevice => 'Выбрать устройство';

  @override
  String get panelFormStateTopic => 'Топик состояния';

  @override
  String get panelFormCommandTopic => 'Топик команд';

  @override
  String get panelFormCommandTopicDerived =>
      'Заполняется из топика состояния, пока вы его не измените.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Связано с $device';
  }

  @override
  String get panelFormOpenDevice => 'Открыть устройство';

  @override
  String get panelFormUnlink => 'Отвязать';

  @override
  String get panelFormValueChoices => 'Значения этого устройства';

  @override
  String get panelFormAdvanced => 'Дополнительно';

  @override
  String get panelFormAdvancedSubtitle => 'Свой префикс, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Пусто = сам префикс (состояние устройства Zigbee2MQTT).';

  @override
  String get dashWallDisplay => 'Настенный экран';

  @override
  String get analyticsSetupCheckbox =>
      'Отправлять анонимные данные об использовании для улучшения настройки';

  @override
  String get analyticsWhatsShared => 'Что отправляется';

  @override
  String get analyticsCardTitle => 'Помочь улучшить ZigDash?';

  @override
  String get analyticsCardBody =>
      'Отправлять анонимные данные об использовании: какие шаги настройки не удаются и какие функции используются. Никогда — ваши устройства, топики или брокер.';

  @override
  String get analyticsShare => 'Отправлять';

  @override
  String get analyticsNoThanks => 'Нет, спасибо';

  @override
  String get settingsAnalytics => 'Анонимные данные об использовании';

  @override
  String get settingsAnalyticsSubtitle =>
      'Шаги настройки и используемые функции. Никогда — ваши устройства, топики или брокер.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Анонимные данные об использовании. Отключите переключателем выше.';

  @override
  String get dashDefaultName => 'Дом';

  @override
  String get dashExportSaveFile => 'Сохранить файл';

  @override
  String get dashExportSaved => 'Резервная копия сохранена';

  @override
  String get dashImportChooseFile => 'Выбрать файл';

  @override
  String get dashImportFileUnreadable => 'Не удалось прочитать файл';

  @override
  String get getHelpTitle => 'Получить помощь';

  @override
  String get getHelpTryFirst => 'Сначала попробуйте это';

  @override
  String get getHelpPromise =>
      'Всё ещё не получается? Обычно я отвечаю в течение 3 дней, на английском или иврите. Я никогда не попрошу ваши пароли.';

  @override
  String get getHelpIncluded => 'Что будет отправлено';

  @override
  String get getHelpContact => 'Написать в поддержку';

  @override
  String get getHelpCopy => 'Скопировать данные';

  @override
  String get getHelpCopied => 'Данные скопированы';

  @override
  String get getHelpLink => 'Всё ещё не получается? Получить помощь';

  @override
  String get getHelpEmailSubject => 'ZigDash: помогите настроить';

  @override
  String get getHelpEmailPrompt => 'Что вы пытались сделать и что произошло?';

  @override
  String get settingsHelpSupport => 'Помощь и поддержка';

  @override
  String get settingsGetHelp => 'Получить помощь';

  @override
  String get settingsGetHelpSubtitle =>
      'Не получается настроить? Сначала советы, потом связь';

  @override
  String get settingsCommunity => 'Присоединяйтесь к сообществу ZigDash';

  @override
  String get settingsCommunitySubtitle =>
      'Группа в Telegram: вопросы, идеи и что дальше';

  @override
  String get getHelpCommunity => 'Спросить в группе Telegram';

  @override
  String get demoBannerHelp => 'Получить помощь';

  @override
  String get tipSameWifiTitle => 'Тот же Wi-Fi, что у хаба';

  @override
  String get tipSameWifiBody =>
      'Телефон должен быть в той же сети, что и хаб, а не в гостевой. На время настройки отключите мобильный интернет.';

  @override
  String get tipBrokerRunningTitle => 'Брокер запущен';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: дополнение Mosquitto запущено. Raspberry Pi: Mosquitto работает. SMLIGHT: включён Settings › MQTT.';

  @override
  String get tipBrokerAcceptsTitle => 'Брокер принимает подключения с телефона';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: включите Allow External. Mosquitto 2 принимает подключения только с самого хаба, пока его не настроят слушать сеть (порт 1883).';

  @override
  String get tipMeshTitle => 'Mesh-сеть или два роутера?';

  @override
  String get tipMeshBody =>
      'Если хаб подключён ко второму роутеру, телефон может его не видеть. Подключите хаб к основному роутеру или подключитесь по его адресу.';

  @override
  String get tipByAddressTitle => 'Подключиться по адресу';

  @override
  String get tipByAddressBody =>
      'Найдите адрес хаба в приложении роутера, затем нажмите «Ввести вручную».';

  @override
  String get tipSameNetworkTitle => 'Одна и та же сеть';

  @override
  String get tipSameNetworkBody =>
      'Телефон и хаб должны быть в одной сети Wi-Fi. Отключите мобильный интернет.';

  @override
  String get tipAddressChangedTitle => 'Адрес изменился';

  @override
  String get tipAddressChangedBody =>
      'После перезапуска хаб может получить новый адрес. Проверьте его в приложении роутера и закрепите там, чтобы он не менялся.';

  @override
  String get tipRightPortTitle => 'Правильный порт';

  @override
  String get tipRightPortBody =>
      'MQTT обычно работает на порту 1883 (8883 с TLS). 8080 или 80 — это веб-интерфейс хаба, а не MQTT.';

  @override
  String get tipStartBrokerTitle => 'Брокер запущен';

  @override
  String get tipStartBrokerBody =>
      'Запустите Mosquitto или дополнение брокера и попробуйте снова.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 принимает подключения только с самого хаба, пока его не настроят слушать сеть (порт 1883).';

  @override
  String get tipMqttLoginTitle => 'Логин MQTT, а не от веб-интерфейса';

  @override
  String get tipMqttLoginBody =>
      'Пароль от веб-интерфейса хаба обычно не совпадает с паролем MQTT. Home Assistant: используйте пользователя Home Assistant или логин, заданный в дополнении Mosquitto.';

  @override
  String get tipSpacesTitle => 'Проверьте пробелы';

  @override
  String get tipSpacesBody =>
      'При копировании пароля в конце может появиться пробел.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT использует этот брокер';

  @override
  String get tipZ2mBrokerBody =>
      'Проверьте в настройках Zigbee2MQTT, что его MQTT-сервер — это тот же брокер.';

  @override
  String get tipBaseTopicTitle => 'Базовый топик';

  @override
  String get tipBaseTopicBody =>
      'Если вы изменили базовый топик с «zigbee2mqtt», укажите его при ручной настройке.';

  @override
  String get tipPairFirstTitle => 'Сначала выполните сопряжение';

  @override
  String get tipPairFirstBody =>
      'Откройте веб-интерфейс Zigbee2MQTT, выполните сопряжение хотя бы одного устройства и проверьте снова.';

  @override
  String get tipRestartZ2mTitle => 'Перезапустить Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'Если устройства сопряжены, но не появляются, перезапустите Zigbee2MQTT, чтобы он опубликовал список устройств.';

  @override
  String get tipNumberAddressTitle => 'Используйте цифровой адрес';

  @override
  String get tipNumberAddressBody =>
      'Имена, оканчивающиеся на .local, работают не на всех Android-телефонах. Попробуйте цифровой адрес хаба, например 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Порт и протокол';

  @override
  String get tipPortProtocolBody =>
      'Обычно это TCP на порту 1883. Выбирайте TLS или WebSocket, только если брокер для этого настроен.';

  @override
  String get tipManualLoginTitle => 'Вход';

  @override
  String get tipManualLoginBody =>
      'Оставьте имя пользователя и пароль пустыми, если у брокера их нет. Иначе используйте логин MQTT, а не логин от веб-интерфейса хаба.';

  @override
  String get tipHubOnTitle => 'Хаб включён?';

  @override
  String get tipHubOnBody =>
      'Он мог перезапуститься из-за отключения электричества или обновления. Подождите минуту после того, как он снова включится.';

  @override
  String get tipAwayTitle => 'Вы дома?';

  @override
  String get tipAwayBody =>
      'Вне дома приложению нужен удалённый адрес (например, Tailscale). Укажите его в настройках подключения дома.';

  @override
  String get tipTailscaleIpTitle => 'Используйте IP Tailscale, а не имя';

  @override
  String get tipTailscaleIpBody =>
      'Имена, оканчивающиеся на .ts.net, часто не разрешаются внутри приложений. Откройте приложение Tailscale на телефоне и убедитесь, что оно подключено, затем укажите адрес хаба 100.x.y.z как удалённый хост.';

  @override
  String get tipHomeAddressChangedTitle => 'Адрес изменился?';

  @override
  String get tipHomeAddressChangedBody =>
      'После перезапуска роутера хаб может получить новый адрес. Закрепите его адрес в приложении роутера, затем обновите дом.';

  @override
  String get tipRestartZ2mButtonTitle => 'Перезапустить Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'Если брокер перезапускался, список устройств Zigbee2MQTT пропадает до перезапуска Zigbee2MQTT. Нажмите кнопку «Перезапустить Zigbee2MQTT» на вкладке «Устройства».';

  @override
  String get tipZ2mRunningTitle => 'Zigbee2MQTT запущен?';

  @override
  String get tipZ2mRunningBody =>
      'Откройте его веб-интерфейс. Если он не загружается, перезапустите Zigbee2MQTT на хабе.';

  @override
  String get tipCantConnectTitle => 'Не могу подключиться к хабу';

  @override
  String get tipCantConnectBody =>
      'Один и тот же Wi-Fi, брокер запущен, включён Allow External или Mosquitto слушает сеть — затем подключитесь по адресу.';

  @override
  String get tipDeviceWrongTitle =>
      'Устройство показывает неверно или не отвечает';

  @override
  String get tipDeviceWrongBody =>
      'Сначала проверьте его в веб-интерфейсе Zigbee2MQTT. Если там оно работает, воспользуйтесь пунктом «Сообщить о проблеме».';

  @override
  String get tipHowDoITitle => 'Как мне…';

  @override
  String get tipHowDoIBody =>
      'Сцены, настенный экран, расписания и резервные копии описаны в разделе «Помощь и руководство».';

  @override
  String get tipRenameHomeTitle => 'Переименовать дом';

  @override
  String get tipRenameHomeBody =>
      'Дом назван по своему адресу? Настройки › Дома, нажмите на дом, затем на Имя.';

  @override
  String get tipWhatYouNeedTitle => 'Что понадобится';

  @override
  String get tipWhatYouNeedBody =>
      'Маленький хаб с Zigbee2MQTT и MQTT-брокером (Mosquitto): хаб SMLIGHT, Raspberry Pi или любой компьютер с Linux. Home Assistant тоже подойдёт, но он не обязателен.';

  @override
  String get tipSetupAtHomeTitle => 'В той же сети Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Настраивайте дома, когда телефон подключён к тому же Wi-Fi, что и хаб.';

  @override
  String get tipFindSetupTitle => 'Затем';

  @override
  String get tipFindSetupBody =>
      'Выйдите из демо-режима и нажмите «Найти мою систему». ZigDash сам найдёт ваш хаб.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Почтовое приложение не найдено. Скопируйте данные и напишите на $email.';
  }

  @override
  String get shortcutWorking => 'выполняется…';

  @override
  String get shortcutCantReach => 'Дом недоступен';

  @override
  String get shortcutNotConfirmed => 'Не подтверждено';

  @override
  String get shortcutRemoved => 'Удалено';

  @override
  String get shortcutSceneSent => 'Отправлено';

  @override
  String get shortcutSceneConfirmed => 'Подтверждено';

  @override
  String get shortcutChooseDevice => 'Выберите устройство';

  @override
  String get shortcutChooseScene => 'Выберите сцену';

  @override
  String get shortcutOpenAppFirstScene =>
      'Откройте ZigDash и сначала создайте сцену.';

  @override
  String get shortcutChooseGroup => 'Выберите группу';

  @override
  String get shortcutPickDevices => 'Выбрать устройства…';

  @override
  String get shortcutGroupName => 'Название группы';

  @override
  String get shortcutGroupLimit => 'До 5 устройств и 3 сцен';

  @override
  String get shortcutAddTile => 'Добавить в быстрые настройки';

  @override
  String get shortcutAddShortcut => 'Добавить ярлык';

  @override
  String get shortcutAddToHome => 'Добавить на главный экран';

  @override
  String get shortcutWidgetHowToTitle => 'Добавить виджет';

  @override
  String get shortcutWidgetHowTo =>
      'Нажмите и удерживайте пустое место на главном экране, выберите «Виджеты», найдите ZigDash и перетащите нужный виджет.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name на плитке ZigDash $slot в быстрых настройках';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name уже на плитке ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Добавить плитку';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Откройте быстрые настройки (проведите вниз дважды), нажмите на карандаш, чтобы изменить, и перетащите «ZigDash $slot» к своим плиткам.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Выберите устройство для ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Пока нет устройств для переключения. Сначала добавьте на дашборд лампу, розетку или штору.';

  @override
  String get shortcutSlotsFull =>
      'Все 4 плитки ZigDash заняты. Какая из них должна показывать это устройство?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Не используется';

  @override
  String get deviceRename => 'Переименовать';

  @override
  String get deviceRenameTitle => 'Переименовать устройство';

  @override
  String get deviceRenameHint =>
      'Название комнаты или устройства, например Спальня';

  @override
  String deviceRenamed(Object name) {
    return 'Новое название: $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Не удалось переименовать: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT не ответил';

  @override
  String get shortcutOpenAppFirst =>
      'Откройте ZigDash и сначала добавьте устройство на дашборд.';

  @override
  String get pollTitle => 'Что ZigDash стоит сделать дальше?';

  @override
  String get pollBody =>
      'Выберите то, чем пользовались бы чаще всего. Ответ отправится вместе с анонимными данными об использовании.';

  @override
  String get pollNotifications => 'Уведомления';

  @override
  String get pollHistory => 'Графики истории';

  @override
  String get pollKiosk => 'Режим киоска для настенного планшета';

  @override
  String get pollGroups => 'Группы Zigbee';

  @override
  String get pollNotNow => 'Не сейчас';

  @override
  String get pollThanks => 'Спасибо! Это помогает решить, что делать дальше.';

  @override
  String get whyTitle => 'Почему вы попробовали ZigDash?';

  @override
  String get whyBody =>
      'Одно касание поможет решить, что делать дальше. Ответ отправится вместе с анонимными данными об использовании.';

  @override
  String get whyFaster => 'Быстрее моего другого приложения';

  @override
  String get whyFamily => 'Просто для всей семьи';

  @override
  String get whyWallTablet => 'Планшет на стене';

  @override
  String get whyWithoutHa => 'Работает без Home Assistant';

  @override
  String get whyOther => 'Другое';

  @override
  String get whyThanks => 'Спасибо, что рассказали!';

  @override
  String get pollNoAnalytics =>
      'Данные об использовании выключены, поэтому отсюда ничего не отправляется. Расскажите нам через «Предложить функцию».';

  @override
  String alertLeak(Object name) {
    return '💧 Протечка — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name снова сухой';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Дым — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Дыма у $name больше нет';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name открыто';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Низкий заряд — $name, $value%';
  }

  @override
  String get alertTest => 'Тестовое уведомление ZigDash';

  @override
  String get alertsChannel => 'Тревоги';

  @override
  String get alertsChannelDescription => 'Протечки и дым';

  @override
  String get noticesChannel => 'Уведомления';

  @override
  String get noticesChannelDescription => 'Двери, окна и батареи';

  @override
  String get alertsTitle => 'Тревоги';

  @override
  String get alertsStatusOn => 'Тревоги включены';

  @override
  String get alertsStatusPaused =>
      'Оповещения приостановлены: ZigDash Engine на хабе не выходит на связь';

  @override
  String get alertsStatusNotSetUp => 'Не настроено';

  @override
  String get alertsStatusPhoneOff => 'Этот телефон не получает уведомления';

  @override
  String get alertsIntro =>
      'Получайте уведомление на этот телефон о протечке, дыме, открытой двери или разряде батареи, даже когда ZigDash закрыт. ZigDash Engine на хабе следит за устройствами; ZigDash его настраивает.';

  @override
  String get alertsSetUpHub => 'Настроить тревоги на хабе';

  @override
  String get alertsHubInstalled => 'Оповещения настроены на хабе';

  @override
  String get alertsHubUpdated => 'Поток тревог на хабе обновлён';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED требует входа, поэтому импортируйте поток вручную:';

  @override
  String get alertsHubManualSteps =>
      'Откройте Node-RED на хабе, выберите Import, вставьте скопированный поток, выберите свой брокер в узле брокера и нажмите Deploy.';

  @override
  String get alertsCopyFlow => 'Скопировать поток';

  @override
  String get alertsFlowCopied => 'Поток скопирован';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Для тревог нужен Node-RED на хабе, но на порту 1880 по адресу $host никто не отвечает. На SMLIGHT SMHUB установите его в разделе Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT не принял ZigDash Engine';

  @override
  String get alertsRecent => 'Последние тревоги';

  @override
  String get alertsRecentNone => 'Пока ничего';

  @override
  String get alertsYourAlerts => 'Ваши тревоги';

  @override
  String get alertsAdd => 'Добавить тревогу';

  @override
  String get alertsNotificationsOnThisPhone => 'Уведомления на этом телефоне';

  @override
  String get alertsNoGoogle =>
      'На этом телефоне нет сервисов Google, поэтому ZigDash не может получать push здесь.';

  @override
  String get alertsSendTest => 'Отправить тестовое уведомление';

  @override
  String get alertsTestSent => 'Тест отправлен. Он должен прийти сейчас.';

  @override
  String alertsTestFailed(Object status) {
    return 'Хаб не смог отправить ($status)';
  }

  @override
  String get alertsTestTimedOut =>
      'Нет ответа от хаба. Запущен ли поток тревог?';

  @override
  String get alertsNotConnected => 'Нет связи с хабом';

  @override
  String get alertsTurnOff => 'Выключить тревоги';

  @override
  String get alertsTurnOffBody =>
      'Тревоги прекратятся на всех телефонах этого дома.';

  @override
  String get alertKindLeak => 'Протечка';

  @override
  String get alertKindSmoke => 'Дым';

  @override
  String get alertKindOpened => 'Открыта дверь или окно';

  @override
  String get alertKindBattery => 'Низкий заряд';

  @override
  String get alertsEditTitle => 'Тревога';

  @override
  String get alertsKind => 'Что';

  @override
  String get alertsDevices => 'Устройства';

  @override
  String get alertsNoDevicesForKind =>
      'Ни одно устройство этого дома такого не сообщает.';

  @override
  String get alertsHours => 'Только между';

  @override
  String get alertsHoursAny => 'В любое время';

  @override
  String get alertsHoursFrom => 'С';

  @override
  String get alertsHoursTo => 'До';

  @override
  String get alertsThreshold => 'Заряд ниже';

  @override
  String get alertsDelete => 'Удалить тревогу';

  @override
  String get alertsNotifyMe => 'Сообщать мне…';

  @override
  String get alertsWhatLeaves =>
      'Тревоги в ZigDash зашифрованы сквозным шифрованием: push-сервис Google их доставляет, но не может прочитать. Больше ничего не покидает ваш хаб.';

  @override
  String get alertsRestricted =>
      'Android может останавливать ZigDash в фоне, и уведомления придут поздно или не придут. Разрешите работу в фоне в настройках Android (на Samsung: Батарея › Никогда не переводить в спящий режим).';

  @override
  String get alertsOpenSettings => 'Открыть настройки Android';

  @override
  String get alertsOff => 'Выкл.';

  @override
  String get alertsSuggested => 'Предлагаемые тревоги';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count устройств',
      few: '$count устройства',
      one: '1 устройство',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Включить';

  @override
  String get alertsShare => 'Поделиться тревогами';

  @override
  String get alertsShareBody =>
      'Любой, у кого есть эта ссылка, получает тревоги этого дома в приложении ntfy, без ZigDash. Текст тревоги проходит через ntfy.sh без шифрования.';

  @override
  String get alertsShareLink => 'Ссылка';

  @override
  String get alertsShareNewLink => 'Новая ссылка';

  @override
  String get alertsShareCopied => 'Ссылка скопирована';

  @override
  String get alertsShareOff => 'Прекратить делиться';

  @override
  String get alertsGetWithNtfy => 'Получать уведомления через ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Тревоги о дыме и протечке повторяются до подтверждения. Нужен аккаунт Pushover (4,99 \$ однократно после пробного периода); ключи хранятся на вашем брокере.';

  @override
  String get alertsPushoverUser => 'Ключ пользователя';

  @override
  String get alertsPushoverToken => 'Токен приложения';

  @override
  String get alertsHideNames => 'Скрывать названия устройств';

  @override
  String get alertsNtfyServer => 'Сервер ntfy';

  @override
  String get wallSheetTitle => 'Настенный экран';

  @override
  String get wallSheetSubtitle => 'Для планшета на стене.';

  @override
  String get wallKeepOn => 'Не гасить экран и скрывать панели';

  @override
  String get wallKeepOnSubtitle =>
      'Они возвращаются при касании и снова скрываются через 10 секунд.';

  @override
  String get wallFullscreen => 'Во весь экран';

  @override
  String get wallFullscreenSubtitle =>
      'Скрывает и строку состояния, и панель навигации Android.';

  @override
  String get wallDimAfter => 'Затемнять через';

  @override
  String get wallDimOff => 'Выкл.';

  @override
  String get wallIdleTitle => 'Когда никто не касается';

  @override
  String get wallIdleAfter => 'Через';

  @override
  String get wallIdleNever => 'Никогда';

  @override
  String get wallIdleShow => 'Показывать';

  @override
  String get wallIdleShowDim => 'Затемнение';

  @override
  String get wallIdleShowClock => 'Часы';

  @override
  String get wallIdleShowBlack => 'Чёрный';

  @override
  String get wallIdleShowReadings => 'Показания';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'На этой панели ещё нет показаний. Сначала добавьте плитку показания или датчика.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Показания на часах (до $count)';
  }

  @override
  String get wallProNote =>
      'Показания на часах, пробуждение по движению, ночной режим и тревоги входят в ZigDash Pro — разовую покупку.';

  @override
  String get wallAlarmLeak => 'Протечка';

  @override
  String get wallAlarmSmoke => 'Дым';

  @override
  String get wallAlarmGas => 'Газ';

  @override
  String get wallAlarmCo => 'Угарный газ';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Пробуждение по движению';

  @override
  String get wallMotionSubtitle =>
      'Датчик, который замечает человека, будит экран.';

  @override
  String get wallMotionNone =>
      'В этом доме нет датчиков движения, присутствия или дверей.';

  @override
  String get wallAlarmsTitle => 'Тревоги на весь экран';

  @override
  String get wallAlarmsSubtitle =>
      'Протечка, дым, газ или угарный газ заполняют экран, пока кто-нибудь не нажмёт OK. Только пока ZigDash открыт на этом планшете; уведомления приходят на телефоны где угодно.';

  @override
  String get wallAlarmSound => 'Звуковой сигнал';

  @override
  String get wallNightTitle => 'Ночь';

  @override
  String get wallNightSubtitle =>
      'Чёрный экран в эти часы. Движение будит его только приглушённо; тревоги — всегда полностью.';

  @override
  String get wallNightFrom => 'С';

  @override
  String get wallNightTo => 'до';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes мин';
  }

  @override
  String get kioskLock => 'Режим киоска';

  @override
  String get kioskLockSubtitle =>
      'Доступны только панели этого дома и их элементы управления. Удерживайте заголовок, чтобы выйти.';

  @override
  String get kioskPin => 'PIN-код';

  @override
  String get kioskPinSet => 'Задать';

  @override
  String get kioskPinNotSet => 'Не задан';

  @override
  String get kioskPinChange => 'Изменить';

  @override
  String get kioskPinRemove => 'Удалить';

  @override
  String get kioskPinSetTitle => 'Задать PIN-код';

  @override
  String get kioskPinEnterTitle => 'Введите PIN-код';

  @override
  String get kioskPinHint => '4 цифры';

  @override
  String get kioskPinConfirmHint => 'Ещё раз';

  @override
  String get kioskPinMismatch => 'PIN-коды не совпадают.';

  @override
  String get kioskPinWrong => 'Неверный PIN-код.';

  @override
  String get kioskPinForgot => 'Забыли PIN-код?';

  @override
  String get kioskPinForgotBody =>
      'Забытый PIN-код можно сбросить только очисткой данных ZigDash в настройках Android, а это удалит этот дом, если нет резервной копии. Экспортируйте её, прежде чем задавать PIN-код.';

  @override
  String get kioskExportBackup => 'Экспорт резервной копии';

  @override
  String get kioskOsPin => 'Также закрепить ZigDash в Android';

  @override
  String get kioskOsPinSubtitle =>
      'Android блокирует кнопку «Домой» и недавние приложения, пока ZigDash не откреплён. Планшет без экрана блокировки открепляется жестом, так что это не замок.';

  @override
  String get kioskOn => 'Киоск включён. Удерживайте заголовок, чтобы выйти.';

  @override
  String get kioskLeaveTitle => 'Выйти из киоска?';

  @override
  String get kioskLeave => 'Выйти';

  @override
  String get kioskStay => 'Остаться';

  @override
  String get a11yKioskLeave => 'Удерживайте, чтобы выйти из киоска';

  @override
  String get historyTitle => 'История';

  @override
  String get historyRangeDay => '24 часа';

  @override
  String get historyRangeWeek => '7 дней';

  @override
  String get historyRangeMonth => '30 дней';

  @override
  String get historySetupTitle => 'Записывать историю на хабе';

  @override
  String get historySetupBody =>
      'У ZigDash нет сервера, поэтому ZigDash Engine на хабе каждые 15 минут записывает показания с ваших панелей. Хранит 30 дней, на вашем брокере.';

  @override
  String get historySetupAction => 'Настроить на хабе';

  @override
  String get historyInstalled =>
      'Запись идёт. Первые значения появятся в течение 15 минут.';

  @override
  String historyNoNodeRed(String host) {
    return 'Для истории нужен Node-RED на хабе, а на порту 1880 по адресу $host никто не отвечает. На SMLIGHT SMHUB установите его в разделе Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Запись с $date';
  }

  @override
  String get historyEmpty =>
      'Значений пока нет. Запись сохраняется каждые 15 минут.';

  @override
  String get historyRecorderOffline =>
      'Запись на хабе не отвечает, поэтому последних значений может не быть.';

  @override
  String get historyLocked =>
      'Более длинная история входит в ZigDash Pro — разовую покупку.';

  @override
  String get historyUnlock => 'Открыть';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Автоматизации без ограничений, более длинная история и дополнения для настенного планшета. Поддерживает проект с открытым кодом.';

  @override
  String get proUnlocked => 'Открыто. Спасибо, что поддерживаете ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash бесплатный и с открытым исходным кодом, его делает один человек в свободное время. Pro — разовая покупка, которая помогает проекту жить.';

  @override
  String get proWhatYouGet => 'Что вы получаете';

  @override
  String get proGetHistory => 'Историю за 7 и 30 дней, а не только за сегодня';

  @override
  String get proGetWall =>
      'Настенный планшет: показания на часах, пробуждение по движению, ночной режим и будильники';

  @override
  String get proGetFuture => 'Все будущие функции Pro без доплаты';

  @override
  String get proFreeTitle => 'Бесплатно навсегда';

  @override
  String get proFreeBody =>
      'Настройка, панели, управление любым устройством, виджеты, плитки быстрых настроек, оповещения, три автоматизации на дом и сам настенный планшет остаются бесплатными. Ничто из того, чем вы пользуетесь сегодня, не будет заблокировано.';

  @override
  String get proBuy => 'Получить Pro';

  @override
  String proBuyPrice(String price) {
    return 'Получить Pro · $price';
  }

  @override
  String get proOnce =>
      'Один платёж, без подписки. Купили на другом телефоне с тем же аккаунтом Google? Pro откроется автоматически.';

  @override
  String get historyNotRecorded =>
      'Записываются только числа, показанные на панели. Добавьте это значение плиткой, чтобы начать его историю.';

  @override
  String get historyRecordHere => 'Записывать на этом устройстве';

  @override
  String get historyRecordHereHint =>
      'Не получается использовать ZigDash Engine на хабе? ZigDash может записывать на телефоне или планшете, который остаётся открытым, например на настенном. Все телефоны этого дома видят историю.';

  @override
  String get historyRecordingHere =>
      'Это устройство записывает историю, пока ZigDash открыт. Первые значения появятся в течение 15 минут.';

  @override
  String get wallRecordHistory => 'Записывать историю на этом устройстве';

  @override
  String get wallRecordHistorySubtitle =>
      'Каждые 15 минут, пока ZigDash открыт, для всех телефонов этого дома. Не нужно, если записывает ZigDash Engine на хабе.';

  @override
  String historyNeedsPassword(String host) {
    return 'Ещё один шаг: брокер требует вход. Откройте Node-RED по адресу $host:1880, дважды нажмите «ZigDash history broker», введите пароль MQTT на вкладке Security и нажмите Deploy. ZigDash никогда не отправляет пароль на хаб.';
  }

  @override
  String get historyNotConnected =>
      'Запись не выходит на связь. Откройте «Автоматизации», чтобы проверить ZigDash Engine на хабе.';

  @override
  String get historyPersistence =>
      'История хранится на брокере. Если вы сами запускаете Mosquitto, убедитесь, что в его конфигурации есть \"persistence true\", иначе история пропадёт при перезапуске брокера.';

  @override
  String get haImportTitle => 'Импорт из Home Assistant';

  @override
  String get haImportSettingsSubtitle => 'Имена и комнаты из Home Assistant';

  @override
  String get haImportIntro =>
      'Перенесите имена и комнаты, настроенные в Home Assistant. ZigDash читает их один раз и больше ничего из Home Assistant не хранит.';

  @override
  String get haImportAddress => 'Адрес Home Assistant';

  @override
  String get haImportAddressHelp =>
      'Адрес, по которому вы открываете Home Assistant, например 192.168.1.20:8123';

  @override
  String get haImportToken => 'Долгосрочный токен доступа';

  @override
  String get haImportTokenHelp =>
      'В Home Assistant откройте профиль, затем Безопасность › Долгосрочные токены доступа › Создать токен. Скопируйте его и вставьте сюда. ZigDash использует его один раз и не хранит; потом его можно удалить в Home Assistant.';

  @override
  String get haImportRead => 'Прочитать из Home Assistant';

  @override
  String get haImportReading => 'Читаем Home Assistant…';

  @override
  String get haImportApplying => 'Импортируем…';

  @override
  String get haImportNoAddress =>
      'Введите адрес, по которому вы открываете Home Assistant.';

  @override
  String get haImportNoToken => 'Вставьте долгосрочный токен доступа.';

  @override
  String get haImportUnreachable =>
      'По этому адресу никто не ответил. Проверьте его и то, что телефон в домашней сети.';

  @override
  String get haImportNotHa =>
      'По этому адресу что-то ответило, но это не Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant отклонил этот токен. Создайте новый и вставьте снова.';

  @override
  String get haImportCertificate =>
      'Телефон не доверяет сертификату этого Home Assistant. Попробуйте его адрес http:// в домашней сети.';

  @override
  String get haImportFailed =>
      'Home Assistant ответил, но прочитать не удалось. Попробуйте снова.';

  @override
  String get haImportNoDevices =>
      'ZigDash сейчас не видит устройства этого дома. Подключитесь к дому и попробуйте снова.';

  @override
  String get haImportAutomations =>
      'Ваши автоматизации остаются в Home Assistant и продолжают работать.';

  @override
  String haImportFound(int count) {
    return 'Устройств найдено в Home Assistant: $count';
  }

  @override
  String get haImportRenameNote =>
      'Плитки, которые всё ещё называются как устройство, получат имя из Home Assistant. Ваши собственные дашборды останутся как есть.';

  @override
  String get haImportMakeDashboards =>
      'Также добавить дашборды по этажам и комнатам';

  @override
  String get haImportOtherRooms => 'Другие комнаты';

  @override
  String get haImportNoRoom => 'Без комнаты';

  @override
  String get haImportApply => 'Импортировать';

  @override
  String get haImportBack => 'Назад';

  @override
  String get haImportZhaOnly =>
      'Эти устройства работают через ZHA, встроенный Zigbee Home Assistant, а не через Zigbee2MQTT, поэтому ZigDash не может их показать.';

  @override
  String get haImportNothing =>
      'Ни одного устройства Zigbee2MQTT этого дома нет в Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Готово. Переименовано плиток: $renamed. Добавлено дашбордов: $dashboards.';
  }

  @override
  String get haImportOpen => 'Открыть дашборды';

  @override
  String get haImportOfferTitle =>
      'Перенести имена и комнаты из Home Assistant?';

  @override
  String get haImportOfferBody =>
      'Home Assistant есть в вашей сети. ZigDash может назвать плитки и добавить дашборд на каждый этаж и комнату, как вы настроили их там.';

  @override
  String get haImportOfferLater => 'Не сейчас';

  @override
  String get haImportOfferGo => 'Импортировать';

  @override
  String get haImportSignIn => 'Войти через Home Assistant';

  @override
  String get haImportSignInHelp =>
      'Вход Home Assistant откроется в браузере. ZigDash не видит ваш пароль и выходит из системы после чтения.';

  @override
  String get haImportOrToken => 'Или использовать долгосрочный токен доступа';

  @override
  String get haImportReadToken => 'Прочитать с токеном';

  @override
  String get haImportSignInRefused =>
      'Home Assistant не принял вход. Так бывает, когда у Home Assistant нет доступа в интернет. Используйте ниже долгосрочный токен доступа.';

  @override
  String get setupIsolatedHint =>
      'Телефон почти ничего больше не видит в этой сети Wi-Fi. Возможно, он в гостевой сети или роутер изолирует устройства друг от друга (часто это называется изоляцией клиентов или AP). Подключитесь к основной сети Wi-Fi или отключите это и попробуйте снова.';

  @override
  String get setupAuthTrust =>
      'Ваш логин остаётся на этом телефоне и передаётся только вашему брокеру. У ZigDash нет сервера и аккаунта, и любое MQTT-приложение входит так же. Безопаснее всего: отдельный пользователь MQTT только для ZigDash, которого можно удалить в любой момент.';

  @override
  String get setupAuthWhatKept => 'Что хранит ZigDash';

  @override
  String get setupAuthDemoFirst => 'Сначала попробовать демо';

  @override
  String get automationsTitle => 'Автоматизации';

  @override
  String get engineRunningOnHub => 'Работает на хабе';

  @override
  String get engineChecking => 'Проверка хаба…';

  @override
  String get engineAwayNoHubTitle => 'Сейчас не удаётся связаться с хабом';

  @override
  String get engineAwayNoHubBody =>
      'Вы не дома, и хаб не подключён к удалённому доступу ZigDash или у него нет интернета. Автоматизации продолжают работать на хабе.';

  @override
  String get engineAwayReinstallAtHome =>
      'Переустановить Engine можно, когда будете дома.';

  @override
  String get engineNoConnection =>
      'ZigDash сейчас не может связаться с брокером этого дома. Автоматизации настраиваются дома, при подключении.';

  @override
  String get engineRestarting =>
      'Перезапуск Zigbee2MQTT… Устройства вернутся примерно через 30 секунд.';

  @override
  String get engineInstalling => 'Установка на хаб…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT нужно обновить';

  @override
  String engineTooOldBody(Object version) {
    return 'Ваш Zigbee2MQTT версии $version. Для автоматизаций нужна 2.4 или новее. Обновите Zigbee2MQTT на хабе и вернитесь сюда.';
  }

  @override
  String get engineIntroTitle =>
      'Автоматизации работают на хабе, а не на телефоне';

  @override
  String get engineIntroBody =>
      'ZigDash добавляет ZigDash Engine в Zigbee2MQTT на вашем хабе. Он следит за устройствами и выполняет ваши правила, так что свет включится при открытии двери, даже если телефон выключен и нет интернета.';

  @override
  String get engineIntroNothingByHand =>
      'Ничего не нужно ставить вручную. ZigDash сделает это через домашнюю сеть.';

  @override
  String engineIntroVersion(Object version) {
    return 'Ваш Zigbee2MQTT версии $version.';
  }

  @override
  String get engineIntroRemove =>
      'Удалить его можно в любой момент на этом экране.';

  @override
  String get engineInstall => 'Установить на хаб';

  @override
  String get engineDeclinedTitle => 'На этом хабе нет автоматизаций';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT на вашем хабе не разрешает расширения, поэтому никто не выполнит ваши правила, пока телефона нет рядом. Сцены, оповещения и панель работают как раньше.';

  @override
  String get engineAllowAfterAll => 'Всё же разрешить расширения';

  @override
  String get engineConsentTitle =>
      'В Zigbee2MQTT нужно изменить одну настройку';

  @override
  String get engineConsentBody =>
      'Ваш Zigbee2MQTT блокирует расширения вроде ZigDash Engine, как делают новые установки. Чтобы автоматизации работали на хабе, ZigDash включит в Zigbee2MQTT «Разрешить внешний JavaScript» и перезапустит его.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT перезапустится один раз. Свет и датчики будут недоступны около 30 секунд.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine с открытым кодом. Его можно прочитать на странице Zigbee2MQTT в разделе «Расширения».';

  @override
  String get engineConsentUndo =>
      'Настройку можно потом выключить. Тогда автоматизации остановятся.';

  @override
  String get engineConsentYes => 'Изменить настройку и перезапустить';

  @override
  String get engineConsentNo => 'Не сейчас';

  @override
  String get automationsPausedTitle => 'Автоматизации приостановлены';

  @override
  String get automationsPausedBody =>
      'Хаб не выходит на связь больше минуты, поэтому ни одна автоматизация не сработает, пока он не вернётся. Ваши правила сохранены.';

  @override
  String get engineReinstall => 'Переустановить на хаб';

  @override
  String get engineStoppedTitle =>
      'Автоматизации приостановлены: ZigDash Engine остановился сам';

  @override
  String get engineStoppedBody =>
      'Он трижды за час столкнулся с ошибками и выключился, чтобы Zigbee2MQTT продолжал работать. Ваши правила сохранены.';

  @override
  String get engineStartAgain => 'Запустить снова';

  @override
  String get engineReportProblem => 'Сообщить о проблеме';

  @override
  String get engineRunningTitle => 'Хаб готов к автоматизациям';

  @override
  String engineRunningBody(Object count) {
    return 'Правил загружено на хаб: $count. Создание автоматизаций появится на следующем шаге этой версии.';
  }

  @override
  String get engineClockOff =>
      'Часы хаба отстают или спешат больше чем на пять минут. Автоматизации по времени будут срабатывать не вовремя, пока это не исправить.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Правил, которые ZigDash Engine на хабе пока не умеет выполнять: $count. Переустановите его, чтобы обновить.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT отклонил ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT не ответил. Проверьте, что дом подключён, и попробуйте снова.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT не принял изменение или не вернулся. Проверьте хаб и попробуйте снова.';

  @override
  String get autoValMotion => 'движение';

  @override
  String get autoValNoMotion => 'нет движения';

  @override
  String get autoValClosed => 'закрыто';

  @override
  String get autoValOpened => 'открыто';

  @override
  String get autoValLeak => 'протечка';

  @override
  String get autoValDry => 'сухо';

  @override
  String get autoValSmoke => 'дым';

  @override
  String get autoValNoSmoke => 'нет дыма';

  @override
  String get autoValOn => 'вкл.';

  @override
  String get autoValOff => 'выкл.';

  @override
  String get autoValToggle => 'переключить';

  @override
  String get autoValOpen => 'открыть';

  @override
  String get autoValClose => 'закрыть';

  @override
  String get autoValStop => 'стоп';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Когда $device: $property выше $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Когда $device: $property ниже $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Когда $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'В $time';
  }

  @override
  String get autoSunrise => 'восход';

  @override
  String get autoSunset => 'закат';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes мин после: $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes мин до: $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return '$sun';
  }

  @override
  String get autoEveryDay => 'каждый день';

  @override
  String get autoWeekdays => 'по будням';

  @override
  String get autoWeekends => 'по выходным';

  @override
  String autoBetween(Object from, Object to) {
    return 'с $from до $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device: $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Запустить «$scene»';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, выключить через $minutes мин';
  }

  @override
  String get autoErrPickTrigger => 'Выберите устройство и событие.';

  @override
  String get autoErrValue => 'Введите число для показания.';

  @override
  String get autoErrDays => 'Выберите хотя бы один день.';

  @override
  String get autoErrTown => 'Укажите город для восхода и заката.';

  @override
  String get autoErrPickAction => 'Выберите, что должно произойти.';

  @override
  String get autoErrEmptyScene => 'В этой сцене нечего отправлять.';

  @override
  String get autoErrNotConnected =>
      'ZigDash не подключён к этому дому. Попробуйте снова дома.';

  @override
  String get autoNewTitle => 'Новая автоматизация';

  @override
  String get autoEditTitle => 'Изменить автоматизацию';

  @override
  String get autoName => 'Название';

  @override
  String get autoNameHint => 'Что она делает (необязательно)';

  @override
  String get autoWhen => 'Когда';

  @override
  String get autoOnlyIf => 'Только если';

  @override
  String get autoThen => 'Тогда';

  @override
  String get autoEnabled => 'Включена';

  @override
  String get autoDelete => 'Удалить автоматизацию';

  @override
  String get autoSave => 'Сохранить';

  @override
  String get autoDeviceChanges => 'Устройство меняется';

  @override
  String get autoTimeComes => 'Наступает время';

  @override
  String get autoDevice => 'Устройство';

  @override
  String get autoAbove => 'выше';

  @override
  String get autoBelow => 'ниже';

  @override
  String get autoClockTime => 'Время';

  @override
  String get autoAt => 'В';

  @override
  String get autoShift => 'Сдвиг в минутах (минус — раньше)';

  @override
  String get autoTownNone => 'Город не указан';

  @override
  String autoTownIs(Object town) {
    return 'Время солнца для: $town';
  }

  @override
  String get autoTownSet => 'Указать город';

  @override
  String get autoTownChange => 'Сменить город';

  @override
  String get autoDays => 'Дни';

  @override
  String get autoNoConditions => 'Без условий. Срабатывает каждый раз.';

  @override
  String get autoAddHours => 'Между часами';

  @override
  String get autoFrom => 'С';

  @override
  String get autoTo => 'До';

  @override
  String get autoAddDeviceCondition => 'Устройство в состоянии…';

  @override
  String get autoRunASceneOption => 'Запустить сцену';

  @override
  String get autoSetADevice => 'Управлять устройством';

  @override
  String get autoScene => 'Сцена';

  @override
  String get autoTurnOffAgain => 'Выключить потом';

  @override
  String get autoStaysAsSet => 'Остаётся как есть';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return 'Через $minutes мин после запуска';
  }

  @override
  String get autoTownSearch => 'Город';

  @override
  String get autoTownWhy =>
      'Только для восхода и заката. Хранится на хабе, а не ваше местоположение.';

  @override
  String get autoNewButton => 'Новая автоматизация';

  @override
  String get autoEmptyBody =>
      'Пока ничего не работает. Нажмите «Новая автоматизация», чтобы создать первую.';

  @override
  String autoOnlyIfList(Object list) {
    return 'только если $list';
  }

  @override
  String get autoEdit => 'Изменить';

  @override
  String get autoNeverRan => 'ещё не срабатывала';

  @override
  String autoRanAt(Object time) {
    return 'сработала в $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return 'Бесплатных автоматизаций: $count из $max';
  }

  @override
  String get autoRecentRuns => 'Последние срабатывания';

  @override
  String get autoDeleted => '(удалена)';

  @override
  String autoCeilingTitle(Object count) {
    return 'Бесплатно: $count автоматизации. Нужно больше?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash бесплатный и с открытым кодом, его делает один человек. Pro — разовая покупка: автоматизации без ограничений, история за 7 и 30 дней и функции для настенного планшета. Ваши автоматизации продолжат работать при любом выборе.';

  @override
  String get autoCeilingSeePro => 'Подробнее о Pro';

  @override
  String get engineRemove => 'Удалить с хаба';

  @override
  String get engineRemoveTitle => 'Удалить ZigDash Engine с хаба?';

  @override
  String get engineRemoveBody =>
      'Автоматизации перестанут работать. Правила останутся на хабе и вернутся после переустановки ZigDash Engine.';

  @override
  String get autoNoTargets =>
      'В этом доме пока нет света, розетки, выключателя или штор для управления.';

  @override
  String get proGetAutomations =>
      'Автоматизации без ограничений; три на дом бесплатно';

  @override
  String get proGetRemote =>
      'Управление откуда угодно через ретранслятор ZigDash, без ежемесячной оплаты';

  @override
  String get proRemoteFair =>
      'Удалённый доступ включён, пока работает ретранслятор ZigDash, для одного дома, до пяти телефонов и обычного домашнего использования. Он может измениться или прекратиться с предварительным уведомлением.';

  @override
  String get autoDeleteConfirm =>
      'Удалить эту автоматизацию? Она перестанет работать на хабе.';

  @override
  String get statusConnectedRelay => 'Подключено · Вне дома через ZigDash';

  @override
  String get shareHomeTitle => 'Поделиться с другим телефоном';

  @override
  String get shareHomeSubtitle =>
      'Добавьте этот дом на другой телефон одним QR-кодом';

  @override
  String get shareHomeIntro =>
      'На другом телефоне, дома в той же Wi-Fi, отсканируйте код камерой. ZigDash добавит этот дом с логином и вашими панелями.';

  @override
  String get shareHomeLoginWarning =>
      'Код содержит логин брокера этого дома. Он виден 2 минуты; показывайте его только тем, кому доверяете.';

  @override
  String get shareHomeShow => 'Показать код';

  @override
  String get shareHomeAtHome =>
      'Сначала подключитесь дома: делиться можно только в домашней сети.';

  @override
  String get shareHomeScanHint =>
      'Отсканируйте камерой другого телефона. Код скроется через 2 минуты.';

  @override
  String get shareHomeHide => 'Скрыть код';

  @override
  String get shareHomeViaHa =>
      'Этот дом подключается через Home Assistant. На другом телефоне установите ZigDash и войдите через Home Assistant.';

  @override
  String get joinHomeTitle => 'Добавить общий дом';

  @override
  String get joinHomeInvalid =>
      'Этот код не приглашение ZigDash или повреждён.';

  @override
  String joinHomeAlready(String name) {
    return '$name уже есть на этом телефоне.';
  }

  @override
  String get joinHomeOpen => 'Открыть';

  @override
  String joinHomeAsk(String name) {
    return 'Добавить $name на этот телефон?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash добавит дом с тем же подключением и логином и возьмёт панели с другого телефона. Оставайтесь в домашней Wi-Fi.';

  @override
  String get joinHomeAdd => 'Добавить дом';

  @override
  String get joinHomeNoDashboards =>
      'Дом добавлен. Панели не пришли; устройства — на вкладке «Устройства».';

  @override
  String get remoteTitle => 'Удалённое управление';

  @override
  String get remoteSettingsSubtitle =>
      'Управляйте этим домом откуда угодно, с Pro';

  @override
  String get remoteIntroTitle => 'Управляйте домом откуда угодно';

  @override
  String get remoteOfferBody =>
      'Управляйте устройствами вне дома через зашифрованный ретранслятор ZigDash. Входит в Pro: один платёж, без ежемесячной оплаты. Настройте, пока вы дома.';

  @override
  String get remoteOfferBodyPro =>
      'У вас есть Pro: включите удалённое управление, пока вы дома, и управляйте устройствами откуда угодно.';

  @override
  String get remoteOfferShow => 'Показать';

  @override
  String get remoteIntroBody =>
      'Хаб держит одно соединение с ретранслятором ZigDash. Вне дома этот телефон достаёт до устройств через него. Всё шифруется на хабе и в телефоне, поэтому ретранслятор не может прочитать ни устройства, ни что они делают.';

  @override
  String get remoteNeedsEngine =>
      'Удалённое управление работает в ZigDash Engine. Сначала установите его в разделе «Автоматизации».';

  @override
  String get remoteSetUp => 'Включить удалённое управление';

  @override
  String get remoteNeedsPro => 'Удалённое управление входит в Pro.';

  @override
  String get remoteNotAtHome => 'Включите это дома, при подключении к брокеру.';

  @override
  String get remoteUnreachable =>
      'Ретранслятор ZigDash не ответил. Попробуйте позже.';

  @override
  String get remoteRefused =>
      'Ретранслятор отказал. Попробуйте снова или сообщите о проблеме.';

  @override
  String get remoteOnTitle => 'Удалённое управление включено';

  @override
  String get remoteOnBody =>
      'Вне дома ZigDash сам подключается через ретранслятор.';

  @override
  String get remoteHubOnline => 'Хаб подключён к ретранслятору';

  @override
  String get remoteHubOffline => 'Хаб не подключён к ретранслятору';

  @override
  String get remoteTurnOff => 'Выключить удалённое управление';

  @override
  String get remoteViaRelayNow =>
      'Этот телефон сейчас подключён через ретранслятор.';

  @override
  String get remotePhones => 'Телефоны с удалённым доступом';

  @override
  String get remoteThisPhone => 'Этот телефон';

  @override
  String get remoteOtherPhone => 'Другой телефон';

  @override
  String remotePhoneAdded(Object date) {
    return 'Добавлен $date';
  }

  @override
  String get remoteRemovePhone => 'Удалить';

  @override
  String get remoteRemovePhoneConfirm =>
      'Удалить этот телефон? Он больше не сможет подключаться к дому издалека.';

  @override
  String get remoteAddPhone => 'Добавить телефон';

  @override
  String get remoteAddPhoneHint =>
      'Дома отсканируйте это камерой другого телефона. Откроется ZigDash и включит там удалённое управление. Показывайте только своим телефонам.';

  @override
  String get remoteAddPhoneFailed =>
      'Ретранслятор не выдал доступ для ещё одного телефона. У дома может быть до пяти.';

  @override
  String get remoteBackupSave => 'Сохранить резервную копию ключа';

  @override
  String get remoteBackupRestore => 'Восстановить из копии ключа';

  @override
  String get remoteBackupPassphrase => 'Пароль копии';

  @override
  String get remoteBackupPassphraseHint =>
      'Если потеряете этот телефон, копия и этот пароль вернут удалённое управление на новом. Не меньше 8 символов; храните пароль отдельно от файла.';

  @override
  String get remoteBackupPassphraseAsk =>
      'Пароль, выбранный при сохранении копии.';

  @override
  String get remoteBackupPassphraseAgain => 'Пароль ещё раз';

  @override
  String get remoteBackupSaved => 'Копия ключа сохранена';

  @override
  String get remoteBackupWrong => 'Этот пароль не открывает копию.';

  @override
  String get remoteBackupWrongFile => 'Это не копия ключа ZigDash.';

  @override
  String get remotePlayOnly =>
      'Пока удалённое управление есть в версии ZigDash из Google Play.';

  @override
  String get remotePairTitle => 'Добавить удалённое управление';

  @override
  String get remotePairBody =>
      'Какой это дом? ZigDash сохранит для него удалённый доступ.';

  @override
  String get remotePairNoHomes =>
      'Сначала настройте этот дом на этом телефоне, дома. Потом отсканируйте код снова.';

  @override
  String get remotePairInvalid =>
      'Это не код удалённого управления ZigDash, или он обрезан.';

  @override
  String remotePairDone(Object home) {
    return 'Удалённое управление включено: $home';
  }

  @override
  String get remoteReconnectHub => 'Переподключить хаб';

  @override
  String get remoteTurnOffConfirm =>
      'Этот телефон отключится от удалённого управления, а хаб — от ретранслятора. Копия ключа, сохранённая с этого телефона, перестанет работать; другие телефоны сохранят доступ, пока вы их не удалите.';

  @override
  String remoteHomeId(Object id) {
    return 'ID дома $id';
  }

  @override
  String get alertsHintTitle => 'Уведомления на этот телефон';

  @override
  String get alertsHintBody =>
      'Протечка, дым, открытая дверь или слабая батарея могут прислать уведомление на этот телефон, даже когда ZigDash закрыт.';

  @override
  String get alertsHintButton => 'Настроить тревоги';

  @override
  String get alertsHintNotNow => 'Не сейчас';

  @override
  String get guidedNoZ2mBody =>
      'Здесь отвечает MQTT-брокер, но Zigbee2MQTT ничего через него не отправляет. Проверьте, что Zigbee2MQTT запущен и использует этот брокер, а базовый топик совпадает с его настройками. Если ваши Zigbee-устройства в ZHA Home Assistant, ZigDash их не видит: он работает с Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT есть на этом брокере с базовым топиком «$found», но этот дом ищет «$current».';
  }

  @override
  String devicesUseBase(String found) {
    return 'Использовать «$found»';
  }

  @override
  String get devicesChangeConnection => 'Изменить подключение';

  @override
  String get updateAvailableTitle => 'Готова новая версия ZigDash';

  @override
  String get updateAvailableBody =>
      'Она загрузится, пока вы пользуетесь ZigDash.';

  @override
  String get updateAvailableButton => 'Обновить';

  @override
  String get updateDownloading => 'Загрузка обновления…';

  @override
  String get updateReadyTitle => 'Обновление загружено';

  @override
  String get updateReadyButton => 'Перезапустить, чтобы завершить';

  @override
  String get nfcWriteTag => 'Записать на NFC-метку';

  @override
  String get nfcHoldTitle => 'Поднесите метку к телефону';

  @override
  String nfcHoldBody(String name) {
    return 'Поднесите пустую NFC-наклейку к задней стороне телефона. Потом касание к ней запустит $name.';
  }

  @override
  String get nfcWrittenTitle => 'Метка готова';

  @override
  String nfcWrittenBody(String name) {
    return 'Коснитесь телефоном этой метки, чтобы запустить $name. Работает даже при закрытом ZigDash.';
  }

  @override
  String get nfcFailedTitle => 'Не удалось записать метку';

  @override
  String get nfcReadonlyBody =>
      'Эта метка заблокирована, её нельзя изменить. Попробуйте другую.';

  @override
  String get nfcTooSmallBody =>
      'Эта метка слишком мала. Используйте наклейку NTAG213 или больше.';

  @override
  String get nfcFailedBody =>
      'Держите метку неподвижно у задней стороны телефона и попробуйте снова.';

  @override
  String get nfcOffTitle => 'NFC выключен';

  @override
  String get nfcOffBody =>
      'Включите NFC в настройках Android и попробуйте снова.';

  @override
  String get nfcNoneTitle => 'На этом телефоне нет NFC';

  @override
  String get nfcNoneBody =>
      'Этот телефон не умеет читать и записывать NFC-метки.';

  @override
  String get nfcWriteAnother => 'Записать ещё метку';

  @override
  String get nfcUnsupportedBody =>
      'Этот телефон не может записать такую метку (часто это MIFARE Classic). Используйте наклейку NTAG213, 215 или 216.';
}
