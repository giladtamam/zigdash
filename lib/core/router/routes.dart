class Routes {
  Routes._();

  static const onboarding = '/onboarding';
  static const connections = '/connections';
  static const connectionForm = '/connections/form';
  // Setup and its manual entry sit outside the navigation shell.
  static const setup = '/setup';
  static const guidedConnect = '/setup/manual';
  static const connectionEdit = '/connections/:id/edit';
  static const dashboards = '/dashboards';
  static const settings = '/settings';
  static const settingsLanguage = '/settings/language';
  static String settingsHome(String connectionId) =>
      '/settings/home/$connectionId';
  static String homeAlerts(String connectionId) =>
      '/settings/home/$connectionId/alerts';
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
  static String getHelpFrom(String from, {String? home, String? error}) =>
      Uri(path: getHelp, queryParameters: {
        'from': from,
        if (home != null) 'home': home,
        if (error != null) 'error': error,
      }).toString();
  static const deviceDiscovery = '/connections/:id/dashboards/:dashboardId/discover';
  static const devices = '/connections/:id/devices';
  static const scenes = '/connections/:id/scenes';

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
