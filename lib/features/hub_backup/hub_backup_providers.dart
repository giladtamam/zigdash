import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show AppLifecycleListener, AppLifecycleState;
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
import '../devices/device_state_refresher.dart' show deviceStateRefresherProvider;
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
    int? attempt,
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
    final generation = mgr.connectionGeneration;
    var left = false;
    final life = AppLifecycleListener(
      onStateChange: (s) {
        if (s != AppLifecycleState.resumed) left = true;
      },
    );
    try {
      return await take(
        MqttHubLink(mgr),
        base,
        connectionId,
        auto: auto,
        attempt: attempt,
        now: now ?? DateTime.now(),
        why: () => !mgr.isConnected || mgr.connectionGeneration != generation
            ? HubBackupWhy.disconnected
            : left
            ? HubBackupWhy.background
            : HubBackupWhy.noAnswer,
      );
    } finally {
      life.dispose();
    }
  }

  /// The part after the connection checks, over any [link]. [why] says,
  /// when no answer came, what happened meanwhile.
  Future<HubBackupOutcome> take(
    HubLink link,
    String base,
    String connectionId, {
    required bool auto,
    required DateTime now,
    int? attempt,
    HubBackupWhy Function()? why,
    Duration within = hubBackupWait,
  }) async {
    final analytics = _ref.read(analyticsProvider);
    final clock = Stopwatch()..start();
    final answer = await requestHubBackup(link, base, within: within);
    final took = hubBackupTook(clock.elapsed);
    switch (answer) {
      case HubBackupZip(:final bytes):
        final store = await _ref.read(hubBackupStoreProvider.future);
        await store.save(connectionId, bytes, now);
        _ref.invalidate(hubBackupsProvider(connectionId));
        analytics.track(
          HubBackupEvent(
            HubBackupStep.made,
            auto: auto,
            took: took,
            attempt: attempt,
          ),
        );
        return HubBackupOutcome.made;
      case HubBackupRefused():
        analytics.track(HubBackupEvent(HubBackupStep.unsupported, auto: auto));
        return HubBackupOutcome.refused;
      case HubBackupNoAnswer():
        analytics.track(
          HubBackupEvent(
            HubBackupStep.failed,
            auto: auto,
            attempt: attempt,
            why: why?.call() ?? HubBackupWhy.noAnswer,
          ),
        );
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
/// Waits until the dashboard has finished asking its devices for their
/// state (Zigbee2MQTT's backup queues behind those requests), and tries a
/// second time a few minutes later if Zigbee2MQTT didn't answer. At most
/// two tries per connection, so a hub that can't back up isn't asked
/// again and again.
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
      final generation = mgr.connectionGeneration;
      bool gone() =>
          disposed ||
          !mgr.isConnected ||
          mgr.connectionGeneration != generation;
      // Let the dashboard's own subscriptions and state requests go first.
      await Future<void>.delayed(hubBackupAutoDelay);
      if (gone()) return;
      try {
        final refresher = await ref.read(
          deviceStateRefresherProvider(connectionId).future,
        );
        await waitForQuiet(() => refresher.lastAskedAt);
        for (var attempt = 1; attempt <= 2; attempt++) {
          if (gone()) return;
          final store = await ref.read(hubBackupStoreProvider.future);
          final list = await store.list(connectionId);
          if (!hubBackupDue(list.firstOrNull?.at, DateTime.now())) return;
          final outcome = await ref
              .read(hubBackupRunnerProvider)
              .run(connectionId, auto: true, attempt: attempt);
          if (outcome != HubBackupOutcome.noAnswer) return;
          await Future<void>.delayed(hubBackupRetryAfter);
        }
      } catch (_) {
        // A backup never gets in the way of the dashboard.
      }
    });
  }());
});

/// When the automatic backup starts after a home connects, at the earliest.
const hubBackupAutoDelay = Duration(seconds: 20);

/// When the automatic backup tries again after Zigbee2MQTT didn't answer.
const hubBackupRetryAfter = Duration(minutes: 3);
