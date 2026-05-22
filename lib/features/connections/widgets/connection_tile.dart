import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../mqtt/mqtt_status.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import 'status_badge.dart';

class ConnectionTile extends ConsumerWidget {
  const ConnectionTile({
    super.key,
    required this.connection,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Connection connection;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = connection.autoConnect
        ? ref.watch(connectionStatusProvider(connection.id)).maybeWhen(
              data: (s) => s,
              loading: () => MqttStatus.connecting,
              orElse: () => MqttStatus.error,
            )
        : MqttStatus.disconnected;

    final endpoint = connection.autoConnect
        ? ref.watch(connectionEndpointProvider(connection.id)).maybeWhen(
              data: (e) => e,
              orElse: () => null,
            )
        : null;

    return Dismissible(
      key: ValueKey(connection.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.connDeleteTitle),
          content: Text(context.l10n.connDeleteContent(connection.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
            FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.delete)),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: const Icon(Icons.cloud),
        title: Text(connection.name),
        subtitle: Text('${connection.host}:${connection.port}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(status: status, endpoint: endpoint),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(context.l10n.edit)),
                PopupMenuItem(value: 'delete', child: Text(context.l10n.delete)),
              ],
            ),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}
