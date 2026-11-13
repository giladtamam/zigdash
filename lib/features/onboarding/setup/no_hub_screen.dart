import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../first_run.dart';
import 'setup_reminder.dart';
import 'setup_screen.dart' show hubsPageUrl, openSetupLink;

/// Zigbee2MQTT's own installation guide, for a Raspberry Pi or any Linux
/// box.
final z2mInstallUrl = Uri.parse('https://www.zigbee2mqtt.io/guide/installation/');

/// ZigDash with Home Assistant: the add-ons, then the sign-in.
final haGuideUrl = Uri.parse('https://zigdash.app/home-assistant/');

/// "Nothing yet" (3.4): what to get when no hub runs Zigbee2MQTT. Until
/// 3.3 this was a browser link off the first screen; 441 of 461 empty
/// scans in October saw no hub at all, and "not yet" outnumbered "yes" two
/// to one when the guide asked whether Zigbee2MQTT runs. The screen keeps
/// those people in the app: the three ways to a hub, the demo, and a
/// reminder for a week later, when the hub has arrived.
class NoHubScreen extends ConsumerStatefulWidget {
  const NoHubScreen({super.key, required this.from});

  /// Where it was opened from: the first question or the guide.
  final NoHubFrom from;

  @override
  ConsumerState<NoHubScreen> createState() => _NoHubScreenState();
}

class _NoHubScreenState extends ConsumerState<NoHubScreen> {
  @override
  void initState() {
    super.initState();
    _track(NoHubAction.opened);
  }

  void _track(NoHubAction action) => ref
      .read(analyticsProvider)
      .track(
        SetupStep(SetupStepKind.noHub, choice: widget.from, result: action),
      );

  Future<void> _open(NoHubAction action, Uri url) async {
    _track(action);
    try {
      await openSetupLink(url);
    } catch (_) {}
  }

  Future<void> _demo() async {
    _track(NoHubAction.demo);
    final id = await ref.read(firstRunProvider).startDemo();
    if (mounted) context.go(Routes.homeDashboards(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget way({
      required Key key,
      required IconData icon,
      required String title,
      required String body,
      required NoHubAction action,
      required Uri url,
    }) => Card.outlined(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(body),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => _open(action, url),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.noHubTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.noHubHeadline, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(l10n.noHubIntro, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 20),
            way(
              key: const Key('no-hub-smhub'),
              icon: Icons.router_outlined,
              title: l10n.noHubSmhub,
              body: l10n.noHubSmhubBody,
              action: NoHubAction.smhub,
              url: hubsPageUrl,
            ),
            way(
              key: const Key('no-hub-pi'),
              icon: Icons.memory,
              title: l10n.noHubPi,
              body: l10n.noHubPiBody,
              action: NoHubAction.pi,
              url: z2mInstallUrl,
            ),
            way(
              key: const Key('no-hub-ha'),
              icon: Icons.home_outlined,
              title: l10n.noHubHa,
              body: l10n.noHubHaBody,
              action: NoHubAction.homeAssistant,
              url: haGuideUrl,
            ),
            const SizedBox(height: 4),
            Text(l10n.noHubRadio, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('no-hub-demo'),
              onPressed: _demo,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(l10n.setupWelcomeDemo),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noHubDemoNote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Center(
              child: RemindMeLater(
                key: const Key('no-hub-remind'),
                kind: ReminderKind.hub,
                onTapped: () => _track(NoHubAction.remind),
              ),
            ),
            TextButton.icon(
              key: const Key('no-hub-have-one'),
              onPressed: () {
                _track(NoHubAction.haveOne);
                context.pop();
              },
              icon: const Icon(Icons.check),
              label: Text(l10n.noHubHaveOne),
            ),
            TextButton(
              key: const Key('no-hub-hubs-page'),
              onPressed: () => _open(NoHubAction.hubsPage, hubsPageUrl),
              child: Text(l10n.setupWelcomeHubs),
            ),
          ],
        ),
      ),
    );
  }
}
