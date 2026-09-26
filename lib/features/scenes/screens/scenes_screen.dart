import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/material_icon.dart';
import '../../../data/database/database.dart';
import '../../../data/database/tables/panels.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../panels/models/panel_config.dart';
import '../models/scene.dart';
import '../scenes_providers.dart';

/// Lists a connection's scenes. Tap a scene to activate it (publishes every
/// saved device action); the FAB creates a new one by capturing device state.
class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key, required this.connectionId});

  final String connectionId;

  Future<void> _activate(
    BuildContext context,
    WidgetRef ref,
    Scene scene,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final actions = SceneAction.decodeList(scene.actions);
    final sent = await activateScene(ref, connectionId, actions);
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(
        sent > 0 ? l10n.scenesActivated(scene.name) : l10n.scenesActivateOffline,
      ),
    ));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Scene scene,
  ) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sceneDeleteTitle),
        content: Text(l10n.sceneDeleteMessage(scene.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.sceneDeleteAction),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(sceneRepoProvider).delete(scene.id);
    }
  }

  /// Adds a scene-activation tile to a dashboard the user picks.
  Future<void> _addToDashboard(
    BuildContext context,
    WidgetRef ref,
    Scene scene,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final dashboards =
        await ref.read(dashboardRepoProvider).getByConnection(connectionId);
    if (!context.mounted) return;
    if (dashboards.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.scenesNone)));
      return;
    }
    final chosen = await showModalBottomSheet<Dashboard>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final d in dashboards)
              ListTile(
                leading: Icon(
                  materialIcon(d.iconCodepoint),
                ),
                title: Text(d.name),
                onTap: () => Navigator.pop(sheetCtx, d),
              ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    await ref.read(panelRepoProvider).create(
          dashboardId: chosen.id,
          name: scene.name,
          type: PanelType.scene,
          topic: '',
          width: PanelWidth.small,
          config: SceneConfig(sceneId: scene.id),
        );
    messenger.showSnackBar(
        SnackBar(content: Text(l10n.sceneAddedToDashboard(chosen.name))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scenesAsync = ref.watch(scenesForConnectionProvider(connectionId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scenesTitle)),
      body: scenesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (scenes) {
          if (scenes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l10n.scenesNone, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.builder(
            itemCount: scenes.length,
            itemBuilder: (context, i) {
              final scene = scenes[i];
              final count = SceneAction.decodeList(scene.actions).length;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(scene.colorSeed),
                  foregroundColor: Colors.white,
                  child: Icon(
                    materialIcon(scene.iconCodepoint),
                  ),
                ),
                title: Text(scene.name),
                subtitle: Text(l10n.sceneActionsCount(count)),
                onTap: () => _activate(context, ref, scene),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') {
                      context.push(
                        '/connections/$connectionId/scenes/${scene.id}/edit',
                      );
                    } else if (v == 'delete') {
                      _confirmDelete(context, ref, scene);
                    } else if (v == 'dashboard') {
                      _addToDashboard(context, ref, scene);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.sceneEditAction)),
                    PopupMenuItem(
                        value: 'dashboard',
                        child: Text(l10n.sceneAddToDashboard)),
                    PopupMenuItem(
                        value: 'delete', child: Text(l10n.sceneDeleteAction)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/connections/$connectionId/scenes/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.scenesNewButton),
      ),
    );
  }
}
