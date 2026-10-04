import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/build/store_capture.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../data/repositories/connection_repo.dart';
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
    return Material(
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
              onPressed: () => context.push(Routes.setup),
              child: Text(l10n.demoBannerAction),
            ),
          ],
        ),
      ),
    );
  }
}
