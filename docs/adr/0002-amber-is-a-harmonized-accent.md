# Signal amber is a harmonized accent, not the primary color

The 2.0 identity centers on an amber "fill when on" tile. Material You dynamic color is protected, so amber is not the theme's primary. It is a state color in a `ThemeExtension`, shifted toward the wallpaper's primary with `harmonizeWith` by at most about 15° of hue. Everything else follows the wallpaper. With Material You off, the ivory, ink and amber fallback palette applies.

Overriding `primary` on a wallpaper scheme replaces only that one role. It leaves `onPrimary` and the container roles unrecomputed, which silently breaks contrast pairs. Turning dynamic color off would drop a protected feature.

## Consequences

- Per-dashboard color swatches are accents: title, tab indicator and section headers. They no longer replace the scheme.
- Hard-coded `Colors.*` values move into the six harmonized state roles: active, idle, stale, attention, offlineDevice, healthy.

Decided 2026-09-26. See `docs/design/tokens.md` and `docs/design/research/m3-expressive-flutter-feasibility.md`, row 5.
