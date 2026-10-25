// Finding Home Assistant on the home network (3.1.8), so the address
// doesn't have to be typed: an empty address was most Home Assistant
// sign-ins, and `homeassistant.local` often doesn't resolve on Android.
//
// Home Assistant announces itself by DNS-SD as `_home-assistant._tcp`, with
// `internal_url`, `base_url`, `location_name` and `uuid` in its TXT record
// (https://developers.home-assistant.io/docs/api/instance_discovery).
// Android's NsdManager finds it and gives its IP; when that finds nothing,
// the usual names are tried.

import 'package:flutter/services.dart';

import '../../../mqtt/ha_address.dart';
import '../../../shortcuts/shortcut_service.dart' show appChannel;
import '../../connections/discovery/hub_probe.dart';
import '../../connections/discovery/hub_prober.dart';

/// A Home Assistant found on the network.
class HaFound {
  const HaFound({
    required this.address,
    this.name,
    this.uuid,
    this.byName = false,
  });

  /// What goes in the address field: a base URL `haBaseUri` reads back.
  final String address;

  /// Its name as set in Home Assistant (`location_name`), when it said.
  final String? name;

  /// Home Assistant's own id for the instance, when it said.
  final String? uuid;

  /// Found at one of [haUsualNames], not by DNS-SD.
  final bool byName;

  @override
  String toString() => 'HaFound($address)';
}

/// How looking for Home Assistant ended, for usage data (`setup_step`
/// ha_discovery). [used] is counted when a sign-in goes to a found address.
enum HaDiscoveryOutcome { one, several, byName, none, used }

/// The Home Assistant one DNS-SD service describes, or null. Its own
/// internal address when that needs no `.local` name; otherwise the IP the
/// service resolved to, with the scheme Home Assistant uses.
HaFound? haFoundOf(Map<Object?, Object?> service) {
  final host = service['host'];
  final port = service['port'];
  if (host is! String || host.isEmpty || port is! int || port <= 0) {
    return null;
  }
  final txt = <String, String>{
    for (final e in (service['txt'] as Map<Object?, Object?>? ?? {}).entries)
      if (e.key is String && e.value is String)
        e.key! as String: e.value! as String,
  };
  final own = [
    txt['internal_url'],
    txt['base_url'],
  ].whereType<String>().map(haBaseUri).whereType<Uri>().firstOrNull;
  final Uri base;
  if (own != null && !own.host.toLowerCase().endsWith('.local')) {
    base = own;
  } else {
    base = Uri(scheme: own?.scheme ?? 'http', host: host, port: port);
  }
  final name = txt['location_name']?.trim();
  return HaFound(
    address: haAddressText(base),
    name: name == null || name.isEmpty ? null : name,
    uuid: txt['uuid'],
  );
}

/// The Home Assistant instances in [services], one per instance.
List<HaFound> haFoundIn(List<Object?> services) {
  final out = <HaFound>[];
  for (final s in services) {
    if (s is! Map) continue;
    final found = haFoundOf(s);
    if (found == null) continue;
    final same = out.any(
      (f) =>
          f.address == found.address ||
          (found.uuid != null && f.uuid == found.uuid),
    );
    if (!same) out.add(found);
  }
  return out;
}

/// The names Home Assistant usually answers on, tried when DNS-SD finds
/// nothing (a phone without it, or multicast blocked).
const haUsualNames = ['homeassistant.local', 'homeassistant'];

/// Looks for Home Assistant: DNS-SD for [timeout], then the usual names.
/// Never throws; an empty list when nothing answered.
Future<List<HaFound>> findHomeAssistant({
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    final services = await appChannel.invokeMethod<List<Object?>>(
      'findServices',
      {'type': '_home-assistant._tcp', 'timeoutMs': timeout.inMilliseconds},
    );
    final found = haFoundIn(services ?? const []);
    if (found.isNotEmpty) return found;
  } on MissingPluginException {
    // Not on Android: only the names.
  } catch (_) {}
  final prober = createPatientHubProber();
  final named = await Future.wait(
    haUsualNames.map((name) async {
      final kind = await prober.probe(name, 8123);
      return kind == HubKind.homeAssistant ? name : null;
    }),
  );
  final name = named.whereType<String>().firstOrNull;
  return name == null
      ? const []
      : [
          HaFound(
            address: haAddressText(Uri.parse('http://$name:8123')),
            byName: true,
          ),
        ];
}
