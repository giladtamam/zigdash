import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/review/review_prompt_controller.dart';
import '../../ha_import/ha_import_offer.dart';
import '../../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'poll_card.dart' show pollAfterDays;

/// The home whose dashboard asks "What made you try ZigDash?": set when first
/// run ends (FirstRun.finish), removed once answered or put away.
const whyAskKey = 'why_ask';

/// "What made you try ZigDash?" (3.1.10): a one-time card on the first home's
/// dashboard, so we learn why people come (the analytics show what they do,
/// not why). Asked only with usage data on, after the usage-data question and
/// the Home Assistant import offer; it gives way to the poll on day three.
class WhyCard extends ConsumerStatefulWidget {
  const WhyCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<WhyCard> createState() => _WhyCardState();
}

class _WhyCardState extends ConsumerState<WhyCard> {
  bool _done = false;

  Future<void> _finish() async {
    setState(() => _done = true);
    await ref.read(sharedPreferencesProvider).remove(whyAskKey);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sharing =
        ref.watch(analyticsAvailableProvider) &&
        ref.watch(analyticsConsentProvider) == AnalyticsConsent.granted;
    final days = prefs.getInt(ReviewPromptController.kSessions) ?? 0;
    if (_done ||
        prefs.getString(whyAskKey) != widget.connectionId ||
        !sharing ||
        days >= pollAfterDays ||
        // The cards don't stack: the import offer comes first.
        ref.watch(haImportOfferProvider) == widget.connectionId) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.whyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(l10n.whyBody, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (choice, label) in [
                  (WhyChoice.faster, l10n.whyFaster),
                  (WhyChoice.family, l10n.whyFamily),
                  (WhyChoice.wallTablet, l10n.whyWallTablet),
                  (WhyChoice.withoutHa, l10n.whyWithoutHa),
                  (WhyChoice.other, l10n.whyOther),
                ])
                  ActionChip(
                    label: Text(label),
                    onPressed: () {
                      ref.read(analyticsProvider).track(WhyAnswer(choice));
                      _finish();
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.whyThanks)),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.pollNotNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
