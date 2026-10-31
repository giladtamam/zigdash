import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../data/repositories/connection_repo.dart';
import '../../l10n/app_localizations.dart';
import 'hub_backup.dart';
import 'hub_backup_providers.dart';
import 'hub_restore.dart';

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

  /// The result of the last restore, and whether it went through.
  String? _restoreText;
  var _restoreOk = false;

  Future<void> _restore(HubBackupEntry entry, String when) async {
    final l10n = context.l10n;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.hubBackupRestoreTitle),
        content: Text(
          '${l10n.hubBackupRestoreBody(when)}\n\n${l10n.hubBackupRestoreExtensions}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('hub-restore-go'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.hubBackupRestore),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    final stage = ValueNotifier<HubRestoreStage?>(null);
    final navigator = Navigator.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: ValueListenableBuilder<HubRestoreStage?>(
              valueListenable: stage,
              builder: (ctx, s, _) => Row(
                children: [
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(_stageText(l10n, s))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final (blocked, outcome) = await ref
        .read(hubRestoreRunnerProvider)
        .run(widget.connectionId, entry, onStage: (s) => stage.value = s);
    navigator.pop();
    stage.dispose();
    if (!mounted) return;
    setState(() {
      // Only the latest result shows.
      _last = null;
      _restoreOk = outcome == HubRestoreOutcome.restored;
      _restoreText = switch ((blocked, outcome)) {
        (HubRestoreBlocked.offline, _) => l10n.hubBackupOffline,
        (HubRestoreBlocked.away, _) => l10n.hubBackupAway,
        (HubRestoreBlocked.noBroker, _) => l10n.hubBackupNoBroker,
        (HubRestoreBlocked.unreadable, _) => l10n.hubBackupUnreadable,
        (_, HubRestoreOutcome.restored) => l10n.hubBackupRestored,
        (_, HubRestoreOutcome.extensionRefused) => l10n.hubBackupRestoreRefused,
        (_, HubRestoreOutcome.notBack) => l10n.hubBackupRestoreNotBack,
        _ => l10n.hubBackupRestoreNotWritten,
      };
    });
  }

  Future<void> _backUp() async {
    setState(() {
      _busy = true;
      _last = null;
      _restoreText = null;
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
          if (_restoreText != null) ...[
            const SizedBox(height: 12),
            Text(
              _restoreText!,
              key: const Key('hub-restore-result'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _restoreOk ? null : theme.colorScheme.error,
              ),
            ),
          ],
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.hubBackupRestore,
                      icon: const Icon(Icons.settings_backup_restore),
                      onPressed: _busy ? null : () => _restore(b, when(b.at)),
                    ),
                    IconButton(
                      tooltip: l10n.hubBackupSaveCopy,
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () => _saveCopy(b),
                    ),
                  ],
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

String _stageText(AppLocalizations l10n, HubRestoreStage? s) => switch (s) {
  HubRestoreStage.allowingExtensions => l10n.hubBackupRestoreStageAllow,
  HubRestoreStage.restarting => l10n.hubBackupRestoreStageRestart,
  _ => l10n.hubBackupRestoreStageSend,
};

String _outcomeText(AppLocalizations l10n, HubBackupOutcome o) => switch (o) {
  HubBackupOutcome.made => l10n.hubBackupMade,
  HubBackupOutcome.refused => l10n.hubBackupRefused,
  HubBackupOutcome.noAnswer => l10n.hubBackupNoAnswer,
  HubBackupOutcome.offline => l10n.hubBackupOffline,
  HubBackupOutcome.away => l10n.hubBackupAway,
  HubBackupOutcome.noBroker => l10n.hubBackupNoBroker,
};
