// Pure helpers for turning the phone's own IPv4 into a list of candidate
// hosts to probe: its `/24` first, then the rest of the surrounding `/22`.

/// Returns the first three octets of [ip] (e.g. `"192.168.7"` for
/// `192.168.7.42`), or null when [ip] isn't a dotted IPv4 quad.
String? subnetBaseFromIp(String ip) {
  final parts = ip.split('.');
  if (parts.length != 4) return null;
  for (final p in parts) {
    final n = int.tryParse(p);
    if (n == null || n < 0 || n > 255) return null;
  }
  return '${parts[0]}.${parts[1]}.${parts[2]}';
}

/// The rest of the aligned `/22` around [deviceIp]: the three other `/24`
/// blocks, in order, without the `/22`'s network and broadcast addresses.
///
/// Mesh systems such as TP-Link Deco hand out a `/22` (255.255.252.0), so a
/// phone on 192.168.69.x can sit next to a hub on 192.168.68.x. Only private
/// ranges are widened. Returns empty when [deviceIp] is malformed or public.
List<String> widerCandidateHosts(String deviceIp) {
  final base = subnetBaseFromIp(deviceIp);
  if (base == null || !_isPrivate(deviceIp)) return const [];
  final parts = base.split('.').map(int.parse).toList();
  final first = parts[2] & ~3; // start of the aligned /22
  return [
    for (var third = first; third < first + 4; third++)
      if (third != parts[2])
        for (var i = 0; i <= 255; i++)
          if (!(third == first && i == 0) && !(third == first + 3 && i == 255))
            '${parts[0]}.${parts[1]}.$third.$i',
  ];
}

bool _isPrivate(String ip) {
  if (ip.startsWith('192.168.') || ip.startsWith('10.')) return true;
  if (ip.startsWith('172.')) {
    final second = int.tryParse(ip.split('.')[1]) ?? 0;
    return second >= 16 && second <= 31;
  }
  return false;
}

/// All host addresses `.1`–`.254` on [deviceIp]'s `/24`, excluding the device's
/// own address. Returns empty when [deviceIp] is malformed.
List<String> candidateHosts(String deviceIp) {
  final base = subnetBaseFromIp(deviceIp);
  if (base == null) return const [];
  final self = deviceIp.split('.').last;
  return [
    for (var i = 1; i <= 254; i++)
      if (i.toString() != self) '$base.$i',
  ];
}
