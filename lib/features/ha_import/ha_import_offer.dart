import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../settings/providers/settings_controller.dart';

/// The home that setup found next to Home Assistant, whose dashboard offers
/// the import once (docs/design/ha-import.md, "Where it starts"). Kept in
/// preferences until the card is answered; one home at a time.
class HaImportOffer extends Notifier<String?> {
  static const key = 'ha_import_offer';

  /// Offered because of a move from ZHA (3.8): Home Assistant may not be
  /// on the scanned network, and the names come from ZHA too.
  static const zhaKey = 'ha_import_offer_zha';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(key);

  bool get fromZha =>
      ref.read(sharedPreferencesProvider).getBool(zhaKey) ?? false;

  Future<void> offer(String connectionId, {bool fromZha = false}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(key, connectionId);
    if (fromZha) {
      await prefs.setBool(zhaKey, true);
    } else {
      await prefs.remove(zhaKey);
    }
    state = connectionId;
  }

  Future<void> clear() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(key);
    await prefs.remove(zhaKey);
    state = null;
  }
}

final haImportOfferProvider = NotifierProvider<HaImportOffer, String?>(
  HaImportOffer.new,
);

/// "Bring your names and rooms from Home Assistant?" on the new home's
/// dashboard, once. Either answer ends the offer; Settings › Home keeps the
/// import.
class HaImportOfferCard extends ConsumerWidget {
  const HaImportOfferCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(haImportOfferProvider) != connectionId) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final offer = ref.read(haImportOfferProvider.notifier);
    final analytics = ref.read(analyticsProvider);
    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.haImportOfferTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(
                offer.fromZha
                    ? l10n.haImportOfferBodyZha
                    : l10n.haImportOfferBody,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    analytics.track(
                      const HaImportEvent(HaImportStep.offerDeclined),
                    );
                    offer.clear();
                  },
                  child: Text(l10n.haImportOfferLater),
                ),
                FilledButton(
                  onPressed: () {
                    analytics.track(
                      const HaImportEvent(HaImportStep.offerAccepted),
                    );
                    offer.clear();
                    context.push(Routes.homeHaImport(connectionId));
                  },
                  child: Text(l10n.haImportOfferGo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
