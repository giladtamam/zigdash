import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/mqtt/broker_config.dart';

/// How the fake client's [connect] behaves.
enum _ConnectBehavior {
  /// Connects and reports `connected` (returnCode accepted).
  connected,

  /// Broker answers but rejects the credentials.
  authRejected,

  /// Socket-level failure (refused / unreachable).
  refused,

  /// Never answers — the case the per-step timeout must bound.
  hang,
}

class _FakeClient extends mc.MqttClient {
  _FakeClient(String server, this.behavior)
      : super.withPort(server, 'cid', 1883);

  final _ConnectBehavior behavior;
  final _status = mc.MqttClientConnectionStatus();
  final _updates =
      StreamController<List<mc.MqttReceivedMessage<mc.MqttMessage>>>.broadcast();

  final subscribedTopics = <String>[];
  bool disconnectedCalled = false;

  @override
  Future<mc.MqttClientConnectionStatus?> connect([String? u, String? p]) {
    switch (behavior) {
      case _ConnectBehavior.connected:
        _status.state = mc.MqttConnectionState.connected;
        _status.returnCode = mc.MqttConnectReturnCode.connectionAccepted;
        return Future.value(_status);
      case _ConnectBehavior.authRejected:
        _status.returnCode = mc.MqttConnectReturnCode.badUsernameOrPassword;
        return Future.value(_status);
      case _ConnectBehavior.refused:
        return Future.error(Exception('connection refused'));
      case _ConnectBehavior.hang:
        return Completer<mc.MqttClientConnectionStatus?>().future;
    }
  }

  @override
  mc.MqttClientConnectionStatus? get connectionStatus =>
      // Faithful to mqtt_client: after a failed connect with no CONNACK
      // (refused / hang) the handler's status is null; a CONNACK refusal
      // (authRejected) leaves the return code readable.
      (behavior == _ConnectBehavior.refused || behavior == _ConnectBehavior.hang)
          ? null
          : _status;

  @override
  Stream<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? get updates =>
      _updates.stream;

  @override
  mc.Subscription? subscribe(String topic, mc.MqttQos qosLevel) {
    subscribedTopics.add(topic);
    return null;
  }

  @override
  void unsubscribe(String topic, {expectAcknowledge = false}) {}

  @override
  void disconnect() {
    disconnectedCalled = true;
    _status.state = mc.MqttConnectionState.disconnected;
  }

  /// Emits a publish on [topic] exactly as a live broker would deliver it.
  void emit(String topic, String payload) {
    final msg = mc.MqttPublishMessage();
    msg.payload.message.addAll(utf8.encode(payload));
    _updates.add([mc.MqttReceivedMessage(topic, msg)]);
  }
}

void main() {
  const host = '192.168.1.50';
  const remoteHost = '100.64.0.1';
  const base = 'zigbee2mqtt';

  BrokerConfig config({String? remote}) => BrokerConfig(
        id: 'conn-1',
        host: host,
        port: 1883,
        protocol: MqttProtocol.tcp,
        remoteHost: remote,
      );

  Future<List<String>> okLookup(String h) async => <String>[h];
  Future<void> okProbe(String h, int p, Duration t) async {}

  ConnectDiagnostics diagnostics({
    _ConnectBehavior behavior = _ConnectBehavior.connected,
    _ConnectBehavior? remoteBehavior,
    HostLookup? hostLookup,
    TcpProbe? tcpProbe,
    List<String>? builtHosts,
  }) {
    final seen = builtHosts ?? <String>[];
    return ConnectDiagnostics(
      hostLookup: hostLookup ?? okLookup,
      tcpProbe: tcpProbe ?? okProbe,
      clientFactory: (cfg, clientId, {host}) {
        seen.add(host ?? cfg.host);
        final h = host ?? cfg.host;
        final b = h == remoteHost ? (remoteBehavior ?? behavior) : behavior;
        return _FakeClient(h, b);
      },
      deviceWindow: const Duration(seconds: 3),
    );
  }

  group('ladder steps', () {
    test('reports all five steps passing with a device count on success', () {
      fakeAsync((async) {
        final builtHosts = <String>[];
        final client = _FakeClient(host, _ConnectBehavior.connected);
        final d = ConnectDiagnostics(
          hostLookup: okLookup,
          tcpProbe: okProbe,
          clientFactory: (cfg, id, {host}) {
            builtHosts.add(host ?? cfg.host);
            return client;
          },
          deviceWindow: const Duration(seconds: 3),
        );

        DiagnosticsReport? report;
        d.run(config: config(), password: '', base: base)
            .then((r) => report = r);

        // Let the ladder reach the devices window (listener attached, SUBSCRIBE
        // sent), then deliver the retained device list + live topics.
        async.flushMicrotasks();
        client
          ..emit(
            '$base/bridge/devices',
            jsonEncode([
              {'friendly_name': 'garage_sensor', 'type': 'EndDevice'},
              {'friendly_name': 'living_plug', 'type': 'EndDevice'},
            ]),
          )
          ..emit('$base/office_light', '{"state":"ON"}')
          ..emit('$base/garage/set', '{"state":"OFF"}') // set echo — ignored
          ..emit('$base/bridge/log', '{"type":"pairing"}') // bridge — ignored
          ..emit('$base/office_light/availability', 'online') // — ignored
          ..emit('$base/lamp', '{"state":"OFF"}');
        async.elapse(const Duration(seconds: 3));

        expect(report, isNotNull);
        expect(report!.connected, isTrue);
        expect(
          report!.steps.map((s) => s.step),
          [DiagnosticStep.resolve, DiagnosticStep.tcp, DiagnosticStep.connack,
           DiagnosticStep.auth, DiagnosticStep.devices],
        );
        for (final s in report!.steps) {
          expect(s.status, StepStatus.pass, reason: 'step ${s.step}');
        }
        // 2 from the retained bridge/devices list + 2 live topics.
        expect(report!.steps.last.deviceCount, 4);
        expect(
          report!.deviceNames,
          containsAll(['office_light', 'lamp', 'garage_sensor', 'living_plug']),
        );
        expect(report!.candidatesTried, 1);
        expect(client.subscribedTopics, containsAll(['$base/#', '$base/bridge/devices']));
      });
    });

    test('retained bridge/devices counts devices that never publish', () {
      fakeAsync((async) {
        final client = _FakeClient(host, _ConnectBehavior.connected);
        final d = ConnectDiagnostics(
          hostLookup: okLookup,
          tcpProbe: okProbe,
          clientFactory: (cfg, id, {host}) => client,
          deviceWindow: const Duration(seconds: 3),
        );
        DiagnosticsReport? report;
        d.run(config: config(), password: '', base: base)
            .then((r) => report = r);
        async.flushMicrotasks();
        // All three devices are silent (no live state topics at all).
        client.emit(
          '$base/bridge/devices',
          jsonEncode([
            {'friendly_name': 'a_sensor', 'type': 'EndDevice'},
            {'friendly_name': 'b_plug', 'type': 'EndDevice'},
            {'friendly_name': 'c_lamp', 'type': 'EndDevice'},
          ]),
        );
        async.elapse(const Duration(seconds: 3));

        expect(report!.connected, isTrue);
        expect(report!.steps.last.deviceCount, 3);
        expect(report!.deviceNames, ['a_sensor', 'b_plug', 'c_lamp']);
      });
    });

    test('zero devices is still a successful connection (count 0)', () {
      fakeAsync((async) {
        final d = diagnostics();
        DiagnosticsReport? report;
        d.run(config: config(), password: '', base: base)
            .then((r) => report = r);
        async.elapse(const Duration(seconds: 3));
        expect(report!.connected, isTrue);
        expect(report!.steps.last.deviceCount, 0);
      });
    });

    test('resolve failure aborts before building any client', () {
      fakeAsync((async) {
        var factoryCalls = 0;
        final d = ConnectDiagnostics(
          hostLookup: (_) async => throw Exception('no such host'),
          tcpProbe: okProbe,
          clientFactory: (cfg, id, {host}) {
            factoryCalls++;
            return _FakeClient(host ?? cfg.host, _ConnectBehavior.connected);
          },
        );
        DiagnosticsReport? report;
        d.run(config: config(), password: '').then((r) => report = r);
        async.flushMicrotasks();

        expect(report!.connected, isFalse);
        expect(report!.steps.single.step, DiagnosticStep.resolve);
        expect(report!.steps.single.status, StepStatus.fail);
        expect(report!.steps.single.detailKey, 'diagResolveFail');
        expect(factoryCalls, 0);
      });
    });

    test('tcp failure reports a fail on the tcp step', () {
      fakeAsync((async) {
        final d = diagnostics(
          tcpProbe: (h, p, t) async => throw Exception('refused'),
        );
        DiagnosticsReport? report;
        d.run(config: config(), password: '').then((r) => report = r);
        async.flushMicrotasks();

        expect(report!.connected, isFalse);
        expect(report!.steps[0].status, StepStatus.pass);
        expect(report!.steps[1].step, DiagnosticStep.tcp);
        expect(report!.steps[1].status, StepStatus.fail);
        expect(report!.steps[1].detailKey, 'diagTcpFail');
        expect(report!.steps.length, 2);
      });
    });

    test('a hung resolver times out with the resolve timeout detail', () {
      fakeAsync((async) {
        final d = diagnostics(
          hostLookup: (_) => Completer<List<String>>().future,
        );
        DiagnosticsReport? report;
        d.run(config: config(), password: '').then((r) => report = r);
        // Standard candidate budget is 5s.
        async.elapse(const Duration(milliseconds: 5001));

        expect(report!.connected, isFalse);
        expect(report!.steps.single.detailKey, 'diagResolveTimeout');
      });
    });

    test('broker refusal fails the connack step', () {
      fakeAsync((async) {
        final d = diagnostics(behavior: _ConnectBehavior.refused);
        DiagnosticsReport? report;
        d.run(config: config(), password: '').then((r) => report = r);
        async.flushMicrotasks();

        expect(report!.steps[2].step, DiagnosticStep.connack);
        expect(report!.steps[2].status, StepStatus.fail);
        expect(report!.steps[2].detailKey, 'diagConnackFail');
        expect(report!.connected, isFalse);
      });
    });

    test('a hung broker connect times out on the connack step', () {
      fakeAsync((async) {
        final d = diagnostics(behavior: _ConnectBehavior.hang);
        DiagnosticsReport? report;
        d.run(config: config(), password: '').then((r) => report = r);
        async.elapse(const Duration(milliseconds: 5001));

        expect(report!.steps[2].status, StepStatus.fail);
        expect(report!.steps[2].detailKey, 'diagConnackFail');
        expect(report!.connected, isFalse);
      });
    });

    test('credential rejection fails the auth step with the auth detail', () {
      fakeAsync((async) {
        final d = diagnostics(behavior: _ConnectBehavior.authRejected);
        DiagnosticsReport? report;
        d.run(config: config(), password: 'wrong').then((r) => report = r);
        async.flushMicrotasks();

        expect(report!.steps[3].step, DiagnosticStep.auth);
        expect(report!.steps[3].status, StepStatus.fail);
        expect(report!.steps[3].detailKey, 'diagAuthRejected');
        expect(report!.connected, isFalse);
      });
    });

    test('web platform: tcp probe and client build report skipped', () {
      fakeAsync((async) {
        final d = ConnectDiagnostics(
          hostLookup: (_) async => throw UnsupportedError('no dart:io'),
          tcpProbe: (h, p, t) async => throw UnsupportedError('no dart:io'),
          clientFactory: (cfg, id, {host}) =>
              throw UnsupportedError('TCP unavailable on web'),
        );
        DiagnosticsReport? report;
        d.run(config: config(), password: '').then((r) => report = r);
        async.flushMicrotasks();

        final byStep = {for (final s in report!.steps) s.step: s.status};
        expect(byStep[DiagnosticStep.resolve], StepStatus.skipped);
        expect(byStep[DiagnosticStep.tcp], StepStatus.skipped);
        expect(byStep[DiagnosticStep.connack], StepStatus.skipped);
        expect(byStep[DiagnosticStep.auth], StepStatus.skipped);
        expect(byStep[DiagnosticStep.devices], StepStatus.skipped);
        expect(report!.connected, isFalse);
      });
    });
  });

  group('remote fallback', () {
    test('falls back to the remote host when the local one fails', () {
      fakeAsync((async) {
        final builtHosts = <String>[];
        final d = diagnostics(
          behavior: _ConnectBehavior.refused,
          remoteBehavior: _ConnectBehavior.connected,
          builtHosts: builtHosts,
        );
        DiagnosticsReport? report;
        d.run(config: config(remote: remoteHost), password: '')
            .then((r) => report = r);
        async.elapse(const Duration(seconds: 3));

        expect(report!.connected, isTrue);
        expect(report!.candidatesTried, 2);
        expect(builtHosts, [host, remoteHost]);
      });
    });

    test('reports the last candidate when every host fails', () {
      fakeAsync((async) {
        final d = diagnostics(behavior: _ConnectBehavior.refused);
        DiagnosticsReport? report;
        d.run(config: config(remote: remoteHost), password: '')
            .then((r) => report = r);
        async.flushMicrotasks();

        expect(report!.connected, isFalse);
        expect(report!.candidatesTried, 2);
        // Steps belong to the last (remote) candidate.
        expect(report!.steps[2].status, StepStatus.fail);
      });
    });
  });
}
