import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
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
}
