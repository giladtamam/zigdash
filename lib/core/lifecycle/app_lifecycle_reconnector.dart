import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/last_known/last_known_store.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';

/// Forces every live [MqttManager] to reconnect when the app returns to the
/// foreground. Android suspends sockets and timers while backgrounded, so a
/// resumed app often holds a dead connection whose next scheduled retry may be
/// up to the backoff ceiling away. Nudging on `resumed` makes the app self-heal
/// instead of the user having to close and reopen it.
class AppLifecycleReconnector extends ConsumerStatefulWidget {
  const AppLifecycleReconnector({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleReconnector> createState() =>
      _AppLifecycleReconnectorState();
}

class _AppLifecycleReconnectorState
    extends ConsumerState<AppLifecycleReconnector>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(mqttManagerRegistryProvider).reconnectAll();
    } else if (state == AppLifecycleState.paused) {
      // Save pending last-known values before Android may end the process.
      ref.read(lastKnownStoreProvider).flush().ignore();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
