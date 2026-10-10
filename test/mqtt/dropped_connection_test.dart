import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/mqtt/dropped_connection.dart';

void main() {
  test('a dead broker socket is swallowed', () {
    const e = SocketException('Software caused connection abort',
        osError: OSError('Software caused connection abort', 103));
    expect(ignoreDroppedConnection(e, StackTrace.current), isTrue);
  });

  test('any other uncaught error still surfaces', () {
    expect(ignoreDroppedConnection(StateError('bug'), StackTrace.current),
        isFalse);
    expect(ignoreDroppedConnection(const FormatException('bad'),
        StackTrace.current), isFalse);
  });
}
