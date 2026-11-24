import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/engine/automation.dart';
import 'package:zigdash/engine/automations_repo.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/scenes/models/scene.dart';

Z2mDevice _device(String name, String ieee, List<Map<String, Object?>> exposes) => parseBridgeDevices(jsonEncode([{
      'friendly_name': name,
      'ieee_address': ieee,
      'type': 'EndDevice',
      'supported': true,
      'definition': {'exposes': exposes},
    }])).single;

void main() {
  test('a rule round-trips through the JSON the Engine reads', () {
    final rule = Automation(
      id: 'a1',
      name: 'Hallway light on motion',
      enabled: true,
      trigger: const DeviceTrigger(ieee: '0xm', property: 'occupancy', equals: true, label: 'Hallway motion'),
      conditions: const [HoursCondition(from: '18:00', to: '07:00')],
      action: const AutomationAction(
        kind: ActionKind.device,
        commands: [EngineCommand(ieee: '0xl', payload: {'state': 'ON'})],
        offAfter: 5,
        label: 'Hallway light',
      ),
    );
    final j = jsonDecode(rule.encode()) as Map;
    expect(j['v'], 1);
    expect(j['trigger'], {'type': 'device', 'ieee': '0xm', 'property': 'occupancy', 'equals': true, 'label': 'Hallway motion'});
    expect((j['action'] as Map)['offAfter'], 5);
    final back = Automation.decode('a1', rule.encode())!;
    expect(back.toJson(), rule.toJson());
    expect(back.action.deviceState, 'ON');
  });

  test('time triggers: clock or sun, with days', () {
    final sunset = Automation.decode('t', jsonEncode({
      'v': 1, 'name': 'x', 'enabled': true,
      'trigger': {'type': 'time', 'sun': 'sunset', 'offset': 15, 'days': [6, 7]},
      'action': {'type': 'scene', 'commands': [], 'scene_id': 's1'},
    }))!;
    final t = sunset.trigger as TimeTrigger;
    expect(t.sun, Sun.sunset);
    expect(t.offset, 15);
    expect(t.days, [6, 7]);
    expect(t.toJson(), {'type': 'time', 'sun': 'sunset', 'offset': 15, 'days': [6, 7]});
    expect(sunset.action.sceneId, 's1');
  });

  test('a rule from a newer app version is not shown', () {
    expect(Automation.decode('n', '{"v":2}'), isNull);
    expect(Automation.decode('n', ''), isNull);
  });

  test('trigger options come from the device exposes', () {
    final motion = _device('Motion', '0xm', [
      {'type': 'binary', 'property': 'occupancy', 'access': 1, 'value_on': true, 'value_off': false},
      {'type': 'numeric', 'property': 'battery', 'access': 1, 'unit': '%'},
      {'type': 'numeric', 'property': 'linkquality', 'access': 1},
    ]);
    final opts = triggerOptionsFor(motion);
    expect(opts.map((o) => o.property), ['occupancy', 'battery']);
    expect(opts.first.choices, [true, false]);

    final button = _device('Button', '0xb', [
      {'type': 'enum', 'property': 'action', 'access': 1, 'values': ['single', 'double', 'hold']},
    ]);
    expect(triggerOptionsFor(button).single.choices, ['single', 'double', 'hold']);

    final light = _device('Lamp', '0xl', [
      {'type': 'light', 'features': [
        {'type': 'binary', 'property': 'state', 'access': 7, 'value_on': 'ON', 'value_off': 'OFF'},
      ]},
    ]);
    expect(triggerOptionsFor(light).single.choices, ['ON', 'OFF']);
    expect(actionStatesFor(light), ['ON', 'OFF', 'TOGGLE']);
    expect(actionStatesFor(motion), isEmpty);
  });

  test('scene commands address devices by IEEE, unknown topics stay raw', () {
    final lamp = _device('Living lamp', '0xl', const []);
    final cmds = sceneCommands(const [
      SceneAction(setTopic: 'zigbee2mqtt/Living lamp/set', payload: '{"state":"ON","brightness":120}'),
      SceneAction(setTopic: 'zigbee2mqtt/Gone/set', payload: '{"state":"OFF"}'),
    ], [lamp], 'zigbee2mqtt');
    expect(cmds[0].toJson(), {'ieee': '0xl', 'payload': {'state': 'ON', 'brightness': 120}});
    expect(cmds[1].toJson(), {'topic': 'zigbee2mqtt/Gone/set', 'payload': {'state': 'OFF'}});
  });

  test('scene commands leave out what the Engine cannot send (3.8.7)', () {
    final lamp = _device('Lamp', '0xl', const []);
    final cmds = sceneCommands(const [
      SceneAction(setTopic: 'zigbee2mqtt/Lamp/set', payload: '{"state":"ON"}'),
      SceneAction(setTopic: 'zigbee2mqtt/kitchen/set', payload: '{"state":"OFF"}'),
      SceneAction(setTopic: 'zigbee2mqtt/Lamp/set', payload: 'ON'),
      SceneAction(setTopic: 'cmnd/plug/POWER', payload: '{"POWER":"ON"}'),
    ], [lamp], 'zigbee2mqtt');
    expect([for (final c in cmds) c.toJson()], [
      {'ieee': '0xl', 'payload': {'state': 'ON'}},
      {'topic': 'zigbee2mqtt/kitchen/set', 'payload': {'state': 'OFF'}},
    ], reason: 'no {} command for the raw payload, nothing outside the base');
  });

  test('recent runs decode', () {
    final runs = decodeRuns('[{"id":"a1","at":"2026-10-22T15:40:08.339Z","commands":1}]');
    expect(runs.single.id, 'a1');
    expect(decodeRuns('garbage'), isEmpty);
  });
}
