import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage.dart';
import '../../data/repositories/connection_repo.dart';
import '../broker_config.dart';
import '../endpoint.dart';
import '../mqtt_manager.dart';
import '../mqtt_status.dart';

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

  ref.onDispose(() {
    manager.dispose();
  });

  // Fire-and-forget connect — UI watches status$ to observe progress.
  manager.connect();

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
