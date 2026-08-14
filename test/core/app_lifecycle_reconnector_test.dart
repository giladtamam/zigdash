import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/core/lifecycle/app_lifecycle_reconnector.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

/// Registry stand-in that just counts reconnectAll() calls.
class _RecordingRegistry extends MqttManagerRegistry {
  int reconnectAllCalls = 0;

  @override
  void reconnectAll() => reconnectAllCalls++;
}

class _HangingClient extends mc.MqttClient {
  _HangingClient(String server) : super.withPort(server, 'cid', 1883);

  final _status = mc.MqttClientConnectionStatus();
  final _connectCompleter = Completer<mc.MqttClientConnectionStatus?>();

  @override
  Future<mc.MqttClientConnectionStatus?> connect([String? u, String? p]) =>
      _connectCompleter.future;

  void finishConnecting() {
    _status.state = mc.MqttConnectionState.connected;
    _connectCompleter.complete(_status);
  }

  @override
  mc.MqttClientConnectionStatus? get connectionStatus => _status;

  @override
  void disconnect() {
    _status.state = mc.MqttConnectionState.disconnected;
  }
}

/// Drives the app lifecycle the way the engine does, via the platform channel,
/// so [WidgetsBindingObserver.didChangeAppLifecycleState] fires.
Future<void> _setLifecycle(WidgetTester tester, AppLifecycleState state) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/lifecycle',
    const StringCodec().encodeMessage(state.toString()),
    (_) {},
  );
  await tester.pump();
}

void main() {
  testWidgets('resume triggers reconnectAll on the registry', (tester) async {
    final registry = _RecordingRegistry();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mqttManagerRegistryProvider.overrideWithValue(registry)],
        child: const AppLifecycleReconnector(child: SizedBox()),
      ),
    );

    expect(registry.reconnectAllCalls, 0);

    // Background then foreground — the resume is what must fire the reconnect.
    await _setLifecycle(tester, AppLifecycleState.inactive);
    await _setLifecycle(tester, AppLifecycleState.paused);
    expect(
      registry.reconnectAllCalls,
      0,
      reason: 'only `resumed` should trigger a reconnect',
    );

    await _setLifecycle(tester, AppLifecycleState.inactive);
    await _setLifecycle(tester, AppLifecycleState.resumed);
    expect(registry.reconnectAllCalls, 1);
  });

  testWidgets('observer is removed on dispose (no reconnect after unmount)', (
    tester,
  ) async {
    final registry = _RecordingRegistry();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mqttManagerRegistryProvider.overrideWithValue(registry)],
        child: const AppLifecycleReconnector(child: SizedBox()),
      ),
    );

    // Replace the subtree so AppLifecycleReconnector is disposed.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mqttManagerRegistryProvider.overrideWithValue(registry)],
        child: const SizedBox(),
      ),
    );

    await _setLifecycle(tester, AppLifecycleState.inactive);
    await _setLifecycle(tester, AppLifecycleState.resumed);
    expect(registry.reconnectAllCalls, 0);
  });

  testWidgets('resume while a manager is connecting is idempotent', (
    tester,
  ) async {
    final registry = MqttManagerRegistry();
    var clientFactoryCalls = 0;
    late _HangingClient client;
    final manager = MqttManager(
      config: const BrokerConfig(
        id: 'connection-under-test',
        host: '192.0.2.1',
        port: 1883,
        protocol: MqttProtocol.tcp,
      ),
      password: '',
      clientFactory: (config, clientId, {host}) {
        clientFactoryCalls++;
        return client = _HangingClient(host ?? config.host);
      },
    );
    registry.register(manager);
    addTearDown(() async {
      registry.unregister(manager);
      await manager.dispose();
    });

    unawaited(manager.connect());
    await tester.pump();
    expect(manager.status, MqttStatus.connecting);
    expect(clientFactoryCalls, 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [mqttManagerRegistryProvider.overrideWithValue(registry)],
        child: const AppLifecycleReconnector(child: SizedBox()),
      ),
    );
    await _setLifecycle(tester, AppLifecycleState.inactive);
    await _setLifecycle(tester, AppLifecycleState.resumed);

    expect(manager.status, MqttStatus.connecting);
    expect(
      clientFactoryCalls,
      1,
      reason: 'resume must not start a second client while connect is active',
    );

    client.finishConnecting();
    await tester.pump();
  });
}
