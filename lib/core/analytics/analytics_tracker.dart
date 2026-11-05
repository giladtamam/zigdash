import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/database/database.dart';
import '../../engine/engine_providers.dart' show engineKnownRules;
import '../../features/onboarding/demo_service.dart';
import '../../features/settings/providers/settings_controller.dart';
import '../router/app_router.dart';
import 'analytics.dart';

/// App-wide usage events: `app_started` once per launch (as soon as the user
/// has opted in), and `feature_used` for the screens people open. Sends
/// nothing without consent (ADR 0006).
class AnalyticsTracker extends ConsumerStatefulWidget {
  const AnalyticsTracker({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AnalyticsTracker> createState() => _AnalyticsTrackerState();
}

class _AnalyticsTrackerState extends ConsumerState<AnalyticsTracker> {
  bool _started = false;
  late final _router = ref.read(routerProvider);

  @override
  void initState() {
    super.initState();
    _router.routerDelegate.addListener(_onRoute);
    ref.listenManual(analyticsProvider, (_, a) {
      if (a.enabled) _appStarted(a);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onRoute);
    super.dispose();
  }

  void _onRoute() {
    final feature = featureForPath(
        _router.routerDelegate.currentConfiguration.uri.path);
    if (feature != null) ref.read(analyticsProvider).track(FeatureUsed(feature));
  }

  Future<void> _appStarted(Analytics analytics) async {
    if (_started) return;
    _started = true;
    final db = ref.read(appDatabaseProvider);
    final homes = await db.select(db.connections).get();
    final tiles = await db.select(db.panels).get();
    final scenes = await db.select(db.scenes).get();
    final shortcuts = await db.select(db.shortcuts).get();
    final installed = await _installTime();
    if (!mounted) return;
    final settings = ref.read(settingsControllerProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    // What is set up counts real homes only: the demo's is not the user's.
    final real = {
      for (final c in homes)
        if (!isDemoConnection(c.host)) c.id,
    };
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    analytics.track(AppStarted(
      form: shortest >= 600 ? FormFactor.tablet : FormFactor.phone,
      theme: ThemeChoice.values.byName(settings.themeMode.name),
      materialYou: settings.dynamicColor,
      homes: real.length,
      tiles: tiles.length,
      demo: ref.read(demoServiceProvider),
      daysInstalled: installed == null
          ? null
          : DateTime.now().difference(installed).inDays.clamp(0, 100000),
      automations: real.fold(0, (n, id) => n + engineKnownRules(prefs, id)),
      scenes: scenes.where((s) => real.contains(s.connectionId)).length,
      shortcuts: shortcuts.where((s) => real.contains(s.connectionId)).length,
    ));
  }

  /// When Android installed ZigDash on this phone; null where unknown
  /// (tests, platforms without it).
  static Future<DateTime?> _installTime() async {
    try {
      return (await PackageInfo.fromPlatform()).installTime;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The feature a route opens, if it is one ZigDash counts.
Feature? featureForPath(String path) {
  final parts = Uri(path: path).pathSegments;
  final i = parts.indexOf('devices');
  if (i >= 0) return i == parts.length - 1 ? Feature.devicesTab : Feature.devicePage;
  if (parts.isNotEmpty && parts.last == 'scenes') return Feature.scenes;
  return null;
}
