import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
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
    if (!mounted) return;
    final settings = ref.read(settingsControllerProvider);
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    analytics.track(AppStarted(
      form: shortest >= 600 ? FormFactor.tablet : FormFactor.phone,
      theme: ThemeChoice.values.byName(settings.themeMode.name),
      materialYou: settings.dynamicColor,
      homes: homes.where((c) => !isDemoConnection(c.host)).length,
      tiles: tiles.length,
      demo: ref.read(demoServiceProvider),
    ));
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
