import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage.dart';
import '../../data/last_known/last_known_store.dart';
import '../../features/onboarding/demo_home.dart' show demoValues;
import '../../features/onboarding/demo_service.dart' show isDemoConnection;
import '../../data/repositories/connection_repo.dart';
import '../broker_config.dart';
import '../endpoint.dart';
import '../mqtt_manager.dart';
import '../mqtt_status.dart';

/// Tracks every live [MqttManager] so app-lifecycle code can act on all of them
/// at once — currently to force an immediate reconnect when the app returns to
/// the foreground (a backgrounded socket is usually dead). Managers register on
/// creation and unregister on dispose, so this only ever holds active ones.
class MqttManagerRegistry {
  final Set<MqttManager> _managers = {};

  void register(MqttManager manager) => _managers.add(manager);
  void unregister(MqttManager manager) => _managers.remove(manager);

  void reconnectAll() {
    for (final manager in _managers) {
      manager.reconnectNow();
    }
  }
}

final mqttManagerRegistryProvider =
    Provider<MqttManagerRegistry>((ref) => MqttManagerRegistry());

/// One manager per Connection ID. Lives for the session — `autoDispose` here
/// caused Riverpod to recreate the manager on every status stream restart, so
/// no connection attempt ever survived long enough to receive CONNACK. The
/// manager is disposed explicitly when its Connection row is deleted.
final mqttManagerProvider =
    FutureProvider.family<MqttManager, String>((ref, connectionId) async {
  final repo = ref.watch(connectionRepoProvider);
  final conn = await repo.getById(connectionId);
  if (conn == null) {
    throw StateError('Connection $connectionId not found');
  }
  final password = await ref.watch(secureStorageProvider).readPassword(connectionId) ?? '';
  final manager = MqttManager(
    config: BrokerConfig(
      id: conn.id,
      host: conn.host,
      port: conn.port,
      protocol: conn.protocol,
      username: conn.username,
      keepAliveSeconds: conn.keepAliveSeconds,
      remoteHost: conn.remoteHost,
    ),
    password: password,
  );

  final registry = ref.watch(mqttManagerRegistryProvider);
  registry.register(manager);

  ref.onDispose(() {
    registry.unregister(manager);
    manager.dispose();
  });

  // Last-known values first, so tiles are never empty when the broker is
  // unreachable; then keep saving what arrives. A store failure never
  // blocks connecting.
  // The demo never connects: its tiles show canned values as current.
  if (isDemoConnection(conn.host)) {
    manager.seedLastKnown(demoValues(DateTime.now()));
  }
  final store = ref.read(lastKnownStoreProvider);
  try {
    manager.seedLastKnown(await store
        .load(connectionId)
        .timeout(const Duration(seconds: 2)));
  } catch (_) {}
  final saving =
      manager.messages.listen((m) => store.record(connectionId, m));
  ref.onDispose(saving.cancel);

  // Fire-and-forget connect — UI watches status$ to observe progress. The
  // demo has no broker: it stays offline, quietly, without a status line.
  if (!isDemoConnection(conn.host)) manager.connect();

  return manager;
});

/// Live status stream for a given connection. While the manager future is
/// resolving, yields `connecting`.
final connectionStatusProvider =
    StreamProvider.family<MqttStatus, String>((ref, connectionId) async* {
  final managerAsync = ref.watch(mqttManagerProvider(connectionId));
  yield* managerAsync.when(
    loading: () => Stream.value(MqttStatus.connecting),
    error: (_, __) => Stream.value(MqttStatus.error),
    data: (mgr) => mgr.status$,
  );
});

/// Live active-endpoint stream for a connection (null until connected).
final connectionEndpointProvider =
    StreamProvider.family<MqttEndpoint?, String>((ref, connectionId) async* {
  final managerAsync = ref.watch(mqttManagerProvider(connectionId));
  yield* managerAsync.when(
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
    data: (mgr) => mgr.endpoint$,
  );
});
