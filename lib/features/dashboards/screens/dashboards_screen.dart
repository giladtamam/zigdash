import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../panels/widgets/panel_grid.dart';

/// Per-connection dashboards screen. Shows a TabBar of all dashboards
/// under [connectionId] and renders the selected dashboard's [PanelGrid].
class DashboardsScreen extends ConsumerWidget {
  const DashboardsScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionByIdProvider(connectionId));
    final dashboardsAsync = ref.watch(dashboardsForConnectionProvider(connectionId));

    final connectionName = connectionAsync.maybeWhen(
      data: (c) => c?.name ?? 'Connection',
      orElse: () => '…',
    );

    return dashboardsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(connectionName)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(connectionName)),
        body: Center(child: Text('Failed: $e')),
      ),
      data: (dashboards) {
        if (dashboards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(connectionName)),
            body: const _EmptyState(),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () =>
                  context.push('/connections/$connectionId/dashboards/form'),
              icon: const Icon(Icons.add),
              label: const Text('Add dashboard'),
            ),
          );
        }
        return _DashboardsTabbed(
          connectionId: connectionId,
          connectionName: connectionName,
          dashboards: dashboards,
        );
      },
    );
  }
}

class _DashboardsTabbed extends StatelessWidget {
  const _DashboardsTabbed({
    required this.connectionId,
    required this.connectionName,
    required this.dashboards,
  });

  final String connectionId;
  final String connectionName;
  final List<Dashboard> dashboards;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dashboards.length,
      child: Builder(builder: (tabCtx) {
        return Scaffold(
          appBar: AppBar(
            title: Text(connectionName),
            actions: [
              Builder(builder: (innerCtx) {
                final idx = DefaultTabController.of(innerCtx).index;
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit dashboard',
                  onPressed: () {
                    final d = dashboards[idx];
                    innerCtx.push(
                      '/connections/$connectionId/dashboards/${d.id}/edit',
                    );
                  },
                );
              }),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add dashboard',
                onPressed: () =>
                    tabCtx.push('/connections/$connectionId/dashboards/form'),
              ),
            ],
            bottom: TabBar(
              isScrollable: dashboards.length > 3,
              tabs: dashboards.map((d) {
                return Tab(
                  icon: Icon(
                    IconData(d.iconCodepoint, fontFamily: 'MaterialIcons'),
                  ),
                  text: d.name,
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: dashboards.map((d) {
              final dashboardTheme = Theme.of(tabCtx).copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Color(d.colorSeed),
                  brightness: Theme.of(tabCtx).brightness,
                ),
              );
              return Theme(
                data: dashboardTheme,
                child: PanelGrid(
                  connectionId: connectionId,
                  dashboard: d,
                ),
              );
            }).toList(),
          ),
          floatingActionButton: Builder(builder: (innerCtx) {
            final idx = DefaultTabController.of(innerCtx).index;
            return FloatingActionButton.extended(
              onPressed: () {
                final d = dashboards[idx];
                _openPanelPicker(innerCtx, connectionId: connectionId, dashboardId: d.id);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add panel'),
            );
          }),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No dashboards yet.\nTap "Add dashboard" to create one for this broker.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

void _openPanelPicker(BuildContext context,
    {required String connectionId, required String dashboardId}) async {
  // Lazy import to avoid a circular reference in feature folders.
  // The picker is a thin bottom sheet that pushes to the form route.
  // Implementation in lib/features/panels/screens/panel_picker_sheet.dart.
  final type = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Add a panel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          ListTile(
            leading: const Icon(Icons.toggle_on),
            title: const Text('Toggle'),
            subtitle: const Text('On/off switch for a device state'),
            onTap: () => Navigator.pop(sheetCtx, 'toggle'),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Slider'),
            subtitle: const Text('Continuous value (brightness, position)'),
            onTap: () => Navigator.pop(sheetCtx, 'slider'),
          ),
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text('Button'),
            subtitle: const Text('Fire a one-shot command'),
            onTap: () => Navigator.pop(sheetCtx, 'button'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (type != null && context.mounted) {
    context.push(
      '/connections/$connectionId/dashboards/$dashboardId/panels/new?type=$type',
    );
  }
}
