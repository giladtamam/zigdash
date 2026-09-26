import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist/alchemist.dart';

/// Golden tests run in two tiers (see docs/design/phasing.md):
///
/// - CI goldens (`goldens/ci/`): text drawn as blocks, identical on every OS.
///   These gate layout, color and shape everywhere.
/// - Platform goldens (`goldens/linux/`): real fonts, rendered only on Linux,
///   the OS CI runs on. These gate typography.
///
/// Refresh after an intended visual change with:
///   tool/flutter test --update-goldens test/goldens
/// Family name of the test-only Hebrew fallback font. Android draws Hebrew
/// with a system fallback font; the test renderer has none, so Hebrew goldens
/// would show empty boxes without it. The font is OFL (see goldens/fonts).
const hebrewFallbackFont = 'NotoSansHebrew';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = File('test/goldens/fonts/NotoSansHebrew.ttf').readAsBytesSync();
  await (FontLoader(hebrewFallbackFont)
        ..addFont(Future.value(ByteData.sublistView(bytes))))
      .load();

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.linux},
      ),
    ),
    run: () async => testMain(),
  );
}
