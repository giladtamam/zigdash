import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../mqtt/broker_config.dart';
import '../../../mqtt/client_factory.dart';
import '../../../mqtt/endpoint.dart';
import '../../../mqtt/mqtt_manager.dart' show MqttClientFactory;
import '../../discovery/models/z2m_device.dart';
import 'setup_coordinator.dart';

/// Verification fetcher for the setup coordinator: connects a throwaway probe
/// client and waits for the retained `$base/bridge/...` topics that only
/// Zigbee2MQTT publishes. [Z2mFetchResult.detected] is true only after such a
/// topic arrived — the flow may not claim "Zigbee2MQTT found" before that.
class Z2mProbeFetcher {
  Z2mProbeFetcher({
    MqttClientFactory? clientFactory,
    this.window = const Duration(seconds: 5),
  }) : _clientFactory = clientFactory ?? buildMqttClient;

  final MqttClientFactory _clientFactory;

  /// How long to wait for retained bridge topics after subscribing.
  final Duration window;

  Future<Z2mFetchResult> fetch(
    BrokerConfig config,
    String password,
    String base,
  ) async {
    final clientId = 'zd-${DateTime.now().microsecondsSinceEpoch & 0xffffff}';
    final client = _clientFactory(config, clientId);
    // Through Home Assistant a connect is a token exchange, TLS, the
    // sign-in and a probe, often over the internet: more than [window].
    final connectBudget = config.viaHomeAssistant
        ? const Duration(milliseconds: homeAssistantConnectTimeoutMs)
        : window;
    client
      ..logging(on: false)
      ..keepAlivePeriod = 5
      ..connectTimeoutPeriod = connectBudget.inMilliseconds
      ..autoReconnect = false
      ..connectionMessage = mc.MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean();

    try {
      await client.connect(config.username, password).timeout(connectBudget);
    } catch (_) {
      _dispose(client);
      return const Z2mFetchResult(detected: false, devices: []);
    }
    if (client.connectionStatus?.state != mc.MqttConnectionState.connected) {
      _dispose(client);
      return const Z2mFetchResult(detected: false, devices: []);
    }

    var detected = false;
    var sawDevices = false;
    var devices = <Z2mDevice>[];
    final others = <String>{};
    final sub = client.updates?.listen((events) {
      for (final event in events) {
        final pub = event.payload;
        if (pub is! mc.MqttPublishMessage) continue;
        // Another Zigbee2MQTT on this broker, under its own base topic.
        if (event.topic.endsWith('/bridge/state') &&
            !event.topic.startsWith('$base/')) {
          others.add(
            event.topic.substring(
              0,
              event.topic.length - '/bridge/state'.length,
            ),
          );
        }
        final rest = event.topic.length > base.length + 1
            ? event.topic.substring(base.length + 1)
            : '';
        if (rest == 'bridge/devices') {
          detected = true;
          sawDevices = true;
          final payload = mc.MqttPublishPayload.bytesToStringAsString(
            pub.payload.message,
          );
          devices = parseBridgeDevices(payload);
        } else if (rest == 'bridge/info' || rest == 'bridge/state') {
          detected = true;
        }
      }
    });
    try {
      client
        ..subscribe('$base/bridge/devices', mc.MqttQos.atLeastOnce)
        ..subscribe('$base/bridge/info', mc.MqttQos.atLeastOnce)
        ..subscribe('$base/bridge/state', mc.MqttQos.atLeastOnce)
        // A base topic of one or two levels ("z2m", "home/zigbee").
        ..subscribe('+/bridge/state', mc.MqttQos.atLeastOnce)
        ..subscribe('+/+/bridge/state', mc.MqttQos.atLeastOnce);
      await Future<void>.delayed(window);
    } finally {
      unawaited(sub?.cancel());
      _dispose(client);
    }
    return Z2mFetchResult(
      detected: detected,
      devices: devices,
      otherBases: others.toList()..sort(),
      devicesMissing: detected && !sawDevices,
    );
  }

  void _dispose(mc.MqttClient client) {
    try {
      client.disconnect();
    } catch (_) {
      // Best-effort teardown of a probe client.
    }
  }
}
