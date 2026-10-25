import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../data/repositories/backup_service.dart';
import '../../data/repositories/connection_repo.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../onboarding/first_run.dart';
import 'home_share.dart';

/// Opened by the camera app from another phone's "Share this home" code
/// (zigdash://home/join?c=…, 3.1.7): adds the Home with its login, then
/// takes the dashboards the other phone left on the home broker.
class JoinHomeScreen extends ConsumerStatefulWidget {
  const JoinHomeScreen({super.key, required this.code});

  final String? code;

  /// How long to wait for the shared dashboards.
  static const dashboardsWait = Duration(seconds: 15);

  @override
  ConsumerState<JoinHomeScreen> createState() => _JoinHomeScreenState();
}

class _JoinHomeScreenState extends ConsumerState<JoinHomeScreen> {
  var _joining = false;

  Future<void> _join(HomeInvite invite) async {
    setState(() => _joining = true);
    final analytics = ref.read(analyticsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final id = await ref
        .read(connectionRepoProvider)
        .create(
          name: invite.name,
          host: invite.host,
          port: invite.port,
          protocol: invite.protocol,
          username: invite.username,
          password: invite.password,
          remoteHost: invite.remoteHost,
        );
    analytics.track(const HomeShareEvent(HomeShareStep.joined));
    analytics.track(
      const SetupStep(SetupStepKind.complete, via: SetupVia.shared),
    );
    var imported = false;
    try {
      final mgr = await ref.read(mqttManagerProvider(id).future);
      final topic = invite.dashboardsTopic;
      final msg = await mgr
          .subscribe(topic)
          .firstWhere((m) => m.payload.trim().isNotEmpty)
          .timeout(JoinHomeScreen.dashboardsWait);
      mgr.unsubscribe(topic);
      await ref.read(backupServiceProvider).importToConnection(id, msg.payload);
      imported = true;
    } catch (_) {
      // No dashboards in time (the code was hidden, or the broker is slow):
      // the home is added; its devices are on the Devices tab.
    }
    analytics.track(
      HomeShareEvent(
        imported
            ? HomeShareStep.dashboardsImported
            : HomeShareStep.dashboardsMissing,
      ),
    );
    try {
      await ref.read(firstRunProvider).finish(id);
    } catch (_) {}
    if (!imported) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.joinHomeNoDashboards)),
      );
    }
    if (mounted) context.go(Routes.homeDashboards(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final invite = HomeInvite.fromCode(widget.code);
    final homes = ref.watch(connectionsStreamProvider).valueOrNull;
    final existing = invite == null || homes == null
        ? null
        : sameHome(homes, invite);
    return Scaffold(
      appBar: AppBar(
        // Opened from the camera app, so there may be nothing to go back to.
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.start),
        ),
        title: Text(l10n.joinHomeTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (invite == null)
            Text(l10n.joinHomeInvalid, style: theme.textTheme.bodyLarge)
          else if (homes == null)
            const LinearProgressIndicator()
          else if (existing != null) ...[
            Text(
              l10n.joinHomeAlready(existing.name),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(Routes.homeDashboards(existing.id)),
              child: Text(l10n.joinHomeOpen),
            ),
          ] else ...[
            Text(
              l10n.joinHomeAsk(invite.name),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.joinHomeBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('join-home-add'),
              onPressed: _joining ? null : () => _join(invite),
              child: _joining
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.joinHomeAdd),
            ),
          ],
        ],
      ),
    );
  }
}
