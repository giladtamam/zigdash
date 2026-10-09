import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'signal_colors.dart';
import 'tokens.dart';

/// The Signal theme (docs/design/signal-2.0.md §1–2). With Material You on,
/// surfaces follow the wallpaper [dynamic] scheme and the state roles are
/// harmonized toward it; otherwise the ivory, ink and amber fallback.
class AppTheme {
  AppTheme._();

  static ThemeData light({ColorScheme? dynamic}) => _build(
        dynamic?.harmonized() ?? _fallback(Brightness.light),
        dynamic == null ? SignalColors.light : null,
      );

  static ThemeData dark({ColorScheme? dynamic}) => _build(
        dynamic?.harmonized() ?? _fallback(Brightness.dark),
        dynamic == null ? SignalColors.dark : null,
      );

  /// The scheme when Material You is off: ivory ground, ink text, amber as
  /// the accent (ink on it in light, amber itself in dark).
  static ColorScheme _fallback(Brightness b) {
    final light = b == Brightness.light;
    final base = ColorScheme.fromSeed(
      seedColor: light ? SignalPalette.amberLight : SignalPalette.amberDark,
      brightness: b,
    );
    return light
        ? base.copyWith(
            primary: SignalPalette.inkLight,
            onPrimary: SignalPalette.amberLight,
            primaryContainer: SignalPalette.amberLight,
            onPrimaryContainer: SignalPalette.onAmber,
            secondaryContainer: SignalPalette.raisedLight,
            onSecondaryContainer: SignalPalette.inkLight,
            surface: SignalPalette.groundLight,
            onSurface: SignalPalette.inkLight,
            onSurfaceVariant: SignalPalette.inkVariantLight,
            surfaceContainerLowest: SignalPalette.tileLight,
            surfaceContainerLow: const Color(0xFFFBF9F4),
            surfaceContainer: const Color(0xFFF3EFE6),
            surfaceContainerHigh: SignalPalette.raisedLight,
            surfaceContainerHighest: SignalPalette.hairlineLight,
            outline: const Color(0xFF8A826F),
            outlineVariant: SignalPalette.hairlineLight,
          )
        : base.copyWith(
            primary: SignalPalette.amberDark,
            onPrimary: SignalPalette.onAmber,
            primaryContainer: SignalPalette.amberDark,
            onPrimaryContainer: SignalPalette.onAmber,
            secondaryContainer: SignalPalette.raisedDark,
            onSecondaryContainer: SignalPalette.inkDark,
            surface: SignalPalette.groundDark,
            onSurface: SignalPalette.inkDark,
            onSurfaceVariant: SignalPalette.inkVariantDark,
            surfaceContainerLowest: const Color(0xFF100E0B),
            surfaceContainerLow: const Color(0xFF1A1813),
            surfaceContainer: const Color(0xFF1E1B16),
            surfaceContainerHigh: SignalPalette.tileDark,
            surfaceContainerHighest: SignalPalette.raisedDark,
            outline: const Color(0xFF7D7566),
            outlineVariant: SignalPalette.hairlineDark,
          );
  }

  static ThemeData _build(ColorScheme scheme, SignalColors? roles) {
    final signal = roles ?? SignalColors.dynamic(scheme);
    final text = _textTheme(scheme);
    RoundedSuperellipseBorder squircle(double r, {BorderSide side = BorderSide.none}) =>
        RoundedSuperellipseBorder(
            borderRadius: BorderRadiusDirectional.circular(r), side: side);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: scheme.brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: SignalFonts.body,
      fontFamilyFallback: SignalFonts.fallback,
      textTheme: text,
      extensions: [signal],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: signal.idle,
        shape: squircle(SignalRadii.tile, side: BorderSide(color: signal.hairline)),
      ),
      chipTheme: ChipThemeData(
        shape: squircle(SignalRadii.chip),
        side: BorderSide(color: signal.hairline),
        labelStyle: text.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: squircle(SignalRadii.button)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: squircle(SignalRadii.button)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: squircle(SignalRadii.chip)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(shape: squircle(SignalRadii.chip)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        shape: squircle(SignalRadii.button),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary,
        indicatorShape: squircle(SignalRadii.navIndicator),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.onSurfaceVariant)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary,
        indicatorShape: squircle(SignalRadii.navIndicator),
        selectedIconTheme: IconThemeData(color: scheme.onPrimary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadiusDirectional.vertical(
              top: Radius.circular(SignalRadii.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: squircle(SignalRadii.sheet),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: squircle(SignalRadii.chip),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: squircle(SignalRadii.chip),
      ),
      dividerTheme: DividerThemeData(color: signal.hairline),
    );
  }

  /// Type roles (tokens.md, Type): Space Grotesk for display and headlines,
  /// IBM Plex Sans for everything else; Hebrew falls back to Plex Hebrew.
  static TextTheme _textTheme(ColorScheme scheme) {
    final base = Typography.material2021(platform: TargetPlatform.android)
        .englishLike
        .merge(scheme.brightness == Brightness.dark
            ? Typography.material2021().white
            : Typography.material2021().black)
        .apply(
          fontFamily: SignalFonts.body,
          fontFamilyFallback: SignalFonts.fallback,
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );
    TextStyle? display(TextStyle? s, {double? size}) => s?.copyWith(
          fontFamily: SignalFonts.display,
          fontWeight: FontWeight.w700,
          fontSize: size ?? s.fontSize,
          letterSpacing: -0.5,
        );
    return base.copyWith(
      displayLarge: display(base.displayLarge),
      displayMedium: display(base.displayMedium),
      displaySmall: display(base.displaySmall, size: 34),
      headlineLarge: display(base.headlineLarge),
      headlineMedium: display(base.headlineMedium),
      headlineSmall: display(base.headlineSmall),
      titleLarge: base.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 15),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 13),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

/// The section label style (tokens.md): Space Grotesk 13 bold, uppercase with
/// +1.2 tracking, except in Hebrew, which has no case.
TextStyle sectionLabelStyle(BuildContext context) {
  final theme = Theme.of(context);
  final hebrew = Localizations.localeOf(context).languageCode == 'he';
  return TextStyle(
    fontFamily: SignalFonts.display,
    fontFamilyFallback: SignalFonts.fallback,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: hebrew ? 0 : 1.2,
    color: theme.colorScheme.onSurfaceVariant,
  );
}

/// Uppercases [text] for a section label, except in Hebrew.
String sectionLabelText(BuildContext context, String text) =>
    Localizations.localeOf(context).languageCode == 'he'
        ? text
        : text.toUpperCase();
