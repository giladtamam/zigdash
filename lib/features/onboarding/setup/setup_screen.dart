import 'package:flutter/material.dart';

import '../../../core/net/mdns_lookup.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shortcuts/shortcut_service.dart' show appChannel;
import '../../connections/discovery/address_check.dart';
import '../../connections/discovery/hub_probe.dart';
import '../../connections/discovery/no_network.dart';
import '../../panels/widgets/device_tile_panel.dart' show ltr;
import '../../settings/screens/settings_screen.dart' show privacyPolicyUrl;
import '../../support/community.dart' show CommunityLink;
import '../../support/get_help_screen.dart' show GetHelpLink;
import '../first_run.dart';
import 'recommendation_policy.dart';
import 'setup_candidate.dart';
import 'setup_coordinator.dart';
import 'setup_error_guidance.dart';
import 'ai_help.dart';
import 'setup_analytics.dart';
import 'setup_providers.dart';
import 'setup_waiting.dart';
import 'setup_reminder.dart';

/// zigdash.app's Hubs page: the small hubs that run Zigbee2MQTT, for the
/// empty result's "I don't have a hub yet" (2.9.6).
final hubsPageUrl = Uri.parse('https://zigdash.app/hubs/');

/// Opens a link outside the app; replaced in tests.
@visibleForTesting
Future<bool> Function(Uri url) openSetupLink = (url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

/// The usual names of a machine running Zigbee2MQTT and its broker, offered
/// under "My hub is on another network" (2.9.6): an SMHUB's own name
/// (SMLIGHT's SMHUB Nano guide), Home Assistant's, and Raspberry Pi OS's
/// default. No SLZB-06: it is only the Zigbee radio and has no broker.
const usualHubNames = [
  'smhub.local',
  'homeassistant.local',
  'raspberrypi.local',
];

/// The discovery-first onboarding flow: renders [SetupCoordinator] state and
/// forwards user intents. No network work or persistence happens here.
class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(setupStateProvider);
    final coordinator = ref.watch(setupCoordinatorProvider);
    final state = asyncState.valueOrNull ?? coordinator.state;
    final l10n = context.l10n;

    // No "ready" screen: a finished setup opens its dashboard directly.
    ref.listen(setupStateProvider, (previous, next) {
      final s = next.valueOrNull;
      if (s == null) return;
      final before = previous?.valueOrNull;
      // 2.10.2: leaving the list by starting over is counted on its own;
      // the step that follows (started, say) is counted as usual.
      if (before is SetupReview &&
          s is! SetupReview &&
          s is! SetupCreating &&
          s is! SetupComplete) {
        ref.read(analyticsProvider).track(reviewLeftStep(before, coordinator));
      }
      final step = setupStepFor(
        previous?.valueOrNull,
        s,
        platform: coordinator.platform,
        aiHelped: ref.read(aiHelpUsedProvider),
      );
      if (step != null) ref.read(analyticsProvider).track(step);
      if (s is SetupComplete) {
        // 3.1.5: the next setup starts without "Ask your AI" behind it.
        ref.read(aiHelpUsedProvider.notifier).state = false;
        ref.read(setupReminderProvider).cancel();
        context.go(Routes.homeDashboards(s.result.connectionId));
      }
    });

    void manual() {
      ref.read(analyticsProvider).track(const SetupStep(SetupStepKind.manual));
      context.push(Routes.guidedConnect);
    }

    // Manual entry filled in with a hub the scan found (2.5).
    void manualTo(HubFound hub) {
      ref.read(analyticsProvider).track(const SetupStep(SetupStepKind.manual));
      context.push(Routes.guidedConnectTo(hub.host, 1883));
    }

    // 2.10.4: manual entry with the port Zigbee2MQTT's page named, the
    // address left for the user (the page named a host only it knows).
    void manualPort(int port) {
      ref.read(analyticsProvider).track(const SetupStep(SetupStepKind.manual));
      context.push(Routes.guidedConnectTo('', port));
    }

    // 2.9.6: a choice on the empty result, counted before it acts.
    void emptyChoice(ScanEmptyChoice choice) => ref
        .read(analyticsProvider)
        .track(
          SetupStep(
            SetupStepKind.emptyChoice,
            choice: choice,
            platform: coordinator.platform,
          ),
        );

    Future<void> tryDemo({SetupStepKind kind = SetupStepKind.demo}) async {
      ref.read(analyticsProvider).track(SetupStep(kind));
      final id = await ref.read(firstRunProvider).startDemo();
      if (context.mounted) context.go(Routes.homeDashboards(id));
    }

    // 2.9.7: no Zigbee2MQTT yet, so no point scanning.
    // Every answer is counted when picked (3.1.3): someone who says ZHA
    // often leaves before any later step would carry it.
    void choosePlatform(SetupPlatform? platform) {
      if (platform != null) {
        ref
            .read(analyticsProvider)
            .track(SetupStep(SetupStepKind.platformChosen, platform: platform));
      }
      coordinator.setPlatform(platform);
    }

    // Which way into the Home Assistant sign-in people take (3.1.3).
    void viaHa(String? host, HaSignInFrom from) {
      ref
          .read(analyticsProvider)
          .track(SetupStep(SetupStepKind.haOpened, choice: from));
      context.push(Routes.haConnectAt(host));
    }

    Future<void> welcomeHubs() async {
      ref
          .read(analyticsProvider)
          .track(const SetupStep(SetupStepKind.welcomeHubs));
      try {
        await openSetupLink(hubsPageUrl);
      } catch (_) {}
    }

    // 3.1.4: on first run setup is the only page, so back closed the app
    // from the middle of setup. It now starts setup over instead.
    final midway =
        state is! SetupIdle &&
        state is! SetupCreating &&
        state is! SetupComplete;
    return PopScope(
      // 3.1.6: back on the device list asks first. A third of the people
      // who reached it left without the one tap that finishes setup.
      canPop: state is! SetupReview && (!midway || Navigator.canPop(context)),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (state is SetupReview) {
          _askBeforeLeavingReview(context, ref, state, coordinator);
        } else {
          coordinator.cancel();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.setupWelcomeTitle)),
        body: SafeArea(
          child: switch (state) {
            SetupIdle() => _Welcome(
              onFind: coordinator.startScan,
              onPlatform: (p) {
                coordinator.answeredFirst = true;
                choosePlatform(p);
              },
              onHa: () => viaHa(null, HaSignInFrom.welcome),
              onZ2mPage: () => _askZ2mPage(context, coordinator),
              onManual: manual,
              onDemo: () => tryDemo(kind: SetupStepKind.welcomeDemo),
              onHubs: welcomeHubs,
            ),
            SetupScanning() => _Scanning(
              state: state,
              askPlatform: !coordinator.answeredFirst,
              onSelect: coordinator.selectCandidate,
              onPlatform: choosePlatform,
              onManual: manual,
              onDemo: tryDemo,
              onConnectViaHa: viaHa,
            ),
            SetupScanEmpty() => _ScanEmpty(
              state: state,
              onZ2mPage: () => _askZ2mPage(context, coordinator),
              onWiden: () => coordinator.startScan(widen: true),
              onRetry: coordinator.retry,
              onPlatform: choosePlatform,
              onCheckAddress: coordinator.checkAddress,
              onChoice: emptyChoice,
              onManual: manual,
              onManualTo: manualTo,
              onManualPort: manualPort,
              onDemo: tryDemo,
              onConnectViaHa: viaHa,
            ),
            SetupVerifying() => SetupWaiting(
              title: l10n.setupVerifyingTitle,
              onCancel: coordinator.cancel,
            ),
            SetupNeedsAuth() => _AuthPrompt(
              state: state,
              onSubmit: coordinator.submitCredentials,
              onDemo: tryDemo,
              onConnectViaHa: viaHa,
            ),
            SetupFailed(kind: SetupErrorKind.notZigbee2Mqtt) => _NoZigbee2Mqtt(
              base: coordinator.base,
              onRetry: coordinator.retryWithBase,
              onDemo: tryDemo,
              onManual: manual,
            ),
            SetupFailed(kind: SetupErrorKind.scanFailed) => _NoNetwork(
              state: state,
              onManual: manual,
              onHa: () {
                ref
                    .read(analyticsProvider)
                    .track(
                      const SetupStep(
                        SetupStepKind.haOpened,
                        choice: HaSignInFrom.noWifi,
                      ),
                    );
                context.push(Routes.haConnectOffWifi);
              },
            ),
            SetupFailed() => _Failure(
              state: state,
              onRetry: coordinator.retry,
              onManual: manual,
            ),
            SetupReview() => _Review(
              state: state,
              onToggle: coordinator.toggleDevice,
              onCreate: coordinator.createDashboard,
            ),
            SetupCreating() => _Review(
              state: state.review,
              busy: true,
              onToggle: (_) {},
              onCreate: () {},
            ),
            // Navigation to the dashboard is under way (see ref.listen above).
            SetupComplete() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

/// Maps a guidance key from [SetupGuidance] to its localized string.
String _guidanceText(AppLocalizations l10n, String key) => switch (key) {
  'setupErrUnreachableTitle' => l10n.setupErrUnreachableTitle,
  'setupErrUnreachableBody' => l10n.setupErrUnreachableBody,
  'setupErrUnreachableAction' => l10n.setupErrUnreachableAction,
  'setupErrPortClosedTitle' => l10n.setupErrPortClosedTitle,
  'setupErrPortClosedBody' => l10n.setupErrPortClosedBody,
  'setupErrPortClosedAction' => l10n.setupErrPortClosedAction,
  'setupErrAuthRequiredTitle' => l10n.setupErrAuthRequiredTitle,
  'setupErrAuthRequiredBody' => l10n.setupErrAuthRequiredBody,
  'setupErrAuthRequiredAction' => l10n.setupErrAuthRequiredAction,
  'setupErrAuthRejectedTitle' => l10n.setupErrAuthRejectedTitle,
  'setupErrAuthRejectedBody' => l10n.setupErrAuthRejectedBody,
  'setupErrAuthRejectedAction' => l10n.setupErrAuthRejectedAction,
  'setupErrNotZ2mTitle' => l10n.setupErrNotZ2mTitle,
  'setupErrNotZ2mBody' => l10n.setupErrNotZ2mBody,
  'setupErrNotZ2mAction' => l10n.setupErrNotZ2mAction,
  'setupErrListMissingTitle' => l10n.setupErrListMissingTitle,
  'setupErrListMissingBody' => l10n.setupErrListMissingBody,
  'setupErrListMissingAction' => l10n.setupErrListMissingAction,
  'setupErrPageTitle' => l10n.setupErrPageTitle,
  'setupErrPageBody' => l10n.setupErrPageBody,
  'setupErrPageAction' => l10n.setupErrPageAction,
  'setupErrHaNoZ2mTitle' => l10n.setupErrHaNoZ2mTitle,
  'setupErrHaNoZ2mBody' => l10n.setupErrHaNoZ2mBody,
  'setupErrHaNoZ2mAction' => l10n.setupErrHaNoZ2mAction,
  'setupErrNoDevicesTitle' => l10n.setupErrNoDevicesTitle,
  'setupErrNoDevicesBody' => l10n.setupErrNoDevicesBody,
  'setupErrNoDevicesAction' => l10n.setupErrNoDevicesAction,
  'setupErrScanFailedTitle' => l10n.setupErrScanFailedTitle,
  'setupErrScanFailedBody' => l10n.setupErrScanFailedBody,
  'setupErrScanFailedAction' => l10n.setupErrScanFailedAction,
  'setupErrSaveFailedTitle' => l10n.setupErrSaveFailedTitle,
  'setupErrSaveFailedBody' => l10n.setupErrSaveFailedBody,
  'setupErrSaveFailedAction' => l10n.setupErrSaveFailedAction,
  'setupErrLoginNoAnswerTitle' => l10n.setupErrLoginNoAnswerTitle,
  'setupErrLoginNoAnswerBody' => l10n.setupErrLoginNoAnswerBody,
  'setupErrLoginNoAnswerAction' => l10n.setupErrLoginNoAnswerAction,
  // Missing until 2.8.2: the unknown screen read "Try again" three times.
  'setupErrUnknownTitle' => l10n.setupErrUnknownTitle,
  'setupErrUnknownBody' => l10n.setupErrUnknownBody,
  _ => l10n.setupErrUnknownAction,
};

/// The first setup screen. With an analytics key in the build and no choice
/// made yet, it carries the one usage-data question for new installs: a box
/// ticked by default (ADR 0007), recorded either way when the user moves on.
class _Welcome extends ConsumerStatefulWidget {
  const _Welcome({
    required this.onFind,
    required this.onPlatform,
    required this.onHa,
    this.onZ2mPage,
    required this.onManual,
    required this.onDemo,
    required this.onHubs,
  });
  final VoidCallback onFind;
  final VoidCallback onManual;

  /// 3.2: connect through Zigbee2MQTT's web page, no broker.
  final VoidCallback? onZ2mPage;

  /// 3.2: the answer to "What runs your Zigbee?", before any scan.
  final ValueChanged<SetupPlatform?> onPlatform;

  /// 3.2: Home Assistant with the Zigbee2MQTT add-on: its sign-in.
  final VoidCallback onHa;

  /// "No Zigbee2MQTT yet?": nothing to scan for, so the demo home or which
  /// hub to get (2.9.7).
  final VoidCallback onDemo;
  final VoidCallback onHubs;

  @override
  ConsumerState<_Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends ConsumerState<_Welcome> {
  bool _share = true;

  @override
  void initState() {
    super.initState();
    // Counted only here: the reminder opens the app on this screen.
    ref.read(setupReminderProvider).openedFromReminder().then((yes) {
      if (yes && mounted) {
        ref
            .read(analyticsProvider)
            .track(const SetupStep(SetupStepKind.reminderOpened));
      }
    });
  }

  bool get _asking =>
      ref.watch(analyticsAvailableProvider) &&
      ref.watch(analyticsConsentProvider) == AnalyticsConsent.unasked;

  Future<void> _then(VoidCallback next) async {
    if (_asking) {
      await ref.read(analyticsConsentProvider.notifier).set(_share);
    }
    next();
  }

  /// 3.2: Home Assistant runs Zigbee one of two ways; only one works here.
  Future<void> _homeAssistant() async {
    final l10n = context.l10n;
    final pick = await showModalBottomSheet<SetupPlatform>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l10n.setupAskHaWhich, style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.extension_outlined),
              title: Text(l10n.setupAskHaZ2m),
              subtitle: Text(l10n.setupAskHaZ2mSub),
              onTap: () => Navigator.pop(context, SetupPlatform.homeAssistant),
            ),
            ListTile(
              leading: const Icon(Icons.hub_outlined),
              title: Text(l10n.setupAskHaZha),
              subtitle: Text(l10n.setupAskHaZhaSub),
              onTap: () => Navigator.pop(context, SetupPlatform.zha),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (pick == null || !mounted) return;
    widget.onPlatform(pick);
    if (pick == SetupPlatform.homeAssistant) {
      widget.onHa();
      return;
    }
    // ZHA: said plainly, with the demo; no scan for what can't be shown.
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.setupZhaNote),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDemo();
            },
            child: Text(l10n.setupWelcomeDemo),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    void find(SetupPlatform platform) => _then(() {
      widget.onPlatform(platform);
      widget.onFind();
    });
    void onManual() => _then(widget.onManual);
    void onDemo() => _then(widget.onDemo);
    void onHubs() => _then(widget.onHubs);
    Widget answer(IconData icon, String title, String subtitle, VoidCallback onTap, {Key? key}) => Card.outlined(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.setupWelcomeHeadline,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        // 3.2: one question first. Two thirds of setups never answered it
        // under a running scan, and half of them had something to connect.
        Text(l10n.setupAsk, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        answer(Icons.memory, l10n.setupAskZ2m, l10n.setupAskZ2mSub, () => find(SetupPlatform.piOrDocker),
            key: const Key('ask-z2m')),
        answer(Icons.home_outlined, l10n.setupAskHa, l10n.setupAskHaSub, () => _then(_homeAssistant),
            key: const Key('ask-ha')),
        answer(Icons.router_outlined, l10n.setupAskSmlight, l10n.setupAskSmlightSub, () => find(SetupPlatform.smlight),
            key: const Key('ask-smlight')),
        // Not sure: the plain scan, as before 3.2 (23 "not sure" answers
        // in 17 days).
        TextButton.icon(
          onPressed: () => _then(widget.onFind),
          icon: const Icon(Icons.wifi_find),
          label: Text(l10n.setupFindMySetup),
        ),
        const SizedBox(height: 8),
        Text(l10n.setupAskNothing, textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: onDemo,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(l10n.setupWelcomeDemo),
            ),
            TextButton.icon(
              onPressed: onHubs,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(l10n.setupWelcomeHubs),
            ),
          ],
        ),
        const Divider(height: 32),
        if (widget.onZ2mPage != null)
          TextButton.icon(
            onPressed: () => _then(widget.onZ2mPage!),
            icon: const Icon(Icons.language),
            label: Text(l10n.setupZ2mPageEntry),
          ),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntryAdvanced)),
        if (_asking) ...[
          const SizedBox(height: 24),
          CheckboxListTile(
            value: _share,
            onChanged: (v) => setState(() => _share = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.analyticsSetupCheckbox),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => launchUrl(
                usageDataPolicyUrl,
                mode: LaunchMode.externalApplication,
              ),
              child: Text(l10n.analyticsWhatsShared),
            ),
          ),
        ],
      ],
    );
  }
}

class _Scanning extends StatelessWidget {
  const _Scanning({
    required this.state,
    this.askPlatform = true,
    required this.onSelect,
    required this.onPlatform,
    required this.onManual,
    required this.onDemo,
    required this.onConnectViaHa,
  });
  final SetupScanning state;

  /// False when the welcome already asked (3.2).
  final bool askPlatform;
  final ValueChanged<SetupCandidate> onSelect;
  final ValueChanged<SetupPlatform?> onPlatform;
  final VoidCallback onManual;
  final VoidCallback onDemo;
  final void Function(String? host, HaSignInFrom from) onConnectViaHa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = state.progress;
    final hint = switch (state.platform) {
      _ when state.done => l10n.setupScanDoneHint,
      SetupPlatform.homeAssistant => l10n.setupScanHintHa,
      SetupPlatform.smlight => l10n.setupScanHintSmlight,
      SetupPlatform.piOrDocker => l10n.setupScanHintPi,
      _ => l10n.setupScanningHint,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            state.done ? l10n.setupScanDoneTitle : l10n.setupScanningTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(hint, style: theme.textTheme.bodyMedium),
        if (!state.done) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress == null || progress.total == 0
                ? 0
                : progress.checked / progress.total,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.setupScanProgress(
              progress?.checked ?? 0,
              progress?.total ?? 0,
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
        // Kept after the scan ends (2.7.1): a fast scan used to hide the
        // question before anyone could answer it.
        if (askPlatform) ...[
          const SizedBox(height: 20),
          _PlatformChips(
            value: state.platform,
            onChanged: onPlatform,
            onDemo: onDemo,
            done: state.done,
          ),
        ],
        if (state.platform == SetupPlatform.homeAssistant) ...[
          const SizedBox(height: 16),
          _HaShortcut(
            onPressed: () => onConnectViaHa(
              state.hubs
                  .where((h) => h.kind == HubKind.homeAssistant)
                  .firstOrNull
                  ?.host,
              HaSignInFrom.scanning,
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (final h in state.hubs)
          Card(
            child: ListTile(
              leading: const Icon(Icons.dns_outlined),
              title: Text(_hubSeen(l10n, h)),
              subtitle: Text(l10n.setupHubSeenHint),
            ),
          ),
        for (final c in state.candidates)
          Card(
            child: ListTile(
              leading: const Icon(Icons.router_outlined),
              title: Text(_candidateTitle(l10n, state.kinds[c.host])),
              subtitle: Text('${c.host}:${c.port} · ${c.protocol.name}'),
              onTap: () => onSelect(c),
            ),
          ),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntryAdvanced)),
      ],
    );
  }
}

String _hubSeen(AppLocalizations l10n, HubFound hub) => switch (hub.kind) {
  HubKind.homeAssistant => l10n.setupHubSeenHa(hub.host),
  HubKind.zigbee2mqtt => l10n.setupHubSeenZ2m(hub.host),
  HubKind.smlight => l10n.setupHubSeenSmlight(hub.host),
};

/// A candidate card's title: what its machine is when the scan could tell
/// (2.7.1), else the generic "Possible connection found".
String _candidateTitle(AppLocalizations l10n, HubKind? kind) => switch (kind) {
  HubKind.homeAssistant => l10n.setupPlatformHa,
  HubKind.smlight => l10n.setupPlatformSmlight,
  HubKind.zigbee2mqtt => 'Zigbee2MQTT',
  null => l10n.setupCandidateFound,
};

/// "Where does Zigbee2MQTT run?", asked while the scan runs and on the empty
/// result (2.5). Tapping the chosen chip again clears the answer.
class _PlatformChips extends StatelessWidget {
  const _PlatformChips({
    required this.value,
    required this.onChanged,
    required this.onDemo,
    this.done = false,
  });
  final SetupPlatform? value;
  final ValueChanged<SetupPlatform?> onChanged;

  /// The demo, offered under the ZHA answer: ZigDash can't see ZHA.
  final VoidCallback onDemo;

  /// The scan has ended: the question drops its "While we look".
  final bool done;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      SetupPlatform.homeAssistant: l10n.setupPlatformHa,
      SetupPlatform.smlight: l10n.setupPlatformSmlight,
      SetupPlatform.piOrDocker: l10n.setupPlatformPi,
      SetupPlatform.zha: l10n.setupPlatformZha,
      SetupPlatform.notSure: l10n.setupPlatformNotSure,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          done ? l10n.setupPlatformQuestionDone : l10n.setupPlatformQuestion,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final p in SetupPlatform.values)
              ChoiceChip(
                label: Text(labels[p]!),
                selected: value == p,
                onSelected: (on) => onChanged(on ? p : null),
              ),
          ],
        ),
        if (value == SetupPlatform.zha)
          Card.outlined(
            key: const Key('setup-zha-note'),
            margin: const EdgeInsets.only(top: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.setupZhaNote),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: onDemo,
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(l10n.onboardingDemo),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ScanEmpty extends StatelessWidget {
  const _ScanEmpty({
    required this.state,
    required this.onZ2mPage,
    required this.onWiden,
    required this.onRetry,
    required this.onPlatform,
    required this.onManual,
    required this.onCheckAddress,
    required this.onChoice,
    required this.onManualTo,
    required this.onManualPort,
    required this.onDemo,
    required this.onConnectViaHa,
  });
  final SetupScanEmpty state;

  /// 3.2: the Zigbee2MQTT page's address, as the browser shows it.
  final VoidCallback onZ2mPage;

  /// 3.2: the rest of the /22, when only the phone's /24 was scanned.
  final VoidCallback onWiden;
  final VoidCallback onRetry;
  final ValueChanged<SetupPlatform?> onPlatform;
  final ValueChanged<String> onCheckAddress;
  final ValueChanged<ScanEmptyChoice> onChoice;
  final VoidCallback onManual;
  final ValueChanged<HubFound> onManualTo;

  /// Manual entry with a port filled in (2.10.4).
  final ValueChanged<int> onManualPort;
  final VoidCallback onDemo;

  /// Connect through Home Assistant (2.10), with the Home Assistant the
  /// scan saw, if any.
  final void Function(String? host, HaSignInFrom from) onConnectViaHa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hub = state.hub;
    final platform = state.platform;
    final haHub = hub?.kind == HubKind.homeAssistant;
    final (title, body) = hub != null
        ? switch (hub.kind) {
            HubKind.homeAssistant => (
              l10n.setupNoBrokerHaTitle,
              l10n.setupNoBrokerHaBody(hub.host),
            ),
            HubKind.zigbee2mqtt => (
              l10n.setupNoBrokerZ2mTitle,
              l10n.setupNoBrokerZ2mBody(hub.host),
            ),
            HubKind.smlight => (
              l10n.setupNoBrokerSmlightTitle,
              l10n.setupNoBrokerSmlightBody(hub.host),
            ),
          }
        : switch (platform) {
            SetupPlatform.homeAssistant => (
              l10n.setupNoCandidatesTitle,
              l10n.setupNotFoundHa,
            ),
            SetupPlatform.smlight => (
              l10n.setupNoCandidatesTitle,
              l10n.setupNotFoundSmlight,
            ),
            SetupPlatform.piOrDocker => (
              l10n.setupNoCandidatesTitle,
              l10n.setupNotFoundPi,
            ),
            _ => (l10n.setupNoCandidatesTitle, l10n.setupNoCandidatesBody),
          };
    final guideFor = hub != null
        ? switch (hub.kind) {
            HubKind.homeAssistant => SetupPlatform.homeAssistant,
            HubKind.zigbee2mqtt => SetupPlatform.piOrDocker,
            HubKind.smlight => SetupPlatform.smlight,
          }
        : platform;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        // 2.6.7: a VPN on the phone hides the home network from the scan.
        // One 2.6.4 user scanned with a VPN up, found nothing and left.
        if (state.network?.vpn ?? false) ...[
          const SizedBox(height: 12),
          _VpnHint(text: l10n.setupVpnHint),
        ],
        // 2.8.1: almost nothing answered on the whole network. A home with
        // a hub has dozens of devices; a phone on a guest network, or kept
        // apart by the router, sees only a few (two users on 2026-10-16).
        if (!(state.network?.vpn ?? false) &&
            hub == null &&
            (state.tried?.aliveHosts ?? 99) <= 5) ...[
          const SizedBox(height: 12),
          _VpnHint(text: l10n.setupIsolatedHint),
        ],
        // 3.2: the page people pair devices on comes before any broker
        // wording; the three chips (18 "no hub" taps in 128 empty results)
        // and the platform question are gone: the welcome asks it first.
        if (hub == null && platform != SetupPlatform.homeAssistant) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('setup-z2m-page'),
            onPressed: onZ2mPage,
            icon: const Icon(Icons.language),
            label: Text(l10n.setupZ2mPageEntry),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        // Once Zigbee2MQTT has said where its broker is (2.7.2), its answer
        // replaces the general guess.
        if (state.z2m?.status != Z2mAnswerStatus.localOnly &&
            state.z2m?.status != Z2mAnswerStatus.nameOnly &&
            state.z2m?.status != Z2mAnswerStatus.unreachable)
          Text(body, style: theme.textTheme.bodyLarge),
        // 2.6.6: two of the first users to reach this screen left within
        // seconds of it. Many Home Assistant users run ZHA, not Zigbee2MQTT,
        // and no broker will ever answer for them; say so, and offer the demo.
        if (haHub) ...[
          const SizedBox(height: 12),
          Text(l10n.setupNoBrokerHaZha, style: theme.textTheme.bodyMedium),
        ],
        if (state.z2m case final z?) ...[
          const SizedBox(height: 12),
          _Z2mAnswerNote(answer: z, onManualPort: onManualPort),
        ],
        const SizedBox(height: 12),
        _SetupGuides(only: guideFor),
        // No hub found: three ways out of the dead end (2.9.6: 13 of the
        // first 20 Home Assistant users left here without typing an
        // address), then the address question, whose Check is the primary
        // action (2.6.4: five users saw it under the chips and none typed
        // into it); the chips and Try again follow.
        if (hub == null) ...[
          // Always in the list, so the choices below keep their state when
          // it appears (it does once a choice says Home Assistant).
          if (platform == SetupPlatform.homeAssistant)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _HaShortcut(
                onPressed: () => onConnectViaHa(null, HaSignInFrom.emptyCard),
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 20),
          _AddressField(
            platform: platform,
            check: state.address,
            onCheck: onCheckAddress,
          ),
        ],
        const SizedBox(height: 24),
        // Home Assistant with nothing on port 1883: connecting to it again
        // cannot work, so Try again (after installing Mosquitto) leads and
        // the demo sits right under it for ZHA users.
        if (haHub) ...[
          // 3.1.2: Home Assistant's sign-in leads. Of 91 users who said
          // they run Home Assistant in 30 days, 7 reached it as the
          // second button; the broker needs a login they rarely have.
          FilledButton.icon(
            onPressed: () => onConnectViaHa(hub!.host, HaSignInFrom.haFound),
            icon: const Icon(Icons.home_outlined),
            label: Text(l10n.haConnectButton),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.setupTryAgain),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onDemo,
            icon: const Icon(Icons.play_circle_outline),
            label: Text(l10n.onboardingDemo),
          ),
        ] else ...[
          if (hub != null) ...[
            FilledButton.icon(
              onPressed: () => onManualTo(hub),
              icon: const Icon(Icons.login),
              label: Text(l10n.setupConnectTo(hub.host)),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.setupTryAgain),
          ),
        ],
        if (!(state.tried?.widened ?? true)) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('setup-look-wider'),
            onPressed: onWiden,
            icon: const Icon(Icons.zoom_out_map),
            label: Text(l10n.setupLookWider),
          ),
        ],
        const SizedBox(height: 16),
        GetHelpLink(
          onPressed: () =>
              context.push(Routes.getHelpFrom(HelpFrom.noConnection.name)),
        ),
        const CommunityLink(from: HelpFrom.noConnection),
        const SizedBox(height: 8),
        if (haHub)
          TextButton(
            onPressed: () => onManualTo(hub),
            child: Text(l10n.setupConnectTo(hub!.host)),
          )
        else ...[
          TextButton(onPressed: onManual, child: Text(l10n.setupManualEntryAdvanced)),
          TextButton(onPressed: onDemo, child: Text(l10n.onboardingDemo)),
        ],
      ],
    );
  }
}

/// The three choices on an empty result with no hub found (2.9.6): no hub
/// yet opens the Hubs page; Home Assistant checks homeassistant.local and
/// says where its broker lives; another network explains guest networks
/// and offers [usualHubNames] to check.
class _EmptyChoices extends StatefulWidget {
  const _EmptyChoices({
    required this.onChoice,
    required this.onHomeAssistant,
    required this.onCheckAddress,
    required this.onConnectViaHa,
  });
  final ValueChanged<ScanEmptyChoice> onChoice;
  final VoidCallback onHomeAssistant;
  final VoidCallback onConnectViaHa;
  final ValueChanged<String> onCheckAddress;

  @override
  State<_EmptyChoices> createState() => _EmptyChoicesState();
}

class _EmptyChoicesState extends State<_EmptyChoices> {
  ScanEmptyChoice? _open;

  Future<void> _tap(ScanEmptyChoice choice) async {
    widget.onChoice(choice);
    switch (choice) {
      case ScanEmptyChoice.noHub:
        try {
          await openSetupLink(hubsPageUrl);
        } catch (_) {}
      case ScanEmptyChoice.homeAssistant:
        setState(() => _open = choice);
        widget.onHomeAssistant();
      case ScanEmptyChoice.otherNetwork:
        setState(() => _open = choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget note(List<Widget> children) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
    Widget tile(
      ScanEmptyChoice choice,
      IconData icon,
      String title,
      String subtitle, {
      IconData? trailing,
    }) => ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing != null
          ? Icon(trailing, size: 20, color: scheme.primary)
          : null,
      selected: _open == choice,
      onTap: () => _tap(choice),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupChoicesTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Card.outlined(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tile(
                ScanEmptyChoice.noHub,
                Icons.router_outlined,
                l10n.setupChoiceNoHub,
                l10n.setupChoiceNoHubSub,
                trailing: Icons.open_in_new,
              ),
              const Divider(height: 1),
              tile(
                ScanEmptyChoice.homeAssistant,
                Icons.home_outlined,
                l10n.setupChoiceHa,
                l10n.setupChoiceHaSub,
              ),
              if (_open == ScanEmptyChoice.homeAssistant)
                note([
                  Text(
                    l10n.setupChoiceHaNote,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  // 2.10: 21 of 22 Home Assistant users saw no Home
                  // Assistant on this network at all; Home Assistant's
                  // own address works from anywhere.
                  Text(
                    l10n.haConnectEmptyNote,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: widget.onConnectViaHa,
                    icon: const Icon(Icons.home_outlined),
                    label: Text(l10n.haConnectButton),
                  ),
                ]),
              const Divider(height: 1),
              tile(
                ScanEmptyChoice.otherNetwork,
                Icons.wifi_find,
                l10n.setupChoiceOther,
                l10n.setupChoiceOtherSub,
              ),
              if (_open == ScanEmptyChoice.otherNetwork)
                note([
                  Text(
                    l10n.setupChoiceOtherNote,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final name in usualHubNames)
                        ActionChip(
                          label: Text(ltr(name)),
                          onPressed: () => widget.onCheckAddress(name),
                        ),
                    ],
                  ),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

/// What Zigbee2MQTT's web page said about its broker (2.7.2): asking, a
/// broker that listens only on its own machine (with the lines that open
/// it), or one that did not answer where Zigbee2MQTT uses it.
class _Z2mAnswerNote extends StatelessWidget {
  const _Z2mAnswerNote({required this.answer, required this.onManualPort});
  final Z2mAnswer answer;
  final ValueChanged<int> onManualPort;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final server = ltr(answer.server);
    return switch (answer.status) {
      Z2mAnswerStatus.asking => Row(
        children: [
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n.setupZ2mAsking, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
      Z2mAnswerStatus.localOnly => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.setupZ2mLocalOnlyTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.setupZ2mLocalOnlyBody(server),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: SelectableText(
                'listener 1883\nallow_anonymous true',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.setupZ2mLocalOnlyNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
      // 2.10.4: a name only Zigbee2MQTT's machine knows (a Docker service,
      // a hostname): the phone needs the broker machine's address instead.
      Z2mAnswerStatus.nameOnly => Builder(
        builder: (context) {
          final uri = Uri.tryParse(answer.server);
          final name = uri?.host ?? answer.server;
          final port = (uri?.hasPort ?? false) ? uri!.port : 1883;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.setupZ2mNameOnlyTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.setupZ2mNameOnlyBody(server, ltr(name), port),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => onManualPort(port),
                  child: Text(l10n.setupManualEntry),
                ),
              ],
            ),
          );
        },
      ),
      Z2mAnswerStatus.unreachable => Text(
        l10n.setupZ2mUnreachable(server),
        style: theme.textTheme.bodyMedium,
      ),
      Z2mAnswerStatus.tokenRequired => Text(
        l10n.setupZ2mTokenRequired,
        style: theme.textTheme.bodyMedium,
      ),
      Z2mAnswerStatus.broker ||
      Z2mAnswerStatus.noAnswer => const SizedBox.shrink(),
    };
  }
}

/// The VPN note on the empty result: tinted so it reads before the body.
class _VpnHint extends StatelessWidget {
  const _VpnHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.vpn_lock, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The address check (2.6.2): "where do you open Home Assistant?" (or the
/// hub's address, by the platform answer), a field for whatever the user
/// types, and the outcome under it. The scanner guesses subnets; the user
/// knows the address.
class _AddressField extends StatefulWidget {
  const _AddressField({
    required this.platform,
    required this.check,
    required this.onCheck,
  });
  final SetupPlatform? platform;
  final AddressCheckState? check;
  final ValueChanged<String> onCheck;

  @override
  State<_AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<_AddressField> {
  final _controller = TextEditingController();

  // A choice above (Home Assistant, a usual name) checks an address the user
  // didn't type: show it in the field, so the outcome under it makes sense.
  @override
  void didUpdateWidget(_AddressField old) {
    super.didUpdateWidget(old);
    final host = widget.check?.host ?? '';
    if (host.isNotEmpty &&
        host != old.check?.host &&
        hostFromAddressInput(_controller.text)?.host != host) {
      _controller.text = host;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final check = widget.check;
    final checking = check?.status == AddressCheckStatus.checking;
    final question = switch (widget.platform) {
      SetupPlatform.homeAssistant => l10n.setupAddressQuestionHa,
      SetupPlatform.smlight => l10n.setupAddressQuestionSmlight,
      SetupPlatform.piOrDocker => l10n.setupAddressQuestionPi,
      _ => l10n.setupAddressQuestionAny,
    };
    final String? outcome = switch (check?.status) {
      AddressCheckStatus.nothing => l10n.setupAddressNothing(check!.host),
      // 3.1.3: a .local name (often the app's own homeassistant.local
      // check) points Home Assistant users at its sign-in, which takes the
      // address they use in the browser.
      AddressCheckStatus.notResolved
          when widget.platform == SetupPlatform.homeAssistant &&
              check!.host.toLowerCase().endsWith('.local') =>
        l10n.setupAddressNotResolvedHa(check.host, l10n.haConnectButton),
      AddressCheckStatus.notResolved => l10n.setupAddressNotResolved(
        check!.host,
      ),
      AddressCheckStatus.notLocal => l10n.setupAddressNotLocal(check!.host),
      AddressCheckStatus.invalid => l10n.setupAddressInvalid,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(question, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        // 3.2.6: SMLIGHT users who reach this field leave without typing
        // (a 2026-10-29 user scanned three times, then went to manual
        // entry). Their hub's Dashboard shows the address; say where.
        if (widget.platform == SetupPlatform.smlight) ...[
          const _SmhubAddressHint(),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _controller,
          enabled: !checking,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: l10n.setupAddressHint,
            hintMaxLines: 2,
            errorText: outcome,
            errorMaxLines: 4,
          ),
          // Every address-field user in the 2.6.4 data tapped Check on an
          // empty field first; an empty submit does nothing now.
          onSubmitted: (text) {
            if (text.trim().isNotEmpty) widget.onCheck(text);
          },
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => FilledButton.icon(
            onPressed: checking || value.text.trim().isEmpty
                ? null
                : () => widget.onCheck(_controller.text),
            icon: checking
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.travel_explore),
            label: Text(l10n.setupAddressCheck),
          ),
        ),
      ],
    );
  }
}

/// Where an SMHUB shows its address (3.2.6): a sketch of the Network box on
/// its Dashboard, then a line for SLZB owners, whose radio has no broker.
/// The sketch keeps the hub's own English labels.
class _SmhubAddressHint extends StatelessWidget {
  const _SmhubAddressHint();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mono = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Column(
      key: const Key('setup-smhub-address-hint'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupAddressWhereSmlight, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lan_outlined, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text('Network', style: theme.textTheme.titleSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(width: 48, child: Text('IPv4', style: mono)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '192.168.1.20',
                        style: mono?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.setupAddressSlzbSmlight,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// "Your broker works, but Zigbee2MQTT isn't publishing here": check the base
/// topic on the same broker, see setup guides, or try the demo meanwhile.
class _NoZigbee2Mqtt extends StatefulWidget {
  const _NoZigbee2Mqtt({
    required this.base,
    required this.onRetry,
    required this.onDemo,
    required this.onManual,
  });
  final String base;
  final ValueChanged<String> onRetry;
  final VoidCallback onDemo;
  final VoidCallback onManual;

  @override
  State<_NoZigbee2Mqtt> createState() => _NoZigbee2MqttState();
}

class _NoZigbee2MqttState extends State<_NoZigbee2Mqtt> {
  late final _baseController = TextEditingController(text: widget.base);

  @override
  void dispose() {
    _baseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(l10n.setupNoZ2mTitle, style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.setupNoZ2mBody(widget.base),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(l10n.setupBaseTopicQuestion, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _baseController,
                decoration: InputDecoration(labelText: l10n.discoverBaseTopic),
                onSubmitted: widget.onRetry,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => widget.onRetry(_baseController.text),
              child: Text(l10n.retry),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AiHelpCard(
          facts: AiHelpFacts(
            from: AiHelpFrom.noZigbee2mqtt,
            baseTopic: widget.base,
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: GetHelpLink(
            onPressed: () => context.push(
              Routes.getHelpFrom(
                HelpFrom.setupError.name,
                error: SetupErrorKind.notZigbee2Mqtt.name,
              ),
            ),
          ),
        ),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: CommunityLink(from: HelpFrom.setupError),
        ),
        const SizedBox(height: 16),
        Text(l10n.setupGuidesTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        const _SetupGuides(),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: widget.onDemo,
          icon: const Icon(Icons.play_circle_outline),
          label: Text(l10n.setupTryDemoMeanwhile),
        ),
        TextButton(
          onPressed: widget.onManual,
          child: Text(l10n.setupManualEntry),
        ),
      ],
    );
  }
}

class _AuthPrompt extends StatefulWidget {
  const _AuthPrompt({
    required this.state,
    required this.onSubmit,
    required this.onDemo,
    required this.onConnectViaHa,
  });
  final SetupNeedsAuth state;
  final void Function(String username, String password) onSubmit;
  final VoidCallback onDemo;
  final void Function(String? host, HaSignInFrom from) onConnectViaHa;

  @override
  State<_AuthPrompt> createState() => _AuthPromptState();
}

class _AuthPromptState extends State<_AuthPrompt> {
  // Zigbee2MQTT's own username, when its web page said (2.7.2).
  late final _username = TextEditingController(
    text: widget.state.suggestedUser ?? '',
  );
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final username = _username.text.trim();
    if (username.isEmpty) return;
    widget.onSubmit(username, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final body = widget.state.rejected
        ? l10n.setupAuthRejectedBody
        : l10n.setupAuthBody(widget.state.candidate.host);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(l10n.setupAuthTitle, style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: widget.state.rejected
              ? theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                )
              : theme.textTheme.bodyMedium,
        ),
        // After a rejected login, the one place that surely holds a working
        // login: the one Zigbee2MQTT itself uses (2.7.1; a user left after
        // a rejected login with no idea which one was wanted).
        if (widget.state.rejected) ...[
          const SizedBox(height: 8),
          Text(l10n.setupAuthRejectedZ2m, style: theme.textTheme.bodyMedium),
        ],
        // 3.1.2: no MQTT user at hand? Home Assistant's own sign-in needs
        // none (48 asked for a login and 20 were refused in 30 days).
        if (widget.state.platform == SetupPlatform.homeAssistant) ...[
          const SizedBox(height: 12),
          _HaShortcut(
            onPressed: () => widget.onConnectViaHa(
              widget.state.candidate.host,
              HaSignInFrom.login,
            ),
          ),
        ],
        const SizedBox(height: 12),
        _LoginHint(platform: widget.state.platform),
        // 2.8.1: people stopped here without typing. Say where the login
        // goes before asking for it.
        const SizedBox(height: 12),
        _LoginTrust(onDemo: widget.onDemo),
        const SizedBox(height: 16),
        // The broker refused anonymous access, so the username is not
        // optional here: the button waits for one (2.6.4; a user tapped it
        // eight times on an empty field before typing).
        TextField(
          controller: _username,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.connUsername),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.connPasswordOptional),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _username,
          builder: (context, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: Text(l10n.setupErrAuthRequiredAction),
          ),
        ),
        const SizedBox(height: 16),
        AiHelpCard(
          facts: AiHelpFacts(
            from: AiHelpFrom.login,
            platform: widget.state.platform,
            loginRejected: widget.state.rejected,
          ),
        ),
        GetHelpLink(
          onPressed: () => context.push(
            Routes.getHelpFrom(
              HelpFrom.setupError.name,
              error:
                  (widget.state.rejected
                          ? SetupErrorKind.authRejected
                          : SetupErrorKind.authRequired)
                      .name,
            ),
          ),
        ),
        const CommunityLink(from: HelpFrom.setupError),
      ],
    );
  }
}

/// Why typing the MQTT login here is safe, with the policy and the demo
/// for anyone who wants to look first (2.8.1).
class _LoginTrust extends StatelessWidget {
  const _LoginTrust({required this.onDemo});
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.setupAuthTrust,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 4,
            children: [
              TextButton(
                onPressed: () => launchUrl(
                  privacyPolicyUrl,
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(l10n.setupAuthWhatKept),
              ),
              TextButton(
                onPressed: onDemo,
                child: Text(l10n.setupAuthDemoFirst),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Where the MQTT login lives, so nobody types their hub's web password
/// here (setup-help-2.5.md, login step). One line for the platform the user
/// named; all three when they didn't.
/// Zigbee2MQTT in Home Assistant: sign in with Home Assistant instead of
/// finding its broker and an MQTT login (3.1.2, ha-route.md).
class _HaShortcut extends StatelessWidget {
  const _HaShortcut({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card.outlined(
      key: const Key('setup-ha-shortcut'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.setupHaShortcut, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.home_outlined),
              label: Text(l10n.haConnectButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginHint extends StatelessWidget {
  const _LoginHint({required this.platform});
  final SetupPlatform? platform;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final lines = switch (platform) {
      SetupPlatform.homeAssistant => [l10n.setupAuthHintHa],
      SetupPlatform.piOrDocker => [l10n.setupAuthHintPi],
      SetupPlatform.smlight => [l10n.setupAuthHintSmlight],
      SetupPlatform.notSure || SetupPlatform.zha || null => [
        l10n.setupAuthHintHa,
        l10n.setupAuthHintPi,
        l10n.setupAuthHintSmlight,
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.setupAuthWhich, style: style),
        for (final line in lines) ...[
          const SizedBox(height: 4),
          Text(line, style: style),
        ],
      ],
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({
    required this.state,
    required this.onRetry,
    required this.onManual,
  });
  final SetupFailed state;
  final VoidCallback onRetry;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final guidance = guidanceFor(state.kind);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(
            _guidanceText(l10n, guidance.titleKey),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _guidanceText(l10n, guidance.explanationKey),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(_guidanceText(l10n, guidance.actionKey)),
        ),
        if (state.kind != SetupErrorKind.saveFailed) ...[
          const SizedBox(height: 16),
          AiHelpCard(
            facts: AiHelpFacts(from: AiHelpFrom.failed, error: state.kind),
          ),
        ],
        GetHelpLink(
          onPressed: () => context.push(
            Routes.getHelpFrom(
              HelpFrom.setupError.name,
              error: state.kind.name,
            ),
          ),
        ),
        const CommunityLink(from: HelpFrom.setupError),
        const SizedBox(height: 8),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntry)),
      ],
    );
  }
}

/// No home address to scan from (2.9.4): says why (mobile data, no
/// network), opens the Wi-Fi panel, and waits; the coordinator scans again
/// by itself once Wi-Fi is back, so there is no Try again to tap repeatedly.
class _NoNetwork extends StatelessWidget {
  const _NoNetwork({
    required this.state,
    required this.onManual,
    required this.onHa,
  });
  final SetupFailed state;
  final VoidCallback onManual;

  /// Home Assistant's sign-in (3.1.9): with its remote address it works
  /// on mobile data, where the scan can't.
  final VoidCallback onHa;

  static Future<void> _openWifi() async {
    try {
      await appChannel.invokeMethod<bool>('openWifiSettings');
    } on PlatformException catch (_) {
      // No settings page to open: the text still says what to do.
    } on MissingPluginException catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final why = state.noNetwork ?? NoNetwork.unknown;
    final (title, body) = switch (why) {
      NoNetwork.mobileData => (
        l10n.setupNoWifiTitle,
        l10n.setupNoWifiMobileData,
      ),
      NoNetwork.offline => (l10n.setupNoWifiTitle, l10n.setupNoWifiOffline),
      NoNetwork.unknown => (
        l10n.setupErrScanFailedTitle,
        l10n.setupNoWifiUnknown,
      ),
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(Icons.wifi_off, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _openWifi,
          icon: const Icon(Icons.wifi),
          label: Text(l10n.setupOpenWifiSettings),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.setupWaitingForWifi,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onHa,
          icon: const Icon(Icons.home_outlined),
          label: Text(l10n.setupNoWifiHa),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntry)),
        GetHelpLink(
          onPressed: () => context.push(
            Routes.getHelpFrom(
              HelpFrom.setupError.name,
              error: state.kind.name,
            ),
          ),
        ),
        const CommunityLink(from: HelpFrom.setupError),
      ],
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.state,
    required this.onToggle,
    required this.onCreate,
    this.busy = false,
  });
  final SetupReview state;
  final ValueChanged<String> onToggle;
  final VoidCallback onCreate;

  /// Saving: the list stays up and the button shows progress.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rows = state.rows;
    final firstOther = rows.indexWhere((r) => r.group == ReviewGroup.other);
    final firstUnsupported = rows.indexWhere(
      (r) => r.group == ReviewGroup.unsupported,
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.setupReviewSubtitle(rows.length),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 4),
              // 3.1.6: say this is the last step, and where it finishes.
              Text(
                l10n.setupReviewLastStep,
                key: const Key('setup-review-last-step'),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < rows.length; i++) ...[
                if (i == firstOther) _GroupHeader(title: l10n.setupGroupOther),
                if (i == firstUnsupported)
                  _GroupHeader(title: l10n.setupGroupUnsupported),
                _DeviceRow(row: rows[i], onToggle: onToggle),
              ],
            ],
          ),
        ),
        // 2.10.2: nothing ticked (only "other" or unsupported devices) is
        // said, and the dashboard can still be created, empty, instead of
        // a disabled button with no way on.
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.selectedCount == 0) ...[
                Text(
                  l10n.setupReviewNoneSelected,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
              ],
              // 3.1.6: full width, the one way on from here.
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: busy ? null : onCreate,
                  icon: busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.dashboard_outlined),
                  label: Text(
                    state.selectedCount == 0
                        ? l10n.setupCreateEmpty
                        : l10n.setupCreateWithCount(state.selectedCount),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.row, required this.onToggle});
  final ReviewRow row;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final enabled = row.selectable;
    // CheckboxListTile owns the semantics: it exposes the row's checked
    // state, its label, and enabled/disabled (onChanged null ⇒ disabled).
    // A Semantics(selected:) wrapper here would be overridden by the tile's
    // own `selected: false` and is therefore dead code.
    return CheckboxListTile(
      value: row.selected,
      onChanged: enabled ? (_) => onToggle(row.device.friendlyName) : null,
      title: Text(row.device.displayName),
      subtitle: Text(
        [row.device.vendor, row.device.model].whereType<String>().join(' · '),
      ),
    );
  }
}

/// Where Zigbee2MQTT usually runs, each opening its setup guide in the
/// browser. Shown when nothing was found and when Zigbee2MQTT is missing;
/// with [only], just that platform's guide (the user's answer, 2.5).
class _SetupGuides extends StatelessWidget {
  const _SetupGuides({this.only});
  final SetupPlatform? only;

  static final _ha = Uri.parse(
    'https://www.zigbee2mqtt.io/guide/installation/03_ha_addon.html',
  );
  static final _linux = Uri.parse(
    'https://www.zigbee2mqtt.io/guide/installation/01_linux.html',
  );
  static final _smlight = Uri.parse(
    'https://smlight.tech/support/manuals/books/smhub',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all = {
      SetupPlatform.homeAssistant: _GuideLink(
        text: l10n.setupGuideHa,
        url: _ha,
      ),
      SetupPlatform.piOrDocker: _GuideLink(
        text: l10n.setupGuidePi,
        url: _linux,
      ),
      SetupPlatform.smlight: _GuideLink(
        text: l10n.setupGuideSmlight,
        url: _smlight,
      ),
    };
    final shown = all[only];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: shown != null ? [shown] : all.values.toList(),
    );
  }
}

class _GuideLink extends StatelessWidget {
  const _GuideLink({required this.text, required this.url});
  final String text;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(text, style: theme.textTheme.bodyMedium),
      trailing: Icon(
        Icons.open_in_new,
        size: 20,
        color: theme.colorScheme.primary,
      ),
      onTap: () => launchUrl(url, mode: LaunchMode.externalApplication),
    );
  }
}

/// What back on the device list was answered (3.1.6).
enum ReviewBackAnswer { create, startOver, stay }

/// Back on the device list (3.1.6): create the dashboard, start setup over,
/// or stay on the list. Leaving used to throw the found devices away
/// without a word.
Future<void> _askBeforeLeavingReview(
  BuildContext context,
  WidgetRef ref,
  SetupReview review,
  SetupCoordinator coordinator,
) async {
  final l10n = context.l10n;
  final answer = await showDialog<ReviewBackAnswer>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.setupLeaveTitle),
      content: Text(l10n.setupLeaveBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(ReviewBackAnswer.startOver),
          child: Text(l10n.setupStartOver),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialog).pop(ReviewBackAnswer.create),
          child: Text(
            review.selectedCount == 0
                ? l10n.setupCreateEmpty
                : l10n.setupCreateWithCount(review.selectedCount),
          ),
        ),
      ],
    ),
  );
  final picked = answer ?? ReviewBackAnswer.stay;
  ref
      .read(analyticsProvider)
      .track(
        SetupStep(
          SetupStepKind.reviewBack,
          result: picked,
          devices: review.rows.length,
          selected: review.selectedCount,
          platform: coordinator.platform,
        ),
      );
  switch (picked) {
    case ReviewBackAnswer.create:
      await coordinator.createDashboard();
    case ReviewBackAnswer.startOver:
      await coordinator.cancel();
    case ReviewBackAnswer.stay:
      break;
  }
}

/// 3.2 spike: the address of Zigbee2MQTT's web page, as the browser shows it
/// (`192.168.1.20:8080`, `http://zigbee.local:8080/#/devices`): host and port.
(String, int)? z2mPageAddress(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  if (!text.contains('://')) text = 'http://$text';
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return null;
  return (uri.host, uri.hasPort ? uri.port : 8080);
}

Future<void> _askZ2mPage(BuildContext context, SetupCoordinator coordinator) async {
  final controller = TextEditingController();
  final address = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.z2mPageTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.z2mPageBody),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(labelText: context.l10n.z2mPageLabel, hintText: '192.168.1.20:8080'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(context.l10n.z2mPageConnect)),
      ],
    ),
  );
  final parsed = address == null ? null : z2mPageAddress(address);
  if (parsed == null) return;
  var host = parsed.$1;
  // 3.2 spike: a .local name Android may not resolve, looked up by ZigDash.
  if (host.toLowerCase().endsWith('.local')) {
    final ip = await mdnsLookup(host);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ip == null ? context.l10n.z2mPageNoName(host) : context.l10n.z2mPageFoundName(host, ip.address)),
      ));
    }
    if (ip != null) host = ip.address;
  }
  await coordinator.adoptZ2mPage(host: host, port: parsed.$2);
}

