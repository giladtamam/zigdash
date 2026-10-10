import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
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
}
