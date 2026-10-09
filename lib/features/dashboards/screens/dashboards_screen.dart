import 'package:flutter/material.dart';
import '../../../core/theme/dashboard_accent.dart';
import '../wall_display.dart';
import '../../../core/theme/signal_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/window_class.dart';
import '../../settings/screens/settings_screen.dart' show homeStatusLabel;
import '../../../core/review/review_prompt_trigger.dart';
import '../../../core/router/last_dashboard_store.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/material_icon.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/backup_files.dart';
import '../../../data/repositories/backup_service.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../mqtt/mqtt_status.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../../devices/device_registry.dart';
import '../../devices/devices_providers.dart';
import '../../home/home_shell.dart';
import '../edit_mode.dart';
import '../../onboarding/demo_banner.dart';
import '../../onboarding/demo_service.dart' show isDemoConnection;
import '../../panels/widgets/panel_grid.dart';
import '../widgets/analytics_consent_card.dart';
import '../widgets/connection_status_banner.dart';

/// Per-connection dashboards screen. Shows a TabBar of all dashboards
/// under [connectionId] and renders the selected dashboard's [PanelGrid].
class DashboardsScreen extends ConsumerWidget {
  const DashboardsScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionByIdProvider(connectionId));
    final dashboardsAsync =
        ref.watch(dashboardsForConnectionProvider(connectionId));
    final connectionStatus =
        ref.watch(connectionStatusProvider(connectionId)).valueOrNull ??
            MqttStatus.connecting;

    // Link tiles to devices and follow renames while this home is open.
    final base = ref.watch(homeBaseTopicProvider(connectionId));
    if (base != null) {
      ref.watch(homeDeviceSyncProvider(
          (connectionId: connectionId, base: base)));
    }

    final connectionName = connectionAsync.maybeWhen(
      data: (c) => c?.name ?? 'Connection',
      orElse: () => '…',
    );

    return dashboardsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: HomeTitle(connectionId: connectionId)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: HomeTitle(connectionId: connectionId)),
        body: Center(child: Text(context.l10n.dashLoadFailed(e.toString()))),
      ),
      data: (dashboards) {
        if (dashboards.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: HomeTitle(connectionId: connectionId),
              actions: [
                const SettingsAction(),
                _DashboardMenu(connectionId: connectionId),
              ],
            ),
            body: Column(
              children: [
                ConnectionStatusBanner(
                  status: connectionStatus,
                  onReconnect: () => _reconnectNow(context, ref, connectionId),
                  onSettings: () => context.push('/connections/$connectionId/edit'),
                ),
                AnalyticsConsentCard(connectionId: connectionId),
                const Expanded(child: _EmptyState()),
              ],
            ),
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
          connectionStatus: connectionStatus,
        );
      },
    );
  }
}

class _DashboardsTabbed extends ConsumerWidget {
  const _DashboardsTabbed({
    required this.connectionId,
    required this.connectionName,
    required this.dashboards,
    required this.connectionStatus,
  });

  final String connectionId;
  final String connectionName;
  final List<Dashboard> dashboards;
  final MqttStatus connectionStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reopen the dashboard last used in this home.
    final store = ref.read(lastDashboardStoreProvider);
    final last = store.lastDashboardOf(connectionId);
    final initial = dashboards.indexWhere((d) => d.id == last);
    return DefaultTabController(
      length: dashboards.length,
      initialIndex: initial < 0 ? 0 : initial,
      child: Builder(builder: (tabCtx) {
        final l10n = context.l10n;
        final editingId = ref.watch(editModeProvider);
        final editing = dashboards.where((d) => d.id == editingId).firstOrNull;
        final edit = ref.read(editModeProvider.notifier);
        Dashboard current() =>
            dashboards[DefaultTabController.of(tabCtx).index];
        final wide = WindowClass.of(context).hasRail;
        // The demo has no broker and stays quiet about it (demo_home.dart).
        final demo = isDemoConnection(
            ref.watch(connectionByIdProvider(connectionId)).valueOrNull?.host);
        final chromeHidden = ref.watch(wallChromeHiddenProvider);
        return AnimatedBuilder(
          animation: DefaultTabController.of(tabCtx),
          builder: (_, child) => WallDisplayScope(
            dashboardId: current().id,
            active: editing == null,
            child: child!,
          ),
          child: PopScope(
          // System back leaves Edit mode first.
          canPop: editing == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) edit.exit();
          },
          child: Scaffold(
          appBar: chromeHidden && editing == null
              ? null
              : editing != null
              ? AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(l10n.editEditing),
                  actions: [
                    // With a rail there is no bottom bar: add from here.
                    if (wide) ...[
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(l10n.dashAddTile),
                        onPressed: () => tabCtx.push(
                            '/connections/$connectionId/dashboards/'
                            '${editing.id}/add'),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.segment),
                        label: Text(l10n.editAddSection),
                        onPressed: () => addSection(tabCtx, ref, editing.id),
                      ),
                    ],
                    TextButton.icon(
                      icon: const Icon(Icons.tune),
                      label: Text(l10n.editDashboard),
                      onPressed: () => tabCtx.push(
                          '/connections/$connectionId/dashboards/'
                          '${editing.id}/edit'),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: FilledButton(
                        onPressed: edit.exit,
                        child: Text(l10n.editDone),
                      ),
                    ),
                  ],
                )
              : AppBar(
            title: HomeTitle(connectionId: connectionId),
            actions: [
              if (wide && !demo) _StatusChip(status: connectionStatus),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.dashEditDashboard,
                onPressed: () {
                  final d = current();
                  if (!d.locked) edit.enter(d.id);
                },
              ),
              const SettingsAction(),
              _DashboardMenu(connectionId: connectionId, current: current),
            ],
            bottom: dashboards.length < 2 || editing != null
                ? null
                : wide
                    ? _DashboardChips(
                        dashboards: dashboards,
                        onPick: (i) => store
                            .rememberDashboard(connectionId, dashboards[i].id)
                            .ignore(),
                      )
                    : TabBar(
              isScrollable: dashboards.length > 3,
              onTap: (i) => store
                  .rememberDashboard(connectionId, dashboards[i].id)
                  .ignore(),
              tabs: dashboards.map((d) {
                return Tab(
                  icon: Icon(
                    materialIcon(d.iconCodepoint),
                  ),
                  text: d.name,
                );
              }).toList(),
            ),
          ),
          body: Column(
            children: [
              ReviewPromptTrigger(connectionId: connectionId),
              RememberHome(connectionId: connectionId),
              DemoBanner(connectionId: connectionId),
              AnalyticsConsentCard(connectionId: connectionId),
              ConnectionStatusBanner(
                status: connectionStatus,
                onReconnect: () => _reconnectNow(tabCtx, ref, connectionId),
                onSettings: () => tabCtx.push('/connections/$connectionId/edit'),
              ),
              Expanded(
                child: TabBarView(
                  // Edit mode works on one dashboard: no swiping away.
                  physics: editing != null
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  children: dashboards.map((d) {
                    // The dashboard's colour is an accent only (Signal).
                    final base = Theme.of(tabCtx);
                    final dashboardTheme = base.copyWith(extensions: [
                      ...base.extensions.values,
                      DashboardAccent.fromSeed(d.colorSeed, base.brightness),
                    ]);
                    return Theme(
                      data: dashboardTheme,
                      child: PanelGrid(
                        connectionId: connectionId,
                        dashboard: d,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          // In Edit mode the bottom bar offers Add tile and Add section.
          floatingActionButton: editing != null || chromeHidden
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => tabCtx.push(
                      '/connections/$connectionId/dashboards/'
                      '${current().id}/add'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.dashAddTile),
                ),
          ),
        ),
        );
      }),
    );
  }
}

/// Dashboard switching with a rail: a chip per dashboard under the header.
class _DashboardChips extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardChips({required this.dashboards, required this.onPick});

  final List<Dashboard> dashboards;
  final ValueChanged<int> onPick;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          children: [
            for (final (i, d) in dashboards.indexed)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  avatar: controller.index == i
                      ? null
                      : Icon(materialIcon(d.iconCodepoint), size: 18),
                  label: Text(d.name),
                  selected: controller.index == i,
                  onSelected: (_) {
                    controller.animateTo(i);
                    onPick(i);
                  },
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

/// The connection state at the end of a wide header.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final MqttStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ok = status == MqttStatus.connected;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok
                  ? SignalColors.of(context).onHealthy
                  : theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: 6),
          Text(homeStatusLabel(status, context.l10n),
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

Future<void> _reconnectNow(
  BuildContext context,
  WidgetRef ref,
  String connectionId,
) async {
  final failureMessage = context.l10n.connectionFailed;
  try {
    final manager = await ref.read(mqttManagerProvider(connectionId).future);
    manager.reconnectNow();
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failureMessage)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.dashEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Custom MQTT tile type list, opened from Add tile. The chosen type's
/// form replaces Add tile, so saving returns to the dashboard.
Future<void> openCustomTilePicker(BuildContext context,
    {required String connectionId, required String dashboardId}) async {
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
              child: Text(sheetCtx.l10n.panelPickerTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(sheetCtx.l10n.panelPickerSectionControl,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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
              leading: const Icon(Icons.timer_outlined),
              title: Text(sheetCtx.l10n.panelPickerAutoCloseTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerAutoCloseSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'autoClose'),
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
              child: Text(sheetCtx.l10n.panelPickerSectionState,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: Icon(Icons.circle, color: SignalColors.of(sheetCtx).onHealthy),
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
    context.pushReplacement(
      '/connections/$connectionId/dashboards/$dashboardId/panels/new?type=$t$preset',
    );
  }
}

/// App-bar overflow menu offering JSON export/import of this connection's
/// dashboards (backup / copy-to-another-device).
class _DashboardMenu extends ConsumerWidget {
  const _DashboardMenu({required this.connectionId, this.current});

  final String connectionId;

  /// The dashboard on screen, for its Wall display switch.
  final Dashboard Function()? current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // With one home the header has no switcher: "Add a home" lives here.
    final homes = ref.watch(connectionsStreamProvider).valueOrNull?.length ?? 0;
    return PopupMenuButton<String>(
      onSelected: (v) {
        switch (v) {
          case 'addDashboard':
            context.push('/connections/$connectionId/dashboards/form');
          case 'addHome':
            context.push(Routes.setup);
          case 'export':
            _export(context, ref);
          case 'import':
            _import(context, ref);
          case 'wall':
            final d = current?.call();
            if (d == null) break;
            ref.read(wallDisplayProvider(d.id).notifier).toggle();
            // Nothing changes on screen for 10 s, so say what will happen.
            final on = ref.read(wallDisplayProvider(d.id));
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(
                    on ? l10n.dashWallDisplayOn : l10n.dashWallDisplayOff),
              ));
        }
      },
      itemBuilder: (_) => [
        if (current != null)
          CheckedPopupMenuItem(
            value: 'wall',
            checked: ref.read(wallDisplayProvider(current!().id)),
            child: Text(l10n.dashWallDisplay),
          ),
        PopupMenuItem(value: 'addDashboard', child: Text(l10n.dashAddDashboard)),
        if (homes < 2)
          PopupMenuItem(value: 'addHome', child: Text(l10n.homeAdd)),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'export', child: Text(l10n.dashExportMenu)),
        PopupMenuItem(value: 'import', child: Text(l10n.dashImportMenu)),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final json =
        await ref.read(backupServiceProvider).exportConnection(connectionId);
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
          TextButton.icon(
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
          // A .json file through Android's file picker: Drive, Downloads, a
          // USB stick (asked for in a Play review).
          FilledButton.icon(
            icon: const Icon(Icons.save_alt),
            label: Text(l10n.dashExportSaveFile),
            onPressed: () async {
              final home =
                  ref.read(connectionByIdProvider(connectionId)).valueOrNull;
              final saved = await ref.read(backupFilesProvider).save(
                  backupFileName(home?.name ?? '', DateTime.now()), json);
              if (!saved) return;
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.dashExportSaved)),
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
          // Fills the box from a saved .json backup; Import still confirms.
          TextButton.icon(
            icon: const Icon(Icons.file_open_outlined),
            label: Text(l10n.dashImportChooseFile),
            onPressed: () async {
              try {
                final text = await ref.read(backupFilesProvider).open();
                if (text != null) controller.text = text;
              } on FormatException {
                messenger.showSnackBar(
                    SnackBar(content: Text(l10n.dashImportFileUnreadable)));
              }
            },
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
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.dashImportFailed(e.toString()))));
    } finally {
      controller.dispose();
    }
  }
}

