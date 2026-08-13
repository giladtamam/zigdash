import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';

StepResult fail(DiagnosticStep step, String key) =>
    StepResult(step: step, status: StepStatus.fail, detailKey: key);

DiagnosticsReport report(List<StepResult> steps, {int? deviceCount}) =>
    DiagnosticsReport(steps: steps, connected: false, candidatesTried: 1);

void main() {
  group('mapLadderFailure', () {
    test('resolve failure → hostUnreachable', () {
      expect(mapLadderFailure(report([fail(DiagnosticStep.resolve, 'diagResolveFail')])),
          SetupErrorKind.hostUnreachable);
      expect(mapLadderFailure(report([fail(DiagnosticStep.resolve, 'diagResolveTimeout')])),
          SetupErrorKind.hostUnreachable);
    });

    test('tcp timeout → hostUnreachable', () {
      final steps = [
        const StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
        fail(DiagnosticStep.tcp, 'diagTcpTimeout'),
      ];
      expect(mapLadderFailure(report(steps)), SetupErrorKind.hostUnreachable);
    });

    test('tcp refused → portClosed', () {
      expect(mapLadderFailure(report([fail(DiagnosticStep.tcp, 'diagTcpFail')])),
          SetupErrorKind.portClosed);
    });

    test('connack failure → portClosed', () {
      expect(
          mapLadderFailure(report([fail(DiagnosticStep.connack, 'diagConnackFail')])),
          SetupErrorKind.portClosed);
    });

    test('auth rejected → authRejected', () {
      expect(
          mapLadderFailure(report([fail(DiagnosticStep.auth, 'diagAuthRejected')])),
          SetupErrorKind.authRejected);
    });

    test('auth refused (other) → authRejected', () {
      expect(
          mapLadderFailure(report([fail(DiagnosticStep.auth, 'diagAuthRefused')])),
          SetupErrorKind.authRejected);
    });

    test('no failing step → unknown', () {
      final steps = [
        const StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
      ];
      expect(mapLadderFailure(report(steps)), SetupErrorKind.unknown);
    });
  });

  group('every error kind offers a recovery action', () {
    test('all kinds have a non-empty action key', () {
      for (final kind in SetupErrorKind.values) {
        expect(guidanceFor(kind).actionKey, isNotEmpty, reason: kind.name);
        expect(guidanceFor(kind).titleKey, isNotEmpty, reason: kind.name);
        expect(guidanceFor(kind).explanationKey, isNotEmpty, reason: kind.name);
      }
    });
  });
}
