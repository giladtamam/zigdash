import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../data/database/tables/connections.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../engine/engine_providers.dart' show setEngineDeclined;
import '../../history/app_history_recorder.dart' show historyRecordHereProvider;
import '../../history/history_service.dart' show historyRecorderOnlineProvider;
import '../../history/history_setup_flow.dart';
import '../../onboarding/demo_service.dart' show isDemoConnection;
import '../../onboarding/setup/setup_completed_at.dart'
    show kSetupCompletedAtMs;
import '../../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../../../engine/engine_installer.dart' show HubAnswer;

/// "1" once the Home's History card was answered (on, this phone, Not now
/// or declined): it asks once per Home.
String historyOnDoneKey(String connectionId) => 'history_on_done_$connectionId';

/// "1" once `history_on shown` was sent for the Home.
String historyOnShownKey(String connectionId) =>
    'history_on_shown_$connectionId';

/// How long after setup the card counts as "right after setup".
const historyOnFinishWindow = Duration(minutes: 30);

/// How long the card waits for a recorder's heartbeat before deciding the
/// Home has none (the heartbeat is retained, so it comes at once if it
/// exists).
const historyOnGrace = Duration(seconds: 4);

/// Whether the History card still waits for an answer on [connectionId]
/// (other one-time cards wait for it: cards never stack).
/// A Home that already records (or the demo) never waits.
bool historyOnPending(WidgetRef ref, String connectionId) {
  final prefs = ref.watch(sharedPreferencesProvider);
  if (prefs.getString(historyOnDoneKey(connectionId)) != null) return false;
  if (ref.watch(historyRecordHereProvider(connectionId))) return false;
  final home = ref.watch(connectionByIdProvider(connectionId)).valueOrNull;
  if (home == null || isDemoConnection(home.host)) return false;
  if (transportOf(home.transport) == ConnectionTransport.z2mPage) return true;
  return ref.watch(historyRecorderOnlineProvider(connectionId)).valueOrNull !=
      true;
}

/// "Turn on History" (3.6, docs/design/pro-trial-360.md §2): the first-week
/// step. Right after setup, and once later for a Home without a recorder,
/// it puts ZigDash Engine on the hub (asking first when Zigbee2MQTT blocks
/// add-ons), offers this phone when the hub can't, and asks for the
/// broker when the Home is reached through Zigbee2MQTT's page.
class HistoryOnCard extends ConsumerStatefulWidget {
  const HistoryOnCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<HistoryOnCard> createState() => _HistoryOnCardState();
}

enum _Stage { offer, working, consent, broker, phone, done }

class _HistoryOnCardState extends ConsumerState<HistoryOnCard> {
  _Stage _stage = _Stage.offer;
  bool _graceOver = false;
  bool _closed = false;
  bool _consentFailed = false;
  Timer? _grace;
  late final HistorySetupFrom _from;

  @override
  void initState() {
    super.initState();
    final at = ref.read(sharedPreferencesProvider).getInt(kSetupCompletedAtMs);
    final recent =
        at != null &&
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(at)) <
            historyOnFinishWindow;
    _from = recent ? HistorySetupFrom.finish : HistorySetupFrom.card;
    _grace = Timer(historyOnGrace, () {
      if (mounted) setState(() => _graceOver = true);
    });
  }

  @override
  void dispose() {
    _grace?.cancel();
    super.dispose();
  }

  void _track(HistoryOnStep step) =>
      ref.read(analyticsProvider).track(HistoryOnEvent(step, _from));

  Future<void> _finish() async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(historyOnDoneKey(widget.connectionId), '1');
  }

  Future<void> _close() async {
    setState(() => _closed = true);
    await _finish();
  }

  Future<void> _later() async {
    _track(HistoryOnStep.later);
    await _close();
  }

  void _shown() {
    final prefs = ref.read(sharedPreferencesProvider);
    final key = historyOnShownKey(widget.connectionId);
    if (prefs.getString(key) != null) return;
    prefs.setString(key, '1');
    _track(HistoryOnStep.shown);
  }

  Future<void> _turnOn() async {
    _track(HistoryOnStep.tapped);
    setState(() => _stage = _Stage.working);
    final result = await turnOnHistory(ref, widget.connectionId, from: _from);
    if (!mounted) return;
    _show(result);
  }

  void _show(HistoryOn result) {
    switch (result) {
      case HistoryOn.on:
        _finish();
        setState(() => _stage = _Stage.done);
      case HistoryOn.needsConsent:
        _track(HistoryOnStep.consentShown);
        setState(() => _stage = _Stage.consent);
      case HistoryOn.needsBroker:
        setState(() => _stage = _Stage.broker);
      case HistoryOn.phoneInstead:
        setState(() => _stage = _Stage.phone);
    }
  }

  Future<void> _allow() async {
    setState(() {
      _stage = _Stage.working;
      _consentFailed = false;
    });
    HubAnswer answer;
    try {
      answer = await allowEngineAndRestart(
        ref,
        widget.connectionId,
        from: EngineFrom.historyOn,
      );
    } catch (_) {
      answer = HubAnswer.noAnswer;
    }
    if (!mounted) return;
    if (answer != HubAnswer.ok) {
      setState(() {
        _stage = _Stage.consent;
        _consentFailed = true;
      });
      return;
    }
    final result = await installThenPublish(
      ref,
      widget.connectionId,
      from: _from,
    );
    if (mounted) _show(result);
  }

  Future<void> _decline() async {
    _track(HistoryOnStep.declined);
    ref
        .read(analyticsProvider)
        .track(
          const EngineEvent(EngineStep.declined, from: EngineFrom.historyOn),
        );
    await setEngineDeclined(
      ref.read(sharedPreferencesProvider),
      widget.connectionId,
      true,
    );
    await _close();
  }

  Future<void> _phone() async {
    _track(HistoryOnStep.phone);
    await recordOnThisPhone(ref, widget.connectionId, from: _from);
    await _finish();
    if (mounted) setState(() => _stage = _Stage.done);
  }

  void _broker() {
    _track(HistoryOnStep.broker);
    context.push(Routes.homeAutomations(widget.connectionId));
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final consent = ref.watch(analyticsConsentProvider);
    final available = ref.watch(analyticsAvailableProvider);
    final home = ref
        .watch(connectionByIdProvider(widget.connectionId))
        .valueOrNull;
    final viaPage = transportOf(home?.transport) == ConnectionTransport.z2mPage;
    final online = viaPage
        ? false
        : ref
              .watch(historyRecorderOnlineProvider(widget.connectionId))
              .valueOrNull;
    final answered =
        prefs.getString(historyOnDoneKey(widget.connectionId)) != null;
    // The finished state stays until closed, though the Home is now done.
    final showing = _stage != _Stage.offer;
    if (_closed ||
        home == null ||
        isDemoConnection(home.host) ||
        (!showing && answered) ||
        (!showing &&
            ref.watch(historyRecordHereProvider(widget.connectionId))) ||
        (!showing && online == true) ||
        (!showing && !_graceOver) ||
        // The usage-data question comes first; the cards don't stack.
        (available && consent == AnalyticsConsent.unasked)) {
      return const SizedBox.shrink();
    }
    if (_stage == _Stage.offer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _shown();
      });
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget text(String s) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8, bottom: 8),
      child: Text(s, style: theme.textTheme.bodyMedium),
    );
    Widget buttons(List<Widget> children) => Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Wrap(alignment: WrapAlignment.end, spacing: 8, children: children),
    );

    final body = <Widget>[
      Text(l10n.historyOnTitle, style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
      ...switch (_stage) {
        _Stage.offer => [
          text(l10n.historyOnBody),
          buttons([
            TextButton(
              key: const Key('history-on-later'),
              onPressed: _later,
              child: Text(l10n.historyOnLater),
            ),
            FilledButton(
              key: const Key('history-on-turn-on'),
              onPressed: _turnOn,
              child: Text(l10n.historyOnTurnOn),
            ),
          ]),
        ],
        _Stage.working => [
          Row(
            children: [
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.historyOnWorking)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        _Stage.consent => [
          text(l10n.historyOnConsentBody),
          text(l10n.engineConsentOutage),
          if (_consentFailed) text(l10n.engineConsentFailed),
          buttons([
            TextButton(
              key: const Key('history-on-decline'),
              onPressed: _decline,
              child: Text(l10n.historyOnLater),
            ),
            FilledButton(
              key: const Key('history-on-allow'),
              onPressed: _allow,
              child: Text(l10n.historyOnAllow),
            ),
          ]),
        ],
        _Stage.broker => [
          text(l10n.historyOnBrokerBody),
          buttons([
            TextButton(onPressed: _later, child: Text(l10n.historyOnLater)),
            FilledButton(
              key: const Key('history-on-broker'),
              onPressed: _broker,
              child: Text(l10n.historyOnAddBroker),
            ),
          ]),
        ],
        _Stage.phone => [
          text(l10n.historyOnPhoneBody),
          buttons([
            TextButton(onPressed: _later, child: Text(l10n.historyOnLater)),
            FilledButton(
              key: const Key('history-on-phone'),
              onPressed: _phone,
              child: Text(l10n.historyOnPhone),
            ),
          ]),
        ],
        _Stage.done => [
          text(
            ref.watch(historyRecordHereProvider(widget.connectionId))
                ? l10n.historyRecordingHere
                : l10n.historyInstalled,
          ),
          buttons([
            TextButton(
              key: const Key('history-on-close'),
              onPressed: () => setState(() => _closed = true),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ]),
        ],
      },
    ];
    return Card(
      key: const Key('history-on-card'),
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: body,
        ),
      ),
    );
  }
}
