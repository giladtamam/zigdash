// Generates the ZigDash launcher icon source PNGs from code (no external image
// tooling needed). Run: dart run tool/gen_icon.dart
// Produces:
//   assets/icon/icon.png        — full-bleed icon (brand bg + tiles) for iOS/web/legacy
//   assets/icon/foreground.png  — transparent foreground (tiles only) for Android adaptive
//
// Motif: the Material "dashboard" pinwheel of four rounded tiles, two-tone,
// echoing the in-app dashboard grid. Brand seed is #3B82F6.
import 'dart:io';
import 'package:image/image.dart';

const int size = 1024;

// Brand palette.
final brand = ColorRgba8(0x3B, 0x82, 0xF6, 0xFF); // #3B82F6 background
final white = ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF);
final tint = ColorRgba8(0xBF, 0xDB, 0xFE, 0xFF); // #BFDBFE accent tiles
const int radius = 30;

// Art box: a 24-unit grid placed in a centered safe zone (~66% of canvas) so
// the pinwheel survives Android's adaptive mask. content spans grid 3..21.
const double box = 680; // art-box side
final double origin = (size - box) / 2; // 172
double u(double v) => origin + (v / 24.0) * box;

/// Draw the four pinwheel tiles into [img] using the given colors.
void drawTiles(Image img) {
  // (col, top-left grid x/y, bottom-right grid x/y, color)
  // TL tall + BR tall in white; TR + BL in accent tint (diagonal rhythm).
  _tile(img, 3, 3, 10, 13, white); // top-left  (tall)
  _tile(img, 12, 3, 21, 9, tint); // top-right (wide, short)
  _tile(img, 3, 15, 10, 21, tint); // bottom-left (short)
  _tile(img, 12, 11, 21, 21, white); // bottom-right (tall)
}

void _tile(Image img, num x1, num y1, num x2, num y2, Color c) {
  fillRect(
    img,
    x1: u(x1.toDouble()).round(),
    y1: u(y1.toDouble()).round(),
    x2: u(x2.toDouble()).round(),
    y2: u(y2.toDouble()).round(),
    color: c,
    radius: radius,
  );
}

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // Full-bleed icon: brand background + tiles.
  final full = Image(width: size, height: size, numChannels: 4);
  fill(full, color: brand);
  drawTiles(full);
  File('assets/icon/icon.png').writeAsBytesSync(encodePng(full));

  // Adaptive foreground: transparent + tiles only.
  final fg = Image(width: size, height: size, numChannels: 4);
  fill(fg, color: ColorRgba8(0, 0, 0, 0));
  drawTiles(fg);
  File('assets/icon/foreground.png').writeAsBytesSync(encodePng(fg));

  stdout.writeln('wrote assets/icon/icon.png + assets/icon/foreground.png (${size}x$size)');
}
