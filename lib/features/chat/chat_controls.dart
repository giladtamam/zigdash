import '../devices/device_profile.dart';
import '../discovery/models/z2m_device.dart';

/// What a device is to ZigDash Chat, from Zigbee2MQTT's exposes, never its
/// name (the same rules as `chatReadOnlyKind` and `chatKindOf` in
/// hub/src/chat.js). Locks, valves and sirens are never controllable from a
/// chat, so they are never on the control list.
enum ChatKind { light, cover, thermostat, switchPlug, lock, valve, siren, other }

extension ChatKindX on ChatKind {
  bool get readOnly => this == ChatKind.lock || this == ChatKind.valve || this == ChatKind.siren;
}

/// Every expose and nested feature, flattened (`chatExposes`).
List<Map<Object?, Object?>> _allExposes(List<Object?> exposes) {
  final out = <Map<Object?, Object?>>[];
  void walk(Object? list) {
    if (list is! List) return;
    for (final e in list) {
      if (e is! Map) continue;
      out.add(e);
      walk(e['features']);
    }
  }

  walk(exposes);
  return out;
}

List<String> _words(Map<Object?, Object?> e) => [
      for (final k in const ['type', 'name', 'property'])
        if (e[k] is String) (e[k] as String).toLowerCase(),
    ];

/// The read-only kind of a device (lock, valve or siren), or null.
ChatKind? chatReadOnlyKind(List<Object?> exposes, {String? description, String? model}) {
  final all = _allExposes(exposes);
  final about = '${description ?? ''} ${model ?? ''}';
  if (all.any((e) => e['type'] == 'lock' || _words(e).contains('lock_state'))) return ChatKind.lock;
  if (all.any((e) => _words(e).any((w) => w == 'warning' || w == 'squawk'))) return ChatKind.siren;
  if (all.any((e) => _words(e).contains('alarm') && ((e['access'] as num?)?.toInt() ?? 0) & 2 != 0)) {
    return ChatKind.siren;
  }
  if (RegExp(r'\bsiren\b', caseSensitive: false).hasMatch(about)) return ChatKind.siren;
  // A thermostat is not a valve even when its definition says "radiator valve".
  final climate = all.any((e) => e['type'] == 'climate');
  if (!climate) {
    const valveWords = {'valve', 'valve_state', 'valve_status'};
    if (all.any((e) => _words(e).any(valveWords.contains))) return ChatKind.valve;
    if (RegExp('valve', caseSensitive: false).hasMatch(about) &&
        all.any((e) => e['property'] == 'state' || e['name'] == 'state')) {
      return ChatKind.valve;
    }
  }
  return null;
}

/// The Chat kind of a device.
ChatKind chatKindOf(List<Object?> exposes, {String? description, String? model}) {
  final ro = chatReadOnlyKind(exposes, description: description, model: model);
  if (ro != null) return ro;
  final types = _allExposes(exposes).map((e) => e['type']).toSet();
  if (types.contains('light')) return ChatKind.light;
  if (types.contains('cover')) return ChatKind.cover;
  if (types.contains('climate')) return ChatKind.thermostat;
  if (types.contains('switch')) return ChatKind.switchPlug;
  // A plug with a bare settable state, as the device tiles see it.
  if (classifyExposes(exposes).deviceClass == DeviceClass.switchPlug) return ChatKind.switchPlug;
  return ChatKind.other;
}

// Gate, garage and door words in the app's 13 languages (en cs de es fr he
// it nb nl pl pt ru sv). Whole words only: "Tor" must not match "Motor" or
// "Monitor", nor "port" "Support".
const _gateWords = {
  'gate', 'gates', 'door', 'doors', 'garage', 'garages', // en
  'brána', 'brana', 'branka', 'vrata', 'dveře', 'dvere', 'garáž', 'garaz', // cs
  'tor', 'tore', 'tür', 'tuer', 'türe', 'garagentor', 'gartentor', 'hoftor', 'einfahrtstor',
  'rolltor', 'schiebetor', 'sektionaltor', 'flügeltor', 'haustür', 'garagentür', // de
  'puerta', 'portón', 'porton', 'verja', 'garaje', 'cochera', // es
  'portail', 'porte', 'portillon', // fr
  'שער', 'דלת', 'מוסך', 'חניה', // he
  'cancello', 'porta', 'portone', 'basculante', // it
  'port', 'grind', 'dør', 'garasje', 'garasjeport', 'garasjedør', // nb
  'poort', 'deur', 'garagedeur', 'garagepoort', 'tuinpoort', 'hek', // nl
  'brama', 'drzwi', 'furtka', 'garaż', 'wjazd', // pl
  'portão', 'portao', 'garagem', 'portões', // pt
  'ворота', 'калитка', 'дверь', 'двери', 'гараж', // ru
  'dörr', 'garageport', 'garagedörr', 'grindar', // sv
};

// Compound heads: a word ending in one of these is a door or a gate
// ("Hintertür", "achterdeur", "ytterdør", "altandörr", "frontdoor").
const _gateEndings = ['tür', 'deur', 'poort', 'dør', 'dörr', 'door'];
const _notGate = {'indoor', 'outdoor'};

// Hebrew joins "the", "and", "to"... to the word: השער, לדלת.
const _hebrewPrefixes = 'הובלמשכ';

/// Whether [text] (a device, tile, section or dashboard name) says gate,
/// garage or door in one of the app's languages.
bool chatLooksLikeGate(String text) {
  for (final raw in text.toLowerCase().split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))) {
    if (raw.isEmpty) continue;
    if (_gateWords.contains(raw)) return true;
    if (raw.length > 1 && _hebrewPrefixes.contains(raw[0]) && _gateWords.contains(raw.substring(1))) return true;
    if (!_notGate.contains(raw) && _gateEndings.any((e) => raw.length > e.length && raw.endsWith(e))) return true;
    if (raw.startsWith('garag') || raw.startsWith('garaż') || raw.startsWith('garáž') || raw.startsWith('гараж')) {
      return true;
    }
  }
  return false;
}

/// One device on the control list.
class ChatControlItem {
  const ChatControlItem({
    required this.ieee,
    required this.name,
    required this.kind,
    required this.onTile,
    required this.gate,
  });

  final String ieee;
  final String name;
  final ChatKind kind;

  /// On a dashboard tile of this Home.
  final bool onTile;

  /// Its name, a tile's, a section's or a dashboard's says gate, garage or door.
  final bool gate;

  /// The plan's defaults (chat-linking.md §3.3): on only for lights and
  /// covers on a dashboard tile; never a cover that looks like a gate or a
  /// garage door; switches (an in-wall relay can run a boiler), plugs and
  /// thermostats off until the person turns them on.
  bool get defaultOn => switch (kind) {
        ChatKind.light => onTile,
        ChatKind.cover => onTile && !gate,
        _ => false,
      };
}

/// The devices Chat could control, in the order the screen lists them:
/// lights, covers, switches and plugs, thermostats, each by name. Locks,
/// valves, sirens and sensors are never listed. [tags] holds, per IEEE
/// address, the names of the tiles, sections and dashboards it is on.
List<ChatControlItem> chatControlItems(
  List<Z2mDevice> devices, {
  required Set<String> onTiles,
  required Map<String, List<String>> tags,
}) {
  const order = [ChatKind.light, ChatKind.cover, ChatKind.switchPlug, ChatKind.thermostat];
  final out = <ChatControlItem>[];
  for (final d in devices) {
    final ieee = d.ieeeAddress;
    if (ieee == null || d.type == 'Coordinator') continue;
    final kind = chatKindOf(d.rawExposes, description: d.description, model: d.model);
    if (!order.contains(kind)) continue;
    final names = [d.displayName, d.friendlyName, ...?tags[ieee]];
    out.add(ChatControlItem(
      ieee: ieee,
      name: d.displayName,
      kind: kind,
      onTile: onTiles.contains(ieee),
      gate: names.any(chatLooksLikeGate),
    ));
  }
  out.sort((a, b) {
    final k = order.indexOf(a.kind).compareTo(order.indexOf(b.kind));
    return k != 0 ? k : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return out;
}
