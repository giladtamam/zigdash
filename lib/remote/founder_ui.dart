import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/analytics/analytics.dart' show ProFrom;
import '../core/l10n/l10n_ext.dart';
import '../features/pro/pro.dart';
import '../features/pro/pro_screen.dart' show openPro;
import '../l10n/app_localizations.dart';
import 'founder.dart';
import 'remote_home.dart';
import 'remote_setup.dart';

/// Whether this build takes a founder's code: the Google Play build (and a
/// test relay), whether or not Play billing is available on the phone.
final founderCodeOfferedProvider = Provider<bool>((ref) => proFlavor == 'play' || relayIsTest);

/// "Feb 14, 2027" ("14 févr. 2027"), as the phone's language writes it.
String founderDate(BuildContext context, DateTime t) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(t.toLocal());

/// What an upgrade's answer says on screen; null when it worked.
String founderUpgradeText(AppLocalizations l10n, FounderUpgradeResult r) => switch (r) {
      FounderUpgradeResult.done => l10n.founderUpgraded,
      FounderUpgradeResult.taken => l10n.founderUpgradeTaken,
      FounderUpgradeResult.unreachable => l10n.remoteUnreachable,
      _ => l10n.founderUpgradeFailed,
    };

/// Moves the Home to this phone's Pro purchase (the person asked for it),
/// then says how it went.
Future<FounderUpgradeResult> runFounderUpgrade(WidgetRef ref, String connectionId, ScaffoldMessengerState messenger,
    AppLocalizations l10n) async {
  final r = await ref.read(founderUpgraderProvider).run(connectionId);
  ref.invalidate(founderStatusProvider(connectionId));
  messenger.showSnackBar(SnackBar(content: Text(founderUpgradeText(l10n, r))));
  return r;
}

/// On opening the Remote or Chat screen: a purchase made from a founder
/// line whose upgrade didn't reach the relay is tried again. Nothing runs
/// without that earlier yes.
Future<void> resumeFounderUpgrade(WidgetRef ref, String connectionId, ScaffoldMessengerState messenger,
    AppLocalizations l10n) async {
  if (!ref.read(founderUpgraderProvider).wanted(connectionId)) return;
  if (ref.read(proStatusProvider) != ProStatus.unlocked) return;
  FounderStatus? status;
  try {
    status = await ref.read(remoteHomeStoreProvider).readFounder(connectionId);
  } catch (_) {}
  if (status == null || !status.founder || status.deleted) return;
  await runFounderUpgrade(ref, connectionId, messenger, l10n);
}

/// The line a founder's Home shows near or after the end of its pass: what
/// happens, and the way on. Without Pro: Get Pro, remembered "for this
/// Home", so the purchase moves this Home when it succeeds. With Pro bought
/// elsewhere: "Use your Pro purchase for this Home?", and nothing happens
/// without a yes.
class FounderProLine extends ConsumerStatefulWidget {
  const FounderProLine({super.key, required this.connectionId, required this.text, required this.from});

  final String connectionId;
  final String text;
  final ProFrom from;

  @override
  ConsumerState<FounderProLine> createState() => _FounderProLineState();
}

class _FounderProLineState extends ConsumerState<FounderProLine> {
  bool _busy = false;

  String get _id => widget.connectionId;

  Future<void> _getPro() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final upgrader = ref.read(founderUpgraderProvider);
    await upgrader.remember(_id);
    if (!mounted) return;
    await openPro(context, from: widget.from);
    if (!mounted) return;
    if (ref.read(proStatusProvider) != ProStatus.unlocked) {
      // Back without buying: a later purchase elsewhere asks first.
      await upgrader.forget(_id);
      return;
    }
    setState(() => _busy = true);
    await runFounderUpgrade(ref, _id, messenger, l10n);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _usePro() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final yes = await confirmFounderUpgrade(context);
    if (yes != true || !mounted) return;
    setState(() => _busy = true);
    await runFounderUpgrade(ref, _id, messenger, l10n);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final owned = ref.watch(proStatusProvider) == ProStatus.unlocked;
    final buy = ref.watch(proStatusProvider) != ProStatus.unavailable;
    return Column(
      key: const Key('founder-pro-line'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.text, key: const Key('founder-line'), style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        if (owned)
          FilledButton(
            key: const Key('founder-use-pro'),
            onPressed: _busy ? null : _usePro,
            child: Text(l10n.founderUsePro),
          )
        else if (buy)
          FilledButton(
            key: const Key('founder-get-pro'),
            onPressed: _busy ? null : _getPro,
            child: Text(l10n.founderGetPro),
          ),
      ],
    );
  }
}

/// "Use your Pro purchase for this Home?": true only on a yes.
Future<bool?> confirmFounderUpgrade(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.founderUseProTitle),
      content: Text(l10n.founderUseProBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
        FilledButton(
          key: const Key('founder-use-pro-ok'),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.founderUsePro),
        ),
      ],
    ),
  );
}
