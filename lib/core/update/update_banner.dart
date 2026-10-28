import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../l10n/l10n_ext.dart';
import 'app_update.dart';

const updateDismissedOnKey = 'update.dismissed_on';

/// Behind by this many version codes, "Not now" no longer hides the banner
/// for the day: only for this visit.
const updateInsistBehind = 3;

String _today(DateTime now) =>
    '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

/// Offers Play's newer ZigDash on the dashboard (3.2.3): download while the
/// app stays open, then restart into it. Play build only.
class UpdateBanner extends ConsumerStatefulWidget {
  const UpdateBanner({super.key, this.now});

  /// For tests.
  final DateTime Function()? now;

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner> {
  bool _hidden = false;

  DateTime _now() => (widget.now ?? DateTime.now)();

  void _notNow() {
    ref
        .read(sharedPreferencesProvider)
        .setString(updateDismissedOnKey, _today(_now()));
    setState(() => _hidden = true);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appUpdateProvider);
    if (s.phase == AppUpdatePhase.none || _hidden) {
      return const SizedBox.shrink();
    }
    final dismissedToday =
        ref.read(sharedPreferencesProvider).getString(updateDismissedOnKey) ==
        _today(_now());
    if (s.phase == AppUpdatePhase.available &&
        dismissedToday &&
        s.behind < updateInsistBehind) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final controller = ref.read(appUpdateProvider.notifier);
    final (String title, Widget? action) = switch (s.phase) {
      AppUpdatePhase.available => (
        l10n.updateAvailableTitle,
        FilledButton.tonal(
          key: const Key('update-start'),
          onPressed: controller.update,
          child: Text(l10n.updateAvailableButton),
        ),
      ),
      AppUpdatePhase.downloading => (l10n.updateDownloading, null),
      _ => (
        l10n.updateReadyTitle,
        FilledButton.tonal(
          key: const Key('update-restart'),
          onPressed: controller.restart,
          child: Text(l10n.updateReadyButton),
        ),
      ),
    };
    return Card(
      key: const Key('update-banner'),
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                if (s.phase == AppUpdatePhase.downloading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (s.phase == AppUpdatePhase.available) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 36),
                child: Text(l10n.updateAvailableBody),
              ),
            ],
            if (action != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 28, top: 4),
                child: Wrap(
                  spacing: 8,
                  children: [
                    action,
                    if (s.phase == AppUpdatePhase.available)
                      TextButton(
                        key: const Key('update-not-now'),
                        onPressed: _notNow,
                        child: Text(l10n.alertsHintNotNow),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
