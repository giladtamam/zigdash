import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
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
                    IconData(scene.iconCodepoint, fontFamily: 'MaterialIcons'),
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
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.sceneEditAction)),
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
