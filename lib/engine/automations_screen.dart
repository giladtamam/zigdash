import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/router/routes.dart';
import '../features/settings/providers/settings_controller.dart' show sharedPreferencesProvider;
import '../l10n/app_localizations.dart';
import '../features/pro/pro_screen.dart';
import '../core/analytics/analytics.dart';
import '../alerts/alerts_hint_card.dart';
import '../features/home/home_shell.dart' show HomeTitle, SettingsAction;
import 'automation.dart';
import 'automation_editor_screen.dart';
import 'automation_text.dart';
import 'automations_repo.dart';
import 'engine_installer.dart';
import 'engine_sheet.dart';
import '../features/history/history_setup_flow.dart' show allowEngineAndRestart, installEngineOn;
import '../features/pro/pro_trial.dart' show ProTrialUse, proAccessProvider, proTrialProvider;
import 'engine_providers.dart';
import 'engine_status.dart';

/// The Automations screen (zigdash-3.0.md §1, §2). Phase 1: the Engine's
/// install, consent and health. The list and editor arrive in phase 2.
class AutomationsScreen extends ConsumerStatefulWidget {
  const AutomationsScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<AutomationsScreen> createState() => _AutomationsScreenState();
}

enum _Busy { none, installing, restarting }

class _AutomationsScreenState extends ConsumerState<AutomationsScreen> {
  _Busy _busy = _Busy.none;
  String? _error;

  void _track(EngineStep step) => ref.read(analyticsProvider).track(EngineEvent(step,
      z2m: ref.read(engineViewProvider(widget.connectionId)).valueOrNull?.hub?.version));

  final _seen = <HubEnginePhase>{};

  /// 3.6.2: the rules for the switches before an install, from the start.
  late final WaitingRulesWatch _rules;

  @override
  void initState() {
    super.initState();
    _rules = WaitingRulesWatch(ref, widget.connectionId);
  }

  @override
  void dispose() {
    _rules.close();
    super.dispose();
  }

  /// Each phase worth counting, once per visit to this screen.
  void _seenPhase(HubEnginePhase phase) {
    if (!_seen.add(phase)) return;
    switch (phase) {
      case HubEnginePhase.notInstalled:
        _track(EngineStep.offered);
      case HubEnginePhase.needsConsent:
        _track(EngineStep.consentShown);
      case HubEnginePhase.tooOld:
        _track(EngineStep.tooOld);
      case HubEnginePhase.paused:
        _track(EngineStep.seenPaused);
      case HubEnginePhase.stoppedSelf:
        _track(EngineStep.seenStopped);
      case HubEnginePhase.checking:
      case HubEnginePhase.running:
      case HubEnginePhase.unreachable:
      case HubEnginePhase.needsBroker:
        break;
    }
  }

  Future<void> _install() async {
    setState(() {
      _busy = _Busy.installing;
      _error = null;
    });
    final l10n = context.l10n;
    try {
      final (answer, error) = await installEngineOn(ref, widget.connectionId,
          from: EngineFrom.automations,
          z2m: ref.read(engineViewProvider(widget.connectionId)).valueOrNull?.hub?.version);
      if (!mounted) return;
      setState(() => _error = switch (answer) {
            HubAnswer.ok => null,
            HubAnswer.refused => l10n.engineInstallRefused(error ?? ''),
            HubAnswer.noAnswer => l10n.engineInstallNoAnswer,
          });
    } catch (_) {
      if (mounted) setState(() => _error = l10n.engineInstallNoAnswer);
    } finally {
      if (mounted) setState(() => _busy = _Busy.none);
    }
  }

  Future<void> _consent() async {
    setState(() {
      _busy = _Busy.restarting;
      _error = null;
    });
    final l10n = context.l10n;
    try {
      final answer =
          await allowEngineAndRestart(ref, widget.connectionId, from: EngineFrom.automations);
      if (!mounted) return;
      if (answer != HubAnswer.ok) {
        setState(() {
          _busy = _Busy.none;
          _error = l10n.engineConsentFailed;
        });
        return;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = _Busy.none;
          _error = l10n.engineConsentFailed;
        });
      }
      return;
    }
    if (mounted) await _install();
  }

  /// The Install button under "None of these run yet": the waiting rules'
  /// switches, then install.
  Future<void> _installTapped() async {
    // Add-ons blocked meanwhile: the consent screen shows; never install past it.
    if (ref.read(engineViewProvider(widget.connectionId)).valueOrNull?.phase != HubEnginePhase.notInstalled) return;
    final rules = await _rules.rules();
    if (!mounted || !await confirmWaitingRules(context, ref, widget.connectionId, rules) || !mounted) return;
    _track(EngineStep.installTapped);
    await _install();
  }

  /// The consent buttons: rules waiting for the Engine are asked about
  /// first, as before any install.
  Future<void> _consentTapped() async {
    final rules = await _rules.rules();
    if (!mounted || !await confirmWaitingRules(context, ref, widget.connectionId, rules) || !mounted) return;
    await _consent();
  }

  /// No Engine on the hub, but rules can be made (3.6.2): they wait for it.
  bool _withoutEngine(EngineView v) =>
      !v.away &&
      (v.phase == HubEnginePhase.notInstalled ||
          v.phase == HubEnginePhase.needsConsent ||
          v.phase == HubEnginePhase.tooOld);

  /// Away and no Engine this phone has seen: automations are made at home.
  bool _awayWithoutEngine(EngineView v) => engineAwayWithoutEngine(v,
      knownInstalled: engineKnownInstalled(ref.read(sharedPreferencesProvider), widget.connectionId));

  /// "Allow add-ons after all": back to the consent screen, with what the
  /// restart means, before anything changes on the hub.
  Future<void> _undecline() async {
    await setEngineDeclined(ref.read(sharedPreferencesProvider), widget.connectionId, false);
    if (mounted) ref.invalidate(engineViewProvider(widget.connectionId));
  }

  Future<void> _decline() async {
    _track(EngineStep.declined);
    await setEngineDeclined(ref.read(sharedPreferencesProvider), widget.connectionId, true);
    ref.invalidate(engineViewProvider(widget.connectionId));
  }

  Future<void> _confirmRemove() async {
    final l10n = context.l10n;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.engineRemoveTitle),
        content: Text(l10n.engineRemoveBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.engineRemove)),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    try {
      final installer = await ref.read(engineInstallerProvider(widget.connectionId).future);
      final (answer, error) = await installer.remove();
      if (!mounted) return;
      if (answer == HubAnswer.ok) _track(EngineStep.removed);
      if (answer != HubAnswer.ok) {
        setState(() => _error = answer == HubAnswer.refused
            ? l10n.engineInstallRefused(error ?? '')
            : l10n.engineInstallNoAnswer);
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.engineInstallNoAnswer);
    }
  }

  void _newAutomation() {
    final count = ref.read(automationsProvider(widget.connectionId)).valueOrNull?.length ?? 0;
    if (count >= freeAutomations && !ref.read(proAccessProvider)) {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => _ProCeilingSheet(onPro: () {
          Navigator.of(ctx).pop();
          openPro(context, from: ProFrom.automations);
        }),
      );
      return;
    }
    // 3.6: past the free three while the trial runs: counted once.
    if (count >= freeAutomations) {
      ref.read(proTrialProvider.notifier).used(ProTrialUse.automation);
    }
    // Above the bottom bar, like the scene editor.
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        builder: (_) => AutomationEditorScreen(connectionId: widget.connectionId)));
  }

  Future<void> _startAgain() async {
    final installer = await ref.read(engineInstallerProvider(widget.connectionId).future);
    installer.startAgain();
    _track(EngineStep.startedAgain);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final view = ref.watch(engineViewProvider(widget.connectionId));
    final installed = view.valueOrNull?.installed ?? false;
    final v = view.valueOrNull;
    final waiting = v != null && _withoutEngine(v);
    return Scaffold(
      floatingActionButton: (installed || waiting) && _busy == _Busy.none
          ? FloatingActionButton.extended(
              key: const Key('auto-new'),
              onPressed: _newAutomation,
              icon: const Icon(Icons.add),
              label: Text(l10n.autoNewButton),
            )
          : null,
      appBar: AppBar(
        title: HomeTitle(connectionId: widget.connectionId),
        actions: [
          if (view.valueOrNull?.phase == HubEnginePhase.running)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: Chip(label: Text(l10n.engineRunningOnHub)),
            ),
          if (installed)
            PopupMenuButton<void>(
              key: const Key('engine-menu'),
              itemBuilder: (_) => [
                PopupMenuItem<void>(onTap: _confirmRemove, child: Text(l10n.engineRemove)),
              ],
            ),
          const SettingsAction(),
        ],
      ),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _Message(title: l10n.engineChecking, body: l10n.engineNoConnection),
        data: (v) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            ..._body(context, l10n, v),
            if (v.installed && _busy == _Busy.none) _AutomationsList(connectionId: widget.connectionId),
            if (_withoutEngine(v) && _busy == _Busy.none)
              _AutomationsList(
                connectionId: widget.connectionId,
                waiting: true,
                onInstall: v.phase == HubEnginePhase.notInstalled ? _installTapped : null,
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, AppLocalizations l10n, EngineView v) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _seenPhase(v.phase);
    });
    if (_busy == _Busy.restarting) {
      return [_Progress(text: l10n.engineRestarting)];
    }
    if (_busy == _Busy.installing) {
      return [_Progress(text: l10n.engineInstalling)];
    }
    switch (v.phase) {
      case HubEnginePhase.checking:
        return [_Progress(text: l10n.engineChecking)];
      case HubEnginePhase.unreachable:
        // 3.6.2: an Engine this phone never saw: made at home.
        if (_awayWithoutEngine(v)) return [const _SlimCard(away: true)];
        return [
          _Message(
            key: const Key('engine-away-unreachable'),
            title: l10n.engineAwayNoHubTitle,
            body: l10n.engineAwayNoHubBody,
          ),
        ];
      case HubEnginePhase.needsBroker:
        // 3.2: a Home set up through the Zigbee2MQTT page has no broker
        // yet; the Engine's Automations, Alerts and history need one.
        return [
          _Message(
            key: const Key('engine-needs-broker'),
            title: l10n.engineNeedsBrokerTitle,
            body: l10n.engineNeedsBrokerBody,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/connections/${widget.connectionId}/edit'),
            icon: const Icon(Icons.settings_ethernet),
            label: Text(l10n.engineNeedsBrokerButton),
          ),
        ];
      case HubEnginePhase.tooOld:
        return [
          _Message(
            title: l10n.engineTooOldTitle,
            body: l10n.engineTooOldBody(v.hub?.version ?? '?'),
          ),
        ];
      case HubEnginePhase.notInstalled:
        // 3.6.2: make the automation first; saving it puts the Engine on
        // the hub (engine_sheet.dart), so the full story moved there. Once
        // a rule waits, "None of these run yet" says it instead.
        if (ref.watch(automationsProvider(widget.connectionId)).valueOrNull?.isNotEmpty ?? false) return const [];
        return [const _SlimCard()];
      case HubEnginePhase.needsConsent:
        if (v.declined) {
          return [
            _Message(title: l10n.engineDeclinedTitle, body: l10n.engineDeclinedBody),
            const SizedBox(height: 16),
            FilledButton.tonal(
              key: const Key('engine-allow-after-all'),
              onPressed: _undecline,
              child: Text(l10n.engineAllowAfterAll),
            ),
          ];
        }
        return [
          _Message(title: l10n.engineConsentTitle, body: l10n.engineConsentBody),
          _Bullets([l10n.engineConsentOutage, l10n.engineConsentOpen, l10n.engineConsentUndo]),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('engine-consent'),
            onPressed: _consentTapped,
            child: Text(l10n.engineConsentYes),
          ),
          TextButton(
            key: const Key('engine-decline'),
            onPressed: _decline,
            child: Text(l10n.engineConsentNo),
          ),
        ];
      case HubEnginePhase.paused:
        return [
          _Alert(
            title: l10n.automationsPausedTitle,
            body: v.away
                ? '${l10n.automationsPausedBody}\n\n${l10n.engineAwayReinstallAtHome}'
                : l10n.automationsPausedBody,
            action: v.away ? null : l10n.engineReinstall,
            onAction: v.away ? null : _install,
          ),
        ];
      case HubEnginePhase.stoppedSelf:
        return [
          _Alert(
            title: l10n.engineStoppedTitle,
            body: l10n.engineStoppedBody,
            action: l10n.engineStartAgain,
            onAction: _startAgain,
            secondary: l10n.engineReportProblem,
            onSecondary: () => context.push(Routes.getHelpFrom('automations', home: widget.connectionId)),
          ),
        ];
      case HubEnginePhase.running:
        final r = v.report;
        return [
          AlertsHintCard(connectionId: widget.connectionId),
          if ((r?.rulesLoaded ?? 0) == 0)
            _Message(title: l10n.engineRunningTitle, body: l10n.autoEmptyBody),
          if (v.clockOff) ...[
            const SizedBox(height: 12),
            Text(l10n.engineClockOff, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if ((r?.rulesUnknown ?? const []).isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.engineRulesUnknown(r!.rulesUnknown.length)),
          ],
        ];
    }
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      );
}

class _Message extends StatelessWidget {
  const _Message({super.key, required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(body, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final i in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(i)),
                  ],
                ),
              ),
          ],
        ),
      );
}

class _Alert extends StatelessWidget {
  const _Alert({
    required this.title,
    required this.body,
    this.action,
    this.onAction,
    this.secondary,
    this.onSecondary,
  });
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  final String? secondary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onErrorContainer)),
            const SizedBox(height: 8),
            Text(body, style: TextStyle(color: scheme.onErrorContainer)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (action != null) FilledButton.tonal(onPressed: onAction, child: Text(action!)),
                if (secondary != null) TextButton(onPressed: onSecondary, child: Text(secondary!)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/// "Automations run on your hub with ZigDash Engine…" (3.6.2): the slim
/// card while the Engine isn't on the hub and no rule waits for it. With
/// [away], automations are made at home.
class _SlimCard extends StatelessWidget {
  const _SlimCard({this.away = false});
  final bool away;

  @override
  Widget build(BuildContext context) => Card(
        key: Key(away ? 'engine-away-slim-card' : 'engine-slim-card'),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(away ? context.l10n.engineAwayMakeAtHome : context.l10n.engineSlimCard),
              const EngineSourceLink(),
            ],
          ),
        ),
      );
}

/// The Home's Automations and Recent runs (zigdash-3.0.md §1). With
/// [waiting] (3.6.2), the Engine isn't on the hub: the rules are listed
/// under "None of these run yet", with [onInstall] when it can go there.
class _AutomationsList extends ConsumerWidget {
  const _AutomationsList({required this.connectionId, this.waiting = false, this.onInstall});
  final String connectionId;
  final bool waiting;
  final VoidCallback? onInstall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ml = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final rules = ref.watch(automationsProvider(connectionId)).valueOrNull ?? const <Automation>[];
    final runs = waiting
        ? const <AutomationRun>[]
        : ref.watch(automationRunsProvider(connectionId)).valueOrNull ?? const <AutomationRun>[];
    final pro = ref.watch(proAccessProvider);
    String time(DateTime t) => MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(t));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        if (waiting && rules.isEmpty) ...[
          const SizedBox(height: 8),
          Text(l10n.autoEmptyBody, style: theme.textTheme.bodyLarge),
        ],
        if (waiting && rules.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(l10n.autoNotRunTitle.toUpperCase(), style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(l10n.autoNotRunBody, key: const Key('auto-not-running'), style: theme.textTheme.bodyMedium),
          if (onInstall != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton(
                  key: const Key('engine-install'),
                  onPressed: onInstall,
                  child: Text(l10n.engineInstall),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
        for (final r in rules)
          Card(
            key: Key('auto-${r.id}'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(r.name, style: theme.textTheme.titleMedium)),
                    Switch(
                      value: r.enabled,
                      onChanged: (on) => ref.read(automationsRepoProvider).save(connectionId, r.copyWith(enabled: on)),
                    ),
                  ]),
                  Opacity(
                    opacity: r.enabled ? 1 : 0.55,
                    child: Text(
                      [
                        triggerText(l10n, ml, r.trigger),
                        if (r.conditions.isNotEmpty)
                          l10n.autoOnlyIfList(r.conditions.map((c) => conditionText(l10n, c)).join(', ')),
                        actionText(l10n, r.action),
                      ].join('\n'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Row(children: [
                    TextButton(
                      onPressed: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
                          builder: (_) => AutomationEditorScreen(connectionId: connectionId, existing: r))),
                      child: Text(l10n.autoEdit),
                    ),
                    const Spacer(),
                    () {
                      if (waiting) return Chip(label: Text(l10n.autoNotRunning));
                      final last = runs.where((x) => x.id == r.id).firstOrNull;
                      return Chip(label: Text(last == null ? l10n.autoNeverRan : l10n.autoRanAt(time(last.at))));
                    }(),
                  ]),
                ],
              ),
            ),
          ),
        if (!pro)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.autoFreeCount(rules.length, freeAutomations),
                textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          ),
        if (runs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.autoRecentRuns.toUpperCase(), style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          for (final run in runs.take(10))
            Text('${time(run.at)} · ${rules.where((x) => x.id == run.id).firstOrNull?.name ?? l10n.autoDeleted}'),
        ],
      ],
    );
  }
}

class _ProCeilingSheet extends StatelessWidget {
  const _ProCeilingSheet({required this.onPro});
  final VoidCallback onPro;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.autoCeilingTitle(freeAutomations), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.autoCeilingBody),
            const SizedBox(height: 16),
            FilledButton(key: const Key('auto-ceiling-pro'), onPressed: onPro, child: Text(l10n.autoCeilingSeePro)),
          ],
        ),
      ),
    );
  }
}
