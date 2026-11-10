import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../l10n/app_localizations.dart';
import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'assistant_client.dart';
import 'support_details.dart';

/// When the assistant last answered, as epoch milliseconds in
/// SharedPreferences (3.5.0): a setup that completes within 24 hours of it
/// reports `help_seen: yes`, the only join between the two that needs no
/// identifier. Set on an answer, never on a card that failed or rested.
const kAssistantAnsweredAtMs = 'assistant_answered_at_ms';

/// Whether the assistant answered within the last 24 hours.
bool assistantHelpedRecently(SharedPreferences prefs, {DateTime? now}) {
  final at = prefs.getInt(kAssistantAnsweredAtMs);
  if (at == null) return false;
  final then = DateTime.fromMillisecondsSinceEpoch(at);
  final t = now ?? DateTime.now();
  return t.isAfter(then) && t.difference(then) < const Duration(hours: 24);
}

/// What the panel hands to Send when the user wants a person, in the order
/// that survives clipping on the developer's side: details first, the
/// user's words, then the last two answers.
class AssistantHandoff {
  const AssistantHandoff({required this.lastAnswers, this.flagged});

  /// The last two assistant answers, oldest first.
  final List<String> lastAnswers;

  /// The answer "Did this help? No" was tapped on, when that is why.
  final String? flagged;
}

/// The assistant inside Get help (3.5.0, assistant-in-app-2026-11.md): a
/// template line from the Support details, the model's first answer
/// fetched once when the panel opens, then a conversation of at most twelve
/// turns. "Did this help?" under each answer; No hands the answer to Send,
/// which is also the way to report a bad answer. Talk to a person is the
/// screen's own Send button, below the panel.
class AssistantPanel extends ConsumerStatefulWidget {
  const AssistantPanel({
    super.key,
    required this.from,
    required this.details,
    required this.triage,
    required this.onTalkToPerson,
    required this.onReport,
  });

  final HelpFrom from;
  final SupportDetails details;
  final AssistantTriage triage;

  /// Talk to a person: opens the Send form with the handoff attached.
  final ValueChanged<AssistantHandoff> onTalkToPerson;

  /// "Did this help? No": opens the Send form with the answer attached.
  final ValueChanged<AssistantHandoff> onReport;

  @override
  ConsumerState<AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends ConsumerState<AssistantPanel> {
  final _turns = <AssistantTurn>[];
  final _reply = TextEditingController();
  final _scroll = ScrollController();
  AssistantOutcome? _last;
  bool _busy = false;
  int _asked = 0;

  /// Per answer index: true = helped, false = did not, null = not asked.
  final _helped = <int, bool>{};

  @override
  void initState() {
    super.initState();
    _reply.addListener(() => setState(() {}));
    ref.read(analyticsProvider).track(AssistantEvent(
          AssistantStep.shown,
          widget.from,
        ));
    WidgetsBinding.instance.addPostFrameCallback((_) => _ask(first: true));
  }

  @override
  void dispose() {
    _reply.dispose();
    _scroll.dispose();
    super.dispose();
  }

  AssistantRequest _request() => AssistantRequest(
        details: widget.details.format(),
        triage: widget.triage,
        locale: Localizations.localeOf(context).toLanguageTag(),
        appVersion: widget.details.appVersion,
        build: widget.details.build,
        turns: List.unmodifiable(_turns),
      );

  Future<void> _ask({bool first = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _last = null;
    });
    final reply = await ref.read(assistantCallerProvider)(
      _request(),
      first ? assistantFirstTimeout : assistantReplyTimeout,
    );
    if (!mounted) return;
    final analytics = ref.read(analyticsProvider);
    switch (reply.outcome) {
      case AssistantOutcome.answered:
        _turns.add(AssistantTurn.assistant(reply.text!));
        analytics.track(AssistantEvent(AssistantStep.answered, widget.from));
        // Best effort: the stamp is bookkeeping for help_seen, never a
        // reason to fail the answer.
        try {
          await ref.read(sharedPreferencesProvider).setInt(
                kAssistantAnsweredAtMs,
                DateTime.now().millisecondsSinceEpoch,
              );
        } catch (_) {}
      case AssistantOutcome.resting:
        analytics.track(AssistantEvent(AssistantStep.resting, widget.from));
      case AssistantOutcome.refused:
        analytics.track(AssistantEvent(AssistantStep.refused, widget.from));
      case AssistantOutcome.failed:
        analytics.track(AssistantEvent(AssistantStep.failed, widget.from));
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _last = reply.outcome;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    if (text.isEmpty || _busy) return;
    _reply.clear();
    setState(() => _turns.add(AssistantTurn.user(text)));
    _asked += 1;
    ref.read(analyticsProvider).track(AssistantEvent(
          AssistantStep.asked,
          widget.from,
          nth: _asked,
        ));
    await _ask();
  }

  List<String> get _lastAnswers => [
        for (final t in _turns.where((t) => !t.fromUser)) t.text,
      ].reversed.take(2).toList().reversed.toList();

  void _helpedTap(int index, bool yes) {
    setState(() => _helped[index] = yes);
    ref.read(analyticsProvider).track(AssistantEvent(
          yes ? AssistantStep.helpedYes : AssistantStep.helpedNo,
          widget.from,
        ));
    if (!yes) {
      widget.onReport(AssistantHandoff(
        lastAnswers: _lastAnswers,
        flagged: _turns[index].text,
      ));
    }
  }

  void _person() {
    ref.read(analyticsProvider).track(AssistantEvent(
          AssistantStep.escalated,
          widget.from,
        ));
    widget.onTalkToPerson(AssistantHandoff(lastAnswers: _lastAnswers));
  }

  /// The template line: what the app already knows, in the user's words'
  /// place, so the first answer does not start from nothing.
  String _opening(AppLocalizations l10n) {
    final d = widget.details;
    final scan = d.lastScan;
    final parts = <String>[];
    if (scan != null) {
      parts.add(l10n.assistantOpeningScan(
        scan.hostsTried,
        scan.brokersFound,
        scan.network ?? '',
      ));
    }
    if (widget.triage.running == 'yes') {
      parts.add(l10n.assistantOpeningRunningYes);
    } else if (widget.triage.running == 'not_sure') {
      parts.add(l10n.assistantOpeningRunningNotSure);
    }
    if (parts.isEmpty) return l10n.assistantOpeningGeneric;
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final answers = _turns.where((t) => !t.fromUser).length;
    final canReply =
        answers > 0 && !_busy && _turns.length < assistantMaxTurns;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.assistantTitle,
                      style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.assistantNotice,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(_opening(l10n), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView(
                controller: _scroll,
                shrinkWrap: true,
                children: [
                  for (var i = 0; i < _turns.length; i++)
                    _Bubble(
                      turn: _turns[i],
                      helped: _helped[i],
                      onHelped: _turns[i].fromUser
                          ? null
                          : (yes) => _helpedTap(i, yes),
                    ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          _TypingText(),
                        ],
                      ),
                    ),
                  if (!_busy && _last != null &&
                      _last != AssistantOutcome.answered)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        switch (_last!) {
                          AssistantOutcome.resting => l10n.assistantResting,
                          AssistantOutcome.refused => l10n.assistantRefused,
                          _ => l10n.assistantFailed,
                        },
                        key: const Key('assistant-status'),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.error),
                      ),
                    ),
                ],
              ),
            ),
            if (!_busy && _last == AssistantOutcome.failed && answers == 0)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  key: const Key('assistant-retry'),
                  onPressed: () => _ask(first: true),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.assistantRetry),
                ),
              ),
            if (answers > 0) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('assistant-reply'),
                      controller: _reply,
                      enabled: canReply,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: assistantMaxTurnChars,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: _turns.length >= assistantMaxTurns
                            ? l10n.assistantTurnsUsed
                            : l10n.assistantReplyHint,
                        border: const OutlineInputBorder(),
                        counterText: '',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: const Key('assistant-send'),
                    onPressed:
                        canReply && _reply.text.trim().isNotEmpty ? _send : null,
                    icon: const Icon(Icons.arrow_upward),
                    tooltip: l10n.getHelpSend,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('assistant-person'),
                onPressed: _person,
                icon: const Icon(Icons.support_agent),
                label: Text(l10n.assistantTalkToPerson),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.turn, this.helped, this.onHelped});
  final AssistantTurn turn;
  final bool? helped;
  final ValueChanged<bool>? onHelped;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = turn.fromUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: mine ? scheme.primaryContainer : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              turn.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mine ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
            ),
          ),
          if (!mine && onHelped != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Text(l10n.assistantHelped,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  IconButton(
                    key: const Key('assistant-helped-yes'),
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    isSelected: helped == true,
                    onPressed: helped == null ? () => onHelped!(true) : null,
                    icon: const Icon(Icons.thumb_up_outlined),
                    selectedIcon: const Icon(Icons.thumb_up),
                    tooltip: l10n.assistantHelpedYes,
                  ),
                  IconButton(
                    key: const Key('assistant-helped-no'),
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    isSelected: helped == false,
                    onPressed: helped == null ? () => onHelped!(false) : null,
                    icon: const Icon(Icons.thumb_down_outlined),
                    selectedIcon: const Icon(Icons.thumb_down),
                    tooltip: l10n.assistantHelpedNo,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingText extends StatelessWidget {
  const _TypingText();
  @override
  Widget build(BuildContext context) => Text(
        context.l10n.assistantThinking,
        style: Theme.of(context).textTheme.bodySmall,
      );
}
