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
}
