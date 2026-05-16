import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage.dart';
import '../../data/repositories/connection_repo.dart';
import '../broker_config.dart';
import '../mqtt_manager.dart';
import '../mqtt_status.dart';

/// One manager per Connection ID. Auto-disposed when nothing watches it; on
/// dispose we tear down the MQTT client cleanly.
final mqttManagerProvider =
    FutureProvider.autoDispose.family<MqttManager, String>((ref, connectionId) async {
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
    StreamProvider.autoDispose.family<MqttStatus, String>((ref, connectionId) async* {
  final managerAsync = ref.watch(mqttManagerProvider(connectionId));
  yield* managerAsync.when(
    loading: () => Stream.value(MqttStatus.connecting),
    error: (_, __) => Stream.value(MqttStatus.error),
    data: (mgr) => mgr.status$,
  );
});
