// Platform-conditional MQTT client factory.
//
// mqtt_client ships two implementations:
//   - MqttServerClient — uses dart:io; supports raw TCP and WebSocket; mobile/desktop only.
//   - MqttBrowserClient — uses dart:html; WebSocket only; web only.
//
// Importing mqtt_server_client.dart in a web build pulls in dart:io's
// SecurityContext via a profile/sky entrypoint and crashes at construction
// with "Unsupported operation: default SecurityContext getter". Conditional
// import below keeps each platform on the right entrypoint.

import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../data/database/tables/connections.dart';
import 'broker_config.dart';

import 'client_factory_io.dart'
    if (dart.library.html) 'client_factory_web.dart' as impl;

/// Builds the right MqttClient subclass for the current platform.
///
/// On web, protocol must be ws/wss — the browser cannot open raw TCP sockets.
/// Callers that pass TCP/TCP-SSL on web will get an [UnsupportedError].
mc.MqttClient buildMqttClient(BrokerConfig config, String clientId, {String? host}) {
  return impl.buildPlatformClient(config, clientId, host: host);
}

bool isWebSocketProtocol(MqttProtocol p) =>
    p == MqttProtocol.ws || p == MqttProtocol.wss;

bool isSecureProtocol(MqttProtocol p) =>
    p == MqttProtocol.tcpSsl || p == MqttProtocol.wss;
