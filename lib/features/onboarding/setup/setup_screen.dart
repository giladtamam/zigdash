import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../first_run.dart';
import 'recommendation_policy.dart';
import 'setup_candidate.dart';
import 'setup_coordinator.dart';
import 'setup_error_guidance.dart';
import 'setup_providers.dart';

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
    ref.listen(setupStateProvider, (_, next) {
      final s = next.valueOrNull;
      if (s is SetupComplete) {
        context.go(Routes.homeDashboards(s.result.connectionId));
      }
    });

    void manual() => context.push(Routes.guidedConnect);
    Future<void> tryDemo() async {
      final id = await ref.read(firstRunProvider).startDemo();
      if (context.mounted) context.go(Routes.homeDashboards(id));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupWelcomeTitle)),
      body: SafeArea(
        child: switch (state) {
          SetupIdle() => _Welcome(
              onFind: coordinator.startScan,
              onManual: manual,
            ),
          SetupScanning() => _Scanning(
              state: state,
              onSelect: coordinator.selectCandidate,
              onManual: manual,
            ),
          SetupScanEmpty() => _ScanEmpty(
              onRetry: coordinator.retry,
              onManual: manual,
              onDemo: tryDemo,
            ),
          SetupVerifying() => const _Verifying(),
          SetupNeedsAuth() => _AuthPrompt(
              state: state,
              onSubmit: coordinator.submitCredentials,
            ),
          SetupFailed(kind: SetupErrorKind.notZigbee2Mqtt) => _NoZigbee2Mqtt(
              base: coordinator.base,
              onRetry: coordinator.retryWithBase,
              onDemo: tryDemo,
              onManual: manual,
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
      'setupErrNoDevicesTitle' => l10n.setupErrNoDevicesTitle,
      'setupErrNoDevicesBody' => l10n.setupErrNoDevicesBody,
      'setupErrNoDevicesAction' => l10n.setupErrNoDevicesAction,
      'setupErrScanFailedTitle' => l10n.setupErrScanFailedTitle,
      'setupErrScanFailedBody' => l10n.setupErrScanFailedBody,
      'setupErrScanFailedAction' => l10n.setupErrScanFailedAction,
      'setupErrSaveFailedTitle' => l10n.setupErrSaveFailedTitle,
      'setupErrSaveFailedBody' => l10n.setupErrSaveFailedBody,
      'setupErrSaveFailedAction' => l10n.setupErrSaveFailedAction,
      _ => l10n.setupErrUnknownAction,
    };

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onFind, required this.onManual});
  final VoidCallback onFind;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Icon(Icons.home_outlined,
            size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 24),
        Text(l10n.setupWelcomeBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: onFind,
          icon: const Icon(Icons.wifi_find),
          label: Text(l10n.setupFindMySetup),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntry)),
      ],
    );
  }
}

class _Scanning extends StatelessWidget {
  const _Scanning({
    required this.state,
    required this.onSelect,
    required this.onManual,
  });
  final SetupScanning state;
  final ValueChanged<SetupCandidate> onSelect;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(l10n.setupScanningTitle,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Text(l10n.setupScanningHint,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        for (final c in state.candidates)
          Card(
            child: ListTile(
              leading: const Icon(Icons.router_outlined),
              title: Text(l10n.setupCandidateFound),
              subtitle: Text('${c.host}:${c.port} · ${c.protocol.name}'),
              onTap: () => onSelect(c),
            ),
          ),
        if (!state.done)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntry)),
      ],
    );
  }
}

class _ScanEmpty extends StatelessWidget {
  const _ScanEmpty({
    required this.onRetry,
    required this.onManual,
    required this.onDemo,
  });
  final VoidCallback onRetry;
  final VoidCallback onManual;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(l10n.setupNoCandidatesTitle,
              style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Text(l10n.setupNoCandidatesBody, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 12),
        const _SetupGuides(),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.setupTryAgain),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntry)),
        TextButton(onPressed: onDemo, child: Text(l10n.onboardingDemo)),
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
        Text(l10n.setupNoZ2mBody(widget.base),
            style: theme.textTheme.bodyMedium),
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
        const SizedBox(height: 24),
        Text(l10n.setupGuidesTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        const _SetupGuides(),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: widget.onDemo,
          icon: const Icon(Icons.play_circle_outline),
          label: Text(l10n.setupTryDemoMeanwhile),
        ),
        TextButton(onPressed: widget.onManual, child: Text(l10n.setupManualEntry)),
      ],
    );
  }
}

class _Verifying extends StatelessWidget {
  const _Verifying();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(context.l10n.setupVerifyingTitle),
          ),
        ],
      ),
    );
  }
}

class _AuthPrompt extends StatefulWidget {
  const _AuthPrompt({required this.state, required this.onSubmit});
  final SetupNeedsAuth state;
  final void Function(String username, String password) onSubmit;

  @override
  State<_AuthPrompt> createState() => _AuthPromptState();
}

class _AuthPromptState extends State<_AuthPrompt> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
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
              ? theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error)
              : theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _username,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.connUsernameOptional),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.connPasswordOptional),
          onSubmitted: (_) =>
              widget.onSubmit(_username.text.trim(), _password.text),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () =>
              widget.onSubmit(_username.text.trim(), _password.text),
          child: Text(l10n.setupErrAuthRequiredAction),
        ),
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
        Icon(Icons.error_outline,
            size: 48, color: theme.colorScheme.error),
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
        const SizedBox(height: 8),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntry)),
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
    final firstOther =
        rows.indexWhere((r) => r.group == ReviewGroup.other);
    final firstUnsupported =
        rows.indexWhere((r) => r.group == ReviewGroup.unsupported);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Semantics(
                liveRegion: true,
                child: Text(l10n.setupReviewSubtitle(rows.length),
                    style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < rows.length; i++) ...[
                if (i == firstOther)
                  _GroupHeader(title: l10n.setupGroupOther),
                if (i == firstUnsupported)
                  _GroupHeader(title: l10n.setupGroupUnsupported),
                _DeviceRow(row: rows[i], onToggle: onToggle),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: state.selectedCount > 0 && !busy ? onCreate : null,
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.dashboard_outlined),
            label: Text(l10n.setupCreateWithCount(state.selectedCount)),
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
      onChanged: enabled
          ? (_) => onToggle(row.device.friendlyName)
          : null,
      title: Text(row.device.friendlyName),
      subtitle: Text(
        [row.device.vendor, row.device.model]
            .whereType<String>()
            .join(' · '),
      ),
    );
  }
}

/// Where Zigbee2MQTT usually runs, each opening its setup guide in the
/// browser. Shown when nothing was found and when Zigbee2MQTT is missing.
class _SetupGuides extends StatelessWidget {
  const _SetupGuides();

  static final _ha = Uri.parse(
      'https://www.zigbee2mqtt.io/guide/installation/03_ha_addon.html');
  static final _linux =
      Uri.parse('https://www.zigbee2mqtt.io/guide/installation/01_linux.html');
  static final _smlight =
      Uri.parse('https://smlight.tech/support/manuals/books/smhub');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GuideLink(text: l10n.setupGuideHa, url: _ha),
        _GuideLink(text: l10n.setupGuidePi, url: _linux),
        _GuideLink(text: l10n.setupGuideSmlight, url: _smlight),
      ],
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
      trailing: Icon(Icons.open_in_new,
          size: 20, color: theme.colorScheme.primary),
      onTap: () => launchUrl(url, mode: LaunchMode.externalApplication),
    );
  }
}
