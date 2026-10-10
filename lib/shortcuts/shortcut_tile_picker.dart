import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n_ext.dart';
import '../data/database/daos/device_registry_dao.dart';
import '../data/database/database.dart';
import '../data/database/tables/panels.dart';
import '../data/repositories/connection_repo.dart';
import '../features/panels/models/panel_config.dart';
import 'shortcut_service.dart';

/// A device that a shortcut can switch: a device tile whose class has an
/// on/off or open/close action.
typedef ShortcutCandidate = ({String connectionId, String home, String ieee, String name});

final shortcutCandidatesProvider =
    FutureProvider.autoDispose<List<ShortcutCandidate>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final homes = await ref.watch(connectionRepoProvider).watchAll().first;
  final out = <ShortcutCandidate>[];
  for (final home in homes) {
    final seen = <String>{};
    for (final (panel, _) in await DeviceRegistryDao(db).tilesOfHome(home.id)) {
      final ieee = panel.deviceIeee;
      if (ieee == null || panel.type != PanelType.device || !seen.add(ieee)) {
        continue;
      }
      final c = PanelConfig.decode(panel.type, panel.config);
      if (c is DeviceTileConfig &&
          (c.profile.switches.isNotEmpty ||
              c.profile.deviceClass.name == 'cover')) {
        out.add((connectionId: home.id, home: home.name, ieee: ieee, name: panel.name));
      }
    }
  }
  return out;
});

/// "Choose a device for ZigDash 2": opened by an unassigned tile.
class ShortcutTilePicker extends ConsumerWidget {
  const ShortcutTilePicker({super.key, required this.slot});

  final int slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final candidates = ref.watch(shortcutCandidatesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shortcutPickTitle(slot))),
      body: candidates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.shortcutPickEmpty)),
        data: (list) => list.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.shortcutPickEmpty),
              )
            : ListView(
                children: [
                  for (final c in list)
                    ListTile(
                      title: Text(c.name),
                      subtitle: Text(c.home),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref.read(shortcutServiceProvider).assignTile(slot,
                            connectionId: c.connectionId, ieee: c.ieee, name: c.name);
                        await refreshShortcutTiles();
                        messenger.showSnackBar(SnackBar(
                            content: Text(l10n.shortcutTileReady(c.name, slot))));
                        if (context.mounted) {
                          context.canPop() ? context.pop() : context.go('/start');
                        }
                      },
                    ),
                ],
              ),
      ),
    );
  }
}
