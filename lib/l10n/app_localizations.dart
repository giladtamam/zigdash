import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ZigDash'**
  String get appTitle;

  /// No description provided for @navBrokers.
  ///
  /// In en, this message translates to:
  /// **'Brokers'**
  String get navBrokers;

  /// No description provided for @navDashboards.
  ///
  /// In en, this message translates to:
  /// **'Dashboards'**
  String get navDashboards;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsDynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Use Material You colors'**
  String get settingsDynamicColor;

  /// No description provided for @settingsDynamicColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Android 12+; otherwise uses the app color'**
  String get settingsDynamicColorSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHebrew.
  ///
  /// In en, this message translates to:
  /// **'עברית'**
  String get languageHebrew;

  /// No description provided for @connectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connectionsTitle;

  /// No description provided for @connLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String connLoadFailed(Object error);

  /// No description provided for @connAddBroker.
  ///
  /// In en, this message translates to:
  /// **'Add broker'**
  String get connAddBroker;

  /// No description provided for @connEmpty.
  ///
  /// In en, this message translates to:
  /// **'No connections yet.\nTap \"Add broker\" to point ZigDash at your MQTT server.'**
  String get connEmpty;

  /// No description provided for @connNew.
  ///
  /// In en, this message translates to:
  /// **'New connection'**
  String get connNew;

  /// No description provided for @connEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit connection'**
  String get connEdit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @connName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get connName;

  /// No description provided for @connNameHint.
  ///
  /// In en, this message translates to:
  /// **'Home broker'**
  String get connNameHint;

  /// No description provided for @connHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get connHost;

  /// No description provided for @connHostHint.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.10'**
  String get connHostHint;

  /// No description provided for @connLocalHost.
  ///
  /// In en, this message translates to:
  /// **'Local host'**
  String get connLocalHost;

  /// No description provided for @connRemoteHost.
  ///
  /// In en, this message translates to:
  /// **'Remote host (Tailscale)'**
  String get connRemoteHost;

  /// No description provided for @connRemoteHostHint.
  ///
  /// In en, this message translates to:
  /// **'Used when the local host can\'t be reached. Prefer the hub\'s Tailscale IP, e.g. 100.x.y.z'**
  String get connRemoteHostHint;

  /// No description provided for @connPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get connPort;

  /// No description provided for @connPortRange.
  ///
  /// In en, this message translates to:
  /// **'1–65535'**
  String get connPortRange;

  /// No description provided for @connUsernameOptional.
  ///
  /// In en, this message translates to:
  /// **'Username (optional)'**
  String get connUsernameOptional;

  /// No description provided for @connPasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get connPasswordOptional;

  /// No description provided for @connPasswordKeepHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep existing'**
  String get connPasswordKeepHint;

  /// No description provided for @connAutoConnect.
  ///
  /// In en, this message translates to:
  /// **'Auto-connect on app start'**
  String get connAutoConnect;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @connKeepAlive.
  ///
  /// In en, this message translates to:
  /// **'Keep-alive (seconds)'**
  String get connKeepAlive;

  /// No description provided for @connKeepAliveRange.
  ///
  /// In en, this message translates to:
  /// **'5–3600'**
  String get connKeepAliveRange;

  /// No description provided for @connProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get connProtocol;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @connDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete connection?'**
  String get connDeleteTitle;

  /// No description provided for @connDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Removes \"{name}\", its dashboards/panels, and its saved password.'**
  String connDeleteContent(Object name);

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get statusDisconnected;

  /// No description provided for @statusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get statusConnecting;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get statusConnected;

  /// No description provided for @statusReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get statusReconnecting;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @statusConnectedRemote.
  ///
  /// In en, this message translates to:
  /// **'Connected · Remote'**
  String get statusConnectedRemote;

  /// No description provided for @dashPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Open a broker from the Brokers tab to see and manage its dashboards.'**
  String get dashPlaceholder;

  /// No description provided for @dashAddDashboard.
  ///
  /// In en, this message translates to:
  /// **'Add dashboard'**
  String get dashAddDashboard;

  /// No description provided for @dashEditDashboard.
  ///
  /// In en, this message translates to:
  /// **'Edit dashboard'**
  String get dashEditDashboard;

  /// No description provided for @dashAddPanel.
  ///
  /// In en, this message translates to:
  /// **'Add panel'**
  String get dashAddPanel;

  /// No description provided for @dashEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dashboards yet.\nTap \"Add dashboard\" to create one for this broker.'**
  String get dashEmpty;

  /// No description provided for @dashLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String dashLoadFailed(Object error);

  /// No description provided for @panelPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a panel'**
  String get panelPickerTitle;

  /// No description provided for @panelPickerSectionControl.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get panelPickerSectionControl;

  /// No description provided for @panelPickerSectionState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get panelPickerSectionState;

  /// No description provided for @panelPickerToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle'**
  String get panelPickerToggleTitle;

  /// No description provided for @panelPickerToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On/off switch for a device state'**
  String get panelPickerToggleSubtitle;

  /// No description provided for @panelPickerSliderBrightnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Slider — Brightness'**
  String get panelPickerSliderBrightnessTitle;

  /// No description provided for @panelPickerSliderBrightnessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light dimming (0–254, brightness:N)'**
  String get panelPickerSliderBrightnessSubtitle;

  /// No description provided for @panelPickerSliderPositionTitle.
  ///
  /// In en, this message translates to:
  /// **'Slider — Position'**
  String get panelPickerSliderPositionTitle;

  /// No description provided for @panelPickerSliderPositionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cover / shutter (0–100, position:N)'**
  String get panelPickerSliderPositionSubtitle;

  /// No description provided for @panelPickerCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get panelPickerCoverTitle;

  /// No description provided for @panelPickerCoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shutter/blind: OPEN·STOP·CLOSE + position slider'**
  String get panelPickerCoverSubtitle;

  /// No description provided for @panelPickerScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get panelPickerScheduleTitle;

  /// No description provided for @panelPickerScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily open/close times, run on the hub (Node-RED)'**
  String get panelPickerScheduleSubtitle;

  /// No description provided for @panelPickerMultiStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-State'**
  String get panelPickerMultiStateTitle;

  /// No description provided for @panelPickerMultiStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Segmented buttons for an enum (e.g. OPEN/STOP/CLOSE)'**
  String get panelPickerMultiStateSubtitle;

  /// No description provided for @panelPickerComboTitle.
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get panelPickerComboTitle;

  /// No description provided for @panelPickerComboSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dropdown selector for an enum'**
  String get panelPickerComboSubtitle;

  /// No description provided for @panelPickerRadioTitle.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get panelPickerRadioTitle;

  /// No description provided for @panelPickerRadioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Radio-button list for an enum'**
  String get panelPickerRadioSubtitle;

  /// No description provided for @panelPickerButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get panelPickerButtonTitle;

  /// No description provided for @panelPickerButtonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fire a one-shot command'**
  String get panelPickerButtonSubtitle;

  /// No description provided for @panelPickerTextInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Input'**
  String get panelPickerTextInputTitle;

  /// No description provided for @panelPickerTextInputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish a free-form value or JSON'**
  String get panelPickerTextInputSubtitle;

  /// No description provided for @panelPickerLedTitle.
  ///
  /// In en, this message translates to:
  /// **'LED'**
  String get panelPickerLedTitle;

  /// No description provided for @panelPickerLedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Colored indicator for a boolean state (contact, leak)'**
  String get panelPickerLedSubtitle;

  /// No description provided for @panelPickerNodeStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Node Status'**
  String get panelPickerNodeStatusTitle;

  /// No description provided for @panelPickerNodeStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Z2M device availability (online/offline)'**
  String get panelPickerNodeStatusSubtitle;

  /// No description provided for @panelPickerProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get panelPickerProgressTitle;

  /// No description provided for @panelPickerProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Numeric bar for battery, link quality, etc.'**
  String get panelPickerProgressSubtitle;

  /// No description provided for @panelPickerTextLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Log'**
  String get panelPickerTextLogTitle;

  /// No description provided for @panelPickerTextLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scrolling history of messages on a topic'**
  String get panelPickerTextLogSubtitle;

  /// No description provided for @dashExportMenu.
  ///
  /// In en, this message translates to:
  /// **'Export dashboards'**
  String get dashExportMenu;

  /// No description provided for @dashImportMenu.
  ///
  /// In en, this message translates to:
  /// **'Import dashboards'**
  String get dashImportMenu;

  /// No description provided for @dashExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export dashboards'**
  String get dashExportTitle;

  /// No description provided for @dashExportClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dashExportClose;

  /// No description provided for @dashExportCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get dashExportCopy;

  /// No description provided for @dashExportCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get dashExportCopied;

  /// No description provided for @dashImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import dashboards'**
  String get dashImportTitle;

  /// No description provided for @dashImportHint.
  ///
  /// In en, this message translates to:
  /// **'Paste exported JSON here'**
  String get dashImportHint;

  /// No description provided for @dashImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get dashImportButton;

  /// No description provided for @dashImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Imported 1 dashboard} other{Imported {count} dashboards}}'**
  String dashImportSuccess(int count);

  /// No description provided for @dashImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String dashImportFailed(Object error);

  /// No description provided for @dashFormNew.
  ///
  /// In en, this message translates to:
  /// **'New dashboard'**
  String get dashFormNew;

  /// No description provided for @dashFormEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit dashboard'**
  String get dashFormEdit;

  /// No description provided for @dashFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get dashFormName;

  /// No description provided for @dashFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get dashFormNameHint;

  /// No description provided for @dashFormTopicPrefix.
  ///
  /// In en, this message translates to:
  /// **'Topic prefix (optional)'**
  String get dashFormTopicPrefix;

  /// No description provided for @dashFormTopicPrefixHint.
  ///
  /// In en, this message translates to:
  /// **'zigbee2mqtt/living-room'**
  String get dashFormTopicPrefixHint;

  /// No description provided for @dashFormTopicPrefixHelper.
  ///
  /// In en, this message translates to:
  /// **'Prepended to every panel topic in this dashboard'**
  String get dashFormTopicPrefixHelper;

  /// No description provided for @dashFormColorSeed.
  ///
  /// In en, this message translates to:
  /// **'Color seed'**
  String get dashFormColorSeed;

  /// No description provided for @dashFormIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get dashFormIcon;

  /// No description provided for @dashFormLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get dashFormLock;

  /// No description provided for @dashFormLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide edit affordances while locked'**
  String get dashFormLockSubtitle;

  /// No description provided for @dashFormDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete dashboard'**
  String get dashFormDelete;

  /// No description provided for @dashDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this dashboard?'**
  String get dashDeleteTitle;

  /// No description provided for @dashDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'All panels under it will also be removed.'**
  String get dashDeleteContent;

  /// No description provided for @dashDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dashDeleteConfirm;

  /// No description provided for @panelFormNew.
  ///
  /// In en, this message translates to:
  /// **'New {type}'**
  String panelFormNew(Object type);

  /// No description provided for @panelFormEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit {type}'**
  String panelFormEdit(Object type);

  /// No description provided for @panelTypeButton.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get panelTypeButton;

  /// No description provided for @panelTypeToggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle'**
  String get panelTypeToggle;

  /// No description provided for @panelTypeSlider.
  ///
  /// In en, this message translates to:
  /// **'Slider'**
  String get panelTypeSlider;

  /// No description provided for @panelTypeLed.
  ///
  /// In en, this message translates to:
  /// **'LED'**
  String get panelTypeLed;

  /// No description provided for @panelTypeNodeStatus.
  ///
  /// In en, this message translates to:
  /// **'Node Status'**
  String get panelTypeNodeStatus;

  /// No description provided for @panelTypeProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get panelTypeProgress;

  /// No description provided for @panelTypeMultiState.
  ///
  /// In en, this message translates to:
  /// **'Multi-State'**
  String get panelTypeMultiState;

  /// No description provided for @panelTypeCombo.
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get panelTypeCombo;

  /// No description provided for @panelTypeRadio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get panelTypeRadio;

  /// No description provided for @panelTypeCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get panelTypeCover;

  /// No description provided for @panelTypeTextInput.
  ///
  /// In en, this message translates to:
  /// **'Text Input'**
  String get panelTypeTextInput;

  /// No description provided for @panelTypeTextLog.
  ///
  /// In en, this message translates to:
  /// **'Text Log'**
  String get panelTypeTextLog;

  /// No description provided for @panelTypeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get panelTypeSchedule;

  /// No description provided for @panelFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get panelFormName;

  /// No description provided for @panelFormDashboardPrefix.
  ///
  /// In en, this message translates to:
  /// **'Dashboard prefix: {prefix}/ (used unless overridden below)'**
  String panelFormDashboardPrefix(Object prefix);

  /// No description provided for @panelFormTopicPrefixOverride.
  ///
  /// In en, this message translates to:
  /// **'Topic prefix override (optional)'**
  String get panelFormTopicPrefixOverride;

  /// No description provided for @panelFormTopicPrefixOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'zigbee2mqtt/shutter'**
  String get panelFormTopicPrefixOverrideHint;

  /// No description provided for @panelFormTopicPrefixOverrideHelper.
  ///
  /// In en, this message translates to:
  /// **'Use a different device on this dashboard. Blank = use dashboard prefix.'**
  String get panelFormTopicPrefixOverrideHelper;

  /// No description provided for @panelFormPublishTopic.
  ///
  /// In en, this message translates to:
  /// **'Publish topic (suffix)'**
  String get panelFormPublishTopic;

  /// No description provided for @panelFormPublishTopicHint.
  ///
  /// In en, this message translates to:
  /// **'set'**
  String get panelFormPublishTopicHint;

  /// No description provided for @panelFormPublishTopicHelper.
  ///
  /// In en, this message translates to:
  /// **'Appended to the effective prefix. Leave blank to publish at the prefix itself.'**
  String get panelFormPublishTopicHelper;

  /// No description provided for @panelFormTopicSuffix.
  ///
  /// In en, this message translates to:
  /// **'Topic (suffix)'**
  String get panelFormTopicSuffix;

  /// No description provided for @panelFormSubscribeTopic.
  ///
  /// In en, this message translates to:
  /// **'Subscribe topic (suffix, optional)'**
  String get panelFormSubscribeTopic;

  /// No description provided for @panelFormSubscribeTopicHelperReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Appended to the dashboard prefix. Blank = subscribe to the prefix itself (Z2M state).'**
  String get panelFormSubscribeTopicHelperReadOnly;

  /// No description provided for @panelFormSubscribeTopicHelper.
  ///
  /// In en, this message translates to:
  /// **'Blank = subscribe to the prefix itself (Z2M state). Same as Publish topic = use that.'**
  String get panelFormSubscribeTopicHelper;

  /// No description provided for @panelFormWidth.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get panelFormWidth;

  /// No description provided for @panelFormWidthFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get panelFormWidthFull;

  /// No description provided for @panelFormWidthHalf.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get panelFormWidthHalf;

  /// No description provided for @panelFormWidthThird.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get panelFormWidthThird;

  /// No description provided for @panelFormQos.
  ///
  /// In en, this message translates to:
  /// **'QoS'**
  String get panelFormQos;

  /// No description provided for @panelFormQos0.
  ///
  /// In en, this message translates to:
  /// **'0 — at most once'**
  String get panelFormQos0;

  /// No description provided for @panelFormQos1.
  ///
  /// In en, this message translates to:
  /// **'1 — at least once'**
  String get panelFormQos1;

  /// No description provided for @panelFormQos2.
  ///
  /// In en, this message translates to:
  /// **'2 — exactly once'**
  String get panelFormQos2;

  /// No description provided for @panelFormRetain.
  ///
  /// In en, this message translates to:
  /// **'Retain'**
  String get panelFormRetain;

  /// No description provided for @panelToggleOnPayload.
  ///
  /// In en, this message translates to:
  /// **'On payload'**
  String get panelToggleOnPayload;

  /// No description provided for @panelToggleOffPayload.
  ///
  /// In en, this message translates to:
  /// **'Off payload'**
  String get panelToggleOffPayload;

  /// No description provided for @panelToggleJsonPath.
  ///
  /// In en, this message translates to:
  /// **'JSON path (optional)'**
  String get panelToggleJsonPath;

  /// No description provided for @panelToggleJsonPathHint.
  ///
  /// In en, this message translates to:
  /// **'state'**
  String get panelToggleJsonPathHint;

  /// No description provided for @panelToggleOnMatch.
  ///
  /// In en, this message translates to:
  /// **'On match'**
  String get panelToggleOnMatch;

  /// No description provided for @panelToggleOnMatchHelper.
  ///
  /// In en, this message translates to:
  /// **'Value at JSON path that means \"on\" (e.g. \"ON\")'**
  String get panelToggleOnMatchHelper;

  /// No description provided for @panelSliderMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get panelSliderMin;

  /// No description provided for @panelSliderMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get panelSliderMax;

  /// No description provided for @panelSliderStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get panelSliderStep;

  /// No description provided for @panelSliderTemplate.
  ///
  /// In en, this message translates to:
  /// **'Value template'**
  String get panelSliderTemplate;

  /// No description provided for @panelSliderTemplateHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the word value as a placeholder — it is replaced with the slider value'**
  String get panelSliderTemplateHelper;

  /// No description provided for @panelSliderJsonPath.
  ///
  /// In en, this message translates to:
  /// **'JSON path (optional)'**
  String get panelSliderJsonPath;

  /// No description provided for @panelSliderJsonPathHint.
  ///
  /// In en, this message translates to:
  /// **'brightness'**
  String get panelSliderJsonPathHint;

  /// No description provided for @panelButtonPayload.
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get panelButtonPayload;

  /// No description provided for @panelLedJsonPath.
  ///
  /// In en, this message translates to:
  /// **'JSON path (optional)'**
  String get panelLedJsonPath;

  /// No description provided for @panelLedJsonPathHint.
  ///
  /// In en, this message translates to:
  /// **'contact'**
  String get panelLedJsonPathHint;

  /// No description provided for @panelLedJsonPathHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"contact\", \"occupancy\", \"water_leak\"'**
  String get panelLedJsonPathHelper;

  /// No description provided for @panelLedOnMatch.
  ///
  /// In en, this message translates to:
  /// **'On match'**
  String get panelLedOnMatch;

  /// No description provided for @panelLedOnMatchHelper.
  ///
  /// In en, this message translates to:
  /// **'Value at JSON path that lights the LED (e.g. \"true\", \"ON\")'**
  String get panelLedOnMatchHelper;

  /// No description provided for @panelLedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'On label (optional)'**
  String get panelLedOnLabel;

  /// No description provided for @panelLedOnLabelHint.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get panelLedOnLabelHint;

  /// No description provided for @panelLedOffLabel.
  ///
  /// In en, this message translates to:
  /// **'Off label (optional)'**
  String get panelLedOffLabel;

  /// No description provided for @panelLedOffLabelHint.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get panelLedOffLabelHint;

  /// No description provided for @panelNodeOnlinePayload.
  ///
  /// In en, this message translates to:
  /// **'Online payload'**
  String get panelNodeOnlinePayload;

  /// No description provided for @panelNodeOnlinePayloadHelper.
  ///
  /// In en, this message translates to:
  /// **'Value that means \"online\" (Z2M default: \"online\")'**
  String get panelNodeOnlinePayloadHelper;

  /// No description provided for @panelNodeJsonPath.
  ///
  /// In en, this message translates to:
  /// **'JSON path (optional)'**
  String get panelNodeJsonPath;

  /// No description provided for @panelNodeJsonPathHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave blank for Z2M default (raw \"online\"/\"offline\" string)'**
  String get panelNodeJsonPathHelper;

  /// No description provided for @panelProgressMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get panelProgressMin;

  /// No description provided for @panelProgressMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get panelProgressMax;

  /// No description provided for @panelProgressUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get panelProgressUnit;

  /// No description provided for @panelProgressUnitHint.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get panelProgressUnitHint;

  /// No description provided for @panelProgressJsonPath.
  ///
  /// In en, this message translates to:
  /// **'JSON path (optional)'**
  String get panelProgressJsonPath;

  /// No description provided for @panelProgressJsonPathHint.
  ///
  /// In en, this message translates to:
  /// **'battery'**
  String get panelProgressJsonPathHint;

  /// No description provided for @panelProgressJsonPathHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"battery\", \"linkquality\"'**
  String get panelProgressJsonPathHelper;

  /// No description provided for @panelOptionsJsonPath.
  ///
  /// In en, this message translates to:
  /// **'JSON path (optional)'**
  String get panelOptionsJsonPath;

  /// No description provided for @panelOptionsJsonPathHint.
  ///
  /// In en, this message translates to:
  /// **'state'**
  String get panelOptionsJsonPathHint;

  /// No description provided for @panelOptionsJsonPathHelper.
  ///
  /// In en, this message translates to:
  /// **'Field in the received payload that holds the current value'**
  String get panelOptionsJsonPathHelper;

  /// No description provided for @panelOptionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get panelOptionsHeader;

  /// No description provided for @panelOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get panelOptionsLabel;

  /// No description provided for @panelOptionsPayload.
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get panelOptionsPayload;

  /// No description provided for @panelOptionsMatch.
  ///
  /// In en, this message translates to:
  /// **'Match (current value)'**
  String get panelOptionsMatch;

  /// No description provided for @panelOptionsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get panelOptionsAdd;

  /// No description provided for @panelCoverDescription.
  ///
  /// In en, this message translates to:
  /// **'OPEN / STOP / CLOSE buttons plus a row of position presets. Uses the standard Z2M cover payloads (state and position).'**
  String get panelCoverDescription;

  /// No description provided for @panelCoverPresets.
  ///
  /// In en, this message translates to:
  /// **'Position presets'**
  String get panelCoverPresets;

  /// No description provided for @panelCoverPresetsHint.
  ///
  /// In en, this message translates to:
  /// **'0, 25, 50, 100'**
  String get panelCoverPresetsHint;

  /// No description provided for @panelCoverPresetsHelper.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated percentages (0–100). Blank = no preset row.'**
  String get panelCoverPresetsHelper;

  /// No description provided for @panelCoverShowSlider.
  ///
  /// In en, this message translates to:
  /// **'Show position slider'**
  String get panelCoverShowSlider;

  /// No description provided for @panelTextInputHint.
  ///
  /// In en, this message translates to:
  /// **'Hint (optional)'**
  String get panelTextInputHint;

  /// No description provided for @panelTextInputHintHint.
  ///
  /// In en, this message translates to:
  /// **'Type a value…'**
  String get panelTextInputHintHint;

  /// No description provided for @panelTextInputTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get panelTextInputTemplate;

  /// No description provided for @panelTextInputTemplateHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the word value as a placeholder — it is replaced with the typed text. Default publishes the raw text.'**
  String get panelTextInputTemplateHelper;

  /// No description provided for @panelTextInputClearAfterSend.
  ///
  /// In en, this message translates to:
  /// **'Clear after send'**
  String get panelTextInputClearAfterSend;

  /// No description provided for @panelTextLogMaxLines.
  ///
  /// In en, this message translates to:
  /// **'Max lines'**
  String get panelTextLogMaxLines;

  /// No description provided for @panelTextLogMaxLinesHelper.
  ///
  /// In en, this message translates to:
  /// **'How many recent messages to keep'**
  String get panelTextLogMaxLinesHelper;

  /// No description provided for @panelTextLogJsonPath.
  ///
  /// In en, this message translates to:
  /// **'JSON path (optional)'**
  String get panelTextLogJsonPath;

  /// No description provided for @panelTextLogJsonPathHelper.
  ///
  /// In en, this message translates to:
  /// **'Log just this field instead of the whole payload'**
  String get panelTextLogJsonPathHelper;

  /// No description provided for @panelScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Runs on the SMHUB via Node-RED — fires even when this phone is off. The Publish topic above is the shutter command target.'**
  String get panelScheduleDescription;

  /// No description provided for @panelScheduleOpenTime.
  ///
  /// In en, this message translates to:
  /// **'Open time'**
  String get panelScheduleOpenTime;

  /// No description provided for @panelScheduleCloseTime.
  ///
  /// In en, this message translates to:
  /// **'Close time'**
  String get panelScheduleCloseTime;

  /// No description provided for @panelScheduleOpenPayload.
  ///
  /// In en, this message translates to:
  /// **'Open payload'**
  String get panelScheduleOpenPayload;

  /// No description provided for @panelScheduleClosePayload.
  ///
  /// In en, this message translates to:
  /// **'Close payload'**
  String get panelScheduleClosePayload;

  /// No description provided for @panelScheduleEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get panelScheduleEnabled;

  /// No description provided for @panelScheduleSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved — not connected; schedule will sync when online.'**
  String get panelScheduleSavedOffline;

  /// No description provided for @panelTileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit panel'**
  String get panelTileEdit;

  /// No description provided for @panelTileDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate panel'**
  String get panelTileDuplicate;

  /// No description provided for @panelTileMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get panelTileMoveUp;

  /// No description provided for @panelTileMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get panelTileMoveDown;

  /// No description provided for @panelTileWidth.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get panelTileWidth;

  /// No description provided for @panelTileWidthFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get panelTileWidthFull;

  /// No description provided for @panelTileWidthHalf.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get panelTileWidthHalf;

  /// No description provided for @panelTileWidthThird.
  ///
  /// In en, this message translates to:
  /// **'⅓'**
  String get panelTileWidthThird;

  /// No description provided for @panelTileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete panel'**
  String get panelTileDelete;

  /// No description provided for @panelCoverOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get panelCoverOpen;

  /// No description provided for @panelCoverStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get panelCoverStop;

  /// No description provided for @panelCoverClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get panelCoverClose;

  /// No description provided for @panelToggleNoState.
  ///
  /// In en, this message translates to:
  /// **'(no state)'**
  String get panelToggleNoState;

  /// No description provided for @panelToggleError.
  ///
  /// In en, this message translates to:
  /// **'err'**
  String get panelToggleError;

  /// No description provided for @panelStateOn.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get panelStateOn;

  /// No description provided for @panelStateOff.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get panelStateOff;

  /// No description provided for @panelNodeStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get panelNodeStatusOnline;

  /// No description provided for @panelNodeStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get panelNodeStatusOffline;

  /// No description provided for @panelNodeStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get panelNodeStatusUnknown;

  /// No description provided for @panelNodeStatusError.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get panelNodeStatusError;

  /// No description provided for @panelMultiStateNoOptions.
  ///
  /// In en, this message translates to:
  /// **'No options configured'**
  String get panelMultiStateNoOptions;

  /// No description provided for @panelTextInputDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Type a value…'**
  String get panelTextInputDefaultHint;

  /// No description provided for @panelTextLogWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for messages…'**
  String get panelTextLogWaiting;

  /// No description provided for @panelScheduleOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Opens {time}'**
  String panelScheduleOpensAt(Object time);

  /// No description provided for @panelScheduleClosesAt.
  ///
  /// In en, this message translates to:
  /// **'Closes {time}'**
  String panelScheduleClosesAt(Object time);

  /// No description provided for @panelScheduleOfflineWarning.
  ///
  /// In en, this message translates to:
  /// **'Scheduler offline — won\'t run'**
  String get panelScheduleOfflineWarning;

  /// No description provided for @panelScheduleDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get panelScheduleDisabled;

  /// No description provided for @panelScheduleNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {action} at {at}'**
  String panelScheduleNext(Object action, Object at);

  /// No description provided for @panelScheduleActionOpen.
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get panelScheduleActionOpen;

  /// No description provided for @panelScheduleActionClose.
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get panelScheduleActionClose;

  /// No description provided for @panelGridEmpty.
  ///
  /// In en, this message translates to:
  /// **'No panels yet.\nTap + to add a Toggle, Slider, or Button.'**
  String get panelGridEmpty;

  /// No description provided for @panelsOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing last values'**
  String get panelsOffline;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Guide'**
  String get settingsHelp;

  /// No description provided for @a11yBackupMenu.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get a11yBackupMenu;

  /// No description provided for @a11ySelectColor.
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get a11ySelectColor;

  /// No description provided for @a11ySelectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select icon'**
  String get a11ySelectIcon;

  /// No description provided for @a11yDeleteOption.
  ///
  /// In en, this message translates to:
  /// **'Delete option'**
  String get a11yDeleteOption;

  /// No description provided for @a11yPanelOptions.
  ///
  /// In en, this message translates to:
  /// **'Panel options'**
  String get a11yPanelOptions;

  /// No description provided for @a11yMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get a11yMoreOptions;

  /// No description provided for @a11yDeleteConnection.
  ///
  /// In en, this message translates to:
  /// **'Delete connection'**
  String get a11yDeleteConnection;

  /// No description provided for @controlNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected — change not sent'**
  String get controlNotConnected;

  /// No description provided for @discoverFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Add from a device…'**
  String get discoverFromDevice;

  /// No description provided for @discoverFromDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect a Zigbee2MQTT device'**
  String get discoverFromDeviceSubtitle;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Add from device'**
  String get discoverTitle;

  /// No description provided for @discoverBaseTopic.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT base topic'**
  String get discoverBaseTopic;

  /// No description provided for @discoverScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning for devices…'**
  String get discoverScanning;

  /// No description provided for @discoverNone.
  ///
  /// In en, this message translates to:
  /// **'No devices found.'**
  String get discoverNone;

  /// No description provided for @discoverFailed.
  ///
  /// In en, this message translates to:
  /// **'No device list found. Check the base topic and that the broker is connected.'**
  String get discoverFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get previewTitle;

  /// No description provided for @previewWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a message on {topic}…'**
  String previewWaiting(Object topic);

  /// No description provided for @previewExtracted.
  ///
  /// In en, this message translates to:
  /// **'Extracted ({path}): {value}'**
  String previewExtracted(Object path, Object value);

  /// No description provided for @previewNoValue.
  ///
  /// In en, this message translates to:
  /// **'(no value at this path)'**
  String get previewNoValue;

  /// No description provided for @connErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connErrorTitle;

  /// No description provided for @connErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'No error details available.'**
  String get connErrorUnknown;

  /// No description provided for @connTestButton.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get connTestButton;

  /// No description provided for @connTestOk.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get connTestOk;

  /// No description provided for @connTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {error}'**
  String connTestFailed(Object error);

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devicesTitle;

  /// No description provided for @devicesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get devicesAddButton;

  /// No description provided for @devicesPairingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pairing — press the device\'s button'**
  String get devicesPairingTitle;

  /// No description provided for @devicesPairingHint.
  ///
  /// In en, this message translates to:
  /// **'Searching for new devices… {seconds}s'**
  String devicesPairingHint(int seconds);

  /// No description provided for @devicesPairingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get devicesPairingStop;

  /// No description provided for @devicesNone.
  ///
  /// In en, this message translates to:
  /// **'No devices found.'**
  String get devicesNone;

  /// No description provided for @devicesBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get devicesBattery;

  /// No description provided for @devicesLinkQuality.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get devicesLinkQuality;

  /// No description provided for @devicesOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get devicesOnline;

  /// No description provided for @devicesOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get devicesOffline;

  /// No description provided for @devicesPaired.
  ///
  /// In en, this message translates to:
  /// **'Ready: {name}'**
  String devicesPaired(Object name);

  /// No description provided for @devicesPairedHint.
  ///
  /// In en, this message translates to:
  /// **'Added to your network. To put it on a dashboard, use \'Add from a device\' on that dashboard.'**
  String get devicesPairedHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
