import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/lifecycle/app_lifecycle_reconnector.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

/// Registry stand-in that just counts reconnectAll() calls.
class _RecordingRegistry extends MqttManagerRegistry {
  int reconnectAllCalls = 0;

  @override
  void reconnectAll() => reconnectAllCalls++;
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
    expect(registry.reconnectAllCalls, 0,
        reason: 'only `resumed` should trigger a reconnect');

    await _setLifecycle(tester, AppLifecycleState.inactive);
    await _setLifecycle(tester, AppLifecycleState.resumed);
    expect(registry.reconnectAllCalls, 1);
  });

  testWidgets('observer is removed on dispose (no reconnect after unmount)',
      (tester) async {
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
}
