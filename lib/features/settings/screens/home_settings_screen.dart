import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../panels/widgets/device_tile_panel.dart' show ltr;
import '../../../core/router/last_dashboard_store.dart';
import '../../../core/router/routes.dart';
import '../../../data/database/database.dart';
import '../../../data/last_known/last_known_store.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../devices/devices_providers.dart';

/// One home's page in Settings (devices-tablet-1.13.md §6): its name, its
/// connection, its Zigbee2MQTT base topic, switching to it, and deleting it.
class HomeSettingsScreen extends ConsumerWidget {
  const HomeSettingsScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final homes = ref.watch(connectionsStreamProvider).valueOrNull;
    final home = homes?.where((c) => c.id == connectionId).firstOrNull;
    if (home == null) {
      return Scaffold(
        appBar: AppBar(),
        body: homes == null
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox.shrink(),
      );
    }
    final current =
        ref.watch(lastDashboardStoreProvider).lastConnectionId == home.id;
    final base = ref.watch(homeBaseTopicProvider(home.id)) ?? 'zigbee2mqtt';
    final error = Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(title: Text(home.name)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.connName),
                subtitle: Text(home.name),
                onTap: () => _rename(context, ref, home),
              ),
              ListTile(
                leading: const Icon(Icons.lan_outlined),
                title: Text(l10n.homeConnection),
                subtitle: Text(ltr('${home.host}:${home.port}')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/connections/${home.id}/edit'),
              ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: Text(l10n.discoverBaseTopic),
                subtitle: Text(base),
                onTap: () => _editBase(context, ref, home, base),
              ),
              if (!current)
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(l10n.homeSwitchTo),
                  onTap: () => context.go(Routes.homeDashboards(home.id)),
                ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete_outline, color: error),
                title: Text(l10n.homeDelete, style: TextStyle(color: error)),
                onTap: () => _delete(context, ref, home, current),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _ask(
    BuildContext context, {
    required String title,
    required String initial,
  }) async {
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<void> _rename(
      BuildContext context, WidgetRef ref, Connection home) async {
    final v = (await _ask(context,
            title: context.l10n.connName, initial: home.name))
        ?.trim();
    if (v == null || v.isEmpty || v.length > 64) return;
    await ref.read(connectionRepoProvider).rename(home.id, v);
  }

  Future<void> _editBase(BuildContext context, WidgetRef ref, Connection home,
      String base) async {
    final v = await _ask(context,
        title: context.l10n.discoverBaseTopic, initial: base);
    if (v == null) return;
    await ref.read(connectionRepoProvider).setBaseTopic(home.id, v);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Connection home,
      bool current) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.connDeleteTitle),
        content: Text(l10n.connDeleteContent(home.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final repo = ref.read(connectionRepoProvider);
    final store = ref.read(lastDashboardStoreProvider);
    final remaining = [
      for (final c in ref.read(connectionsStreamProvider).valueOrNull ??
          const <Connection>[])
        if (c.id != home.id) c.id,
    ];
    await repo.delete(home.id);
    await store.forget(home.id);
    // Its last-known values go with it.
    await ref.read(lastKnownStoreProvider).keepOnly(remaining.toSet());
    if (!context.mounted) return;
    // The current home's screens are gone: open the next home, or setup.
    if (current) {
      context.go(Routes.start);
    } else {
      context.pop();
    }
  }
}
