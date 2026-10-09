import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/build/store_capture.dart';

void main() {
  test('store capture is off unless the capture script asks for it', () {
    expect(storeCapture, isFalse);
  });

  test('release builds never hide the demo bar', () {
    for (final f in Directory('tool').listSync(recursive: true)) {
      if (f is! File || f.path.contains('tool/store/')) continue;
      if (!(f.path.endsWith('.sh') || f.path.endsWith('.dart'))) continue;
      expect(f.readAsStringSync(), isNot(contains('ZIGDASH_STORE_CAPTURE')),
          reason: f.path);
    }
  });
}
