import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart' show ProFrom;

import '../../core/l10n/l10n_ext.dart';
import '../../data/database/tables/connections.dart';
import '../../data/repositories/connection_repo.dart';
import '../../l10n/app_localizations.dart';
import '../history/history_service.dart' show historyRecorderOnlineProvider;
import '../onboarding/demo_service.dart' show isDemoConnection;
import 'pro.dart';
import 'pro_screen.dart';
import 'pro_trial.dart';

/// What the trial card shows now, or null for nothing.
enum ProTrialCardShows { started, offer, ending }

/// The trial's dashboard card (3.6, pro-trial-360.md §3) for [connectionId]:
/// "Pro is on for 14 days" once after it starts, "Try ZigDash Pro free" for
/// a Home that already recorded, or "ends in 2 days". Null when there is
/// nothing to show (cards never stack: the next card waits on this).
ProTrialCardShows? proTrialCardFor(WidgetRef ref, String connectionId) {
  if (!ref.watch(proTrialOfferedProvider)) return null;
  if (ref.watch(proStatusProvider) == ProStatus.unlocked) return null;
  final trial = ref.watch(proTrialProvider);
  if (!trial.loaded) return null;
  final home = ref.watch(connectionByIdProvider(connectionId)).valueOrNull;
  if (home == null || isDemoConnection(home.host)) return null;
  final now = ref.read(proTrialNowProvider)();
  if (trial.start == null) {
    if (trial.offerAnswered || trial.pendingFrom != null) return null;
    final viaPage = transportOf(home.transport) == ConnectionTransport.z2mPage;
    final online = viaPage
        ? false
        : ref.watch(historyRecorderOnlineProvider(connectionId)).valueOrNull;
    return online == true ? ProTrialCardShows.offer : null;
  }
  if (!trial.runningAt(now)) return null;
  if (!trial.startNoticeSeen) return ProTrialCardShows.started;
  final end = trial.end!;
  if (!trial.endingDismissed &&
      !now.isBefore(end.subtract(proTrialEndingNotice))) {
    return ProTrialCardShows.ending;
  }
  return null;
}

class ProTrialCard extends ConsumerStatefulWidget {
  const ProTrialCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<ProTrialCard> createState() => _ProTrialCardState();
}

class _ProTrialCardState extends ConsumerState<ProTrialCard> {
  bool _endingCounted = false;

  ConnectionTransport? get _transport => ref
      .read(connectionByIdProvider(widget.connectionId))
      .valueOrNull
      ?.transport;

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(proTrialProvider.notifier);
    // Starts the trial the first time a recorder reports online after this
    // install's own "Turn on History" (pro-trial-360.md §3).
    final home = ref
        .watch(connectionByIdProvider(widget.connectionId))
        .valueOrNull;
    final viaPage = transportOf(home?.transport) == ConnectionTransport.z2mPage;
    if (!viaPage && home != null && !isDemoConnection(home.host)) {
      final online = ref
          .watch(historyRecorderOnlineProvider(widget.connectionId))
          .valueOrNull;
      if (online == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) controller.recorderOnline(home.transport);
        });
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.endedIfDue();
    });

    final shows = proTrialCardFor(ref, widget.connectionId);
    if (shows == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final trial = ref.watch(proTrialProvider);
    if (shows == ProTrialCardShows.ending && !_endingCounted) {
      _endingCounted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.endingShown();
      });
    }
    final price = ref.watch(proPriceProvider).valueOrNull;

    final (title, body, actions) = switch (shows) {
      ProTrialCardShows.started => (
        l10n.proTrialStartedTitle,
        '${l10n.proTrialWhat} ${l10n.proTrialNoPayment}',
        <Widget>[
          TextButton(
            key: const Key('pro-trial-ok'),
            onPressed: controller.noticeSeen,
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
      ProTrialCardShows.offer => (
        l10n.proTrialOfferTitle,
        '${l10n.proTrialWhat} ${l10n.proTrialNoPayment}',
        <Widget>[
          TextButton(
            key: const Key('pro-trial-not-now'),
            onPressed: controller.declineOffer,
            child: Text(l10n.historyOnLater),
          ),
          FilledButton(
            key: const Key('pro-trial-start'),
            onPressed: () async {
              await controller.startFromOffer(_transport);
              await controller.noticeSeen();
            },
            child: Text(l10n.proTrialStart),
          ),
        ],
      ),
      ProTrialCardShows.ending => (
        l10n.proTrialEndingTitle,
        _endingBody(l10n, trial),
        <Widget>[
          TextButton(
            key: const Key('pro-trial-ending-not-now'),
            onPressed: controller.dismissEnding,
            child: Text(l10n.historyOnLater),
          ),
          FilledButton(
            key: const Key('pro-trial-keep'),
            onPressed: () => openPro(context, from: ProFrom.trialEnd),
            child: Text(price == null ? l10n.proBuy : l10n.proTrialKeep(price)),
          ),
        ],
      ),
    };
    return Card(
      key: const Key('pro-trial-card'),
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(body, style: theme.textTheme.bodyMedium),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _endingBody(AppLocalizations l10n, ProTrial trial) {
    final used = [
      if (trial.used.contains(ProTrialUse.history)) l10n.proTrialUsedHistory,
      if (trial.used.contains(ProTrialUse.wall)) l10n.proTrialUsedWall,
      if (trial.used.contains(ProTrialUse.automation))
        l10n.proTrialUsedAutomation,
    ];
    final first = used.isEmpty
        ? l10n.proTrialWhat
        : l10n.proTrialYouUsed(used.join(', '));
    return '$first ${l10n.proTrialAfterEnd}';
  }
}

/// "Trial, N days left" for Settings and the Pro screen; null when no
/// trial runs.
String? proTrialDaysLeftText(WidgetRef ref, AppLocalizations l10n) {
  if (!ref.watch(proTrialOfferedProvider)) return null;
  if (ref.watch(proStatusProvider) == ProStatus.unlocked) return null;
  final trial = ref.watch(proTrialProvider);
  final now = ref.read(proTrialNowProvider)();
  if (!trial.runningAt(now)) return null;
  final left = trial.end!.difference(now);
  final days = (left.inHours / 24).ceil().clamp(1, 14);
  return l10n.proTrialDaysLeft(days);
}
