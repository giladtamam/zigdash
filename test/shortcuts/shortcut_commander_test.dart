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
  bool reachable;
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

final _dimmer = classifyExposes([
  {
    'type': 'light',
    'features': [
      {
        'type': 'binary', 'name': 'state', 'property': 'state',
        'value_on': 'ON', 'value_off': 'OFF', 'value_toggle': 'TOGGLE',
        'access': 7
      },
      {
        'type': 'numeric', 'name': 'brightness', 'property': 'brightness',
        'value_min': 0, 'value_max': 254, 'access': 7
      },
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
      expect(b.sent.single, ('zigbee2mqtt/lamp/set', '{"state":"ON"}'));
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

  test('the value the manager already held is not the answer', () async {
    // Real time: replayed values carry the time they first arrived.
    final b = _Broker(silent: true);
    final m = _manager(b);
    await m.ensureConnected();
    final watch = m.subscribe('zigbee2mqtt/lamp').listen((_) {});
    b.emit('zigbee2mqtt/lamp', '{"state":"OFF"}');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final r = await ShortcutCommander(
            l10n: l10n, confirmWithin: const Duration(milliseconds: 200))
        .toggle(m, _device(_light, 'lamp'),
            lastPayload: '{"state":"ON"}', command: {'state': 'OFF'});
    expect(r.outcome, ShortcutOutcome.unconfirmed,
        reason: 'the replayed OFF is from before the send');
    await watch.cancel();
    await m.dispose();
  });

  test('a first tap learns the current state, then sends its target value',
      () {
    fakeAsync((async) {
      final b = _Broker();
      final m = _manager(b);
      ShortcutResult? r;
      ShortcutCommander(l10n: l10n)
          .toggle(m, _device(_light, 'lamp'))
          .then((v) => r = v);
      async.elapse(const Duration(milliseconds: 50));
      expect(b.sent, isEmpty, reason: 'waiting briefly for the state');
      b.emit('zigbee2mqtt/lamp', '{"state":"ON"}');
      async.elapse(const Duration(milliseconds: 50));
      expect(b.sent.single.$2, '{"state":"OFF"}');
      async.elapse(const Duration(milliseconds: 50));
      expect(r!.outcome, ShortcutOutcome.confirmed);
      expect(r!.on, isFalse);
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
    // A shutter starting to move confirms OPEN/CLOSE before it gets there.
    expect(ShortcutCommander.confirms({'state': 'OPEN'},
        {'state': 'CLOSE', 'motor_run_status': 'Forward'}, {}), isTrue);
    expect(ShortcutCommander.confirms({'state': 'OPEN'},
        {'state': 'CLOSE', 'position': 12}, {'position': 0}), isTrue);
    expect(ShortcutCommander.confirms({'state': 'OPEN'},
        {'state': 'CLOSE', 'motor_run_status': 'Stop', 'position': 0},
        {'position': 0}), isFalse);
    expect(ShortcutCommander.confirms(
        {'state': 'OPEN'}, {'motor_run_status': 'Forward'}, {}), isTrue);
    // The slider pop-up: STOP, and a position.
    expect(ShortcutCommander.confirms({'state': 'STOP'},
        {'state': 'OPEN', 'motor_run_status': 'Stop'}, {}), isTrue);
    expect(ShortcutCommander.confirms({'position': 50},
        {'position': 46, 'motor_run_status': 'Forward'}, {'position': 46}),
        isTrue, reason: 'motor started');
    expect(ShortcutCommander.confirms({'position': 50}, {'position': 50}, {}),
        isTrue);
    expect(ShortcutCommander.confirms({'position': 50},
        {'position': 46, 'motor_run_status': 'Stop'}, {'position': 46}),
        isFalse, reason: 'nothing moved');
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

  test('a refused first connect is tried again within connectWithin', () {
    // Android lets a just-started widget service onto the network a moment
    // after it starts: the first attempt can fail at once.
    fakeAsync((async) {
      final b = _Broker(reachable: false);
      final m = _manager(b);
      ShortcutResult? r;
      ShortcutCommander(l10n: l10n)
          .toggle(m, _device(_light, 'lamp'), lastPayload: '{"state":"ON"}')
          .then((v) => r = v);
      async.elapse(const Duration(milliseconds: 100));
      expect(r, isNull, reason: 'still trying');
      b.reachable = true;
      async.elapse(const Duration(seconds: 2));
      expect(b.sent.single, ('zigbee2mqtt/lamp/set', '{"state":"OFF"}'));
      b.emit('zigbee2mqtt/lamp', '{"state":"OFF"}');
      async.elapse(const Duration(milliseconds: 50));
      expect(r!.outcome, ShortcutOutcome.confirmed);
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

  group('Device Controls', () {
    test('on and off name their value, never TOGGLE', () {
      expect(ShortcutCommander.switchTo(_device(_light, 'lamp'), on: false),
          {'state': 'OFF'});
      expect(ShortcutCommander.switchTo(_device(_light, 'lamp'), on: true),
          {'state': 'ON'});
    });

    test('a level is a light\'s brightness or a shutter\'s position', () {
      expect(ShortcutCommander.levelTo(_device(_dimmer, 'lamp'), 50),
          {'brightness': 127});
      expect(ShortcutCommander.levelTo(_device(_cover, 'blind'), 30),
          {'position': 30});
      expect(ShortcutCommander.levelTo(_device(_light, 'lamp'), 30), isNull);
    });

    test('the state a shortcut shows carries its level (0–100)', () {
      final c = ShortcutCommander(l10n: l10n);
      final at = DateTime(2026, 10, 10);
      expect(
          c.describe(_device(_dimmer, 'lamp'),
              '{"state":"ON","brightness":127}', at).toJson()['level'],
          50);
      expect(
          c.describe(_device(_cover, 'blind'), '{"position":46}', at)
              .toJson()['level'],
          46);
      expect(
          c.describe(_device(_light, 'lamp'), '{"state":"ON"}', at)
              .toJson()
              .containsKey('level'),
          isFalse);
    });

    test('a brightness change is confirmed by the new brightness', () {
      expect(
          ShortcutCommander.confirms(
              {'brightness': 127}, {'state': 'ON', 'brightness': 127}, {}),
          isTrue);
      expect(
          ShortcutCommander.confirms(
              {'brightness': 127}, {'state': 'ON', 'brightness': 254}, {}),
          isFalse);
    });
  });

  group('asking for state', () {
    test('only what a shortcut shows: on/off, brightness, position', () {
      expect(ShortcutCommander.stateRequest(_device(_dimmer, 'lamp')),
          {'state': '', 'brightness': ''});
      expect(ShortcutCommander.stateRequest(_device(_light, 'lamp')),
          {'state': ''});
      expect(ShortcutCommander.stateRequest(_device(_cover, 'blind')),
          {'position': ''});
    });

    test('a sensor is not asked: it reports by itself', () {
      final sensor = classifyExposes([
        {'type': 'numeric', 'name': 'temperature', 'property': 'temperature',
          'access': 5},
      ]);
      expect(ShortcutCommander.stateRequest(_device(sensor, 'climate')), isNull);
    });
  });
}
