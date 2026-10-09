import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zigdash/l10n/app_localizations.dart';

import 'core/lifecycle/app_lifecycle_reconnector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_controller.dart';
import 'core/analytics/analytics_tracker.dart';

class ZigDashApp extends ConsumerWidget {
  const ZigDashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);

    return AppLifecycleReconnector(
      child: DynamicColorBuilder(
        builder: (light, dark) => MaterialApp.router(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(dynamic: settings.dynamicColor ? light : null),
          darkTheme:
              AppTheme.dark(dynamic: settings.dynamicColor ? dark : null),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
          builder: (context, child) => AnalyticsTracker(child: child!),
          // Onboarding is a router route (Routes.onboarding) with a redirect,
          // so its context.go calls can reach the InheritedGoRouter.
        ),
      ),
    );
  }
}
