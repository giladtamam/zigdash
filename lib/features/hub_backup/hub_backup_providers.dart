import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/analytics/analytics.dart';
import '../../data/database/tables/connections.dart';
import '../../data/repositories/connection_repo.dart';
import '../../engine/engine_installer.dart' show HubLink;
import '../../engine/engine_providers.dart' show MqttHubLink;
import '../../mqtt/endpoint.dart';
import '../../mqtt/mqtt_status.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../devices/devices_providers.dart' show homeBaseTopicProvider;
import 'hub_backup.dart';
import 'hub_restore.dart';

const _keyName = 'hub_backup_key';

/// One key per install, in secure storage; made on first use.
Future<Uint8List> _backupKey() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final stored = await storage.read(key: _keyName);
  if (stored != null) return base64Decode(stored);
  final key = BackupSeal.newKey();
  await storage.write(key: _keyName, value: base64Encode(key));
  return key;
}

final hubBackupStoreProvider = FutureProvider<HubBackupStore>((ref) async {
  final support = await getApplicationSupportDirectory();
  return HubBackupStore(
    root: Directory('${support.path}/hub-backups'),
    key: _backupKey,
  );
});

/// A home's backups, newest first.
final hubBackupsProvider = FutureProvider.autoDispose
    .family<List<HubBackupEntry>, String>((ref, connectionId) async {
      final store = await ref.watch(hubBackupStoreProvider.future);
      return store.list(connectionId);
    });

/// Why Back up now did not make one.
enum HubBackupOutcome {
  made,

  /// Zigbee2MQTT said it can't (this adapter or version).
  refused,
  noAnswer,

  /// The home is not connected right now.
  offline,

  /// Through the relay: bridge requests wait until the phone is home.
  away,

  /// Connected through Zigbee2MQTT's page only: no broker to ask.
  noBroker,
}

/// Saving a copy where the user picks (Android's file picker). Swapped in
/// tests.
abstract interface class HubBackupFiles {
  Future<bool> saveZip(String fileName, Uint8List bytes);
}

class PickerHubBackupFiles implements HubBackupFiles {
  const PickerHubBackupFiles();

  @override
  Future<bool> saveZip(String fileName, Uint8List bytes) async =>
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      ) !=
      null;
}

final hubBackupFilesProvider = Provider<HubBackupFiles>(
  (ref) => const PickerHubBackupFiles(),
);

/// Takes a backup of a home's hub: asks Zigbee2MQTT, seals and keeps it.
class HubBackupRunner {
  HubBackupRunner(this._ref);
  final Ref _ref;

  Future<HubBackupOutcome> run(
    String connectionId, {
    required bool auto,
    DateTime? now,
  }) async {
    final home = await _ref.read(connectionRepoProvider).getById(connectionId);
    if (transportOf(home?.transport) == ConnectionTransport.z2mPage) {
      return HubBackupOutcome.noBroker;
    }
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (mgr.status != MqttStatus.connected) return HubBackupOutcome.offline;
    if (mgr.activeEndpoint == MqttEndpoint.relay) return HubBackupOutcome.away;
    final base =
        _ref.read(homeBaseTopicProvider(connectionId)) ?? 'zigbee2mqtt';
    return take(
      MqttHubLink(mgr),
      base,
      connectionId,
      auto: auto,
      now: now ?? DateTime.now(),
    );
  }

  /// The part after the connection checks, over any [link].
  Future<HubBackupOutcome> take(
    HubLink link,
    String base,
    String connectionId, {
    required bool auto,
    required DateTime now,
  }) async {
    final analytics = _ref.read(analyticsProvider);
    final answer = await requestHubBackup(link, base);
    switch (answer) {
      case HubBackupZip(:final bytes):
        final store = await _ref.read(hubBackupStoreProvider.future);
        await store.save(connectionId, bytes, now);
        _ref.invalidate(hubBackupsProvider(connectionId));
        analytics.track(HubBackupEvent(HubBackupStep.made, auto: auto));
        return HubBackupOutcome.made;
      case HubBackupRefused():
        analytics.track(HubBackupEvent(HubBackupStep.unsupported, auto: auto));
        return HubBackupOutcome.refused;
      case HubBackupNoAnswer():
        analytics.track(HubBackupEvent(HubBackupStep.failed, auto: auto));
        return HubBackupOutcome.noAnswer;
    }
  }
}

final hubBackupRunnerProvider = Provider<HubBackupRunner>(HubBackupRunner.new);

/// Why a restore could not start, before anything was sent.
enum HubRestoreBlocked { offline, away, noBroker, unreadable }

/// Restores one of a home's backups onto its hub (hub_restore.dart).
class HubRestoreRunner {
  HubRestoreRunner(this._ref);
  final Ref _ref;

  /// Null when it ran (see [outcome]), else why it could not start.
  Future<(HubRestoreBlocked?, HubRestoreOutcome?)> run(
    String connectionId,
    HubBackupEntry entry, {
    void Function(HubRestoreStage stage)? onStage,
  }) async {
    final home = await _ref.read(connectionRepoProvider).getById(connectionId);
    if (transportOf(home?.transport) == ConnectionTransport.z2mPage) {
      return (HubRestoreBlocked.noBroker, null);
    }
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (mgr.status != MqttStatus.connected) {
      return (HubRestoreBlocked.offline, null);
    }
    if (mgr.activeEndpoint == MqttEndpoint.relay) {
      return (HubRestoreBlocked.away, null);
    }
    final store = await _ref.read(hubBackupStoreProvider.future);
    final zip = await store.read(entry);
    if (zip == null) return (HubRestoreBlocked.unreadable, null);
    final base =
        _ref.read(homeBaseTopicProvider(connectionId)) ?? 'zigbee2mqtt';
    final source = await rootBundle.loadString(restoreAsset);
    final outcome = await HubRestorer(
      MqttHubLink(mgr),
      base: base,
    ).restore(zip, extensionSource: source, onStage: onStage);
    _ref
        .read(analyticsProvider)
        .track(
          HubBackupEvent(
            outcome == HubRestoreOutcome.restored
                ? HubBackupStep.restored
                : HubBackupStep.restoreFailed,
          ),
        );
    return (null, outcome);
  }
}

final hubRestoreRunnerProvider = Provider<HubRestoreRunner>(
  HubRestoreRunner.new,
);

/// Watched while a home is open (HomeShell): once it is connected on the
/// home network and its newest backup is a day old, takes one quietly.
/// Tries at most once per connection, so a hub that can't back up isn't
/// asked again and again.
final hubBackupAutoProvider = Provider.autoDispose.family<void, String>((
  ref,
  connectionId,
) {
  StreamSubscription<MqttStatus>? sub;
  var tried = false;
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
    unawaited(sub?.cancel());
  });
  unawaited(() async {
    final mgr = await ref.read(mqttManagerProvider(connectionId).future);
    if (disposed) return;
    sub = mgr.status$.listen((status) async {
      if (status != MqttStatus.connected) {
        tried = false;
        return;
      }
      if (tried) return;
      tried = true;
      // Let the dashboard's own subscriptions go first.
      await Future<void>.delayed(const Duration(seconds: 20));
      if (disposed) return;
      try {
        final store = await ref.read(hubBackupStoreProvider.future);
        final list = await store.list(connectionId);
        if (!hubBackupDue(list.firstOrNull?.at, DateTime.now())) return;
        await ref.read(hubBackupRunnerProvider).run(connectionId, auto: true);
      } catch (_) {
        // A backup never gets in the way of the dashboard.
      }
    });
  }());
});
