# Signal amber is a harmonized accent, not the primary color

The 2.0 identity centers on an amber "fill when on" tile. Material You dynamic color is protected, so amber is not the theme's primary. It is a state color in a `ThemeExtension`, shifted toward the wallpaper's primary with `harmonizeWith` by at most about 15° of hue. Everything else follows the wallpaper. With Material You off, the ivory, ink and amber fallback palette applies.

Overriding `primary` on a wallpaper scheme replaces only that one role. It leaves `onPrimary` and the container roles unrecomputed, which silently breaks contrast pairs. Turning dynamic color off would drop a protected feature.

## Consequences

- Per-dashboard color swatches are accents: title, tab indicator and section headers. They no longer replace the scheme.
- Hard-coded `Colors.*` values move into the six harmonized state roles: active, idle, stale, attention, offlineDevice, healthy.

Decided 2026-09-26. See `docs/design/tokens.md` and `docs/design/research/m3-expressive-flutter-feasibility.md`, row 5.

## Amendment, 2026-09-27: Signal is the default; Material You is an option

The first device run of 2.0 showed that with Material You on, the wallpaper's surfaces, navigation and buttons hide most of Signal. Only the amber tiles, type and shapes stayed. The user decided that the setting "Use Material You colors" now defaults to off, for new installs and for upgraders who never changed it. Anyone who turned it on or off themselves keeps that choice. When it is on, everything above still holds: surfaces follow the wallpaper, and amber is harmonized toward it.
