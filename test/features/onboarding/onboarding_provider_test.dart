import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/onboarding/onboarding_provider.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

ProviderContainer _containerWith(SharedPreferences prefs) => ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fresh install requires onboarding and is not demo', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = _containerWith(prefs).read(onboardingProvider);
    expect(state.isComplete, isFalse);
    expect(state.isDemo, isFalse);
    expect(state.needsOnboarding, isTrue);
  });

  test('completeOnboarding marks complete and persists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);

    await c.read(onboardingProvider.notifier).completeOnboarding();

    final s = c.read(onboardingProvider);
    expect(s.isComplete, isTrue);
    expect(s.needsOnboarding, isFalse);
    expect(prefs.getBool('onboarding_complete'), isTrue);
  });

  test('skipOnboarding behaves like completeOnboarding', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);

    await c.read(onboardingProvider.notifier).skipOnboarding();

    expect(c.read(onboardingProvider).needsOnboarding, isFalse);
    expect(prefs.getBool('onboarding_complete'), isTrue);
  });

  test('enableDemo marks complete + demo and persists both', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);

    await c.read(onboardingProvider.notifier).enableDemo();

    final s = c.read(onboardingProvider);
    expect(s.isComplete, isTrue);
    expect(s.isDemo, isTrue);
    expect(s.needsOnboarding, isFalse);
    expect(prefs.getBool('onboarding_complete'), isTrue);
    expect(prefs.getBool('demo_mode'), isTrue);
  });

  test('disableDemo clears only the demo flag, keeps completion', () async {
    SharedPreferences.setMockInitialValues({
      'demo_mode': true,
      'onboarding_complete': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final c = _containerWith(prefs);

    await c.read(onboardingProvider.notifier).disableDemo();

    final s = c.read(onboardingProvider);
    expect(s.isDemo, isFalse);
    expect(s.isComplete, isTrue);
    expect(s.needsOnboarding, isFalse);
    expect(prefs.getBool('demo_mode'), isFalse);
  });
}
