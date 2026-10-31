import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../engine/engine_installer.dart';
import '../../engine/engine_status.dart' show HubInfo;

/// Restoring a hub backup (docs/design/hub-backup.md, "Restoring"): the
/// one-shot `hub/zigdash-restore.js` extension writes the backup into
/// Zigbee2MQTT's data folder and stops Zigbee2MQTT hard; its service
/// manager starts it again on the restored files.

const restoreExtensionName = 'zigdash-restore.js';
const restoreAsset = 'hub/zigdash-restore.js';
const restoreTopic = 'zigdash/backup/restore';
const restoreResultTopic = 'zigdash/backup/restore/result';

/// Where a restore is, for the progress shown while it runs.
enum HubRestoreStage { allowingExtensions, sending, restarting }

enum HubRestoreOutcome {
  /// Written, and Zigbee2MQTT came back.
  restored,

  /// Allowing extensions (and the restart it needs) did not finish.
  /// Nothing was written.
  consentFailed,

  /// Zigbee2MQTT refused the restore extension. Nothing was written.
  extensionRefused,

  /// The extension never confirmed, or refused the backup. Nothing was
  /// written.
  notWritten,

  /// Written, but Zigbee2MQTT has not come back on its own.
  notBack,
}

/// Runs a restore over a Home's broker connection.
class HubRestorer {
  HubRestorer(
    this._link, {
    required this.base,
    this.answerWithin = const Duration(seconds: 20),
    this.backWithin = const Duration(seconds: 180),
  }) : _installer = EngineInstaller(_link, base: base);

  final HubLink _link;
  final String base;
  final EngineInstaller _installer;
  final Duration answerWithin;
  final Duration backWithin;

  Future<HubRestoreOutcome> restore(
    Uint8List zip, {
    required String extensionSource,
    void Function(HubRestoreStage stage)? onStage,
  }) async {
    final info = await _first('$base/bridge/info', const Duration(seconds: 10));
    final hub = info == null ? null : HubInfo.decode(info);
    if (hub != null && !hub.externalJsAllowed) {
      onStage?.call(HubRestoreStage.allowingExtensions);
      if (await _installer.allowExtensionsAndRestart() != HubAnswer.ok) {
        return HubRestoreOutcome.consentFailed;
      }
    }
    onStage?.call(HubRestoreStage.sending);
    final (saved, _) = await _installer.request('extension/save', {
      'name': restoreExtensionName,
      'code': extensionSource,
    });
    if (saved != HubAnswer.ok) return HubRestoreOutcome.extensionRefused;

    final tx = 'zigdash-restore-${DateTime.now().millisecondsSinceEpoch}';
    final written = Completer<bool>();
    // Listen for Zigbee2MQTT going down and back before it can happen.
    var wentOffline = false;
    final back = Completer<void>();
    final stateSub = _link.listen('$base/bridge/state').listen((raw) {
      final online = raw.contains('online');
      if (!online) wentOffline = true;
      if (online && wentOffline && !back.isCompleted) back.complete();
    });
    final resultSub = _link.listen(restoreResultTopic).listen((raw) {
      try {
        final j = jsonDecode(raw) as Map;
        if (j['tx'] != tx || written.isCompleted) return;
        written.complete(j['status'] == 'writing');
      } catch (_) {}
    });
    try {
      _link.publish(
        restoreTopic,
        jsonEncode({'tx': tx, 'zip': base64Encode(zip)}),
      );
      final ok = await written.future.timeout(
        answerWithin,
        onTimeout: () => false,
      );
      if (!ok) {
        // Nothing was written: take the extension away again.
        unawaited(
          _installer.request('extension/remove', {
            'name': restoreExtensionName,
          }),
        );
        return HubRestoreOutcome.notWritten;
      }
      onStage?.call(HubRestoreStage.restarting);
      try {
        await back.future.timeout(backWithin);
        return HubRestoreOutcome.restored;
      } on TimeoutException {
        return HubRestoreOutcome.notBack;
      }
    } finally {
      await resultSub.cancel();
      await stateSub.cancel();
    }
  }

  /// The first (usually retained) message on [topic], or null.
  Future<String?> _first(String topic, Duration within) async {
    final got = Completer<String?>();
    final sub = _link.listen(topic).listen((raw) {
      if (!got.isCompleted && raw.isNotEmpty) got.complete(raw);
    });
    try {
      return await got.future.timeout(within, onTimeout: () => null);
    } finally {
      await sub.cancel();
    }
  }
}
