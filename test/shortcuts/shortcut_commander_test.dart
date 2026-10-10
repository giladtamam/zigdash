import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:typed_data/typed_data.dart' as typed;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/features/scenes/models/scene.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/shortcuts/shortcut_commander.dart';

/// A broker that answers like Zigbee2MQTT: a `/set` is echoed back as the
/// device's new state, unless [silent].
class _Broker extends mc.MqttClient {
  _Broker({this.reachable = true, this.silent = false})
      : super.withPort('h', 'c', 1883);
  final bool reachable;
  final bool silent;
  final sent = <(String, String)>[];
  final _status = mc.MqttClientConnectionStatus();
  final _updates =
      StreamController<List<mc.MqttReceivedMessage<mc.MqttMessage>>>.broadcast();

  @override
  Future<mc.MqttClientConnectionStatus?> connect([String? u, String? p]) {
    if (!reachable) return Future.error(Exception('refused'));
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
    final payload = utf8.decode(data);
    sent.add((topic, payload));
    if (!silent && topic.endsWith('/set')) {
      final cmd = jsonDecode(payload) as Map<String, dynamic>;
      final state = cmd['state'] == 'TOGGLE' ? 'ON' : cmd['state'];
      scheduleMicrotask(() => emit(topic.substring(0, topic.length - 4),
          jsonEncode({...cmd, 'state': state})));
    }
    return 1;
  }
}

final _light = classifyExposes([
  {
    'type': 'light',
    'features': [
      {
        'type': 'binary', 'name': 'state', 'property': 'state',
        'value_on': 'ON', 'value_off': 'OFF', 'value_toggle': 'TOGGLE',
        'access': 7
      },
    ]
  }
]);

final _cover = classifyExposes([
  {
    'type': 'cover',
    'features': [
      {
        'type': 'enum', 'name': 'state', 'property': 'state',
        'values': ['OPEN', 'CLOSE', 'STOP'], 'access': 7
      },
      {'type': 'numeric', 'name': 'position', 'property': 'position', 'access': 7},
    ]
  }
]);

ShortcutDevice _device(DeviceProfile p, String name) => ShortcutDevice(
      ieee: '0x1',
      name: name,
      publishTopic: 'zigbee2mqtt/$name/set',
      subscribeTopic: 'zigbee2mqtt/$name',
      profile: p,
    );

MqttManager _manager(_Broker b) => MqttManager(
      config: const BrokerConfig(
          id: 'home', host: 'h', port: 1883, protocol: MqttProtocol.tcp),
      password: '',
      clientFactory: (c, id, {host}) => b,
    );

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('a light toggles and the tap is confirmed with the new state', () {
    fakeAsync((async) {
      final b = _Broker();
      final m = _manager(b);
      ShortcutResult? r;
      ShortcutCommander(l10n: l10n)
          .toggle(m, _device(_light, 'lamp'), lastPayload: '{"state":"OFF"}')
          .then((v) => r = v);
      async.elapse(const Duration(milliseconds: 100));
      expect(b.sent.single, ('zigbee2mqtt/lamp/set', '{"state":"TOGGLE"}'));
      expect(r!.outcome, ShortcutOutcome.confirmed);
      expect(r!.on, isTrue);
      expect(r!.line, 'On');
      m.dispose();
      async.flushMicrotasks();
    });
  });

  test('an old state arriving first (a retained message) is not the answer',
      () {
    fakeAsync((async) {
      final b = _Broker(silent: true);
      final m = _manager(b);
      ShortcutResult? r;
      ShortcutCommander(l10n: l10n)
          .toggle(m, _device(_light, 'lamp'), lastPayload: '{"state":"OFF"}')
          .then((v) => r = v);
      async.elapse(const Duration(milliseconds: 50));
      b.emit('zigbee2mqtt/lamp', '{"state":"OFF"}'); // the broker's old copy
      async.elapse(const Duration(milliseconds: 50));
      expect(r, isNull, reason: 'still waiting for the real answer');
      b.emit('zigbee2mqtt/lamp', '{"state":"ON"}');
      async.elapse(const Duration(milliseconds: 50));
      expect(r!.outcome, ShortcutOutcome.confirmed);
      expect(r!.on, isTrue);
      m.dispose();
      async.flushMicrotasks();
    });
  });

  test('confirms only a state that matches the command', () {
    expect(ShortcutCommander.confirms({'state': 'ON'}, {'state': 'on'}, {}), isTrue);
    expect(ShortcutCommander.confirms({'state': 'ON'}, {'state': 'OFF'}, {}), isFalse);
    expect(ShortcutCommander.confirms({'state': 'CLOSE'}, {'state': 'CLOSED'}, {}),
        isTrue);
    expect(ShortcutCommander.confirms({'state': 'TOGGLE'}, {'state': 'ON'},
        {'state': 'OFF'}), isTrue);
    expect(ShortcutCommander.confirms({'state': 'TOGGLE'}, {'state': 'OFF'},
        {'state': 'OFF'}), isFalse);
    expect(ShortcutCommander.confirms({'state': 'TOGGLE'}, {'state': 'OFF'}, {}),
        isTrue, reason: 'unknown before: any answer counts');
    expect(ShortcutCommander.confirms({'state': 'ON'}, {'power': 3}, {}), isFalse);
  });

  test('a closed cover opens, an open one closes', () {
    final d = _device(_cover, 'shutter');
    expect(ShortcutCommander.commandFor(d, '{"state":"CLOSE","position":0}'),
        {'state': 'OPEN'});
    expect(ShortcutCommander.commandFor(d, '{"position":40}'), {'state': 'CLOSE'});
    expect(ShortcutCommander.commandFor(d, null), {'state': 'OPEN'});
  });

  test('no answer within 5 s is unconfirmed, keeping the last state', () {
    fakeAsync((async) {
      final b = _Broker(silent: true);
      final m = _manager(b);
      ShortcutResult? r;
      ShortcutCommander(l10n: l10n)
          .toggle(m, _device(_light, 'lamp'), lastPayload: '{"state":"OFF"}')
          .then((v) => r = v);
      async.elapse(const Duration(seconds: 6));
      expect(r!.outcome, ShortcutOutcome.unconfirmed);
      expect(r!.line, 'Off');
      expect(r!.payload, '{"state":"OFF"}');
      m.dispose();
      async.flushMicrotasks();
    });
  });

  test('a device that never reported reads "Not responding"', () {
    fakeAsync((async) {
      final m = _manager(_Broker(silent: true));
      ShortcutResult? r;
      ShortcutCommander(l10n: l10n)
          .toggle(m, _device(_light, 'lamp'))
          .then((v) => r = v);
      async.elapse(const Duration(seconds: 6));
      expect(r!.line, l10n.deviceNotResponding);
      m.dispose();
      async.flushMicrotasks();
    });
  });

  test('an unreachable broker sends nothing', () {
    fakeAsync((async) {
      final b = _Broker(reachable: false);
      final m = _manager(b);
      ShortcutResult? r;
      ShortcutCommander(l10n: l10n, connectWithin: const Duration(seconds: 2))
          .toggle(m, _device(_light, 'lamp'), lastPayload: '{"state":"ON"}')
          .then((v) => r = v);
      async.elapse(const Duration(seconds: 3));
      expect(r!.outcome, ShortcutOutcome.unreachable);
      expect(r!.line, 'On');
      expect(b.sent, isEmpty);
      m.dispose();
      async.flushMicrotasks();
    });
  });

  test('a scene publishes every action', () {
    fakeAsync((async) {
      final b = _Broker(silent: true);
      final m = _manager(b);
      ShortcutOutcome? r;
      ShortcutCommander(l10n: l10n).runScene(m, const [
        SceneAction(setTopic: 'zigbee2mqtt/a/set', payload: '{"state":"OFF"}'),
        SceneAction(setTopic: 'zigbee2mqtt/b/set', payload: '{"state":"ON"}'),
      ]).then((v) => r = v);
      async.elapse(const Duration(milliseconds: 100));
      expect(r, ShortcutOutcome.sent);
      expect(b.sent.map((p) => p.$1),
          ['zigbee2mqtt/a/set', 'zigbee2mqtt/b/set']);
      m.dispose();
      async.flushMicrotasks();
    });
  });
}
