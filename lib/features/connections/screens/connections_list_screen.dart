import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/last_dashboard_store.dart';
import '../../../core/router/routes.dart';
import '../../../data/repositories/connection_repo.dart';
import '../widgets/connection_tile.dart';

class ConnectionsListScreen extends ConsumerWidget {
  const ConnectionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(connectionsStreamProvider);
    final repo = ref.watch(connectionRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.connectionsTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.guidedConnectTitle,
            icon: const Icon(Icons.auto_fix_high),
            onPressed: () => context.push(Routes.guidedConnect),
          ),
        ],
      ),
      body: connections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.connLoadFailed(e.toString()))),
        data: (rows) {
          if (rows.isEmpty) {
            return const _Empty();
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = rows[i];
              return ConnectionTile(
                connection: c,
                onOpen: () => context.push(Routes.homeDashboards(c.id)),
                onEdit: () => context.push('/connections/${c.id}/edit'),
                onDelete: () async {
                  final store = ref.read(lastDashboardStoreProvider);
                  await repo.delete(c.id);
                  await store.forget(c.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/connections/form'),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.connAddBroker),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

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
              Icons.cloud_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.connEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(Routes.guidedConnect),
              icon: const Icon(Icons.auto_fix_high),
              label: Text(context.l10n.guidedConnectTitle),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push('/connections/form'),
              child: Text(context.l10n.connAddBroker),
            ),
          ],
        ),
      ),
    );
  }
}
