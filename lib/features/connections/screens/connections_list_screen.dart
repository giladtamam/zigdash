import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/connection_repo.dart';
import '../widgets/connection_tile.dart';

class ConnectionsListScreen extends ConsumerWidget {
  const ConnectionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(connectionsStreamProvider);
    final repo = ref.watch(connectionRepoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: connections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
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
                onOpen: () => context.push('/connections/${c.id}/dashboards'),
                onEdit: () => context.push('/connections/${c.id}/edit'),
                onDelete: () => repo.delete(c.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/connections/form'),
        icon: const Icon(Icons.add),
        label: const Text('Add broker'),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No connections yet.\nTap "Add broker" to point ZigDash at your MQTT server.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
