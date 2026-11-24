import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart' show Panel;
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/scenes/models/scene.dart';
import 'package:zigdash/features/scenes/scene_capture.dart';

// A light device: state + brightness + color_temp are settable (access 7),
// linkquality is read-only (access 1).
const _light = Z2mDevice(
  friendlyName: 'living_lamp',
  type: 'Router',
  exposes: [
    Z2mExpose(type: 'light'),
    Z2mExpose(type: 'binary', property: 'state', access: 7, valueOn: 'ON'),
    Z2mExpose(type: 'numeric', property: 'brightness', access: 7),
    Z2mExpose(type: 'numeric', property: 'color_temp', access: 7),
    Z2mExpose(type: 'numeric', property: 'linkquality', access: 1),
  ],
);

// A battery sensor: everything it reports is read-only (access 1).
const _sensor = Z2mDevice(
  friendlyName: 'door_sensor',
  type: 'EndDevice',
  exposes: [
    Z2mExpose(type: 'binary', property: 'contact', access: 1),
    Z2mExpose(type: 'numeric', property: 'battery', access: 1),
    Z2mExpose(type: 'numeric', property: 'linkquality', access: 1),
  ],
);

void main() {
  group('Z2mExpose.access', () {
    test('parses the access bitmask and isSettable', () {
      final devices = parseBridgeDevices(jsonEncode([
        {
          'friendly_name': 'lamp',
          'type': 'Router',
          'definition': {
            'vendor': 'IKEA',
            'model': 'LED1',
            'exposes': [
              {
                'type': 'light',
                'features': [
                  {'type': 'binary', 'property': 'state', 'access': 7},
                  {'type': 'numeric', 'property': 'brightness', 'access': 7},
                ],
              },
              {'type': 'numeric', 'property': 'linkquality', 'access': 1},
            ],
          },
        },
      ]));

      final lamp = devices.single;
      final state = lamp.exposes.firstWhere((e) => e.property == 'state');
      final lq = lamp.exposes.firstWhere((e) => e.property == 'linkquality');
      expect(state.access, 7);
      expect(state.isSettable, isTrue);
      expect(lq.isSettable, isFalse);
    });

    test('defaults access to 0 (not settable) when absent', () {
      const e = Z2mExpose(type: 'numeric', property: 'foo');
      expect(e.access, 0);
      expect(e.isSettable, isFalse);
    });
  });

  group('captureSettableState', () {
    test('keeps settable keys, drops read-only and unknown keys', () {
      final captured = captureSettableState(_light, {
        'state': 'ON',
        'brightness': 180,
        'color_temp': 370,
        'linkquality': 84, // read-only → dropped
        'update': {'state': 'idle'}, // not exposed → dropped
      });

      expect(captured, {'state': 'ON', 'brightness': 180, 'color_temp': 370});
    });

    test('returns empty for a device with no settable exposes', () {
      final captured = captureSettableState(_sensor, {
        'contact': true,
        'battery': 95,
        'linkquality': 60,
      });
      expect(captured, isEmpty);
    });

    test('returns empty for a device with no exposes at all', () {
      const bare = Z2mDevice(friendlyName: 'x', type: 'Router');
      expect(captureSettableState(bare, {'state': 'ON'}), isEmpty);
    });
  });

  group('buildSceneAction', () {
    test('builds a /set topic and JSON payload', () {
      final action = buildSceneAction(
        base: 'zigbee2mqtt',
        friendlyName: 'living_lamp',
        settableState: {'state': 'ON', 'brightness': 180},
      );
      expect(action, isNotNull);
      expect(action!.setTopic, 'zigbee2mqtt/living_lamp/set');
      expect(jsonDecode(action.payload), {'state': 'ON', 'brightness': 180});
    });

    test('returns null when nothing is settable', () {
      final action = buildSceneAction(
        base: 'zigbee2mqtt',
        friendlyName: 'door_sensor',
        settableState: const {},
      );
      expect(action, isNull);
    });
  });

  group('captureDeviceAction', () {
    test('captures from raw state JSON end to end', () {
      final action = captureDeviceAction(
        base: 'zigbee2mqtt',
        device: _light,
        rawStateJson: '{"state":"ON","brightness":120,"linkquality":50}',
      );
      expect(action!.setTopic, 'zigbee2mqtt/living_lamp/set');
      expect(jsonDecode(action.payload), {'state': 'ON', 'brightness': 120});
    });

    test('returns null on malformed JSON', () {
      expect(
        captureDeviceAction(
          base: 'zigbee2mqtt',
          device: _light,
          rawStateJson: 'not json',
        ),
        isNull,
      );
    });

    test('returns null when the device has nothing settable', () {
      expect(
        captureDeviceAction(
          base: 'zigbee2mqtt',
          device: _sensor,
          rawStateJson: '{"contact":true,"battery":95}',
        ),
        isNull,
      );
    });
  });

  group('sceneControlsFor / initialSceneEdits', () {
    const cover = Z2mDevice(
      friendlyName: 'shutter',
      type: 'Router',
      exposes: [
        Z2mExpose(type: 'cover'),
        Z2mExpose(type: 'enum', property: 'state', access: 3), // skip (enum)
        Z2mExpose(type: 'numeric', property: 'position', access: 7),
      ],
    );

    test('cover yields a position slider only', () {
      final controls = sceneControlsFor(cover);
      expect(controls.length, 1);
      expect(controls.single.property, 'position');
      expect(controls.single.kind, SceneControlKind.slider);
      expect(controls.single.max, 100);
    });

    test('light yields a state toggle and a brightness slider', () {
      final controls = sceneControlsFor(_light);
      expect(controls.map((c) => c.property).toList(), ['state', 'brightness']);
      expect(controls[0].kind, SceneControlKind.toggle);
      expect(controls[1].kind, SceneControlKind.slider);
      expect(controls[1].max, 254);
    });

    test('seeds edits from live state', () {
      final edits = initialSceneEdits(_light, {'state': 'ON', 'brightness': 200});
      expect(edits, {'state': 'ON', 'brightness': 200});
    });

    test('seeds defaults when no live state', () {
      final edits = initialSceneEdits(cover, null);
      expect(edits, {'position': 50}); // mid-range
    });

    test('toggle resolves OFF when live state is off', () {
      final edits = initialSceneEdits(_light, {'state': 'OFF', 'brightness': 0});
      expect(edits['state'], 'OFF');
    });
  });

  group('buildGetPayload', () {
    test('requests gettable+settable props (access & 6 == 6)', () {
      // _light: state/brightness/color_temp are access 7 (get+set+published),
      // linkquality is access 1 (read-only).
      final payload = buildGetPayload(_light);
      expect(payload.keys.toSet(),
          {'state', 'brightness', 'color_temp'});
      expect(payload.values.every((v) => v == ''), isTrue);
    });

    test('omits set-only props (no get bit) and read-only props', () {
      // A cover: state is access 3 (set, no get) → omitted; position access 7.
      const cover = Z2mDevice(
        friendlyName: 'shutter',
        type: 'Router',
        exposes: [
          Z2mExpose(type: 'cover'),
          Z2mExpose(type: 'enum', property: 'state', access: 3),
          Z2mExpose(type: 'numeric', property: 'position', access: 7),
          Z2mExpose(type: 'numeric', property: 'linkquality', access: 1),
        ],
      );
      expect(buildGetPayload(cover), {'position': ''});
    });

    test('returns empty when nothing is gettable+settable', () {
      expect(buildGetPayload(_sensor), isEmpty);
    });
  });

  group('SceneAction.encodeList / decodeList', () {
    test('round-trips a list of actions', () {
      const actions = [
        SceneAction(setTopic: 'zigbee2mqtt/a/set', payload: '{"state":"ON"}'),
        SceneAction(setTopic: 'zigbee2mqtt/b/set', payload: '{"state":"OFF"}'),
      ];
      final encoded = SceneAction.encodeList(actions);
      final decoded = SceneAction.decodeList(encoded);
      expect(decoded, actions);
    });

    test('decodeList returns empty on malformed input', () {
      expect(SceneAction.decodeList('not json'), isEmpty);
      expect(SceneAction.decodeList('{"not":"a list"}'), isEmpty);
    });
  });

  // ---- Own tiles in scenes (3.8.7, scene-own-tiles-387.md) ----

  group('sceneTileOf', () {
    test('control tiles carry the composed topics', () {
      final t = sceneTileOf(
          _panel(PanelType.toggle, const ToggleConfig(), topic: 'lamp/set',
              sub: 'lamp'),
          'zigbee2mqtt',
          dashboardName: 'Home')!;
      expect(t.publishTopic, 'zigbee2mqtt/lamp/set');
      expect(t.subscribeTopic, 'zigbee2mqtt/lamp');
      expect(t.jsonPath, 'state');
      expect(t.dashboardName, 'Home');
      expect(t.name, 'Tile');

      // The tile's own prefix wins; an empty prefix leaves the topic as is.
      expect(
          sceneTileOf(
                  _panel(PanelType.button, const ButtonConfig(payload: 'ON'),
                      topic: 'cmnd/plug/POWER', prefix: ''),
                  'zigbee2mqtt')!
              .publishTopic,
          'cmnd/plug/POWER');
      expect(
          sceneTileOf(
                  _panel(PanelType.slider, const SliderConfig(),
                      topic: 'g/set', prefix: 'z2m'),
                  'zigbee2mqtt')!
              .publishTopic,
          'z2m/g/set');
      expect(
          sceneTileOf(_panel(PanelType.slider, const SliderConfig(),
                  topic: 'cmnd/dim'), null)!
              .publishTopic,
          'cmnd/dim');
      final cover = sceneTileOf(
          _panel(PanelType.cover, const CoverConfig(), topic: 'blind/set'),
          'zigbee2mqtt')!;
      expect(cover.jsonPath, isNull, reason: 'a cover reads the whole payload');
      for (final type in [PanelType.multiState, PanelType.combo, PanelType.radio]) {
        expect(
            sceneTileOf(_panel(type, OptionsConfig.coverDefault()), 'z')?.type,
            type);
      }
    });

    test('types a scene does not send are left out', () {
      for (final type in [
        PanelType.textInput,
        PanelType.schedule,
        PanelType.autoClose,
        PanelType.scene,
        PanelType.led,
        PanelType.reading,
        PanelType.device,
        PanelType.textLog,
        PanelType.progress,
        PanelType.nodeStatus,
      ]) {
        final config = PanelConfig.defaultFor(type);
        expect(sceneTileOf(_panel(type, config), 'zigbee2mqtt'), isNull,
            reason: type.name);
      }
    });
  });

  group('buildTileAction', () {
    test('toggle: on/off payloads, raw or JSON, unchanged', () {
      final raw = _tile(const ToggleConfig(onPayload: 'ON', offPayload: 'OFF'),
          topic: 'cmnd/plug/POWER');
      expect(buildTileAction(raw, false),
          const SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'OFF'));
      expect(buildTileAction(raw, true)!.payload, 'ON');
      final json = _tile(const ToggleConfig());
      expect(buildTileAction(json, true)!.payload, '{"state":"ON"}');
      expect(buildTileAction(json, false)!.payload, '{"state":"OFF"}');
    });

    test('slider: {value} rounded and clamped', () {
      final t = _tile(const SliderConfig(min: 0, max: 100,
          valueTemplate: '{"brightness":{value}}'));
      expect(buildTileAction(t, 42.6)!.payload, '{"brightness":43}');
      expect(buildTileAction(t, 400)!.payload, '{"brightness":100}');
      expect(buildTileAction(t, -3)!.payload, '{"brightness":0}');
    });

    test('options, cover and button payloads', () {
      final o = _tile(OptionsConfig.coverDefault());
      expect(buildTileAction(o, 2)!.payload, '{"state":"CLOSE"}');
      final c = _tile(const CoverConfig());
      expect(buildTileAction(c, const SceneCoverValue(SceneCoverChoice.open))!
          .payload, '{"state":"OPEN"}');
      expect(buildTileAction(c, const SceneCoverValue(SceneCoverChoice.close))!
          .payload, '{"state":"CLOSE"}');
      expect(buildTileAction(c, const SceneCoverValue(SceneCoverChoice.stop))!
          .payload, '{"state":"STOP"}');
      expect(
          buildTileAction(
                  c, const SceneCoverValue(SceneCoverChoice.position, 30))!
              .payload,
          '{"position":30}');
      final b = _tile(const ButtonConfig(payload: 'PRESS {x}'),
          type: PanelType.button);
      expect(buildTileAction(b, null)!.payload, 'PRESS {x}');
    });

    test('slider guards: step 0 has no divisions; min ≥ max is disabled', () {
      const free = SliderConfig(min: 0, max: 10, step: 0,
          valueTemplate: '{value}');
      expect(sliderDivisions(free), isNull);
      expect(sliderDivisions(const SliderConfig(min: 0, max: 10, step: 2)), 5);
      final t = _tile(free);
      expect(t.disabled, isFalse);
      expect(buildTileAction(t, 99)!.payload, '10');
      final broken = _tile(const SliderConfig(min: 5, max: 5));
      expect(broken.disabled, isTrue);
      expect(buildTileAction(broken, 5), isNull);
      expect(tileSeedValue(broken, 5), isNull);
      expect(_tile(const OptionsConfig()).disabled, isTrue);
    });
  });

  group('payload → value', () {
    test('each kind finds its value, or null', () {
      final toggle = _tile(const ToggleConfig(onPayload: 'ON', offPayload: 'OFF'));
      expect(tileValueOf(toggle, 'ON'), true);
      expect(tileValueOf(toggle, 'OFF'), false);
      expect(tileValueOf(toggle, 'TOGGLE'), isNull);

      final slider = _tile(const SliderConfig(
          min: 0, max: 100, valueTemplate: 'dim {value} now'));
      expect(tileValueOf(slider, 'dim 40 now'), 40);
      expect(tileValueOf(slider, 'dim 400 now'), 100, reason: 'clamped');
      expect(tileValueOf(slider, 'dim 4.5 now'), 4.5);
      expect(tileValueOf(slider, 'dim x now'), isNull);
      expect(tileValueOf(slider, 'dim 40'), isNull);

      final options = _tile(OptionsConfig.coverDefault());
      expect(tileValueOf(options, '{"state":"STOP"}'), 1);
      expect(tileValueOf(options, '{"state":"HALF"}'), isNull);

      final cover = _tile(const CoverConfig());
      expect(tileValueOf(cover, '{"state":"CLOSE"}'),
          const SceneCoverValue(SceneCoverChoice.close));
      expect(tileValueOf(cover, '{"position":70}'),
          const SceneCoverValue(SceneCoverChoice.position, 70));
      expect(
          tileValueOf(_tile(const CoverConfig(showSlider: false)),
              '{"position":70}'),
          isNull);

      final button = _tile(const ButtonConfig(payload: 'PRESS'),
          type: PanelType.button);
      expect(tileValueOf(button, 'PRESS'), true);
      expect(tileValueOf(button, 'press'), isNull);
    });

    test('templateValue with repeated {value}', () {
      expect(templateValue('{value}-{value}', '3-3'), 3);
      expect(templateValue('{value}-{value}', '3-4'), isNull);
      expect(templateValue('no placeholder', 'no placeholder'), isNull);
    });
  });

  group('seeding from the tile', () {
    test('toggle, slider, options', () {
      final toggle = _tile(const ToggleConfig(onMatch: 'on'));
      expect(tileSeedValue(toggle, 'on'), true);
      expect(tileSeedValue(toggle, 'off'), false);
      expect(tileSeedValue(toggle, null), true, reason: 'unknown → on');
      final slider = _tile(const SliderConfig(min: 0, max: 100));
      expect(tileSeedValue(slider, 250), 100);
      expect(tileSeedValue(slider, '30'), 30);
      expect(tileSeedValue(slider, null), 50, reason: 'mid-range');
      final options = _tile(OptionsConfig.coverDefault());
      expect(tileSeedValue(options, 'CLOSE'), 2);
      expect(tileSeedValue(options, 'HALF'), 0);
      expect(tileSeedValue(options, null), 0);
    });

    test('cover: position when shown, else the state', () {
      const raw = '{"state":"CLOSED","position":40}';
      expect(tileSeedValue(_tile(const CoverConfig()), raw),
          const SceneCoverValue(SceneCoverChoice.position, 40));
      expect(tileSeedValue(_tile(const CoverConfig(showSlider: false)), raw),
          const SceneCoverValue(SceneCoverChoice.close));
      expect(tileSeedValue(_tile(const CoverConfig()), '{"state":"stopped"}'),
          const SceneCoverValue(SceneCoverChoice.stop));
      expect(tileSeedValue(_tile(const CoverConfig()), '{"state":"opening"}'),
          const SceneCoverValue(SceneCoverChoice.open));
      expect(tileSeedValue(_tile(const CoverConfig()), null),
          const SceneCoverValue(SceneCoverChoice.open));
      expect(tileSeedValue(_tile(const CoverConfig()), '{"position":"55"}'),
          const SceneCoverValue(SceneCoverChoice.position, 55));
    });
  });

  group('engineCanSend', () {
    test('only a JSON object to <base>/…/set', () {
      bool can(String topic, String payload) => engineCanSend(
          SceneAction(setTopic: topic, payload: payload), 'zigbee2mqtt');
      expect(can('zigbee2mqtt/lamp/set', '{"state":"ON"}'), isTrue);
      expect(can('zigbee2mqtt/lamp/set', 'ON'), isFalse);
      expect(can('zigbee2mqtt/lamp/set', '[1]'), isFalse);
      expect(can('cmnd/plug/POWER', '{"state":"ON"}'), isFalse);
      expect(can('zigbee2mqtt/lamp', '{"state":"ON"}'), isFalse);
      expect(can('zigbee2mqtt/lamp/get', '{"state":""}'), isFalse);
      expect(can('zigbee2mqttx/lamp/set', '{"state":"ON"}'), isFalse);
    });
  });

  group('deviceRowPayload', () {
    test('only payloads the device row could build', () {
      expect(deviceRowPayload(_light, '{"state":"ON","brightness":9}'),
          {'state': 'ON', 'brightness': 9});
      expect(deviceRowPayload(_light, '{"state_l2":"ON"}'), isNull);
      expect(deviceRowPayload(_light, '{}'), isNull);
      expect(deviceRowPayload(_light, 'ON'), isNull);
    });
  });
}

final _stamp = DateTime(2026, 11, 21);

Panel _panel(
  PanelType type,
  PanelConfig config, {
  String topic = 'x/set',
  String? sub,
  String? prefix,
}) =>
    Panel(
      id: 'p-${type.name}',
      dashboardId: 'd1',
      name: 'Tile',
      type: type,
      topic: topic,
      subscribeTopic: sub,
      topicPrefixOverride: prefix,
      qos: 1,
      retain: false,
      width: PanelWidth.small,
      sortOrder: 0,
      config: jsonEncode(config.toJson()),
      mergeFlags: 0,
      createdAt: _stamp,
      updatedAt: _stamp,
    );

SceneTile _tile(PanelConfig config,
        {String topic = 'zigbee2mqtt/t/set', PanelType? type}) =>
    SceneTile(
      panelId: 'p1',
      name: 'T',
      type: type ??
          switch (config) {
            ToggleConfig() => PanelType.toggle,
            SliderConfig() => PanelType.slider,
            ButtonConfig() => PanelType.button,
            OptionsConfig() => PanelType.multiState,
            _ => PanelType.cover,
          },
      config: config,
      publishTopic: topic,
      subscribeTopic: topic,
    );
