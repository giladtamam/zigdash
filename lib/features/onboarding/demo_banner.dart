import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/build/store_capture.dart';
import '../../core/analytics/analytics_events.dart'
    show HelpFrom, ZhaMoveFrom;
import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../data/repositories/connection_repo.dart';
import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../zha_move/zha_move.dart';
import 'demo_service.dart';

/// "You're in demo mode — Connect your home", shown on the demo home's
/// dashboards. Nothing on real homes. Connecting runs setup, which removes
/// the demo when it finishes.
class DemoBanner extends ConsumerWidget {
  const DemoBanner({super.key, required this.connectionId});
  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionByIdProvider(connectionId));
    if (storeCapture || !isDemoConnection(connection.valueOrNull?.host)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final banner = Material(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 8, 4),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline,
                size: 20, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.demoBannerText,
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.push(Routes.getHelpFrom(HelpFrom.demo.name)),
              child: Text(l10n.demoBannerHelp),
            ),
            TextButton(
              onPressed: () => context.push(Routes.setup),
              child: Text(l10n.demoBannerAction),
            ),
          ],
        ),
      ),
    );
    // 3.8: after a ZHA answer, the way from ZHA (zha-migration.md), on its
    // own line: the row above is already full on a small phone.
    if (!_answeredZha(ref)) return banner;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        banner,
        Material(
          color: scheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('demo-zha-move'),
                onPressed: () =>
                    showZhaMoveSheet(context, ref, ZhaMoveFrom.demo),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: Text(l10n.haConnectZhaMove),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Best effort: no preferences (golden tests) reads as no answer.
  bool _answeredZha(WidgetRef ref) {
    try {
      return ref.read(sharedPreferencesProvider).getBool(zhaAnsweredKey) ??
          false;
    } catch (_) {
      return false;
    }
  }
}
