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
}
