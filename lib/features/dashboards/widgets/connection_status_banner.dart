import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../mqtt/mqtt_status.dart';

/// The slim "Can't reach your broker · Why?" line
/// (docs/design/dashboard-1.12.md §5). It replaces the old banner: it never
/// covers tiles, which keep their last known values. "Why?" explains and
/// offers Reconnect now and the connection settings, where the connection
/// can be tested. Hidden while connected, first connecting, or signed out.
class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({
    super.key,
    required this.status,
    required this.onReconnect,
    this.onSettings,
    this.lastError,
  });

  final MqttStatus status;
  final VoidCallback onReconnect;
  final VoidCallback? onSettings;
  final String? lastError;

  @override
  Widget build(BuildContext context) {
    if (status != MqttStatus.reconnecting && status != MqttStatus.error) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Semantics(
      identifier: 'connection-status-banner',
      liveRegion: true,
      container: true,
      child: Material(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 4, 0),
          child: Row(
            children: [
              Icon(Icons.cloud_off,
                  size: 18, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.statusCantReach,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onErrorContainer),
                ),
              ),
              TextButton(
                onPressed: () => _explain(context),
                child: Text(l10n.statusWhy),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _explain(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.statusWhyTitle,
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(l10n.statusWhyBody),
              if (lastError != null) ...[
                const SizedBox(height: 12),
                Text(lastError!,
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onReconnect();
                },
                child: Text(l10n.connectionReconnectNow),
              ),
              if (onSettings != null) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onSettings!();
                  },
                  child: Text(l10n.statusSettings),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
