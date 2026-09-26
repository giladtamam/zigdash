import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/last_dashboard_store.dart';
import 'demo_service.dart';
import 'onboarding_provider.dart';

/// Finishes first run once a real home exists, from the setup flow or from
/// manual entry: removes the demo home, marks first run done, and makes the
/// new home the place the app opens.
class FirstRun {
  FirstRun(this._ref);
  final Ref _ref;

  Future<void> finish(String connectionId) async {
    if (_ref.read(demoServiceProvider)) {
      await _ref.read(demoServiceProvider.notifier).deactivate();
    }
    final onboarding = _ref.read(onboardingProvider.notifier);
    await onboarding.disableDemo();
    await onboarding.completeOnboarding();
    await _ref.read(lastDashboardStoreProvider).remember(connectionId);
  }

  /// Creates the demo home, ends first run in demo mode, and returns the demo
  /// connection id so the caller can open its dashboards.
  Future<String> startDemo() async {
    final id = await _ref.read(demoServiceProvider.notifier).activate();
    await _ref.read(onboardingProvider.notifier).enableDemo();
    await _ref.read(lastDashboardStoreProvider).remember(id);
    return id;
  }
}

final firstRunProvider = Provider<FirstRun>(FirstRun.new);
