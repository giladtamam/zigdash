import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/ha_import/ha_registry.dart';

// Shaped like the user's Home Assistant 2026.1.1 on 2026-10-16 (see
// docs/design/ha-import.md, "Checked on a real Home Assistant"): three
// motion sensors, the bridge, a shutter Zigbee2MQTT removed long ago, rooms
// with Hebrew names, one floor, and a room set only on a device's entities.
Map<String, Object?> _dev(
  String id,
  String ident, {
  String? name,
  String? byUser,
  String? area,
  String? parent,
  String domain = 'mqtt',
}) => {
  'id': id,
  'identifiers': [
    [domain, ident],
  ],
  'name': name,
  'name_by_user': byUser,
  'area_id': area,
  'parent_device_id': parent,
  'config_entries': ['01KJQDAXG9DJVSZYAQWS4XMRYN'],
  'connections': <Object?>[],
  'model': 'Motion sensor',
  'model_id': 'ZG-204Z',
};

final _registry = HaRegistry.fromLists(
  devices: [
    _dev('shutter', 'zigbee2mqtt_0xc02cedfffec08aa5', name: 'תריס חדר עבודה'),
    _dev(
      'bridge',
      'zigbee2mqtt_bridge_0x00be44fffe70c427',
      name: 'Zigbee2MQTT Bridge',
      area: 'khdr_hvrym',
    ),
    _dev(
      'living',
      'zigbee2mqtt_0xa4c13836276df66f',
      name: '0xa4c13836276df66f',
      byUser: 'Living room motion',
      area: 'living_room',
    ),
    _dev(
      'kitchen',
      'zigbee2mqtt_0xa4c13828d7b8e8a1',
      name: '0xa4c13828d7b8e8a1',
      byUser: 'Kitchen motion',
      area: 'kitchen',
    ),
    _dev(
      'bedroom',
      'zigbee2mqtt_0xa4c13863521bcd41',
      name: '0xa4c13863521bcd41',
      byUser: 'Bedroom motion',
    ),
    _dev(
      'group',
      'zigbee2mqtt_1221051039810110150109113116116_5',
      name: 'All lights',
    ),
  ],
  areas: [
    {
      'area_id': 'living_room',
      'name': 'Living Room',
      'floor_id': 'ground_floor',
    },
    {'area_id': 'kitchen', 'name': 'Kitchen', 'floor_id': 'ground_floor'},
    {'area_id': 'bedroom', 'name': 'Bedroom', 'floor_id': null},
    {'area_id': 'khdr_hvrym', 'name': 'חדר הורים', 'floor_id': null},
  ],
  floors: [
    {'floor_id': 'ground_floor', 'name': 'Ground floor', 'level': 0},
  ],
  entitiesForDisplay: {
    'entity_categories': {},
    'entities': [
      {
        'ei': 'binary_sensor.0xa4c13863521bcd41_occupancy',
        'di': 'bedroom',
        'ai': 'bedroom',
      },
      {
        'ei': 'sensor.0xa4c13863521bcd41_battery',
        'di': 'bedroom',
        'ai': 'bedroom',
      },
      {'ei': 'binary_sensor.0xa4c13836276df66f_occupancy', 'di': 'living'},
    ],
  },
);

Z2mDevice _z2m(String ieee) => Z2mDevice(
  friendlyName: ieee,
  type: 'EndDevice',
  ieeeAddress: ieee,
  model: 'ZG-204Z',
  description: 'Motion sensor',
);

final _z2mDevices = [
  _z2m('0xa4c13836276df66f'),
  _z2m('0xa4c13828d7b8e8a1'),
  _z2m('0xa4c13863521bcd41'),
];

void main() {
  test('Zigbee2MQTT devices are known by their address; bridge and groups '
      'are not devices', () {
    final ieee = {for (final d in _registry.devices) d.id: d.z2mIeee};
    expect(ieee['living'], '0xa4c13836276df66f');
    expect(ieee['bridge'], isNull);
    expect(ieee['group'], isNull);
  });

  test('a dashboard per floor, a section per room, the rest last', () {
    final plan = planImport(_registry, _z2mDevices);
    expect(plan.dashboards.map((d) => d.floor), ['Ground floor', null]);
    final ground = plan.dashboards.first;
    expect(ground.rooms.map((r) => r.name), ['Kitchen', 'Living Room']);
    expect(ground.rooms.first.devices.single.name, 'Kitchen motion');
    expect(plan.matched, 3);
    expect(plan.rooms, 3);
    expect(plan.zhaOnly, isFalse);
  });

  test('a room set only on the entities counts', () {
    final noFloor = planImport(_registry, _z2mDevices).dashboards.last;
    expect(noFloor.rooms.single.name, 'Bedroom');
    expect(noFloor.rooms.single.devices.single.name, 'Bedroom motion');
  });

  test('devices Zigbee2MQTT no longer has are not imported', () {
    final plan = planImport(_registry, _z2mDevices);
    final names = [
      for (final d in plan.dashboards)
        for (final r in d.rooms)
          for (final x in r.devices) x.name,
    ];
    expect(names, isNot(contains('תריס חדר עבודה')));
  });

  test('no floors: one dashboard; no area: a section without a name', () {
    final plan = planImport(
      HaRegistry.fromLists(
        devices: [
          _dev(
            'a',
            'zigbee2mqtt_0xa4c13836276df66f',
            byUser: 'Hall',
            area: 'hall',
          ),
          _dev(
            'b',
            'zigbee2mqtt_0xa4c13828d7b8e8a1',
            name: '0xa4c13828d7b8e8a1',
          ),
        ],
        areas: [
          {'area_id': 'hall', 'name': 'Hall'},
        ],
      ),
      _z2mDevices,
    );
    expect(plan.dashboards.single.floor, isNull);
    expect(plan.dashboards.single.rooms.map((r) => r.name), ['Hall', null]);
    // Named nowhere: the device's own readable name.
    expect(
      plan.dashboards.single.rooms.last.devices.single.name,
      'Motion sensor e8a1',
    );
  });

  test('child devices are skipped; a device listed twice counts once', () {
    final plan = planImport(
      HaRegistry.fromLists(
        devices: [
          _dev('a', 'zigbee2mqtt_0xa4c13836276df66f', byUser: 'One'),
          _dev('a2', 'zigbee2mqtt_0xa4c13836276df66f', byUser: 'Again'),
          _dev(
            'c',
            'zigbee2mqtt_0xa4c13828d7b8e8a1',
            byUser: 'Child',
            parent: 'a',
          ),
        ],
        areas: const [],
      ),
      _z2mDevices,
    );
    expect(plan.matched, 1);
  });

  test('ZHA only: nothing to import, and the plan says why', () {
    final plan = planImport(
      HaRegistry.fromLists(
        devices: [
          _dev('z', '84:fd:27:ff:fe:6d:2f:80', name: 'Lamp', domain: 'zha'),
        ],
        areas: const [],
      ),
      _z2mDevices,
    );
    expect(plan.matched, 0);
    expect(plan.zhaOnly, isTrue);
  });

  test('odd shapes are skipped, not fatal', () {
    final registry = HaRegistry.fromLists(
      devices: [
        {'identifiers': 'nope'},
        {
          'id': 'x',
          'identifiers': [
            ['mqtt'],
          ],
        },
        null,
      ],
      areas: [
        {'area_id': 3},
      ],
      floors: null,
      entitiesForDisplay: {'entities': 'nope'},
    );
    expect(registry.devices.single.z2mIeee, isNull);
    expect(registry.areas, isEmpty);
    expect(planImport(registry, _z2mDevices).dashboards, isEmpty);
  });

  group('3.8: names and rooms from the old ZHA entries', () {
    Map<String, Object?> zha(
      String id,
      String ieee, {
      String? byUser,
      String? area,
      String? via = 'coord',
    }) => {
      ..._dev(id, ieee, byUser: byUser, area: area, domain: 'zha'),
      'name': 'TS0601',
      'via_device_id': via,
      'disabled_by': 'config_entry',
    };

    final registry = HaRegistry.fromLists(
      devices: [
        // ZHA's coordinator: no parent device; never a tile.
        zha('coord', '00:be:44:ff:fe:70:c4:27', byUser: 'Stick', via: null),
        zha(
          'z-living',
          'a4:c1:38:36:27:6d:f6:6f',
          byUser: 'Sofa motion',
          area: 'living_room',
        ),
        zha(
          'z-kitchen',
          'a4:c1:38:28:d7:b8:e8:a1',
          byUser: 'Old kitchen',
          area: 'bedroom',
        ),
        zha('z-bedroom', 'a4:c1:38:63:52:1b:cd:41'),
        // The same kitchen sensor, now in Zigbee2MQTT, named and placed.
        _dev(
          'kitchen',
          'zigbee2mqtt_0xa4c13828d7b8e8a1',
          byUser: 'Kitchen motion',
          area: 'kitchen',
        ),
        // The living-room sensor in Zigbee2MQTT, not yet named or placed.
        _dev(
          'living',
          'zigbee2mqtt_0xa4c13836276df66f',
          name: '0xa4c13836276df66f',
        ),
      ],
      areas: [
        {'area_id': 'living_room', 'name': 'Living Room'},
        {'area_id': 'kitchen', 'name': 'Kitchen'},
        {'area_id': 'bedroom', 'name': 'Bedroom'},
      ],
    );

    test('ZHA addresses become Zigbee2MQTT ones; the coordinator has none', () {
      final ieee = {for (final d in registry.devices) d.id: d.zhaIeee};
      expect(ieee['z-living'], '0xa4c13836276df66f');
      expect(ieee['coord'], isNull);
      expect(ieee['kitchen'], isNull);
    });

    test('an unnamed Zigbee2MQTT entry takes the ZHA name and room; a named '
        'one keeps its own', () {
      final plan = planImport(registry, [
        ..._z2mDevices,
        _z2m('0x00be44fffe70c427'),
      ]);
      final rooms = {
        for (final d in plan.dashboards)
          for (final r in d.rooms) r.name: [for (final x in r.devices) x.name],
      };
      expect(rooms['Living Room'], ['Sofa motion']);
      expect(rooms['Kitchen'], ['Kitchen motion']);
      // No MQTT entry: ZHA's alone; nothing to give, so the device's own.
      expect(rooms[null], ['Motion sensor cd41']);
      expect(plan.matched, 3, reason: 'the stick is never a device');
      expect(plan.fromZha, 1);
      expect(plan.zhaOnly, isFalse);
    });

    test('no MQTT entries at all (no MQTT integration): ZHA alone', () {
      final zhaOnly = HaRegistry.fromLists(
        devices: [
          for (final d in registry.devices.where((d) => d.isZha))
            zha(
              d.id,
              d.identifiers.single.$2,
              byUser: d.nameByUser,
              area: d.areaId,
              via: d.viaId,
            ),
        ],
        areas: [
          {'area_id': 'living_room', 'name': 'Living Room'},
          {'area_id': 'bedroom', 'name': 'Bedroom'},
        ],
      );
      final plan = planImport(zhaOnly, _z2mDevices);
      expect(plan.matched, 3);
      expect(plan.fromZha, 2);
      final names = [
        for (final d in plan.dashboards)
          for (final r in d.rooms)
            for (final x in r.devices) '${r.name}/${x.name}',
      ];
      expect(
        names,
        containsAll([
          'Bedroom/Old kitchen',
          'Living Room/Sofa motion',
          'null/Motion sensor cd41',
        ]),
      );
    });
    test('a name given in Zigbee2MQTT since the move wins over ZHA\'s', () {
      final renamed = Z2mDevice(
        friendlyName: 'Couch sensor',
        type: 'EndDevice',
        ieeeAddress: '0xa4c13836276df66f',
        model: 'ZG-204Z',
        description: 'Motion sensor',
      );
      final plan = planImport(registry, [renamed]);
      final device = plan.dashboards.single.rooms.single;
      expect(device.name, 'Living Room', reason: 'the room still comes');
      expect(device.devices.single.name, 'Couch sensor');
      expect(plan.fromZha, 1);
    });

    test('nothing paired in Zigbee2MQTT yet is not "ZHA only"', () {
      final plan = planImport(registry, const []);
      expect(plan.matched, 0);
      expect(plan.zhaOnly, isFalse);
      expect(plan.z2mEmpty, isTrue);
    });
  });
}
