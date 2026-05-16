import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../mqtt/mqtt_status.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import 'status_badge.dart';

class ConnectionTile extends ConsumerWidget {
  const ConnectionTile({
    super.key,
    required this.connection,
    required this.onTap,
    required this.onDelete,
  });

  final Connection connection;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only autoConnect connections actively maintain a live status; others
    // show "Disconnected" until the user opens a dashboard (Phase 4) or
    // a future "connect now" action.
    final status = connection.autoConnect
        ? ref.watch(connectionStatusProvider(connection.id)).maybeWhen(
              data: (s) => s,
              loading: () => MqttStatus.connecting,
              orElse: () => MqttStatus.error,
            )
        : MqttStatus.disconnected;

    return Dismissible(
      key: ValueKey(connection.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete connection?'),
          content: Text('Removes "${connection.name}" and its saved password.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: const Icon(Icons.cloud),
        title: Text(connection.name),
        subtitle: Text('${connection.host}:${connection.port}'),
        trailing: StatusBadge(status: status),
        onTap: onTap,
      ),
    );
  }
}
