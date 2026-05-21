import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/widgets/cover_panel.dart';

void main() {
  group('resolveCoverAction', () {
    test('tapping a different segment returns that segment', () {
      expect(resolveCoverAction({'CLOSE'}, 'OPEN'), 'CLOSE');
    });

    // The bug: SegmentedButton emits an EMPTY selection when you re-tap the
    // segment that is already selected (it deselects, because
    // emptySelectionAllowed is true). The active segment matches the device
    // state, so re-tapping it must still re-issue that command.
    test('re-tapping the active segment (empty selection) still returns the current state', () {
      expect(resolveCoverAction(<String>{}, 'OPEN'), 'OPEN');
    });

    test('tapping a segment when no state is known returns that segment', () {
      expect(resolveCoverAction({'OPEN'}, null), 'OPEN');
    });

    test('empty selection with no known state is a no-op', () {
      expect(resolveCoverAction(<String>{}, null), isNull);
    });
  });
}
