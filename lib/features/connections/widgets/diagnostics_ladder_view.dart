import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../diagnostics/connect_diagnostics.dart';

/// Renders the guided-connect diagnostic ladder: one row per [DiagnosticStep]
/// with a status icon, localized label, and (on failure) a localized fix.
/// Shared by the guided-connect wizard and the manual connection form's test.
class DiagnosticsLadderView extends StatelessWidget {
  const DiagnosticsLadderView({
    super.key,
    required this.steps,
    this.running = false,
    this.showTriedHint = false,
    this.candidatesTried = 1,
  });

  final List<StepResult> steps;

  /// True while a run is in flight — rows without a result show as pending.
  final bool running;
  final bool showTriedHint;
  final int candidatesTried;

  String _stepLabel(BuildContext context, DiagnosticStep step) =>
      switch (step) {
        DiagnosticStep.resolve => context.l10n.stepResolve,
        DiagnosticStep.tcp => context.l10n.stepTcp,
        DiagnosticStep.connack => context.l10n.stepConnack,
        DiagnosticStep.auth => context.l10n.stepAuth,
        DiagnosticStep.devices => context.l10n.stepDevices,
      };

  String? _detail(BuildContext context, String? key) => switch (key) {
        'diagResolveFail' => context.l10n.diagResolveFail,
        'diagResolveTimeout' => context.l10n.diagResolveTimeout,
        'diagTcpFail' => context.l10n.diagTcpFail,
        'diagTcpTimeout' => context.l10n.diagTcpTimeout,
        'diagConnackFail' => context.l10n.diagConnackFail,
        'diagAuthRejected' => context.l10n.diagAuthRejected,
        'diagAuthRefused' => context.l10n.diagAuthRefused,
        _ => null,
      };

  IconData _icon(StepStatus s) => switch (s) {
        StepStatus.pass => Icons.check_circle,
        StepStatus.fail => Icons.cancel,
        StepStatus.skipped => Icons.remove_circle_outline,
        StepStatus.pending || StepStatus.running => Icons.radio_button_unchecked,
      };

  Color _color(BuildContext context, StepStatus s) {
    final cs = Theme.of(context).colorScheme;
    return switch (s) {
      StepStatus.pass => cs.tertiary,
      StepStatus.fail => cs.error,
      StepStatus.skipped => cs.outline,
      StepStatus.pending || StepStatus.running => cs.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in DiagnosticStep.values) _row(context, step),
        if (showTriedHint && candidatesTried > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.ladderTriedHint(candidatesTried),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, DiagnosticStep step) {
    StepResult? result;
    for (final s in steps) {
      if (s.step == step) {
        result = s;
        break;
      }
    }
    final status = result?.status ??
        (running ? StepStatus.running : StepStatus.pending);
    final cs = Theme.of(context).colorScheme;
    final detail = _detail(context, result?.detailKey);
    final trailing = (step == DiagnosticStep.devices &&
            result?.status == StepStatus.pass &&
            result?.deviceCount != null)
        ? Text(
            '${result!.deviceCount}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.tertiary),
          )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(status), size: 20, color: _color(context, status)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_stepLabel(context, step),
                    style: Theme.of(context).textTheme.bodyLarge),
                if (detail != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      detail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.error,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
