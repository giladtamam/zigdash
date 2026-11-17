import '../discovery/models/z2m_device.dart';

/// What Home Assistant knows about a home, read once from its registries
/// (`config/device_registry/list`, `config/area_registry/list`,
/// `config/floor_registry/list`, `config/entity_registry/list_for_display`)
/// for the import (docs/design/ha-import.md). Parsing is defensive: unknown
/// fields are ignored and missing ones read as absent.
class HaRegistry {
  const HaRegistry({
    required this.devices,
    required this.areas,
    this.floors = const [],
    this.entityAreas = const {},
  });

  /// Parses the four list results as Home Assistant sends them. [floors] is
  /// null when the floor registry could not be read (an old Home
  /// Assistant): no floors.
  factory HaRegistry.fromLists({
    required List<Object?> devices,
    required List<Object?> areas,
    List<Object?>? floors,
    Map<String, Object?>? entitiesForDisplay,
  }) {
    final entityAreas = <String, Set<String>>{};
    final entities = entitiesForDisplay?['entities'];
    if (entities is List) {
      for (final e in entities.whereType<Map>()) {
        final device = e['di'], area = e['ai'];
        if (device is String && area is String) {
          entityAreas.putIfAbsent(device, () => {}).add(area);
        }
      }
    }
    return HaRegistry(
      devices: [
        for (final d in devices.whereType<Map>()) ?HaDevice.fromJson(d),
      ],
      areas: [for (final a in areas.whereType<Map>()) ?HaArea.fromJson(a)],
      floors: [
        for (final f in (floors ?? const []).whereType<Map>())
          ?HaFloor.fromJson(f),
      ],
      entityAreas: entityAreas,
    );
  }

  final List<HaDevice> devices;
  final List<HaArea> areas;
  final List<HaFloor> floors;

  /// The areas a device's entities are in, by device id, where an entity
  /// has its own area.
  final Map<String, Set<String>> entityAreas;
}

class HaDevice {
  const HaDevice({
    required this.id,
    required this.identifiers,
    this.name,
    this.nameByUser,
    this.areaId,
    this.parentId,
    this.viaId,
  });

  static HaDevice? fromJson(Map<Object?, Object?> json) {
    final id = json['id'];
    if (id is! String) return null;
    final identifiers = <(String, String)>[
      for (final i in (json['identifiers'] as List?) ?? const [])
        if (i is List && i.length == 2 && i[0] is String && i[1] is String)
          (i[0] as String, i[1] as String),
    ];
    return HaDevice(
      id: id,
      identifiers: identifiers,
      name: json['name'] as String?,
      nameByUser: json['name_by_user'] as String?,
      areaId: json['area_id'] as String?,
      parentId: json['parent_device_id'] as String?,
      viaId: json['via_device_id'] as String?,
    );
  }

  final String id;
  final List<(String, String)> identifiers;
  final String? name;
  final String? nameByUser;
  final String? areaId;

  /// Set on child devices (Home Assistant 2026.9+); those are skipped.
  final String? parentId;

  /// The device this one connects through. Every ZHA device but the
  /// coordinator has one.
  final String? viaId;

  /// The name the user gave the device in Home Assistant. Without one,
  /// Home Assistant's `name` is only Zigbee2MQTT's own (often the address),
  /// which ZigDash already shows better.
  String? get userName {
    final n = nameByUser?.trim();
    return n == null || n.isEmpty ? null : n;
  }

  /// The Zigbee2MQTT device's IEEE address, lowercased, when this is one:
  /// `["mqtt", "zigbee2mqtt_0x…"]`. Null for the bridge
  /// (`zigbee2mqtt_bridge_…`), groups and anything else.
  String? get z2mIeee {
    for (final (domain, value) in identifiers) {
      if (domain != 'mqtt') continue;
      final m = _z2mDevice.firstMatch(value);
      if (m != null) return m.group(1)!.toLowerCase();
    }
    return null;
  }

  /// A device ZHA (Home Assistant's own Zigbee) runs.
  bool get isZha => identifiers.any((i) => i.$1 == 'zha');

  /// The IEEE address of a device ZHA runs (not its coordinator), in
  /// Zigbee2MQTT's form: ZHA's `aa:bb:…` becomes `0xaabb…`. After a move
  /// from ZHA (zha-migration.md), the same device has the same address in
  /// Zigbee2MQTT, and ZHA's entry, disabled or not, still has its name and
  /// room.
  String? get zhaIeee {
    if (viaId == null) return null;
    for (final (domain, value) in identifiers) {
      if (domain != 'zha') continue;
      final hex = value.replaceAll(':', '').toLowerCase();
      if (_hex16.hasMatch(hex)) return '0x$hex';
    }
    return null;
  }
}

final _z2mDevice = RegExp(r'^zigbee2mqtt_(0x[0-9a-fA-F]{16})$');
final _hex16 = RegExp(r'^[0-9a-f]{16}$');

class HaArea {
  const HaArea({required this.id, required this.name, this.floorId});

  static HaArea? fromJson(Map<Object?, Object?> json) {
    final id = json['area_id'], name = json['name'];
    if (id is! String || name is! String) return null;
    return HaArea(id: id, name: name, floorId: json['floor_id'] as String?);
  }

  final String id;
  final String name;
  final String? floorId;
}

class HaFloor {
  const HaFloor({required this.id, required this.name, this.level});

  static HaFloor? fromJson(Map<Object?, Object?> json) {
    final id = json['floor_id'], name = json['name'];
    if (id is! String || name is! String) return null;
    final level = json['level'];
    return HaFloor(id: id, name: name, level: level is int ? level : null);
  }

  final String id;
  final String name;
  final int? level;
}

/// A Zigbee2MQTT device with the name Home Assistant gives it.
class ImportedDevice {
  const ImportedDevice({required this.device, required this.name});
  final Z2mDevice device;

  /// The name given in Home Assistant, or the device's own readable name.
  final String name;
}

/// One section of an imported dashboard: a Home Assistant area, or the
/// devices in no area ([name] null).
class ImportRoom {
  const ImportRoom({required this.name, required this.devices});
  final String? name;
  final List<ImportedDevice> devices;
}

/// One dashboard to create: a floor, or the rooms on no floor ([floor]
/// null, the only dashboard when the home has no floors).
class ImportDashboard {
  const ImportDashboard({required this.floor, required this.rooms});
  final String? floor;
  final List<ImportRoom> rooms;
}

/// What the import would create, for the preview (decisions Q3 and Q4:
/// a dashboard per floor, a section per room, built from rooms rather than
/// Home Assistant's own dashboards).
class ImportPlan {
  const ImportPlan({
    required this.dashboards,
    required this.zhaDevices,
    this.fromZha = 0,
    required this.z2mDevices,
  });
  final List<ImportDashboard> dashboards;

  /// Devices whose name or room came from their old ZHA entry (3.8).
  final int fromZha;

  /// Devices Zigbee2MQTT has. None during a move (nothing paired yet) is
  /// not "ZHA only" (3.8).
  final int z2mDevices;

  /// Devices ZHA runs. ZigDash cannot show them; when nothing matched and
  /// these exist, Zigbee2MQTT is not in use and the import says so.
  final int zhaDevices;

  int get matched => [
    for (final d in dashboards)
      for (final r in d.rooms) r.devices.length,
  ].fold(0, (a, b) => a + b);

  int get rooms => [
    for (final d in dashboards)
      for (final r in d.rooms)
        if (r.name != null) r,
  ].length;

  bool get zhaOnly => matched == 0 && zhaDevices > 0 && z2mDevices > 0;

  /// Nothing paired in Zigbee2MQTT yet, often mid-move from ZHA (3.8).
  bool get z2mEmpty => matched == 0 && z2mDevices == 0;
}

/// Matches Home Assistant's devices to the Zigbee2MQTT devices ZigDash sees,
/// by IEEE address, and sorts them into floors and rooms. Only devices in
/// [z2m] count: Home Assistant keeps devices Zigbee2MQTT has removed.
///
/// A device's room is its own area, unless all of its entities that have an
/// area share a different one (a room set on the entities only). Floors
/// order by level, then name; rooms and devices by name.
ImportPlan planImport(HaRegistry registry, List<Z2mDevice> z2m) {
  final byIeee = {
    for (final d in z2m)
      if (d.ieeeAddress != null) d.ieeeAddress!.toLowerCase(): d,
  };
  final areas = {for (final a in registry.areas) a.id: a};
  final floors = {for (final f in registry.floors) f.id: f};

  // A device moved from ZHA keeps its address: ZHA's entry fills in a
  // name or room the Zigbee2MQTT one lacks (3.8, zha-migration.md).
  final zhaByIeee = <String, HaDevice>{
    for (final d in registry.devices)
      if (d.parentId == null && d.zhaIeee != null) d.zhaIeee!: d,
  };

  // floor id (or null) -> area id (or null) -> devices
  final grouped = <String?, Map<String?, List<ImportedDevice>>>{};
  final seen = <String>{};
  var fromZha = 0;
  void add(Z2mDevice device, String? areaId, String? name) {
    final floorId = areas[areaId]?.floorId;
    grouped
        .putIfAbsent(floors.containsKey(floorId) ? floorId : null, () => {})
        .putIfAbsent(areaId, () => [])
        .add(ImportedDevice(device: device, name: name ?? device.displayName));
  }

  String? zhaRoom(HaDevice? zha) =>
      zha == null ? null : _roomOf(zha, registry.entityAreas[zha.id], areas);

  for (final ha in registry.devices) {
    if (ha.parentId != null) continue;
    final ieee = ha.z2mIeee;
    final device = ieee == null ? null : byIeee[ieee];
    if (device == null || !seen.add(ieee!)) continue;
    final zha = zhaByIeee[ieee];
    final room = _roomOf(ha, registry.entityAreas[ha.id], areas);
    final name = ha.userName ?? (_unnamed(device) ? zha?.userName : null);
    final areaId = room ?? zhaRoom(zha);
    if ((ha.userName == null && name != null) ||
        (room == null && areaId != null)) {
      fromZha++;
    }
    add(device, areaId, name);
  }
  // Zigbee2MQTT devices Home Assistant has no MQTT entry for (no MQTT
  // integration, or discovery off): ZHA's entry alone.
  for (final MapEntry(key: ieee, value: zha) in zhaByIeee.entries) {
    final device = byIeee[ieee];
    if (device == null || !seen.add(ieee)) continue;
    final areaId = zhaRoom(zha);
    final name = _unnamed(device) ? zha.userName : null;
    if (name != null || areaId != null) fromZha++;
    add(device, areaId, name);
  }

  int byName(String? a, String? b) {
    if (a == null) return b == null ? 0 : 1; // no room/floor goes last
    if (b == null) return -1;
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  final floorIds = grouped.keys.toList()
    ..sort((a, b) {
      if (a == null || b == null) return byName(a, b);
      final la = floors[a]!.level, lb = floors[b]!.level;
      if (la != null && lb != null && la != lb) return la.compareTo(lb);
      return byName(floors[a]!.name, floors[b]!.name);
    });
  return ImportPlan(
    dashboards: [
      for (final f in floorIds)
        ImportDashboard(
          floor: f == null ? null : floors[f]!.name,
          rooms: [
            for (final a
                in grouped[f]!.keys.toList()
                  ..sort((x, y) => byName(areas[x]?.name, areas[y]?.name)))
              ImportRoom(
                name: areas[a]?.name,
                devices: grouped[f]![a]!
                  ..sort((x, y) => byName(x.name, y.name)),
              ),
          ],
        ),
    ],
    zhaDevices: registry.devices.where((d) => d.isZha).length,
    fromZha: fromZha,
    z2mDevices: byIeee.length,
  );
}

/// Still called by its address in Zigbee2MQTT: a name given there since the
/// move wins over the old ZHA one.
bool _unnamed(Z2mDevice d) =>
    d.friendlyName.toLowerCase() == d.ieeeAddress?.toLowerCase();

String? _roomOf(
  HaDevice device,
  Set<String>? entityAreas,
  Map<String, HaArea> areas,
) {
  final own = areas.containsKey(device.areaId) ? device.areaId : null;
  final entities = entityAreas?.where(areas.containsKey).toSet() ?? const {};
  if (entities.length == 1 && entities.single != own) return entities.single;
  return own;
}
