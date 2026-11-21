import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../core/analytics/analytics_events.dart' show ManualTestResult;
import '../../../mqtt/broker_config.dart';
import '../../../mqtt/client_factory.dart';
import '../../../mqtt/connection_failure.dart' show isTlsFailure;
import '../../../mqtt/endpoint.dart';
import '../../../mqtt/mqtt_manager.dart' show MqttClientFactory;
import '../../discovery/models/z2m_device.dart';
import '../discovery/hub_probe.dart';
import '../discovery/z2m_frontend.dart';
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
typedef TcpProbe =
    Future<void> Function(String host, int port, Duration timeout);

/// Names the machine at a host from its web pages ([identifyHost]).
typedef HostIdentifier = Future<HubKind?> Function(String host);

/// Asks Zigbee2MQTT's web page at host:port where its broker is (2.10.4).
typedef Z2mBrokerAsk =
    Future<Z2mBrokerSetting?> Function(String host, int port);

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
    BadCertWatcher? watchCert,
    HostLookup? hostLookup,
    TcpProbe? tcpProbe,
    HostIdentifier? identify,
    Z2mBrokerAsk? askZ2m,
    this.deviceWindow = const Duration(seconds: 3),
  }) : _clientFactory = clientFactory ?? buildMqttClient,
       _watchCert = watchCert ?? watchBadCert,
       _hostLookup = hostLookup ?? defaultHostLookup,
       _tcpProbe = tcpProbe ?? defaultTcpProbe,
       _identify = identify,
       _askZ2m = askZ2m;

  final MqttClientFactory _clientFactory;

  /// Tells a certificate the phone doesn't trust apart (3.8.5); the real
  /// one is [watchBadCert].
  final BadCertWatcher _watchCert;
  final HostLookup _hostLookup;
  final TcpProbe _tcpProbe;

  /// Asked only after a refused connection or login (2.9.3), so the
  /// failure can say "this is your Home Assistant, and here is what it
  /// lacks". Without it the general messages stay.
  final HostIdentifier? _identify;

  /// Asked when a Zigbee2MQTT machine refuses 1883 (2.10.4): its settings
  /// may name the broker elsewhere, and "open Mosquitto here" would be
  /// the wrong advice (a German Docker user got it five times, 2026-10-22).
  final Z2mBrokerAsk? _askZ2m;
  final Duration deviceWindow;

  /// Whether Zigbee2MQTT at [host] names its broker on another machine or
  /// under a name of its own (a container); false when it can't be told.
  Future<bool> _brokerElsewhere(String host) async {
    final ask = _askZ2m;
    if (ask == null) return false;
    try {
      final setting = await ask(
        host,
        hubPorts[HubKind.zigbee2mqtt]!,
      ).timeout(const Duration(seconds: 6));
      return setting != null && !setting.sameMachine;
    } catch (_) {
      return false;
    }
  }

  /// The kind of machine at [host], or null when it can't be told.
  Future<HubKind?> _kindOf(String host) async {
    final identify = _identify;
    if (identify == null) return null;
    try {
      return await identify(host).timeout(const Duration(seconds: 4));
    } catch (_) {
      return null;
    }
  }

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
      steps.add(
        StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
      );
    } on UnsupportedError {
      steps.add(
        StepResult(step: DiagnosticStep.resolve, status: StepStatus.skipped),
      );
    } on TimeoutException {
      steps.add(
        StepResult(
          step: DiagnosticStep.resolve,
          status: StepStatus.fail,
          detailKey: _isLocalName(cand.host)
              ? 'diagResolveLocalName'
              : 'diagResolveTimeout',
        ),
      );
    } catch (_) {
      steps.add(
        StepResult(
          step: DiagnosticStep.resolve,
          status: StepStatus.fail,
          detailKey: _isLocalName(cand.host)
              ? 'diagResolveLocalName'
              : 'diagResolveFail',
        ),
      );
    }
    if (steps.last.status == StepStatus.fail) return _aborted(steps);

    // --- tcp ---
    try {
      await _tcpProbe(cand.host, config.port, budget);
      steps.add(StepResult(step: DiagnosticStep.tcp, status: StepStatus.pass));
    } on UnsupportedError {
      steps.add(
        StepResult(step: DiagnosticStep.tcp, status: StepStatus.skipped),
      );
    } on TimeoutException {
      steps.add(
        StepResult(
          step: DiagnosticStep.tcp,
          status: StepStatus.fail,
          detailKey: 'diagTcpTimeout',
        ),
      );
    } catch (_) {
      // Refused: something is there. Home Assistant without the Mosquitto
      // add-on refuses 1883 (a US user, 2026-10-17, went from here to
      // giving up); so does an SMLIGHT hub with Allow External off, and a
      // Mosquitto 2 with no `listener` line, which listens only locally
      // (2.9.5: manual_test tcp was the biggest dead end, Oct 7-19).
      // Only on the usual port: another port refused says nothing about
      // whether a broker runs there.
      final kind = config.port == 1883 ? await _kindOf(cand.host) : null;
      final elsewhere =
          kind == HubKind.zigbee2mqtt && await _brokerElsewhere(cand.host);
      steps.add(
        StepResult(
          step: DiagnosticStep.tcp,
          status: StepStatus.fail,
          detailKey: switch (kind) {
            HubKind.homeAssistant => 'diagTcpHaNoBroker',
            HubKind.smlight => 'diagTcpSmlightClosed',
            HubKind.zigbee2mqtt =>
              elsewhere ? 'diagTcpZ2mBrokerElsewhere' : 'diagTcpZ2mNoBroker',
            null => 'diagTcpFail',
          },
        ),
      );
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
        ..add(
          StepResult(step: DiagnosticStep.connack, status: StepStatus.skipped),
        )
        ..add(StepResult(step: DiagnosticStep.auth, status: StepStatus.skipped))
        ..add(
          StepResult(step: DiagnosticStep.devices, status: StepStatus.skipped),
        );
      return _aborted(steps);
    }
    // Per candidate: the local try's certificate says nothing of the
    // remote one's (3.8.5).
    var sawBadCert = false;
    _watchCert(client, config, () => sawBadCert = true);

    // --- connack ---
    // Inspect the status AFTER connect, whether it returned or threw: strict
    // brokers send a refusal CONNACK then drop the socket, which mqtt_client
    // surfaces as a thrown error — the return code is still in the status.
    var answered = false;
    Object? connectError;
    try {
      await client.connect(config.username, password).timeout(budget);
    } on UnsupportedError {
      _dispose(client);
      steps
        ..add(
          StepResult(step: DiagnosticStep.connack, status: StepStatus.skipped),
        )
        ..add(StepResult(step: DiagnosticStep.auth, status: StepStatus.skipped))
        ..add(
          StepResult(step: DiagnosticStep.devices, status: StepStatus.skipped),
        );
      return _aborted(steps);
    } on TimeoutException {
      // No CONNACK within budget — fall through to the fail below.
    } catch (e) {
      // Socket-level failure OR a refusal CONNACK + close — the status below
      // distinguishes "broker answered and refused" from "never answered".
      connectError = e;
    }
    final status = client.connectionStatus;
    final code = status?.returnCode;
    // mqtt_client starts every attempt at `noneSpecified` and only replaces
    // it when a CONNACK arrives, so that value means no answer at all. It
    // used to count as an answer that passed the login, and the device step
    // then threw on a dead client: setup showed "unknown" (a Spanish user on
    // Home Assistant, 2026-10-17).
    answered =
        status?.state == mc.MqttConnectionState.connected ||
        (code != null && code != mc.MqttConnectReturnCode.noneSpecified);
    if (!answered) {
      _dispose(client);
      steps.add(
        StepResult(
          step: DiagnosticStep.connack,
          status: StepStatus.fail,
          // A TLS failure first (3.8.5): it used to read as "no answer",
          // and retrying can never help. With a login the broker was
          // reached and went quiet on it; the Mosquitto add-on checks
          // logins against Home Assistant's users.
          detailKey: sawBadCert
              ? 'diagTlsUntrusted'
              : isTlsFailure(connectError)
              ? 'diagTlsFailed'
              : config.username == null
              ? 'diagConnackFail'
              : 'diagLoginNoAnswer',
        ),
      );
      return _aborted(steps);
    }
    steps.add(
      StepResult(step: DiagnosticStep.connack, status: StepStatus.pass),
    );

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
      steps.add(
        StepResult(
          step: DiagnosticStep.auth,
          status: StepStatus.fail,
          detailKey: await _kindOf(cand.host) == HubKind.homeAssistant
              ? 'diagAuthRejectedHa'
              : 'diagAuthRejected',
        ),
      );
      return _aborted(steps);
    } else {
      _dispose(client);
      steps.add(
        StepResult(
          step: DiagnosticStep.auth,
          status: StepStatus.fail,
          detailKey: 'diagAuthRefused',
        ),
      );
      return _aborted(steps);
    }

    // Accepted, then dropped before we could listen: nothing to subscribe on.
    if (status?.state != mc.MqttConnectionState.connected) {
      _dispose(client);
      steps.add(
        StepResult(
          step: DiagnosticStep.devices,
          status: StepStatus.fail,
          detailKey: 'diagConnackFail',
        ),
      );
      return _aborted(steps);
    }

    // --- devices ---
    // Counts from two sources merged into one set: the retained
    // `$base/bridge/devices` list (every paired device, including silent ones
    // that never publish) and live `$base/#` state topics.
    final names = <String>{};
    // Unnamed devices read "Motion sensor f66f", not their address (2.7.1).
    final shown = <String, String>{};
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
            final payload = mc.MqttPublishPayload.bytesToStringAsString(
              pub.payload.message,
            );
            for (final device in parseBridgeDevices(payload)) {
              if (device.friendlyName.isEmpty) continue;
              names.add(device.friendlyName);
              shown[device.friendlyName] = device.displayName;
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
    } on mc.ConnectionException {
      // Dropped between the CONNACK and the subscribe.
      steps.add(
        StepResult(
          step: DiagnosticStep.devices,
          status: StepStatus.fail,
          detailKey: 'diagConnackFail',
        ),
      );
      return _aborted(steps);
    } finally {
      // Fire-and-forget: the probe client is disposed immediately after, and
      // awaiting cancel() here deadlocks the ladder under fakeAsync.
      unawaited(sub?.cancel());
      _dispose(client);
    }
    steps.add(
      StepResult(
        step: DiagnosticStep.devices,
        status: StepStatus.pass,
        deviceCount: names.length,
      ),
    );
    final sorted = [for (final n in names) shown[n] ?? n]..sort();
    return DiagnosticsReport(
      steps: steps,
      connected: true,
      candidatesTried: 1,
      deviceNames: sorted,
    );
  }

  DiagnosticsReport _aborted(List<StepResult> steps) =>
      DiagnosticsReport(steps: steps, connected: false, candidatesTried: 1);

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

/// A `.local` name, which Android often cannot look up (2.9.3).
bool _isLocalName(String host) =>
    host.toLowerCase().replaceFirst(RegExp(r'\.$'), '').endsWith('.local');

/// How a ladder run ends, for analytics: connected, or its first failed
/// step (2.7.2), or the more precise reason its message gave (2.9.3,
/// 2.9.5).
ManualTestResult manualTestResult(DiagnosticsReport report) {
  if (report.connected) return ManualTestResult.connected;
  final failure = report.steps
      .where((s) => s.status == StepStatus.fail)
      .firstOrNull;
  switch (failure?.detailKey) {
    case 'diagResolveLocalName':
      return ManualTestResult.localName;
    case 'diagTcpHaNoBroker':
      return ManualTestResult.haNoBroker;
    case 'diagTcpSmlightClosed':
      return ManualTestResult.smlightClosed;
    case 'diagTcpZ2mNoBroker':
      return ManualTestResult.z2mNoBroker;
    case 'diagTcpZ2mBrokerElsewhere':
      return ManualTestResult.z2mBrokerElsewhere;
    case 'diagAuthRejectedHa':
      return ManualTestResult.haLogin;
    case 'diagTlsUntrusted':
      return ManualTestResult.tlsUntrusted;
    case 'diagTlsFailed':
      return ManualTestResult.tlsFailed;
  }
  return switch (failure?.step) {
    DiagnosticStep.resolve => ManualTestResult.resolve,
    DiagnosticStep.tcp || null => ManualTestResult.tcp,
    DiagnosticStep.connack => ManualTestResult.connack,
    DiagnosticStep.auth || DiagnosticStep.devices => ManualTestResult.auth,
  };
}
