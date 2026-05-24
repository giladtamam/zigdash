// Pure helpers for turning the phone's own IPv4 into a list of candidate
// hosts to probe on its `/24` subnet (assumes a `255.255.255.0` mask).

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
