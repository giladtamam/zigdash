import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

/// What "Set up alerts on the hub" found (docs/design/alerts-2.3.md,
/// "Installing the flow").
enum NodeRedInstall {
  /// The flow was added.
  installed,

  /// The flow was already there and was brought up to date.
  updated,

  /// Node-RED asks for a login: the user imports the flow by hand.
  needsLogin,

  /// Nothing answers on port 1880: Node-RED isn't installed, or not there.
  notInstalled,

  /// Node-RED answered but refused the flow.
  failed,
}

/// Installs the alerts flow on the hub through Node-RED's admin API, with
/// the Home's broker and base topic filled in. Node-RED is looked for at
/// the broker's address on port 1880 (SMHUB's default).
class NodeRedInstaller {
  NodeRedInstaller({
    required this.host,
    this.port = 1880,
    HttpClient? client,
    Future<String> Function()? flowJson,
  })  : _client = client ?? HttpClient(),
        _flowJson = flowJson ?? (() => rootBundle.loadString(flowAsset));

  static const flowAsset = 'node-red/alerts-flow.json';
  static const tabLabel = 'ZigDash alerts';

  final String host;
  final int port;
  final HttpClient _client;
  final Future<String> Function() _flowJson;

  Uri _url(String path) => Uri(scheme: 'http', host: host, port: port, path: path);

  /// The tab as Node-RED's `/flow` API wants it: the flow's nodes with the
  /// broker's address, port and username and the base topic filled in, and
  /// the `mqtt-broker` config node in `configs`. Never the password: the
  /// broker node asks for it in Node-RED.
  static Map<String, Object?> tabFor(
    String flowJson, {
    required String brokerHost,
    required int brokerPort,
    String? username,
    required String baseTopic,
  }) {
    final nodes = (jsonDecode(flowJson) as List).cast<Map<String, dynamic>>();
    final tab = nodes.firstWhere((n) => n['type'] == 'tab');
    final out = <Map<String, Object?>>[];
    final configs = <Map<String, Object?>>[];
    for (final n in nodes) {
      if (n['type'] == 'tab') continue;
      final node = Map<String, Object?>.from(n)..remove('z');
      switch (n['type']) {
        case 'mqtt-broker':
          node['broker'] = brokerHost;
          node['port'] = '$brokerPort';
          if (username != null && username.isNotEmpty) {
            node['credentials'] = {'user': username};
          }
          configs.add(node);
          continue;
        case 'mqtt in':
          if (n['name'] == 'devices') node['topic'] = '$baseTopic/#';
      }
      out.add(node);
    }
    return {
      'label': tab['label'],
      'info': tab['info'],
      'nodes': out,
      'configs': configs,
    };
  }

  Future<NodeRedInstall> install({
    required String brokerHost,
    required int brokerPort,
    String? username,
    required String baseTopic,
  }) async {
    final Map<String, dynamic>? settings;
    try {
      settings = await _getJson('/settings');
    } on SocketException {
      return NodeRedInstall.notInstalled;
    } on HttpException {
      return NodeRedInstall.notInstalled;
    }
    if (settings == null) return NodeRedInstall.needsLogin;
    final tab = tabFor(await _flowJson(),
        brokerHost: brokerHost,
        brokerPort: brokerPort,
        username: username,
        baseTopic: baseTopic);
    try {
      final flows = await _getJson('/flows', apiV2: true);
      final existing = (flows?['flows'] as List?)
          ?.cast<Map<String, dynamic>>()
          .where((n) => n['type'] == 'tab' && n['label'] == tabLabel)
          .firstOrNull;
      if (existing != null) {
        final id = existing['id'] as String;
        final r = await _send('PUT', '/flow/$id', {...tab, 'id': id});
        return r == 200 ? NodeRedInstall.updated : NodeRedInstall.failed;
      }
      final r = await _send('POST', '/flow', tab);
      return r == 200 ? NodeRedInstall.installed : NodeRedInstall.failed;
    } on SocketException {
      return NodeRedInstall.notInstalled;
    } on HttpException {
      return NodeRedInstall.failed;
    }
  }

  /// GET as JSON; null when Node-RED asks for a login.
  Future<Map<String, dynamic>?> _getJson(String path, {bool apiV2 = false}) async {
    final req = await _client.getUrl(_url(path)).timeout(const Duration(seconds: 6));
    if (apiV2) req.headers.set('Node-RED-API-Version', 'v2');
    final res = await req.close().timeout(const Duration(seconds: 10));
    final body = await utf8.decodeStream(res);
    if (res.statusCode == 401) return null;
    if (res.statusCode != 200) throw HttpException('$path: ${res.statusCode}');
    final j = jsonDecode(body);
    return j is Map ? Map<String, dynamic>.from(j) : {'flows': j};
  }

  Future<int> _send(String method, String path, Map<String, Object?> body) async {
    final req = await _client.openUrl(method, _url(path)).timeout(const Duration(seconds: 6));
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close().timeout(const Duration(seconds: 20));
    await res.drain<void>();
    return res.statusCode;
  }
}
