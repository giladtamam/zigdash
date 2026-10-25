import 'package:drift/native.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/last_known/last_known_db.dart';
import 'package:zigdash/data/last_known/last_known_store.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';

MqttRxMessage _m(String topic, String payload, DateTime at) => MqttRxMessage(
    topic: topic, payload: payload, receivedAt: at, connectionGeneration: 3);

void main() {
  late LastKnownDb db;
  late LastKnownStore store;
  final now = DateTime(2026, 9, 27, 12);
  setUp(() {
    db = LastKnownDb.test(NativeDatabase.memory());
    store = LastKnownStore(() => db, now: () => now);
  });
  tearDown(() => db.close());

  test('values are written in batches and come back as last known', () async {
    store.record('c1', _m('zigbee2mqtt/lamp', '{"state":"ON"}', now));
    store.record('c1', _m('zigbee2mqtt/lamp', '{"state":"OFF"}', now));
    expect(await db.select(db.lastKnownValues).get(), isEmpty,
        reason: 'nothing written before the flush');

    await store.flush();
    final loaded = await store.load('c1');
    expect(loaded.single.payload, '{"state":"OFF"}');
    expect(loaded.single.connectionGeneration, -1);
    expect(await store.load('c2'), isEmpty);
  });

  test('a flush happens on its own after the batch interval', () {
    fakeAsync((async) {
      store.record('c1', _m('t/a', '1', now));
      async.elapse(const Duration(seconds: 6));
      async.flushMicrotasks();
    });
    expect(db.select(db.lastKnownValues).get(), completion(hasLength(1)));
  });

  test('bridge metadata, command echoes and huge payloads are not kept', () {
    // The device list is kept since 3.1.7 (for the relay); the rest of the
    // bridge is not.
    expect(LastKnownStore.keeps(_m('zigbee2mqtt/bridge/info', '{}', now)),
        isFalse);
    expect(LastKnownStore.keeps(_m('zigbee2mqtt/lamp/set', '{}', now)), isFalse);
    expect(LastKnownStore.keeps(_m('zigbee2mqtt/lamp/get', '{}', now)), isFalse);
    expect(
        LastKnownStore.keeps(
            _m('zigdash/history/0xa1/temperature/2026-10-15', '{}', now)),
        isFalse,
        reason: 'day records are read fresh, never cached');
    expect(LastKnownStore.keeps(_m('t', 'x' * 20000, now)), isFalse);
    expect(LastKnownStore.keeps(_m('zigbee2mqtt/lamp', '{}', now)), isTrue);
  });

  test('values older than 30 days are dropped; a home keeps 2000 at most',
      () async {
    store.record('c1', _m('old', '1', now.subtract(const Duration(days: 31))));
    for (var i = 0; i < LastKnownStore.maxTopics + 5; i++) {
      store.record('c1', _m('t$i', '$i', now.subtract(Duration(minutes: i))));
    }
    await store.flush();
    final loaded = await store.load('c1');
    expect(loaded, hasLength(LastKnownStore.maxTopics));
    expect(loaded.map((m) => m.topic), isNot(contains('old')));
    expect(loaded.map((m) => m.topic), contains('t0'),
        reason: 'the newest are kept');
  });

  test('values of deleted homes are dropped', () async {
    store.record('c1', _m('a', '1', now));
    store.record('c2', _m('b', '2', now));
    await store.flush();
    await store.keepOnly({'c2'});
    expect(await store.load('c1'), isEmpty);
    expect(await store.load('c2'), hasLength(1));
  });

  test('a seeded value reaches a new subscription until live data arrives',
      () async {
    final mgr = MqttManager(
      config: const BrokerConfig(
          id: 'c1', host: 'h', port: 1883, protocol: MqttProtocol.tcp),
      password: '',
    );
    addTearDown(mgr.dispose);
    mgr.seedLastKnown([
      MqttRxMessage(
          topic: 'zigbee2mqtt/lamp',
          payload: '{"state":"ON"}',
          receivedAt: now,
          connectionGeneration: -1),
    ]);
    final first = await mgr.subscribe('zigbee2mqtt/lamp').first;
    expect(first.payload, '{"state":"ON"}');
    expect(first.connectionGeneration, -1);
  });

  // 3.1.7: the device list is kept, for the relay, which never carries it.
  test('keeps the device list, not other bridge data', () {
    MqttRxMessage m(String t, String p) =>
        MqttRxMessage(topic: t, payload: p, receivedAt: now, connectionGeneration: 1);
    expect(LastKnownStore.keeps(m('zigbee2mqtt/bridge/devices', '[${'x' * 100000}]')), isTrue);
    expect(LastKnownStore.keeps(m('zigbee2mqtt/bridge/info', '{}')), isFalse);
    expect(LastKnownStore.keeps(m('zigbee2mqtt/bridge/extensions', '[]')), isFalse);
  });

  test('a saved device list is not replayed at home', () async {
    final mgr = MqttManager(
      config: const BrokerConfig(
          id: 'c1', host: 'h', port: 1883, protocol: MqttProtocol.tcp),
      password: '',
    );
    addTearDown(mgr.dispose);
    mgr.seedLastKnown([
      MqttRxMessage(
          topic: 'zigbee2mqtt/bridge/devices',
          payload: '[]',
          receivedAt: now,
          connectionGeneration: -1),
    ]);
    final got = <MqttRxMessage>[];
    final sub = mgr.subscribe('zigbee2mqtt/bridge/devices').listen(got.add);
    addTearDown(sub.cancel);
    await Future<void>.delayed(Duration.zero);
    expect(got, isEmpty, reason: 'at home the live list always wins');
    expect(mgr.latestUnder('zigbee2mqtt/'), isEmpty);
  });

  // 3.1.7: a wildcard reader opened after the relay delivered starts from
  // this session's messages, never from saved ones.
  test('liveUnder holds this session only', () async {
    final mgr = MqttManager(
      config: const BrokerConfig(
          id: 'c1', host: 'h', port: 1883, protocol: MqttProtocol.tcp),
      password: '',
    );
    addTearDown(mgr.dispose);
    mgr.seedLastKnown([
      MqttRxMessage(
          topic: 'zigdash/automations/rules/old',
          payload: '{}',
          receivedAt: now,
          connectionGeneration: -1),
    ]);
    expect(mgr.liveUnder('zigdash/automations/rules/'), isEmpty);
  });
}
