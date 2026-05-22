// Generates Google Play store graphic assets. Run: dart run tool/gen_store_assets.dart
//   store/play_icon_512.png        — 512x512 hi-res listing icon (full-bleed)
//   store/feature_graphic.png      — 1024x500 feature graphic
// On-brand: dashboard-tiles pinwheel (white + #BFDBFE) on brand #3B82F6.
import 'dart:io';
import 'package:image/image.dart';

final brand = ColorRgba8(0x3B, 0x82, 0xF6, 0xFF); // #3B82F6
final brandDark = ColorRgba8(0x25, 0x63, 0xEB, 0xFF); // #2563EB
final white = ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF);
final tint = ColorRgba8(0xBF, 0xDB, 0xFE, 0xFF); // #BFDBFE

/// Draw the four-tile pinwheel inside a [box]-sized square at (ox, oy).
void drawPinwheel(Image img, double box, double ox, double oy) {
  double gx(double v) => ox + (v / 24.0) * box;
  final r = (box * 0.045).round();
  void tile(num x1, num y1, num x2, num y2, Color c) => fillRect(img,
      x1: gx(x1.toDouble()).round(),
      y1: gx(y1.toDouble()).round() - ox.round() + oy.round(),
      x2: gx(x2.toDouble()).round(),
      y2: gx(y2.toDouble()).round() - ox.round() + oy.round(),
      color: c,
      radius: r);
  tile(3, 3, 10, 13, white); // TL tall
  tile(12, 3, 21, 9, tint); // TR wide-short
  tile(3, 15, 10, 21, tint); // BL short
  tile(12, 11, 21, 21, white); // BR tall
}

void main() {
  Directory('store').createSync(recursive: true);

  // 512x512 hi-res icon (same composition as launcher icon, full-bleed).
  final icon = Image(width: 512, height: 512, numChannels: 4);
  fill(icon, color: brand);
  drawPinwheel(icon, 340, 86, 86);
  File('store/play_icon_512.png').writeAsBytesSync(encodePng(icon));

  // 1024x500 feature graphic: vertical brand gradient + logo + wordmark.
  const w = 1024, h = 500;
  final fg = Image(width: w, height: h, numChannels: 4);
  for (var y = 0; y < h; y++) {
    final t = y / (h - 1);
    final c = ColorRgba8(
      (brand.r + (brandDark.r - brand.r) * t).round(),
      (brand.g + (brandDark.g - brand.g) * t).round(),
      (brand.b + (brandDark.b - brand.b) * t).round(),
      255,
    );
    drawLine(fg, x1: 0, y1: y, x2: w - 1, y2: y, color: c);
  }
  // Hero logo on the left, vertically centered.
  drawPinwheel(fg, 300, 90, 100);
  // Wordmark + tagline on the right (bundled bitmap fonts; crisp at native size).
  drawString(fg, 'ZigDash',
      font: arial48, x: 470, y: 200, color: white);
  drawString(fg, 'Zigbee2MQTT dashboards over MQTT',
      font: arial24, x: 472, y: 262, color: tint);
  File('store/feature_graphic.png').writeAsBytesSync(encodePng(fg));

  stdout.writeln('wrote store/play_icon_512.png (512x512) + store/feature_graphic.png (1024x500)');
}
