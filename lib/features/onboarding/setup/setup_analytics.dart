import '../../../core/analytics/analytics_events.dart';
import '../../connections/discovery/address_check.dart';
import 'setup_coordinator.dart';

/// The `setup_step` event for a setup state change, or null when the change
/// is not a step (more candidates arriving, say). Recorded only with
/// consent (ADR 0006). [platform] is the user's answer so far; an empty scan
/// also reports what it saw (2.5), and the address check its outcome
/// (2.6.2): a broker found leaves the empty result for verification, the
/// other outcomes stay on it.
SetupStep? setupStepFor(
  SetupState? previous,
  SetupState next, {
  SetupPlatform? platform,
  bool aiHelped = false,
}) => switch (next) {
  SetupScanning() when previous is! SetupScanning => const SetupStep(
    SetupStepKind.started,
  ),
  // 2.7.2: Zigbee2MQTT's web page was asked where its broker is.
  SetupVerifying()
      when previous is SetupScanEmpty &&
          previous.z2m?.status == Z2mAnswerStatus.asking =>
    SetupStep(
      SetupStepKind.z2mAsked,
      result: Z2mAnswerStatus.broker,
      platform: platform,
    ),
  SetupScanEmpty(z2m: (status: Z2mAnswerStatus.asking, server: _)) => null,
  SetupScanEmpty(z2m: (:final status, server: _))
      when previous is SetupScanEmpty &&
          previous.z2m?.status == Z2mAnswerStatus.asking =>
    SetupStep(
      SetupStepKind.z2mAsked,
      result: status,
      platform: next.platform ?? platform,
    ),
  SetupVerifying(:final lateHosts) when previous is SetupScanning => SetupStep(
    SetupStepKind.scanFound,
    platform: platform,
    lateHosts: lateHosts,
  ),
  SetupVerifying() when previous is SetupScanEmpty => SetupStep(
    SetupStepKind.address,
    result: AddressOutcome.broker,
    platform: platform,
  ),
  // The check is running: nothing to count yet.
  SetupScanEmpty(address: (status: AddressCheckStatus.checking, host: _)) =>
    null,
  // A chip tap re-emits the empty result with the same check: count once.
  SetupScanEmpty(address: final a?)
      when previous is SetupScanEmpty && previous.address == a =>
    null,
  SetupScanEmpty(address: (:final status, host: _)) => SetupStep(
    SetupStepKind.address,
    result: switch (status) {
      AddressCheckStatus.hub => AddressOutcome.hub,
      AddressCheckStatus.notResolved => AddressOutcome.notResolved,
      AddressCheckStatus.notLocal => AddressOutcome.notLocal,
      AddressCheckStatus.invalid => AddressOutcome.invalid,
      AddressCheckStatus.checking ||
      AddressCheckStatus.nothing => AddressOutcome.nothing,
    },
    platform: next.platform ?? platform,
  ),
  // A chip tap on the empty result re-emits it with the answer. The scan was
  // counted when it ended; the answer rides on the steps after it (2.6.3).
  SetupScanEmpty() when previous is SetupScanEmpty => null,
  SetupScanEmpty(:final tried, :final deviceIp, :final network) => SetupStep(
    SetupStepKind.scanEmpty,
    platform: next.platform ?? platform,
    hub: next.hub?.kind,
    hostsTried: tried?.hostsTried,
    widened: tried?.widened,
    subnet: subnetShape(deviceIp),
    aliveHosts: tried?.aliveHosts,
    lateHosts: tried?.lateHosts,
    vpn: network?.vpn,
    network: network?.kind,
  ),
  SetupNeedsAuth(:final rejected) => SetupStep(
    rejected ? SetupStepKind.loginRejected : SetupStepKind.needsLogin,
    platform: next.platform ?? platform,
  ),
  SetupFailed(:final kind, :final noNetwork) => SetupStep(
    SetupStepKind.failed,
    error: kind,
    noNetwork: noNetwork,
  ),
  SetupReview(:final rows) when previous is! SetupReview => SetupStep(
    SetupStepKind.review,
    devices: rows.length,
    selected: rows.where((r) => r.selected).length,
    platform: platform,
  ),
  SetupComplete(:final result, :final via) => SetupStep(
    SetupStepKind.complete,
    devices: result.panelCount,
    platform: platform,
    via: via,
    aiHelped: aiHelped,
  ),
  _ => null,
};

/// The review was left without a dashboard (2.10.2): what the list held
/// and how much of it was ticked, so a review nobody can finish (nothing
/// preselected) shows up as `review_left` with `selected: 0`.
SetupStep reviewLeftStep(SetupReview review, SetupCoordinator coordinator) =>
    SetupStep(
      SetupStepKind.reviewLeft,
      devices: review.rows.length,
      selected: review.selectedCount,
      platform: coordinator.platform,
    );

/// The private range the phone's address is in, never the address itself.
String? subnetShape(String? ip) {
  if (ip == null) return null;
  final parts = ip.split('.');
  if (parts.length != 4) return 'other';
  final a = int.tryParse(parts[0]), b = int.tryParse(parts[1]);
  if (a == 192 && b == 168) return '192.168';
  if (a == 10) return '10';
  if (a == 172 && b != null && b >= 16 && b <= 31) return '172.16';
  return 'other';
}
