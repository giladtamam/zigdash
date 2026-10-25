import 'dart:convert';
import 'dart:math';

import '../../data/database/database.dart';
import '../../data/database/tables/connections.dart';

/// "Share this home" (3.1.7): another phone at home joins a Home with one
/// QR code. The code carries the broker's address and login; the
/// dashboards wait on the home broker under a one-time topic while the code
/// is shown, since they don't fit in a QR code. Nothing crosses the internet.
class HomeInvite {
  const HomeInvite({
    required this.name,
    required this.host,
    required this.port,
    required this.protocol,
    required this.code,
    this.username,
    this.password,
    this.remoteHost,
  });

  final String name;
  final String host;
  final int port;
  final MqttProtocol protocol;
  final String? username;
  final String? password;
  final String? remoteHost;

  /// The one-time code: the dashboards wait under [dashboardsTopic].
  final String code;

  /// `zigdash://home/join?c=<base64url JSON>`
  static const linkPath = '/join';

  String get dashboardsTopic => homeShareTopic(code);

  String link() {
    final j = {
      'v': 1,
      'name': name,
      'host': host,
      'port': port,
      'protocol': protocol.name,
      if (username != null && username!.isNotEmpty) 'user': username,
      if (password != null && password!.isNotEmpty) 'pass': password,
      if (remoteHost != null && remoteHost!.isNotEmpty) 'remote': remoteHost,
      'code': code,
    };
    final c = base64Url.encode(utf8.encode(jsonEncode(j))).replaceAll('=', '');
    return 'zigdash://home$linkPath?c=$c';
  }

  /// The invite in a link's `c` parameter, or null.
  static HomeInvite? fromCode(String? c) {
    if (c == null || c.isEmpty) return null;
    try {
      final padded = c.padRight((c.length + 3) ~/ 4 * 4, '=');
      final j = jsonDecode(utf8.decode(base64Url.decode(padded)));
      if (j is! Map || j['v'] != 1) return null;
      final protocol = MqttProtocol.values
          .where((p) => p.name == j['protocol'])
          .firstOrNull;
      final host = j['host'], port = j['port'], code = j['code'];
      if (protocol == null ||
          host is! String ||
          host.isEmpty ||
          port is! int ||
          code is! String) {
        return null;
      }
      return HomeInvite(
        name: '${j['name'] ?? host}',
        host: host,
        port: port,
        protocol: protocol,
        username: j['user'] as String?,
        password: j['pass'] as String?,
        remoteHost: j['remote'] as String?,
        code: code,
      );
    } catch (_) {
      return null;
    }
  }

  static HomeInvite of(
    Connection home, {
    String? password,
    required String code,
  }) => HomeInvite(
    name: home.name,
    host: home.host,
    port: home.port,
    protocol: home.protocol,
    username: home.username,
    password: password,
    remoteHost: home.remoteHost,
    code: code,
  );
}

/// Where the shared dashboards wait on the home broker.
String homeShareTopic(String code) => 'zigdash/share/$code';

final _random = Random.secure();

/// A fresh one-time code: 16 letters and digits.
String newShareCode() {
  const chars = 'abcdefghijkmnpqrstuvwxyz23456789';
  return List.generate(16, (_) => chars[_random.nextInt(chars.length)]).join();
}

/// Homes that can be shared this way: a broker the phone reaches itself.
/// A Home Assistant home signs in on each phone instead.
bool canShareHome(Connection home) =>
    transportOf(home.transport) == ConnectionTransport.mqtt;

/// The same home is already on this phone.
Connection? sameHome(Iterable<Connection> homes, HomeInvite invite) => homes
    .where((h) => h.host == invite.host && h.port == invite.port)
    .firstOrNull;
