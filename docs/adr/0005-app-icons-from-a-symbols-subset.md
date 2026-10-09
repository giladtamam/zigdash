# App icons come from a Material Symbols subset; stored icons stay Material Icons

From 2.0 the icons the app draws itself (device classes, navigation, headers, tile and page chrome) come from a subset of **Material Symbols Rounded** that ZigDash bundles as its own font file. The subset is cut with fonttools to the glyphs the app uses and keeps the variable FILL axis. An idle device draws with FILL 0 (outlined) and an active one with FILL 1 (filled): the second "on" cue that `tokens.md` asks for beside the amber fill.

Icons the user picked are stored in the database as MaterialIcons code points: dashboard icons, scene icons, and toggle and button tile icons. They stay that way. `materialIcon()` draws each stored code point through a generated table that maps a regular glyph to its `_rounded` variant in the same font. Every stored icon then renders in the rounded style, with nothing migrated and nothing stored changed. A code point missing from the table draws as before.

`tokens.md` asked for Material Symbols Rounded everywhere. This splits it for two reasons.

- **Flutter's built-in font cannot give both corner style and fill.** In Flutter 3.47 most glyphs have `_rounded` (filled) and `_outlined` (square-cornered outline) variants, but few have `_outline_rounded`. The device-class icons do not. Built-in icons alone would mix corner styles between idle and active.
- **Converting stored code points would be an upgrade-time data change.** It would also need the whole Symbols font, because release builds cannot tree-shake icons (`--no-tree-shake-icons`), and that font is several megabytes. The subset is tens of kilobytes. The render-time table changes nothing a user saved.

## Considered options

- **Symbols everywhere, with stored code points migrated.** Rejected: it needs a mapping for every stored icon, a migration users cannot undo, and a multi-megabyte font.
- **Built-in Material Icons only (`_rounded` for active, `_outlined` for idle).** Rejected: the corners change shape when a device turns on.
- **The material_symbols_icons package.** Rejected: it ships whole font files, and tree-shaking is off in release builds.

Decided 2026-09-27. See `docs/design/signal-2.0.md` and the recipe in `tool/fonts/`.
