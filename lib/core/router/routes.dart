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
  static const help = '/help';
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
