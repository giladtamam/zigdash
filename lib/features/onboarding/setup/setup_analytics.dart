import '../../../core/analytics/analytics_events.dart';
import 'setup_coordinator.dart';

/// The `setup_step` event for a setup state change, or null when the change
/// is not a step (more candidates arriving, say). Recorded only with
/// consent (ADR 0006).
SetupStep? setupStepFor(SetupState? previous, SetupState next) =>
    switch (next) {
      SetupScanning() when previous is! SetupScanning =>
        const SetupStep(SetupStepKind.started),
      SetupVerifying() when previous is SetupScanning =>
        const SetupStep(SetupStepKind.scanFound),
      SetupScanEmpty() => const SetupStep(SetupStepKind.scanEmpty),
      SetupNeedsAuth(:final rejected) => SetupStep(
          rejected ? SetupStepKind.loginRejected : SetupStepKind.needsLogin),
      SetupFailed(:final kind) =>
        SetupStep(SetupStepKind.failed, error: kind),
      SetupReview(:final rows) when previous is! SetupReview =>
        SetupStep(SetupStepKind.review, devices: rows.length),
      SetupComplete(:final result) =>
        SetupStep(SetupStepKind.complete, devices: result.panelCount),
      _ => null,
    };
