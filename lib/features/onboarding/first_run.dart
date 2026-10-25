import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/last_dashboard_store.dart';
import '../settings/providers/settings_controller.dart';
import '../dashboards/widgets/why_card.dart' show whyAskKey;
import 'demo_service.dart';
import 'onboarding_provider.dart';

/// Finishes first run once a real home exists, from the setup flow or from
/// manual entry: removes the demo home, marks first run done, and makes the
/// new home the place the app opens.
class FirstRun {
  FirstRun(this._ref, {double Function()? shortestSide})
      : _shortestSide = shortestSide ?? _screenShortestSide;
  final Ref _ref;
  final double Function() _shortestSide;

  static double _screenShortestSide() {
    final view = PlatformDispatcher.instance.views.firstOrNull;
    if (view == null) return 0;
    return (view.physicalSize / view.devicePixelRatio).shortestSide;
  }

  /// Tablets default to dark (signal-2.0.md §5), for fresh installs only:
  /// written once, when first run ends, as the ordinary theme setting. An
  /// upgrader never reaches this with first run still open, and a theme the
  /// user already chose is kept.
  Future<void> _tabletDefaults() async {
    if (_ref.read(onboardingProvider).isComplete) return;
    if (_shortestSide() < 600) return;
    await _ref.read(settingsControllerProvider.notifier).setThemeModeIfUnset(
        ThemeMode.dark);
  }

  Future<void> finish(String connectionId) async {
    // Read before first run is marked done: only the first home is asked.
    final first = !_ref.read(onboardingProvider).isComplete;
    await _tabletDefaults();
    if (_ref.read(demoServiceProvider)) {
      await _ref.read(demoServiceProvider.notifier).deactivate();
    }
    final onboarding = _ref.read(onboardingProvider.notifier);
    await onboarding.disableDemo();
    await onboarding.completeOnboarding();
    await _ref.read(lastDashboardStoreProvider).remember(connectionId);
    if (first) {
      // "What made you try ZigDash?" on its dashboard, once (3.1.10).
      await _ref
          .read(sharedPreferencesProvider)
          .setString(whyAskKey, connectionId);
    }
  }

  /// Creates the demo home, ends first run in demo mode, and returns the demo
  /// connection id so the caller can open its dashboards.
  Future<String> startDemo() async {
    await _tabletDefaults();
    final id = await _ref.read(demoServiceProvider.notifier).activate();
    await _ref.read(onboardingProvider.notifier).enableDemo();
    await _ref.read(lastDashboardStoreProvider).remember(id);
    return id;
  }
}

final firstRunProvider = Provider<FirstRun>(FirstRun.new);
