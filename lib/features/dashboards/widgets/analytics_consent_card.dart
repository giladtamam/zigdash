import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../onboarding/demo_service.dart' show isDemoConnection;

/// The one consent question for people who installed before 2.0 (ADR 0006):
/// shown once, on a real home's dashboard, until they answer. New installs
/// answer on the first setup screen instead.
class AnalyticsConsentCard extends ConsumerWidget {
  const AnalyticsConsentCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(connectionByIdProvider(connectionId)).valueOrNull?.host;
    if (!ref.watch(analyticsAvailableProvider) ||
        ref.watch(analyticsConsentProvider) != AnalyticsConsent.unasked ||
        host == null ||
        isDemoConnection(host)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final consent = ref.read(analyticsConsentProvider.notifier);
    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.analyticsCardTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(l10n.analyticsCardBody,
                  style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => launchUrl(usageDataPolicyUrl,
                      mode: LaunchMode.externalApplication),
                  child: Text(l10n.analyticsWhatsShared),
                ),
                TextButton(
                  onPressed: () => consent.set(false),
                  child: Text(l10n.analyticsNoThanks),
                ),
                FilledButton(
                  onPressed: () => consent.set(true),
                  child: Text(l10n.analyticsShare),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
