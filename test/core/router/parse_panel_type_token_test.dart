import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/router/app_router.dart';
import 'package:zigdash/data/database/tables/panels.dart';

void main() {
  group('parsePanelTypeToken', () {
    test('every PanelType round-trips through its .name token', () {
      // The panel picker pushes `?type=<PanelType.name>`. Every enum value must
      // resolve back to itself — a missing mapping silently routed autoClose to
      // toggle (regression guard for that bug).
      for (final type in PanelType.values) {
        expect(parsePanelTypeToken(type.name), type,
            reason: 'token "${type.name}" should map to $type');
      }
    });

    test('autoClose token maps to PanelType.autoClose (not toggle)', () {
      expect(parsePanelTypeToken('autoClose'), PanelType.autoClose);
    });

    test('null and unknown tokens fall back to toggle', () {
      expect(parsePanelTypeToken(null), PanelType.toggle);
      expect(parsePanelTypeToken('nonsense'), PanelType.toggle);
      expect(parsePanelTypeToken(''), PanelType.toggle);
    });
  });
}
