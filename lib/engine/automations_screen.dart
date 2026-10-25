import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/router/routes.dart';
import '../features/settings/providers/settings_controller.dart' show sharedPreferencesProvider;
import '../l10n/app_localizations.dart';
import '../features/pro/pro.dart';
import '../features/pro/pro_screen.dart';
import '../core/analytics/analytics.dart';
import '../features/home/home_shell.dart' show HomeTitle, SettingsAction;
import 'automation.dart';
import 'automation_editor_screen.dart';
import 'automation_text.dart';
import 'automations_repo.dart';
import 'engine_installer.dart';
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
      final installer = await ref.read(engineInstallerProvider(widget.connectionId).future);
      final source = await ref.read(engineSourceProvider.future);
      final (answer, error) = await installer.install(source);
      if (!mounted) return;
      _track(answer == HubAnswer.ok ? EngineStep.installed : EngineStep.failed);
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
    await setEngineDeclined(ref.read(sharedPreferencesProvider), widget.connectionId, false);
    _track(EngineStep.consented);
    try {
      final installer = await ref.read(engineInstallerProvider(widget.connectionId).future);
      final answer = await installer.allowExtensionsAndRestart();
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
    if (count >= freeAutomations && ref.read(proStatusProvider) != ProStatus.unlocked) {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => _ProCeilingSheet(onPro: () {
          Navigator.of(ctx).pop();
          openPro(context);
        }),
      );
      return;
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
    return Scaffold(
      floatingActionButton: installed && _busy == _Busy.none
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
        return [
          _Message(
            key: const Key('engine-away-unreachable'),
            title: l10n.engineAwayNoHubTitle,
            body: l10n.engineAwayNoHubBody,
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
        return [
          _Message(title: l10n.engineIntroTitle, body: l10n.engineIntroBody),
          _Bullets([
            l10n.engineIntroNothingByHand,
            l10n.engineIntroVersion(v.hub?.version ?? '?'),
            l10n.engineIntroRemove,
          ]),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('engine-install'),
            onPressed: _install,
            child: Text(l10n.engineInstall),
          ),
        ];
      case HubEnginePhase.needsConsent:
        if (v.declined) {
          return [
            _Message(title: l10n.engineDeclinedTitle, body: l10n.engineDeclinedBody),
            const SizedBox(height: 16),
            FilledButton.tonal(
              key: const Key('engine-allow-after-all'),
              onPressed: _consent,
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
            onPressed: _consent,
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


/// The Home's Automations and Recent runs (zigdash-3.0.md §1).
class _AutomationsList extends ConsumerWidget {
  const _AutomationsList({required this.connectionId});
  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ml = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final rules = ref.watch(automationsProvider(connectionId)).valueOrNull ?? const <Automation>[];
    final runs = ref.watch(automationRunsProvider(connectionId)).valueOrNull ?? const <AutomationRun>[];
    final pro = ref.watch(proStatusProvider) == ProStatus.unlocked;
    String time(DateTime t) => MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(t));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
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
