import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/grid_layout.dart';

void main() {
  test('columns follow the window class', () {
    expect(gridColumns(390), 2);
    expect(gridColumns(700), 3);
    expect(gridColumns(1280), 4);
  });

  test('compact windows drop to one column at 160% text', () {
    expect(gridColumns(390, textScale: 1.5), 2);
    expect(gridColumns(390, textScale: 1.6), 1);
    expect(gridColumns(700, textScale: 2.0), 3);
  });

  test('a Wide tile never spans more columns than exist', () {
    expect(tileSpan(PanelWidth.wide, 4), 2);
    expect(tileSpan(PanelWidth.wide, 1), 1);
    expect(tileSpan(PanelWidth.full, 3), 3);
  });

  test('packing keeps order and starts a new row when a tile does not fit',
      () {
    const s = PanelWidth.small, w = PanelWidth.wide, f = PanelWidth.full;
    final rows = packRows([s, w, s, s, f, s], (x) => x, 2);
    expect(
      rows.map((r) => r.map((c) => c.span).toList()).toList(),
      [
        [1],
        [2],
        [1, 1],
        [2],
        [1],
      ],
    );
  });
}
