import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/review/review_prompt_controller.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../onboarding/demo_service.dart' show isDemoConnection;
import '../../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../../settings/screens/settings_screen.dart' show sendFeedback;

/// "1" once the poll was answered or put away: it is asked only once.
const pollDoneKey = 'poll_next_done';

/// Days on a connected dashboard before the poll is asked.
const pollAfterDays = 3;

/// "What should ZigDash do next?" (docs/design/roadmap-post-2.0.md, 2.2 §6):
/// a one-time card on a real Home's dashboard once the app was used on
/// [pollAfterDays] days, after the usage-data question was answered. With
/// usage data on, a choice is sent as `poll_answer`; with it off, nothing is
/// sent and the card points to Request a feature.
class PollCard extends ConsumerStatefulWidget {
  const PollCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<PollCard> createState() => _PollCardState();
}

class _PollCardState extends ConsumerState<PollCard> {
  bool _done = false;

  Future<void> _finish() async {
    setState(() => _done = true);
    await ref.read(sharedPreferencesProvider).setString(pollDoneKey, '1');
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final consent = ref.watch(analyticsConsentProvider);
    final available = ref.watch(analyticsAvailableProvider);
    final host =
        ref.watch(connectionByIdProvider(widget.connectionId)).valueOrNull?.host;
    final days = prefs.getInt(ReviewPromptController.kSessions) ?? 0;
    if (_done ||
        prefs.getString(pollDoneKey) != null ||
        days < pollAfterDays ||
        host == null ||
        isDemoConnection(host) ||
        // The usage-data question comes first; the cards don't stack.
        (available && consent == AnalyticsConsent.unasked)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sharing = available && consent == AnalyticsConsent.granted;
    final messenger = ScaffoldMessenger.of(context);
    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pollTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(sharing ? l10n.pollBody : l10n.pollNoAnalytics,
                  style: theme.textTheme.bodyMedium),
            ),
            if (sharing) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (choice, label) in [
                    (PollChoice.notifications, l10n.pollNotifications),
                    (PollChoice.history, l10n.pollHistory),
                    (PollChoice.kiosk, l10n.pollKiosk),
                    (PollChoice.groups, l10n.pollGroups),
                  ])
                    ActionChip(
                      label: Text(label),
                      onPressed: () {
                        ref.read(analyticsProvider).track(PollAnswer(choice));
                        _finish();
                        messenger.showSnackBar(
                            SnackBar(content: Text(l10n.pollThanks)));
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(onPressed: _finish, child: Text(l10n.pollNotNow)),
                if (!sharing)
                  FilledButton(
                    onPressed: () {
                      _finish();
                      sendFeedback(context, ref, problem: false);
                    },
                    child: Text(l10n.settingsFeatureRequest),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
