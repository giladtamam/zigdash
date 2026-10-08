// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Last known';

  @override
  String get reliabilityControlsUnavailable => 'Controls unavailable';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'Try demo';

  @override
  String get navBrokers => 'Brokers';

  @override
  String get navDashboards => 'Dashboards';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsDynamicColor => 'Use Material You colors';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; otherwise uses the app color';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Homes';

  @override
  String connLoadFailed(Object error) {
    return 'Failed to load: $error';
  }

  @override
  String get connAddBroker => 'Add broker';

  @override
  String get connEmpty =>
      'No connections yet.\nTap \"Add broker\" to point ZigDash at your MQTT server.';

  @override
  String get connNew => 'New connection';

  @override
  String get connEdit => 'Edit connection';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get fieldRequired => 'Required';

  @override
  String get connName => 'Name';

  @override
  String get connNameHint => 'Home broker';

  @override
  String get connHost => 'Host';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Local host';

  @override
  String get connFindBrokers => 'Find brokers';

  @override
  String get connHowToFind => 'How do I find this?';

  @override
  String get connRescan => 'Rescan';

  @override
  String get connBrokerNeedsLogin => 'Needs login';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Scanning $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return '$count broker(s) found — tap to use';
  }

  @override
  String get connFindBrokersNone => 'No brokers found on your Wi-Fi.';

  @override
  String get connFindBrokersNoIp =>
      'Couldn\'t read your Wi-Fi address. Make sure Wi-Fi is on and try again.';

  @override
  String get connHelpTitle => 'Finding your broker IP';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT in Docker';

  @override
  String get connHelpDockerBody =>
      'The broker IP is the LAN address of the machine running Docker (your NAS, Raspberry Pi, etc.). Find it in your router\'s device list, or run \'hostname -I\' / \'ip addr\' on that machine. Port is usually 1883 (Mosquitto). Use the host\'s LAN IP — not 127.0.0.1 — even if Mosquitto runs in its own container.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'The broker IP is the hub\'s IP address. Find it in the SMLIGHT web interface under Settings → Network, or in your router. Port is 1883, with no username/password by default.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA has no MQTT broker — it talks to Home Assistant directly, so ZigDash can\'t connect to it. To use ZigDash, switch to Zigbee2MQTT (available as a Home Assistant add-on or a Docker container), which provides an MQTT broker.';

  @override
  String get connHelpSameNetwork =>
      'Your phone and the broker must be on the same Wi-Fi network (not a guest or isolated VLAN).';

  @override
  String get connRemoteHost => 'Remote host (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Used when the local host can\'t be reached. Prefer the hub\'s Tailscale IP, e.g. 100.x.y.z';

  @override
  String get connPort => 'Port';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsernameOptional => 'Username (optional)';

  @override
  String get connPasswordOptional => 'Password (optional)';

  @override
  String get connPasswordKeepHint => 'Leave blank to keep existing';

  @override
  String get connAutoConnect => 'Auto-connect on app start';

  @override
  String get advanced => 'Advanced';

  @override
  String get connKeepAlive => 'Keep-alive (seconds)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protocol';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get connDeleteTitle => 'Delete connection?';

  @override
  String connDeleteContent(Object name) {
    return 'Removes \"$name\", its dashboards/panels, and its saved password.';
  }

  @override
  String get statusDisconnected => 'Disconnected';

  @override
  String get statusConnecting => 'Connecting';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusReconnecting => 'Reconnecting';

  @override
  String get statusError => 'Error';

  @override
  String get statusConnectedRemote => 'Connected · Remote';

  @override
  String get dashPlaceholder =>
      'Open a broker from the Brokers tab to see and manage its dashboards.';

  @override
  String get dashAddDashboard => 'Add dashboard';

  @override
  String get dashEditDashboard => 'Edit dashboard';

  @override
  String get dashAddPanel => 'Add panel';

  @override
  String get dashEmpty =>
      'No dashboards yet.\nTap \"Add dashboard\" to create one for this broker.';

  @override
  String dashLoadFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String get panelPickerTitle => 'Add a panel';

  @override
  String get panelPickerSectionControl => 'Control';

  @override
  String get panelPickerSectionState => 'State';

  @override
  String get panelPickerToggleTitle => 'Toggle';

  @override
  String get panelPickerToggleSubtitle => 'On/off switch for a device state';

  @override
  String get panelPickerSliderBrightnessTitle => 'Slider — Brightness';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Light dimming (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Slider — Position';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Cover / shutter (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Cover';

  @override
  String get panelPickerCoverSubtitle =>
      'Shutter/blind: OPEN·STOP·CLOSE + position slider';

  @override
  String get panelPickerScheduleTitle => 'Schedule';

  @override
  String get panelPickerScheduleSubtitle =>
      'Daily open/close times, run on the hub (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Auto-close rule';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Close a device automatically N seconds after it turns on, run on the hub (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Multi-State';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Segmented buttons for an enum (e.g. OPEN/STOP/CLOSE)';

  @override
  String get panelPickerComboTitle => 'Combo';

  @override
  String get panelPickerComboSubtitle => 'Dropdown selector for an enum';

  @override
  String get panelPickerRadioTitle => 'Radio';

  @override
  String get panelPickerRadioSubtitle => 'Radio-button list for an enum';

  @override
  String get panelPickerButtonTitle => 'Button';

  @override
  String get panelPickerButtonSubtitle => 'Fire a one-shot command';

  @override
  String get panelPickerTextInputTitle => 'Text Input';

  @override
  String get panelPickerTextInputSubtitle =>
      'Publish a free-form value or JSON';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Colored indicator for a boolean state (contact, leak)';

  @override
  String get panelPickerNodeStatusTitle => 'Node Status';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Z2M device availability (online/offline)';

  @override
  String get panelPickerProgressTitle => 'Progress';

  @override
  String get panelPickerProgressSubtitle =>
      'Numeric bar for battery, link quality, etc.';

  @override
  String get panelPickerTextLogTitle => 'Text Log';

  @override
  String get panelPickerTextLogSubtitle =>
      'Scrolling history of messages on a topic';

  @override
  String get dashExportMenu => 'Export dashboards';

  @override
  String get dashImportMenu => 'Import dashboards';

  @override
  String get dashExportTitle => 'Export dashboards';

  @override
  String get dashExportClose => 'Close';

  @override
  String get dashExportCopy => 'Copy';

  @override
  String get dashExportCopied => 'Copied to clipboard';

  @override
  String get dashImportTitle => 'Import dashboards';

  @override
  String get dashImportHint => 'Paste exported JSON here';

  @override
  String get dashImportButton => 'Import';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count dashboards',
      one: 'Imported 1 dashboard',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get dashFormNew => 'New dashboard';

  @override
  String get dashFormEdit => 'Edit dashboard';

  @override
  String get dashFormName => 'Name';

  @override
  String get dashFormNameHint => 'Office';

  @override
  String get dashFormTopicPrefix => 'Topic prefix (optional)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/living-room';

  @override
  String get dashFormTopicPrefixHelper =>
      'Prepended to every panel topic in this dashboard';

  @override
  String get dashFormColorSeed => 'Color seed';

  @override
  String get dashFormIcon => 'Icon';

  @override
  String get dashFormLock => 'Lock';

  @override
  String get dashFormLockSubtitle => 'Hide edit affordances while locked';

  @override
  String get dashFormDelete => 'Delete dashboard';

  @override
  String get dashDeleteTitle => 'Delete this dashboard?';

  @override
  String get dashDeleteContent => 'All panels under it will also be removed.';

  @override
  String get dashDeleteConfirm => 'Delete';

  @override
  String panelFormNew(Object type) {
    return 'New $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Edit $type';
  }

  @override
  String get panelTypeButton => 'Button';

  @override
  String get panelTypeToggle => 'Toggle';

  @override
  String get panelTypeSlider => 'Slider';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Node Status';

  @override
  String get panelTypeProgress => 'Progress';

  @override
  String get panelTypeMultiState => 'Multi-State';

  @override
  String get panelTypeCombo => 'Combo';

  @override
  String get panelTypeRadio => 'Radio';

  @override
  String get panelTypeCover => 'Cover';

  @override
  String get panelTypeTextInput => 'Text Input';

  @override
  String get panelTypeTextLog => 'Text Log';

  @override
  String get panelTypeSchedule => 'Schedule';

  @override
  String get panelTypeAutoClose => 'Auto-close';

  @override
  String get panelTypeDevice => 'Device';

  @override
  String get panelTypeReading => 'Reading';

  @override
  String get panelFormName => 'Name';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Dashboard prefix: $prefix/ (used unless overridden below)';
  }

  @override
  String get panelFormTopicPrefixOverride => 'Topic prefix override (optional)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/shutter';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Use a different device on this dashboard. Blank = use dashboard prefix.';

  @override
  String get panelFormPublishTopic => 'Publish topic (suffix)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Appended to the effective prefix. Leave blank to publish at the prefix itself.';

  @override
  String get panelFormTopicSuffix => 'Topic (suffix)';

  @override
  String get panelFormSubscribeTopic => 'Subscribe topic (suffix, optional)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Appended to the dashboard prefix. Blank = subscribe to the prefix itself (Z2M state).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Blank = subscribe to the prefix itself (Z2M state). Same as Publish topic = use that.';

  @override
  String get tileSize => 'Size';

  @override
  String get tileSizeSmall => 'Small';

  @override
  String get tileSizeWide => 'Wide';

  @override
  String get tileSizeFull => 'Full';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — at most once';

  @override
  String get panelFormQos1 => '1 — at least once';

  @override
  String get panelFormQos2 => '2 — exactly once';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'On payload';

  @override
  String get panelToggleOffPayload => 'Off payload';

  @override
  String get panelToggleJsonPath => 'JSON path (optional)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'On match';

  @override
  String get panelToggleOnMatchHelper =>
      'Value at JSON path that means \"on\" (e.g. \"ON\")';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Max';

  @override
  String get panelSliderStep => 'Step';

  @override
  String get panelSliderTemplate => 'Value template';

  @override
  String get panelSliderTemplateHelper =>
      'Use the word value as a placeholder — it is replaced with the slider value';

  @override
  String get panelSliderJsonPath => 'JSON path (optional)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'JSON path (optional)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'e.g. \"contact\", \"occupancy\", \"water_leak\"';

  @override
  String get panelLedOnMatch => 'On match';

  @override
  String get panelLedOnMatchHelper =>
      'Value at JSON path that lights the LED (e.g. \"true\", \"ON\")';

  @override
  String get panelLedOnLabel => 'On label (optional)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Off label (optional)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Online payload';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Value that means \"online\" (Z2M default: \"online\")';

  @override
  String get panelNodeJsonPath => 'JSON path (optional)';

  @override
  String get panelNodeJsonPathHelper =>
      'Leave blank for Z2M default (raw \"online\"/\"offline\" string)';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Max';

  @override
  String get panelProgressUnit => 'Unit';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'JSON path (optional)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'e.g. \"battery\", \"linkquality\"';

  @override
  String get panelOptionsJsonPath => 'JSON path (optional)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Field in the received payload that holds the current value';

  @override
  String get panelOptionsHeader => 'Options';

  @override
  String get panelOptionsLabel => 'Label';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Match (current value)';

  @override
  String get panelOptionsAdd => 'Add option';

  @override
  String get panelCoverDescription =>
      'OPEN / STOP / CLOSE buttons plus a row of position presets. Uses the standard Z2M cover payloads (state and position).';

  @override
  String get panelCoverPresets => 'Position presets';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Comma-separated percentages (0–100). Blank = no preset row.';

  @override
  String get panelCoverShowSlider => 'Show position slider';

  @override
  String get panelTextInputHint => 'Hint (optional)';

  @override
  String get panelTextInputHintHint => 'Type a value…';

  @override
  String get panelTextInputTemplate => 'Template';

  @override
  String get panelTextInputTemplateHelper =>
      'Use the word value as a placeholder — it is replaced with the typed text. Default publishes the raw text.';

  @override
  String get panelTextInputClearAfterSend => 'Clear after send';

  @override
  String get panelTextLogMaxLines => 'Max lines';

  @override
  String get panelTextLogMaxLinesHelper => 'How many recent messages to keep';

  @override
  String get panelTextLogJsonPath => 'JSON path (optional)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Log just this field instead of the whole payload';

  @override
  String get panelScheduleDescription =>
      'Runs on the SMHUB via Node-RED — fires even when this phone is off. The Publish topic above is the shutter command target.';

  @override
  String get panelScheduleOpenTime => 'Open time';

  @override
  String get panelScheduleCloseTime => 'Close time';

  @override
  String get panelScheduleOpenPayload => 'Open payload';

  @override
  String get panelScheduleClosePayload => 'Close payload';

  @override
  String get panelScheduleEnabled => 'Enabled';

  @override
  String get panelScheduleSavedOffline =>
      'Saved — not connected; schedule will sync when online.';

  @override
  String get panelAutoCloseDescription =>
      'Runs on the SMHUB via Node-RED — fires even when this phone is off. The Publish topic above is the device\'s command target (e.g. door).';

  @override
  String get panelAutoCloseTriggerPath => 'Trigger JSON path';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Field in the device\'s state JSON to watch (default: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Trigger value';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Fire the timer when the trigger field equals this value (default: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Close payload';

  @override
  String get panelAutoCloseDelaySeconds => 'Delay (seconds)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1-3600. Time to wait after the device turns on before publishing the close payload.';

  @override
  String get panelAutoCloseEnabled => 'Enabled';

  @override
  String get panelAutoCloseSavedOffline =>
      'Saved — not connected; rule will sync when online.';

  @override
  String get panelTileEdit => 'Edit panel';

  @override
  String get panelTileDuplicate => 'Duplicate panel';

  @override
  String get panelTileMoveUp => 'Move up';

  @override
  String get panelTileMoveDown => 'Move down';

  @override
  String get panelTileDelete => 'Delete panel';

  @override
  String get panelCoverOpen => 'Open';

  @override
  String get panelCoverStop => 'Stop';

  @override
  String get panelCoverClose => 'Close';

  @override
  String get panelToggleNoState => '(no state)';

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
  String get panelNodeStatusUnknown => 'unknown';

  @override
  String get panelNodeStatusError => 'error';

  @override
  String get panelMultiStateNoOptions => 'No options configured';

  @override
  String get panelTextInputDefaultHint => 'Type a value…';

  @override
  String get panelTextLogWaiting => 'Waiting for messages…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Opens $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Closes $time';
  }

  @override
  String get panelScheduleOfflineWarning => 'Scheduler offline — won\'t run';

  @override
  String get panelScheduleDisabled => 'Disabled';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Next: $action at $at';
  }

  @override
  String get panelScheduleActionOpen => 'open';

  @override
  String get panelScheduleActionClose => 'close';

  @override
  String get panelAutoCloseIdle => 'Idle';

  @override
  String get panelAutoCloseDisabled => 'Disabled';

  @override
  String get panelAutoCloseOffline => 'Automation offline — rule won\'t run';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Closing in ${seconds}s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Closing now…';

  @override
  String get panelGridEmpty =>
      'No tiles yet.\nTap Add tile to put your devices here.';

  @override
  String get panelsOffline => 'Offline — showing last values';

  @override
  String get connectionConnecting => 'Connecting…';

  @override
  String get connectionReconnecting => 'Reconnecting…';

  @override
  String get connectionShowingLastKnownValues => 'Showing last known values';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get connectionAutomaticRetry => 'Automatic retry will continue';

  @override
  String get connectionReconnectNow => 'Reconnect now';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsHelp => 'Help & Guide';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsRateApp => 'Rate ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Enjoying it? A quick review helps others find it.';

  @override
  String get settingsBuyCoffee => 'Buy me a coffee';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Free & open source — tips keep it brewing.';

  @override
  String get a11yBackupMenu => 'Backup & restore';

  @override
  String get a11ySelectColor => 'Select color';

  @override
  String get a11ySelectIcon => 'Select icon';

  @override
  String get a11yDeleteOption => 'Delete option';

  @override
  String get a11yPanelOptions => 'Panel options';

  @override
  String get a11yMoreOptions => 'More options';

  @override
  String get a11yRefresh => 'Refresh';

  @override
  String get a11yDeleteConnection => 'Delete connection';

  @override
  String get controlNotConnected => 'Not connected — change not sent';

  @override
  String get discoverFromDevice => 'Add from a device…';

  @override
  String get discoverFromDeviceSubtitle => 'Auto-detect a Zigbee2MQTT device';

  @override
  String get discoverTitle => 'Add from device';

  @override
  String get discoverBaseTopic => 'Zigbee2MQTT base topic';

  @override
  String get discoverScanning => 'Scanning for devices…';

  @override
  String get discoverNone => 'No devices found.';

  @override
  String get discoverFailed =>
      'No device list found. Check the base topic and that the broker is connected.';

  @override
  String get retry => 'Retry';

  @override
  String get previewTitle => 'Live preview';

  @override
  String previewWaiting(Object topic) {
    return 'Waiting for a message on $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Extracted ($path): $value';
  }

  @override
  String get previewNoValue => '(no value at this path)';

  @override
  String get connErrorTitle => 'Connection error';

  @override
  String get connErrorUnknown => 'No error details available.';

  @override
  String get connTestButton => 'Test connection';

  @override
  String get connTestOk => 'Connection successful';

  @override
  String connTestFailed(Object error) {
    return 'Connection failed: $error';
  }

  @override
  String get devicesTitle => 'Devices';

  @override
  String get devicesAddButton => 'Add device';

  @override
  String get devicesPairingTitle => 'Pairing — press the device\'s button';

  @override
  String devicesPairingHint(int seconds) {
    return 'Searching for new devices… ${seconds}s';
  }

  @override
  String get devicesPairingStop => 'Stop';

  @override
  String get devicesNone => 'No devices found.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT hasn\'t sent its device list. This can happen after the MQTT broker restarts.';

  @override
  String get devicesRestartZ2m => 'Restart Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Restarting Zigbee2MQTT. Your devices should appear in a few seconds.';

  @override
  String get devicesBattery => 'Battery';

  @override
  String get devicesLinkQuality => 'Link';

  @override
  String get devicesOnline => 'Online';

  @override
  String get devicesOffline => 'Offline';

  @override
  String devicesPaired(Object name) {
    return 'Ready: $name';
  }

  @override
  String get devicesPairedHint =>
      'Added to your network. To put it on a dashboard, use \'Add from a device\' on that dashboard.';

  @override
  String get scenesTitle => 'Scenes';

  @override
  String get scenesNone =>
      'No scenes yet. Set your devices the way you like, then capture them as a scene.';

  @override
  String get scenesNewButton => 'New scene';

  @override
  String scenesActivated(Object name) {
    return 'Activated $name';
  }

  @override
  String get scenesActivateOffline =>
      'Not connected — can\'t activate the scene';

  @override
  String get sceneFormNewTitle => 'New scene';

  @override
  String get sceneFormEditTitle => 'Edit scene';

  @override
  String get sceneFormNameLabel => 'Scene name';

  @override
  String get sceneFormDevicesHeader => 'Devices to capture';

  @override
  String get sceneFormCaptureHint =>
      'Each selected device\'s current settable state (on/off, brightness, colour, position…) is saved. Read-only values are ignored.';

  @override
  String get sceneFormNoDevices =>
      'No controllable devices found. Make sure they\'re paired, then tap refresh.';

  @override
  String get sceneFormReadingState => 'Reading current state…';

  @override
  String get sceneCtrlPower => 'Power';

  @override
  String get sceneCtrlBrightness => 'Brightness';

  @override
  String get sceneCtrlPosition => 'Position';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get sceneFormNoDevicesSelected =>
      'Select at least one device to capture.';

  @override
  String get sceneFormNothingCaptured =>
      'Nothing settable was captured from the selected devices.';

  @override
  String get sceneDeleteTitle => 'Delete scene?';

  @override
  String sceneDeleteMessage(Object name) {
    return '\"$name\" will be removed. Devices keep their current state.';
  }

  @override
  String get sceneEditAction => 'Edit';

  @override
  String get sceneDeleteAction => 'Delete';

  @override
  String get sceneAddToDashboard => 'Add to dashboard';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Added to $name';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count devices';
  }

  @override
  String get panelTypeScene => 'Scene';

  @override
  String get panelPickerSceneTitle => 'Scene button';

  @override
  String get panelPickerSceneSubtitle => 'One tap activates a saved scene';

  @override
  String get panelSceneChoose => 'Scene';

  @override
  String get panelSceneMissing => 'Scene not found — re-pick it';

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
  String get guidedConnectTitle => 'Set up your broker';

  @override
  String get guidedConnectIntro =>
      'We\'ll test each step of the connection and show your Zigbee devices.';

  @override
  String get guidedBaseTopic => 'Base topic';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Test & connect';

  @override
  String get guidedTesting => 'Testing your connection…';

  @override
  String get stepResolve => 'Resolving host';

  @override
  String get stepTcp => 'TCP connection';

  @override
  String get stepConnack => 'MQTT handshake';

  @override
  String get stepAuth => 'Authentication';

  @override
  String get stepDevices => 'Looking for devices';

  @override
  String get diagResolveFail =>
      'The host name couldn\'t be resolved. Check the address you entered.';

  @override
  String get diagResolveTimeout =>
      'Resolving the host timed out. Check the address and your network.';

  @override
  String get diagTcpFail =>
      'Can\'t reach the broker. Is Zigbee2MQTT running? Check the address and port.';

  @override
  String get diagTcpTimeout =>
      'Connecting to the broker timed out. It may be offline or unreachable.';

  @override
  String get diagConnackFail =>
      'The broker didn\'t complete the MQTT handshake. Make sure this is an MQTT broker (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'The broker rejected the username or password. Check your credentials.';

  @override
  String get diagAuthRefused =>
      'The broker refused the connection. Check the connection settings.';

  @override
  String foundDevices(Object count) {
    return 'Found $count devices';
  }

  @override
  String get foundDevicesHint =>
      'Your Zigbee devices are visible. Continue to build your dashboard.';

  @override
  String get noDevicesTitle => 'Connected — no devices found yet';

  @override
  String get noDevicesHint =>
      'ZigDash can see your broker, but hasn\'t found any Zigbee devices yet. You can start pairing to add them.';

  @override
  String get startPairing => 'Start pairing';

  @override
  String get pairingEnabled =>
      'Pairing is enabled. Press the pairing button on your device to join it.';

  @override
  String get continueToDashboard => 'Continue to dashboard';

  @override
  String get guidedBackToForm => 'Edit settings';

  @override
  String ladderTriedHint(Object count) {
    return 'Tried $count addresses';
  }

  @override
  String get guidedSaveFailed =>
      'Couldn\'t save the connection. Please try again.';

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
      'SMLIGHT / SMHUB: open the device\'s web UI, go to Settings > MQTT, turn on Allow External so your phone can reach the broker, and check that Zigbee2MQTT shows as running.';

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

  @override
  String get setupNoZ2mTitle =>
      'Your broker works, but Zigbee2MQTT isn\'t publishing here';

  @override
  String setupNoZ2mBody(String base) {
    return 'We listened on $base/bridge and heard nothing.';
  }

  @override
  String get setupBaseTopicQuestion => 'Using a different base topic?';

  @override
  String get setupGuidesTitle => 'Set up Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'Try the demo meanwhile';

  @override
  String get demoBannerText => 'You\'re in demo mode';

  @override
  String get demoBannerAction => 'Connect your home';

  @override
  String get deviceOn => 'On';

  @override
  String get deviceOff => 'Off';

  @override
  String get deviceOpen => 'Open';

  @override
  String get deviceClosed => 'Closed';

  @override
  String get deviceMotion => 'Motion';

  @override
  String get deviceClear => 'Clear';

  @override
  String get deviceLeakDetected => 'Leak detected';

  @override
  String get deviceSmokeDetected => 'Smoke detected';

  @override
  String get deviceGasDetected => 'Gas detected';

  @override
  String get deviceWaiting => 'Waiting for first report';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on on · $off off';
  }

  @override
  String get deviceBrightness => 'Brightness';

  @override
  String get deviceWhite => 'White';

  @override
  String get deviceColor => 'Color';

  @override
  String get deviceHue => 'Hue';

  @override
  String get devicePosition => 'Position';

  @override
  String get deviceControls => 'Controls';

  @override
  String deviceBattery(int percent) {
    return 'Battery $percent%';
  }

  @override
  String get deviceToggle => 'Turn on or off';

  @override
  String get deviceMore => 'More';

  @override
  String get sectionLights => 'Lights';

  @override
  String get sectionSwitchesCovers => 'Switches and covers';

  @override
  String get sectionSensors => 'Sensors';

  @override
  String get sectionOther => 'Other';

  @override
  String get homeFirstName => 'My Home';

  @override
  String homeNumberedName(int number) {
    return 'Home $number';
  }

  @override
  String get dashAddTile => 'Add tile';

  @override
  String get addTileSearch => 'Search devices';

  @override
  String get addTileNotOnDashboard => 'Not on a dashboard';

  @override
  String get addTileAllDevices => 'All devices';

  @override
  String get addTileReading => 'Reading';

  @override
  String get addTileReadingSubtitle => 'One value from a device or topic';

  @override
  String get addTileCustom => 'Custom MQTT tile';

  @override
  String get addTileCustomSubtitle => 'Any tile type, set up by topic';

  @override
  String get addTileNoDevices =>
      'No devices to show. Connect to your broker, or pair a device in Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Add';

  @override
  String get addTileName => 'Name';

  @override
  String addTileNameHint(String model) {
    return 'e.g. $model';
  }

  @override
  String get addTileSection => 'Section';

  @override
  String get addTileNoSection => 'No section';

  @override
  String get addTileSize => 'Size';

  @override
  String get deviceClassColorLight => 'Color light';

  @override
  String get deviceClassLight => 'Light';

  @override
  String get deviceClassSwitch => 'Switch or plug';

  @override
  String get deviceClassCover => 'Cover';

  @override
  String get deviceClassLeak => 'Leak or smoke';

  @override
  String get deviceClassContact => 'Contact';

  @override
  String get deviceClassMotion => 'Motion';

  @override
  String get deviceClassClimate => 'Climate sensor';

  @override
  String get deviceClassGeneric => 'Device';

  @override
  String get deviceNotResponding => 'Not responding';

  @override
  String get homeAdd => 'Add a home';

  @override
  String get homeManage => 'Manage homes';

  @override
  String get homeSwitch => 'Switch home';

  @override
  String get navDevices => 'Devices';

  @override
  String get navScenes => 'Scenes';

  @override
  String get devicesNewDot => 'New devices';

  @override
  String get editEditing => 'Editing';

  @override
  String get editDashboard => 'Dashboard';

  @override
  String get editDone => 'Done';

  @override
  String get editAddSection => 'Add section';

  @override
  String get editSectionName => 'Section name';

  @override
  String get editRenameSection => 'Rename section';

  @override
  String get editDeleteSection => 'Delete section';

  @override
  String get editDeleteSectionBody => 'What should happen to its tiles?';

  @override
  String get editKeepTiles => 'Keep tiles, remove section';

  @override
  String get editDeleteTiles => 'Delete tiles too';

  @override
  String get editMoveToSection => 'Move to section';

  @override
  String get editEditTile => 'Edit tile';

  @override
  String get editRemove => 'Remove from dashboard';

  @override
  String get editRemoved => 'Tile removed';

  @override
  String get editUndo => 'Undo';

  @override
  String get editReplaceWithDevice => 'Replace with device tile';

  @override
  String get editMoveEarlier => 'Move earlier';

  @override
  String get editMoveLater => 'Move later';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices aren\'t on any dashboard',
      one: '1 device isn\'t on any dashboard',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Tile options';

  @override
  String get editSave => 'Save';

  @override
  String get editCancel => 'Cancel';

  @override
  String get ageJustNow => 'Just now';

  @override
  String ageMinutes(int n) {
    return '$n min ago';
  }

  @override
  String ageHours(int n) {
    return '$n h ago';
  }

  @override
  String get statusCantReach => 'Can\'t reach your broker';

  @override
  String get statusWhy => 'Why?';

  @override
  String get statusWhyTitle => 'Your broker isn\'t answering';

  @override
  String get statusWhyBody =>
      'ZigDash keeps trying on its own. Until it\'s back, tiles show their last known values, dimmed, with their age. Check that the broker is on and this phone is on the same network, or test the connection in its settings.';

  @override
  String get statusSettings => 'Connection settings';

  @override
  String get deviceAddToDashboard => 'Add to a dashboard';

  @override
  String get deviceDismiss => 'Dismiss';

  @override
  String get devicesFilterAll => 'All';

  @override
  String devicesFilterAttention(int count) {
    return 'Needs attention · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Not on a dashboard · $count';
  }

  @override
  String get devicesNoMatch => 'No devices match';

  @override
  String get deviceBatteryLow => 'Battery low';

  @override
  String get deviceLinkWeak => 'Weak';

  @override
  String get deviceUnsupported => 'Not supported by Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'Pairing didn\'t finish';

  @override
  String get deviceNoReport => 'No report yet';

  @override
  String get devicesAvailabilityOff =>
      'Zigbee2MQTT availability is off, so offline devices show as Not responding.';

  @override
  String get devicesAvailabilityHow => 'How to turn it on';

  @override
  String get devicesDotBattery => 'Battery low';

  @override
  String get deviceDetails => 'Device details';

  @override
  String get deviceGone => 'This device is no longer in Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Control';

  @override
  String get deviceReadingsTitle => 'Readings';

  @override
  String get deviceHealthTitle => 'Health';

  @override
  String get deviceOnDashboards => 'On dashboards';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT doesn\'t support this device yet, so there is nothing to control.';

  @override
  String get deviceAddReadingTile => 'Add as reading tile';

  @override
  String get deviceAddReadingTo => 'Add to which dashboard?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Added to $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Link quality';

  @override
  String get deviceLinkGood => 'Good';

  @override
  String get devicePowerSource => 'Power source';

  @override
  String get devicePowerBattery => 'Battery';

  @override
  String get devicePowerMains => 'Mains';

  @override
  String get deviceLastHeard => 'Last heard';

  @override
  String get deviceAvailability => 'Availability';

  @override
  String get deviceAvailabilityOff => 'Off in Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsPrivacySubtitle =>
      'No telemetry. Everything stays on this phone.';

  @override
  String get homeCurrent => 'Current home';

  @override
  String get homeConnection => 'Connection';

  @override
  String get homeSwitchTo => 'Switch to this home';

  @override
  String get homeDelete => 'Delete home';

  @override
  String get devicesSelect => 'Select a device';

  @override
  String get scenesSelect => 'Select a scene to edit';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'Pick a device';

  @override
  String get panelFormStateTopic => 'State topic';

  @override
  String get panelFormCommandTopic => 'Command topic';

  @override
  String get panelFormCommandTopicDerived =>
      'Filled from the state topic until you change it.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Linked to $device';
  }

  @override
  String get panelFormOpenDevice => 'Open device';

  @override
  String get panelFormUnlink => 'Unlink';

  @override
  String get panelFormValueChoices => 'Values from this device';

  @override
  String get panelFormAdvanced => 'Advanced';

  @override
  String get panelFormAdvancedSubtitle => 'Prefix override, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Blank = the prefix itself (a Zigbee2MQTT device\'s state).';

  @override
  String get dashWallDisplay => 'Wall display';

  @override
  String get analyticsSetupCheckbox =>
      'Share anonymous usage data to help improve setup';

  @override
  String get analyticsWhatsShared => 'What\'s shared';

  @override
  String get analyticsCardTitle => 'Help improve ZigDash?';

  @override
  String get analyticsCardBody =>
      'Share anonymous usage data: which setup steps fail and which features get used. Never your devices, topics or broker.';

  @override
  String get analyticsShare => 'Share';

  @override
  String get analyticsNoThanks => 'No thanks';

  @override
  String get settingsAnalytics => 'Share anonymous usage data';

  @override
  String get settingsAnalyticsSubtitle =>
      'Setup steps and features used. Never your devices, topics or broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Anonymous usage data only if you opt in.';

  @override
  String get dashDefaultName => 'Home';

  @override
  String get dashExportSaveFile => 'Save file';

  @override
  String get dashExportSaved => 'Backup saved';

  @override
  String get dashImportChooseFile => 'Choose file';

  @override
  String get dashImportFileUnreadable => 'Couldn\'t read that file';
}
