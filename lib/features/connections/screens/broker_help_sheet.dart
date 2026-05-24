import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';

/// Static "How do I find my broker IP?" guidance, covering the common
/// Zigbee2MQTT setups. Shown from the connection form.
class BrokerHelpSheet extends StatelessWidget {
  const BrokerHelpSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const BrokerHelpSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(l10n.connHelpTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _Section(
            icon: Icons.dns_outlined,
            title: l10n.connHelpDockerTitle,
            body: l10n.connHelpDockerBody,
          ),
          _Section(
            icon: Icons.router_outlined,
            title: l10n.connHelpSmhubTitle,
            body: l10n.connHelpSmhubBody,
          ),
          _Section(
            icon: Icons.warning_amber_rounded,
            title: l10n.connHelpZhaTitle,
            body: l10n.connHelpZhaBody,
          ),
          const Divider(height: 28),
          Row(
            children: [
              Icon(Icons.wifi, size: 18, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.connHelpSameNetwork,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
