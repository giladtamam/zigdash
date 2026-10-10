// Keeps the headless shortcut entrypoint in the build (2.1 §1).
// ignore: unused_import
import 'shortcuts/shortcut_engine.dart';
import 'package:flutter/foundation.dart'
    show PlatformDispatcher, TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alerts/alert_push.dart';
import 'app.dart';
import 'mqtt/dropped_connection.dart';
import 'core/theme/font_licenses.dart';
import 'features/settings/providers/settings_controller.dart';

Future<void> main([List<String> args = const []]) async {
  WidgetsFlutterBinding.ensureInitialized();
  // A push arriving while ZigDash is closed starts this entrypoint headless
  // (--unifiedpush-bg) just to show the notification (alerts-2.3.md).
  final pushBackground = args.contains('--unifiedpush-bg');
  if (pushBackground) {
    await AlertPush.init(await SharedPreferences.getInstance(), background: true);
    return;
  }
  PlatformDispatcher.instance.onError = ignoreDroppedConnection;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    // Draw behind the system bars on every Android version, not only where
    // Android 15 enforces it. Scaffold/NavigationBar consume the insets.
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  registerFontLicenses();
  final prefs = await SharedPreferences.getInstance();
  await AlertPush.init(prefs, background: false);
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ZigDashApp(),
    ),
  );
}
