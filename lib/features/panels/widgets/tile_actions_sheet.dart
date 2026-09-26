import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/database/tables/panels.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/repositories/section_repo.dart';
import '../../devices/device_tiles.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../services/auto_close_config_publisher.dart';
import '../services/automation_config_publisher.dart';

/// The Edit-mode actions of one tile (docs/design/dashboard-1.12.md §7):
/// size, move to section, edit, duplicate, replace with a device tile
/// (custom tiles linked to a device), and remove with Undo.
Future<void> showTileActions(
  BuildContext context,
  WidgetRef ref, {
  required String connectionId,
  required Panel panel,
}) {
  final l10n = context.l10n;
  final repo = ref.read(panelRepoProvider);
  final messenger = ScaffoldMessenger.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(panel.name,
                style: Theme.of(sheetCtx).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SegmentedButton<PanelWidth>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: PanelWidth.small, label: Text(l10n.tileSizeSmall)),
                ButtonSegment(
                    value: PanelWidth.wide, label: Text(l10n.tileSizeWide)),
                ButtonSegment(
                    value: PanelWidth.full, label: Text(l10n.tileSizeFull)),
              ],
              selected: {panel.width},
              onSelectionChanged: (sel) async {
                Navigator.pop(sheetCtx);
                await repo.setWidth(panel.id, sel.first);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_move_outline),
            title: Text(l10n.editMoveToSection),
            onTap: () async {
              Navigator.pop(sheetCtx);
              await _moveToSection(context, ref, panel);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.editEditTile),
            onTap: () {
              Navigator.pop(sheetCtx);
              context.push('/connections/$connectionId/dashboards/'
                  '${panel.dashboardId}/panels/${panel.id}/edit');
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: Text(l10n.panelTileDuplicate),
            onTap: () async {
              Navigator.pop(sheetCtx);
              await repo.duplicate(panel.id);
            },
          ),
          if (panel.type != PanelType.device && panel.deviceIeee != null)
            ListTile(
              leading: const Icon(Icons.auto_fix_high),
              title: Text(l10n.editReplaceWithDevice),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _replaceWithDeviceTile(
                    context, ref, messenger, connectionId, panel);
              },
            ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_outline,
                color: Theme.of(sheetCtx).colorScheme.error),
            title: Text(l10n.editRemove,
                style: TextStyle(color: Theme.of(sheetCtx).colorScheme.error)),
            onTap: () {
              Navigator.pop(sheetCtx);
              removeTileWithUndo(ref, messenger, l10n.editRemoved,
                  l10n.editUndo, connectionId, panel);
            },
          ),
        ],
      ),
    ),
  );
}

/// Removes [panel] at once and offers Undo. A schedule's or auto-close
/// rule's retained config on the hub is cleared only once the snackbar
/// closes without Undo, so Undo brings the rule back intact.
Future<void> removeTileWithUndo(
  WidgetRef ref,
  ScaffoldMessengerState messenger,
  String removedLabel,
  String undoLabel,
  String connectionId,
  Panel panel,
) async {
  final repo = ref.read(panelRepoProvider);
  final automation = ref.read(automationConfigPublisherProvider);
  final autoClose = ref.read(autoCloseConfigPublisherProvider);
  await repo.delete(panel.id);
  var undone = false;
  final closed = messenger
      .showSnackBar(SnackBar(
        content: Text(removedLabel),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: undoLabel,
          onPressed: () {
            undone = true;
            repo.restore(panel);
          },
        ),
      ))
      .closed;
  await closed;
  if (undone) return;
  if (panel.type == PanelType.schedule) {
    await automation.clearConfig(connectionId: connectionId, panelId: panel.id);
  } else if (panel.type == PanelType.autoClose) {
    await autoClose.clearConfig(connectionId: connectionId, panelId: panel.id);
  }
}

Future<void> _moveToSection(
    BuildContext context, WidgetRef ref, Panel panel) async {
  final l10n = context.l10n;
  final sections =
      await ref.read(sectionRepoProvider).getByDashboard(panel.dashboardId);
  if (!context.mounted) return;
  const none = '';
  final chosen = await showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(l10n.editMoveToSection),
      children: [
        for (final (id, name) in [
          (none, l10n.addTileNoSection),
          for (final s in sections) (s.id, s.name),
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, id),
            child: Row(
              children: [
                Expanded(child: Text(name)),
                if ((panel.sectionId ?? none) == id) const Icon(Icons.check),
              ],
            ),
          ),
      ],
    ),
  );
  if (chosen == null || chosen == (panel.sectionId ?? none)) return;
  await ref.read(panelRepoProvider).moveTile(
        panel.dashboardId,
        panel.id,
        sectionId: chosen == none ? null : chosen,
      );
}

/// Swaps a custom tile linked to a device for that device's tile, keeping
/// name, size, section and position; Undo swaps back.
Future<void> _replaceWithDeviceTile(
  BuildContext context,
  WidgetRef ref,
  ScaffoldMessengerState messenger,
  String connectionId,
  Panel panel,
) async {
  final l10n = context.l10n;
  final dashboard =
      await ref.read(dashboardRepoProvider).getById(panel.dashboardId);
  final base = z2mBase(dashboard?.topicPrefix);
  final devices = await ref
      .read(bridgeDevicesStreamProvider(
              (connectionId: connectionId, base: base))
          .future)
      .timeout(const Duration(seconds: 8), onTimeout: () => const []);
  final device =
      devices.where((d) => d.ieeeAddress == panel.deviceIeee).firstOrNull;
  if (device == null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.addTileNoDevices)));
    return;
  }
  final repo = ref.read(panelRepoProvider);
  final newId = await createDeviceTile(
    repo,
    dashboardId: panel.dashboardId,
    base: base,
    device: device,
    name: panel.name,
    size: panel.width,
    sectionId: panel.sectionId,
    sortOrder: panel.sortOrder,
  );
  await repo.delete(panel.id);
  messenger.showSnackBar(SnackBar(
    content: Text(l10n.editReplaceWithDevice),
    action: SnackBarAction(
      label: l10n.editUndo,
      onPressed: () async {
        await repo.delete(newId);
        await repo.restore(panel);
      },
    ),
  ));
}
