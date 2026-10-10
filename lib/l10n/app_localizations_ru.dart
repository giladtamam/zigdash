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
  String get dashFormLock => 'Блокировка';

  @override
  String get dashFormLockSubtitle =>
      'Скрывать элементы редактирования при блокировке';

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
      'Брокер недоступен. Запущен ли Zigbee2MQTT? Проверьте адрес и порт.';

  @override
  String get diagTcpTimeout =>
      'Истекло время подключения к брокеру. Возможно, он выключен или недоступен.';

  @override
  String get diagConnackFail =>
      'Брокер не завершил рукопожатие MQTT. Убедитесь, что это MQTT-брокер (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'Брокер отклонил имя пользователя или пароль. Проверьте учётные данные.';

  @override
  String get diagAuthRefused =>
      'Брокер отказал в подключении. Проверьте настройки подключения.';

  @override
  String foundDevices(Object count) {
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
  String ladderTriedHint(Object count) {
    return 'Проверено адресов: $count';
  }

  @override
  String get guidedSaveFailed =>
      'Не удалось сохранить подключение. Повторите попытку.';

  @override
  String get setupWelcomeTitle => 'Добро пожаловать в ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash управляет вашим умным домом на Zigbee2MQTT — локально, без облака. Убедитесь, что Zigbee2MQTT запущен, и позвольте ZigDash его найти.';

  @override
  String get setupFindMySetup => 'Найти мою систему';

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
  String get setupAuthTitle => 'Брокеру нужен вход';

  @override
  String setupAuthBody(Object host) {
    return 'Введите имя пользователя и пароль MQTT для $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Имя пользователя или пароль отклонены. Проверьте их и повторите попытку.';

  @override
  String get setupVerifyingTitle => 'Проверка подключения…';

  @override
  String get setupReviewTitle => 'Ваши устройства';

  @override
  String setupReviewSubtitle(Object count) {
    return 'Найдено устройств: $count. Выберите, что будет на первом дашборде.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'Создать дашборд ($count)';
  }

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
  String get setupErrScanFailedTitle => 'Нет локальной сети';

  @override
  String get setupErrScanFailedBody =>
      'Не удалось определить локальную сеть этого устройства. Подключитесь к Wi-Fi и повторите попытку.';

  @override
  String get setupErrScanFailedAction => 'Повторить';

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
  String get dashWallDisplayOn =>
      'Настенный дисплей включён: экран не гаснет, а панели скрываются через 10 секунд без касаний. Коснитесь, чтобы вернуть их.';

  @override
  String get dashWallDisplayOff => 'Настенный дисплей выключен.';

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
      'Анонимные данные — только с вашего согласия.';

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
  String get tipWhatYouNeedTitle => 'Что понадобится';

  @override
  String get tipWhatYouNeedBody =>
      'MQTT-брокер (Mosquitto) и Zigbee2MQTT, работающие на хабе: Home Assistant, Raspberry Pi или хабе SMLIGHT.';

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
}
