import 'package:flutter/widgets.dart';

import 'material_icon_rounded.g.dart';

/// Builds a Material icon from a code point stored in the database
/// (user-chosen dashboard, panel and scene icons), drawn in its rounded
/// variant when it has one (ADR 0005). The stored value never changes.
///
/// `IconData`'s code point is marked must-be-const so release builds can
/// tree-shake the icon font. ZigDash picks icons at runtime, so release builds
/// pass `--no-tree-shake-icons` (see tool/build_release.sh) and this is the one
/// place that opts out of the const check.
IconData materialIcon(int codePoint) =>
    // ignore: non_const_argument_for_const_parameter
    IconData(materialRounded[codePoint] ?? codePoint, fontFamily: 'MaterialIcons');
