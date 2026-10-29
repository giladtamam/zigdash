import 'dart:convert';

/// Where Zigbee2MQTT says its broker is (2.7.2), read from its own web
/// page's API when the scan saw the page but no broker: the `mqtt` section of
/// `bridge/info`. Only the server and the username are kept; Zigbee2MQTT
/// never sends the password there.
class Z2mBrokerSetting {
  const Z2mBrokerSetting({
    required this.server,
    required this.hosts,
    required this.port,
    required this.tls,
    required this.sameMachine,
    this.user,
    this.bareName = false,
  });

  /// The server as Zigbee2MQTT has it, for the screen: `mqtt://localhost:1883`.
  final String server;

  /// Where to look for the broker, in order: the machine serving the web
  /// page first when the server is on that machine (or may be, like a
  /// Docker service name), then the named host.
  final List<String> hosts;
  final int port;
  final bool tls;

  /// The server is surely the machine serving the web page (`localhost`,
  /// `127.0.0.1`, Home Assistant's `core-mosquitto`). If no broker answers
  /// there, it listens only on that machine.
  final bool sameMachine;

  /// The MQTT username Zigbee2MQTT logs in with, if any.
  final String? user;

  /// The server is a bare name (`mosquitto`, `nas`): a Docker service or
  /// a hostname that only Zigbee2MQTT's machine may know (2.10.4). The
  /// phone cannot use it; the broker's IP address can be typed instead.
  final bool bareName;
}

/// Zigbee2MQTT's web page is protected by a token (`frontend.auth_token`):
/// it accepts the socket, then closes it with 4401 "Unauthorized" (2.10.4).
class Z2mPageLocked implements Exception {
  const Z2mPageLocked();
}

/// The `mqtt` section of a `bridge/info` frame from Zigbee2MQTT's web API,
/// or null for any other frame.
Map<String, dynamic>? z2mMqttConfigOf(String frame) {
  try {
    final decoded = jsonDecode(frame);
    if (decoded is! Map || decoded['topic'] != 'bridge/info') return null;
    final payload = decoded['payload'];
    if (payload is! Map) return null;
    final config = payload['config'];
    if (config is! Map) return null;
    final mqtt = config['mqtt'];
    return mqtt is Map ? Map<String, dynamic>.from(mqtt) : null;
  } catch (_) {
    return null;
  }
}

/// The `bridge/devices` payload of a frame from Zigbee2MQTT's web API, as
/// JSON text for [parseBridgeDevices], or null for any other frame.
String? z2mDeviceListOf(String frame) {
  try {
    final decoded = jsonDecode(frame);
    if (decoded is! Map || decoded['topic'] != 'bridge/devices') return null;
    final payload = decoded['payload'];
    return payload is List ? jsonEncode(payload) : null;
  } catch (_) {
    return null;
  }
}

const _sameMachineNames = {'localhost', '127.0.0.1', '::1', 'core-mosquitto'};

/// What [mqtt] (Zigbee2MQTT's `mqtt` settings) means for a phone that
/// reached Zigbee2MQTT's web page at [frontendHost]. Null when there is no
/// usable server (a WebSocket server, say).
Z2mBrokerSetting? z2mBrokerSetting(
  Map<String, dynamic>? mqtt, {
  required String frontendHost,
}) {
  final server = mqtt?['server'];
  if (server is! String || server.trim().isEmpty) return null;
  final uri = Uri.tryParse(server.trim());
  if (uri == null || uri.host.isEmpty) return null;
  final tls = switch (uri.scheme) {
    'mqtt' || 'tcp' => false,
    'mqtts' || 'ssl' || 'tls' => true,
    _ => null,
  };
  if (tls == null) return null;
  final host = uri.host.toLowerCase();
  final same = _sameMachineNames.contains(host);
  // A bare name like `mosquitto` is usually a Docker service next to
  // Zigbee2MQTT: look on the web page's machine first, then try the name.
  final maybeSame = same || !host.contains('.') && !host.contains(':');
  final user = mqtt?['user'];
  return Z2mBrokerSetting(
    server: server.trim(),
    hosts: [
      if (maybeSame) frontendHost,
      if (!same && host != frontendHost) host,
    ],
    port: uri.hasPort ? uri.port : (tls ? 8883 : 1883),
    tls: tls,
    sameMachine: same,
    bareName: maybeSame && !same,
    user: user is String && user.isNotEmpty ? user : null,
  );
}
