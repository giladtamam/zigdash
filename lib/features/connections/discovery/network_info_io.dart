import 'dart:io';

/// Returns the phone's private IPv4 address (Wi-Fi/LAN), or null if none found.
/// Prefers 192.168/10/172.16-31 ranges so we scan the home subnet, not a
/// VPN/cellular interface.
Future<String?> wifiIpv4() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    String? fallback;
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        final ip = addr.address;
        if (_isPrivate(ip)) return ip;
        fallback ??= ip;
      }
    }
    return fallback;
  } catch (_) {
    return null;
  }
}

bool _isPrivate(String ip) {
  if (ip.startsWith('192.168.') || ip.startsWith('10.')) return true;
  if (ip.startsWith('172.')) {
    final second = int.tryParse(ip.split('.')[1]) ?? 0;
    return second >= 16 && second <= 31;
  }
  return false;
}
