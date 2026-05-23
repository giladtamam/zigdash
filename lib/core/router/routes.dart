class Routes {
  Routes._();

  static const connections = '/connections';
  static const connectionForm = '/connections/form';
  static const connectionEdit = '/connections/:id/edit';
  static const dashboards = '/dashboards';
  static const settings = '/settings';
  static const help = '/help';
  static const deviceDiscovery = '/connections/:id/dashboards/:dashboardId/discover';
  static const devices = '/connections/:id/devices';
}
