// Generates the ZigDash launcher icon source PNGs from code.
// Run: dart run tool/gen_icon.dart
// Produces:
//   assets/icon/icon.png        — full-bleed glossy icon for iOS/web/legacy
//   assets/icon/foreground.png  — transparent foreground (tiles only) for Android adaptive
//
// Design: "Glass Dashboard"
//   - Deep radial gradient background (navy → brand blue)
//   - 4 rounded pinwheel tiles with glossy highlights + soft shadows
//   - Diagonal glass reflection overlay
//   - Brand: #3B82F6
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart';

const int size = 1024;

final brandBright = ColorRgba8(0x3B, 0x82, 0xF6, 0xFF);
final brandDark = ColorRgba8(0x1E, 0x40, 0xAF, 0xFF);
final white = ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF);
final tileLight = ColorRgba8(0xDB, 0xE8, 0xFE, 0xFF);
final tileDark = ColorRgba8(0xBF, 0xDB, 0xFE, 0xFF);
final shadowColor = ColorRgba8(0x1E, 0x3A, 0x8F, 0x50);
final trans = ColorRgba8(0x00, 0x00, 0x00, 0x00);

const int tileRadius = 36;

const double box = 676;
final double origin = (size - box) / 2;

double u(double v) => (origin + (v / 24.0) * box).roundToDouble();

num mx(num x, num y, num a) => x * (1 - a) + y * a;

ColorRgba8 lerpColor(ColorRgba8 a, ColorRgba8 b, double t) {
  t = t.clamp(0.0, 1.0);
  return ColorRgba8(
    mx(a.r, b.r, t).round(),
    mx(a.g, b.g, t).round(),
    mx(a.b, b.b, t).round(),
    mx(a.a, b.a, t).round(),
  );
}

void fillRadialGradient(
  Image img, {
  required ColorRgba8 centerColor,
  required ColorRgba8 edgeColor,
  double cx = 0.5,
  double cy = 0.5,
  double r = 0.7,
}) {
  final pcx = (img.width * cx).round();
  final pcy = (img.height * cy).round();
  final maxD = sqrt(pow(img.width / 2, 2) + pow(img.height / 2, 2)) * r;
  for (final p in img) {
    final dx = p.x - pcx;
    final dy = p.y - pcy;
    final d = sqrt(dx * dx + dy * dy);
    final t = (d / maxD).clamp(0.0, 1.0);
    p.set(lerpColor(centerColor, edgeColor, t));
  }
}

bool inRoundedRect(int x, int y, int x1, int y1, int x2, int y2, int r) {
  if (x < x1 || x >= x2 || y < y1 || y >= y2) return false;
  if (r <= 0) return true;
  if (x < x1 + r && y < y1 + r) {
    final dx = x1 + r - x, dy = y1 + r - y;
    if (dx * dx + dy * dy > r * r) return false;
  }
  if (x >= x2 - r && y < y1 + r) {
    final dx = x - (x2 - r - 1), dy = y1 + r - y;
    if (dx * dx + dy * dy > r * r) return false;
  }
  if (x < x1 + r && y >= y2 - r) {
    final dx = x1 + r - x, dy = y - (y2 - r - 1);
    if (dx * dx + dy * dy > r * r) return false;
  }
  if (x >= x2 - r && y >= y2 - r) {
    final dx = x - (x2 - r - 1), dy = y - (y2 - r - 1);
    if (dx * dx + dy * dy > r * r) return false;
  }
  return true;
}

void drawGlossyTile(
  Image img, {
  required int x1,
  required int y1,
  required int x2,
  required int y2,
  required ColorRgba8 bodyColor,
}) {
  final h = y2 - y1;

  const int sd = 6;
  // Shadow — offset fill behind the tile
  for (final p in img) {
    if (inRoundedRect(
            p.x, p.y, x1 + sd, y1 + sd, x2 + sd, y2 + sd, tileRadius) &&
        !inRoundedRect(p.x, p.y, x1, y1, x2, y2, tileRadius)) {
      final a = shadowColor.a / 255.0;
      p.r = mx(p.r, shadowColor.r, a).round();
      p.g = mx(p.g, shadowColor.g, a).round();
      p.b = mx(p.b, shadowColor.b, a).round();
    }
  }

  // Body — solid fill with rounded corners
  fillRect(
      img, x1: x1, y1: y1, x2: x2, y2: y2, color: bodyColor, radius: tileRadius);

  // Bottom gradient for depth
  final bodyDark =
      lerpColor(bodyColor, ColorRgba8(0x1E, 0x3A, 0x8F, 0xFF), 0.18);
  final gradientStart = y1 + (h * 0.65).round();
  for (final p in img) {
    if (p.y >= gradientStart &&
        inRoundedRect(p.x, p.y, x1, y1, x2, y2, tileRadius)) {
      final t = (p.y - gradientStart) / (y2 - gradientStart);
      final g = lerpColor(bodyColor, bodyDark, t);
      final a = g.a / 255.0;
      p.r = mx(p.r, g.r, a).round();
      p.g = mx(p.g, g.g, a).round();
      p.b = mx(p.b, g.b, a).round();
    }
  }

  // Top highlight strip — glossy sheen
  final hlH = (h * 0.22).round();
  for (final p in img) {
    if (p.y >= y1 &&
        p.y < y1 + hlH &&
        inRoundedRect(p.x, p.y, x1, y1, x2, y2, tileRadius)) {
      final t = 1.0 - (p.y - y1) / hlH;
      final ha = (t * 55).round();
      final hl = ColorRgba8(0xFF, 0xFF, 0xFF, ha);
      final a = hl.a / 255.0;
      p.r = mx(p.r, hl.r, a).round();
      p.g = mx(p.g, hl.g, a).round();
      p.b = mx(p.b, hl.b, a).round();
    }
  }
}

void drawGlassReflection(Image img) {
  for (final p in img) {
    final t = ((p.x / img.width) + (p.y / img.height)) / 2;
    final alpha = ((1.0 - t) * 0.12).clamp(0.0, 1.0);
    if (alpha <= 0) continue;
    final refl = ColorRgba8(0xFF, 0xFF, 0xFF, (alpha * 255).round());
    final a = refl.a / 255.0;
    p.r = mx(p.r, refl.r, a).round();
    p.g = mx(p.g, refl.g, a).round();
    p.b = mx(p.b, refl.b, a).round();
  }
}

void drawTiles(Image img, bool shadowed) {
  final sd = shadowed ? 6 : 0;

  // Top-left  (tall white tile)
  drawGlossyTile(img,
      x1: u(3).round(),
      y1: u(3).round(),
      x2: u(10).round() + sd,
      y2: u(13).round() + sd,
      bodyColor: white);

  // Top-right (wide, short, light-blue tile)
  drawGlossyTile(img,
      x1: u(12).round(),
      y1: u(3).round(),
      x2: u(21).round() + sd,
      y2: u(9).round() + sd,
      bodyColor: tileLight);

  // Bottom-left (short, darker-blue tile)
  drawGlossyTile(img,
      x1: u(3).round(),
      y1: u(15).round(),
      x2: u(10).round() + sd,
      y2: u(21).round() + sd,
      bodyColor: tileDark);

  // Bottom-right (tall white tile)
  drawGlossyTile(img,
      x1: u(12).round(),
      y1: u(11).round(),
      x2: u(21).round() + sd,
      y2: u(21).round() + sd,
      bodyColor: white);
}

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // Full-bleed icon: glossy gradient background + tiles + glass reflection.
  final full =
      Image(width: size, height: size, format: Format.uint8, numChannels: 4);

  fillRadialGradient(
    full,
    centerColor: brandBright,
    edgeColor: brandDark,
    cx: 0.5,
    cy: 0.5,
    r: 0.8,
  );

  drawTiles(full, true);
  drawGlassReflection(full);

  File('assets/icon/icon.png').writeAsBytesSync(encodePng(full));

  // Adaptive foreground: transparent + tiles (no background for Android).
  final fg =
      Image(width: size, height: size, format: Format.uint8, numChannels: 4);
  fill(fg, color: trans);

  drawTiles(fg, false);
  drawGlassReflection(fg);

  // 512x512 store icon
  final storeIcon = copyResize(full, width: 512, height: 512);
  Directory('store').createSync(recursive: true);
  File('store/play_icon_512.png').writeAsBytesSync(encodePng(storeIcon));

  File('assets/icon/foreground.png').writeAsBytesSync(encodePng(fg));

  stdout.writeln(
      'wrote assets/icon/icon.png + assets/icon/foreground.png + store/play_icon_512.png (${size}x$size)');
}
