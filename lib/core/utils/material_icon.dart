import 'package:flutter/widgets.dart';

/// Builds a Material icon from a code point stored in the database
/// (user-chosen dashboard, panel and scene icons).
///
/// `IconData`'s code point is marked must-be-const so release builds can
/// tree-shake the icon font. ZigDash picks icons at runtime, so release builds
/// pass `--no-tree-shake-icons` (see tool/build_release.sh) and this is the one
/// place that opts out of the const check.
IconData materialIcon(int codePoint) =>
    // ignore: non_const_argument_for_const_parameter
    IconData(codePoint, fontFamily: 'MaterialIcons');
