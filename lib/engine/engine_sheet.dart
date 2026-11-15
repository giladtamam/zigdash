import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/analytics/analytics.dart';
import '../core/l10n/l10n_ext.dart';
import '../features/history/history_setup_flow.dart' show allowEngineAndRestart, installEngineOn;
import '../features/settings/providers/settings_controller.dart' show sharedPreferencesProvider;
import 'automation.dart';
import 'automations_repo.dart';
import 'engine_installer.dart';
import 'engine_providers.dart';
import 'engine_setup.dart' show EngineCheck;
import 'engine_status.dart';

/// The Engine when it's needed (3.6.2, docs/design/engine-on-save-362.md):
/// saving an Automation on a hub without ZigDash Engine opens a sheet that
/// says what the Engine is and installs it, or keeps the rule not running.
/// Before any install, rules saved earlier are listed with a switch each,
/// so an old "7:00 heater on" doesn't start by surprise.

/// How saving through the sheet ended; null from the sheet when it was
/// closed without a choice (nothing saved).
class EngineSaveResult {
  const EngineSaveResult({required this.saved, required this.running});

  /// False when the broker wasn't connected.
  final bool saved;

  /// ZigDash Engine runs the rule now.
  final bool running;
}

/// What the sheet can offer for the hub as the check left it.
enum EngineSheetKind {
  /// Not installed, add-ons allowed: Install and save.
  install,

  /// Zigbee2MQTT blocks add-ons: the consent screen comes first.
  consent,

  /// The user said "Not now" to the consent screen on this phone: the
  /// rule is kept, not running; "Allow add-ons after all" is on the tab.
  declined,

  /// Zigbee2MQTT older than 2.4: the rule is kept, not running.
  tooOld,

  /// The hub didn't say: Save only.
  noAnswer,
}

/// Never away: the editor isn't reachable there ([engineAwayWithoutEngine]).
EngineSheetKind engineSheetKind(EngineView? view) => switch (view?.phase) {
      HubEnginePhase.notInstalled => EngineSheetKind.install,
      HubEnginePhase.needsConsent => view!.declined ? EngineSheetKind.declined : EngineSheetKind.consent,
      HubEnginePhase.tooOld => EngineSheetKind.tooOld,
      _ => EngineSheetKind.noAnswer,
    };

/// Away through the relay with no Engine this phone has seen (3.6.2): the
/// relay reaches the hub's broker only through the Engine, so automations
/// are made at home, where ZigDash can put the Engine on the hub.
bool engineAwayWithoutEngine(EngineView? view, {required bool knownInstalled}) =>
    view != null &&
    !view.installed &&
    (view.away || view.phase == HubEnginePhase.unreachable) &&
    !knownInstalled;

/// The Home's rules that wait for the Engine (on the broker).
List<Automation> waitingRules(WidgetRef ref, String connectionId, {List<Automation>? onBroker}) =>
    onBroker ?? ref.read(automationsProvider(connectionId)).valueOrNull ?? const <Automation>[];

/// Keeps the Home's rules coming in while the hub is checked, so they are
/// there when the install asks about them (the retained rules arrive a
/// moment after subscribing).
ProviderSubscription<AsyncValue<List<Automation>>> watchWaitingRules(WidgetRef ref, String connectionId) =>
    ref.listenManual(automationsProvider(connectionId), (_, __) {});

/// Before an install from any path: when rules wait, asks for each whether
/// it runs, saves the paused ones disabled and says whether to go on.
/// True at once when nothing waits.
Future<bool> confirmWaitingRules(BuildContext context, WidgetRef ref, String connectionId, List<Automation> rules) async {
  final waiting = waitingRules(ref, connectionId, onBroker: rules);
  if (waiting.isEmpty) return true;
  if (!context.mounted) return false;
  final go = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => EngineSheet(connectionId: connectionId, waiting: waiting),
  );
  return go ?? false;
}

/// Saving [rule] on a hub without the Engine ([check] as the hub check
/// left it).
Future<EngineSaveResult?> showEngineSaveSheet(
    BuildContext context, WidgetRef ref, String connectionId, Automation rule, EngineCheck check) async {
  final waiting = waitingRules(ref, connectionId).where((r) => r.id != rule.id).toList();
  var saved = false;
  final result = await showModalBottomSheet<EngineSaveResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => EngineSheet(
        connectionId: connectionId, waiting: waiting, rule: rule, view: check.view, onSaved: () => saved = true),
  );
  // Swiped away once the rule was saved: it is kept, not running.
  return result ?? (saved ? const EngineSaveResult(saved: true, running: false) : null);
}

/// The sheet. With [rule] it saves (pops an [EngineSaveResult]); without,
/// it only asks before an install and pops true to go on.
class EngineSheet extends ConsumerStatefulWidget {
  const EngineSheet(
      {super.key, required this.connectionId, required this.waiting, this.rule, this.view, this.onSaved});

  final String connectionId;
  final List<Automation> waiting;
  final Automation? rule;
  final EngineView? view;

  /// The rule was saved (whatever happens to the install after).
  final VoidCallback? onSaved;

  @override
  ConsumerState<EngineSheet> createState() => _EngineSheetState();
}

enum _Stage { offer, consent, restarting, installing, failed }

class _EngineSheetState extends ConsumerState<EngineSheet> {
  _Stage _stage = _Stage.offer;
  String? _error;

  /// Each waiting rule's switch: run, or keep paused.
  late final Map<String, bool> _run = {for (final r in widget.waiting) r.id: r.enabled};

  EngineSheetKind get _kind => widget.rule == null ? EngineSheetKind.install : engineSheetKind(widget.view);
  AutomationsRepo get _repo => ref.read(automationsRepoProvider);
  String? get _z2m => widget.view?.hub?.version;

  void _track(EngineStep step) =>
      ref.read(analyticsProvider).track(EngineEvent(step, z2m: _z2m, from: EngineFrom.save));

  /// Paused rules are saved disabled before the Engine loads them. False
  /// when the sheet went away meanwhile.
  Future<bool> _applySwitches() async {
    final repo = _repo;
    for (final r in widget.waiting) {
      final run = _run[r.id] ?? r.enabled;
      if (run != r.enabled) await repo.save(widget.connectionId, r.copyWith(enabled: run));
      if (!mounted) return false;
    }
    return true;
  }

  /// Save without running (and the declined, too-old and no-answer Save).
  Future<void> _saveOnly() async {
    final ok = await _repo.save(widget.connectionId, widget.rule!);
    if (ok) widget.onSaved?.call();
    if (mounted) Navigator.of(context).pop(EngineSaveResult(saved: ok, running: false));
  }

  Future<void> _installTapped() async {
    if (widget.rule == null) {
      if (await _applySwitches() && mounted) Navigator.of(context).pop(true);
      return;
    }
    _track(EngineStep.installTapped);
    final repo = _repo;
    setState(() => _stage = _Stage.installing);
    if (!await _applySwitches()) return;
    final ok = await repo.save(widget.connectionId, widget.rule!);
    if (ok) widget.onSaved?.call();
    if (!mounted) return;
    if (!ok) return Navigator.of(context).pop(const EngineSaveResult(saved: false, running: false));
    if (_kind == EngineSheetKind.consent) {
      setState(() => _stage = _Stage.consent);
      return;
    }
    await _install();
  }

  Future<void> _install() async {
    final l10n = context.l10n;
    setState(() => _stage = _Stage.installing);
    HubAnswer answer;
    String? error;
    try {
      (answer, error) = await installEngineOn(ref, widget.connectionId, from: EngineFrom.save, z2m: _z2m);
    } catch (_) {
      answer = HubAnswer.noAnswer;
    }
    if (!mounted) return;
    if (answer == HubAnswer.ok) {
      Navigator.of(context).pop(const EngineSaveResult(saved: true, running: true));
      return;
    }
    setState(() {
      _stage = _Stage.failed;
      _error = answer == HubAnswer.refused ? l10n.engineInstallRefused(error ?? '') : l10n.engineInstallNoAnswer;
    });
  }

  Future<void> _consent() async {
    final l10n = context.l10n;
    setState(() => _stage = _Stage.restarting);
    HubAnswer answer;
    try {
      answer = await allowEngineAndRestart(ref, widget.connectionId, from: EngineFrom.save);
    } catch (_) {
      answer = HubAnswer.noAnswer;
    }
    if (!mounted) return;
    if (answer != HubAnswer.ok) {
      ref.read(analyticsProvider).track(EngineEvent(EngineStep.failed,
          z2m: _z2m, from: EngineFrom.save, why: answer == HubAnswer.refused ? EngineWhy.refused : EngineWhy.blocked));
      setState(() {
        _stage = _Stage.failed;
        _error = l10n.engineConsentFailed;
      });
      return;
    }
    await _install();
  }

  /// "Not now" on the consent screen: the rule is kept, not running.
  Future<void> _decline() async {
    _track(EngineStep.declined);
    await setEngineDeclined(ref.read(sharedPreferencesProvider), widget.connectionId, true);
    if (!mounted) return;
    ref.invalidate(engineViewProvider(widget.connectionId));
    Navigator.of(context).pop(const EngineSaveResult(saved: true, running: false));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final working = _stage == _Stage.restarting || _stage == _Stage.installing;
    final saving = widget.rule != null;

    final List<Widget> children;
    switch (_stage) {
      case _Stage.restarting:
      case _Stage.installing:
        children = [
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          Text(_stage == _Stage.restarting ? l10n.engineRestarting : l10n.engineInstalling,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
        ];
      case _Stage.failed:
        children = [
          Text(_error ?? l10n.engineInstallNoAnswer, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          Text(l10n.engineSheetSavedNotRunning),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('engine-sheet-ok'),
            onPressed: () => Navigator.of(context).pop(const EngineSaveResult(saved: true, running: false)),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ];
      case _Stage.consent:
        children = [
          Text(l10n.engineConsentTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.engineConsentBody),
          const SizedBox(height: 8),
          Text(l10n.engineConsentOutage),
          const SizedBox(height: 16),
          FilledButton(key: const Key('engine-sheet-consent'), onPressed: _consent, child: Text(l10n.engineConsentYes)),
          TextButton(key: const Key('engine-sheet-decline'), onPressed: _decline, child: Text(l10n.engineConsentNo)),
        ];
      case _Stage.offer:
        children = switch (_kind) {
          EngineSheetKind.install || EngineSheetKind.consent => [
              Text(l10n.engineSheetTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.engineSheetBody),
              const EngineSourceLink(),
              if (widget.waiting.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.engineWaitingTitle, style: theme.textTheme.titleSmall),
                for (final r in widget.waiting)
                  SwitchListTile(
                    key: Key('engine-waiting-${r.id}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(r.name),
                    subtitle: Text((_run[r.id] ?? r.enabled) ? l10n.engineWaitingRun : l10n.engineWaitingPaused),
                    value: _run[r.id] ?? r.enabled,
                    onChanged: (on) => setState(() => _run[r.id] = on),
                  ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('engine-sheet-install'),
                onPressed: _installTapped,
                child: Text(saving ? l10n.engineSheetInstallSave : l10n.engineInstall),
              ),
              TextButton(
                key: const Key('engine-sheet-save'),
                onPressed: saving ? _saveOnly : () => Navigator.of(context).pop(false),
                child: Text(saving ? l10n.engineSheetSaveOnly : l10n.engineConsentNo),
              ),
            ],
          EngineSheetKind.tooOld => [
              Text(l10n.engineTooOldTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.engineTooOldBody(_z2m ?? '?')),
              const SizedBox(height: 16),
              FilledButton(
                  key: const Key('engine-sheet-save'), onPressed: _saveOnly, child: Text(l10n.engineSheetSaveOnly)),
            ],
          EngineSheetKind.declined => [
              Text(l10n.engineDeclinedTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.engineDeclinedBody),
              const SizedBox(height: 16),
              FilledButton(
                  key: const Key('engine-sheet-save'), onPressed: _saveOnly, child: Text(l10n.engineSheetSaveOnly)),
            ],
          EngineSheetKind.noAnswer => [
              Text(l10n.engineSheetTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.engineSheetNoAnswer),
              const SizedBox(height: 16),
              FilledButton(
                  key: const Key('engine-sheet-save'), onPressed: _saveOnly, child: Text(l10n.engineSheetSave)),
            ],
        };
    }
    return PopScope(
      // Installing or restarting Zigbee2MQTT: the sheet stays until it ends.
      canPop: !working && _stage != _Stage.consent,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// "See its source on GitHub", at the release this app's Engine ships in.
class EngineSourceLink extends StatelessWidget {
  const EngineSourceLink({super.key});

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: const Key('engine-source'),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => launchUrl(engineSourceUrl, mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.code, size: 18),
          label: Text(context.l10n.engineSheetSource),
        ),
      );
}
