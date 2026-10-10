import 'dart:convert';

import '../l10n/app_localizations.dart';

/// One alert as the hub sends it (docs/design/alerts-2.3.md, "What it
/// sends"): the kind, which device, in which Home, and whether it fired or
/// cleared. The phone writes the words (CONTEXT.md: Notification).
class AlertEvent {
  const AlertEvent({
    required this.kind,
    required this.connectionId,
    required this.device,
    required this.name,
    required this.home,
    required this.cleared,
    this.value,
    required this.at,
  });

  /// `leak`, `smoke`, `opened`, `battery` or `test`.
  final String kind;
  final String? connectionId;
  final String? device;
  final String name;
  final String home;
  final bool cleared;
  final num? value;
  final DateTime at;

  static AlertEvent? decode(String raw) {
    try {
      final j = jsonDecode(raw);
      if (j is! Map) return null;
      return AlertEvent(
        kind: j['kind'] as String? ?? '',
        connectionId: j['connection'] as String?,
        device: j['device'] as String?,
        name: j['name'] as String? ?? '',
        home: j['home'] as String? ?? '',
        cleared: j['cleared'] == true,
        value: j['value'] is num ? j['value'] as num : null,
        at: DateTime.tryParse(j['at'] as String? ?? '')?.toLocal() ??
            DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, Object?> toJson() => {
        'v': 1,
        'kind': kind,
        'connection': connectionId,
        'device': device,
        'name': name,
        'home': home,
        'cleared': cleared,
        'value': value,
        'at': at.toUtc().toIso8601String(),
      };

  /// Leak and smoke ring; the rest just show.
  bool get urgent => (kind == 'leak' || kind == 'smoke') && !cleared;

  /// The notification's text, in the app's language. [oneHome]: leave the
  /// Home's name out.
  String text(AppLocalizations l10n, {bool oneHome = false}) {
    final body = switch (kind) {
      'leak' => cleared ? l10n.alertLeakCleared(name) : l10n.alertLeak(name),
      'smoke' =>
        cleared ? l10n.alertSmokeCleared(name) : l10n.alertSmoke(name),
      'opened' => l10n.alertOpened(name),
      'battery' => l10n.alertBattery(name, value?.round().toString() ?? '?'),
      'test' => l10n.alertTest,
      _ => name,
    };
    return oneHome || home.isEmpty ? body : '$body ($home)';
  }
}
