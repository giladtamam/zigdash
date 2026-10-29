// What kind of Home Assistant address was typed (3.1.12), for the screen's
// advice when nothing answers and for usage data: the 3.1.11 week showed
// every stuck Home Assistant user on Wi-Fi with Home Assistant not on the
// phone's network, and nothing said which kind of address they then tried.
// Only the kind ever leaves the phone, never the address.

import '../../../mqtt/ha_address.dart';
import '../../connections/discovery/subnet.dart';

enum HaAddressShape {
  /// Nothing usable typed.
  empty,

  /// A private IP in the phone's own network (the aligned `/22` the scan
  /// covers).
  sameNetwork,

  /// A private IP outside the phone's network: another router, a VLAN.
  otherNetwork,

  /// A private IP, with the phone's own address unknown.
  privateIp,

  /// A `.local` name, or a bare name such as `homeassistant`.
  localName,

  /// A Nabu Casa address (`….ui.nabu.casa`).
  nabuCasa,

  /// Any other domain name: DuckDNS, Cloudflare, the user's own.
  remoteName,

  /// A public IP address.
  publicIp,
}

/// The shape of [typed], judged against [phoneIp] (the phone's own IPv4,
/// when known).
HaAddressShape haAddressShapeOf(String typed, {String? phoneIp}) {
  final base = haBaseUri(typed);
  if (base == null) return HaAddressShape.empty;
  final host = base.host.toLowerCase();
  if (subnetBaseFromIp(host) != null) {
    if (!isPrivateIpv4(host)) return HaAddressShape.publicIp;
    if (phoneIp == null || subnetBaseFromIp(phoneIp) == null) {
      return HaAddressShape.privateIp;
    }
    return _block22(host) == _block22(phoneIp)
        ? HaAddressShape.sameNetwork
        : HaAddressShape.otherNetwork;
  }
  if (host.endsWith('.local') || !host.contains('.')) {
    return HaAddressShape.localName;
  }
  if (host.endsWith('.ui.nabu.casa')) return HaAddressShape.nabuCasa;
  return HaAddressShape.remoteName;
}

/// The aligned `/22` [ip] sits in, as `a.b.c` with `c` rounded down.
String _block22(String ip) {
  final p = ip.split('.').map(int.parse).toList();
  return '${p[0]}.${p[1]}.${p[2] & ~3}';
}

/// The port of [base] as a class for usage data: Home Assistant's own,
/// the HTTPS default, or another.
String haPortClassOf(Uri base) => switch (base.port) {
  8123 => '8123',
  443 => '443',
  _ => 'other',
};
