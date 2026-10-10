import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:typed_data/typed_data.dart' as typed;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/connection_failure.dart';
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
  final StreamController<List<mc.MqttReceivedMessage<mc.MqttMessage>>>
  _updates = StreamController.broadcast();

  bool disconnectCalled = false;

  void emit(String topic, String payload) {
    final message = mc.MqttPublishMessage();
    message.payload.message.addAll(utf8.encode(payload));
    _updates.add([mc.MqttReceivedMessage(topic, message)]);
  }

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

  @override
  mc.Subscription? subscribe(String topic, mc.MqttQos qosLevel) => null;

  final unsubscribed = <String>[];

  /// Protocol version in effect while unsubscribe ran (decides the header).
  final unsubscribeProtocol = <int>[];

  @override
  void unsubscribe(String topic, {expectAcknowledge = false}) {
    unsubscribed.add(topic);
    unsubscribeProtocol.add(mc.Protocol.version);
  }
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

  test('connect() completes (does not hang) and ends in error when every '
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

      expect(
        completed,
        isTrue,
        reason: 'connect() must terminate once both candidates time out',
      );
      expect(manager.status, MqttStatus.error);

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  group('ensureConnected (shortcut taps and app resume, ticket 07)', () {
    const local = BrokerConfig(
      id: 'conn-1',
      host: localHost,
      port: 1883,
      protocol: MqttProtocol.tcp,
      keepAliveSeconds: 60,
    );

    /// Hands out clients in [behaviors] order and records them.
    MqttClientFactory sequence(List<_Behavior> behaviors, List<_FakeClient> made) =>
        (BrokerConfig c, String id, {String? host}) {
          final client = _FakeClient(host ?? c.host, behaviors.removeAt(0));
          made.add(client);
          return client;
        };

    test('a fresh connection is used as is', () {
      fakeAsync((async) {
        final made = <_FakeClient>[];
        final m = MqttManager(
            config: local,
            password: '',
            clientFactory: sequence([_Behavior.succeed], made));
        m.connect();
        async.flushMicrotasks();
        bool? ok;
        m.ensureConnected().then((v) => ok = v);
        async.flushMicrotasks();
        expect(ok, isTrue);
        expect(made, hasLength(1));
        m.dispose();
        async.flushMicrotasks();
      });
    });

    test('a connection silent for longer than keep-alive is replaced at once',
        () {
      fakeAsync((async) {
        var now = DateTime(2026, 10, 10, 12);
        final made = <_FakeClient>[];
        final m = MqttManager(
            config: local,
            password: '',
            now: () => now,
            clientFactory: sequence([_Behavior.succeed, _Behavior.succeed], made));
        m.connect();
        async.flushMicrotasks();
        expect(m.connectionGeneration, 1);
        // The app idled (frozen): no message, no PINGRESP for 2 minutes.
        now = now.add(const Duration(minutes: 2));
        bool? ok;
        m.ensureConnected().then((v) => ok = v);
        async.elapse(const Duration(milliseconds: 50));
        async.flushMicrotasks();
        expect(ok, isTrue);
        expect(made, hasLength(2));
        expect(made.first.disconnectCalled, isTrue);
        expect(m.connectionGeneration, 2);
        m.dispose();
        async.flushMicrotasks();
      });
    });

    test('a hung attempt is abandoned and a new one starts', () {
      fakeAsync((async) {
        final made = <_FakeClient>[];
        final m = MqttManager(
            config: local,
            password: '',
            clientFactory: sequence([_Behavior.hang, _Behavior.succeed], made));
        m.connect();
        // Stuck for 1.5 s: past the 1 s "hung" mark.
        async.elapse(const Duration(milliseconds: 1500));
        expect(m.status, MqttStatus.connecting);
        bool? ok;
        m.ensureConnected().then((v) => ok = v);
        async.elapse(const Duration(milliseconds: 50));
        async.flushMicrotasks();
        expect(ok, isTrue, reason: 'must not wait for the hung attempt');
        expect(made, hasLength(2));
        // The abandoned attempt finishing later changes nothing.
        async.elapse(const Duration(seconds: 10));
        expect(m.status, MqttStatus.connected);
        m.dispose();
        async.flushMicrotasks();
      });
    });

    test('a young attempt is waited for, not doubled', () {
      fakeAsync((async) {
        final made = <_FakeClient>[];
        final m = MqttManager(
            config: local,
            password: '',
            clientFactory: sequence([_Behavior.hang, _Behavior.succeed], made));
        m.connect();
        async.elapse(const Duration(milliseconds: 100));
        m.ensureConnected();
        m.ensureConnected();
        async.elapse(const Duration(milliseconds: 100));
        expect(made, hasLength(1));
        m.dispose();
        async.flushMicrotasks();
      });
    });

    test('a pending backoff is skipped', () {
      fakeAsync((async) {
        final made = <_FakeClient>[];
        final m = MqttManager(
            config: local,
            password: '',
            clientFactory: sequence([_Behavior.fail, _Behavior.succeed], made));
        m.connect();
        async.flushMicrotasks();
        expect(m.status, MqttStatus.error);
        bool? ok;
        m.ensureConnected().then((v) => ok = v);
        async.elapse(const Duration(milliseconds: 50));
        async.flushMicrotasks();
        expect(ok, isTrue);
        expect(made, hasLength(2));
        m.dispose();
        async.flushMicrotasks();
      });
    });

    test('gives up after its timeout when nothing answers', () {
      fakeAsync((async) {
        final made = <_FakeClient>[];
        final m = MqttManager(
            config: local,
            password: '',
            clientFactory:
                sequence(List.filled(10, _Behavior.hang), made));
        bool? ok;
        m.ensureConnected(timeout: const Duration(seconds: 3))
            .then((v) => ok = v);
        async.elapse(const Duration(seconds: 4));
        expect(ok, isFalse);
        m.dispose();
        async.flushMicrotasks();
      });
    });
  });

  test('lastFailure keeps the local failure kind, then clears on connect', () {
    fakeAsync((async) {
      final manager = MqttManager(
        config: configWithRemote(),
        password: '',
        clientFactory: factoryFor({
          localHost: _Behavior.hang,
          remoteHost: _Behavior.fail,
        }),
      );
      expect(manager.lastFailure, isNull);
      manager.connect();
      async.elapse(const Duration(milliseconds: 8100));
      expect(manager.status, MqttStatus.error);
      // The remote refusal doesn't overwrite why the local address failed.
      expect(manager.lastFailure, FailureKind.timedOut);
      manager.dispose();
      async.flushMicrotasks();
    });
    fakeAsync((async) {
      final manager = MqttManager(
        config: configWithRemote(),
        password: '',
        clientFactory: factoryFor({
          localHost: _Behavior.succeed,
          remoteHost: _Behavior.succeed,
        }),
      );
      manager.connect();
      async.elapse(const Duration(milliseconds: 100));
      expect(manager.status, MqttStatus.connected);
      expect(manager.lastFailure, isNull);
      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('dispose() tolerates listeners unsubscribing during subject close', () {
    fakeAsync((async) {
      final manager = MqttManager(
        config: configWithRemote(),
        password: '',
        clientFactory: factoryFor({
          localHost: _Behavior.succeed,
          remoteHost: _Behavior.succeed,
        }),
      );

      // No connect() — _client stays null, so unsubscribe takes the
      // ref-count-only path (no wire UNSUBSCRIBE) and still mutates _subs.
      // This mirrors panelValueProvider's autoDispose teardown: closing a
      // subject runs onDone → unsubscribe → _subs.remove while dispose() is
      // iterating _subs. Before the fix that crashed with
      // ConcurrentModificationError on shutdown / broker switch.
      manager
          .subscribe('a/b')
          .listen((_) {}, onDone: () => manager.unsubscribe('a/b'));

      var disposed = false;
      manager.dispose().then((_) => disposed = true);
      async.flushMicrotasks();

      expect(
        disposed,
        isTrue,
        reason: 'dispose() must complete without concurrent-modification',
      );
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

  test('a failed candidate does not emit a phantom reconnect before the next '
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

  test('received publish has the receive time and connection generation', () {
    fakeAsync((async) {
      final receivedAt = DateTime.utc(2026, 8, 14, 10, 30);
      late _FakeClient client;
      final manager = MqttManager(
        config: configWithRemote(),
        password: '',
        now: () => receivedAt,
        clientFactory: (config, clientId, {host}) =>
            client = _FakeClient(host ?? config.host, _Behavior.succeed),
      );
      MqttRxMessage? received;
      manager.subscribe('devices/+').listen((message) => received = message);

      manager.connect();
      async.flushMicrotasks();
      client.emit('devices/lamp', '{"state":"ON"}');
      async.flushMicrotasks();

      expect(manager.connectionGeneration, 1);
      expect(received?.topic, 'devices/lamp');
      expect(received?.payload, '{"state":"ON"}');
      expect(received?.receivedAt, receivedAt);
      expect(received?.connectionGeneration, 1);

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test(
    'failed reconnect candidate does not increment connection generation',
    () {
      fakeAsync((async) {
        final clients = <_FakeClient>[];
        final behaviors = <_Behavior>[
          _Behavior.succeed,
          _Behavior.fail,
          _Behavior.succeed,
        ];
        final manager = MqttManager(
          config: configWithRemote(),
          password: '',
          clientFactory: (config, clientId, {host}) {
            final client = _FakeClient(
              host ?? config.host,
              behaviors.removeAt(0),
            );
            clients.add(client);
            return client;
          },
        );

        manager.connect();
        async.flushMicrotasks();
        expect(manager.connectionGeneration, 1);

        clients.first._updates.close();
        async.flushMicrotasks();
        clients.first.onDisconnected?.call();
        manager.reconnectNow();
        async.elapse(const Duration(seconds: 1));

        expect(clients, hasLength(3));
        expect(clients[1].disconnectCalled, isTrue);
        expect(
          clients[2].connectionStatus?.state,
          mc.MqttConnectionState.connected,
        );
        expect(manager.connectionGeneration, 2);

        manager.dispose();
        async.flushMicrotasks();
      });
    },
  );

  test('reconnectNow twice while connecting creates only one new client', () {
    fakeAsync((async) {
      final clients = <_FakeClient>[];
      final behaviors = <_Behavior>[_Behavior.succeed, _Behavior.hang];
      final manager = MqttManager(
        config: const BrokerConfig(
          id: 'conn-1',
          host: localHost,
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
        clientFactory: (config, clientId, {host}) {
          final client = _FakeClient(
            host ?? config.host,
            behaviors.removeAt(0),
          );
          clients.add(client);
          return client;
        },
      );

      manager.connect();
      async.flushMicrotasks();
      clients.first.onDisconnected?.call();

      manager.reconnectNow();
      manager.reconnectNow();
      async.flushMicrotasks();

      expect(manager.status, MqttStatus.reconnecting);
      expect(clients, hasLength(2));

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('scheduled retry after connection loss stays reconnecting', () {
    fakeAsync((async) {
      final clients = <_FakeClient>[];
      final behaviors = <_Behavior>[_Behavior.succeed, _Behavior.hang];
      final manager = MqttManager(
        config: const BrokerConfig(
          id: 'conn-1',
          host: localHost,
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
        clientFactory: (config, clientId, {host}) {
          final client = _FakeClient(
            host ?? config.host,
            behaviors.removeAt(0),
          );
          clients.add(client);
          return client;
        },
      );
      final statuses = <MqttStatus>[];
      manager.status$.listen(statuses.add);

      manager.connect();
      async.flushMicrotasks();
      clients.first.onDisconnected?.call();
      async.elapse(const Duration(seconds: 1));

      expect(clients, hasLength(2));
      expect(manager.status, MqttStatus.reconnecting);
      expect(statuses, [
        MqttStatus.disconnected,
        MqttStatus.connecting,
        MqttStatus.connected,
        MqttStatus.reconnecting,
      ]);

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('initial connection attempt stays connecting', () {
    fakeAsync((async) {
      final manager = MqttManager(
        config: const BrokerConfig(
          id: 'conn-1',
          host: localHost,
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
        clientFactory: (config, clientId, {host}) =>
            _FakeClient(host ?? config.host, _Behavior.hang),
      );

      manager.connect();
      async.flushMicrotasks();

      expect(manager.status, MqttStatus.connecting);
      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('late disconnect from an old client does not reconnect again', () {
    fakeAsync((async) {
      final clients = <_FakeClient>[];
      final manager = MqttManager(
        config: const BrokerConfig(
          id: 'conn-1',
          host: localHost,
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
        clientFactory: (config, clientId, {host}) {
          final client = _FakeClient(host ?? config.host, _Behavior.succeed);
          clients.add(client);
          return client;
        },
      );

      manager.connect();
      async.flushMicrotasks();
      final oldDisconnect = clients.first.onDisconnected!;

      manager.disconnect();
      manager.connect();
      async.flushMicrotasks();
      expect(manager.status, MqttStatus.connected);
      expect(manager.connectionGeneration, 2);
      expect(clients, hasLength(2));

      oldDisconnect();
      async.elapse(const Duration(seconds: 2));

      expect(manager.status, MqttStatus.connected);
      expect(manager.connectionGeneration, 2);
      expect(clients, hasLength(2));

      manager.dispose();
      async.flushMicrotasks();
    });
  });

  MqttManager connectedManager(void Function(_FakeClient) onClient) =>
      MqttManager(
        config: const BrokerConfig(
          id: 'conn-1',
          host: localHost,
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
        clientFactory: (config, clientId, {host}) {
          final c = _FakeClient(host ?? config.host, _Behavior.succeed);
          onClient(c);
          return c;
        },
      );

  // Regression: mqtt_client sends UNSUBSCRIBE without the QoS 1 flag in MQTT
  // 3.1 mode and Mosquitto 2 drops the connection for it. The UNSUBSCRIBE
  // also waits out the release grace period (aedes race).
  test('last release sends UNSUBSCRIBE after the grace, in 3.1.1 framing', () {
    fakeAsync((async) {
      late _FakeClient client;
      final manager = connectedManager((c) => client = c);
      manager.connect();
      async.flushMicrotasks();
      final before = mc.Protocol.version;

      final sub = manager.subscribe('zigbee2mqtt/lamp').listen((_) {});
      manager.subscribe('zigbee2mqtt/lamp').listen((_) {});
      manager.unsubscribe('zigbee2mqtt/lamp');
      sub.cancel();
      manager.unsubscribe('zigbee2mqtt/lamp');

      async.elapse(MqttManager.releaseGrace - const Duration(milliseconds: 1));
      expect(client.unsubscribed, isEmpty, reason: 'still in the grace period');

      async.elapse(const Duration(milliseconds: 2));
      expect(client.unsubscribed, ['zigbee2mqtt/lamp']);
      expect(client.unsubscribeProtocol,
          [mc.MqttClientConstants.mqttV311ProtocolVersion]);
      expect(mc.Protocol.version, before);
      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('a watcher returning within the grace reuses the subscription', () {
    fakeAsync((async) {
      late _FakeClient client;
      final manager = connectedManager((c) => client = c);
      manager.connect();
      async.flushMicrotasks();

      final first = <String>[];
      final sub =
          manager.subscribe('zigbee2mqtt/lamp').listen((m) => first.add(m.payload));
      client.emit('zigbee2mqtt/lamp', 'ON');
      async.flushMicrotasks();
      sub.cancel();
      manager.unsubscribe('zigbee2mqtt/lamp');

      async.elapse(const Duration(seconds: 1));
      final again = <String>[];
      manager.subscribe('zigbee2mqtt/lamp').listen((m) => again.add(m.payload));
      async.flushMicrotasks();
      expect(again, ['ON'], reason: 'last value replayed');

      async.elapse(const Duration(seconds: 10));
      expect(client.unsubscribed, isEmpty);
      client.emit('zigbee2mqtt/lamp', 'OFF');
      async.flushMicrotasks();
      expect(again, ['ON', 'OFF']);
      manager.dispose();
      async.flushMicrotasks();
    });
  });

  // Regression (found on the SMHUB, 1.13 device check): a tile off screen
  // past the grace (another tab open) came back with no value, and since
  // devices are asked for state once per connection it then read
  // "Not responding".
  test('a watcher returning after the grace gets this session\'s value', () {
    fakeAsync((async) {
      late _FakeClient client;
      final manager = connectedManager((c) => client = c);
      manager.connect();
      async.flushMicrotasks();

      final sub = manager.subscribe('zigbee2mqtt/cover').listen((_) {});
      client.emit('zigbee2mqtt/cover', '{"position":37}');
      async.flushMicrotasks();
      sub.cancel();
      manager.unsubscribe('zigbee2mqtt/cover');
      async.elapse(MqttManager.releaseGrace + const Duration(seconds: 1));
      expect(client.unsubscribed, ['zigbee2mqtt/cover']);

      final again = <String>[];
      manager
          .subscribe('zigbee2mqtt/cover')
          .listen((m) => again.add(m.payload));
      async.flushMicrotasks();
      expect(again, ['{"position":37}']);
      manager.dispose();
      async.flushMicrotasks();
    });
  });

  test('UNSUBSCRIBE bytes carry the QoS 1 flag (0xA2)', () {
    final msg = mc.MqttUnsubscribeMessage()
        .withMessageIdentifier(1)
        .fromTopic('zigbee2mqtt/lamp');
    final saved = mc.Protocol.version;
    mc.Protocol.version = mc.MqttClientConstants.mqttV311ProtocolVersion;
    final buf = mc.MqttByteBuffer(typed.Uint8Buffer());
    try {
      msg.writeTo(buf);
    } finally {
      mc.Protocol.version = saved;
    }
    expect(buf.buffer![0], 0xA2);
  });
}
