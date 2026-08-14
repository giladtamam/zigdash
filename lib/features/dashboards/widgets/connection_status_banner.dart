import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../mqtt/mqtt_status.dart';

class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({
    super.key,
    required this.status,
    required this.onReconnect,
  });

  final MqttStatus status;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    if (status == MqttStatus.connected || status == MqttStatus.disconnected) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final (title, detail, canReconnect) = switch (status) {
      MqttStatus.connecting => (l10n.connectionConnecting, null, false),
      MqttStatus.reconnecting => (
          l10n.connectionReconnecting,
          l10n.connectionShowingLastKnownValues,
          true,
        ),
      MqttStatus.error => (
          l10n.connectionFailed,
          l10n.connectionAutomaticRetry,
          true,
        ),
      MqttStatus.connected || MqttStatus.disconnected => throw StateError(
          'Hidden connection status reached banner rendering',
        ),
    };

    return Semantics(
      identifier: 'connection-status-banner',
      liveRegion: true,
      container: true,
      child: Card(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (detail != null) Text(detail),
                      ],
                    ),
                  ),
                ],
              ),
              if (canReconnect)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: onReconnect,
                    child: Text(l10n.connectionReconnectNow),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
