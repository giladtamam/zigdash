import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/data/database/database.dart' show Connection, Scene;
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/devices/devices_providers.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/scenes/models/scene.dart';
import 'package:zigdash/features/scenes/scene_capture.dart';
import 'package:zigdash/features/scenes/scenes_providers.dart';
import 'package:zigdash/features/scenes/screens/scene_form_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

// The user's own tiles in the scene editor, and a saved scene opening as it
// was saved (3.8.7, scene-own-tiles-387.md).

class _Recording extends MqttManager {
  _Recording()
    : super(
        config: const BrokerConfig(
          id: 'c1',
          host: 'localhost',
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
      );
  final published = <(String, String)>[];
  @override
  bool get isConnected => true;
  @override
  void publish(
    String topic,
    String template,
    Object value, {
    mc.MqttQos qos = mc.MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    published.add((topic, template.replaceAll('{value}', '$value')));
  }
}

class _Repo implements SceneRepo {
  _Repo([this.scene]);
  final Scene? scene;
  final updates = <List<SceneAction>>[];
  final creates = <List<SceneAction>>[];

  @override
  Future<Scene?> getById(String id) async => scene;

  @override
  Future<void> update({
    required String id,
    required String name,
    required int iconCodepoint,
    required int colorSeed,
    required List<SceneAction> actions,
  }) async => updates.add(actions);

  @override
  Future<String> create({
    required String connectionId,
    required String name,
    required int iconCodepoint,
    required int colorSeed,
    required List<SceneAction> actions,
    int sortOrder = 0,
  }) async {
    creates.add(actions);
    return 'new';
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Scene _scene(List<SceneAction> actions) => Scene(
  id: 's1',
  connectionId: 'c1',
  name: 'Evening',
  iconCodepoint: Icons.auto_awesome.codePoint,
  colorSeed: 0xFF3B82F6,
  actions: SceneAction.encodeList(actions),
  sortOrder: 0,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Z2mDevice _device(String name, String ieee, List<String> settable) => Z2mDevice(
  friendlyName: name,
  type: 'Router',
  ieeeAddress: ieee,
  exposes: [
    for (final p in settable)
      Z2mExpose(
        type: p == 'state' || p == 'state_l2' ? 'binary' : 'numeric',
        property: p,
        access: 7,
        valueOn: 'ON',
      ),
  ],
);

SceneTile _tile(
  String id,
  String name,
  PanelConfig config,
  String topic, {
  String? ieee,
  String? sub,
  String? dashboard,
}) => SceneTile(
  panelId: id,
  name: name,
  dashboardName: dashboard,
  type: switch (config) {
    ToggleConfig() => PanelType.toggle,
    SliderConfig() => PanelType.slider,
    ButtonConfig() => PanelType.button,
    OptionsConfig() => PanelType.radio,
    _ => PanelType.cover,
  },
  config: config,
  deviceIeee: ieee,
  publishTopic: topic,
  subscribeTopic: sub ?? topic,
  jsonPath: switch (config) {
    ToggleConfig c => c.jsonPath,
    SliderConfig c => c.jsonPath,
    OptionsConfig c => c.jsonPath,
    _ => null,
  },
);

const _plugConfig = ToggleConfig(onPayload: 'ON', offPayload: 'OFF');
final _plug = _tile(
  'plug',
  'Tasmota plug',
  _plugConfig,
  'cmnd/plug/POWER',
  sub: 'stat/plug/POWER',
);
final _group = _tile(
  'grp',
  'Kitchen group',
  const ToggleConfig(),
  'zigbee2mqtt/kitchen/set',
);

class _Setup {
  _Setup({
    this.scene,
    this.devices = const [],
    this.devicesFuture,
    this.discoveryFails = false,
    this.tiles = SceneTiles.empty,
    this.tilesDelay,
    this.live = const {},
    this.base = 'zigbee2mqtt',
  });

  /// The Home's own base topic setting.
  final String base;

  final Scene? scene;
  List<Z2mDevice> devices;
  Future<List<Z2mDevice>>? devicesFuture;
  bool discoveryFails;
  final SceneTiles tiles;
  final Duration? tilesDelay;
  final Map<String, Object?> live;
  late final _Repo repo = _Repo(scene);
  final mgr = _Recording();
  var tileReads = 0;
}

Future<void> _pump(WidgetTester tester, _Setup s) async {
  tester.view.physicalSize = const Size(1200, 9000);
  tester.view.devicePixelRatio = 1.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectionsStreamProvider.overrideWith(
          (ref) => Stream.value(const <Connection>[]),
        ),
        baseTopicOverrideProvider.overrideWith((ref, _) => s.base),
        sceneRepoProvider.overrideWithValue(s.repo),
        mqttManagerProvider.overrideWith((ref, _) async => s.mgr),
        sceneTilesLoaderProvider.overrideWithValue((_) async {
          s.tileReads++;
          if (s.tilesDelay case final d?) await Future<void>.delayed(d);
          return s.tiles;
        }),
        discoveredDevicesProvider.overrideWith((ref, args) {
          if (s.discoveryFails) {
            return Future.error(TimeoutException('no bridge/devices'));
          }
          return s.devicesFuture ?? Future.value(s.devices);
        }),
        deviceStatesProvider.overrideWith(
          (ref, _) => Stream.value(const <String, String>{}),
        ),
        panelValueSnapshotProvider.overrideWith((ref, key) {
          if (!s.live.containsKey(key.topic)) return const Stream.empty();
          return Stream.value(
            PanelValueSnapshot(
              value: s.live[key.topic],
              receivedAt: DateTime(2026),
              connectionGeneration: 0,
              freshness: PanelFreshness.fresh,
            ),
          );
        }),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SceneFormScreen(
          connectionId: 'c1',
          sceneId: s.scene?.id,
          onDone: () {},
        ),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

bool? _ticked(WidgetTester tester, String title) => tester
    .widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, title))
    .value;

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('Save'));
  await _settle(tester);
}

const _homeOnly =
    "Runs only from this phone at home: not from Automations or when you're away.";

void main() {
  final lamp = _device('lamp', '0xlamp', ['state', 'brightness']);

  testWidgets('a new scene lists a custom tile and saves what it sends', (
    tester,
  ) async {
    final s = _Setup(
      devices: [lamp],
      tiles: SceneTiles(
        tiles: [
          _plug,
          _tile(
            'lampTile',
            'Lamp switch',
            const ToggleConfig(),
            'zigbee2mqtt/lamp/set',
          ),
        ],
      ),
      live: {'stat/plug/POWER': 'ON'},
    );
    await _pump(tester, s);
    expect(find.text('Your tiles'), findsOneWidget);
    expect(find.text('Tasmota plug'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Night');
    await tester.tap(find.text('Tasmota plug'));
    await _settle(tester);
    expect(_ticked(tester, 'Tasmota plug'), isTrue);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
      reason: 'seeded from the tile: ON',
    );
    expect(find.text(_homeOnly), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    await _settle(tester);

    // A JSON tile under the base: no note.
    await tester.tap(find.text('Lamp switch'));
    await _settle(tester);
    expect(find.text(_homeOnly), findsOneWidget);

    await _save(tester);
    expect(s.repo.creates.single, const [
      SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'OFF'),
      SceneAction(setTopic: 'zigbee2mqtt/lamp/set', payload: '{"state":"ON"}'),
    ]);
  });

  testWidgets('a device row shows the name of its device tile', (tester) async {
    await _pump(
      tester,
      _Setup(
        devices: [
          _device('0x00158d0001', '0xlamp', ['state']),
        ],
        tiles: const SceneTiles(deviceNames: {'0xlamp': 'Wohnzimmer Licht'}),
      ),
    );
    expect(find.text('Wohnzimmer Licht'), findsOneWidget);
    expect(
      find.textContaining('0x00158d0001'),
      findsOneWidget,
      reason: 'the Zigbee2MQTT name as the subtitle',
    );
    expect(find.text('Your tiles'), findsNothing);
  });

  testWidgets('tiles and no devices: the tiles, no dead end', (tester) async {
    await _pump(tester, _Setup(tiles: SceneTiles(tiles: [_plug])));
    expect(find.text('Tasmota plug'), findsOneWidget);
    expect(find.textContaining('No controllable'), findsNothing);
  });

  testWidgets('neither devices nor tiles: the reworded text', (tester) async {
    await _pump(tester, _Setup());
    expect(
      find.text(
        'No controllable devices or tiles found. '
        "Make sure they're paired, then tap refresh.",
      ),
      findsOneWidget,
    );
  });

  group('edit: the scene opens as it was saved', () {
    testWidgets('a group tile: waits for the device list, then ticks', (
      tester,
    ) async {
      const stored = [
        SceneAction(
          setTopic: 'zigbee2mqtt/kitchen/set',
          payload: '{"state":"ON"}',
        ),
      ];
      final devices = Completer<List<Z2mDevice>>();
      final s = _Setup(
        scene: _scene(stored),
        devicesFuture: devices.future,
        tiles: SceneTiles(tiles: [_group]),
      );
      await _pump(tester, s);
      expect(find.text('1 other action is kept'), findsOneWidget);
      expect(_ticked(tester, 'Kitchen group'), isFalse);

      devices.complete([lamp]);
      await _settle(tester);
      expect(_ticked(tester, 'Kitchen group'), isTrue);
      expect(find.text('kitchen'), findsNothing, reason: 'no device row');
      expect(find.textContaining('other action'), findsNothing);

      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.single),
        SceneAction.encodeList(stored),
      );
    });

    testWidgets('a group tile still ticks when discovery fails', (
      tester,
    ) async {
      const stored = [
        SceneAction(
          setTopic: 'zigbee2mqtt/kitchen/set',
          payload: '{"state":"ON"}',
        ),
      ];
      final s = _Setup(
        scene: _scene(stored),
        discoveryFails: true,
        tiles: SceneTiles(tiles: [_group]),
      );
      await _pump(tester, s);
      expect(_ticked(tester, 'Kitchen group'), isTrue);
      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.single),
        SceneAction.encodeList(stored),
      );
    });

    testWidgets('a hand-typed toggle on a device topic: the device row', (
      tester,
    ) async {
      const stored = [
        SceneAction(
          setTopic: 'zigbee2mqtt/lamp/set',
          payload: '{"state":"ON"}',
        ),
      ];
      final s = _Setup(
        scene: _scene(stored),
        devices: [lamp],
        tiles: SceneTiles(
          tiles: [
            _tile(
              'typed',
              'Typed lamp',
              const ToggleConfig(),
              'zigbee2mqtt/lamp/set',
            ),
          ],
        ),
      );
      await _pump(tester, s);
      expect(_ticked(tester, 'lamp'), isTrue);
      expect(_ticked(tester, 'Typed lamp'), isFalse);
      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.single),
        SceneAction.encodeList(stored),
      );
    });

    for (final l2Settable in [false, true]) {
      testWidgets(
        'linked tiles vs the device (state_l2 settable: $l2Settable)',
        (tester) async {
          const stored = [
            SceneAction(
              setTopic: 'zigbee2mqtt/relay/set',
              payload: '{"state":"ON"}',
            ),
            SceneAction(
              setTopic: 'zigbee2mqtt/relay/set',
              payload: '{"state_l2":"ON"}',
            ),
          ];
          final relay = _device('relay', '0xrelay', [
            'state',
            if (l2Settable) 'state_l2',
          ]);
          final s = _Setup(
            scene: _scene(stored),
            devices: [relay],
            tiles: SceneTiles(
              tiles: [
                _tile(
                  'l1',
                  'Relay L1',
                  const ToggleConfig(),
                  'zigbee2mqtt/relay/set',
                  ieee: '0xrelay',
                ),
                _tile(
                  'l2',
                  'Relay L2',
                  const ToggleConfig(
                    onPayload: '{"state_l2":"ON"}',
                    offPayload: '{"state_l2":"OFF"}',
                  ),
                  'zigbee2mqtt/relay/set',
                  ieee: '0xrelay',
                ),
              ],
            ),
          );
          await _pump(tester, s);
          expect(_ticked(tester, 'relay'), isTrue);
          expect(_ticked(tester, 'Relay L1'), isFalse);
          expect(_ticked(tester, 'Relay L2'), isTrue);
          expect(find.textContaining('other action'), findsNothing);
          await _save(tester);
          expect(
            SceneAction.encodeList(s.repo.updates.single),
            SceneAction.encodeList(stored),
          );
        },
      );
    }

    testWidgets('tiles are read before seeding, with nothing watching', (
      tester,
    ) async {
      const stored = [SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'OFF')];
      final s = _Setup(
        scene: _scene(stored),
        devices: [lamp],
        tiles: SceneTiles(tiles: [_plug]),
        tilesDelay: const Duration(milliseconds: 500),
      );
      await _pump(tester, s);
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
        reason: 'still reading the tiles',
      );
      expect(find.text('Evening'), findsNothing);
      await tester.pump(const Duration(milliseconds: 600));
      await _settle(tester);
      expect(s.tileReads, 1);
      expect(_ticked(tester, 'Tasmota plug'), isTrue);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      expect(
        find.textContaining('other action'),
        findsNothing,
        reason: 'on its tile, not kept',
      );
    });

    testWidgets('devices late: counted as kept, then moved; Save before', (
      tester,
    ) async {
      const stored = [
        SceneAction(
          setTopic: 'zigbee2mqtt/lamp/set',
          payload: '{"state":"ON", "brightness":120}',
        ),
        SceneAction(
          setTopic: 'zigbee2mqtt/gone/set',
          payload: '{"state":"OFF"}',
        ),
      ];
      final devices = Completer<List<Z2mDevice>>();
      final s = _Setup(scene: _scene(stored), devicesFuture: devices.future);
      await _pump(tester, s);
      expect(find.text('2 other actions are kept'), findsOneWidget);
      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.single),
        SceneAction.encodeList(stored),
        reason: 'saved before the list: as they were',
      );

      devices.complete([lamp]);
      await _settle(tester);
      expect(_ticked(tester, 'lamp'), isTrue);
      expect(find.text('1 other action is kept'), findsOneWidget);
      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.last),
        SceneAction.encodeList(stored),
        reason: 'the hand-typed spacing survives an untouched save',
      );
    });

    testWidgets('refresh while waiting: the list still settles pending', (
      tester,
    ) async {
      const stored = [
        SceneAction(
          setTopic: 'zigbee2mqtt/lamp/set',
          payload: '{"state":"ON"}',
        ),
      ];
      final devices = Completer<List<Z2mDevice>>();
      final s = _Setup(scene: _scene(stored), devicesFuture: devices.future);
      await _pump(tester, s);
      expect(find.text('1 other action is kept'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await _settle(tester);
      devices.complete([lamp]);
      await _settle(tester);
      expect(_ticked(tester, 'lamp'), isTrue);
      expect(find.textContaining('other action'), findsNothing);
    });

    testWidgets('discovery fails: pending kept and saved; a refresh settles', (
      tester,
    ) async {
      const stored = [
        SceneAction(
          setTopic: 'zigbee2mqtt/lamp/set',
          payload: '{"state":"ON"}',
        ),
      ];
      final s = _Setup(scene: _scene(stored), discoveryFails: true);
      await _pump(tester, s);
      expect(find.text('1 other action is kept'), findsOneWidget);
      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.single),
        SceneAction.encodeList(stored),
        reason: 'nothing ticked, the pending one saved as it was',
      );

      s
        ..discoveryFails = false
        ..devices = [lamp];
      await tester.tap(find.byIcon(Icons.refresh));
      await _settle(tester);
      expect(_ticked(tester, 'lamp'), isTrue);
      expect(find.textContaining('other action'), findsNothing);

      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.last),
        SceneAction.encodeList(stored),
        reason: 'one action for the lamp, not two',
      );
    });

    testWidgets('controls the scene does not set read "not set"', (
      tester,
    ) async {
      final cover = Z2mDevice(
        friendlyName: 'blind',
        type: 'Router',
        ieeeAddress: '0xblind',
        exposes: const [
          Z2mExpose(type: 'enum', property: 'state', access: 3),
          Z2mExpose(type: 'numeric', property: 'position', access: 7),
        ],
      );
      final plug = _device('plug', '0xplug', ['state']);
      const stored = [
        SceneAction(
          setTopic: 'zigbee2mqtt/lamp/set',
          payload: '{"state":"ON"}',
        ),
        SceneAction(
          setTopic: 'zigbee2mqtt/blind/set',
          payload: '{"state":"OPEN"}',
        ),
        SceneAction(
          setTopic: 'zigbee2mqtt/plug/set',
          payload: '{"state":"TOGGLE"}',
        ),
      ];
      final s = _Setup(scene: _scene(stored), devices: [lamp, cover, plug]);
      await _pump(tester, s);
      expect(_ticked(tester, 'lamp'), isTrue);
      expect(_ticked(tester, 'blind'), isTrue);
      expect(_ticked(tester, 'plug'), isTrue);
      expect(
        find.byKey(const Key('scene-unset-lamp-brightness')),
        findsOneWidget,
        reason: 'not Brightness 0',
      );
      expect(find.byKey(const Key('scene-unset-lamp-state')), findsNothing);
      expect(
        find.byKey(const Key('scene-unset-blind-position')),
        findsOneWidget,
        reason: 'not Position 0%',
      );
      expect(
        find.byKey(const Key('scene-unset-plug-state')),
        findsOneWidget,
        reason: 'not Power off',
      );
      expect(find.text('TOGGLE'), findsOneWidget);
      expect(find.text('0%'), findsNothing);

      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.single),
        SceneAction.encodeList(stored),
      );

      // Changing a "not set" control adds it.
      final slider = find.descendant(
        of: find.byKey(const Key('scene-unset-lamp-brightness')),
        matching: find.byType(Slider),
      );
      tester.widget<Slider>(slider).onChanged!(100);
      await _settle(tester);
      expect(
        find.byKey(const Key('scene-unset-lamp-brightness')),
        findsNothing,
      );
      await _save(tester);
      expect(
        s.repo.updates.last.first,
        const SceneAction(
          setTopic: 'zigbee2mqtt/lamp/set',
          payload: '{"state":"ON","brightness":100}',
        ),
      );
    });

    testWidgets('a Home with its own base: matched, built and noted on it', (
      tester,
    ) async {
      const stored = [
        SceneAction(setTopic: 'myz2m/lamp/set', payload: '{"state":"ON"}'),
      ];
      final s = _Setup(
        scene: _scene(stored),
        devices: [lamp],
        base: 'myz2m',
        tiles: SceneTiles(
          tiles: [
            _tile('grp', 'Group', const ToggleConfig(), 'myz2m/kitchen/set'),
          ],
        ),
      );
      await _pump(tester, s);
      expect(_ticked(tester, 'lamp'), isTrue);
      await tester.tap(find.text('Group'));
      await _settle(tester);
      expect(
        find.text(_homeOnly),
        findsNothing,
        reason: 'a JSON /set under the Home base runs from Automations',
      );
      await _save(tester);
      expect(s.repo.updates.single, const [
        SceneAction(setTopic: 'myz2m/lamp/set', payload: '{"state":"ON"}'),
        SceneAction(setTopic: 'myz2m/kitchen/set', payload: '{"state":"ON"}'),
      ]);
    });

    testWidgets('duplicates: one place each, the rest kept, order kept', (
      tester,
    ) async {
      const stored = [
        SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'ON'),
        SceneAction(
          setTopic: 'zigbee2mqtt/lamp/set',
          payload: '{"state":"ON"}',
        ),
        SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'ON'),
        SceneAction(
          setTopic: 'zigbee2mqtt/lamp/set',
          payload: '{"state":"ON"}',
        ),
      ];
      final s = _Setup(
        scene: _scene(stored),
        devices: [lamp],
        tiles: SceneTiles(tiles: [_plug]),
      );
      await _pump(tester, s);
      expect(_ticked(tester, 'Tasmota plug'), isTrue);
      expect(_ticked(tester, 'lamp'), isTrue);
      expect(find.text('2 other actions are kept'), findsOneWidget);
      await _save(tester);
      expect(
        SceneAction.encodeList(s.repo.updates.single),
        SceneAction.encodeList(stored),
      );
    });

    testWidgets(
      'round trip: as saved; a new tile appended; nothing → refused',
      (tester) async {
        final plant = _device('plant', '0xplant', ['state']);
        const stored = [
          SceneAction(
            setTopic: 'zigbee2mqtt/lamp/set',
            payload: '{"brightness":80}',
          ),
          SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'ON'),
          SceneAction(setTopic: 'other/thing', payload: 'x'),
          SceneAction(
            setTopic: 'zigbee2mqtt/plant/set',
            payload: '{"state":"OFF"}',
          ),
        ];
        final s = _Setup(
          scene: _scene(stored),
          devices: [lamp, plant],
          tiles: SceneTiles(
            tiles: [
              _plug,
              _tile(
                'dim',
                'Dimmer',
                const SliderConfig(min: 0, max: 100),
                'cmnd/dim/set',
              ),
            ],
          ),
        );
        await _pump(tester, s);
        expect(_ticked(tester, 'lamp'), isTrue);
        expect(_ticked(tester, 'plant'), isTrue);
        expect(_ticked(tester, 'Tasmota plug'), isTrue);
        expect(find.text('1 other action is kept'), findsOneWidget);
        await _save(tester);
        expect(
          SceneAction.encodeList(s.repo.updates.single),
          SceneAction.encodeList(stored),
        );

        // Adding a tile keeps everything already in the scene (cause 4).
        await tester.tap(find.text('Dimmer'));
        await _settle(tester);
        await _save(tester);
        expect(s.repo.updates.last, [
          ...stored,
          const SceneAction(
            setTopic: 'cmnd/dim/set',
            payload: '{"brightness":50}',
          ),
        ]);

        // Everything unticked and the kept one removed: refused.
        for (final name in ['lamp', 'plant', 'Tasmota plug', 'Dimmer']) {
          await tester.tap(find.text(name));
          await _settle(tester);
        }
        await tester.tap(find.byKey(const Key('scene-remove-kept')));
        await _settle(tester);
        await _save(tester);
        expect(
          find.text('Select at least one device or tile.'),
          findsOneWidget,
        );
        expect(s.repo.updates, hasLength(2));
      },
    );

    testWidgets('Remove drops the kept actions on Save only', (tester) async {
      const stored = [
        SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'ON'),
        SceneAction(setTopic: 'other/thing', payload: 'x'),
      ];
      final s = _Setup(
        scene: _scene(stored),
        devices: [lamp],
        tiles: SceneTiles(tiles: [_plug]),
      );
      await _pump(tester, s);
      await tester.tap(find.text('Remove'));
      await _settle(tester);
      expect(find.textContaining('other action'), findsNothing);
      expect(s.repo.updates, isEmpty, reason: 'leaving now changes nothing');
      await _save(tester);
      expect(s.repo.updates.single, [stored.first]);
    });
  });

  testWidgets('slider guards: step 0 works; min ≥ max is disabled', (
    tester,
  ) async {
    final s = _Setup(
      devices: [lamp],
      tiles: SceneTiles(
        tiles: [
          _tile(
            'free',
            'Free slider',
            const SliderConfig(
              min: 0,
              max: 10,
              step: 0,
              valueTemplate: '{value}',
            ),
            'cmnd/free',
          ),
          _tile(
            'broken',
            'Broken slider',
            const SliderConfig(min: 5, max: 5),
            'cmnd/broken',
          ),
        ],
      ),
    );
    await _pump(tester, s);
    expect(
      tester
          .widget<CheckboxListTile>(
            find.widgetWithText(CheckboxListTile, 'Broken slider'),
          )
          .onChanged,
      isNull,
    );
    await tester.tap(find.text('Free slider'));
    await _settle(tester);
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.divisions, isNull);
    await tester.enterText(find.byType(TextFormField), 'S');
    await _save(tester);
    expect(s.repo.creates.single, const [
      SceneAction(setTopic: 'cmnd/free', payload: '5'),
    ]);
  });

  testWidgets('activateScene publishes a raw payload unchanged', (
    tester,
  ) async {
    final mgr = _Recording();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mqttManagerProvider.overrideWith((ref, _) async => mgr)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () => activateScene(ref, 'c1', const [
                SceneAction(setTopic: 'cmnd/plug/POWER', payload: 'OFF'),
                SceneAction(
                  setTopic: 'zigbee2mqtt/kitchen/set',
                  payload: '{ "state" : "ON" }',
                ),
              ], gap: Duration.zero),
              child: const Text('Run'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Run'));
    await tester.pump();
    expect(mgr.published, [
      ('cmnd/plug/POWER', 'OFF'),
      ('zigbee2mqtt/kitchen/set', '{ "state" : "ON" }'),
    ]);
  });
}
