import 'dart:convert';

import '../../data/database/database.dart' show Panel;
import '../../data/database/tables/panels.dart' show PanelType;
import '../devices/device_profile.dart';
import '../panels/models/panel_config.dart';
import 'history_record.dart';

/// The retained config the recorder reads (docs/design/history-2.7.md).
const historyConfigTopic = 'zigdash/history/config';

/// The recorder's heartbeat: `online`, or `offline` by its Last Will.
const historyBridgeTopic = 'zigdash/history/bridge/state';

/// At most this many readings are recorded per Home.
const historyMaxReadings = 50;

/// One recorded value: a device's numeric attribute at [path] of its state
/// topic [topic].
class HistoryReading {
  const HistoryReading({
    required this.ieee,
    required this.path,
    required this.topic,
    this.unit,
  });

  final String ieee;
  final String path;
  final String topic;
  final String? unit;

  String get attr => historyAttr(path);

  Map<String, Object?> toJson() => {
    'ieee': ieee,
    'attr': attr,
    'topic': topic,
    'path': path,
    'unit': unit ?? '',
  };

  @override
  bool operator ==(Object other) =>
      other is HistoryReading &&
      other.ieee == ieee &&
      other.path == path &&
      other.topic == topic &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(ieee, path, topic, unit);

  @override
  String toString() => 'HistoryReading($ieee $path @ $topic $unit)';
}

/// The values a device tile shows, primary first: a climate sensor's two
/// readings (temperature and humidity), any other class's first reading
/// (a plug's power). Matches the tile in device_tile_panel.dart.
List<DeviceFeature> historyShownOnDeviceTile(DeviceProfile profile) => profile
    .readings
    .take(profile.deviceClass == DeviceClass.climate ? 2 : 1)
    .toList();

/// What a Home records: every number its dashboards show, from reading
/// tiles and from device tiles, once each, in dashboard order, at most
/// [historyMaxReadings]. Tiles not linked to a device are left out: the
/// recorder keys history by IEEE address so renames keep it.
List<HistoryReading> historyReadingsOf(Iterable<Panel> tiles) {
  final out = <HistoryReading>[];
  final seen = <String>{};
  void add(Panel tile, String path, String? unit) {
    final ieee = tile.deviceIeee;
    final topic = tile.topicPrefixOverride;
    if (ieee == null || topic == null || topic.isEmpty || path.isEmpty) {
      return;
    }
    if (!seen.add('$ieee/${historyAttr(path)}')) return;
    out.add(HistoryReading(ieee: ieee, path: path, topic: topic, unit: unit));
  }

  for (final tile in tiles) {
    if (out.length >= historyMaxReadings) break;
    switch (tile.type) {
      case PanelType.reading:
        final c = PanelConfig.decode(PanelType.reading, tile.config);
        if (c is ReadingConfig) add(tile, c.jsonPath, c.unit);
      case PanelType.device:
        final c = PanelConfig.decode(PanelType.device, tile.config);
        if (c is DeviceTileConfig) {
          for (final f in historyShownOnDeviceTile(c.profile)) {
            add(tile, f.property, f.unit);
          }
        }
      default:
        break;
    }
  }
  return out.take(historyMaxReadings).toList();
}

/// At most this many devices are tallied per Home (3.3).
const historyMaxTallies = 50;

/// What a tally counts: a light or plug turning on ([on]), a door or window
/// opening ([open]), a motion sensor seeing motion ([motion]).
enum HistoryTallyKind { on, open, motion }

/// One tallied device (3.3, the weekly card): the Engine counts the times
/// the value at [path] turns on and the minutes it stays on.
class HistoryTally {
  const HistoryTally({
    required this.ieee,
    required this.path,
    required this.topic,
    required this.kind,
  });

  final String ieee;
  final String path;
  final String topic;
  final HistoryTallyKind kind;

  String get attr => historyAttr(path);

  Map<String, Object?> toJson() => {
    'ieee': ieee,
    'attr': attr,
    'topic': topic,
    'path': path,
    'kind': kind.name,
  };

  @override
  bool operator ==(Object other) =>
      other is HistoryTally &&
      other.ieee == ieee &&
      other.path == path &&
      other.topic == topic &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(ieee, path, topic, kind);
}

/// What a Home tallies: every light, plug, door and motion sensor with a
/// device tile on its dashboards, once each, at most [historyMaxTallies].
List<HistoryTally> historyTalliesOf(Iterable<Panel> tiles) {
  final out = <HistoryTally>[];
  final seen = <String>{};
  for (final tile in tiles) {
    if (out.length >= historyMaxTallies) break;
    final ieee = tile.deviceIeee;
    final topic = tile.topicPrefixOverride;
    if (tile.type != PanelType.device ||
        ieee == null ||
        topic == null ||
        topic.isEmpty) {
      continue;
    }
    final c = PanelConfig.decode(PanelType.device, tile.config);
    if (c is! DeviceTileConfig) continue;
    final profile = c.profile;
    final (String? path, HistoryTallyKind kind) = switch (profile.deviceClass) {
      DeviceClass.light || DeviceClass.colorLight || DeviceClass.switchPlug => (
        profile.switches.firstOrNull?.property,
        HistoryTallyKind.on,
      ),
      DeviceClass.contact => (
        _featureNamed(profile, 'contact'),
        HistoryTallyKind.open,
      ),
      DeviceClass.motion => (
        _featureNamed(profile, 'occupancy'),
        HistoryTallyKind.motion,
      ),
      _ => (null, HistoryTallyKind.on),
    };
    if (path == null || !seen.add('$ieee/${historyAttr(path)}')) continue;
    out.add(HistoryTally(ieee: ieee, path: path, topic: topic, kind: kind));
  }
  return out;
}

String? _featureNamed(DeviceProfile profile, String property) {
  for (final f in profile.features) {
    if (f.property == property) return f.property;
  }
  return null;
}

/// The config payload for the recorder.
String encodeHistoryConfig({
  required String home,
  required String base,
  required String timeZone,
  required List<HistoryReading> readings,
  List<HistoryTally> tallies = const [],
}) => jsonEncode({
  'v': 1,
  'home': home,
  'base': base,
  'timeZone': timeZone,
  'keepDays': historyKeepDays,
  'readings': [for (final r in readings) r.toJson()],
  if (tallies.isNotEmpty) 'tallies': [for (final t in tallies) t.toJson()],
});

/// The tallies in a retained config payload; empty for none or a broken one.
List<HistoryTally> decodeHistoryTallies(String payload) {
  if (payload.trim().isEmpty) return const [];
  try {
    final j = jsonDecode(payload);
    if (j is! Map || j['tallies'] is! List) return const [];
    return [
      for (final t in j['tallies'] as List)
        if (t is Map &&
            t['ieee'] is String &&
            t['path'] is String &&
            t['topic'] is String &&
            HistoryTallyKind.values.any((k) => k.name == t['kind']))
          HistoryTally(
            ieee: t['ieee'] as String,
            path: t['path'] as String,
            topic: t['topic'] as String,
            kind: HistoryTallyKind.values.byName(t['kind'] as String),
          ),
    ];
  } on FormatException {
    return const [];
  }
}

/// [mine] merged into [retained] as for readings: another phone's tallies
/// stay, mine replace theirs for the same device.
List<HistoryTally> mergeHistoryTallies(
  List<HistoryTally> retained,
  List<HistoryTally> mine,
) {
  String key(HistoryTally t) => '${t.ieee}/${t.attr}';
  final byKey = {for (final t in mine) key(t): t};
  final out = <HistoryTally>[for (final t in retained) byKey[key(t)] ?? t];
  final seen = {for (final t in out) key(t)};
  for (final t in mine) {
    if (seen.add(key(t))) out.add(t);
  }
  return out.take(historyMaxTallies).toList();
}

/// The readings in a retained config payload; empty for none or a broken one.
List<HistoryReading> decodeHistoryReadings(String payload) {
  if (payload.trim().isEmpty) return const [];
  try {
    final j = jsonDecode(payload);
    if (j is! Map || j['readings'] is! List) return const [];
    return [
      for (final r in j['readings'] as List)
        if (r is Map &&
            r['ieee'] is String &&
            r['path'] is String &&
            r['topic'] is String)
          HistoryReading(
            ieee: r['ieee'] as String,
            path: r['path'] as String,
            topic: r['topic'] as String,
            unit: (r['unit'] as String?)?.isEmpty ?? true
                ? null
                : r['unit'] as String,
          ),
    ];
  } on FormatException {
    return const [];
  }
}

/// What to record when several phones share a Home: the readings already
/// on the broker, then this phone's new ones, at most [historyMaxReadings].
/// Phones only ever add, so two phones with different dashboards converge
/// instead of overwriting each other. A reading whose topic changed (a
/// renamed device) takes this phone's topic.
List<HistoryReading> mergeHistoryReadings(
  List<HistoryReading> retained,
  List<HistoryReading> mine,
) {
  String key(HistoryReading r) => '${r.ieee}/${r.attr}';
  final byKey = {for (final r in mine) key(r): r};
  final out = <HistoryReading>[for (final r in retained) byKey[key(r)] ?? r];
  final seen = {for (final r in out) key(r)};
  for (final r in mine) {
    if (seen.add(key(r))) out.add(r);
  }
  return out.take(historyMaxReadings).toList();
}
