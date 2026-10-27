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
  String get connUsername => 'Username';

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
  String get dashFormLock => 'Edit lock';

  @override
  String get dashFormLockSubtitle => 'Hides Edit for this dashboard';

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
  String get settingsFeatureRequest => 'Request a feature';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Tell me what would make ZigDash better.';

  @override
  String get featureRequestGithub => 'On GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Public: others can see it and vote for it.';

  @override
  String get featureRequestEmail => 'By email';

  @override
  String get featureRequestEmailSubtitle =>
      'Private, straight to the developer.';

  @override
  String get featureRequestEmailSubject => 'ZigDash feature request';

  @override
  String get featureRequestEmailPrompt =>
      'What would you like ZigDash to do, and why?';

  @override
  String get settingsReportProblem => 'Report a problem';

  @override
  String get settingsReportProblemSubtitle =>
      'Something broken or confusing? Tell me.';

  @override
  String get reportProblemEmailSubject => 'ZigDash problem report';

  @override
  String get reportProblemEmailPrompt =>
      'What happened, and what did you expect?';

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
  String get scenesAllShutters => 'All shutters';

  @override
  String get sceneCloseAllShutters => 'Close all shutters';

  @override
  String get sceneOpenAllShutters => 'Open all shutters';

  @override
  String get sceneStopAllShutters => 'Stop all shutters';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shutters',
      one: '1 shutter',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Which shutters…';

  @override
  String get sceneWhichShuttersHint =>
      'Every shutter in this Home is included. Untick any that should stay out, like a garage door.';

  @override
  String get scenesYours => 'Your scenes';

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
      'The broker didn\'t accept the connection. Check that your MQTT broker (usually Mosquitto) is running and accepts connections from other devices, and that the address and port (usually 1883) are right.';

  @override
  String get diagTcpTimeout =>
      'Connecting to the broker timed out. It may be offline or unreachable.';

  @override
  String get diagConnackFail =>
      'The broker didn\'t complete the MQTT handshake. Make sure this is an MQTT broker (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'The broker didn\'t answer the login in time. Home Assistant can take a few seconds to check it, so try again.';

  @override
  String get diagAuthRejected =>
      'The broker rejected the username or password. Check your credentials.';

  @override
  String get diagAuthRefused =>
      'The broker refused the connection. Check the connection settings.';

  @override
  String get diagResolveLocalName =>
      'Your phone couldn\'t find this name. Android often can\'t look up names ending in .local, so enter the IP address instead (Home Assistant shows it under Settings › System › Network).';

  @override
  String get diagTcpHaNoBroker =>
      'This is your Home Assistant, but no MQTT broker is running on it. Install and start the Mosquitto broker add-on (Settings › Add-ons), then try again.';

  @override
  String get diagTcpSmlightClosed =>
      'This is your SMLIGHT hub, but its MQTT broker doesn\'t accept connections from other devices. In the hub\'s web page, open Settings › MQTT, turn on Allow External, save, then try again.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Zigbee2MQTT runs at this address, but it reaches its broker under another name (see Zigbee2MQTT\'s Settings › MQTT › Server). If that is another machine, type its address, usually with port 1883. If it is a container on this machine, publish its port (ports: \"1883:1883\") and let it listen to the network, then try again.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Zigbee2MQTT runs at this address, but its MQTT broker doesn\'t accept connections from other devices. Mosquitto listens only on its own machine until you add the lines \"listener 1883\" and \"allow_anonymous true\" to mosquitto.conf (or set up a password). Restart Mosquitto, then try again.';

  @override
  String get diagAuthRejectedHa =>
      'Home Assistant\'s broker refused this login. Use the name and password of a Home Assistant user (Settings › People › Users); a separate user just for MQTT works best.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count devices',
      one: 'Found 1 device',
    );
    return '$_temp0';
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
  String get guidedStuckTitle => 'Stuck? Ask a person';

  @override
  String get guidedStuckBody =>
      'Two tries without a connection. Tell us which hub you have and what you typed, and we\'ll help you find it.';

  @override
  String get guidedStuckTelegram => 'Ask in Telegram';

  @override
  String get guidedStuckHelp => 'Tips and email';

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
  String get setupWelcomeHeadline => 'Your Zigbee home, on your phone';

  @override
  String get setupWelcomeBody =>
      'A small hub running Zigbee2MQTT is all you need: an SMLIGHT hub, a Raspberry Pi or any Linux box. No Home Assistant needed, and if you have it, ZigDash works with it too. Everything stays local, with no cloud.';

  @override
  String get setupFindMySetup => 'Find my setup';

  @override
  String get setupErrPageTitle => 'Zigbee2MQTT\'s page didn\'t answer';

  @override
  String get setupErrPageBody =>
      'Nothing answered as a Zigbee2MQTT page at that address. Open it in this phone\'s browser to check it, and copy the address exactly (with its port, often 8080). If the page asks for a token, enter your broker details instead.';

  @override
  String get setupErrPageAction => 'Try again';

  @override
  String get setupLookWider => 'Look on the whole network';

  @override
  String get setupAsk => 'What runs your Zigbee?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'On a Raspberry Pi, a server or Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'With the Zigbee2MQTT add-on, or ZHA';

  @override
  String get setupAskSmlight => 'An SMLIGHT hub';

  @override
  String get setupAskSmlightSub => 'SLZB or SMHUB running Zigbee2MQTT';

  @override
  String get setupAskNothing => 'Nothing yet?';

  @override
  String get setupAskHaWhich => 'How does your Home Assistant run Zigbee?';

  @override
  String get setupAskHaZ2m => 'The Zigbee2MQTT add-on';

  @override
  String get setupAskHaZ2mSub => 'Sign in with Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, Home Assistant\'s own Zigbee';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, no Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Connect to my Zigbee2MQTT page';

  @override
  String get setupManualEntryAdvanced => 'Enter broker details (advanced)';

  @override
  String get z2mPageTitle => 'Your Zigbee2MQTT page';

  @override
  String get z2mPageBody =>
      'The address in your browser when the Zigbee2MQTT page is open, the one you pair devices on. No MQTT username or password needed.';

  @override
  String get z2mPageLabel => 'Page address';

  @override
  String get z2mPageConnect => 'Connect';

  @override
  String z2mPageFoundName(String host, String ip) {
    return 'Found $host at $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Nothing answered for $host on this network';
  }

  @override
  String get engineNeedsBrokerTitle => 'Automations need your MQTT broker';

  @override
  String get engineNeedsBrokerBody =>
      'This home connects through the Zigbee2MQTT page, which is all your dashboards need. Automations, Alerts and history run in the ZigDash Engine on your hub, which talks through your MQTT broker. Add its details once, and ZigDash connects through the broker from then on.';

  @override
  String get engineNeedsBrokerButton => 'Add broker details';

  @override
  String get connFromPageNote =>
      'This home connects through the Zigbee2MQTT page. Enter your MQTT broker (usually the same machine, port 1883) to turn on Automations, Alerts and history. After saving, ZigDash connects through the broker.';

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
  String get reminderButton => 'Remind me tomorrow';

  @override
  String get reminderSet => 'We\'ll remind you tomorrow, on this phone.';

  @override
  String get reminderNoPermission =>
      'Notifications are off for ZigDash, so there\'s no reminder. You can turn them on in Android\'s settings.';

  @override
  String get reminderChannel => 'Setup reminder';

  @override
  String get reminderTitle => 'Finish setting up ZigDash';

  @override
  String get reminderBody =>
      'At home on your Wi-Fi? Tap to try again: it takes about a minute.';

  @override
  String get setupWelcomeNoZ2m => 'No Zigbee2MQTT yet?';

  @override
  String get setupWelcomeDemo => 'Try the demo home';

  @override
  String get setupWelcomeHubs => 'Which hub to get';

  @override
  String get haConnectTitle => 'Connect through Home Assistant';

  @override
  String get haConnectIntro =>
      'Your phone can\'t reach the broker, but it can reach Home Assistant. Sign in once, and ZigDash talks to Zigbee2MQTT through Home Assistant: at home or away, with no broker settings.';

  @override
  String get haConnectAddressHelp =>
      'The address you open Home Assistant with: 192.168.1.20:8123, or a remote address like your Nabu Casa or Cloudflare address';

  @override
  String get haConnectSignInHelp =>
      'Home Assistant\'s own login opens in your browser. ZigDash never sees your password.';

  @override
  String get haConnectKeeps =>
      'ZigDash keeps this sign-in on your phone and acts as you in Home Assistant, for MQTT only. End it any time in Home Assistant under Profile › Security.';

  @override
  String get haConnectTokenHelp =>
      'In Home Assistant, open your profile, then Security › Long-lived access tokens › Create token. Copy it and paste it here. ZigDash keeps it on this phone to connect; delete it in Home Assistant whenever you want to end that.';

  @override
  String get haConnectWithToken => 'Connect with token';

  @override
  String get haConnectChecking => 'Checking Home Assistant…';

  @override
  String get setupStillChecking =>
      'Still checking. This can take up to 30 seconds.';

  @override
  String get aiHelpTitle => 'Stuck? Ask your AI assistant';

  @override
  String get aiHelpBody =>
      'ZigDash writes up what it found for ChatGPT, Claude, Gemini or any AI app, without passwords or addresses. You see it before it\'s shared.';

  @override
  String get aiHelpButton => 'Ask an AI';

  @override
  String get aiHelpPreviewTitle => 'What will be shared';

  @override
  String get aiHelpShare => 'Share to an AI app';

  @override
  String get aiHelpCopied => 'Copied. Paste it into any AI chat.';

  @override
  String get haConnectWhereAddress =>
      'Not sure what it is? In the Home Assistant app, open Settings › Companion app and tap your server: its address is there. On a computer, it\'s what the browser shows when Home Assistant is open.';

  @override
  String get haFindLooking => 'Looking for Home Assistant on this network…';

  @override
  String get haFindSeveral =>
      'Found more than one Home Assistant. Tap the one to use:';

  @override
  String get haFindNone =>
      'This phone can\'t see Home Assistant on this Wi-Fi. Use the address your Home Assistant app opens: often a remote one, like https://abcd1234.ui.nabu.casa or https://myhome.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'That address is on a different network from this phone, which is on $network. Use the address your Home Assistant app opens, often a remote one, or connect the phone to the network Home Assistant is on.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'This phone couldn\'t find that name: Android often can\'t open .local names. Type Home Assistant\'s IP address (like 192.168.1.20:8123), or its remote address.';

  @override
  String get haConnectRemoteUnreachable =>
      'Nothing answered at that remote address. Open it in this phone\'s browser to check that it works, and copy it exactly as your Home Assistant app shows it.';

  @override
  String get setupNoWifiHa => 'Use Home Assistant? Sign in';

  @override
  String get haConnectNotAdmin =>
      'Your Home Assistant user isn\'t an administrator. ZigDash needs one for Home Assistant\'s MQTT. Sign in as an administrator, or paste a token an administrator created.';

  @override
  String get haConnectNoMqtt =>
      'This Home Assistant has no MQTT integration. Zigbee2MQTT needs one too: in Home Assistant, add the Mosquitto broker add-on and the MQTT integration, then try again.';

  @override
  String get haConnectSignInFailed =>
      'The sign-in didn\'t complete. Try again, or use a long-lived token.';

  @override
  String get setupHaShortcut =>
      'Zigbee2MQTT runs in Home Assistant? Skip the broker and its login: sign in with your Home Assistant admin account. It works from any network.';

  @override
  String get haConnectButton => 'Connect through Home Assistant';

  @override
  String get haConnectManualLink =>
      'Using Home Assistant? Connect through it instead';

  @override
  String get haConnectEmptyNote =>
      'Can\'t reach the broker from this phone? Home Assistant can carry the connection for you.';

  @override
  String get haHomeConnected => 'Connected through Home Assistant';

  @override
  String get haHomeChange =>
      'If the sign-in stops working, on a new phone or after you removed the token in Home Assistant, sign in again here. You can also end it in Home Assistant under Profile › Security.';

  @override
  String get haHomeSignInAgain => 'Sign in again';

  @override
  String get haHomeRemote => 'Remote Home Assistant address (optional)';

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
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT already logs in to this broker: its web page shows the username under Settings › MQTT. Use that user and its password.';

  @override
  String get setupAuthWhich =>
      'This is the MQTT login, not the password of your hub\'s web page.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: use a Home Assistant user. Most people create one just for MQTT under Settings › People › Users, and the Mosquitto add-on accepts it.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi or Docker: the user and password from Mosquitto\'s password file, the same ones in Zigbee2MQTT\'s configuration.yaml under mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: the login shown on the hub\'s web page under Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'Checking the connection…';

  @override
  String get setupReviewTitle => 'Your devices';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices found.',
      one: '1 device found.',
    );
    return '$_temp0 Choose what goes on your first dashboard.';
  }

  @override
  String get setupReviewLastStep =>
      'Last step: tick the devices you want, then tap Create dashboard below.';

  @override
  String get setupLeaveTitle => 'Create your dashboard?';

  @override
  String get setupLeaveBody =>
      'Your devices are found. Create the dashboard now, or start setup over and lose this list.';

  @override
  String get setupStartOver => 'Start over';

  @override
  String setupCreateWithCount(Object count) {
    return 'Create dashboard with $count';
  }

  @override
  String get setupReviewNoneSelected =>
      'Nothing is ticked yet. Tick the devices you want on the dashboard, or create it empty and add tiles later.';

  @override
  String get setupCreateEmpty => 'Create an empty dashboard';

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
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT didn\'t send its device list';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT answers, but its device list didn\'t come. This usually happens after the MQTT broker restarts: Zigbee2MQTT before 2.14.2 only sends the list again when it restarts. Restart Zigbee2MQTT (or update it), then try again.';

  @override
  String get setupErrListMissingAction => 'Try again';

  @override
  String get setupErrHaNoZ2mTitle => 'No Zigbee2MQTT in this Home Assistant';

  @override
  String get setupErrHaNoZ2mBody =>
      'You\'re signed in to Home Assistant, but Zigbee2MQTT isn\'t sending anything on its MQTT. If your Zigbee devices are in ZHA (Home Assistant\'s built-in Zigbee), ZigDash can\'t see them: it works with Zigbee2MQTT. If you use the Zigbee2MQTT add-on, open it in Home Assistant, check that it\'s started, then try again.';

  @override
  String get setupErrHaNoZ2mAction => 'Try again';

  @override
  String get setupErrScanFailedTitle => 'No local network';

  @override
  String get setupErrScanFailedBody =>
      'Couldn\'t determine this device\'s local network. Connect to Wi-Fi and try again.';

  @override
  String get setupErrScanFailedAction => 'Try again';

  @override
  String get setupNoWifiTitle => 'Your phone isn\'t on Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'It\'s using mobile data, so it can\'t see the devices at home. Turn on Wi-Fi and join your home network: setup starts again by itself.';

  @override
  String get setupNoWifiOffline =>
      'Your phone has no network connection. Turn on Wi-Fi and join your home network: setup starts again by itself.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash can\'t find your phone\'s Wi-Fi address. Check that Wi-Fi is on and joined to your home network: setup starts again by itself. On a VPN or away from home? Enter the details manually.';

  @override
  String get setupOpenWifiSettings => 'Open Wi-Fi settings';

  @override
  String get setupWaitingForWifi => 'Waiting for Wi-Fi…';

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
  String get setupErrLoginNoAnswerTitle =>
      'The broker didn\'t answer the login';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Your broker was found, but it didn\'t answer the username and password in time. Home Assistant\'s Mosquitto add-on checks logins with Home Assistant, which can take a few seconds on a Raspberry Pi. Try again, and check that this user exists in Home Assistant.';

  @override
  String get setupErrLoginNoAnswerAction => 'Try again';

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
  String get setupPlatformQuestion =>
      'While we look: where does Zigbee2MQTT run?';

  @override
  String get setupPlatformQuestionDone => 'Where does Zigbee2MQTT run?';

  @override
  String get setupScanDoneTitle => 'Choose a connection';

  @override
  String get setupScanDoneHint =>
      'More than one broker answered. Pick the one Zigbee2MQTT uses.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'SMLIGHT hub';

  @override
  String get setupPlatformPi => 'Raspberry Pi or Docker';

  @override
  String get setupPlatformZha => 'ZHA, no Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash shows devices from Zigbee2MQTT, so it can\'t see devices in ZHA, Home Assistant\'s own Zigbee. You can try the demo home to see how ZigDash works.';

  @override
  String get setupPlatformNotSure => 'Not sure';

  @override
  String setupScanProgress(int checked, int total) {
    return 'Checked $checked of $total addresses';
  }

  @override
  String get setupScanHintHa =>
      'Looking for Home Assistant and its MQTT broker…';

  @override
  String get setupScanHintSmlight => 'Looking for your SMLIGHT hub…';

  @override
  String get setupScanHintPi => 'Looking for an MQTT broker on your network…';

  @override
  String setupHubSeenHa(String host) {
    return 'Found Home Assistant at $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Found Zigbee2MQTT at $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Found your SMLIGHT hub at $host';
  }

  @override
  String get setupHubSeenHint => 'Still looking for its MQTT broker…';

  @override
  String get setupNoBrokerHaTitle => 'Found Home Assistant, but no MQTT broker';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant is at $host, but nothing answers on MQTT port 1883. In Home Assistant, open Settings › Add-ons, install and start the Mosquitto broker add-on, then try again.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Using Home Assistant\'s own Zigbee (ZHA) instead of Zigbee2MQTT? ZigDash works only with Zigbee2MQTT, so it can\'t see ZHA devices. The demo shows what you\'d get.';

  @override
  String get setupVpnHint =>
      'A VPN is on, and it can hide your home network from the scan. If you\'re at home, turn the VPN off and tap Try again.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Found Zigbee2MQTT, but its broker can\'t be reached';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT is at $host, but its MQTT broker doesn\'t accept connections from your phone. Mosquitto 2 only listens on the hub itself until its config has \'listener 1883\' and \'allow_anonymous true\' (or a login). Restart it, then try again.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Found your SMLIGHT hub, but MQTT is off';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Your hub is at $host, but its MQTT broker can\'t be reached. In the hub\'s web UI, open Settings › MQTT, turn on Allow External and check that Zigbee2MQTT is running, then try again.';
  }

  @override
  String get setupZ2mAsking => 'Asking Zigbee2MQTT where its broker is…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Your broker only accepts connections from its own machine';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT uses $server, and nothing answers there from your phone. Mosquitto 2 does this by default. Add these two lines to mosquitto.conf, restart Mosquitto, then try again:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Prefer a login over open access? Use a password_file instead of allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT reaches its broker by a name your phone can\'t use';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT uses $server. \"$name\" is a name only Zigbee2MQTT\'s machine knows, a Docker service or a hostname. Type the broker machine\'s IP address with port $port instead. If the broker runs in a container, its port must also be published on the machine (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'Zigbee2MQTT\'s web page is protected by a token, so the app couldn\'t read where its broker is. Type the broker address from Zigbee2MQTT\'s Settings › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT uses the broker at $server, but it didn\'t answer from your phone. Check that the broker is running and that your phone is on the same network.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Connect to $host';
  }

  @override
  String get setupNotFoundHa =>
      'No Home Assistant found on this network. Check that your phone is on the same Wi-Fi as Home Assistant (not a guest network), then try again. If you know its address, enter it below.';

  @override
  String get setupNotFoundSmlight =>
      'No SMLIGHT hub found on this network. Check that the hub is on and your phone is on the same Wi-Fi, then try again. If you know its address, enter it below.';

  @override
  String get setupNotFoundPi =>
      'No MQTT broker found on this network. Check that Mosquitto is running and listening on the network (port 1883), and that your phone is on the same Wi-Fi, then try again.';

  @override
  String get setupAddressQuestionHa => 'Where do you open Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      'What is your SMLIGHT hub\'s address?';

  @override
  String get setupAddressQuestionPi =>
      'What is the address of the machine running Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      'What is the address of your hub, or of the machine running Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'An address like 192.168.1.20, a name, or the link from your browser';

  @override
  String get setupAddressCheck => 'Check this address';

  @override
  String setupAddressNothing(String host) {
    return 'Nothing answered at $host. Check the address, and that your phone is on the same Wi-Fi as it.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return '$host could not be looked up. Names ending in .local often fail on Android; try the IP address instead. Home Assistant shows it under Settings › System › Network.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host can\'t be found from this phone; Android often can\'t look up .local names. Tap $button above and use the address you open Home Assistant with in your browser, or type its IP address here. Home Assistant shows it under Settings › System › Network.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host is not on your home network. Use the address that works on your Wi-Fi, not a remote link such as Nabu Casa or DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Enter an address first.';

  @override
  String get setupChoicesTitle => 'Which of these fits you?';

  @override
  String get setupChoiceNoHub => 'I don\'t have a hub yet';

  @override
  String get setupChoiceNoHubSub => 'See the small hubs that run Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'I use Home Assistant';

  @override
  String get setupChoiceHaSub => 'Look for it at homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash connects to Home Assistant\'s MQTT broker, the Mosquitto broker add-on under Settings › Add-ons, and Zigbee2MQTT has to use it too. If homeassistant.local isn\'t found, enter Home Assistant\'s IP address below. It\'s under Settings › System › Network.';

  @override
  String get setupChoiceOther => 'My hub is on another network';

  @override
  String get setupChoiceOtherSub => 'A guest Wi-Fi or a second router';

  @override
  String get setupChoiceOtherNote =>
      'Your phone has to reach your hub. A guest Wi-Fi, or a second router with its own Wi-Fi, keeps them apart. Join the Wi-Fi your hub is on and tap Try again. Or enter the hub\'s IP address below, or try one of these usual names:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Your phone is $ip, so the hub usually starts with $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Using Home Assistant? The host is the address you open Home Assistant with, port 1883.';

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
  String get readingShowAs => 'Show as';

  @override
  String get readingStyleValue => 'Value';

  @override
  String get readingStyleGauge => 'Gauge';

  @override
  String get gaugeBands => 'Color bands';

  @override
  String get gaugeBandsHelper =>
      'Up to three. The band the value is in colors the arc.';

  @override
  String get gaugeBandFrom => 'From';

  @override
  String get gaugeBandTo => 'To';

  @override
  String get gaugeBandAdd => 'Add band';

  @override
  String get gaugeBandRemove => 'Remove band';

  @override
  String get gaugeToneNormal => 'Normal';

  @override
  String get gaugeToneGood => 'Good';

  @override
  String get gaugeToneAttention => 'Attention';

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
      'Anonymous usage data. Turn it off with the switch above.';

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

  @override
  String get getHelpTitle => 'Get help';

  @override
  String get getHelpTryFirst => 'Try these first';

  @override
  String get getHelpPromise =>
      'Still stuck? I usually reply within 3 days, in English or Hebrew. I\'ll never ask for your passwords.';

  @override
  String get getHelpIncluded => 'What\'s included';

  @override
  String get getHelpContact => 'Contact support';

  @override
  String get getHelpCopy => 'Copy details';

  @override
  String get getHelpCopied => 'Details copied';

  @override
  String get getHelpLink => 'Still stuck? Get help';

  @override
  String get getHelpEmailSubject => 'ZigDash: help getting it working';

  @override
  String get getHelpEmailPrompt =>
      'What were you trying to do, and what happened?';

  @override
  String get settingsHelpSupport => 'Help & support';

  @override
  String get settingsGetHelp => 'Get help';

  @override
  String get settingsGetHelpSubtitle =>
      'Can\'t get it working? Tips first, then contact';

  @override
  String get settingsCommunity => 'Join the ZigDash community';

  @override
  String get settingsCommunitySubtitle =>
      'Telegram group: questions, ideas and what\'s coming';

  @override
  String get getHelpCommunity => 'Ask in the Telegram group';

  @override
  String get demoBannerHelp => 'Get help';

  @override
  String get tipSameWifiTitle => 'Same Wi-Fi as your hub';

  @override
  String get tipSameWifiBody =>
      'Your phone must be on the same network as the hub, not a guest network. Turn mobile data off while you set up.';

  @override
  String get tipBrokerRunningTitle => 'The broker is running';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: the Mosquitto add-on is started. Raspberry Pi: Mosquitto is running. SMLIGHT: Settings › MQTT is on.';

  @override
  String get tipBrokerAcceptsTitle => 'The broker accepts your phone';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: turn on Allow External. Mosquitto 2 only accepts connections from the hub itself until it\'s set to listen on the network (port 1883).';

  @override
  String get tipMeshTitle => 'Mesh Wi-Fi or two routers?';

  @override
  String get tipMeshBody =>
      'If the hub hangs off a second router, your phone may not see it. Plug the hub into the main router, or connect by its address.';

  @override
  String get tipByAddressTitle => 'Connect by address';

  @override
  String get tipByAddressBody =>
      'Find the hub\'s address in your router\'s app, then tap Enter details manually.';

  @override
  String get tipSameNetworkTitle => 'Same network';

  @override
  String get tipSameNetworkBody =>
      'Phone and hub must be on the same Wi-Fi. Turn mobile data off.';

  @override
  String get tipAddressChangedTitle => 'The address changed';

  @override
  String get tipAddressChangedBody =>
      'Hubs can get a new address after a restart. Check it in your router\'s app, and reserve it there so it stays the same.';

  @override
  String get tipRightPortTitle => 'The right port';

  @override
  String get tipRightPortBody =>
      'MQTT is usually 1883 (8883 with TLS). 8080 or 80 is the hub\'s web page, not MQTT.';

  @override
  String get tipStartBrokerTitle => 'The broker is running';

  @override
  String get tipStartBrokerBody =>
      'Start Mosquitto or the broker add-on, then try again.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 only accepts connections from the hub itself until it\'s set to listen on the network (port 1883).';

  @override
  String get tipMqttLoginTitle => 'The MQTT login, not the web login';

  @override
  String get tipMqttLoginBody =>
      'Your hub\'s web page password is usually not the MQTT one. Home Assistant: use a Home Assistant user, or the login set in the Mosquitto add-on.';

  @override
  String get tipSpacesTitle => 'Check for spaces';

  @override
  String get tipSpacesBody => 'Copying a password can add a space at the end.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT uses this broker';

  @override
  String get tipZ2mBrokerBody =>
      'In Zigbee2MQTT\'s settings, check that its MQTT server is this same broker.';

  @override
  String get tipBaseTopicTitle => 'Base topic';

  @override
  String get tipBaseTopicBody =>
      'If you changed the base topic from \"zigbee2mqtt\", enter it in manual setup.';

  @override
  String get tipPairFirstTitle => 'Pair devices first';

  @override
  String get tipPairFirstBody =>
      'Open Zigbee2MQTT\'s web page and pair at least one device, then check again.';

  @override
  String get tipRestartZ2mTitle => 'Restart Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'If devices are paired but none arrive, restart Zigbee2MQTT so it publishes its device list.';

  @override
  String get tipNumberAddressTitle => 'Use the number address';

  @override
  String get tipNumberAddressBody =>
      'Names ending in .local don\'t work on every Android phone. Try the hub\'s number address, like 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Port and protocol';

  @override
  String get tipPortProtocolBody =>
      'TCP on 1883 is the usual. Pick TLS or WebSocket only if your broker is set up for it.';

  @override
  String get tipManualLoginTitle => 'Login';

  @override
  String get tipManualLoginBody =>
      'Leave username and password empty if your broker has none. Otherwise use the MQTT login, not the hub\'s web login.';

  @override
  String get tipHubOnTitle => 'Is the hub on?';

  @override
  String get tipHubOnBody =>
      'A power cut or update may have restarted it. Give it a minute after it comes back.';

  @override
  String get tipAwayTitle => 'Are you at home?';

  @override
  String get tipAwayBody =>
      'Away from home, the app needs a remote address (for example Tailscale). Set it in the home\'s connection settings.';

  @override
  String get tipTailscaleIpTitle => 'Use the Tailscale IP, not the name';

  @override
  String get tipTailscaleIpBody =>
      'Names ending in .ts.net often don\'t resolve inside apps. Open the Tailscale app on the phone and make sure it\'s connected, then use the hub\'s 100.x.y.z address as the Remote host.';

  @override
  String get tipHomeAddressChangedTitle => 'Did the address change?';

  @override
  String get tipHomeAddressChangedBody =>
      'After a router restart the hub may get a new address. Reserve its address in your router\'s app, then update the home.';

  @override
  String get tipRestartZ2mButtonTitle => 'Restart Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'If the broker restarted, Zigbee2MQTT\'s device list is gone until Zigbee2MQTT restarts. Use the Restart Zigbee2MQTT button on the Devices tab.';

  @override
  String get tipZ2mRunningTitle => 'Is Zigbee2MQTT running?';

  @override
  String get tipZ2mRunningBody =>
      'Open its web page. If it doesn\'t load, restart it on your hub.';

  @override
  String get tipCantConnectTitle => 'Can\'t connect to my hub';

  @override
  String get tipCantConnectBody =>
      'Same Wi-Fi, broker running, Allow External or Mosquitto listening on the network, then connect by address.';

  @override
  String get tipDeviceWrongTitle => 'A device shows wrong or doesn\'t respond';

  @override
  String get tipDeviceWrongBody =>
      'Check it in Zigbee2MQTT\'s web page first. If it works there, use Report a problem.';

  @override
  String get tipHowDoITitle => 'How do I…';

  @override
  String get tipHowDoIBody =>
      'Scenes, Wall display, schedules and backups are in Help & Guide.';

  @override
  String get tipRenameHomeTitle => 'Rename a home';

  @override
  String get tipRenameHomeBody =>
      'A home named after its address? Settings › Homes, tap the home, then tap Name.';

  @override
  String get tipWhatYouNeedTitle => 'What you need';

  @override
  String get tipWhatYouNeedBody =>
      'A small hub running Zigbee2MQTT and an MQTT broker (Mosquitto): an SMLIGHT hub, a Raspberry Pi or any Linux box. Home Assistant works too, but you don\'t need it.';

  @override
  String get tipSetupAtHomeTitle => 'On the same Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Set up at home, with your phone on the same Wi-Fi as the hub.';

  @override
  String get tipFindSetupTitle => 'Then';

  @override
  String get tipFindSetupBody =>
      'Leave the demo and tap Find my setup. ZigDash looks for your hub on its own.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'No email app found. Copy the details and write to $email.';
  }

  @override
  String get shortcutWorking => 'working…';

  @override
  String get shortcutCantReach => 'Can\'t reach home';

  @override
  String get shortcutNotConfirmed => 'Not confirmed';

  @override
  String get shortcutRemoved => 'Removed';

  @override
  String get shortcutSceneSent => 'Sent';

  @override
  String get shortcutSceneConfirmed => 'Confirmed';

  @override
  String get shortcutChooseDevice => 'Choose a device';

  @override
  String get shortcutChooseScene => 'Choose a scene';

  @override
  String get shortcutOpenAppFirstScene =>
      'Open ZigDash and create a scene first.';

  @override
  String get shortcutChooseGroup => 'Choose a group';

  @override
  String get shortcutPickDevices => 'Pick devices…';

  @override
  String get shortcutGroupName => 'Group name';

  @override
  String get shortcutGroupLimit => 'Up to 5 devices and 3 scenes';

  @override
  String get shortcutAddTile => 'Add to Quick Settings';

  @override
  String get shortcutAddShortcut => 'Add shortcut';

  @override
  String get shortcutAddToHome => 'Add to home screen';

  @override
  String get shortcutWidgetHowToTitle => 'Add the widget';

  @override
  String get shortcutWidgetHowTo =>
      'Long-press an empty spot on your home screen, tap Widgets, find ZigDash and drag the widget you want.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name is on Quick Settings tile ZigDash $slot';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name is already on tile ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Add the tile';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Open Quick Settings (swipe down twice), tap the pencil to edit, and drag “ZigDash $slot” into your tiles.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Choose a device for ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'No devices to switch yet. Put a light, plug or shutter on a dashboard first.';

  @override
  String get shortcutSlotsFull =>
      'All 4 ZigDash tiles are in use. Which one should show this device instead?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Not used';

  @override
  String get deviceRename => 'Rename';

  @override
  String get deviceRenameTitle => 'Rename device';

  @override
  String get deviceRenameHint =>
      'A name for the room or the device, like Bedroom';

  @override
  String deviceRenamed(Object name) {
    return 'Renamed to $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Couldn\'t rename: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT didn\'t answer';

  @override
  String get shortcutOpenAppFirst =>
      'Open ZigDash and put a device on a dashboard first.';

  @override
  String get pollTitle => 'What should ZigDash do next?';

  @override
  String get pollBody =>
      'Pick the one you\'d use most. Your answer is sent with your anonymous usage data.';

  @override
  String get pollNotifications => 'Notifications';

  @override
  String get pollHistory => 'History graphs';

  @override
  String get pollKiosk => 'Kiosk mode for a wall tablet';

  @override
  String get pollGroups => 'Zigbee groups';

  @override
  String get pollNotNow => 'Not now';

  @override
  String get pollThanks => 'Thanks! That helps decide what comes next.';

  @override
  String get whyTitle => 'What made you try ZigDash?';

  @override
  String get whyBody =>
      'One tap helps decide what to build. Your answer is sent with your anonymous usage data.';

  @override
  String get whyFaster => 'Quicker than my other app';

  @override
  String get whyFamily => 'Easy for the family';

  @override
  String get whyWallTablet => 'A wall tablet';

  @override
  String get whyWithoutHa => 'Works without Home Assistant';

  @override
  String get whyOther => 'Something else';

  @override
  String get whyThanks => 'Thanks for telling us!';

  @override
  String get pollNoAnalytics =>
      'Usage data is off, so nothing is sent from here. Tell us with Request a feature instead.';

  @override
  String alertLeak(Object name) {
    return '💧 Leak — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name is dry again';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Smoke — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ No more smoke at $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name opened';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Battery low — $name, $value%';
  }

  @override
  String get alertTest => 'ZigDash test alert';

  @override
  String get alertsChannel => 'Alerts';

  @override
  String get alertsChannelDescription => 'Leaks and smoke';

  @override
  String get noticesChannel => 'Notices';

  @override
  String get noticesChannelDescription => 'Doors, windows and batteries';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsStatusOn => 'Alerts are on';

  @override
  String get alertsStatusPaused =>
      'Alerts are paused: ZigDash Engine on your hub isn\'t reporting';

  @override
  String get alertsStatusNotSetUp => 'Not set up';

  @override
  String get alertsStatusPhoneOff => 'This phone isn\'t getting notifications';

  @override
  String get alertsIntro =>
      'Get a notification on this phone when a leak, smoke, an opened door or a low battery is reported, even with ZigDash closed. ZigDash Engine on your hub watches the devices; ZigDash sets it up.';

  @override
  String get alertsSetUpHub => 'Set up alerts on the hub';

  @override
  String get alertsHubInstalled => 'Alerts are set up on your hub';

  @override
  String get alertsHubUpdated => 'The alerts flow on the hub is up to date';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED asks for a login, so import the flow by hand:';

  @override
  String get alertsHubManualSteps =>
      'Open Node-RED on the hub, choose Import, paste the copied flow, pick your broker in the broker node, and Deploy.';

  @override
  String get alertsCopyFlow => 'Copy the flow';

  @override
  String get alertsFlowCopied => 'Flow copied';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Alerts need Node-RED on the hub, and nothing answers on port 1880 at $host. On an SMLIGHT SMHUB, install it under Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT didn\'t accept ZigDash Engine';

  @override
  String get alertsRecent => 'Recent alerts';

  @override
  String get alertsRecentNone => 'Nothing yet';

  @override
  String get alertsYourAlerts => 'Your alerts';

  @override
  String get alertsAdd => 'Add alert';

  @override
  String get alertsNotificationsOnThisPhone => 'Notifications on this phone';

  @override
  String get alertsNoGoogle =>
      'This phone has no Google services, so ZigDash can\'t receive pushes here.';

  @override
  String get alertsSendTest => 'Send test notification';

  @override
  String get alertsTestSent => 'Test sent. It should arrive now.';

  @override
  String alertsTestFailed(Object status) {
    return 'The hub couldn\'t send it ($status)';
  }

  @override
  String get alertsTestTimedOut =>
      'No answer from the hub. Is the alerts flow running?';

  @override
  String get alertsNotConnected => 'Not connected to the hub';

  @override
  String get alertsTurnOff => 'Turn alerts off';

  @override
  String get alertsTurnOffBody => 'Alerts stop for every phone of this Home.';

  @override
  String get alertKindLeak => 'Leak';

  @override
  String get alertKindSmoke => 'Smoke';

  @override
  String get alertKindOpened => 'Door or window opened';

  @override
  String get alertKindBattery => 'Battery low';

  @override
  String get alertsEditTitle => 'Alert';

  @override
  String get alertsKind => 'What';

  @override
  String get alertsDevices => 'Devices';

  @override
  String get alertsNoDevicesForKind => 'No device of this Home reports that.';

  @override
  String get alertsHours => 'Only between';

  @override
  String get alertsHoursAny => 'Any time';

  @override
  String get alertsHoursFrom => 'From';

  @override
  String get alertsHoursTo => 'To';

  @override
  String get alertsThreshold => 'Battery below';

  @override
  String get alertsDelete => 'Delete alert';

  @override
  String get alertsNotifyMe => 'Notify me…';

  @override
  String get alertsWhatLeaves =>
      'Alerts to ZigDash are encrypted end to end: Google\'s push service carries them but can\'t read them. Nothing else leaves your hub.';

  @override
  String get alertsRestricted =>
      'Android may stop ZigDash in the background, so notifications could be late or missed. Allow it to run in the background in Android\'s settings (on Samsung: Battery › Never sleeping apps).';

  @override
  String get alertsOpenSettings => 'Open Android settings';

  @override
  String get alertsOff => 'Off';

  @override
  String get alertsSuggested => 'Suggested alerts';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '1 device',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Turn on';

  @override
  String get alertsShare => 'Share alerts';

  @override
  String get alertsShareBody =>
      'Anyone with this link gets this Home\'s alerts in the ntfy app, with no ZigDash needed. The alert text goes through ntfy.sh unencrypted.';

  @override
  String get alertsShareLink => 'Link';

  @override
  String get alertsShareNewLink => 'New link';

  @override
  String get alertsShareCopied => 'Link copied';

  @override
  String get alertsShareOff => 'Stop sharing';

  @override
  String get alertsGetWithNtfy => 'Get notifications with ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Smoke and leak alerts repeat until acknowledged. Needs a Pushover account (\$4.99 once after a trial); its keys are kept on your broker.';

  @override
  String get alertsPushoverUser => 'User key';

  @override
  String get alertsPushoverToken => 'App token';

  @override
  String get alertsHideNames => 'Hide device names';

  @override
  String get alertsNtfyServer => 'ntfy server';

  @override
  String get wallSheetTitle => 'Wall display';

  @override
  String get wallSheetSubtitle => 'For a tablet on the wall.';

  @override
  String get wallKeepOn => 'Keep the screen on and hide the bars';

  @override
  String get wallKeepOnSubtitle =>
      'They come back with a touch and hide again after 10 seconds.';

  @override
  String get wallFullscreen => 'Fullscreen';

  @override
  String get wallFullscreenSubtitle =>
      'Hides Android\'s status and navigation bars too.';

  @override
  String get wallDimAfter => 'Dim after';

  @override
  String get wallDimOff => 'Off';

  @override
  String get wallIdleTitle => 'When no one touches it';

  @override
  String get wallIdleAfter => 'After';

  @override
  String get wallIdleNever => 'Never';

  @override
  String get wallIdleShow => 'Show';

  @override
  String get wallIdleShowDim => 'Dimmed';

  @override
  String get wallIdleShowClock => 'Clock';

  @override
  String get wallIdleShowBlack => 'Black';

  @override
  String get wallIdleShowReadings => 'Readings';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'This dashboard has no readings yet. Add a reading or a sensor tile first.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Readings on the clock (up to $count)';
  }

  @override
  String get wallProNote =>
      'Readings on the clock, wake on motion, the night schedule and alarms are part of ZigDash Pro, a one-time purchase.';

  @override
  String get wallAlarmLeak => 'Water leak';

  @override
  String get wallAlarmSmoke => 'Smoke';

  @override
  String get wallAlarmGas => 'Gas';

  @override
  String get wallAlarmCo => 'Carbon monoxide';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Wake on motion';

  @override
  String get wallMotionSubtitle =>
      'A sensor that sees someone wakes the screen.';

  @override
  String get wallMotionNone =>
      'No motion, presence or door sensors in this Home.';

  @override
  String get wallAlarmsTitle => 'Alarms take over the screen';

  @override
  String get wallAlarmsSubtitle =>
      'Leak, smoke, gas or carbon monoxide fills the screen until someone taps OK. Only while ZigDash is open on this tablet; Alerts reach phones anywhere.';

  @override
  String get wallAlarmSound => 'Play a sound';

  @override
  String get wallNightTitle => 'Night';

  @override
  String get wallNightSubtitle =>
      'Black between these hours. Motion wakes it only dimly; alarms always fully.';

  @override
  String get wallNightFrom => 'From';

  @override
  String get wallNightTo => 'to';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Kiosk lock';

  @override
  String get kioskLockSubtitle =>
      'Only this Home\'s dashboards and their controls stay reachable. Long-press the title to leave.';

  @override
  String get kioskPin => 'PIN';

  @override
  String get kioskPinSet => 'Set';

  @override
  String get kioskPinNotSet => 'Not set';

  @override
  String get kioskPinChange => 'Change';

  @override
  String get kioskPinRemove => 'Remove';

  @override
  String get kioskPinSetTitle => 'Set a PIN';

  @override
  String get kioskPinEnterTitle => 'Enter the PIN';

  @override
  String get kioskPinHint => '4 digits';

  @override
  String get kioskPinConfirmHint => 'Again';

  @override
  String get kioskPinMismatch => 'The two PINs differ.';

  @override
  String get kioskPinWrong => 'Wrong PIN.';

  @override
  String get kioskPinForgot => 'Forgot the PIN?';

  @override
  String get kioskPinForgotBody =>
      'A forgotten PIN can only be reset by clearing ZigDash\'s data in Android\'s settings, which removes this Home unless you have a backup. Export one before setting a PIN.';

  @override
  String get kioskExportBackup => 'Export backup';

  @override
  String get kioskOsPin => 'Also pin ZigDash on Android';

  @override
  String get kioskOsPinSubtitle =>
      'Android blocks Home and recent apps until ZigDash is unpinned. A tablet without a lock screen unpins with a gesture, so this is not the lock.';

  @override
  String get kioskOn => 'Kiosk on. Long-press the title to leave.';

  @override
  String get kioskLeaveTitle => 'Leave kiosk?';

  @override
  String get kioskLeave => 'Leave';

  @override
  String get kioskStay => 'Stay';

  @override
  String get a11yKioskLeave => 'Long-press to leave kiosk';

  @override
  String get historyTitle => 'History';

  @override
  String get historyRangeDay => '24 hours';

  @override
  String get historyRangeWeek => '7 days';

  @override
  String get historyRangeMonth => '30 days';

  @override
  String get historySetupTitle => 'Record history on your hub';

  @override
  String get historySetupBody =>
      'ZigDash has no server, so ZigDash Engine on your hub records the numbers on your dashboards every 15 minutes. It keeps 30 days, on your own broker.';

  @override
  String get historySetupAction => 'Set up on the hub';

  @override
  String get historyInstalled =>
      'Recording. The first values appear within 15 minutes.';

  @override
  String historyNoNodeRed(String host) {
    return 'History needs Node-RED on the hub, and nothing answers on port 1880 at $host. On an SMLIGHT SMHUB, install it under Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Recording since $date';
  }

  @override
  String get historyEmpty =>
      'No values yet. The recorder saves every 15 minutes.';

  @override
  String get historyRecorderOffline =>
      'The recorder on the hub isn\'t answering, so recent values may be missing.';

  @override
  String get historyLocked =>
      'Longer history is part of ZigDash Pro, a one-time purchase.';

  @override
  String get historyUnlock => 'Unlock';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Unlimited automations, longer history and wall tablet extras. Supports the open-source project.';

  @override
  String get proUnlocked => 'Unlocked. Thank you for supporting ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash is free and open source, built by one person in their spare time. Pro is a one-time purchase that keeps it going.';

  @override
  String get proWhatYouGet => 'What you get';

  @override
  String get proGetHistory => 'History for 7 and 30 days, not just today';

  @override
  String get proGetWall =>
      'Wall tablet: readings on the clock, wake on motion, a night schedule and alarms';

  @override
  String get proGetFuture =>
      'Every Pro feature that comes later, at no extra cost';

  @override
  String get proFreeTitle => 'Free forever';

  @override
  String get proFreeBody =>
      'Setup, dashboards, every device control, widgets, Quick Settings tiles, alerts, three automations per home and the wall tablet itself stay free. Nothing you use today gets locked.';

  @override
  String get proBuy => 'Get Pro';

  @override
  String proBuyPrice(String price) {
    return 'Get Pro · $price';
  }

  @override
  String get proOnce =>
      'One payment, no subscription. Bought on another phone with the same Google account? It unlocks automatically.';

  @override
  String get historyNotRecorded =>
      'Only numbers shown on a dashboard are recorded. Add this one as a tile to start its history.';

  @override
  String get historyRecordHere => 'Record on this device';

  @override
  String get historyRecordHereHint =>
      'Can\'t use ZigDash Engine on your hub? ZigDash can record on a phone or tablet that stays open, like a wall tablet. Every phone of this Home sees the history.';

  @override
  String get historyRecordingHere =>
      'This device records history while ZigDash is open. The first values appear within 15 minutes.';

  @override
  String get wallRecordHistory => 'Record history on this device';

  @override
  String get wallRecordHistorySubtitle =>
      'Every 15 minutes while ZigDash is open, for every phone of this Home. Not needed when ZigDash Engine on your hub records.';

  @override
  String historyNeedsPassword(String host) {
    return 'One more step: your broker asks for a login. Open Node-RED at $host:1880, double-click \"ZigDash history broker\", type the MQTT password on its Security tab, then Deploy. ZigDash never sends your password to the hub.';
  }

  @override
  String get historyNotConnected =>
      'The recorder isn\'t reporting. Open Automations to check ZigDash Engine on your hub.';

  @override
  String get historyPersistence =>
      'History lives on your broker. If you run Mosquitto yourself, make sure its config has \"persistence true\", or history is lost when the broker restarts.';

  @override
  String get haImportTitle => 'Import from Home Assistant';

  @override
  String get haImportSettingsSubtitle =>
      'Names and rooms you set up in Home Assistant';

  @override
  String get haImportIntro =>
      'Bring the names and rooms you set up in Home Assistant. ZigDash reads them once and keeps nothing else from Home Assistant.';

  @override
  String get haImportAddress => 'Home Assistant address';

  @override
  String get haImportAddressHelp =>
      'The address you open Home Assistant with, like 192.168.1.20:8123';

  @override
  String get haImportToken => 'Long-lived access token';

  @override
  String get haImportTokenHelp =>
      'In Home Assistant, open your profile, then Security › Long-lived access tokens › Create token. Copy it and paste it here. ZigDash uses it once and doesn\'t keep it; you can delete it in Home Assistant afterwards.';

  @override
  String get haImportRead => 'Read from Home Assistant';

  @override
  String get haImportReading => 'Reading Home Assistant…';

  @override
  String get haImportApplying => 'Importing…';

  @override
  String get haImportNoAddress =>
      'Type the address you open Home Assistant with.';

  @override
  String get haImportNoToken => 'Paste a long-lived access token.';

  @override
  String get haImportUnreachable =>
      'Nothing answered at that address. Check it, and that your phone is on your home network.';

  @override
  String get haImportNotHa =>
      'Something answered at that address, but it isn\'t Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant refused that token. Create a new one and paste it again.';

  @override
  String get haImportCertificate =>
      'Your phone doesn\'t trust this Home Assistant\'s certificate. Try its http:// address on your home network.';

  @override
  String get haImportFailed =>
      'Home Assistant answered, but reading it failed. Try again.';

  @override
  String get haImportNoDevices =>
      'ZigDash can\'t see this home\'s devices right now. Connect to the home, then try again.';

  @override
  String get haImportAutomations =>
      'Your automations stay in Home Assistant and keep running.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices found in Home Assistant',
      one: '1 device found in Home Assistant',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'Tiles still named after their device take the name from Home Assistant. Dashboards you built stay as they are.';

  @override
  String get haImportMakeDashboards =>
      'Also add dashboards from your floors and rooms';

  @override
  String get haImportOtherRooms => 'Other rooms';

  @override
  String get haImportNoRoom => 'No room';

  @override
  String get haImportApply => 'Import';

  @override
  String get haImportBack => 'Back';

  @override
  String get haImportZhaOnly =>
      'These devices run on ZHA, Home Assistant\'s own Zigbee, not on Zigbee2MQTT, so ZigDash can\'t show them.';

  @override
  String get haImportNothing =>
      'None of this home\'s Zigbee2MQTT devices are in Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Done. Tiles renamed: $renamed. Dashboards added: $dashboards.';
  }

  @override
  String get haImportOpen => 'Open dashboards';

  @override
  String get haImportOfferTitle =>
      'Bring your names and rooms from Home Assistant?';

  @override
  String get haImportOfferBody =>
      'Home Assistant is on your network. ZigDash can name your tiles and add a dashboard per floor and room, the way you set them up there.';

  @override
  String get haImportOfferLater => 'Not now';

  @override
  String get haImportOfferGo => 'Import';

  @override
  String get haImportSignIn => 'Sign in with Home Assistant';

  @override
  String get haImportSignInHelp =>
      'Home Assistant\'s own login opens in your browser. ZigDash never sees your password and signs out again after reading.';

  @override
  String get haImportOrToken => 'Or use a long-lived token';

  @override
  String get haImportReadToken => 'Read with token';

  @override
  String get haImportSignInRefused =>
      'Home Assistant didn\'t accept the sign-in. This happens when Home Assistant has no internet access. Use a long-lived token below instead.';

  @override
  String get setupIsolatedHint =>
      'Your phone can see almost nothing else on this Wi-Fi. It may be on a guest network, or the router may keep devices apart (often called client or AP isolation). Join your main Wi-Fi, or turn that off, then try again.';

  @override
  String get setupAuthTrust =>
      'Your login stays on this phone and goes only to your own broker. ZigDash has no server and no account, and every MQTT app logs in this way. Safest: a separate MQTT user just for ZigDash, which you can remove any time.';

  @override
  String get setupAuthWhatKept => 'What ZigDash keeps';

  @override
  String get setupAuthDemoFirst => 'Try the demo first';

  @override
  String get automationsTitle => 'Automations';

  @override
  String get engineRunningOnHub => 'Running on hub';

  @override
  String get engineChecking => 'Checking your hub…';

  @override
  String get engineAwayNoHubTitle => 'Can\'t reach your hub right now';

  @override
  String get engineAwayNoHubBody =>
      'You\'re away, and your hub isn\'t connected to ZigDash\'s remote access, or its internet is down. Your automations keep running on the hub.';

  @override
  String get engineAwayReinstallAtHome =>
      'You can reinstall the Engine when you\'re at home.';

  @override
  String get engineNoConnection =>
      'ZigDash can\'t reach this Home\'s broker right now. Automations are set up while connected at home.';

  @override
  String get engineRestarting =>
      'Restarting Zigbee2MQTT… Your devices are back in about 30 seconds.';

  @override
  String get engineInstalling => 'Installing on your hub…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT needs an update';

  @override
  String engineTooOldBody(Object version) {
    return 'Your Zigbee2MQTT is version $version. Automations need 2.4 or newer. Update Zigbee2MQTT on your hub, then come back here.';
  }

  @override
  String get engineIntroTitle =>
      'Automations run on your hub, not on your phone';

  @override
  String get engineIntroBody =>
      'ZigDash puts ZigDash Engine inside Zigbee2MQTT on your hub. It watches your devices and runs your rules, so a light turns on when the door opens even with your phone off and the internet down.';

  @override
  String get engineIntroNothingByHand =>
      'Nothing to install by hand. ZigDash does it over your home network.';

  @override
  String engineIntroVersion(Object version) {
    return 'Your Zigbee2MQTT is version $version.';
  }

  @override
  String get engineIntroRemove =>
      'You can remove it any time from this screen.';

  @override
  String get engineInstall => 'Install on hub';

  @override
  String get engineDeclinedTitle => 'No automations on this hub';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT on your hub doesn\'t allow add-ons, so nothing can run your rules while your phone is away. Scenes, alerts and the dashboard work as before.';

  @override
  String get engineAllowAfterAll => 'Allow add-ons after all';

  @override
  String get engineConsentTitle => 'Zigbee2MQTT needs one setting changed';

  @override
  String get engineConsentBody =>
      'Your Zigbee2MQTT blocks add-ons like ZigDash Engine, as new installs do. To run automations on your hub, ZigDash would turn on \"Allow external JavaScript\" in Zigbee2MQTT and restart it.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT restarts once. Your lights and sensors can\'t be reached for about 30 seconds.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine is open source. You can read it on your Zigbee2MQTT page under Extensions.';

  @override
  String get engineConsentUndo =>
      'You can turn the setting off again later. Automations stop then.';

  @override
  String get engineConsentYes => 'Change the setting and restart';

  @override
  String get engineConsentNo => 'Not now';

  @override
  String get automationsPausedTitle => 'Automations paused';

  @override
  String get automationsPausedBody =>
      'Your hub hasn\'t reported in for over a minute, so no automation can run until it does. Your rules are kept.';

  @override
  String get engineReinstall => 'Reinstall on hub';

  @override
  String get engineStoppedTitle =>
      'Automations paused: ZigDash Engine stopped itself';

  @override
  String get engineStoppedBody =>
      'It ran into errors three times in an hour and switched off so Zigbee2MQTT keeps running. Your rules are kept.';

  @override
  String get engineStartAgain => 'Start again';

  @override
  String get engineReportProblem => 'Report a problem';

  @override
  String get engineRunningTitle => 'Your hub is ready for automations';

  @override
  String engineRunningBody(Object count) {
    return 'Rules loaded on the hub: $count. Creating automations comes in the next step of this release.';
  }

  @override
  String get engineClockOff =>
      'Your hub\'s clock is more than five minutes off. Time-based automations will run at the wrong time until it is fixed.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Rules ZigDash Engine on your hub can\'t run yet: $count. Update it by reinstalling.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT refused ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT didn\'t answer. Check that the Home is connected and try again.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT didn\'t accept the change or didn\'t come back. Check your hub and try again.';

  @override
  String get autoValMotion => 'motion';

  @override
  String get autoValNoMotion => 'no motion';

  @override
  String get autoValClosed => 'closed';

  @override
  String get autoValOpened => 'opened';

  @override
  String get autoValLeak => 'leak';

  @override
  String get autoValDry => 'dry';

  @override
  String get autoValSmoke => 'smoke';

  @override
  String get autoValNoSmoke => 'no smoke';

  @override
  String get autoValOn => 'on';

  @override
  String get autoValOff => 'off';

  @override
  String get autoValToggle => 'toggle';

  @override
  String get autoValOpen => 'open';

  @override
  String get autoValClose => 'close';

  @override
  String get autoValStop => 'stop';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'When $device: $property above $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'When $device: $property below $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'When $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'At $time';
  }

  @override
  String get autoSunrise => 'sunrise';

  @override
  String get autoSunset => 'sunset';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min after $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min before $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'At $sun';
  }

  @override
  String get autoEveryDay => 'every day';

  @override
  String get autoWeekdays => 'weekdays';

  @override
  String get autoWeekends => 'weekends';

  @override
  String autoBetween(Object from, Object to) {
    return 'between $from and $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device is $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Run “$scene”';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, off again after $minutes min';
  }

  @override
  String get autoErrPickTrigger => 'Pick a device and what it does.';

  @override
  String get autoErrValue => 'Type a number for the reading.';

  @override
  String get autoErrDays => 'Pick at least one day.';

  @override
  String get autoErrTown => 'Set your town for sunrise and sunset.';

  @override
  String get autoErrPickAction => 'Pick what should happen.';

  @override
  String get autoErrEmptyScene => 'That scene has nothing to send.';

  @override
  String get autoErrNotConnected =>
      'ZigDash isn\'t connected to this Home. Try again at home.';

  @override
  String get autoNewTitle => 'New automation';

  @override
  String get autoEditTitle => 'Edit automation';

  @override
  String get autoName => 'Name';

  @override
  String get autoNameHint => 'What this does (optional)';

  @override
  String get autoWhen => 'When';

  @override
  String get autoOnlyIf => 'Only if';

  @override
  String get autoThen => 'Then';

  @override
  String get autoEnabled => 'Enabled';

  @override
  String get autoDelete => 'Delete automation';

  @override
  String get autoSave => 'Save';

  @override
  String get autoDeviceChanges => 'A device changes';

  @override
  String get autoTimeComes => 'A time comes';

  @override
  String get autoDevice => 'Device';

  @override
  String get autoAbove => 'above';

  @override
  String get autoBelow => 'below';

  @override
  String get autoClockTime => 'Clock time';

  @override
  String get autoAt => 'At';

  @override
  String get autoShift => 'Shift in minutes (minus is before)';

  @override
  String get autoTownNone => 'No town set';

  @override
  String autoTownIs(Object town) {
    return 'Sun times for $town';
  }

  @override
  String get autoTownSet => 'Set town';

  @override
  String get autoTownChange => 'Change town';

  @override
  String get autoDays => 'Days';

  @override
  String get autoNoConditions => 'No conditions. It runs every time.';

  @override
  String get autoAddHours => 'Between hours';

  @override
  String get autoFrom => 'From';

  @override
  String get autoTo => 'To';

  @override
  String get autoAddDeviceCondition => 'A device is…';

  @override
  String get autoRunASceneOption => 'Run a scene';

  @override
  String get autoSetADevice => 'Set a device';

  @override
  String get autoScene => 'Scene';

  @override
  String get autoTurnOffAgain => 'Turn off again';

  @override
  String get autoStaysAsSet => 'Stays as set';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minutes after it ran';
  }

  @override
  String get autoTownSearch => 'Town';

  @override
  String get autoTownWhy =>
      'Used only for sunrise and sunset. Stored on your hub, never your location.';

  @override
  String get autoNewButton => 'New automation';

  @override
  String get autoEmptyBody =>
      'Nothing runs yet. Tap New automation to make the first one.';

  @override
  String autoOnlyIfList(Object list) {
    return 'only if $list';
  }

  @override
  String get autoEdit => 'Edit';

  @override
  String get autoNeverRan => 'never ran';

  @override
  String autoRanAt(Object time) {
    return 'ran $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count of $max free automations';
  }

  @override
  String get autoRecentRuns => 'Recent runs';

  @override
  String get autoDeleted => '(deleted)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count automations are free. Want more?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash is free and open source, built by one person. Pro is a one-time purchase: unlimited automations, history for 7 and 30 days and the wall tablet extras. Your automations keep running whatever you choose.';

  @override
  String get autoCeilingSeePro => 'See Pro';

  @override
  String get engineRemove => 'Remove from hub';

  @override
  String get engineRemoveTitle => 'Remove ZigDash Engine from your hub?';

  @override
  String get engineRemoveBody =>
      'Automations stop running. Your rules stay on the hub, so installing ZigDash Engine again brings them back.';

  @override
  String get autoNoTargets =>
      'This Home has no light, plug, switch or shutter to control yet.';

  @override
  String get proGetAutomations =>
      'Unlimited automations; three per home are free';

  @override
  String get proGetRemote =>
      'Remote control from anywhere, through the ZigDash relay, with no monthly fee';

  @override
  String get proRemoteFair =>
      'Remote access is included while the ZigDash relay runs, for one home, up to five phones and normal household use. It may change or end with notice.';

  @override
  String get autoDeleteConfirm =>
      'Delete this automation? It stops running on your hub.';

  @override
  String get statusConnectedRelay => 'Connected · Away via ZigDash';

  @override
  String get shareHomeTitle => 'Share with another phone';

  @override
  String get shareHomeSubtitle =>
      'Add this home to another phone with one QR code';

  @override
  String get shareHomeIntro =>
      'On the other phone, at home on the same Wi-Fi, scan the code with the camera. ZigDash adds this home with its login and your dashboards.';

  @override
  String get shareHomeLoginWarning =>
      'The code includes this home\'s broker login. It shows for 2 minutes; show it only to people you trust.';

  @override
  String get shareHomeShow => 'Show the code';

  @override
  String get shareHomeAtHome =>
      'Connect at home first: sharing works only on your home network.';

  @override
  String get shareHomeScanHint =>
      'Scan with the other phone\'s camera. The code hides in 2 minutes.';

  @override
  String get shareHomeHide => 'Hide the code';

  @override
  String get shareHomeViaHa =>
      'This home connects through Home Assistant. On the other phone, install ZigDash and sign in with Home Assistant.';

  @override
  String get joinHomeTitle => 'Add a shared home';

  @override
  String get joinHomeInvalid =>
      'This code isn\'t a ZigDash home invitation, or it\'s damaged.';

  @override
  String joinHomeAlready(String name) {
    return '$name is already on this phone.';
  }

  @override
  String get joinHomeOpen => 'Open it';

  @override
  String joinHomeAsk(String name) {
    return 'Add $name to this phone?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash adds the home with the same connection and login, and takes the dashboards from the other phone. Keep this phone on your home Wi-Fi.';

  @override
  String get joinHomeAdd => 'Add home';

  @override
  String get joinHomeNoDashboards =>
      'Home added. The dashboards didn\'t arrive; your devices are on the Devices tab.';

  @override
  String get remoteTitle => 'Remote control';

  @override
  String get remoteSettingsSubtitle =>
      'Control this home from anywhere, with Pro';

  @override
  String get remoteIntroTitle => 'Control your home from anywhere';

  @override
  String get remoteOfferBody =>
      'Reach your devices when you\'re away, through ZigDash\'s encrypted relay. Part of Pro: one payment, no monthly fee. Set it up while you\'re at home.';

  @override
  String get remoteOfferBodyPro =>
      'You have Pro: turn on remote control while you\'re at home, then reach your devices from anywhere.';

  @override
  String get remoteOfferShow => 'Show me';

  @override
  String get remoteIntroBody =>
      'Your hub keeps one connection to ZigDash\'s relay. Away from home, this phone reaches your devices through it. Everything is encrypted on your hub and your phone, so the relay can\'t read your devices or what they do.';

  @override
  String get remoteNeedsEngine =>
      'Remote control runs in ZigDash Engine. Install it under Automations first.';

  @override
  String get remoteSetUp => 'Turn on remote control';

  @override
  String get remoteNeedsPro => 'Remote control is part of Pro.';

  @override
  String get remoteNotAtHome =>
      'Turn this on at home, connected to your broker.';

  @override
  String get remoteUnreachable =>
      'ZigDash\'s relay didn\'t answer. Try again later.';

  @override
  String get remoteRefused =>
      'The relay refused. Try again, or report a problem.';

  @override
  String get remoteOnTitle => 'Remote control is on';

  @override
  String get remoteOnBody =>
      'Away from home, ZigDash connects through the relay by itself.';

  @override
  String get remoteHubOnline => 'Your hub is connected to the relay';

  @override
  String get remoteHubOffline => 'Your hub isn\'t connected to the relay';

  @override
  String get remoteTurnOff => 'Turn off remote control';

  @override
  String get remoteViaRelayNow =>
      'This phone is connected through the relay right now.';

  @override
  String get remotePhones => 'Phones with remote access';

  @override
  String get remoteThisPhone => 'This phone';

  @override
  String get remoteOtherPhone => 'Another phone';

  @override
  String remotePhoneAdded(Object date) {
    return 'Added $date';
  }

  @override
  String get remoteRemovePhone => 'Remove';

  @override
  String get remoteRemovePhoneConfirm =>
      'Remove this phone? It can no longer reach this home from away.';

  @override
  String get remoteAddPhone => 'Add a phone';

  @override
  String get remoteAddPhoneHint =>
      'At home, scan this with the other phone\'s camera. It opens ZigDash and adds remote control there. Show it only to your own phones.';

  @override
  String get remoteAddPhoneFailed =>
      'The relay didn\'t give a login for another phone. A home can have up to five.';

  @override
  String get remoteBackupSave => 'Save a key backup';

  @override
  String get remoteBackupRestore => 'Restore from a key backup';

  @override
  String get remoteBackupPassphrase => 'Backup passphrase';

  @override
  String get remoteBackupPassphraseHint =>
      'If you lose this phone, the backup and this passphrase bring remote control back on a new one. Use at least 8 characters, and keep the passphrase somewhere else than the file.';

  @override
  String get remoteBackupPassphraseAsk =>
      'The passphrase you chose when you saved the backup.';

  @override
  String get remoteBackupPassphraseAgain => 'Passphrase again';

  @override
  String get remoteBackupSaved => 'Key backup saved';

  @override
  String get remoteBackupWrong => 'That passphrase doesn\'t open this backup.';

  @override
  String get remoteBackupWrongFile => 'That isn\'t a ZigDash key backup.';

  @override
  String get remotePlayOnly =>
      'Remote control is in the Google Play version of ZigDash for now.';

  @override
  String get remotePairTitle => 'Add remote control';

  @override
  String get remotePairBody =>
      'Which home is this? ZigDash keeps the remote login for it.';

  @override
  String get remotePairNoHomes =>
      'Set this home up on this phone first, at home. Then scan the code again.';

  @override
  String get remotePairInvalid =>
      'This code isn\'t a ZigDash remote control code, or it was cut off.';

  @override
  String remotePairDone(Object home) {
    return 'Remote control is on for $home';
  }

  @override
  String get remoteReconnectHub => 'Reconnect the hub';

  @override
  String get remoteTurnOffConfirm =>
      'This phone leaves remote control and your hub disconnects from the relay. A key backup saved from this phone stops working; other phones keep their access until you remove them.';

  @override
  String remoteHomeId(Object id) {
    return 'Home ID $id';
  }

  @override
  String get alertsHintTitle => 'Get notified on this phone';

  @override
  String get alertsHintBody =>
      'A leak, smoke, an opened door or a low battery can send a notification to this phone, even with ZigDash closed.';

  @override
  String get alertsHintButton => 'Set up Alerts';

  @override
  String get alertsHintNotNow => 'Not now';

  @override
  String get guidedNoZ2mBody =>
      'An MQTT broker answers here, but Zigbee2MQTT isn\'t sending anything on it. Check that Zigbee2MQTT is started and uses this broker, and that the base topic matches its settings. If your Zigbee devices are in Home Assistant\'s ZHA, ZigDash can\'t see them: it works with Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT is on this broker with the base topic “$found”, but this Home looks for “$current”.';
  }

  @override
  String devicesUseBase(String found) {
    return 'Use “$found”';
  }

  @override
  String get devicesChangeConnection => 'Change connection';
}
