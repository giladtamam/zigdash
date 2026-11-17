// Moving from ZHA (docs/design/zha-migration.md, Phase 1): a short sheet
// that says what moving means, the web guide in the app's language, and
// "I'm moving", which setup and the Home Assistant import remember for 60
// days. Everything here stays on the phone; only the steps are counted.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../onboarding/setup/setup_screen.dart' show openSetupLink;
import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;

/// When "I'm moving" was tapped, as epoch milliseconds.
const zhaMovingAtKey = 'zha_moving_at';

/// When setup's Home Assistant check last found devices in ZHA (3.7.1).
const zhaFoundAtKey = 'zha_found_at';

/// Whether the last answer to "What runs your Zigbee?" was ZHA: the demo
/// home's banner then offers the sheet.
const zhaAnsweredKey = 'setup_answer_zha';

/// How long "I'm moving" and a ZHA find count: the second-adapter way can
/// mean ordering an adapter first.
const zhaMoveWindow = Duration(days: 60);

bool _recent(SharedPreferences prefs, String key, DateTime now) {
  final at = prefs.getInt(key);
  return at != null &&
      now.difference(DateTime.fromMillisecondsSinceEpoch(at)) < zhaMoveWindow;
}

/// Whether "I'm moving" was tapped within [zhaMoveWindow].
bool zhaMoving(SharedPreferences prefs, {DateTime? now}) =>
    _recent(prefs, zhaMovingAtKey, now ?? DateTime.now());

/// What a finished setup says about ZHA (`from_zha`): moving after "I'm
/// moving", devices when the Home Assistant check found ZHA devices, both
/// within [zhaMoveWindow]. A ZHA answer alone never counts: people change
/// answers.
FromZha? fromZhaOf(SharedPreferences prefs, {DateTime? now}) {
  final at = now ?? DateTime.now();
  if (_recent(prefs, zhaMovingAtKey, at)) return FromZha.moving;
  if (_recent(prefs, zhaFoundAtKey, at)) return FromZha.devices;
  return null;
}

/// A setup finished: the move is over, as far as ZigDash can tell. Best
/// effort: a working home must never hang on this.
Future<void> endZhaMove(SharedPreferences prefs) async {
  try {
    await prefs.remove(zhaMovingAtKey);
    await prefs.remove(zhaFoundAtKey);
  } catch (_) {}
}

/// The last answer to "What runs your Zigbee?" (3.8), best effort.
Future<void> noteZhaAnswer(SharedPreferences Function() prefs, bool zha) async {
  try {
    if (zha) {
      await prefs().setBool(zhaAnsweredKey, true);
    } else {
      await prefs().remove(zhaAnsweredKey);
    }
  } catch (_) {}
}

/// Best effort for screens shown without preferences (golden tests).
FromZha? fromZhaOrNull(SharedPreferences Function() prefs) {
  try {
    return fromZhaOf(prefs());
  } catch (_) {
    return null;
  }
}

/// "I'm moving", watched so setup's first screen can lead with it.
class ZhaMovingNotifier extends Notifier<bool> {
  /// Best effort: screens shown without preferences (golden tests) are
  /// never moving.
  @override
  bool build() {
    try {
      return zhaMoving(ref.watch(sharedPreferencesProvider));
    } catch (_) {
      return false;
    }
  }

  Future<void> start() async {
    await ref
        .read(sharedPreferencesProvider)
        .setInt(zhaMovingAtKey, DateTime.now().millisecondsSinceEpoch);
    state = true;
  }

  Future<void> end() async {
    try {
      await endZhaMove(ref.read(sharedPreferencesProvider));
    } catch (_) {}
    state = false;
  }
}

final zhaMovingProvider = NotifierProvider<ZhaMovingNotifier, bool>(
  ZhaMovingNotifier.new,
);

/// The guide's languages besides English (zigdash.app/zha/<code>/).
const _guideLanguages = {
  'cs', 'de', 'es', 'fr', 'he', 'it', 'nb', 'nl', 'pl', 'pt', 'ru', 'sv', //
};

/// The web guide in [locale]'s language, English otherwise.
Uri zhaGuideUrlFor(Locale? locale) {
  final code = locale?.languageCode;
  return Uri.parse(
    code != null && _guideLanguages.contains(code)
        ? 'https://zigdash.app/zha/$code/'
        : 'https://zigdash.app/zha/',
  );
}

/// The sheet: what moving means, the two ways in a line each, and Read
/// the steps / I'm moving / Not now. Counted as `zha_move` with [from].
Future<void> showZhaMoveSheet(
  BuildContext context,
  WidgetRef ref,
  ZhaMoveFrom from,
) async {
  final analytics = ref.read(analyticsProvider);
  void count(ZhaMoveStep step) => analytics.track(ZhaMoveEvent(step, from));
  count(ZhaMoveStep.opened);
  final l10n = context.l10n;
  final locale = Localizations.maybeLocaleOf(context);
  final moving = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final theme = Theme.of(context);
      Widget way(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          ],
        ),
      );
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            key: const Key('zha-move-sheet'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.haConnectZhaMove, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(l10n.zhaMoveBody, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              way(Icons.add_circle_outline, l10n.zhaMoveWaySecond),
              way(Icons.swap_horiz, l10n.zhaMoveWaySame),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                key: const Key('zha-move-guide'),
                onPressed: () {
                  count(ZhaMoveStep.guide);
                  openSetupLink(zhaGuideUrlFor(locale));
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l10n.zhaMoveReadSteps),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const Key('zha-move-moving'),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.zhaMoveImMoving),
              ),
              TextButton(
                key: const Key('zha-move-not-now'),
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.zhaMoveNotNow),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (moving == true) {
    count(ZhaMoveStep.moving);
    await ref.read(zhaMovingProvider.notifier).start();
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(l10n.zhaMovingNoted)));
    }
  } else if (moving == false) {
    count(ZhaMoveStep.notNow);
  }
}
