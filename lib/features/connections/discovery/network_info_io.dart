import 'dart:io';

import 'package:flutter/services.dart';

import 'no_network.dart';

export 'no_network.dart';

/// The App Store build (3.3.1 build 97). App Review's automated check read
/// the tunnel-interface names [vpnActive] looks for as VPN functionality
/// and rejected build 96, so that build never lists or names them: no VPN
/// hint on iOS, and only Apple's own Wi-Fi and Ethernet (`en*`) are home
/// interfaces. A compile-time constant, so the other code isn't in it.
const _apple = String.fromEnvironment('ZIGDASH_FLAVOR') == 'appstore';

/// How asking for iOS's Local Network access ended.
enum LocalNetworkAccess { granted, denied, unknown }

LocalNetworkAccess? _localNetwork;

/// Waits for iOS's Local Network access before the first scan (build 97):
/// the first scan used to run while Apple's prompt was still open, so
/// every new iPhone's first scan found nothing. Asks once (iOS shows its
/// prompt then), and remembers a yes. Elsewhere, granted at once. Never
/// throws.
Future<LocalNetworkAccess> localNetworkAccess({
  Duration timeout = const Duration(seconds: 60),
}) async {
  if (!Platform.isIOS) return LocalNetworkAccess.granted;
  final known = _localNetwork;
  if (known == LocalNetworkAccess.granted) return known!;
  try {
    final answer = await const MethodChannel('zigdash/app').invokeMethod<String>(
      'localNetworkAccess',
      {'timeoutMs': timeout.inMilliseconds},
    );
    final access = LocalNetworkAccess.values.firstWhere(
      (a) => a.name == answer,
      orElse: () => LocalNetworkAccess.unknown,
    );
    return _localNetwork = access;
  } catch (_) {
    return LocalNetworkAccess.unknown;
  }
}

/// Returns the phone's private IPv4 address on the home network (Wi-Fi or
/// Ethernet), or null if none is found.
Future<String?> wifiIpv4() async => (await homeIpv4())?.ip;

/// The home-network address and the name of the interface it is on.
Future<({String name, String ip})?> homeIpv4() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    return pickHomeAddress([
      for (final iface in interfaces)
        for (final addr in iface.addresses)
          (name: iface.name, ip: addr.address),
    ]);
  } catch (_) {
    return null;
  }
}

/// Why there is no home address (2.9.4): every interface and address
/// family, since mobile data is often IPv6 only. Never throws; unreadable
/// interfaces are [NoNetwork.unknown], never mobile data.
Future<NoNetwork> noNetworkReason() async {
  try {
    final interfaces = await NetworkInterface.list(includeLoopback: false);
    return whyNoNetwork([
      for (final iface in interfaces)
        for (final addr in iface.addresses)
          (name: iface.name, ip: addr.address),
    ]);
  } catch (_) {
    return NoNetwork.unknown;
  }
}

/// Whether a VPN is up: a tunnel interface exists next to the home one. A VPN
/// often routes or blocks local traffic, so an empty scan under one is a
/// different problem (2.6.2 diagnostics). Never throws.
Future<bool> vpnActive() async {
  if (_apple) return false;
  try {
    final interfaces = await NetworkInterface.list(includeLoopback: false);
    return hasVpnInterface([for (final i in interfaces) i.name]);
  } catch (_) {
    return false;
  }
}

/// True when any of [names] is a tunnel interface (`tun0`, `ppp0`, `ipsec0`,
/// `wg0`, `utun2`).
bool hasVpnInterface(Iterable<String> names) => names.any(
  (n) =>
      n.startsWith('tun') ||
      n.startsWith('utun') ||
      n.startsWith('ppp') ||
      n.startsWith('ipsec') ||
      n.startsWith('wg'),
);

/// Picks the address to scan from the phone's IPv4 interfaces.
///
/// Samsung phones keep Wi-Fi Direct up (`p2p-wlan0-0`, 192.168.x), and mobile
/// data can be private too (`rmnet*`, 10.x). Taking the first private address
/// could pick one of those and scan an empty network, so Wi-Fi and Ethernet
/// (`wlan*`, `eth*`, `en*`) come first, other private addresses next, any
/// other address last, and Wi-Fi Direct, mobile data, VPN and tethering
/// interfaces never.
String? pickHomeIpv4(List<({String name, String ip})> addresses) =>
    pickHomeAddress(addresses)?.ip;

/// [pickHomeIpv4], keeping the interface name (for Support details' network
/// kind; the name itself is never shown).
({String name, String ip})? pickHomeAddress(
  List<({String name, String ip})> addresses,
) {
  if (_apple) {
    final home = [
      for (final a in addresses)
        if (a.name.startsWith('en')) a,
    ];
    for (final a in home) {
      if (_isPrivate(a.ip)) return a;
    }
    return home.firstOrNull;
  }
  final usable = [
    for (final a in addresses)
      if (!_isExcluded(a.name)) a,
  ];
  final private = [
    for (final a in usable)
      if (_isPrivate(a.ip)) a,
  ];
  for (final a in private) {
    if (_isHomeInterface(a.name)) return a;
  }
  if (private.isNotEmpty) return private.first;
  return usable.isEmpty ? null : usable.first;
}

bool _isHomeInterface(String name) =>
    name.startsWith('wlan') || name.startsWith('eth') || name.startsWith('en');

bool _isExcluded(String name) {
  const prefixes = [
    'p2p',
    'rmnet',
    'ccmni',
    'pdp',
    'v4-rmnet',
    'tun',
    'ppp',
    'ipsec',
    'dummy',
    'swlan',
    'ap',
    'rndis',
    'bt-pan',
    'aware',
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
