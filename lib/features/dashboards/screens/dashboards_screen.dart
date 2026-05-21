import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
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
        body: Center(child: Text(context.l10n.dashLoadFailed(e.toString()))),
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
              label: Text(context.l10n.dashAddDashboard),
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
                  tooltip: context.l10n.dashEditDashboard,
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
                tooltip: context.l10n.dashAddDashboard,
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
              label: Text(innerCtx.l10n.dashAddPanel),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          context.l10n.dashEmpty,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(sheetCtx.l10n.panelPickerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(sheetCtx.l10n.panelPickerSectionControl, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.toggle_on),
              title: Text(sheetCtx.l10n.panelPickerToggleTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerToggleSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'toggle'),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: Text(sheetCtx.l10n.panelPickerSliderBrightnessTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerSliderBrightnessSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'slider'),
            ),
            ListTile(
              leading: const Icon(Icons.blinds),
              title: Text(sheetCtx.l10n.panelPickerSliderPositionTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerSliderPositionSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'slider:position'),
            ),
            ListTile(
              leading: const Icon(Icons.blinds_closed),
              title: Text(sheetCtx.l10n.panelPickerCoverTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerCoverSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'cover'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(sheetCtx.l10n.panelPickerScheduleTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerScheduleSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'schedule'),
            ),
            ListTile(
              leading: const Icon(Icons.view_week),
              title: Text(sheetCtx.l10n.panelPickerMultiStateTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerMultiStateSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'multiState'),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_drop_down_circle_outlined),
              title: Text(sheetCtx.l10n.panelPickerComboTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerComboSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'combo'),
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_checked),
              title: Text(sheetCtx.l10n.panelPickerRadioTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerRadioSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'radio'),
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: Text(sheetCtx.l10n.panelPickerButtonTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerButtonSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'button'),
            ),
            ListTile(
              leading: const Icon(Icons.keyboard),
              title: Text(sheetCtx.l10n.panelPickerTextInputTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerTextInputSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'textInput'),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(sheetCtx.l10n.panelPickerSectionState, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.green),
              title: Text(sheetCtx.l10n.panelPickerLedTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerLedSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'led'),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_done),
              title: Text(sheetCtx.l10n.panelPickerNodeStatusTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerNodeStatusSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'nodeStatus'),
            ),
            ListTile(
              leading: const Icon(Icons.battery_5_bar),
              title: Text(sheetCtx.l10n.panelPickerProgressTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerProgressSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'progress'),
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text(sheetCtx.l10n.panelPickerTextLogTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerTextLogSubtitle),
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
      itemBuilder: (_) => [
        PopupMenuItem(value: 'export', child: Text(context.l10n.dashExportMenu)),
        PopupMenuItem(value: 'import', child: Text(context.l10n.dashImportMenu)),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final json = await ref.read(backupServiceProvider).exportConnection(connectionId);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dashExportTitle),
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
            child: Text(l10n.dashExportClose),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(l10n.dashExportCopy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.dashExportCopied)),
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
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dashImportTitle),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: l10n.dashImportHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.dashImportButton),
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
        SnackBar(content: Text(l10n.dashImportSuccess(n))),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.dashImportFailed(e.toString()))));
    } finally {
      controller.dispose();
    }
  }
}
