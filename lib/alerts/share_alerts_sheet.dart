import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/l10n/l10n_ext.dart';
import 'alerts_config.dart';
import 'alerts_service.dart';

/// Share alerts (docs/design/alerts-2.3.md): an ntfy topic for the Home so
/// other people get its alerts with only the ntfy app, or this phone when
/// it has no Google services; plus Pushover for smoke and leak that repeat
/// until acknowledged. The text on these paths is not encrypted, and the
/// sheet says so.
class ShareAlertsSheet extends ConsumerStatefulWidget {
  const ShareAlertsSheet({super.key, required this.connectionId});

  final String connectionId;

  static Future<void> show(BuildContext context, String connectionId) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => ShareAlertsSheet(connectionId: connectionId),
      );

  @override
  ConsumerState<ShareAlertsSheet> createState() => _ShareAlertsSheetState();
}

class _ShareAlertsSheetState extends ConsumerState<ShareAlertsSheet> {
  final _user = TextEditingController();
  final _token = TextEditingController();
  final _server = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _user.dispose();
    _token.dispose();
    _server.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final config = ref.watch(alertsConfigProvider(widget.connectionId)).valueOrNull;
    if (config == null) return const SizedBox.shrink();
    if (!_filled) {
      _filled = true;
      _user.text = config.pushover?.user ?? '';
      _token.text = config.pushover?.token ?? '';
      _server.text = config.ntfy?.server ?? 'https://ntfy.sh';
    }
    final ntfy = config.ntfy;
    final link = ntfy == null ? null : _link(ntfy, config.home);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(l10n.alertsShare, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.alertsShareBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (link == null)
              FilledButton.tonal(
                onPressed: () => _update(config.copyWith(
                    ntfy: () => NtfySettings(topic: _newTopic(), server: _server.text.trim()))),
                child: Text(l10n.alertsShare),
              )
            else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.alertsShareLink),
                subtitle: Text(link, style: theme.textTheme.bodySmall),
                trailing: IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: l10n.alertsShareLink,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: link));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(l10n.alertsShareCopied)));
                    }
                  },
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.alertsGetWithNtfy),
                  ),
                  TextButton(
                    onPressed: () => _update(config.copyWith(
                        ntfy: () => NtfySettings(topic: _newTopic(), server: ntfy!.server))),
                    child: Text(l10n.alertsShareNewLink),
                  ),
                  TextButton(
                    onPressed: () => _update(config.copyWith(ntfy: () => null)),
                    child: Text(l10n.alertsShareOff),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.alertsHideNames),
                value: config.hideNames,
                onChanged: (v) => _update(config.copyWith(hideNames: v)),
              ),
              TextField(
                controller: _server,
                decoration: InputDecoration(labelText: l10n.alertsNtfyServer),
                keyboardType: TextInputType.url,
                onSubmitted: (v) => _update(config.copyWith(
                    ntfy: () => NtfySettings(topic: ntfy!.topic, server: v.trim()))),
              ),
            ],
            const Divider(height: 32),
            Text(l10n.alertsPushover, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.alertsPushoverBody, style: theme.textTheme.bodyMedium),
            TextField(
              controller: _user,
              decoration: InputDecoration(labelText: l10n.alertsPushoverUser),
            ),
            TextField(
              controller: _token,
              decoration: InputDecoration(labelText: l10n.alertsPushoverToken),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () {
                  final user = _user.text.trim(), token = _token.text.trim();
                  _update(config.copyWith(
                      pushover: () => user.isEmpty || token.isEmpty
                          ? null
                          : PushoverSettings(user: user, token: token)));
                },
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _link(NtfySettings n, String home) {
    final host = Uri.parse(n.server).host;
    final secure = n.server.startsWith('https');
    return 'ntfy://$host/${n.topic}?display=${Uri.encodeQueryComponent(home)}${secure ? '' : '&secure=false'}';
  }

  static String _newTopic() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random.secure();
    return 'zd-${List.generate(22, (_) => chars[r.nextInt(chars.length)]).join()}';
  }

  Future<void> _update(AlertsConfig config) async {
    final service = ref.read(alertsServiceProvider);
    await service.save(config);
    await service.publish(widget.connectionId);
  }
}
