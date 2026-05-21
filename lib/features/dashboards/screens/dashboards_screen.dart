import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/backup_service.dart';
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
            appBar: AppBar(
              title: Text(connectionName),
              actions: [_BackupMenu(connectionId: connectionId)],
            ),
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
              _BackupMenu(connectionId: connectionId),
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
    isScrollControlled: true,
    builder: (sheetCtx) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Add a panel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text('Control', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.toggle_on),
              title: const Text('Toggle'),
              subtitle: const Text('On/off switch for a device state'),
              onTap: () => Navigator.pop(sheetCtx, 'toggle'),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Slider — Brightness'),
              subtitle: const Text('Light dimming (0–254, {"brightness":N})'),
              onTap: () => Navigator.pop(sheetCtx, 'slider'),
            ),
            ListTile(
              leading: const Icon(Icons.blinds),
              title: const Text('Slider — Position'),
              subtitle: const Text('Cover / shutter (0–100, {"position":N})'),
              onTap: () => Navigator.pop(sheetCtx, 'slider:position'),
            ),
            ListTile(
              leading: const Icon(Icons.blinds_closed),
              title: const Text('Cover'),
              subtitle: const Text('Shutter/blind: OPEN·STOP·CLOSE + position slider'),
              onTap: () => Navigator.pop(sheetCtx, 'cover'),
            ),
            ListTile(
              leading: const Icon(Icons.view_week),
              title: const Text('Multi-State'),
              subtitle: const Text('Segmented buttons for an enum (e.g. OPEN/STOP/CLOSE)'),
              onTap: () => Navigator.pop(sheetCtx, 'multiState'),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_drop_down_circle_outlined),
              title: const Text('Combo'),
              subtitle: const Text('Dropdown selector for an enum'),
              onTap: () => Navigator.pop(sheetCtx, 'combo'),
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_checked),
              title: const Text('Radio'),
              subtitle: const Text('Radio-button list for an enum'),
              onTap: () => Navigator.pop(sheetCtx, 'radio'),
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Button'),
              subtitle: const Text('Fire a one-shot command'),
              onTap: () => Navigator.pop(sheetCtx, 'button'),
            ),
            ListTile(
              leading: const Icon(Icons.keyboard),
              title: const Text('Text Input'),
              subtitle: const Text('Publish a free-form value or JSON'),
              onTap: () => Navigator.pop(sheetCtx, 'textInput'),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('State', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.green),
              title: const Text('LED'),
              subtitle: const Text('Colored indicator for a boolean state (contact, leak)'),
              onTap: () => Navigator.pop(sheetCtx, 'led'),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_done),
              title: const Text('Node Status'),
              subtitle: const Text('Z2M device availability (online/offline)'),
              onTap: () => Navigator.pop(sheetCtx, 'nodeStatus'),
            ),
            ListTile(
              leading: const Icon(Icons.battery_5_bar),
              title: const Text('Progress'),
              subtitle: const Text('Numeric bar for battery, link quality, etc.'),
              onTap: () => Navigator.pop(sheetCtx, 'progress'),
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Text Log'),
              subtitle: const Text('Scrolling history of messages on a topic'),
              onTap: () => Navigator.pop(sheetCtx, 'textLog'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
  if (type != null && context.mounted) {
    // Tokens like "slider:position" carry an additional preset hint; split here.
    final parts = type.split(':');
    final t = parts.first;
    final preset = parts.length > 1 ? '&preset=${parts[1]}' : '';
    context.push(
      '/connections/$connectionId/dashboards/$dashboardId/panels/new?type=$t$preset',
    );
  }
}

/// App-bar overflow menu offering JSON export/import of this connection's
/// dashboards (backup / copy-to-another-device).
class _BackupMenu extends ConsumerWidget {
  const _BackupMenu({required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'export') _export(context, ref);
        if (v == 'import') _import(context, ref);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'export', child: Text('Export dashboards')),
        PopupMenuItem(value: 'import', child: Text('Import dashboards')),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final json = await ref.read(backupServiceProvider).exportConnection(connectionId);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export dashboards'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import dashboards'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Paste exported JSON here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      controller.dispose();
      return;
    }
    try {
      final n = await ref
          .read(backupServiceProvider)
          .importToConnection(connectionId, controller.text);
      messenger.showSnackBar(
        SnackBar(content: Text('Imported $n dashboard${n == 1 ? '' : 's'}')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      controller.dispose();
    }
  }
}
