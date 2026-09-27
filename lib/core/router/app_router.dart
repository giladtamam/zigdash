import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database/tables/panels.dart';
import '../../features/connections/screens/connection_form_screen.dart';
import '../../features/connections/screens/connections_list_screen.dart';
import '../../features/guided_connect/guided_connect_screen.dart';
import '../../features/onboarding/setup/setup_screen.dart';
import '../../features/dashboards/screens/dashboard_form_screen.dart';
import '../../features/dashboards/screens/dashboards_screen.dart';
import '../../features/onboarding/onboarding_provider.dart';
import '../../features/panels/screens/panel_form_screen.dart';
import '../../features/discovery/models/device_panel_suggestion.dart';
import '../../features/discovery/screens/device_picker_screen.dart';
import '../../features/panels/screens/add_tile_screen.dart';
import '../../features/devices/screens/device_page.dart';
import '../../features/devices/screens/devices_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/scenes/screens/scenes_screen.dart';
import '../../features/scenes/screens/scene_form_screen.dart';
import '../../features/help/screens/help_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import 'first_run_redirect.dart';
import 'last_dashboard_store.dart';
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
  // Read once: the app opens on the last-used home's dashboards.
  final startLocation = ref.read(lastDashboardStoreProvider).startLocation;
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: startLocation,
    // First run lives in the router (not in MaterialApp's builder) so its
    // screens can navigate with context.go — an InheritedGoRouter is only
    // available below the Router.
    redirect: (context, state) => firstRunRedirect(
      needsSetup: ref.read(onboardingProvider).needsOnboarding,
      location: state.matchedLocation,
      startLocation: ref.read(lastDashboardStoreProvider).startLocation,
    ),
    routes: [
      // Retired carousel address; the redirect above always leaves it.
      GoRoute(
        path: Routes.onboarding,
        redirect: (_, __) => Routes.setup,
      ),
      // First run and adding a home: outside the navigation shell.
      GoRoute(
        path: Routes.setup,
        builder: (_, __) => const SetupScreen(),
        routes: [
          GoRoute(
            path: 'manual',
            pageBuilder: (_, __) => _slideUp(const GuidedConnectScreen()),
          ),
        ],
      ),
      GoRoute(
        path: Routes.help,
        pageBuilder: (_, __) => _slideUp(const HelpScreen()),
      ),
      // One home at a time: Dashboards, Devices and Scenes share the bottom
      // bar; screens opened from them cover it (root navigator).
      ShellRoute(
        builder: (_, state, child) => HomeShell(
          connectionId: state.pathParameters['id']!,
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/connections/:id/dashboards',
            pageBuilder: (_, state) => NoTransitionPage(
                child:
                    DashboardsScreen(connectionId: state.pathParameters['id']!)),
            routes: [
              GoRoute(
                parentNavigatorKey: rootKey,
                path: 'form',
                pageBuilder: (_, state) => _slideUp(DashboardFormScreen(
                  connectionId: state.pathParameters['id']!,
                )),
              ),
              GoRoute(
                parentNavigatorKey: rootKey,
                path: ':dashboardId/edit',
                pageBuilder: (_, state) => _slideUp(DashboardFormScreen(
                  connectionId: state.pathParameters['id']!,
                  dashboardId: state.pathParameters['dashboardId'],
                )),
              ),
              GoRoute(
                parentNavigatorKey: rootKey,
                path: ':dashboardId/panels/new',
                pageBuilder: (_, state) => _slideUp(PanelFormScreen(
                  connectionId: state.pathParameters['id']!,
                  dashboardId: state.pathParameters['dashboardId']!,
                  initialType:
                      parsePanelTypeToken(state.uri.queryParameters['type']),
                  initialSliderPreset:
                      _parseSliderPreset(state.uri.queryParameters['preset']),
                  suggestion: state.extra as PanelSuggestion?,
                )),
              ),
              GoRoute(
                parentNavigatorKey: rootKey,
                path: ':dashboardId/add',
                pageBuilder: (_, state) {
                  final connectionId = state.pathParameters['id']!;
                  final dashboardId = state.pathParameters['dashboardId']!;
                  return _slideUp(AddTileScreen(
                    connectionId: connectionId,
                    dashboardId: dashboardId,
                    onCustomTile: (context) => openCustomTilePicker(context,
                        connectionId: connectionId, dashboardId: dashboardId),
                  ));
                },
              ),
              GoRoute(
                parentNavigatorKey: rootKey,
                path: ':dashboardId/discover',
                pageBuilder: (_, state) => _slideUp(DevicePickerScreen(
                  connectionId: state.pathParameters['id']!,
                  dashboardId: state.pathParameters['dashboardId']!,
                )),
              ),
              GoRoute(
                parentNavigatorKey: rootKey,
                path: ':dashboardId/panels/:panelId/edit',
                pageBuilder: (_, state) => _slideUp(PanelFormScreen(
                  connectionId: state.pathParameters['id']!,
                  dashboardId: state.pathParameters['dashboardId']!,
                  panelId: state.pathParameters['panelId'],
                )),
              ),
            ],
          ),
          GoRoute(
            path: Routes.devices,
            pageBuilder: (_, state) => NoTransitionPage(
                child: DevicesScreen(connectionId: state.pathParameters['id']!)),
            routes: [
              GoRoute(
                parentNavigatorKey: rootKey,
                path: ':ieee',
                builder: (_, state) => DevicePage(
                  connectionId: state.pathParameters['id']!,
                  ieee: state.pathParameters['ieee']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.scenes,
            pageBuilder: (_, state) => NoTransitionPage(
                child: ScenesScreen(connectionId: state.pathParameters['id']!)),
            routes: [
              GoRoute(
                parentNavigatorKey: rootKey,
                path: 'new',
                pageBuilder: (_, state) => _slideUp(
                    SceneFormScreen(connectionId: state.pathParameters['id']!)),
              ),
              GoRoute(
                parentNavigatorKey: rootKey,
                path: ':sceneId/edit',
                pageBuilder: (_, state) => _slideUp(SceneFormScreen(
                  connectionId: state.pathParameters['id']!,
                  sceneId: state.pathParameters['sceneId'],
                )),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.start,
        builder: (_, __) => const HomeStartScreen(),
      ),
      GoRoute(
        path: Routes.dashboards,
        redirect: (_, __) => Routes.start,
      ),
      // Manage homes (the broker list) until 1.13 Settings.
      GoRoute(
        path: Routes.connections,
        pageBuilder: (_, __) => _slideUp(const ConnectionsListScreen()),
        routes: [
          GoRoute(
            path: 'form',
            pageBuilder: (_, __) => _slideUp(const ConnectionFormScreen()),
          ),
          GoRoute(
            path: ':id/edit',
            pageBuilder: (_, state) => _slideUp(ConnectionFormScreen(
                connectionId: state.pathParameters['id'])),
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        pageBuilder: (_, __) => _slideUp(const SettingsScreen()),
      ),
    ],
  );
});

Page<dynamic> _slideUp(Widget child) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
