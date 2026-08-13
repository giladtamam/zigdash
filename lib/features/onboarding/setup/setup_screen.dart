import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupWelcomeTitle)),
      body: SafeArea(
        child: switch (state) {
          SetupIdle() => _Welcome(
              onFind: coordinator.startScan,
              onManual: () => context.go(Routes.guidedConnect),
            ),
          SetupScanning() => _Scanning(
              state: state,
              onSelect: coordinator.selectCandidate,
              onManual: () => context.go(Routes.guidedConnect),
            ),
          SetupScanEmpty() => _ScanEmpty(
              onRetry: coordinator.retry,
              onManual: () => context.go(Routes.guidedConnect),
            ),
          SetupVerifying() => const _Verifying(),
          SetupNeedsAuth() => _AuthPrompt(
              state: state,
              onSubmit: coordinator.submitCredentials,
            ),
          SetupFailed() => _Failure(
              state: state,
              onRetry: state.kind == SetupErrorKind.notZigbee2Mqtt
                  ? coordinator.startScan
                  : coordinator.retry,
              onManual: () => context.go(Routes.guidedConnect),
            ),
          SetupReview() => _Review(
              state: state,
              onToggle: coordinator.toggleDevice,
              onCreate: coordinator.createDashboard,
            ),
          SetupCreating() => const _Creating(),
          SetupComplete() => _Complete(
              state: state,
              onOpen: () => context.go(
                  '/connections/${state.result.connectionId}/dashboards'),
            ),
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
  const _ScanEmpty({required this.onRetry, required this.onManual});
  final VoidCallback onRetry;
  final VoidCallback onManual;

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
        Text(l10n.setupGuideHa, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(l10n.setupGuidePi, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(l10n.setupGuideSmlight, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.setupTryAgain),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onManual, child: Text(l10n.setupManualEntry)),
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
  });
  final SetupReview state;
  final ValueChanged<String> onToggle;
  final VoidCallback onCreate;

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
            onPressed: state.selectedCount > 0 ? onCreate : null,
            icon: const Icon(Icons.dashboard_outlined),
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
    return Semantics(
      selected: row.selected,
      enabled: enabled,
      child: CheckboxListTile(
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
      ),
    );
  }
}

class _Creating extends StatelessWidget {
  const _Creating();

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
            child: Text(context.l10n.setupCreatingTitle),
          ),
        ],
      ),
    );
  }
}

class _Complete extends StatelessWidget {
  const _Complete({required this.state, required this.onOpen});
  final SetupComplete state;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Icon(Icons.check_circle, size: 56, color: theme.colorScheme.tertiary),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(l10n.setupReadyTitle,
              textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 8),
        Text(l10n.setupReadyBody(state.result.panelCount),
            textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: onOpen,
          icon: const Icon(Icons.dashboard_outlined),
          label: Text(l10n.setupOpenDashboard),
        ),
      ],
    );
  }
}
