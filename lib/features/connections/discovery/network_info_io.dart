import 'dart:io';

/// Returns the phone's private IPv4 address on the home network (Wi-Fi or
/// Ethernet), or null if none is found.
Future<String?> wifiIpv4() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    return pickHomeIpv4([
      for (final iface in interfaces)
        for (final addr in iface.addresses) (name: iface.name, ip: addr.address),
    ]);
  } catch (_) {
    return null;
  }
}

/// Picks the address to scan from the phone's IPv4 interfaces.
///
/// Samsung phones keep Wi-Fi Direct up (`p2p-wlan0-0`, 192.168.x), and mobile
/// data can be private too (`rmnet*`, 10.x). Taking the first private address
/// could pick one of those and scan an empty network, so Wi-Fi and Ethernet
/// (`wlan*`, `eth*`, `en*`) come first, other private addresses next, any
/// other address last, and Wi-Fi Direct, mobile data, VPN and tethering
/// interfaces never.
String? pickHomeIpv4(List<({String name, String ip})> addresses) {
  final usable = [
    for (final a in addresses)
      if (!_isExcluded(a.name)) a,
  ];
  final private = [
    for (final a in usable)
      if (_isPrivate(a.ip)) a,
  ];
  for (final a in private) {
    if (_isHomeInterface(a.name)) return a.ip;
  }
  if (private.isNotEmpty) return private.first.ip;
  return usable.isEmpty ? null : usable.first.ip;
}

bool _isHomeInterface(String name) =>
    name.startsWith('wlan') || name.startsWith('eth') || name.startsWith('en');

bool _isExcluded(String name) {
  const prefixes = [
    'p2p', 'rmnet', 'ccmni', 'pdp', 'v4-rmnet', 'tun', 'ppp', 'ipsec',
    'dummy', 'swlan', 'ap', 'rndis', 'bt-pan', 'aware',
  ];
  return name.contains('p2p') || prefixes.any(name.startsWith);
}

bool _isPrivate(String ip) {
  if (ip.startsWith('192.168.') || ip.startsWith('10.')) return true;
  if (ip.startsWith('172.')) {
    final second = int.tryParse(ip.split('.')[1]) ?? 0;
    return second >= 16 && second <= 31;
  }
  return false;
}
