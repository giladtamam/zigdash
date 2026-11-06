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
  // The port as typed: `Uri` forgets a typed `:80`, its scheme's default,
  // and `192.168.1.20:80` then went to 8123.
  final typedPort = int.tryParse(_typedPort.firstMatch(text)?.group(1) ?? '');
  if (hasScheme) {
    // A remote name given as plain http with no port: https first. The
    // Home Assistant app's "Share server" link carries http for a server
    // that sits behind an https tunnel.
    if (uri.scheme == 'http' && typedPort == null && isRemoteHaName(uri.host)) {
      return [at('https', null), at('http', null)];
    }
    return [at(uri.scheme, uri.hasPort ? uri.port : null)];
  }
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

/// The Home Assistant address in text that was handed over rather than
/// typed: pasted from the clipboard, or shared from another app. Null when
/// it holds none.
///
/// The Home Assistant app's "Share server" (Settings › Companion app › the
/// server; from its 2025.7 invite flow) shares
/// `https://my.home-assistant.io/invite/#url=<the server's address>`, and
/// "Copy link" on that sheet copies the same. A browser shares the page's
/// link, sometimes after its title. Otherwise one word that reads as a
/// host, with or without a port, is taken as typed.
///
/// Returns the address as the field shows it: scheme, host and port, no
/// path. What it means is still [haBaseCandidates]' call.
String? haAddressIn(String text) {
  final links = _link.allMatches(text).map((m) => m.group(0)!).toList();
  for (final link in links) {
    final inner = _invitedAddress(link);
    if (inner != null) return inner;
  }
  for (final link in links) {
    final uri = Uri.tryParse(link);
    if (uri == null || uri.host.isEmpty) continue;
    // My Home Assistant's own pages are not anyone's Home Assistant.
    if (uri.host.toLowerCase() == _myHost) continue;
    return haAddressText(
      Uri(
        scheme: uri.scheme.toLowerCase(),
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
      ),
    );
  }
  final word = text.trim();
  if (word.isEmpty || word.contains(RegExp(r'\s')) || word.contains('@')) {
    return null;
  }
  if (!_hostWord.hasMatch(word)) return null;
  final host = word.split(RegExp('[:/]')).first;
  // A name as people write one: an IP address, a home name, or a domain in
  // small letters. A copied token or password has dots too, and is not one.
  final known =
      _ipv4.hasMatch(host) ||
      host == 'homeassistant' ||
      host == 'localhost' ||
      _homeSuffixes.any(host.toLowerCase().endsWith) ||
      _domainWord.hasMatch(host);
  return known && haBaseUri(word) != null ? word : null;
}

const _myHost = 'my.home-assistant.io';

/// A link in running text, up to the first space or bracket.
final _link = RegExp(r'https?://[^\s<>"]+', caseSensitive: false);

/// One word that may be a host: letters, digits, dots and dashes, then
/// perhaps a port and a path.
final _hostWord = RegExp(r'^[A-Za-z0-9.-]+(:\d{1,5})?(/\S*)?$');

/// A domain name in small letters: short labels, letters at the end.
final _domainWord = RegExp(
  r'^(?:[a-z0-9](?:[a-z0-9-]{0,30}[a-z0-9])?\.)+[a-z]{2,24}$',
);

/// The server address inside a My Home Assistant invite link, or null when
/// [link] is not one.
String? _invitedAddress(String link) {
  final uri = Uri.tryParse(link);
  if (uri == null || uri.host.toLowerCase() != _myHost) return null;
  if (!uri.path.startsWith('/invite')) return null;
  for (final part in [uri.fragment, uri.query]) {
    if (part.isEmpty) continue;
    final String? inner;
    try {
      inner = Uri.splitQueryString(part)['url'];
    } catch (_) {
      continue;
    }
    if (inner == null || inner.trim().isEmpty) continue;
    final base = haBaseUri(inner.trim());
    if (base == null) continue;
    final at = Uri.tryParse(inner.trim());
    // As the server gave it: its own scheme and port, no path.
    return haAddressText(
      Uri(
        scheme: (at != null && at.hasScheme ? at.scheme : base.scheme)
            .toLowerCase(),
        host: base.host,
        port: at != null && at.hasPort ? at.port : null,
      ),
    );
  }
  return null;
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
