import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

/// The six state roles (tokens.md, State roles), each a container and the
/// content drawn on it. Screens read these, never hex values:
/// `SignalColors.of(context).active`.
@immutable
class SignalColors extends ThemeExtension<SignalColors> {
  const SignalColors({
    required this.active,
    required this.onActive,
    required this.idle,
    required this.onIdle,
    required this.stale,
    required this.onStale,
    required this.attention,
    required this.onAttention,
    required this.offline,
    required this.healthy,
    required this.onHealthy,
    required this.hairline,
    required this.raised,
  });

  /// On or open: the amber fill.
  final Color active;
  final Color onActive;

  /// Off or closed: the tile surface.
  final Color idle;
  final Color onIdle;

  /// A value older than the connection.
  final Color stale;
  final Color onStale;

  /// Low battery, leak, door open too long. Differs from amber in lightness.
  final Color attention;
  final Color onAttention;

  /// The far end of a leak or smoke alarm's slow pulse (signal-2.0.md §6):
  /// the attention fill eased a third of the way toward the tile surface.
  Color get attentionPulse => Color.lerp(attention, idle, 0.3)!;

  /// A device reports unavailable: outline and muted text.
  final Color offline;

  /// Online indicators, used sparingly.
  final Color healthy;
  final Color onHealthy;

  /// The 1 dp line around tiles.
  final Color hairline;

  /// Quick actions and chips on an idle tile.
  final Color raised;

  static SignalColors of(BuildContext context) =>
      Theme.of(context).extension<SignalColors>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  static const light = SignalColors(
    active: SignalPalette.amberLight,
    onActive: SignalPalette.onAmber,
    idle: SignalPalette.tileLight,
    onIdle: SignalPalette.inkLight,
    stale: SignalPalette.staleLight,
    onStale: SignalPalette.inkVariantLight,
    attention: SignalPalette.attentionLight,
    onAttention: SignalPalette.onAttentionLight,
    offline: SignalPalette.offlineLight,
    healthy: SignalPalette.healthyLight,
    onHealthy: SignalPalette.onHealthyLight,
    hairline: SignalPalette.hairlineLight,
    raised: SignalPalette.raisedLight,
  );

  static const dark = SignalColors(
    active: SignalPalette.amberDark,
    onActive: SignalPalette.onAmber,
    idle: SignalPalette.tileDark,
    onIdle: SignalPalette.inkDark,
    stale: SignalPalette.staleDark,
    onStale: SignalPalette.inkVariantDark,
    attention: SignalPalette.attentionDark,
    onAttention: SignalPalette.onAttentionDark,
    offline: SignalPalette.offlineDark,
    healthy: SignalPalette.healthyDark,
    onHealthy: SignalPalette.onHealthyDark,
    hairline: SignalPalette.hairlineDark,
    raised: SignalPalette.raisedDark,
  );

  /// With Material You on: surfaces come from the wallpaper [scheme], and
  /// the coloured roles are harmonized toward its primary (ADR 0002).
  factory SignalColors.dynamic(ColorScheme scheme) {
    final base = scheme.brightness == Brightness.dark ? dark : light;
    Color h(Color c) => c.harmonizeWith(scheme.primary);
    return base.copyWith(
      active: h(base.active),
      idle: scheme.brightness == Brightness.dark
          ? scheme.surfaceContainerHigh
          : scheme.surfaceContainerLowest,
      onIdle: scheme.onSurface,
      stale: scheme.surfaceContainer,
      onStale: scheme.onSurfaceVariant,
      attention: h(base.attention),
      onAttention: h(base.onAttention),
      healthy: h(base.healthy),
      onHealthy: h(base.onHealthy),
      hairline: scheme.outlineVariant,
      raised: scheme.surfaceContainerHighest,
    );
  }

  @override
  SignalColors copyWith({
    Color? active,
    Color? onActive,
    Color? idle,
    Color? onIdle,
    Color? stale,
    Color? onStale,
    Color? attention,
    Color? onAttention,
    Color? offline,
    Color? healthy,
    Color? onHealthy,
    Color? hairline,
    Color? raised,
  }) =>
      SignalColors(
        active: active ?? this.active,
        onActive: onActive ?? this.onActive,
        idle: idle ?? this.idle,
        onIdle: onIdle ?? this.onIdle,
        stale: stale ?? this.stale,
        onStale: onStale ?? this.onStale,
        attention: attention ?? this.attention,
        onAttention: onAttention ?? this.onAttention,
        offline: offline ?? this.offline,
        healthy: healthy ?? this.healthy,
        onHealthy: onHealthy ?? this.onHealthy,
        hairline: hairline ?? this.hairline,
        raised: raised ?? this.raised,
      );

  @override
  SignalColors lerp(SignalColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SignalColors(
      active: l(active, other.active),
      onActive: l(onActive, other.onActive),
      idle: l(idle, other.idle),
      onIdle: l(onIdle, other.onIdle),
      stale: l(stale, other.stale),
      onStale: l(onStale, other.onStale),
      attention: l(attention, other.attention),
      onAttention: l(onAttention, other.onAttention),
      offline: l(offline, other.offline),
      healthy: l(healthy, other.healthy),
      onHealthy: l(onHealthy, other.onHealthy),
      hairline: l(hairline, other.hairline),
      raised: l(raised, other.raised),
    );
  }
}
