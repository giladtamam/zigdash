import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../scenes/models/scene.dart';
import '../../scenes/scenes_providers.dart';
import '../models/panel_config.dart';

/// A dashboard tile that activates a saved scene on tap. Looks the scene up by
/// id from the connection's scenes; shows a "missing" state if it was deleted.
class ScenePanel extends ConsumerWidget {
  const ScenePanel({
    super.key,
    required this.connectionId,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final Panel panel;
  final SceneConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scenesAsync = ref.watch(scenesForConnectionProvider(connectionId));
    final scene = scenesAsync.value
        ?.where((s) => s.id == config.sceneId)
        .cast<Scene?>()
        .firstOrNull;

    final missing = scene == null;
    final color = scene != null ? Color(scene.colorSeed) : null;
    final icon = scene != null
        ? IconData(scene.iconCodepoint, fontFamily: 'MaterialIcons')
        : Icons.help_outline;

    Future<void> activate() async {
      final messenger = ScaffoldMessenger.of(context);
      final actions = SceneAction.decodeList(scene!.actions);
      final sent = await activateScene(ref, connectionId, actions);
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(sent > 0
            ? l10n.scenesActivated(scene.name)
            : l10n.scenesActivateOffline),
      ));
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: missing ? null : activate,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                missing ? l10n.panelSceneMissing : panel.name,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
