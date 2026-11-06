/// Where Home Assistant is, from what the user typed or the scan saw:
/// `192.168.1.20`, `homeassistant.local:8123`, `http://…/lovelace/0`,
/// `https://xyz.ui.nabu.casa`. Without a scheme, a home address is http on
/// 8123 (then on port 80) and a remote name https ([haBaseCandidates]).
/// Null when nothing usable was typed.
Uri? haBaseUri(String input) => haBaseCandidates(input).firstOrNull;

/// The addresses [input] may mean, the likeliest first; empty when nothing
/// usable was typed. With a scheme, only that one.
///
/// 3.3.4: a remote name typed without `https://` went to http on 8123, and
/// nothing answered: all 12 remote tries in the 30 days to 3 Nov 2026.
/// Nabu Casa and Cloudflare tunnels answer https on 443, the DuckDNS add-on
/// https on 8123; a reverse proxy may still be plain http on 8123.
List<Uri> haBaseCandidates(String input) {
  var text = input.trim();
  if (text.isEmpty) return const [];
  final hasScheme = text.contains('://');
  if (!hasScheme) text = 'http://$text';
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return const [];
  if (uri.scheme != 'http' && uri.scheme != 'https') return const [];
  Uri at(String scheme, int? port) =>
      Uri(scheme: scheme, host: uri.host, port: port);
  if (hasScheme) return [at(uri.scheme, uri.hasPort ? uri.port : null)];
  // The port as typed: `Uri` forgets a typed `:80`, its scheme's default,
  // and `192.168.1.20:80` then went to 8123.
  final typedPort = int.tryParse(_typedPort.firstMatch(text)?.group(1) ?? '');
  if (!isRemoteHaName(uri.host)) {
    if (typedPort != null) return [at('http', typedPort)];
    // Home Assistant OS installed since 2026.8 serves on port 80, not
    // 8123 (Home Assistant's http integration); Container and every older
    // install keep 8123. A home address typed without a port means either.
    return [at('http', 8123), at('http', null)];
  }
  if (typedPort != null) {
    return [at('https', typedPort), at('http', typedPort)];
  }
  final host = uri.host.toLowerCase();
  if (host.endsWith('.ui.nabu.casa')) return [at('https', null)];
  if (host.endsWith('.duckdns.org')) {
    return [at('https', 8123), at('https', null), at('http', 8123)];
  }
  return [at('https', null), at('https', 8123), at('http', 8123)];
}

/// Whether [candidate] is the port-80 guess for a home address typed
/// without a port ([haBaseCandidates]). A router, a printer or an SMHUB
/// answers there too, so it counts only once it is seen to be Home
/// Assistant.
bool isImpliedHaPort80(List<Uri> candidates, Uri candidate) =>
    candidates.length > 1 &&
    candidates.first != candidate &&
    candidate.scheme == 'http' &&
    candidate.port == 80 &&
    !isRemoteHaName(candidate.host);

/// The `:port` after the host of an address with its scheme in front.
final _typedPort = RegExp(
  r'^[a-z]+://(?:\[[^\]]*\]|[^/:?#]*):(\d+)(?:[/?#]|$)',
);

final _ipv4 = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');

/// Names only a home network knows; anything else with a dot is remote.
const _homeSuffixes = ['.local', '.lan', '.home', '.internal', '.home.arpa'];

/// Whether [host] is a domain name reached over the internet, rather than
/// an IP address or a name only the home network knows.
bool isRemoteHaName(String host) {
  final h = host.toLowerCase();
  if (!h.contains('.') || h.contains(':') || _ipv4.hasMatch(h)) return false;
  return !_homeSuffixes.any(h.endsWith);
}

/// Home Assistant's WebSocket API for [base]: `ws(s)://host:port/api/websocket`.
Uri haWebSocketUri(Uri base) => base.replace(
  scheme: base.scheme == 'https' ? 'wss' : 'ws',
  path: '/api/websocket',
);

/// The address as stored on a Home Assistant home's row: the base URL text,
/// without a trailing slash, so `haBaseUri` reads it back unchanged.
String haAddressText(Uri base) {
  final text = base.toString();
  return text.endsWith('/') ? text.substring(0, text.length - 1) : text;
}
