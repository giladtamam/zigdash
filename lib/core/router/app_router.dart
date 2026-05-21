import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database/tables/panels.dart';
import '../../features/connections/screens/connection_form_screen.dart';
import '../../features/connections/screens/connections_list_screen.dart';
import '../../features/dashboards/screens/dashboard_form_screen.dart';
import '../../features/dashboards/screens/dashboards_placeholder.dart';
import '../../features/dashboards/screens/dashboards_screen.dart';
import '../../features/panels/screens/panel_form_screen.dart';
import '../../features/settings/screens/settings_placeholder.dart';
import 'routes.dart';

PanelType _parseType(String? s) => switch (s) {
      'button' => PanelType.button,
      'slider' => PanelType.slider,
      'led' => PanelType.led,
      'nodeStatus' => PanelType.nodeStatus,
      'progress' => PanelType.progress,
      'multiState' => PanelType.multiState,
      'combo' => PanelType.combo,
      'radio' => PanelType.radio,
      'cover' => PanelType.cover,
      'textInput' => PanelType.textInput,
      'textLog' => PanelType.textLog,
      _ => PanelType.toggle,
    };

SliderPreset? _parseSliderPreset(String? s) => switch (s) {
      'brightness' => SliderPreset.brightness,
      'position' => SliderPreset.position,
      _ => null,
    };

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.connections,
    routes: [
      // Full-screen routes (no bottom nav). Push these from inside the shell
      // and the shell's NavigationBar gets out of the way.
      GoRoute(
        path: '/connections/:id/dashboards',
        builder: (_, state) => DashboardsScreen(connectionId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'form',
            builder: (_, state) => DashboardFormScreen(
              connectionId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: ':dashboardId/edit',
            builder: (_, state) => DashboardFormScreen(
              connectionId: state.pathParameters['id']!,
              dashboardId: state.pathParameters['dashboardId'],
            ),
          ),
          GoRoute(
            path: ':dashboardId/panels/new',
            builder: (_, state) => PanelFormScreen(
              connectionId: state.pathParameters['id']!,
              dashboardId: state.pathParameters['dashboardId']!,
              initialType: _parseType(state.uri.queryParameters['type']),
              initialSliderPreset:
                  _parseSliderPreset(state.uri.queryParameters['preset']),
            ),
          ),
          GoRoute(
            path: ':dashboardId/panels/:panelId/edit',
            builder: (_, state) => PanelFormScreen(
              connectionId: state.pathParameters['id']!,
              dashboardId: state.pathParameters['dashboardId']!,
              panelId: state.pathParameters['panelId'],
            ),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _RootShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.connections,
                builder: (_, __) => const ConnectionsListScreen(),
                routes: [
                  GoRoute(
                    path: 'form',
                    builder: (_, __) => const ConnectionFormScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (_, state) =>
                        ConnectionFormScreen(connectionId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboards,
                builder: (_, __) => const DashboardsPlaceholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (_, __) => const SettingsPlaceholder(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RootShell extends StatelessWidget {
  const _RootShell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.cloud_outlined), selectedIcon: Icon(Icons.cloud), label: 'Brokers'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboards'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
