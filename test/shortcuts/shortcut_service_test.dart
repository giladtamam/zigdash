import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/data/database/daos/shortcut_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/database/tables/shortcuts.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/shortcuts/shortcut_service.dart';
import 'package:zigdash/shortcuts/shortcut_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late SharedPreferences prefs;
  late ShortcutService service;
  final t = DateTime(2026, 10, 10);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.test(NativeDatabase.memory());
    await db.into(db.connections).insert(ConnectionsCompanion.insert(
        id: 'home', name: 'Home', host: 'h', port: 1883,
        protocol: MqttProtocol.tcp, createdAt: t, updatedAt: t));
    service = ShortcutService(db, prefs, now: () => t);
  });
  tearDown(() => db.close());

  test('slots fill in order and a device keeps its slot', () async {
    expect(await service.freeTileSlot(), 1);
    await service.assignTile(1, connectionId: 'home', ieee: '0x1', name: 'Lamp');
    await service.assignTile(2, connectionId: 'home', ieee: '0x2', name: 'Plug');
    expect(await service.freeTileSlot(), 3);
    expect(await service.tileSlotOf('home', '0x2'), 2);
    expect(await service.tileSlotOf('home', '0x9'), isNull);
    for (var s = 3; s <= shortcutTileSlots; s++) {
      await service.assignTile(s, connectionId: 'home', ieee: '0x$s', name: 'D$s');
    }
    expect(await service.freeTileSlot(), isNull);
  });

  test('assigning writes what the native tile reads; clearing removes it',
      () async {
    await service.assignTile(2, connectionId: 'home', ieee: '0x2', name: 'Plug');
    expect(jsonDecode(prefs.getString(shortcutTileKey(2))!),
        {'connectionId': 'home', 'ieee': '0x2', 'name': 'Plug'});
    // Replacing a slot keeps one row.
    await service.assignTile(2, connectionId: 'home', ieee: '0x3', name: 'Lamp');
    expect(await db.select(db.shortcuts).get(), hasLength(1));
    await service.clearTile(2);
    expect(prefs.getString(shortcutTileKey(2)), isNull);
    expect(await db.select(db.shortcuts).get(), isEmpty);
  });

  test('the native words come in the app language', () async {
    await service.writeStrings(lookupAppLocalizations(const Locale('en')));
    final words = jsonDecode(prefs.getString(shortcutStringsKey)!) as Map;
    expect(words.keys, containsAll(
        ['working', 'cantReach', 'notConfirmed', 'removed', 'chooseDevice']));
    expect(words['cantReach'], "Can't reach home");
  });

  test('outside Android, adding a tile reports unsupported', () async {
    expect(await service.requestAddTile(1, 'Plug'), AddTileResult.unsupported);
  });

  group('Device Controls', () {
    Future<void> dashboard(String id, String name) => db
        .into(db.dashboards)
        .insert(DashboardsCompanion.insert(
            id: id, connectionId: 'home', name: name, colorSeed: 0,
            iconCodepoint: 0, createdAt: t, updatedAt: t));

    Future<void> tile(String id, String dash, String ieee, String name,
            List<Map<String, Object?>> exposes) =>
        db.into(db.panels).insert(PanelsCompanion.insert(
            id: id, dashboardId: dash, name: name, type: PanelType.device,
            topic: name, width: PanelWidth.wide,
            config: DeviceTileConfig(profile: classifyExposes(exposes)).encode(),
            createdAt: t, updatedAt: t, deviceIeee: Value(ieee)));

    const light = [
      {
        'type': 'light',
        'features': [
          {'type': 'binary', 'name': 'state', 'property': 'state',
            'value_on': 'ON', 'value_off': 'OFF', 'access': 7},
          {'type': 'numeric', 'name': 'brightness', 'property': 'brightness',
            'value_min': 0, 'value_max': 254, 'access': 7},
        ]
      }
    ];
    const plug = [
      {
        'type': 'switch',
        'features': [
          {'type': 'binary', 'name': 'state', 'property': 'state',
            'value_on': 'ON', 'value_off': 'OFF', 'access': 7},
        ]
      }
    ];
    const cover = [
      {
        'type': 'cover',
        'features': [
          {'type': 'enum', 'name': 'state', 'property': 'state',
            'values': ['OPEN', 'CLOSE', 'STOP'], 'access': 7},
          {'type': 'numeric', 'name': 'position', 'property': 'position',
            'access': 7},
        ]
      }
    ];
    const sensor = [
      {'type': 'numeric', 'name': 'temperature', 'property': 'temperature',
        'access': 5, 'unit': '°C'},
    ];

    test('every device on a dashboard is offered once, with its kind',
        () async {
      await dashboard('d1', 'Main');
      await dashboard('d2', 'Bedroom');
      await tile('p1', 'd1', '0x1', 'אור חדר שרות', light);
      await tile('p2', 'd1', '0x2', 'Plug', plug);
      await tile('p3', 'd2', '0x3', 'תריס 1', cover);
      await tile('p4', 'd2', '0x4', 'Climate', sensor);
      await tile('p5', 'd2', '0x1', 'אור חדר שרות', light); // on both
      await service.resyncControls();
      final list = (jsonDecode(prefs.getString(shortcutControlsKey)!) as List)
          .cast<Map<String, dynamic>>();
      expect(list.map((c) => c['ieee']), ['0x1', '0x2', '0x3', '0x4']);
      expect(list.map((c) => c['kind']), ['dimmer', 'switch', 'cover', 'sensor']);
      expect(list.first, {
        'connectionId': 'home', 'home': 'Home', 'ieee': '0x1',
        'name': 'אור חדר שרות', 'class': 'light', 'kind': 'dimmer',
      });
    });
  });

  group('home-screen widgets', () {
    test('widgets set up on the home screen become shortcuts the app follows',
        () async {
      await prefs.setString('shortcut.widget.7',
          '{"connectionId":"home","ieee":"0x1","name":"Lamp","class":"light"}');
      await prefs.setString('shortcut.widget.9',
          '{"connectionId":"home","ieee":"0x2","name":"Blind","class":"cover","cover":true}');
      await service.syncWidgets();
      final rows = await db.select(db.shortcuts).get();
      expect(rows.map((r) => '${r.appWidgetId} ${shortcutTargets(r)}').toSet(),
          {'7 [0x1]', '9 [0x2]'});

      // A widget removed from the home screen goes away here too.
      await prefs.remove('shortcut.widget.7');
      await service.syncWidgets();
      expect((await db.select(db.shortcuts).get()).single.appWidgetId, 9);
    });

    test('a scene widget becomes a scene shortcut', () async {
      await prefs.setString('shortcut.widget.4',
          '{"connectionId":"home","kind":"scene","sceneId":"s1","name":"Evening"}');
      await service.syncWidgets();
      final row = (await db.select(db.shortcuts).get()).single;
      expect(row.kind, ShortcutKind.scene);
      expect(shortcutTargets(row), ['s1']);
      expect(row.appWidgetId, 4);
    });

    test('a widget for a Home that no longer exists is skipped', () async {
      await prefs.setString('shortcut.widget.3',
          '{"connectionId":"gone","ieee":"0x1","name":"Lamp"}');
      await service.syncWidgets();
      expect(await db.select(db.shortcuts).get(), isEmpty);
    });
  });

  test('the scenes the native picker offers, per Home in the app\'s order',
      () async {
    Future<void> scene(String id, String name, int order) =>
        db.into(db.scenes).insert(ScenesCompanion.insert(
            id: id, connectionId: 'home', name: name, iconCodepoint: 0,
            colorSeed: 0, actions: '[]', createdAt: t, updatedAt: t,
            sortOrder: Value(order)));
    await scene('s2', 'Night', 1);
    await scene('s1', 'Evening', 0);
    await service.resyncScenes();
    expect(jsonDecode(prefs.getString(shortcutScenesKey)!), [
      {'connectionId': 'home', 'home': 'Home', 'sceneId': 's1', 'name': 'Evening'},
      {'connectionId': 'home', 'home': 'Home', 'sceneId': 's2', 'name': 'Night'},
    ]);
  });

  test("a deleted scene's last run is forgotten; devices' states stay",
      () async {
    await db.into(db.scenes).insert(ScenesCompanion.insert(
        id: 'kept', connectionId: 'home', name: 'Evening', iconCodepoint: 0,
        colorSeed: 0, actions: '[]', createdAt: t, updatedAt: t));
    await prefs.setString(shortcutStateKey('home', 'kept'), '{"line":"Sent"}');
    await prefs.setString(shortcutStateKey('home', 'gone'), '{"line":"Sent"}');
    await prefs.setString(
        shortcutStateKey('home', '0x00158d0001'), '{"line":"On"}');
    await service.resyncScenes();
    expect(prefs.getString(shortcutStateKey('home', 'kept')), isNotNull);
    expect(prefs.getString(shortcutStateKey('home', 'gone')), isNull);
    expect(prefs.getString(shortcutStateKey('home', '0x00158d0001')),
        isNotNull);
  });

  group('group widgets', () {
    const plug = [
      {
        'type': 'switch',
        'features': [
          {'type': 'binary', 'name': 'state', 'property': 'state',
            'value_on': 'ON', 'value_off': 'OFF', 'access': 7},
        ]
      }
    ];
    var order = 0;
    Future<void> dashboard(String id, String name) => db
        .into(db.dashboards)
        .insert(DashboardsCompanion.insert(
            id: id, connectionId: 'home', name: name, colorSeed: 0,
            iconCodepoint: 0, createdAt: t, updatedAt: t));
    Future<void> section(String id, String dash, String name, int sort) =>
        db.into(db.sections).insert(SectionsCompanion.insert(
            id: id, dashboardId: dash, name: name, createdAt: t, updatedAt: t,
            sortOrder: Value(sort)));
    Future<void> device(String id, String dash, String? sec, String ieee) =>
        db.into(db.panels).insert(PanelsCompanion.insert(
            id: id, dashboardId: dash, name: ieee, type: PanelType.device,
            topic: ieee, width: PanelWidth.wide,
            config: DeviceTileConfig(profile: classifyExposes(plug)).encode(),
            createdAt: t, updatedAt: t, deviceIeee: Value(ieee),
            sectionId: Value(sec), sortOrder: Value(order++)));
    Future<void> sceneTile(String id, String dash, String? sec, String scene) =>
        db.into(db.panels).insert(PanelsCompanion.insert(
            id: id, dashboardId: dash, name: scene, type: PanelType.scene,
            topic: '', width: PanelWidth.small,
            config: SceneConfig(sceneId: scene).encode(),
            createdAt: t, updatedAt: t,
            sectionId: Value(sec), sortOrder: Value(order++)));

    test('each dashboard section is offered as a group: 5 devices, 3 scenes',
        () async {
      await dashboard('d1', 'Main');
      await section('s1', 'd1', 'Lights', 0);
      await section('s2', 'd1', 'Covers', 1);
      await device('p0', 'd1', null, '0x0'); // no section: the dashboard's
      for (var i = 1; i <= 6; i++) {
        await device('p$i', 'd1', 's1', '0x$i');
      }
      await device('p7', 'd1', 's1', '0x1'); // twice: once in the group
      for (var i = 1; i <= 4; i++) {
        await sceneTile('c$i', 'd1', 's1', 'scene$i');
      }
      await device('p8', 'd1', 's2', '0x8');
      await service.resyncGroups();
      final groups = (jsonDecode(prefs.getString(shortcutGroupsKey)!) as List)
          .cast<Map<String, dynamic>>();
      expect(groups.map((g) => g['name']), ['Main', 'Lights', 'Covers']);
      expect(groups.map((g) => g['id']), ['dashboard:d1', 's1', 's2']);
      expect(groups[1], {
        'connectionId': 'home',
        'id': 's1',
        'home': 'Home',
        'dashboard': 'Main',
        'name': 'Lights',
        'ieees': ['0x1', '0x2', '0x3', '0x4', '0x5'],
        'scenes': ['scene1', 'scene2', 'scene3'],
      });
      expect(groups[0]['ieees'], ['0x0']);
    });

    test('a section with no devices or scenes is not offered', () async {
      await dashboard('d1', 'Main');
      await section('s1', 'd1', 'Empty', 0);
      await service.resyncGroups();
      expect(jsonDecode(prefs.getString(shortcutGroupsKey)!), isEmpty);
    });

    test('a group widget becomes a group shortcut of its devices', () async {
      await prefs.setString('shortcut.widget.5',
          '{"kind":"group","connectionId":"home","name":"Lights",'
          '"ieees":["0x1","0x2","0x3"],"scenes":["scene1"]}');
      await service.syncWidgets();
      final row = (await db.select(db.shortcuts).get()).single;
      expect(row.kind, ShortcutKind.group);
      expect(shortcutTargets(row), ['0x1', '0x2', '0x3']);

      // Changing its devices (set up again) updates the row.
      await prefs.setString('shortcut.widget.5',
          '{"kind":"group","connectionId":"home","name":"Lights",'
          '"ieees":["0x1","0x4"],"scenes":[]}');
      await service.syncWidgets();
      expect(shortcutTargets((await db.select(db.shortcuts).get()).single),
          ['0x1', '0x4']);
    });
  });
}
