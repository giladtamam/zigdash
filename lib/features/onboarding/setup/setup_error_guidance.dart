import '../../connections/diagnostics/connect_diagnostics.dart';

/// The user-facing failure categories of the discovery-first setup. Every
/// kind maps to a localized title, explanation, and at least one recovery
/// action (see l10n keys produced by [guidanceFor]).
enum SetupErrorKind {
  /// This device and the Zigbee2MQTT host can't reach each other.
  hostUnreachable,

  /// Host answers but the MQTT port is closed / nothing MQTT listens there.
  portClosed,

  /// The broker refuses anonymous access — ask for credentials.
  authRequired,

  /// Credentials were given and rejected — allow correction and retry.
  authRejected,

  /// Credentials were given and the broker never answered them in time
  /// (2.8.2). Home Assistant's Mosquitto add-on checks logins against Home
  /// Assistant's users, which can be slow on a Raspberry Pi.
  loginNoAnswer,

  /// MQTT connected but no Zigbee2MQTT topics verified on this endpoint.
  notZigbee2Mqtt,

  /// Zigbee2MQTT verified but no devices were published during verification.
  noDevices,

  /// Zigbee2MQTT answered but its device list never came, and its web page
  /// couldn't give it either (3.1.13): the broker lost its retained
  /// messages. Restarting Zigbee2MQTT republishes the list.
  devicesListMissing,

  /// Zigbee2MQTT's page did not answer at the address given, or wants a
  /// token (3.2): no broker message, it is not a broker.
  pageNoAnswer,

  /// Signed in to Home Assistant, but no Zigbee2MQTT on its MQTT (3.1.13):
  /// Zigbee through ZHA, or the Zigbee2MQTT add-on stopped.
  haNoZigbee2Mqtt,

  /// The scan itself failed (e.g. no local network) before any candidate.
  scanFailed,

  /// Saving the connection/dashboard/panels failed — retryable.
  saveFailed,

  /// A failure the mapper can't classify; still offers a generic retry.
  unknown,
}

/// Localized-guidance key bundle for a [SetupErrorKind]. The UI resolves the
/// keys through l10n; this class contains no widget code.
class SetupGuidance {
  const SetupGuidance({
    required this.titleKey,
    required this.explanationKey,
    required this.actionKey,
  });

  final String titleKey;
  final String explanationKey;
  final String actionKey;
}

/// Maps a failed ladder report to its user-facing category, using the first
/// failed step. An auth rejection during guided setup with no credentials
/// yet is [SetupErrorKind.authRequired] upstream — this mapper only sees the
/// ladder outcome and reports [SetupErrorKind.authRejected] either way; the
/// coordinator distinguishes "never asked" from "asked and rejected".
SetupErrorKind mapLadderFailure(DiagnosticsReport report) {
  StepResult? firstFail;
  for (final s in report.steps) {
    if (s.status == StepStatus.fail) {
      firstFail = s;
      break;
    }
  }
  if (firstFail == null) return SetupErrorKind.unknown;
  return switch (firstFail.detailKey) {
    'diagResolveFail' ||
    'diagResolveTimeout' ||
    'diagResolveLocalName' ||
    'diagTcpTimeout' => SetupErrorKind.hostUnreachable,
    'diagTcpFail' ||
    'diagTcpHaNoBroker' ||
    'diagTcpSmlightClosed' ||
    'diagTcpZ2mNoBroker' ||
    'diagTcpZ2mBrokerElsewhere' ||
    'diagConnackFail' => SetupErrorKind.portClosed,
    'diagAuthRejected' ||
    'diagAuthRejectedHa' ||
    'diagAuthRefused' => SetupErrorKind.authRejected,
    'diagLoginNoAnswer' => SetupErrorKind.loginNoAnswer,
    _ => SetupErrorKind.unknown,
  };
}

/// The l10n key bundle for each error kind.
SetupGuidance guidanceFor(SetupErrorKind kind) => switch (kind) {
  SetupErrorKind.hostUnreachable => const SetupGuidance(
    titleKey: 'setupErrUnreachableTitle',
    explanationKey: 'setupErrUnreachableBody',
    actionKey: 'setupErrUnreachableAction',
  ),
  SetupErrorKind.portClosed => const SetupGuidance(
    titleKey: 'setupErrPortClosedTitle',
    explanationKey: 'setupErrPortClosedBody',
    actionKey: 'setupErrPortClosedAction',
  ),
  SetupErrorKind.loginNoAnswer => const SetupGuidance(
    titleKey: 'setupErrLoginNoAnswerTitle',
    explanationKey: 'setupErrLoginNoAnswerBody',
    actionKey: 'setupErrLoginNoAnswerAction',
  ),
  SetupErrorKind.authRequired => const SetupGuidance(
    titleKey: 'setupErrAuthRequiredTitle',
    explanationKey: 'setupErrAuthRequiredBody',
    actionKey: 'setupErrAuthRequiredAction',
  ),
  SetupErrorKind.authRejected => const SetupGuidance(
    titleKey: 'setupErrAuthRejectedTitle',
    explanationKey: 'setupErrAuthRejectedBody',
    actionKey: 'setupErrAuthRejectedAction',
  ),
  SetupErrorKind.notZigbee2Mqtt => const SetupGuidance(
    titleKey: 'setupErrNotZ2mTitle',
    explanationKey: 'setupErrNotZ2mBody',
    actionKey: 'setupErrNotZ2mAction',
  ),
  SetupErrorKind.devicesListMissing => const SetupGuidance(
    titleKey: 'setupErrListMissingTitle',
    explanationKey: 'setupErrListMissingBody',
    actionKey: 'setupErrListMissingAction',
  ),
  SetupErrorKind.pageNoAnswer => const SetupGuidance(
    titleKey: 'setupErrPageTitle',
    explanationKey: 'setupErrPageBody',
    actionKey: 'setupErrPageAction',
  ),
  SetupErrorKind.haNoZigbee2Mqtt => const SetupGuidance(
    titleKey: 'setupErrHaNoZ2mTitle',
    explanationKey: 'setupErrHaNoZ2mBody',
    actionKey: 'setupErrHaNoZ2mAction',
  ),
  SetupErrorKind.noDevices => const SetupGuidance(
    titleKey: 'setupErrNoDevicesTitle',
    explanationKey: 'setupErrNoDevicesBody',
    actionKey: 'setupErrNoDevicesAction',
  ),
  SetupErrorKind.scanFailed => const SetupGuidance(
    titleKey: 'setupErrScanFailedTitle',
    explanationKey: 'setupErrScanFailedBody',
    actionKey: 'setupErrScanFailedAction',
  ),
  SetupErrorKind.saveFailed => const SetupGuidance(
    titleKey: 'setupErrSaveFailedTitle',
    explanationKey: 'setupErrSaveFailedBody',
    actionKey: 'setupErrSaveFailedAction',
  ),
  SetupErrorKind.unknown => const SetupGuidance(
    titleKey: 'setupErrUnknownTitle',
    explanationKey: 'setupErrUnknownBody',
    actionKey: 'setupErrUnknownAction',
  ),
};
