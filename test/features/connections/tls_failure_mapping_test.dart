// 3.8.5 (tls-home-broker.md §2a): each new TLS detail key runs through
// every place a failure is mapped. Most of them end in a catch-all the
// analyzer can't flag, so a missed one would fall back to "unknown" or the
// "no connection" tips without a sound. The setup screen's own mapping
// (_guidanceText) is pinned in setup_screen_test.dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/connections/widgets/diagnostics_ladder_view.dart';
import 'package:zigdash/features/onboarding/setup/ai_help.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/support/help_tips.dart';
import 'package:zigdash/features/support/support_details.dart';
import 'package:zigdash/l10n/app_localizations.dart';

typedef _Case = ({
  String key,
  SetupErrorKind kind,
  FailureKind failure,
  ManualTestResult result,
  String label,
  String title,
  String text,
  String Function(AppLocalizations l) message,
});

final List<_Case> _cases = [
  (
    key: 'diagTlsUntrusted',
    kind: SetupErrorKind.tlsUntrusted,
    failure: FailureKind.tlsUntrusted,
    result: ManualTestResult.tlsUntrusted,
    label: 'certificate not trusted',
    title: 'setupErrTlsUntrustedTitle',
    text: "doesn't trust the broker's certificate",
    message: (l) => l.diagTlsUntrusted,
  ),
  (
    key: 'diagTlsFailed',
    kind: SetupErrorKind.tlsFailed,
    failure: FailureKind.tlsFailed,
    result: ManualTestResult.tlsFailed,
    label: 'encrypted connection failed',
    title: 'setupErrTlsFailedTitle',
    text: 'the TLS handshake failed',
    message: (l) => l.diagTlsFailed,
  ),
];

DiagnosticsReport _failedWith(String key) => DiagnosticsReport(
  steps: [
    const StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
    const StepResult(step: DiagnosticStep.tcp, status: StepStatus.pass),
    StepResult(
      step: DiagnosticStep.connack,
      status: StepStatus.fail,
      detailKey: key,
    ),
  ],
  connected: false,
  candidatesTried: 1,
);

void main() {
  final l = lookupAppLocalizations(const Locale('en'));

  for (final c in _cases) {
    group(c.key, () {
      final report = _failedWith(c.key);

      test('analytics: manual_test result', () {
        expect(manualTestResult(report), c.result);
      });

      test('setup: its own error kind and guidance', () {
        expect(mapLadderFailure(report), c.kind);
        final g = guidanceFor(c.kind);
        expect(g.titleKey, c.title);
        expect(g.explanationKey, c.key);
        expect(g.actionKey, 'setupErrTlsAction');
      });

      test('Support details: failure kind and label', () {
        expect(failureKindFromLadder(report), c.failure);
        expect(failureKindFromSetup(c.kind), c.failure);
        expect(failureKindLabel(c.failure), c.label);
        expect(FailureKind.values.asNameMap()[c.failure.name], c.failure);
      });

      test('Get help: the port tips, not the "no connection" ones', () {
        final tips = tipsFor(l, HelpFrom.setupError, c.kind);
        expect(tips.first.title, l.tipRightPortTitle);
        expect(tips.map((t) => t.title), isNot(contains(l.tipSameWifiTitle)));
      });

      test('Ask your AI: says what went wrong', () {
        final text = aiHelpText(
          AiHelpFacts(from: AiHelpFrom.failed, error: c.kind),
        );
        expect(text, contains(c.text));
        expect(text, isNot(contains('unexpected error')));
      });

      testWidgets('the ladder shows its message', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: DiagnosticsLadderView(steps: report.steps)),
          ),
        );
        expect(find.text(c.message(l)), findsOneWidget);
      });
    });
  }

  test('a TLS failure is told by its exception, never its text', () {
    expect(isTlsFailure(null), isFalse);
    expect(isTlsFailure(Exception('connection refused')), isFalse);
    // mqtt_client's own wrapper, should it ever wrap one.
    expect(
      isTlsFailure(
        Exception(
          'MqttSecureConnection::connect - Handshake exception to the '
          'message broker',
        ),
      ),
      isTrue,
    );
  });
}
