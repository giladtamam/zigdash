import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:zigdash/alerts/alert_push.dart';
import 'package:zigdash/alerts/alerts_config.dart';
import 'package:zigdash/alerts/alerts_service.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';

/// A broker that records publishes and lets a test feed messages.
class _Broker extends mc.MqttClient {
  _Broker() : super.withPort('h', 'c', 1883);
  final sent = <(String, String, bool)>[];
  final _status = mc.MqttClientConnectionStatus();
  final _updates =
      StreamController<List<mc.MqttReceivedMessage<mc.MqttMessage>>>.broadcast();

  @override
  Future<mc.MqttClientConnectionStatus?> connect([String? u, String? p]) {
    _status.state = mc.MqttConnectionState.connected;
    return Future.value(_status);
  }

  @override
  mc.MqttClientConnectionStatus? get connectionStatus => _status;
  @override
  void disconnect() => _status.state = mc.MqttConnectionState.disconnected;
  @override
  Stream<List<mc.MqttReceivedMessage<mc.MqttMessage>>>? get updates =>
      _updates.stream;
  @override
  mc.Subscription? subscribe(String topic, mc.MqttQos qosLevel) => null;
  @override
  void unsubscribe(String topic, {expectAcknowledge = false}) {}

  void emit(String topic, String payload) {
    final m = mc.MqttPublishMessage();
    m.payload.message.addAll(utf8.encode(payload));
    _updates.add([mc.MqttReceivedMessage(topic, m)]);
  }

  @override
  int publishMessage(String topic, mc.MqttQos qualityOfService,
      typed.Uint8Buffer data,
      {bool retain = false}) {
    sent.add((topic, utf8.decode(data), retain));
    return 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late SharedPreferences prefs;
  late _Broker broker;
  late MqttManager mgr;
  late AlertsService service;
  final t = DateTime(2026, 10, 10);

  setUp(() async {
    SharedPreferences.setMockInitialValues({'alerts.phone.id': 'me'});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.test(NativeDatabase.memory());
    await db.into(db.connections).insert(ConnectionsCompanion.insert(
        id: 'home', name: 'My Home', host: 'h', port: 1883,
        protocol: MqttProtocol.tcp, createdAt: t, updatedAt: t));
    broker = _Broker();
    mgr = MqttManager(
      config: const BrokerConfig(
          id: 'home', host: 'h', port: 1883, protocol: MqttProtocol.tcp),
      password: '',
      clientFactory: (c, id, {host}) => broker,
    );
    await mgr.ensureConnected();
    service = AlertsService(db, prefs, (_) async => mgr);
  });
  tearDown(() async {
    await mgr.dispose();
    await db.close();
  });

  AlertsConfig config() => const AlertsConfig(
      connectionId: 'home', home: 'My Home', base: 'zigbee2mqtt',
      timeZone: 'Asia/Jerusalem',
      vapid: VapidKeys(publicKey: 'PUB', privateJwk: {'d': 'D'}));

  test('saving and publishing: the hub gets the config retained at QoS 1',
      () async {
    await service.save(config());
    expect(await service.publish('home'), isTrue);
    final (topic, payload, retain) = broker.sent.single;
    expect(topic, 'zigdash/alerts/config');
    expect(retain, isTrue);
    expect(jsonDecode(payload)['home'], 'My Home');
  });

  test('a push registration puts this phone into the config and republishes',
      () async {
    await service.save(config());
    await service.onEndpoint('home',
        const PushRegistration(endpoint: 'https://fcm/e', p256dh: 'k', auth: 'a'));
    final saved = (await service.load('home'))!;
    expect(saved.phones.single.id, 'me');
    expect(saved.phones.single.endpoint, 'https://fcm/e');
    expect(broker.sent.last.$1, 'zigdash/alerts/config');
    // The same registration again changes nothing.
    final n = broker.sent.length;
    await service.onEndpoint('home',
        const PushRegistration(endpoint: 'https://fcm/e', p256dh: 'k', auth: 'a'));
    expect(broker.sent.length, n);
  });

  test("the broker's copy from another phone is taken, keeping my entry",
      () async {
    await service.save(config().withPhone(const AlertPhone(
        id: 'me', name: 'Galaxy', endpoint: 'mine', p256dh: 'k', auth: 'a')));
    final theirs = config().withPhone(const AlertPhone(
        id: 'other', name: 'Pixel', endpoint: 'theirs', p256dh: 'k2', auth: 'a2'))
        .copyWith(alerts: const [
      AlertRule(id: 'a1', kind: AlertKind.smoke, devices: [
        AlertDevice(ieee: '0x9', topic: 'zigbee2mqtt/Hall', name: 'Hall')
      ])
    ]);
    await service.onRetained('home', theirs.encode());
    final merged = (await service.load('home'))!;
    expect(merged.alerts.single.kind, AlertKind.smoke);
    expect(merged.phones.map((p) => p.endpoint), ['theirs', 'mine']);
  });

  test("the broker's copy from another phone lands under this phone's Home id",
      () async {
    // The other phone knows the same Home by a different id.
    final theirs = AlertsConfig(
        connectionId: 'their-id-for-it', home: 'My Home', base: 'zigbee2mqtt',
        timeZone: 'Asia/Jerusalem',
        vapid: const VapidKeys(publicKey: 'PUB', privateJwk: {'d': 'D'}),
        phones: const [AlertPhone(id: 'other', name: 'Pixel', endpoint: 'e', p256dh: 'k', auth: 'a')]);
    await service.onRetained('home', theirs.encode());
    final mine = (await service.load('home'))!;
    expect(mine.connectionId, 'home');
    expect(mine.vapid?.publicKey, 'PUB', reason: 'the keys come along');
    expect(mine.phones.single.id, 'other');
    // Pushes will name the Home by their id: it maps to ours, with our name.
    expect(AlertPush.homeOf(prefs, 'their-id-for-it'), ('home', 'My Home'));
  });

  test('an empty retained config means another phone turned alerts off',
      () async {
    await service.save(config());
    await service.onRetained('home', '');
    expect(await service.load('home'), isNull);
  });

  test('turning off removes the config here and on the broker', () async {
    await service.save(config());
    await service.turnOff('home');
    expect(await service.load('home'), isNull);
    expect(broker.sent.last, ('zigdash/alerts/config', '', true));
  });

  test('a test notification waits for the hub\'s answer for this phone',
      () async {
    await service.save(config());
    final result = service.sendTest('home', within: const Duration(seconds: 2));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(broker.sent.last.$1, 'zigdash/alerts/test');
    expect(jsonDecode(broker.sent.last.$2), {'phone': 'me'});
    broker.emit('zigdash/alerts/test/result',
        '{"phone":"other","ok":false,"status":410}'); // someone else's
    broker.emit('zigdash/alerts/test/result',
        '{"phone":"me","ok":true,"status":201,"body":""}');
    final r = await result;
    expect(r.ok, isTrue);
    expect(r.status, 201);
  });

  test('no answer: the test times out rather than hangs', () async {
    await service.save(config());
    final r = await service.sendTest('home', within: const Duration(milliseconds: 100));
    expect(r.timedOut, isTrue);
  });
}
