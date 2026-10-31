import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../features/pro/pro.dart' show proFlavor;

/// Where an update offered by Play stands (3.2.3, Play build only).
enum AppUpdatePhase { none, available, downloading, ready }

class AppUpdateState {
  const AppUpdateState(this.phase, {this.behind = 0});

  static const none = AppUpdateState(AppUpdatePhase.none);

  final AppUpdatePhase phase;

  /// How many version codes the installed app is behind Play's.
  final int behind;
}

/// Play's in-app update API over the "zigdash/update" channel
/// (PlayUpdates.kt); a fake in tests.
class AppUpdateBridge {
  AppUpdateBridge() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'downloaded') _downloaded.add(null);
    });
  }

  static const _channel = MethodChannel('zigdash/update');
  final _downloaded = StreamController<void>.broadcast();

  /// Fires when Play finished downloading the update.
  Stream<void> get downloaded => _downloaded.stream;

  /// Play's answer, or null when it can't say (no Play, no network).
  Future<({bool available, int versionCode, bool downloaded})?> check() async {
    try {
      final m = await _channel.invokeMapMethod<String, Object?>('check');
      if (m == null) return null;
      return (
        available: m['available'] == true,
        versionCode: (m['versionCode'] as int?) ?? 0,
        downloaded: m['downloaded'] == true,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> start() async {
    try {
      return await _channel.invokeMethod<bool>('start') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> complete() async {
    try {
      await _channel.invokeMethod<void>('complete');
    } on PlatformException {
      // Play restarts the app itself, or the update waits for the next start.
    } on MissingPluginException {
      // Not the Play build.
    }
  }
}

final appUpdateBridgeProvider = Provider<AppUpdateBridge>(
  (ref) => AppUpdateBridge(),
);

/// This build's version code.
final installedVersionCodeProvider = FutureProvider<int>(
  (ref) async =>
      int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0,
);

/// Asks Play once per app start whether a newer ZigDash exists; outside the
/// Play build, never.
class AppUpdateController extends Notifier<AppUpdateState> {
  StreamSubscription<void>? _sub;

  @override
  AppUpdateState build() {
    if (proFlavor != 'play') return AppUpdateState.none;
    final bridge = ref.watch(appUpdateBridgeProvider);
    _sub = bridge.downloaded.listen((_) {
      state = AppUpdateState(AppUpdatePhase.ready, behind: state.behind);
    });
    ref.onDispose(() => _sub?.cancel());
    unawaited(_check(bridge));
    return AppUpdateState.none;
  }

  Future<void> _check(AppUpdateBridge bridge) async {
    final info = await bridge.check();
    if (info == null) return;
    final installed = await ref.read(installedVersionCodeProvider.future);
    final behind = info.versionCode > installed
        ? info.versionCode - installed
        : 0;
    if (info.downloaded) {
      state = AppUpdateState(AppUpdatePhase.ready, behind: behind);
    } else if (info.available) {
      state = AppUpdateState(AppUpdatePhase.available, behind: behind);
    }
  }

  /// Starts Play's download; the banner shows it until Play says it's done.
  Future<void> update() async {
    final started = await ref.read(appUpdateBridgeProvider).start();
    if (started) {
      state = AppUpdateState(AppUpdatePhase.downloading, behind: state.behind);
    }
  }

  /// Installs the downloaded update; Play restarts ZigDash.
  Future<void> restart() => ref.read(appUpdateBridgeProvider).complete();
}

final appUpdateProvider = NotifierProvider<AppUpdateController, AppUpdateState>(
  AppUpdateController.new,
);
