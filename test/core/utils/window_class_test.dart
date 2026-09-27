import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/utils/window_class.dart';
import 'package:zigdash/features/panels/models/grid_layout.dart';

void main() {
  test('window classes at the Material 3 breakpoints', () {
    expect(WindowClass.forWidth(599), WindowClass.compact);
    expect(WindowClass.forWidth(600), WindowClass.medium);
    expect(WindowClass.forWidth(839), WindowClass.medium);
    expect(WindowClass.forWidth(840), WindowClass.expanded);
    expect(WindowClass.forWidth(599).hasRail, isFalse);
    expect(WindowClass.forWidth(600).hasRail, isTrue);
  });

  test('columns follow the window, so the rail never costs a column', () {
    // The grid passes the window width, not the width the rail leaves.
    for (final (window, columns) in [
      (599.0, 2),
      (600.0, 3),
      (679.0, 3),
      (839.0, 3),
      (840.0, 4),
    ]) {
      expect(gridColumns(window), columns, reason: '$window dp');
    }
  });
}
