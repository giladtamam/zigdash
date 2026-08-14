import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

class _FakeMqttManager extends MqttManager {
  _FakeMqttManager()
    : super(
        config: const BrokerConfig(
          id: 'connection',
          host: 'localhost',
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
      );

  final messages = BehaviorSubject<MqttRxMessage>();
  final statuses = BehaviorSubject<MqttStatus>.seeded(MqttStatus.disconnected);
  int generation = 0;

  @override
  int get connectionGeneration => generation;

  @override
  Stream<MqttStatus> get status$ => statuses.stream;

  @override
  Stream<MqttRxMessage> subscribe(String pattern) => messages.stream;

  @override
  void unsubscribe(String pattern) {}

  @override
  Future<void> dispose() async {
    await messages.close();
    await statuses.close();
    await super.dispose();
  }
}

MqttRxMessage _message({required int generation, Object payload = 'on'}) =>
    MqttRxMessage(
      topic: 'device/state',
      payload: '{"state":"$payload"}',
      receivedAt: DateTime.utc(2026, 8, 14, 12),
      connectionGeneration: generation,
    );

void main() {
  group('PanelValueSnapshot.fromMessage', () {
    test('is fresh only while connected on the current generation', () {
      final message = _message(generation: 3);

      final fresh = PanelValueSnapshot.fromMessage(
        message: message,
        value: 'on',
        status: MqttStatus.connected,
        currentGeneration: 3,
      );
      expect(fresh.value, 'on');
      expect(fresh.receivedAt, message.receivedAt);
      expect(fresh.connectionGeneration, 3);
      expect(fresh.freshness, PanelFreshness.fresh);
      expect(
        PanelValueSnapshot.fromMessage(
          message: message,
          value: 'on',
          status: MqttStatus.disconnected,
          currentGeneration: 3,
        ).freshness,
        PanelFreshness.stale,
      );
      expect(
        PanelValueSnapshot.fromMessage(
          message: message,
          value: 'on',
          status: MqttStatus.connected,
          currentGeneration: 4,
        ).freshness,
        PanelFreshness.stale,
      );
    });
  });

  test(
    'snapshot stays stale across reconnect until a current message arrives',
    () async {
      final manager = _FakeMqttManager();
      final container = ProviderContainer(
        overrides: [
          mqttManagerProvider.overrideWith((ref, id) async => manager),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(manager.dispose);
      const key = PanelStreamKey(
        connectionId: 'connection',
        topic: 'device/state',
        jsonPath: 'state',
      );
      final states = <AsyncValue<PanelValueSnapshot>>[];
      final subscription = container.listen(
        panelValueSnapshotProvider(key),
        (_, next) => states.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await Future<void>.delayed(Duration.zero);
      expect(states.last, isA<AsyncLoading<PanelValueSnapshot>>());

      manager.generation = 1;
      manager.statuses.add(MqttStatus.connected);
      manager.messages.add(_message(generation: 1));
      await Future<void>.delayed(Duration.zero);
      expect(states.last.requireValue.value, 'on');
      expect(states.last.requireValue.freshness, PanelFreshness.fresh);

      manager.statuses.add(MqttStatus.disconnected);
      await Future<void>.delayed(Duration.zero);
      expect(states.last.requireValue.freshness, PanelFreshness.stale);

      manager.statuses.add(MqttStatus.reconnecting);
      await Future<void>.delayed(Duration.zero);
      expect(states.last.requireValue.freshness, PanelFreshness.stale);

      manager.generation = 2;
      manager.statuses.add(MqttStatus.connected);
      await Future<void>.delayed(Duration.zero);
      expect(states.last.requireValue.value, 'on');
      expect(states.last.requireValue.freshness, PanelFreshness.stale);

      manager.messages.add(_message(generation: 2, payload: 'off'));
      await Future<void>.delayed(Duration.zero);
      expect(states.last.requireValue.value, 'off');
      expect(states.last.requireValue.freshness, PanelFreshness.fresh);
    },
  );
}
