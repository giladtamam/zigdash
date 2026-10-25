class Routes {
  Routes._();

  static const onboarding = '/onboarding';
  static const connections = '/connections';
  static const connectionForm = '/connections/form';
  // Setup and its manual entry sit outside the navigation shell.
  static const setup = '/setup';
  static const guidedConnect = '/setup/manual';

  /// Manual entry with the host and port filled in (a hub the scan found).
  static String guidedConnectTo(String host, int port) => Uri(
    path: guidedConnect,
    queryParameters: {'host': host, 'port': '$port'},
  ).toString();

  /// Connecting through Home Assistant (docs/design/ha-route.md), with
  /// the address filled in when the scan saw Home Assistant.
  static const haConnect = '/setup/home-assistant';
  static String haConnectAt(String? host) => host == null
      ? haConnect
      : Uri(path: haConnect, queryParameters: {'host': host}).toString();

  /// Connecting through Home Assistant from the no-Wi-Fi screen (3.1.9):
  /// no network to look on, so the address (a remote one) is typed.
  static final haConnectOffWifi = Uri(
    path: haConnect,
    queryParameters: {'wifi': 'off'},
  ).toString();

  /// Signing in again for a home that connects through Home Assistant
  /// (2.10.1): a new phone, or a token the user removed.
  static String haConnectAgain(String connectionId, String host) => Uri(
    path: haConnect,
    queryParameters: {'again': connectionId, 'host': host},
  ).toString();
  static const connectionEdit = '/connections/:id/edit';
  static const dashboards = '/dashboards';
  static const settings = '/settings';
  static const settingsLanguage = '/settings/language';
  static String settingsHome(String connectionId) =>
      '/settings/home/$connectionId';
  static String homeRemote(String connectionId) =>
      '/settings/home/$connectionId/remote';
  /// The Automations tab (3.1.1): the fourth destination of a home.
  static String homeAutomations(String connectionId) =>
      '/connections/$connectionId/automations';
  /// Joining a home another phone shared (3.1.7): zigdash://home/join?c=…
  static const joinHome = '/join';

  /// Share this home with another phone at home (3.1.7).
  static String homeShare(String connectionId) =>
      '/settings/home/$connectionId/share';
  static String homeAlerts(String connectionId) =>
      '/settings/home/$connectionId/alerts';

  /// Importing names and rooms from Home Assistant (docs/design/ha-import.md).
  static String homeHaImport(String connectionId) =>
      '/settings/home/$connectionId/ha-import';
  static String homeAlertEdit(String connectionId, String alertId) =>
      '/settings/home/$connectionId/alerts/$alertId';

  /// The editor for a new alert of [kind] with [ieee] already ticked, or
  /// the alert that device is already in (Notify me… on a device page).
  static String homeAlertFor(String connectionId, String kind, String ieee) =>
      '/settings/home/$connectionId/alerts/new?kind=$kind&ieee=${Uri.encodeQueryComponent(ieee)}';
  static const help = '/help';
  static const getHelp = '/get-help';

  /// Choosing the device a Quick Settings tile slot controls.
  static String shortcutTile(int slot) => '/shortcuts/tile/$slot';

  /// Get help, opened [from] a place (an `HelpFrom` name), for a home or a
  /// setup error (a `SetupErrorKind` name) when there is one.
  static String getHelpFrom(String from, {String? home, String? error}) => Uri(
    path: getHelp,
    queryParameters: {
      'from': from,
      if (home != null) 'home': home,
      if (error != null) 'error': error,
    },
  ).toString();
  static const deviceDiscovery =
      '/connections/:id/dashboards/:dashboardId/discover';
  static const devices = '/connections/:id/devices';
  static const scenes = '/connections/:id/scenes';
  static const automations = '/connections/:id/automations';

  /// Opens the first home, or setup when there is none.
  static const start = '/start';

  static String homeDevices(String connectionId) =>
      '/connections/$connectionId/devices';

  /// The device page, by IEEE address so it follows renames.
  static String homeDevice(String connectionId, String ieee) =>
      '/connections/$connectionId/devices/$ieee';

  static String homeScenes(String connectionId) =>
      '/connections/$connectionId/scenes';

  /// The dashboards of home (connection) [connectionId].
  static String homeDashboards(String connectionId) =>
      '/connections/$connectionId/dashboards';
}
