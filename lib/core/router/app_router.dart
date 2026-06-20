import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database/tables/panels.dart';
import '../l10n/l10n_ext.dart';
import '../../features/connections/screens/connection_form_screen.dart';
import '../../features/connections/screens/connections_list_screen.dart';
import '../../features/dashboards/screens/dashboard_form_screen.dart';
import '../../features/dashboards/screens/dashboards_placeholder.dart';
import '../../features/dashboards/screens/dashboards_screen.dart';
import '../../features/panels/screens/panel_form_screen.dart';
import '../../features/discovery/models/device_panel_suggestion.dart';
import '../../features/discovery/screens/device_picker_screen.dart';
import '../../features/devices/screens/devices_screen.dart';
import '../../features/scenes/screens/scenes_screen.dart';
import '../../features/scenes/screens/scene_form_screen.dart';
import '../../features/help/screens/help_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import 'routes.dart';

/// Maps a `?type=` query token to a [PanelType]. Tokens are the enum's
/// `.name` (the panel picker pushes `PanelType.<x>.name`), so resolve by name
/// and fall back to [PanelType.toggle] for null/unknown values. Resolving by
/// name (rather than a hand-kept switch) means new panel types are routable
/// automatically — a missing case here previously sent `autoClose` to toggle.
@visibleForTesting
PanelType parsePanelTypeToken(String? s) {
  if (s == null) return PanelType.toggle;
  try {
    return PanelType.values.byName(s);
  } on ArgumentError {
    return PanelType.toggle;
  }
}

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
        path: Routes.help,
        builder: (_, __) => const HelpScreen(),
      ),
      GoRoute(
        path: Routes.devices,
        builder: (_, state) =>
            DevicesScreen(connectionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.scenes,
        builder: (_, state) =>
            ScenesScreen(connectionId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, state) =>
                SceneFormScreen(connectionId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: ':sceneId/edit',
            builder: (_, state) => SceneFormScreen(
              connectionId: state.pathParameters['id']!,
              sceneId: state.pathParameters['sceneId'],
            ),
          ),
        ],
      ),
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
              initialType:
                  parsePanelTypeToken(state.uri.queryParameters['type']),
              initialSliderPreset:
                  _parseSliderPreset(state.uri.queryParameters['preset']),
              suggestion: state.extra as PanelSuggestion?,
            ),
          ),
          GoRoute(
            path: ':dashboardId/discover',
            builder: (_, state) => DevicePickerScreen(
              connectionId: state.pathParameters['id']!,
              dashboardId: state.pathParameters['dashboardId']!,
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
                builder: (_, __) => const SettingsScreen(),
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
        destinations: [
          NavigationDestination(icon: const Icon(Icons.cloud_outlined), selectedIcon: const Icon(Icons.cloud), label: context.l10n.navBrokers),
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: context.l10n.navDashboards),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: context.l10n.navSettings),
        ],
      ),
    );
  }
}
