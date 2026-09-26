import '../../../data/database/tables/panels.dart';

/// Grid columns for a window [width] in dp: 2 on compact (< 600), 3 on
/// medium (< 840), 4 on expanded. On compact windows at a text scale of 1.6
/// or more the grid drops to a single column so tiles keep readable names.
int gridColumns(double width, {double textScale = 1.0}) {
  if (width < 600) return textScale >= 1.6 ? 1 : 2;
  if (width < 840) return 3;
  return 4;
}

/// The smallest a tile may be, in dp, at the same window classes as
/// [gridColumns]. A row is as tall as its tallest tile, never shorter.
double minTileHeight(double width) {
  if (width < 600) return 118;
  if (width < 840) return 140;
  return 176;
}

/// How many columns a tile of [size] spans in a grid of [columns].
int tileSpan(PanelWidth size, int columns) => switch (size) {
      PanelWidth.small => 1,
      PanelWidth.wide => columns < 2 ? columns : 2,
      PanelWidth.full => columns,
    };

/// One tile placed in a grid row.
typedef PlacedTile<T> = ({T tile, int span});

/// Packs [tiles] into rows of [columns] in order. A tile that does not fit
/// in what is left of a row starts the next row; order is never changed, so
/// a row can end with a gap.
List<List<PlacedTile<T>>> packRows<T>(
  List<T> tiles,
  PanelWidth Function(T) sizeOf,
  int columns,
) {
  final rows = <List<PlacedTile<T>>>[];
  var row = <PlacedTile<T>>[];
  var used = 0;
  for (final tile in tiles) {
    final span = tileSpan(sizeOf(tile), columns);
    if (used + span > columns && row.isNotEmpty) {
      rows.add(row);
      row = [];
      used = 0;
    }
    row.add((tile: tile, span: span));
    used += span;
  }
  if (row.isNotEmpty) rows.add(row);
  return rows;
}
