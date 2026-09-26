import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../mqtt/broker_config.dart';
import '../../../mqtt/client_factory.dart';
import '../../../mqtt/endpoint.dart';
import '../../../mqtt/mqtt_manager.dart' show MqttClientFactory;
import '../../discovery/models/z2m_device.dart';
import 'socket_probe.dart';

/// The ladder's steps, in run order.
enum DiagnosticStep { resolve, tcp, connack, auth, devices }

enum StepStatus { pending, running, pass, fail, skipped }

/// Result of one ladder step.
class StepResult {
  const StepResult({
    required this.step,
    required this.status,
    this.detailKey,
    this.deviceCount,
  });

  final DiagnosticStep step;
  final StepStatus status;

  /// Stable key the UI maps to a localized message; null when the step
  /// passed or was skipped.
  final String? detailKey;

  /// Distinct devices seen during the window; only set for the devices step.
  final int? deviceCount;
}

/// The ladder's overall outcome.
class DiagnosticsReport {
  const DiagnosticsReport({
    required this.steps,
    required this.connected,
    required this.candidatesTried,
    this.deviceNames = const [],
  });

  final List<StepResult> steps;

  /// True when the connection succeeded end-to-end. The devices step counts
  /// zero as success — a connected-but-empty broker is a valid, flaggable
  /// outcome, not a ladder failure.
  final bool connected;
  final int candidatesTried;
  final List<String> deviceNames;
}

typedef HostLookup = Future<List<String>> Function(String host);
typedef TcpProbe = Future<void> Function(String host, int port, Duration timeout);

/// Runs the guided-connect diagnostic ladder: resolve → tcp → connack → auth
/// → devices, one candidate at a time ([endpointCandidates] order), reporting
/// per-step results with stable detail keys.
///
/// `MqttManager` is deliberately untouched: the MQTT phases (connack, auth,
/// devices) run on a probe client built through the same injectable
/// [MqttClientFactory] seam the manager uses, and the resolve/tcp phases use
/// injectable socket primitives (real dart:io impls; no-ops on web, where the
/// ws/wss client handles resolution itself).
class ConnectDiagnostics {
  ConnectDiagnostics({
    MqttClientFactory? clientFactory,
    HostLookup? hostLookup,
    TcpProbe? tcpProbe,
    this.deviceWindow = const Duration(seconds: 3),
  })  : _clientFactory = clientFactory ?? buildMqttClient,
        _hostLookup = hostLookup ?? defaultHostLookup,
        _tcpProbe = tcpProbe ?? defaultTcpProbe;

  final MqttClientFactory _clientFactory;
  final HostLookup _hostLookup;
  final TcpProbe _tcpProbe;
  final Duration deviceWindow;

  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) async {
    final candidates = endpointCandidates(config);
    DiagnosticsReport? last;
    var tried = 0;
    for (final cand in candidates) {
      tried++;
      final report = await _runCandidate(cand, config, password, base);
      if (report.connected) {
        return DiagnosticsReport(
          steps: report.steps,
          connected: true,
          candidatesTried: tried,
          deviceNames: report.deviceNames,
        );
      }
      last = report;
    }
    return DiagnosticsReport(
      steps: last?.steps ?? const [],
      connected: false,
      candidatesTried: tried,
    );
  }

  Future<DiagnosticsReport> _runCandidate(
    MqttCandidate cand,
    BrokerConfig config,
    String password,
    String base,
  ) async {
    final steps = <StepResult>[];
    // Mirrors MqttManager's per-candidate budgets: short local probe, standard
    // remote/only-host attempt.
    final budget = Duration(milliseconds: cand.timeoutMs);
    final clientId = 'zd-${DateTime.now().microsecondsSinceEpoch & 0xffffff}';

    // --- resolve ---
    try {
      await _hostLookup(cand.host).timeout(budget);
      steps.add(StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass));
    } on UnsupportedError {
      steps.add(StepResult(step: DiagnosticStep.resolve, status: StepStatus.skipped));
    } on TimeoutException {
      steps.add(StepResult(step: DiagnosticStep.resolve, status: StepStatus.fail, detailKey: 'diagResolveTimeout'));
    } catch (_) {
      steps.add(StepResult(step: DiagnosticStep.resolve, status: StepStatus.fail, detailKey: 'diagResolveFail'));
    }
    if (steps.last.status == StepStatus.fail) return _aborted(steps);

    // --- tcp ---
    try {
      await _tcpProbe(cand.host, config.port, budget);
      steps.add(StepResult(step: DiagnosticStep.tcp, status: StepStatus.pass));
    } on UnsupportedError {
      steps.add(StepResult(step: DiagnosticStep.tcp, status: StepStatus.skipped));
    } on TimeoutException {
      steps.add(StepResult(step: DiagnosticStep.tcp, status: StepStatus.fail, detailKey: 'diagTcpTimeout'));
    } catch (_) {
      steps.add(StepResult(step: DiagnosticStep.tcp, status: StepStatus.fail, detailKey: 'diagTcpFail'));
    }
    if (steps.last.status == StepStatus.fail) return _aborted(steps);

    // --- probe client ---
    final mc.MqttClient client;
    try {
      client = _clientFactory(config, clientId, host: cand.host);
      _configure(client, budget, clientId);
    } on UnsupportedError {
      // e.g. TCP requested on web — the browser cannot open raw sockets.
      steps
        ..add(StepResult(step: DiagnosticStep.connack, status: StepStatus.skipped))
        ..add(StepResult(step: DiagnosticStep.auth, status: StepStatus.skipped))
        ..add(StepResult(step: DiagnosticStep.devices, status: StepStatus.skipped));
      return _aborted(steps);
    }

    // --- connack ---
    // Inspect the status AFTER connect, whether it returned or threw: strict
    // brokers send a refusal CONNACK then drop the socket, which mqtt_client
    // surfaces as a thrown error — the return code is still in the status.
    var answered = false;
    try {
      await client.connect(config.username, password).timeout(budget);
    } on UnsupportedError {
      _dispose(client);
      steps
        ..add(StepResult(step: DiagnosticStep.connack, status: StepStatus.skipped))
        ..add(StepResult(step: DiagnosticStep.auth, status: StepStatus.skipped))
        ..add(StepResult(step: DiagnosticStep.devices, status: StepStatus.skipped));
      return _aborted(steps);
    } on TimeoutException {
      // No CONNACK within budget — fall through to the fail below.
    } catch (_) {
      // Socket-level failure OR a refusal CONNACK + close — the status below
      // distinguishes "broker answered and refused" from "never answered".
    }
    final status = client.connectionStatus;
    final code = status?.returnCode;
    answered = status?.state == mc.MqttConnectionState.connected || code != null;
    if (!answered) {
      _dispose(client);
      steps.add(StepResult(step: DiagnosticStep.connack, status: StepStatus.fail, detailKey: 'diagConnackFail'));
      return _aborted(steps);
    }
    steps.add(StepResult(step: DiagnosticStep.connack, status: StepStatus.pass));

    // --- auth (from the CONNACK return code) ---
    final connected = status?.state == mc.MqttConnectionState.connected;
    if (connected ||
        code == null ||
        code == mc.MqttConnectReturnCode.noneSpecified ||
        code == mc.MqttConnectReturnCode.connectionAccepted) {
      steps.add(StepResult(step: DiagnosticStep.auth, status: StepStatus.pass));
    } else if (code == mc.MqttConnectReturnCode.badUsernameOrPassword ||
        code == mc.MqttConnectReturnCode.notAuthorized) {
      _dispose(client);
      steps.add(StepResult(step: DiagnosticStep.auth, status: StepStatus.fail, detailKey: 'diagAuthRejected'));
      return _aborted(steps);
    } else {
      _dispose(client);
      steps.add(StepResult(step: DiagnosticStep.auth, status: StepStatus.fail, detailKey: 'diagAuthRefused'));
      return _aborted(steps);
    }

    // --- devices ---
    // Counts from two sources merged into one set: the retained
    // `$base/bridge/devices` list (every paired device, including silent ones
    // that never publish) and live `$base/#` state topics.
    final names = <String>{};
    StreamSubscription<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? sub;
    try {
      sub = client.updates?.listen((events) {
        for (final event in events) {
          final pub = event.payload;
          if (pub is! mc.MqttPublishMessage) continue;
          final topic = event.topic;
          if (topic.length <= base.length + 1) continue;
          final rest = topic.substring(base.length + 1);
          if (rest == 'bridge/devices') {
            final payload =
                mc.MqttPublishPayload.bytesToStringAsString(pub.payload.message);
            for (final device in parseBridgeDevices(payload)) {
              if (device.friendlyName.isNotEmpty) names.add(device.friendlyName);
            }
            continue;
          }
          if (rest.startsWith('bridge')) continue;
          if (rest.contains('/')) continue; // availability, /set echoes
          names.add(rest);
        }
      });
      client
        ..subscribe('$base/bridge/devices', mc.MqttQos.atLeastOnce)
        ..subscribe('$base/#', mc.MqttQos.atLeastOnce);
      await Future<void>.delayed(deviceWindow);
    } finally {
      // Fire-and-forget: the probe client is disposed immediately after, and
      // awaiting cancel() here deadlocks the ladder under fakeAsync.
      unawaited(sub?.cancel());
      _dispose(client);
    }
    steps.add(StepResult(
      step: DiagnosticStep.devices,
      status: StepStatus.pass,
      deviceCount: names.length,
    ));
    final sorted = names.toList()..sort();
    return DiagnosticsReport(
      steps: steps,
      connected: true,
      candidatesTried: 1,
      deviceNames: sorted,
    );
  }

  DiagnosticsReport _aborted(List<StepResult> steps) => DiagnosticsReport(
        steps: steps,
        connected: false,
        candidatesTried: 1,
      );

  void _configure(mc.MqttClient client, Duration budget, String clientId) {
    client.logging(on: false);
    client.keepAlivePeriod = 5;
    client.connectTimeoutPeriod = budget.inMilliseconds;
    client.autoReconnect = false; // diagnostics run one shot
    // No will. Setting withWillQos() without a will topic emits a CONNECT that
    // strict brokers (e.g. aedes) reject ("Will QoS must be zero when Will Flag
    // is 0"); the manager and prober were fixed to match this in 1.9.3.
    client.connectionMessage = mc.MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
  }

  void _dispose(mc.MqttClient client) {
    try {
      client.disconnect();
    } catch (_) {
      // Best-effort teardown of a probe client.
    }
  }
}
