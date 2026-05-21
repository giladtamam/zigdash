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
