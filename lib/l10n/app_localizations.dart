import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('sv'),
  ];

  /// No description provided for @reliabilityLastKnown.
  ///
  /// In en, this message translates to:
  /// **'Last known'**
  String get reliabilityLastKnown;

  /// No description provided for @reliabilityControlsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Controls unavailable'**
  String get reliabilityControlsUnavailable;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ZigDash'**
  String get appTitle;

  /// No description provided for @onboardingDemo.
  ///
  /// In en, this message translates to:
  /// **'Try demo'**
  String get onboardingDemo;

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
  /// **'Homes'**
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

  /// No description provided for @connFindBrokers.
  ///
  /// In en, this message translates to:
  /// **'Find brokers'**
  String get connFindBrokers;

  /// No description provided for @connHowToFind.
  ///
  /// In en, this message translates to:
  /// **'How do I find this?'**
  String get connHowToFind;

  /// No description provided for @connRescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get connRescan;

  /// No description provided for @connBrokerNeedsLogin.
  ///
  /// In en, this message translates to:
  /// **'Needs login'**
  String get connBrokerNeedsLogin;

  /// No description provided for @connFindBrokersScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning {subnet}…'**
  String connFindBrokersScanning(Object subnet);

  /// No description provided for @connFindBrokersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} broker(s) found — tap to use'**
  String connFindBrokersFound(int count);

  /// No description provided for @connFindBrokersNone.
  ///
  /// In en, this message translates to:
  /// **'No brokers found on your Wi-Fi.'**
  String get connFindBrokersNone;

  /// No description provided for @connFindBrokersNoIp.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read your Wi-Fi address. Make sure Wi-Fi is on and try again.'**
  String get connFindBrokersNoIp;

  /// No description provided for @connHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Finding your broker IP'**
  String get connHelpTitle;

  /// No description provided for @connHelpDockerTitle.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT in Docker'**
  String get connHelpDockerTitle;

  /// No description provided for @connHelpDockerBody.
  ///
  /// In en, this message translates to:
  /// **'The broker IP is the LAN address of the machine running Docker (your NAS, Raspberry Pi, etc.). Find it in your router\'s device list, or run \'hostname -I\' / \'ip addr\' on that machine. Port is usually 1883 (Mosquitto). Use the host\'s LAN IP — not 127.0.0.1 — even if Mosquitto runs in its own container.'**
  String get connHelpDockerBody;

  /// No description provided for @connHelpSmhubTitle.
  ///
  /// In en, this message translates to:
  /// **'SMLIGHT SMHUB'**
  String get connHelpSmhubTitle;

  /// No description provided for @connHelpSmhubBody.
  ///
  /// In en, this message translates to:
  /// **'The broker IP is the hub\'s IP address. Find it in the SMLIGHT web interface under Settings → Network, or in your router. Port is 1883, with no username/password by default.'**
  String get connHelpSmhubBody;

  /// No description provided for @connHelpZhaTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant ZHA'**
  String get connHelpZhaTitle;

  /// No description provided for @connHelpZhaBody.
  ///
  /// In en, this message translates to:
  /// **'ZHA has no MQTT broker — it talks to Home Assistant directly, so ZigDash can\'t connect to it. To use ZigDash, switch to Zigbee2MQTT (available as a Home Assistant add-on or a Docker container), which provides an MQTT broker.'**
  String get connHelpZhaBody;

  /// No description provided for @connHelpSameNetwork.
  ///
  /// In en, this message translates to:
  /// **'Your phone and the broker must be on the same Wi-Fi network (not a guest or isolated VLAN).'**
  String get connHelpSameNetwork;

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

  /// No description provided for @panelPickerAutoCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-close rule'**
  String get panelPickerAutoCloseTitle;

  /// No description provided for @panelPickerAutoCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close a device automatically N seconds after it turns on, run on the hub (Node-RED)'**
  String get panelPickerAutoCloseSubtitle;

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

  /// No description provided for @panelTypeAutoClose.
  ///
  /// In en, this message translates to:
  /// **'Auto-close'**
  String get panelTypeAutoClose;

  /// No description provided for @panelTypeDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get panelTypeDevice;

  /// No description provided for @panelTypeReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get panelTypeReading;

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

  /// No description provided for @tileSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get tileSize;

  /// No description provided for @tileSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get tileSizeSmall;

  /// No description provided for @tileSizeWide.
  ///
  /// In en, this message translates to:
  /// **'Wide'**
  String get tileSizeWide;

  /// No description provided for @tileSizeFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get tileSizeFull;

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

  /// No description provided for @panelAutoCloseDescription.
  ///
  /// In en, this message translates to:
  /// **'Runs on the SMHUB via Node-RED — fires even when this phone is off. The Publish topic above is the device\'s command target (e.g. door).'**
  String get panelAutoCloseDescription;

  /// No description provided for @panelAutoCloseTriggerPath.
  ///
  /// In en, this message translates to:
  /// **'Trigger JSON path'**
  String get panelAutoCloseTriggerPath;

  /// No description provided for @panelAutoCloseTriggerPathHelper.
  ///
  /// In en, this message translates to:
  /// **'Field in the device\'s state JSON to watch (default: state)'**
  String get panelAutoCloseTriggerPathHelper;

  /// No description provided for @panelAutoCloseTriggerValue.
  ///
  /// In en, this message translates to:
  /// **'Trigger value'**
  String get panelAutoCloseTriggerValue;

  /// No description provided for @panelAutoCloseTriggerValueHelper.
  ///
  /// In en, this message translates to:
  /// **'Fire the timer when the trigger field equals this value (default: ON)'**
  String get panelAutoCloseTriggerValueHelper;

  /// No description provided for @panelAutoCloseClosePayload.
  ///
  /// In en, this message translates to:
  /// **'Close payload'**
  String get panelAutoCloseClosePayload;

  /// No description provided for @panelAutoCloseDelaySeconds.
  ///
  /// In en, this message translates to:
  /// **'Delay (seconds)'**
  String get panelAutoCloseDelaySeconds;

  /// No description provided for @panelAutoCloseDelaySecondsHelper.
  ///
  /// In en, this message translates to:
  /// **'1-3600. Time to wait after the device turns on before publishing the close payload.'**
  String get panelAutoCloseDelaySecondsHelper;

  /// No description provided for @panelAutoCloseEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get panelAutoCloseEnabled;

  /// No description provided for @panelAutoCloseSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved — not connected; rule will sync when online.'**
  String get panelAutoCloseSavedOffline;

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

  /// No description provided for @panelAutoCloseIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get panelAutoCloseIdle;

  /// No description provided for @panelAutoCloseDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get panelAutoCloseDisabled;

  /// No description provided for @panelAutoCloseOffline.
  ///
  /// In en, this message translates to:
  /// **'Automation offline — rule won\'t run'**
  String get panelAutoCloseOffline;

  /// No description provided for @panelAutoCloseClosingIn.
  ///
  /// In en, this message translates to:
  /// **'Closing in {seconds}s'**
  String panelAutoCloseClosingIn(int seconds);

  /// No description provided for @panelAutoCloseClosingNow.
  ///
  /// In en, this message translates to:
  /// **'Closing now…'**
  String get panelAutoCloseClosingNow;

  /// No description provided for @panelGridEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tiles yet.\nTap Add tile to put your devices here.'**
  String get panelGridEmpty;

  /// No description provided for @panelsOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing last values'**
  String get panelsOffline;

  /// No description provided for @connectionConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connectionConnecting;

  /// No description provided for @connectionReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get connectionReconnecting;

  /// No description provided for @connectionShowingLastKnownValues.
  ///
  /// In en, this message translates to:
  /// **'Showing last known values'**
  String get connectionShowingLastKnownValues;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// No description provided for @connectionAutomaticRetry.
  ///
  /// In en, this message translates to:
  /// **'Automatic retry will continue'**
  String get connectionAutomaticRetry;

  /// No description provided for @connectionReconnectNow.
  ///
  /// In en, this message translates to:
  /// **'Reconnect now'**
  String get connectionReconnectNow;

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

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate ZigDash'**
  String get settingsRateApp;

  /// No description provided for @settingsRateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying it? A quick review helps others find it.'**
  String get settingsRateAppSubtitle;

  /// No description provided for @settingsBuyCoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get settingsBuyCoffee;

  /// No description provided for @settingsBuyCoffeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free & open source — tips keep it brewing.'**
  String get settingsBuyCoffeeSubtitle;

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

  /// Screen-reader label for icon-only refresh buttons.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get a11yRefresh;

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

  /// No description provided for @scenesTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get scenesTitle;

  /// No description provided for @scenesNone.
  ///
  /// In en, this message translates to:
  /// **'No scenes yet. Set your devices the way you like, then capture them as a scene.'**
  String get scenesNone;

  /// No description provided for @scenesNewButton.
  ///
  /// In en, this message translates to:
  /// **'New scene'**
  String get scenesNewButton;

  /// No description provided for @scenesActivated.
  ///
  /// In en, this message translates to:
  /// **'Activated {name}'**
  String scenesActivated(Object name);

  /// No description provided for @scenesActivateOffline.
  ///
  /// In en, this message translates to:
  /// **'Not connected — can\'t activate the scene'**
  String get scenesActivateOffline;

  /// No description provided for @sceneFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New scene'**
  String get sceneFormNewTitle;

  /// No description provided for @sceneFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit scene'**
  String get sceneFormEditTitle;

  /// No description provided for @sceneFormNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Scene name'**
  String get sceneFormNameLabel;

  /// No description provided for @sceneFormDevicesHeader.
  ///
  /// In en, this message translates to:
  /// **'Devices to capture'**
  String get sceneFormDevicesHeader;

  /// No description provided for @sceneFormCaptureHint.
  ///
  /// In en, this message translates to:
  /// **'Each selected device\'s current settable state (on/off, brightness, colour, position…) is saved. Read-only values are ignored.'**
  String get sceneFormCaptureHint;

  /// No description provided for @sceneFormNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No controllable devices found. Make sure they\'re paired, then tap refresh.'**
  String get sceneFormNoDevices;

  /// No description provided for @sceneFormReadingState.
  ///
  /// In en, this message translates to:
  /// **'Reading current state…'**
  String get sceneFormReadingState;

  /// No description provided for @sceneCtrlPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get sceneCtrlPower;

  /// No description provided for @sceneCtrlBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get sceneCtrlBrightness;

  /// No description provided for @sceneCtrlPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get sceneCtrlPosition;

  /// No description provided for @sceneFormSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String sceneFormSelectedCount(int count);

  /// No description provided for @sceneFormNoDevicesSelected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one device to capture.'**
  String get sceneFormNoDevicesSelected;

  /// No description provided for @sceneFormNothingCaptured.
  ///
  /// In en, this message translates to:
  /// **'Nothing settable was captured from the selected devices.'**
  String get sceneFormNothingCaptured;

  /// No description provided for @sceneDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete scene?'**
  String get sceneDeleteTitle;

  /// No description provided for @sceneDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed. Devices keep their current state.'**
  String sceneDeleteMessage(Object name);

  /// No description provided for @sceneEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sceneEditAction;

  /// No description provided for @sceneDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sceneDeleteAction;

  /// No description provided for @sceneAddToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Add to dashboard'**
  String get sceneAddToDashboard;

  /// No description provided for @sceneAddedToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String sceneAddedToDashboard(Object name);

  /// No description provided for @sceneActionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} devices'**
  String sceneActionsCount(int count);

  /// No description provided for @panelTypeScene.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get panelTypeScene;

  /// No description provided for @panelPickerSceneTitle.
  ///
  /// In en, this message translates to:
  /// **'Scene button'**
  String get panelPickerSceneTitle;

  /// No description provided for @panelPickerSceneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One tap activates a saved scene'**
  String get panelPickerSceneSubtitle;

  /// No description provided for @panelSceneChoose.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get panelSceneChoose;

  /// No description provided for @panelSceneMissing.
  ///
  /// In en, this message translates to:
  /// **'Scene not found — re-pick it'**
  String get panelSceneMissing;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageDutch.
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get languageDutch;

  /// No description provided for @languageSwedish.
  ///
  /// In en, this message translates to:
  /// **'Svenska'**
  String get languageSwedish;

  /// No description provided for @languageNorwegian.
  ///
  /// In en, this message translates to:
  /// **'Norsk'**
  String get languageNorwegian;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @guidedConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your broker'**
  String get guidedConnectTitle;

  /// No description provided for @guidedConnectIntro.
  ///
  /// In en, this message translates to:
  /// **'We\'ll test each step of the connection and show your Zigbee devices.'**
  String get guidedConnectIntro;

  /// No description provided for @guidedBaseTopic.
  ///
  /// In en, this message translates to:
  /// **'Base topic'**
  String get guidedBaseTopic;

  /// No description provided for @guidedBaseTopicHint.
  ///
  /// In en, this message translates to:
  /// **'zigbee2mqtt'**
  String get guidedBaseTopicHint;

  /// No description provided for @guidedConnect.
  ///
  /// In en, this message translates to:
  /// **'Test & connect'**
  String get guidedConnect;

  /// No description provided for @guidedTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing your connection…'**
  String get guidedTesting;

  /// No description provided for @stepResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolving host'**
  String get stepResolve;

  /// No description provided for @stepTcp.
  ///
  /// In en, this message translates to:
  /// **'TCP connection'**
  String get stepTcp;

  /// No description provided for @stepConnack.
  ///
  /// In en, this message translates to:
  /// **'MQTT handshake'**
  String get stepConnack;

  /// No description provided for @stepAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get stepAuth;

  /// No description provided for @stepDevices.
  ///
  /// In en, this message translates to:
  /// **'Looking for devices'**
  String get stepDevices;

  /// No description provided for @diagResolveFail.
  ///
  /// In en, this message translates to:
  /// **'The host name couldn\'t be resolved. Check the address you entered.'**
  String get diagResolveFail;

  /// No description provided for @diagResolveTimeout.
  ///
  /// In en, this message translates to:
  /// **'Resolving the host timed out. Check the address and your network.'**
  String get diagResolveTimeout;

  /// No description provided for @diagTcpFail.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the broker. Is Zigbee2MQTT running? Check the address and port.'**
  String get diagTcpFail;

  /// No description provided for @diagTcpTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the broker timed out. It may be offline or unreachable.'**
  String get diagTcpTimeout;

  /// No description provided for @diagConnackFail.
  ///
  /// In en, this message translates to:
  /// **'The broker didn\'t complete the MQTT handshake. Make sure this is an MQTT broker (Mosquitto, Zigbee2MQTT).'**
  String get diagConnackFail;

  /// No description provided for @diagAuthRejected.
  ///
  /// In en, this message translates to:
  /// **'The broker rejected the username or password. Check your credentials.'**
  String get diagAuthRejected;

  /// No description provided for @diagAuthRefused.
  ///
  /// In en, this message translates to:
  /// **'The broker refused the connection. Check the connection settings.'**
  String get diagAuthRefused;

  /// No description provided for @foundDevices.
  ///
  /// In en, this message translates to:
  /// **'Found {count} devices'**
  String foundDevices(Object count);

  /// No description provided for @foundDevicesHint.
  ///
  /// In en, this message translates to:
  /// **'Your Zigbee devices are visible. Continue to build your dashboard.'**
  String get foundDevicesHint;

  /// No description provided for @noDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected — no devices found yet'**
  String get noDevicesTitle;

  /// No description provided for @noDevicesHint.
  ///
  /// In en, this message translates to:
  /// **'ZigDash can see your broker, but hasn\'t found any Zigbee devices yet. You can start pairing to add them.'**
  String get noDevicesHint;

  /// No description provided for @startPairing.
  ///
  /// In en, this message translates to:
  /// **'Start pairing'**
  String get startPairing;

  /// No description provided for @pairingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Pairing is enabled. Press the pairing button on your device to join it.'**
  String get pairingEnabled;

  /// No description provided for @continueToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Continue to dashboard'**
  String get continueToDashboard;

  /// No description provided for @guidedBackToForm.
  ///
  /// In en, this message translates to:
  /// **'Edit settings'**
  String get guidedBackToForm;

  /// No description provided for @ladderTriedHint.
  ///
  /// In en, this message translates to:
  /// **'Tried {count} addresses'**
  String ladderTriedHint(Object count);

  /// No description provided for @guidedSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the connection. Please try again.'**
  String get guidedSaveFailed;

  /// No description provided for @setupWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ZigDash'**
  String get setupWelcomeTitle;

  /// No description provided for @setupWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'ZigDash controls your existing Zigbee2MQTT home — locally, with no cloud. Make sure Zigbee2MQTT is running, then let ZigDash find it.'**
  String get setupWelcomeBody;

  /// No description provided for @setupFindMySetup.
  ///
  /// In en, this message translates to:
  /// **'Find my setup'**
  String get setupFindMySetup;

  /// No description provided for @setupManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Enter details manually'**
  String get setupManualEntry;

  /// No description provided for @setupScanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for a connection…'**
  String get setupScanningTitle;

  /// No description provided for @setupScanningHint.
  ///
  /// In en, this message translates to:
  /// **'Keep this device on the same local network as your Zigbee2MQTT host.'**
  String get setupScanningHint;

  /// No description provided for @setupCandidateFound.
  ///
  /// In en, this message translates to:
  /// **'Possible connection found'**
  String get setupCandidateFound;

  /// No description provided for @setupNoCandidatesTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection found'**
  String get setupNoCandidatesTitle;

  /// No description provided for @setupNoCandidatesBody.
  ///
  /// In en, this message translates to:
  /// **'Where does Zigbee2MQTT run?'**
  String get setupNoCandidatesBody;

  /// No description provided for @setupGuideHa.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant: make sure the MQTT broker add-on (e.g. Mosquitto) and the Zigbee2MQTT add-on are installed and running.'**
  String get setupGuideHa;

  /// No description provided for @setupGuidePi.
  ///
  /// In en, this message translates to:
  /// **'Raspberry Pi / Linux: check that your broker (e.g. Mosquitto) and the Zigbee2MQTT service are running, and that port 1883 is reachable.'**
  String get setupGuidePi;

  /// No description provided for @setupGuideSmlight.
  ///
  /// In en, this message translates to:
  /// **'SMLIGHT / SMHUB: open the device\'s web UI, go to Settings > MQTT, turn on Allow External so your phone can reach the broker, and check that Zigbee2MQTT shows as running.'**
  String get setupGuideSmlight;

  /// No description provided for @setupTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupTryAgain;

  /// No description provided for @setupAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'This broker needs a login'**
  String get setupAuthTitle;

  /// No description provided for @setupAuthBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the MQTT username and password for {host}.'**
  String setupAuthBody(Object host);

  /// No description provided for @setupAuthRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'The username or password was rejected. Check them and try again.'**
  String get setupAuthRejectedBody;

  /// No description provided for @setupVerifyingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking the connection…'**
  String get setupVerifyingTitle;

  /// No description provided for @setupReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your devices'**
  String get setupReviewTitle;

  /// No description provided for @setupReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} devices found. Choose what goes on your first dashboard.'**
  String setupReviewSubtitle(Object count);

  /// No description provided for @setupCreateWithCount.
  ///
  /// In en, this message translates to:
  /// **'Create dashboard with {count}'**
  String setupCreateWithCount(Object count);

  /// No description provided for @setupGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other devices'**
  String get setupGroupOther;

  /// No description provided for @setupGroupUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Unsupported devices'**
  String get setupGroupUnsupported;

  /// No description provided for @setupCreatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating your dashboard…'**
  String get setupCreatingTitle;

  /// No description provided for @setupReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard is ready'**
  String get setupReadyTitle;

  /// No description provided for @setupReadyBody.
  ///
  /// In en, this message translates to:
  /// **'{count} controls created.'**
  String setupReadyBody(Object count);

  /// No description provided for @setupOpenDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open dashboard'**
  String get setupOpenDashboard;

  /// No description provided for @setupErrUnreachableTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach this address'**
  String get setupErrUnreachableTitle;

  /// No description provided for @setupErrUnreachableBody.
  ///
  /// In en, this message translates to:
  /// **'This device and the Zigbee2MQTT host can\'t reach each other. Check that both are on the same local network.'**
  String get setupErrUnreachableBody;

  /// No description provided for @setupErrUnreachableAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrUnreachableAction;

  /// No description provided for @setupErrPortClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing answers on this port'**
  String get setupErrPortClosedTitle;

  /// No description provided for @setupErrPortClosedBody.
  ///
  /// In en, this message translates to:
  /// **'The host is reachable, but no MQTT broker answered. Check that the broker is running and that the port is correct.'**
  String get setupErrPortClosedBody;

  /// No description provided for @setupErrPortClosedAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrPortClosedAction;

  /// No description provided for @setupErrAuthRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get setupErrAuthRequiredTitle;

  /// No description provided for @setupErrAuthRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This broker needs a username and password.'**
  String get setupErrAuthRequiredBody;

  /// No description provided for @setupErrAuthRequiredAction.
  ///
  /// In en, this message translates to:
  /// **'Enter login'**
  String get setupErrAuthRequiredAction;

  /// No description provided for @setupErrAuthRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Login rejected'**
  String get setupErrAuthRejectedTitle;

  /// No description provided for @setupErrAuthRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'The broker rejected these credentials.'**
  String get setupErrAuthRejectedBody;

  /// No description provided for @setupErrAuthRejectedAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrAuthRejectedAction;

  /// No description provided for @setupErrNotZ2mTitle.
  ///
  /// In en, this message translates to:
  /// **'No Zigbee2MQTT here'**
  String get setupErrNotZ2mTitle;

  /// No description provided for @setupErrNotZ2mBody.
  ///
  /// In en, this message translates to:
  /// **'An MQTT broker answers here, but Zigbee2MQTT topics weren\'t found. It may be a different broker.'**
  String get setupErrNotZ2mBody;

  /// No description provided for @setupErrNotZ2mAction.
  ///
  /// In en, this message translates to:
  /// **'Pick another'**
  String get setupErrNotZ2mAction;

  /// No description provided for @setupErrNoDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'No devices received'**
  String get setupErrNoDevicesTitle;

  /// No description provided for @setupErrNoDevicesBody.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT is running, but no devices were published during the check. Pair devices in Zigbee2MQTT first.'**
  String get setupErrNoDevicesBody;

  /// No description provided for @setupErrNoDevicesAction.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get setupErrNoDevicesAction;

  /// No description provided for @setupErrScanFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'No local network'**
  String get setupErrScanFailedTitle;

  /// No description provided for @setupErrScanFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t determine this device\'s local network. Connect to Wi-Fi and try again.'**
  String get setupErrScanFailedBody;

  /// No description provided for @setupErrScanFailedAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrScanFailedAction;

  /// No description provided for @setupErrSaveFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save'**
  String get setupErrSaveFailedTitle;

  /// No description provided for @setupErrSaveFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Saving your setup failed. Nothing was half-saved — you can safely retry.'**
  String get setupErrSaveFailedBody;

  /// No description provided for @setupErrSaveFailedAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrSaveFailedAction;

  /// No description provided for @setupErrUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get setupErrUnknownTitle;

  /// No description provided for @setupErrUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get setupErrUnknownBody;

  /// No description provided for @setupErrUnknownAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrUnknownAction;

  /// No description provided for @setupNoZ2mTitle.
  ///
  /// In en, this message translates to:
  /// **'Your broker works, but Zigbee2MQTT isn\'t publishing here'**
  String get setupNoZ2mTitle;

  /// No description provided for @setupNoZ2mBody.
  ///
  /// In en, this message translates to:
  /// **'We listened on {base}/bridge and heard nothing.'**
  String setupNoZ2mBody(String base);

  /// No description provided for @setupBaseTopicQuestion.
  ///
  /// In en, this message translates to:
  /// **'Using a different base topic?'**
  String get setupBaseTopicQuestion;

  /// No description provided for @setupGuidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up Zigbee2MQTT'**
  String get setupGuidesTitle;

  /// No description provided for @setupTryDemoMeanwhile.
  ///
  /// In en, this message translates to:
  /// **'Try the demo meanwhile'**
  String get setupTryDemoMeanwhile;

  /// No description provided for @demoBannerText.
  ///
  /// In en, this message translates to:
  /// **'You\'re in demo mode'**
  String get demoBannerText;

  /// No description provided for @demoBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Connect your home'**
  String get demoBannerAction;

  /// No description provided for @deviceOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get deviceOn;

  /// No description provided for @deviceOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get deviceOff;

  /// No description provided for @deviceOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get deviceOpen;

  /// No description provided for @deviceClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get deviceClosed;

  /// No description provided for @deviceMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get deviceMotion;

  /// No description provided for @deviceClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get deviceClear;

  /// No description provided for @deviceLeakDetected.
  ///
  /// In en, this message translates to:
  /// **'Leak detected'**
  String get deviceLeakDetected;

  /// No description provided for @deviceSmokeDetected.
  ///
  /// In en, this message translates to:
  /// **'Smoke detected'**
  String get deviceSmokeDetected;

  /// No description provided for @deviceGasDetected.
  ///
  /// In en, this message translates to:
  /// **'Gas detected'**
  String get deviceGasDetected;

  /// No description provided for @deviceWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for first report'**
  String get deviceWaiting;

  /// No description provided for @deviceEndpointsOnOff.
  ///
  /// In en, this message translates to:
  /// **'{on} on · {off} off'**
  String deviceEndpointsOnOff(int on, int off);

  /// No description provided for @deviceBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get deviceBrightness;

  /// No description provided for @deviceWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get deviceWhite;

  /// No description provided for @deviceColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get deviceColor;

  /// No description provided for @deviceHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get deviceHue;

  /// No description provided for @devicePosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get devicePosition;

  /// No description provided for @deviceControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get deviceControls;

  /// No description provided for @deviceBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery {percent}%'**
  String deviceBattery(int percent);

  /// No description provided for @deviceToggle.
  ///
  /// In en, this message translates to:
  /// **'Turn on or off'**
  String get deviceToggle;

  /// No description provided for @deviceMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get deviceMore;

  /// No description provided for @sectionLights.
  ///
  /// In en, this message translates to:
  /// **'Lights'**
  String get sectionLights;

  /// No description provided for @sectionSwitchesCovers.
  ///
  /// In en, this message translates to:
  /// **'Switches and covers'**
  String get sectionSwitchesCovers;

  /// No description provided for @sectionSensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sectionSensors;

  /// No description provided for @sectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sectionOther;

  /// No description provided for @homeFirstName.
  ///
  /// In en, this message translates to:
  /// **'My Home'**
  String get homeFirstName;

  /// No description provided for @homeNumberedName.
  ///
  /// In en, this message translates to:
  /// **'Home {number}'**
  String homeNumberedName(int number);

  /// No description provided for @dashAddTile.
  ///
  /// In en, this message translates to:
  /// **'Add tile'**
  String get dashAddTile;

  /// No description provided for @addTileSearch.
  ///
  /// In en, this message translates to:
  /// **'Search devices'**
  String get addTileSearch;

  /// No description provided for @addTileNotOnDashboard.
  ///
  /// In en, this message translates to:
  /// **'Not on a dashboard'**
  String get addTileNotOnDashboard;

  /// No description provided for @addTileAllDevices.
  ///
  /// In en, this message translates to:
  /// **'All devices'**
  String get addTileAllDevices;

  /// No description provided for @addTileReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get addTileReading;

  /// No description provided for @addTileReadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One value from a device or topic'**
  String get addTileReadingSubtitle;

  /// No description provided for @addTileCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom MQTT tile'**
  String get addTileCustom;

  /// No description provided for @addTileCustomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Any tile type, set up by topic'**
  String get addTileCustomSubtitle;

  /// No description provided for @addTileNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices to show. Connect to your broker, or pair a device in Zigbee2MQTT.'**
  String get addTileNoDevices;

  /// No description provided for @addTileAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addTileAdd;

  /// No description provided for @addTileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addTileName;

  /// No description provided for @addTileNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. {model}'**
  String addTileNameHint(String model);

  /// No description provided for @addTileSection.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get addTileSection;

  /// No description provided for @addTileNoSection.
  ///
  /// In en, this message translates to:
  /// **'No section'**
  String get addTileNoSection;

  /// No description provided for @addTileSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get addTileSize;

  /// No description provided for @deviceClassColorLight.
  ///
  /// In en, this message translates to:
  /// **'Color light'**
  String get deviceClassColorLight;

  /// No description provided for @deviceClassLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get deviceClassLight;

  /// No description provided for @deviceClassSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch or plug'**
  String get deviceClassSwitch;

  /// No description provided for @deviceClassCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get deviceClassCover;

  /// No description provided for @deviceClassLeak.
  ///
  /// In en, this message translates to:
  /// **'Leak or smoke'**
  String get deviceClassLeak;

  /// No description provided for @deviceClassContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get deviceClassContact;

  /// No description provided for @deviceClassMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get deviceClassMotion;

  /// No description provided for @deviceClassClimate.
  ///
  /// In en, this message translates to:
  /// **'Climate sensor'**
  String get deviceClassClimate;

  /// No description provided for @deviceClassGeneric.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceClassGeneric;

  /// No description provided for @deviceNotResponding.
  ///
  /// In en, this message translates to:
  /// **'Not responding'**
  String get deviceNotResponding;

  /// No description provided for @homeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a home'**
  String get homeAdd;

  /// No description provided for @homeManage.
  ///
  /// In en, this message translates to:
  /// **'Manage homes'**
  String get homeManage;

  /// No description provided for @homeSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch home'**
  String get homeSwitch;

  /// No description provided for @navDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get navDevices;

  /// No description provided for @navScenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get navScenes;

  /// No description provided for @devicesNewDot.
  ///
  /// In en, this message translates to:
  /// **'New devices'**
  String get devicesNewDot;

  /// No description provided for @editEditing.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editEditing;

  /// No description provided for @editDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get editDashboard;

  /// No description provided for @editDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editDone;

  /// No description provided for @editAddSection.
  ///
  /// In en, this message translates to:
  /// **'Add section'**
  String get editAddSection;

  /// No description provided for @editSectionName.
  ///
  /// In en, this message translates to:
  /// **'Section name'**
  String get editSectionName;

  /// No description provided for @editRenameSection.
  ///
  /// In en, this message translates to:
  /// **'Rename section'**
  String get editRenameSection;

  /// No description provided for @editDeleteSection.
  ///
  /// In en, this message translates to:
  /// **'Delete section'**
  String get editDeleteSection;

  /// No description provided for @editDeleteSectionBody.
  ///
  /// In en, this message translates to:
  /// **'What should happen to its tiles?'**
  String get editDeleteSectionBody;

  /// No description provided for @editKeepTiles.
  ///
  /// In en, this message translates to:
  /// **'Keep tiles, remove section'**
  String get editKeepTiles;

  /// No description provided for @editDeleteTiles.
  ///
  /// In en, this message translates to:
  /// **'Delete tiles too'**
  String get editDeleteTiles;

  /// No description provided for @editMoveToSection.
  ///
  /// In en, this message translates to:
  /// **'Move to section'**
  String get editMoveToSection;

  /// No description provided for @editEditTile.
  ///
  /// In en, this message translates to:
  /// **'Edit tile'**
  String get editEditTile;

  /// No description provided for @editRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from dashboard'**
  String get editRemove;

  /// No description provided for @editRemoved.
  ///
  /// In en, this message translates to:
  /// **'Tile removed'**
  String get editRemoved;

  /// No description provided for @editUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get editUndo;

  /// No description provided for @editReplaceWithDevice.
  ///
  /// In en, this message translates to:
  /// **'Replace with device tile'**
  String get editReplaceWithDevice;

  /// No description provided for @editMoveEarlier.
  ///
  /// In en, this message translates to:
  /// **'Move earlier'**
  String get editMoveEarlier;

  /// No description provided for @editMoveLater.
  ///
  /// In en, this message translates to:
  /// **'Move later'**
  String get editMoveLater;

  /// No description provided for @editUnassigned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device isn\'t on any dashboard} other{{count} devices aren\'t on any dashboard}}'**
  String editUnassigned(int count);

  /// No description provided for @editTileActions.
  ///
  /// In en, this message translates to:
  /// **'Tile options'**
  String get editTileActions;

  /// No description provided for @editSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editSave;

  /// No description provided for @editCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editCancel;

  /// No description provided for @ageJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get ageJustNow;

  /// No description provided for @ageMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String ageMinutes(int n);

  /// No description provided for @ageHours.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String ageHours(int n);

  /// No description provided for @statusCantReach.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach your broker'**
  String get statusCantReach;

  /// No description provided for @statusWhy.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get statusWhy;

  /// No description provided for @statusWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your broker isn\'t answering'**
  String get statusWhyTitle;

  /// No description provided for @statusWhyBody.
  ///
  /// In en, this message translates to:
  /// **'ZigDash keeps trying on its own. Until it\'s back, tiles show their last known values, dimmed, with their age. Check that the broker is on and this phone is on the same network, or test the connection in its settings.'**
  String get statusWhyBody;

  /// No description provided for @statusSettings.
  ///
  /// In en, this message translates to:
  /// **'Connection settings'**
  String get statusSettings;

  /// No description provided for @deviceAddToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Add to a dashboard'**
  String get deviceAddToDashboard;

  /// No description provided for @deviceDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get deviceDismiss;

  /// No description provided for @devicesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get devicesFilterAll;

  /// No description provided for @devicesFilterAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention · {count}'**
  String devicesFilterAttention(int count);

  /// No description provided for @devicesFilterUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Not on a dashboard · {count}'**
  String devicesFilterUnassigned(int count);

  /// No description provided for @devicesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No devices match'**
  String get devicesNoMatch;

  /// No description provided for @deviceBatteryLow.
  ///
  /// In en, this message translates to:
  /// **'Battery low'**
  String get deviceBatteryLow;

  /// No description provided for @deviceLinkWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get deviceLinkWeak;

  /// No description provided for @deviceUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported by Zigbee2MQTT'**
  String get deviceUnsupported;

  /// No description provided for @deviceInterviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Pairing didn\'t finish'**
  String get deviceInterviewFailed;

  /// No description provided for @deviceNoReport.
  ///
  /// In en, this message translates to:
  /// **'No report yet'**
  String get deviceNoReport;

  /// No description provided for @devicesAvailabilityOff.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT availability is off, so offline devices show as Not responding.'**
  String get devicesAvailabilityOff;

  /// No description provided for @devicesAvailabilityHow.
  ///
  /// In en, this message translates to:
  /// **'How to turn it on'**
  String get devicesAvailabilityHow;

  /// No description provided for @devicesDotBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery low'**
  String get devicesDotBattery;

  /// No description provided for @deviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Device details'**
  String get deviceDetails;

  /// No description provided for @deviceGone.
  ///
  /// In en, this message translates to:
  /// **'This device is no longer in Zigbee2MQTT.'**
  String get deviceGone;

  /// No description provided for @deviceControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get deviceControlTitle;

  /// No description provided for @deviceReadingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get deviceReadingsTitle;

  /// No description provided for @deviceHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get deviceHealthTitle;

  /// No description provided for @deviceOnDashboards.
  ///
  /// In en, this message translates to:
  /// **'On dashboards'**
  String get deviceOnDashboards;

  /// No description provided for @deviceUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT doesn\'t support this device yet, so there is nothing to control.'**
  String get deviceUnsupportedBody;

  /// No description provided for @deviceAddReadingTile.
  ///
  /// In en, this message translates to:
  /// **'Add as reading tile'**
  String get deviceAddReadingTile;

  /// No description provided for @deviceAddReadingTo.
  ///
  /// In en, this message translates to:
  /// **'Add to which dashboard?'**
  String get deviceAddReadingTo;

  /// No description provided for @deviceAddedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to {dashboard}'**
  String deviceAddedTo(Object dashboard);

  /// No description provided for @deviceLinkQuality.
  ///
  /// In en, this message translates to:
  /// **'Link quality'**
  String get deviceLinkQuality;

  /// No description provided for @deviceLinkGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get deviceLinkGood;

  /// No description provided for @devicePowerSource.
  ///
  /// In en, this message translates to:
  /// **'Power source'**
  String get devicePowerSource;

  /// No description provided for @devicePowerBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get devicePowerBattery;

  /// No description provided for @devicePowerMains.
  ///
  /// In en, this message translates to:
  /// **'Mains'**
  String get devicePowerMains;

  /// No description provided for @deviceLastHeard.
  ///
  /// In en, this message translates to:
  /// **'Last heard'**
  String get deviceLastHeard;

  /// No description provided for @deviceAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get deviceAvailability;

  /// No description provided for @deviceAvailabilityOff.
  ///
  /// In en, this message translates to:
  /// **'Off in Zigbee2MQTT'**
  String get deviceAvailabilityOff;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No telemetry. Everything stays on this phone.'**
  String get settingsPrivacySubtitle;

  /// No description provided for @homeCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current home'**
  String get homeCurrent;

  /// No description provided for @homeConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get homeConnection;

  /// No description provided for @homeSwitchTo.
  ///
  /// In en, this message translates to:
  /// **'Switch to this home'**
  String get homeSwitchTo;

  /// No description provided for @homeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete home'**
  String get homeDelete;

  /// No description provided for @devicesSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a device'**
  String get devicesSelect;

  /// No description provided for @scenesSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a scene to edit'**
  String get scenesSelect;

  /// No description provided for @panelFormTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get panelFormTopic;

  /// No description provided for @panelFormPickDevice.
  ///
  /// In en, this message translates to:
  /// **'Pick a device'**
  String get panelFormPickDevice;

  /// No description provided for @panelFormStateTopic.
  ///
  /// In en, this message translates to:
  /// **'State topic'**
  String get panelFormStateTopic;

  /// No description provided for @panelFormCommandTopic.
  ///
  /// In en, this message translates to:
  /// **'Command topic'**
  String get panelFormCommandTopic;

  /// No description provided for @panelFormCommandTopicDerived.
  ///
  /// In en, this message translates to:
  /// **'Filled from the state topic until you change it.'**
  String get panelFormCommandTopicDerived;

  /// No description provided for @panelFormLinkedTo.
  ///
  /// In en, this message translates to:
  /// **'Linked to {device}'**
  String panelFormLinkedTo(Object device);

  /// No description provided for @panelFormOpenDevice.
  ///
  /// In en, this message translates to:
  /// **'Open device'**
  String get panelFormOpenDevice;

  /// No description provided for @panelFormUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get panelFormUnlink;

  /// No description provided for @panelFormValueChoices.
  ///
  /// In en, this message translates to:
  /// **'Values from this device'**
  String get panelFormValueChoices;

  /// No description provided for @panelFormAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get panelFormAdvanced;

  /// No description provided for @panelFormAdvancedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prefix override, QoS, retain'**
  String get panelFormAdvancedSubtitle;

  /// No description provided for @panelFormStateTopicHelper.
  ///
  /// In en, this message translates to:
  /// **'Blank = the prefix itself (a Zigbee2MQTT device\'s state).'**
  String get panelFormStateTopicHelper;

  /// No description provided for @dashWallDisplay.
  ///
  /// In en, this message translates to:
  /// **'Wall display'**
  String get dashWallDisplay;

  /// No description provided for @analyticsSetupCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data to help improve setup'**
  String get analyticsSetupCheckbox;

  /// No description provided for @analyticsWhatsShared.
  ///
  /// In en, this message translates to:
  /// **'What\'s shared'**
  String get analyticsWhatsShared;

  /// No description provided for @analyticsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Help improve ZigDash?'**
  String get analyticsCardTitle;

  /// No description provided for @analyticsCardBody.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data: which setup steps fail and which features get used. Never your devices, topics or broker.'**
  String get analyticsCardBody;

  /// No description provided for @analyticsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get analyticsShare;

  /// No description provided for @analyticsNoThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get analyticsNoThanks;

  /// No description provided for @settingsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data'**
  String get settingsAnalytics;

  /// No description provided for @settingsAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Setup steps and features used. Never your devices, topics or broker.'**
  String get settingsAnalyticsSubtitle;

  /// No description provided for @settingsPrivacySubtitleOptIn.
  ///
  /// In en, this message translates to:
  /// **'Anonymous usage data only if you opt in.'**
  String get settingsPrivacySubtitleOptIn;

  /// No description provided for @dashDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashDefaultName;

  /// No description provided for @dashExportSaveFile.
  ///
  /// In en, this message translates to:
  /// **'Save file'**
  String get dashExportSaveFile;

  /// No description provided for @dashExportSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get dashExportSaved;

  /// No description provided for @dashImportChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get dashImportChooseFile;

  /// No description provided for @dashImportFileUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that file'**
  String get dashImportFileUnreadable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'he',
    'nb',
    'nl',
    'pl',
    'pt',
    'ru',
    'sv',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
