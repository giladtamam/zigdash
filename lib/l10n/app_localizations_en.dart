// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZigDash';

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
  String get connectionsTitle => 'Connections';

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
  String get panelFormWidth => 'Width';

  @override
  String get panelFormWidthFull => 'Full';

  @override
  String get panelFormWidthHalf => 'Half';

  @override
  String get panelFormWidthThird => 'Third';

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
  String get panelTileEdit => 'Edit panel';

  @override
  String get panelTileDuplicate => 'Duplicate panel';

  @override
  String get panelTileMoveUp => 'Move up';

  @override
  String get panelTileMoveDown => 'Move down';

  @override
  String get panelTileWidth => 'Width';

  @override
  String get panelTileWidthFull => 'Full';

  @override
  String get panelTileWidthHalf => 'Half';

  @override
  String get panelTileWidthThird => '⅓';

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
  String get panelGridEmpty =>
      'No panels yet.\nTap + to add a Toggle, Slider, or Button.';

  @override
  String get panelsOffline => 'Offline — showing last values';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsHelp => 'Help & Guide';

  @override
  String get settingsVersion => 'Version';

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
}
