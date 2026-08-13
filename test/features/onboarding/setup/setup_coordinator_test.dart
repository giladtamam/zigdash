import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/connections/discovery/broker_probe.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/onboarding/setup/recommendation_policy.dart';
import 'package:zigdash/features/onboarding/setup/setup_candidate.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/mqtt/broker_config.dart';

const _lamp = Z2mDevice(
  friendlyName: 'lamp',
  type: 'EndDevice',
  exposes: [Z2mExpose(type: 'light')],
);
const _plug = Z2mDevice(
  friendlyName: 'plug',
  type: 'EndDevice',
  exposes: [Z2mExpose(type: 'switch')],
);

class _FakeDiagnostics extends ConnectDiagnostics {
  _FakeDiagnostics(this.reports);
  final List<DiagnosticsReport> reports;
  final calls = <({String? username, String password})>[];

  @override
  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) async {
    calls.add((username: config.username, password: password));
    return reports.removeAt(0);
  }
}

DiagnosticsReport ok() => const DiagnosticsReport(
      steps: [
        StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
        StepResult(step: DiagnosticStep.tcp, status: StepStatus.pass),
        StepResult(step: DiagnosticStep.connack, status: StepStatus.pass),
        StepResult(step: DiagnosticStep.auth, status: StepStatus.pass),
        StepResult(step: DiagnosticStep.devices, status: StepStatus.pass),
      ],
      connected: true,
      candidatesTried: 1,
      deviceNames: ['lamp'],
    );

DiagnosticsReport failAt(DiagnosticStep step, String key) => DiagnosticsReport(
      steps: [StepResult(step: step, status: StepStatus.fail, detailKey: key)],
      connected: false,
      candidatesTried: 1,
    );

class _FakeCreator implements SetupStore {
  var calls = 0;
  Object? error;
  @override
  Future<SetupResult> create({
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    String base = 'zigbee2mqtt',
    String dashboardName = 'Home',
    int dashboardColor = 0,
    int dashboardIcon = 0,
    required List<ReviewRow> selected,
  }) async {
    calls++;
    if (error != null) throw error!;
    return SetupResult(
      connectionId: 'c1',
      dashboardId: 'd1',
      panelCount: selected.length,
    );
  }
}

class _Harness {
  _Harness({
    List<DiagnosticsReport>? reports,
    Stream<ProbeResult> Function(String ip)? scan,
    Z2mFetchResult fetch = const Z2mFetchResult(detected: true, devices: [_lamp, _plug]),
    String? ip = '192.168.1.5',
  })  : diagnostics = _FakeDiagnostics(reports ?? [ok()]),
        creator = _FakeCreator() {
    coordinator = SetupCoordinator(
      scan: scan ??
          (ip) => Stream.fromIterable(
              [const ProbeResult(host: '192.168.1.10', port: 1883)]),
      deviceIp: () async => ip,
      diagnostics: diagnostics,
      fetchDevices: (config, password, base) async => fetch,
      creator: creator,
    );
  }

  late final SetupCoordinator coordinator;
  final _FakeDiagnostics diagnostics;
  final _FakeCreator creator;
}

void main() {
  test('starts idle', () {
    expect(_Harness().coordinator.state, isA<SetupIdle>());
  });

  group('scanning', () {
    test('emits candidates progressively and finishes', () async {
      final controller = StreamController<ProbeResult>();
      final h = _Harness(scan: (_) => controller.stream);
      final states = <SetupState>[];
      h.coordinator.states.listen(states.add);

      unawaited(h.coordinator.startScan());
      controller.add(const ProbeResult(host: '192.168.1.10', port: 1883));
      await Future<void>.delayed(Duration.zero);
      controller.add(const ProbeResult(host: '192.168.1.11', port: 1883));
      await Future<void>.delayed(Duration.zero);
      await controller.close();
      await Future<void>.delayed(Duration.zero);

      final scanning = states.whereType<SetupScanning>().toList();
      expect(scanning.first.candidates, isEmpty);
      expect(scanning[1].candidates, hasLength(1));
      expect(scanning[2].candidates, hasLength(2));
      expect(h.coordinator.state, isA<SetupScanning>());
      expect((h.coordinator.state as SetupScanning).done, isTrue);
    });

    test('no candidates found → SetupScanEmpty', () async {
      final h = _Harness(scan: (_) => const Stream.empty());
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero); // let onDone land
      expect(h.coordinator.state, isA<SetupScanEmpty>());
    });

    test('no local IP → SetupFailed(scanFailed)', () async {
      final h = _Harness(ip: null);
      await h.coordinator.startScan();
      final s = h.coordinator.state;
      expect(s, isA<SetupFailed>());
      expect((s as SetupFailed).kind, SetupErrorKind.scanFailed);
    });

    test('retry from empty scan rescans', () async {
      var n = 0;
      final h = _Harness(scan: (_) {
        n++;
        return n == 1
            ? const Stream.empty()
            : Stream.value(const ProbeResult(host: '10.0.0.1', port: 1883));
      });
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero);
      expect(h.coordinator.state, isA<SetupScanEmpty>());
      await h.coordinator.retry();
      await Future<void>.delayed(Duration.zero);
      expect((h.coordinator.state as SetupScanning).candidates, hasLength(1));
    });

    test('cancel during scan returns to idle and stops the scan', () async {
      final controller = StreamController<ProbeResult>();
      final h = _Harness(scan: (_) => controller.stream);
      unawaited(h.coordinator.startScan());
      await Future<void>.delayed(Duration.zero);
      await h.coordinator.cancel();
      expect(h.coordinator.state, isA<SetupIdle>());
      expect(controller.hasListener, isFalse);
    });
  });

  group('verification', () {
    const candidate = SetupCandidate(
        host: '192.168.1.10', port: 1883, protocol: MqttProtocol.tcp);

    test('connected with devices → review with preselected rows', () async {
      final h = _Harness();
      await h.coordinator.selectCandidate(candidate);
      final s = h.coordinator.state;
      expect(s, isA<SetupReview>());
      final rows = (s as SetupReview).rows;
      expect(rows, hasLength(2));
      expect(rows.every((r) => r.selected), isTrue);
    });

    test('anonymous rejected → needsAuth, preserving the candidate', () async {
      final h = _Harness(reports: [failAt(DiagnosticStep.auth, 'diagAuthRejected'), ok()]);
      await h.coordinator.selectCandidate(candidate);
      final s = h.coordinator.state;
      expect(s, isA<SetupNeedsAuth>());
      expect((s as SetupNeedsAuth).rejected, isFalse);
      expect(s.candidate, candidate);
    });

    test('candidate flagged needsAuth asks before verifying', () async {
      final h = _Harness();
      await h.coordinator.selectCandidate(const SetupCandidate(
          host: 'h', port: 1883, protocol: MqttProtocol.tcp, needsAuth: true));
      expect(h.coordinator.state, isA<SetupNeedsAuth>());
      expect(h.diagnostics.calls, isEmpty);
    });

    test('submitting credentials verifies with them and reaches review',
        () async {
      final h = _Harness(reports: [failAt(DiagnosticStep.auth, 'diagAuthRejected'), ok()]);
      await h.coordinator.selectCandidate(candidate);
      await h.coordinator.submitCredentials('user', 'secret');
      expect(h.coordinator.state, isA<SetupReview>());
      expect(h.diagnostics.calls.last.username, 'user');
      expect(h.diagnostics.calls.last.password, 'secret');
    });

    test('rejected credentials → needsAuth(rejected: true)', () async {
      final h = _Harness(reports: [
        failAt(DiagnosticStep.auth, 'diagAuthRejected'),
        failAt(DiagnosticStep.auth, 'diagAuthRejected'),
      ]);
      await h.coordinator.selectCandidate(candidate);
      await h.coordinator.submitCredentials('user', 'wrong');
      final s = h.coordinator.state;
      expect(s, isA<SetupNeedsAuth>());
      expect((s as SetupNeedsAuth).rejected, isTrue);
    });

    test('tcp failure → SetupFailed(hostUnreachable-ish), retry re-verifies',
        () async {
      final h = _Harness(reports: [failAt(DiagnosticStep.tcp, 'diagTcpFail'), ok()]);
      await h.coordinator.selectCandidate(candidate);
      var s = h.coordinator.state;
      expect(s, isA<SetupFailed>());
      expect((s as SetupFailed).kind, SetupErrorKind.portClosed);

      await h.coordinator.retry();
      expect(h.coordinator.state, isA<SetupReview>());
      expect(h.diagnostics.calls, hasLength(2));
    });

    test('MQTT without Zigbee2MQTT topics → notZigbee2Mqtt', () async {
      final h = _Harness(
          fetch: const Z2mFetchResult(detected: false, devices: []));
      await h.coordinator.selectCandidate(candidate);
      expect((h.coordinator.state as SetupFailed).kind,
          SetupErrorKind.notZigbee2Mqtt);
    });

    test('Zigbee2MQTT detected but no devices → noDevices', () async {
      final h = _Harness(
          fetch: const Z2mFetchResult(detected: true, devices: []));
      await h.coordinator.selectCandidate(candidate);
      expect(
          (h.coordinator.state as SetupFailed).kind, SetupErrorKind.noDevices);
    });
  });

  group('review and creation', () {
    const candidate = SetupCandidate(
        host: '192.168.1.10', port: 1883, protocol: MqttProtocol.tcp);

    Future<_Harness> inReview() async {
      final h = _Harness();
      await h.coordinator.selectCandidate(candidate);
      return h;
    }

    test('toggle flips selection', () async {
      final h = await inReview();
      h.coordinator.toggleDevice('lamp');
      final s = h.coordinator.state as SetupReview;
      expect(s.rows.firstWhere((r) => r.device.friendlyName == 'lamp').selected,
          isFalse);
      expect(s.selectedCount, 1);
    });

    test('createDashboard → complete with the selected panels only', () async {
      final h = await inReview();
      h.coordinator.toggleDevice('lamp');
      await h.coordinator.createDashboard();
      final s = h.coordinator.state;
      expect(s, isA<SetupComplete>());
      expect((s as SetupComplete).result.panelCount, 1);
    });

    test('save failure → SetupFailed(saveFailed), retry resumes at creation',
        () async {
      final h = await inReview();
      h.creator.error = StateError('disk full');
      await h.coordinator.createDashboard();
      expect((h.coordinator.state as SetupFailed).kind,
          SetupErrorKind.saveFailed);

      h.creator.error = null;
      await h.coordinator.retry();
      expect(h.coordinator.state, isA<SetupComplete>());
      // The retry went straight to creation — no extra ladder run.
      expect(h.diagnostics.calls, hasLength(1));
    });

    test('credentials entered during setup reach the creator', () async {
      final h = _Harness(reports: [failAt(DiagnosticStep.auth, 'diagAuthRejected'), ok()]);
      await h.coordinator.selectCandidate(candidate);
      await h.coordinator.submitCredentials('user', 'secret');
      await h.coordinator.createDashboard();
      expect(h.creator.calls, 1);
    });
  });
}
