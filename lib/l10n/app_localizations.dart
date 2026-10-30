import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_it.dart';
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
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('it'),
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
  /// **'The broker IP is the hub\'s IP address. Open the hub\'s web page (smhub.local): on the Dashboard, the Network box shows it next to IPv4. Your router\'s app also lists the hub as SMHUB. Port is 1883, with no username/password by default.'**
  String get connHelpSmhubBody;

  /// No description provided for @connHelpZhaTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant ZHA'**
  String get connHelpZhaTitle;

  /// No description provided for @connHelpZhaBody.
  ///
  /// In en, this message translates to:
  /// **'ZHA has no MQTT broker — it talks to Home Assistant directly, so ZigDash can\'t connect to it. To use ZigDash, switch to Zigbee2MQTT (available as a Home Assistant app or a Docker container), which provides an MQTT broker.'**
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

  /// No description provided for @connUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get connUsername;

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
  /// **'Edit lock'**
  String get dashFormLock;

  /// No description provided for @dashFormLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hides Edit for this dashboard'**
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

  /// No description provided for @settingsFeatureRequest.
  ///
  /// In en, this message translates to:
  /// **'Request a feature'**
  String get settingsFeatureRequest;

  /// No description provided for @settingsFeatureRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell me what would make ZigDash better.'**
  String get settingsFeatureRequestSubtitle;

  /// No description provided for @featureRequestGithub.
  ///
  /// In en, this message translates to:
  /// **'On GitHub'**
  String get featureRequestGithub;

  /// No description provided for @featureRequestGithubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Public: others can see it and vote for it.'**
  String get featureRequestGithubSubtitle;

  /// No description provided for @featureRequestEmail.
  ///
  /// In en, this message translates to:
  /// **'By email'**
  String get featureRequestEmail;

  /// No description provided for @featureRequestEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Private, straight to the developer.'**
  String get featureRequestEmailSubtitle;

  /// No description provided for @featureRequestEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'ZigDash feature request'**
  String get featureRequestEmailSubject;

  /// No description provided for @featureRequestEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'What would you like ZigDash to do, and why?'**
  String get featureRequestEmailPrompt;

  /// No description provided for @settingsReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get settingsReportProblem;

  /// No description provided for @settingsReportProblemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something broken or confusing? Tell me.'**
  String get settingsReportProblemSubtitle;

  /// No description provided for @reportProblemEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'ZigDash problem report'**
  String get reportProblemEmailSubject;

  /// No description provided for @reportProblemEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'What happened, and what did you expect?'**
  String get reportProblemEmailPrompt;

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

  /// No description provided for @devicesListMissing.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT hasn\'t sent its device list. This can happen after the MQTT broker restarts.'**
  String get devicesListMissing;

  /// No description provided for @devicesRestartZ2m.
  ///
  /// In en, this message translates to:
  /// **'Restart Zigbee2MQTT'**
  String get devicesRestartZ2m;

  /// No description provided for @devicesRestartingZ2m.
  ///
  /// In en, this message translates to:
  /// **'Restarting Zigbee2MQTT. Your devices should appear in a few seconds.'**
  String get devicesRestartingZ2m;

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

  /// No description provided for @scenesAllShutters.
  ///
  /// In en, this message translates to:
  /// **'All shutters'**
  String get scenesAllShutters;

  /// No description provided for @sceneCloseAllShutters.
  ///
  /// In en, this message translates to:
  /// **'Close all shutters'**
  String get sceneCloseAllShutters;

  /// No description provided for @sceneOpenAllShutters.
  ///
  /// In en, this message translates to:
  /// **'Open all shutters'**
  String get sceneOpenAllShutters;

  /// No description provided for @sceneStopAllShutters.
  ///
  /// In en, this message translates to:
  /// **'Stop all shutters'**
  String get sceneStopAllShutters;

  /// No description provided for @sceneShuttersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shutter} other{{count} shutters}}'**
  String sceneShuttersCount(int count);

  /// No description provided for @sceneWhichShutters.
  ///
  /// In en, this message translates to:
  /// **'Which shutters…'**
  String get sceneWhichShutters;

  /// No description provided for @sceneWhichShuttersHint.
  ///
  /// In en, this message translates to:
  /// **'Every shutter in this Home is included. Untick any that should stay out, like a garage door.'**
  String get sceneWhichShuttersHint;

  /// No description provided for @scenesYours.
  ///
  /// In en, this message translates to:
  /// **'Your scenes'**
  String get scenesYours;

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
  /// **'The broker didn\'t accept the connection. Check that your MQTT broker (usually Mosquitto) is running and accepts connections from other devices, and that the address and port (usually 1883) are right.'**
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

  /// No description provided for @diagLoginNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'The broker didn\'t answer the login in time. Home Assistant can take a few seconds to check it, so try again.'**
  String get diagLoginNoAnswer;

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

  /// Broker test: the name ends in .local and could not be looked up (2.9.3). Settings › System › Network is Home Assistant's own menu path.
  ///
  /// In en, this message translates to:
  /// **'Your phone couldn\'t find this name. Android often can\'t look up names ending in .local, so enter the IP address instead (Home Assistant shows it under Settings › System › Network).'**
  String get diagResolveLocalName;

  /// No description provided for @diagTcpHaNoBroker.
  ///
  /// In en, this message translates to:
  /// **'This is your Home Assistant, but no MQTT broker is running on it. Install and start the Mosquitto broker app (Settings › Apps), then try again.'**
  String get diagTcpHaNoBroker;

  /// Broker test: port 1883 refused on an SMLIGHT hub (2.9.5). Settings › MQTT and Allow External are the hub's own English labels; keep them in English.
  ///
  /// In en, this message translates to:
  /// **'This is your SMLIGHT hub, but its MQTT broker doesn\'t accept connections from other devices. In the hub\'s web page, open Settings › MQTT, turn on Allow External, save, then try again.'**
  String get diagTcpSmlightClosed;

  /// No description provided for @diagTcpZ2mBrokerElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT runs at this address, but it reaches its broker under another name (see Zigbee2MQTT\'s Settings › MQTT › Server). If that is another machine, type its address, usually with port 1883. If it is a container on this machine, publish its port (ports: \"1883:1883\") and let it listen to the network, then try again.'**
  String get diagTcpZ2mBrokerElsewhere;

  /// Broker test: port 1883 refused on a machine serving the Zigbee2MQTT web page (2.9.5). The quoted lines are mosquitto.conf syntax; keep them as is.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT runs at this address, but its MQTT broker doesn\'t accept connections from other devices. Mosquitto listens only on its own machine until you add the lines \"listener 1883\" and \"allow_anonymous true\" to mosquitto.conf (or set up a password). Restart Mosquitto, then try again.'**
  String get diagTcpZ2mNoBroker;

  /// No description provided for @diagAuthRejectedHa.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant\'s broker refused this login. Use the name and password of a Home Assistant user (Settings › People › Users); a separate user just for MQTT works best.'**
  String get diagAuthRejectedHa;

  /// No description provided for @foundDevices.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 device} other{Found {count} devices}}'**
  String foundDevices(int count);

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

  /// No description provided for @guidedStuckTitle.
  ///
  /// In en, this message translates to:
  /// **'Stuck? Ask a person'**
  String get guidedStuckTitle;

  /// No description provided for @guidedStuckBody.
  ///
  /// In en, this message translates to:
  /// **'Two tries without a connection. Tell us which hub you have and what you typed, and we\'ll help you find it.'**
  String get guidedStuckBody;

  /// No description provided for @guidedStuckTelegram.
  ///
  /// In en, this message translates to:
  /// **'Ask in Telegram'**
  String get guidedStuckTelegram;

  /// No description provided for @guidedStuckHelp.
  ///
  /// In en, this message translates to:
  /// **'Tips and email'**
  String get guidedStuckHelp;

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

  /// No description provided for @setupWelcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your Zigbee home, on your phone'**
  String get setupWelcomeHeadline;

  /// No description provided for @setupWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A small hub running Zigbee2MQTT is all you need: an SMLIGHT hub, a Raspberry Pi or any Linux box. No Home Assistant needed, and if you have it, ZigDash works with it too. Everything stays local, with no cloud.'**
  String get setupWelcomeBody;

  /// No description provided for @setupFindMySetup.
  ///
  /// In en, this message translates to:
  /// **'Find my setup'**
  String get setupFindMySetup;

  /// No description provided for @setupErrPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT\'s page didn\'t answer'**
  String get setupErrPageTitle;

  /// No description provided for @setupErrPageBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing answered as a Zigbee2MQTT page at that address. Open it in this phone\'s browser to check it, and copy the address exactly (with its port, often 8080). If the page asks for a token, enter your broker details instead.'**
  String get setupErrPageBody;

  /// No description provided for @setupErrPageAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrPageAction;

  /// No description provided for @setupLookWider.
  ///
  /// In en, this message translates to:
  /// **'Look on the whole network'**
  String get setupLookWider;

  /// No description provided for @setupAsk.
  ///
  /// In en, this message translates to:
  /// **'What runs your Zigbee?'**
  String get setupAsk;

  /// No description provided for @setupAskZ2m.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT'**
  String get setupAskZ2m;

  /// No description provided for @setupAskZ2mSub.
  ///
  /// In en, this message translates to:
  /// **'On a Raspberry Pi, a server or Docker'**
  String get setupAskZ2mSub;

  /// No description provided for @setupAskHa.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant'**
  String get setupAskHa;

  /// No description provided for @setupAskHaSub.
  ///
  /// In en, this message translates to:
  /// **'With the Zigbee2MQTT app, or ZHA'**
  String get setupAskHaSub;

  /// No description provided for @setupAskSmlight.
  ///
  /// In en, this message translates to:
  /// **'An SMLIGHT hub'**
  String get setupAskSmlight;

  /// No description provided for @setupAskSmlightSub.
  ///
  /// In en, this message translates to:
  /// **'SLZB or SMHUB running Zigbee2MQTT'**
  String get setupAskSmlightSub;

  /// No description provided for @setupAskNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet?'**
  String get setupAskNothing;

  /// No description provided for @setupAskHaWhich.
  ///
  /// In en, this message translates to:
  /// **'How does your Home Assistant run Zigbee?'**
  String get setupAskHaWhich;

  /// No description provided for @setupAskHaZ2m.
  ///
  /// In en, this message translates to:
  /// **'The Zigbee2MQTT app'**
  String get setupAskHaZ2m;

  /// No description provided for @setupAskHaZ2mSub.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Home Assistant'**
  String get setupAskHaZ2mSub;

  /// No description provided for @setupAskHaZha.
  ///
  /// In en, this message translates to:
  /// **'ZHA, Home Assistant\'s own Zigbee'**
  String get setupAskHaZha;

  /// No description provided for @setupAskHaZhaSub.
  ///
  /// In en, this message translates to:
  /// **'Zigbee Home Automation, no Zigbee2MQTT'**
  String get setupAskHaZhaSub;

  /// No description provided for @setupZ2mPageEntry.
  ///
  /// In en, this message translates to:
  /// **'Connect to my Zigbee2MQTT page'**
  String get setupZ2mPageEntry;

  /// No description provided for @setupManualEntryAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Enter broker details (advanced)'**
  String get setupManualEntryAdvanced;

  /// No description provided for @z2mPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Zigbee2MQTT page'**
  String get z2mPageTitle;

  /// No description provided for @z2mPageBody.
  ///
  /// In en, this message translates to:
  /// **'The address in your browser when the Zigbee2MQTT page is open, the one you pair devices on. No MQTT username or password needed.'**
  String get z2mPageBody;

  /// No description provided for @z2mPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page address'**
  String get z2mPageLabel;

  /// No description provided for @z2mPageConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get z2mPageConnect;

  /// No description provided for @z2mPageFoundName.
  ///
  /// In en, this message translates to:
  /// **'Found {host} at {ip}'**
  String z2mPageFoundName(String host, String ip);

  /// No description provided for @z2mPageNoName.
  ///
  /// In en, this message translates to:
  /// **'Nothing answered for {host} on this network'**
  String z2mPageNoName(String host);

  /// No description provided for @engineNeedsBrokerTitle.
  ///
  /// In en, this message translates to:
  /// **'Automations need your MQTT broker'**
  String get engineNeedsBrokerTitle;

  /// No description provided for @engineNeedsBrokerBody.
  ///
  /// In en, this message translates to:
  /// **'This home connects through the Zigbee2MQTT page, which is all your dashboards need. Automations, Alerts and history run in the ZigDash Engine on your hub, which talks through your MQTT broker. Add its details once, and ZigDash connects through the broker from then on.'**
  String get engineNeedsBrokerBody;

  /// No description provided for @engineNeedsBrokerButton.
  ///
  /// In en, this message translates to:
  /// **'Add broker details'**
  String get engineNeedsBrokerButton;

  /// No description provided for @connFromPageNote.
  ///
  /// In en, this message translates to:
  /// **'This home connects through the Zigbee2MQTT page. Enter your MQTT broker (usually the same machine, port 1883) to turn on Automations, Alerts and history. After saving, ZigDash connects through the broker.'**
  String get connFromPageNote;

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
  /// **'Home Assistant: make sure the Mosquitto broker app and the Zigbee2MQTT app are installed and running (Settings › Apps).'**
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

  /// No description provided for @reminderButton.
  ///
  /// In en, this message translates to:
  /// **'Remind me tomorrow'**
  String get reminderButton;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you tomorrow, on this phone.'**
  String get reminderSet;

  /// No description provided for @reminderNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for ZigDash, so there\'s no reminder. You can turn them on in Android\'s settings.'**
  String get reminderNoPermission;

  /// No description provided for @reminderChannel.
  ///
  /// In en, this message translates to:
  /// **'Setup reminder'**
  String get reminderChannel;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up ZigDash'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'At home on your Wi-Fi? Tap to try again: it takes about a minute.'**
  String get reminderBody;

  /// No description provided for @setupWelcomeNoZ2m.
  ///
  /// In en, this message translates to:
  /// **'No Zigbee2MQTT yet?'**
  String get setupWelcomeNoZ2m;

  /// No description provided for @setupWelcomeDemo.
  ///
  /// In en, this message translates to:
  /// **'Try the demo home'**
  String get setupWelcomeDemo;

  /// No description provided for @setupWelcomeHubs.
  ///
  /// In en, this message translates to:
  /// **'Which hub to get'**
  String get setupWelcomeHubs;

  /// No description provided for @haConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect through Home Assistant'**
  String get haConnectTitle;

  /// No description provided for @haConnectIntro.
  ///
  /// In en, this message translates to:
  /// **'Your phone can\'t reach the broker, but it can reach Home Assistant. Sign in once, and ZigDash talks to Zigbee2MQTT through Home Assistant: at home or away, with no broker settings.'**
  String get haConnectIntro;

  /// No description provided for @haConnectAddressHelp.
  ///
  /// In en, this message translates to:
  /// **'The address you open Home Assistant with: 192.168.1.20:8123, or a remote address like your Nabu Casa or Cloudflare address'**
  String get haConnectAddressHelp;

  /// No description provided for @haConnectSignInHelp.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant\'s own login opens in your browser. ZigDash never sees your password.'**
  String get haConnectSignInHelp;

  /// No description provided for @haConnectKeeps.
  ///
  /// In en, this message translates to:
  /// **'ZigDash keeps this sign-in on your phone and acts as you in Home Assistant, for MQTT only. End it any time in Home Assistant under Profile › Security.'**
  String get haConnectKeeps;

  /// No description provided for @haConnectTokenHelp.
  ///
  /// In en, this message translates to:
  /// **'In Home Assistant, open your profile, then Security › Long-lived access tokens › Create token. Copy it and paste it here. ZigDash keeps it on this phone to connect; delete it in Home Assistant whenever you want to end that.'**
  String get haConnectTokenHelp;

  /// No description provided for @haConnectWithToken.
  ///
  /// In en, this message translates to:
  /// **'Connect with token'**
  String get haConnectWithToken;

  /// No description provided for @haConnectChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking Home Assistant…'**
  String get haConnectChecking;

  /// No description provided for @setupStillChecking.
  ///
  /// In en, this message translates to:
  /// **'Still checking. This can take up to 30 seconds.'**
  String get setupStillChecking;

  /// No description provided for @aiHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Stuck? Ask your AI assistant'**
  String get aiHelpTitle;

  /// No description provided for @aiHelpBody.
  ///
  /// In en, this message translates to:
  /// **'ZigDash writes up what it found for ChatGPT, Claude, Gemini or any AI app, without passwords or addresses. You see it before it\'s shared.'**
  String get aiHelpBody;

  /// No description provided for @aiHelpButton.
  ///
  /// In en, this message translates to:
  /// **'Ask an AI'**
  String get aiHelpButton;

  /// No description provided for @aiHelpPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'What will be shared'**
  String get aiHelpPreviewTitle;

  /// No description provided for @aiHelpShare.
  ///
  /// In en, this message translates to:
  /// **'Share to an AI app'**
  String get aiHelpShare;

  /// No description provided for @aiHelpCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied. Paste it into any AI chat.'**
  String get aiHelpCopied;

  /// No description provided for @haConnectWhereAddress.
  ///
  /// In en, this message translates to:
  /// **'Not sure what it is? In the Home Assistant app, open Settings › Companion app and tap your server: its address is there. On a computer, it\'s what the browser shows when Home Assistant is open.'**
  String get haConnectWhereAddress;

  /// No description provided for @haFindLooking.
  ///
  /// In en, this message translates to:
  /// **'Looking for Home Assistant on this network…'**
  String get haFindLooking;

  /// No description provided for @haFindSeveral.
  ///
  /// In en, this message translates to:
  /// **'Found more than one Home Assistant. Tap the one to use:'**
  String get haFindSeveral;

  /// No description provided for @haFindNone.
  ///
  /// In en, this message translates to:
  /// **'This phone can\'t see Home Assistant on this Wi-Fi. Use the address your Home Assistant app opens: often a remote one, like https://abcd1234.ui.nabu.casa or https://myhome.duckdns.org.'**
  String get haFindNone;

  /// No description provided for @haConnectOtherNetwork.
  ///
  /// In en, this message translates to:
  /// **'That address is on a different network from this phone, which is on {network}. Use the address your Home Assistant app opens, often a remote one, or connect the phone to the network Home Assistant is on.'**
  String haConnectOtherNetwork(String network);

  /// No description provided for @haConnectLocalNameUnreachable.
  ///
  /// In en, this message translates to:
  /// **'This phone couldn\'t find that name: Android often can\'t open .local names. Type Home Assistant\'s IP address (like 192.168.1.20:8123), or its remote address.'**
  String get haConnectLocalNameUnreachable;

  /// No description provided for @haConnectRemoteUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Nothing answered at that remote address. Open it in this phone\'s browser to check that it works, and copy it exactly as your Home Assistant app shows it.'**
  String get haConnectRemoteUnreachable;

  /// No description provided for @setupNoWifiHa.
  ///
  /// In en, this message translates to:
  /// **'Use Home Assistant? Sign in'**
  String get setupNoWifiHa;

  /// No description provided for @haConnectNotAdmin.
  ///
  /// In en, this message translates to:
  /// **'Your Home Assistant user isn\'t an administrator. ZigDash needs one for Home Assistant\'s MQTT. Sign in as an administrator, or paste a token an administrator created.'**
  String get haConnectNotAdmin;

  /// No description provided for @haConnectNoMqtt.
  ///
  /// In en, this message translates to:
  /// **'This Home Assistant has no MQTT integration. Zigbee2MQTT needs one too: in Home Assistant, add the Mosquitto broker app (Settings › Apps) and the MQTT integration, then try again.'**
  String get haConnectNoMqtt;

  /// No description provided for @haConnectSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'The sign-in didn\'t complete. Try again, or use a long-lived token.'**
  String get haConnectSignInFailed;

  /// Setup, when Zigbee2MQTT runs in Home Assistant: the Home Assistant sign-in instead of the broker (3.1.2).
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT runs in Home Assistant? Skip the broker and its login: sign in with your Home Assistant admin account. It works from any network.'**
  String get setupHaShortcut;

  /// No description provided for @haConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect through Home Assistant'**
  String get haConnectButton;

  /// No description provided for @haConnectManualLink.
  ///
  /// In en, this message translates to:
  /// **'Using Home Assistant? Connect through it instead'**
  String get haConnectManualLink;

  /// No description provided for @haConnectEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the broker from this phone? Home Assistant can carry the connection for you.'**
  String get haConnectEmptyNote;

  /// No description provided for @haHomeConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected through Home Assistant'**
  String get haHomeConnected;

  /// No description provided for @haHomeChange.
  ///
  /// In en, this message translates to:
  /// **'If the sign-in stops working, on a new phone or after you removed the token in Home Assistant, sign in again here. You can also end it in Home Assistant under Profile › Security.'**
  String get haHomeChange;

  /// No description provided for @haHomeSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get haHomeSignInAgain;

  /// No description provided for @haHomeRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote Home Assistant address (optional)'**
  String get haHomeRemote;

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

  /// No description provided for @setupAuthRejectedZ2m.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT already logs in to this broker: its web page shows the username under Settings › MQTT. Use that user and its password.'**
  String get setupAuthRejectedZ2m;

  /// Setup, login step: where the MQTT login comes from (setup-help-2.5.md).
  ///
  /// In en, this message translates to:
  /// **'This is the MQTT login, not the password of your hub\'s web page.'**
  String get setupAuthWhich;

  /// No description provided for @setupAuthHintHa.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant: use a Home Assistant user. Most people create one just for MQTT under Settings › People › Users, and the Mosquitto broker app accepts it.'**
  String get setupAuthHintHa;

  /// No description provided for @setupAuthHintPi.
  ///
  /// In en, this message translates to:
  /// **'Raspberry Pi or Docker: the user and password from Mosquitto\'s password file, the same ones in Zigbee2MQTT\'s configuration.yaml under mqtt.'**
  String get setupAuthHintPi;

  /// No description provided for @setupAuthHintSmlight.
  ///
  /// In en, this message translates to:
  /// **'SMLIGHT: the login shown on the hub\'s web page under Settings › MQTT. Or turn on Allow Anonymous there and save: then no login is needed.'**
  String get setupAuthHintSmlight;

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
  /// **'{count, plural, =1{1 device found.} other{{count} devices found.}} Choose what goes on your first dashboard.'**
  String setupReviewSubtitle(int count);

  /// No description provided for @setupReviewLastStep.
  ///
  /// In en, this message translates to:
  /// **'Last step: tick the devices you want, then tap Create dashboard below.'**
  String get setupReviewLastStep;

  /// No description provided for @setupLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your dashboard?'**
  String get setupLeaveTitle;

  /// No description provided for @setupLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your devices are found. Create the dashboard now, or start setup over and lose this list.'**
  String get setupLeaveBody;

  /// No description provided for @setupStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get setupStartOver;

  /// No description provided for @setupCreateWithCount.
  ///
  /// In en, this message translates to:
  /// **'Create dashboard with {count}'**
  String setupCreateWithCount(Object count);

  /// No description provided for @setupReviewNoneSelected.
  ///
  /// In en, this message translates to:
  /// **'Nothing is ticked yet. Tick the devices you want on the dashboard, or create it empty and add tiles later.'**
  String get setupReviewNoneSelected;

  /// No description provided for @setupCreateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Create an empty dashboard'**
  String get setupCreateEmpty;

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

  /// No description provided for @setupErrListMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT didn\'t send its device list'**
  String get setupErrListMissingTitle;

  /// No description provided for @setupErrListMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT answers, but its device list didn\'t come. This usually happens after the MQTT broker restarts: Zigbee2MQTT before 2.14.2 only sends the list again when it restarts. Restart Zigbee2MQTT (or update it), then try again.'**
  String get setupErrListMissingBody;

  /// No description provided for @setupErrListMissingAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrListMissingAction;

  /// No description provided for @setupErrHaNoZ2mTitle.
  ///
  /// In en, this message translates to:
  /// **'No Zigbee2MQTT in this Home Assistant'**
  String get setupErrHaNoZ2mTitle;

  /// No description provided for @setupErrHaNoZ2mBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in to Home Assistant, but Zigbee2MQTT isn\'t sending anything on its MQTT. If your Zigbee devices are in ZHA (Home Assistant\'s built-in Zigbee), ZigDash can\'t see them: it works with Zigbee2MQTT. If you use the Zigbee2MQTT app, open it under Settings › Apps, check that it\'s started, then try again.'**
  String get setupErrHaNoZ2mBody;

  /// No description provided for @setupErrHaNoZ2mAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrHaNoZ2mAction;

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

  /// No description provided for @setupNoWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Your phone isn\'t on Wi-Fi'**
  String get setupNoWifiTitle;

  /// No description provided for @setupNoWifiMobileData.
  ///
  /// In en, this message translates to:
  /// **'It\'s using mobile data, so it can\'t see the devices at home. Turn on Wi-Fi and join your home network: setup starts again by itself.'**
  String get setupNoWifiMobileData;

  /// No description provided for @setupNoWifiOffline.
  ///
  /// In en, this message translates to:
  /// **'Your phone has no network connection. Turn on Wi-Fi and join your home network: setup starts again by itself.'**
  String get setupNoWifiOffline;

  /// No description provided for @setupNoWifiUnknown.
  ///
  /// In en, this message translates to:
  /// **'ZigDash can\'t find your phone\'s Wi-Fi address. Check that Wi-Fi is on and joined to your home network: setup starts again by itself. On a VPN or away from home? Enter the details manually.'**
  String get setupNoWifiUnknown;

  /// No description provided for @setupOpenWifiSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Wi-Fi settings'**
  String get setupOpenWifiSettings;

  /// No description provided for @setupWaitingForWifi.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Wi-Fi…'**
  String get setupWaitingForWifi;

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

  /// No description provided for @setupErrLoginNoAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'The broker didn\'t answer the login'**
  String get setupErrLoginNoAnswerTitle;

  /// No description provided for @setupErrLoginNoAnswerBody.
  ///
  /// In en, this message translates to:
  /// **'Your broker was found, but it didn\'t answer the username and password in time. Home Assistant\'s Mosquitto broker app checks logins with Home Assistant, which can take a few seconds on a Raspberry Pi. Try again, and check that this user exists in Home Assistant. On an SMLIGHT hub, turn on Allow Anonymous under Settings › MQTT instead, and no login is needed.'**
  String get setupErrLoginNoAnswerBody;

  /// No description provided for @setupErrLoginNoAnswerAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get setupErrLoginNoAnswerAction;

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

  /// No description provided for @setupPlatformQuestion.
  ///
  /// In en, this message translates to:
  /// **'While we look: where does Zigbee2MQTT run?'**
  String get setupPlatformQuestion;

  /// No description provided for @setupPlatformQuestionDone.
  ///
  /// In en, this message translates to:
  /// **'Where does Zigbee2MQTT run?'**
  String get setupPlatformQuestionDone;

  /// No description provided for @setupScanDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a connection'**
  String get setupScanDoneTitle;

  /// No description provided for @setupScanDoneHint.
  ///
  /// In en, this message translates to:
  /// **'More than one broker answered. Pick the one Zigbee2MQTT uses.'**
  String get setupScanDoneHint;

  /// No description provided for @setupPlatformHa.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant'**
  String get setupPlatformHa;

  /// No description provided for @setupPlatformSmlight.
  ///
  /// In en, this message translates to:
  /// **'SMLIGHT hub'**
  String get setupPlatformSmlight;

  /// No description provided for @setupPlatformPi.
  ///
  /// In en, this message translates to:
  /// **'Raspberry Pi or Docker'**
  String get setupPlatformPi;

  /// No description provided for @setupPlatformZha.
  ///
  /// In en, this message translates to:
  /// **'ZHA, no Zigbee2MQTT'**
  String get setupPlatformZha;

  /// Under the setup answer for Home Assistant's own Zigbee (ZHA), 3.1.3: ZigDash cannot see ZHA devices; a Try demo button follows.
  ///
  /// In en, this message translates to:
  /// **'ZigDash shows devices from Zigbee2MQTT, so it can\'t see devices in ZHA, Home Assistant\'s own Zigbee. You can try the demo home to see how ZigDash works.'**
  String get setupZhaNote;

  /// No description provided for @setupPlatformNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get setupPlatformNotSure;

  /// No description provided for @setupScanProgress.
  ///
  /// In en, this message translates to:
  /// **'Checked {checked} of {total} addresses'**
  String setupScanProgress(int checked, int total);

  /// No description provided for @setupScanHintHa.
  ///
  /// In en, this message translates to:
  /// **'Looking for Home Assistant and its MQTT broker…'**
  String get setupScanHintHa;

  /// No description provided for @setupScanHintSmlight.
  ///
  /// In en, this message translates to:
  /// **'Looking for your SMLIGHT hub…'**
  String get setupScanHintSmlight;

  /// No description provided for @setupScanHintPi.
  ///
  /// In en, this message translates to:
  /// **'Looking for an MQTT broker on your network…'**
  String get setupScanHintPi;

  /// No description provided for @setupHubSeenHa.
  ///
  /// In en, this message translates to:
  /// **'Found Home Assistant at {host}'**
  String setupHubSeenHa(String host);

  /// No description provided for @setupHubSeenZ2m.
  ///
  /// In en, this message translates to:
  /// **'Found Zigbee2MQTT at {host}'**
  String setupHubSeenZ2m(String host);

  /// No description provided for @setupHubSeenSmlight.
  ///
  /// In en, this message translates to:
  /// **'Found your SMLIGHT hub at {host}'**
  String setupHubSeenSmlight(String host);

  /// No description provided for @setupHubSeenHint.
  ///
  /// In en, this message translates to:
  /// **'Still looking for its MQTT broker…'**
  String get setupHubSeenHint;

  /// No description provided for @setupNoBrokerHaTitle.
  ///
  /// In en, this message translates to:
  /// **'Found Home Assistant, but no MQTT broker'**
  String get setupNoBrokerHaTitle;

  /// No description provided for @setupNoBrokerHaBody.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant is at {host}, but nothing answers on MQTT port 1883. In Home Assistant, open Settings › Apps, install and start the Mosquitto broker app, then try again.'**
  String setupNoBrokerHaBody(String host);

  /// No description provided for @setupNoBrokerHaZha.
  ///
  /// In en, this message translates to:
  /// **'Using Home Assistant\'s own Zigbee (ZHA) instead of Zigbee2MQTT? ZigDash works only with Zigbee2MQTT, so it can\'t see ZHA devices. The demo shows what you\'d get.'**
  String get setupNoBrokerHaZha;

  /// Setup, Home Assistant found without a broker (3.2.6): Home Assistant Container has no Apps, so Mosquitto runs in its own container. Use Home Assistant's own name for Settings › Apps in this language.
  ///
  /// In en, this message translates to:
  /// **'No Apps in your Home Assistant\'s Settings? Then it runs in Docker (Home Assistant Container), which has no apps: Mosquitto runs in its own container. Enter the address of the machine that runs it below.'**
  String get setupNoBrokerHaDocker;

  /// No description provided for @setupVpnHint.
  ///
  /// In en, this message translates to:
  /// **'A VPN is on, and it can hide your home network from the scan. If you\'re at home, turn the VPN off and tap Try again. Or keep it on and allow local network (LAN) access in the VPN app\'s settings.'**
  String get setupVpnHint;

  /// No description provided for @setupNoBrokerZ2mTitle.
  ///
  /// In en, this message translates to:
  /// **'Found Zigbee2MQTT, but its broker can\'t be reached'**
  String get setupNoBrokerZ2mTitle;

  /// No description provided for @setupNoBrokerZ2mBody.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT is at {host}, but its MQTT broker doesn\'t accept connections from your phone. Mosquitto 2 only listens on the hub itself until its config has \'listener 1883\' and \'allow_anonymous true\' (or a login). Restart it, then try again.'**
  String setupNoBrokerZ2mBody(String host);

  /// No description provided for @setupNoBrokerSmlightTitle.
  ///
  /// In en, this message translates to:
  /// **'Found your SMLIGHT hub, but MQTT is off'**
  String get setupNoBrokerSmlightTitle;

  /// No description provided for @setupNoBrokerSmlightBody.
  ///
  /// In en, this message translates to:
  /// **'Your hub is at {host}, but its MQTT broker can\'t be reached. In the hub\'s web UI, open Settings › MQTT, turn on Allow External and check that Zigbee2MQTT is running, then try again.'**
  String setupNoBrokerSmlightBody(String host);

  /// No description provided for @setupZ2mAsking.
  ///
  /// In en, this message translates to:
  /// **'Asking Zigbee2MQTT where its broker is…'**
  String get setupZ2mAsking;

  /// No description provided for @setupZ2mLocalOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your broker only accepts connections from its own machine'**
  String get setupZ2mLocalOnlyTitle;

  /// No description provided for @setupZ2mLocalOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT uses {server}, and nothing answers there from your phone. Mosquitto 2 does this by default. Add these two lines to mosquitto.conf, restart Mosquitto, then try again:'**
  String setupZ2mLocalOnlyBody(String server);

  /// No description provided for @setupZ2mLocalOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Prefer a login over open access? Use a password_file instead of allow_anonymous.'**
  String get setupZ2mLocalOnlyNote;

  /// No description provided for @setupZ2mNameOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT reaches its broker by a name your phone can\'t use'**
  String get setupZ2mNameOnlyTitle;

  /// No description provided for @setupZ2mNameOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT uses {server}. \"{name}\" is a name only Zigbee2MQTT\'s machine knows, a Docker service or a hostname. Type the broker machine\'s IP address with port {port} instead. If the broker runs in a container, its port must also be published on the machine (ports: \"{port}:{port}\").'**
  String setupZ2mNameOnlyBody(String server, String name, int port);

  /// No description provided for @setupZ2mTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT\'s web page is protected by a token, so the app couldn\'t read where its broker is. Type the broker address from Zigbee2MQTT\'s Settings › MQTT.'**
  String get setupZ2mTokenRequired;

  /// No description provided for @setupZ2mUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT uses the broker at {server}, but it didn\'t answer from your phone. Check that the broker is running and that your phone is on the same network.'**
  String setupZ2mUnreachable(String server);

  /// No description provided for @setupConnectTo.
  ///
  /// In en, this message translates to:
  /// **'Connect to {host}'**
  String setupConnectTo(String host);

  /// No description provided for @setupNotFoundHa.
  ///
  /// In en, this message translates to:
  /// **'No Home Assistant found on this network. Check that your phone is on the same Wi-Fi as Home Assistant (not a guest network), then try again. If you know its address, enter it below.'**
  String get setupNotFoundHa;

  /// No description provided for @setupNotFoundSmlight.
  ///
  /// In en, this message translates to:
  /// **'No SMLIGHT hub found on this network. Check that the hub is on and your phone is on the same Wi-Fi, then try again. If you know its address, enter it below.'**
  String get setupNotFoundSmlight;

  /// No description provided for @setupNotFoundPi.
  ///
  /// In en, this message translates to:
  /// **'No MQTT broker found on this network. Check that Mosquitto is running and listening on the network (port 1883), and that your phone is on the same Wi-Fi, then try again.'**
  String get setupNotFoundPi;

  /// Setup, empty result: the address check field (setup-help-2.5.md, 2.6.2).
  ///
  /// In en, this message translates to:
  /// **'Where do you open Home Assistant?'**
  String get setupAddressQuestionHa;

  /// No description provided for @setupAddressQuestionSmlight.
  ///
  /// In en, this message translates to:
  /// **'What is your SMLIGHT hub\'s address?'**
  String get setupAddressQuestionSmlight;

  /// Setup, SMLIGHT address step (3.2.6): where an SMHUB shows its IP. Dashboard, Network and IPv4 are the hub's own English labels; keep them in English.
  ///
  /// In en, this message translates to:
  /// **'Open your hub\'s web page: smhub.local, or smhub.local:3000 on early hubs. On the Dashboard, the Network box shows the address next to IPv4. Type it here. If the page doesn\'t open, your router\'s app lists the hub as SMHUB, with its IP.'**
  String get setupAddressWhereSmlight;

  /// Setup, SMLIGHT address step (3.2.6): SLZB models run no broker (SLZB-OS manual).
  ///
  /// In en, this message translates to:
  /// **'An SLZB-06, MR or UltimaX is only the Zigbee radio and has no broker. Type the address of the computer that runs Zigbee2MQTT and Mosquitto instead.'**
  String get setupAddressSlzbSmlight;

  /// No description provided for @setupAddressQuestionPi.
  ///
  /// In en, this message translates to:
  /// **'What is the address of the machine running Mosquitto?'**
  String get setupAddressQuestionPi;

  /// No description provided for @setupAddressQuestionAny.
  ///
  /// In en, this message translates to:
  /// **'What is the address of your hub, or of the machine running Zigbee2MQTT?'**
  String get setupAddressQuestionAny;

  /// No description provided for @setupAddressHint.
  ///
  /// In en, this message translates to:
  /// **'An address like 192.168.1.20, a name, or the link from your browser'**
  String get setupAddressHint;

  /// No description provided for @setupAddressCheck.
  ///
  /// In en, this message translates to:
  /// **'Check this address'**
  String get setupAddressCheck;

  /// No description provided for @setupAddressNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing answered at {host}. Check the address, and that your phone is on the same Wi-Fi as it.'**
  String setupAddressNothing(String host);

  /// No description provided for @setupAddressNotResolved.
  ///
  /// In en, this message translates to:
  /// **'{host} could not be looked up. Names ending in .local often fail on Android; try the IP address instead. Home Assistant shows it under Settings › System › Network.'**
  String setupAddressNotResolved(String host);

  /// A .local name that did not resolve, for someone who said they use Home Assistant (3.1.3). {button} is the Connect through Home Assistant button above.
  ///
  /// In en, this message translates to:
  /// **'{host} can\'t be found from this phone; Android often can\'t look up .local names. Tap {button} above and use the address you open Home Assistant with in your browser, or type its IP address here. Home Assistant shows it under Settings › System › Network.'**
  String setupAddressNotResolvedHa(String host, String button);

  /// No description provided for @setupAddressNotLocal.
  ///
  /// In en, this message translates to:
  /// **'{host} is not on your home network. Use the address that works on your Wi-Fi, not a remote link such as Nabu Casa or DuckDNS.'**
  String setupAddressNotLocal(String host);

  /// No description provided for @setupAddressInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an address first.'**
  String get setupAddressInvalid;

  /// No description provided for @setupChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Which of these fits you?'**
  String get setupChoicesTitle;

  /// No description provided for @setupChoiceNoHub.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have a hub yet'**
  String get setupChoiceNoHub;

  /// No description provided for @setupChoiceNoHubSub.
  ///
  /// In en, this message translates to:
  /// **'See the small hubs that run Zigbee2MQTT'**
  String get setupChoiceNoHubSub;

  /// No description provided for @setupChoiceHa.
  ///
  /// In en, this message translates to:
  /// **'I use Home Assistant'**
  String get setupChoiceHa;

  /// No description provided for @setupChoiceHaSub.
  ///
  /// In en, this message translates to:
  /// **'Look for it at homeassistant.local'**
  String get setupChoiceHaSub;

  /// No description provided for @setupChoiceHaNote.
  ///
  /// In en, this message translates to:
  /// **'ZigDash connects to Home Assistant\'s MQTT broker, the Mosquitto broker app under Settings › Apps, and Zigbee2MQTT has to use it too. If homeassistant.local isn\'t found, enter Home Assistant\'s IP address below. It\'s under Settings › System › Network.'**
  String get setupChoiceHaNote;

  /// No description provided for @setupChoiceOther.
  ///
  /// In en, this message translates to:
  /// **'My hub is on another network'**
  String get setupChoiceOther;

  /// No description provided for @setupChoiceOtherSub.
  ///
  /// In en, this message translates to:
  /// **'A guest Wi-Fi or a second router'**
  String get setupChoiceOtherSub;

  /// No description provided for @setupChoiceOtherNote.
  ///
  /// In en, this message translates to:
  /// **'Your phone has to reach your hub. A guest Wi-Fi, or a second router with its own Wi-Fi, keeps them apart. Join the Wi-Fi your hub is on and tap Try again. Or enter the hub\'s IP address below, or try one of these usual names:'**
  String get setupChoiceOtherNote;

  /// No description provided for @guidedHostYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Your phone is {ip}, so the hub usually starts with {prefix}.'**
  String guidedHostYourPhone(String ip, String prefix);

  /// No description provided for @guidedHostHa.
  ///
  /// In en, this message translates to:
  /// **'Using Home Assistant? The host is the address you open Home Assistant with, port 1883.'**
  String get guidedHostHa;

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

  /// No description provided for @readingShowAs.
  ///
  /// In en, this message translates to:
  /// **'Show as'**
  String get readingShowAs;

  /// No description provided for @readingStyleValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get readingStyleValue;

  /// No description provided for @readingStyleGauge.
  ///
  /// In en, this message translates to:
  /// **'Gauge'**
  String get readingStyleGauge;

  /// No description provided for @gaugeBands.
  ///
  /// In en, this message translates to:
  /// **'Color bands'**
  String get gaugeBands;

  /// No description provided for @gaugeBandsHelper.
  ///
  /// In en, this message translates to:
  /// **'Up to three. The band the value is in colors the arc.'**
  String get gaugeBandsHelper;

  /// No description provided for @gaugeBandFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get gaugeBandFrom;

  /// No description provided for @gaugeBandTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get gaugeBandTo;

  /// No description provided for @gaugeBandAdd.
  ///
  /// In en, this message translates to:
  /// **'Add band'**
  String get gaugeBandAdd;

  /// No description provided for @gaugeBandRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove band'**
  String get gaugeBandRemove;

  /// No description provided for @gaugeToneNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get gaugeToneNormal;

  /// No description provided for @gaugeToneGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get gaugeToneGood;

  /// No description provided for @gaugeToneAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get gaugeToneAttention;

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
  /// **'Anonymous usage data. Turn it off with the switch above.'**
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

  /// No description provided for @getHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get getHelpTitle;

  /// No description provided for @getHelpTryFirst.
  ///
  /// In en, this message translates to:
  /// **'Try these first'**
  String get getHelpTryFirst;

  /// No description provided for @getHelpPromise.
  ///
  /// In en, this message translates to:
  /// **'Still stuck? I usually reply within 3 days, in English or Hebrew. I\'ll never ask for your passwords.'**
  String get getHelpPromise;

  /// No description provided for @getHelpIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get getHelpIncluded;

  /// No description provided for @getHelpContact.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get getHelpContact;

  /// No description provided for @getHelpCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy details'**
  String get getHelpCopy;

  /// No description provided for @getHelpCopied.
  ///
  /// In en, this message translates to:
  /// **'Details copied'**
  String get getHelpCopied;

  /// No description provided for @getHelpLink.
  ///
  /// In en, this message translates to:
  /// **'Still stuck? Get help'**
  String get getHelpLink;

  /// No description provided for @getHelpEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'ZigDash: help getting it working'**
  String get getHelpEmailSubject;

  /// No description provided for @getHelpEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'What were you trying to do, and what happened?'**
  String get getHelpEmailPrompt;

  /// No description provided for @settingsHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get settingsHelpSupport;

  /// No description provided for @settingsGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get settingsGetHelp;

  /// No description provided for @settingsGetHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t get it working? Tips first, then contact'**
  String get settingsGetHelpSubtitle;

  /// No description provided for @settingsCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the ZigDash community'**
  String get settingsCommunity;

  /// No description provided for @settingsCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Telegram group: questions, ideas and what\'s coming'**
  String get settingsCommunitySubtitle;

  /// No description provided for @getHelpCommunity.
  ///
  /// In en, this message translates to:
  /// **'Ask in the Telegram group'**
  String get getHelpCommunity;

  /// No description provided for @demoBannerHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get demoBannerHelp;

  /// No description provided for @tipSameWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Same Wi-Fi as your hub'**
  String get tipSameWifiTitle;

  /// No description provided for @tipSameWifiBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone must be on the same network as the hub, not a guest network. Turn mobile data off while you set up.'**
  String get tipSameWifiBody;

  /// No description provided for @tipBrokerRunningTitle.
  ///
  /// In en, this message translates to:
  /// **'The broker is running'**
  String get tipBrokerRunningTitle;

  /// No description provided for @tipBrokerRunningBody.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant: the Mosquitto broker app is started. Raspberry Pi: Mosquitto is running. SMLIGHT: Settings › MQTT is on.'**
  String get tipBrokerRunningBody;

  /// No description provided for @tipBrokerAcceptsTitle.
  ///
  /// In en, this message translates to:
  /// **'The broker accepts your phone'**
  String get tipBrokerAcceptsTitle;

  /// No description provided for @tipBrokerAcceptsBody.
  ///
  /// In en, this message translates to:
  /// **'SMLIGHT: turn on Allow External. Mosquitto 2 only accepts connections from the hub itself until it\'s set to listen on the network (port 1883).'**
  String get tipBrokerAcceptsBody;

  /// No description provided for @tipMeshTitle.
  ///
  /// In en, this message translates to:
  /// **'Mesh Wi-Fi or two routers?'**
  String get tipMeshTitle;

  /// No description provided for @tipMeshBody.
  ///
  /// In en, this message translates to:
  /// **'If the hub hangs off a second router, your phone may not see it. Plug the hub into the main router, or connect by its address.'**
  String get tipMeshBody;

  /// No description provided for @tipByAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect by address'**
  String get tipByAddressTitle;

  /// No description provided for @tipByAddressBody.
  ///
  /// In en, this message translates to:
  /// **'Find the hub\'s address in your router\'s app, then tap Enter details manually.'**
  String get tipByAddressBody;

  /// No description provided for @tipSameNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Same network'**
  String get tipSameNetworkTitle;

  /// No description provided for @tipSameNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'Phone and hub must be on the same Wi-Fi. Turn mobile data off.'**
  String get tipSameNetworkBody;

  /// No description provided for @tipAddressChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'The address changed'**
  String get tipAddressChangedTitle;

  /// No description provided for @tipAddressChangedBody.
  ///
  /// In en, this message translates to:
  /// **'Hubs can get a new address after a restart. Check it in your router\'s app, and reserve it there so it stays the same.'**
  String get tipAddressChangedBody;

  /// No description provided for @tipRightPortTitle.
  ///
  /// In en, this message translates to:
  /// **'The right port'**
  String get tipRightPortTitle;

  /// No description provided for @tipRightPortBody.
  ///
  /// In en, this message translates to:
  /// **'MQTT is usually 1883 (8883 with TLS). 8080 or 80 is the hub\'s web page, not MQTT.'**
  String get tipRightPortBody;

  /// No description provided for @tipStartBrokerTitle.
  ///
  /// In en, this message translates to:
  /// **'The broker is running'**
  String get tipStartBrokerTitle;

  /// No description provided for @tipStartBrokerBody.
  ///
  /// In en, this message translates to:
  /// **'Start Mosquitto or the Mosquitto broker app, then try again.'**
  String get tipStartBrokerBody;

  /// No description provided for @tipMosquitto2Title.
  ///
  /// In en, this message translates to:
  /// **'Mosquitto 2'**
  String get tipMosquitto2Title;

  /// No description provided for @tipMosquitto2Body.
  ///
  /// In en, this message translates to:
  /// **'Mosquitto 2 only accepts connections from the hub itself until it\'s set to listen on the network (port 1883).'**
  String get tipMosquitto2Body;

  /// No description provided for @tipMqttLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'The MQTT login, not the web login'**
  String get tipMqttLoginTitle;

  /// No description provided for @tipMqttLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Your hub\'s web page password is usually not the MQTT one. Home Assistant: use a Home Assistant user, or the login set in the Mosquitto broker app.'**
  String get tipMqttLoginBody;

  /// No description provided for @tipSpacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Check for spaces'**
  String get tipSpacesTitle;

  /// No description provided for @tipSpacesBody.
  ///
  /// In en, this message translates to:
  /// **'Copying a password can add a space at the end.'**
  String get tipSpacesBody;

  /// No description provided for @tipZ2mBrokerTitle.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT uses this broker'**
  String get tipZ2mBrokerTitle;

  /// No description provided for @tipZ2mBrokerBody.
  ///
  /// In en, this message translates to:
  /// **'In Zigbee2MQTT\'s settings, check that its MQTT server is this same broker.'**
  String get tipZ2mBrokerBody;

  /// No description provided for @tipBaseTopicTitle.
  ///
  /// In en, this message translates to:
  /// **'Base topic'**
  String get tipBaseTopicTitle;

  /// No description provided for @tipBaseTopicBody.
  ///
  /// In en, this message translates to:
  /// **'If you changed the base topic from \"zigbee2mqtt\", enter it in manual setup.'**
  String get tipBaseTopicBody;

  /// No description provided for @tipPairFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair devices first'**
  String get tipPairFirstTitle;

  /// No description provided for @tipPairFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Open Zigbee2MQTT\'s web page and pair at least one device, then check again.'**
  String get tipPairFirstBody;

  /// No description provided for @tipRestartZ2mTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart Zigbee2MQTT'**
  String get tipRestartZ2mTitle;

  /// No description provided for @tipRestartZ2mBody.
  ///
  /// In en, this message translates to:
  /// **'If devices are paired but none arrive, restart Zigbee2MQTT so it publishes its device list.'**
  String get tipRestartZ2mBody;

  /// No description provided for @tipNumberAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the number address'**
  String get tipNumberAddressTitle;

  /// No description provided for @tipNumberAddressBody.
  ///
  /// In en, this message translates to:
  /// **'Names ending in .local don\'t work on every Android phone. Try the hub\'s number address, like 192.168.1.20.'**
  String get tipNumberAddressBody;

  /// No description provided for @tipPortProtocolTitle.
  ///
  /// In en, this message translates to:
  /// **'Port and protocol'**
  String get tipPortProtocolTitle;

  /// No description provided for @tipPortProtocolBody.
  ///
  /// In en, this message translates to:
  /// **'TCP on 1883 is the usual. Pick TLS or WebSocket only if your broker is set up for it.'**
  String get tipPortProtocolBody;

  /// No description provided for @tipManualLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get tipManualLoginTitle;

  /// No description provided for @tipManualLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Leave username and password empty if your broker has none. Otherwise use the MQTT login, not the hub\'s web login.'**
  String get tipManualLoginBody;

  /// No description provided for @tipHubOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Is the hub on?'**
  String get tipHubOnTitle;

  /// No description provided for @tipHubOnBody.
  ///
  /// In en, this message translates to:
  /// **'A power cut or update may have restarted it. Give it a minute after it comes back.'**
  String get tipHubOnBody;

  /// No description provided for @tipAwayTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you at home?'**
  String get tipAwayTitle;

  /// No description provided for @tipAwayBody.
  ///
  /// In en, this message translates to:
  /// **'Away from home, the app needs a remote address (for example Tailscale). Set it in the home\'s connection settings.'**
  String get tipAwayBody;

  /// No description provided for @tipTailscaleIpTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the Tailscale IP, not the name'**
  String get tipTailscaleIpTitle;

  /// No description provided for @tipTailscaleIpBody.
  ///
  /// In en, this message translates to:
  /// **'Names ending in .ts.net often don\'t resolve inside apps. Open the Tailscale app on the phone and make sure it\'s connected, then use the hub\'s 100.x.y.z address as the Remote host.'**
  String get tipTailscaleIpBody;

  /// No description provided for @tipHomeAddressChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Did the address change?'**
  String get tipHomeAddressChangedTitle;

  /// No description provided for @tipHomeAddressChangedBody.
  ///
  /// In en, this message translates to:
  /// **'After a router restart the hub may get a new address. Reserve its address in your router\'s app, then update the home.'**
  String get tipHomeAddressChangedBody;

  /// No description provided for @tipRestartZ2mButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart Zigbee2MQTT'**
  String get tipRestartZ2mButtonTitle;

  /// No description provided for @tipRestartZ2mButtonBody.
  ///
  /// In en, this message translates to:
  /// **'If the broker restarted, Zigbee2MQTT\'s device list is gone until Zigbee2MQTT restarts. Use the Restart Zigbee2MQTT button on the Devices tab.'**
  String get tipRestartZ2mButtonBody;

  /// No description provided for @tipZ2mRunningTitle.
  ///
  /// In en, this message translates to:
  /// **'Is Zigbee2MQTT running?'**
  String get tipZ2mRunningTitle;

  /// No description provided for @tipZ2mRunningBody.
  ///
  /// In en, this message translates to:
  /// **'Open its web page. If it doesn\'t load, restart it on your hub.'**
  String get tipZ2mRunningBody;

  /// No description provided for @tipCantConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t connect to my hub'**
  String get tipCantConnectTitle;

  /// No description provided for @tipCantConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Same Wi-Fi, broker running, Allow External or Mosquitto listening on the network, then connect by address.'**
  String get tipCantConnectBody;

  /// No description provided for @tipDeviceWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'A device shows wrong or doesn\'t respond'**
  String get tipDeviceWrongTitle;

  /// No description provided for @tipDeviceWrongBody.
  ///
  /// In en, this message translates to:
  /// **'Check it in Zigbee2MQTT\'s web page first. If it works there, use Report a problem.'**
  String get tipDeviceWrongBody;

  /// No description provided for @tipHowDoITitle.
  ///
  /// In en, this message translates to:
  /// **'How do I…'**
  String get tipHowDoITitle;

  /// No description provided for @tipHowDoIBody.
  ///
  /// In en, this message translates to:
  /// **'Scenes, Wall display, schedules and backups are in Help & Guide.'**
  String get tipHowDoIBody;

  /// No description provided for @tipRenameHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename a home'**
  String get tipRenameHomeTitle;

  /// No description provided for @tipRenameHomeBody.
  ///
  /// In en, this message translates to:
  /// **'A home named after its address? Settings › Homes, tap the home, then tap Name.'**
  String get tipRenameHomeBody;

  /// No description provided for @tipWhatYouNeedTitle.
  ///
  /// In en, this message translates to:
  /// **'What you need'**
  String get tipWhatYouNeedTitle;

  /// No description provided for @tipWhatYouNeedBody.
  ///
  /// In en, this message translates to:
  /// **'A small hub running Zigbee2MQTT and an MQTT broker (Mosquitto): an SMLIGHT hub, a Raspberry Pi or any Linux box. Home Assistant works too, but you don\'t need it.'**
  String get tipWhatYouNeedBody;

  /// No description provided for @tipSetupAtHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'On the same Wi-Fi'**
  String get tipSetupAtHomeTitle;

  /// No description provided for @tipSetupAtHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Set up at home, with your phone on the same Wi-Fi as the hub.'**
  String get tipSetupAtHomeBody;

  /// No description provided for @tipFindSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get tipFindSetupTitle;

  /// No description provided for @tipFindSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Leave the demo and tap Find my setup. ZigDash looks for your hub on its own.'**
  String get tipFindSetupBody;

  /// No description provided for @getHelpNoEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Copy the details and write to {email}.'**
  String getHelpNoEmailApp(Object email);

  /// No description provided for @shortcutWorking.
  ///
  /// In en, this message translates to:
  /// **'working…'**
  String get shortcutWorking;

  /// No description provided for @shortcutCantReach.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach home'**
  String get shortcutCantReach;

  /// No description provided for @shortcutNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get shortcutNotConfirmed;

  /// No description provided for @shortcutRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get shortcutRemoved;

  /// A scene shortcut's line once its commands went out (not every device answered yet).
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get shortcutSceneSent;

  /// A scene shortcut's line once every device reported its new state.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get shortcutSceneConfirmed;

  /// No description provided for @shortcutChooseDevice.
  ///
  /// In en, this message translates to:
  /// **'Choose a device'**
  String get shortcutChooseDevice;

  /// Title of the scene widget's picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a scene'**
  String get shortcutChooseScene;

  /// Scene widget picker, when there are no scenes yet.
  ///
  /// In en, this message translates to:
  /// **'Open ZigDash and create a scene first.'**
  String get shortcutOpenAppFirstScene;

  /// Title of the group widget's picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a group'**
  String get shortcutChooseGroup;

  /// Group widget picker: build a group by hand instead of from a dashboard section.
  ///
  /// In en, this message translates to:
  /// **'Pick devices…'**
  String get shortcutPickDevices;

  /// Group widget picker: label of the name field for a hand-picked group.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get shortcutGroupName;

  /// Group widget picker: how many devices and scenes a group can hold.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 devices and 3 scenes'**
  String get shortcutGroupLimit;

  /// No description provided for @shortcutAddTile.
  ///
  /// In en, this message translates to:
  /// **'Add to Quick Settings'**
  String get shortcutAddTile;

  /// Device page: button offering a home-screen widget or a Quick Settings tile for the device.
  ///
  /// In en, this message translates to:
  /// **'Add shortcut'**
  String get shortcutAddShortcut;

  /// Adds a widget for this device or scene to the phone's home screen.
  ///
  /// In en, this message translates to:
  /// **'Add to home screen'**
  String get shortcutAddToHome;

  /// Dialog title when the launcher can't add a widget for the app.
  ///
  /// In en, this message translates to:
  /// **'Add the widget'**
  String get shortcutWidgetHowToTitle;

  /// How to add a ZigDash widget by hand.
  ///
  /// In en, this message translates to:
  /// **'Long-press an empty spot on your home screen, tap Widgets, find ZigDash and drag the widget you want.'**
  String get shortcutWidgetHowTo;

  /// No description provided for @shortcutTileReady.
  ///
  /// In en, this message translates to:
  /// **'{name} is on Quick Settings tile ZigDash {slot}'**
  String shortcutTileReady(Object name, Object slot);

  /// No description provided for @shortcutTileAlready.
  ///
  /// In en, this message translates to:
  /// **'{name} is already on tile ZigDash {slot}'**
  String shortcutTileAlready(Object name, Object slot);

  /// No description provided for @shortcutTileHowToTitle.
  ///
  /// In en, this message translates to:
  /// **'Add the tile'**
  String get shortcutTileHowToTitle;

  /// No description provided for @shortcutTileHowTo.
  ///
  /// In en, this message translates to:
  /// **'Open Quick Settings (swipe down twice), tap the pencil to edit, and drag “ZigDash {slot}” into your tiles.'**
  String shortcutTileHowTo(Object slot);

  /// No description provided for @shortcutPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a device for ZigDash {slot}'**
  String shortcutPickTitle(Object slot);

  /// No description provided for @shortcutPickEmpty.
  ///
  /// In en, this message translates to:
  /// **'No devices to switch yet. Put a light, plug or shutter on a dashboard first.'**
  String get shortcutPickEmpty;

  /// No description provided for @shortcutSlotsFull.
  ///
  /// In en, this message translates to:
  /// **'All 4 ZigDash tiles are in use. Which one should show this device instead?'**
  String get shortcutSlotsFull;

  /// No description provided for @shortcutSlotLabel.
  ///
  /// In en, this message translates to:
  /// **'ZigDash {slot}'**
  String shortcutSlotLabel(Object slot);

  /// No description provided for @shortcutSlotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not used'**
  String get shortcutSlotEmpty;

  /// No description provided for @deviceRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get deviceRename;

  /// No description provided for @deviceRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get deviceRenameTitle;

  /// No description provided for @deviceRenameHint.
  ///
  /// In en, this message translates to:
  /// **'A name for the room or the device, like Bedroom'**
  String get deviceRenameHint;

  /// No description provided for @deviceRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed to {name}'**
  String deviceRenamed(Object name);

  /// No description provided for @deviceRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t rename: {reason}'**
  String deviceRenameFailed(Object reason);

  /// No description provided for @deviceRenameNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT didn\'t answer'**
  String get deviceRenameNoAnswer;

  /// Home-screen widget picker, when no device is on a dashboard yet.
  ///
  /// In en, this message translates to:
  /// **'Open ZigDash and put a device on a dashboard first.'**
  String get shortcutOpenAppFirst;

  /// One-time dashboard card asking what to build next.
  ///
  /// In en, this message translates to:
  /// **'What should ZigDash do next?'**
  String get pollTitle;

  /// Under the poll title, for people who share usage data.
  ///
  /// In en, this message translates to:
  /// **'Pick the one you\'d use most. Your answer is sent with your anonymous usage data.'**
  String get pollBody;

  /// Poll choice: alerts on the phone (door opened, leak…).
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get pollNotifications;

  /// Poll choice: graphs of past readings.
  ///
  /// In en, this message translates to:
  /// **'History graphs'**
  String get pollHistory;

  /// Poll choice: a full-screen mode for a wall tablet.
  ///
  /// In en, this message translates to:
  /// **'Kiosk mode for a wall tablet'**
  String get pollKiosk;

  /// Poll choice: control Zigbee2MQTT groups.
  ///
  /// In en, this message translates to:
  /// **'Zigbee groups'**
  String get pollGroups;

  /// Hides the poll for good.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get pollNotNow;

  /// Snackbar after answering the poll.
  ///
  /// In en, this message translates to:
  /// **'Thanks! That helps decide what comes next.'**
  String get pollThanks;

  /// One-time dashboard card after the first setup, asking why the user tried the app.
  ///
  /// In en, this message translates to:
  /// **'What made you try ZigDash?'**
  String get whyTitle;

  /// Body of the why card.
  ///
  /// In en, this message translates to:
  /// **'One tap helps decide what to build. Your answer is sent with your anonymous usage data.'**
  String get whyBody;

  /// Why-card choice.
  ///
  /// In en, this message translates to:
  /// **'Quicker than my other app'**
  String get whyFaster;

  /// Why-card choice.
  ///
  /// In en, this message translates to:
  /// **'Easy for the family'**
  String get whyFamily;

  /// Why-card choice.
  ///
  /// In en, this message translates to:
  /// **'A wall tablet'**
  String get whyWallTablet;

  /// Why-card choice: direct MQTT keeps working with no Home Assistant or while it is down.
  ///
  /// In en, this message translates to:
  /// **'Works without Home Assistant'**
  String get whyWithoutHa;

  /// Why-card choice.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get whyOther;

  /// Snackbar after answering the why card.
  ///
  /// In en, this message translates to:
  /// **'Thanks for telling us!'**
  String get whyThanks;

  /// Poll card text for people who don't share usage data.
  ///
  /// In en, this message translates to:
  /// **'Usage data is off, so nothing is sent from here. Tell us with Request a feature instead.'**
  String get pollNoAnalytics;

  /// Notification: a leak sensor got wet. {name} is the device's name.
  ///
  /// In en, this message translates to:
  /// **'💧 Leak — {name}'**
  String alertLeak(Object name);

  /// Notification: the leak sensor is dry again.
  ///
  /// In en, this message translates to:
  /// **'✅ {name} is dry again'**
  String alertLeakCleared(Object name);

  /// Notification: smoke detected.
  ///
  /// In en, this message translates to:
  /// **'🔥 Smoke — {name}'**
  String alertSmoke(Object name);

  /// Notification: no more smoke.
  ///
  /// In en, this message translates to:
  /// **'✅ No more smoke at {name}'**
  String alertSmokeCleared(Object name);

  /// Notification: a door or window opened.
  ///
  /// In en, this message translates to:
  /// **'🚪 {name} opened'**
  String alertOpened(Object name);

  /// Notification: a battery is low; {value} is the percentage.
  ///
  /// In en, this message translates to:
  /// **'🔋 Battery low — {name}, {value}%'**
  String alertBattery(Object name, Object value);

  /// The test notification's text.
  ///
  /// In en, this message translates to:
  /// **'ZigDash test alert'**
  String get alertTest;

  /// Android notification channel for leak and smoke (urgent).
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsChannel;

  /// What the urgent channel carries.
  ///
  /// In en, this message translates to:
  /// **'Leaks and smoke'**
  String get alertsChannelDescription;

  /// Android notification channel for doors and batteries.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get noticesChannel;

  /// What the notices channel carries.
  ///
  /// In en, this message translates to:
  /// **'Doors, windows and batteries'**
  String get noticesChannelDescription;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Alerts are on'**
  String get alertsStatusOn;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Alerts are paused: ZigDash Engine on your hub isn\'t reporting'**
  String get alertsStatusPaused;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get alertsStatusNotSetUp;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'This phone isn\'t getting notifications'**
  String get alertsStatusPhoneOff;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Get a notification on this phone when a leak, smoke, an opened door or a low battery is reported, even with ZigDash closed. ZigDash Engine on your hub watches the devices; ZigDash sets it up.'**
  String get alertsIntro;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Set up alerts on the hub'**
  String get alertsSetUpHub;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Alerts are set up on your hub'**
  String get alertsHubInstalled;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'The alerts flow on the hub is up to date'**
  String get alertsHubUpdated;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Node-RED asks for a login, so import the flow by hand:'**
  String get alertsHubNeedsLogin;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Open Node-RED on the hub, choose Import, paste the copied flow, pick your broker in the broker node, and Deploy.'**
  String get alertsHubManualSteps;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Copy the flow'**
  String get alertsCopyFlow;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Flow copied'**
  String get alertsFlowCopied;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Alerts need Node-RED on the hub, and nothing answers on port 1880 at {host}. On an SMLIGHT SMHUB, install it under Apps.'**
  String alertsNoNodeRed(Object host);

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT didn\'t accept ZigDash Engine'**
  String get alertsHubFailed;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts'**
  String get alertsRecent;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get alertsRecentNone;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Your alerts'**
  String get alertsYourAlerts;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Add alert'**
  String get alertsAdd;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Notifications on this phone'**
  String get alertsNotificationsOnThisPhone;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'This phone has no Google services, so ZigDash can\'t receive pushes here.'**
  String get alertsNoGoogle;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get alertsSendTest;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Test sent. It should arrive now.'**
  String get alertsTestSent;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'The hub couldn\'t send it ({status})'**
  String alertsTestFailed(Object status);

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'No answer from the hub. Is the alerts flow running?'**
  String get alertsTestTimedOut;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Not connected to the hub'**
  String get alertsNotConnected;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Turn alerts off'**
  String get alertsTurnOff;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Alerts stop for every phone of this Home.'**
  String get alertsTurnOffBody;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Leak'**
  String get alertKindLeak;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Smoke'**
  String get alertKindSmoke;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Door or window opened'**
  String get alertKindOpened;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Battery low'**
  String get alertKindBattery;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alertsEditTitle;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get alertsKind;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get alertsDevices;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'No device of this Home reports that.'**
  String get alertsNoDevicesForKind;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Only between'**
  String get alertsHours;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get alertsHoursAny;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get alertsHoursFrom;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get alertsHoursTo;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Battery below'**
  String get alertsThreshold;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Delete alert'**
  String get alertsDelete;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Notify me…'**
  String get alertsNotifyMe;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Alerts to ZigDash are encrypted end to end: Google\'s push service carries them but can\'t read them. Nothing else leaves your hub.'**
  String get alertsWhatLeaves;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Android may stop ZigDash in the background, so notifications could be late or missed. Allow it to run in the background in Android\'s settings (on Samsung: Battery › Never sleeping apps).'**
  String get alertsRestricted;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Open Android settings'**
  String get alertsOpenSettings;

  /// Alerts screen.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get alertsOff;

  /// Alerts screen, suggested alerts on first visit.
  ///
  /// In en, this message translates to:
  /// **'Suggested alerts'**
  String get alertsSuggested;

  /// Alerts screen, suggested alerts on first visit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device} other{{count} devices}}'**
  String alertsSuggestedCount(int count);

  /// Alerts screen, suggested alerts on first visit.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get alertsTurnOn;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Share alerts'**
  String get alertsShare;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Anyone with this link gets this Home\'s alerts in the ntfy app, with no ZigDash needed. The alert text goes through ntfy.sh unencrypted.'**
  String get alertsShareBody;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get alertsShareLink;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'New link'**
  String get alertsShareNewLink;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get alertsShareCopied;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get alertsShareOff;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Get notifications with ntfy'**
  String get alertsGetWithNtfy;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Pushover'**
  String get alertsPushover;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Smoke and leak alerts repeat until acknowledged. Needs a Pushover account (\$4.99 once after a trial); its keys are kept on your broker.'**
  String get alertsPushoverBody;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'User key'**
  String get alertsPushoverUser;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'App token'**
  String get alertsPushoverToken;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'Hide device names'**
  String get alertsHideNames;

  /// Alerts screen: sharing with the household (ntfy) and Pushover.
  ///
  /// In en, this message translates to:
  /// **'ntfy server'**
  String get alertsNtfyServer;

  /// No description provided for @wallSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Wall display'**
  String get wallSheetTitle;

  /// No description provided for @wallSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For a tablet on the wall.'**
  String get wallSheetSubtitle;

  /// No description provided for @wallKeepOn.
  ///
  /// In en, this message translates to:
  /// **'Keep the screen on and hide the bars'**
  String get wallKeepOn;

  /// No description provided for @wallKeepOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They come back with a touch and hide again after 10 seconds.'**
  String get wallKeepOnSubtitle;

  /// No description provided for @wallFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get wallFullscreen;

  /// No description provided for @wallFullscreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hides Android\'s status and navigation bars too.'**
  String get wallFullscreenSubtitle;

  /// No description provided for @wallDimAfter.
  ///
  /// In en, this message translates to:
  /// **'Dim after'**
  String get wallDimAfter;

  /// No description provided for @wallDimOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get wallDimOff;

  /// No description provided for @wallIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'When no one touches it'**
  String get wallIdleTitle;

  /// No description provided for @wallIdleAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get wallIdleAfter;

  /// No description provided for @wallIdleNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get wallIdleNever;

  /// No description provided for @wallIdleShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get wallIdleShow;

  /// No description provided for @wallIdleShowDim.
  ///
  /// In en, this message translates to:
  /// **'Dimmed'**
  String get wallIdleShowDim;

  /// No description provided for @wallIdleShowClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get wallIdleShowClock;

  /// No description provided for @wallIdleShowBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get wallIdleShowBlack;

  /// No description provided for @wallIdleShowReadings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get wallIdleShowReadings;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proBadge;

  /// No description provided for @wallIdleReadingsNone.
  ///
  /// In en, this message translates to:
  /// **'This dashboard has no readings yet. Add a reading or a sensor tile first.'**
  String get wallIdleReadingsNone;

  /// No description provided for @wallIdleReadingsPick.
  ///
  /// In en, this message translates to:
  /// **'Readings on the clock (up to {count})'**
  String wallIdleReadingsPick(int count);

  /// No description provided for @wallProNote.
  ///
  /// In en, this message translates to:
  /// **'Readings on the clock, wake on motion, the night schedule and alarms are part of ZigDash Pro, a one-time purchase.'**
  String get wallProNote;

  /// No description provided for @wallAlarmLeak.
  ///
  /// In en, this message translates to:
  /// **'Water leak'**
  String get wallAlarmLeak;

  /// No description provided for @wallAlarmSmoke.
  ///
  /// In en, this message translates to:
  /// **'Smoke'**
  String get wallAlarmSmoke;

  /// No description provided for @wallAlarmGas.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get wallAlarmGas;

  /// No description provided for @wallAlarmCo.
  ///
  /// In en, this message translates to:
  /// **'Carbon monoxide'**
  String get wallAlarmCo;

  /// No description provided for @wallAlarmOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get wallAlarmOk;

  /// No description provided for @wallMotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Wake on motion'**
  String get wallMotionTitle;

  /// No description provided for @wallMotionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A sensor that sees someone wakes the screen.'**
  String get wallMotionSubtitle;

  /// No description provided for @wallMotionNone.
  ///
  /// In en, this message translates to:
  /// **'No motion, presence or door sensors in this Home.'**
  String get wallMotionNone;

  /// No description provided for @wallAlarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms take over the screen'**
  String get wallAlarmsTitle;

  /// No description provided for @wallAlarmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leak, smoke, gas or carbon monoxide fills the screen until someone taps OK. Only while ZigDash is open on this tablet; Alerts reach phones anywhere.'**
  String get wallAlarmsSubtitle;

  /// No description provided for @wallAlarmSound.
  ///
  /// In en, this message translates to:
  /// **'Play a sound'**
  String get wallAlarmSound;

  /// No description provided for @wallNightTitle.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get wallNightTitle;

  /// No description provided for @wallNightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Black between these hours. Motion wakes it only dimly; alarms always fully.'**
  String get wallNightSubtitle;

  /// No description provided for @wallNightFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get wallNightFrom;

  /// No description provided for @wallNightTo.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get wallNightTo;

  /// No description provided for @wallDimMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String wallDimMinutes(Object minutes);

  /// No description provided for @kioskLock.
  ///
  /// In en, this message translates to:
  /// **'Kiosk lock'**
  String get kioskLock;

  /// No description provided for @kioskLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only this Home\'s dashboards and their controls stay reachable. Long-press the title to leave.'**
  String get kioskLockSubtitle;

  /// No description provided for @kioskPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get kioskPin;

  /// No description provided for @kioskPinSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get kioskPinSet;

  /// No description provided for @kioskPinNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get kioskPinNotSet;

  /// No description provided for @kioskPinChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get kioskPinChange;

  /// No description provided for @kioskPinRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get kioskPinRemove;

  /// No description provided for @kioskPinSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get kioskPinSetTitle;

  /// No description provided for @kioskPinEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN'**
  String get kioskPinEnterTitle;

  /// No description provided for @kioskPinHint.
  ///
  /// In en, this message translates to:
  /// **'4 digits'**
  String get kioskPinHint;

  /// No description provided for @kioskPinConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get kioskPinConfirmHint;

  /// No description provided for @kioskPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two PINs differ.'**
  String get kioskPinMismatch;

  /// No description provided for @kioskPinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN.'**
  String get kioskPinWrong;

  /// No description provided for @kioskPinForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot the PIN?'**
  String get kioskPinForgot;

  /// No description provided for @kioskPinForgotBody.
  ///
  /// In en, this message translates to:
  /// **'A forgotten PIN can only be reset by clearing ZigDash\'s data in Android\'s settings, which removes this Home unless you have a backup. Export one before setting a PIN.'**
  String get kioskPinForgotBody;

  /// No description provided for @kioskExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get kioskExportBackup;

  /// No description provided for @kioskOsPin.
  ///
  /// In en, this message translates to:
  /// **'Also pin ZigDash on Android'**
  String get kioskOsPin;

  /// No description provided for @kioskOsPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Android blocks Home and recent apps until ZigDash is unpinned. A tablet without a lock screen unpins with a gesture, so this is not the lock.'**
  String get kioskOsPinSubtitle;

  /// No description provided for @kioskOn.
  ///
  /// In en, this message translates to:
  /// **'Kiosk on. Long-press the title to leave.'**
  String get kioskOn;

  /// No description provided for @kioskLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave kiosk?'**
  String get kioskLeaveTitle;

  /// No description provided for @kioskLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get kioskLeave;

  /// No description provided for @kioskStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get kioskStay;

  /// No description provided for @a11yKioskLeave.
  ///
  /// In en, this message translates to:
  /// **'Long-press to leave kiosk'**
  String get a11yKioskLeave;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyRangeDay.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get historyRangeDay;

  /// No description provided for @historyRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get historyRangeWeek;

  /// No description provided for @historyRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get historyRangeMonth;

  /// No description provided for @historySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Record history on your hub'**
  String get historySetupTitle;

  /// No description provided for @historySetupBody.
  ///
  /// In en, this message translates to:
  /// **'ZigDash has no server, so ZigDash Engine on your hub records the numbers on your dashboards every 15 minutes. It keeps 30 days, on your own broker.'**
  String get historySetupBody;

  /// No description provided for @historySetupAction.
  ///
  /// In en, this message translates to:
  /// **'Set up on the hub'**
  String get historySetupAction;

  /// No description provided for @historyInstalled.
  ///
  /// In en, this message translates to:
  /// **'Recording. The first values appear within 15 minutes.'**
  String get historyInstalled;

  /// No description provided for @historyNoNodeRed.
  ///
  /// In en, this message translates to:
  /// **'History needs Node-RED on the hub, and nothing answers on port 1880 at {host}. On an SMLIGHT SMHUB, install it under Apps.'**
  String historyNoNodeRed(String host);

  /// No description provided for @historyRecordingSince.
  ///
  /// In en, this message translates to:
  /// **'Recording since {date}'**
  String historyRecordingSince(String date);

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No values yet. The recorder saves every 15 minutes.'**
  String get historyEmpty;

  /// No description provided for @historyRecorderOffline.
  ///
  /// In en, this message translates to:
  /// **'The recorder on the hub isn\'t answering, so recent values may be missing.'**
  String get historyRecorderOffline;

  /// No description provided for @historyLocked.
  ///
  /// In en, this message translates to:
  /// **'Longer history is part of ZigDash Pro, a one-time purchase.'**
  String get historyLocked;

  /// No description provided for @historyUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get historyUnlock;

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'ZigDash Pro'**
  String get proTitle;

  /// No description provided for @proAbout.
  ///
  /// In en, this message translates to:
  /// **'Unlimited automations, longer history and wall tablet extras. Supports the open-source project.'**
  String get proAbout;

  /// No description provided for @proUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked. Thank you for supporting ZigDash.'**
  String get proUnlocked;

  /// No description provided for @proScreenIntro.
  ///
  /// In en, this message translates to:
  /// **'ZigDash is free and open source, built by one person in their spare time. Pro is a one-time purchase that keeps it going.'**
  String get proScreenIntro;

  /// No description provided for @proWhatYouGet.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get proWhatYouGet;

  /// No description provided for @proGetHistory.
  ///
  /// In en, this message translates to:
  /// **'History for 7 and 30 days, not just today'**
  String get proGetHistory;

  /// No description provided for @proGetWall.
  ///
  /// In en, this message translates to:
  /// **'Wall tablet: readings on the clock, wake on motion, a night schedule and alarms'**
  String get proGetWall;

  /// No description provided for @proGetFuture.
  ///
  /// In en, this message translates to:
  /// **'Every Pro feature that comes later, at no extra cost'**
  String get proGetFuture;

  /// No description provided for @proFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free forever'**
  String get proFreeTitle;

  /// No description provided for @proFreeBody.
  ///
  /// In en, this message translates to:
  /// **'Setup, dashboards, every device control, widgets, Quick Settings tiles, alerts, three automations per home and the wall tablet itself stay free. Nothing you use today gets locked.'**
  String get proFreeBody;

  /// No description provided for @proBuy.
  ///
  /// In en, this message translates to:
  /// **'Get Pro'**
  String get proBuy;

  /// No description provided for @proBuyPrice.
  ///
  /// In en, this message translates to:
  /// **'Get Pro · {price}'**
  String proBuyPrice(String price);

  /// No description provided for @proOnce.
  ///
  /// In en, this message translates to:
  /// **'One payment, no subscription. Bought on another phone with the same Google account? It unlocks automatically.'**
  String get proOnce;

  /// No description provided for @historyNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Only numbers shown on a dashboard are recorded. Add this one as a tile to start its history.'**
  String get historyNotRecorded;

  /// No description provided for @historyRecordHere.
  ///
  /// In en, this message translates to:
  /// **'Record on this device'**
  String get historyRecordHere;

  /// No description provided for @historyRecordHereHint.
  ///
  /// In en, this message translates to:
  /// **'Can\'t use ZigDash Engine on your hub? ZigDash can record on a phone or tablet that stays open, like a wall tablet. Every phone of this Home sees the history.'**
  String get historyRecordHereHint;

  /// No description provided for @historyRecordingHere.
  ///
  /// In en, this message translates to:
  /// **'This device records history while ZigDash is open. The first values appear within 15 minutes.'**
  String get historyRecordingHere;

  /// No description provided for @wallRecordHistory.
  ///
  /// In en, this message translates to:
  /// **'Record history on this device'**
  String get wallRecordHistory;

  /// No description provided for @wallRecordHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every 15 minutes while ZigDash is open, for every phone of this Home. Not needed when ZigDash Engine on your hub records.'**
  String get wallRecordHistorySubtitle;

  /// No description provided for @historyNeedsPassword.
  ///
  /// In en, this message translates to:
  /// **'One more step: your broker asks for a login. Open Node-RED at {host}:1880, double-click \"ZigDash history broker\", type the MQTT password on its Security tab, then Deploy. ZigDash never sends your password to the hub.'**
  String historyNeedsPassword(String host);

  /// No description provided for @historyNotConnected.
  ///
  /// In en, this message translates to:
  /// **'The recorder isn\'t reporting. Open Automations to check ZigDash Engine on your hub.'**
  String get historyNotConnected;

  /// No description provided for @historyPersistence.
  ///
  /// In en, this message translates to:
  /// **'History lives on your broker. If you run Mosquitto yourself, make sure its config has \"persistence true\", or history is lost when the broker restarts.'**
  String get historyPersistence;

  /// No description provided for @haImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Home Assistant'**
  String get haImportTitle;

  /// No description provided for @haImportSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Names and rooms you set up in Home Assistant'**
  String get haImportSettingsSubtitle;

  /// No description provided for @haImportIntro.
  ///
  /// In en, this message translates to:
  /// **'Bring the names and rooms you set up in Home Assistant. ZigDash reads them once and keeps nothing else from Home Assistant.'**
  String get haImportIntro;

  /// No description provided for @haImportAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant address'**
  String get haImportAddress;

  /// No description provided for @haImportAddressHelp.
  ///
  /// In en, this message translates to:
  /// **'The address you open Home Assistant with, like 192.168.1.20:8123'**
  String get haImportAddressHelp;

  /// No description provided for @haImportToken.
  ///
  /// In en, this message translates to:
  /// **'Long-lived access token'**
  String get haImportToken;

  /// No description provided for @haImportTokenHelp.
  ///
  /// In en, this message translates to:
  /// **'In Home Assistant, open your profile, then Security › Long-lived access tokens › Create token. Copy it and paste it here. ZigDash uses it once and doesn\'t keep it; you can delete it in Home Assistant afterwards.'**
  String get haImportTokenHelp;

  /// No description provided for @haImportRead.
  ///
  /// In en, this message translates to:
  /// **'Read from Home Assistant'**
  String get haImportRead;

  /// No description provided for @haImportReading.
  ///
  /// In en, this message translates to:
  /// **'Reading Home Assistant…'**
  String get haImportReading;

  /// No description provided for @haImportApplying.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get haImportApplying;

  /// No description provided for @haImportNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Type the address you open Home Assistant with.'**
  String get haImportNoAddress;

  /// No description provided for @haImportNoToken.
  ///
  /// In en, this message translates to:
  /// **'Paste a long-lived access token.'**
  String get haImportNoToken;

  /// No description provided for @haImportUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Nothing answered at that address. Check it, and that your phone is on your home network.'**
  String get haImportUnreachable;

  /// No description provided for @haImportNotHa.
  ///
  /// In en, this message translates to:
  /// **'Something answered at that address, but it isn\'t Home Assistant.'**
  String get haImportNotHa;

  /// No description provided for @haImportBadToken.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant refused that token. Create a new one and paste it again.'**
  String get haImportBadToken;

  /// No description provided for @haImportCertificate.
  ///
  /// In en, this message translates to:
  /// **'Your phone doesn\'t trust this Home Assistant\'s certificate. Try its http:// address on your home network.'**
  String get haImportCertificate;

  /// No description provided for @haImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant answered, but reading it failed. Try again.'**
  String get haImportFailed;

  /// No description provided for @haImportNoDevices.
  ///
  /// In en, this message translates to:
  /// **'ZigDash can\'t see this home\'s devices right now. Connect to the home, then try again.'**
  String get haImportNoDevices;

  /// No description provided for @haImportAutomations.
  ///
  /// In en, this message translates to:
  /// **'Your automations stay in Home Assistant and keep running.'**
  String get haImportAutomations;

  /// No description provided for @haImportFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device found in Home Assistant} other{{count} devices found in Home Assistant}}'**
  String haImportFound(int count);

  /// No description provided for @haImportRenameNote.
  ///
  /// In en, this message translates to:
  /// **'Tiles still named after their device take the name from Home Assistant. Dashboards you built stay as they are.'**
  String get haImportRenameNote;

  /// No description provided for @haImportMakeDashboards.
  ///
  /// In en, this message translates to:
  /// **'Also add dashboards from your floors and rooms'**
  String get haImportMakeDashboards;

  /// No description provided for @haImportOtherRooms.
  ///
  /// In en, this message translates to:
  /// **'Other rooms'**
  String get haImportOtherRooms;

  /// No description provided for @haImportNoRoom.
  ///
  /// In en, this message translates to:
  /// **'No room'**
  String get haImportNoRoom;

  /// No description provided for @haImportApply.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get haImportApply;

  /// No description provided for @haImportBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get haImportBack;

  /// No description provided for @haImportZhaOnly.
  ///
  /// In en, this message translates to:
  /// **'These devices run on ZHA, Home Assistant\'s own Zigbee, not on Zigbee2MQTT, so ZigDash can\'t show them.'**
  String get haImportZhaOnly;

  /// No description provided for @haImportNothing.
  ///
  /// In en, this message translates to:
  /// **'None of this home\'s Zigbee2MQTT devices are in Home Assistant.'**
  String get haImportNothing;

  /// No description provided for @haImportDone.
  ///
  /// In en, this message translates to:
  /// **'Done. Tiles renamed: {renamed}. Dashboards added: {dashboards}.'**
  String haImportDone(int renamed, int dashboards);

  /// No description provided for @haImportOpen.
  ///
  /// In en, this message translates to:
  /// **'Open dashboards'**
  String get haImportOpen;

  /// No description provided for @haImportOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring your names and rooms from Home Assistant?'**
  String get haImportOfferTitle;

  /// No description provided for @haImportOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant is on your network. ZigDash can name your tiles and add a dashboard per floor and room, the way you set them up there.'**
  String get haImportOfferBody;

  /// No description provided for @haImportOfferLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get haImportOfferLater;

  /// No description provided for @haImportOfferGo.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get haImportOfferGo;

  /// No description provided for @haImportSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Home Assistant'**
  String get haImportSignIn;

  /// No description provided for @haImportSignInHelp.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant\'s own login opens in your browser. ZigDash never sees your password and signs out again after reading.'**
  String get haImportSignInHelp;

  /// No description provided for @haImportOrToken.
  ///
  /// In en, this message translates to:
  /// **'Or use a long-lived token'**
  String get haImportOrToken;

  /// No description provided for @haImportReadToken.
  ///
  /// In en, this message translates to:
  /// **'Read with token'**
  String get haImportReadToken;

  /// No description provided for @haImportSignInRefused.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant didn\'t accept the sign-in. This happens when Home Assistant has no internet access. Use a long-lived token below instead.'**
  String get haImportSignInRefused;

  /// No description provided for @setupIsolatedHint.
  ///
  /// In en, this message translates to:
  /// **'Your phone can see almost nothing else on this Wi-Fi. It may be on a guest network, or the router may keep devices apart (often called client or AP isolation). Join your main Wi-Fi, or turn that off, then try again.'**
  String get setupIsolatedHint;

  /// No description provided for @setupAuthTrust.
  ///
  /// In en, this message translates to:
  /// **'Your login stays on this phone and goes only to your own broker. ZigDash has no server and no account, and every MQTT app logs in this way. Safest: a separate MQTT user just for ZigDash, which you can remove any time.'**
  String get setupAuthTrust;

  /// No description provided for @setupAuthWhatKept.
  ///
  /// In en, this message translates to:
  /// **'What ZigDash keeps'**
  String get setupAuthWhatKept;

  /// No description provided for @setupAuthDemoFirst.
  ///
  /// In en, this message translates to:
  /// **'Try the demo first'**
  String get setupAuthDemoFirst;

  /// No description provided for @automationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Automations'**
  String get automationsTitle;

  /// No description provided for @engineRunningOnHub.
  ///
  /// In en, this message translates to:
  /// **'Running on hub'**
  String get engineRunningOnHub;

  /// No description provided for @engineChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your hub…'**
  String get engineChecking;

  /// No description provided for @engineAwayNoHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach your hub right now'**
  String get engineAwayNoHubTitle;

  /// No description provided for @engineAwayNoHubBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re away, and your hub isn\'t connected to ZigDash\'s remote access, or its internet is down. Your automations keep running on the hub.'**
  String get engineAwayNoHubBody;

  /// No description provided for @engineAwayReinstallAtHome.
  ///
  /// In en, this message translates to:
  /// **'You can reinstall the Engine when you\'re at home.'**
  String get engineAwayReinstallAtHome;

  /// No description provided for @engineNoConnection.
  ///
  /// In en, this message translates to:
  /// **'ZigDash can\'t reach this Home\'s broker right now. Automations are set up while connected at home.'**
  String get engineNoConnection;

  /// No description provided for @engineRestarting.
  ///
  /// In en, this message translates to:
  /// **'Restarting Zigbee2MQTT… Your devices are back in about 30 seconds.'**
  String get engineRestarting;

  /// No description provided for @engineInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing on your hub…'**
  String get engineInstalling;

  /// No description provided for @engineTooOldTitle.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT needs an update'**
  String get engineTooOldTitle;

  /// No description provided for @engineTooOldBody.
  ///
  /// In en, this message translates to:
  /// **'Your Zigbee2MQTT is version {version}. Automations need 2.4 or newer. Update Zigbee2MQTT on your hub, then come back here.'**
  String engineTooOldBody(Object version);

  /// No description provided for @engineIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Automations run on your hub, not on your phone'**
  String get engineIntroTitle;

  /// No description provided for @engineIntroBody.
  ///
  /// In en, this message translates to:
  /// **'ZigDash puts ZigDash Engine inside Zigbee2MQTT on your hub. It watches your devices and runs your rules, so a light turns on when the door opens even with your phone off and the internet down.'**
  String get engineIntroBody;

  /// No description provided for @engineIntroNothingByHand.
  ///
  /// In en, this message translates to:
  /// **'Nothing to install by hand. ZigDash does it over your home network.'**
  String get engineIntroNothingByHand;

  /// No description provided for @engineIntroVersion.
  ///
  /// In en, this message translates to:
  /// **'Your Zigbee2MQTT is version {version}.'**
  String engineIntroVersion(Object version);

  /// No description provided for @engineIntroRemove.
  ///
  /// In en, this message translates to:
  /// **'You can remove it any time from this screen.'**
  String get engineIntroRemove;

  /// No description provided for @engineInstall.
  ///
  /// In en, this message translates to:
  /// **'Install on hub'**
  String get engineInstall;

  /// No description provided for @engineDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'No automations on this hub'**
  String get engineDeclinedTitle;

  /// No description provided for @engineDeclinedBody.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT on your hub doesn\'t allow add-ons, so nothing can run your rules while your phone is away. Scenes, alerts and the dashboard work as before.'**
  String get engineDeclinedBody;

  /// No description provided for @engineAllowAfterAll.
  ///
  /// In en, this message translates to:
  /// **'Allow add-ons after all'**
  String get engineAllowAfterAll;

  /// No description provided for @engineConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT needs one setting changed'**
  String get engineConsentTitle;

  /// No description provided for @engineConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Your Zigbee2MQTT blocks add-ons like ZigDash Engine, as new installs do. To run automations on your hub, ZigDash would turn on \"Allow external JavaScript\" in Zigbee2MQTT and restart it.'**
  String get engineConsentBody;

  /// No description provided for @engineConsentOutage.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT restarts once. Your lights and sensors can\'t be reached for about 30 seconds.'**
  String get engineConsentOutage;

  /// No description provided for @engineConsentOpen.
  ///
  /// In en, this message translates to:
  /// **'ZigDash Engine is open source. You can read it on your Zigbee2MQTT page under Extensions.'**
  String get engineConsentOpen;

  /// No description provided for @engineConsentUndo.
  ///
  /// In en, this message translates to:
  /// **'You can turn the setting off again later. Automations stop then.'**
  String get engineConsentUndo;

  /// No description provided for @engineConsentYes.
  ///
  /// In en, this message translates to:
  /// **'Change the setting and restart'**
  String get engineConsentYes;

  /// No description provided for @engineConsentNo.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get engineConsentNo;

  /// No description provided for @automationsPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Automations paused'**
  String get automationsPausedTitle;

  /// No description provided for @automationsPausedBody.
  ///
  /// In en, this message translates to:
  /// **'Your hub hasn\'t reported in for over a minute, so no automation can run until it does. Your rules are kept.'**
  String get automationsPausedBody;

  /// No description provided for @engineReinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstall on hub'**
  String get engineReinstall;

  /// No description provided for @engineStoppedTitle.
  ///
  /// In en, this message translates to:
  /// **'Automations paused: ZigDash Engine stopped itself'**
  String get engineStoppedTitle;

  /// No description provided for @engineStoppedBody.
  ///
  /// In en, this message translates to:
  /// **'It ran into errors three times in an hour and switched off so Zigbee2MQTT keeps running. Your rules are kept.'**
  String get engineStoppedBody;

  /// No description provided for @engineStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get engineStartAgain;

  /// No description provided for @engineReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get engineReportProblem;

  /// No description provided for @engineRunningTitle.
  ///
  /// In en, this message translates to:
  /// **'Your hub is ready for automations'**
  String get engineRunningTitle;

  /// No description provided for @engineRunningBody.
  ///
  /// In en, this message translates to:
  /// **'Rules loaded on the hub: {count}. Creating automations comes in the next step of this release.'**
  String engineRunningBody(Object count);

  /// No description provided for @engineClockOff.
  ///
  /// In en, this message translates to:
  /// **'Your hub\'s clock is more than five minutes off. Time-based automations will run at the wrong time until it is fixed.'**
  String get engineClockOff;

  /// No description provided for @engineRulesUnknown.
  ///
  /// In en, this message translates to:
  /// **'Rules ZigDash Engine on your hub can\'t run yet: {count}. Update it by reinstalling.'**
  String engineRulesUnknown(Object count);

  /// No description provided for @engineInstallRefused.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT refused ZigDash Engine: {error}'**
  String engineInstallRefused(Object error);

  /// No description provided for @engineInstallNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT didn\'t answer. Check that the Home is connected and try again.'**
  String get engineInstallNoAnswer;

  /// No description provided for @engineConsentFailed.
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT didn\'t accept the change or didn\'t come back. Check your hub and try again.'**
  String get engineConsentFailed;

  /// No description provided for @autoValMotion.
  ///
  /// In en, this message translates to:
  /// **'motion'**
  String get autoValMotion;

  /// No description provided for @autoValNoMotion.
  ///
  /// In en, this message translates to:
  /// **'no motion'**
  String get autoValNoMotion;

  /// No description provided for @autoValClosed.
  ///
  /// In en, this message translates to:
  /// **'closed'**
  String get autoValClosed;

  /// No description provided for @autoValOpened.
  ///
  /// In en, this message translates to:
  /// **'opened'**
  String get autoValOpened;

  /// No description provided for @autoValLeak.
  ///
  /// In en, this message translates to:
  /// **'leak'**
  String get autoValLeak;

  /// No description provided for @autoValDry.
  ///
  /// In en, this message translates to:
  /// **'dry'**
  String get autoValDry;

  /// No description provided for @autoValSmoke.
  ///
  /// In en, this message translates to:
  /// **'smoke'**
  String get autoValSmoke;

  /// No description provided for @autoValNoSmoke.
  ///
  /// In en, this message translates to:
  /// **'no smoke'**
  String get autoValNoSmoke;

  /// No description provided for @autoValOn.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get autoValOn;

  /// No description provided for @autoValOff.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get autoValOff;

  /// No description provided for @autoValToggle.
  ///
  /// In en, this message translates to:
  /// **'toggle'**
  String get autoValToggle;

  /// No description provided for @autoValOpen.
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get autoValOpen;

  /// No description provided for @autoValClose.
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get autoValClose;

  /// No description provided for @autoValStop.
  ///
  /// In en, this message translates to:
  /// **'stop'**
  String get autoValStop;

  /// No description provided for @autoWhenAbove.
  ///
  /// In en, this message translates to:
  /// **'When {device}: {property} above {value}'**
  String autoWhenAbove(Object device, Object property, Object value);

  /// No description provided for @autoWhenBelow.
  ///
  /// In en, this message translates to:
  /// **'When {device}: {property} below {value}'**
  String autoWhenBelow(Object device, Object property, Object value);

  /// No description provided for @autoWhenDevice.
  ///
  /// In en, this message translates to:
  /// **'When {device}: {what}'**
  String autoWhenDevice(Object device, Object what);

  /// No description provided for @autoAtTime.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String autoAtTime(Object time);

  /// No description provided for @autoSunrise.
  ///
  /// In en, this message translates to:
  /// **'sunrise'**
  String get autoSunrise;

  /// No description provided for @autoSunset.
  ///
  /// In en, this message translates to:
  /// **'sunset'**
  String get autoSunset;

  /// No description provided for @autoAfterSun.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min after {sun}'**
  String autoAfterSun(Object minutes, Object sun);

  /// No description provided for @autoBeforeSun.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before {sun}'**
  String autoBeforeSun(Object minutes, Object sun);

  /// No description provided for @autoAtSun.
  ///
  /// In en, this message translates to:
  /// **'At {sun}'**
  String autoAtSun(Object sun);

  /// No description provided for @autoEveryDay.
  ///
  /// In en, this message translates to:
  /// **'every day'**
  String get autoEveryDay;

  /// No description provided for @autoWeekdays.
  ///
  /// In en, this message translates to:
  /// **'weekdays'**
  String get autoWeekdays;

  /// No description provided for @autoWeekends.
  ///
  /// In en, this message translates to:
  /// **'weekends'**
  String get autoWeekends;

  /// No description provided for @autoBetween.
  ///
  /// In en, this message translates to:
  /// **'between {from} and {to}'**
  String autoBetween(Object from, Object to);

  /// No description provided for @autoDeviceIs.
  ///
  /// In en, this message translates to:
  /// **'{device} is {value}'**
  String autoDeviceIs(Object device, Object value);

  /// No description provided for @autoRunScene.
  ///
  /// In en, this message translates to:
  /// **'Run “{scene}”'**
  String autoRunScene(Object scene);

  /// No description provided for @autoSetDevice.
  ///
  /// In en, this message translates to:
  /// **'{device}: {state}'**
  String autoSetDevice(Object device, Object state);

  /// No description provided for @autoOffAfter.
  ///
  /// In en, this message translates to:
  /// **'{action}, off again after {minutes} min'**
  String autoOffAfter(Object action, Object minutes);

  /// No description provided for @autoErrPickTrigger.
  ///
  /// In en, this message translates to:
  /// **'Pick a device and what it does.'**
  String get autoErrPickTrigger;

  /// No description provided for @autoErrValue.
  ///
  /// In en, this message translates to:
  /// **'Type a number for the reading.'**
  String get autoErrValue;

  /// No description provided for @autoErrDays.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day.'**
  String get autoErrDays;

  /// No description provided for @autoErrTown.
  ///
  /// In en, this message translates to:
  /// **'Set your town for sunrise and sunset.'**
  String get autoErrTown;

  /// No description provided for @autoErrPickAction.
  ///
  /// In en, this message translates to:
  /// **'Pick what should happen.'**
  String get autoErrPickAction;

  /// No description provided for @autoErrEmptyScene.
  ///
  /// In en, this message translates to:
  /// **'That scene has nothing to send.'**
  String get autoErrEmptyScene;

  /// No description provided for @autoErrNotConnected.
  ///
  /// In en, this message translates to:
  /// **'ZigDash isn\'t connected to this Home. Try again at home.'**
  String get autoErrNotConnected;

  /// No description provided for @autoNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New automation'**
  String get autoNewTitle;

  /// No description provided for @autoEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit automation'**
  String get autoEditTitle;

  /// No description provided for @autoName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get autoName;

  /// No description provided for @autoNameHint.
  ///
  /// In en, this message translates to:
  /// **'What this does (optional)'**
  String get autoNameHint;

  /// No description provided for @autoWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get autoWhen;

  /// No description provided for @autoOnlyIf.
  ///
  /// In en, this message translates to:
  /// **'Only if'**
  String get autoOnlyIf;

  /// No description provided for @autoThen.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get autoThen;

  /// No description provided for @autoEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get autoEnabled;

  /// No description provided for @autoDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete automation'**
  String get autoDelete;

  /// No description provided for @autoSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get autoSave;

  /// No description provided for @autoDeviceChanges.
  ///
  /// In en, this message translates to:
  /// **'A device changes'**
  String get autoDeviceChanges;

  /// No description provided for @autoTimeComes.
  ///
  /// In en, this message translates to:
  /// **'A time comes'**
  String get autoTimeComes;

  /// No description provided for @autoDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get autoDevice;

  /// No description provided for @autoAbove.
  ///
  /// In en, this message translates to:
  /// **'above'**
  String get autoAbove;

  /// No description provided for @autoBelow.
  ///
  /// In en, this message translates to:
  /// **'below'**
  String get autoBelow;

  /// No description provided for @autoClockTime.
  ///
  /// In en, this message translates to:
  /// **'Clock time'**
  String get autoClockTime;

  /// No description provided for @autoAt.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get autoAt;

  /// No description provided for @autoShift.
  ///
  /// In en, this message translates to:
  /// **'Shift in minutes (minus is before)'**
  String get autoShift;

  /// No description provided for @autoTownNone.
  ///
  /// In en, this message translates to:
  /// **'No town set'**
  String get autoTownNone;

  /// No description provided for @autoTownIs.
  ///
  /// In en, this message translates to:
  /// **'Sun times for {town}'**
  String autoTownIs(Object town);

  /// No description provided for @autoTownSet.
  ///
  /// In en, this message translates to:
  /// **'Set town'**
  String get autoTownSet;

  /// No description provided for @autoTownChange.
  ///
  /// In en, this message translates to:
  /// **'Change town'**
  String get autoTownChange;

  /// No description provided for @autoDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get autoDays;

  /// No description provided for @autoNoConditions.
  ///
  /// In en, this message translates to:
  /// **'No conditions. It runs every time.'**
  String get autoNoConditions;

  /// No description provided for @autoAddHours.
  ///
  /// In en, this message translates to:
  /// **'Between hours'**
  String get autoAddHours;

  /// No description provided for @autoFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get autoFrom;

  /// No description provided for @autoTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get autoTo;

  /// No description provided for @autoAddDeviceCondition.
  ///
  /// In en, this message translates to:
  /// **'A device is…'**
  String get autoAddDeviceCondition;

  /// No description provided for @autoRunASceneOption.
  ///
  /// In en, this message translates to:
  /// **'Run a scene'**
  String get autoRunASceneOption;

  /// No description provided for @autoSetADevice.
  ///
  /// In en, this message translates to:
  /// **'Set a device'**
  String get autoSetADevice;

  /// No description provided for @autoScene.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get autoScene;

  /// No description provided for @autoTurnOffAgain.
  ///
  /// In en, this message translates to:
  /// **'Turn off again'**
  String get autoTurnOffAgain;

  /// No description provided for @autoStaysAsSet.
  ///
  /// In en, this message translates to:
  /// **'Stays as set'**
  String get autoStaysAsSet;

  /// No description provided for @autoOffAfterMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes after it ran'**
  String autoOffAfterMinutes(Object minutes);

  /// No description provided for @autoTownSearch.
  ///
  /// In en, this message translates to:
  /// **'Town'**
  String get autoTownSearch;

  /// No description provided for @autoTownWhy.
  ///
  /// In en, this message translates to:
  /// **'Used only for sunrise and sunset. Stored on your hub, never your location.'**
  String get autoTownWhy;

  /// No description provided for @autoNewButton.
  ///
  /// In en, this message translates to:
  /// **'New automation'**
  String get autoNewButton;

  /// No description provided for @autoEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing runs yet. Tap New automation to make the first one.'**
  String get autoEmptyBody;

  /// No description provided for @autoOnlyIfList.
  ///
  /// In en, this message translates to:
  /// **'only if {list}'**
  String autoOnlyIfList(Object list);

  /// No description provided for @autoEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get autoEdit;

  /// No description provided for @autoNeverRan.
  ///
  /// In en, this message translates to:
  /// **'never ran'**
  String get autoNeverRan;

  /// No description provided for @autoRanAt.
  ///
  /// In en, this message translates to:
  /// **'ran {time}'**
  String autoRanAt(Object time);

  /// No description provided for @autoFreeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} free automations'**
  String autoFreeCount(Object count, Object max);

  /// No description provided for @autoRecentRuns.
  ///
  /// In en, this message translates to:
  /// **'Recent runs'**
  String get autoRecentRuns;

  /// No description provided for @autoDeleted.
  ///
  /// In en, this message translates to:
  /// **'(deleted)'**
  String get autoDeleted;

  /// No description provided for @autoCeilingTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} automations are free. Want more?'**
  String autoCeilingTitle(Object count);

  /// No description provided for @autoCeilingBody.
  ///
  /// In en, this message translates to:
  /// **'ZigDash is free and open source, built by one person. Pro is a one-time purchase: unlimited automations, history for 7 and 30 days and the wall tablet extras. Your automations keep running whatever you choose.'**
  String get autoCeilingBody;

  /// No description provided for @autoCeilingSeePro.
  ///
  /// In en, this message translates to:
  /// **'See Pro'**
  String get autoCeilingSeePro;

  /// No description provided for @engineRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from hub'**
  String get engineRemove;

  /// No description provided for @engineRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove ZigDash Engine from your hub?'**
  String get engineRemoveTitle;

  /// No description provided for @engineRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Automations stop running. Your rules stay on the hub, so installing ZigDash Engine again brings them back.'**
  String get engineRemoveBody;

  /// No description provided for @autoNoTargets.
  ///
  /// In en, this message translates to:
  /// **'This Home has no light, plug, switch or shutter to control yet.'**
  String get autoNoTargets;

  /// No description provided for @proGetAutomations.
  ///
  /// In en, this message translates to:
  /// **'Unlimited automations; three per home are free'**
  String get proGetAutomations;

  /// No description provided for @proGetRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote control from anywhere, through the ZigDash relay, with no monthly fee'**
  String get proGetRemote;

  /// No description provided for @proRemoteFair.
  ///
  /// In en, this message translates to:
  /// **'Remote access is included while the ZigDash relay runs, for one home, up to five phones and normal household use. It may change or end with notice.'**
  String get proRemoteFair;

  /// No description provided for @autoDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this automation? It stops running on your hub.'**
  String get autoDeleteConfirm;

  /// No description provided for @statusConnectedRelay.
  ///
  /// In en, this message translates to:
  /// **'Connected · Away via ZigDash'**
  String get statusConnectedRelay;

  /// No description provided for @shareHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Share with another phone'**
  String get shareHomeTitle;

  /// No description provided for @shareHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add this home to another phone with one QR code'**
  String get shareHomeSubtitle;

  /// No description provided for @shareHomeIntro.
  ///
  /// In en, this message translates to:
  /// **'On the other phone, at home on the same Wi-Fi, scan the code with the camera. ZigDash adds this home with its login and your dashboards.'**
  String get shareHomeIntro;

  /// No description provided for @shareHomeLoginWarning.
  ///
  /// In en, this message translates to:
  /// **'The code includes this home\'s broker login. It shows for 2 minutes; show it only to people you trust.'**
  String get shareHomeLoginWarning;

  /// No description provided for @shareHomeShow.
  ///
  /// In en, this message translates to:
  /// **'Show the code'**
  String get shareHomeShow;

  /// No description provided for @shareHomeAtHome.
  ///
  /// In en, this message translates to:
  /// **'Connect at home first: sharing works only on your home network.'**
  String get shareHomeAtHome;

  /// No description provided for @shareHomeScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan with the other phone\'s camera. The code hides in 2 minutes.'**
  String get shareHomeScanHint;

  /// No description provided for @shareHomeHide.
  ///
  /// In en, this message translates to:
  /// **'Hide the code'**
  String get shareHomeHide;

  /// No description provided for @shareHomeViaHa.
  ///
  /// In en, this message translates to:
  /// **'This home connects through Home Assistant. On the other phone, install ZigDash and sign in with Home Assistant.'**
  String get shareHomeViaHa;

  /// No description provided for @joinHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a shared home'**
  String get joinHomeTitle;

  /// No description provided for @joinHomeInvalid.
  ///
  /// In en, this message translates to:
  /// **'This code isn\'t a ZigDash home invitation, or it\'s damaged.'**
  String get joinHomeInvalid;

  /// No description provided for @joinHomeAlready.
  ///
  /// In en, this message translates to:
  /// **'{name} is already on this phone.'**
  String joinHomeAlready(String name);

  /// No description provided for @joinHomeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open it'**
  String get joinHomeOpen;

  /// No description provided for @joinHomeAsk.
  ///
  /// In en, this message translates to:
  /// **'Add {name} to this phone?'**
  String joinHomeAsk(String name);

  /// No description provided for @joinHomeBody.
  ///
  /// In en, this message translates to:
  /// **'ZigDash adds the home with the same connection and login, and takes the dashboards from the other phone. Keep this phone on your home Wi-Fi.'**
  String get joinHomeBody;

  /// No description provided for @joinHomeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add home'**
  String get joinHomeAdd;

  /// No description provided for @joinHomeNoDashboards.
  ///
  /// In en, this message translates to:
  /// **'Home added. The dashboards didn\'t arrive; your devices are on the Devices tab.'**
  String get joinHomeNoDashboards;

  /// No description provided for @remoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote control'**
  String get remoteTitle;

  /// No description provided for @remoteSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control this home from anywhere, with Pro'**
  String get remoteSettingsSubtitle;

  /// No description provided for @remoteIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Control your home from anywhere'**
  String get remoteIntroTitle;

  /// No description provided for @remoteOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Reach your devices when you\'re away, through ZigDash\'s encrypted relay. Part of Pro: one payment, no monthly fee. Set it up while you\'re at home.'**
  String get remoteOfferBody;

  /// No description provided for @remoteOfferBodyPro.
  ///
  /// In en, this message translates to:
  /// **'You have Pro: turn on remote control while you\'re at home, then reach your devices from anywhere.'**
  String get remoteOfferBodyPro;

  /// No description provided for @remoteOfferShow.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get remoteOfferShow;

  /// No description provided for @remoteIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Your hub keeps one connection to ZigDash\'s relay. Away from home, this phone reaches your devices through it. Everything is encrypted on your hub and your phone, so the relay can\'t read your devices or what they do.'**
  String get remoteIntroBody;

  /// No description provided for @remoteNeedsEngine.
  ///
  /// In en, this message translates to:
  /// **'Remote control runs in ZigDash Engine. Install it under Automations first.'**
  String get remoteNeedsEngine;

  /// No description provided for @remoteSetUp.
  ///
  /// In en, this message translates to:
  /// **'Turn on remote control'**
  String get remoteSetUp;

  /// No description provided for @remoteNeedsPro.
  ///
  /// In en, this message translates to:
  /// **'Remote control is part of Pro.'**
  String get remoteNeedsPro;

  /// No description provided for @remoteNotAtHome.
  ///
  /// In en, this message translates to:
  /// **'Turn this on at home, connected to your broker.'**
  String get remoteNotAtHome;

  /// No description provided for @remoteUnreachable.
  ///
  /// In en, this message translates to:
  /// **'ZigDash\'s relay didn\'t answer. Try again later.'**
  String get remoteUnreachable;

  /// No description provided for @remoteRefused.
  ///
  /// In en, this message translates to:
  /// **'The relay refused. Try again, or report a problem.'**
  String get remoteRefused;

  /// No description provided for @remoteOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote control is on'**
  String get remoteOnTitle;

  /// No description provided for @remoteOnBody.
  ///
  /// In en, this message translates to:
  /// **'Away from home, ZigDash connects through the relay by itself.'**
  String get remoteOnBody;

  /// No description provided for @remoteHubOnline.
  ///
  /// In en, this message translates to:
  /// **'Your hub is connected to the relay'**
  String get remoteHubOnline;

  /// No description provided for @remoteHubOffline.
  ///
  /// In en, this message translates to:
  /// **'Your hub isn\'t connected to the relay'**
  String get remoteHubOffline;

  /// No description provided for @remoteTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off remote control'**
  String get remoteTurnOff;

  /// No description provided for @remoteViaRelayNow.
  ///
  /// In en, this message translates to:
  /// **'This phone is connected through the relay right now.'**
  String get remoteViaRelayNow;

  /// No description provided for @remotePhones.
  ///
  /// In en, this message translates to:
  /// **'Phones with remote access'**
  String get remotePhones;

  /// No description provided for @remoteThisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get remoteThisPhone;

  /// No description provided for @remoteOtherPhone.
  ///
  /// In en, this message translates to:
  /// **'Another phone'**
  String get remoteOtherPhone;

  /// No description provided for @remotePhoneAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String remotePhoneAdded(Object date);

  /// No description provided for @remoteRemovePhone.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remoteRemovePhone;

  /// No description provided for @remoteRemovePhoneConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this phone? It can no longer reach this home from away.'**
  String get remoteRemovePhoneConfirm;

  /// No description provided for @remoteAddPhone.
  ///
  /// In en, this message translates to:
  /// **'Add a phone'**
  String get remoteAddPhone;

  /// No description provided for @remoteAddPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'At home, scan this with the other phone\'s camera. It opens ZigDash and adds remote control there. Show it only to your own phones.'**
  String get remoteAddPhoneHint;

  /// No description provided for @remoteAddPhoneFailed.
  ///
  /// In en, this message translates to:
  /// **'The relay didn\'t give a login for another phone. A home can have up to five.'**
  String get remoteAddPhoneFailed;

  /// No description provided for @remoteBackupSave.
  ///
  /// In en, this message translates to:
  /// **'Save a key backup'**
  String get remoteBackupSave;

  /// No description provided for @remoteBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a key backup'**
  String get remoteBackupRestore;

  /// No description provided for @remoteBackupPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Backup passphrase'**
  String get remoteBackupPassphrase;

  /// No description provided for @remoteBackupPassphraseHint.
  ///
  /// In en, this message translates to:
  /// **'If you lose this phone, the backup and this passphrase bring remote control back on a new one. Use at least 8 characters, and keep the passphrase somewhere else than the file.'**
  String get remoteBackupPassphraseHint;

  /// No description provided for @remoteBackupPassphraseAsk.
  ///
  /// In en, this message translates to:
  /// **'The passphrase you chose when you saved the backup.'**
  String get remoteBackupPassphraseAsk;

  /// No description provided for @remoteBackupPassphraseAgain.
  ///
  /// In en, this message translates to:
  /// **'Passphrase again'**
  String get remoteBackupPassphraseAgain;

  /// No description provided for @remoteBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'Key backup saved'**
  String get remoteBackupSaved;

  /// No description provided for @remoteBackupWrong.
  ///
  /// In en, this message translates to:
  /// **'That passphrase doesn\'t open this backup.'**
  String get remoteBackupWrong;

  /// No description provided for @remoteBackupWrongFile.
  ///
  /// In en, this message translates to:
  /// **'That isn\'t a ZigDash key backup.'**
  String get remoteBackupWrongFile;

  /// No description provided for @remotePlayOnly.
  ///
  /// In en, this message translates to:
  /// **'Remote control is in the Google Play version of ZigDash for now.'**
  String get remotePlayOnly;

  /// No description provided for @remotePairTitle.
  ///
  /// In en, this message translates to:
  /// **'Add remote control'**
  String get remotePairTitle;

  /// No description provided for @remotePairBody.
  ///
  /// In en, this message translates to:
  /// **'Which home is this? ZigDash keeps the remote login for it.'**
  String get remotePairBody;

  /// No description provided for @remotePairNoHomes.
  ///
  /// In en, this message translates to:
  /// **'Set this home up on this phone first, at home. Then scan the code again.'**
  String get remotePairNoHomes;

  /// No description provided for @remotePairInvalid.
  ///
  /// In en, this message translates to:
  /// **'This code isn\'t a ZigDash remote control code, or it was cut off.'**
  String get remotePairInvalid;

  /// No description provided for @remotePairDone.
  ///
  /// In en, this message translates to:
  /// **'Remote control is on for {home}'**
  String remotePairDone(Object home);

  /// No description provided for @remoteReconnectHub.
  ///
  /// In en, this message translates to:
  /// **'Reconnect the hub'**
  String get remoteReconnectHub;

  /// No description provided for @remoteTurnOffConfirm.
  ///
  /// In en, this message translates to:
  /// **'This phone leaves remote control and your hub disconnects from the relay. A key backup saved from this phone stops working; other phones keep their access until you remove them.'**
  String get remoteTurnOffConfirm;

  /// No description provided for @remoteHomeId.
  ///
  /// In en, this message translates to:
  /// **'Home ID {id}'**
  String remoteHomeId(Object id);

  /// Automations tab: card pointing to Alerts (3.2.1).
  ///
  /// In en, this message translates to:
  /// **'Get notified on this phone'**
  String get alertsHintTitle;

  /// Automations tab: card pointing to Alerts (3.2.1).
  ///
  /// In en, this message translates to:
  /// **'A leak, smoke, an opened door or a low battery can send a notification to this phone, even with ZigDash closed.'**
  String get alertsHintBody;

  /// Automations tab: card pointing to Alerts (3.2.1).
  ///
  /// In en, this message translates to:
  /// **'Set up Alerts'**
  String get alertsHintButton;

  /// Automations tab: card pointing to Alerts (3.2.1).
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get alertsHintNotNow;

  /// Test & connect: a broker with no Zigbee2MQTT on it (3.2.1).
  ///
  /// In en, this message translates to:
  /// **'An MQTT broker answers here, but Zigbee2MQTT isn\'t sending anything on it. Check that Zigbee2MQTT is started and uses this broker, and that the base topic matches its settings. If your Zigbee devices are in Home Assistant\'s ZHA, ZigDash can\'t see them: it works with Zigbee2MQTT.'**
  String get guidedNoZ2mBody;

  /// Devices tab: Zigbee2MQTT found under another base topic (3.2.2).
  ///
  /// In en, this message translates to:
  /// **'Zigbee2MQTT is on this broker with the base topic “{found}”, but this Home looks for “{current}”.'**
  String devicesOtherBaseBody(String found, String current);

  /// Devices tab: button that switches the Home to the base topic found (3.2.2).
  ///
  /// In en, this message translates to:
  /// **'Use “{found}”'**
  String devicesUseBase(String found);

  /// Devices tab: no Zigbee2MQTT on the broker, opens the connection settings (3.2.2).
  ///
  /// In en, this message translates to:
  /// **'Change connection'**
  String get devicesChangeConnection;

  /// Dashboard: Play in-app update banner (3.2.3).
  ///
  /// In en, this message translates to:
  /// **'A new version of ZigDash is ready'**
  String get updateAvailableTitle;

  /// Dashboard: Play in-app update banner (3.2.3).
  ///
  /// In en, this message translates to:
  /// **'It downloads while you keep using ZigDash.'**
  String get updateAvailableBody;

  /// Dashboard: Play in-app update banner (3.2.3).
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAvailableButton;

  /// Dashboard: Play in-app update banner (3.2.3).
  ///
  /// In en, this message translates to:
  /// **'Downloading the update…'**
  String get updateDownloading;

  /// Dashboard: Play in-app update banner (3.2.3).
  ///
  /// In en, this message translates to:
  /// **'Update downloaded'**
  String get updateReadyTitle;

  /// Dashboard: Play in-app update banner (3.2.3).
  ///
  /// In en, this message translates to:
  /// **'Restart to finish'**
  String get updateReadyButton;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Write to NFC tag'**
  String get nfcWriteTag;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Hold a tag to your phone'**
  String get nfcHoldTitle;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Hold a blank NFC sticker to the back of your phone. Tapping it later runs {name}.'**
  String nfcHoldBody(String name);

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Tag ready'**
  String get nfcWrittenTitle;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Tap your phone on this tag to run {name}. It works with ZigDash closed.'**
  String nfcWrittenBody(String name);

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t write the tag'**
  String get nfcFailedTitle;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'This tag is locked and can\'t be changed. Try another one.'**
  String get nfcReadonlyBody;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'This tag is too small. Use an NTAG213 sticker or larger.'**
  String get nfcTooSmallBody;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Hold the tag still against the back of the phone and try again.'**
  String get nfcFailedBody;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'NFC is off'**
  String get nfcOffTitle;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Turn on NFC in Android\'s settings, then try again.'**
  String get nfcOffBody;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'No NFC on this phone'**
  String get nfcNoneTitle;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'This phone can\'t read or write NFC tags.'**
  String get nfcNoneBody;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'Write another tag'**
  String get nfcWriteAnother;

  /// NFC tags (3.3).
  ///
  /// In en, this message translates to:
  /// **'This kind of tag can\'t be written by this phone (often MIFARE Classic). Use an NTAG213, 215 or 216 sticker.'**
  String get nfcUnsupportedBody;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'NFC tags'**
  String get nfcTagsTitle;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'Tags that run a scene or switch a device'**
  String get nfcTagsSubtitle;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Long-press a scene, light, plug or shutter tile and choose Write to NFC tag.'**
  String get nfcTagsEmpty;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'Runs the scene'**
  String get nfcTagRunsScene;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'Switches on and off'**
  String get nfcTagSwitches;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'written {when}'**
  String nfcTagWritten(String when);

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'last tapped {when}'**
  String nfcTagLastTap(String when);

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'not tapped yet'**
  String get nfcTagNeverTapped;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get nfcTagOffLabel;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'Rewrite'**
  String get nfcTagRewrite;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get nfcTagForget;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'This tag is turned off in ZigDash'**
  String get nfcTagOffToast;

  /// NFC tags list (3.3).
  ///
  /// In en, this message translates to:
  /// **'A tag you turn off does nothing on this phone. Tags written before this list aren\'t shown: rewrite them once.'**
  String get nfcTagsNote;

  /// NFC tag popup (3.3), shown by Android outside the app.
  ///
  /// In en, this message translates to:
  /// **'ZigDash tag'**
  String get nfcPopupHeader;

  /// NFC tag popup (3.3), shown by Android outside the app.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get nfcPopupRunning;

  /// NFC tag popup (3.3), shown by Android outside the app.
  ///
  /// In en, this message translates to:
  /// **'Switching…'**
  String get nfcPopupSwitching;

  /// NFC tag popup (3.3), shown by Android outside the app.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get nfcPopupDone;

  /// NFC tag popup (3.3), shown by Android outside the app.
  ///
  /// In en, this message translates to:
  /// **'Closes in 2 seconds'**
  String get nfcPopupClosing;

  /// NFC tag popup (3.3), shown by Android outside the app.
  ///
  /// In en, this message translates to:
  /// **'This phone can\'t reach the home right now. Check the Wi-Fi, or turn on remote control.'**
  String get nfcPopupUnreachable;

  /// NFC tag popup (3.3), shown by Android outside the app.
  ///
  /// In en, this message translates to:
  /// **'Nothing was switched. Turn it back on in the Home\'s settings, under NFC tags.'**
  String get nfcPopupOffBody;

  /// NFC tag popup (3.3), shown by Android outside the app.
  ///
  /// In en, this message translates to:
  /// **'Open ZigDash'**
  String get nfcPopupOpenApp;
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
    'cs',
    'de',
    'en',
    'es',
    'fr',
    'he',
    'it',
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
    case 'cs':
      return AppLocalizationsCs();
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
    case 'it':
      return AppLocalizationsIt();
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
