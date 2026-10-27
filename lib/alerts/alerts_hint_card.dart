import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/router/routes.dart';
import '../features/settings/providers/settings_controller.dart' show sharedPreferencesProvider;
import 'alerts_service.dart';

String _dismissedKey(String connectionId) => 'alerts.hint_dismissed.$connectionId';

/// Points to Alerts from the Automations tab (3.2.1): people asked for
/// notifications without finding Alerts under the Home's settings. Shown
/// until this phone gets the Home's alerts, or "Not now" hides it for good.
class AlertsHintCard extends ConsumerStatefulWidget {
  const AlertsHintCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<AlertsHintCard> createState() => _AlertsHintCardState();
}

class _AlertsHintCardState extends ConsumerState<AlertsHintCard> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _dismissed = ref.read(sharedPreferencesProvider).getBool(_dismissedKey(widget.connectionId)) ?? false;
  }

  void _dismiss() {
    ref.read(sharedPreferencesProvider).setBool(_dismissedKey(widget.connectionId), true);
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final config = ref.watch(alertsConfigProvider(widget.connectionId));
    // Not known yet: wait rather than flash the card at people who have alerts.
    if (config.isLoading) return const SizedBox.shrink();
    final c = config.valueOrNull;
    if (c != null && ref.read(alertsServiceProvider).thisPhoneIn(c)) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      key: const Key('alerts-hint'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.alertsHintTitle, style: theme.textTheme.titleMedium)),
            ]),
            const SizedBox(height: 8),
            Text(l10n.alertsHintBody),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  key: const Key('alerts-hint-open'),
                  onPressed: () => context.push(Routes.homeAlerts(widget.connectionId)),
                  child: Text(l10n.alertsHintButton),
                ),
                TextButton(
                  key: const Key('alerts-hint-dismiss'),
                  onPressed: _dismiss,
                  child: Text(l10n.alertsHintNotNow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
