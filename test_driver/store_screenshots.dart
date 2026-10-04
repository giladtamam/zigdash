import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Host side of integration_test/store_screenshots_test.dart: writes each
/// screenshot to `$STORE_OUT/<name>.png` (tool/store/capture.sh sets it).
Future<void> main() => integrationDriver(
      onScreenshot: (name, bytes, [args]) async {
        final out = Platform.environment['STORE_OUT'] ?? 'build/store';
        File('$out/$name.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        return true;
      },
    );
