import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../data/repositories/connection_repo.dart';
import '../../l10n/app_localizations.dart';
import '../../remote/remote_setup.dart' show remoteFits;
import '../onboarding/demo_service.dart' show isDemoConnection;
import 'pro.dart';

/// Opens the Pro screen. Settings and every Unlock lead here first, so
/// nobody meets Play's purchase sheet before knowing what Pro adds and what
/// stays free (2.9.6).
void openPro(BuildContext context, {required ProFrom from}) {
  // Kept for the purchase events: a tap on the price says where it began.
  final scope = ProviderScope.containerOf(context, listen: false);
  scope.read(proFromProvider.notifier).state = from;
  // "The sale has ended" belongs to the visit in which the tap found it
  // gone, not to every later one.
  scope.read(proSaleEndedProvider.notifier).state = false;
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ProScreen(from: from)),
  );
}

/// Whether the Pro screen may promise remote control on this phone (3.4.4):
/// not when every real home here is one the relay can't serve (carried by
/// Home Assistant or by Zigbee2MQTT's page). No home yet counts as yes.
final proRemoteLineProvider = Provider.autoDispose<bool>((ref) {
  final homes = ref.watch(connectionsStreamProvider).valueOrNull;
  if (homes == null) return true;
  final real = homes.where((h) => !isDemoConnection(h.host));
  return real.isEmpty || real.any(remoteFits);
});

/// What Pro adds, what stays free, and why it exists: ZigDash is open
/// source, and Pro keeps it going. No donation link: in the Play build the
/// purchase is the only way to support it.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key, this.from});

  /// The view that opened it, for the usage events.
  final ProFrom? from;

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref
        .read(analyticsProvider)
        .track(ProEvent(ProStep.screenShown, from: widget.from));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back in front: a sale may have ended while the app was away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(proOfferProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unlocked = ref.watch(proStatusProvider) == ProStatus.unlocked;
    final buy = ref.watch(proPurchaseProvider);
    final price = ref.watch(proPriceProvider).valueOrNull;
    final offer = ref.watch(proOfferProvider).valueOrNull;
    final onSale = !unlocked && offer != null && offer.onSale(DateTime.now());
    final fullPrice = onSale
        ? offer.fullPrice(Localizations.localeOf(context).toLanguageTag())
        : null;
    final saleEnded = !onSale && ref.watch(proSaleEndedProvider);
    final remote = proFlavor == 'play' && ref.watch(proRemoteLineProvider);

    Widget item(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.proScreenIntro, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text(l10n.proWhatYouGet, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            // Remote control first (3.1.11): it is what people ask for.
            if (remote) item(Icons.public, l10n.proGetRemote),
            item(Icons.bolt_outlined, l10n.proGetAutomations),
            item(Icons.show_chart, l10n.proGetHistory),
            item(Icons.tablet_outlined, l10n.proGetWall),
            item(Icons.auto_awesome_outlined, l10n.proGetFuture),
            if (remote) ...[
              const SizedBox(height: 4),
              Text(l10n.proRemoteFair, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 24),
            Text(l10n.proFreeTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.proFreeBody, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 32),
            if (unlocked)
              Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.proUnlocked,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // The sale, in Play's own numbers: what it is, until when,
              // and the price it replaces. No countdown.
              if (onSale) ...[
                Text(
                  proSaleLine(context, l10n, offer),
                  key: const Key('pro-sale'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (fullPrice != null)
                  Text(
                    fullPrice,
                    key: const Key('pro-full-price'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              if (saleEnded) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.proSaleEnded,
                    key: const Key('pro-sale-ended'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: buy,
                child: Text(
                  price == null ? l10n.proBuy : l10n.proBuyPrice(price),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.proOnce,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Sale: 40% off until 30 November", from what Play says about the offer.
String proSaleLine(BuildContext context, AppLocalizations l10n, ProOffer offer) {
  final ends = offer.ends;
  final percent = offer.percent ?? 0;
  if (ends == null) return l10n.proSaleNoEnd(percent);
  return l10n.proSale(
    percent,
    MaterialLocalizations.of(context).formatMediumDate(ends),
  );
}
