import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/review/review_prompt_controller.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../../onboarding/demo_service.dart' show isDemoConnection;
import '../../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../../settings/screens/settings_screen.dart' show sendFeedback;
import 'remote_offer_card.dart' show remoteOfferProvider;

/// "1" once the 3.3.5 poll was answered or put away: the card asks once.
/// A new key, so people who answered the old poll are asked again.
const pollDoneKey = 'poll_next_2_done';

/// Days with a live connection before the card asks.
const pollAfterSessions = 2;

/// "What should ZigDash do next?" (3.3.5): a one-time card on a real
/// Home's dashboard from the [pollAfterSessions]th day it was used, after
/// the usage-data question was answered. The same question stays in
/// Settings ([showPollSheet]).
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
    final host = ref
        .watch(connectionByIdProvider(widget.connectionId))
        .valueOrNull
        ?.host;
    final sessions = prefs.getInt(ReviewPromptController.kSessions) ?? 0;
    if (_done ||
        prefs.getString(pollDoneKey) != null ||
        sessions < pollAfterSessions ||
        host == null ||
        isDemoConnection(host) ||
        // The usage-data question comes first; the cards don't stack.
        (available && consent == AnalyticsConsent.unasked) ||
        // The remote control offer goes first while it shows (3.1.11).
        ref.watch(remoteOfferProvider(widget.connectionId))) {
      return const SizedBox.shrink();
    }
    return Card(
      key: const Key('poll-card'),
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: PollQuestion(from: PollFrom.card, onDone: _finish),
      ),
    );
  }
}

/// The poll in a sheet, from Settings › What should ZigDash do next?
Future<void> showPollSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (ctx) => SafeArea(
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 16, 16),
      child: PollQuestion(
        from: PollFrom.settings,
        onDone: () => Navigator.of(ctx).pop(),
      ),
    ),
  ),
);

/// The question, its choices (pick any), and Send. With usage data on,
/// each choice is sent as `poll_answer`; Something else also opens Request
/// a feature for the words. With it off, nothing is sent and it points to
/// Request a feature.
class PollQuestion extends ConsumerStatefulWidget {
  const PollQuestion({super.key, required this.from, required this.onDone});

  final PollFrom from;
  final VoidCallback onDone;

  @override
  ConsumerState<PollQuestion> createState() => _PollQuestionState();
}

class _PollQuestionState extends ConsumerState<PollQuestion> {
  final _picked = <PollChoice>{};

  static String _label(AppLocalizations l10n, PollChoice choice) =>
      switch (choice) {
        PollChoice.pair => l10n.pollPair,
        PollChoice.deviceSettings => l10n.pollDeviceSettings,
        PollChoice.zha => l10n.pollZha,
        PollChoice.aiAssistant => l10n.pollAiAssistant,
        PollChoice.other => l10n.pollOther,
      };

  Future<void> _send() async {
    final analytics = ref.read(analyticsProvider);
    for (final choice in PollChoice.values.where(_picked.contains)) {
      analytics.track(PollAnswer(choice, widget.from));
    }
    if (_picked.contains(PollChoice.other)) {
      await _requestFeature();
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    widget.onDone();
    messenger.showSnackBar(SnackBar(content: Text(l10n.pollThanks)));
  }

  /// Request a feature first, then [PollQuestion.onDone]: done first would
  /// close the Settings sheet under it.
  Future<void> _requestFeature() async {
    await sendFeedback(context, ref, problem: false);
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sharing =
        ref.watch(analyticsAvailableProvider) &&
        ref.watch(analyticsConsentProvider) == AnalyticsConsent.granted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.pollTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Text(
            sharing ? l10n.pollBody : l10n.pollNoAnalytics,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        if (sharing) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final choice in PollChoice.values)
                FilterChip(
                  key: Key('poll-${choice.wire}'),
                  label: Text(_label(l10n, choice)),
                  selected: _picked.contains(choice),
                  onSelected: (on) => setState(
                    () => on ? _picked.add(choice) : _picked.remove(choice),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                key: const Key('poll-not-now'),
                onPressed: widget.onDone,
                child: Text(l10n.pollNotNow),
              ),
              if (sharing)
                FilledButton(
                  key: const Key('poll-send'),
                  onPressed: _picked.isEmpty ? null : _send,
                  child: Text(l10n.pollSend),
                )
              else
                FilledButton(
                  onPressed: _requestFeature,
                  child: Text(l10n.settingsFeatureRequest),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
