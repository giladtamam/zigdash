import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import 'pro.dart';

/// Opens the Pro screen. Settings and every Unlock lead here first, so
/// nobody meets Play's purchase sheet before knowing what Pro adds and what
/// stays free (2.9.6).
void openPro(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => const ProScreen()));

/// What Pro adds, what stays free, and why it exists: ZigDash is open
/// source, and Pro keeps it going. No donation link: in the Play build the
/// purchase is the only way to support it.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).track(const ProEvent(ProStep.screenShown));
  }

  /// App Review requires a way to restore a purchase (iOS build only).
  /// Says so when the Apple ID has none; success shows as Unlocked.
  Future<void> _restore() async {
    final messenger = ScaffoldMessenger.of(context);
    final none = context.l10n.proRestoreNone;
    await ref.read(proBillingProvider.notifier).restore();
    if (!mounted) return;
    if (ref.read(proStatusProvider) != ProStatus.unlocked) {
      messenger.showSnackBar(SnackBar(content: Text(none)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unlocked = ref.watch(proStatusProvider) == ProStatus.unlocked;
    final buy = ref.watch(proPurchaseProvider);
    final price = ref.watch(proPriceProvider).valueOrNull;

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
            if (proSold) item(Icons.public, l10n.proGetRemote),
            item(Icons.bolt_outlined, l10n.proGetAutomations),
            item(Icons.show_chart, l10n.proGetHistory),
            item(Icons.tablet_outlined, l10n.proGetWall),
            item(Icons.auto_awesome_outlined, l10n.proGetFuture),
            if (proSold) ...[
              const SizedBox(height: 4),
              Text(l10n.proRemoteFair, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 24),
            Text(l10n.proFreeTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              proFlavor == 'appstore' ? l10n.proFreeBodyIos : l10n.proFreeBody,
              style: theme.textTheme.bodyLarge,
            ),
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
              FilledButton(
                onPressed: buy,
                child: Text(
                  price == null ? l10n.proBuy : l10n.proBuyPrice(price),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                proFlavor == 'appstore' ? l10n.proOnceIos : l10n.proOnce,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              if (proFlavor == 'appstore') ...[
                const SizedBox(height: 8),
                TextButton(onPressed: _restore, child: Text(l10n.proRestore)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
