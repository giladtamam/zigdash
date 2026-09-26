import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_controller.dart';

const _kOnboardingComplete = 'onboarding_complete';

class OnboardingState {
  final bool isComplete;
  final bool isDemo;

  const OnboardingState({required this.isComplete, this.isDemo = false});

  bool get needsOnboarding => !isComplete && !isDemo;
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final complete = prefs.getBool(_kOnboardingComplete) ?? false;
    final isDemo = prefs.getBool('demo_mode') ?? false;
    return OnboardingState(isComplete: complete, isDemo: isDemo);
  }

  Future<void> completeOnboarding() async {
    state = OnboardingState(isComplete: true, isDemo: state.isDemo);
    await ref.read(sharedPreferencesProvider).setBool(_kOnboardingComplete, true);
  }

  Future<void> enableDemo() async {
    state = OnboardingState(isComplete: true, isDemo: true);
    await ref.read(sharedPreferencesProvider).setBool(_kOnboardingComplete, true);
    await ref.read(sharedPreferencesProvider).setBool('demo_mode', true);
  }

  Future<void> disableDemo() async {
    state = OnboardingState(isComplete: state.isComplete, isDemo: false);
    await ref.read(sharedPreferencesProvider).setBool('demo_mode', false);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
        OnboardingController.new);
