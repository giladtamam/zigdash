import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../data/repositories/connection_repo.dart';
import '../../l10n/app_localizations.dart';
import 'hub_backup.dart';
import 'hub_backup_providers.dart';

/// Hub backup (3.3, docs/design/hub-backup.md), in Settings › Home: when the
/// last backup was taken, Back up now, and the backups kept on this phone,
/// each of which can be saved as Zigbee2MQTT's own zip.
class HubBackupScreen extends ConsumerStatefulWidget {
  const HubBackupScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<HubBackupScreen> createState() => _HubBackupScreenState();
}

class _HubBackupScreenState extends ConsumerState<HubBackupScreen> {
  var _busy = false;
  HubBackupOutcome? _last;

  Future<void> _backUp() async {
    setState(() {
      _busy = true;
      _last = null;
    });
    final outcome = await ref
        .read(hubBackupRunnerProvider)
        .run(widget.connectionId, auto: false);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _last = outcome;
    });
  }

  Future<void> _saveCopy(HubBackupEntry entry) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final store = await ref.read(hubBackupStoreProvider.future);
    final zip = await store.read(entry);
    if (zip == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.hubBackupUnreadable)));
      return;
    }
    final home = await ref
        .read(connectionRepoProvider)
        .getById(widget.connectionId);
    final saved = await ref
        .read(hubBackupFilesProvider)
        .saveZip(hubBackupFileName(home?.name ?? '', entry.at), zip);
    if (!saved) return;
    ref
        .read(analyticsProvider)
        .track(const HubBackupEvent(HubBackupStep.savedCopy));
    messenger.showSnackBar(SnackBar(content: Text(l10n.hubBackupSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    String when(DateTime t) =>
        DateFormat.yMMMd(locale).add_Hm().format(t.toLocal());
    final backups =
        ref.watch(hubBackupsProvider(widget.connectionId)).valueOrNull ??
        const <HubBackupEntry>[];
    final newest = backups.firstOrNull;
    final message = _last == null ? null : _outcomeText(l10n, _last!);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.hubBackupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.hubBackupIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text(
            newest == null
                ? l10n.hubBackupNone
                : l10n.hubBackupLast(when(newest.at)),
            key: const Key('hub-backup-last'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('hub-backup-now'),
            onPressed: _busy ? null : _backUp,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.backup_outlined),
            label: Text(l10n.hubBackupNow),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message,
              key: const Key('hub-backup-result'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _last == HubBackupOutcome.made
                    ? null
                    : theme.colorScheme.error,
              ),
            ),
          ],
          if (backups.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.hubBackupKept, style: theme.textTheme.titleSmall),
            for (final b in backups)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(when(b.at)),
                trailing: IconButton(
                  tooltip: l10n.hubBackupSaveCopy,
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () => _saveCopy(b),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Text(l10n.hubBackupRestoreNote, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            l10n.hubBackupPrivate,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _outcomeText(AppLocalizations l10n, HubBackupOutcome o) => switch (o) {
  HubBackupOutcome.made => l10n.hubBackupMade,
  HubBackupOutcome.refused => l10n.hubBackupRefused,
  HubBackupOutcome.noAnswer => l10n.hubBackupNoAnswer,
  HubBackupOutcome.offline => l10n.hubBackupOffline,
  HubBackupOutcome.away => l10n.hubBackupAway,
  HubBackupOutcome.noBroker => l10n.hubBackupNoBroker,
};
