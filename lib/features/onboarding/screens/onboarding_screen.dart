import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../demo_service.dart';
import '../onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      ref.read(onboardingProvider.notifier).completeOnboarding();
      context.go(Routes.connections);
    }
  }

  void _skip() {
    ref.read(onboardingProvider.notifier).skipOnboarding();
    context.go(Routes.connections);
  }

  void _enableDemo() async {
    await ref.read(demoServiceProvider.notifier).activate();
    ref.read(onboardingProvider.notifier).enableDemo();
    if (mounted) {
      context.go(Routes.connections);
    }
  }

  void _connectBroker() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    // Discovery-first setup: scan for the broker before asking for fields.
    // The manual guided-connect form remains available inside the flow.
    context.go(Routes.setup);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _Page(
                    icon: Icons.phone_android_rounded,
                    title: l10n.onboardingWelcomeTitle,
                    subtitle: l10n.onboardingWelcomeSubtitle,
                    color: cs.primary,
                  ),
                  _Page(
                    icon: Icons.cloud_outlined,
                    title: l10n.onboardingBrokerTitle,
                    subtitle: l10n.onboardingBrokerSubtitle,
                    color: cs.tertiary,
                  ),
                  _Page(
                    icon: Icons.grid_view_rounded,
                    title: l10n.onboardingDashboardTitle,
                    subtitle: l10n.onboardingDashboardSubtitle,
                    color: cs.secondary,
                  ),
                ],
              ),
            ),
            _PageDots(count: 3, current: _page, color: cs.primary),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: Text(l10n.onboardingSkip),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _enableDemo,
                    child: Text(l10n.onboardingDemo),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _next,
                    child: Text(
                      _page == 2 ? l10n.onboardingGetStarted : l10n.onboardingNext,
                    ),
                  ),
                ],
              ),
            ),
            if (_page == 2) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: _connectBroker,
                    icon: const Icon(Icons.wifi_tethering),
                    label: Text(l10n.onboardingConnectBroker),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: color),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current, required this.color});

  final int count;
  final int current;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? color : color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
