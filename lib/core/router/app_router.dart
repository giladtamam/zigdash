import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/connections/screens/connection_form_screen.dart';
import '../../features/connections/screens/connections_list_screen.dart';
import '../../features/dashboards/screens/dashboards_placeholder.dart';
import '../../features/settings/screens/settings_placeholder.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.connections,
    routes: [
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
