import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/review/review_prompt_controller.dart';
import '../../data/database/tables/connections.dart';
import '../../data/repositories/connection_repo.dart';
import '../../remote/remote_setup.dart' show remoteHomeProvider;
import '../onboarding/demo_service.dart' show isDemoConnection;
import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'pro.dart';
import 'pro_screen.dart';

/// Days with live data before the sale card shows: new users are still
/// finding their way, and nobody is sold to on day one.
const saleCardAfterDays = 3;

/// "1" once this offer's card was opened or put away: asked once per sale.
String saleCardDoneKey(String offerId) => 'sale_card_done_$offerId';

/// "1" once this offer's card was counted as shown.
String saleCardShownKey(String offerId) => 'sale_card_shown_$offerId';

/// Play's offer, held for as long as the app runs, so going back to the
/// Devices tab neither asks Play again nor moves the list under a finger.
/// The card refreshes [proOfferProvider] when the app comes back to the front.
final saleCardOfferProvider = FutureProvider<ProOffer?>(
  (ref) => ref.watch(proOfferProvider.future),
);

/// Which line [SaleCard] can truthfully show for a home.
enum SaleCardLine { remote, homeAssistant }

/// The line for [connectionId], or null while no card may show. Everything
/// here is known without asking Play. A Zigbee2MQTT-page home has no Engine,
/// so neither remote control, history nor automations can be promised; a
/// phone paired without Pro already has remote control.
final saleCardLineProvider = Provider.autoDispose.family<SaleCardLine?, String>(
  (ref, connectionId) {
    if (ref.watch(proStatusProvider) != ProStatus.locked) return null;
    final prefs = ref.watch(sharedPreferencesProvider);
    final days = prefs.getInt(ReviewPromptController.kSessions) ?? 0;
    if (days < saleCardAfterDays) return null;
    final home = ref.watch(connectionByIdProvider(connectionId)).valueOrNull;
    if (home == null || isDemoConnection(home.host)) return null;
    final paired = ref.watch(remoteHomeProvider(connectionId));
    if (!paired.hasValue || paired.value != null) return null;
    return switch (transportOf(home.transport)) {
      ConnectionTransport.mqtt => SaleCardLine.remote,
      ConnectionTransport.homeAssistant => SaleCardLine.homeAssistant,
      ConnectionTransport.z2mPage => null,
    };
  },
);

/// One slim card at the top of the Devices list while Play runs a sale on
/// Pro (devices-sale-card.md). Opens the Pro screen, where the price and
/// what stays free are; asked once per sale.
class SaleCard extends ConsumerWidget {
  const SaleCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final line = ref.watch(saleCardLineProvider(connectionId));
    // Play is only asked for someone who could see the card.
    if (line == null) return const SizedBox.shrink();
    return _OfferedSaleCard(line: line);
  }
}

class _OfferedSaleCard extends ConsumerStatefulWidget {
  const _OfferedSaleCard({required this.line});

  final SaleCardLine line;

  @override
  ConsumerState<_OfferedSaleCard> createState() => _OfferedSaleCardState();
}

class _OfferedSaleCardState extends ConsumerState<_OfferedSaleCard>
    with WidgetsBindingObserver {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(proOfferProvider);
  }

  void _countShown(String offerId) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getString(saleCardShownKey(offerId)) != null) return;
    prefs.setString(saleCardShownKey(offerId), '1');
    ref.read(analyticsProvider).track(const SaleCardEvent(SaleCardStep.shown));
  }

  void _finish(String offerId, SaleCardStep step) {
    ref
        .read(sharedPreferencesProvider)
        .setString(saleCardDoneKey(offerId), '1');
    ref.read(analyticsProvider).track(SaleCardEvent(step));
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final offer = ref.watch(saleCardOfferProvider).valueOrNull;
    final offerId = offer?.offerId;
    if (_done ||
        offer == null ||
        offerId == null ||
        !offer.onSale(DateTime.now()) ||
        ref
                .watch(sharedPreferencesProvider)
                .getString(saleCardDoneKey(offerId)) !=
            null) {
      return const SizedBox.shrink();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _countShown(offerId);
    });
    final l10n = context.l10n;
    return Card(
      key: const Key('sale-card'),
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(Icons.local_offer_outlined),
        title: Text(proSaleLine(context, l10n, offer)),
        subtitle: Text(switch (widget.line) {
          SaleCardLine.remote => l10n.saleCardRemote,
          SaleCardLine.homeAssistant => l10n.saleCardHomeAssistant,
        }),
        trailing: IconButton(
          key: const Key('sale-card-close'),
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => _finish(offerId, SaleCardStep.closed),
        ),
        onTap: () {
          _finish(offerId, SaleCardStep.opened);
          openPro(context, from: ProFrom.saleCard);
        },
      ),
    );
  }
}
