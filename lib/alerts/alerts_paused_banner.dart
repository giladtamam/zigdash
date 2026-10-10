import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/router/routes.dart';
import 'alerts_providers.dart';
import 'alerts_service.dart';

/// On the dashboard when the Home has alerts but the hub's flow has gone
/// quiet (CONTEXT.md: Alerts paused): nothing can fire, so say so.
/// Dismissing hides it until the flow comes back and stops again.
class AlertsPausedBanner extends ConsumerStatefulWidget {
  const AlertsPausedBanner({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<AlertsPausedBanner> createState() => _AlertsPausedBannerState();
}

class _AlertsPausedBannerState extends ConsumerState<AlertsPausedBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(alertsConfigProvider(widget.connectionId)).valueOrNull;
    final online = ref.watch(alertsBridgeOnlineProvider(widget.connectionId)).valueOrNull;
    ref.listen(alertsBridgeOnlineProvider(widget.connectionId), (_, next) {
      if (next.valueOrNull == true && _dismissed) setState(() => _dismissed = false);
    });
    if (config == null || online != false || _dismissed) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
        child: Row(
          children: [
            Icon(Icons.pause_circle_outline, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.alertsStatusPaused,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onErrorContainer)),
            ),
            TextButton(
              onPressed: () => context.push(Routes.homeAlerts(widget.connectionId)),
              child: Text(l10n.alertsTitle),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _dismissed = true),
            ),
          ],
        ),
      ),
    );
  }
}
