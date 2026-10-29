import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:mqtt_client/mqtt_server_client.dart';

import '../data/database/tables/connections.dart';
import 'broker_config.dart';
import 'client_factory.dart';
import 'ha_address.dart';
import 'endpoint.dart';
import 'ha_mqtt_client.dart';
import 'relay_mqtt_client.dart';
import 'z2m_frontend_client.dart';

/// Whether something answers TCP at [host]:[port] within [timeout]: used to
/// notice the home network is back while connected through the relay (3.1).
Future<bool> probeTcp(String host, int port, {Duration timeout = const Duration(seconds: 2)}) async {
  try {
    final socket = await Socket.connect(host, port, timeout: timeout);
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

mc.MqttClient buildPlatformClient(
  BrokerConfig config,
  String clientId, {
  String? host,
}) {
  final target = host ?? config.host;
  final relay = config.relay;
  if (target == relayCandidateHost && relay != null) {
    return RelayMqttClient(relay, clientId);
  }
  if (config.viaZ2mPage) {
    return Z2mFrontendClient(Uri(scheme: 'ws', host: target, port: config.port, path: '/api'), clientId);
  }
  if (config.viaHomeAssistant) {
    final base = haBaseUri(target);
    if (base == null) {
      throw UnsupportedError('Not a Home Assistant address: $target');
    }
    return HaMqttClient(haWebSocketUri(base), clientId);
  }
  final ws = isWebSocketProtocol(config.protocol);
  final client = MqttServerClient.withPort(
    ws ? webSocketServer(config.protocol, target) : target,
    clientId,
    config.port,
  );
  client.secure = isSecureProtocol(config.protocol);
  if (ws) {
    client.useWebSocket = true;
    client.websocketProtocols = ['mqtt'];
  }
  return client;
}

/// mqtt_client's WebSocket connection only accepts a ws:// or wss:// URL and
/// rejected a bare host with "incorrect scheme", so WS/WSS connections on
/// Android never connected. A scheme the user already typed is kept.
String webSocketServer(MqttProtocol protocol, String host) {
  if (host.startsWith('ws://') || host.startsWith('wss://')) return host;
  final scheme = protocol == MqttProtocol.wss ? 'wss' : 'ws';
  return '$scheme://$host';
}
