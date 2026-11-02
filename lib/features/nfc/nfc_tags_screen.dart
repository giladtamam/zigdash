import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n_ext.dart';
import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'nfc_tag_store.dart';
import 'nfc_tags.dart';

/// The NFC tags this phone wrote for a Home (3.3): what each does, when it
/// was last tapped, and a switch that makes this phone ignore it.
class NfcTagsScreen extends ConsumerStatefulWidget {
  const NfcTagsScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<NfcTagsScreen> createState() => _NfcTagsScreenState();
}

class _NfcTagsScreenState extends ConsumerState<NfcTagsScreen>
    with WidgetsBindingObserver {
  List<NfcTagRecord> _tags = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // A tap while ZigDash was in the background is written by Android:
  // read again when the screen comes back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    await ref.read(sharedPreferencesProvider).reload();
    if (!mounted) return;
    setState(
      () => _tags = ref.read(nfcTagStoreProvider).ofHome(widget.connectionId),
    );
  }

  Future<void> _rewrite(NfcTagRecord t) async {
    await showWriteNfcTag(
      context,
      connectionId: t.connectionId,
      action: t.action,
      target: t.target,
      label: t.label,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final store = ref.read(nfcTagStoreProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    String when(DateTime t) => DateFormat.MMMd(locale).add_Hm().format(t);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nfcTagsTitle)),
      body: _tags.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.nfcTagsEmpty,
                  key: const Key('nfc-tags-empty'),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              children: [
                for (final t in _tags)
                  ListTile(
                    key: Key('nfc-tag-${t.serial}'),
                    leading: Icon(
                      t.action == NfcTagAction.scene
                          ? Icons.auto_awesome_outlined
                          : Icons.power_settings_new,
                      color: t.off
                          ? theme.disabledColor
                          : theme.colorScheme.primary,
                    ),
                    title: Text(t.label.isEmpty ? l10n.nfcTagsTitle : t.label),
                    subtitle: Text(
                      [
                        if (t.off) l10n.nfcTagOffLabel,
                        t.action == NfcTagAction.scene
                            ? l10n.nfcTagRunsScene
                            : l10n.nfcTagSwitches,
                        l10n.nfcTagWritten(when(t.writtenAt)),
                        switch (store.lastTap(t.serial)) {
                          final at? => l10n.nfcTagLastTap(when(at)),
                          null => l10n.nfcTagNeverTapped,
                        },
                      ].join(' · '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          key: Key('nfc-tag-on-${t.serial}'),
                          value: !t.off,
                          onChanged: (on) async {
                            await store.setOff(t.serial, !on);
                            await _load();
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'rewrite') {
                              await _rewrite(t);
                            } else {
                              await store.forget(t.serial);
                              await _load();
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'rewrite',
                              child: Text(l10n.nfcTagRewrite),
                            ),
                            PopupMenuItem(
                              value: 'forget',
                              child: Text(l10n.nfcTagForget),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Text(
                    l10n.nfcTagsNote,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
    );
  }
}
