import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/endpoint.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';

/// How a fake client's [connect] behaves — the three cases a candidate hits.
enum _Behavior {
  /// TCP connect never answers (the real-world hang that motivated the fix).
  hang,

  /// Connects and reports `connected`.
  succeed,

  /// Connect throws synchronously (refused / unreachable).
  fail,
}

/// Minimal [mc.MqttClient] that overrides only what [MqttManager] touches during
/// a connect attempt. Lets us drive connect/timeout/fallback paths under
/// [fakeAsync] without a live broker.
class _FakeClient extends mc.MqttClient {
  _FakeClient(String server, this.behavior)
      : super.withPort(server, 'cid', 1883);

  final _Behavior behavior;
  final mc.MqttClientConnectionStatus _status = mc.MqttClientConnectionStatus();
  final StreamController<List<mc.MqttReceivedMessage<mc.MqttMessage>>> _updates =
      StreamController.broadcast();

  bool disconnectCalled = false;

  @override
  Future<mc.MqttClientConnectionStatus?> connect([String? u, String? p]) {
    switch (behavior) {
      case _Behavior.hang:
        // Never completes — mqtt_client's Socket.connect has no timeout, so this
        // is exactly the future MqttManager must bound with .timeout().
        return Completer<mc.MqttClientConnectionStatus?>().future;
      case _Behavior.succeed:
        _status.state = mc.MqttConnectionState.connected;
        return Future.value(_status);
      case _Behavior.fail:
        return Future.error(Exception('connection refused'));
    }
  }

  @override
  mc.MqttClientConnectionStatus? get connectionStatus => _status;

  @override
  void disconnect() {
    disconnectCalled = true;
    _status.state = mc.MqttConnectionState.disconnected;
    // Faithful to mqtt_client: a solicited disconnect fires onDisconnected.
    // This is what would trigger a phantom reconnect if the manager wired the
    // callback before a candidate actually reached `connected`.
    onDisconnected?.call();
  }

  @override
  Stream<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? get updates =>
      _updates.stream;
}

void main() {
  const localHost = '192.168.1.50';
  const remoteHost = '100.64.0.1';

  BrokerConfig configWithRemote() => const BrokerConfig(
        id: 'conn-1',
        host: localHost,
        port: 1883,
        protocol: MqttProtocol.tcp,
        remoteHost: remoteHost,
      );

  /// Factory that returns a fake whose behavior is chosen per host.
  MqttClientFactory factoryFor(Map<String, _Behavior> byHost) {
    return (BrokerConfig config, String clientId, {String? host}) {
      final h = host ?? config.host;
      return _FakeClient(h, byHost[h]!);
    };
  }

  test(
      'connect() completes (does not hang) and ends in error when every '
      'candidate socket hangs', () {
    fakeAsync((async) {
      final manager = MqttManager(
        config: configWithRemote(),
        password: '',
        clientFactory: factoryFor({
          localHost: _Behavior.hang,
          remoteHost: _Behavior.hang,
        }),
      );

      var completed = false;
      manager.connect().then((_) => completed = true);

      // Local probe (3s) then remote (5s) must each time out instead of
      // blocking forever. Before the fix, the awaited connect never returned
      // and `completed` would stay false.
      async.elapse(const Duration(milliseconds: 8100));

      expect(completed, isTrue,
          reason: 'connect() must terminate once both candidates time out');
      expect(manager.status, MqttStatus.error);

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('falls back to the remote host when the local probe times out', () {
    fakeAsync((async) {
      final manager = MqttManager(
        config: configWithRemote(),
        password: '',
        clientFactory: factoryFor({
          localHost: _Behavior.hang,
          remoteHost: _Behavior.succeed,
        }),
      );

      manager.connect();
      // Past the 3s local-probe budget; the remote candidate then succeeds.
      async.elapse(const Duration(milliseconds: 3100));

      expect(manager.status, MqttStatus.connected);
      expect(manager.activeEndpoint, MqttEndpoint.remote);

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test(
      'a failed candidate does not emit a phantom reconnect before the next '
      'candidate connects', () {
    fakeAsync((async) {
      final manager = MqttManager(
        config: configWithRemote(),
        password: '',
        clientFactory: factoryFor({
          localHost: _Behavior.fail,
          remoteHost: _Behavior.succeed,
        }),
      );

      final statuses = <MqttStatus>[];
      final sub = manager.status$.listen(statuses.add);

      manager.connect();
      async.elapse(const Duration(seconds: 1));

      // The local candidate fails and is disconnected, but onDisconnected is
      // wired only after a candidate reaches `connected`, so no `reconnecting`
      // should ever be emitted on the way to a successful remote connect.
      expect(statuses, isNot(contains(MqttStatus.reconnecting)));
      expect(manager.status, MqttStatus.connected);
      expect(manager.activeEndpoint, MqttEndpoint.remote);

      sub.cancel();
      manager.dispose();
      async.flushMicrotasks();
    });
  });
}
