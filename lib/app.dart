import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class ZigDashApp extends ConsumerWidget {
  const ZigDashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return DynamicColorBuilder(
      builder: (light, dark) => MaterialApp.router(
        title: 'ZigDash',
        theme: AppTheme.light(dynamic: light),
        darkTheme: AppTheme.dark(dynamic: dark),
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
