import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.test(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> insert(
    String id,
    PanelType type, {
    required String topic,
    String? subscribe,
    String? prefix,
  }) =>
      db.into(db.panels).insert(PanelsCompanion.insert(
            id: id,
            dashboardId: 'd1',
            name: id,
            type: type,
            topic: topic,
            subscribeTopic: Value(subscribe),
            topicPrefixOverride: Value(prefix),
            width: PanelWidth.half,
            config: '{}',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ));

  Future<(String, String?)> topics(String id) async {
    final p = (await PanelDao(db).getById(id))!;
    return (p.topic, p.subscribeTopic);
  }

  test('1.11.0 setup tiles are rewritten to set / empty suffixes', () async {
    const lamp = 'zigbee2mqtt/lamp';
    await insert('toggle', PanelType.toggle,
        topic: lamp, subscribe: lamp, prefix: lamp);
    await insert('slider', PanelType.slider,
        topic: lamp, subscribe: lamp, prefix: lamp);
    await insert('led', PanelType.led,
        topic: 'zigbee2mqtt/door', subscribe: 'zigbee2mqtt/door',
        prefix: 'zigbee2mqtt/door');

    await db.repairSetupTopics();

    expect(await topics('toggle'), ('set', ''));
    expect(await topics('slider'), ('set', ''));
    expect(await topics('led'), ('', ''));
  });

  test('hand-made tiles are left alone, and a second run changes nothing',
      () async {
    await insert('manual', PanelType.toggle,
        topic: 'set', subscribe: '', prefix: 'zigbee2mqtt/lamp');
    await insert('plain', PanelType.toggle,
        topic: 'light/living/set', subscribe: 'light/living');
    await insert('broken', PanelType.cover,
        topic: 'z2m/blind', subscribe: 'z2m/blind', prefix: 'z2m/blind');

    await db.repairSetupTopics();
    await db.repairSetupTopics();

    expect(await topics('manual'), ('set', ''));
    expect(await topics('plain'), ('light/living/set', 'light/living'));
    expect(await topics('broken'), ('set', ''));
  });
}
